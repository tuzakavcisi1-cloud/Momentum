using Momentum.Application.Abstractions.Sync;
using Momentum.Domain.Sync;
using Momentum.Infrastructure.Persistence;

namespace Momentum.Infrastructure.Sync;

/// <summary>
/// Raw-SQL sync store (GOREV slice-2b1 D2/D4). Advisory locks in the FIXED client->entity order,
/// hydrate via <see cref="SyncRowHydration"/>, and persist the delta the DOMAIN decided with
/// UNCONDITIONAL upserts (no SQL LWW — correctness comes from the entity lock + the Domain decision, §5).
/// </summary>
public sealed class SyncStore(SyncDbContext db) : ISyncStore
{
    public async Task LockClientAsync(Guid clientId, CancellationToken cancellationToken)
    {
        await using var command = await db.CreateRawCommandAsync(
            "SELECT pg_advisory_xact_lock(hashtextextended('sync_client:' || @c::text, 0))", cancellationToken);
        command.Parameters.AddWithValue("c", clientId);
        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    public async Task LockEntityAsync(string entityType, Guid entityId, CancellationToken cancellationToken)
    {
        await using var command = await db.CreateRawCommandAsync(
            "SELECT pg_advisory_xact_lock(hashtextextended('sync_entity:' || @t || ':' || @e::text, 0))", cancellationToken);
        command.Parameters.AddWithValue("t", entityType);
        command.Parameters.AddWithValue("e", entityId);
        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    public Task HydrateAsync(EntityState target, string entityType, Guid entityId, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(target);
        return SyncRowHydration.HydrateAsync(db, target, entityType, entityId, cancellationToken);
    }

    public async Task PersistDeltaAsync(ChangeOperation op, EntityState state, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(op);
        ArgumentNullException.ThrowIfNull(state);

        foreach (var field in op.Fields.Keys)
        {
            if (state.Fields.TryGetValue(field, out var register) && register.HasValue)
            {
                await UpsertScalarAsync(op.EntityType, op.EntityId, field, register.Value, register.Key, cancellationToken);
            }
        }

        foreach (var field in op.Order.Keys)
        {
            if (state.Orders.TryGetValue(field, out var register) && register.HasValue)
            {
                await UpsertScalarAsync(op.EntityType, op.EntityId, field, register.Value, register.Key, cancellationToken);
            }
        }

        foreach (var groupName in op.Groups.Keys)
        {
            if (state.Groups.TryGetValue(groupName, out var group) && group.HasValue)
            {
                await PersistGroupAsync(op.EntityType, op.EntityId, groupName, group, cancellationToken);
            }
        }

        foreach (var (setName, delta) in op.Sets)
        {
            await PersistSetAsync(op.EntityType, op.EntityId, setName, delta, state, cancellationToken);
        }
    }

    private async Task UpsertScalarAsync(string entityType, Guid entityId, string field, string? value, HlcKey key, CancellationToken cancellationToken)
    {
        await using var command = await db.CreateRawCommandAsync(
            "INSERT INTO sync_scalar_meta (entity_type, entity_id, field, value, hlc, win_operation_id) " +
            "VALUES (@t, @e, @f, @v, @h, @w) " +
            "ON CONFLICT (entity_type, entity_id, field) DO UPDATE SET value = excluded.value, hlc = excluded.hlc, win_operation_id = excluded.win_operation_id",
            cancellationToken);
        command.Parameters.AddWithValue("t", entityType);
        command.Parameters.AddWithValue("e", entityId);
        command.Parameters.AddWithValue("f", field);
        command.Parameters.AddWithValue("v", (object?)value ?? DBNull.Value);
        command.Parameters.AddWithValue("h", key.Hlc.Encode());
        command.Parameters.AddWithValue("w", key.OperationId);
        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    private async Task PersistGroupAsync(string entityType, Guid entityId, string groupName, ResolvedGroupField group, CancellationToken cancellationToken)
    {
        // Marker row (field == group name, value NULL) is the SOLE authority for the group HlcKey (B5).
        await UpsertScalarAsync(entityType, entityId, groupName, null, group.Key, cancellationToken);

        foreach (var (member, value) in group.Fields)
        {
            await UpsertScalarAsync(entityType, entityId, $"{groupName}.{member}", value, group.Key, cancellationToken);
        }

        // REPLACE: delete member rows the winner did not write (registry names are dotless -> no false positive).
        var keep = group.Fields.Keys.Select(member => $"{groupName}.{member}").ToArray();
        await using var command = await db.CreateRawCommandAsync(
            "DELETE FROM sync_scalar_meta WHERE entity_type = @t AND entity_id = @e AND field LIKE @prefix AND field <> ALL(@keep)",
            cancellationToken);
        command.Parameters.AddWithValue("t", entityType);
        command.Parameters.AddWithValue("e", entityId);
        command.Parameters.AddWithValue("prefix", groupName + ".%");
        command.Parameters.AddWithValue("keep", keep);
        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    private async Task PersistSetAsync(string entityType, Guid entityId, string setName, SetDelta delta, EntityState state, CancellationToken cancellationToken)
    {
        state.TryGetSet(setName, out var set);

        foreach (var add in delta.Adds)
        {
            Hlc? hlc = add.Hlc;
            var cancelled = false;
            if (set is not null && set.TryGetTag(add.Element, add.Tag, out var resolvedHlc, out var resolvedCancelled))
            {
                hlc = resolvedHlc;
                cancelled = resolvedCancelled;
            }

            await UpsertTagAsync(entityType, entityId, setName, add.Element, add.Tag, hlc, cancelled, cancellationToken);
        }

        foreach (var remove in delta.Removes)
        {
            foreach (var observed in remove.Observed)
            {
                await TombstoneTagAsync(entityType, entityId, setName, remove.Element, observed, cancellationToken);
            }

            await InsertRemoveStampAsync(entityType, entityId, setName, remove.Element, remove.Hlc, cancellationToken);
        }
    }

    private async Task UpsertTagAsync(string entityType, Guid entityId, string setName, string element, Guid tag, Hlc? hlc, bool cancelled, CancellationToken cancellationToken)
    {
        // A later add of an already-cancelled tag ONLY fills hlc (cancelled stays -> born-dead stamp kept, B4).
        await using var command = await db.CreateRawCommandAsync(
            "INSERT INTO sync_orset_tags (entity_type, entity_id, set_name, element, add_tag, hlc, cancelled) " +
            "VALUES (@t, @e, @s, @el, @tag, @h, @c) " +
            "ON CONFLICT (entity_type, entity_id, set_name, element, add_tag) DO UPDATE SET hlc = excluded.hlc",
            cancellationToken);
        AddSetKey(command, entityType, entityId, setName, element, tag);
        command.Parameters.AddWithValue("h", (object?)hlc?.Encode() ?? DBNull.Value);
        command.Parameters.AddWithValue("c", cancelled);
        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    private async Task TombstoneTagAsync(string entityType, Guid entityId, string setName, string element, Guid tag, CancellationToken cancellationToken)
    {
        // Unseen tag -> (hlc NULL, cancelled=true) marker; existing tag -> just cancel (keep hlc). (B4)
        await using var command = await db.CreateRawCommandAsync(
            "INSERT INTO sync_orset_tags (entity_type, entity_id, set_name, element, add_tag, hlc, cancelled) " +
            "VALUES (@t, @e, @s, @el, @tag, NULL, true) " +
            "ON CONFLICT (entity_type, entity_id, set_name, element, add_tag) DO UPDATE SET cancelled = true",
            cancellationToken);
        AddSetKey(command, entityType, entityId, setName, element, tag);
        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    private async Task InsertRemoveStampAsync(string entityType, Guid entityId, string setName, string element, Hlc hlc, CancellationToken cancellationToken)
    {
        await using var command = await db.CreateRawCommandAsync(
            "INSERT INTO sync_orset_removes (id, entity_type, entity_id, set_name, element, hlc) VALUES (@id, @t, @e, @s, @el, @h)",
            cancellationToken);
        command.Parameters.AddWithValue("id", Guid.CreateVersion7());
        command.Parameters.AddWithValue("t", entityType);
        command.Parameters.AddWithValue("e", entityId);
        command.Parameters.AddWithValue("s", setName);
        command.Parameters.AddWithValue("el", element);
        command.Parameters.AddWithValue("h", hlc.Encode());
        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    private static void AddSetKey(Npgsql.NpgsqlCommand command, string entityType, Guid entityId, string setName, string element, Guid tag)
    {
        command.Parameters.AddWithValue("t", entityType);
        command.Parameters.AddWithValue("e", entityId);
        command.Parameters.AddWithValue("s", setName);
        command.Parameters.AddWithValue("el", element);
        command.Parameters.AddWithValue("tag", tag);
    }
}

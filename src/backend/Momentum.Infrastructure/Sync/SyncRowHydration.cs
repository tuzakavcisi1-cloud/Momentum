using Momentum.Domain.Sync;
using Momentum.Infrastructure.Persistence;

namespace Momentum.Infrastructure.Sync;

/// <summary>
/// Rebuilds a Domain <see cref="EntityState"/> from the persisted rows (GOREV slice-2b1 D0/D4). Channel
/// routing uses the ONE registry (<see cref="FieldStrategyRegistry.TryGetStrategy"/>) — no second copy.
/// Group rows are reassembled to a single <see cref="HlcKey"/> from the marker; member disagreement throws.
/// </summary>
internal static class SyncRowHydration
{
    public static async Task HydrateAsync(SyncDbContext db, EntityState target, string entityType, Guid entityId, CancellationToken ct)
    {
        var registry = FieldStrategyRegistry.Default;

        var scalarRows = await ReadScalarRowsAsync(db, entityType, entityId, ct);
        var groupMarkers = new Dictionary<string, HlcKey>(StringComparer.Ordinal);
        var groupMembers = new Dictionary<string, Dictionary<string, string?>>(StringComparer.Ordinal);
        var groupMemberKeys = new Dictionary<string, HlcKey>(StringComparer.Ordinal);

        foreach (var (field, value, hlcText, winOperationId) in scalarRows)
        {
            if (!registry.TryGetStrategy(entityType, field, out var strategy))
            {
                continue;
            }

            var key = new HlcKey(Hlc.Parse(hlcText), winOperationId);
            switch (strategy)
            {
                case FieldStrategy.ScalarLww:
                    target.LoadField(field, value, key);
                    break;
                case FieldStrategy.FractionalIndex:
                    target.LoadOrder(field, value, key);
                    break;
                case FieldStrategy.ResolvedGroup:
                    var dot = field.IndexOf('.', StringComparison.Ordinal);
                    if (dot < 0)
                    {
                        groupMarkers[field] = key; // marker row
                    }
                    else
                    {
                        var group = field[..dot];
                        var member = field[(dot + 1)..];
                        if (!groupMembers.TryGetValue(group, out var members))
                        {
                            members = new Dictionary<string, string?>(StringComparer.Ordinal);
                            groupMembers[group] = members;
                        }

                        members[member] = value;
                        if (groupMemberKeys.TryGetValue(group, out var existing) && !existing.Equals(key))
                        {
                            throw new InvalidOperationException($"Corrupt group '{group}': member keys disagree.");
                        }

                        groupMemberKeys[group] = key;
                    }

                    break;
                default:
                    break;
            }
        }

        foreach (var (group, markerKey) in groupMarkers)
        {
            if (groupMemberKeys.TryGetValue(group, out var memberKey) && !memberKey.Equals(markerKey))
            {
                throw new InvalidOperationException($"Corrupt group '{group}': member key disagrees with marker.");
            }

            var fields = groupMembers.TryGetValue(group, out var members)
                ? members
                : new Dictionary<string, string?>(StringComparer.Ordinal);
            target.LoadGroup(group, fields, markerKey);
        }

        foreach (var (setName, element, tag, hlcText, cancelled) in await ReadTagRowsAsync(db, entityType, entityId, ct))
        {
            target.GetOrCreateSet(setName).LoadTag(element, tag, hlcText is null ? null : Hlc.Parse(hlcText), cancelled);
        }

        foreach (var (setName, element, hlcText) in await ReadRemoveRowsAsync(db, entityType, entityId, ct))
        {
            target.GetOrCreateSet(setName).LoadRemoveStamp(element, Hlc.Parse(hlcText));
        }
    }

    private static async Task<List<(string Field, string? Value, string Hlc, Guid Win)>> ReadScalarRowsAsync(
        SyncDbContext db, string entityType, Guid entityId, CancellationToken ct)
    {
        await using var command = await db.CreateRawCommandAsync(
            "SELECT field, value, hlc, win_operation_id FROM sync_scalar_meta WHERE entity_type = @t AND entity_id = @e", ct);
        command.Parameters.AddWithValue("t", entityType);
        command.Parameters.AddWithValue("e", entityId);

        var rows = new List<(string, string?, string, Guid)>();
        await using var reader = await command.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
        {
            rows.Add((reader.GetString(0), reader.IsDBNull(1) ? null : reader.GetString(1), reader.GetString(2), reader.GetGuid(3)));
        }

        return rows;
    }

    private static async Task<List<(string SetName, string Element, Guid Tag, string? Hlc, bool Cancelled)>> ReadTagRowsAsync(
        SyncDbContext db, string entityType, Guid entityId, CancellationToken ct)
    {
        await using var command = await db.CreateRawCommandAsync(
            "SELECT set_name, element, add_tag, hlc, cancelled FROM sync_orset_tags WHERE entity_type = @t AND entity_id = @e", ct);
        command.Parameters.AddWithValue("t", entityType);
        command.Parameters.AddWithValue("e", entityId);

        var rows = new List<(string, string, Guid, string?, bool)>();
        await using var reader = await command.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
        {
            rows.Add((reader.GetString(0), reader.GetString(1), reader.GetGuid(2), reader.IsDBNull(3) ? null : reader.GetString(3), reader.GetBoolean(4)));
        }

        return rows;
    }

    private static async Task<List<(string SetName, string Element, string Hlc)>> ReadRemoveRowsAsync(
        SyncDbContext db, string entityType, Guid entityId, CancellationToken ct)
    {
        await using var command = await db.CreateRawCommandAsync(
            "SELECT set_name, element, hlc FROM sync_orset_removes WHERE entity_type = @t AND entity_id = @e", ct);
        command.Parameters.AddWithValue("t", entityType);
        command.Parameters.AddWithValue("e", entityId);

        var rows = new List<(string, string, string)>();
        await using var reader = await command.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
        {
            rows.Add((reader.GetString(0), reader.GetString(1), reader.GetString(2)));
        }

        return rows;
    }
}

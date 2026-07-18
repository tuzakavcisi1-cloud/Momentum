using System.Globalization;
using Microsoft.EntityFrameworkCore;
using Momentum.Application.Abstractions.Sync;
using Momentum.Domain.Sync;
using Momentum.Infrastructure.Persistence;
using EntityState = Momentum.Domain.Sync.EntityState;

namespace Momentum.Infrastructure.Sync;

/// <summary>
/// Pull side — RAW SQL (GOREV slice-2b1 D5/D6). Incremental changes are bounded by the
/// <c>pg_snapshot_xmin</c> horizon and ordered by <c>(commit_xid, server_seq)</c>; the full snapshot
/// captures the horizon in one REPEATABLE READ txn and returns the <c>(horizon, 0)</c> continuation.
/// </summary>
public sealed class SyncPuller(SyncDbContext db) : ISyncPuller
{
    private const int PageSize = 500;

    public async Task<bool> ShouldResyncAsync(SyncCursor since, CancellationToken cancellationToken)
    {
        await using var command = await db.CreateRawCommandAsync(
            "SELECT gc_horizon_xid::text, gc_horizon_seq FROM sync_gc_state WHERE id = 1", cancellationToken);
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken) || reader.IsDBNull(0))
        {
            return false; // no GC horizon set -> never resync
        }

        var horizon = new SyncCursor(ulong.Parse(reader.GetString(0), CultureInfo.InvariantCulture), reader.GetInt64(1));
        return ResyncPolicy.ShouldResync(since, horizon);
    }

    public async Task<PullPage> PullIncrementalAsync(Guid actorId, SyncCursor since, CancellationToken cancellationToken)
    {
        // xid8 has no bigint cast in Postgres (M1): pass sinceXid as text + ::xid8.
        await using var command = await db.CreateRawCommandAsync(
            "SELECT commit_xid::text, server_seq, payload::text FROM outbox_messages " +
            "WHERE commit_xid < pg_snapshot_xmin(pg_current_snapshot()) " +
            "AND (commit_xid, server_seq) > (@sinceXid::xid8, @sinceSeq) " +
            "AND owner_id = @actorId " +
            "ORDER BY commit_xid, server_seq LIMIT " + PageSize,
            cancellationToken);
        command.Parameters.AddWithValue("sinceXid", since.Xid.ToString(CultureInfo.InvariantCulture));
        command.Parameters.AddWithValue("sinceSeq", since.Seq);
        command.Parameters.AddWithValue("actorId", actorId);

        var changes = new List<ChangeRecord>();
        await using (var reader = await command.ExecuteReaderAsync(cancellationToken))
        {
            while (await reader.ReadAsync(cancellationToken))
            {
                var cursor = new SyncCursor(ulong.Parse(reader.GetString(0), CultureInfo.InvariantCulture), reader.GetInt64(1));
                changes.Add(new ChangeRecord(cursor, reader.GetString(2)));
            }
        }

        var next = changes.Count > 0 ? changes[^1].Cursor : since;
        return new PullPage(changes, next, changes.Count == PageSize);
    }

    public async Task<SnapshotPage> SnapshotAsync(Guid actorId, CancellationToken cancellationToken)
    {
        await using var transaction = await db.Database.BeginTransactionAsync(System.Data.IsolationLevel.RepeatableRead, cancellationToken);

        var horizon = await ReadHorizonAsync(cancellationToken);
        var owned = await ReadOwnedEntitiesAsync(actorId, cancellationToken);

        var entities = new List<SnapshotEntity>(owned.Count);
        foreach (var (entityType, entityId) in owned)
        {
            var state = new EntityState();
            await SyncRowHydration.HydrateAsync(db, state, entityType, entityId, cancellationToken);
            entities.Add(Project(entityType, entityId, state));
        }

        await transaction.CommitAsync(cancellationToken);
        return new SnapshotPage(entities, SyncCursor.AtHorizon(horizon));
    }

    private async Task<ulong> ReadHorizonAsync(CancellationToken cancellationToken)
    {
        await using var command = await db.CreateRawCommandAsync(
            "SELECT pg_snapshot_xmin(pg_current_snapshot())::text", cancellationToken);
        var text = (string)(await command.ExecuteScalarAsync(cancellationToken))!;
        return ulong.Parse(text, CultureInfo.InvariantCulture);
    }

    private async Task<List<(string EntityType, Guid EntityId)>> ReadOwnedEntitiesAsync(Guid actorId, CancellationToken cancellationToken)
    {
        await using var command = await db.CreateRawCommandAsync(
            "SELECT DISTINCT aggregate_type, aggregate_id FROM outbox_messages WHERE owner_id = @actorId " +
            "ORDER BY aggregate_type, aggregate_id", cancellationToken);
        command.Parameters.AddWithValue("actorId", actorId);

        var result = new List<(string, Guid)>();
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            result.Add((reader.GetString(0), reader.GetGuid(1)));
        }

        return result;
    }

    private static SnapshotEntity Project(string entityType, Guid entityId, EntityState entity)
    {
        var scalars = new List<SnapshotScalar>();
        foreach (var (field, register) in entity.Fields)
        {
            if (register.HasValue)
            {
                scalars.Add(new SnapshotScalar(field, register.Value, register.Key.Hlc, register.Key.OperationId));
            }
        }

        foreach (var (field, register) in entity.Orders)
        {
            if (register.HasValue)
            {
                scalars.Add(new SnapshotScalar(field, register.Value, register.Key.Hlc, register.Key.OperationId));
            }
        }

        var groups = new List<SnapshotGroup>();
        foreach (var (name, group) in entity.Groups)
        {
            if (group.HasValue)
            {
                groups.Add(new SnapshotGroup(name, group.Fields, group.Key.Hlc, group.Key.OperationId));
            }
        }

        var sets = new List<SnapshotSet>();
        foreach (var (setName, set) in entity.Sets)
        {
            var elements = set.DumpTags()
                .Where(tag => tag is { Cancelled: false, Hlc: not null })
                .GroupBy(tag => tag.Element, StringComparer.Ordinal)
                .Select(group => new SnapshotSetElement(
                    group.Key,
                    group.Select(tag => new SnapshotActiveTag(tag.Tag, tag.Hlc!.Value)).ToList()))
                .ToList();

            if (elements.Count > 0)
            {
                sets.Add(new SnapshotSet(setName, elements));
            }
        }

        return new SnapshotEntity(entityType, entityId, scalars, sets, groups);
    }
}

using Momentum.Domain.Sync;

namespace Momentum.Application.Abstractions.Sync;

/// <summary>
/// Pull side (ADR 0002 K2-E2/E4/C6, GOREV slice-2b1 D5/D6) — RAW SQL, never EF LINQ. Incremental pull
/// is bounded by the <c>pg_snapshot_xmin</c> horizon; the full snapshot captures the horizon and
/// returns the <c>(horizon, 0)</c> continuation cursor.
/// </summary>
public interface ISyncPuller
{
    /// <summary><c>since &lt; (gc_horizon_xid, gc_horizon_seq)</c> -> caller must resync (horizon NULL -> never).</summary>
    Task<bool> ShouldResyncAsync(SyncCursor since, CancellationToken cancellationToken);

    /// <summary>Incremental changes visible below the xmin horizon, after <paramref name="since"/>, owned by the actor.</summary>
    Task<PullPage> PullIncrementalAsync(Guid actorId, SyncCursor since, CancellationToken cancellationToken);

    /// <summary>Full snapshot in one REPEATABLE READ txn; continuation cursor is (horizon, 0).</summary>
    Task<SnapshotPage> SnapshotAsync(Guid actorId, CancellationToken cancellationToken);
}

public sealed record ChangeRecord(SyncCursor Cursor, string PayloadJson);

public sealed record PullPage(IReadOnlyList<ChangeRecord> Changes, SyncCursor NextCursor, bool HasMore);

public sealed record SnapshotScalar(string Field, string? Value, Hlc Hlc, Guid WinOperationId);

public sealed record SnapshotActiveTag(Guid Tag, Hlc Hlc);

public sealed record SnapshotSetElement(string Element, IReadOnlyList<SnapshotActiveTag> ActiveTags);

public sealed record SnapshotSet(string SetName, IReadOnlyList<SnapshotSetElement> Elements);

public sealed record SnapshotGroup(string Group, IReadOnlyDictionary<string, string?> Fields, Hlc Hlc, Guid WinOperationId);

public sealed record SnapshotEntity(
    string EntityType,
    Guid EntityId,
    IReadOnlyList<SnapshotScalar> Scalars,
    IReadOnlyList<SnapshotSet> Sets,
    IReadOnlyList<SnapshotGroup> Groups);

public sealed record SnapshotPage(IReadOnlyList<SnapshotEntity> Entities, SyncCursor NextCursor);

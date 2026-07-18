namespace Momentum.Domain.Sync;

/// <summary>
/// Commit-visibility cursor (ADR 0002 K2-E2/E4). Ordered by <c>(Xid, Seq)</c>. The snapshot
/// continuation cursor is <see cref="AtHorizon"/> = <c>(xid, 0)</c>; real outbox rows have
/// <c>Seq &gt;= 1</c> (server_seq IDENTITY START WITH 1) so the sentinel sorts strictly before any
/// real row of the same xid. That <c>Seq &gt;= 1</c> row invariant is enforced in slice-2b (DB).
/// </summary>
public readonly record struct SyncCursor(ulong Xid, long Seq) : IComparable<SyncCursor>
{
    public static SyncCursor AtHorizon(ulong xid) => new(xid, 0);

    public int CompareTo(SyncCursor other)
    {
        var c = Xid.CompareTo(other.Xid);
        return c != 0 ? c : Seq.CompareTo(other.Seq);
    }

    public static bool operator <(SyncCursor left, SyncCursor right) => left.CompareTo(right) < 0;

    public static bool operator >(SyncCursor left, SyncCursor right) => left.CompareTo(right) > 0;

    public static bool operator <=(SyncCursor left, SyncCursor right) => left.CompareTo(right) <= 0;

    public static bool operator >=(SyncCursor left, SyncCursor right) => left.CompareTo(right) >= 0;
}

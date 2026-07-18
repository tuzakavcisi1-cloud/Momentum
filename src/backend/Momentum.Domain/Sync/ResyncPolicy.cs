namespace Momentum.Domain.Sync;

/// <summary>
/// GC-horizon resync trigger (ADR 0002 K2-C6/H7a): an incremental pull whose <paramref name="since"/>
/// cursor is below the GC horizon cannot be served incrementally and must resync.
/// </summary>
public static class ResyncPolicy
{
    public static bool ShouldResync(SyncCursor since, SyncCursor gcHorizon) => since < gcHorizon;
}

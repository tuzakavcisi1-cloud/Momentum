namespace Momentum.Domain.Sync;

/// <summary>
/// Per-client monotonic effective op-HLC (ADR 0002 K2-A4/2), the Cowork-locked reading of ADR H1:
/// monotonic bump is applied ONLY to the op-HLC. Per-field/set/group/order HLCs are preserved
/// after clamp — raising them would kill fork #2 (client-HLC preservation) and make P1 convergence
/// impossible. The effective op-HLC feeds the per-client clock (slice-2b <c>outbox.hlc</c> restore)
/// and diagnostics; LWW resolution uses the field HLCs, not this value.
/// </summary>
public sealed class EffectiveHlcAssigner
{
    private readonly ClientClockStore _store;

    public EffectiveHlcAssigner(ClientClockStore store)
    {
        ArgumentNullException.ThrowIfNull(store);
        _store = store;
    }

    /// <param name="clampedOpHlc">The op-HLC AFTER clamp (K2-A4/1).</param>
    public Hlc AssignOpHlc(Guid clientId, Hlc clampedOpHlc)
    {
        // per-client advisory lock -> slice-2b (DB); 2a serializes ingest with one global lock.
        Hlc candidate;
        if (_store.TryGet(clientId, out var last))
        {
            var bumped = Bump(last); // smallest value strictly greater than last
            candidate = clampedOpHlc >= bumped ? clampedOpHlc : bumped;
        }
        else
        {
            candidate = clampedOpHlc; // first op for this client: no prior effective HLC
        }

        return _store.Merge(clientId, candidate); // atomic GREATEST
    }

    // last (+) tick: Counter+1, overflow carries to WallMs+1,0 (K2-A2 rule).
    private static Hlc Bump(Hlc last) =>
        last.Counter == uint.MaxValue
            ? new Hlc(last.WallMs + 1, 0, last.ClientId)
            : new Hlc(last.WallMs, last.Counter + 1, last.ClientId);
}

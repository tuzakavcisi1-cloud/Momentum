namespace Momentum.Domain.Sync;

/// <summary>
/// In-memory equivalent of <c>sync_client_clock</c> (ADR 0002 K2-A4): per-client last effective
/// op-HLC, updated atomic-monotonic (GREATEST). In slice-2a all ingest is serialized under one
/// global lock; this class keeps its own lock so the store stays correct in isolation too.
/// </summary>
public sealed class ClientClockStore
{
    private readonly Dictionary<Guid, Hlc> _last = [];
    private readonly Lock _gate = new();

    public bool TryGet(Guid clientId, out Hlc last)
    {
        lock (_gate)
        {
            return _last.TryGetValue(clientId, out last);
        }
    }

    /// <summary>Atomic GREATEST: store <c>max(current, candidate)</c>; returns the stored value.</summary>
    public Hlc Merge(Guid clientId, Hlc candidate)
    {
        lock (_gate)
        {
            if (_last.TryGetValue(clientId, out var current) && current >= candidate)
            {
                return current;
            }

            _last[clientId] = candidate;
            return candidate;
        }
    }
}

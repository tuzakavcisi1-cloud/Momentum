using Momentum.Domain.Sync;

namespace Momentum.Application.Abstractions.Sync;

/// <summary>
/// The <c>sync_client_clock</c> per-client clock (ADR 0002 K2-A4). Read to SEED the Domain
/// <c>ClientClockStore</c> before deciding; written back with an atomic <c>GREATEST</c> upsert (the ONE
/// SQL exception to "no SQL LWW", §5). Serialization is provided by the client advisory lock.
/// </summary>
public interface IClientClock
{
    Task<Hlc?> GetAsync(Guid clientId, CancellationToken cancellationToken);

    /// <summary>Atomic <c>INSERT … ON CONFLICT DO UPDATE SET hlc = GREATEST(excluded.hlc, current)</c>.</summary>
    Task UpsertGreatestAsync(Guid clientId, Hlc effectiveOpHlc, CancellationToken cancellationToken);
}

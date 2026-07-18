using Momentum.Domain.Sync;

namespace Momentum.Application.Abstractions.Sync;

/// <summary>
/// Per-op sync state store (GOREV slice-2b1 D2/D4). Holds the two advisory locks (client then entity,
/// FIXED order), hydrates the Domain <see cref="EntityState"/> from the persisted rows, and writes the
/// delta the Domain resolver decided. NO decision logic here — the ONLY authority is Domain (§5).
/// </summary>
public interface ISyncStore
{
    /// <summary>Advisory locks in the FIXED order client -> entity (deadlock-free; ADR 0002 K2-A4 / B1).</summary>
    Task LockClientAsync(Guid clientId, CancellationToken cancellationToken);

    Task LockEntityAsync(string entityType, Guid entityId, CancellationToken cancellationToken);

    /// <summary>Hydrate the persisted rows for one entity into <paramref name="target"/> (D0 Load APIs).</summary>
    Task HydrateAsync(EntityState target, string entityType, Guid entityId, CancellationToken cancellationToken);

    /// <summary>Persist the delta for exactly the channels this op touched, reading the resolved state.</summary>
    Task PersistDeltaAsync(ChangeOperation op, EntityState state, CancellationToken cancellationToken);
}

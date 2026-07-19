using Momentum.Domain.Sync;

namespace Momentum.Application.Abstractions.Sync;

/// <summary>
/// GOREV slice-3a D3 (ADR 0002 K2-I2): materializes the resolved <see cref="EntityState"/> into the
/// read-model row (tasks/task_lists/task_tags), in the SAME op-transaction, right after
/// <see cref="ISyncStore.PersistDeltaAsync"/>, Applied branch ONLY. <paramref name="ownerId"/> is the
/// AUTHENTICATED actor (<c>command.ActorId</c>) -- NEVER <c>op.ActorId</c> (the wire-declared, untrusted
/// per-op actor; F5). Out-of-scope entityType (Project, Tag, unrecognized) is a silent no-op (D6).
/// </summary>
public interface IEntityMaterializer
{
    Task MaterializeAsync(ChangeOperation op, EntityState state, Guid ownerId, CancellationToken cancellationToken);
}

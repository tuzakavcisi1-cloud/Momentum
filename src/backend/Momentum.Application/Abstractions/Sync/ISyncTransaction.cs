namespace Momentum.Application.Abstractions.Sync;

/// <summary>
/// Op-scope transaction port (ADR 0002 K2-E5, GOREV slice-2b1 M7). Application cannot touch EF
/// (K-A1); the handler opens one scope per op, and every writer port shares that scope's connection
/// and transaction. Disposing without <see cref="ISyncOpScope.CommitAsync"/> rolls the op back.
/// </summary>
public interface ISyncTransaction
{
    Task<ISyncOpScope> BeginOpScopeAsync(CancellationToken cancellationToken);
}

public interface ISyncOpScope : IAsyncDisposable
{
    Task CommitAsync(CancellationToken cancellationToken);
}

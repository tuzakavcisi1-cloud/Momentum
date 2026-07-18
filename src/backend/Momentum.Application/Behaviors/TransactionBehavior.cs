using Mediator;
using Momentum.Application.Abstractions;
using Momentum.Application.Abstractions.Sync;

namespace Momentum.Application.Behaviors;

/// <summary>
/// Ambient unit-of-work behavior (ADR 0001 K-G1, first use). Opens ONE transaction around a command's
/// handler — but NOT for queries and NOT for <see cref="ITransactionOptOut"/> commands (e.g.
/// <c>SyncCommand</c>, which runs a transaction per op, K2-E5). Reuses the same <see cref="ISyncTransaction"/>
/// port so writer ports share the connection/transaction.
/// </summary>
public sealed class TransactionBehavior<TMessage, TResponse> : IPipelineBehavior<TMessage, TResponse>
    where TMessage : notnull, IMessage
{
    private readonly ISyncTransaction _transaction;

    public TransactionBehavior(ISyncTransaction transaction) => _transaction = transaction;

    public async ValueTask<TResponse> Handle(
        TMessage message,
        MessageHandlerDelegate<TMessage, TResponse> next,
        CancellationToken cancellationToken)
    {
        if (message is not ICommand<TResponse> || message is ITransactionOptOut)
        {
            return await next(message, cancellationToken); // queries + opt-out commands: no ambient txn
        }

        await using var scope = await _transaction.BeginOpScopeAsync(cancellationToken);
        var response = await next(message, cancellationToken);
        await scope.CommitAsync(cancellationToken);
        return response;
    }
}

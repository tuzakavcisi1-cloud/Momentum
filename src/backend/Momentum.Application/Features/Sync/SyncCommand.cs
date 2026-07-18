using Mediator;
using Momentum.Application.Abstractions;

namespace Momentum.Application.Features.Sync;

/// <summary>
/// The /v1/sync command (ADR 0002 K2-E1). <see cref="ActorId"/> is the authenticated user (from
/// <c>ICurrentUser</c>, resolved at the endpoint). <see cref="ITransactionOptOut"/> makes the ambient
/// <c>TransactionBehavior</c> skip it — the handler runs one transaction per op (K2-E5).
/// </summary>
public sealed record SyncCommand(Guid ActorId, SyncRequest Request) : ICommand<SyncResponse>, ITransactionOptOut;

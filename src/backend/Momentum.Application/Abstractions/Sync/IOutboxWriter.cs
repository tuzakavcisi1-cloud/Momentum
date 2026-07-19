namespace Momentum.Application.Abstractions.Sync;

/// <summary>
/// One accepted op -> one <c>outbox_messages</c> row, written in the SAME commit as the mutation and
/// the dedup record (ADR 0002 K2-F1, K-C4). <c>id</c>/<c>commit_xid</c>/<c>server_seq</c> are produced
/// by the server/DB, not here.
/// </summary>
public interface IOutboxWriter
{
    Task WriteAsync(OutboxRecord record, CancellationToken cancellationToken);
}

/// <summary>The EF-mapped outbox fields (GOREV slice-2b1 D4, slice-2b2 D6-1). Hlc is the 3-part codec of
/// the effective op-HLC. <see cref="AvailableAt"/> is written EXPLICITLY from <c>TimeProvider</c> — the
/// DB-default <c>now()</c> was removed (slice-2b2 D2-b/D6): dispatcher lease comparisons use ONE clock
/// source only, never SQL <c>now()</c>.</summary>
public sealed record OutboxRecord(
    string AggregateType,
    Guid AggregateId,
    Guid OperationId,
    Guid OwnerId,
    Guid? ScopeId,
    Guid? OldScopeId,
    Guid ActorId,
    string EventType,
    string Payload,
    string Hlc,
    DateTimeOffset OccurredAt,
    DateTimeOffset AvailableAt);

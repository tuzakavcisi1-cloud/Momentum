using Momentum.Application.Abstractions.Sync;
using Momentum.Infrastructure.Persistence;

namespace Momentum.Infrastructure.Sync;

/// <summary>
/// Writes one <c>outbox_messages</c> row in the current op transaction (ADR 0002 K2-F1, K-C4). The
/// server generates <c>id</c> (UUIDv7); <c>commit_xid</c>/<c>server_seq</c> are DB-generated (omitted).
/// </summary>
public sealed class OutboxWriter(SyncDbContext db) : IOutboxWriter
{
    public async Task WriteAsync(OutboxRecord record, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(record);

        await using var command = await db.CreateRawCommandAsync(
            "INSERT INTO outbox_messages " +
            "(id, aggregate_type, aggregate_id, operation_id, owner_id, scope_id, old_scope_id, actor_id, event_type, payload, hlc, occurred_at) " +
            "VALUES (@id, @at, @ai, @oi, @ow, @sc, @os, @ac, @et, @pl::jsonb, @hl, @oc)",
            cancellationToken);
        command.Parameters.AddWithValue("id", Guid.CreateVersion7());
        command.Parameters.AddWithValue("at", record.AggregateType);
        command.Parameters.AddWithValue("ai", record.AggregateId);
        command.Parameters.AddWithValue("oi", record.OperationId);
        command.Parameters.AddWithValue("ow", record.OwnerId);
        command.Parameters.AddWithValue("sc", (object?)record.ScopeId ?? DBNull.Value);
        command.Parameters.AddWithValue("os", (object?)record.OldScopeId ?? DBNull.Value);
        command.Parameters.AddWithValue("ac", record.ActorId);
        command.Parameters.AddWithValue("et", record.EventType);
        command.Parameters.AddWithValue("pl", record.Payload);
        command.Parameters.AddWithValue("hl", record.Hlc);
        command.Parameters.AddWithValue("oc", record.OccurredAt);
        await command.ExecuteNonQueryAsync(cancellationToken);
    }
}

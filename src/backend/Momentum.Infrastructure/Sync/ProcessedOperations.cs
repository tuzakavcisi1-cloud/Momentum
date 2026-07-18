using Momentum.Application.Abstractions.Sync;
using Momentum.Domain.Sync;
using Momentum.Infrastructure.Persistence;

namespace Momentum.Infrastructure.Sync;

/// <summary>
/// <c>processed_operations</c> dedup (ADR 0002 K2-D2). <c>INSERT … ON CONFLICT DO NOTHING</c>. slice-2a
/// ERRATA: <c>RejectedInvalid</c> is never recorded (the handler returns before calling this).
/// </summary>
public sealed class ProcessedOperations(SyncDbContext db, TimeProvider timeProvider) : IProcessedOperations
{
    public async Task<ProcessedRecord?> GetAsync(Guid clientId, Guid operationId, CancellationToken cancellationToken)
    {
        await using var command = await db.CreateRawCommandAsync(
            "SELECT result_code, effective_op_hlc FROM processed_operations WHERE client_id = @c AND operation_id = @o",
            cancellationToken);
        command.Parameters.AddWithValue("c", clientId);
        command.Parameters.AddWithValue("o", operationId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        var code = Enum.Parse<IngestResultCode>(reader.GetString(0));
        Hlc? effective = !reader.IsDBNull(1) && Hlc.TryParse(reader.GetString(1), out var hlc) ? hlc : null;
        return new ProcessedRecord(code, effective);
    }

    public async Task RecordAsync(Guid clientId, Guid operationId, IngestResultCode code, Hlc? effectiveOpHlc, CancellationToken cancellationToken)
    {
        await using var command = await db.CreateRawCommandAsync(
            "INSERT INTO processed_operations (client_id, operation_id, first_seen_at, result_code, effective_op_hlc) " +
            "VALUES (@c, @o, @t, @r, @e) ON CONFLICT (client_id, operation_id) DO NOTHING",
            cancellationToken);
        command.Parameters.AddWithValue("c", clientId);
        command.Parameters.AddWithValue("o", operationId);
        command.Parameters.AddWithValue("t", timeProvider.GetUtcNow());
        command.Parameters.AddWithValue("r", code.ToString());
        command.Parameters.AddWithValue("e", (object?)effectiveOpHlc?.Encode() ?? DBNull.Value);
        await command.ExecuteNonQueryAsync(cancellationToken);
    }
}

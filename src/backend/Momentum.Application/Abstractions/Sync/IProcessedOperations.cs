using Momentum.Domain.Sync;

namespace Momentum.Application.Abstractions.Sync;

/// <summary>
/// The <c>processed_operations</c> dedup table (ADR 0002 K2-D2). Written with
/// <c>INSERT … ON CONFLICT DO NOTHING</c>. slice-2a ERRATA carried forward: <c>RejectedInvalid</c> is
/// NOT recorded (step-1, receive-time-independent); every other result IS (replay determinism).
/// </summary>
public interface IProcessedOperations
{
    Task<ProcessedRecord?> GetAsync(Guid clientId, Guid operationId, CancellationToken cancellationToken);

    Task RecordAsync(Guid clientId, Guid operationId, IngestResultCode code, Hlc? effectiveOpHlc, CancellationToken cancellationToken);
}

public sealed record ProcessedRecord(IngestResultCode Code, Hlc? EffectiveOpHlc);

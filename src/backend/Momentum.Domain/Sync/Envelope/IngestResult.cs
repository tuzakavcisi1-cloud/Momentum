namespace Momentum.Domain.Sync;

/// <summary>Ingest outcome codes (ADR 0002 §2.B/D; GOREV slice-2a D5).</summary>
public enum IngestResultCode
{
    Applied,
    Duplicate,
    RejectedRegistryViolation,
    RejectedAbsurdHlc,
    RejectedSetCapExceeded,
    RejectedInvalid,
}

/// <summary>
/// Result of ingesting one <see cref="ChangeOperation"/>. <see cref="EffectiveOpHlc"/> is set on
/// <see cref="IngestResultCode.Applied"/>; an <c>Applied</c>-origin <see cref="IngestResultCode.Duplicate"/>
/// carries the original's value; all reject codes carry <c>null</c>.
/// </summary>
public sealed record IngestResult(Guid OperationId, IngestResultCode Code, Hlc? EffectiveOpHlc);

namespace Momentum.Infrastructure.Persistence;

// EF-mapped rows (GOREV slice-2b1 D2). commit_xid + server_seq are DELIBERATELY not mapped on
// OutboxMessage (DB-generated: DEFAULT pg_current_xact_id() + GENERATED ALWAYS AS IDENTITY), added via
// migrationBuilder.Sql. Reads/writes go through raw SQL in the Sync/* implementations; these entities
// exist for the schema (migrations) and model validation.

public sealed class OutboxMessage
{
    public Guid Id { get; set; }
    public string AggregateType { get; set; } = string.Empty;
    public Guid AggregateId { get; set; }
    public Guid OperationId { get; set; }
    public Guid OwnerId { get; set; }
    public Guid? ScopeId { get; set; }
    public Guid? OldScopeId { get; set; }
    public Guid ActorId { get; set; }
    public string EventType { get; set; } = string.Empty;
    public string Payload { get; set; } = "{}";
    public string Hlc { get; set; } = string.Empty;
    public DateTimeOffset OccurredAt { get; set; }
    public DateTimeOffset? SignaledAt { get; set; }
    public int Attempts { get; set; }
    public DateTimeOffset AvailableAt { get; set; }
}

public sealed class ProcessedOperation
{
    public Guid ClientId { get; set; }
    public Guid OperationId { get; set; }
    public DateTimeOffset FirstSeenAt { get; set; }
    public string ResultCode { get; set; } = string.Empty;
    public string? EffectiveOpHlc { get; set; }
}

public sealed class SyncClientClockRow
{
    public Guid ClientId { get; set; }
    public string Hlc { get; set; } = string.Empty;
}

public sealed class SyncScalarMeta
{
    public string EntityType { get; set; } = string.Empty;
    public Guid EntityId { get; set; }
    public string Field { get; set; } = string.Empty;
    public string? Value { get; set; }
    public string Hlc { get; set; } = string.Empty;
    public Guid WinOperationId { get; set; }
}

public sealed class SyncOrsetTag
{
    public string EntityType { get; set; } = string.Empty;
    public Guid EntityId { get; set; }
    public string SetName { get; set; } = string.Empty;
    public string Element { get; set; } = string.Empty;
    public Guid AddTag { get; set; }
    public string? Hlc { get; set; }
    public bool Cancelled { get; set; }
}

public sealed class SyncOrsetRemove
{
    public Guid Id { get; set; }
    public string EntityType { get; set; } = string.Empty;
    public Guid EntityId { get; set; }
    public string SetName { get; set; } = string.Empty;
    public string Element { get; set; } = string.Empty;
    public string Hlc { get; set; } = string.Empty;
}

public sealed class SyncGcState
{
    public int Id { get; set; }
    public long GcHorizonSeq { get; set; }
}

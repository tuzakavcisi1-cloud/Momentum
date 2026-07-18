namespace Momentum.Domain.Sync;

/// <summary>
/// The delta wire envelope (ADR 0002 K2-B1) — only changed fields are carried; per-field HLCs.
/// <see cref="EntityType"/> matches a registry name (Ordinal, case-sensitive). Channels:
/// <see cref="Fields"/> = scalar-LWW, <see cref="Sets"/> = OR-Set, <see cref="Groups"/> = co-resolved,
/// <see cref="Order"/> = fractional-index (scalar-LWW mechanic). JSON mapping is Application/slice-2b.
/// </summary>
public sealed record ChangeOperation(
    Guid OperationId,
    Guid ClientId,
    Guid EntityId,
    Guid ActorId,
    string EntityType,
    Hlc OpHlc,
    IReadOnlyDictionary<string, FieldWrite> Fields,
    IReadOnlyDictionary<string, SetDelta> Sets,
    IReadOnlyDictionary<string, GroupWrite> Groups,
    IReadOnlyDictionary<string, FieldWrite> Order);

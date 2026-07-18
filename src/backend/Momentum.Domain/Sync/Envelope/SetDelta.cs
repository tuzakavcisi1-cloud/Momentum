namespace Momentum.Domain.Sync;

/// <summary>An OR-Set add: a unique <paramref name="Tag"/> for <paramref name="Element"/> (ADR 0002 K2-B1/C2).</summary>
public sealed record SetAdd(string Element, Guid Tag, Hlc Hlc);

/// <summary>
/// An OR-Set remove: cancels ONLY the <paramref name="Observed"/> tags of <paramref name="Element"/>
/// (never a concurrent unseen add). Cancellation is permanent (tombstone), even for a not-yet-seen tag.
/// </summary>
public sealed record SetRemove(string Element, IReadOnlyList<Guid> Observed, Hlc Hlc);

/// <summary>A per-set delta (ADR 0002 K2-B1). Empty add/remove lists are legal no-ops.</summary>
public sealed record SetDelta(IReadOnlyList<SetAdd> Adds, IReadOnlyList<SetRemove> Removes);

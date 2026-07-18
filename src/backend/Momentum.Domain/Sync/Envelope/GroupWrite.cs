namespace Momentum.Domain.Sync;

/// <summary>
/// A co-resolved group write under a single group HLC (ADR 0002 K2-C1b). A partial write is LEGAL
/// and carries REPLACE semantics: the winner's <paramref name="Fields"/> replaces the ENTIRE group
/// state — unwritten members become unset/null (NOT merged). An empty dictionary empties the group.
/// </summary>
public sealed record GroupWrite(IReadOnlyDictionary<string, string?> Fields, Hlc Hlc);

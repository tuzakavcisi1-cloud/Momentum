namespace Momentum.Domain.Sync;

/// <summary>
/// A scalar/order field write (ADR 0002 K2-B1). <paramref name="Value"/> is OPAQUE: the core never
/// interprets it, only compares HLCs. The single exception is the <c>isDeleted</c> field, whose
/// value drives the C4 delete/edit derivation — exact lowercase <c>"true"</c> means deleted, every
/// other value (including <c>null</c>) means not deleted.
/// </summary>
public sealed record FieldWrite(string? Value, Hlc Hlc);

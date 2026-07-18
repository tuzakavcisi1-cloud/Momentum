namespace Momentum.Domain.Sync;

/// <summary>Per-field conflict strategy (ADR 0002 K2-B2).</summary>
public enum FieldStrategy
{
    ScalarLww,
    OrSet,
    FractionalIndex,
    ResolvedGroup,
}

namespace Momentum.Domain.Sync;

/// <summary>
/// Hybrid Logical Clock value (ADR 0002 K2-A1). Standalone ordering everywhere is the canonical
/// <c>(WallMs, Counter, ClientId-hex-ordinal)</c> — the ClientId is compared as its lowercase "N"
/// hex form under <see cref="StringComparer.Ordinal"/>, never via <see cref="Guid.CompareTo"/>.
/// </summary>
public readonly record struct Hlc(long WallMs, uint Counter, Guid ClientId) : IComparable<Hlc>
{
    public int CompareTo(Hlc other)
    {
        var c = WallMs.CompareTo(other.WallMs);
        if (c != 0)
        {
            return c;
        }

        c = Counter.CompareTo(other.Counter);
        if (c != 0)
        {
            return c;
        }

        return string.CompareOrdinal(ClientId.ToString("N"), other.ClientId.ToString("N"));
    }

    public static bool operator <(Hlc left, Hlc right) => left.CompareTo(right) < 0;

    public static bool operator >(Hlc left, Hlc right) => left.CompareTo(right) > 0;

    public static bool operator <=(Hlc left, Hlc right) => left.CompareTo(right) <= 0;

    public static bool operator >=(Hlc left, Hlc right) => left.CompareTo(right) >= 0;
}

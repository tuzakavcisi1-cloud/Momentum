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

    // --- slice-2b1 D0 (ADDITIVE): 3-part codec for persistence -------------------------------------

    /// <summary>
    /// Canonical 3-part encoding: <c>"{WallMs:D13}.{Counter:x8}.{ClientId:N}"</c> (lowercase, fixed-width).
    /// Byte order under <c>COLLATE "C"</c> / <c>GREATEST</c> / <c>ORDER BY</c> matches the HLC order.
    /// </summary>
    public string Encode() => $"{WallMs:D13}.{Counter:x8}.{ClientId:N}";

    public static Hlc Parse(string encoded) =>
        TryParse(encoded, out var hlc) ? hlc : throw new FormatException($"Invalid HLC encoding: '{encoded}'.");

    public static bool TryParse(string? encoded, out Hlc hlc)
    {
        hlc = default;
        if (encoded is null)
        {
            return false;
        }

        var parts = encoded.Split('.');
        if (parts.Length != 3)
        {
            return false;
        }

        if (!long.TryParse(parts[0], System.Globalization.NumberStyles.None, System.Globalization.CultureInfo.InvariantCulture, out var wallMs)
            || !uint.TryParse(parts[1], System.Globalization.NumberStyles.HexNumber, System.Globalization.CultureInfo.InvariantCulture, out var counter)
            || !Guid.TryParseExact(parts[2], "N", out var clientId))
        {
            return false;
        }

        hlc = new Hlc(wallMs, counter, clientId);
        return true;
    }
}

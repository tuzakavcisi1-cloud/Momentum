namespace Momentum.Domain.Sync;

/// <summary>
/// The LWW comparison key (ADR 0002 K2-A1): an <see cref="Hlc"/> plus the final tiebreaker
/// <see cref="OperationId"/> (UUIDv7). The order authority is the <see cref="StringComparer.Ordinal"/>
/// order of <see cref="Encode"/>; the field-by-field <see cref="CompareTo"/> is a fast path proven
/// isomorphic to it by property P9. Encoding is defined for <c>0 &lt;= WallMs &lt; 10^13</c>.
/// </summary>
public readonly record struct HlcKey(Hlc Hlc, Guid OperationId) : IComparable<HlcKey>
{
    /// <summary>Canonical lowercase, fixed-width, single-format encoding (ADR 0002 K2-A1).</summary>
    public string Encode() =>
        $"{Hlc.WallMs:D13}.{Hlc.Counter:x8}.{Hlc.ClientId:N}.{OperationId:N}";

    public int CompareTo(HlcKey other)
    {
        var c = Hlc.CompareTo(other.Hlc);
        if (c != 0)
        {
            return c;
        }

        return string.CompareOrdinal(OperationId.ToString("N"), other.OperationId.ToString("N"));
    }

    public static bool operator <(HlcKey left, HlcKey right) => left.CompareTo(right) < 0;

    public static bool operator >(HlcKey left, HlcKey right) => left.CompareTo(right) > 0;

    public static bool operator <=(HlcKey left, HlcKey right) => left.CompareTo(right) <= 0;

    public static bool operator >=(HlcKey left, HlcKey right) => left.CompareTo(right) >= 0;

    // --- slice-2b1 D0 (ADDITIVE): 4-part parse for persistence (Encode already exists) --------------

    public static HlcKey Parse(string encoded) =>
        TryParse(encoded, out var key) ? key : throw new FormatException($"Invalid HlcKey encoding: '{encoded}'.");

    public static bool TryParse(string? encoded, out HlcKey key)
    {
        key = default;
        if (encoded is null)
        {
            return false;
        }

        var lastDot = encoded.LastIndexOf('.');
        if (lastDot < 0)
        {
            return false;
        }

        if (!Hlc.TryParse(encoded[..lastDot], out var hlc)
            || !Guid.TryParseExact(encoded[(lastDot + 1)..], "N", out var operationId))
        {
            return false;
        }

        key = new HlcKey(hlc, operationId);
        return true;
    }
}

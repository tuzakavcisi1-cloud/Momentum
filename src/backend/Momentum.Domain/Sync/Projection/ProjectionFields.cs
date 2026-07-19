using System.Globalization;

namespace Momentum.Domain.Sync;

/// <summary>
/// GOREV slice-3a D2: shared field-reading rules for <see cref="TaskProjection"/>/<see cref="TaskListProjection"/>
/// (the SOURCE CHANNEL TABLE + the four-state malformed-fields machine, applied IDENTICALLY by both).
/// Pure, IO-less. <c>InvariantCulture</c> is mandatory throughout (no <c>CurrentCulture</c>/<c>ToLower</c>/
/// <c>ToUpper</c>, ADR 0002 K2-I3 kirmizi cizgi).
/// </summary>
internal static class ProjectionFields
{
    // TARIH KURALI (BIREBIR PINLI, GOREV slice-3a D2): DateTimeStyles.RoundtripKind is INEFFECTIVE on
    // DateTimeOffset (no Kind property to round-trip). AssumeUniversal makes the trailing offset OPTIONAL
    // -- an un-offset input is treated as UTC, never the machine's local time zone (mutant-8's target,
    // environment-dependent: only bites where local TZ != UTC, D2d). AdjustToUniversal canonicalizes the
    // stored instant. A lenient TryParse (no Exact) would accept InvariantCulture's ShortDatePattern
    // "MM/dd/yyyy" silently (mutant-7's target).
    private static readonly string[] IsoFormats = ["yyyy-MM-dd'T'HH:mm:ss.FFFFFFFK", "yyyy-MM-dd'T'HH:mm:ssK"];

    public static string? ReadText(IReadOnlyDictionary<string, LwwRegister> source, string field) =>
        source.TryGetValue(field, out var register) && register.HasValue ? register.Value : null;

    public static int? ReadInt(IReadOnlyDictionary<string, LwwRegister> source, string field, List<string> malformed)
    {
        if (!source.TryGetValue(field, out var register) || !register.HasValue)
        {
            return null; // state 1: no register at all -> NULL, NOT malformed
        }

        if (register.Value is null)
        {
            return null; // state 2: legitimate null value -> NULL, NOT malformed
        }

        if (int.TryParse(register.Value, NumberStyles.Integer, CultureInfo.InvariantCulture, out var parsed))
        {
            return parsed;
        }

        malformed.Add(field); // state 3: non-null, unparseable -> NULL + malformed
        return null;
    }

    public static Guid? ReadGuid(IReadOnlyDictionary<string, LwwRegister> source, string field, List<string> malformed)
    {
        if (!source.TryGetValue(field, out var register) || !register.HasValue)
        {
            return null;
        }

        if (register.Value is null)
        {
            return null;
        }

        // Deliberately Guid.TryParse (not TryParseExact) -- SyncCommandHandler.TryScope resolves
        // projectId -> scope_id the same way; a stricter parse here would silently desynchronize the two.
        if (Guid.TryParse(register.Value, out var parsed))
        {
            return parsed;
        }

        malformed.Add(field);
        return null;
    }

    public static DateTimeOffset? ReadDate(IReadOnlyDictionary<string, LwwRegister> source, string field, List<string> malformed)
    {
        if (!source.TryGetValue(field, out var register) || !register.HasValue)
        {
            return null;
        }

        if (register.Value is null)
        {
            return null;
        }

        if (TryParseDate(register.Value, out var parsed))
        {
            return parsed;
        }

        malformed.Add(field);
        return null;
    }

    public static string? ReadGroupText(IReadOnlyDictionary<string, string?> fields, string member) =>
        fields.TryGetValue(member, out var value) ? value : null;

    public static DateTimeOffset? ReadGroupDate(IReadOnlyDictionary<string, string?> fields, string member, List<string> malformed)
    {
        if (!fields.TryGetValue(member, out var value) || value is null)
        {
            return null; // state 1 (member absent from the winning REPLACE) or state 2 (legitimate null)
        }

        if (TryParseDate(value, out var parsed))
        {
            return parsed;
        }

        malformed.Add(member);
        return null;
    }

    public static bool TryParseDate(string value, out DateTimeOffset parsed) =>
        DateTimeOffset.TryParseExact(value, IsoFormats, CultureInfo.InvariantCulture,
            DateTimeStyles.AssumeUniversal | DateTimeStyles.AdjustToUniversal, out parsed);

    /// <summary>DURUM TABLOSU dedup+sort pin: Ordinal, never the CurrentCulture default List&lt;string&gt;.Sort().</summary>
    public static IReadOnlyList<string> FinalizeMalformed(List<string> malformed)
    {
        var distinct = malformed.Distinct(StringComparer.Ordinal).ToList();
        distinct.Sort(StringComparer.Ordinal);
        return distinct;
    }
}

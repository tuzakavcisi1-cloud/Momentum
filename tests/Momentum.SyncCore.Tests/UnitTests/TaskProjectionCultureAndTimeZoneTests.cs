using System.Globalization;
using Momentum.Domain.Sync;
using Momentum.SyncCore.Tests.TestUtil;
using Shouldly;
using Xunit;

namespace Momentum.SyncCore.Tests.UnitTests;

/// <summary>D2c/D2d (GOREV slice-3a): culture- and timezone-immunity of TaskProjection's parsing rules.</summary>
public sealed class TaskProjectionCultureAndTimeZoneTests
{
    /// <summary>
    /// D2c [mutantsiz -- durustluk beyani]: a REGRESSION SAFEGUARD, not a mutant-gated test. Verified in
    /// the technical audit: the format string's '-' is a literal (only '/' is culture-dependent as a date
    /// separator), ':' is the time separator (already ':' in tr-TR), and int.TryParse(NumberStyles.Integer)
    /// behaves identically in tr-TR -- an InvariantCulture -> CurrentCulture mutation would NOT bite here.
    /// </summary>
    [Fact]
    public void Projection_parsing_is_identical_under_tr_TR_current_culture()
    {
        var original = CultureInfo.CurrentCulture;
        try
        {
            CultureInfo.CurrentCulture = new CultureInfo("tr-TR");

            var client = Ids.Client(0);
            var entity = new EntityState();
            entity.ApplyField("priority", new FieldWrite("2", new Hlc(1, 0, client)), Ids.Op(0));
            entity.ApplyField("dueAt", new FieldWrite("2026-07-19T10:00:00Z", new Hlc(1, 0, client)), Ids.Op(1));

            var projection = TaskProjection.From(Guid.NewGuid(), entity);

            projection.Priority.ShouldBe(2);
            projection.DueAt.ShouldBe(new DateTimeOffset(2026, 7, 19, 10, 0, 0, TimeSpan.Zero));
            projection.MalformedFields.ShouldBeEmpty();
        }
        finally
        {
            CultureInfo.CurrentCulture = original;
        }
    }

    /// <summary>
    /// D2d [ortam-bagimli kapi, mutant-8]: un-offset ISO input is treated as UTC (AssumeUniversal), never
    /// the machine's local time zone. mutant-8 (drop AssumeUniversal) only bites when the local TZ != UTC.
    /// KANIT must record TimeZoneInfo.Local.Id (this machine's declared expectation: tr-TR, +03:00).
    /// </summary>
    [Fact]
    public void Unoffset_iso_datetime_is_assumed_utc_not_local_timezone()
    {
        var client = Ids.Client(0);
        var entity = new EntityState();
        entity.ApplyField("dueAt", new FieldWrite("2026-07-19T10:00:00", new Hlc(1, 0, client)), Ids.Op(0));
        entity.ApplyField("remindAt", new FieldWrite("2026-07-19T13:00:00+03:00", new Hlc(1, 0, client)), Ids.Op(1));

        var projection = TaskProjection.From(Guid.NewGuid(), entity);

        projection.DueAt.ShouldNotBeNull();
        projection.DueAt!.Value.Offset.ShouldBe(TimeSpan.Zero);
        projection.DueAt.Value.UtcDateTime.ShouldBe(new DateTime(2026, 7, 19, 10, 0, 0, DateTimeKind.Utc));

        projection.RemindAt.ShouldNotBeNull();
        projection.RemindAt!.Value.UtcDateTime.ShouldBe(projection.DueAt.Value.UtcDateTime);

        projection.MalformedFields.ShouldBeEmpty();
    }

    /// <summary>
    /// OLCUM GOREVI (GOREV slice-3a D2, kabul kriteri 2/rapor maddesi l): does the FIRST ISO format alone
    /// (".FFFFFFFK", fractional-seconds specifier) match a FRACTION-LESS input, or does only the SECOND
    /// format ("no fractional group") rescue it? Measured, not assumed -- both outcomes are reported.
    /// </summary>
    [Fact]
    public void Measurement_fractional_seconds_format_alone_against_fraction_less_input()
    {
        var matchesFirstFormatAlone = DateTimeOffset.TryParseExact(
            "2026-07-19T10:00:00Z", "yyyy-MM-dd'T'HH:mm:ss.FFFFFFFK", CultureInfo.InvariantCulture,
            DateTimeStyles.AssumeUniversal | DateTimeStyles.AdjustToUniversal, out _);

        matchesFirstFormatAlone.ShouldBeTrue(); // .NET's "." + consecutive "F" is an OPTIONAL group when parsing
    }
}

using System.Globalization;
using Momentum.Application.Abstractions.Sync;
using Momentum.Domain.Sync;
using Npgsql;
using Shouldly;
using Xunit;

namespace Momentum.Persistence.Tests;

/// <summary>
/// IS-EMRI-o83-F: <c>PullIncrementalAsync</c>'s <c>ORDER BY commit_xid, server_seq</c> was shadowed by its
/// own <c>::text</c> output alias (KANIT/o84, o83-D/o83-E) -- rows sort lexicographically, not by xid8
/// value, wherever the written xid range crosses a decimal-digit boundary (e.g. 999 -&gt; 1000). These two
/// tests write rows with EXPLICIT <c>commit_xid</c> values straddling a MEASURED digit boundary (never a
/// hardcoded one -- the horizon moves with however many prior transactions this run has already consumed)
/// and assert on order/loss deterministically. No timing, no concurrency, no <c>Task.Delay</c>, no retry
/// (o83-F s3.3 pin): this defect is deterministic, so the test is too. Both tests run ISOLATED (o83-F
/// s3.1 "YASAK COZUM": a test whose validity depends on "how many other tests ran first" is the exact
/// context-dependence class that already bit this project once -- it must not bite it twice).
/// </summary>
[Collection(PostgresCollection.Name)]
public sealed class PullCursorOrderTests(PostgresFixture fixture)
{
    /// <summary>
    /// Test 1's boundary: the largest power of ten <c>B</c> such that writing xids in
    /// <c>[B-before, B+after]</c> stays (a) entirely &gt;= 1 and (b) entirely below the CURRENT horizon
    /// <paramref name="horizon"/> (so <c>PullIncrementalAsync</c>'s own
    /// <c>commit_xid &lt; pg_snapshot_xmin(...)</c> predicate never excludes a written row).
    /// <see langword="null"/> if no such <c>B</c> exists -- callers must fail loudly with the measured
    /// horizon, never skip silently (o83-F s3.1 pin).
    /// </summary>
    private static ulong? PickDigitBoundary(ulong horizon, ulong before, ulong after)
    {
        ulong? best = null;
        for (var power = 10UL; power <= horizon; power *= 10)
        {
            if (power >= before + 1 && power + after < horizon)
            {
                best = power;
            }
        }

        return best;
    }

    /// <summary>
    /// Test 2's boundary (o84-B fix, o83-F s3.1): the invariant that actually reproduces the LOSS is (i) a
    /// FULL <c>PageSize</c> (500) rows AT or ABOVE the boundary, (ii) at least one row BELOW it, and (iii)
    /// the below-boundary block sorts, LEXICOGRAPHICALLY, AFTER the whole above-boundary block -- which
    /// only the "all values start with digit 9" block directly under a power of ten guarantees (e.g.
    /// 90..99 vs 100..599: "9..." is never a text-prefix of "1..."). <c>B</c> = the largest power of ten
    /// with <c>B &gt;= 100</c> and <c>B + 499 &lt; horizon</c>. <see langword="null"/> if none fits.
    /// </summary>
    private static ulong? PickPageWindowBoundary(ulong horizon)
    {
        ulong? best = null;
        for (var power = 100UL; power + 499 < horizon; power *= 10)
        {
            best = power;
        }

        return best;
    }

    /// <summary>
    /// o83-F s3.1 fallback: if even <c>B=100</c> does not fit (horizon &lt;= 599), advance the CLUSTER's
    /// transaction counter by committing empty transactions (each <c>pg_current_xact_id()</c> call forces
    /// a real xid assignment) until the horizon clears <paramref name="target"/>. Returns how many
    /// transactions were burned, so the caller can report it (never silently).
    /// </summary>
    private static async Task<int> BurnTransactionsUntilAsync(string connectionString, ulong target)
    {
        var burned = 0;
        while (await ReadHorizonAsync(connectionString) <= target && burned < 10_000)
        {
            await using var connection = await Db.OpenAsync(connectionString);
            await using var transaction = await connection.BeginTransactionAsync();
            await using (var command = connection.CreateCommand())
            {
                command.Transaction = transaction;
                command.CommandText = "SELECT pg_current_xact_id()";
                await command.ExecuteScalarAsync();
            }

            await transaction.CommitAsync();
            burned++;
        }

        return burned;
    }

    /// <summary>
    /// Writes <c>before + after + 1</c> rows for one owner with EXPLICIT <c>commit_xid</c> values
    /// <c>xidBase-before .. xidBase+after</c> (schema DEFAULT, so writable -- <c>OutboxWriter</c> is NOT
    /// used here, it never writes <c>commit_xid</c>). <c>server_seq</c> is left to
    /// <c>GENERATED ALWAYS AS IDENTITY</c>: the single <c>INSERT ... SELECT ... ORDER BY s</c> writes rows
    /// in ascending xid order so the identity sequence comes out ascending too (o83-F s3.1 pin). Payload
    /// <c>title</c> = <c>"v&lt;offset&gt;"</c> (offset 0 = smallest xid) so callers recover write order
    /// from the pull result the same way <c>DispatcherTests.cs</c> does.
    /// </summary>
    private static async Task WriteRowsAsync(string connectionString, Guid owner, ulong xidBase, long before, long after)
    {
        await using var connection = await Db.OpenAsync(connectionString);
        await using var command = connection.CreateCommand();
        command.CommandText =
            "INSERT INTO outbox_messages " +
            "(id, aggregate_type, aggregate_id, operation_id, owner_id, actor_id, event_type, payload, hlc, occurred_at, available_at, commit_xid) " +
            "SELECT gen_random_uuid(), 'Task', gen_random_uuid(), gen_random_uuid(), @owner, @owner, 'Task.changed', " +
            "jsonb_build_object('title', 'v' || (s + @before)::text), 'o83f-pin', now(), now(), (@xidBase + s)::text::xid8 " +
            "FROM generate_series(-@before::bigint, @after::bigint) AS s " +
            "ORDER BY s";
        command.Parameters.AddWithValue("owner", owner);
        command.Parameters.AddWithValue("xidBase", (long)xidBase);
        command.Parameters.AddWithValue("before", before);
        command.Parameters.AddWithValue("after", after);
        await command.ExecuteNonQueryAsync();
    }

    private static async Task<ulong> ReadHorizonAsync(string connectionString)
    {
        var text = await Db.ScalarAsync<string>(connectionString, "SELECT pg_snapshot_xmin(pg_current_snapshot())::text");
        return ulong.Parse(text, CultureInfo.InvariantCulture);
    }

    [Fact]
    public async Task Pull_returns_rows_in_ascending_cursor_order_across_a_digit_boundary()
    {
        const long before = 12;
        const long after = 12;
        const int rowCount = 25; // before + after + 1

        var connectionString = await TestDatabase.CreateAsync(fixture);
        var owner = Guid.NewGuid();

        var horizon = await ReadHorizonAsync(connectionString);
        var boundary = PickDigitBoundary(horizon, before, after);
        if (boundary is not { } b)
        {
            Assert.Fail($"no power-of-ten digit boundary fits under the measured horizon X={horizon} (need B>=13, B+12<X)");
            return;
        }

        Console.WriteLine($"o83-F Test1: X={horizon} B={b} xid=[{b - (ulong)before}..{b + (ulong)after}] rows={rowCount}");

        await WriteRowsAsync(connectionString, owner, b, before, after);

        await using var puller = new SyncTestApp(connectionString);
        var page = await puller.PullAsync(owner, new SyncCursor(0, 0));

        page.Changes.Count.ShouldBe(rowCount);
        for (var i = 0; i < rowCount; i++)
        {
            page.Changes[i].PayloadJson.ShouldContain($"\"v{i}\"");
            if (i > 0)
            {
                page.Changes[i].Cursor.CompareTo(page.Changes[i - 1].Cursor).ShouldBeGreaterThan(0);
            }
        }

        page.NextCursor.ShouldBe(new SyncCursor(b + (ulong)after, rowCount));
    }

    [Fact]
    public async Task Pull_pagination_delivers_every_row_without_loss_across_a_digit_boundary()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        var owner = Guid.NewGuid();

        var horizon = await ReadHorizonAsync(connectionString);
        var burned = 0;
        if (PickPageWindowBoundary(horizon) is null && horizon <= 600)
        {
            burned = await BurnTransactionsUntilAsync(connectionString, target: 600);
            horizon = await ReadHorizonAsync(connectionString);
        }

        var boundary = PickPageWindowBoundary(horizon);
        if (boundary is not { } b)
        {
            Assert.Fail($"no page-window boundary fits under the measured horizon X={horizon} (burned {burned} transactions; need B>=100, B+499<X)");
            return;
        }

        var before = (long)Math.Min(b / 10, 100);
        const long after = 499;
        var rowCount = (int)(before + after + 1);

        Console.WriteLine($"o83-F Test2: X={horizon} B={b} burned={burned} xid=[{b - (ulong)before}..{b + (ulong)after}] rows={rowCount}");

        await WriteRowsAsync(connectionString, owner, b, before, after);

        await using var puller = new SyncTestApp(connectionString);
        var since = new SyncCursor(0, 0);
        var seen = new List<ChangeRecord>();
        var hasMore = true;
        for (var round = 0; round < 10 && hasMore; round++)
        {
            var page = await puller.PullAsync(owner, since);
            seen.AddRange(page.Changes);
            since = page.NextCursor;
            hasMore = page.HasMore;
        }

        if (hasMore)
        {
            Assert.Fail($"pagination did not converge in 10 rounds (delivered so far: {seen.Count}/{rowCount})");
            return;
        }

        seen.Count.ShouldBe(rowCount); // no loss
        seen.Select(c => c.Cursor).Distinct().Count().ShouldBe(rowCount); // no duplicates
        for (var i = 1; i < seen.Count; i++)
        {
            seen[i].Cursor.CompareTo(seen[i - 1].Cursor).ShouldBeGreaterThan(0); // numerically ascending
        }
    }
}

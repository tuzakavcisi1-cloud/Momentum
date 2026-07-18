using Momentum.Domain.Sync;
using Shouldly;
using Xunit;

namespace Momentum.Persistence.Tests;

[Collection(PostgresCollection.Name)]
public sealed class VisibilityTests(PostgresFixture fixture)
{
    /// <summary>
    /// H7b (ADR 0002 K2-H7b / BLOKER-R1): txn-A in-flight (small xid), txn-B commits (bigger xid). The
    /// snapshot continuation is <c>(horizon, 0)</c> (Seq == 0). After A commits, an incremental pull from
    /// it returns BOTH rows, none skipped, all <c>server_seq &gt;= 1</c>. A last-row cursor would skip A.
    /// </summary>
    [Fact]
    public async Task H7b_snapshot_continuation_is_horizon_and_skips_nothing()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actor = Guid.NewGuid();

        await using var connA = await Db.OpenAsync(connectionString);
        await using var connB = await Db.OpenAsync(connectionString);

        var txnA = await connA.BeginTransactionAsync();
        await Db.InsertOutboxAsync(connA, txnA, actor, Wire.EncodeHlc(actor, 1)); // A: smaller xid, in-flight

        var txnB = await connB.BeginTransactionAsync();
        await Db.InsertOutboxAsync(connB, txnB, actor, Wire.EncodeHlc(actor, 2)); // B: bigger xid
        await txnB.CommitAsync();

        var snapshot = await app.SnapshotAsync(actor);
        snapshot.NextCursor.Seq.ShouldBe(0); // (horizon, 0) — NOT the last visible row

        await txnA.CommitAsync();

        var page = await app.PullAsync(actor, snapshot.NextCursor);
        page.Changes.Count.ShouldBe(2);                    // A and B both delivered
        page.Changes.ShouldAllBe(change => change.Cursor.Seq >= 1);
    }

    /// <summary>
    /// H8 (ADR 0002 K2-H8): (i) a rolled-back write leaves no row; (ii) holdback — while T1 (small xid)
    /// is in flight and T2 (big xid) is committed, a pull returns NEITHER (<c>commit_xid &lt; xmin</c>
    /// covers both); after T1 commits both arrive in <c>(commit_xid, server_seq)</c> order (T1 first).
    /// </summary>
    [Fact]
    public async Task H8_rollback_empty_and_holdback_then_ordered_delivery()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actor = Guid.NewGuid();

        // (i) rollback -> no row
        await using (var conn = await Db.OpenAsync(connectionString))
        {
            var txn = await conn.BeginTransactionAsync();
            await Db.InsertOutboxAsync(conn, txn, actor, Wire.EncodeHlc(actor, 9));
            await txn.RollbackAsync();
        }

        (await app.PullAsync(actor, new SyncCursor(0, 0))).Changes.ShouldBeEmpty();

        // (ii) holdback
        await using var conn1 = await Db.OpenAsync(connectionString);
        await using var conn2 = await Db.OpenAsync(connectionString);

        var t1 = await conn1.BeginTransactionAsync();
        await Db.InsertOutboxAsync(conn1, t1, actor, Wire.EncodeHlc(actor, 1)); // small xid, in-flight
        var t2 = await conn2.BeginTransactionAsync();
        await Db.InsertOutboxAsync(conn2, t2, actor, Wire.EncodeHlc(actor, 2)); // big xid
        await t2.CommitAsync();

        (await app.PullAsync(actor, new SyncCursor(0, 0))).Changes.ShouldBeEmpty(); // holdback: neither yet

        await t1.CommitAsync();

        var page = await app.PullAsync(actor, new SyncCursor(0, 0));
        page.Changes.Count.ShouldBe(2);
        page.Changes[0].Cursor.Xid.ShouldBeLessThan(page.Changes[1].Cursor.Xid); // T1 first
    }

    /// <summary>H8(iii): a write made inside a savepoint/subtransaction is visible after commit.</summary>
    [Fact]
    public async Task H8_savepoint_write_is_visible_after_commit()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actor = Guid.NewGuid();

        await using (var conn = await Db.OpenAsync(connectionString))
        {
            var txn = await conn.BeginTransactionAsync();
            await Db.InsertOutboxAsync(conn, txn, actor, Wire.EncodeHlc(actor, 1));
            await Db.ExecuteAsync(conn, txn, "SAVEPOINT sp1");
            await Db.InsertOutboxAsync(conn, txn, actor, Wire.EncodeHlc(actor, 2));
            await Db.ExecuteAsync(conn, txn, "RELEASE SAVEPOINT sp1");
            await txn.CommitAsync();
        }

        (await app.PullAsync(actor, new SyncCursor(0, 0))).Changes.Count.ShouldBe(2);
    }
}

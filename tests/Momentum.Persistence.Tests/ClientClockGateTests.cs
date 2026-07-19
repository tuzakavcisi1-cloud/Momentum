using Momentum.Domain.Sync;
using Shouldly;
using Xunit;

namespace Momentum.Persistence.Tests;

/// <summary>
/// slice-2b2 D0 (2b1's CLOSURE CONDITION). Cowork proved that with the client advisory lock HELD,
/// mutating <c>GREATEST(...)</c> to a plain overwrite left Persistence.Tests 21/21 green
/// (<c>KANIT/slice-2b1/cowork-bagimsiz-dogrulama.txt</c> §5) -- the lock already serializes same-client
/// writes, so GREATEST was defense-in-depth, never a bitten gate (ADR K2-A4's pin was BLIND). These
/// tests call the storage port DIRECTLY, WITHOUT the lock, so GREATEST is the ONLY thing standing between
/// a future "forgot the lock" code path and a clock that jumps backwards.
/// </summary>
[Collection(PostgresCollection.Name)]
public sealed class ClientClockGateTests(PostgresFixture fixture)
{
    /// <summary>D0 steps 1-4. mutant-1 (GREATEST -> excluded.hlc) fails step 3's assert; mutant-2
    /// (GREATEST -> sync_client_clock.hlc, i.e. a no-op) fails step 4's assert.</summary>
    [Fact]
    public async Task Client_clock_is_monotonic_at_storage_level_even_without_the_client_lock()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var client = Guid.NewGuid();

        // (1) a normal /v1/sync write establishes a real, clamped/node-monotonic-bumped clock value.
        await app.SyncAsync(client, Wire.PushNoPull(client,
            Wire.TaskField(Guid.CreateVersion7(), client, Guid.NewGuid(), client, "title", "x")));

        // (2) read the BASE back from STORAGE -- not the wire HLC we sent (clamp + node-monotonic bump
        // mean the two differ; asserting against the wire HLC would pass/fail for the wrong reason).
        var baseHlc = await app.GetClientClockAsync(client);
        baseHlc.ShouldNotBeNull();

        // (3) WITHOUT the client lock: a LOWER HLC must not drag the stored clock backwards.
        var lower = new Hlc(baseHlc!.Value.WallMs - 1_000, 0, client);
        await app.UpsertClientClockGreatestAsync(client, lower);

        (await app.GetClientClockAsync(client)).ShouldBe(baseHlc);

        // (4) reverse direction: a HIGHER HLC must still win (rules out a one-way no-op mutation).
        // Honesty note (spec-QA, carried into KANIT): this direction has NO independent gate surface --
        // a mutation that breaks "upward" GREATEST also kills
        // ConcurrencyTests.H12_concurrent_same_client_ingest_no_lost_update. Written for regression value.
        var higher = new Hlc(baseHlc.Value.WallMs + 1_000, 0, client);
        await app.UpsertClientClockGreatestAsync(client, higher);

        (await app.GetClientClockAsync(client)).ShouldBe(higher);
    }

    /// <summary>
    /// D0-b: K2-A4's "atomic" claim. conn1 opens a txn and upserts H_high WITHOUT committing; conn2
    /// concurrently upserts a LOWER H_low for the SAME client. The test does not commit conn1 until it has
    /// POSITIVELY confirmed (via <c>pg_locks</c>) that conn2 is actually blocked on the row lock -- the v4
    /// interleaving pin (KB-D): without it, if conn1 happened to commit first, conn2 would read a FRESH
    /// value, refuse to regress it even under a naive read-compare-write, and the mutant would pass by
    /// accident while looking like a real green run. mutant-9 (SQL GREATEST -> C# read-compare-write)
    /// fails the final assert: conn2 would have read the STALE (pre-conn1) value and lost the update.
    /// </summary>
    [Fact]
    public async Task Client_clock_greatest_upsert_is_atomic_under_concurrent_writers()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var client = Guid.NewGuid();

        var high = new Hlc(Wire.BaseWall + 10_000, 0, client);
        var low = new Hlc(Wire.BaseWall + 1_000, 0, client);

        await using var conn1 = await app.BeginClientClockScopeAsync();
        await conn1.UpsertGreatestAsync(client, high); // NOT committed yet -- row lock held

        var conn2Task = Task.Run(async () =>
        {
            await using var conn2 = await app.BeginClientClockScopeAsync();
            await conn2.UpsertGreatestAsync(client, low); // blocks on conn1's row lock
            await conn2.CommitAsync();
        });

        await WaitUntilAConcurrentWriterIsBlockedAsync(connectionString, TimeSpan.FromSeconds(10));

        await conn1.CommitAsync();
        await conn2Task;

        (await app.GetClientClockAsync(client)).ShouldBe(high);
    }

    private static async Task WaitUntilAConcurrentWriterIsBlockedAsync(string connectionString, TimeSpan timeout)
    {
        var deadline = DateTime.UtcNow + timeout;
        while (DateTime.UtcNow < deadline)
        {
            if (await Db.ScalarAsync<long>(connectionString, "SELECT count(*) FROM pg_locks WHERE NOT granted") > 0)
            {
                return;
            }

            await Task.Delay(50);
        }

        throw new TimeoutException("conn2 never entered a blocked wait state -- the v4 interleaving pin (KB-D) was not exercised.");
    }
}

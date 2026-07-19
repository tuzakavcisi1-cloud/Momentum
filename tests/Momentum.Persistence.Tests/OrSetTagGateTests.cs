using Momentum.Domain.Sync;
using Shouldly;
using Xunit;

namespace Momentum.Persistence.Tests;

/// <summary>
/// D3 (ADR 0002 ERRATA E-1b, GOREV slice-2c): the <c>sync_orset_tags.hlc</c> storage-level GREATEST
/// invariant. DÜRÜSTLÜK BEYANI (mandatory per spec): this gates a DEPOLAMA DEĞİŞMEZİ (storage invariant)
/// independent of caller discipline, NOT a reachable production RACE — the entity advisory lock
/// (slice-2b1 D2) already excludes concurrent writers to this row; the normal lock-then-hydrate path
/// would already have re-read HIGH and max-joined it in Domain before any SQL ran. This mirrors
/// <c>ClientClockGateTests</c>'s D0 pattern exactly, for the OR-Set tag column instead of the client clock.
/// </summary>
[Collection(PostgresCollection.Name)]
public sealed class OrSetTagGateTests(PostgresFixture fixture)
{
    [Fact]
    public async Task Orset_tag_upsert_cannot_be_dragged_backwards_by_a_stale_direct_persist()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        var entity = Guid.NewGuid();
        var client = Guid.NewGuid();
        var tag = Guid.NewGuid();

        var high = new Hlc(Wire.BaseWall + 10_000, 0, client);
        var low = new Hlc(Wire.BaseWall + 1_000, 0, client);

        // 1. Raw-SQL insert the HIGH-hlc row directly (bypasses all Domain/Application logic).
        await Db.ExecuteAsync(connectionString,
            "INSERT INTO sync_orset_tags (entity_type, entity_id, set_name, element, add_tag, hlc, cancelled) " +
            "VALUES ('Task', @e, 'tags', 'el0', @tag, @h, false)",
            ("e", entity), ("tag", tag), ("h", high.Encode()));

        // 2. A FRESH (unhydrated) EntityState, ApplyAdd(LOW) for the SAME tag, persisted DIRECTLY -- no
        //    LockEntityAsync, no HydrateAsync. Doing both writes via raw SQL would never exercise
        //    UpsertTagAsync at all (kör); going through the normal /v1/sync path would hydrate HIGH
        //    first and max-join it in Domain, so the SQL would receive HIGH anyway (mutant-4 would not
        //    bite either way) -- this helper is the only path that isolates the SQL-level GREATEST.
        await using var app = new SyncTestApp(connectionString);
        var state = new EntityState();
        state.GetOrCreateSet("tags").ApplyAdd(new SetAdd("el0", tag, low));

        var op = new ChangeOperation(
            Guid.CreateVersion7(), client, entity, client, "Task", low,
            new Dictionary<string, FieldWrite>(),
            new Dictionary<string, SetDelta> { ["tags"] = new SetDelta([new SetAdd("el0", tag, low)], []) },
            new Dictionary<string, GroupWrite>(),
            new Dictionary<string, FieldWrite>());

        await app.PersistSetDeltaWithoutHydrationAsync(op, state);

        // 3. Assert: the row is STILL HIGH -- GREATEST refused to let the stale LOW write win.
        (await Db.ScalarAsync<string>(connectionString,
            "SELECT hlc FROM sync_orset_tags WHERE entity_id = @e AND add_tag = @tag", ("e", entity), ("tag", tag)))
            .ShouldBe(high.Encode());
    }
}

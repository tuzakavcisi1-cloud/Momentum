using Momentum.Application.Features.Sync;
using Shouldly;
using Xunit;

namespace Momentum.Persistence.Tests;

[Collection(PostgresCollection.Name)]
public sealed class SemanticRoundTripTests(PostgresFixture fixture)
{
    /// <summary>
    /// Group round-trip (B5): a full completion write then a partial (status-only) write with a bigger
    /// group HLC REPLACES the group — the completedAt member row is DELETED, and the hydrated state
    /// matches 2a REPLACE (only status remains).
    /// </summary>
    [Fact]
    public async Task Group_partial_write_replaces_and_deletes_unwritten_member()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var client = Guid.NewGuid();
        var entity = Guid.NewGuid();

        await app.SyncAsync(client, Wire.PushNoPull(client,
            Wire.TaskGroup(Guid.CreateVersion7(), client, entity, client, 1, ("status", "done"), ("completedAt", "t1"))));
        await app.SyncAsync(client, Wire.PushNoPull(client,
            Wire.TaskGroup(Guid.CreateVersion7(), client, entity, client, 2, ("status", "redo"))));

        (await Db.ScalarAsync<long>(connectionString,
            "SELECT count(*) FROM sync_scalar_meta WHERE entity_id = @e AND field = 'completion.completedAt'", ("e", entity)))
            .ShouldBe(0); // deleted by REPLACE
        (await Db.ScalarAsync<string>(connectionString,
            "SELECT value FROM sync_scalar_meta WHERE entity_id = @e AND field = 'completion.status'", ("e", entity)))
            .ShouldBe("redo");

        var state = await app.HydrateAsync("Task", entity);
        state.Groups["completion"].Fields.Count.ShouldBe(1);
        state.Groups["completion"].Fields["status"].ShouldBe("redo");
    }

    /// <summary>
    /// Tombstone + C4 round-trip (B4): unseen-tag remove writes (hlc NULL, cancelled=true); a later
    /// same-tag add fills hlc but keeps cancelled; hydrated <c>HasDeleteEditConflict</c> equals the 2a
    /// in-memory result for isDeleted@10 + remove@5 + add@20 (the add stamp is above the delete key).
    /// </summary>
    [Fact]
    public async Task Tombstone_persists_and_delete_edit_conflict_matches_domain()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var client = Guid.NewGuid();
        var entity = Guid.NewGuid();
        var tag = Guid.NewGuid();

        var ops = new[]
        {
            Wire.TaskField(Guid.CreateVersion7(), client, entity, client, "isDeleted", "true", counter: 10),
            Wire.TaskSet(Guid.CreateVersion7(), client, entity, client, 5, adds: null,
                removes: [new WireSetRemove("el0", [tag], Wire.Hlc(client, 5))]),
            Wire.TaskSet(Guid.CreateVersion7(), client, entity, client, 20,
                adds: [new WireSetAdd("el0", tag, Wire.Hlc(client, 20))], removes: null),
        };

        var response = await app.SyncAsync(client, new SyncRequest(client, null, new WireCursor(9_000_000_000_000_000_000UL, 0), ops));
        response.Applied.ShouldAllBe(r => r.Code == "Applied");

        // The tag row: add filled hlc, but the earlier remove kept cancelled = true (born-dead stamp kept).
        (await Db.ScalarAsync<bool>(connectionString,
            "SELECT cancelled FROM sync_orset_tags WHERE entity_id = @e AND add_tag = @t", ("e", entity), ("t", tag))).ShouldBeTrue();
        (await Db.ScalarAsync<string>(connectionString,
            "SELECT hlc FROM sync_orset_tags WHERE entity_id = @e AND add_tag = @t", ("e", entity), ("t", tag))).ShouldNotBeNull();

        var state = await app.HydrateAsync("Task", entity);
        state.HasDeleteEditConflict.ShouldBeTrue(); // add stamp @20 is above isDeleted key @10
    }
}

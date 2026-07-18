using System.Text.Json;
using Momentum.Application.Features.Sync;
using Npgsql;
using Shouldly;
using Xunit;

namespace Momentum.Persistence.Tests;

[Collection(PostgresCollection.Name)]
public sealed class SyncRoundTripTests(PostgresFixture fixture)
{
    [Fact]
    public async Task Push_then_incremental_pull_returns_the_change()
    {
        await using var app = new SyncTestApp(await TestDatabase.CreateAsync(fixture));
        var client = Guid.NewGuid();
        var entity = Guid.NewGuid();
        var op = Wire.TaskField(Guid.CreateVersion7(), client, entity, client, "title", "Milk");

        var response = await app.SyncAsync(client, new SyncRequest(client, null, new WireCursor(0, 0), [op]));

        response.Applied.ShouldHaveSingleItem().Code.ShouldBe("Applied");
        var change = response.Changes.ShouldHaveSingleItem();
        change.Payload.GetProperty("entityType").GetString().ShouldBe("Task");
        change.Payload.GetProperty("fields").GetProperty("title").GetProperty("value").GetString().ShouldBe("Milk");
        response.NextCursor!.Xid.ShouldBeGreaterThan(0UL);
    }

    [Fact]
    public async Task Push_then_snapshot_returns_the_entity_with_horizon_cursor()
    {
        await using var app = new SyncTestApp(await TestDatabase.CreateAsync(fixture));
        var client = Guid.NewGuid();
        var entity = Guid.NewGuid();
        var op = Wire.TaskField(Guid.CreateVersion7(), client, entity, client, "title", "Eggs");

        var response = await app.SyncAsync(client, Wire.PushOnly(client, op)); // sinceCursor == null -> snapshot

        response.Snapshot.ShouldNotBeNull();
        var snapshotEntity = response.Snapshot.ShouldHaveSingleItem();
        snapshotEntity.EntityId.ShouldBe(entity);
        snapshotEntity.Scalars.ShouldContain(s => s.Field == "title" && s.Value == "Eggs");
        response.NextCursor!.Seq.ShouldBe(0); // (horizon, 0)
    }

    [Fact]
    public async Task Idempotent_replay_yields_one_outbox_row_and_duplicate_with_original_effective()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var client = Guid.NewGuid();
        var entity = Guid.NewGuid();
        var op = Wire.TaskField(Guid.CreateVersion7(), client, entity, client, "title", "Bread");

        var first = await app.SyncAsync(client, Wire.PushOnly(client, op));
        var applied = first.Applied.ShouldHaveSingleItem();
        applied.Code.ShouldBe("Applied");

        var second = await app.SyncAsync(client, Wire.PushOnly(client, op));
        var duplicate = second.Applied.ShouldHaveSingleItem();
        duplicate.Code.ShouldBe("Duplicate");
        JsonSerializer.Serialize(duplicate.EffectiveOpHlc).ShouldBe(JsonSerializer.Serialize(applied.EffectiveOpHlc));

        (await CountAsync(connectionString, "SELECT count(*) FROM outbox_messages")).ShouldBe(1);
        (await CountAsync(connectionString, "SELECT count(*) FROM sync_scalar_meta WHERE field = 'title'")).ShouldBe(1);
    }

    private static async Task<long> CountAsync(string connectionString, string sql)
    {
        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();
        await using var command = connection.CreateCommand();
        command.CommandText = sql;
        return (long)(await command.ExecuteScalarAsync())!;
    }
}

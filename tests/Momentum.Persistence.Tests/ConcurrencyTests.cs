using Momentum.Application.Features.Sync;
using Shouldly;
using Xunit;

namespace Momentum.Persistence.Tests;

[Collection(PostgresCollection.Name)]
public sealed class ConcurrencyTests(PostgresFixture fixture)
{
    /// <summary>
    /// H12 (ADR 0002 K2-H12): 8 parallel ops for ONE client, each on its OWN entity (so only the client
    /// advisory lock serializes them) and carrying IDENTICAL opHlc. Effective HLCs must be distinct (no
    /// lost update), dedup rows exactly 8, and the client clock a single row.
    /// </summary>
    [Fact]
    public async Task H12_concurrent_same_client_ingest_no_lost_update()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var client = Guid.NewGuid();

        var tasks = Enumerable.Range(0, 8).Select(_ =>
        {
            // Same opHlc (counter 0, wallOffset 0) on DIFFERENT entities -> entity lock cannot serialize.
            var op = Wire.TaskField(Guid.CreateVersion7(), client, Guid.NewGuid(), client, "title", "v");
            return app.SyncAsync(client, new SyncRequest(client, null, new WireCursor(0, 0), [op]));
        }).ToArray();

        var responses = await Task.WhenAll(tasks);

        responses.ShouldAllBe(r => r.Applied[0].Code == "Applied");
        var effectives = responses.Select(r => r.Applied[0].EffectiveOpHlc).ToList();
        effectives.Distinct().Count().ShouldBe(8); // distinct -> GREATEST + client-lock held, no back-jump

        (await Db.ScalarAsync<long>(connectionString, "SELECT count(*) FROM processed_operations WHERE client_id = @c", ("c", client)))
            .ShouldBe(8);
        (await Db.ScalarAsync<long>(connectionString, "SELECT count(*) FROM sync_client_clock WHERE client_id = @c", ("c", client)))
            .ShouldBe(1);
    }

    /// <summary>
    /// Different-client same-entity race (B1 closure): two clients write the same field concurrently; the
    /// larger HlcKey wins in the materialized row (entity lock -> no lost update; hydrate -> Domain LWW).
    /// </summary>
    [Fact]
    public async Task Different_clients_same_entity_larger_hlckey_wins()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var entity = Guid.NewGuid();
        var clientHigh = Guid.NewGuid();
        var clientLow = Guid.NewGuid();

        var high = Wire.TaskField(Guid.CreateVersion7(), clientHigh, entity, clientHigh, "title", "HIGH", counter: 5);
        var low = Wire.TaskField(Guid.CreateVersion7(), clientLow, entity, clientLow, "title", "LOW", counter: 2);

        await Task.WhenAll(
            app.SyncAsync(clientHigh, new SyncRequest(clientHigh, null, new WireCursor(0, 0), [high])),
            app.SyncAsync(clientLow, new SyncRequest(clientLow, null, new WireCursor(0, 0), [low])));

        (await Db.ScalarAsync<string>(connectionString,
            "SELECT value FROM sync_scalar_meta WHERE entity_type = 'Task' AND entity_id = @e AND field = 'title'", ("e", entity)))
            .ShouldBe("HIGH");
    }
}

using Momentum.Application.Features.Sync;
using Momentum.Domain.Sync;
using Shouldly;
using Xunit;

namespace Momentum.Persistence.Tests;

/// <summary>
/// D4 (ADR 0002 ERRATA E-1, GOREV slice-2c): a write → hydrate → re-apply END-TO-END persistence
/// regression, through the REAL <c>/v1/sync</c> path (lock → hydrate → Domain decides → persist), NOT a
/// gate for D2 (D2's gate is the direct-call API-contract unit test in
/// <c>OrSetConvergenceRegressionTests.LoadTag_called_twice_for_the_same_tag_keeps_the_higher_stamp</c>).
/// </summary>
[Collection(PostgresCollection.Name)]
public sealed class OrSetPersistenceRoundTripTests(PostgresFixture fixture)
{
    [Fact]
    public async Task Orset_tag_stamp_survives_write_hydrate_reapply_cycle_as_the_max()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var client = Guid.NewGuid();
        var entity = Guid.NewGuid();
        var tag = Guid.NewGuid();

        var highStamp = new Hlc(Wire.BaseWall, 5, client);

        // WRITE (real /v1/sync path): the higher-stamped add is processed FIRST; a lower-stamped add for
        // the SAME tag arrives in a SEPARATE, later op.
        await app.SyncAsync(client, Wire.PushNoPull(client,
            Wire.TaskSet(Guid.CreateVersion7(), client, entity, client, counter: 5,
                adds: [new WireSetAdd("el0", tag, Wire.Hlc(client, 5))], removes: null)));
        await app.SyncAsync(client, Wire.PushNoPull(client,
            Wire.TaskSet(Guid.CreateVersion7(), client, entity, client, counter: 1,
                adds: [new WireSetAdd("el0", tag, Wire.Hlc(client, 1))], removes: null)));

        // HYDRATE from persistence.
        var hydrated = await app.HydrateAsync("Task", entity);
        hydrated.TryGetSet("tags", out var hydratedSet).ShouldBeTrue();
        hydratedSet.TryGetTag("el0", tag, out var hydratedHlc, out _).ShouldBeTrue();
        hydratedHlc.ShouldNotBeNull();
        hydratedHlc!.Value.ShouldBe(highStamp);

        // RE-APPLY an even-lower stamp on the hydrated in-memory state -- the max-join must hold there too.
        var evenLower = new Hlc(Wire.BaseWall - 1, 0, client);
        hydratedSet.ApplyAdd(new SetAdd("el0", tag, evenLower));
        hydratedSet.MaxStamp().ShouldNotBeNull();
        hydratedSet.MaxStamp()!.Value.ShouldBe(highStamp);
    }
}

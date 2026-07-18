using Microsoft.Extensions.DependencyInjection;
using Momentum.Application.Abstractions.Sync;
using Momentum.Domain.Sync;
using Shouldly;
using Xunit;

namespace Momentum.Persistence.Tests;

[Collection(PostgresCollection.Name)]
public sealed class RollbackAtomicityTests(PostgresFixture fixture)
{
    // Faults AFTER the outbox write (RecordAsync is the last write before commit in the handler).
    private sealed class ThrowingProcessedOperations : IProcessedOperations
    {
        public Task<ProcessedRecord?> GetAsync(Guid clientId, Guid operationId, CancellationToken cancellationToken) =>
            Task.FromResult<ProcessedRecord?>(null);

        public Task RecordAsync(Guid clientId, Guid operationId, IngestResultCode code, Hlc? effectiveOpHlc, CancellationToken cancellationToken) =>
            throw new InvalidOperationException("fault injected after the outbox write");
    }

    /// <summary>
    /// Rollback atomicity (mutant-5 surface): a fault after the outbox write rolls the op transaction
    /// back, so the outbox row (written in the SAME transaction) is gone — no orphan. mutant-5 (outbox on
    /// a separate connection/commit) would leave the orphan behind.
    /// </summary>
    [Fact]
    public async Task Fault_after_outbox_write_rolls_back_the_outbox_row()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        var client = Guid.NewGuid();
        var op = Wire.TaskField(Guid.CreateVersion7(), client, Guid.NewGuid(), client, "title", "x");

        await using var app = new SyncTestApp(connectionString,
            configure: services => services.AddScoped<IProcessedOperations, ThrowingProcessedOperations>());

        await Should.ThrowAsync<InvalidOperationException>(() => app.SyncAsync(client, Wire.PushNoPull(client, op)));

        (await Db.ScalarAsync<long>(connectionString, "SELECT count(*) FROM outbox_messages")).ShouldBe(0);
        (await Db.ScalarAsync<long>(connectionString, "SELECT count(*) FROM sync_scalar_meta")).ShouldBe(0);
    }
}

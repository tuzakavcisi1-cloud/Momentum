using Microsoft.EntityFrameworkCore;
using Momentum.Infrastructure.Persistence;
using Shouldly;
using Xunit;

namespace Momentum.Persistence.Tests;

/// <summary>DB-less model validation (ADR 0001 K-F1): building the model must succeed.</summary>
public sealed class ModelValidationTests
{
    [Fact]
    public void Model_is_valid_and_has_seven_tables()
    {
        var options = new DbContextOptionsBuilder<SyncDbContext>()
            .UseNpgsql("Host=localhost;Database=x;Username=x;Password=x")
            .Options;

        using var db = new SyncDbContext(options);

        db.Model.GetEntityTypes().Count().ShouldBe(7); // building IModel throws if invalid
    }
}

[Collection(PostgresCollection.Name)]
public sealed class SchemaTests(PostgresFixture fixture)
{
    [Fact]
    public async Task UuidV7_preserves_time_order_under_order_by()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        var generated = Enumerable.Range(0, 50)
            .Select(i => Guid.CreateVersion7(DateTimeOffset.FromUnixTimeMilliseconds(Wire.BaseWall + i)))
            .ToList();

        await using var connection = await Db.OpenAsync(connectionString);
        await Db.ExecuteAsync(connection, null, "CREATE TEMP TABLE u (id uuid)");
        foreach (var id in generated)
        {
            await Db.ExecuteAsync(connection, null, "INSERT INTO u VALUES (@i)", ("i", id));
        }

        var ordered = new List<Guid>();
        await using (var command = connection.CreateCommand())
        {
            command.CommandText = "SELECT id FROM u ORDER BY id";
            await using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                ordered.Add(reader.GetGuid(0));
            }
        }

        ordered.ShouldBe(generated); // uuid ORDER BY == generation order (index-friendly, K-E1)
    }

    [Fact]
    public async Task Outbox_has_generated_cursor_columns_and_hlc_is_collation_c()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);

        (await Db.ScalarAsync<long>(connectionString,
            "SELECT count(*) FROM information_schema.columns WHERE table_name = 'outbox_messages' AND column_name IN ('commit_xid','server_seq')"))
            .ShouldBe(2);
        (await Db.ScalarAsync<string>(connectionString,
            "SELECT is_identity FROM information_schema.columns WHERE table_name = 'outbox_messages' AND column_name = 'server_seq'"))
            .ShouldBe("YES");
        (await Db.ScalarAsync<string>(connectionString,
            "SELECT collation_name FROM information_schema.columns WHERE table_name = 'outbox_messages' AND column_name = 'hlc'"))
            .ShouldBe("C");
    }
}

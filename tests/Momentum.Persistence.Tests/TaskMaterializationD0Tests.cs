using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Momentum.Application.Abstractions;
using Momentum.Application.Features.Sync;
using Shouldly;
using Xunit;

namespace Momentum.Persistence.Tests;

/// <summary>
/// D0 (GOREV slice-3a, KIRMIZI ONCE, PAZARLIKSIZ ilk is): three tests compiled against TODAY's tree
/// (no new C# types) that must fail at RUNTIME (missing "tasks"/"task_lists" tables, missing read
/// endpoints -> 404) before any slice-3a implementation exists. D0-a's own mutant does NOT exist (it is
/// a red-before smoke test / duman testi); the distinguishing gates for materialization/ownership are
/// D5-a/D5-b and mutants 1-16.
/// </summary>
[Collection(PostgresCollection.Name)]
public sealed class TaskMaterializationD0Tests(PostgresFixture fixture)
{
    /// <summary>D0-a: raw-SQL check that a Task op materializes a "tasks" row with the pushed values.</summary>
    [Fact]
    public async Task D0a_task_op_materializes_into_the_tasks_row()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actor = Guid.NewGuid();
        var entity = Guid.NewGuid();

        await app.SyncAsync(actor, Wire.PushNoPull(actor,
            Wire.TaskFields(Guid.CreateVersion7(), actor, entity, actor, 1, ("title", "Buy milk"), ("priority", "2"))));

        (await Db.ScalarAsync<string>(connectionString, "SELECT title FROM tasks WHERE entity_id = @e", ("e", entity)))
            .ShouldBe("Buy milk");
        (await Db.ScalarAsync<int>(connectionString, "SELECT priority FROM tasks WHERE entity_id = @e", ("e", entity)))
            .ShouldBe(2);
        (await Db.ScalarAsync<Guid>(connectionString, "SELECT owner_id FROM tasks WHERE entity_id = @e", ("e", entity)))
            .ShouldBe(actor);
    }

    /// <summary>
    /// D0-b: owner-filter gate, FIVE mandatory asserts (GOREV slice-3a pin — all five required, none may
    /// be dropped). Uses TWO WebApplicationFactory instances with FIXED, DISTINCT FakeCurrentUser identities
    /// pointed at the SAME database (FakeCurrentUser is fixed-identity per instance, TestSupport.cs).
    /// </summary>
    [Fact]
    public async Task D0b_owner_filter_gates_task_and_tasklist_visibility()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        var actorA = Guid.NewGuid();
        var actorB = Guid.NewGuid();

        await using var factoryA = new WebApplicationFactory<Program>().WithWebHostBuilder(builder => builder
            .UseSetting("ConnectionStrings:Momentum", connectionString)
            .ConfigureTestServices(services => services.AddScoped<ICurrentUser>(_ => new FakeCurrentUser(actorA))));
        await using var factoryB = new WebApplicationFactory<Program>().WithWebHostBuilder(builder => builder
            .UseSetting("ConnectionStrings:Momentum", connectionString)
            .ConfigureTestServices(services => services.AddScoped<ICurrentUser>(_ => new FakeCurrentUser(actorB))));

        var clientA = factoryA.CreateClient();
        var clientB = factoryB.CreateClient();

        await using var app = new SyncTestApp(connectionString);
        var taskEntity = Guid.NewGuid();

        await app.SyncAsync(actorA, Wire.PushNoPull(actorA,
            Wire.TaskFields(Guid.CreateVersion7(), actorA, taskEntity, actorA, 1, ("title", "A's task"))));

        // Assert 1: A sees the task (without this assert, the test would pass trivially once the
        // endpoint exists even if the owner filter were backwards -- it proves the POSITIVE case first).
        (await ContainsEntityAsync(clientA, "/v1/tasks", taskEntity)).ShouldBeTrue();

        // Assert 2: B does not see it.
        (await ContainsEntityAsync(clientB, "/v1/tasks", taskEntity)).ShouldBeFalse();

        // Assert 3: by-id -- A gets 200 + correct body, B gets 404 (an endpoint that always 404s would
        // fail A's leg; an endpoint that always 200s would fail B's leg).
        var byIdA = await clientA.GetAsync($"/v1/tasks/{taskEntity}");
        byIdA.StatusCode.ShouldBe(HttpStatusCode.OK);
        var bodyA = await byIdA.Content.ReadFromJsonAsync<JsonElement>();
        bodyA.GetProperty("entityId").GetGuid().ShouldBe(taskEntity);
        var byIdB = await clientB.GetAsync($"/v1/tasks/{taskEntity}");
        byIdB.StatusCode.ShouldBe(HttpStatusCode.NotFound);

        // Assert 4 [F5's gate]: authenticate the PUSH as A, but the wire op's own declared actorId is B
        // (an injection attempt) -- the materialized row must belong to A (the authenticated caller),
        // never to the wire-declared actor.
        var injectedEntity = Guid.NewGuid();
        await app.SyncAsync(actorA, Wire.PushNoPull(actorA,
            Wire.TaskFields(Guid.CreateVersion7(), actorA, injectedEntity, actorB, 1, ("title", "injected"))));
        (await clientA.GetAsync($"/v1/tasks/{injectedEntity}")).StatusCode.ShouldBe(HttpStatusCode.OK);
        (await ContainsEntityAsync(clientB, "/v1/tasks", injectedEntity)).ShouldBeFalse();

        // Assert 5: TaskList leg -- A writes a TaskList, A sees it, B does not.
        var listEntity = Guid.NewGuid();
        await app.SyncAsync(actorA, Wire.PushNoPull(actorA, Wire.Op(Guid.CreateVersion7(), actorA, listEntity, actorA, 1,
            fields: new Dictionary<string, WireFieldWrite>(StringComparer.Ordinal) { ["name"] = new("My List", Wire.Hlc(actorA, 1)) },
            entityType: "TaskList")));
        (await ContainsEntityAsync(clientA, "/v1/task-lists", listEntity)).ShouldBeTrue();
        (await ContainsEntityAsync(clientB, "/v1/task-lists", listEntity)).ShouldBeFalse();
    }

    /// <summary>
    /// D0-c: NULL-boundary keyset pagination. 3 tasks WITH listPos (pinned lexical order "m1"&lt;"m2"&lt;"m3"),
    /// 3 WITHOUT (Order channel never written for them -- NULL, tail group ordered by entity_id). The
    /// three NULL-group ids use EXPLICIT strictly-increasing millisecond timestamps (SchemaTests.
    /// UuidV7_preserves_time_order_under_order_by's pattern) so Postgres ORDER BY == construction order;
    /// bare back-to-back Guid.CreateVersion7() calls land in the SAME millisecond and tie-break on
    /// RANDOM bits, NOT a monotonic counter (measured -- an earlier draft of this test assumed otherwise
    /// and failed on ordering alone, all 6 ids present/distinct). limit=2.
    /// SERT TUR SINIRI (PAZARLIKSIZ): bounded for-loop, max 10 rounds -- unbounded while is FORBIDDEN.
    /// </summary>
    [Fact]
    public async Task D0c_keyset_pagination_crosses_the_null_boundary_without_gaps_or_repeats()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actor = Guid.NewGuid();

        var withPos = new (Guid Entity, string Pos)[]
        {
            (Guid.NewGuid(), "m1"),
            (Guid.NewGuid(), "m2"),
            (Guid.NewGuid(), "m3"),
        };
        foreach (var (entity, pos) in withPos)
        {
            await app.SyncAsync(actor, Wire.PushNoPull(actor, TaskOrderOp(actor, entity, "listPos", pos, 1)));
        }

        // Explicit, STRICTLY INCREASING millisecond timestamps -- back-to-back bare Guid.CreateVersion7()
        // calls land in the SAME millisecond and tie-break on RANDOM bits (not a monotonic counter), so
        // generation order alone does NOT guarantee Postgres ORDER BY order (unlike SchemaTests.
        // UuidV7_preserves_time_order_under_order_by, which forces distinct milliseconds the same way).
        var noPos = Enumerable.Range(0, 3)
            .Select(i => Guid.CreateVersion7(DateTimeOffset.FromUnixTimeMilliseconds(Wire.BaseWall + i)))
            .ToArray();
        foreach (var entity in noPos)
        {
            await app.SyncAsync(actor, Wire.PushNoPull(actor,
                Wire.TaskFields(Guid.CreateVersion7(), actor, entity, actor, 1, ("title", "no-pos"))));
        }

        var expectedOrder = withPos.Select(t => t.Entity).Concat(noPos).ToList();

        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder => builder
            .UseSetting("ConnectionStrings:Momentum", connectionString)
            .ConfigureTestServices(services => services.AddScoped<ICurrentUser>(_ => new FakeCurrentUser(actor))));
        var client = factory.CreateClient();

        var collected = new List<Guid>();
        string? cursor = null;
        for (var page = 0; page < 10; page++)
        {
            var url = cursor is null ? "/v1/tasks?limit=2" : $"/v1/tasks?limit=2&cursor={Uri.EscapeDataString(cursor)}";
            var response = await client.GetFromJsonAsync<JsonElement>(url);
            foreach (var item in response.GetProperty("items").EnumerateArray())
            {
                collected.Add(item.GetProperty("entityId").GetGuid());
            }

            var next = response.GetProperty("nextCursor");
            if (next.ValueKind == JsonValueKind.Null)
            {
                break;
            }

            cursor = next.GetString();
        }

        collected.Count.ShouldBe(6);
        collected.Distinct().Count().ShouldBe(6);
        collected.ShouldBe(expectedOrder);
    }

    private static async Task<bool> ContainsEntityAsync(HttpClient client, string path, Guid entityId)
    {
        var page = await client.GetFromJsonAsync<JsonElement>(path);
        return page.GetProperty("items").EnumerateArray().Any(item => item.GetProperty("entityId").GetGuid() == entityId);
    }

    /// <summary>
    /// ORDER KANALI PINI (GOREV slice-3a D0): Wire has no Order helper -- WireOp is built INLINE so a
    /// registry-violation mutation cannot masquerade as this test being "wrong for the wrong reason".
    /// </summary>
    private static WireOp TaskOrderOp(Guid client, Guid entity, string field, string value, uint counter) =>
        new(Guid.CreateVersion7(), client, entity, client, "Task", Wire.Hlc(client, counter),
            Fields: null, Sets: null, Groups: null,
            Order: new Dictionary<string, WireFieldWrite>(StringComparer.Ordinal) { [field] = new(value, Wire.Hlc(client, counter)) });
}

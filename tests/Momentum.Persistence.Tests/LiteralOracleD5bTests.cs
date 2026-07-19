using Momentum.Application.Features.Sync;
using Shouldly;
using Xunit;

namespace Momentum.Persistence.Tests;

/// <summary>
/// D5-b (GOREV slice-3a, ADR 0002 K2-I2) — the ASIL AYIRT EDICI kapi: the ORTAK SENARYO's nine steps,
/// each asserted against HAND-WRITTEN LITERALS via raw SQL. <c>TaskProjection.From</c>/<c>TaskListProjection.From</c>
/// is NEVER called here (unlike D5-a, which is blind to a mutation shared by both the write and read
/// side of <c>From</c> -- these asserts pin the ACTUAL persisted bytes independently). Each step is its
/// own [Fact] against its OWN entity (isolation) so a failing mutant's kill surface is unambiguous.
/// </summary>
[Collection(PostgresCollection.Name)]
public sealed class LiteralOracleD5bTests(PostgresFixture fixture)
{
    /// <summary>
    /// Adim 1: title='x' + notes='y', then notes=null (DURUM 2: register VAR, HasValue, Value==null --
    /// NOT malformed). Kapiladigi mutant: mutant-14 (durum 2 yanlislikla malformed sayilirsa FAIL).
    /// </summary>
    [Fact]
    public async Task Adim1_legitimate_null_write_is_not_malformed()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actorA = Guid.NewGuid();
        var entity = Guid.NewGuid();

        await app.SyncAsync(actorA, Wire.PushNoPull(actorA,
            Wire.TaskFields(Guid.CreateVersion7(), actorA, entity, actorA, 1, ("title", "x"), ("notes", "y"))));
        await app.SyncAsync(actorA, Wire.PushNoPull(actorA,
            Wire.TaskFields(Guid.CreateVersion7(), actorA, entity, actorA, 2, ("notes", null))));

        (await Db.ScalarAsync<string>(connectionString, "SELECT title FROM tasks WHERE entity_id = @e", ("e", entity))).ShouldBe("x");
        (await Db.ScalarAsync<string>(connectionString, "SELECT notes FROM tasks WHERE entity_id = @e", ("e", entity))).ShouldBeNull();
        (await Db.ScalarAsync<string[]>(connectionString, "SELECT malformed_fields FROM tasks WHERE entity_id = @e", ("e", entity))).ShouldBeEmpty();
    }

    /// <summary>Adim 2: group write -> a FEWER-member REPLACE deletes the unwritten member. Kapiladigi mutant: mutant-1 (delta-shaped writer leaves it stale).</summary>
    [Fact]
    public async Task Adim2_group_replace_with_fewer_members_deletes_the_unwritten_member()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actorA = Guid.NewGuid();
        var entity = Guid.NewGuid();

        await app.SyncAsync(actorA, Wire.PushNoPull(actorA,
            Wire.TaskGroup(Guid.CreateVersion7(), actorA, entity, actorA, 1, ("status", "done"), ("completedAt", "2026-07-19T10:00:00Z"))));
        await app.SyncAsync(actorA, Wire.PushNoPull(actorA,
            Wire.TaskGroup(Guid.CreateVersion7(), actorA, entity, actorA, 2, ("status", "done"))));

        (await Db.ScalarAsync<string>(connectionString, "SELECT status FROM tasks WHERE entity_id = @e", ("e", entity))).ShouldBe("done");
        (await Db.ScalarAsync<DateTime?>(connectionString, "SELECT completed_at FROM tasks WHERE entity_id = @e", ("e", entity))).ShouldBeNull();
    }

    /// <summary>Adim 3: tag add -> remove. Kapiladigi mutant: mutant-11 (PresentElements yerine filtresiz DumpTags kullanilirsa cancelled tag yine gorunur).</summary>
    [Fact]
    public async Task Adim3_removed_tag_does_not_appear_in_task_tags()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actorA = Guid.NewGuid();
        var entity = Guid.NewGuid();
        var tag = Guid.NewGuid();

        await app.SyncAsync(actorA, Wire.PushNoPull(actorA,
            Wire.TaskSet(Guid.CreateVersion7(), actorA, entity, actorA, 1, adds: [new WireSetAdd("el0", tag, Wire.Hlc(actorA, 1))], removes: null)));
        await app.SyncAsync(actorA, Wire.PushNoPull(actorA,
            Wire.TaskSet(Guid.CreateVersion7(), actorA, entity, actorA, 2, adds: null, removes: [new WireSetRemove("el0", [tag], Wire.Hlc(actorA, 2))])));

        (await ReadTagsAsync(connectionString, entity)).ShouldBeEmpty();
    }

    /// <summary>Adim 4: isDeleted:true + a HIGHER-stamped op touching ONLY the tags channel. Kapiladigi mutant: mutant-10 (HasDeleteEditConflict sabit false).</summary>
    [Fact]
    public async Task Adim4_tags_only_edit_above_the_delete_stamp_surfaces_the_conflict_flag()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actorA = Guid.NewGuid();
        var entity = Guid.NewGuid();
        var tag = Guid.NewGuid();

        await app.SyncAsync(actorA, Wire.PushNoPull(actorA,
            Wire.TaskField(Guid.CreateVersion7(), actorA, entity, actorA, "isDeleted", "true", counter: 5)));
        await app.SyncAsync(actorA, Wire.PushNoPull(actorA,
            Wire.TaskSet(Guid.CreateVersion7(), actorA, entity, actorA, 10, adds: [new WireSetAdd("el0", tag, Wire.Hlc(actorA, 10))], removes: null)));

        (await Db.ScalarAsync<bool>(connectionString, "SELECT has_delete_edit_conflict FROM tasks WHERE entity_id = @e", ("e", entity))).ShouldBeTrue();
    }

    /// <summary>Adim 5: unparseable dueAt ("07/19/2026", InvariantCulture's own ShortDatePattern). Kapiladigi mutant: mutant-7 (lenient TryParse would silently accept it).</summary>
    [Fact]
    public async Task Adim5_unparseable_date_is_null_and_malformed()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actorA = Guid.NewGuid();
        var entity = Guid.NewGuid();

        await app.SyncAsync(actorA, Wire.PushNoPull(actorA,
            Wire.TaskField(Guid.CreateVersion7(), actorA, entity, actorA, "dueAt", "07/19/2026", counter: 1)));

        (await Db.ScalarAsync<DateTime?>(connectionString, "SELECT due_at FROM tasks WHERE entity_id = @e", ("e", entity))).ShouldBeNull();
        (await Db.ScalarAsync<string[]>(connectionString, "SELECT malformed_fields FROM tasks WHERE entity_id = @e", ("e", entity))).ShouldBe(["dueAt"]);
    }

    /// <summary>
    /// Adim 6: a SECOND op on the SAME entity, authenticated as a DIFFERENT, real actor B. PIN: the
    /// WIRE actorId is NOT distinguishing here (F5 already means owner_id comes only from command.ActorId);
    /// what matters is B being AUTHENTICATED (SyncAsync's own actorId param). Kapiladigi mutant: mutant-2
    /// (owner_id added to DO UPDATE SET would let B's later write steal ownership from first-writer A).
    /// </summary>
    [Fact]
    public async Task Adim6_second_authenticated_actor_does_not_steal_ownership()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actorA = Guid.NewGuid();
        var actorB = Guid.NewGuid();
        var entity = Guid.NewGuid();

        await app.SyncAsync(actorA, Wire.PushNoPull(actorA,
            Wire.TaskField(Guid.CreateVersion7(), actorA, entity, actorA, "title", "first", counter: 1)));
        await app.SyncAsync(actorB, Wire.PushNoPull(actorB,
            Wire.TaskField(Guid.CreateVersion7(), actorB, entity, actorB, "title", "second", counter: 2)));

        (await Db.ScalarAsync<Guid>(connectionString, "SELECT owner_id FROM tasks WHERE entity_id = @e", ("e", entity))).ShouldBe(actorA);
    }

    /// <summary>Adim 7: Task Order channel -- listPos + boardPos, one changed later. Kapiladigi mutant: mutant-16 (defensive Fields-read of an Orders-only channel -> silent NULL).</summary>
    [Fact]
    public async Task Adim7_task_order_channel_persists_both_fractional_columns()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actorA = Guid.NewGuid();
        var entity = Guid.NewGuid();

        await app.SyncAsync(actorA, Wire.PushNoPull(actorA, OrderOp(actorA, entity, "Task", "listPos", "p1", 1)));
        await app.SyncAsync(actorA, Wire.PushNoPull(actorA, OrderOp(actorA, entity, "Task", "boardPos", "b1", 2)));
        await app.SyncAsync(actorA, Wire.PushNoPull(actorA, OrderOp(actorA, entity, "Task", "listPos", "p2", 3)));

        (await Db.ScalarAsync<string>(connectionString, "SELECT list_pos FROM tasks WHERE entity_id = @e", ("e", entity))).ShouldBe("p2");
        (await Db.ScalarAsync<string>(connectionString, "SELECT board_pos FROM tasks WHERE entity_id = @e", ("e", entity))).ShouldBe("b1");
    }

    /// <summary>Adim 8: TaskList -- name + pos (Order channel), then name changed. Kapiladigi mutant: mutant-16 (the TaskList side of the symmetric fix, v4's asymmetry).</summary>
    [Fact]
    public async Task Adim8_tasklist_order_channel_and_name_change_both_persist()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actorA = Guid.NewGuid();
        var entity = Guid.NewGuid();

        await app.SyncAsync(actorA, Wire.PushNoPull(actorA, TaskListFieldOp(actorA, entity, "name", "Original", 1)));
        await app.SyncAsync(actorA, Wire.PushNoPull(actorA, OrderOp(actorA, entity, "TaskList", "pos", "z1", 2)));
        await app.SyncAsync(actorA, Wire.PushNoPull(actorA, TaskListFieldOp(actorA, entity, "name", "Renamed", 3)));

        (await Db.ScalarAsync<string>(connectionString, "SELECT name FROM task_lists WHERE entity_id = @e", ("e", entity))).ShouldBe("Renamed");
        (await Db.ScalarAsync<string>(connectionString, "SELECT pos FROM task_lists WHERE entity_id = @e", ("e", entity))).ShouldBe("z1");
    }

    /// <summary>
    /// Adim 9: isDeleted="True" (capital T) + a HIGHER-stamped title write. D2 durum tablosu md.4: Ordinal
    /// equality is not "parsing" -- there is no malformed state for isDeleted, and malformed_fields does
    /// NOT contain "isDeleted" here. Kapiladigi mutant: mutant-9 (bool.TryParse would treat "True" as deleted).
    /// </summary>
    [Fact]
    public async Task Adim9_ordinal_case_sensitive_isdeleted_is_not_deleted_and_has_no_conflict()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actorA = Guid.NewGuid();
        var entity = Guid.NewGuid();

        await app.SyncAsync(actorA, Wire.PushNoPull(actorA,
            Wire.TaskField(Guid.CreateVersion7(), actorA, entity, actorA, "isDeleted", "True", counter: 5)));
        await app.SyncAsync(actorA, Wire.PushNoPull(actorA,
            Wire.TaskField(Guid.CreateVersion7(), actorA, entity, actorA, "title", "later-edit", counter: 10)));

        (await Db.ScalarAsync<bool>(connectionString, "SELECT is_deleted FROM tasks WHERE entity_id = @e", ("e", entity))).ShouldBeFalse();
        (await Db.ScalarAsync<bool>(connectionString, "SELECT has_delete_edit_conflict FROM tasks WHERE entity_id = @e", ("e", entity))).ShouldBeFalse();
        (await Db.ScalarAsync<string[]>(connectionString, "SELECT malformed_fields FROM tasks WHERE entity_id = @e", ("e", entity))).ShouldNotContain("isDeleted");
    }

    /// <summary>ORDER KANALI PINI: WireOp built INLINE (Wire has no Order helper).</summary>
    private static WireOp OrderOp(Guid client, Guid entity, string entityType, string field, string value, uint counter) =>
        new(Guid.CreateVersion7(), client, entity, client, entityType, Wire.Hlc(client, counter),
            Fields: null, Sets: null, Groups: null,
            Order: new Dictionary<string, WireFieldWrite>(StringComparer.Ordinal) { [field] = new(value, Wire.Hlc(client, counter)) });

    private static WireOp TaskListFieldOp(Guid client, Guid entity, string field, string value, uint counter) =>
        Wire.Op(Guid.CreateVersion7(), client, entity, client, counter,
            fields: new Dictionary<string, WireFieldWrite>(StringComparer.Ordinal) { [field] = new(value, Wire.Hlc(client, counter)) },
            entityType: "TaskList");

    private static async Task<List<string>> ReadTagsAsync(string connectionString, Guid taskId)
    {
        await using var connection = await Db.OpenAsync(connectionString);
        await using var command = connection.CreateCommand();
        command.CommandText = "SELECT tag FROM task_tags WHERE task_id = @id ORDER BY tag";
        command.Parameters.AddWithValue("id", taskId);

        var tags = new List<string>();
        await using var reader = await command.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            tags.Add(reader.GetString(0));
        }

        return tags;
    }
}

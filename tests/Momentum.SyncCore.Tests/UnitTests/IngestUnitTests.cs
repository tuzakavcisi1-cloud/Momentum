using System.Collections.Concurrent;
using Momentum.Domain.Sync;
using Momentum.SyncCore.Tests.TestUtil;
using Shouldly;
using Xunit;

namespace Momentum.SyncCore.Tests.UnitTests;

public sealed class IngestUnitTests
{
    private static Hlc H(long wall, uint counter) => new(wall, counter, Ids.Client(0));

    /// <summary>
    /// P4 parallel arm: 8 threads x 50 ops for ONE client -> effective op-HLCs are all distinct
    /// (no lost update), and the per-client clock stays monotone (a following op strictly exceeds all).
    /// </summary>
    [Fact]
    public void Parallel_same_client_ingest_no_lost_update_and_monotone()
    {
        var state = new SyncState();
        var ingest = new SyncIngest(state, new ClientClockStore());
        var effectives = new ConcurrentBag<Hlc>();

        Parallel.For(0, 8, thread =>
        {
            for (var k = 0; k < 50; k++)
            {
                var opIdx = (thread * 1000) + k + 1;
                var hlc = new Hlc(Scenario.BaseWall + (opIdx % 100), (uint)(opIdx % 7), Ids.Client(0));
                var op = Build.Op(opIdx, 0, 0, "Task", hlc, fields: Build.Fields(("title", "v" + opIdx, hlc)));
                var result = ingest.Ingest(op, Scenario.BaseWall);
                if (result is { Code: IngestResultCode.Applied, EffectiveOpHlc: { } effective })
                {
                    effectives.Add(effective);
                }
            }
        });

        effectives.Count.ShouldBe(400);
        effectives.Distinct().Count().ShouldBe(400); // no lost update -> no duplicate effective HLC

        var max = effectives.Aggregate((best, current) => current.CompareTo(best) > 0 ? current : best);
        var follow = ingest.Ingest(
            Build.Op(999_999, 0, 0, "Task", H(Scenario.BaseWall, 0), fields: Build.Fields(("title", "z", H(Scenario.BaseWall, 0)))),
            Scenario.BaseWall);
        follow.Code.ShouldBe(IngestResultCode.Applied);
        (follow.EffectiveOpHlc!.Value.CompareTo(max) > 0).ShouldBeTrue(); // clock retained the max (monotone)
    }

    [Fact]
    public void LwwRegister_equal_or_smaller_key_does_not_win()
    {
        var register = new LwwRegister();
        var write = new FieldWrite("first", H(100, 0));

        register.Apply(write, Ids.Op(1)).ShouldBeTrue();
        register.Apply(write, Ids.Op(1)).ShouldBeFalse(); // identical key -> not strictly greater
        register.Apply(new FieldWrite("older", H(50, 0)), Ids.Op(2)).ShouldBeFalse();

        register.Value.ShouldBe("first");
    }

    [Fact]
    public void Rejected_absurd_op_replays_with_same_code_via_dedup_before_clamp()
    {
        var state = new SyncState();
        var ingest = new SyncIngest(state, new ClientClockStore());
        const long receive = Scenario.BaseWall;

        var op = Build.Op(1, 0, 0, "Task", H(receive, 0),
            fields: Build.Fields(("title", "x", new Hlc(receive + HlcClamp.AbsurdForwardMs + 1_000, 0, Ids.Client(0)))));

        ingest.Ingest(op, receive).Code.ShouldBe(IngestResultCode.RejectedAbsurdHlc);

        // Replay at a later receive time where the HLC would NOT be absurd: dedup (before clamp) returns
        // the cached reject deterministically.
        var later = receive + HlcClamp.AbsurdForwardMs + 2_000;
        ingest.Ingest(op, later).Code.ShouldBe(IngestResultCode.RejectedAbsurdHlc);
    }

    [Fact]
    public void C4_delete_edit_conflict_surfaces_and_undelete_clears()
    {
        var state = new SyncState();
        var ingest = new SyncIngest(state, new ClientClockStore());
        const long receive = Scenario.BaseWall;

        ingest.Ingest(Build.Op(1, 0, 0, "Task", H(receive, 0), fields: Build.Fields(("isDeleted", "true", H(receive, 10)))), receive);
        var entity = state.Entities[("Task", Ids.Entity(0))];
        entity.HasDeleteEditConflict.ShouldBeFalse(); // delete only

        ingest.Ingest(Build.Op(2, 0, 0, "Task", H(receive, 0), fields: Build.Fields(("title", "late", H(receive, 20)))), receive);
        entity.HasDeleteEditConflict.ShouldBeTrue(); // edit stamp greater than the delete

        ingest.Ingest(Build.Op(3, 0, 0, "Task", H(receive, 0), fields: Build.Fields(("isDeleted", "false", H(receive, 30)))), receive);
        entity.HasDeleteEditConflict.ShouldBeFalse(); // undelete clears (value != "true")
    }

    [Fact]
    public void Effective_first_op_equals_clamped_op_hlc()
    {
        var state = new SyncState();
        var ingest = new SyncIngest(state, new ClientClockStore());
        const long receive = Scenario.BaseWall;
        var opHlc = new Hlc(receive, 5, Ids.Client(0));

        var result = ingest.Ingest(Build.Op(1, 0, 0, "Task", opHlc, fields: Build.Fields(("title", "x", opHlc))), receive);

        result.Code.ShouldBe(IngestResultCode.Applied);
        result.EffectiveOpHlc.ShouldBe(opHlc); // first op, within skew -> clamped == original
    }

    [Fact]
    public void Empty_op_is_rejected_invalid_and_not_recorded()
    {
        var state = new SyncState();
        var ingest = new SyncIngest(state, new ClientClockStore());

        var empty = Build.Op(1, 0, 0, "Task", H(Scenario.BaseWall, 0));
        ingest.Ingest(empty, Scenario.BaseWall).Code.ShouldBe(IngestResultCode.RejectedInvalid);

        // Not recorded: a later valid op with the SAME (clientId, operationId) is processed normally.
        var valid = empty with { Fields = Build.Fields(("title", "x", H(Scenario.BaseWall, 0))) };
        ingest.Ingest(valid, Scenario.BaseWall).Code.ShouldBe(IngestResultCode.Applied);
    }
}

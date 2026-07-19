using CsCheck;
using Momentum.Domain.Sync;
using Momentum.SyncCore.Tests.TestUtil;
using Shouldly;
using Xunit;

namespace Momentum.SyncCore.Tests.Properties;

/// <summary>
/// P7 (ADR 0002 K2-C2/H): OR-Set add-wins laws — membership converges under reordering (permanent
/// tombstone), remove only cancels observed tags, compaction is observational-equivalent with composed
/// remove-remap, and the cap is admission-control that leaves state unchanged on rejection.
/// </summary>
public sealed class OrSetProperties
{
    private static Hlc H(long wall) => new(wall, 0, Ids.Client(0));

    private sealed record SetOpSpec(bool IsAdd, int TagIdx, int[] Observed, long Wall);

    // Add/remove sequence on ONE element, NO compaction -> membership is order-independent.
    [Fact]
    public void P7_add_wins_membership_converges_under_reordering()
    {
        (from ops in
            (from isAdd in Gen.Bool
             from tag in Gen.Int[0, 5]
             from observed in Gen.Int[0, 5].Array[0, 3]
             from wall in Gen.Long[1, 1_000]
             select new SetOpSpec(isAdd, tag, observed, wall)).Array[1, 16]
         select ops)
            .Sample(
                ops =>
                {
                    var forward = MembershipAfter(ops);
                    var backward = MembershipAfter(ops.Reverse().ToArray());
                    forward.ShouldBe(backward);
                },
                iter: PropertyConfig.Iter);
    }

    private static bool MembershipAfter(IEnumerable<SetOpSpec> ops)
    {
        var set = new OrSetField();
        foreach (var op in ops)
        {
            if (op.IsAdd)
            {
                set.ApplyAdd(new SetAdd("el0", Ids.Tag(op.TagIdx), H(op.Wall)));
            }
            else
            {
                set.ApplyRemove(new SetRemove("el0", op.Observed.Select(Ids.Tag).ToList(), H(op.Wall)));
            }
        }

        return set.Contains("el0");
    }

    /// <summary>
    /// D2d (GOREV slice-2c, ADR 0002 ERRATA E-1) — commutativity property, GENERATOR PINNED: stamps draw
    /// <c>WallMs</c> from a small 3-value pool with <c>Counter</c>/<c>ClientIdx</c> varying independently,
    /// so WallMs-EQUAL/Counter-or-ClientId-DIFFERENT collisions are FORCED to occur often. <see cref="H"/>
    /// (used by the other P7 tests) fixes Counter=0/ClientIdx=0 — there, WallMs equality means "IDENTICAL
    /// stamp", which would let a half-max ("WallMs-only") merge rule pass completely undetected. That is
    /// exactly mutant-7's kill surface, and exactly where the real bug lived: duplicate clamp-ceiling
    /// WallMs values with different Counter/ClientId (KANIT/slice-2b2 BULGU-3).
    /// </summary>
    [Fact]
    public void P8_orset_add_merge_is_order_independent_including_wallms_ties()
    {
        var stampGen =
            from wallOffset in Gen.Int[0, 2]
            from counter in Gen.UInt[0u, 3u]
            from clientIdx in Gen.Int[0, 2]
            select new Hlc(1_700_000_000_000 + wallOffset, counter, Ids.Client(clientIdx));

        (from stamps in stampGen.Array[1, 8]
         from shuffleSeed in Gen.Int[1, int.MaxValue]
         select (stamps, shuffleSeed))
            .Sample(
                t =>
                {
                    var trueMax = t.stamps.Aggregate((a, b) => a.CompareTo(b) >= 0 ? a : b);

                    MaxStampAfterApplying(t.stamps).ShouldBe(trueMax);
                    MaxStampAfterApplying(t.stamps.Reverse().ToArray()).ShouldBe(trueMax);
                    MaxStampAfterApplying(Shuffled(t.stamps, t.shuffleSeed)).ShouldBe(trueMax);
                },
                iter: PropertyConfig.Iter);
    }

    private static Hlc MaxStampAfterApplying(IReadOnlyList<Hlc> stamps)
    {
        var set = new OrSetField();
        foreach (var stamp in stamps)
        {
            set.ApplyAdd(new SetAdd("el0", Ids.Tag(0), stamp));
        }

        return set.MaxStamp()!.Value;
    }

    private static Hlc[] Shuffled(Hlc[] stamps, int seed)
    {
        var copy = (Hlc[])stamps.Clone();
        var rng = new Random(seed);
        for (var i = copy.Length - 1; i > 0; i--)
        {
            var j = rng.Next(i + 1);
            (copy[i], copy[j]) = (copy[j], copy[i]);
        }

        return copy;
    }

    [Fact]
    public void P7_remove_only_cancels_observed_tags()
    {
        var set = new OrSetField();
        set.ApplyAdd(new SetAdd("el0", Ids.Tag(0), H(10)));
        set.ApplyAdd(new SetAdd("el0", Ids.Tag(1), H(20)));
        set.ApplyRemove(new SetRemove("el0", [Ids.Tag(0)], H(30)));

        set.Contains("el0").ShouldBeTrue(); // tag 1 survives (add-wins; unseen/unobserved add not cancelled)
    }

    [Fact]
    public void P7_tombstone_is_permanent_in_both_orders()
    {
        var addThenRemove = new OrSetField();
        addThenRemove.ApplyAdd(new SetAdd("el0", Ids.Tag(0), H(10)));
        addThenRemove.ApplyRemove(new SetRemove("el0", [Ids.Tag(0)], H(20)));
        addThenRemove.Contains("el0").ShouldBeFalse();

        var removeThenAdd = new OrSetField();
        removeThenAdd.ApplyRemove(new SetRemove("el0", [Ids.Tag(0)], H(20)));
        removeThenAdd.ApplyAdd(new SetAdd("el0", Ids.Tag(0), H(10))); // born dead
        removeThenAdd.Contains("el0").ShouldBeFalse();
    }

    [Fact]
    public void P7_compaction_preserves_membership_then_remove_remaps()
    {
        var set = new OrSetField();
        set.ApplyAdd(new SetAdd("el0", Ids.Tag(0), H(10)));
        set.ApplyAdd(new SetAdd("el0", Ids.Tag(1), H(20)));
        set.Contains("el0").ShouldBeTrue();

        set.CompactBelow(H(30)); // both below horizon -> collapse to canonical (highest = tag 1)
        set.Contains("el0").ShouldBeTrue();

        // A remove observing the compacted-away tag 0 must remap to the canonical and still delete.
        set.ApplyRemove(new SetRemove("el0", [Ids.Tag(0)], H(40)));
        set.Contains("el0").ShouldBeFalse();
    }

    [Fact]
    public void P7_two_chained_compactions_compose_the_remap()
    {
        var set = new OrSetField();
        set.ApplyAdd(new SetAdd("el0", Ids.Tag(0), H(10)));
        set.ApplyAdd(new SetAdd("el0", Ids.Tag(1), H(20)));
        set.CompactBelow(H(30)); // {0,1} -> canonical tag 1; remap 0 -> 1

        set.ApplyAdd(new SetAdd("el0", Ids.Tag(2), H(40)));
        set.CompactBelow(H(50)); // {1,2} -> canonical tag 2; remap 1 -> 2 (so 0 -> 1 -> 2 composes)
        set.Contains("el0").ShouldBeTrue();

        // Observing the original tag 0 must resolve transitively to tag 2 and delete the element.
        set.ApplyRemove(new SetRemove("el0", [Ids.Tag(0)], H(60)));
        set.Contains("el0").ShouldBeFalse();
    }

    [Fact]
    public void P7_cap_is_admission_control_at_the_exact_boundary()
    {
        // Exactly 100 new-active tags on a fresh element -> Applied.
        RunCap(addCount: SyncIngest.SetTagCap).ShouldBe(IngestResultCode.Applied);

        // 101 new-active tags on a fresh element -> rejected.
        RunCap(addCount: SyncIngest.SetTagCap + 1).ShouldBe(IngestResultCode.RejectedSetCapExceeded);

        // 100 present, then +1 genuinely new -> rejected; state unchanged.
        var state = new SyncState();
        var ingest = new SyncIngest(state, new ClientClockStore());
        ingest.Ingest(CapOp(1, 0, SyncIngest.SetTagCap), Scenario.BaseWall).Code.ShouldBe(IngestResultCode.Applied);
        var before = ProdProjector.Project(state);
        ingest.Ingest(CapOp(2, SyncIngest.SetTagCap, 1), Scenario.BaseWall).Code.ShouldBe(IngestResultCode.RejectedSetCapExceeded);
        ProdProjector.Project(state).ShouldBe(before);

        // Re-adding an already-active tag is not new-active -> stays at the cap, Applied.
        var reAdd = Build.Op(3, 0, 0, "Task", H(Scenario.BaseWall),
            sets: Build.Set("tags", [Build.Add("el0", 0, H(Scenario.BaseWall))], []));
        ingest.Ingest(reAdd, Scenario.BaseWall).Code.ShouldBe(IngestResultCode.Applied);
    }

    private static IngestResultCode RunCap(int addCount)
    {
        var state = new SyncState();
        var ingest = new SyncIngest(state, new ClientClockStore());
        return ingest.Ingest(CapOp(1, 0, addCount), Scenario.BaseWall).Code;
    }

    private static ChangeOperation CapOp(int opIdx, int firstTag, int count)
    {
        var adds = Enumerable.Range(firstTag, count)
            .Select(i => Build.Add("el0", i, H(Scenario.BaseWall)))
            .ToList();
        return Build.Op(opIdx, 0, 0, "Task", H(Scenario.BaseWall), sets: Build.Set("tags", adds, []));
    }
}

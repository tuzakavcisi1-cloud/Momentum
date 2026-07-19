using Momentum.Domain.Sync;
using Momentum.SyncCore.Tests.TestUtil;
using Shouldly;
using Xunit;

namespace Momentum.SyncCore.Tests.UnitTests;

/// <summary>
/// D0b (ADR 0002 ERRATA E-1, GOREV slice-2c) — a generator-independent, un-driftable literal
/// reproduction of the exact case D0's pinned CsCheck seed exercises: the SAME (element, tag) receives
/// two DIFFERENT stamps (A above <c>deleteKey</c>, B below it), and <c>isDeleted</c>'s key sits BETWEEN
/// them. This is the asserted-kept case even if D0's seed drifts under a future CsCheck/generator change.
/// </summary>
public sealed class OrSetConvergenceRegressionTests
{
    [Fact]
    public void OrSet_add_stamp_order_does_not_flip_the_derived_delete_conflict_flag()
    {
        var client = Ids.Client(0);
        var tag = Ids.Tag(0);

        // Literal values from the diagnosed case (KANIT/slice-2b2 BULGU-3): A is at the clamp ceiling
        // (op#4), B is a later, lower op (op#6); deleteKey sits strictly between them.
        var stampA = new Hlc(1_700_000_300_000, 5, client);
        var stampB = new Hlc(1_700_000_046_192, 0, client);
        var deleteKey = new HlcKey(new Hlc(1_700_000_300_000, 4, client), Ids.Op(3));

        // Sanity on the literal ordering the diagnosis reported: A > deleteKey.Hlc > B.
        stampA.CompareTo(deleteKey.Hlc).ShouldBeGreaterThan(0);
        deleteKey.Hlc.CompareTo(stampB).ShouldBeGreaterThan(0);

        var forward = ProjectConflictFlag(deleteKey, tag, stampA, stampB);
        var reverse = ProjectConflictFlag(deleteKey, tag, stampB, stampA);

        reverse.ShouldBe(forward); // order-independence -- the actual convergence bug
        forward.ShouldBeTrue(); // and the converged value must be the CORRECT one: max(A,B) = A > deleteKey
    }

    private static bool ProjectConflictFlag(HlcKey deleteKey, Guid tag, Hlc first, Hlc second)
    {
        var entity = new EntityState();
        entity.ApplyField("isDeleted", new FieldWrite("true", deleteKey.Hlc), deleteKey.OperationId);
        entity.GetOrCreateSet("tags").ApplyAdd(new SetAdd("el0", tag, first));
        entity.GetOrCreateSet("tags").ApplyAdd(new SetAdd("el0", tag, second));
        return entity.HasDeleteEditConflict;
    }

    /// <summary>
    /// D2 (GOREV slice-2c) — an API-CONTRACT gate, NOT a production-path gate: the persisted PK is
    /// <c>(entity_type, entity_id, set_name, element, add_tag)</c>, so <c>SyncRowHydration</c> calls
    /// <see cref="OrSetField.LoadTag"/> AT MOST ONCE per (element, tag) in production — the max-join
    /// only becomes observable if a caller invokes it twice for the same key, which is exactly what this
    /// test does. It proves <c>LoadTag</c> promises the SAME merge rule as <see cref="OrSetField.ApplyAdd"/>
    /// (mutant-3's only kill surface — see GOREV slice-2c D2/mutant-3).
    /// </summary>
    [Fact]
    public void LoadTag_called_twice_for_the_same_tag_keeps_the_higher_stamp()
    {
        var set = new OrSetField();
        var tag = Ids.Tag(0);
        var high = new Hlc(2_000, 0, Ids.Client(0));
        var low = new Hlc(1_000, 0, Ids.Client(0));

        set.LoadTag("el0", tag, high, cancelled: false);
        set.LoadTag("el0", tag, low, cancelled: false); // decreasing stamp -- must NOT overwrite

        set.MaxStamp().ShouldNotBeNull();
        set.MaxStamp()!.Value.ShouldBe(high);
    }

    /// <summary>D6 (GOREV slice-2c): pins the documented <see cref="OrSetField.CompactBelow"/> invariant
    /// — canonical-tag selection is the arg-max of the compacted set, so <see cref="OrSetField.MaxStamp"/>
    /// is unchanged by compaction.</summary>
    [Fact]
    public void CompactBelow_does_not_change_MaxStamp()
    {
        var set = new OrSetField();
        set.ApplyAdd(new SetAdd("el0", Ids.Tag(0), new Hlc(10, 0, Ids.Client(0))));
        set.ApplyAdd(new SetAdd("el0", Ids.Tag(1), new Hlc(20, 0, Ids.Client(0))));
        var before = set.MaxStamp();

        set.CompactBelow(new Hlc(30, 0, Ids.Client(0)));

        set.MaxStamp().ShouldBe(before);
    }
}

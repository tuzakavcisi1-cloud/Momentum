using Momentum.Domain.Sync;
using Momentum.SyncCore.Tests.TestUtil;
using Shouldly;
using Xunit;

namespace Momentum.SyncCore.Tests.UnitTests;

/// <summary>
/// D2b/D2c (ADR 0002 K2-C4, GOREV slice-2c) — positive, Docker-less unit gates for
/// <see cref="EntityState.HasDeleteEditConflict"/>'s TWO OR-Set-derived branches (add-activity and
/// remove-activity, via <see cref="OrSetField.MaxStamp"/>). Each fixture ISOLATES all four
/// <c>HasDeleteEditConflict</c> channels (fields/orders/groups/sets): only <c>isDeleted</c> is written
/// among fields, and no order/group register is touched at all — so a mutant that guts ONE branch of
/// <c>MaxStamp</c> is observable ONLY through that branch. A fixture that also let some other channel
/// exceed <c>deleteKey</c> would let the mutant hide behind that channel (v2's fixtures only isolated
/// the remove channel, per GOREV slice-2c D2b/D2c "İZOLASYON PİNİ").
/// </summary>
public sealed class DeleteEditConflictTests
{
    /// <summary>
    /// D2b: an OR-Set ADD stamped above <c>deleteKey</c> surfaces the conflict. mutant-5 (MaxStamp drops
    /// the Adds loop) fails this. <c>SemanticRoundTripTests.Tombstone_persists_and_delete_edit_conflict_
    /// matches_domain</c> (Persistence.Tests, Docker) already covers this path end-to-end; D2b's value is
    /// being the Docker-less UNIT-level equivalent of that same gate (GOREV slice-2c D2b honesty note).
    /// </summary>
    [Fact]
    public void Add_stamped_above_delete_key_surfaces_conflict()
    {
        var entity = new EntityState();
        var deleteKey = new HlcKey(new Hlc(10_000, 0, Ids.Client(0)), Ids.Op(0));
        entity.ApplyField("isDeleted", new FieldWrite("true", deleteKey.Hlc), deleteKey.OperationId);

        // ONLY an add above deleteKey -- no removes, no other field/order/group register touched.
        entity.GetOrCreateSet("tags").ApplyAdd(new SetAdd("el0", Ids.Tag(0), new Hlc(20_000, 0, Ids.Client(0))));

        entity.HasDeleteEditConflict.ShouldBeTrue();
    }

    /// <summary>
    /// D2c: an OR-Set REMOVE (of a never-seen tag) stamped above <c>deleteKey</c> surfaces the conflict.
    /// No test in the tree asserted this branch before this slice (GOREV slice-2c D2c: "mutant-6'nın
    /// bugün ısırma yüzeyi YOKTUR" — <c>SemanticRoundTripTests</c> uses remove@5 &lt; isDeleted@10, so
    /// that dial staying green does not depend on the remove branch at all).
    /// </summary>
    [Fact]
    public void Remove_of_an_unseen_tag_stamped_above_delete_key_surfaces_conflict()
    {
        var entity = new EntityState();
        var deleteKey = new HlcKey(new Hlc(10_000, 0, Ids.Client(0)), Ids.Op(0));
        entity.ApplyField("isDeleted", new FieldWrite("true", deleteKey.Hlc), deleteKey.OperationId);

        // ONLY a remove (of a NEVER-added tag) above deleteKey -- no adds, no other field/order/group
        // register touched.
        entity.GetOrCreateSet("tags").ApplyRemove(new SetRemove("el0", [Ids.Tag(0)], new Hlc(20_000, 0, Ids.Client(0))));

        entity.HasDeleteEditConflict.ShouldBeTrue();
    }
}

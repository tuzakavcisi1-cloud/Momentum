using Momentum.Domain.Sync;
using Momentum.SyncCore.Tests.TestUtil;
using Shouldly;
using Xunit;

namespace Momentum.SyncCore.Tests.UnitTests;

/// <summary>
/// D2a GUVENLIK AGI (GOREV slice-3a) — a DEDICATED new file (kabul kriteri 6(a): existing
/// <see cref="DeleteEditConflictTests"/> bodies must stay untouched, so this cannot be added there).
/// v2's claim that <c>DeleteEditConflictTests</c> + <c>SemanticRoundTripTests</c> already measure the D2a
/// refactor was BLIND: all three of those asserts are <c>ShouldBeTrue</c> with the literal value
/// <c>"true"</c>, so they stay green even if <c>deleteKey</c> were wired to <c>default(HlcKey)</c> (zero)
/// instead of <c>isDeleted</c>'s own winning key. This test proves the wiring is real: a competing write
/// stamped STRICTLY BELOW <c>isDeleted</c>'s key must NOT surface a conflict — if <c>deleteKey</c> were
/// zero, almost any positive-HLC write would incorrectly exceed it and flip this to <c>true</c>.
/// </summary>
public sealed class EntityStateDeleteKeyWiringTests
{
    [Fact]
    public void A_write_stamped_below_isdeleted_key_does_not_surface_a_conflict()
    {
        var entity = new EntityState();
        var client = Ids.Client(0);

        entity.ApplyField("isDeleted", new FieldWrite("true", new Hlc(10, 0, client)), Ids.Op(1));
        entity.ApplyField("title", new FieldWrite("x", new Hlc(5, 0, client)), Ids.Op(0));

        entity.HasDeleteEditConflict.ShouldBeFalse();
    }
}

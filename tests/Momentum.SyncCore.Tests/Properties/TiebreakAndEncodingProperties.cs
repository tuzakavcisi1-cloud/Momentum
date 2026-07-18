using CsCheck;
using Momentum.Domain.Sync;
using Momentum.SyncCore.Tests.TestUtil;
using Shouldly;
using Xunit;

namespace Momentum.SyncCore.Tests.Properties;

public sealed class TiebreakAndEncodingProperties
{
    /// <summary>
    /// P6 (ADR 0002 K2-H5): the tiebreaker chain. (a) equal (WallMs,Counter), different ClientId ->
    /// ClientId resolves; (b) equal (WallMs,Counter,ClientId), different OperationId -> OperationId
    /// resolves. Deterministic single winner, independent of application order.
    /// </summary>
    [Fact]
    public void P6_tiebreaker_chain_client_then_operation()
    {
        (from wall in Gen.Long[0, 5_000_000_000_000]
         from counter in Gen.UInt[0u, 1_000u]
         from c1 in Gen.Int[0, 30]
         from c2 in Gen.Int[0, 30]
         from o1 in Gen.Int[0, 30]
         from o2 in Gen.Int[0, 30]
         select (wall, counter, c1, c2, o1, o2))
            .Sample(
                t =>
                {
                    // (a) same operationId, HLC differs only in ClientId.
                    if (t.c1 != t.c2)
                    {
                        var opId = Ids.Op(1);
                        var a = new FieldWrite("v1", new Hlc(t.wall, t.counter, Ids.Client(t.c1)));
                        var b = new FieldWrite("v2", new Hlc(t.wall, t.counter, Ids.Client(t.c2)));
                        var forward = Winner(a, opId, b, opId);
                        var backward = Winner(b, opId, a, opId);
                        forward.ShouldBe(backward);
                        var expected = string.CompareOrdinal(Ids.Client(t.c1).ToString("N"), Ids.Client(t.c2).ToString("N")) > 0 ? "v1" : "v2";
                        forward.ShouldBe(expected);
                    }

                    // (b) identical HLC (wall,counter,clientId), OperationId differs.
                    if (t.o1 != t.o2)
                    {
                        var hlc = new Hlc(t.wall, t.counter, Ids.Client(t.c1));
                        var a = new FieldWrite("v1", hlc);
                        var b = new FieldWrite("v2", hlc);
                        var oa = Ids.Op(t.o1);
                        var ob = Ids.Op(t.o2);
                        var forward = Winner(a, oa, b, ob);
                        var backward = Winner(b, ob, a, oa);
                        forward.ShouldBe(backward);
                        var expected = string.CompareOrdinal(oa.ToString("N"), ob.ToString("N")) > 0 ? "v1" : "v2";
                        forward.ShouldBe(expected);
                    }
                },
                iter: PropertyConfig.Iter);
    }

    /// <summary>P9 (ADR 0002 K2-A1): CompareTo is isomorphic to Ordinal(Encode); Encode is lowercase, fixed-width.</summary>
    [Fact]
    public void P9_encoding_is_isomorphic_to_compareto()
    {
        GenKeyPair.Sample(
            pair =>
            {
                var (a, b) = pair;
                Math.Sign(a.CompareTo(b)).ShouldBe(Math.Sign(string.CompareOrdinal(a.Encode(), b.Encode())));

                var encoded = a.Encode();
                encoded.ShouldBe(encoded.ToLowerInvariant());
                encoded.Length.ShouldBe(13 + 1 + 8 + 1 + 32 + 1 + 32); // WallMs.Counter.ClientId.OperationId
            },
            iter: PropertyConfig.Iter);
    }

    private static string? Winner(FieldWrite first, Guid firstOp, FieldWrite second, Guid secondOp)
    {
        var register = new LwwRegister();
        register.Apply(first, firstOp);
        register.Apply(second, secondOp);
        return register.Value;
    }

    // WallMs in [0, 10^13); heavy equal-prefix bias to exercise the tiebreaker layers.
    private static readonly Gen<(HlcKey, HlcKey)> GenKeyPair =
        from wall in Gen.Long[0, 9_999_999_999_999]
        from counter in Gen.UInt
        from client in Gen.Int[0, 5]
        from op1 in Gen.Int[0, 5]
        from op2 in Gen.Int[0, 5]
        from sameWall in Gen.Bool
        from sameCounter in Gen.Bool
        from sameClient in Gen.Bool
        from wall2 in Gen.Long[0, 9_999_999_999_999]
        from counter2 in Gen.UInt
        from client2 in Gen.Int[0, 5]
        select (
            new HlcKey(new Hlc(wall, counter, Ids.Client(client)), Ids.Op(op1)),
            new HlcKey(
                new Hlc(sameWall ? wall : wall2, sameCounter ? counter : counter2, Ids.Client(sameClient ? client : client2)),
                Ids.Op(op2)));
}

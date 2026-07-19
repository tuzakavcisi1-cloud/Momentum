using CsCheck;
using Momentum.Domain.Sync;
using Momentum.SyncCore.Tests.TestUtil;
using Shouldly;
using Xunit;

namespace Momentum.SyncCore.Tests.Properties;

public sealed class ConvergenceAndMonotonicityProperties
{
    /// <summary>
    /// P1: the same op SET ingested in different orders converges to an identical observational state
    /// (fixed receive time; unique opIds; no compaction; adds/element bounded well under the cap).
    /// </summary>
    [Fact]
    public void P1_permutations_of_an_op_set_converge()
    {
        (from ops in Scenario.P1OpSet
         from seed in Gen.Int[1, int.MaxValue]
         select (ops, seed))
            .Sample(
                t =>
                {
                    var materialized = Scenario.MaterializeOps(t.ops, fixedReceive: true);
                    var baseline = DualRunner.ProductionProjection(materialized);

                    DualRunner.ProductionProjection(Reversed(materialized)).ShouldBe(baseline);
                    DualRunner.ProductionProjection(Shuffled(materialized, t.seed)).ShouldBe(baseline);
                },
                iter: PropertyConfig.Iter);
    }

    /// <summary>
    /// D0 (ADR 0002 ERRATA E-1, GOREV slice-2c — KIRMIZI ÖNCE). Pinned-seed regression for a genuine,
    /// deterministic P1 violation Cowork found independently verifying slice-2b2
    /// (<c>KANIT/slice-2b2/cowork-bagimsiz-dogrulama.txt</c> §6): <c>OrSetField.ApplyAdd</c>'s
    /// "first stamp wins" is idempotent but NOT commutative, so the DERIVED <c>HasDeleteEditConflict</c>
    /// (K2-C4) flag flips 1/0 depending on ingest order even though the stored OR-Set membership itself
    /// converges. Same generator composition as P1, replayed via CsCheck's explicit <c>seed</c> ARGUMENT
    /// (not the <c>CsCheck_Seed</c> env var — an explicit argument overrides it) so this exact case
    /// reproduces regardless of environment/random draw. Must be run once BEFORE the D1 fix to prove
    /// red; a green run without first proving red is not evidence (20 random runs saw 0 FAIL — GOREV D0).
    /// </summary>
    [Fact]
    public void P1_regression_seed_fcGWfMJW_dB2()
    {
        (from ops in Scenario.P1OpSet
         from seed in Gen.Int[1, int.MaxValue]
         select (ops, seed))
            .Sample(
                t =>
                {
                    var materialized = Scenario.MaterializeOps(t.ops, fixedReceive: true);
                    AssertDuplicateTagSurfaceExists(materialized);

                    var baseline = DualRunner.ProductionProjection(materialized);

                    DualRunner.ProductionProjection(Reversed(materialized)).ShouldBe(baseline);
                    DualRunner.ProductionProjection(Shuffled(materialized, t.seed)).ShouldBe(baseline);
                },
                seed: "fcGWfMJW_dB2",
                iter: 1);
    }

    /// <summary>
    /// v3's seed-drift guard (D0 precondition, KATMAN PİNİ): the pinned case only exercises the E-1 bug
    /// if the SAME (entityType, entityId, setName, element, tag) receives >= 2 DIFFERENT stamps —
    /// compared AFTER clamping (<see cref="HlcClamp.Clamp"/>), since the clamp CEILING is exactly where
    /// WallMs collisions are common and a pre-clamp check would pass while the post-clamp surface had
    /// already vanished (v2's bug). Necessary but not sufficient (the case must also land deleteKey
    /// between the two stamps) — a drift ALARM, not a re-pin of the case; D0b is the non-drifting gate.
    /// </summary>
    private static void AssertDuplicateTagSurfaceExists(IReadOnlyList<MatStep> materialized)
    {
        var seenClampedStamps = new Dictionary<(string EntityType, Guid EntityId, string SetName, string Element, Guid Tag), Hlc>();
        foreach (var step in materialized)
        {
            if (step is not MatIngest ingest)
            {
                continue;
            }

            foreach (var (setName, delta) in ingest.Op.Sets)
            {
                foreach (var add in delta.Adds)
                {
                    var clamped = HlcClamp.Clamp(add.Hlc, ingest.ReceiveWall);
                    var key = (ingest.Op.EntityType, ingest.Op.EntityId, setName, add.Element, add.Tag);
                    if (seenClampedStamps.TryGetValue(key, out var existing))
                    {
                        if (!existing.Equals(clamped))
                        {
                            return; // duplicate-tag surface found -- precondition satisfied
                        }
                    }
                    else
                    {
                        seenClampedStamps[key] = clamped;
                    }
                }
            }
        }

        Assert.Fail("seed drift: pinned case no longer exhibits the duplicate-tag surface");
    }

    /// <summary>P4: per-client Applied EffectiveOpHlc is strictly increasing (in ingest order).</summary>
    [Fact]
    public void P4_effective_op_hlc_strictly_increases_per_client()
    {
        Scenario.P3Scenario.Sample(
            steps =>
            {
                var run = DualRunner.RunProduction(Scenario.Materialize(steps, fixedReceive: false));
                var lastPerClient = new Dictionary<Guid, string>();

                foreach (var (op, result) in run.Ingests)
                {
                    if (result.Code != IngestResultCode.Applied)
                    {
                        continue;
                    }

                    var encoded = OracleMapper.EncodeEffective(result.EffectiveOpHlc);
                    if (lastPerClient.TryGetValue(op.ClientId, out var previous))
                    {
                        string.CompareOrdinal(encoded, previous).ShouldBeGreaterThan(0);
                    }

                    lastPerClient[op.ClientId] = encoded;
                }
            },
            iter: PropertyConfig.Iter);
    }

    private static List<MatStep> Reversed(List<MatStep> steps)
    {
        var copy = new List<MatStep>(steps);
        copy.Reverse();
        return copy;
    }

    private static List<MatStep> Shuffled(List<MatStep> steps, int seed)
    {
        var copy = new List<MatStep>(steps);
        var rng = new Random(seed);
        for (var i = copy.Count - 1; i > 0; i--)
        {
            var j = rng.Next(i + 1);
            (copy[i], copy[j]) = (copy[j], copy[i]);
        }

        return copy;
    }
}

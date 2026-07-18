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

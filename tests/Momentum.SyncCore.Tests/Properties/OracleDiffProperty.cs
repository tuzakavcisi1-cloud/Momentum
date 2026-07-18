using CsCheck;
using Momentum.SyncCore.Tests.TestUtil;
using Shouldly;
using Xunit;

namespace Momentum.SyncCore.Tests.Properties;

/// <summary>
/// P3 (ADR 0002 K2-H2, MOST CRITICAL): a random scenario (op sequence + free receive times + absurd
/// HLCs + compaction events + partial group writes + unseen-tag removes) resolved by the production
/// <c>SyncIngest</c> equals the independent oracle — both per-op results (incl. EffectiveOpHlc) and the
/// final observational projection.
/// </summary>
public sealed class OracleDiffProperty
{
    [Fact]
    public void P3_production_ingest_matches_independent_oracle()
    {
        Scenario.P3Scenario.Sample(
            steps =>
            {
                var materialized = Scenario.Materialize(steps, fixedReceive: false);
                var outcome = DualRunner.Run(materialized);

                outcome.ProductionResults.ShouldBe(outcome.OracleResults);
                outcome.ProductionProjection.ShouldBe(outcome.OracleProjection);
            },
            iter: PropertyConfig.Iter);
    }
}

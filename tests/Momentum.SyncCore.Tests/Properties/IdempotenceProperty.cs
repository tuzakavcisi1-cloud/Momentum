using CsCheck;
using Momentum.Domain.Sync;
using Momentum.SyncCore.Tests.TestUtil;
using Shouldly;
using Xunit;

namespace Momentum.SyncCore.Tests.Properties;

/// <summary>
/// P2 (ADR 0002 K2-H3): replaying an <c>Applied</c> op is a <c>Duplicate</c> no-op that returns the
/// original EffectiveOpHlc and never mutates state, even at a later receive time (dedup precedes the
/// receive-time-dependent steps).
/// </summary>
public sealed class IdempotenceProperty
{
    [Fact]
    public void P2_replaying_an_applied_op_is_a_duplicate_noop()
    {
        Scenario.P3Scenario.Sample(
            steps =>
            {
                var materialized = Scenario.Materialize(steps, fixedReceive: false);

                var state = new SyncState();
                var ingest = new SyncIngest(state, new ClientClockStore());
                (ChangeOperation Op, long Receive, IngestResult Result)? firstApplied = null;

                foreach (var step in materialized)
                {
                    switch (step)
                    {
                        case MatIngest ing:
                            var result = ingest.Ingest(ing.Op, ing.ReceiveWall);
                            if (firstApplied is null && result.Code == IngestResultCode.Applied)
                            {
                                firstApplied = (ing.Op, ing.ReceiveWall, result);
                            }

                            break;
                        case MatCompact compact:
                            ingest.Compact(compact.EntityType, compact.EntityId, compact.SetName, compact.Horizon);
                            break;
                    }
                }

                if (firstApplied is not { } applied)
                {
                    return; // no Applied op in this scenario
                }

                var before = ProdProjector.Project(state);

                var replay = ingest.Ingest(applied.Op, applied.Receive + 987_654); // different receive time
                replay.Code.ShouldBe(IngestResultCode.Duplicate);
                OracleMapper.EncodeEffective(replay.EffectiveOpHlc)
                    .ShouldBe(OracleMapper.EncodeEffective(applied.Result.EffectiveOpHlc));
                ProdProjector.Project(state).ShouldBe(before);

                var replayAgain = ingest.Ingest(applied.Op, applied.Receive);
                replayAgain.Code.ShouldBe(IngestResultCode.Duplicate);
                ProdProjector.Project(state).ShouldBe(before);
            },
            iter: PropertyConfig.Iter);
    }
}

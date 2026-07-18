using Momentum.Domain.Sync;
using Momentum.SyncCore.Tests.Oracle;

namespace Momentum.SyncCore.Tests.TestUtil;

/// <summary>
/// Runs a materialized scenario through BOTH the production <see cref="SyncIngest"/> and the isolated
/// <see cref="OracleEngine"/>, capturing per-op result strings and the final projection of each.
/// </summary>
public static class DualRunner
{
    public sealed record Outcome(
        IReadOnlyList<string> ProductionResults,
        IReadOnlyList<string> OracleResults,
        string ProductionProjection,
        string OracleProjection);

    public static Outcome Run(IReadOnlyList<MatStep> steps)
    {
        var state = new SyncState();
        var ingest = new SyncIngest(state, new ClientClockStore());
        var oracle = new OracleEngine();

        var productionResults = new List<string>();
        var oracleResults = new List<string>();

        foreach (var step in steps)
        {
            switch (step)
            {
                case MatIngest ingestStep:
                    var prod = ingest.Ingest(ingestStep.Op, ingestStep.ReceiveWall);
                    productionResults.Add($"{prod.Code}|{OracleMapper.EncodeEffective(prod.EffectiveOpHlc)}");

                    var oracleResult = oracle.Ingest(OracleMapper.Map(ingestStep.Op), ingestStep.ReceiveWall);
                    oracleResults.Add($"{oracleResult.Code}|{OracleMapper.EncodeEffective(oracleResult.EffectiveOpHlc)}");
                    break;

                case MatCompact compactStep:
                    ingest.Compact(compactStep.EntityType, compactStep.EntityId, compactStep.SetName, compactStep.Horizon);
                    oracle.Compact(compactStep.EntityType, compactStep.EntityId, compactStep.SetName, OracleMapper.Map(compactStep.Horizon));
                    break;
            }
        }

        return new Outcome(productionResults, oracleResults, ProdProjector.Project(state), oracle.Project());
    }

    public sealed record ProductionRun(IReadOnlyList<(ChangeOperation Op, IngestResult Result)> Ingests, SyncState State);

    /// <summary>Runs only the production engine, returning per-op results and the final state.</summary>
    public static ProductionRun RunProduction(IReadOnlyList<MatStep> steps)
    {
        var state = new SyncState();
        var ingest = new SyncIngest(state, new ClientClockStore());
        var ingests = new List<(ChangeOperation, IngestResult)>();

        foreach (var step in steps)
        {
            switch (step)
            {
                case MatIngest ingestStep:
                    ingests.Add((ingestStep.Op, ingest.Ingest(ingestStep.Op, ingestStep.ReceiveWall)));
                    break;
                case MatCompact compactStep:
                    ingest.Compact(compactStep.EntityType, compactStep.EntityId, compactStep.SetName, compactStep.Horizon);
                    break;
            }
        }

        return new ProductionRun(ingests, state);
    }

    public static string ProductionProjection(IReadOnlyList<MatStep> steps) =>
        ProdProjector.Project(RunProduction(steps).State);
}

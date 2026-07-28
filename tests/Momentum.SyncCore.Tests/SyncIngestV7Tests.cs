using Momentum.Domain.Sync;
using Momentum.SyncCore.Tests.TestUtil;
using Shouldly;
using Xunit;

namespace Momentum.SyncCore.Tests;

/// <summary>
/// GOREV-slice-3d G7/D8 -- saf, DB'siz. `SyncIngest.IsEnvelopeValid`'in opId v7 zorlamasini ölçer.
/// `Momentum.SyncCore.Tests` bu ölçümün dogru evi: `SyncIngest`'i zaten DB'siz, saf sekilde kosturan
/// tek proje budur (spec'in andigi `Momentum.Domain.Tests` bu repoda mevcut degil -- ölçülmüs karar).
/// </summary>
public sealed class SyncIngestV7Tests
{
    private static ChangeOperation TitleOp(Guid operationId, int clientIdx = 0, int entityIdx = 0) =>
        Build.Op(0, clientIdx, entityIdx, "Task", new Hlc(Scenario.BaseWall, 0, Ids.Client(clientIdx)),
                fields: Build.Fields(("title", "v7 testi", new Hlc(Scenario.BaseWall, 0, Ids.Client(clientIdx)))))
            with
        { OperationId = operationId };

    [Fact]
    public void OperationId_gercek_v7_Applied_doner()
    {
        var ingest = new SyncIngest(new SyncState(), new ClientClockStore());
        var result = ingest.Ingest(TitleOp(Guid.CreateVersion7()), Scenario.BaseWall);
        result.Code.ShouldBe(IngestResultCode.Applied);
    }

    [Fact]
    public void OperationId_gercek_v4_RejectedInvalid_doner()
    {
        var ingest = new SyncIngest(new SyncState(), new ClientClockStore());
        var result = ingest.Ingest(TitleOp(Guid.NewGuid()), Scenario.BaseWall);
        result.Code.ShouldBe(IngestResultCode.RejectedInvalid);
    }

    [Fact]
    public void Uc_oplu_istek_v7_v4_v7_hepsi_islenir_istek_400_DEGIL()
    {
        var ingest = new SyncIngest(new SyncState(), new ClientClockStore());
        var r1 = ingest.Ingest(TitleOp(Guid.CreateVersion7(), entityIdx: 0), Scenario.BaseWall);
        var r2 = ingest.Ingest(TitleOp(Guid.NewGuid(), entityIdx: 1), Scenario.BaseWall);
        var r3 = ingest.Ingest(TitleOp(Guid.CreateVersion7(), entityIdx: 2), Scenario.BaseWall);

        r1.Code.ShouldBe(IngestResultCode.Applied);
        r2.Code.ShouldBe(IngestResultCode.RejectedInvalid);
        r3.Code.ShouldBe(IngestResultCode.Applied);
    }

    [Fact]
    public void V4_op_ikinci_kez_gonderilir_yine_RejectedInvalid_dedupa_kaydedilmez()
    {
        var ingest = new SyncIngest(new SyncState(), new ClientClockStore());
        var v4OpId = Guid.NewGuid();

        var ilk = ingest.Ingest(TitleOp(v4OpId), Scenario.BaseWall);
        var ikinci = ingest.Ingest(TitleOp(v4OpId), Scenario.BaseWall);

        ilk.Code.ShouldBe(IngestResultCode.RejectedInvalid);
        ikinci.Code.ShouldBe(IngestResultCode.RejectedInvalid, "ERRATA: RejectedInvalid dedup'a kaydedilmez -- Duplicate DONMEMELI");
    }
}

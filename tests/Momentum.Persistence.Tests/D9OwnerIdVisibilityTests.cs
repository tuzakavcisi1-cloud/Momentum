using Momentum.Application.Abstractions.Sync;
using Momentum.Application.Features.Sync;
using Shouldly;
using Xunit;

namespace Momentum.Persistence.Tests;

/// <summary>
/// GOREV-slice-3d G7/D9 -- `owner_id` KUSURU düzeltmesinin çekme GÖRÜNÜRLÜĞÜ üzerindeki etkisi
/// (gerçek PostgreSQL, Testcontainers). `ScopeAndDriftAnchorTests.D9_...` SQL sütunlarını doğrudan
/// ölçer; bu dosya AYNI senaryoyu `SyncPuller`in `owner_id` süzgeci ÜZERİNDEN, uçtan uca ölçer.
/// </summary>
[Collection(PostgresCollection.Name)]
public sealed class D9OwnerIdVisibilityTests(PostgresFixture fixture)
{
    [Fact]
    public async Task D9_baslik_X_govde_actorId_Y_ise_satir_Xin_cekmesinde_gorunur_Yninkinde_gorunmez()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actorX = Guid.NewGuid();
        var actorY = Guid.NewGuid();
        var entity = Guid.NewGuid();
        var opId = Guid.CreateVersion7();

        // Baslik (kimlik dogrulama) X'tir; govdenin actorId'si Y'dir (enjeksiyon senaryosu).
        await app.SyncAsync(actorX, Wire.PushNoPull(actorX, Wire.TaskField(opId, actorX, entity, actorY, "title", "D9 gorunurluk testi")));

        var xSnapshot = await app.SnapshotAsync(actorX);
        xSnapshot.Entities.ShouldContain(e => e.EntityId == entity, "D9: outbox owner_id KIMLIK DOGRULANMIS X'tir -- X'in cekmesinde GORUNMELI");

        var ySnapshot = await app.SnapshotAsync(actorY);
        ySnapshot.Entities.ShouldNotContain(e => e.EntityId == entity, "D9: govdenin actorId iddiasi (Y) outbox owner_id'yi BELIRLEMEMELI -- Y'nin cekmesinde GORUNMEMELI");
    }

    /// <summary>
    /// IS-EMRI-o83 F5 KILIDI: D9'un onceki beyanini SUPERSEDE eder. Eskiden ("D9 BEYAN") actor_id
    /// (denetim kaydi) BILEREK govdeden geliyordu; artik GERCEK kullanicilar var ve govdenin actorId
    /// iddiasini denetim kaydinda bile serbest birakmak bir kullaniciya baskasinin degisikligini
    /// YUKLEYEBILMEK demek (dilim 3 isbirliginde sahtekarlik riski) -- bu yuzden actor_id de artik
    /// KIMLIK DOGRULANMIS aktorden yazilir, govdenin (Y) iddiasi YOK SAYILIR.
    /// </summary>
    [Fact]
    public async Task D9_outbox_owner_id_VE_actor_id_ikisi_de_artik_dogrulanan_aktorden_yazilir()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actorX = Guid.NewGuid();
        var actorY = Guid.NewGuid();
        var entity = Guid.NewGuid();
        var opId = Guid.CreateVersion7();

        // Baslik (kimlik dogrulama) X'tir; govdenin actorId'si Y'dir (enjeksiyon senaryosu, degismedi).
        await app.SyncAsync(actorX, Wire.PushNoPull(actorX, Wire.TaskField(opId, actorX, entity, actorY, "title", "F5 SQL dogrulamasi")));

        var ownerId = await Db.ScalarAsync<Guid>(connectionString, "SELECT owner_id FROM outbox_messages WHERE operation_id = @op", ("op", opId));
        var actorId = await Db.ScalarAsync<Guid>(connectionString, "SELECT actor_id FROM outbox_messages WHERE operation_id = @op", ("op", opId));

        // GOREV-slice-3d 8.2 deseni korunur: bu sorgu Testcontainers icinde kosar, PowerShell o
        // baglantiyi GOREMEZ -- KANITI ayagin KENDISI yazar. Ortam degiskeni yoksa SESSIZCE atlamak
        // YASAK, test firlatir.
        var kanitDizini = Environment.GetEnvironmentVariable("MOMENTUM_KANIT_DIZIN")
            ?? throw new InvalidOperationException("MOMENTUM_KANIT_DIZIN ortam degiskeni ayarli degil -- KANIT sessizce atlanamaz.");
        Directory.CreateDirectory(kanitDizini);
        await File.WriteAllTextAsync(Path.Combine(kanitDizini, "outbox-sorgu.txt"),
            $"SELECT owner_id, actor_id FROM outbox_messages WHERE operation_id = @op (op={opId})\n" +
            $"actorX (kimlik dogrulama basligi) = {actorX}\n" +
            $"actorY (govdenin actorId iddiasi, ARTIK EZILIYOR) = {actorY}\n" +
            $"owner_id  = {ownerId}  (beklenen: actorX)\n" +
            $"actor_id  = {actorId}  (beklenen: actorX -- o83 F5, D9'u supersede eder)\n");

        ownerId.ShouldBe(actorX, "owner_id KIMLIK DOGRULAMADAN gelir");
        actorId.ShouldBe(actorX, "IS-EMRI-o83 F5: actor_id de artik KIMLIK DOGRULANMIS aktorden yazilir -- govdenin (Y) iddiasi yok sayilir");
    }

    /// <summary>
    /// IS-EMRI-o83 F5 -- ikinci yari: bayt-duzeyinde OutboxRecord.ActorId (DB sutunu) duzeltilse bile,
    /// WireMapping.ClampedPayload govdenin actorId'sini AYRICA yankiliyor olabilirdi -- bu payload,
    /// BASKA istemcilerin pull ile GERCEKTEN okudugu JSON'un ta kendisidir (WireChange.Payload). Bu
    /// test DB sutununu DEGIL, tam da o yankilanan payload'in icindeki actorId alanini olcer.
    /// </summary>
    [Fact]
    public async Task F5_pull_payloadindaki_WireOp_ActorId_de_authenticated_aktorden_gelir_govdeden_DEGIL()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actorX = Guid.NewGuid();
        var actorY = Guid.NewGuid();
        var entity = Guid.NewGuid();
        var opId = Guid.CreateVersion7();

        // Bos taban imlec (entity henuz yok), sonra AYNI istekte push+pull -- X kendi yazdigi
        // degisikligi "changes" olarak geri okur (SyncCommandHandler: push ONCE, pull SONRA, ayni istek).
        var taban = await app.SnapshotAsync(actorX);
        var yanit = await app.SyncAsync(actorX, new SyncRequest(actorX, null,
            new WireCursor(taban.NextCursor.Xid, taban.NextCursor.Seq),
            [Wire.TaskField(opId, actorX, entity, actorY, "title", "F5 payload testi")]));

        var degisiklik = yanit.Changes.ShouldHaveSingleItem();
        degisiklik.Payload.GetProperty("actorId").GetGuid()
            .ShouldBe(actorX, "IS-EMRI-o83 F5: pull payload'indaki WireOp.ActorId de kimlik dogrulanmis aktorden gelir, govdenin (Y) iddiasi DEGIL");
    }
}

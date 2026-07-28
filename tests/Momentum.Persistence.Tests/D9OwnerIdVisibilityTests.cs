using Momentum.Application.Abstractions.Sync;
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

    [Fact]
    public async Task D9_outbox_owner_id_X_actor_id_Y_kalir()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actorX = Guid.NewGuid();
        var actorY = Guid.NewGuid();
        var entity = Guid.NewGuid();
        var opId = Guid.CreateVersion7();

        await app.SyncAsync(actorX, Wire.PushNoPull(actorX, Wire.TaskField(opId, actorX, entity, actorY, "title", "D9 SQL dogrulamasi")));

        var ownerId = await Db.ScalarAsync<Guid>(connectionString, "SELECT owner_id FROM outbox_messages WHERE operation_id = @op", ("op", opId));
        var actorId = await Db.ScalarAsync<Guid>(connectionString, "SELECT actor_id FROM outbox_messages WHERE operation_id = @op", ("op", opId));

        // GOREV-slice-3d 8.2: bu sorgu Testcontainers icinde kosar, PowerShell o baglantiyi GOREMEZ --
        // KANITI ayagin KENDISI yazar. Ortam degiskeni yoksa SESSIZCE atlamak YASAK, test firlatir.
        var kanitDizini = Environment.GetEnvironmentVariable("MOMENTUM_KANIT_DIZIN")
            ?? throw new InvalidOperationException("MOMENTUM_KANIT_DIZIN ortam degiskeni ayarli degil -- KANIT sessizce atlanamaz.");
        Directory.CreateDirectory(kanitDizini);
        await File.WriteAllTextAsync(Path.Combine(kanitDizini, "outbox-sorgu.txt"),
            $"SELECT owner_id, actor_id FROM outbox_messages WHERE operation_id = @op (op={opId})\n" +
            $"actorX (kimlik dogrulama basligi) = {actorX}\n" +
            $"actorY (govdenin actorId iddiasi) = {actorY}\n" +
            $"owner_id  = {ownerId}  (beklenen: actorX)\n" +
            $"actor_id  = {actorId}  (beklenen: actorY -- D9 BEYAN, degismez)\n");

        ownerId.ShouldBe(actorX, "owner_id KIMLIK DOGRULAMADAN gelir");
        actorId.ShouldBe(actorY, "actor_id (denetim kaydi) govdeden gelmeye DEVAM eder -- D9 BEYAN, ikisi bilerek ayri");
    }
}

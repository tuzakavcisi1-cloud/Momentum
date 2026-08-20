using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Momentum.Application.Abstractions;
using Momentum.Application.Features.Sync;
using Shouldly;
using Xunit;

namespace Momentum.Persistence.Tests;

/// <summary>D6 (artik MUTANT-GATED, IS-EMRI-o85B2 §B) + D7/D8 (GOREV slice-3a, MUTANTSIZ) -- regression safeguards / drift documentation.</summary>
[Collection(PostgresCollection.Name)]
public sealed class ScopeAndDriftAnchorTests(PostgresFixture fixture)
{
    /// <summary>
    /// D6 [kapsam cipasi]: `Tag` kapsam disidir -- uc eski materyalize tabloda sifir satir. `Project`
    /// IS-EMRI-o85-B ile kapsama GIRDI: `projects` tablosuna tam bir satir yazar (pozitif kontrol).
    /// IS-EMRI-o85B2 B1 olcumu: "D6_out_of_scope" dizgesi .github//araclar//verify.ps1'de GECMIYOR ⇒
    /// ad da duzeltildi (asagida).
    /// </summary>
    [Fact]
    public async Task D6_Tag_kapsam_disi_sifir_satir_Project_ise_materyalize_edilir()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actor = Guid.NewGuid();
        var projectEntity = Guid.NewGuid();
        var tagEntity = Guid.NewGuid();

        await app.SyncAsync(actor, Wire.PushNoPull(actor, Wire.Op(Guid.CreateVersion7(), actor, projectEntity, actor, 1,
            fields: new Dictionary<string, WireFieldWrite>(StringComparer.Ordinal) { ["name"] = new("P", Wire.Hlc(actor, 1)) },
            entityType: "Project")));
        await app.SyncAsync(actor, Wire.PushNoPull(actor, Wire.Op(Guid.CreateVersion7(), actor, tagEntity, actor, 1,
            fields: new Dictionary<string, WireFieldWrite>(StringComparer.Ordinal) { ["label"] = new("T", Wire.Hlc(actor, 1)) },
            entityType: "Tag")));

        // Tag: hala kapsam disi -- uc eski tabloda sifir satir.
        (await Db.ScalarAsync<long>(connectionString, "SELECT count(*) FROM tasks")).ShouldBe(0L);
        (await Db.ScalarAsync<long>(connectionString, "SELECT count(*) FROM task_lists")).ShouldBe(0L);
        (await Db.ScalarAsync<long>(connectionString, "SELECT count(*) FROM task_tags")).ShouldBe(0L);

        // Project: ARTIK kapsam ici -- POZITIF KONTROL (IS-EMRI-o85B2 B3, ayni testte).
        (await Db.ScalarAsync<long>(connectionString, "SELECT count(*) FROM projects WHERE entity_id = @e", ("e", projectEntity))).ShouldBe(1L);
        // Tag op'u projects'e satir DOGURMADI ("gorunmemeli" iddiasi da olculur).
        (await Db.ScalarAsync<long>(connectionString, "SELECT count(*) FROM projects")).ShouldBe(1L);
    }

    /// <summary>
    /// D7 [mutantsiz -- surukleme cipasi, BULGU-C -- slice-3d D9 ile DUZELTILDI, IS-EMRI-o83 F5 ile
    /// GENISLETILDI]: F5 daha once yalniz materialize edilen yolu temizlemisti; outbox/SyncPuller yolu
    /// HALA govdedeki actorId'ye guveniyordu. slice-3d D9 `BuildOutbox`i `authenticatedActorId` almaya
    /// zorlayarak `owner_id`yi kapatti ama `actor_id` (denetim kaydi) BILEREK govdeden gelmeye devam
    /// ediyordu ("D9 BEYAN"). IS-EMRI-o83 F5 bu beyani SUPERSEDE eder: artik gercek kullanicilar var,
    /// govdenin actorId iddiasini denetim kaydinda bile serbest birakmak bir kullaniciya baskasinin
    /// degisikligini YUKLEYEBILMEK demek. A olusturur; A daha sonraki bir op'u KIMLIK DOGRULAR ama
    /// govdenin actorId'si B'dir (enjeksiyon) -- artik hem materialize edilen sahip HEM outbox
    /// satirinin sahibi HEM `actor_id` A'dir (govdenin B iddiasi HER YERDE yok sayilir).
    /// </summary>
    [Fact]
    public async Task D9_F5_outbox_owner_VE_actor_ikisi_de_authenticated_actorden_gelir_not_wire_actor()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        await using var app = new SyncTestApp(connectionString);
        var actorA = Guid.NewGuid();
        var actorB = Guid.NewGuid();
        var entity = Guid.NewGuid();

        await app.SyncAsync(actorA, Wire.PushNoPull(actorA,
            Wire.TaskField(Guid.CreateVersion7(), actorA, entity, actorA, "title", "created-by-A", counter: 1)));
        await app.SyncAsync(actorA, Wire.PushNoPull(actorA,
            Wire.TaskField(Guid.CreateVersion7(), actorA, entity, actorB, "notes", "edited", counter: 2)));

        (await Db.ScalarAsync<Guid>(connectionString, "SELECT owner_id FROM tasks WHERE entity_id = @e", ("e", entity))).ShouldBe(actorA);
        (await Db.ScalarAsync<Guid>(connectionString,
            "SELECT owner_id FROM outbox_messages WHERE aggregate_id = @e ORDER BY id DESC LIMIT 1", ("e", entity)))
            .ShouldBe(actorA, "D9: owner_id KIMLIK DOGRULAMADAN gelir, ASLA govdenin actorId'sinden");
        (await Db.ScalarAsync<Guid>(connectionString,
            "SELECT actor_id FROM outbox_messages WHERE aggregate_id = @e ORDER BY id DESC LIMIT 1", ("e", entity)))
            .ShouldBe(actorA, "IS-EMRI-o83 F5: actor_id ARTIK kimlik dogrulanmis aktorden gelir -- D9 BEYAN supersede edildi");
    }

    /// <summary>
    /// D8 [mutantsiz -- tanim geregi totolojik]: a directly-seeded sync_scalar_meta row (NO op sent, the
    /// materializer never ran) never appears via the read API -- it only ever reads the "tasks" table.
    /// Does NOT replace kriter 9 (build-time measurement of pre-existing rows) -- different proposition.
    /// </summary>
    [Fact]
    public async Task D8_directly_seeded_scalar_meta_row_is_not_returned_by_the_read_api()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        var actor = Guid.NewGuid();
        var entity = Guid.NewGuid();

        await Db.ExecuteAsync(connectionString,
            "INSERT INTO sync_scalar_meta (entity_type, entity_id, field, value, hlc, win_operation_id) VALUES ('Task', @e, 'title', 'seeded', @hlc, @op)",
            ("e", entity), ("hlc", Wire.EncodeHlc(actor, 1)), ("op", Guid.CreateVersion7()));

        (await Db.ScalarAsync<long>(connectionString, "SELECT count(*) FROM tasks WHERE entity_id = @e", ("e", entity))).ShouldBe(0L);

        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder => builder
            .UseSetting("ConnectionStrings:Momentum", connectionString)
            .ConfigureTestServices(services => services.AddScoped<ICurrentUser>(_ => new FakeCurrentUser(actor))));
        var client = factory.CreateClient();

        var page = await client.GetFromJsonAsync<JsonElement>("/v1/tasks");
        page.GetProperty("items").EnumerateArray().Any(item => item.GetProperty("entityId").GetGuid() == entity).ShouldBeFalse();
    }
}

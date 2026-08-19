# IS-EMRI-o85-B -- CEVAP (bes satir, s7)

## 1. `FieldStrategyRegistryCoverageTests`'in `Project`i ele alisi (olcum) + sonraki durum

**Once (`01-registry-kapsam-olcumu.txt`, kod yazilmadan ONCE alindi):** 3/3 yesil. Dosyada `"Project"`
sozcugu HIC GECMIYOR -- ne muaf-liste var ne `DescribeFieldKeys("Project")`i bir projeksiyona karsi
sinayan bir test. Genel canlilik testi (`DescribeFieldKeys_derives_live_from_the_entities_field_...`)
`_entities`teki HER kayitli tipi (Project dahil, zaten registry'de) donuyor ama yalniz
`DescribeFieldKeys`in kendi ic-tutarliligini sinar -- projeksiyon KAPSAMINI degil. Iki "uc kova"
testi (bucket-coverage) yalniz `"Task"` ve `"TaskList"` icin var, `Project` icin YOK.
**Sonra (`ProjectProjection` eklendikten sonra, yeniden kosuldu):** yine 3/3 yesil, **DEGISMEDI** --
bu dosyada `Project`e ozel hicbir assert olmadigi icin `ProjectProjection`in varligi bu kapiyi
KIRMIZIYA DUSURMEDI (is emrinin ongordugu iki ihtimalden biri: "muaf" -- kapsam disi, hata degil).

## 2. `projects` tablosunun son sutun listesi + indeks adi

Sutunlar (`AddProjects` migration'i, `02-migration.txt`): `entity_id` (uuid, PK) · `owner_id` (uuid) ·
`name` (text, null olabilir) · `color` (text, null olabilir) · `is_deleted` (boolean, varsayilan
false) · `pos` (text, null olabilir, `COLLATE "C"`) · `has_delete_edit_conflict` (boolean, varsayilan
false) · `malformed_fields` (text[], varsayilan `'{}'`).
Indeks: **`ix_projects_owner_deleted_pos_entity`** = `(owner_id, is_deleted, pos, entity_id)`.

## 3. `ProjectProjection`in `Pos` okuma satiri (birebir) + `members` gerekcesi (tek cumle)

```csharp
var pos = ProjectionFields.ReadText(state.Orders, "pos");
```

`members` gerekcesi (kodda, `ProjectProjection.cs`): *"paylasim DILIM 3'un isi; `task_tags`in muadili
`project_members` O DILIMDE acilir -- bugun acmak, ekrani ve akisi olmayan bir tablo dogurur."*

## 4. `verify.ps1` EXIT + test sayisi (oncesi/sonrasi) + `GET /v1/projects` 401/400/200

`verify.ps1` **EXIT 0** (`05-verify-ps1.txt`: build 0 uyari/0 hata, 4 test projesi toplami **144**
yesil/0 kirmizi, CVE gate temiz). Test sayisi **oncesi 142 -> sonrasi 144** (net +2: D2+D3 birlesik
materyalizasyon testi + D4 okuma-ucu testi; `git diff` net +2 `[Fact]` ile dogrulandi).
`GET /v1/projects` canli olculdu (docker compose, gercek Postgres, `04-canli-tur-regresyon.txt`
sonrasi ayni oturumda): auth basliksiz **401** · `limit=0` **400** ProblemDetails
(`"limit must be between 1 and 200."`) · bozuk cursor **400** ProblemDetails (ASLA 500,
`"cursor is malformed or has an unrecognized version."`) · gecerli istekte **200** +
`{"items":[{"entityId":"...","name":"İş","color":null,"isDeleted":false,"pos":null,...}],"nextCursor":null}`
(canli turda A'nin yarattigi 'İş' listesi, dogru materyalize edilmis).

## 5. `git --no-optional-locks status --porcelain -- src tests` (ham cikti)

```
 M src/backend/Momentum.Api/Program.cs
 M src/backend/Momentum.Application/Abstractions/Sync/ITaskReadStore.cs
 M src/backend/Momentum.Infrastructure/Persistence/Configurations/SyncConfigurations.cs
 M src/backend/Momentum.Infrastructure/Persistence/Migrations/SyncDbContextModelSnapshot.cs
 M src/backend/Momentum.Infrastructure/Persistence/SyncDbContext.cs
 M src/backend/Momentum.Infrastructure/Persistence/SyncEntities.cs
 M src/backend/Momentum.Infrastructure/Sync/EntityMaterializer.cs
 M src/backend/Momentum.Infrastructure/Sync/TaskReadStore.cs
 M tests/Momentum.Persistence.Tests/MaterializationRoundTripTests.cs
 M tests/Momentum.Persistence.Tests/SchemaTests.cs
 M tests/Momentum.Persistence.Tests/TaskMaterializationD0Tests.cs
?? src/backend/Momentum.Api/Endpoints/ProjectEndpoints.cs
?? src/backend/Momentum.Application/Features/Tasks/GetProjectsQuery.cs
?? src/backend/Momentum.Application/Features/Tasks/GetProjectsQueryHandler.cs
?? src/backend/Momentum.Domain/Sync/Projection/ProjectProjection.cs
?? src/backend/Momentum.Infrastructure/Persistence/Migrations/20260819212451_AddProjects.Designer.cs
?? src/backend/Momentum.Infrastructure/Persistence/Migrations/20260819212451_AddProjects.cs
```

**`src/client/**` GORUNMUYOR** (istemci degismedi). `SyncDbContextModelSnapshot.cs` `dotnet ef
migrations add` tarafindan OTOMATIK yeniden uretildi (elle DOKUNULMADI); mevcut dort migration
dosyasi (`InitialSync`/`DispatcherIndexes`/`MaterializeTasksAndTaskLists`/`AddUsersAndRefreshTokens`)
**BIREBIR DEGISMEDI** (ayrica dogrulandi, `git diff --stat` bos). `FieldStrategyRegistry.cs`
**degismedi** (ayrica dogrulandi, `git status --porcelain` bos).

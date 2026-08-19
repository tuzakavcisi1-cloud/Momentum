# İŞ EMRİ o85-B — DİLİM 2 / SUNUCU AYAĞI: `Project` materyalizasyonu + `GET /v1/projects`

`MOD: NORMAL` · kutu **20-21 Ağu 2026** · yazan: Cowork · koşacak: **Claude Code**
Öncül: `e9bcb91` — DİLİM 2 ürün ve kapı olarak **BİTTİ** (üç kapı yeşil). Bu emir **vitrin/mimari
bütünlük** işidir: ürünü bloke etmez, ürün davranışını **değiştirmez**.

---

## 0. DEMİR KURALLAR

1. 🔴 **ADR/spec YAZILMAZ** (İŞLEYİŞ md.4). Tasarım bu emirdedir.
2. 🔴 **`FieldStrategyRegistry`ye DOKUNULMAZ.** `Project` zaten kayıtlı: scalars `name`/`color`/
   `isDeleted` · OrSet `members` · fractional `pos`. Alan eklemek ADR 0002 K2-B2 kilidini açmaktır.
3. 🔴 **İSTEMCİ DEĞİŞMEZ.** Ölçüldü: istemci yalnız `/v1/auth/*` ve `/v1/sync` çağırıyor;
   `GET /v1/projects` **ürün akışında kullanılmaz** — API paritesi/vitrin içindir. İstemciyi bu uca
   bağlama dürtüsü olursa **DUR ve bildir**.
4. 🔴 **Senkron yolu davranışı DEĞİŞMEZ.** `Project` op'ları bugün zaten uçtan uca akıyor
   (`KANIT/o85A`). Materyalizasyon **eklenir**, ingest/pull/hydration **dokunulmaz**.
5. 🔴 **`members` OrSet BU DİLİMDE MATERYALİZE EDİLMEZ** — paylaşım DİLİM 3'ün işi (§3).
6. **Yeni kapı DOSYASI açılmaz** (DURUM sınır 3). Testler mevcut `Momentum.Persistence.Tests` /
   `Momentum.Api.Tests` dosyalarına girer.
7. `verify.ps1` · `DURUM.md` · `CLAUDE.md` · `arsiv/` · `.github/workflows/*` · `src/client/**`:
   **dokunma**. **PUSH ONUR'DA.**

---

## 1. NEREDEYİZ (Cowork ölçtü, 19-20 Ağu — kaynak dosyalardan)

- `EntityMaterializer.MaterializeAsync`: `case "Task"` ve `case "TaskList"` var; **`default: break`**
  — yorumda *"D6 anchor: Project/Tag/unrecognized entityType — silent no-op, zero new rows"*.
- `projects` tablosu **YOK** · `ProjectProjection` **YOK** · `GET /v1/projects` **YOK**.
- Şablon **birebir hazır**: `TaskListProjection` · `task_lists` migration'ı ·
  `TaskListRowConfiguration` · `TaskReadStore.ListTaskListsAsync` · `GetTaskListsQuery(+Handler)` ·
  `TaskListEndpoints` · `Program.cs:253` kaydı.
- `Momentum.SyncCore.Tests/UnitTests/FieldStrategyRegistryCoverageTests.cs` **registry ↔ projeksiyon
  kapsam kapısıdır** ve `Project`i bugün nasıl ele aldığı **ÖLÇÜLMEDİ** — §5'in ilk işi budur.

---

## 2. §A — şema: `projects` tablosu (SALT-EKLEME migration)

**A1.** `ProjectRow` entity (`Persistence/SyncEntities.cs`, `TaskListRow`ın hemen altına):
`EntityId` · `OwnerId` · `Name` · `Color` · `IsDeleted` · `Pos` · `HasDeleteEditConflict` ·
`MalformedFields`.

**A2.** `ProjectRowConfiguration` (`Configurations/SyncConfigurations.cs`, `TaskListRowConfiguration`
deseninin aynısı): `ToTable("projects")`, snake_case sütun adları, `pos` **`collation: "C"`**,
`malformed_fields` `text[]` `DEFAULT '{}'`, indeks
`ix_projects_owner_deleted_pos_entity` = `(owner_id, is_deleted, pos, entity_id)`.
`SyncDbContext`e `DbSet<ProjectRow> Projects`.

**A3.** Migration adı **`AddProjects`**. Yalnız `CreateTable` + `CreateIndex`; `Down` tabloyu
düşürür. **Mevcut migration'lara DOKUNULMAZ.**

🔴 **`color` ve `pos` sütunları AÇILIR** — istemci bugün ikisini de yazmıyor ama sunucu tarafında
materyalize satır **registry'nin izdüşümüdür**: `tasks` da `remind_at`/`recurrence_rule`/`board_pos`
sütunlarını hiçbir istemci yazmadan taşıyor. ("Ölü sütun yazılmaz" doktrini **istemci** şeması
içindir; sunucuda emsal terstir.)

## 3. §B — `ProjectProjection` (Domain, saf, IO'suz)

`Momentum.Domain/Sync/Projection/ProjectProjection.cs`, `TaskListProjection`ın birebir deseni:

```
ProjectProjection(Guid EntityId, string? Name, string? Color, bool IsDeleted, string? Pos,
                  bool HasDeleteEditConflict, IReadOnlyList<string> MalformedFields)
```

- `Name`/`Color` → `ProjectionFields.ReadText(state.Fields, …)`
- 🔴 **`Pos` → `ProjectionFields.ReadText(state.Orders, "pos")`** — fractional **YALNIZ**
  `state.Orders`ta yaşar. `state.Fields`ten okumak (savunma amaçlı `TryGetValue` ile bile)
  **sonsuza dek sessizce NULL** döndürür (`TaskListProjection`daki "CHANNEL WARNING (mutant-16)"
  yorumunun aynısı — o yorum buraya da yazılır).
- `Project`in int/date/Guid scalar'ı **yok** ⇒ `MalformedFields` **daima boş**; gerekçe yorumda.
- 🔴 **`members` (OrSet) OKUNMAZ.** Beyan edilmiş sınır, yorumda tek cümle: *"paylaşım DİLİM 3;
  `task_tags`ın muadili `project_members` O DİLİMDE açılır — bugün açmak, ekranı ve akışı olmayan
  bir tablo doğurur."* Veri kaybı yok: `members` yazımları `sync_orset_tags`e zaten düşüyor.

## 4. §C — `EntityMaterializer` + okuma yolu

**C1.** `case "Project": await MaterializeProjectAsync(...)` — `MaterializeTaskListAsync`ın birebir
deseni: **TAM-SATIR UPSERT** (`ON CONFLICT (entity_id) DO UPDATE SET` her sütun),
🔴 **`owner_id` `DO UPDATE SET`e GİRMEZ** (F2: ilk yazan sahipliği korur).
`default:` yorumu güncellenir — artık yalnız `Tag` ve tanınmayan tipler no-op.

**C2.** `ITaskReadStore.ListProjectsAsync(Guid ownerId, bool includeDeleted, int limit,
TaskKeysetCursor? cursor, CancellationToken ct)` + `TaskReadStore` uygulaması —
`ListTaskListsAsync`ın birebir SQL'i (`ORDER BY pos, entity_id`), 🔴 **İKİ DALLI keyset yüklemi
PAZARLIKSIZ** (cursor yok → süzgeçsiz · `cursor.Pos != null` → geçilmiş non-null pozisyonlar **VEYA**
herhangi bir null-pozisyon satırı · `cursor.Pos == null` → yalnız `entity_id` geçilmiş null-pozisyonlar).
`OR pos IS NULL` kolunu düşürmek null bölmesini çökertir.

**C3.** `GetProjectsQuery`/`GetProjectsResult` + Handler — `GetTaskListsQueryHandler` deseni
(`limit + 1` çek, `hasMore`, `TaskCursorCodec.Encode`).

**C4.** `ProjectEndpoints` → `GET /v1/projects` (`TaskListEndpoints`ın aynısı): `ICurrentUser.UserId`
yoksa **401** · `limit` 1–200 dışında **400 ProblemDetails** · bozuk cursor **400, ASLA 500** ·
`Program.cs`e `ProjectEndpoints.Map(app, versionSet);` satırı (`TaskListEndpoints`ın altına).

## 5. §D — testler (mevcut dosyalara)

**D1. 🔴 İLK İŞ — ÖLÇ:** `FieldStrategyRegistryCoverageTests` `Project`i bugün nasıl ele alıyor?
(muaf mı, yoksa `DescribeFieldKeys("Project")` bir projeksiyona karşı mı sınanıyor?) Ham çıktı
KANIT'a. **Ölçmeden kod yazma** — `ProjectProjection` eklenince bu kapı kırmızıya dönebilir ve
o zaman düzeltme testi değil **kapsamı** ilgilendirir (`members` bilerek dışarıda).

**D2.** Materyalizasyon gidiş-dönüş: `Project` op'u (`name` + `isDeleted`) → `projects` satırı;
`name` güncellemesi satırı **yerinde** günceller; `owner_id` **DEĞİŞMEZ** (ikinci sahip yazamaz).

**D3.** 🔴 **Kanal testi (mutant-16'nın muadili):** `pos` yalnız `Orders`tan gelen bir op'ta
materyalize satırda **DOLU** olmalı. `ProjectProjection`ı `Fields`ten okumaya çeviren mutant bu
testte **ÖLMELİ**. Mutant **uygulanıp kırmızısı ham çıktıyla** gösterilir, sonra geri alınır.

**D4.** Okuma ucu: farklı sahibin projesi **görünmez** (owner süzgeci) · `includeDeleted=false`
silinmişi **eler** · keyset ikinci sayfayı **tekrarsız** getirir.

**D5.** 🔴 **REGRESYON — YENİ BETİK YAZILMAZ:** `KANIT/o85A/_canli_tur_o85a.py` **olduğu gibi
yeniden koşulur** ve **6/6 geçmelidir**. Materyalizasyon eklendikten sonra her `Project` op'u
fazladan bir DB yazımı yapıyor; senkron davranışı bozulmadığının kanıtı budur. Ham çıktı KANIT'a.

## 6. §E — KANIT

- `KANIT/o85B/00-CEVAP.md` (beş satır, §7)
- `01-registry-kapsam-olcumu.txt` — D1'in ham çıktısı (kod yazmadan ÖNCE alınmış)
- `02-migration.txt` — `AddProjects`in tam metni + `dotnet ef migrations list` çıktısı
- `03-kanal-mutanti-kirmizi.txt` — D3 mutantının düşürdüğü testin ham çıktısı
- `04-canli-tur-regresyon.txt` — D5'in ham çıktısı (6/6)
- `05-verify-ps1.txt` — `verify.ps1` EXIT 0 özeti

## 7. CEVAP — `KANIT/o85B/00-CEVAP.md`, beş satır

1. `FieldStrategyRegistryCoverageTests`in `Project`i ele alışı (ölçüm) ve `ProjectProjection`
   eklendikten sonraki durumu.
2. `projects` tablosunun **son sütun listesi** + indeks adı.
3. `ProjectProjection`ın `Pos` okuma satırı (birebir) ve `members`in okunmadığının tek cümlelik gerekçesi.
4. `verify.ps1` EXIT + test sayısı (öncesi/sonrası) + `GET /v1/projects`in 401/400/200 davranışı.
5. `git --no-optional-locks status --porcelain -- src tests` — `src/client/**` **GÖRÜNMEMELİ**.

## 8. KABUL

- [ ] `projects` tablosu + `AddProjects` migration'ı var; eski migration'lara dokunulmadı
- [ ] `ProjectProjection` `pos`u **`state.Orders`tan** okuyor; D3 mutantı **öldü** (ham kırmızı var)
- [ ] `EntityMaterializer` `Project` dalı TAM-SATIR UPSERT, `owner_id` `DO UPDATE SET`te **YOK**
- [ ] `GET /v1/projects`: 401 (kimliksiz) · 400 (bozuk cursor / limit) · 200 + keyset sayfalama
- [ ] `members` materyalize **EDİLMEDİ**, gerekçesi kodda tek cümle
- [ ] 🔴 `_canli_tur_o85a.py` **6/6** — senkron davranışı bozulmadı
- [ ] `src/client/**` ve `FieldStrategyRegistry` **değişmedi** · yeni kapı dosyası açılmadı
- [ ] `verify.ps1` EXIT 0 · Tek commit, **yol belirterek**, çift tırnaksız mesaj,
      author `onurkesimbjk@gmail.com` · 🔴 **PUSH YOK**
- [ ] Kanıt dosyası **kendi commit'inin hash'ini yazmaz**

## 9. DOKUNMA LİSTESİ

- ❌ `src/client/**` · `FieldStrategyRegistry` · mevcut migration'lar · ingest/pull/hydration
- ❌ `members` / `project_members` (DİLİM 3)
- ❌ `verify.ps1` · `DURUM.md` · `CLAUDE.md` · `arsiv/` · `.github/workflows/*`
- ❌ Yeni kapı dosyası · `GET /v1/projects`i istemciye bağlamak
- ❌ **PUSH** — sıradaki adım Onur'un

# GÖREV (Claude Code) — slice-3a: entity materyalizasyonu + okuma API'si (ADR 0002 K2-I2 / K2-I3)  [v5]

> **BEŞ TUR BAĞIMSIZ DENETİMDEN GEÇTİ:** v1 → (red-team **5 bloker + 11 majör + 7 minör** · teknik doğruluk **4 bloker + 6 majör + 9 minör**) → v2 → (**hedefli yeniden-doğrulama: 2 kalan bloker + 7 majör + 11 minör**) → v3 → (**taze kapanış denetimi: 1 kalan bloker + 4 majör + 2 minör**) → v4 → (**delta denetimi: 2 kalan bloker + 5 çelişki**) → **v5**.
>
> **v4'ün kusurları — ikisi de kapı fiziğiydi, biri doktrinde delikti:**
> 1. **`mutant-16` KeyNotFoundException fırlatırdı.** `state.Fields["pos"]` **indeksleyicisi** eksik anahtarda fırlatır; `_fields`'e yalnız `ApplyField`/`LoadField` yazar ve `pos` Fractional olduğu için oraya **hiç girmez** ⇒ istisna `ProcessOpAsync`'e sızar (try/catch yok), txn geri alınır, `/v1/sync` 500 döner ve satır **hiç yazılmaz**. Yani adım 8 "sessiz NULL" yüzünden değil **istisna** yüzünden kırılırdı — iddia edilen ısırma yüzeyi bu değildi ve senaryonun kalanına cascade ederdi. Diff **savunmacı okuma** olarak pinlendi.
> 2. **"YAPISAL SINIR — ADLANDIRILMIŞ MUAFİYET" İDDİASI YANLIŞTI.** v2/v3/v4, `mutant-13(b)`'yi "öldürülemez, hayatta kalan mutant" ilan edip §5'in "ısırmayan mutantta DUR" kırmızı çizgisine **muafiyet** açmıştı. Denetim gösterdi: `_entities` ↔ `DescribeFieldKeys` **canlılık assert'i** (reflection) onu **öldürür**. Ayrıca teşhis de yanlıştı — (b)'nin hayatta kalma sebebi "D2b'nin tek yönlü olması" değil, (b)'nin bugünkü registry üzerinde **davranışsal olarak EŞDEĞER** bir mutant olmasıydı; eşdeğer mutant **muafiyetle değil, kapsam dışı bırakılarak** ele alınır. **Muafiyet kaldırıldı**; "kör kapı yok" doktrininde delik yoktur.
> 3. **Adım 7 / adım 8 asimetrisi keyfiydi.** `listPos`/`boardPos` ile `pos` **birebir aynı fiziktir** (üçü de Fractional, üçü de `_orders`'ta) ama adım 7 "mutantsız", adım 8 kapılıydı ve Task tarafını koruyan başka kapı **yoktu**. `mutant-16` ikisini birden kapsar (sayı değişmedi).
> 4. Ayrıca beş metin çelişkisi: satır-içi "sessiz NULL" fiziği · adım 8'in iki yerde hâlâ "mutantsız" sayılması · teslim protokolünün bayat maddesi · D0-a'nın beyansız kalması · sürüm başlığı.
>
> **v3'ün kusurları — üçü doğrudan kapı fiziğiydi:** (1) §5'in "bir mutant ısırmıyorsa DUR" kırmızı çizgisi, `mutant-13`'ün zorunlu kıldığı "(a)+(b) PASS" sonucuyla **doğrudan çelişiyordu** ⇒ lafzen uygulayan builder o mutantta dururdu (v2 blokerinin farklı yoldan dönüşü); (2) senaryo başlığı **"sekiz adım"** diyordu ama dokuz madde listeliyordu — başlığı harfiyen uygulayan builder **adım 9'u düşürür ve `mutant-9` kapısız kalırdı**; (3) adım 1'de **hangi alanın** null'a çekileceği adlandırılmamıştı ⇒ builder alanı hiç yazmazsa (durum 1) assert aynen geçer ama `mutant-14` **silahsızlanırdı**; (4) `task_lists`'in `pos → Orders` kanal hatasını ısırdığı kanıtlanan **hiçbir mutant yoktu** (`mutant-16` eklendi); (5) kriter 6(a) `SyncDbContextModelSnapshot.cs`'i saymıyordu — `dotnet ef migrations add` onu her zaman yeniden üretir ⇒ **garantili sapma**.
>
> **Kapanış denetimi ayrıca DOĞRULADI:** v2'nin iki blokeri **kapandı** — `mutant-13` artık izole ham kırmızı üretiyor (koşum (a)), ve `isDeleted` düzeltmesi tam: `mutant-9` altında hem `is_deleted` hem `has_delete_edit_conflict` **iki uçtan birden** ısırıyor. D2a'nın pinli gövdesi mevcut davranışı birebir koruyor ve `deleteKey` regresyonunu yakalayan deterministik assert gerçekten kırılıyor.
>
> **v2'nin kusuru — ev tarihinin tam olarak uyardığı kalıp (2c'de birebir yaşandı):** v2, blokerleri "kapattığını beyan etti" ama **iki kapı fiilen ısırmıyordu**:
> 1. **`mutant-13`'ün YÖNÜ TERSTİ.** "`DescribeFieldKeys` sabit liste döndürür" mutasyonu, bugünkü doğru listeyle özdeş bir sabit liste olduğu için D2b'yi **aynen yeşil** bırakıyordu; parantez içindeki ölçüm ise mutantın tersini anlatıyordu. **Hiç kırmızı çıktı üretilemezdi** ⇒ KANIT kuralı (b) sağlanamaz, builder kilitlenirdi.
> 2. **`mutant-1`'in "D5-b adım 7 FAIL" atfı FİZİKSEL OLARAK YANLIŞTI.** Op `listPos`'a dokunuyorsa delta yazımı da onu yazar ⇒ assert geçer. Adım 7 bir mutant kapısı değil, kanal-karışıklığı regresyon önlemidir.
> 3. **`isDeleted` düzeltmesi yarım kaldı.** Kural Domain'e (Ordinal) taşındı ama D5-b'nin `malformed_fields ⊇ {isDeleted}` beklentisi `bool.TryParse` dünyasından kalmıştı — Ordinal-eşitlik semantiğinde "ayrıştırılamayan değer" **diye bir durum yoktur**, dolayısıyla o beklenti §7'yi ihlal etmeden **üretilemezdi**. Aynı gözden kaçma ÜÇ+BİR DURUM'un 4. maddesini **ölü koda** çevirmişti.
> 4. **`task_lists` uçtan uca KAPISIZDI** — şemada, indekste ve uç tablosunda vardı ama **hiçbir teslimat bir `task_lists` satırı yazıp okumuyordu**; `TaskListProjection`'ın kaydı ve `pos → state.Orders` kanalı hiç pinlenmemişti (v1'in Task tarafında kapattığı kanal hatasının TaskList'te açık kalmış hâli).
> 5. **D5-a'nın totolojisi adım 1 üzerinden geri sızıyordu** — "meşru `null` ⇒ malformed DEĞİL" kuralını ölçen tek yüzey D5-a'ydı ve iki tarafı da `From`'u çağırdığı için o kuralın ihlali ısırmıyordu.
>
> **v1'in kusurları:** D5 totolojiydi · `isDeleted` ikinci implementasyon · `owner_id` istemci-kontrollü · `mutant-1` inşa edilemiyordu · `SchemaTests` entity sayımı kabul kriteriyle çelişiyordu · okuma portu yoktu (arch Rule 2) · `RoundtripKind` `DateTimeOffset`'te etkisizdi ve offset'siz girdi yerel saat dilimini alıyordu.
>
> **Kaynak karar:** ADR 0002 **K2-I1/I2/I3** + bu dilimin **yedi fork'u** (Onur, 19 Tem 2026 — §3).

- **Rol:** Sen **build** edersin. `PROJE_HAFIZA.md` ve `docs/ADR/*`'a **DOKUNMA**. Cowork artefaktı bağımsız doğrular.
- **Dil:** Kod/isimler İngilizce; commit mesajı **ASCII**.
- Testler Docker İSTER (Persistence.Tests). Docker'sız koşuda fail = doğru davranış (skip/kör-kapı YOK).

## 0. Önce oku

`CLAUDE.md` · `PROJE_HAFIZA.md` (oturum-7 devri) · ADR 0002 **K2-I1/I2/I3**, **K2-B2**, **K2-C3**, **K2-C4**, **K2-E3**, **K2-E5** · `Domain/Sync/State/EntityState.cs` (**TAMAMI**, 63-118 kritik) · `Domain/Sync/Crdt/OrSetField.cs` · `LwwRegister.cs` · `ResolvedGroupField.cs` · `Domain/Sync/Registry/FieldStrategyRegistry.cs` · `Application/Features/Sync/SyncCommandHandler.cs` · `Application/Behaviors/TransactionBehavior.cs` · `Application/MediatorConfiguration.cs` · `Infrastructure/Sync/SyncStore.cs` · `SyncRowHydration.cs` · **`SyncPuller.cs`** · `Infrastructure/DependencyInjection.cs` · `Api/Endpoints/SyncEndpoints.cs` · `Api/Endpoints/DiagnosticsEndpoints.cs` (mediator'lu uç kalıbı) · **`tests/Momentum.ArchitectureTests/ArchitectureRuleTests.cs` (Rule 1/2/3/4 — PAZARLIKSIZ)** · `tests/Momentum.Persistence.Tests/TestSupport.cs` · `SchemaTests.cs` · `EndpointTests.cs` · `FakeCurrentUser.cs`.

## 1. KANITLANMIŞ BOŞLUK (yeniden keşfetme; doğrula ve geç)

**B1 — Entity tablosu yok.** DB'de **7 senkron tablosu** (+ `__EFMigrationsHistory`) var: `outbox_messages`, `processed_operations`, `sync_client_clock`, `sync_gc_state`, `sync_orset_removes`, `sync_orset_tags`, `sync_scalar_meta`. **Hiçbiri entity satırı değil.** Çözülmüş entity durumu **yalnız bellekte** (`EntityState`) yaşıyor, her istekte `SyncRowHydration` ile yeniden kuruluyor. Sunucu-tarafı sorgu/sıralama dayanağı **yok**. *(Bu 7 sayısı `SchemaTests.cs:20`'nin `ShouldBe(7)`'siyle birebir örtüşür; kriter 2'nin `ShouldBe(10)`'u = 7 + 3 yeni.)*

**B2 — Sahiplik yalnız outbox'ta ve İSTEMCİ BEYANLI.** `SyncPuller.cs:88-103` sahipliği `outbox_messages.owner_id`'den türetiyor; o kolon `op.ActorId`'den geliyor (`SyncCommandHandler.cs:178`), yani **istemcinin gönderdiği JSON alanından** (`WireOp`, `SyncContracts.cs:22-32`). İki kusur: (i) outbox budandığında sahiplik buharlaşır (**GC yazıcısı bugün YOK** ⇒ gizli risk); (ii) sahiplik **doğrulanmamıştır**. Bu dilim (ii)'yi **kendi yolu için** kapatır (§3/F5), outbox/snapshot yolu için **kapatmaz**.

## 2. Kapsam — NE VAR / NE YOK

**VAR:** `tasks` + `task_lists` + `task_tags` şeması · saf Domain **projeksiyon fonksiyonları (Task VE TaskList)** · aynı-txn **tam-satır** materyalizasyon · kimliği doğrulanmış `owner_id` · **okuma portu + okuma API'si** (3 uç) · NULL-sınırlı keyset sayfalama · collation pini · registry↔projeksiyon tam-kapsam kapısı · **D5-a round-trip + D5-b literal oracle** · **16 mutant** + KANIT.

**YOK — adlandırılmış erteleme (sessiz açık bırakma YASAK):**
- **`Project` ve `Tag` materyalizasyonu** — ADR K2-I2 kapsam pini.
- **`assignees` / `checklistItems` OR-Set materyalizasyonu** — §3/F4.
- **`Task` ↔ `TaskList` bağı** — registry'de `taskListId` **YOKTUR**, bu dilimde **İCAT EDİLMEZ** (§3/F6). `task_lists` bağımsız materyalize edilir.
- **`Section` entityType'ı** — `FieldStrategyRegistry` yalnız `"TaskList"` tanımlıyor (`FieldStrategyRegistry.cs:153-154`; tel eşlemesi Application'a bırakılmış, eşleme bugün **yok**) ⇒ `entityType="Section"` op'ları registry ihlali olarak reddedilir. `task_lists` **yalnız `TaskList`** tutar.
- **Metin arama / `ILIKE` / `lower()`** — tr-TR'de I↔ı pinlenmeden açılan arama kapısız bir yüzeydir.
- **BACKFILL YOK** — D8 çıpasıyla pinlenir.
- **Keyset sayfalamanın EŞZAMANLI YAZIM altındaki davranışı** — D0-c'nin garantisi **sabit (yazımsız) veri kümesi** içindir. `list_pos` sürükle-bırak sıralamanın taşıyıcısıdır; sayfalar arası değişirse tekrar/atlama olabilir.
- **`owner_id`'nin outbox/snapshot yolundaki doğrulanmamışlığı** (B2-ii) — D7 çıpasıyla belgelenir.
- **Materyalize satırda damga/`updatedAt` kolonu yok.**
- **`GET /v1/task-lists/{id}`** yok (asimetri bilinçli).
- 3b (Flutter), collab-auth, K2-G2, K2-C7 pull ayağı, push-authz E3, Redis backplane.

## 3. KİLİTLİ TASARIM KARARLARI (Onur, 19 Tem 2026)

**F1 — Materyalizasyon AYNI OP-TRANSACTION'INDA.** `ProcessOpAsync` içinde, `PersistDeltaAsync`'ten hemen sonra, aynı `scope`'ta, **yalnız `Applied`** dalında. *Reddedilen:* asenkron projektör = tel formatını yorumlayan ikinci yer = E-1 hata sınıfı.

**F2 — `owner_id` İLK YAZAN SAHİPLENİR.** `ON CONFLICT ... DO UPDATE SET` listesinde `owner_id` **BULUNMAZ**. **GEÇİCİ POLİTİKA**; auth dilimi değiştirir.

**F3 — Tipli kolonlar + HOŞGÖRÜLÜ ayrıştırma.** `sync_scalar_meta` otorite kalır ⇒ veri kaybı imkânsız.

**F4 — OR-Set kapsamı: YALNIZ `tags`.**

**F5 — `owner_id` KİMLİĞİ DOĞRULANMIŞ actor'dan gelir.** `SyncCommand.ActorId` (uçtaki `ICurrentUser.UserId`'den, `SyncEndpoints.cs:33-36`) `ProcessOpAsync`'e geçirilir; materyalizasyon **YALNIZ onu** kullanır. `op.ActorId` materyalizasyonda **KULLANILMAZ**. Outbox/`SyncPuller` **DEĞİŞMEZ**. Kapısı `mutant-3`.

**F6 — Task↔TaskList bağı İCAT EDİLMEZ.** Okuma API'si görevleri yalnız `projectId` ile filtreler.

**F7 — Dilim BÖLÜNMEZ.**

## 4. Teslimatlar

---

**D0 — KIRMIZI ÖNCE [PAZARLIKSIZ, İLK İŞ].**

**UYGULAMA PİNİ [PAZARLIKSIZ]:** üç test **bugünkü ağaca karşı DERLENMEK ZORUNDADIR** — yalnız (a) HTTP yüzeyi (`WebApplicationFactory<Program>`, `EndpointTests.cs:33-35` kalıbı), (b) ham SQL (`Db.ScalarAsync`/`ExecuteAsync`), (c) bugün var olan `SyncTestApp`/`Wire` üyeleri, (d) **inline kurulan `WireOp`** (public record, `SyncContracts.cs:22-32`). Var olmayan bir C# tipine referans **VERME**. Kırmızı, **koşum hatası** olmalıdır (`relation "tasks" does not exist`, `404`) ve KANIT'a **ham** yapıştırılır.

**İKİ KİMLİK PİNİ:** `FakeCurrentUser` **sabit kimliklidir** (`FakeCurrentUser.cs:13-15`) ⇒ D0-b iki actor için **aynı connection string'e bakan İKİ `WebApplicationFactory`** kurar. Push'lar `SyncTestApp.SyncAsync(actorId, request)` ile yapılır (kimliği doğrulanmış actor'ı gövdeden **ayrı** alır, `TestSupport.cs:80`).

**ORDER KANALI PİNİ:** `Wire`'da Order yardımcısı **YOKTUR** (`TestSupport.cs:207-251`; `Op` bile `order`'ı `null` geçer). `listPos`/`pos` **Order kanalıdır**; `Fields`'e konursa `IsOperationValid` op'u **`RejectedRegistryViolation`** ile eler ve test "yanlış sebeple kırmızı" olur. `WireOp`'u **inline kur**; `TestSupport.cs`'e yardımcı eklersen sapma listesine yaz.

- **D0-a — materyalizasyon çıktısı (ham SQL):** birkaç op push et, `tasks` satırını ham SQL ile oku, beklenen değerlerle karşılaştır.
- **D0-b — sahip filtresi kapısı. BEŞ assert, beşi de zorunlu:**
  1. A bir Task yazar → `GET /v1/tasks` (A) **görevi GÖRÜR** *(bu assert olmadan test, uç eklendikten sonra yanlış sebeple yeşil kalır)*;
  2. `GET /v1/tasks` (B) → **GÖRMEZ**;
  3. `GET /v1/tasks/{id}` → **A için 200 + doğru gövde**, **B için 404** *("her zaman 404 dönen" bir uç 200 assert'i olmadan bu testi geçerdi)*;
  4. **ENJEKSİYON [F5'in kapısı]:** A olarak kimlik doğrula, gövdede `actorId = B` olan op push et → satır **A'nın olur**, B'nin listesinde **GÖRÜNMEZ**;
  5. **TaskList ayağı:** A bir TaskList yazar → `GET /v1/task-lists` (A) **GÖRÜR**, (B) **GÖRMEZ**.
- **D0-c — NULL-sınırı keyset sayfalama:** 3 görev `listPos` ile, 3 görev `listPos`'suz; `limit=2`.
  **SERT TUR SINIRI [PAZARLIKSIZ]:** `for (var page = 0; page < 10; page++)` — sınırsız `while` **YASAK**. Assert: toplanan id **tam 6**, **hepsi farklı**, **pinli sırada**.

**Dürüstlük sınırı:** D0-b/D0-c'nin "bugün kırmızı" olması ucun yokluğundandır; ayırt edici güçleri `mutant-3/4/5/12/15`'ten gelir. **D0-a'nın kendi mutantı YOKTUR** — o bir kırmızı-önce kanıtı ve duman testidir; materyalizasyonun ayırt edici kapıları D5-a/D5-b'dir. Raporda böyle adlandır.

---

**D1 — ŞEMA (EF Core migration).**

**PİN:** tablolar **mevcut `SyncDbContext`'e** eklenir (ayrı context YOK); entity tipleri `SyncEntities.cs`'e, yapılandırma `Configurations/`'a (`SyncConfigurations.cs:25` `UseCollation("C")` kalıbı).

```sql
CREATE TABLE tasks (
  entity_id uuid PRIMARY KEY, owner_id uuid NOT NULL,
  title text NULL, notes text NULL, priority integer NULL,
  due_at timestamptz NULL, remind_at timestamptz NULL, project_id uuid NULL,
  is_deleted boolean NOT NULL DEFAULT false, recurrence_rule text NULL,
  list_pos text COLLATE "C" NULL, board_pos text COLLATE "C" NULL,
  status text NULL, completed_at timestamptz NULL,
  has_delete_edit_conflict boolean NOT NULL DEFAULT false,
  malformed_fields text[] NOT NULL DEFAULT '{}'
);
CREATE TABLE task_lists (
  entity_id uuid PRIMARY KEY, owner_id uuid NOT NULL, name text NULL,
  is_deleted boolean NOT NULL DEFAULT false, pos text COLLATE "C" NULL,
  has_delete_edit_conflict boolean NOT NULL DEFAULT false,
  malformed_fields text[] NOT NULL DEFAULT '{}'
);
CREATE TABLE task_tags (
  task_id uuid NOT NULL, tag text COLLATE "C" NOT NULL, PRIMARY KEY (task_id, tag)
);
```

**İndeksler:** `tasks(owner_id, is_deleted, list_pos, entity_id)` · `tasks(owner_id, project_id)` · `task_lists(owner_id, is_deleted, pos, entity_id)`.
*İndeks gerekçesi yalnız `includeDeleted=false` yolunda sıralamayı karşılar; `includeDeleted=true`'da `is_deleted` öncü kolon olduğu için planlayıcı yine `Sort` ekler. Bu bilinçlidir (varsayılan yol optimize edilmiştir).*

**PİNLER:**
- **`task_tags`'te FK YOK** — K2-E5 soft-ref. Yorum satırıyla gerekçelendir.
- **Konum kolonları + `tag` `COLLATE "C"`** — kesirli-index anahtarları noktalama içerir, dilbilimsel collation onu birincil düzeyde yok sayabilir; `OrSetField` eleman kimliğini `StringComparer.Ordinal` ile karşılaştırır.
- `malformed_fields` **`StringComparer.Ordinal` ile sıralı ve tekilleştirilmiş** *(`List<string>.Sort()`'un varsayılanı `CurrentCulture`'dır ve §7 onu yasaklar)*.
- **ÖLÇÜM GÖREVİ:** kriter 2 `ShouldBe(10)` diyor. `malformed_fields`'in `string[]` **primitive collection** olarak ayrı bir EF entity tipi **yaratmadığını** doğrula; yaratıyorsa sayıyı ölçtüğün değere göre düzelt ve rapora yaz.

---

**D2 — SAF DOMAIN PROJEKSİYON FONKSİYONLARI [tek otorite].**

Yer: `Momentum.Domain/Sync/Projection/TaskProjection.cs` + `TaskListProjection.cs`.
**Namespace `Momentum.Domain.Sync`** (klasör ≠ namespace; mevcut kalıp: `State/EntityState.cs:1`, `Crdt/*`, `Registry/*`).
Saf, IO'suz: `static TaskProjection From(Guid entityId, EntityState state)` / `static TaskListProjection From(...)`.

```csharp
public sealed record TaskProjection(
    Guid EntityId, string? Title, string? Notes, int? Priority,
    DateTimeOffset? DueAt, DateTimeOffset? RemindAt, Guid? ProjectId,
    bool IsDeleted, string? RecurrenceRule, string? ListPos, string? BoardPos,
    string? Status, DateTimeOffset? CompletedAt,
    bool HasDeleteEditConflict, IReadOnlyList<string> MalformedFields, IReadOnlyList<string> Tags);

public sealed record TaskListProjection(
    Guid EntityId, string? Name, bool IsDeleted, string? Pos,
    bool HasDeleteEditConflict, IReadOnlyList<string> MalformedFields);
```

**KAYNAK KANAL TABLOSU [PAZARLIKSIZ]:** her alanın hangi sözlükten okunacağı pinlidir.

| alan | kaynak kanal | tip kuralı |
|---|---|---|
| `title`, `notes`, `recurrenceRule` (Task) · `name` (TaskList) | `state.Fields` | text, dönüşüm yok |
| `priority` | `state.Fields` | `int.TryParse(v, NumberStyles.Integer, CultureInfo.InvariantCulture, out var parsed)` |
| `dueAt`, `remindAt` | `state.Fields` | tarih kuralı (aşağıda) |
| `projectId` | `state.Fields` | `Guid.TryParse(v, out var parsed)` *(bilerek `TryParseExact` DEĞİL — `SyncCommandHandler.TryScope`'un `Guid.TryParse`'ı ile aynı olsun, `scope_id` ↔ `project_id` ayrışmasın)* |
| `isDeleted` (her iki entity) | **`state.IsDeleted`** (D2a) | Ordinal tek-otorite; **ayrıştırma YOK** |
| **`listPos`, `boardPos` (Task) · `pos` (TaskList)** | **`state.Orders`** | text, dönüşüm yok |
| `status`, `completedAt` | **`state.Groups["completion"].Fields`** | text / tarih kuralı |
| `hasDeleteEditConflict` | **`state.HasDeleteEditConflict`** | çağrılır, yeniden hesaplanmaz |
| `tags` (Task) | **`state.Sets["tags"].PresentElements()`** | `StringComparer.Ordinal` ile **SIRALANIR** |

> **`pos`/`listPos`/`boardPos` kanal uyarısı:** bunlar registry'de `Fractionals`'tır (`FieldStrategyRegistry.cs:143,158`) ve **yalnız `EntityState.Orders`'ta** yaşar (`SyncRowHydration.cs:35-37`, `ConflictResolver.cs:21-24`); `_fields`'te bu anahtarlar **hiç oluşmaz**. `state.Fields`'ten (savunmacı) okuyan bir uygulama kolonu **sessizce hep NULL** yazar — *indeksleyiciyle (`state.Fields["pos"]`) okursa `KeyNotFoundException` fırlatır ve op'un txn'i çöker; bkz. `mutant-16` diff pini*. **Kapısı `mutant-16`'dır** (D5-b adım 7 **ve** 8).

**TARİH KURALI [BİREBİR PİNLİ]:**
```csharp
DateTimeOffset.TryParseExact(v, IsoFormats, CultureInfo.InvariantCulture,
    DateTimeStyles.AssumeUniversal | DateTimeStyles.AdjustToUniversal, out var parsed)
// IsoFormats = ["yyyy-MM-dd'T'HH:mm:ss.FFFFFFFK", "yyyy-MM-dd'T'HH:mm:ssK"]
```
- **`RoundtripKind` KULLANILAMAZ** — `DateTimeOffset` üzerinde **etkisizdir** (`Kind` özelliği yok; MS Learn `DateTimeOffset.ParseExact` styles tablosu).
- **`AssumeUniversal` PAZARLIKSIZ:** `K` offset'i **opsiyonel** kılar; offset'siz girdide varsayılan `AssumeLocal`'dır ⇒ değer **makinenin yerel saat dilimine** göre ayrıştırılır. `AdjustToUniversal` saklanan değeri kanonikleştirir. **Offset'siz girdi UTC sayılır.** Kapısı `mutant-8` (ortam-bağımlı, D2d).
- **ÖLÇÜM:** `.FFFFFFF`'in kesirsiz girdiyle eşleştiğini ilk iş olarak tek satırlık bir testle **ölç**; eşleşmiyorsa ikinci format kurtarır, ama ölçümü rapora yaz.
- **`TryParseExact` PİNİ:** gevşek `TryParse` yasak — `InvariantCulture`'ın `ShortDatePattern`'ı `MM/dd/yyyy`'dir ⇒ `TryParse("07/19/2026")` **sessizce kabul eder**. Kapısı `mutant-7`.

**D2a — `EntityState.IsDeleted` [Domain teslimatı].**
`EntityState`'e **public** `IsDeleted` eklenir, **mevcut** `IsDeletedField`/`DeletedValue` sabitlerini (`EntityState.cs:10-11`) kullanır:
```csharp
public bool IsDeleted =>
    _fields.TryGetValue(IsDeletedField, out var d) && d.HasValue
    && string.Equals(d.Value, DeletedValue, StringComparison.Ordinal);
```
`HasDeleteEditConflict`'in ilk iki kontrolü (`EntityState.cs:67-75`) bunu çağıracak şekilde yeniden yazılır. **`deleteKey` ERİŞİM PİNİ [PAZARLIKSIZ]:** `EntityState.cs:77`'deki `var deleteKey = deleted.Key;` satırı `deleted` yerel değişkenine bağlıdır ve refactor'da **kaybolmamalıdır**. Gövde birebir şu olur:
```csharp
if (!IsDeleted) { return false; }
var deleteKey = _fields[IsDeletedField].Key;   // IsDeleted true iken anahtarın varlığı garantidir
```
Projeksiyon `isDeleted`'i **YALNIZ** `state.IsDeleted`'ten alır. **`bool.TryParse` YASAKTIR** — büyük/küçük harf duyarsızdır ve boşluk kırpar; `"True"`/`" true "`/`"1"` girdilerinde Domain'in Ordinal kuralından ayrışır ⇒ satır silinmiş görünür ama çakışma bayrağı hiç yanmaz (K2-C4 ihlali). Kapısı `mutant-9`.

**GÜVENLİK AĞI — DÜRÜSTLÜK BEYANI [ZORUNLU, v2'nin kör iddiasının düzeltmesi]:** v2 "mevcut `DeleteEditConflictTests` + `SemanticRoundTripTests` bu refactor'ı ölçer" diyordu. **Bu iddia KÖRDÜ:** o üç assert de yalnız `ShouldBeTrue` ve değer birebir `"true"` (`DeleteEditConflictTests.cs:36,56`; `SemanticRoundTripTests.cs:73`) ⇒ `deleteKey` yanlış kurulsa bile (ör. `default(HlcKey)`) hepsi yeşil kalır. **Gerçek ağlar:** `IngestUnitTests.C4_delete_edit_conflict_surfaces_and_undelete_clears` ve **rastgele** `OracleDiffProperty` (P3) — ikisi de `deleteKey` regresyonuna **kısmen kördür**. Bu yüzden **ZORUNLU deterministik birim assert** ekle: `isDeleted@HLC(10)` + `title@HLC(5)` ⇒ `HasDeleteEditConflict == false` (yani `deleteKey` gerçekten `isDeleted`'in anahtarıdır, sıfır değil).

**DURUM TABLOSU [PAZARLIKSIZ — v2'nin ölü maddesinin düzeltmesi]:**
1. **Alan yok** (register yok veya `HasValue == false`) ⇒ kolon `NULL`, **malformed DEĞİL**.
2. **Değer meşru `null`** (`Value == null`) ⇒ kolon `NULL`, **malformed DEĞİL**.
3. **Değer non-null ama ayrıştırılamıyor** (`priority`, `dueAt`, `remindAt`, `completedAt`, `projectId`) ⇒ kolon `NULL`, alan adı `MalformedFields`'e girer.
4. **`isDeleted` için 3. durum OLUŞMAZ** — Ordinal-eşitlik bir ayrıştırma değildir: `"True"`, `"xyz"`, `"1"` hepsi eşit derecede "silinmiş DEĞİL"dir ve **malformed sayılmaz**. *v2 buraya "NOT NULL kolonda DEFAULT yazılır + malformed işaretlenir" yazmıştı; o kural `bool.TryParse` dünyasından kalmıştı ve D2a'dan sonra **üretilemez** hâle geldi — üretmenin tek yolu projeksiyona ikinci bir `isDeleted` yüklemi yazmaktı, yani §7'nin ihlali.*
5. `is_deleted` ve `has_delete_edit_conflict` **NOT NULL**'dır; değerleri her zaman Domain'den gelir, hiçbir koşulda NULL yazılmaz.

**İKİNCİ İMPLEMENTASYON YASAĞI:** `HasDeleteEditConflict`, `IsDeleted`, aktif-eleman kümesi ve grup üyeleri — **BİRER** implementasyon, hepsi Domain'de. `DumpTags()` üzerinden elle `Cancelled`/`Hlc` filtresi **yazılamaz**; `"completion.status"` satır biçimi projeksiyonda **yeniden çözümlenmez**.
*Not (adlandırılmış, düzeltilmiyor):* `SyncPuller.cs:136-137` bugün bu filtreyi elle yazıyor — **mevcut** bir koku; dokunma ama **kopyalama**. Raporda beyan et.

---

**D2b — REGISTRY ↔ PROJEKSİYON TAM-KAPSAM KAPISI (birim, `Momentum.SyncCore.Tests`).**

`FieldStrategyRegistry`'ye **ADDITIVE** `IReadOnlyCollection<string> DescribeFieldKeys(string entityType)`.
**TÜRETME PİNİ [PAZARLIKSIZ]:** küme **YALNIZ `_entities`'ten** türetilir (`Scalars` ∪ `Fractionals` ∪ `OrSets` ∪ grup marker'ları ∪ `"group.member"` anahtarları). Elle yazılmış sabit liste **YASAK**. Kapısı `mutant-13`.

**CANLILIK ASSERT'İ [PAZARLIKSIZ — v5'in düzeltmesi]:** üç-kova kuralına ek olarak D2b, `_entities`'i **reflection ile** okuyup beklenen anahtar kümesini kurar ve `DescribeFieldKeys(t)` çıktısıyla **küme eşitliği** assert eder:
```csharp
var entities = typeof(FieldStrategyRegistry)
    .GetField("_entities", BindingFlags.NonPublic | BindingFlags.Instance)!
    .GetValue(FieldStrategyRegistry.Default);
// beklenen = Scalars ∪ Fractionals ∪ OrSets ∪ grup marker'ları ∪ "group.member"
DescribeFieldKeys(t).ShouldBe(beklenen, ignoreOrder: true);
```
*Gerekçe:* üç-kova kuralı **tek yönlüdür** ("sayılan her anahtar kapsanmalı") ve donmuş/bayat bir numaralandırmayı **göremez**. Canlılık assert'i numaralandırmanın gerçekten `_entities`'ten türediğini ölçer ve `mutant-13`'ün tek gerçek kapısıdır. Reflection **yalnız testtedir**; üretim kodu değişmez (kriter 5 etkilenmez).

**KABUL KURALI — ÜÇ KOVA [v2'nin eksiği]:** `Task` ve `TaskList` için her anahtar şunlardan **birine** düşmeli, yoksa FAIL:
1. bir projeksiyon kolonuna **eşlenir**;
2. açık **`Deferred`** listesinde (`assignees`, `checklistItems`);
3. **grup marker'ı** (`"completion"`) — *tüm üyeleri* (`completion.status`, `completion.completedAt`) eşlenmişse **KAPSANMIŞ** sayılır; üyelerden biri eşlenmemişse **FAIL**. *(v2'de bu kova yoktu; `"completion"` marker'ı hiçbir kolona eşlenmediği için builder ya `Deferred`'a ekleyecek ya türetmeden dışlayacaktı — ikisi de pini ihlal eder.)*

---

**D2c — KÜLTÜR BAĞIŞIKLIĞI [mutantsız — dürüstlük beyanı].** (`Momentum.SyncCore.Tests`)

Projeksiyon testleri `CultureInfo.CurrentCulture = new CultureInfo("tr-TR")` altında **birebir aynı** sonucu vermeli.
**BEYAN [ZORUNLU]:** **regresyon önlemidir, kapı DEĞİLDİR.** Gerekçe teknik denetimde doğrulandı: format dizesindeki `-` gerçek literaldir (yalnız `/` kültür-bağımlı tarih ayıracıdır), `:` zaman ayıracıdır ve tr-TR'de zaten `:`'tir; `int.TryParse(NumberStyles.Integer)` tr-TR'de aynı davranır ⇒ `InvariantCulture → CurrentCulture` mutasyonu **ısırmaz**.

---

**D2d — SAAT DİLİMİ BAĞIŞIKLIĞI [ortam-bağımlı kapı].** (`Momentum.SyncCore.Tests`)

`"2026-07-19T10:00:00"` ⇒ `parsed.Offset == TimeSpan.Zero` **ve** `parsed.UtcDateTime == 2026-07-19T10:00:00Z`. `"2026-07-19T13:00:00+03:00"` ⇒ aynı UTC ana normalize olur.
**BEYAN [ZORUNLU]:** `mutant-8` **yalnız yerel TZ ≠ UTC olan makinede** ısırır. Bu makine tr-TR/`+03:00`'tür ⇒ burada ısırır; UTC bir CI konteynerinde **ısırmaz**. KANIT'a `TimeZoneInfo.Local.Id` **yaz**.

---

**D3 — MATERYALİZASYON YAZICISI (port + Infrastructure).**

- Port: `Momentum.Application/Abstractions/Sync/IEntityMaterializer.cs`
  ```csharp
  Task MaterializeAsync(ChangeOperation op, EntityState state, Guid ownerId, CancellationToken ct);
  ```
  **İMZA PİNİ:** `op` **parametre olarak geçer** (`ISyncStore.PersistDeltaAsync(op, state, ct)` kalıbı) — `mutant-1`'in inşa edilebilmesi buna bağlıdır. **`ownerId`** kimliği doğrulanmış `command.ActorId`'dir; `op.ActorId` **KULLANILMAZ** (F5).
- Uygulama: `Momentum.Infrastructure/Sync/EntityMaterializer.cs`, `SyncDbContext.CreateRawCommandAsync` ile.
- **DI:** `DependencyInjection.cs`'e `services.AddScoped<IEntityMaterializer, EntityMaterializer>();`. *Unutulursa `TestSupport.cs:83`'ün `ActivatorUtilities.CreateInstance` çağrısı yüzünden **35 Persistence testi birden** patlar.*
- **Çağrı yeri:** `ProcessOpAsync`, `PersistDeltaAsync`'ten hemen sonra, yalnız `Applied`, aynı `scope`. `ProcessOpAsync` imzasına kimliği doğrulanmış actor eklenir (`Handle`'daki `command.ActorId`'den). *Tek çağıran `SyncCommandHandler.cs:55`, metot `private` ⇒ imza değişikliği güvenli.*
- **Kapsam dışı entityType (`Project`, `Tag`, tanınmayan) ⇒ sessiz no-op.** Çıpası D6.

**TAM-SATIR UPSERT [PAZARLIKSIZ]:** yazıcı op'un dokunduğu kanallara **BAKMAZ**; çözülmüş `EntityState`'in tamamını projekte eder, **bütün kolonları** yazar.
```sql
INSERT INTO tasks (...) VALUES (...)
ON CONFLICT (entity_id) DO UPDATE SET title = excluded.title, ..., malformed_fields = excluded.malformed_fields
  -- owner_id BİLEREK YOK (F2)
```
*Delta yazımının ayrıştığı gerçek yer:* **grup REPLACE** — `ResolvedGroupField.Apply` tüm sözlüğü değiştirir (`ResolvedGroupField.cs:29`), `SyncStore.PersistGroupAsync` yazılmayan üye satırlarını siler (`SyncStore.cs:98-107`) ⇒ delta yazımı `completed_at`'i **bayat** bırakır. Kapısı `mutant-1`.
**`task_tags`:** o `task_id` için **tüm satırları sil, mevcut elemanları yeniden ekle**. Kısmi delta YOK.

---

**D3b — COLLATION KAPISI (`SchemaTests`'e YENİ `[Fact]`).**

`tasks.list_pos`, `tasks.board_pos`, `task_lists.pos`, `task_tags.tag` ⇒ `information_schema.columns.collation_name = 'C'`.
**BEYAN + ÖLÇÜM GÖREVİ [ZORUNLU]:** bu kapı **şema beyanını** pinler, çalışma-zamanı davranışını değil. `postgres:17-alpine` musl kullanır; musl `strcoll` ≈ `strcmp` ⇒ varsayılan collation davranışsal olarak `C` ile **aynı olabilir**.
Ölç ve **ham** yaz: `SHOW lc_collate;` **ve** davranışsal örnek (`SELECT 'a|b' < 'ab' COLLATE "default"` vs `... COLLATE "C"`).
**UYARI:** `SHOW lc_collate` muhtemelen `en_US.utf8` yazacak ve **yanıltıcı** olacaktır (musl'da etiket ≠ davranış). İkisinin çelişmesi normaldir; ikisini de yaz.
- Ayrışıyorsa: davranışsal sıralama testi de ekle, `mutant-6`'nın onu da kırdığını göster.
- Ayrışmıyorsa: `mutant-6`'nın yüzeyinin **yalnız şema beyanı** olduğunu beyan et; testi güçlü gösterme.

---

**D4 — OKUMA PORTU + OKUMA API'Sİ.**

**KATMAN PİNİ [PAZARLIKSIZ]:** `ArchitectureRuleTests.cs:46-57` **Rule 2** = `Momentum.Api.Endpoints` `Momentum.Infrastructure`'a bağımlı **olamaz**. Endpoint'e ham SQL koymak `SyncDbContext`/`NpgsqlCommand` gerektirir ⇒ **derleme geçer, arch testi KIRILIR**. Zincir:

`Endpoint (Api) → IMediator → Query handler (Application/Features/Tasks) → ITaskReadStore (Application/Abstractions/Sync) → TaskReadStore (Infrastructure)`

*`SyncCommandHandler → ISyncStore` kalıbının aynısı. `TransactionBehavior.cs:25` sorguları atlar ⇒ ambient txn açılmaz. Mediator handler keşfi **otomatiktir** (`PingQueryHandler` kalıbı; `AddMediator()` çapraz-derleme keşfi yapar, `MediatorConfiguration.cs`'in `[assembly: MediatorOptions(Scoped)]`'u yeni handler'a da uygulanır) ⇒ **ek kayıt gerekmez**.*
**Tüm SQL `TaskReadStore`'dadır**; `mutant-4/5/12/15`'in mutasyon hedefi bu dosyadır.

| uç | davranış |
|---|---|
| `GET /v1/tasks` | `projectId?`, `includeDeleted` (varsayılan `false`), `limit` (varsayılan 50, **1..200 dışı ⇒ 400**), `cursor?` |
| `GET /v1/tasks/{id}` | sahibi değilse veya yoksa **404**; **soft-silinmiş görev 200 döner** (bayraklarıyla) |
| `GET /v1/task-lists` | `includeDeleted`, `limit`, `cursor` |

**PİNLER:**
- **Deny-by-default:** `ICurrentUser.UserId is not { } actorId` ⇒ `401` (`SyncEndpoints.cs:33-36` kalıbı).
- **Sahip filtresi ZORUNLU:** her sorguda `WHERE owner_id = @actorId` — **üç kod yolu ayrıdır** (tasks-liste, tasks-by-id, task-lists) ve **üçü de kapılanır** (`mutant-4`, `mutant-5`, `mutant-15`).
- **Sıralama:** `ORDER BY list_pos, entity_id` (Postgres ASC = **NULLS LAST**; `task_lists` için `pos`). *v1'in `(list_pos IS NULL), …` ifadesi semantik olarak denkti ama ifade-listesi olduğu için indeks sıralamayı karşılayamıyordu.*
- **Keyset — İKİ DALLI [PAZARLIKSIZ]:**
  - imleç yok ⇒ filtresiz;
  - `p != null` ⇒ `((list_pos IS NOT NULL AND (list_pos, entity_id) > (@p, @i)) OR list_pos IS NULL)`;
  - `p == null` ⇒ `(list_pos IS NULL AND entity_id > @i)`.
  *Kolon `COLLATE "C"` implicit collation taşır, parametre taşımaz ⇒ kolonun collation'ı kazanır; sıralama ile filtre tutarlıdır.* Kapısı `mutant-12`, ölçümü D0-c.
- **İMLEÇ SÖZLEŞMESİ:** opak base64url JSON `{"v":1,"p":string|null,"i":uuid}`; yanıtta `nextCursor` (son sayfada `null`). **Ayrıştırılamayan/sürümü tanınmayan imleç ⇒ `400` ProblemDetails, 500 DEĞİL.** Bir test pinler.
- Yanıt DTO'su `malformedFields` ve `hasDeleteEditConflict`'i **açıkça döndürür** (K2-C4).

---

**D5 — İKİ KAPI.**

**ORTAK SENARYO (Persistence.Tests, Docker) — DOKUZ adım:**
1. `title = 'x'` **ve** `notes = 'y'` yazılır; sonra `notes = null` yazılır.
   **ALAN PİNİ [PAZARLIKSIZ]:** bu **durum 2**'dir — register VAR, `HasValue == true`, `Value == null`. `notes`'u hiç **yazmadan bırakmak durum 1**'dir ve kolon yine `NULL`, `malformed_fields` yine `'{}'` olur ⇒ assert **aynen geçer** ama `mutant-14` **hiç ısırmaz** (kapı yeşil ama dişsiz inşa edilir).
2. Grup yazımı → daha **AZ** üyeli grup REPLACE (`{status, completedAt}` → yalnız `{status}`).
3. Tag ekleme → **remove**.
4. `isDeleted:true` + ondan **büyük** damgalı, **yalnız `tags` kanalına** dokunan op (C4 bayrağını çevirir).
5. Ayrıştırılamayan değer: `dueAt = "07/19/2026"`.
6. **Kimliği doğrulanmış B ile** aynı entity'ye op — `SyncAsync(actorB, …)`. **PİN:** tel `actorId` bu adımda **ayırt edici DEĞİLDİR** (F5'ten sonra `owner_id` yalnız `command.ActorId`'den gelir); adım **kimliği doğrulanmış** ikinci actor'la kurulmalıdır, yoksa `mutant-2` **ısırmaz**.
7. **Task Order kanalı:** `listPos` + `boardPos` yaz (biri sonradan değiştirilir).
8. **TaskList:** `name` + `pos` yaz (`pos` Order kanalı), sonra `name`'i değiştir.
9. `isDeleted = "True"` (büyük harfli) yazan bir op + ondan büyük damgalı bir `title` yazımı.

**D5-a — KALICILIK ROUND-TRIP KAPISI.**
Her entity için: `SyncTestApp.HydrateAsync(type,id)` → `TaskProjection.From` / `TaskListProjection.From` → **DB satırıyla alan alan eşit**.
**KARŞILAŞTIRMA PİNİ:** `record ==` **KULLANILMAZ** — sentezlenen `Equals` koleksiyon üyelerinde (`MalformedFields`, `Tags`) **referans eşitliği** kullanır ve test her zaman FAIL eder. Alan alan; koleksiyonlarda `SequenceEqual`.
**BEYAN [ZORUNLU]:** bu kapı **kalıcılık zincirini** ölçer (meta satırları durumu tam yakalıyor mu, tam-satır yazımı bayat kolon bırakıyor mu). **Projeksiyon fonksiyonunun KENDİSİNİ ÖLÇMEZ** — iki taraf da onu çağırır, içindeki her mutasyon iki tarafı birden bozar. Kapıladığı mutant: `mutant-1`.

**D5-b — LİTERAL ORACLE KAPISI [asıl ayırt edici kapı].**
Her adımdan sonra **ham SQL** ile okunan değerler **elle yazılmış literallere** karşı assert edilir. `TaskProjection.From` / `TaskListProjection.From` **ÇAĞRILMAZ**.

| adım | ham SQL assert (literal) | kapıladığı mutant |
|---|---|---|
| 1 | `SELECT title, notes, malformed_fields` ⇒ `'x'`, **`NULL`**, **`'{}'`** *(meşru null malformed DEĞİL)* | `mutant-14` |
| 2 | `SELECT status, completed_at` ⇒ `'done'`, **`NULL`** | `mutant-1` |
| 3 | `SELECT tag FROM task_tags WHERE task_id=@id` ⇒ **boş küme** | `mutant-11` |
| 4 | `SELECT has_delete_edit_conflict` ⇒ **`true`** | `mutant-10` |
| 5 | `SELECT due_at, malformed_fields` ⇒ **`NULL`**, **`{dueAt}`** | `mutant-7` |
| 6 | `SELECT owner_id` ⇒ **actor A** | `mutant-2` |
| 7 | `SELECT list_pos, board_pos` ⇒ yazılan literaller | `mutant-16` |
| 8 | `SELECT name, pos FROM task_lists` ⇒ yazılan literaller | `mutant-16` |
| 9 | `SELECT is_deleted, has_delete_edit_conflict` ⇒ **`false`**, **`false`** *(Ordinal: `"True"` silinmiş DEĞİLDİR)* | `mutant-9` |

**ADIM 7 ve 8 — KANAL KAPISI [v5'te SİMETRİK hâle getirildi]:** ikisi de **`mutant-16` ile gerçek kapıdır**. Gerekçe: `Order → state.Orders` kanal hatası bu kod tabanında **bir kez zaten yaşandı** (v1 Task tarafında kapattı, v2 TaskList tarafında açık bıraktı) ve D5-a bu sınıfa **tanım gereği kördür** (iki taraf da `From`'u çağırır). Kanal hatasını kanıtlanmış şekilde ısıran tek yüzey budur.
> *v4'te adım 7 "mutantsız regresyon önlemi", adım 8 ise `mutant-16` ile kapılıydı. Denetim bu asimetrinin **keyfi** olduğunu gösterdi: `listPos`/`boardPos` ve `pos` **birebir aynı fiziktir** (üçü de Fractional, üçü de `_orders`'ta yaşar) ve Task tarafını koruyan başka hiçbir kapı yoktu — tek fark tarihseldi ("v1 kapatmıştı"), ki bu bir kapı değil bir anıdır. `mutant-16` ikisini birden kapsayacak şekilde genişletildi; mutant sayısı **değişmedi**.*
> *Ayrıca v2 adım 7'yi `mutant-1`'in kapısı sanıyordu; **fiziksel olarak yanlıştı** — op `listPos`'a dokunuyorsa delta yazımı da onu yazar, assert geçer.*
**ADIM 9 NOTU:** `malformed_fields` bu adımda `isDeleted` **İÇERMEZ** (D2 durum tablosu md. 4). *v2 burada `⊇ {isDeleted}` bekliyordu; o beklenti projeksiyona ikinci bir `isDeleted` yüklemi yazmadan üretilemezdi, yani §7'nin ihlaliydi.*
**`owner_id` NOTU:** `owner_id` `TaskProjection`'da **yoktur** (satır kimliğidir) ⇒ D5-a onu hiç karşılaştırmaz; `mutant-2`'nin tek kapısı adım 6'nın literal assert'idir.

---

**D6 — KAPSAM DIŞI ENTITY ÇIPASI [mutantsız].** `Project`/`Tag` op'ları ⇒ hata YOK, üç tabloda **0 yeni satır**. **Beyan:** kapsam çıpasıdır, kapı değildir.

**D7 — SAHİPLİK SAPMASI ÇIPASI [mutantsız].** F5'ten sonra: materyalize `owner_id` = **kimliği doğrulanmış** actor; `outbox_messages.owner_id` = **istemci-beyanlı** `op.ActorId`. Ayrıca okuma API'si ilk-yazan, snapshot her-yazan gösterir. Somut: A yaratır, B düzenler ⇒ B **snapshot'ta görür, okuma API'sinde görmez**; gövdede `actorId=B` gönderen A ⇒ **outbox satırı B'nin, materyalize satır A'nın**. Test bunları **belgeler** (düzeltmez). **Beyan:** kapı değil, sürüklenme çıpası.

**D8 — BACKFILL YOKLUĞU ÇIPASI [mutantsız].** `sync_scalar_meta`'ya ham SQL ile bir entity seed et (yeni op **göndermeden**) ⇒ `GET /v1/tasks` onu **DÖNMEZ**. *Zorunlu kolonlar: `entity_type`, `entity_id`, `field`, `hlc`, `win_operation_id`; `value` nullable. `Wire.EncodeHlc` geçerli HLC üretir.*
**BEYAN [ZORUNLU]:** bu çıpa **tanım gereği totolojiktir** — okuma API'si yalnız `tasks` tablosunu okur, hiçbir üretim mutasyonu bunu kıramaz. Değeri: backfill bir gün eklenirse test kırılır ve karar bilinçli verilir. **Kriter 9'un yerine GEÇMEZ** — kriter 9 "build öncesi mevcut satır sayısı 0 mı", D8 "seed'lenmiş satır okuma API'sinde çıkmıyor mu"; **farklı önermelerdir, ikisi de istenir.**

---

## 5. MUTANTLAR (16 zorunlu) — `KANIT/slice-3a/`

**KANIT KURALI v2.1 [PAZARLIKSIZ]:**
- **Tüm KANIT koşumları `DOTNET_CLI_UI_LANGUAGE=en` ile.** *(`verify.ps1` bu pine tabi DEĞİLDİR.)*
- KANIT'a **HAM koşucu çıktısı YAPIŞTIRILIR**: özet satırı (`Failed!  - Failed: N, Passed: M, Skipped: K, Total: T, Duration: … - X.dll (net9.0)`) + **kırılan testlerin koşucudan kopyalanmış tam adları**. Elle listeleme YOK.
- **Hiçbir karakteri değiştirme** (diakritik katlama / boşluk sıkıştırma **YASAK**).
- Her KANIT: (a) mutasyonun tam diff'i, (b) ham kırmızı çıktı, (c) `git checkout` sonrası **TAM SUITE** yeşil koşumunun ham özeti, (d) `--blame-hang-timeout 120s`.

| # | mutant | mutasyon | ısırması ZORUNLU |
|---|--------|----------|------------------|
| 1 | `mutant-1-materializer-delta-columns` | D3 → yalnız `op`'un dokunduğu **anahtarların** kolonları yazılır (diff pini aşağıda) | **D5-a FAIL + D5-b adım 2 FAIL** |
| 2 | `mutant-2-owner-overwritten` | D3 → `DO UPDATE SET`'e `owner_id` eklenir | **D5-b adım 6 FAIL** |
| 3 | `mutant-3-owner-from-wire-actor` | D3 → `ownerId` yerine `op.ActorId` | **D0-b adım 4 FAIL** |
| 4 | `mutant-4-list-drops-owner-filter` | `TaskReadStore` tasks-liste sorgusundan `WHERE owner_id` kaldırılır | **D0-b adım 2 FAIL** |
| 5 | `mutant-5-byid-drops-owner-filter` | `TaskReadStore` tasks-by-id sorgusundan `WHERE owner_id` kaldırılır | **D0-b adım 3 FAIL** |
| 6 | `mutant-6-position-no-collate` | D1 → konum kolonları + `tag` `COLLATE "C"`'siz | **D3b FAIL** *(davranışsal ısırma D3b ölçümüne bağlı)* |
| 7 | `mutant-7-lenient-datetime-parse` | D2 → `TryParseExact` yerine `TryParse` | **D5-b adım 5 FAIL** |
| 8 | `mutant-8-datetime-assume-local` | D2 → `AssumeUniversal` kaldırılır | **D2d FAIL** *(ortam-bağımlı; `TimeZoneInfo.Local.Id`'yi KANIT'a yaz)* |
| 9 | `mutant-9-isdeleted-lenient-parse` | D2a → Ordinal eşitlik yerine `bool.TryParse` | **D5-b adım 9 FAIL** |
| 10 | `mutant-10-conflict-flag-constant-false` | D2 → `HasDeleteEditConflict` yerine sabit `false` | **D5-b adım 4 FAIL** |
| 11 | `mutant-11-tags-ignore-cancelled` | D2 → `PresentElements()` yerine `DumpTags()`'ten filtresiz liste | **D5-b adım 3 FAIL** |
| 12 | `mutant-12-keyset-drops-null-block` | `TaskReadStore` → `p != null` dalından **yalnızca `OR list_pos IS NULL`** kaldırılır (bu, `p == null` dalını doğal olarak ölü kılar) | **D0-c FAIL** (6 yerine **3 id**) |
| 13 | `mutant-13-registry-enumeration-not-live` | `_entities`'e bir alan eklenir (`Task` `Scalars` → `"zzzTemp"`) **VE** `DescribeFieldKeys` donmuş/sabit liste döndürür | **D2b'nin CANLILIK assert'i FAIL** |
| 14 | `mutant-14-null-counts-as-malformed` | D2 → durum 2 (meşru `null`) malformed sayılır | **D5-b adım 1 FAIL** |
| 15 | `mutant-15-tasklists-drops-owner-filter` | `TaskReadStore` task-lists sorgusundan `WHERE owner_id` kaldırılır | **D0-b adım 5 FAIL** |
| 16 | `mutant-16-order-channel-read-from-fields` | D2 → **HEM** `TaskProjection.ListPos`/`BoardPos` **HEM** `TaskListProjection.Pos`, `state.Orders` yerine **`state.Fields`'ten SAVUNMACI okunur** (diff pini aşağıda) | **D5-b adım 7 FAIL + adım 8 FAIL** *(kolonlar sessizce NULL)* |

**`mutant-16` DİFF PİNİ [PAZARLIKSIZ — v5'in düzeltmesi]:** mutasyon **SAVUNMACI okuma** olarak ve **her iki projeksiyonda birden** yazılır:
```csharp
// mutant-16: Order kanalını YANLIŞ sözlükten oku (Orders yerine Fields), ama İNDEKSLEYİCİYLE DEĞİL
state.Fields.TryGetValue(name, out var r) && r.HasValue ? r.Value : null
// name ∈ { "listPos", "boardPos" }  (TaskProjection)  ve  { "pos" }  (TaskListProjection)
```
*Gerekçe (ölçüldü):* `EntityState._fields`'e **yalnız** `ApplyField` (op'un `Fields` kanalı) ve `LoadField` (registry `ScalarLww`) yazar (`EntityState.cs:26-27,50`); `Task.listPos`/`boardPos` (`FieldStrategyRegistry.cs:143`) ve `TaskList.pos` (`:158`) **Fractional**'dır ⇒ hidrasyonda `LoadOrder`'a (`SyncRowHydration.cs:35-37`), ingest'te `ApplyOrder`'a (`ConflictResolver.cs:21-24`) gider ⇒ **`_fields`'te `"pos"` anahtarı HİÇ OLUŞMAZ**. Dolayısıyla `state.Fields["pos"]` **indeksleyicisi `KeyNotFoundException` FIRLATIR**; istisna materyalizasyondan `ProcessOpAsync`'e sızar (orada try/catch YOK), `scope` commit edilmeden dispose olur ⇒ **txn geri alınır**, `/v1/sync` 500 döner ve `task_lists` satırı **hiç yazılmaz**. O hâlde adım 8 "sessiz NULL" yüzünden değil **istisna** yüzünden kırılır — spec'in iddia ettiği ısırma yüzeyi bu DEĞİLDİR ve senaryonun kalanına cascade eder. Savunmacı okuma kanal hatasının gerçek üretim biçimini (sessiz NULL) taklit eder.

**`mutant-1` DİFF PİNİ [PAZARLIKSIZ]:** "dokunulmuşluk" **anahtar düzeyindedir** — `op.Fields` ∪ `op.Order` anahtarları + `op.Groups[g].Fields` **üye** anahtarları. Aksi hâlde ısırma builder'ın mutasyon yorumuna kalır.

**`mutant-13` DİFF PİNİ [PAZARLIKSIZ — v5'in düzeltmesi]:** mutasyon **iki değişikliktir ve İKİSİ BİRDEN uygulanır** (tek koşum, tek kırmızı):
1. `_entities`'e bir alan ekle — `Task` `Scalars`'a `"zzzTemp"` (`FieldStrategyRegistry.cs:141`);
2. `DescribeFieldKeys`'i **donmuş** (mutasyon öncesi) sabit listeye çevir.
**Beklenen:** D2b'nin **CANLILIK assert'i** kırılır (reflection `zzzTemp`'i görür, donmuş liste görmez). *Üç-kova assert'i de kırılır — KANIT'ın kırılan-test listesi ikisini de gösterecektir; kapının canlılığı ölçen ayağı **canlılık assert'idir**.*

> **NEDEN İKİ DEĞİŞİKLİK BİRDEN [dürüstlük notu]:** "Yalnız `DescribeFieldKeys`'i sabit listeye çevir" biçimindeki tek-parçalı mutasyon, bugünkü registry üzerinde **davranışsal olarak EŞDEĞER bir mutanttır** (donmuş liste = canlı liste) ve hiçbir test onu ayırt edemez. Eşdeğer mutantlar mutasyon testinde **muafiyetle değil, kapsam dışı bırakılarak** ele alınır — bu yüzden mutasyon registry'nin değiştiği bir dünyada tanımlanır ve orada **gerçekten ısırır**. *v2/v3/v4 bunu "öldürülemez, hayatta kalan mutant" diye ADLANDIRILMIŞ MUAFİYET'e bağlamıştı; denetim gösterdi ki iddia **YANLIŞTI** — canlılık assert'i onu öldürebiliyor. Muafiyet kaldırıldı; "kör kapı yok" doktrininde delik yoktur.*
- **Yan hasar uyarısı:** `"zzzTemp"` adı `RegistryProperty.cs:35`'in bilinmeyen-alan vakasıyla (`"foo"`) çakışmaz ve Oracle rastgele üretimde çıkmaz ⇒ koşum **izole, yalnız D2b kırmızısı** verir. *(Alanı yeniden ADLANDIRAN bir varyant seçme — Oracle kendi ayna registry'sini taşır (`OracleEngine.cs:539`, `Scenario.cs:79`) ve `OracleDiffProperty` de kırmızıya döner, izolasyon bozulur.)*

**Bir mutant ısırmıyorsa testi ZAYIFLATMA — bu testin değil SPEC'in kusurudur, DUR ve bildir. İstisna YOKTUR.**

**İLK MUTANTTA DİL PİNİNİ DOĞRULA:** `mutant-1`'i koşarken `DOTNET_CLI_UI_LANGUAGE=en` altında İngilizce özet satırının **gerçekten basıldığını GÖR**. Basılmıyorsa DUR ve bildir.

**Maliyet uyarısı:** KANIT kuralı (c) her mutant için TAM SUITE yeşil koşum istiyor; Persistence.Tests ~1 dk 31 sn. **16 mutant**, her biri tek koşum. Docker'sız koşabilenler: **8, 13** (`SyncCore.Tests`) — belirgin şekilde ucuzdur, ayrı grupla. *`mutant-9`'un ve `mutant-14`'ün kapıları D5-b'dedir, yani **Docker gerektirir**; v2 mutant-9 için var olmayan bir "birim ayağı"na atıf yapıyordu.* Bu maliyet **bilinçli kabul edilmiştir**.

## 6. Kabul kriterleri

1. Build `-warnaserror` **0/0**.
2. **Mevcut 85 test yeşil — İKİ adlandırılmış istisna:** (i) `SchemaTests`'e D3b'nin **YENİ** `[Fact]`'i; (ii) **`SchemaTests.cs:20` (`ModelValidationTests`) `ShouldBe(7)` → ölçülen değer (beklenen `10`)** ve test adının güncellenmesi. Başka hiçbir mevcut test değiştirilemez; yeni testler ayrı sayılır.
3. **D0'ın KIRMIZI-ÖNCE ham çıktısı** (üç test için de) KANIT'ta. Bu olmadan dilim kabul EDİLMEZ.
4. **16 mutant**, KANIT KURALI v2.1'e birebir uygun; **her biri tek koşumda ham kırmızı üretir, istisna yoktur**. Temiz ağaçta kalıntı yok.
5. **Domain değişikliği SINIRLI:** (a) yeni `Sync/Projection/*`, (b) `FieldStrategyRegistry.DescribeFieldKeys` (additive), (c) `EntityState.IsDeleted` + `HasDeleteEditConflict`'in D2a'daki **birebir pinli** gövdeye sadeleşmesi. Başka Domain dosyası değişirse **DUR ve Cowork'e sor**.
6. **Dosya beklentisi — önceden sayıldı.**
   **(a) DEĞİŞECEK mevcut dosyalar:** `SyncCommandHandler.cs` · `DependencyInjection.cs` · `SyncDbContext.cs` · `SyncEntities.cs` · `Configurations/SyncConfigurations.cs` · `Program.cs` · `EntityState.cs` · `FieldStrategyRegistry.cs` · `SchemaTests.cs` · **`Persistence/Migrations/SyncDbContextModelSnapshot.cs`** *(`dotnet ef migrations add` bunu HER ZAMAN yeniden üretir — listede olmasaydı garantili "sapma" sayılırdı)*.
   **(b) EKLENECEK yeni dosyalar:** `Domain/Sync/Projection/TaskProjection.cs` + `TaskListProjection.cs` · `Application/Abstractions/Sync/IEntityMaterializer.cs` · `Application/Abstractions/Sync/ITaskReadStore.cs` · `Application/Features/Tasks/*` (query + handler + DTO) · `Infrastructure/Sync/EntityMaterializer.cs` · `Infrastructure/Sync/TaskReadStore.cs` · `Api/Endpoints/TaskEndpoints.cs` + `TaskListEndpoints.cs` · yeni migration (+ `.Designer.cs`) · yeni test dosyaları — **D2a'nın deterministik `deleteKey` assert'i YENİ bir test dosyasına girer** (mevcut `DeleteEditConflictTests.cs`'e eklenirse kriter 6(a) ihlali olur).
   **Sapma = bu iki listenin dışına çıkan her dosya.**
7. `araclar/verify.ps1` **DEĞİŞMEDEN** geçer (Docker açık), exit 0.
8. CVE temiz; sır yok; `PROJE_HAFIZA`/`docs/ADR` **dokunulmamış**; `bin/obj` ignore.
9. **Backfill ölçümü:** build'e başlamadan `sync_scalar_meta` + `sync_orset_tags` satır sayısını ölç, rapora yaz. **0 değilse DUR ve Cowork'e bildir.** *(D8 çıpası bunun yerine geçmez — bkz. D8.)*
10. **D3b collation ölçümü** (`SHOW lc_collate` + davranışsal örnek) rapora **ham**.
11. **D2d'nin `TimeZoneInfo.Local.Id` kaydı** KANIT'ta.
12. **EF entity tipi sayımı ölçüldü** (kriter 2'nin `ShouldBe(10)`'u varsayım değil ölçüm).

## 7. Kırmızı çizgiler

Sır repoya girmez · **yeni bağımlılık YOK** · `DateTime.UtcNow`/`DateTimeOffset.UtcNow` üretimde yasak · SQL `now()` yasak · **SQL yalnız SUNUM SIRALAMASI yapabilir; kazanan seçimi / damga karşılaştırması / çakışma kararı SQL'e GİRMEZ** · **`HasDeleteEditConflict`, `IsDeleted`, aktif-eleman kümesi ve ayrıştırma kurallarının BİRER implementasyonu vardır ve hepsi Domain'dedir** · ayrıştırmada **`CultureInfo.InvariantCulture` zorunlu**, `CurrentCulture`/`ToLower()`/`ToUpper()` yasak; sıralamada `StringComparer.Ordinal` · `task_tags`'te FK yok · **`owner_id` geçici politikadır** · **testi mutanta uydurmak için zayıflatmak yasak** · `SyncPuller`/`SyncStore`/`OrSetField`/outbox davranışına **dokunulmaz** · **sınırsız `while` ile sayfalama testi yazılmaz**.

## 8. Teslim protokolü

1. `araclar/verify.ps1` (Docker açık) — TÜM çıktı rapora.
2. Commit (ASCII): `feat(read): materialize task and task_list rows + read api (ADR 0002 K2-I2/I3)`. **Push YAPMA** (Cowork).
3. Rapor: (a) test sayıları (85 + yeni), (b) **D0 ayrı başlık: üç testin kırmızı-önce + yeşil-sonra ham çıktısı**, (c) verify exit, (d) 16 mutant KANIT yolu + kırılan-test listeleri (**mutant-13'ün iki-değişiklikli diff'i + hangi assert'in canlılığı ölçtüğü**), (e) Domain diff + kriter 6'nın iki listesinin dışına çıkan her dosya, (f) sapma/varsayım TAM listesi, (g) D3b collation ölçümünün ham çıktısı + `mutant-6`'nın ısırma yüzeyinin dürüst tarifi, (h) `mutant-8`'in ortam-bağımlılığı + `TimeZoneInfo.Local.Id`, (i) D2c/D6/D7/D8'in "mutantsız çıpa/regresyon önlemi" beyanları, (j) **D5-a'nın "projeksiyon fonksiyonunu ölçmez" beyanı**, (k) kriter 9'un backfill ölçümü, (l) `.FFFFFFF` kesirsiz-girdi ölçümü, (m) EF entity sayımı ölçümü.

## 9. DENETİMDE KIRILAMAYAN NOKTALAR (yeniden denetlenmesin)

Üç tur boyunca **kırılmaya çalışılıp kırılamayan** noktalar:
- **İki dallı keyset tarifi DOĞRU** — 3 non-NULL + 3 NULL, `limit=2` elle simüle edildi; sayfa sınırı tam geçişe denk geldiğinde bile 6 farklı id, atlama/tekrar yok. Parametre collation'ı kolonunkini ezmez.
- **`ORDER BY list_pos, entity_id` sıralamayı DEĞİŞTİRMEZ** — Postgres ASC = NULLS LAST; v1'in ifadesiyle denk, keyset dallarıyla tutarlı.
- **Materyalize satır ↔ hydrate ayrışması bulunamadı** — adds-önce-removes sırası Domain ve kalıcılıkta aynı; `UpsertTagAsync`'in `GREATEST`'i `MergeStamp` ile aynı kuralı uygular; grup REPLACE'in üye DELETE'i marker-güdümlü hydrate ile tutarlı. Materyalizasyon patlarsa aynı `scope`'ta olduğu için **ikisi de geri alınır**.
- **`EntityState` public API'si projeksiyon için YETERLİ** — üç-durum ayrımı (`TryGetValue` / `HasValue` / `Value == null`) tam kurulabiliyor.
- **D4 katman zinciri arch Rule 1/2/3/4'ü GEÇER**; mediator handler keşfi otomatiktir, ek kayıt gerekmez.
- **`ProcessOpAsync` imza değişikliği güvenli** — tek çağıran `SyncCommandHandler.cs:55`, metot `private`.
- **`ON CONFLICT DO UPDATE SET`'ten `owner_id`'yi çıkarmak ilk-yazan etkisini gerçekten verir.**
- **`text[]` Npgsql parametre yazımı üretimde kanıtlı** (`SyncStore.cs:106`). *Okuma yönü (`Db.ScalarAsync<string[]>`) muhtemelen çalışır ama **kanıtlanmadı** — builder ilk kullanımda doğrulasın.*
- **BannedApiAnalyzers takılmaz** — `BannedSymbols.txt` yalnız `Now`/`UtcNow`/`Today` **property**'lerini yasaklar.
- **"Mevcut 85 test" sayımı DOĞRU** (arch 5 + Api 12 + SyncCore 33 + Persistence 35; Theory yok; ham grep'teki 86'nın biri `SchemaTests.cs:75`'te **yorum içindeki** `[Fact]`).
- **`verify.ps1` değişmeden geçer** (`.sln` üzerinden koşar, yeni proje eklenmez).
- **`mutant-4/5/6/7/10/11/12` ısırır** — tek tek zihinsel mutasyonla doğrulandı.
- **`mutant-3` / D0-b adım 4 inşa edilebilir** — `SyncAsync(actorId, request)` kimliği doğrulanmış actor'ı gövdeden ayrı alır.

## 10. AÇIK BULGULAR (Cowork → Onur)

**BULGU-A — Registry'de `Task` → `TaskList` bağı YOK.** **Onur kararı (19 Tem 2026): 3b proje bazında gruplar; bağ İCAT EDİLMEZ** (F6). Bağ ileride istenirse ADR errata gerekir.

**BULGU-B — `mutant-6`'nın ısırma yüzeyi ölçülmemiştir.** Teknik denetimin tahmini: musl `strcoll` ≈ `strcmp` ⇒ **ayrışmayacak** ⇒ `COLLATE "C"` bu ortamda **savunma-derinliğidir**, davranışsal kapı değildir (2b1 BULGU-2 dersi). D3b ölçüme bağladı.

**BULGU-C — `outbox_messages.owner_id` doğrulanmamıştır ve bu dilim onu düzeltmez.** F5 yalnız materyalize satırı temizler; auth dilimi iki yolu birleştirmelidir. D7 sapmayı görünür tutar.

**BULGU-D — `task_lists` bu dilimde bağlantısız bir tablodur.** Materyalize edilir, okunur, kapılanır; ama hiçbir görevle ilişkilendirilemez (BULGU-A). ADR K2-I2'nin "Task + TaskList" pini korunmuştur, işlevsel değeri BULGU-A çözülene dek sınırlıdır.

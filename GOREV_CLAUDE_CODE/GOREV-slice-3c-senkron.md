# GÖREV (Claude Code) — slice-3c: senkron kuyruğu + `POST /v1/sync` (K42-d adım 3)  [v2]

> **v2 — iki bağımsız denetçinin bulgularıyla yeniden yazıldı.** v1 (`5899A220`) **GEÇERSİZDİR.**
> Kırılan yerler: `actorId` kilitsizdi · alan/grup yazımlarının kendi HLC'si spec'te yoktu ·
> `durum='gonderildi'`in çıkışı yoktu · sunucu HLC clamp'i hiç anılmamıştı · `G6` sunucudaki
> **içeriği** hiç ölçmüyordu · `M13` eşdeğer mutanttı · `M14`'ün "DB'de kopya" iddiası **olgusal olarak
> yanlıştı** (`tasks` upsert'tir) · atomiklik kuralı kapısızdı · `M5b` numaralandırma dışındaydı.

## 0. Önce oku

`DURUM.md` (canlı durum) · `CLAUDE.md` (kalıcı kurallar). `PROJE_HAFIZA.md`'yi **açma** — append-only arşivdir.
Bu spec **kilitlidir**: §3'teki `D0`–`D9` kararları ve §5'teki `G1`–`G8` kapıları **pazarlığa kapalıdır**.
Bir karar yanlışsa **kodla değil, Onur'un kilidiyle** değişir: bulguyu §10'a yaz, dur, sor.

**Yürüyen iskelet önce (K53 madde 5):** önce en küçük çalışan şey — bir op üretilir, kuyruğa yazılır,
sunucuya gider, `Applied` döner, kuyruktan silinir. Kapılar bu koşan şeyin **üstüne** kurulur.

---

## 1. ÖLÇÜLMÜŞ ZEMİN — yeniden keşfetme; doğrula ve geç

Aşağıdaki her satır **oturum 32'de gerçek dosyadan okundu** ve **iki bağımsız denetçi tarafından
yeniden ölçüldü**. Yeniden tasarlama; doğrula ve kullan.

### 1.1 Backend senkron yüzeyi HAZIR — tek satırı yeniden yazılmayacak
| ne | nerede | ölçülen |
|---|---|---|
| uç nokta | `Momentum.Api/Endpoints/SyncEndpoints.cs` | `MapPost("/sync")`, grup `/v{version:apiVersion}`, `ApiVersion(1,0)` |
| 401 yolu | aynı dosya | `if (currentUser.UserId is not { } actorId) return Results.Unauthorized();` |
| yapısal doğrulama | `SyncRequestValidator.cs` | `Ops` **NotNull** · `Ops.Count <= 100` · `SinceCursor.Seq >= 0` — **başka hiçbir şey** |
| sözleşme | `SyncContracts.cs` | `SyncRequest(ClientId, ClientHlc, SinceCursor, Ops)` · `WireOp(OperationId, ClientId, EntityId, ActorId, EntityType, OpHlc, Fields, Sets, Groups, Order)` · `WireHlc(WallMs, Counter, ClientId)` · `WireCursor(Xid, Seq)` |
| **alan/grup yazımı** | `SyncContracts.cs` | `WireFieldWrite(string? Value, WireHlc Hlc)` · `WireGroupWrite(IReadOnlyDictionary<string,string?> Fields, WireHlc Hlc)` — **her yazımın KENDİ HLC'si vardır** |
| zarf geçerliliği | `Domain/Sync/SyncIngest.cs` | `OperationId`, `ClientId`, `EntityId`, **`ActorId`** — dördü de **boş GUID olamaz**; biri boşsa `RejectedInvalid` |
| sonuç kodları | `Domain/Sync/Envelope/IngestResult.cs` | `Applied` · `Duplicate` · `RejectedRegistryViolation` · `RejectedAbsurdHlc` · `RejectedSetCapExceeded` · `RejectedInvalid` |
| kod biçimi | `WireMapping.cs` | `result.Code.ToString()` ⇒ **PascalCase** (`"Applied"`). `JsonSerializerDefaults.Web` yalnız **anahtarları** camelCase yapar, **değerleri değil** |
| yanıt | `SyncContracts.cs` | `SyncResponse(ServerHlc, NextCursor, HasMore, ResyncRequired, Applied, Changes, Snapshot)` · `WireIngestResult(OperationId, Code, EffectiveOpHlc)` |
| saat kırpma | `Domain/Sync/HlcClamp.cs` | `MaxForwardSkewMs = 300_000` (**5 dk**) · `AbsurdForwardMs = 31_536_000_000` (**365 gün**) |
| materyalizasyon | `Infrastructure/Sync/EntityMaterializer.cs` | `INSERT INTO tasks … ON CONFLICT (entity_id) DO UPDATE SET …` — **`tasks`'ta kopya satır DOĞAMAZ** |

**JSON camelCase'dir; HLC bir nesnedir:** `{"wallMs":…, "counter":…, "clientId":"…"}`.

### 1.2 `Task` alan kayıt tablosu (`FieldStrategyRegistry.BuildDefault`) — **Ordinal, büyük/küçük harf duyarlı**
- **scalar (`Fields`):** `title` · `notes` · `priority` · `dueAt` · `remindAt` · `projectId` · `isDeleted` · `recurrenceRule`
- **grup (`Groups`):** `completion` → üyeleri `status`, `completedAt`
- **OR-Set (`Sets`):** `tags` · `assignees` · `checklistItems` — **bu dilimde kullanılmaz**
- **fractional (`Order`):** `listPos` · `boardPos` — **bu dilimde kullanılmaz**

`IsOperationValid` **bütün op'u** reddeder: bilinmeyen `entityType`, bilinmeyen alan, ya da **yanlış kanal**
⇒ `RejectedRegistryViolation`. **Remap YOKTUR** (ADR H11). Yani `tamamlandi`'yı `Fields`'e koymak
"biraz yanlış" değil, **op'un tamamının çöpe gitmesidir**.

### 1.3 Değer biçimleri — ÖLÇÜLDÜ, VARSAYILMADI
| alan | biçim | kaynak (ölçülen dosya) |
|---|---|---|
| `isDeleted` | **tam olarak `"true"`** (Ordinal eşitlik) | `State/EntityState.cs`: `DeletedValue = "true"`, `StringComparison.Ordinal` |
| `completedAt` | `yyyy-MM-dd'T'HH:mm:ss.FFFFFFFK` **veya** `yyyy-MM-dd'T'HH:mm:ssK` — `TryParseExact` | `Projection/ProjectionFields.cs`: `IsoFormats` |
| `status` | **serbest metin, sunucu YORUMLAMAZ** | `ProjectionFields.ReadGroupText` |

🔴 **`"True"`, `"TRUE"`, `" true"` SİLİNMİŞ SAYILMAZ** ve **reddedilmez de** — sessizce yanlış veri üretir.

🔴 **`F` (büyük) OPSİYONEL basamaktır**, `f` (zorunlu) değil. Dart'ın `toIso8601String()` çıktısı (3 veya
6 basamak + `Z`) her iki biçimce de kabul edilir. **ASIL TEHLİKE BAŞKA:** `DateTimeStyles.AssumeUniversal`
yüzünden **offset'siz** bir damga (`"2026-07-27T13:20:30.123456"` — `.toUtc()` unutulmuş yerel saat)
**reddedilmez**, sessizce UTC sayılır ⇒ Türkiye'de **3 saat kayma**, `malformed_fields`'e bile düşmez.

🔴 **GRUP YAZIMI REPLACE'TİR.** `WireGroupWrite.Fields` kazanırsa grubun **tamamı** o sözlükle değişir;
yazmadığın üye **kaybolur** (`ProjectionFields`: *"member absent from the winning REPLACE"*).
Bu yüzden `completion` yazılırken **`status` ve `completedAt` DAİMA BİRLİKTE** yazılır.

🔴 **`status`'ü SUNUCU YORUMLAMAZ.** İstemci `"done"` yerine `"tamamlandi"` yazsa **hiçbir sunucu kapısı
kırmızı yanmaz** ve slice-3d'de tüm tamamlanma durumu bozuk çıkar ⇒ değer **istemci sözleşmesidir** ve
`D2`'de pinlenir, `G2`'de **tam dize** olarak ölçülür.

### 1.4 Sunucu davranışı — kuyruk politikasını belirleyen beş ölçüm
1. **`Duplicate` çalışıyor.** `SyncCommandHandler.ProcessOpAsync` önce `IProcessedOperations.GetAsync`
   ile DB dedup yapar ⇒ kuyruk **at-least-once** gönderebilir, tekrar zararsızdır.
2. **`RejectedInvalid` dedup'a KAYDEDİLMEZ** (kodda `// ERRATA`) ⇒ aynı op **sonsuza dek** reddedilir.
   Yeniden deneme bunu **asla** çözmez ⇒ karantina zorunludur (`D5`).
   *(Diğer `Rejected*` kodları **kaydedilir**; yalnız `RejectedInvalid` kaydedilmez.)*
3. **Sahiplik ve çekme actorId'ye bağlıdır:** `MaterializeAsync(…, authenticatedActorId, …)` ve
   `SnapshotAsync(command.ActorId)` / `PullIncrementalAsync(command.ActorId, …)` ⇒ dev kimliğin ürettiği
   `UserId` oturumlar arasında **KARARLI** olmak zorundadır.
4. **Outbox `op.ActorId`'den beslenir:** `OwnerId: op.ActorId, ActorId: op.ActorId`. `WireOp.ActorId`
   yanlış bir GUID taşırsa `tasks` **doğru** yazılır ama outbox olayları **yanlış aktöre** etiketlenir —
   bu dilimde görünmez, slice-3d'nin yönlendirmesinde patlar (`D7`).
5. **Her HLC clamp'lenir.** `SyncIngest` op/alan/grup HLC'lerinin **her birini** önce absürtlük için
   sınar, sonra `serverReceiveWall + 5dk` tavanına **kırpar**. İstemci bunu bilmezse `D3`'teki sessiz
   kayıp senaryosu doğar.

### 1.5 İstemci yüzeyi (ölçüldü)
`src/client/lib/veri/veritabani.dart` — **tek tablo `Gorevler`**: `id` (TEXT, PK) · `baslik` ·
`tamamlandi` · `olusturuldu` · `guncellendi` · `senkronDurumu` (CHECK: **yalnız `'yerel'`**) · `silindi`.
`schemaVersion = 1` · `storeDateTimeAsText: true` · **`MigrationStrategy` override'ı YOK** (drift'in
varsayılan `onUpgrade`'i sürüm artınca **fırlatır**).
`GorevDeposu` arayüzü + `DriftGorevDeposu` (`saat`, `idUret` **enjekte edilebilir**).

🔴 **Rozet dikişi YOK ve adı da farklı:** enum `senkron_rozeti.dart`'ta **`SenkronDurumTuru`**
(`yerel · kuyrukta · senkronize · cevrimdisi` — **`cakisma` ÜYESİ YOK**); `GorevSatiri` ayrıca
`bool cakismaVarMi` alır; `gorev_listesi_ekrani.dart` bu iki parametreyi **HİÇ GEÇMİYOR**.
`Gorev.senkronDurumu` alanından rozete giden bağlantı **yoktur** — `D5` onu kurar.

🔴 **Mevcut testler GUID üretmiyor:** `veri_kapisi_test.dart` → `idUret: () => 'test-id-${idSayaci++}'`.
Tel sözleşmesinde bu alanlar `Guid`'dir ⇒ böyle bir id **400** aldırır (`D7`).

**Kuyruk tablosu YOK** — bu dilimde doğacak.

---

## 2. Kapsam — NE VAR / NE YOK

### VAR
1. **Dev-kimlik kalkanı** (`Development`'a hapsedilmiş) — `D0`.
2. **`senkron_kuyrugu` tablosu** + migration `v1 → v2` — `D1`.
3. **`WireOp` üreteci** (kanal eşlemesi + zarf + her yazımın HLC'si) — `D2`, `D7`.
4. **Monoton + TAVANLI HLC**, kalıcı `clientId`, sunucu damgasıyla birleştirme — `D3`.
5. **Toplu gönderim (`≤ 100`), tek uçuş, sonuç işleme, yanıt sınıflandırması** — `D4`, `D5`, `D9`.
6. **İmleç kalıcılığı + `resyncRequired`** — `D6`.
7. **Atomiklik + çökme kurtarma** — `D8`.
8. **Sekiz kapı `G1`–`G8` + otuz altı mutant `M1`–`M36`**, hepsi KANIT'lı.

### YOK — bu dilimde YASAK
- ❌ **Çekme (pull) uygulanması.** `changes`/`snapshot` Drift'e **YAZILMAZ** (`D6`) → slice-3d.
- ❌ **SignalR / gerçek zamanlı** → K42-d adım 4.
- ❌ **OR-Set, fractional index, `notes`/`priority`/`dueAt`/`projectId`** — registry'de var, bu dilimde **gönderilmez**.
- ❌ **Gerçek kimlik doğrulama.** ADR 0003 **DONDURULMUŞ** (K41); `DevCurrentUser` bir **ölçüm iskelesidir**.
- ❌ **`DESIGN.md`'ye tek bayt** (K46).
- ❌ **Backend senkron çekirdeğine dokunmak.** `SyncIngest`/`SyncCommandHandler`/`FieldStrategyRegistry`
  **okunur, değiştirilmez**. İzinli tek istisna: `Program.cs`'e `D0`'ın koşullu kaydı **ve** onun
  gerektirdiği `AddHttpContextAccessor()` satırı.

---

## 3. KİLİTLİ TASARIM KARARLARI

### `D0` — Dev-kimlik kalkanı, ortama hapsedilmiş
`DevCurrentUser`, `ICurrentUser`'ı uygular; `UserId`'yi **`X-Momentum-Dev-User`** başlığındaki GUID'den okur.
- Kayıt **yalnız** `builder.Environment.IsDevelopment()` doğruyken; aksi hâlde `NullCurrentUser` kalır.
- Başlık **yok, boş ya da GUID değilse ⇒ `UserId = null`** ⇒ 401. **Sessiz varsayılan kullanıcı ÜRETİLMEZ.**
- `UserId` (kişi) ⟂ `ClientId` (cihaz). İstemci **iki ayrı** değer taşır.
- `Program.cs`'e `AddHttpContextAccessor()` eklenmesi bu kararın **parçasıdır** ve §2'nin izinli istisnasına dâhildir.
- Başlığın değeri **koda gömülmez**; testler kendi GUID'ini üretir.

### `D1` — `senkron_kuyrugu` tablosu; gövde ÜRETİM ANINDA donar
| sütun | tip | not |
|---|---|---|
| `opId` | TEXT, **PK** | **UUID v4** (`uretimIdUret()` biçimi), sunucudaki dedup anahtarı |
| `clientId` | TEXT | cihazın kalıcı GUID'i (`D3`) |
| `entityType` | TEXT | bu dilimde daima `Task` |
| `entityId` | TEXT | `Gorevler.id` |
| `govdeJson` | TEXT | **tam `WireOp` JSON'u**, üretim anında donmuş |
| `hlcWallMs` | INT | sıralama (`D3`) |
| `hlcCounter` | INT | sıralama (`D3`) |
| `durum` | TEXT | CHECK: `bekliyor` · `gonderildi` · `zehirli` |
| `denemeSayisi` | INT | varsayılan 0; tavanı `D9`'da |
| `sonHataKodu` | TEXT? | sunucu kodu ya da ağ hatası etiketi |
| `olusturuldu` | DATETIME | UTC |

🔴 **`govdeJson` GÖNDERİM ANINDA YENİDEN ÜRETİLMEZ.** Op değişmezdir; yeniden üretmek HLC damgasını
ileri kaydırır ve CRDT sıralamasını sessizce bozar.

🔴 **OKUMA SIRASI `(hlcWallMs, hlcCounter, opId)` ARTAN.** Üçüncü anahtar **pazarlıksızdır**: sunucu
clamp'i iki damgayı eşitleyebilir (`D3`); tie-break'siz sıralamada SQLite'ın döndürdüğü sıra
**koşumdan koşuma değişir**.

**Migration `v1 → v2`:** tabloyu ekler **ve** `Gorevler.senkronDurumu` CHECK kısıtını
`'yerel' · 'kuyrukta' · 'senkronize' · 'cakisma' · 'cevrimdisi'` olarak genişletir.
🔴 SQLite bir CHECK kısıtını `ALTER TABLE` ile **değiştiremez** ⇒ drift'te `Migrator.alterTable(TableMigration(...))`
ile tablo **yeniden yaratılır**, veri `columnTransformer` olmadan kopyalanır. `MigrationStrategy` bu dilimde doğar.

### `D2` — Kanal eşlemesi (registry'ye BİREBİR uyar)
| istemci alanı | kanal | anahtar | değer |
|---|---|---|---|
| `baslik` | `Fields` | `title` | metin |
| `silindi` | `Fields` | `isDeleted` | **`"true"` / `"false"`** — tam bu iki dize, Ordinal |
| `tamamlandi` | **`Groups`** | `completion` | `{"status": …, "completedAt": …}` — **iki üye DAİMA birlikte** |
| `olusturuldu` | — | — | **GÖNDERİLMEZ** (registry'de yok ⇒ tüm op reddedilir) |
| `guncellendi` | — | — | **GÖNDERİLMEZ** (aynı sebep) |
| `senkronDurumu` | — | — | **GÖNDERİLMEZ** — yerel görüntüleme alanıdır |

- `entityType` = **`"Task"`** (Ordinal; `"task"` reddedilir).
- `status` ∈ **{`"done"`, `"open"`}** — tam dize, Ordinal. Sunucu yorumlamaz; sözleşme **buradadır**.
- `completedAt` = `tamamlandi` ise `saat().toUtc().toIso8601String()`, değilse `null`.
  🔴 **`.toUtc()` PAZARLIKSIZDIR** — düşürülürse damga sessizce 3 saat kayar (§1.3).
- Her op **en az bir kanal** taşır; **boş op üretilemez** (sunucuda `RejectedInvalid` ⇒ kalıcı zehir).

### `D3` — HLC: monoton, KALICI ve TAVANLI; sunucu damgasıyla birleşir
```
sonrakiHlc(now):
  tavan   = now + 300000            // HlcClamp.MaxForwardSkewMs ile AYNI değer
  wall    = min(max(now, sonWall), tavan)
  counter = (wall == sonWall) ? sonCounter + 1 : 0
  sonWall, sonCounter = wall, counter
  return WireHlc(wall, counter, clientId)

yanitIsle(serverHlc, effectiveOpHlc):        // her senkron turundan sonra
  for h in [serverHlc, effectiveOpHlc]:
     if h != null and h.wallMs > sonWall: sonWall, sonCounter = h.wallMs, h.counter
```
🔴 **TAVAN NEDEN PAZARLIKSIZ (ölçülmüş senaryo):** cihaz saati 6 dk ileriyken çevrimdışı iki ardışık
başlık düzenlemesi yapılır ve **aynı istekte** gider. Sunucu ikisini de `receiveWall + 5dk`'ya kırpar ⇒
iki alan-HLC'si **birebir aynı** olur ⇒ `LwwRegister` tie-break'i `opId` dize-ordinal karşılaştırmasıdır
ve `opId` **rastgele UUID v4**'tür ⇒ **%50 olasılıkla kullanıcının SON yazdığı değer kaybolur**, iki op
da `Applied` döner, kuyruk temizlenir, **hiçbir kapı kırmızı yanmaz**. Tavan bu çakışmayı kaynağında keser.

🔴 **`sonWall` KALICIDIR ama TAVANLIDIR.** Tavansız bir `max(now, sonWall)` şu ölümü üretir: saat bir kez
2030'a alınır, bir op üretilir, `sonWall` kalıcıya yazılır ⇒ saat düzeltilse bile her op ~4 yıl ileri
damga taşır ⇒ `AbsurdForwardMs` (365 gün) aşılır ⇒ `RejectedAbsurdHlc` ⇒ **cihaz kalıcı olarak senkron
dışıdır ve tek çare uygulamayı silmektir.**

`clientId` ilk açılışta bir kez üretilir ve **kalıcı** saklanır (`ayarlar` tablosu). `counter` `uint`'tir.
`SyncRequest.ClientHlc` **`null` gönderilir** — handler onu okumuyor (ölçüldü).

### `D4` — Toplu gönderim tavanı **100** · **TEK UÇUŞ**
- Sunucu `Ops.Count > 100` ⇒ **400** ve **hiçbir op işlenmez**. İstemci bir istekte en çok **100** op
  gönderir; fazlası art arda turlarla gider.
- 🔴 **Aynı anda en fazla BİR senkron turu** (mutex/`Completer`). Zamanlayıcı + elle tetik +
  "bağlantı geri geldi" olayı çakışırsa iki tur aynı satırları seçer: `denemeSayisi` çift artar ve
  geç dönen tur, diğerinin **karantinaya aldığı** satırı `bekliyor`e geri çevirerek `D5`'in en sert
  güvencesini bozar.

### `D5` — Sonuç işleme (op bazında, `applied` listesinden)
| sunucu kodu | kuyruk | `Gorevler.senkronDurumu` |
|---|---|---|
| `Applied` | satır **silinir** | `senkronize` |
| `Duplicate` | satır **silinir** (idempotent) | `senkronize` |
| `RejectedRegistryViolation` · `RejectedAbsurdHlc` · `RejectedInvalid` | `durum='zehirli'`, `sonHataKodu` yazılır, satır **KALIR ama bir daha SEÇİLMEZ** | `cakisma` |
| **tanınmayan** `code` | aynı: `zehirli`, `sonHataKodu` = **ham dize** | `cakisma` |

*(`RejectedSetCapExceeded` bu dilimde **erişilemez** — `Sets` gönderilmiyor. Kapı onu ölçmez; tanınmayan
kod kuralı zaten kapsar.)*

🔴 **`cakisma` KİLİTLENİR.** Bir görev için kuyrukta **zehirli satır varsa** `senkronDurumu` `cakisma`da
kalır; sonraki bir `Applied`/`Duplicate` onu **`senkronize` yapamaz**. Aksi hâlde: aynı görev için op1
(`Applied`) → op2 (`Rejected`, zehirli) → op3 (`Applied`) dizisinde rozet `senkronize` olur, veri kaybı
**gerçekleşir ama görünmez** — `D5`'in tüm gerekçesi çöker.

🔴 **Zehirli op kuyruğu TIKAMAZ.** Karantinaya düşen op sonraki turlarda **seçilmez**; diğer op'lar
normal gönderilir. Reddedilen op **silinmez** — sessiz veri kaybı bu projede kabul edilmez.

**Rozet dikişi (§1.5'te YOKTU, burada doğar):** `senkronDurumu` → `(SenkronDurumTuru, cakismaVarMi)`:
`'yerel'→(yerel,false)` · `'kuyrukta'→(kuyrukta,false)` · `'senkronize'→(senkronize,false)` ·
`'cevrimdisi'→(cevrimdisi,false)` · `'cakisma'→(yerel,**true**)`. **Tanınmayan dize ⇒ `assert`/fırlat**
(sessizce `yerel`e düşmek CHECK kısıtının anlamını yok eder). `gorev_listesi_ekrani.dart` bu iki
parametreyi `GorevSatiri`'na **geçirir**.

### `D6` — Çekme yanıtı: yalnız imleç
- `SyncResponse.NextCursor` **ham JSON metni olarak** `ayarlar`'a yazılır ve aynen geri gönderilir.
  🔴 `WireCursor.Xid` **`ulong`**'dur; Dart `int` web'de 53-bit güvenlidir ⇒ **sayıya çevirmek yasak**.
- 🔴 **`resyncRequired == true` ise saklanan imleç SİLİNİR** (sonraki istek `sinceCursor` olmadan gider).
  Sunucu bu dalda **aynı bayat imleci** geri döndürür (`nextCursor = request.SinceCursor`); körü körüne
  yazılırsa istemci GC ufkunun altında **sonsuza dek** sıkışır.
- `Changes` ve `Snapshot` **okunur, Drift'e UYGULANMAZ.**
- ℹ️ `sinceCursor == null` ⇒ sunucu **tam snapshot** üretir; bu dilimde o gövde **atılır** — beyan
  edilmiş ağ maliyetidir.

🟡 **BEYAN EDİLMİŞ SINIR:** bu dilim **iki cihazın yakınsadığını KANITLAMAZ**; yalnız *"çevrimdışı biriken
op ağa çıkınca sunucuya doğru içerikle işlenir ve tekrarı zararsızdır"* iddiasını kanıtlar.

### `D7` — Zarf ve HLC iskeleti (v1'de YOKTU; iki denetçi de bunu bloker saydı)
Her `WireOp` şu **dört zarf alanını** taşır, **hiçbiri boş GUID olamaz**:
| alan | değer |
|---|---|
| `operationId` | kuyruğun `opId`'si — **UUID v4** |
| `clientId` | `D3`'ün kalıcı cihaz GUID'i |
| `entityId` | `Gorevler.id` — **geçerli GUID biçimi** |
| `actorId` | **`X-Momentum-Dev-User` başlığındaki GUID** (`D0` ile aynı değer); `clientId` ile **asla aynı değildir** |

🔴 `entityId`/`opId` için `Gorevler.id` üreteci **GUID biçiminde** olmak zorundadır (`uretimIdUret()`);
`'test-id-0'` gibi bir id **400** aldırır ve `G6` kapıdan önce ölür.

🔴 **HER YAZIMIN KENDİ HLC'Sİ VARDIR.** Tel biçimi:
```jsonc
{ "operationId":"…","clientId":"…","entityId":"…","actorId":"…","entityType":"Task",
  "opHlc":   {"wallMs":0,"counter":0,"clientId":"…"},
  "fields":  { "title": {"value":"…","hlc":{…}} },
  "groups":  { "completion": {"fields":{"status":"done","completedAt":"…Z"},"hlc":{…}} } }
```
Op içindeki **tüm** HLC'ler `D3`'ün **aynı damgasıdır**. `hlc` atlanırsa `WireMapping.ToHlc(null)` ⇒
**NullReferenceException ⇒ 500**; validator bunu yakalamaz (`D9` 5xx'i sınıflandırır).

### `D8` — Atomiklik ve çökme kurtarma (v1'de kapısız bir cümleydi)
1. 🔴 **`Gorevler` yazımı ile kuyruk yazımı TEK Drift `transaction()` içindedir.** Kuyruk yazılmadan
   `Gorevler` commit olursa kullanıcı verisi yerelde vardır ama sunucuya **asla gitmez** — hiçbir rozet,
   hiçbir hata, hiçbir kapı görmez. Ters sıra **hayalet op** üretir.
2. 🔴 **`durum='gonderildi'` UÇUŞ İŞARETİDİR ve ÇIKIŞI VARDIR.** Gönderim başlarken satır `gonderildi`
   olur. **Uygulama açılışında ve her turun başında `gonderildi` olan TÜM satırlar `bekliyor`e döndürülür.**
   Sunucu dedup'ı tekrarı zararsız kılar (§1.4/1). Kurtarma olmazsa: istek gitti, yanıt gelmeden çökme ⇒
   satır bir daha **asla seçilmez, asla silinmez**; sunucuda veri var, istemci bunu asla bilemez.
3. Kuyruk seçim yüklemi **`durum = 'bekliyor'`**, sıra `D1`'deki üçlü anahtar.

### `D9` — HTTP yanıt sınıflandırması ve deneme tavanı
| yanıt | kuyruk | rozet |
|---|---|---|
| **200** | gövdedeki `applied` listesi `D5`'e göre işlenir | `D5` |
| **401** | `bekliyor`, `denemeSayisi++` | `cevrimdisi` |
| **4xx (401 hariç; 400, 413…)** | 🔴 **tur DURUR**, satırlar `bekliyor` kalır, `denemeSayisi` **artmaz**, hata kaydedilir ve kullanıcıya gösterilir | `cakisma` |
| **5xx** | `bekliyor`, `denemeSayisi++` | `cevrimdisi` |
| ağ hatası / zaman aşımı | `bekliyor`, `denemeSayisi++` | `cevrimdisi` |

🔴 **400'ü "ağ hatası" saymak SONSUZ DÖNGÜDÜR:** tavanda bir off-by-one 101 op yollar, sunucu 400 döner,
istemci yeniden dener, aynı 101'lik yığın **sonsuza dek** gider.
**`denemeSayisi` ÖLÜ SAYAÇ OLAMAZ:** üstel geri çekilme (`2^n` saniye, tavan 5 dk) ve
**`denemeSayisi > 8` ⇒ `durum='zehirli'`, `sonHataKodu='deneme-tavani'`** kuralı bu sayacı okur.

---

## 4. Teslimat adımları

1. **T1 — Yürüyen iskelet.** `Program.cs`: `AddHttpContextAccessor()` + `D0` koşullu kaydı + `DevCurrentUser`.
   Elle `.http`/`curl`: başlıksız **401**, başlıklı **200**. *(Bu adım bitmeden başka kod yazma.)*
2. **T2 — Kuyruk ve migration.** `senkron_kuyrugu` + `MigrationStrategy` + `TableMigration` ile CHECK
   genişletmesi. **Migration testi için altyapı:** `dart run drift_dev schema dump` (v1 şeması) +
   `schema generate` ⇒ `test/generated_migrations/`. Bu altyapı **kurulamazsa** `G3`'ün migration ayağı
   `[DOĞRULANMADI]` yazılır — "yeşil" **denmez**.
3. **T3 — HLC ve kimlik.** `HlcUretici` + `ayarlar` tablosu (`clientId`, `sonWall`, `sonCounter`,
   `nextCursorJson`, `devUserId`) (`D3`, `D6`, `D7`).
4. **T4 — `WireOp` üreteci.** Dört yazma yolu (`ekle`/`duzenle`/`tamamlaGeriAl`/`sil`) `Gorevler` **ve**
   kuyruk satırını **tek `transaction()` içinde** yazar (`D2`, `D7`, `D8/1`). `idUret` **GUID biçiminde**.
5. **T5 — Ağ katmanı.** `SenkronAgi` arayüzü + `HttpSenkronAgi`. **Sahte ağ, sunucunun sözleşmesini
   taklit eder:** `ops.length > 100` ⇒ 400 döndürür (aksi hâlde `D4` ayağı hiçbir şey ölçmez).
6. **T6 — Senkron döngüsü.** Tek uçuş (`D4`) + `gonderildi` kurtarma (`D8/2`) + sonuç işleme (`D5`) +
   yanıt sınıflandırma (`D9`) + rozet dikişi (`D5`).
7. **T7 — Kapılar.** `G1`–`G8` yazılır ve koşulur; sonra **her mutant tek tek uygulanır, kapının ısırdığı
   ölçülür, mutant geri alınır** (§6).
8. **T8 — KANIT.** §8'e göre `KANIT/slice-3c/` doldurulur.

**Bağımlılık:** `package:http`. Eklemeden önce `araclar/pub-cve-kapisi.py` ve `araclar/pub-lisans-kapisi.py`
EXIT 0 vermelidir; pin `flutter pub get` ile **çözümlenerek** doğrulanır (`Z10b` borcu).

---

## 5. KAPILAR

Hüküm **çıkış kodudur**, beyan değil. Kör kapı yoktur: §6'daki mutant o kapının **gerçekten ısırdığını**
kanıtlar.

### G1 — DEV-KİMLİK KAPISI
🔴 **Ön koşul ve yer:** `SyncCommandHandler` push'tan sonra **koşulsuz** pull yapar ⇒ **200 almak için
gerçek PostgreSQL şarttır**. Bu yüzden ayaklar **iki projeye bölünür**: 401 ayakları DB'siz
`Momentum.Api.Tests`'te; 200 ayağı `Momentum.Persistence.Tests`'te (Testcontainers).
`Production` ayağı `WithWebHostBuilder(b => b.UseEnvironment("Production"))` ile **açıkça pinlenir**
(WAF varsayılanı `Development`'tır — pinlenmezse ayak kendiliğinden geçer ve kapı körleşir).

| ölçülen karar | ayak | beklenen |
|---|---|---|
| `D0` | `Development` + geçerli başlık (**DB'li**) | **200**, `applied` döner |
| `D0` | `Development`, başlık yok | **401** |
| `D0` | `Development`, başlık GUID değil (`"abc"`) | **401** |
| `D0` | **`Production`** + geçerli başlık | **401** |

### G2 — REGISTRY UYUM + ZARF KAPISI (Dart birim testi; ağ YOK)
Dört yazma yolunun ürettiği `WireOp` JSON'u ölçülür.

| ölçülen karar | ayak | beklenen |
|---|---|---|
| `D2` | `entityType` | **tam `"Task"`** |
| `D2` | `fields` anahtarları | ⊆ {`title`,`isDeleted`}; `groups` anahtarı yalnız `completion` |
| `D2` | `olusturuldu`/`guncellendi`/`senkronDurumu` | **hiçbir kanalda geçmez** |
| `D2` | `silindi == true` | `fields.isDeleted.value == "true"` (**tam dize**) |
| `D2` | `completion` | `fields`'inde **hem `status` hem `completedAt`** var |
| `D2` | `status` değeri | **∈ {`"done"`,`"open"`}**, tam dize |
| `D2` | `completedAt` | `…Z` ile biter **ve** `DateTime.parse` ile geri okunabilir |
| `D2` | **boş op** | üretilen hiçbir op kanalsız değil (en az bir kanal) |
| `D7` | dört zarf alanı | `operationId`/`clientId`/`entityId`/`actorId` **boş-olmayan geçerli GUID** |
| `D7` | `actorId` | dev kullanıcı GUID'ine **eşit** ve `clientId`'den **farklı** |
| `D7` | HLC iskeleti | `opHlc` **ve** her `fields.*.hlc` / `groups.*.hlc` mevcut, üçü de **aynı damga** |

Üretilen dört JSON `KANIT/slice-3c/02-G2/` altına **ham** yazılır; `G6` **bu ham JSON'ları** kullanır.

### G3 — KUYRUK / TOPLU GÖNDERİM / İMLEÇ KAPISI
🔴 **Gerçek dosya zorunlu:** `NativeDatabase(File(p.join(tempDir.path,'m.sqlite')))`.
**`NativeDatabase.memory()` YASAK** — "kapat, yeniden aç" ayağı bellekte doğru kodla da kırmızı yanar,
yani `M13` ile doğru kod ayırt edilemez.

| ölçülen karar | ayak | beklenen |
|---|---|---|
| `D1` | üç op üret, DB'yi **kapat**, yeniden aç | kuyrukta **üç** satır |
| `D1` | sıralama | `(hlcWallMs, hlcCounter, opId)` artan; **eşit damgalı iki op'ta sıra deterministik** |
| `D1` | `govdeJson` | gönderim öncesi ve sonrası **bayt bayt aynı** |
| `D1` | migration `v1 → v2` | eski `'yerel'` satırlar korunur; yeni CHECK beş değeri kabul eder |
| `D4` | kuyrukta 150 op | **gözlenen her isteğin `ops` uzunluğu ≤ 100** (assert edilir); iki tur; sahte ağ 400 **döndürmez** |
| `D4` | iki tur **eşzamanlı** başlatılır | sahte ağa giden istek sayısı beklenen tur sayısını **aşmaz**; `denemeSayisi` çift artmaz |
| `D6` | `nextCursor` | ham metin olarak yazılır, yeniden açılışta okunur, sonraki istek `sinceCursor` ile gider |
| `D6` | `resyncRequired: true` | saklanan imleç **silinir**; sonraki istek `sinceCursor` **olmadan** gider |

### G4 — HLC KAPISI (saat enjekte edilir)
| ölçülen karar | ayak | beklenen |
|---|---|---|
| `D3` | aynı ms'de 1000 çağrı | `wallMs` sabit, `counter` 0…999, tekrar yok |
| `D3` | saat **geri** gider | `wallMs` **düşmez**; `counter` artar |
| `D3` | saat ileri gider | `counter` **0'a döner** |
| `D3` | **`sonWall` 10 dk ileri kurulur** | üretilen `wallMs` **`now + 300000`'i AŞMAZ** |
| `D3` | **saat 400 gün ileri alınır** | üretilen `wallMs` yine **`now + 300000`'i aşmaz** (absürt ret imkânsız) |
| `D3` | yanıtta `serverHlc.wallMs > sonWall` | `sonWall` **ileri taşınır**; sonraki damga ondan büyüktür |
| `D3` | yeniden başlatma | `sonWall`/`sonCounter` kalıcıdan okunur; yeni damga öncekinden **kesin büyük** |
| `D3` | `clientId` | iki açılışta **aynı**; `ayarlar`'da tek satır |

### G5 — KARANTİNA / ROZET / YANIT SINIFI KAPISI (sahte ağ)
| ölçülen karar | ayak | beklenen |
|---|---|---|
| `D5` | `RejectedRegistryViolation` | `durum='zehirli'`, **silinmez**, `sonHataKodu` yazılır |
| `D5` | zehirli + iki sağlam op | iki sağlam op **gönderilir** — kuyruk tıkanmaz |
| `D5` | zehirli op sonraki turda | **seçilmez**, `denemeSayisi` artmaz |
| `D5` | **tanınmayan `code`** (`"Foo"`) | `zehirli`, `sonHataKodu == "Foo"` |
| `D5` | **`cakisma` kilidi**: aynı görev için `Applied` → `Rejected` → `Applied` | görev `cakisma`da **kalır**, `senkronize` olmaz |
| `D5` | rozet dikişi | `'cakisma'` ⇒ `GorevSatiri.cakismaVarMi == true`, `CakismaRozeti` görünür |
| `D5` | tanınmayan `senkronDurumu` dizesi | **fırlatır** (sessizce `yerel`e düşmez) |
| `D9` | **HTTP 400** | tur **durur**, `denemeSayisi` **artmaz**, satırlar `bekliyor` |
| `D9` | HTTP 500 / zaman aşımı | `bekliyor`, `denemeSayisi++`, rozet `cevrimdisi` |
| `D9` | `denemeSayisi` 9'a ulaşır | `durum='zehirli'`, `sonHataKodu='deneme-tavani'` |

### G6 — UÇTAN UCA KAPI (**gerçek backend + gerçek PostgreSQL**, `Development`)
Ön koşul: `momentum-postgres` Up (healthy) · `araclar/verify.ps1` EXIT 0 · API `Development`'ta ayakta.

| ölçülen karar | ayak | beklenen |
|---|---|---|
| `D2` | **1:** ağ kapalıyken üç görev işlemi | kuyrukta üç satır, hiçbir istek gitmemiş |
| `D5` | **2:** ağ açılır, senkron koşar | üç kez **`Applied`**; kuyruk **boş**; üç görev `senkronize` |
| `D2` | **3 (İÇERİK):** `SELECT title, status, completed_at, is_deleted FROM tasks WHERE entity_id IN (…)` | **alan alan** istemcideki üç `Gorevler` satırıyla eşleşir |
| `D5` | **4:** aynı üç op **zorla** yeniden gönderilir | üç kez **`Duplicate`**; `SELECT count(*) FROM processed_operations WHERE client_id=@c` ⇒ **3 (artmaz)** |
| `D5` | **5:** kasten bozuk op (`entityType="task"`) | `RejectedRegistryViolation`; op kuyrukta **zehirli** kalır; sonraki sağlam op yine gider |
| `D3` | **6:** cihaz saati **+6 dk** ileri alınır, iki ardışık başlık düzenlemesi **tek turda** gider | sunucudaki `title` **SON** değere eşittir |

🔴 **Ayak 3 pazarlıksızdır.** v1'de yoktu ve şu teslimi yeşil geçiriyordu: `title` değeri boş dize
yazılır → `G2` geçer (anahtar kontrolü, değer değil) → `G3` geçer → `G6` ayak 2 geçer (`Applied`) →
ayak 4 geçer (`Duplicate`) → **on kabul kriteri yeşil, sunucudaki üç görevin başlığı boş.**
🔴 **Ayak 4'ün hüküm dayanağı `processed_operations`'tır, `tasks` DEĞİL** — `tasks` `entity_id` üzerinde
**upsert**tir, `opId` değişse bile kopya satır **doğamaz**; `tasks` sayımı bilgi amaçlıdır.

### G7 — REGRESYON KAPISI
| ölçülen karar | ayak | beklenen |
|---|---|---|
| — | `flutter analyze --fatal-infos` | **0 bulgu** |
| — | `flutter test` | mevcut **36** test dahil hepsi yeşil, EXIT 0 |
| — | `araclar/verify.ps1` | build 0 uyarı/0 hata, testler yeşil, CVE 0, EXIT 0 |
| — | `python araclar\design-token-kapisi.py .` | EXIT 0 |
| — | `python araclar\tek-kopya-kapisi.py .` | EXIT 0 (**YEŞİL**) |

> ⚠ `flutter test` bu ortamda `PROGRAMFILES(X86)=C:\Program Files (x86)` **enjekte edilmeden** çöker.
> `flutter test --platform chrome` **sonuç üretmiyor** ⇒ web test ayağı `[DOĞRULANMADI]` kalır, uydurulmaz.

### G8 — ATOMİKLİK + ÇÖKME KURTARMA KAPISI (Dart testi, gerçek dosya DB)
| ölçülen karar | ayak | beklenen |
|---|---|---|
| `D8` | kuyruk yazımı zorla fırlatılır | `Gorevler`'de de **0 satır** (işlem geri sarıldı) |
| `D8` | `Gorevler` yazımı zorla fırlatılır | kuyrukta da **0 satır** (hayalet op yok) |
| `D8` | üç op `gonderildi` iken DB kapatılıp açılır | üçü de **`bekliyor`e döner**, yeniden seçilebilir |
| `D8` | seçim yüklemi | yalnız `durum='bekliyor'` satırlar seçilir |

---

## 6. MUTANTLAR — otuz altı; KAPALI ve numaralı liste

**Kural:** mutant **tek tek** uygulanır → kapının **KIRMIZI** yandığı ölçülür → mutant **geri alınır** →
kapı yeniden **YEŞİL** olur. Isırmayan mutant, kapının **kör** olduğunun kanıtıdır; **kapı düzeltilir**.

**Maliyet sınıfı (K53 madde 3):** koşan uygulama isteyen **yalnız üç** mutant vardır — `M28`, `M29`, `M30`
(tavan **üç**). Kalan **otuz üç** mutant statik/birim/widget sınıfıdır ⇒ **tavansız**.
*(v1'in `M13`'ü **iptal edildi**: `G6`'nın hiçbir ayağında reddedilen op yoktu, dolayısıyla "kuyruğu
koşulsuz temizle" bozması doğru davranışla **birebir aynı gözlemi** üretiyordu — eşdeğer mutanttı ve
en kıt bütçenin üçte birini yiyordu.)*

| # | mutant (kodda yapılan bozma) | kapı / kural | beklenen |
|---|---|---|---|
| **M1** | `IsDevelopment()` koşulunu kaldır | G1 / D0 | `Production` ayağı 200 döner ⇒ **KIRMIZI** |
| **M2** | Başlık yok/bozukken sabit varsayılan GUID döndür | G1 / D0 | iki 401 ayağı düşer ⇒ **KIRMIZI** |
| **M3** | `tamamlandi`'yı `Fields["completion"]`'a yaz | G2 / D2 | kanal ihlali ⇒ **KIRMIZI** |
| **M4** | `isDeleted` değerini `"True"` yaz | G2 / D2 | tam-dize ayağı düşer ⇒ **KIRMIZI** |
| **M5** | `entityType`'ı `"task"` yap | G2 / D2 | Ordinal ayağı düşer ⇒ **KIRMIZI** |
| **M6** | `completion`'da yalnız `status` yaz | G2 / D2 | REPLACE ayağı düşer ⇒ **KIRMIZI** |
| **M7** | `.toUtc()`'yi düşür (`saat().toIso8601String()`) | G2 / D2 | `…Z` ayağı düşer ⇒ **KIRMIZI** |
| **M8** | `status`'e `"tamamlandi"` yaz | G2 / D2 | değer ayağı düşer ⇒ **KIRMIZI** |
| **M9** | Kanalsız (boş) op üret | G2 / D2 | "en az bir kanal" ayağı düşer ⇒ **KIRMIZI** |
| **M10** | `actorId`'yi `Guid.Empty` yaz | G2 / D7 | zarf ayağı düşer ⇒ **KIRMIZI** |
| **M11** | `actorId = clientId` yaz | G2 / D7 | "farklı" ayağı düşer ⇒ **KIRMIZI** |
| **M12** | Bir alandan `hlc`'yi sil | G2 / D7 | HLC iskeleti ayağı düşer ⇒ **KIRMIZI** |
| **M13** | `idUret`'i `'test-id-N'` biçimine çevir | G2 / D7 | GUID ayağı düşer ⇒ **KIRMIZI** |
| **M14** | Kuyruğu Drift yerine bellek içi listede tut | G3 / D1 | yeniden açılışta kuyruk boş ⇒ **KIRMIZI** |
| **M15** | Sıralamadan `opId` tie-break'ini çıkar | G3 / D1 | eşit damgada sıra deterministik değil ⇒ **KIRMIZI** |
| **M16** | Migration'ı "drop & recreate" yap | G3 / D1 | eski `'yerel'` satırlar kaybolur ⇒ **KIRMIZI** |
| **M17** | Toplu gönderim tavanını 101 yap | G3 / D4 | `ops.length ≤ 100` assert'i düşer; sahte ağ 400 döner ⇒ **KIRMIZI** |
| **M18** | Tek-uçuş kilidini kaldır | G3 / D4 | eşzamanlı tur ayağı düşer ⇒ **KIRMIZI** |
| **M19** | `nextCursor` yazımını kaldır | G3 / D6 | imleç kalıcılığı düşer ⇒ **KIRMIZI** |
| **M20** | `resyncRequired`'ı yok say (imleci sakla) | G3 / D6 | resync ayağı düşer ⇒ **KIRMIZI** |
| **M21** | `counter`'ı daima 0 bırak | G4 / D3 | aynı ms'de damgalar tekrar eder ⇒ **KIRMIZI** |
| **M22** | `wall = max(now, sonWall)` yerine `wall = now` | G4 / D3 | saat-geri ayağı düşer ⇒ **KIRMIZI** |
| **M23** | İstemci tavanını (`min(..., now+300000)`) kaldır | G4 / D3 | 10 dk ve 400 gün ayakları düşer ⇒ **KIRMIZI** |
| **M24** | `serverHlc` birleştirmesini kaldır | G4 / D3 | birleştirme ayağı düşer ⇒ **KIRMIZI** |
| **M25** | `Rejected*` gelince kuyruk satırını **sil** | G5 / D5 | karantina ayağı düşer (sessiz kayıp yakalanır) ⇒ **KIRMIZI** |
| **M26** | Zehirli op'u seçilebilir bırak | G5 / D5 | kuyruk tıkanır ⇒ **KIRMIZI** |
| **M27** | `Duplicate`'i hata say, satırı silme | G5 / D5 | idempotens ayağı düşer ⇒ **KIRMIZI** |
| **M28** | `cakisma` kilidini kaldır (sonraki `Applied` rozeti ezsin) | G5 / D5 | kilit ayağı düşer ⇒ **KIRMIZI** |
| **M29** | HTTP 400'ü ağ hatası say | G5 / D9 | 400 ayağı düşer (`denemeSayisi` artar) ⇒ **KIRMIZI** |
| **M30** | `denemeSayisi` tavanını kaldır | G5 / D9 | tavan ayağı düşer ⇒ **KIRMIZI** |
| **M31** | Kuyruk ve `Gorevler` yazımını **iki ayrı** `transaction`'a böl | G8 / D8 | geri sarma ayağı düşer ⇒ **KIRMIZI** |
| **M32** | Açılışta `gonderildi → bekliyor` kurtarmasını kaldır | G8 / D8 | kurtarma ayağı düşer ⇒ **KIRMIZI** |
| **M33** | Bir dosyaya `info` seviyesinde analyzer ihlali ekle | G7 | `--fatal-infos` ısırmalı ⇒ **KIRMIZI** |
| **M34** | `opId`'yi her gönderimde yeniden üret | G6 / D5 | ayak 4'te `Duplicate` yerine `Applied`; `processed_operations` **3 → 6** ⇒ **KIRMIZI** *(koşan)* |
| **M35** | `title` yerine sabit `"x"` gönder | G6 / D2 | **içerik ayağı (3)** düşer ⇒ **KIRMIZI** *(koşan)* |
| **M36** | İstemci HLC tavanını kaldır (canlıda) | G6 / D3 | ayak 6'da sunucudaki `title` **eski** değere düşer ⇒ **KIRMIZI** *(koşan)* |

**Koşan-uygulama mutantları: `M34`, `M35`, `M36` — üç adet, tavan üç.** Kalan otuz üçü tavansız sınıftadır.

---

## 7. Kabul kriterleri (hepsi ölçülür; beyan kabul edilmez)

1. `G1`–`G8` **koştu** ve hepsi **YEŞİL**; her kapının çıkış kodu KANIT'ta.
2. **`M1`–`M36`'nın hepsi** tek tek uygulandı, hedef kapı **KIRMIZI** yandı, mutant geri alındı, kapı
   **YEŞİL** döndü. Isırmayan mutant varsa **kapı düzeltilir** ve durum §10'a yazılır — **kör kapı teslim edilmez.**
3. `flutter analyze --fatal-infos` **0 bulgu**; `flutter test` EXIT 0.
4. `araclar/verify.ps1` EXIT 0.
5. `python araclar\tek-kopya-kapisi.py .` **YEŞİL** ve `python araclar\design-token-kapisi.py .` EXIT 0.
6. `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-slice-3c-senkron.md` EXIT 0
   **ve** `python araclar\sayi-tazeligi.py .` EXIT 0.
   ⚠ **Bu iki araç mutantın ISIRDIĞINI ölçmez**, yalnız **kapsamayı** ölçer (araçlar bu sınırı kendileri
   beyan ediyor). EXIT 0, kriter 2'nin yerine geçmez.
7. `package:http` için `pub-cve-kapisi.py` ve `pub-lisans-kapisi.py` EXIT 0; pin `flutter pub get` ile çözüldü.
8. **Backend senkron çekirdeğine tek satır dokunulmadı** — kanıt **taban ref'e karşı** alınır:
   `git --no-optional-locks diff --stat 5df3caf..HEAD -- src/backend/` ⇒ yalnız `Program.cs`
   (`AddHttpContextAccessor` + `D0` kaydı) ve yeni `DevCurrentUser` dosyası görünür.
9. `G6`'nın **altı ayağı** gerçek backend + gerçek PostgreSQL'e karşı koştu; ham HTTP gövdeleri **ve**
   `tasks` / `processed_operations` sorgu çıktıları KANIT'ta.
10. Uygulama Android'de **açıldı ve çalıştı** (ekran görüntüsü); çevrimdışı üretilen op ağ açılınca senkronlandı.

---

## 8. KANIT protokolü — `KANIT/slice-3c/`

```
KANIT/slice-3c/
  00-OZET.md                 <- her kapı: komut, çıkış kodu, tek satır hüküm
  01-G1-dev-kimlik/          <- dört ayak (401'ler DB'siz, 200 DB'li)
  02-G2-registry-zarf/       <- dört ham WireOp JSON'u (G6 bunları kullanır)
  03-G3-kuyruk/              <- test çıktısı + migration öncesi/sonrası şema dökümü
  04-G4-hlc/                 <- koşum özeti (1000 damganın tam listesi DEĞİL)
  05-G5-karantina/           <- test çıktısı
  06-G6-uctan-uca/           <- altı ayağın ham HTTP gövdeleri + SQL çıktıları
  07-G7-regresyon/           <- analyze, flutter test, verify.ps1
  08-G8-atomiklik/           <- test çıktısı
  09-MUTANT/                 <- M1..M36: her biri için "kapı KIRMIZI" kanıtı + geri alma
  HUKUM.md                   <- nihai karar; her iddia bir dosyaya ATIF yapar
```

🔴 **Ham dökümü olduğu gibi atma.** `KANIT/slice-3b/04-G3/gercek-tarama.txt` **1,9 MB** oldu.
Kural: **ilgili kesit + `sha256`**; 200 KB'ı aşan her kanıt dosyası **budanır** ve `00-OZET.md`'de yazılır.
`HUKUM.md`'de hiçbir cümle *"doğrulandı"* diyemez; **hangi dosyanın hangi satırına** dayandığını yazar.

---

## 9. Kırmızı çizgiler — bu dilimde YASAK

1. **`DevCurrentUser`'ı üretim yoluna sızdırmak.** Ortam koşulu kaldırılamaz, gevşetilemez.
2. **Sırrı repoya yazmak.** Dev başlığın değeri koda gömülmez.
3. **`RejectedInvalid`'i yeniden denemek.** Kalıcı rettir; sonsuz döngü üretir.
4. **Reddedilen op'u sessizce silmek.** Veri kaybı beyansız olamaz.
5. **`DESIGN.md`'ye tek bayt yazmak** (K46).
6. **Backend senkron çekirdeğini değiştirmek** (§2).
7. **`git add -A`** (K55) — yol belirterek ekle.
8. **`device_bash`/mount'tan commit/push.** **PUSH ONUR'DADIR.**
9. **Yol adına Türkçe karakter** (K56).
10. **Ölçmediğini "temiz" saymak.** Ölç ya da `[DOĞRULANMADI]` yaz.
11. **Bir kapıyı, ısırmayan mutantı "eşdeğer" ilan ederek gevşetmek.** Önce kapı düzeltilir; mutant ancak
    **ölçümle** yanlış olduğu gösterilirse dürüstleştirilir (K60'ın M2b emsali).

---

## 10. Açık kalemler / devir

- 🟡 **`D6` sınırı:** çekme uygulanmıyor ⇒ **iki cihazın yakınsaması bu dilimde KANITLANMAZ.** slice-3d borcu.
- 🟡 **`DevCurrentUser` kimlik çözümü değildir.** ADR 0003 donmuş (K41); gerçek kimlik hâlâ borç.
- 🟡 **Tek kullanıcı varsayımı:** `ayarlar`'da **tek** `clientId` ve **tek** imleç var. `X-Momentum-Dev-User`
  değişirse önceki kullanıcının imleci yeni kullanıcının akışına uygulanır. Bu dilimde pull olmadığı için
  gizli kalır, **slice-3d'de patlar** — beyan edilmiş sınırdır.
- 🟡 **Migration ortası çökme ölçülmüyor.** `TableMigration` tam tablo yeniden yazımı yapar; ortada çökme
  yarım artefakt bırakabilir. `G3` yalnız mutlu yolu + `M16`'yı ölçüyor.
- 🟡 **Kuyruk büyüklüğü tavanı yok.** Uzun çevrimdışı dönemde kuyruk sınırsız büyür; toplam gövde boyutu
  için de tavan yok (413 `D9`'da sınıflandırılmıştır ama önlenmemiştir).
- 🟡 **Web ayağı `[DOĞRULANMADI]`:** `flutter test --platform chrome` bu ortamda sonuç üretmiyor.
- 🟡 **`Z10b`:** `pub-surum-olc.py` çözümlenebilirliği ölçmüyor ⇒ pin elle `flutter pub get` ile doğrulanır.
- Bir karar yanlış çıkarsa: **kodla düzeltme.** Bulguyu buraya yaz, dur, Onur'un kilidini bekle (K40).

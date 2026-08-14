# GÖREV (Claude Code) — slice-3d: ÇEKME (pull) + yerel LWW yakınsaması (K42-d adım 3b)  [v1]

> **Bu dilim slice-3c'nin BEYAN EDİLMİŞ borcunu kapatır.** slice-3c §10: *"çekme uygulanmıyor
> ⇒ iki cihazın yakınsaması bu dilimde KANITLANMAZ. slice-3d borcu."* Ödenen borç budur.
> **SignalR / gerçek zamanlı bu dilimde YOK** — o slice-3e'dir.

## 0. Önce oku

`DURUM.md` (canlı durum) · `CLAUDE.md` (kalıcı kurallar) · `GOREV_CLAUDE_CODE/GOREV-slice-3c-senkron.md`
(**biçim ve kilitli kararlar D0-D9 orada; bu spec'in D-kodları AYRI bir kümedir, karıştırma**).
`PROJE_HAFIZA.md`'yi **açma** — append-only arşivdir.

Bu spec **kilitlidir**: §3'teki `D0`-`D9` kararları ve §5'teki `G1`-`G9` kapıları **pazarlığa kapalıdır**
(K68 + K69, Onur onayladı). Bir karar yanlışsa **kodla değil, Onur'un kilidiyle** değişir: bulguyu §10'a
yaz, dur, sor.

**Yürüyen iskelet önce (K53 madde 5):** önce en küçük çalışan şey — `"ops":[]` taşıyan bir yalnız-çekme
isteği gerçek API'ye gider, `200` döner, `changes`/`snapshot` ham olarak basılır. Kapılar bu koşan şeyin
**üstüne** kurulur.

---

## 1. ÖLÇÜLMÜŞ ZEMİN — yeniden keşfetme; doğrula ve geç

Aşağıdaki her satır **gerçek dosyadan okundu**. Yeniden tasarlama; doğrula ve kullan.
Bir satırın ölçülmediği yerde `[DOGRULANMADI]` yazılıdır — o satır **varsayım değildir, boşluktur**.

### 1.1 Çekme yüzeyi HAZIR — backend'de tek satırı bu iş için yazılmayacak

| ne | nerede | ölçülen |
|---|---|---|
| **çekme için ayrı uç YOK** | `Momentum.Api/Endpoints/SyncEndpoints.cs:21` | tek uç `POST /v1/sync`; çekme aynı isteğin yanıtındadır |
| yanıt alanları | `SyncContracts.cs:61-68` | `serverHlc · nextCursor · hasMore · resyncRequired · applied[] · changes[] · snapshot[]` |
| **`ops` ATLANAMAZ** | `SyncRequestValidator.cs:14` | `Ops` **NotNull** ⇒ yalnız-çekme gövdesi bile `"ops":[]` taşımak ZORUNDA |
| ilk senkron dalı | `SyncCommandHandler.cs:74-95` | `sinceCursor == null` ⇒ `changes` **boş**, `snapshot` **dolu**, `nextCursor = (horizon, 0)` |
| artımlı dal | `SyncPuller.PullIncrementalAsync` | `owner_id = @actorId` **tek süzgeçtir**; `client_id` süzgeci **YOK** |
| sayfa boyu | `SyncPuller.cs:17` | `PageSize = 500` **sabit**; `hasMore = (changes.Count == PageSize)` |
| **`hlc` kolonu SELECT EDİLMEZ** | `SyncPuller.PullIncrementalAsync` SELECT listesi | `commit_xid, server_seq, payload` — outbox'ın `hlc` kolonu tele **hiç çıkmaz** |
| imleç tipi | `Momentum.Domain/Sync/SyncCursor.cs:9` | `(Xid: ulong, Seq: long)` — **HLC DEĞİL**, Postgres commit görünürlüğü çifti |
| resync | `SyncCommandHandler.cs:82-86` | `resyncRequired = true` dalında `nextCursor = request.SinceCursor` (**bayat imleç geri döner**) |

[KIRMIZI] **`SyncCursor` HLC DEĞİLDİR ve `Xid` `ulong`'dur.** Dart `int` 64-bit **işaretlidir**; `ulong`
taşar. İstemci `Xid`'i **ayrıştırmaz, sayıya çevirmez, karşılaştırmaz** — slice-3c'nin `_hamCursorCikar`
ham-metin deseni (`senkron_dongusu.dart:289-299`) **aynen korunur**.

[BEYAN] **`hasMore` yanlış-pozitif verebilir:** son sayfa **tam** 500 satırsa `changes.Count == PageSize`
doğru olur ve istemci fazladan **bir boş tur** koşar. Bu **veri kaybı değil, maliyettir**; bu dilimde
düzeltilmez, beyan edilir.

### 1.2 `changes[]` ve `snapshot[]` **TAMAMEN FARKLI İKİ ŞEKİLDİR** — iki ayrı ayrıştırıcı zorunlu

**`changes[i]` = `{cursor:{xid,seq}, payload:<WireOp>}`** (`SyncContracts.cs:22-32`,
`WireMapping.ClampedPayload`, `WireMapping.cs:47-66`). `payload` bir **projeksiyon değil**, kabul edilmiş
op'un kendisidir — **her HLC'si sunucu tarafında KIRPILMIŞ** olarak:

```jsonc
{ "operationId":"…","clientId":"…","entityId":"…","actorId":"…","entityType":"Task",
  "opHlc":{"wallMs":0,"counter":0,"clientId":"…"},
  "fields":{ "title":{"value":"…","hlc":{…}} },
  "sets":null, "groups":{ "completion":{"fields":{"status":"done","completedAt":"…Z"},"hlc":{…}} },
  "order":null }
```

[KIRMIZI] **`sets`/`groups`/`order` ANAHTARI VAR AMA DEĞERİ `null` OLABİLİR.** `ClampedPayload`
`JsonSerializerOptions(JsonSerializerDefaults.Web)` ile serialize eder ve **`DefaultIgnoreCondition`
AYARLANMAMIŞTIR** ⇒ boş kanal **atlanmaz**, `null` olarak yazılır. `payload['groups']` üzerinde
`as Map` cast'i **null kontrolü olmadan** yapılırsa uzak değişiklik uygulaması ilk boş kanalda **çöker**.

[KIRMIZI] **`changes` payload'ında `winOperationId` YOKTUR.** Kazanan op kimliği yalnız `snapshot`'ta
gelir. `changes` dalında tie-break için **op-düzeyi `operationId`** kullanılır — bu **doğru** eşdeğerdir,
çünkü sunucunun anahtarı da `(alanın HLC'si, o yazımı taşıyan op'un id'si)`dir (§1.3).

**`snapshot[i]`** (`SyncContracts.cs:44-59`) **başka bir şeydir** — op değil, **kazanmış durum**:

```jsonc
{ "entityType":"Task","entityId":"…",
  "scalars":[ {"field":"title","value":"…","hlc":{…},"winOperationId":"…"} ],
  "sets":[ {"setName":"tags","elements":[ {"element":"…","activeTags":[{"tag":"…","hlc":{…}}] } ]} ],
  "groups":[ {"group":"completion","fields":{"status":"done","completedAt":"…Z"},
              "hlc":{…},"winOperationId":"…"} ] }
```

[KIRMIZI] **İLK SENKRON ZORUNLU OLARAK SNAPSHOT DALINA DÜŞER.** `sinceCursor == null` iken sunucu
`changes`'i **boş** döndürür (`SyncCommandHandler.cs:74-95`). *"Önce yalnız artımlıyı yap, snapshot'ı
sonraki dilime ertele"* **teknik olarak imkânsızdır**: saklanmış imleç yoksa artımlı dal hiç koşmaz.
**İki dal da bu dilimde uygulanır** — tek dal uygulamak, uygulamanın ilk açılışında hiçbir şey
çekmemesi demektir.

### 1.3 LWW anahtarı ve HLC sırası — ÖLÇÜLDÜ, VARSAYILMADI

| ne | nerede | ölçülen |
|---|---|---|
| karşılaştırma anahtarı | `Momentum.Domain/Sync/HlcKey.cs:9` | `HlcKey(Hlc Hlc, Guid OperationId)` — **alan HLC'si + op id** |
| tie-break | `HlcKey.cs:21-23` | `string.CompareOrdinal(OperationId.ToString("N"), …)` |
| HLC sırası | `Momentum.Domain/Sync/Hlc.cs:10-25` | `(WallMs, Counter, ClientId'nin "N" hex biçiminin ORDINAL dize sırası)` |
| kazanma koşulu | `Domain/Sync/Crdt/LwwRegister.cs` `Apply` | `if (HasValue && candidate <= Key) return false;` ⇒ **KESİN BÜYÜKLÜK** |

[KIRMIZI] **`clientId` KARŞILAŞTIRMASI GUID SIRALAMASI DEĞİLDİR.** Sunucu `Guid.ToString("N")` ile
**tiresiz, küçük harfli 32 haneli hex** üretir ve onu `StringComparer.Ordinal` ile karşılaştırır
(`Hlc.cs` sınıf yorumu bunu açıkça yazıyor: *"never via Guid.CompareTo"*). İstemci Dart'ta `clientId`'yi
**tireleri silip küçük harfe indirerek** karşılaştırmak ZORUNDADIR. Tireli dizeyi olduğu gibi
karşılaştırmak farklı bir sıra üretir (`-` = 0x2D, hex basamakları 0x30-0x66) ⇒ **iki cihaz aynı
çakışmada FARKLI kazanan seçer** ve hiçbir tek-cihaz testi bunu görmez.

[KIRMIZI] **Eşit anahtar MEVCUDU KORUR.** `<=` ⇒ gelen yazım eşit anahtarla **kaybeder**. İstemci `>=`
yazarsa echo (§1.5/D6) kendi yazımını kendi üstüne yeniden uygular ve alanın HLC'si sessizce **kendi
kopyasıyla** değişir; yakınsama testi tek cihazda yine yeşil yanar.

### 1.4 Kanal eşlemesi (K62 D0 — KİLİTLİ, `Registry/FieldStrategyRegistry.cs:170-176`)

- **scalar (`fields`):** `title` · `notes` · `priority` · `dueAt` · `remindAt` · `projectId` ·
  `isDeleted` · `recurrenceRule`
- **OR-Set (`sets`):** `tags` · `assignees` · `checklistItems`
- **fractional (`order`):** `listPos` · `boardPos`
- **grup (`groups`):** `completion` → üyeleri `status`, `completedAt` (grup yazımı **REPLACE**'tir)

**Yerel projeksiyona giden ÜÇ alan (bu dilimde uygulanan):**
`baslik <- fields.title.value` · `tamamlandi <- groups.completion.fields.status == "done"` ·
`silindi <- fields.isDeleted.value == "true"` (**Ordinal**, tam dize — `EntityState.DeletedValue`).

[BEYAN] Diğer bütün scalar/grup/`order` alanları `UzakAlanDurumu`'na **kaydedilir ama projeksiyona
YAZILMAZ** (ileri uyumluluk). `sets` kanalı bu dilimde **yok sayılır** — OR-Set durumu
`(entityType, entityId, alan)` anahtarına sığmaz (öğe başına etiket kümesi taşır); slice-3e/3f borcu.

### 1.5 Bugünkü istemci durumu (ÖLÇÜLDÜ)

| ne | ölçülen |
|---|---|
| şema sürümü | **3** (`veritabani.dart:79`); tablolar `Gorevler`, `SenkronKuyrugu`, `Ayarlar` |
| `Gorevler`'de HLC/versiyon sütunu | **HİÇ YOK** (`veritabani.dart:10-32`) ⇒ çekme bugün **kör overwrite**tan başka bir şey yapamaz |
| `senkronDurumu` CHECK | **beş değer** (`veritabani.dart:16-27`): `yerel · kuyrukta · senkronize · cakisma · cevrimdisi` |
| `changes` / `snapshot` / `hasMore` dizeleri | `src/client/lib` ağacında **SIFIR** kez geçiyor |
| çekme yolu testi | **TEK TEST YOK** |
| yalnız-çekme kod yolu | **YOK**: `_turCalistirIc()` bekleyen satır yoksa `if (secilenler.isEmpty) return;` ile **hiç istek atmadan** döner (`senkron_dongusu.dart:73-75`) |
| `actorId` kaynağı | `ayarlar.devUserId`; **aynı kaynaktan** hem `X-Momentum-Dev-User` başlığına (`http_senkron_agi.dart:33`) hem `op.actorId`'ye (`gorev_deposu.dart:99`) gider |
| `opId` üreteci | `uretimIdUret()` — **UUID v7** (`baytlar[6] = (baytlar[6] & 0x0F) \| 0x70`), `gorev_deposu.dart:230+` |
| imleç saklama | `ayarlar.nextCursorJson` — **ham metin**, `_hamCursorCikar` ile çıkarılır |

### 1.6 `owner_id` KUSURU — tasarım tercihi değil, ÖLÇÜLMÜŞ İHLAL

`SyncCommandHandler.cs` içinde **üç satır aynı dosyada birbiriyle çelişiyor**:

| satır | ne diyor |
|---|---|
| `:156` (yorum) | *"ownerId is the AUTHENTICATED actor -- NEVER op.ActorId"* (yorum ayrıca slice-3a F5'in mutantına atıf yapıyor) |
| `:157` | `MaterializeAsync(op, entity, authenticatedActorId, …)` — **kurala UYUYOR** |
| `:184` | `OwnerId: op.ActorId` — **kuralı İHLAL EDİYOR** |

Çekme **yalnız** `owner_id` süzgeciyle çalıştığı için (`SyncPuller.cs:40`) bu doğrudan **çekme
görünürlüğüdür**: gövdesinde başlıktakinden farklı bir `actorId` taşıyan bir op materyalize edilir
(`tasks` doğru yazılır) ama outbox satırı **yanlış sahibe** etiketlenir ⇒ o satır **hiç kimsenin**
çekmesinde görünmez. slice-3c §10 bunu *"slice-3d'de patlar"* diye tam olarak öngörmüştü.

[BEYAN] Bugün v7/`actorId` uyumunun tek dayanağı **istemcinin uslu davranmasıdır**: `actorId` ile başlık
aynı değişkenden gelir (§1.5). Bu bir **istemci kusuru değil, backend'de ZORLANMAMIŞ varsayımdır** —
`D8` ve `D9` tam olarak bunu zorlar.

---

## 2. Kapsam — NE VAR / NE YOK

### VAR
1. **Yalnız-çekme kod yolu** (`"ops":[]`) + tetikleyiciler + boşaltma döngüsü — `D0`, `D7`.
2. **`UzakAlanDurumu` tablosu** + şema `v3 -> v4` (TEK migration, SALT-EKLEME) — `D1`.
3. **İki ayrı ayrıştırıcı** (`changes` / `snapshot`) + projeksiyon eşlemesi — `D2`, `D4`.
4. **Yerel LWW karşılaştırıcı** (sunucunun anahtarını BİREBİR taklit eder) — `D3`.
5. **Bekleyen yerel yazımın korunması** — `D5`. **Echo uygulanır** — `D6`.
6. **Backend `opId` v7 zorlaması** — `D8`. **Backend `owner_id` düzeltmesi** — `D9`.
7. **İtme turu da yanıtı uygular** (K2) + **yutulan tetikleyici bir kez yeniden koşar** (K3) — `D0`.
8. Dokuz kapı `G1`-`G9` + kırk mutant `M1`-`M40`, hepsi KANIT'lı.

### YOK — bu dilimde YASAK
- [YASAK] **SignalR / gerçek zamanlı itme** → slice-3e. Çekme **tetiklenerek** koşar, sürekli değil.
- [YASAK] **Periyodik yoklama (polling)**. Zamanlayıcı YOK — `D0`.
- [YASAK] **OR-Set (`sets`) uygulaması** — §1.4.
- [YASAK] **`senkronDurumu` CHECK kısıtını değiştirmek / yeni rozet değeri eklemek** — `D4`.
- [YASAK] **`Gorevler` tablosuna sütun eklemek / tipini değiştirmek.** `Gorevler` **saf projeksiyon**
  kalır; LWW meta verisi **ayrı tabloda** durur (`D1`).
- [YASAK] **Backend senkron çekirdeğine `D8`/`D9` dışında dokunmak.** `SyncPuller`,
  `FieldStrategyRegistry`, `HlcClamp`, `LwwRegister`, `EntityMaterializer` **okunur, değiştirilmez**.
  İzinli tek istisna: `SyncIngest.IsEnvelopeValid` (`D8`) ve `SyncCommandHandler.BuildOutbox` (`D9`).
- [YASAK] **`DESIGN.md`'ye tek bayt** (K46). **`git add -A`** (K55). **Push** (Onur'un işi).

---

## 3. KİLİTLİ TASARIM KARARLARI (K68 + K69)

### `D0` — YALNIZ-ÇEKME KOD YOLU ve TETİKLEYİCİLER

**Yeni kod yolu:** `SenkronDongusu.cekmeTuruCalistir()` — kuyrukta bekleyen satır olup olmadığına
**bakmaz**, gövdeyi `"ops":[]` ile kurar ve gönderir. İkisi de **AYNI tek-uçuş kilidini**
(`_devamEdenTur`) paylaşır (slice-3c `D4`).

[KIRMIZI] **`turCalistir()` (İTME TURU) DA YANITI UYGULAR — K2 (Onur, kilitli).** *"Mevcut
`turCalistir()` değişmez"* cümlesi **DÜŞTÜ**. Ölçülmüş sebep: `SyncCommandHandler.Handle` **her**
yanıtta çekme yapar (`SyncCommandHandler.cs:74-95`) ve `_basariliYanitIsle` `nextCursor`'ı
**koşulsuz** kalıcılaştırır (`senkron_dongusu.dart:158-162`) ama `changes`/`snapshot`'a **hiç bakmaz**.
Yani itme turu bugün gelen veriyi **atar, imleci ilerletir** ⇒ o aralık bir daha **hiç** gelmez:
**sessiz ve KALICI veri kaybı**. İlk itme turunda `sinceCursor == null` ise atılan şey **tüm
snapshot**tur. Bu yüzden: **her iki tur da** dönen `changes`/`snapshot`'ı **aynı**
`UzakDegisiklikUygulayici`'ya verir ve **imleç ancak veri uygulandıktan SONRA** ilerler (`D7`/1).

[KIRMIZI] **YUTULAN ÇEKME TETİKLEYİCİSİ BİR KEZ YENİDEN KOŞAR — K3 (Onur, kilitli).** Tek-uçuş kilidi
devam eden turu döndürdüğünde çekme tetikleyicisi **kaybolur**: kullanıcı yenilemeye bastığı anda bir
itme turu koşuyorsa hiçbir şey çekilmez ve kullanıcıya **hiçbir geri bildirim gitmez**. Kural:
tetikleyici yutulduğunda `_cekmeBekliyor = true` bayrağı kurulur; devam eden tur bittiğinde
(`whenComplete`) bayrak doğruysa **bir kez** (ve yalnız bir kez) `cekmeTuruCalistir()` koşar ve bayrak
temizlenir. Bayrak **sayaç değildir** — yutulan on tetikleyici tek bir ek tur üretir.

[KIRMIZI] **`_turCalistirIc()`'in erken `return`'ü çekme yolunu ÖLDÜRÜR.** Bugün bekleyen satır yoksa
hiç istek atılmıyor (`senkron_dongusu.dart:73-75`); çekme bu dala **eklenemez**, **ayrı bir kod yolu**
gerektirir. Aksi hâlde uygulama, kuyruğu boş olan (yani normal) her açılışta **hiçbir şey çekmez**.

[KIRMIZI] **`"ops"` alanı ATLANAMAZ** — `SyncRequestValidator` `Ops`u `NotNull` istiyor
(`SyncRequestValidator.cs:14`) ⇒ alanı düşürmek **400** demektir ve slice-3c `D9`'a göre
*"tur DURUR, `denemeSayisi` artmaz"* — yani hata **sessizdir**, kuyruk temizdir, kimse bir şey görmez.

**Tetikleyiciler — KAPALI LİSTE (dört tanedir, beşincisi yoktur):**
1. **Uygulama açılışı:** `gonderildiKurtar()`'dan sonra **bir** çekme turu.
2. **Kullanıcı elle yenilediğinde:** bir çekme turu (mevcut listede yenileme eylemi).
3. **`hasMore == true` ve gelen sayfa BOŞ DEĞİLKEN boşaltma döngüsü** (`D7`).
4. **Yutulan tetikleyicinin ertelenmiş tekrarı (K3)** — yeni bir kaynak değil, 1 ya da 2'nin
   tek-uçuş kilidine takılmış hâlinin telafisidir; devam eden tur bittiğinde **bir kez** koşar.

[KIRMIZI] **PERİYODİK YOKLAMA YASAK.** `Timer.periodic` ile çekmek bu dilimin maliyet modelini bozar
(mobil pil + sunucu yükü) **ve** gerçek zamanlı ihtiyacı 3e'den önce sahte biçimde karşılamış gibi
görünmesine yol açar. Zamanlayıcı eklemek `G1`'in **istek sayısı** ayağını kırar.

### `D1` — `UzakAlanDurumu` tablosu; `Gorevler` SAF PROJEKSİYON kalır

| sütun | tip | not |
|---|---|---|
| `entityType` | TEXT | bu dilimde daima `Task` |
| `entityId` | TEXT | `Gorevler.id` |
| `alan` | TEXT | **kanal-nitelikli ad**: `fields:title` · `groups:completion` · `order:listPos` |
| `hlcWall` | INT | kazanan yazımın **kırpılmış** `wallMs`'i |
| `hlcCounter` | INT | kazanan yazımın `counter`'ı |
| `hlcClientId` | TEXT | kazanan yazımın `clientId`'si (**karşılaştırma için normalize edilir**, `D3`) |
| `winOpId` | TEXT | kazanan op'un `operationId`'si — tie-break anahtarı |

**Birincil anahtar: `(entityType, entityId, alan)`.**

[KIRMIZI] **`alan` KANAL-NİTELİKLİ OLMAK ZORUNDA.** Registry'de scalar `title` ile bir grup adı
çakışmasa da, `groups.completion`'ın **tek bir HLC'si** vardır ve üyeleri (`status`, `completedAt`)
**ayrı ayrı damgalanmaz** (grup yazımı REPLACE'tir). `completedAt`'ı scalar sanıp ayrı satır yazmak
grubu iki bağımsız alana böler ve REPLACE anlamını yok eder.

**Migration: `v3 -> v4`, TEK migration, SALT-EKLEME.**
```dart
if (from < 4) {
  await m.createTable(uzakAlanDurumu);
  await m.addColumn(ayarlar, ayarlar.imlecSahibi);   // D7/4 -- AYNI migration, atlanamaz
}
```
[KIRMIZI] **`addColumn` satırı bu bloğun PARÇASIDIR.** `D7`/4, `T2` ve `G2` aynı `v3 -> v4`
migration'ının `imlecSahibi` sütununu da eklemesini şart koşar; bloğu eksik kopyalayan build `G2`'de
kırmızı yanar. `addColumn` **salt-eklemedir**, tablo yeniden yaratmaz — `D1`'in kilidini bozmaz.
[KIRMIZI] **`Gorevler`'e DOKUNULMAZ, `alterTable` ÇAĞRILMAZ, CHECK/tip DEĞİŞTİRİLMEZ.** Gerekçe ölçüldü:
SQLite bir CHECK kısıtını `ALTER TABLE` ile değiştiremez ⇒ `TableMigration` tabloyu **yeniden yaratır**;
bu, "salt-ekleme" kilidini bozar, veri kopyalama riski doğurur ve `v1 -> v2`'deki (slice-3c) pahalı
yeniden-yaratmayı **ikinci kez** yapar. `schemaVersion` **3 -> 4**.

**Gerekçe (ölçüldü):** `Gorevler`'de bugün **hiç** HLC/versiyon sütunu yok (`veritabani.dart:10-32`).
Bu yüzden çekme, ayrı bir meta tablo olmadan **kör overwrite**tan başka bir şey yapamaz — hangi tarafın
daha yeni olduğunu söyleyecek veri **yerelde mevcut değildir**.

### `D2` — İKİ AYRI AYRIŞTIRICI (tek ayrıştırıcı yazmak imkânsızdır)

`UzakDegisiklikUygulayici` sınıfı **iki** genel giriş sunar:

1. `changesUygula(List<Map<String,Object?>> changes)` — her öğe `{cursor, payload}`; `payload` bir
   **WireOp**tur (§1.2). Yazımlar şöyle çıkarılır:
   `payload['fields']` (kanal `fields`, HLC yazım başına) · `payload['groups']` (kanal `groups`, HLC grup
   başına) · `payload['order']` (kanal `order`) · **tie-break** `payload['operationId']`.
2. `snapshotUygula(List<Map<String,Object?>> snapshot)` — her öğe `{entityType, entityId, scalars[],
   sets[], groups[]}`; **tie-break `winOperationId` doğrudan gelir**, uydurulmaz.

[KIRMIZI] **`null` kanal koruması PAZARLIKSIZ** — §1.2. Her kanal okuması
`(payload['groups'] as Map<String,Object?>?) ?? const {}` biçiminde yazılır.

[KIRMIZI] **BİLİNMEYEN ALAN SESSİZCE ATLANMAZ, `UzakAlanDurumu`'na YAZILIR.** `notes`, `priority`,
`dueAt` gibi bugün projeksiyonu olmayan alanlar da kaydedilir. Atlanırsa: slice-3e'de `notes` eklendiğinde
istemcinin elinde o alanın **hiç HLC'si olmaz** ⇒ ilk yazım kör overwrite'a döner. `sets` kanalı
**bilinçli** olarak yok sayılır (§1.4) ve bu **beyan edilmiş** sınırdır.

[KIRMIZI] **İKİ DAL DA UYGULANIR.** `sinceCursor == null` ⇒ `snapshot`, aksi hâlde `changes`. Bir dalı
"sonra" bırakmak = uygulamanın ilk açılışında hiçbir şey çekmemesi (§1.2).

[KIRMIZI] **SNAPSHOT BİRLEŞTİRİLİR, SIFIRLAMAZ.** `snapshotUygula` gelen her yazımı `D3`'ün **aynı
karşılaştırma yolundan** geçirir; `UzakAlanDurumu` **temizlenmez**, `Gorevler` **boşaltılmaz**. Sebep:
snapshot, `resyncRequired` sonrasında da gelir (`D7`/3) ve o anda cihazda **kuyrukta bekleyen yerel
yazımlar** olabilir; tabloyu silmek `D5`'in koruduğu tabanı yok eder ve kullanıcının gönderilmemiş
düzenlemesini geri alır.

[SINIR] **Sunucuda artık olmayan yerel satır bu dilimde SİLİNMEZ.** Snapshot bir *"tam durum"*
bildirimidir; teorik olarak yerelde olup snapshot'ta olmayan bir `entityId` **artık yok** demektir. Bu
dilimde böyle bir kesişim-farkı silme **uygulanmaz** — yanlış silmenin bedeli (veri kaybı) fazlalık
satırın bedelinden büyüktür ve GC ufku/sahiplik semantiği bu dilimde **ölçülmemiştir**. slice-3e borcu.

### `D3` — YEREL LWW: sunucunun anahtarını BİREBİR taklit et

```
alanAnahtari(hlcWall, hlcCounter, hlcClientId, opId):
  return (hlcWall, hlcCounter, normHex(hlcClientId), normHex(opId))

normHex(guidDizesi):                     // PAZARLIKSIZ
  return guidDizesi.replaceAll('-', '').toLowerCase()

karsilastir(a, b):                       // negatif/0/pozitif
  if a.wall   != b.wall   : return a.wall.compareTo(b.wall)
  if a.counter != b.counter: return a.counter.compareTo(b.counter)
  c = a.clientHex.compareTo(b.clientHex) // Dart String.compareTo = KOD BİRİMİ sırası = ordinal
  if c != 0: return c
  return a.opHex.compareTo(b.opHex)

kazandiMi(gelen, mevcut):
  if mevcut == null: return true
  return karsilastir(gelen, mevcut) > 0   // KESİN büyüklük; eşit veya küçük => mevcut KORUNUR
```

[KIRMIZI] **`normHex` PAZARLIKSIZDIR.** Sunucu `Guid.ToString("N")` (tiresiz, küçük harf) üzerinde
`StringComparer.Ordinal` kullanır (`Hlc.cs:10-25`). Dart'ta tireli/büyük harfli dizeyi karşılaştırmak
**farklı bir sıra** üretir ve iki cihaz aynı çakışmada **farklı kazanan** seçer. Dart'ın
`String.compareTo`'su UTF-16 kod birimi sırasıdır ve `normHex` çıktısı `[0-9a-f]` olduğu için
`CompareOrdinal` ile **aynı** sonucu verir — bu eşdeğerlik `G4`'te ölçülür, varsayılmaz.

[KIRMIZI] **`>` DEĞİL `>=` yazmak sessiz bozulmadır** — §1.3.

[KIRMIZI] **İKİ AYRI KARAR VARDIR — KARIŞTIRMAK `D6`'YI ÖLDÜRÜR (Ö1, pinlendi).**

| karar | taban | sonuç |
|---|---|---|
| **Meta kararı** | **yalnız** `UzakAlanDurumu` satırı | kazanırsa `UzakAlanDurumu` **her hâlükârda** güncellenir |
| **Projeksiyon kararı** | `enBuyuk(UzakAlanDurumu satırı, kuyruk tabanı)` (`D5`) | kazanırsa `Gorevler` güncellenir |

**Kuyruk tabanı YALNIZ projeksiyon yazımını kapılar.** Ölçülmüş sebep: kuyruk satırı yalnız
`Applied`/`Duplicate`'te silinir (`senkron_dongusu.dart:171-173`); echo geldiğinde aynı alanın
**kırpılmamış (daha büyük)** damgası hâlâ kuyruktadır. Tek birleşik taban kullanılırsa echo **kaybeder**
ve sunucunun **kırpılmış** damgası `UzakAlanDurumu`'na **hiç yazılmaz** ⇒ `D6`'nın tek gerekçesi çöker
ve `G5`'in iki echo ayağı doğru kodda kırmızı yanar.

### `D4` — PROJEKSİYON EŞLEMESİ ve ROZET DOKUNULMAZLIĞI

Bir yazım **meta kararını** kazandığında `UzakAlanDurumu` **her zaman** güncellenir (`D3`);
**projeksiyona** yalnız **projeksiyon kararını** da kazanmışsa ve yalnız şu üç eşleme yazılır (§1.4):
`fields:title -> baslik` · `groups:completion -> tamamlandi (status == "done", Ordinal)` ·
`fields:isDeleted -> silindi (value == "true", Ordinal)`.

**YENİ ENTITY — `Gorevler` satırı YOKSA (B3; bu olmadan `G8` ayak 2 imkânsızdır):**
`Gorevler` yedi sütunludur ve `olusturuldu`/`guncellendi` **NOT NULL**'dır (`veritabani.dart:10-32`);
telde `createdAt` **yoktur** (`olusturuldu` Task scalar listesinde yok, `FieldStrategyRegistry.cs:170`).
Bu yüzden INSERT sütun kümesi **kurala bağlanır**:

| sütun | değer |
|---|---|
| `id` | `entityId` (telden) |
| `baslik` | kazanan `fields:title` değeri; henüz yoksa **boş dize** |
| `tamamlandi` / `silindi` | kazanan eşleme; yoksa `false` |
| `olusturuldu` | **o entity için görülen EN KÜÇÜK op-HLC'sinin `wallMs`'i** (UTC) |
| `guncellendi` | **kazanan alan-HLC'sinin `wallMs`'i** (UTC) |
| `senkronDurumu` | **yazılmaz — sütun varsayılanıyla (`'yerel'`) doğar** |

[KIRMIZI] **`olusturuldu` CİHAZ SAATİNDEN YAZILAMAZ.** `saat()` kullanılırsa aynı entity iki cihazda
**iki farklı** `olusturuldu` alır; `gorevlerGorunur()` bu sütuna göre sıraladığı için **liste sırası
cihazdan cihaza değişir** ve hiçbir kapı bunu görmez. Veriden türetilen `wallMs` **deterministiktir**.

[BEYAN] Yeni entity `senkronDurumu = 'yerel'` ile doğar; bu **yanlış görünen ama bilinçli** bir
sonuçtur: `D4` rozete dokunmayı yasaklar ve CHECK sözlüğünde *"uzaktan geldi"* diye bir değer yoktur.
`olusturuldu`, `guncellendi` ve `senkronDurumu` **K1 gereği yakınsama dökümünde YER ALMAZ** (§`G6`).

[KIRMIZI] **`"True"`/`"TRUE"`/`" true"` SİLİNMİŞ SAYILMAZ.** Sunucu `status`'ü ve `isDeleted`'ı
**yorumlamaz** (slice-3c §1.3); değerler istemci sözleşmesidir. Karşılaştırma **Ordinal ve tam dize**
olmak zorundadır — `toLowerCase()` ile gevşetmek, başka bir istemcinin yazdığı `"True"`'yu silme
komutuna çevirir.

[KIRMIZI] **`senkronDurumu` (ROZET) YAZILMAZ.** Uzak değişiklik `Gorevler`'in yalnız `baslik`,
`tamamlandi`, `silindi`, `guncellendi` sütunlarına dokunur. Gerekçe (ölçüldü): CHECK kısıtı bugün beş
değerle sınırlıdır (`veritabani.dart:16-27`); `uzaktan-guncellendi` gibi yeni bir değer eklemek SQLite'ta
`ALTER TABLE` ile **yapılamaz**, tabloyu yeniden yaratmayı gerektirir ve `D1`'in *"tek migration, salt
ekleme"* kilidini bozar. Mevcut beş değerden birini yazmak da yanlıştır: `senkronize` yazmak, o satır
için kuyrukta **bekleyen** bir op varken *"gönderildi"* yalanı söyler; `cakisma` yazmak slice-3c `D5`'in
karantina anlamını çalar.

[BEYAN EDİLMİŞ SINIR] **Kullanıcı bir satırın uzaktan değiştiğini rozette GÖRMEZ.** Liste yenilenir,
değer değişir, rozet aynı kalır. Bu bilinçli bir kilittir (K69), gizlenmiş bir eksik değildir; rozet
sözlüğünün genişletilmesi slice-3e borcudur (§10).

### `D5` — BEKLEYEN YEREL YAZIM KORUNUR (K69)

[KIRMIZI] **BU TABAN YALNIZ PROJEKSİYON YAZIMINI KAPILAR** (`D3`'ün iki-karar tablosu). `UzakAlanDurumu`
kararı **asla** kuyruk tabanına bakmaz; aksi hâlde `D6` (echo) çalışmaz.

```
projeksiyonTabani(entityId, alan):
  a = UzakAlanDurumu[(Task, entityId, alan)]                  // olabilir null
  b = kuyrukEnBuyuk(entityId, alan)                           // olabilir null
  return enBuyuk(a, b)                                        // D3'un karsilastirmasiyla

metaTabani(entityId, alan):
  return UzakAlanDurumu[(Task, entityId, alan)]               // KUYRUK YOK

kuyrukEnBuyuk(entityId, alan):
  satirlar = SELECT opId, govdeJson FROM senkronKuyrugu
             WHERE entityId = ? AND durum IN ('bekliyor','gonderildi')
  en = null
  for s in satirlar:
     h = hamAlanHlcCikar(s.govdeJson, alan)   // null = op o alani YAZMIYOR (cipa yok)
     if h != null: en = enBuyuk(en, anahtar(h, s.opId))
  return en
```

[KIRMIZI] **`gonderildi` DURUMU DIŞARIDA BIRAKILAMAZ.** Uçuştaki (`gonderildi`) bir op, sunucu onu
işlemiş ama yanıt henüz dönmemişken echo olarak **geri gelebilir**; ayrıca slice-3c `D8/2` gereği
çökmeden sonra `bekliyor`e döner. Yalnız `bekliyor` taranırsa kullanıcı kendi düzenlemesinin **bir an
silinip geri geldiğini** görür — P7'nin bütün gerekçesi budur.

**Ham metin çıkarma (`hamAlanHlcCikar`) — decode/re-encode YOK** (`D1`/slice-3c: gövde yeniden
üretilmez; mevcut `_hamCursorCikar` deseninin kardeşi, `senkron_dongusu.dart:289-299`). Desenler
**pazarlıksız** olarak pinlenir; `govdeJson` `jsonEncode(WireOp.toJson())` çıktısıdır ve anahtar sırası
`toJson()` tarafından **sabittir** (`wire_op.dart`: `value` sonra `hlc`; grupta `fields` sonra `hlc`):

```dart
// kanal 'fields:<ad>' icin:
r'"<ad>":\{"value":(?:null|"(?:[^"\\]|\\.)*"),"hlc":\{"wallMs":(\d+),"counter":(\d+),"clientId":"([^"]+)"\}'
// kanal 'groups:<ad>' icin:
r'"<ad>":\{"fields":\{(?:"(?:[^"\\]|\\.)*"|[^{}])*\},"hlc":\{"wallMs":(\d+),"counter":(\d+),"clientId":"([^"]+)"\}'
```

[BEYAN] **`order` kanalı için kuyruk deseni YOKTUR** ve yazılmaz: istemcinin `WireOp.toJson()`'unda
`order` anahtarı **hiç üretilmiyor** (`wire_op.dart`) ⇒ kuyrukta böyle bir alan **asla** bulunmaz. Ölü
deseni spec'te tutmak uygulayıcıyı olmayan şeyi aramaya iter. (Gelen `changes` payload'ındaki `order`
kanalı **ayrı** bir şeydir; o `D2` yolundan okunur ve `UzakAlanDurumu`'na kaydedilir.)

[KIRMIZI] **`(?:[^"\\]|\\.)*` KAÇIŞ-DUYARLI ALTERNATİFİ SADELEŞTİRİLEMEZ.** `[^"]*` yazılırsa, başlığına
`"hlc":{"wallMs":99…` yazan bir kullanıcı deseni **kendi lehine yanıltır** ve kendi bekleyen yazımını
ezdirir. Kaçış-duyarlı alternatif JSON dizesini doğru tüketir; bu `M21` ile ölçülür.

[KIRMIZI] **FAIL-LOUD: SESSİZ `null` YALNIZ ÇIPA YOKKEN MEŞRUDUR (Ö5).** `hamAlanHlcCikar` iki farklı
olayı **aynı `null`'a** çeviremez. Kural:
```
cipa = '"<ad>":'                      // alan adinin govdede gecmesi
if (!govdeJson.contains(cipa)) return null;             // MESRU: op o alani yazmiyor
if (desen tutmadi)  throw StateError('hamAlanHlcCikar: cipa VAR, desen TUTMADI -- <ad>');
```
Sebep: desen tutmazsa (ör. grup deseninin `[^{}]` alternatifi süslü parantez içeren bir değere takılır)
sonuç sessiz `null` olur, kuyruk tabanı **boş** görünür ve **bekleyen yerel yazım sessizce ezilir** —
yani `P7` kör kalır ve `M21` bile bunu göremez. Fail-loud, bu kör noktayı **teste görünür** kılar.

### `D6` — ECHO UYGULANIR, ATILMAZ

Sunucuda `client_id` süzgeci **yoktur**; tek süzgeç `owner_id`'dir (`SyncPuller.cs:36-45`) ⇒ istemcinin
kendi op'u `changes` içinde **geri gelir**. Bu op **atlanmaz, uygulanır**.

[KIRMIZI] **DOĞRU GEREKÇE (K68'in bu noktadaki cümlesi DÜZELTİLDİ).** K68 önce *"echo'yu atmak
efektif op-HLC bilgisini kaybettirir"* diyordu; bu **yanlıştı**: efektif op-HLC'yi istemci zaten
`applied[].effectiveOpHlc` ile öğreniyor (slice-3c `D3` `yanitIsle`) ve `SyncPuller` outbox'ın `hlc`
kolonunu **SELECT ETMİYOR** (§1.1) — yani echo o bilgiyi hiç taşımıyor. **Echo'nun gerçek değeri
şudur:** atılırsa, kendi yazımının sunucudaki **KIRPILMIŞ alan-HLC'si**
(`WireMapping.ClampedPayload`, `WireMapping.cs:47-66`) `UzakAlanDurumu`'na **hiç girmez**. O zaman
istemci kendi **yerel** damgasını, karşı taraf ise **kırpılmış** damgayı taban alır ⇒ aynı çakışmada
**farklı kazanan** seçilir ve yakınsama sessizce bozulur. Kırpma gerçek bir olaydır: `HlcClamp`
her HLC'yi `serverReceiveWall + 5dk` tavanına çeker (slice-3c §1.1).

Echo `D3`'ün normal yolundan geçer ve **meta kararı yalnız `UzakAlanDurumu`'na karşı** verildiği için
(`D3` iki-karar tablosu, `D5`) kuyruktaki **kırpılmamış** damga onu **engellemez**: satır yoksa ya da
gelen anahtar büyükse `UzakAlanDurumu` **kırpılmış** değerle yazılır — çünkü sunucunun gördüğü
gerçeklik odur. Projeksiyon ise kuyruk tabanıyla kapılıdır, yani kullanıcı ekranında bir şey oynamaz.

### `D7` — İMLEÇ, BOŞALTMA DÖNGÜSÜ, KULLANICI DEĞİŞİMİ

1. `nextCursor` **ham metin** olarak `ayarlar.nextCursorJson`'a yazılır (mevcut mekanizma); `Xid`
   **ayrıştırılmaz** (§1.1).
   [KIRMIZI] **BİR SAYFA ATOMİKTİR (B4).** Bir sayfanın `changes`/`snapshot` uygulaması ve o sayfanın
   `nextCursor` yazımı **TEK `_db.transaction()`** içindedir ve **imleç EN SON yazılır**. İki ayrı
   transaction'a bölünürse şu senaryo sessiz kalıcı veri kaybı üretir: 300 değişikliğin 120'si
   uygulanır, işlem çöker/uygulama kapanır, ama imleç **zaten ilerlemiştir** ⇒ kalan 180 değişiklik
   **bir daha hiç gelmez**. Sıra da pazarlıksızdır: önce veri, sonra imleç. Ters sıra aynı kaybı
   **her** çökmede üretir. (slice-3c `D8`/1'in *"tek transaction"* kuralının çekme tarafındaki eşi.)
2. **Boşaltma döngüsü:** `hasMore == true` **ve gelen sayfa boş değilken** tur **kendini yeniden
   çağırır** (aynı tek-uçuş kilidi içinde, `while` ile) — ta ki `hasMore == false` olana kadar.
   [KIRMIZI] **`changes` (ya da `snapshot`) BOŞ gelirse `hasMore`'a BAKILMAKSIZIN döngü DURUR.** Aksi
   hâlde sunucu tarafındaki bir tutarsızlık ya da `hasMore` yanlış-pozitifi (§1.1) **20 boş tur**
   koşturur: imleç ilerlemez, veri gelmez, istek sayısı yirmiye çıkar. Tavan: **20 tur**
   (`_bosaltmaTavani`);
   tavana çarpılırsa döngü **durur** ve `sonHataKodu` yerine bir günlük satırı bırakılır.
   [BEYAN] Tavan uydurulmadı: `PageSize = 500` ile 20 tur = 10.000 değişiklik; bu dilimde bundan büyük
   bir veri kümesi **ölçülmedi** ⇒ tavanın yeterliliği `[DOGRULANMADI]`, ama **sonsuz döngü riski
   kapatıldı**.
3. **`resyncRequired == true` ⇒ saklanan imleç SİLİNİR** (slice-3c `D6`, mevcut davranış korunur) ⇒
   sonraki tur `sinceCursor` olmadan gider ve **snapshot** dalına düşer. `D2` bu yüzden iki dalı da
   uygulamak zorundadır.
   [KIRMIZI] **`UzakAlanDurumu` bu dalda KORUNUR — silinmez (Ö7).** `resyncRequired` *"imlecin GC
   ufkunun altında kaldı"* demektir, *"yerel bilgin çöp"* demek **değildir**. Meta tablosu silinirse
   gelen snapshot kör overwrite'a döner ve kuyrukta bekleyen yerel yazımların tabanı yok olur. Bu,
   `D7`/4'ün (kullanıcı değişimi) tabloyu **boşaltmasıyla** kasten asimetriktir: orada **sahip**
   değişir (veri artık bu kullanıcının değildir), burada yalnız **imleç** bayatlamıştır.

4. [KIRMIZI] **`devUserId` DEĞİŞİRSE İMLEÇ SİLİNİR.** `ayarlar` tablosunda **tek** `nextCursorJson` ve
   **tek** `devUserId` vardır. slice-3c §10 bunu *"bu dilimde pull olmadığı için gizli kalır, slice-3d'de
   patlar"* diye beyan etmişti — **patladığı dilim burasıdır**. Açılışta okunan `devUserId`, imlecin
   yazıldığı andaki `devUserId`'den farklıysa: `nextCursorJson = null` **ve** `UzakAlanDurumu`
   **tamamen boşaltılır**. Aksi hâlde önceki kullanıcının imleci yeni kullanıcının akışına uygulanır ve
   istemci, hiç görmediği bir aralığı **görmüş sayarak** kalıcı olarak eksik veriyle çalışır.
   Uygulama: `ayarlar`a `imlecSahibi` (TEXT, nullable) sütunu **eklenir** — bu da `D1`'in aynı
   `v3 -> v4` salt-ekleme migration'ının parçasıdır (`m.addColumn(ayarlar, ayarlar.imlecSahibi)`).

   **KİM, NE ZAMAN yazar (Ö4 — pinlendi):**
   - **Yazan:** `AyarlarDeposu.nextCursorKalicilastir(...)` — imleç **her** yazıldığında
     `imlecSahibi = devUserId` **AYNI transaction'da** (`D7`/1'in sayfa transaction'ı) yazılır. Ayrı
     yazım YASAK: imleç yeni sahiple, sahip alanı eski değerle kalırsa karşılaştırma **kalıcı olarak
     yanlış** cevap verir.
   - **Karşılaştıran:** `AyarlarDeposu.yukleVeyaOlustur()` — açılışta, `SenkronDongusu` kurulmadan
     **önce** koşar; `imlecSahibi != devUserId` ise `nextCursorJson = null` **ve**
     `DELETE FROM uzak_alan_durumu` **tek transaction'da** yapılır, sonra `imlecSahibi = devUserId`.
   - `imlecSahibi == null` (migration'dan gelen eski satır) **sahipsiz** sayılır: imleç **silinir**
     (temkinli yön; eski imlecin hangi kullanıcıya ait olduğu **ölçülemez**).
   [KIRMIZI] **`devUserId`'yi DEĞİŞTİREN BİR API BUGÜN YOK.** `G1`'in kullanıcı-değişimi ayağı bunu
   uydurmadan ölçemez. Zorunlu iş: `AyarlarDeposu`'na **test-görünür** bir yol açılır
   (`Future<void> devUserIdDegistir(String yeni)` — yalnız `devUserId` sütununu yazar, imlece
   **dokunmaz**); ayak DB'yi kapatıp yeniden açarak `yukleVeyaOlustur()`'u koşturur. Bu yol
   üretimde çağrılmaz ama **gizli test kancası değildir**: `AyarlarDeposu`'nun genel API'sidir ve
   slice-3e'de gerçek kimlik geldiğinde kullanılacaktır.

### `D8` — BACKEND: `opId` v7 ZORLAMASI (op bazında, isteğin geri kalanı İŞLENİR)

`SyncIngest.IsEnvelopeValid` (`SyncIngest.cs:117-136`) içine, boş-GUID kontrollerinin **hemen ardına**:

```csharp
// slice-3d D8: operationId UUIDv7 olmak ZORUNDA -- LWW tie-break'i (HlcKey) zaman-sirali
// bir opId varsayar; v4 ile tie-break yazi-turaya doner.
if ((op.OperationId.ToByteArray()[7] >> 4) != 0x7) { return false; }
```

[KIRMIZI] **BAYT DİZİLİMİ TUZAĞI — SÜRÜM NIBBLE'I `ToByteArray()`'in 7. BAYTINDADIR.**
.NET'in `Guid.ToByteArray()`'i ilk üç grubu **little-endian** yazar; RFC 9562'nin `ver` nibble'ı
dizenin 15. hane grubunun başında (`xxxxxxxx-xxxx-7xxx-…`) durur ve little-endian dizilimde bu
**indeks 7**'ye düşer. Yanlış indeks (ör. 6) seçilirse kontrol **rastgele bir bayta** bakar ve geçerli
v7 op'ları reddeder. **Bu satır uydurulmaz, `G7`'de gerçek v7 ve gerçek v4 GUID'lerle ölçülür**;
alternatif ve daha güvenli uygulama `Guid.ToString("N")[12] == '7'`dır ve **tercih edilebilir** —
seçim serbesttir, **ölçüm zorunludur**.

[KIRMIZI] **REDDİN KAPSAMI: YALNIZ O OP.** `IsEnvelopeValid` yanlış dönerse mevcut desen o op'a
`RejectedInvalid` verir ve **isteğin geri kalanı işlenmeye devam eder**. *"Tüm istek 400"* seçeneği
**REDDEDİLDİ**: bir bozuk op yüzünden 99 sağlam op'u geri çevirmek, slice-3c `D9`'un *"4xx ⇒ tur DURUR,
`denemeSayisi` artmaz"* kuralıyla birleşince kuyruğu **kalıcı olarak tıkar**.

[BEYAN] `RejectedInvalid` **dedup'a kaydedilmez** (`SyncCommandHandler.cs` ERRATA) ⇒ v4 op'u sonsuza dek
reddedilir; istemci tarafında bu satır slice-3c `D5` gereği **zehirli** olur ve kuyruğu tıkamaz.

**İstemcinin gerçekten v7 ürettiği BAĞIMSIZ ölçülür.** Bugün v7 olmasının tek dayanağı istemcinin uslu
davranmasıdır (§1.6). `G1`'de bir Dart ayağı, dört yazma yolunun ürettiği `govdeJson`'lardan
`operationId`'yi okur ve **13. hex hanesinin `'7'` olduğunu** doğrular (tireleri attıktan sonra
indeks 12). Bu ayak sunucudan bağımsızdır ve `uretimIdUret()`'i doğrudan ölçer.

### `D9` — BACKEND: `owner_id` KUSURU DÜZELTİLİR (K69)

`SyncCommandHandler.cs:184`: `OwnerId: op.ActorId` **->** `OwnerId: authenticatedActorId`.

`authenticatedActorId`, `ProcessOpAsync`'in parametresidir (`SyncCommandHandler.cs:112`); `BuildOutbox`
onu görmüyor ⇒ **imza değişir**:

```csharp
private OutboxRecord BuildOutbox(WireOp wireOp, ChangeOperation op, EntityState entity, Hlc effective,
                                 string? preProjectId, long receiveWall, Guid authenticatedActorId)
```
ve tek çağrı yeri — **`SyncCommandHandler.cs:159`**, `_outbox.WriteAsync(BuildOutbox(...), …)` —
`authenticatedActorId` ile güncellenir.

[KIRMIZI] **ATIF TUZAĞI (Ö2'de düzeltildi):** `:187` **çağrı yeri DEĞİLDİR**; `:187`
`OutboxRecord`'un **`ActorId: op.ActorId`** satırıdır — yani birkaç satır aşağıda *"DEĞİŞMEZ"* dediğimiz
alan. Çağrıyı `:187`'de arayan bir el, düzeltmesi gereken satırın yerine **dokunmaması gereken** satırı
bulur. Değişecek üç yer **tam olarak**: imza (`BuildOutbox`), çağrı (`:159`), `OwnerId` (`:184`).

[KIRMIZI] **Bu bir tasarım tercihi DEĞİL, KUSUR düzeltmesidir** — aynı dosyanın `:156` yorumu
*"ownerId is the AUTHENTICATED actor -- NEVER op.ActorId"* diyor, `:157` materialize'de öyle yapıyor,
`:184` outbox'ta ihlal ediyor (§1.6).

[BEYAN] **`ActorId: op.ActorId` DEĞİŞMEZ.** `OwnerId` *"bu satır kimin akışında görünecek"* sorusunun
cevabıdır ve **kimlik doğrulamadan** gelmek zorundadır; `ActorId` ise *"op kendini kimin adına yazdı"*
denetim kaydıdır ve gövdeden gelmesi **doğrudur**. İkisini birlikte değiştirmek denetim izini yok eder.

[BEYAN EDİLMİŞ SINIR] Bu kusurun **canlı PoC'u tasarım aşamasında koşulmadı**; mekanizma kodla ölçüldü
(§1.6). `G7` onu **gerçek PostgreSQL'e karşı** ölçer. **`G8` (F3) bu kusuru GÖRMEZ** — F3 tek kullanıcıyla
koşar, gövdedeki `actorId` başlıktakiyle aynıdır, `op.ActorId == authenticatedActorId` olur ve iki kod
yolu **ayırt edilemez**. Bu yüzden `D9`'un mutantı `G8`'de değil `G7`'dedir (`M28`).

---

## 4. Teslimat adımları (her adımın kabul kriteri ÖLÇÜLÜR)

**T1 — Yürüyen iskelet (bu adım bitmeden başka kod yazma).**
`src/client/tool/t1_yalniz_cekme_duman.dart`: `ayarlar.devUserId` ile `"ops":[]` gövdesi kurulur,
gerçek API'ye gönderilir, ham yanıt `stdout`'a basılır. Drift'e **hiçbir şey yazılmaz**.
*Kabul:* `200` alınır; `sinceCursor:null` turunda `snapshot` **dolu**, `changes` **boş**; yanıtın ham
metni `KANIT\slice-3d\01-G1-yalniz-cekme\t1-iskelet.txt`'e yazılır.

**T2 — Şema `v3 -> v4` (`D1`, `D7/4`).** `UzakAlanDurumu` tablosu + `ayarlar.imlecSahibi` sütunu +
`onUpgrade`'e `if (from < 4)` dalı (**createTable + addColumn, ikisi birden**) + `schemaVersion => 4`.
[KIRMIZI] **İKİ AYRI KOMUT GEREKİR (Ö6; slice-3c'de doğru yazılmıştı, burada gerileme oldu):**
```powershell
dart run drift_dev schema dump lib\veri\veritabani.dart drift_schemas\      # JSON: drift_schema_v4.json
dart run drift_dev schema generate drift_schemas\ test\generated_migrations\ # DART: schema_v4.dart
```
`dump` **yalnız JSON** üretir (mevcut `src\client\drift_schemas\drift_schema_v3.json` bunun çıktısıdır);
`.dart` dosyalarını **`schema generate`** üretir ve **`build_runner` bunu YAPMAZ**. Tek komutla
yetinen build `G2`'nin migration ayağını hiç koşturamaz.
*Kabul:* `G2` yeşil; `drift_schemas\drift_schema_v4.json` **ve** `test\generated_migrations\schema_v4.dart`
repoda; `Gorevler`'in `CREATE TABLE` metni v3 ve v4'te **bayt bayt aynı**.

**T3 — İki ayrıştırıcı + projeksiyon (`D2`, `D4`).** `lib/senkron/uzak_degisiklik_uygulayici.dart`:
`changesUygula` / `snapshotUygula`, kanal-nitelikli `alan` adları, `null` kanal koruması, üç alanın
projeksiyonu, rozete dokunmama, **yerelde olmayan `entityId` için INSERT** (`D4`'ün yeni-entity
tablosu: `olusturuldu` = en küçük op-HLC `wallMs`'i, `guncellendi` = kazanan alan-HLC `wallMs`'i,
`senkronDurumu` **varsayılanla**), snapshot'ın **birleştirici** olması (tablo temizlenmez).
*Kabul:* `G3` yeşil; hem `changes` hem `snapshot` gövdesi (sabit fixture JSON) doğru projeksiyon üretir;
yeni entity **INSERT edilir** ve `olusturuldu` iki farklı çalıştırmada **aynı** değeri alır.

**T4 — Yerel LWW (`D3`).** `lib/senkron/alan_anahtari.dart`: `normHex`, `karsilastir`, `kazandiMi` +
`UzakAlanDurumu` okuma/yazma **ve iki karar ayrımı** (meta tabanı = yalnız `UzakAlanDurumu`;
projeksiyon tabanı = `enBuyuk(meta, kuyruk)`). Saf sınıf; DB'ye yalnız çağıran dokunur.
*Kabul:* `G4` yeşil; sunucunun `Hlc.CompareTo` sırasıyla eşdeğerlik **tabloyla** ölçülür.

**T5 — Bekleyen yerel yazım koruması (`D5`).** `hamAlanHlcCikar` (**fail-loud**: çıpa varken desen
tutmazsa `StateError`) + `kuyrukEnBuyuk` + **yalnız projeksiyon tabanının** birleştirilmesi.
*Kabul:* `G5` yeşil; `bekliyor` **ve** `gonderildi` satırları tarandı; kaçış-duyarlı desen ayağı ve
fail-loud ayağı geçti; echo ayakları **hâlâ** yeşil (iki karar ayrımı çalışıyor).

**T6 — Çekme turu (`D0`, `D6`, `D7`).** `SenkronDongusu.cekmeTuruCalistir()`, `ops:[]` gövdesi, tek-uçuş
kilidi paylaşımı, **K3 bayrağı** (`_cekmeBekliyor`, yutulan tetikleyici bir kez yeniden koşar),
boşaltma döngüsü + tavan + **boş sayfada durma**, `resyncRequired` (imleç silinir, `UzakAlanDurumu`
korunur), `devUserId` değişimi + `imlecSahibi` (`AyarlarDeposu.yukleVeyaOlustur` /
`devUserIdDegistir`), echo'nun normal yoldan uygulanması, `main.dart`'ta açılış tetiği + listede elle
yenileme eylemi.
*Kabul:* `G1` yeşil (tetikleyici sayımı, K3 ayağı, kullanıcı değişimi ayağı dâhil); `G6` (F2) yeşil.

**T7 — İTME TURU DA UYGULAR + ATOMİK SAYFA (`D0`/K2, `D7`/1).**
`_basariliYanitIsle` yeniden düzenlenir: `applied` işlendikten **sonra** dönen `changes`/`snapshot`
**aynı** `UzakDegisiklikUygulayici`'ya verilir; sayfa uygulaması **ve** `nextCursor` yazımı **tek**
`_db.transaction()` içindedir ve imleç **en son** yazılır. `turCalistir()` ve `cekmeTuruCalistir()`
bu **aynı** yolu kullanır — kopya uygulama yolu YASAK (`tek-kopya-kapisi.py` bunu ölçer).
*Kabul:* `G5`'in dört yeni ayağı yeşil (itme turu uygular · imleç en son · tek transaction · yarım
sayfa senaryosunda imleç ilerlememiş); `M33`, `M34`, `M35` ısırır.

**T8 — Backend zorlamaları (`D8`, `D9`).** `SyncIngest.IsEnvelopeValid`'e sürüm nibble kontrolü;
`BuildOutbox` imzası + `OwnerId: authenticatedActorId`. Başka hiçbir backend dosyasına dokunulmaz.
*Kabul:* `G7` yeşil; `araclar\verify.ps1` EXIT 0; mevcut backend testlerinin **hepsi** yeşil kalır.

**T9 — F3 canlı yakınsama koşumu (`G8`).** `src/client/tool/f3_iki_istemci_yakinsama.dart`: iki ayrı
Drift dosya-DB'si (`f3-a.sqlite`, `f3-b.sqlite`), **tek** `devUserId` (aynı sahip), iki farklı
`clientId`. Sıra: A yazar+senkron -> B çeker -> B yazar+senkron -> A çeker -> iki **DAR DÖKÜM**
karşılaştırılır.

[KIRMIZI] **YAKINSAMA DÖKÜMÜ DARDIR — K1 (Onur, kilitli).** Karşılaştırma **tam olarak** şudur:
```sql
SELECT id, baslik, tamamlandi, silindi FROM gorevler ORDER BY id
```
`sha256` iddiası **yalnız bu dökümün** üstünde kurulur. `olusturuldu`, `guncellendi` ve `senkronDurumu`
**HARİÇTİR**. Ölçülmüş gerekçe: `Gorevler` yedi sütunludur (`veritabani.dart:10-32`) ama
(a) `olusturuldu` Task scalar listesinde **yoktur** (`FieldStrategyRegistry.cs:170`) ⇒ **tele hiç
çıkmaz**, B onu `D4`'ün kuralıyla türetir, A ise kendi yazımında `saat()`'ten almıştır
(`gorev_deposu.dart:112`) ⇒ ikisi **hiçbir doğru kodda** eşitlenemez; (b) `senkronDurumu` A'da
`'senkronize'` olur (`senkron_dongusu.dart:186`), B'de varsayılan `'yerel'` kalır
(`veritabani.dart:27`) çünkü `D4` uzak yazımda rozete **dokunmayı yasaklar**. Geniş döküm iddiası
**doğru kodda bile imkânsızdı**; dar döküm ölçülebilir olanı ölçer.
[SINIR] Bu üç sütunun yakınsadığı **iddia edilmiyor ve ölçülmüyor**. `guncellendi` `D4`'ün kuralıyla
türetilir ama eşitliği bu dilimde **doğrulanmamıştır**.
*Kabul:* `G8` yeşil; ham çıktı KANIT'ta; iki **dar dökümün** `sha256`'sı **eşit**.

**T10 — Mutantlar.** `M1`-`M40` **tek tek** uygulanır, hedef kapının **KIRMIZI** yandığı ölçülür, mutant
geri alınır, kapı yeniden **YEŞİL** olur. Her mutantın ham çıktısı **koşum anında** dosyaya yazılır (§8).
*Kabul:* `09-MUTANT` altında **kırk** dosya; `iddia-kapisi.py --kanit` EXIT 0.

**T11 — KANIT ve kapanış.** §8'e göre `KANIT\slice-3d\` doldurulur; `00-OZET.md` ve `HUKUM.md` yazılır.
*Kabul:* §7'nin **tamamı** ölçülmüş; `spec-kapi-kapsama.py` ve `iddia-kapisi.py` EXIT 0.

**Yeni bağımlılık YOK.** `package:http` ve `drift` zaten var; `pub-cve-kapisi.py` /
`pub-lisans-kapisi.py` yeni pin **eklenmediği için** yalnız regresyon amacıyla koşulur.

---

## 5. KAPILAR

Hüküm **çıkış kodudur**, beyan değil. Kör kapı yoktur: §6'daki mutant o kapının **gerçekten ısırdığını**
kanıtlar. Bütün Dart kapıları `src/client` dizininden koşar (`flutter test`), backend kapıları
`src/backend`'den (`dotnet test`).

### G1 — YALNIZ-ÇEKME İSTEK YOLU KAPISI (Dart birim testi, sahte ağ)
`test/g1_cekme_yolu_kapisi_test.dart`. Sahte ağ **gövdeyi kaydeder**; ayaklar gövdeye ve istek sayısına
bakar. [KIRMIZI] **Sahte ağ sunucunun sözleşmesini TAKLİT ETMEK ZORUNDA:** gövdede `ops` anahtarı
**yoksa 400 döndürür** (`SyncRequestValidator` `Ops` NotNull, §1.1). Aksi hâlde `M1` hiçbir şey
ölçmez ve kapı **kör** kalır — slice-3c `T5`'in `ops.length > 100` emsali aynıdır.

| ölçülen karar | ayak | beklenen |
|---|---|---|
| `D0` | kuyruk **boş**, `cekmeTuruCalistir()` | **bir** istek gitti (bugün: sıfır) |
| `D0` | gövde | `"ops":[]` **taşır**; `jsonDecode(govde)['ops']` boş liste |
| `D0` | tetikleyici sayımı: açılış + elle yenileme (kuyruk **boş**) | gözlenen istek sayısı **iki**, fazlası yok |
| `D0` | 5 sn sanal saat ilerletilir, hiçbir tetik yok | **ek istek YOK** (periyodik yoklama yasağı) |
| `D0` | **kuyrukta bir bekleyen op VARKEN** `turCalistir()` başlatılır, o `Future` beklenmeden `cekmeTuruCalistir()` çağrılır | tek-uçuş: **ilk** tur devam ederken **ikinci istek gitmez** |
| `D0` | (aynı ayak devam) ilk tur bittikten sonra | **K3:** yutulan çekme **bir kez** koşar ⇒ toplam istek **iki** (biri itme, biri çekme); üçüncü istek **yok** |
| `D0` | tek tur devam ederken **üç** çekme tetikleyicisi yutulur | tur bitince yalnız **bir** ek istek (bayrak sayaç değil) |
| `D7` | `hasMore: true` -> `true` -> `false` | **üç** istek; her istek öncekinin `nextCursor`'ını taşır |
| `D7` | `hasMore` daima `true`, sayfalar **dolu** | tur **20**'de durur, sonsuza gitmez |
| `D7` | `hasMore: true` ama `changes` **boş** | döngü **ilk turda DURUR** (tek istek; yirmi boş tur yok) |
| `D7` | `resyncRequired: true` | saklanan imleç **silinir**; sonraki istek `"sinceCursor":null`; `UzakAlanDurumu` satırları **AYNEN durur** |
| `D7` | `devUserIdDegistir(...)` sonrası DB kapatılıp açılır, `yukleVeyaOlustur()` koşar | `nextCursorJson` **null**, `UzakAlanDurumu` **boş**, `imlecSahibi` = yeni `devUserId` |
| `D7` | `imlecSahibi == null` olan (migration'dan gelen) satır | imleç **silinir** (sahipsiz imleç güvenilmez) |
| `D8` | dört yazma yolunun `operationId`'leri | tiresiz biçimin **13. hanesi (indeks 12) `'7'`** |

### G2 — ŞEMA / MIGRATION KAPISI (Drift, **gerçek dosya DB**)
`test/g2_migration_kapisi_test.dart`. `NativeDatabase(File(...))` — **`memory()` YASAK** (slice-3c `G3`
gerekçesi: "kapat/yeniden aç" ayağı bellekte doğru kodla da kırmızı yanar).

| ölçülen karar | ayak | beklenen |
|---|---|---|
| `D1` | `schemaVersion` | **4** |
| `D1` | `schema_v3 -> v4` migration (`generated_migrations`) | hatasız; `uzak_alan_durumu` tablosu **var** |
| `D1` | v3'te yazılmış üç `Gorevler` satırı | migration sonrası **üçü de aynen** durur |
| `D1` | `Gorevler`'in `CREATE TABLE` SQL metni (v3 vs v4) | **bayt bayt AYNI** (tabloya dokunulmadı) |
| `D1` | `UzakAlanDurumu` PK | `(entityType, entityId, alan)`; aynı üçlü ikinci kez yazılınca **upsert**, kopya satır **doğmaz** |
| `D1` | `ayarlar.imlecSahibi` | sütun **var**, eski satırlarda `null` |

### G3 — İKİ AYRIŞTIRICI + PROJEKSİYON KAPISI (Dart birim testi; ağ YOK)
`test/g3_ayristirici_kapisi_test.dart`. Girdi: **elle yazılmış sabit fixture JSON**'lar
(`test/destekler/fixture_changes.json`, `fixture_snapshot.json`) — sunucudan ölçülmüş şekle birebir uyar.

| ölçülen karar | ayak | beklenen |
|---|---|---|
| `D2` | `changes` fixture'ı | `fields.title` + `groups.completion` okundu; projeksiyon güncellendi |
| `D2` | `snapshot` fixture'ı | `scalars[]`/`groups[]` okundu; `winOperationId` **doğrudan** kullanıldı |
| `D2` | `"sets":null,"order":null` taşıyan payload | **çökme yok**, kanal boş sayıldı |
| `D2` | `notes`/`priority` taşıyan payload | `UzakAlanDurumu`'nda **satır var**, `Gorevler` **değişmedi** |
| `D2` | `"sets":[…]` taşıyan snapshot | yok sayıldı, çökme yok, `UzakAlanDurumu`'na **yazılmadı** |
| `D4` | `completion.status == "open"` | `tamamlandi == false` |
| `D4` | `completion.status == "done"` | `tamamlandi == true` |
| `D4` | `isDeleted.value == "True"` (büyük T) | `silindi` **false kalır** (Ordinal, tam dize) |
| `D4` | uygulama sonrası `senkronDurumu` | **değişmedi** (rozete dokunulmadı) |
| `D4` | **yerelde OLMAYAN** `entityId` taşıyan `changes` | `Gorevler`'e **INSERT** edildi; `baslik` telden, `senkronDurumu == 'yerel'` (varsayılan) |
| `D4` | aynı fixture **iki kez** ve **iki farklı** sanal saatle uygulanır | `olusturuldu` **iki koşumda da AYNI** (en küçük op-HLC `wallMs`'i; cihaz saatinden değil) |
| `D2` | dolu bir `UzakAlanDurumu` + `Gorevler` üstüne **snapshot** uygulanır | tablolar **temizlenmedi**; snapshot'ta olmayan yerel satır **duruyor**; her alan `D3` yolundan geçti |

### G4 — LWW KARŞILAŞTIRMA KAPISI (Dart birim testi, saf sınıf)
`test/g4_lww_kapisi_test.dart`.

| ölçülen karar | ayak | beklenen |
|---|---|---|
| `D3` | `wallMs` farklı | büyük `wallMs` kazanır |
| `D3` | `wallMs` eşit, `counter` farklı | büyük `counter` kazanır |
| `D3` | `wallMs`+`counter` eşit, `clientId` farklı | **tiresiz küçük harf hex** ordinal sırası kazanır |
| `D3` | `clientId` **tam olarak** `"00000000-0000-0000-0000-0000000000ff"` vs `"0000000a-…-000000000000"` | tireli dize sırası ile **normalize** sıra farklı sonuç verir; beklenen **normalize** olan |
| `D3` | anahtarın **tamamı** eşit | mevcut **KORUNUR** (kesin büyüklük) |
| `D3` | HLC eşit, `opId` farklı | `opId`'nin **tiresiz** ordinal sırası tie-break |
| `D3` | 200 rastgele çift, Dart sırası vs **beklenen ordinal hex** sırası | **birebir aynı** (Dart `compareTo` eşdeğerliği ölçülür, varsayılmaz) |

### G5 — YEREL KORUMA / ROZET / ECHO KAPISI (Dart, gerçek dosya DB + sahte ağ)
`test/g5_yerel_koruma_kapisi_test.dart`.

| ölçülen karar | ayak | beklenen |
|---|---|---|
| `D5` | kuyrukta `bekliyor` op (HLC büyük), uzak yazım (HLC küçük) gelir | projeksiyon **yerel değeri korur** |
| `D5` | aynı senaryo, kuyruk satırı `gonderildi` | projeksiyon **yine yerel değeri korur** |
| `D5` | kuyrukta op **yok** | uzak değer **uygulanır** |
| `D5` | `baslik` değeri **tam olarak** `{"value":"a\"hlc\":{\"wallMs\":9999999999999,…","hlc":…}` üretecek bir metin | desen yanılmaz; doğru HLC okunur |
| `D6` | `changes`'te **kendi `clientId`'li** echo op'u | **uygulanır**; `UzakAlanDurumu` sunucunun (kırpılmış) HLC'siyle yazılır |
| `D6` | echo sonrası `UzakAlanDurumu.hlcWall` | gövdedeki yerel damga **değil**, yanıttaki damga |
| `D6` | echo, **aynı alan için kuyrukta `bekliyor` op VARKEN** gelir | `UzakAlanDurumu` **yine yazılır** (meta kararı kuyruğa bakmaz); `Gorevler` **değişmez** |
| `D5` | `hamAlanHlcCikar`: gövdede `"title":` çıpası **var**, desen bozulmuş | **`StateError` fırlatır** (sessiz `null` YOK) |
| `D5` | gövdede `"notes":` çıpası **yok** | sessiz `null` (meşru dal), istisna **yok** |
| `D4` | uzak yazım uygulandıktan sonra `senkronDurumu` | **değişmedi** |
| `D0` | **itme turu** (`turCalistir()`) yanıtı `changes` taşır | değişiklikler **uygulanır** (bugün: atılıyor) |
| `D0` | ilk itme turu, `sinceCursor == null`, yanıt `snapshot` taşır | snapshot **uygulanır**; hiçbir entity kaybolmaz |
| `D7` | sayfa uygulaması ile imleç yazımının sırası (log/çağrı kaydı) | imleç **EN SON** yazıldı |
| `D7` | uygulama ortasında fırlatan sahte uygulayıcı (yarım sayfa) | **tek transaction** geri sarıldı: `nextCursorJson` **eski değerinde**, uygulanan satır **yok** |

### G6 — F2 UCUZ YAKINSAMA KAPISI (Dart, **iki Drift DB + sahte sunucu**, saniyeler)
`test/g6_f2_yakinsama_kapisi_test.dart`. `SahteSunucu` sınıfı: bellek içi outbox tutar, `owner_id`
süzgecini uygular, **her HLC'yi `receiveWall + 300000` tavanına kırpar**, `PageSize` uygular ve
`changes`/`snapshot` şekillerini **ölçülmüş biçimde** üretir.

[BEYAN EDİLMİŞ SINIR] **`SahteSunucu` SUNUCU DEĞİLDİR** — sunucunun `LwwRegister`'ını, registry
doğrulamasını ve Postgres imleç semantiğini taklit etmez; yalnız tel şeklini + kırpmayı + sahip
süzgecini taşır. **Yakınsamanın otoritesi `G8`'dir (F3).** `G6` ucuz bir regresyon ağıdır.

| ölçülen karar | ayak | beklenen |
|---|---|---|
| `D3` | A yazar -> B çeker -> B yazar -> A çeker | iki **DAR DÖKÜM** bayt-özdeş (`sha256` eşit) — döküm `T9`'da pinlendi: `SELECT id, baslik, tamamlandi, silindi FROM gorevler ORDER BY id` |
| `D3` | aynı alana **eşzamanlı** iki yazım (farklı `clientId`, aynı `wallMs`+`counter`) | iki istemci **AYNI kazananı** seçer |
| `D5` | A'nın bekleyen düzenlemesi varken A çeker | çekmeden **hemen sonra** okunan A projeksiyonu **A'nın bekleyen değerini** taşır |
| `D0` | ikinci tur | `sinceCursor` **dolu** gider (snapshot dalına dönmez) |

### G7 — BACKEND ZORLAMA KAPISI (xUnit; `owner_id` ayağı **gerçek PostgreSQL**)
`Momentum.Domain.Tests/Sync/SyncIngestV7Tests.cs` (saf, DB'siz) +
`Momentum.Persistence.Tests` içinde `owner_id` ayağı (Testcontainers).

| ölçülen karar | ayak | beklenen |
|---|---|---|
| `D8` | `operationId` **gerçek v7** (`uretimIdUret` biçimi) | `Applied` |
| `D8` | `operationId` **gerçek v4** (`Guid.NewGuid()`) | **`RejectedInvalid`** |
| `D8` | 3 op'luk istek: v7, v4, v7 | `Applied`, `RejectedInvalid`, `Applied` — **istek 400 DEĞİL** |
| `D8` | v4 op'u ikinci kez gönderilir | yine `RejectedInvalid` (dedup'a kaydedilmez, ERRATA) |
| `D9` | başlık `actorId = X`, gövde `op.actorId = Y` (X != Y), sonra `X` ile çekilir | satır **X'in `changes`'inde görünür** |
| `D9` | aynı op, `Y` ile çekilir | satır **görünmez** |
| `D9` | `SELECT owner_id, actor_id FROM outbox_messages WHERE operation_id = @op` | `owner_id == X` **ve** `actor_id == Y` |

### G8 — F3 CANLI YAKINSAMA KAPISI (**gerçek backend + gerçek PostgreSQL**, `Development`)
Ön koşul: `momentum-postgres` Up (healthy) · `araclar\verify.ps1` EXIT 0 · API `Development`'ta ayakta.
Koşum: `dart run tool/f3_iki_istemci_yakinsama.dart` (cwd = `src/client`).

| ölçülen karar | ayak | beklenen |
|---|---|---|
| `D7` | **1:** A ve B ilk kez açılır (imleç yok) | ikisi de **snapshot** dalını alır, `nextCursor` saklanır |
| `D2` | **2:** A bir görev yazar + senkron; B çeker | B'nin projeksiyonunda görev **var**, alanları A'nınkiyle **birebir** |
| `D3` | **3:** B başlığı değiştirir + senkron; A çeker | A'nın başlığı B'nin değeriyle **aynı** |
| `D3` | **4:** iki tarafın **DAR DÖKÜMÜ** (`SELECT id, baslik, tamamlandi, silindi FROM gorevler ORDER BY id`) | **bayt-özdeş** (`sha256` eşit). `olusturuldu`/`guncellendi`/`senkronDurumu` **karşılaştırılmaz** — K1, gerekçesi `T9`'da |
| `D5` | **5:** A yerel düzenleme yapar (kuyrukta bekliyor), sonra A çeker | çekme **hemen sonrası** A'nın başlığı **A'nın bekleyen değeri** |
| `D3` | **6:** A ve B aynı alanı çevrimdışı yazar, sonra ikisi de senkron+çeker | ikisi de **aynı** kazananda durur |

[KIRMIZI] **Ayak 5 SIRALAMA HASSASTIR.** A'nın bekleyen op'u gönderilirse sunucu A'nın (daha büyük)
damgasını kabul eder ve **her iki taraf da** A'nın değerine yakınsar — yani kusur sonunda **kaybolur**.
`D5`'in koruduğu şey **geçici** bir görünümdür: kullanıcı kendi düzenlemesinin silinip geri geldiğini
görür. Bu yüzden ayak 5 A'nın projeksiyonunu **çekmeden hemen sonra, A'nın push'undan ÖNCE** okur.
Ölçüm bu sırada yapılmazsa ayak **kör** olur ve `M31` ısırmaz.

[BEYAN EDİLMİŞ SINIR] **F3 tek sahiple (tek `devUserId`) koşar** ⇒ `D9`'un kusurunu **göremez** (§`D9`).
İki farklı sahiple çekme görünürlüğü `G7`'de ölçülür.

### G9 — REGRESYON KAPISI
| ölçülen karar | ayak | beklenen |
|---|---|---|
| — | `flutter analyze --fatal-infos` | **0 bulgu** |
| — | `flutter test` | mevcut **ve** yeni testlerin hepsi yeşil, EXIT 0 |
| — | `araclar\verify.ps1` | build 0 uyarı/0 hata, testler yeşil, CVE 0, EXIT 0 |
| — | `python araclar\design-token-kapisi.py .` | EXIT 0 |
| — | `python araclar\tek-kopya-kapisi.py .` | EXIT 0 |
| — | `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-slice-3d-cekme.md` | EXIT 0 |
| — | `python araclar\iddia-kapisi.py GOREV_CLAUDE_CODE\GOREV-slice-3d-cekme.md --kanit KANIT\slice-3d` | EXIT 0 |

> [UYARI] `flutter test` bu ortamda `PROGRAMFILES(X86)=C:\Program Files (x86)` **enjekte edilmeden**
> çöker. `flutter test --platform chrome` **sonuç üretmiyor** ⇒ web test ayağı `[DOGRULANMADI]` kalır,
> uydurulmaz. iOS yalnız CI'da derlenir.
> [UYARI] Çıkış kodu **`cmd /v:on /c "... & echo EXIT=!ERRORLEVEL!"`** ile ölçülür;
> `cmd /c "... %ERRORLEVEL%"` **KÖRDÜR** (genişletme erken olur, sahte `0` verir).

---

## 6. MUTANTLAR — kırk; KAPALI ve numaralı liste

**Kural:** mutant **tek tek** uygulanır -> kapının **KIRMIZI** yandığı ölçülür -> mutant **geri alınır**
-> kapı yeniden **YEŞİL** olur. Isırmayan mutant, kapının **kör** olduğunun kanıtıdır; **kapı düzeltilir,
mutant gevşetilmez** (slice-3c §9/11).

**Maliyet sınıfı (K53 madde 3):** koşan uygulama isteyen mutantlar yalnız `M29`, `M30`, `M31`'dir
(tavan üç). Kalan mutantların hepsi statik / birim / widget sınıfındadır ⇒ **tavansız**.
`M29` ve `M31`, `M24`/`M25`'in **aynı bozmalarının canlı tekrarıdır**; bu bilinçlidir — her kapı
kendi ısırma kanıtını taşır (`G6` sahte sunucuya, `G8` gerçek sunucuya karşı) ve eşdeğer-mutant
şişirmesi değildir.

| # | mutant (kodda yapılan bozma) | kapı / kural | beklenen |
|---|---|---|---|
| **M1** | Yalnız-çekme gövdesinden `"ops":[]` alanını çıkar | G1 / D0 | sahte ağ **400** döner; gövde ayağı düşer ⇒ **KIRMIZI** |
| **M2** | `cekmeTuruCalistir()`'i `turCalistir()`'e çevir (bekleyen yoksa erken `return`) | G1 / D0 | kuyruk boşken **sıfır** istek ⇒ **KIRMIZI** |
| **M3** | `hasMore` boşaltma döngüsünü kaldır (tek tur) | G1 / D7 | üç-istek ayağı düşer ⇒ **KIRMIZI** |
| **M4** | `Timer.periodic(2s, cekmeTuruCalistir)` ekle | G1 / D0 | sanal saat ayağında **ek istek** görülür ⇒ **KIRMIZI** |
| **M5** | `uretimIdUret`'te sürüm nibble'ını `0x70` yerine `0x40` yaz | G1 / D8 | v7 ayağı düşer (13. hane `'4'`) ⇒ **KIRMIZI** |
| **M6** | `devUserId` değişince imleci/`UzakAlanDurumu`'nu silme kuralını kaldır | G1 / D7 | kullanıcı değişimi ayağı düşer ⇒ **KIRMIZI** |
| **M7** | `v3 -> v4` dalına `alterTable(TableMigration(gorevler))` ekle | G2 / D1 | `Gorevler` `CREATE TABLE` metni değişir ⇒ **KIRMIZI** |
| **M8** | `UzakAlanDurumu`'nu yalnız `onCreate`'e ekle, `onUpgrade` dalına ekleme | G2 / D1 | migration ayağı "tablo yok" ile düşer ⇒ **KIRMIZI** |
| **M9** | `changes` ayrıştırıcısını `snapshot` şekline göre yaz (`scalars` oku) | G3 / D2 | `changes` fixture'ı hiçbir şey uygulamaz ⇒ **KIRMIZI** |
| **M10** | `snapshot` dalını yok say (yalnız `changes` uygula) | G3 / D2 | snapshot fixture ayağı düşer ⇒ **KIRMIZI** |
| **M11** | `null` kanal korumasını kaldır (`as Map` doğrudan cast) | G3 / D2 | `"sets":null` payload'ında **çöker** ⇒ **KIRMIZI** |
| **M12** | Bilinmeyen alanı (`notes`/`priority`) `UzakAlanDurumu`'na yazmadan atla | G3 / D2 | ileri uyumluluk ayağı düşer ⇒ **KIRMIZI** |
| **M13** | `tamamlandi` eşlemesini `status.isNotEmpty` yap | G3 / D4 | `status == "open"` ayağı düşer ⇒ **KIRMIZI** |
| **M14** | `isDeleted` karşılaştırmasını `toLowerCase() == "true"` yap | G3 / D4 | `"True"` ayağı düşer ⇒ **KIRMIZI** |
| **M15** | `normHex`'i kaldır (tireli, olduğu gibi karşılaştır) | G4 / D3 | tire-tuzağı ayağı ve 200-çift eşdeğerliği düşer ⇒ **KIRMIZI** |
| **M16** | Kazanma koşulunu `>= 0` yap | G4 / D3 | "eşit anahtar mevcudu korur" ayağı düşer ⇒ **KIRMIZI** |
| **M17** | `opId` tie-break'ini kaldır (HLC eşitse 0 dön) | G4 / D3 | tie-break ayağı düşer ⇒ **KIRMIZI** |
| **M18** | `counter` karşılaştırmasını atla (yalnız `wall`) | G4 / D3 | `counter` ayağı düşer ⇒ **KIRMIZI** |
| **M19** | Karşılaştırma tabanına kuyruğu hiç katma (yalnız `UzakAlanDurumu`) | G5 / D5 | bekleyen yazım ezilir ⇒ **KIRMIZI** |
| **M20** | Kuyruk taramasında yalnız `durum='bekliyor'` say (`gonderildi` hariç) | G5 / D5 | uçuş ayağı düşer ⇒ **KIRMIZI** |
| **M21** | Ham desendeki kaçış-duyarlı dize alternatifini `[^"]*` ile değiştir | G5 / D5 | kaçış-tuzağı ayağı düşer (yanlış HLC okunur) ⇒ **KIRMIZI** |
| **M22** | Uzak uygulamada `senkronDurumu`'na `'senkronize'` yaz | G5 / D4 | rozet dokunulmazlığı ayağı düşer ⇒ **KIRMIZI** |
| **M23** | Echo'yu at (`payload.clientId == kendi clientId` ise atla) | G5 / D6 | `UzakAlanDurumu` kırpılmış damga yerine hiç yazılmaz ⇒ **KIRMIZI** |
| **M24** | `UzakAlanDurumu` yazımını kaldır (kör overwrite) | G6 / D3 | bayt-özdeşlik ve "aynı kazanan" ayakları düşer ⇒ **KIRMIZI** |
| **M25** | Bekleyen yerel yazım korumasını kaldır | G6 / D5 | F2'nin bekleyen-yazım ayağı düşer ⇒ **KIRMIZI** |
| **M26** | `IsEnvelopeValid`'den sürüm nibble kontrolünü kaldır | G7 / D8 | v4 op'u `Applied` döner ⇒ **KIRMIZI** |
| **M27** | Nibble ihlalinde **tüm isteği** 400 yap (op-bazlı desen bozulur) | G7 / D8 | "v7, v4, v7" ayağı düşer ⇒ **KIRMIZI** |
| **M28** | `OwnerId: authenticatedActorId` düzeltmesini geri al (`op.ActorId`) | G7 / D9 | gövde `actorId`'si başlıktan farklı op **X'in çekmesinde görünmez** ⇒ **KIRMIZI** |
| **M29** | (koşan) Canlıda `UzakAlanDurumu` yazımını kaldır | G8 / D3 | ayak 4'te `sha256` ayrışır ⇒ **KIRMIZI** |
| **M30** | (koşan) Canlıda `changes` dalını yok say (yalnız `snapshot`) | G8 / D2 | ayak 3'te A, B'nin başlığını hiç görmez ⇒ **KIRMIZI** |
| **M31** | (koşan) Canlıda bekleyen yerel yazım korumasını kaldır | G8 / D5 | ayak 5'te A'nın başlığı bir an B'nin değerine düşer ⇒ **KIRMIZI** |
| **M32** | Bir dosyaya `info` seviyesinde analyzer ihlali ekle | G9 | `--fatal-infos` ısırmalı ⇒ **KIRMIZI** |
| **M33** | İtme turunda (`turCalistir()`) dönen `changes`/`snapshot`'ı uygulama (slice-3c davranışı) | G5 / D0 | itme-turu ayakları düşer; snapshot sessizce kaybolur ⇒ **KIRMIZI** |
| **M34** | İmleç yazımını sayfa uygulamasından **ÖNCEYE** al | G5 / D7 | sıra ayağı düşer; yarım sayfada imleç ilerlemiş olur ⇒ **KIRMIZI** |
| **M35** | Sayfa uygulaması ile imleç yazımını **iki ayrı** `transaction`'a böl | G5 / D7 | geri sarma ayağı düşer (`nextCursorJson` ilerlemiş kalır) ⇒ **KIRMIZI** |
| **M36** | K3 bayrağını (`_cekmeBekliyor`) kaldır — yutulan tetikleyici kaybolsun | G1 / D0 | K3 ayağında ikinci istek hiç gelmez ⇒ **KIRMIZI** |
| **M37** | `hamAlanHlcCikar`'da çıpa varken desen tutmazsa `StateError` yerine `null` dön | G5 / D5 | fail-loud ayağı düşer ⇒ **KIRMIZI** |
| **M38** | Yeni entity INSERT'inde `olusturuldu`'yu `saat()`'ten yaz | G3 / D4 | determinizm ayağı düşer (iki koşum farklı değer) ⇒ **KIRMIZI** |
| **M39** | Boş sayfada durma kuralını kaldır (yalnız `hasMore`'a bak) | G1 / D7 | boş-sayfa ayağı düşer (bir yerine yirmi istek) ⇒ **KIRMIZI** |
| **M40** | `snapshotUygula`'nın başına `DELETE FROM uzak_alan_durumu` + `gorevler` temizliği ekle | G3 / D2 | birleştirme ayağı düşer (yerel satır kaybolur) ⇒ **KIRMIZI** |

**Koşan-uygulama mutantları: `M29`, `M30`, `M31` — tavan üç, aşılmadı.** `M33`-`M40` **statik/birim**
sınıfındadır (sahte ağ + bellek/dosya DB, saniyeler) ⇒ tavansız.

---

## 7. Kabul kriterleri (hepsi ölçülür; beyan kabul edilmez)

1. `G1`-`G9` **koştu** ve hepsi **YEŞİL**; her kapının çıkış kodu KANIT'ta (`cmd /v:on` ölçümüyle).
2. `M1`-`M40`'ın tamamı tek tek uygulandı, hedef kapı **KIRMIZI** yandı, mutant geri alındı, kapı
   **YEŞİL** döndü. Isırmayan mutant varsa **kapı düzeltilir** ve durum §10'a yazılır — **kör kapı
   teslim edilmez.**
3. Her mutantın ham çıktısı **koşum anında** `KANIT\slice-3d\09-MUTANT\` altına yazıldı (§8 şeması).
4. `flutter analyze --fatal-infos` **0 bulgu**; `flutter test` EXIT 0; `araclar\verify.ps1` EXIT 0.
5. `python araclar\tek-kopya-kapisi.py .` ve `python araclar\design-token-kapisi.py .` EXIT 0.
6. `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-slice-3d-cekme.md` EXIT 0 **ve**
   `python araclar\iddia-kapisi.py GOREV_CLAUDE_CODE\GOREV-slice-3d-cekme.md --kanit KANIT\slice-3d`
   EXIT 0 **ve** `python araclar\sayi-tazeligi.py .` EXIT 0.
   [UYARI] Bu araçlar mutantın **ISIRDIĞINI ölçmez**, yalnız kapsamayı ve iddia tutarlılığını ölçer
   (ikisi de bu sınırı kendileri beyan ediyor). EXIT 0, kriter 2'nin yerine **geçmez**.
7. **Backend'de yalnız iki nokta değişti** — kanıt taban ref'e karşı alınır:
   `git --no-optional-locks diff --stat <slice-3c-kapanis-ref>..HEAD -- src/backend/` ⇒ yalnız
   `Momentum.Domain/Sync/SyncIngest.cs` (`D8`) ve
   `Momentum.Application/Features/Sync/SyncCommandHandler.cs` (`D9`) + yeni test dosyaları.
8. `G8` (F3) **gerçek backend + gerçek PostgreSQL**'e karşı koştu; altı ayağın ham çıktısı ve iki
   projeksiyonun `sha256` değerleri KANIT'ta.
9. Uygulama Android'de **açıldı ve çalıştı** (ekran görüntüsü); açılışta çekme turu koştu ve uzaktan
   gelen bir görev listede **göründü**.
10. `schemaVersion == 4`; `test/generated_migrations/schema_v4.dart` repoda; `Gorevler`'in `CREATE TABLE`
    metni v3 ile **bayt bayt aynı**.
11. **Ölçmediğin hiçbir şey "temiz" sayılmadı**: web ayağı `[DOGRULANMADI]`, iOS `[DOGRULANMADI]`,
    boşaltma tavanının yeterliliği `[DOGRULANMADI]` olarak §10'da duruyor.

---

## 8. KANIT protokolü — `KANIT\slice-3d\`  [SART: PAZARLIKSIZ]

```
KANIT\slice-3d\
  00-OZET.md                      <- her kapi: komut, cikis kodu, tek satir hukum
  01-G1-yalniz-cekme\             <- t1-iskelet.txt + G1 test ciktisi + kaydedilen ham govdeler
  02-G2-migration\                <- test ciktisi + v3/v4 CREATE TABLE dokumu
  03-G3-ayristirici\              <- test ciktisi + iki fixture'in kopyasi
  04-G4-lww\                      <- test ciktisi + 200-cift esdegerlik ozeti
  05-G5-yerel-koruma\             <- test ciktisi
  06-G6-f2-yakinsama\             <- test ciktisi + iki projeksiyonun sha256'si
  07-G7-backend-zorlama\          <- dotnet test ciktisi + outbox SQL sorgu ciktisi
  08-G8-f3-canli\                 <- alti ayagin ham cikti + iki projeksiyon sha256
  09-MUTANT\                      <- M1..M40: her biri icin AYRI dosya (asagidaki desen)
  10-G9-regresyon\                <- analyze, flutter test, verify.ps1, kapi betikleri
  HUKUM.md                        <- nihai karar; her iddia bir dosyaya ATIF yapar
```

### 8.1 Mutant kanıtı — dosya adı deseni ve onu YAZAN taraf

**Her mutantın ham çıktısı KOŞUM ANINDA şu yola yazılır:**
`KANIT\slice-3d\09-MUTANT\Mnn-<kisa-ad>.txt`

[KIRMIZI] **SIFIR DOLGUSU YASAK.** `M1-...txt` yazılır, `M01-...txt` **yazılmaz**. Ölçülmüş sebep:
`araclar\iddia-kapisi.py` kimliği `\bM(\d{1,3}[a-z]?)\b` deseniyle okur; `M01` **`M1` değildir** ⇒
kapı aynı anda `I2 KANITSIZ MUTANT` **ve** `I3 HAYALET KANIT` verir.

[KIRMIZI] **`<kisa-ad>` SAF ASCII olacak** (K56: yol adında Türkçe karakter yasak). Örnekler:
`M1-ops-alani-yok.txt` · `M15-normhex-yok.txt` · `M28-ownerid-geri.txt` · `M31-canli-bekleyen-koruma.txt`.

[KIRMIZI] **HER MUTANT DOSYASI YALNIZ KENDİ KİMLİĞİNİ ANAR.** `iddia-kapisi.py`
`LISTE_ESIGI = 8`'dir: sekiz ya da daha fazla farklı `Mnn` kimliği taşıyan dosya **ENVANTER** sayılır ve
kanıt **kabul edilmez**. Toplu çıktıyı tek dosyaya yığmak bütün mutant kanıtını **çöpe atar**.

[KIRMIZI] **`00-OZET.md` ve `HUKUM.md` KANIT SAYILMAZ** (dairesel kanıt yasağı, `iddia-kapisi.py`
`kanit_mutantlari`). Onlar hükümdür; kanıt ham çıktıdır.

**Her mutant dosyasının içeriği (dört bölüm, bu sırayla):**
1. `MUTANT Mnn -- <kapi>/<kural>` ve **uygulanan bozmanın diff'i** (`git --no-optional-locks diff`).
2. Mutant **uygulanmışken** kapının ham çıktısı + `EXIT=<n>` satırı (**n != 0 olmalı**).
3. Mutant **geri alındıktan sonra** kapının ham çıktısı + `EXIT=0` satırı.
4. Bir satırlık hüküm: `ISIRDI` ya da `ISIRMADI`.

**Koşum kalıbı (PowerShell; çıkış kodu körlüğüne karşı `cmd /v:on`):**
```powershell
$k = "C:\dev\Momentum\KANIT\slice-3d\09-MUTANT\M1-ops-alani-yok.txt"
cmd /v:on /c "cd /d C:\dev\Momentum\src\client && flutter test test\g1_cekme_yolu_kapisi_test.dart & echo EXIT=!ERRORLEVEL!" *>&1 |
  Tee-Object -FilePath $k -Append
```

### 8.2 KANIT yolunu YAZAN TARAF — her dosya için pinlenir

[KIRMIZI] **slice-3c'de kusur buradaydı:** `g2_registry_zarf_kapisi_test.dart:64`
`Directory('../../KANIT/slice-3c/02-G2')` yoluna yazıyordu, spec ise şemayı `02-G2-registry-zarf/`
diye yazmıştı ⇒ **spec ile kod farklı yolu gösteriyordu**. Bu dilimde her kanıt dosyasının **yazan
tarafı** tabloya girer ve **dizin adı kodla birebir aynı** olur.

| kanıt | yazan taraf | yol (koddaki literal) |
|---|---|---|
| `01-.../t1-iskelet.txt` | `tool/t1_yalniz_cekme_duman.dart` (`dart:io`) | `../../KANIT/slice-3d/01-G1-yalniz-cekme` |
| `01-.../g1-govdeler.txt` | `test/g1_cekme_yolu_kapisi_test.dart` (`dart:io`) | `../../KANIT/slice-3d/01-G1-yalniz-cekme` |
| `02-.../create-table-v3-v4.txt` | `test/g2_migration_kapisi_test.dart` (`dart:io`) | `../../KANIT/slice-3d/02-G2-migration` |
| `03-.../fixture-*.json` | `test/g3_ayristirici_kapisi_test.dart` (`dart:io`) | `../../KANIT/slice-3d/03-G3-ayristirici` |
| `04-.../esdegerlik.txt` | `test/g4_lww_kapisi_test.dart` (`dart:io`) | `../../KANIT/slice-3d/04-G4-lww` |
| `06-.../sha256.txt` | `test/g6_f2_yakinsama_kapisi_test.dart` (`dart:io`) | `../../KANIT/slice-3d/06-G6-f2-yakinsama` |
| `07-.../dotnet-test.txt` | **PowerShell komut satırı** (`Tee-Object -FilePath`) | mutlak: `C:\dev\Momentum\KANIT\slice-3d\07-G7-backend-zorlama\dotnet-test.txt` |
| `07-.../outbox-sorgu.txt` | **`owner_id` ayağının KENDİSİ** (`Momentum.Persistence.Tests`, `File.WriteAllText`) — sorgu Testcontainers içinde koşar, PowerShell o bağlantıyı **göremez** | mutlak, ortam değişkeninden: `MOMENTUM_KANIT_DIZIN` (yoksa test **fırlatır**, sessizce atlamaz) |
| `08-.../f3-*.txt` | `tool/f3_iki_istemci_yakinsama.dart` (`dart:io`) | `../../KANIT/slice-3d/08-G8-f3-canli` |
| kapı test/derleme çıktıları (`05`, `10`) | **PowerShell komut satırı** (`Tee-Object -FilePath`) | mutlak: `C:\dev\Momentum\KANIT\slice-3d\<dizin>\<ad>.txt` |
| `09-MUTANT\Mnn-*.txt` | **PowerShell koşum kalıbı** (§8.1) | mutlak: `C:\dev\Momentum\KANIT\slice-3d\09-MUTANT\` |

[KIRMIZI] **Dart tarafındaki göreli yollar cwd = `src\client` VARSAYAR** (`flutter test` /
`dart run tool\...` oradan koşar). Başka bir dizinden koşulursa kanıt **yanlış yere** düşer; her test
dosyası yazmadan önce `Directory(...).createSync(recursive: true)` çağırır ve **mutlak** çözülmüş yolu
`stdout`'a basar (böylece 00-OZET.md'de yol doğrulanabilir).

[KIRMIZI] **Ham dökümü olduğu gibi atma.** `KANIT/slice-3b/04-G3/gercek-tarama.txt` **1,9 MB** oldu.
Kural: **ilgili kesit + `sha256`**; 200 KB'ı aşan her kanıt dosyası **budanır** ve `00-OZET.md`'de
budandığı yazılır. `HUKUM.md`'de hiçbir cümle *"doğrulandı"* diyemez; **hangi dosyanın hangi satırına**
dayandığını yazar.

---

## 9. Kırmızı çizgiler — bu dilimde YASAK

1. **`Gorevler`'e sütun eklemek / CHECK kısıtını değiştirmek.** LWW meta verisi ayrı tablodadır (`D1`).
2. **`senkronDurumu`'nu uzak değişiklikten yazmak** (`D4`) — beş değerli sözlük genişletilemez.
3. **`Xid`'i sayıya çevirmek** (`D7`) — `ulong` Dart `int`'te taşar.
4. **Echo'yu atmak** (`D6`) — kırpılmış alan-HLC'si kaybolur, yakınsama sessizce bozulur.
5. **`normHex` olmadan `clientId`/`opId` karşılaştırmak** (`D3`) — iki cihaz farklı kazanan seçer.
6. **Periyodik yoklama eklemek** (`D0`).
7. **`D8`/`D9` dışında backend senkron çekirdeğine dokunmak** (§2).
8. **Bir bozuk op yüzünden tüm isteği reddetmek** (`D8`) — kuyruğu kalıcı tıkar.
9. **Ölçmediğini "temiz" saymak.** Ölç ya da `[DOGRULANMADI]` yaz (K21/§4 doktrini).
10. **Bir kapıyı, ısırmayan mutantı "eşdeğer" ilan ederek gevşetmek.** Önce kapı düzeltilir.
11. **Mutant kanıtını sonradan transkriptten çıkarmak.** slice-3c'de otuz altı mutantın yirmi sekizi
    böyle kaldı ve `iddia-kapisi.py` bu yüzden yazıldı. **Koşum anında yazılmayan çıktı sonradan
    ÜRETİLEMEZ.**
12. **`git add -A`** (K55) · **`device_bash`/mount'tan commit/push** · **PUSH ONUR'DADIR.**
13. **Yol adına Türkçe karakter** (K56).
14. **`DESIGN.md`'ye tek bayt** (K46).

---

## 10. Beyan edilmiş sınırlar ve açık kalemler / devir

**Doktrin (K21/§4):** *"ölç ya da `[DOGRULANMADI]` yaz"* · *"beyan edilmiş sınır kabul edilir,
gizlenmiş sınır edilmez."* Aşağıdaki her satır **bilinçli** bir sınırdır.

1. [SINIR] **Rozete dokunulmaz** (`D4`, K69) ⇒ kullanıcı bir satırın uzaktan değiştiğini rozette
   **GÖRMEZ**. Rozet sözlüğünün genişletilmesi (`uzaktan-guncellendi`) slice-3e borcudur ve **tabloyu
   yeniden yaratan** bir migration gerektirir.
2. [SINIR] **`hasMore` yanlış-pozitif verebilir** (§1.1): son sayfa tam `PageSize` ise fazladan bir boş
   tur koşulur. Veri kaybı değil, maliyet. (`D7`/2'nin boş-sayfa kuralı bunu **bir** tura indirir.)
2b. [SINIR] **YAKINSAMA DAR DÖKÜM ÜZERİNDEDİR (K1).** `sha256` iddiası yalnız
   `id, baslik, tamamlandi, silindi` sütunlarını kapsar. `olusturuldu`, `guncellendi` ve
   `senkronDurumu` **karşılaştırılmaz ve yakınsadıkları İDDİA EDİLMEZ** — gerekçe `T9`'da ölçümle
   yazılıdır (`olusturuldu` tele hiç çıkmıyor; `senkronDurumu`'na `D4` gereği dokunulmuyor).
2c. [SINIR] **Yerelde olup sunucuda olmayan satır silinmez** (`D2`); snapshot **birleştiricidir**.
3. [SINIR] **Boşaltma tavanı 20 tur** (`D7`); 10.000 değişikliğin üstünde davranış `[DOGRULANMADI]`.
4. [SINIR] **`sets` (OR-Set) kanalı uygulanmaz** (§1.4) — `UzakAlanDurumu` anahtarına sığmaz.
   `tags`/`assignees`/`checklistItems` uzaktan değişse istemci **hiçbir şey görmez**.
5. [SINIR] **Yalnız üç alan projeksiyona yazılır** (`baslik`, `tamamlandi`, `silindi`). `notes`,
   `priority`, `dueAt`, `remindAt`, `projectId`, `recurrenceRule`, `order` alanları `UzakAlanDurumu`'na
   **kaydedilir** ama kullanıcıya **görünmez**.
6. [SINIR] **`G6` (F2) sunucu değildir** — `SahteSunucu` yalnız tel şekli + kırpma + sahip süzgecini
   taşır. Yakınsamanın otoritesi `G8`'dir.
7. [SINIR] **`G8` (F3) tek sahiple koşar** ⇒ `D9`'un `owner_id` kusurunu **göremez**; o kusur `G7`'de
   iki farklı kimlikle ölçülür. `D9`'un **canlı PoC'u tasarım aşamasında koşulmadı**, mekanizma kodla
   ölçüldü (§1.6).
8. [DOGRULANMADI] **Web test ayağı:** `flutter test --platform chrome` bu ortamda sonuç üretmiyor.
   Çekme yolunun web'de çalıştığı **ölçülmemiştir** — "çalışıyor" denmez.
9. [DOGRULANMADI] **iOS:** Mac yok, yalnız CI'da derlenir; çekme yolu iOS'ta koşulmadı.
10. [SINIR] **Tek kullanıcı, tek imleç.** `ayarlar` tek satırdır; `D7/4` kullanıcı değişiminde imleci ve
    `UzakAlanDurumu`'nu **siler**, yani çok kullanıcılı eşzamanlı kullanım **desteklenmez**, güvenli
    biçimde **sıfırlanır**.
11. [SINIR] **Migration ortası çökme ölçülmüyor** (slice-3c'den devralınan sınır). `v3 -> v4` salt
    ekleme olduğu için risk düşüktür ama **ölçülmemiştir**.
12. [BULGU / Onur'un kilidini bekler] `D5`'in **ham metin** zorunluluğu (P7) `_hamCursorCikar`
    emsalinden geliyor; oysa kuyruk gövdesinden alan-HLC okumakta `ulong` taşma riski **yoktur** ve
    `jsonDecode` ile **okumak** (yeniden üretmeden) `D1`'i ihlal etmezdi. Kilit **değişmedi**: bu dilimde
    ham metin uygulanır ve deseni `M21` korur. Kilit gevşetilecekse **Onur karar verir** (K40).
13. [SINIR] **Yeni entity `senkronDurumu = 'yerel'` ile doğar** (`D4`). Rozet sözlüğünde *"uzaktan
    geldi"* yok; bu satır kullanıcıya *"henüz gönderilmedi"* gibi görünür. Bilinçli, `D4`'ün doğrudan
    sonucu, K1 gereği dökümde de yok.
14. [SINIR] **`AyarlarDeposu.devUserIdDegistir(...)` üretimde çağrılmaz** (`D7`/4). Bugün kullanıcı
    değiştiren bir akış yok; yol yalnız `G1`'in ayağını **ölçülebilir** kılmak için genel API'de durur.
15. [SINIR] **Çekme yalnız TETİKLE koşar** — periyodik yoklama yok, itme yok. Uygulama açıkken başka
    bir cihazın yazdığı satır, kullanıcı yenilemedikçe ya da uygulama yeniden açılmadıkça **gelmez**.
    Gerçek zamanlılık slice-3e'nin (SignalR) işidir.
16. Bir karar yanlış çıkarsa: **kodla düzeltme.** Bulguyu buraya yaz, dur, Onur'un kilidini bekle.

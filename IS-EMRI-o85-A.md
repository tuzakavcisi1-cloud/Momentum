# İŞ EMRİ o85-A — DİLİM 2 / LİSTE · İSTEMCİ AYAĞI (ürün burada yeşile döner)

`MOD: NORMAL` · kutu **22-23 Ağu 2026** · yazan: Cowork · koşacak: **Claude Code**
Kilit: [Onur, **19 Ağu 2026**] · Karar: **Liste = sunucudaki `Project`**

---

## 0. DEMİR KURALLAR

1. 🔴 **ADR/spec YAZILMAZ** (İŞLEYİŞ md.4). Bu dilimi bir kez altı kâğıt kapı turu öldürdü (30 gün).
   Tasarım bu emirdedir; başka belge doğmaz.
2. 🔴 **`FieldStrategyRegistry`ye DOKUNULMAZ.** İhtiyacımız olan her alan **zaten kayıtlı**:
   `Task.projectId` (scalar) · `Project.name/color/isDeleted` (scalar) · `Project.pos` (fractional).
   Registry'ye alan eklemek ADR 0002 K2-B2 kilidini açmaktır — bu emirde YASAK.
3. 🔴 **`order` kanalı BU DİLİMDE AÇILMAZ** [Onur kilidi]. `pos`/`listPos` **yazılmaz**.
   İstemcinin `WireOp`u `order` taşımıyor ve taşımayacak. Sıralama = mevcut varsayılan sıra.
4. 🔴 **Sunucu kodu bu emirde DEĞİŞMEZ.** Ölçüldü: `Project` op'ları bugün **olduğu gibi**
   uçtan uca akıyor (§1.3). Materyalizasyon + `GET /v1/projects` **o85-B**'nin işidir ve ürünü
   bloke etmez.
5. `verify.ps1` · `CLAUDE.md` · `arsiv/` · `.github/workflows/*`: **dokunma**.
   `DURUM.md`: yalnız §7'deki iki satır.
6. **PUSH ONUR'DA.** Mount'tan commit YASAK.

---

## 1. NEREDEYİZ (Cowork ölçtü, 19 Ağu 2026 — kaynak dosyalardan, varsayılmadı)

### 1.1 Sunucuda hazır olan

- `FieldStrategyRegistry.BuildDefault()`: `Task` scalar'ları arasında **`projectId` VAR**;
  `Project` = scalars `name/color/isDeleted` + OrSet `members` + fractional `pos`.
- `tasks` tablosunda **`project_id uuid NULL`** sütunu ve `ix_tasks_owner_project` indeksi VAR
  (`20260719162721_MaterializeTasksAndTaskLists`).
- `SyncCommandHandler.TryScope`: **`scope_id` = `projectId`**; görev proje değiştirince
  `old_scope_id` yazılıyor.
- `GET /v1/tasks?projectId=` **uçtan uca kayıtlı ve çalışıyor** (`TaskEndpoints` → `GetTasksQuery`
  → `TaskReadStore.ListTasksAsync`).

### 1.2 Sunucuda OLMAYAN (o85-B'nin işi, ürünü bloke ETMEZ)

- `projects` tablosu YOK · `ProjectProjection` YOK · `EntityMaterializer` `Project` için
  **sessiz no-op** ("D6 anchor") · `GET /v1/projects` YOK.

### 1.3 🔴 ÖLÇÜLEN EN ÖNEMLİ ŞEY — `Project` op'u bugün zaten senkron oluyor

- `IsOperationValid`: `Project` **kayıtlı** ⇒ ingest kabul eder.
- `SyncRowHydration` registry üzerinden çalışır, entityType'a özel dal yoktur.
- `SyncPuller.PullIncrementalAsync` filtresi **yalnız `owner_id = @actorId`** — `scope_id`'ye
  bakmaz ⇒ `scope_id` NULL olan `Project` op'u sahibin öteki cihazına **sorunsuz iner**.
- `ReadOwnedEntitiesAsync` (snapshot) **entityType'tan bağımsız** `DISTINCT aggregate_type,
  aggregate_id` çeker ⇒ `Project` anlık görünüme de girer.

⇒ **İki cihazın aynı listeyi görmesi için sunucuda TEK SATIR değişiklik gerekmiyor.**

### 1.4 İstemcide olan / olmayan

- Drift **v7**: `gorevler · senkronKuyrugu · ayarlar · uzakAlanDurumu · cakismaKayitlari ·
  gorevEtiketleri`. **Liste/proje kavramı sıfır**, `gorevler`de kap sütunu yok.
- İstemci **yalnız `/v1/auth/*` ve `/v1/sync`** çağırıyor — ölçüldü (`grep -rn "v1/" src/client/lib`).
  `/v1/tasks` ve `/v1/task-lists` **istemciden hiç çağrılmıyor**.
- `WireOp` `order` kanalı **taşımıyor** (fields/groups/sets var) — DR 3 gereği taşımayacak da.
- 🔴 `changesUygula` **entityType'a dal AÇMIYOR**: gelen her değişikliği `_GorevGuncellemesi`
  olarak toplayıp `_projeksiyonYaz`a veriyor. `Project` değişiklikleri bugün oraya düşerdi.
- 🔴 `gorev_deposu.dart:456` kuyruk join'i **`entityType.equals('Task')`** sabitiyle
  ⇒ rozet/kuyruk görünürlüğü yalnız görevler için.
- Çakışma tespiti yalnız `fields:title` + `groups:completion` (`kanonikDize` başkasında **fırlatır**).

---

## 2. KİLİTLER (Onur, 19 Ağu 2026)

| # | karar | kilit |
|---|---|---|
| K1 | Ürünün "Liste"si = sunucudaki **`Project`** | A şıkkı |
| K2 | **Klasör KESİLDİ** → `CLAUDE.md §5` + README | bu dilimde yok |
| K3 | **`listPos`/`order` kanalı AÇILMAZ** | sıra = varsayılan |
| K4 | `projectId == null` ⇒ **Gelen Kutusu** (sanal, satır yaratılmaz) | tavsiye kilitlendi |
| K5 | Liste silinince görevleri **Gelen Kutusu'na düşer**, silinmez | tavsiye kilitlendi |

**Ad çarpıklığı beyanı (gizlenmiyor):** üründe **"Liste"**, kodda ve telde **`Project`**.
Birincil referans Todoist'te de kap "Project"tir. README'ye **tek cümle** yazılır.

---

## 3. §A — Drift şeması v7 → v8 (SALT-EKLEME)

**A1.** Yeni tablo `Projeler`: `id (text, PK)` · `ad (text)` · `silindi (bool, default false)` ·
`olusturuldu (dateTime)`. **`pos` SÜTUNU YOK** (K3) · **`renk` SÜTUNU YOK** (ekranı yok ⇒ ölü sütun
yazılmaz; `cakismaKayitlari.entityType` ve `gorevEtiketleri.hlc` düşürme emsali).

**A2.** `Gorevler`e **tek nullable sütun**: `projeId (text, nullable)`. NULL = Gelen Kutusu (K4).

**A3.** Migration `from < 8`:
```
if (from < 8) {
  await m.createTable(projeler);                       // her yoldan BİR KEZ
  if (!gorevlerYenidenYaratildi) {                     // 🔴 PAZARLIKSIZ
    await m.addColumn(gorevler, gorevler.projeId);
  }
}
```
🔴 `gorevlerYenidenYaratildi` koşulu **v5→v6'nın birebir aynısıdır**: v1'den gelen yolda
`alterTable` tabloyu GÜNCEL tanımla yeniden yaratır, `projeId` zaten içindedir; ikinci kez eklemek
**"duplicate column" ile patlar**. `createTable` koşulsuzdur (v6→v7'nin deseni).

**A4.** Sıra **pazarlıksız**. Ölçüldü: `drift_schemas/drift_schema_v7.json` **ZATEN VAR**
⇒ yeniden alınmaz. Yapılacak: (1) v7 dump'ının **güncelliğini doğrula** (`gorevEtiketleri`
içeriyor mu — içermiyorsa **önce** onu al, `schemaVersion` hâlâ 7 iken) → (2) bump 8 →
(3) `build_runner` → (4) **v8 dump'ını al** (bir sonraki migration'ın borcu bugün ödenir).
Yol **saf ASCII** kalmalı (mayın 4); `build_runner` Türkçe karakterde kırılıyor.

---

## 4. §B — senkron: op üretimi (istemci → sunucu)

**B1. Liste yaratma/yeniden adlandırma/silme** → `entityType: 'Project'`, `fields` kanalı:
`name` (text) · `isDeleted` (silmede `'true'`). **`pos` YAZILMAZ · `color` YAZILMAZ.**
`entityId` = UUID v7 (`uretimIdUret`). Tel biçimi mevcut `Task` yazımlarının **birebir aynısıdır** —
yeni bir zarf icat edilmez.

**B2. Görevi listeye taşı** → mevcut `Task` op'una `fields: {projectId: <guid|null>}` eklenir.
Gelen Kutusu'na taşımak = `value: null` (registry'de scalar, `ProjectionFields.ReadGuid` null'ı
"state 2: meşru null" sayar — malformed DEĞİL). **Yeni entityType yok, yeni kanal yok.**

**B3. Ekleme akışı** — görev **aktif listede** doğar: `ekle(...)` çağrısı `projeId`yi de aynı
**TEK `WireOp`** ve **TEK `transaction()`** içinde yazar (doğal dil diliminin `ekle` deseni).
🔴 `ekle` imzası üç opsiyonel alan taşıyor (DURUM sınır 18) ⇒ **yeni sahte depo dördünü de kabul
etmek zorundadır.**

**B4. 🔴 Kuyruk/rozet sabiti.** `gorev_deposu.dart:456`'daki `entityType.equals('Task')`
**OLDUĞU GİBİ KALIR** ve üstüne tek satır gerekçe yazılır: rozet **görev satırının** durumudur,
liste satırının değil. Liste satırlarına rozet **bu dilimde yoktur** — beyan edilmiş sınır.

---

## 5. §C — senkron: uzak değişiklik uygulama (sunucu → istemci)

**C1. 🔴 `changesUygula`ya entityType DALI AÇILIR.** Bugün dal yok; `Project` değişiklikleri
`_GorevGuncellemesi` havuzuna düşerdi. Yeni yapı:
- `entityType == 'Task'` → **bugünkü yol, DEĞİŞMEDEN**.
- `entityType == 'Project'` → ayrı havuz; `fields:name` ve `fields:isDeleted` `projeler` tablosuna
  yazılır. Meta kararı (`UzakAlanDurumu.degerlendirVeMetaYaz`) **aynı** — PK zaten
  `(entityType, entityId, alan)`, çarpışma yok.
- **başka entityType** → `UzakAlanDurumu`ya yazılır, projeksiyona **yazılmaz** (bugünkü davranış).

**C2. Anlık görünüm (`snapshot`) yolu için de aynı dal** açılır. `Project` varlıkları snapshot'ta
gelir (§1.3) — dal açılmazsa liste **temiz kurulumda görünmez**.

**C3.** `fields:projectId` **Task** tarafında projeksiyona bağlanır (`gorevler.projeId`).
🔴 Çakışma tespiti bu alan için **KAPSAM DIŞIDIR** — `kanonikDize` yalnız `fields:title` ve
`groups:completion` tanır, **başkasında FIRLATIR**. `projectId` için `kanonikDize` **çağrılmaz**;
`priority`/`dueAt` için yazılan sınırın aynısı. §7'de DURUM.md'ye yazılır.

**C4.** Liste silme (`fields:isDeleted = true`) gelince: `projeler.silindi = true`; o listedeki
görevlerin `projeId`si **istemci tarafından DEĞİŞTİRİLMEZ** (K5) — ekranda Gelen Kutusu'na
düşerler çünkü sorgu silinmiş listeyi göstermez. 🔴 Görevlere yerelde yazmak **yeni op doğurur ve
iki cihazda ıraksar**; yasak.

---

## 6. §D — ekran

**D1.** `Scaffold`a **Drawer**: `[Gelen Kutusu] + listeler`. Seçim ekranın **bağlamıdır**.
**D2.** Liste oluştur · yeniden adlandır · sil (silme **onay sorarak** — mevcut silme deseni).
**D3.** Görev satırında **"Listeye taşı"** (mevcut ayrıntı akışının içinde).
**D4.** 🔴 **Liste bir SÜZGEÇ DEĞİL, BAĞLAMDIR.** DURUM sınır 28 ("ekleme süzgeçleri SIFIRLAR")
arama ve etiket çipleri içindir; **aktif liste sıfırlanmaz** — aksi hâlde kullanıcı bir listeye
görev ekleyip Gelen Kutusu'na fırlar. Bu ayrım **pazarlıksızdır** ve testle ısırtılır.
**D5.** Boş durum: liste boşken mevcut `bos_durum.dart` deseni, liste adıyla.

---

## 7. §E — DURUM.md (yalnız iki satır) + README (bir cümle)

**E1.** `DURUM.md` "bilinen sınırlar"a **iki satır**:
1. `projectId` için çakışma tespiti yok (`kanonikDize` tanımaz) — `priority`/`dueAt` ile aynı sınıf.
2. 🔴 **[o85 ÖLÇÜLDÜ] Kanal adı asimetrisi:** `SyncPuller.Project(...)` anlık görünümde
   `entity.Orders`ı **`scalars` listesine** koyuyor; istemci onu `fields:<ad>` diye kaydediyor.
   Artımlı yolda aynı alan **`order:<ad>`**tır ⇒ `UzakAlanDurumu` PK'sinde **iki ayrı satır**.
   Bugün ısırmıyor (hiçbir fractional yazılmıyor, K3 ile yazılmayacak da); `pos`/`listPos` açıldığı
   gün **sessizce** ısırır. o84'ün `ORDER BY` gölgelemesiyle **aynı sınıf**.

**E2.** `README.md`: ad beyanı tek cümle + `CLAUDE.md §5`'e klasörün kesildiği.
**E3.** `CLAUDE.md §2`nin liste maddesi ✅'ye döner, §5'e klasör kesmesi yazılır — **Cowork yapar**,
Claude Code **dokunmaz**.

---

## 8. §F — KANIT

- `KANIT/o85A/00-CEVAP.md` (altı satır, §9)
- `01-sema-v8-migration.txt` — v7 dump'ının alındığı an + migration bloğunun tam metni
- `02-op-ornekleri.json` — üretilen üç ham `WireOp`: liste yarat · görevi listeye taşı ·
  görevi Gelen Kutusu'na taşı (`projectId: null`)
- `03-iki-istemci.md` — **canlı** ölçüm: iki gerçek istemci, birinde liste yaratılır, ötekinde
  belirir; görev taşınır, ötekinde taşınır. 🔴 Boş liste üstünde **pozitif kontrol** şart
  (o83-G dersi: boş liste her iddiayı geçirir).
- `04-cevrimdisi.md` — ağ kapalıyken liste yaratma + görev taşıma, bağlantı gelince eşitlenme

---

## 9. CEVAP — `KANIT/o85A/00-CEVAP.md`, altı satır

1. `schemaVersion` 8 · migration bloğunun **tam metni** · v7 dump'ının alındığı an
2. `Projeler` tablosunun **son sütun listesi** (renk/pos yoksa "yok" yaz)
3. `changesUygula`daki dalın **tam kodu** (üç dal: Task / Project / diğer)
4. `ekle` imzasının **yeni hâli** ve kaç çağrı yerinin güncellendiği
5. `flutter analyze` **0** + `flutter test` sayısı (koşum dizini `src/client` — mayın: kökten koşarsa yalan söyler)
6. `git --no-optional-locks status --porcelain -- src tests` — `KANIT/slice-3c/02-G2/*.json` **görünmemeli**

## 10. KABUL

- [ ] Boş kurulumda uygulama açılıyor; **Gelen Kutusu** var, liste yok, mevcut görevler orada
- [ ] Liste yaratılıyor · yeniden adlandırılıyor · onayla siliniyor
- [ ] Görev listeye taşınıyor **ve** Gelen Kutusu'na geri alınıyor (`projectId: null`)
- [ ] Silinen listenin görevleri **Gelen Kutusu'nda duruyor, kaybolmuyor** (K5)
- [ ] Aktif liste seçiliyken eklenen görev **o listede görünüyor** (D4 — ekranda ölçüldü, depoda değil)
- [ ] Çevrimdışı yaratılan liste bağlantı gelince eşitleniyor; **iki istemcide** görünüyor
- [ ] `WireOp`ta **`order` kanalı yok** · registry'ye **hiç alan eklenmedi** · **sunucu kodu değişmedi**
- [ ] `flutter analyze` 0 · testler yeşil · `dart format` **yalnız dokunulan dosyada** (sınır 27)
- [ ] Tek commit, **yol belirterek** (`git add -A` YASAK), çift tırnaksız mesaj,
      author `onurkesimbjk@gmail.com` · 🔴 **PUSH YOK**
- [ ] Kanıt dosyası **kendi commit'inin hash'ini yazmaz** — dosya listesi yeterli

## 11. DOKUNMA LİSTESİ

- ❌ `FieldStrategyRegistry` · migration'lar · `src/backend/**` (tamamı)
- ❌ `WireOp`a `order` kanalı · `pos`/`listPos`/`boardPos` yazımı
- ❌ `verify.ps1` · `CLAUDE.md` · `arsiv/` · `.github/workflows/*`
- ❌ `gorev_deposu.dart:456`'daki `entityType.equals('Task')` (kalır, gerekçesi yazılır)
- ❌ `kanonikDize`ye yeni alan (çakışma tespiti bu dilimde genişlemez)
- ❌ Klasör / proje kapsayıcısı (K2 ile kesildi)
- ❌ **PUSH** — sıradaki adım Onur'un

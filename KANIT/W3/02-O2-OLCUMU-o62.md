# `W3`/`O2` ÖLÇÜLDÜ — izolasyon **temiz kurulumda** OPFS'i açıyor (oturum 62)

> 🔴 **ERRATUM — `03-VERI-GOCU-OLCUMU-o62.md` bu belgeyi DARALTIR.** Aşağıdaki
> *"`B1` yanlışlandı"* hükmü **yalnız TEMİZ PROFİL için** doğrudur. **Mevcut bir
> `sharedIndexedDb` deposu varken** aynı ölçüm tekrarlandığında drift izolasyon açık olmasına
> rağmen `sharedIndexedDb`'de **KALDI** ve OPFS **boş** kaldı ⇒ **`B1` mevcut kullanıcı için
> AYAKTA**. Bu belge silinmedi; hükmü **daraltıldı** (`B2` sınıfı: *"ölçüldü" damgalı iddia
> ölçülünce ters çıktı* — bu kez üretenin kendi çıktısında).

**6 Ağu 2026, oturum 62. Koşan el:** Cowork.
🔴 **NEREDE KOŞTU:** Cowork'ün **bulut konteyneri** — **Flutter 3.44.9** (depo `DURUM.md` **3.44.6**
diyor ⇒ **yama farkı var, beyan ediliyor**), **Dart 3.12.2** (birebir aynı), headless **Chromium**
+ Playwright. **Onur'un Windows makinesinde DEĞİL.**

---

## Ölçülen soru

`W3`'ün **merkezî ürün sorusu**. Denetim raporu `00-DENETIM-o60.md`, `B1` blokeri:

> *"`drift_flutter 0.3.1` `moveExistingIndexedDbToOpfs` bayrağını **geçiremiyor** ve
> `veritabani.dart:180` `driftDatabase()` kullanıyor ⇒ **izolasyon kusursuz sağlansa bile drift
> `sharedIndexedDb`'de KALIR, ürün davranışı DEĞİŞMEZ**."*

Bu iddia iki tur boyunca **kâğıtta** kaldı ve `T5`'in (koşullu import + dosya bölmesi,
`WasmDatabase.open`, `W2`'nin `onResult` dikişini kırma riski) **tek gerekçesiydi**.

## Kurgu

`flutter build web --no-web-resources-cdn` ile **gerçek build** üretildi (63,2 s, `EXIT 0`).
Aynı build **iki kez** servis edildi, **tek fark yanıt başlıkları**:

| koşul | sunucu ne gönderdi |
|---|---|
| **A** | başlık **yok** |
| **B** | `COOP: same-origin` + `COEP: require-corp` |

Ürün kodunda **tek bayt** değişmedi. `W2`'nin görünür dikişi (`MOMENTUM-G6-KANIT …`) konsoldan
okundu — sabit bekleme yok, anahtar dizge görünene kadar **yoklandı** (tavan 25 s).

## ÖLÇÜLEN

**A — izolasyonsuz:**
```
crossOriginIsolated = false · typeof SharedArrayBuffer = "undefined"
MOMENTUM-G6-KANIT chosenImplementation=WasmStorageImplementation.sharedIndexedDb
  missingFeatures={MissingBrowserFeature.dedicatedWorkersInSharedWorkers,
                   MissingBrowserFeature.sharedArrayBuffers}
```

**B — izole:**
```
crossOriginIsolated = true · typeof SharedArrayBuffer = "function"
MOMENTUM-G6-KANIT chosenImplementation=WasmStorageImplementation.opfsLocks
  missingFeatures={MissingBrowserFeature.dedicatedWorkersInSharedWorkers}
```

## 🟢 HÜKÜM: **İZOLASYON ÜRÜN DAVRANIŞINI DEĞİŞTİRDİ**

**`sharedIndexedDb` → `opfsLocks`.** Yalnızca **iki yanıt başlığıyla**, `veritabani.dart`'a
**dokunmadan**, `driftDatabase()` çağrısı **yerinde dururken**.

🔴 **Bu, `B1`'in yanlışlanmasıdır.** `B1` *"drift sharedIndexedDb'de KALIR"* diyordu; ölçüm
**kalmadığını** gösteriyor. `missingFeatures` listesinden `sharedArrayBuffers` **düştü** ve drift
seçimini **kendiliğinden** yükseltti — çünkü `WasmDatabase.open`'ın seçim mantığı zaten
tarayıcı yeteneğine bakıyor; eksik olan **bayrak değil, izolasyondu**.

### Doğrudan sonucu: `T5`'in gerekçesi ortadan kalktı

`K151/③` `T5`'i *"koşullu import + dosya bölmesi"* olarak kilitlemişti; tek sebebi `B1`'di.
Ölçüm `B1`'i çürüttüğüne göre `T5`'in **maliyeti** (dosya bölmesi · `WasmDatabase.open`'ın VM'de
derlenmemesi · `W2`'nin `onResult` çapasını taşıma riski — denetimin `B-2`/`B-6` blokerleri)
**bedelsiz kazanç sağlamıyor** olabilir.
🔴 **KİLİT AÇILMADI.** `K151` yürürlüktedir; bu ölçüm bir **kilit değiştirme önerisidir** ve
kararı **Onur verir**. Üreten kendi çıktısını adjudike edemez (`K26`).

---

## İKİNCİL ÖLÇÜM — `G45/d` gerçek build üzerinde **DOĞRULANDI**

`--no-web-resources-cdn` ile üretilen çıktıda `www.gstatic.com/flutter-canvaskit` dizgesi
**`flutter.js` (1) + `flutter_bootstrap.js` (1) = 2** yerde **DURUYOR** — denetimin `B-5`
ölçümünün birebir tekrarı. `fonts.gstatic.com` ise `main.dart.js`'te **1** yerde duruyor (`Y2`).

🟢 **Ama çalışma zamanında canvaskit gstatic'ten İSTENMEDİ:** yerel `canvaskit/` dizini üretildi
(`canvaskit.wasm`, `skwasm.wasm`, …) ve başarısız istekler listesinde **canvaskit yok**.
⇒ Bayrak `useLocalCanvasKit`'i **çalışma zamanında** çeviriyor, **baytı çıkarmıyor**.
**`K151/④`'ün "pinli sayan-raporlayan `G45/d`" kararı ölçümle DOĞRULANDI**; taban
`{flutter.js: 1, flutter_bootstrap.js: 1}` **gerçek build üzerinde** teyit edildi.

---

## NE ÖLÇÜLEMEDİ (boş olamaz)

1. **`moveExistingIndexedDbToOpfs` — VERİ GÖÇÜ ÖLÇÜLMEDİ.** Ölçüm **temiz profille** koştu;
   içinde veri olan bir `sharedIndexedDb`'den `opfsLocks`'a **geçişte ne olduğu** ölçülmedi.
   Denetimin `B-11`'i (*"taşıma kopyalamıyor, kaynağı SİLİYOR; atomik değil"*) **açık kalıyor**
   ve `B1`'in çürümesi onu çürütmez — **iki ayrı sorudur.**
2. **`fonts.gstatic.com`'un COEP altında bloklanıp bloklanmadığı.** Konteynerin dış ağı kapalı
   olduğu için font isteği **iki koşulda da** `ERR_CONNECTION_RESET` verdi ⇒ COEP bloğu ile ağ
   bloğu **ayırt edilemedi**. Bu ölçüm **dış ağı açık** bir ortamda tekrarlanmalıdır.
3. **`dedicatedWorkersInSharedWorkers`** iki koşulda da eksik ⇒ `opfsShared` **hiç ölçülmedi**;
   ölçülen `opfsLocks`'tur. Chromium'un headless kipiyle ilgili olabilir — **ölçülmedi**.
4. **Onur'un makinesinde hiçbiri.** Flutter sürümü de **3.44.9 ≠ 3.44.6**.
5. **Gerçek kullanıcı akışı yok** — uygulama açıldı, drift init'i ölçüldü; **CRUD, senkron,
   kalıcılık** hiç denenmedi. Bir sonraki açılışta OPFS'ten okuyup okumadığı **ölçülmedi**.
6. **`flutter test` / `verify.ps1`** bu turda koşulmadı.
7. 🔴 **Ölçüm ortamının kendi kusuru vardı ve düzeltildi:** ilk koşumda uygulama
   `RangeError: Incorrect locale information provided` ile **açılışta çöküyordu** ve `G6` kanıtı
   *"hiçbir koşulda görünmedi"* diyordu — bu **ürün kusuru değil**, konteynerde locale
   olmamasıydı. `--lang=en-US` + `new_context(locale=…)` ile giderildi. **İlk çıktı bir
   `ÖLÇÜLEMEDİ`ydi ve öyle raporlanmıştı; `TEMIZ` diye geçilmedi.**

**Koşucu:** `KANIT/W3/_o2_olc.py` — iki koşulu da koşar, farkı kendisi hükme bağlar.

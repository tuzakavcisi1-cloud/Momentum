# GOREV-W2 — WEB DEPOLAMA KATMANI GÖRÜNÜR OLUR **(v3)**

> **Durum: KİLİT ADAYI v3.** Üreten el: Cowork (oturum 59, 5 Ağu 2026).
> **`v1` (`C9BC8453`) ve `v2` (`94124CE5`) GEÇERSİZDİR.**
> **`K127` — kilit öncesi bağımsız denetim İKİ TUR koştu:**
> `KANIT/W2/00-DENETIM-o59.md` (v1 · iki denetçi · **7 BLOKER + 13 MAJOR**) ve
> `KANIT/W2/01-v2-DOGRULAMA-o59.md` (v2 · bağımsız doğrulayıcı · **3 yeni BLOKER + 5 MAJOR + 3 MINOR**).
> 🔴 **İkinci tur `K53/1`'in kendi istisnasıyla açıldı:** birinci tur **mimariyi değiştiren** bir bloker
> buldu (`BL-1` — dilimin tek dikişi ölçülmüyordu ⇒ `G42` kapısı doğdu). **ÜÇÜNCÜ TUR YOKTUR**
> (radar `R1`: aynı artefakta üçüncü tur YASAK).
> **Biçim:** `K81` · `K126` (**3. sütun = hedef**). **Kapı kimliği spec-yereldir (`K108`).**
> **Onur'un yedi kilidi:** ① yalnız kusurda konuş ② bilinmeyen ad ⇒ geri-düşüş ③ kapsam = durum+UI+test
> ④ minimal spec ⑤ `G41` **gerçek enum** + `// ignore` ⑥ `DESIGN.md` **yazılır** ⑦ `A11Y-7` **uygulanır**.
> 🔴 **BEYAN EDİLMİŞ SAPMA:** ④'ün *"≤ 12 KB"* hedefi aşıldı. Ölçülmüş gerekçe: **on BLOKER**in kapatılması
> bir kapı (`G42`), altı yeni ayak ve altı yeni mutant gerektirdi. Sapma gizlenmiyor, ölçülüyor.

---

## 1. NEDEN — ÖLÇÜLMÜŞ, TAHMİN DEĞİL

**① Geri-düşüş gerçektir.** o57'de tarayıcıda ölçülen satır: `chosenImplementation=sharedIndexedDb`,
`missingFeatures={dedicatedWorkersInSharedWorkers, sharedArrayBuffers}` (borç `B-W1-2`).

**② Sebebi ÖLÇÜLDÜ ve İKİ bağımsız denetçi birebir doğruladı** — `drift-2.34.3/.../wasm_setup/types.dart`:
`opfsShared` için *"this is only implemented in Firefox at the time of writing. Chrome
(https://crbug.com/1088481) and Safari don't support this yet."* · `opfsLocks` için *"It requires
cross-origin isolation, which needs to be enabled by serving your app with special headers:
Cross-Origin-Opener-Policy: same-origin / Cross-Origin-Embedder-Policy: require-corp."*
⇒ **Chrome + COOP/COEP'siz sunucu = `sharedIndexedDb` kaçınılmazdır.**

**③ Kalıcılık BUGÜN ÇALIŞIYOR** (`W1` kriter 9: F5 sonrası görev yaşadı) ⇒ bu dilim kalıcılığı **ONARMAZ**.

**④ Onardığı şey SESSİZLİKTİR.** **Ölçen ama söylemeyen kanal, ölçmeyen kanaldır.**

**⑤ İKİ TURUN ORTAK DERSİ:** bu dilimin kırılgan yeri model ya da widget değil, **aradaki DİKİŞ**tir.
`v1` dikişi hiç ölçmüyordu; `v2` **varlığını** ölçtü ama **argümanlarını** ölçmedi ⇒ sabit-argümanlı bir
gövde on beş mutantı ve on iki kriteri **tam puanla** geçip şeridi hiç göstermeyebilirdi. `v3` argümanları
da ölçer (`G42/a`, `M215`, `M216`).

---

## 2. KAPSAM

**İÇERİDE:** saf sınıflandırma · dikiş + **dikişin statik kapısı** · şerit · `Metinler` girdileri ·
`DESIGN.md`'nin üç satırı · testler · 17 mutant + 1 negatif kontrol.
**DIŞARIDA, gerekçeli:** COOP/COEP ve OPFS'e geçiş ⇒ **`ADR 0004`** (iskeleti bu turda, kriter 10) ·
ayrı `.py` kapı betiği ⇒ Onur kilidi ③ · gerçek tarayıcı ölçümü ⇒ `ORTAM.md` (§8/1).

---

## 3. KARARLAR

### D-W2-1 — SINIFLANDIRMA SAF VE **DİZE** TABANLIDIR, PİNİ **GERÇEK ENUM**DUR
İmza: `DepolamaSinifi depolamaSinifiCoz({required String? uygulamaAdi, required String? depolamaApi})`.
**Gerekçe:** Onur'un ② kilidi bilinmeyen adın **test edilebilir** olmasını ister; Dart enum'u kapalıdır.
**Bedel ÖDENİR (kilit ⑤):** `G41` drift'in **gerçek** `WasmStorageImplementation.values` /
`WebStorageApi.values` kümesini numaralandırır. 🟢 Doğrulayıcı ölçtü — `types.dart` başlığı birebir:
*"This library **must not import web-specific APIs**, as it is also imported in **integration tests on a
Dart VM**"*; importları yalnız `dart:async`, `package:drift/drift.dart`, `package:sqlite3/common.dart`
⇒ **VM'de import EDİLEBİLİR.** Import satırına `// ignore: implementation_imports`.
🔴 Kabul edilen risk: drift **dosya yolunu** değiştirirse derleme düşer — **gürültülü**, sessiz değil.

### D-W2-2 — SIRALI KARAR LİSTESİ (öncelik PAZARLIKSIZ)
① ad `inMemory` ⇒ `kaliciDegil` · ② ad ∈ `kaliciOpfsAdlari` **VE** api `opfs` ⇒ `kaliciOpfs` ·
③ ad ∈ `geriDususAdlari` ⇒ `geriDusus` · ④ **aksi hâlde** ⇒ `geriDusus`.
Doğrulayıcı bu listeyi `G39`'un altı ayağına **elle uyguladı: çelişki YOK.**
**Tanınmayan ad hiçbir api ile `kaliciOpfs` olamaz.**

### D-W2-3 — UI YALNIZ KUSURDA KONUŞUR
`kaliciOpfs` ⇒ şerit **YOK** · `geriDusus` ve `kaliciDegil` ⇒ şerit **VAR** · `olculmedi` ⇒ şerit **YOK**.

### D-W2-4 — ŞERİT RENGİ `MRenk.cevrimdisi`; **METİN + İKON** RENGİDİR, DOLGU YOKTUR
Zemin `MRenk.yuzey`. Üç denetçi **ayrı ayrı** ölçtü: `uyari` (`#8A5A00`) koyu yüzeyde **3,14:1** ⇒ AA
**DÜŞER**; `cevrimdisi` koyu **11,11:1**, açık **6,92:1** ⇒ geçer. Dolgulu okuma **YASAK** (koyu temada
metin/dolgu **1,40:1** olurdu).

### D-W2-5 — ŞERİT `DESIGN.md`'YE **KENDİ SATIRIYLA** YAZILIR (kilit ⑥)
🔴 `v1`'in *"K46 dondurulmuş ⇒ yazılamaz"* öncülü **YANLIŞTI**; `DESIGN.md:4`: *"**K46 AÇILDI (K75)** …
başka değişiklik yine **Onur'un kilidini ister**."* Kilit **verildi**. Şerit §4'ün *çevrimdışı* satırının
**geometrisini ödünç alır, satırını DEVRALMAZ**. ⇒ **`B-W2-1` borcu DOĞMAZ.**

### D-W2-6 — `print` KALDIRILMAZ **ve bu ÖLÇÜLÜR** (`G42/b`)
`MOMENTUM-G6-KANIT …` `W1/G37`'nin kanıt zinciridir. `DESIGN.md` ban-list #5 ihlal edilmez: `print`
`lib/veri`'dedir ve **KANIT kanalıdır**, UI durumu değildir.

### D-W2-7 — NATIVE YOLDA DURUM `olculmedi`'DİR
Başlangıç değeri `const DepolamaDurumu.olculmedi()` **sabitindedir** (mutant orayı hedefler).

### D-W2-8 — DİKİŞ TEK NOKTADAN VE **DOĞRU ARGÜMANLARLA** YAZILIR; KÜRESEL DEĞİŞKEN **YASAK**
`onResult` gövdesi iş yapmaz, yalnız çağırır:
`depolamaBildirimiYaz(bildirim, uygulamaAdi: sonuc.chosenImplementation.name, depolamaApi: sonuc.chosenImplementation.storageApi?.name)`.
🔴 **Argümanlar PAZARLIKSIZ:** sabit dizge, farklı alan ya da yorum satırı **kapıyı geçmez** (`G42/a`).
Bildirim `Veritabani`'na **parametreyle** geçer.

---

## 4. YAPILACAKLAR

| # | dosya | iş |
|---|---|---|
| T1 | `lib/veri/depolama_durumu.dart` **(yeni)** | `enum DepolamaSinifi { kaliciOpfs, geriDusus, kaliciDegil, olculmedi }` · `class DepolamaDurumu` (yalnız `sinif` + `uygulamaAdi`; `const DepolamaDurumu.olculmedi()`) · 🔴 **dışa verilen** `const Set<String> kaliciOpfsAdlari = {'opfsShared','opfsLocks'}` · `const Set<String> geriDususAdlari = {'sharedIndexedDb','unsafeIndexedDb'}` · `const String kaliciDegilAdi = 'inMemory'` — `depolamaSinifiCoz` **bunları kullanır**, satır-içi literal YAZMAZ · `typedef DepolamaBildirimi = ValueNotifier<DepolamaDurumu>` · saf `depolamaBildirimiYaz(...)`. 🔴 `eksikYetenekler` alanı **YAZILMAZ** (ölü alan; emsal `veritabani.dart:100`) |
| T2 | `lib/veri/veritabani.dart` | İmza **tam**: `Veritabani([QueryExecutor? baglanti, DepolamaBildirimi? bildirim]) : super(baglanti ?? _uretimBaglantisi(bildirim));` — **31 konumsal çağrı korunur**. `onResult`: `print` **korunur**, hemen ardından `D-W2-8`'in **birebir** çağrısı |
| T3 | `lib/sunum/depolama_seridi.dart` **(yeni)** | `DepolamaSeridi(durum:)`; gerekmiyorsa `SizedBox.shrink()`. İkon **`Icons.storage`** (🔴 `Icons.cloud_off` **YASAK** — `DESIGN.md:184` anlam pini; doğrulayıcı ölçtü: `storage` mevcut pin listesinde **YOK**, `lib` altında kullanımı **0**) + `Metinler` metni. 🔴 **TEK BİR `Text(` düğümü** (`R4` tabanı buna göre pinlenir). `Flexible` içinde `maxLines: 2` + `TextOverflow.ellipsis` (desen `senkron_rozeti.dart:169-185`), `Semantics(label:)`, renk `MRenk.cevrimdisi`. Sınıf `geriDusus`/`kaliciDegil`'e **geçtiğinde** `SemanticsService.sendAnnouncement(Metinler.duyuruDepolamaGeriDususu, …)` **bir kez** (desen `senkron_rozeti.dart:103`). 🔴 **YASAK sarmalayıcılar:** `Opacity` · `Visibility` · `Offstage` · `Transform` · `ClipRect` · `ColorFiltered` · sabit yükseklik/genişlik |
| T4 | `lib/sunum/gorev_listesi_ekrani.dart` | `final ValueListenable<DepolamaDurumu>? depolama;` (null ⇒ hiç çizilmez) → listenin **ÜSTÜNE** `ValueListenableBuilder` |
| T5 | `lib/main.dart` | `final depolamaBildirimi = DepolamaBildirimi(const DepolamaDurumu.olculmedi());` → `Veritabani(null, depolamaBildirimi)` **ve** `GorevListesiEkrani(depolama: depolamaBildirimi)` |
| T6 | `lib/design/metinler.dart` | **Üç** sabit: geri-düşüş metni *"Veriler tarayıcı deposunda tutuluyor."* · kalıcı-değil metni *"Veriler kalıcı DEĞİL: sekme kapanınca silinir."* · **`duyuruDepolamaGeriDususu`** (ekran okuyucu). 🔴 Ham dizge widget'a **gömülmez** |
| T7 | `DESIGN.md` (kilit ⑥) | **Üç satır:** §3.1 envanterine `DepolamaSeridi` · §4 matrisine *depolama geri-düşüşü* satırı — 🔴 **"semantics duyurusu" sütunu `Metinler.duyuruDepolamaGeriDususu` ile DOLDURULUR** · §6 anlam pinine `Icons.storage`. Kimlik `3780ACA4` **GEÇERSİZ** olur ⇒ `DURUM.md` §9 aynı turda güncellenir |
| T8 | `test/a11y_statik_tasma_test.dart` | 🔴 `R4` pozitif kontrol tabanı **12 → 13** (tek yeni `Text(`; sebep yorumda **adıyla**) · `F6` dizge listesi **13 → 16** (üç yeni sabit) |
| T9 | `test/destekler/duyuru_yakala.dart` **(yeni)** | `a11y_kapisi_test.dart:62`'deki **özel** `_duyurulariYakala` yardımcısı **özel-olmayan** bir kopyaya çıkarılır ve `a11y_kapisi_test.dart` onu kullanır (tek kaynak; `kanonik-kopya` doğmaz) |
| T10 | `test/` **(yeni)** | `w2_depolama_esleme_test.dart` (`G39`, `G41`) · `w2_depolama_seridi_test.dart` (`G40`) · `w2_dikis_kapisi_test.dart` (`G42`) |

---

## 5. KAPILAR

### G39 — eşleme kapısı (birim testi)

| ayak | ölçtüğü |
|---|---|
| a) | `('opfsShared','opfs')` ve `('opfsLocks','opfs')` ⇒ `kaliciOpfs` **(pozitif kontrol)** |
| b) | `('opfsQuantum','opfs')` — **bilinmeyen ad** ⇒ `geriDusus` |
| c) | `('sharedIndexedDb', null)` ve `('unsafeIndexedDb','indexedDb')` ⇒ `geriDusus` (**`null` api tek başına `kaliciDegil` YAPMAZ**) |
| d) | `('inMemory', null)` ⇒ `kaliciDegil` |
| e) | `('opfsShared','webSql')` — **bilinmeyen api** ⇒ `geriDusus` |
| g) | `(null, null)` ⇒ `geriDusus` (üretimde erişilemez; güvenli taraf yine de ölçülür) |

### G40 — şerit kapısı (widget testi; **`GorevListesiEkrani` pump edilir, şerit YALITILMIŞ DEĞİL**)

🔴 **"ŞERİT VAR" YÜKLEMİ (PAZARLIKSIZ, beş koşul):** `find.text(Metinler.<ilgili>)` **VE**
`find.byIcon(Icons.storage)` **VE** `tester.getSize(find.byType(DepolamaSeridi)).height > 0` **VE**
`… .width > 0` **VE** alt ağaçta `T3`'ün **yasak sarmalayıcılarından hiçbiri BULUNMAZ**.
**"YOK"** = `find.byType(DepolamaSeridi)` **hiç bulunmaz**.

| ayak | ölçtüğü |
|---|---|
| a) | `kaliciOpfs` ⇒ **YOK** (pozitif kontrol: aynı testte `geriDusus` ⇒ **VAR**) |
| b) | `geriDusus` ⇒ **VAR**, **ikon + metin birlikte** |
| c) | `olculmedi` **ve** `depolama == null` ⇒ **YOK** |
| d) | `textScaler` **2.0×**, genişlik **320 dp** ⇒ şerit metni **en fazla 2 satır** (`RenderParagraph`'ın satır sayısı **ölçülür**, `takeException()` **null**) |
| e) | `MomentumTema.olustur(Brightness.dark)` ile pump edilmiş şerit **`meetsGuideline(textContrastGuideline)`** geçer *(token çifti değil, **çizilmiş** şerit)* |
| f) | `olculmedi` → `geriDusus` geçişinde **tam bir kez** `sendAnnouncement` çağrılır **ve yakalanan dizge `Metinler.duyuruDepolamaGeriDususu` ile BİREBİR aynıdır** |

| bağlı a11y kuralı | nerede koşar |
|---|---|
| A11Y-4 | `G40/d` |
| A11Y-6 | `G40/b` |
| A11Y-7 | `G40/f` |

### G41 — drift sözleşme pini (birim testi, **gerçek enum**)

| ayak | ölçtüğü |
|---|---|
| a) | `WasmStorageImplementation.values.map((e) => e.name).toSet()`, `T1`'in **dışa verdiği** `kaliciOpfsAdlari ∪ geriDususAdlari ∪ {kaliciDegilAdi}` kümesini **KAPSAR**; `WebStorageApi.values` iki api adını kapsar (pozitif kontrol: kapsama bugün **tam**). Import: `// ignore: implementation_imports` |

### G42 — dikiş kapısı (kaynak tarayan birim testi)

🔴 **TARAYICI SÖZLEŞMESİ (PAZARLIKSIZ):** kaynak önce **yorumlardan arındırılır** (`//` **ve** `/* */`)
ve arama **yalnız `onResult` gövdesi** aralığında yapılır. **Pozitif kontrol:** tarayıcı, bugünkü temiz
kaynakta üç ayağı da bulur; bulamazsa kapı `ORTAM HATASI` verir ve **YEŞİL DEMEZ**.
*(Ölçülmüş gerekçe: `ss2-kapisi.py` ve `cors-kapisi.py` tam bu sınıftan kör kaldı.)*

| ayak | ölçtüğü |
|---|---|
| a) | `onResult` gövdesinde `depolamaBildirimiYaz(` çağrısı VAR **ve** argümanları birebir `sonuc.chosenImplementation.name` ile `sonuc.chosenImplementation.storageApi?.name` okur |
| b) | aynı gövdede `MOMENTUM-G6-KANIT` `print` satırı **hâlâ** VAR |
| c) | `lib/main.dart` bildirimi **hem** `Veritabani`'na **hem** `GorevListesiEkrani(depolama:)`'na geçirir |

---

## 6. MUTANTLAR

| id | mutasyon | hedef | beklenen |
|---|---|---|---|
| M200 | `depolamaSinifiCoz` ④ aksi-hâl dalı `geriDusus` → `kaliciOpfs` | `G39/b` · `D-W2-2` | G39/b KIRMIZI |
| M201 | ③ dalı `geriDusus` → `kaliciDegil` | `G39/c` · `D-W2-2` | G39/c KIRMIZI |
| M202 | ① dalı `kaliciDegil` → `geriDusus` | `G39/d` · `D-W2-2` | G39/d KIRMIZI |
| M213 | ② dalının **api koşulu** kaldırılır (yalnız ada bakar) | `G39/e` · `D-W2-2` | G39/e KIRMIZI |
| M203 | şerit `kaliciOpfs` durumunda da çizilir | `G40/a` · `D-W2-3` | G40/a KIRMIZI |
| M204 | şerit `geriDusus` durumunda çizilmez | `G40/a` · `G40/b` · `D-W2-3` | **ikisi de** KIRMIZI |
| M206 | şeritten ikon silinir, yalnız metin kalır | `A11Y-6` · `G40/b` | G40/b KIRMIZI |
| M205 | şerit rengi `MRenk.cevrimdisi` → `MRenk.uyari` | `G40/e` · `D-W2-4` | G40/e KIRMIZI (koyu tema **3,14:1**) |
| M208 | `maxLines: 2` → `maxLines: 5` (🔴 `ellipsis` **KALIR**, `maxLines` **SİLİNMEZ** — `R1` de `R2` de SUSAR) | `A11Y-4` · `G40/d` | G40/d KIRMIZI |
| M207 | `const DepolamaDurumu.olculmedi()` sabiti `geriDusus` döndürür | `G40/c` · `D-W2-7` | G40/c KIRMIZI |
| M214 | `sendAnnouncement` satırı silinir | `A11Y-7` · `G40/f` | G40/f KIRMIZI |
| M209 | `kaliciOpfsAdlari` kümesinde `opfsLocks` → **`kilitliDosyaSistemi`** (önek/sonek bırakmaz) | `G39/a` · `G41/a` · `D-W2-1` | **ikisi de** KIRMIZI |
| M210 | `depolamaBildirimiYaz(` çağrısı **silinir** | `G42/a` · `D-W2-8` | G42/a KIRMIZI |
| M216 | aynı çağrı **yoruma alınır** (silinmez) | `G42/a` · `D-W2-8` | G42/a KIRMIZI (yorum körlüğü kontrolü) |
| M215 | çağrının argümanları **sabit dizgeye** çevrilir (`'opfsShared'`, `'opfs'`) | `G42/a` · `D-W2-8` | G42/a KIRMIZI |
| M211 | `MOMENTUM-G6-KANIT` `print` satırı silinir | `G42/b` · `D-W2-6` | G42/b KIRMIZI |
| M212 | `main.dart`'ta bildirim **ekrana** geçirilmez | `G42/c` · `D-W2-8` | G42/c KIRMIZI |
| MW20 | 🔴 **NEGATİF KONTROL** — hiçbir dosyaya dokunulmaz | *(hedef yok)* | **KALDI**. Koşucu `ISIR` derse **koşucu bozuktur**, koşum GEÇERSİZDİR |

## 6b. MUTANT BORCU

- KURAL: D-W2-5 | GEREKCE: DESIGN.md'ye uc satir yazilmasi bir BELGE kararidir; kod mutantiyla olculemez. Olcusu T7'nin kosmasi ve DURUM.md 9'daki kimligin ayni turda guncellenmesidir (kriter 9).

---

## 7. KABUL KRİTERLERİ (hepsi **Cowork'ün KENDİ koşumuyla** — `K26`)

1. `flutter analyze --fatal-infos` ⇒ **EXIT 0**.
2. `flutter test` ⇒ **EXIT 0**; **önceki N + eklenen M = beklenen N+M** biçiminde beyan edilir (sayı
   **ölçülür**, kopyalanmaz) — bir testin silinerek yeşile boyanması böylece mekanik yakalanır.
3. `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-W2-depolama-gorunurlugu.md` ⇒ **EXIT 0**.
4. 🔴 **On yedi mutant + negatif kontrol gerçek repoda koşar.** Koşucu, `flutter test`'in **kırmızı olan
   test adlarını** toplar, adlardan **ayak kimliklerini** (`G<n>/<harf>`) çıkarır ve `hedef` sütunundaki
   ayak kümesiyle **TAM EŞİTLİK** arar (`olculen == beklenen`; alt küme YETMEZ). Eşleşmezse mutant
   **GEÇMEDİ**. *(Hedefteki `D-W2-*` / `A11Y-*` kodları izlenebilirliktir, test adı değildir.)*
   Her kapı ayağı **AYRI bir `test()`**'tir ve adı `'G39/b — …'` biçiminde ayak kimliğiyle başlar.
   `MW20` **KALDI** vermezse koşum geçersizdir. Geri alma **bayt-özdeş** (`sha256`); `git restore`
   **YASAK**; koşucu **`try/finally`** taşır.
5. Koşumdan sonra `git --no-optional-locks status --porcelain` **hiçbir ürün dosyası göstermez**.
6. `python araclar\radar.py . --olc-urun-kodu <sha>` ⇒ **> 0**; ayrıca **elle yazılmış satır sayısı**
   dosya dosya ayrı beyan edilir (`B-W1-3`).
7. Dört açılış kapısı yeniden koşar: `tek-kopya` · `belge-tavan` · `kapi-ad-teklik` · `sayi-tazeligi`.
8. `python araclar\design-token-kapisi.py .` **build'den ÖNCE ve SONRA** koşar; KIRMIZI ⇒ spec'e dönülür.
9. `T7` sonrası `DESIGN.md`'nin yeni kimliği ölçülür ve **`DURUM.md` §9 aynı turda** güncellenir.
10. `docs/ADR/0004-web-capraz-koken-izolasyonu.md` **iskeleti** yazılır (başlık + bağlam + açık soru);
    **var olmayan bir belgeye devir sarkan atıftır**.
11. 🔴 **Mutant koşucusu da `K26` kapsamındadır:** hükmü veren el koşucuyu **yazmamış** olmalıdır.
12. Ham çıktılar `KANIT/W2/` altında; hüküm dosyası **denetleyen elin** imzasını taşır.

---

## 8. BEYAN EDİLMİŞ SINIRLAR — GİZLENMİYOR

1. 🔴 **Gerçek tarayıcıda şeridin göründüğü BU SPEC'TE ÖLÇÜLMEZ** (`ORTAM.md`: `flutter test
   --platform chrome` bu ortamda sonuç üretmiyor). `G42` dikişin **kaynakta doğru yazıldığını** ölçer,
   **çalıştığını** değil. Canlı ölçüm `ADR 0004` turuna kalır.
2. 🔴 **DARALTILMIŞ İDDİA:** bu dilim *"web depolama katmanı görünür OLDU"* **demez**. Dediği: **model,
   şerit ve dikiş yazıldı; VM'de ölçüldü; dikişin doğru argümanlarla bağlandığı statik olarak
   kanıtlandı; kullanıcıya fiilen göründüğü ÖLÇÜLMEDİ.** `B-W1-2` **açık kalır**.
3. 🔴 `D-W2-7`'nin *"native yolda `onResult` hiç çağrılmaz"* iddiası **[ÖLÇÜLMEDİ]** — `drift_flutter`'ın
   `driftDatabase()` gövdesi açılmadı. Build sırasında ölçülüp buraya yazılır.
4. 🔴 `A11Y-1` (48 dp) **uygulanmaz**: şerit dokunulabilir değildir.
5. 🔴 `M205`'in **açık temada ısırmadığı** ölçüldü (`uyari` açık yüzeyde **5,93:1** ⇒ geçer) ⇒ `G40/e`
   koyu tema olmadan **kördür**; ayak temayı **adıyla** sabitler.
6. 🔴 **`G40`'ın "VAR" yüklemi YERLEŞİM ölçer, BOYAMA değil.** Yasak sarmalayıcı listesi bilinen
   görünmezlik yollarını kapatır ama **tüketici değildir**; piksel doğrulaması yalnız `G40/e`'nin
   kontrast kılavuzu üzerinden dolaylıdır. **[BEYAN EDİLMİŞ SINIR]**
7. 🔴 `G40/d`'nin *"en fazla 2 satır"* ölçümünün bu Flutter sürümünde **yazılabilirliği ÖLÇÜLMEDİ**
   (`RenderParagraph`/`computeLineMetrics` yolu). Yazılamazsa build spec'e döner; **sessiz gevşetme YASAK**.
8. 🔴 `flutter test`'in **taban sayısı (N) ÖLÇÜLMEDİ** — doğrulayıcının regex sayımı (**240** eşleşme)
   `flutter test`'in bildirdiği toplam **değildir**. Kriter 2'nin `N`'i build başında ölçülür.

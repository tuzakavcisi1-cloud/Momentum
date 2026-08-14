# GÖREV (Claude Code) — slice-3b: Flutter istemci iskeleti + TAM ÇEVRİMDIŞI CRUD (K42-d adım 2)  [v6]

> 🔒 **KİLİTLİ — Onur, 27 Tem 2026 (K52 → K54 → K57 → K59 ile güncellendi).** Build başlayabilir.
> **v5 → v6 DEĞİŞİKLİĞİ (K59, oturum 31 — T9 KAPANIŞININ TEK KİLİT TURU):** ① **A2 artık İKİ yakalama ister** (vitrin + gerçek ekran, **ham JSON**, birleşimde 8 ad) — bu bir **gevşetme değil**, sağlanamaz bir şartın sağlanabilir ve **daha pahalı** hale getirilmesidir; gerekçe §5/G1'de **ölçümle** yazılıdır. ② Kabul kriteri **6·7·8**'e **araç adı** eklendi ve rakamlar ölçülen değerlere çekildi (`8/8`, `4/4 → 6/6`, `12 → 18/18`) — böylece `sayi-tazeligi.py` bu satırları artık **mekanik olarak** doğrulayabiliyor. **Kapı, mutant ve kural sayıları DEĞİŞMEDİ.**
> **v4 → v5 DEĞİŞİKLİĞİ (K57, oturum 30 — BAYAT ÇAPRAZ-ATIF DÜZELTMESİ):** dokuz kalem, hepsi **ölçülerek** bulundu (araç koşumu + mekanik tarama), hiçbiri yorum değil. **Kapı sayısı, mutant listesi, kurallar ve kabul ölçütlerinin ÖZÜ DEĞİŞMEDİ; değişen yalnız BAYAT SAYILAR ve onların yarattığı çelişkilerdir.**
> ① **T2/Z10 `build_runner ^2.15.2 → ^2.15.1`** — bu SDK'yla **yapısal olarak çözülemiyor** (kanıt: `KANIT/slice-3b/T2-SAPMA.txt`, ham `pub get` çıktısı + pub.dev `/api` zinciri). ② **Z10'a adlandırılmış boşluk** eklendi: *sürüm ölçümü ≠ çözümlenebilirlik ölçümü.* ③ **T0** ve ④ **kriter 14** artık *"en güncel sürüm"* ile *"pinlenmiş sürüm"*ü ayırıyor — düzeltilmeseydi T0 **DUR** der ve build Z10 eşleşmesinde takılırdı (ölçüldü: `pub-surum-olc.py` bugün `build_runner 2.15.2` basıyor). ⑤ **§6 ve kriter 12b `9/9 → 13/13`** (`spec-kapi-kapsama.py` fiilen 13 vaka taşıyor, ölçüldü). ⑥ **§2 ve T9 "yirmi bir mutant" → "yirmi üç"** (belge KENDİ İÇİNDE çelişiyordu; araç 24 mutant etiketi saydı: M1–M23, M2 → M2a/M2b). ⑦ Başlık *"v3 kilitli"* bayattı. ⑧ **Z16/B‑6'ya ikinci chrome ölçümü** eklendi. ⑨ **§10 borç listesinden** `radar.py` R3 kalemi düşürüldü (bugün kapandı).
> **v3 → v4 DEĞİŞİKLİĞİ (K53 verimlilik reformu, tek kalem):** §6'ya **MALİYET SINIFI** eklendi ve koşum sırası **A → B → C** olarak pazarlıksızlaştırıldı. **Mutant sayısı, kapılar, kurallar, kabul kriterleri DEĞİŞMEDİ.** Ölçüldü: 23 mutantın yalnız **3'ü** koşan uygulama istiyor (M3 · M9 · M4); geri kalanı statik tarama veya widget testi ⇒ gerçekçi maliyet **~30-40 dakika**, saatler değil.
> **DÖRT TUR BAĞIMSIZ DENETİMDEN GEÇTİ.** v1 → (üç denetçi: 18 bloker · 39 majör · 16 minör) → v2 → (red-team: 4 bloker · 6 majör · 4 minör) → v3 → (`spec-kapi-kapsama.py`: 2 mutantsız kural) → **v3 kilitli** → v4 (K53) → **v5 kilitli [K57]**.
> ⚠ **v5'in ÖĞRETTİĞİ ŞEY:** bu dokuz kusurun **hiçbirini** dört bağımsız denetim turu bulamadı; dokuzu da **iki araç koşumu ve bir regex taraması** buldu. Bayat sayı, prozayı okuyan göze görünmez — ölçen betiğe görünür.
> **Denetim tarihçesi ve çürütülen bulgular `PROJE_HAFIZA.md` K48/K50/K51'dedir.** Bu belge yalnız **yapılacak işi** taşır.
> 🔴 **KİLİDİN AÇIK ŞARTI [K52]:** radar bu artefaktı **KIRMIZI** bırakıyor; kalan sınıf **`esdeger-mutant`** ve **kâğıtta kapatılamaz** — bir mutantın gerçekten ısırıp ısırmadığı ancak **koşarak** görülür. Kilit, bu sınıfın **BUILD'e devredilmesi** kararıdır (R2b). ⇒ **§6'nın "her mutant için KIRMIZI çıktı" zorunluluğu bu kilidin bedelidir ve gevşetilemez.** Bir mutant ısırmıyorsa **DUR ve raporla** — o an eşdeğer-mutant bulunmuş demektir ve bu **başarıdır**, gizlenecek şey değil.
> **Yazan el denetleyemez (K26):** bu belgeyi Cowork yazdı; **artefaktı Cowork bağımsız doğrulayacak**, senin beyanına güvenmeyecek.

- **Rol:** Sen **build** edersin. `PROJE_HAFIZA.md`, `CLAUDE.md`, **`DESIGN.md`**, `docs/ADR/*`'a **DOKUNMA**.
- **Dil:** Kod/isimler İngilizce; kullanıcı metinleri **Türkçe** (F6); commit mesajı **ASCII**, **çift tırnaksız**.
- **Kök:** Claude Code **DAİMA `Momentum` kökünden** açılır.
- **Ortam:** Flutter 3.44.6 · Dart 3.12.2 · Android SDK 36.1.0 ✓ · Chrome ✓ · **Windows masaüstü ☠** ⇒ `-d windows` yok.
- **Pazarlıksız üç kural:** ① **Ölçmediğini ölçülmüş yazma — `[DOĞRULANMADI]` yaz.** ② **Kör kapı yok:** her kapı ve her kural, mutantıyla kırmızı da yakabildiğini kanıtlar. ③ **Kapıyı gevşetme, mutantı değiştirme, mutant icat etme — DUR ve raporla.**

---

## 0. Önce oku

**`DURUM.md` TAMAMI** · `CLAUDE.md` **TAMAMI** (özellikle **⚡ VERİMLİLİK KURALLARI**) · **`DESIGN.md` TAMAMI**
*(`PROJE_HAFIZA.md`'yi **AÇMA** — append-only arşivdir; bir kararın gerekçesini merak edersen o zaman bak.)* · `araclar/design-token-kapisi.py` (**koddan** anla) · `araclar/mcp-arac-probe.py` · `dosya-kimlik.py` · `pub-surum-olc.py` · `lisans-yokla.py`.

**`DESIGN.md`'yi DEĞİŞTİRME** (K46). Belge ile kod çelişirse **kodu düzelt**; belge yanlışsa **DUR ve raporla**. §10'daki **BD** kalemleri `DESIGN.md`'nin ölçülmüş kusurlarıdır, bu dilimde **kapatılmaz**.

---

## 1. ÖLÇÜLMÜŞ ZEMİN — yeniden keşfetme; doğrula ve geç

Hepsi 26 Tem 2026'da ölçüldü. Biri bugün yanlış çıkarsa **DUR ve raporla**.

**Z1 — dart MCP `1.1.0`, 14 araç.** `tools/list`'ten ölçüldü. `.mcp.json` → `dart pub global run dart_mcp_server`. Doğrulamak için `--help` **okuma**, `araclar/mcp-arac-probe.py`'yi koş.

**Z2 — `flutter_driver_command.command`:** `get_health · enter_text · send_text_input_action · get_text · scroll · scrollIntoView · set_frame_sync · set_semantics · set_text_entry_emulation · tap · waitFor · waitForAbsent · waitForTappable · get_offset · get_diagnostics_tree · **screenshot**`. Finder'lar: `ByType · ByValueKey · ByTooltipMessage · BySemanticsLabel · ByText · PageBack · Descendant · Ancestor`.
Aracın kendi kuralı **pazarlıksızdır**: *"you must first use the widget_inspector tool (with get_widget_tree command)... **Do not guess at how to select widgets**."*

**Z3 — `widget_inspector.command`:** `get_widget_tree · get_selected_widget · set_widget_selection_mode` (+`summaryOnly`). *"Requires an active DTD connection."*

**Z4 — `dtd.command`:** `connect · disconnect · listConnectedApps · listDtdUris`.

**Z5 — `get_runtime_errors`:** `appUri`, `clearRuntimeErrors`; kaynağı **DTD**.

**Z5b — `vm_service`:** `connect · disconnect · callMethod` (+`method`, `isolateId`, `arguments`). **Kapı ayağı DEĞİLDİR** (F1); yalnız teşhis aracıdır. *Ölçüldü: çizen bir uygulamanın canlı isolate'i tanımı gereği vardır ⇒ `getVM` bağımsız bilgi taşımaz.*

**Z6 — WEB'DE EKRAN GÖRÜNTÜSÜ YOKTUR.** `docs.flutter.dev/ai/mcp-server`, birebir: *"**Web**: the `flutter_driver` extension isn't supported on web builds, so finder-based commands like screenshots and taps aren't available there."* Doğrudan kaynaktan iki kez doğrulandı.

**Z7 — `flutter_driver` üçüncü taraf bağımlılık DEĞİLDİR** (`sdk: flutter`) ⇒ lisans/CVE kapısı gerektirmez. `integration_test` **yerine geçmez**. Aynı sayfa: *"Enabling the Flutter Driver extension disables real keyboard input."*

**Z8 — `--print-dtd` ile `--machine` BİRLİKTE KULLANILMAZ** (flutter/flutter#176310). ⚠ `--print-dtd` MCP sayfasında geçmiyor ⇒ **koşumda fiilen doğrula** (B‑4); çıktı vermezse `dtd → listDtdUris` yolunu kullan.

**Z9 — `sqlite3_flutter_libs 0.6.0+eol` ELENEMEZ, transitif gelir.** `drift_flutter 0.3.1` → `drift · flutter · meta · path · path_provider · sqlcipher_flutter_libs ^0.7.0+eol · sqlite3 ^3.0.0 · sqlite3_flutter_libs ^0.6.0+eol`. İkisi de *"Not used anymore"*; native kütüphaneyi `sqlite3` 3.x **build hooks** getirir.

**Z10 — SÜRÜMLER (pub.dev `/api/` ucundan):** `drift 2.34.2` · `drift_flutter 0.3.1` · `drift_dev 2.34.5` · `sqlite3 3.5.0` · `path_provider 2.1.6` · **`build_runner 2.15.1` (PİN — en güncel DEĞİL, bkz. Z10b)**. Altısının da advisory sayısı **0**. Bağımlılık kısıtları: `drift → sqlite3 ^3.4.0`, `drift_flutter → ^3.0.0`, `drift_dev → ^3.0.0`. ⚠ **pub.dev HTML sayfaları BAYAT veri döndürür; kanıt yalnız `/api/` ucudur.**

🔴 **Z10b — ADLANDIRILMIŞ BOŞLUK: SÜRÜM ÖLÇÜMÜ ≠ ÇÖZÜMLENEBİLİRLİK ÖLÇÜMÜ [K57, ÖLÇÜLDÜ].**
`pub-surum-olc.py` bir paketin **en güncel sürümünü** ve **advisory sayısını** ölçer. **Ölçmediği şey:** o sürümün **bu Flutter SDK'sıyla birlikte fiilen çözülüp çözülmediği.** Z10 ilk yazıldığında `build_runner 2.15.2` **doğru ölçülmüştü** (en güncel sürüm oydu) ama pubspec'e yazılıp `pub get` koşulmadan kilitlendi.
**Ölçülen çakışma:** `build_runner ≥2.15.2` → `analyzer ≥13.3.0` → `meta ^1.18.3`; Flutter 3.44.6'nın `flutter_test`'i `meta`'yı **tam 1.18.0**'a sabitliyor ⇒ `build_runner ^2.15.2` bu SDK ile **yapısal olarak çözülemez** (geçici değil, kalıcı). Çözülen küme: `build_runner 2.15.1` → `analyzer 13.0.0` → `meta 1.18.0`. Ham `pub get` çıktısı, `/api` zinciri ve `pub deps` sonucu: **`KANIT/slice-3b/T2-SAPMA.txt`**.
⇒ **KURAL:** bir sürüm pinlenmeden önce `pub get` **fiilen koşulur**. Bir sayının pub.dev'de var olması, onun **bu ağaçta çözüldüğü anlamına gelmez.** Bu boşluk `pub-surum-olc.py`'nin **beyan edilmiş sınırıdır** — araca bir *çözümlenebilirlik ayağı* eklenene kadar **açık borçtur** ve `DURUM.md` §8'de yazılıdır.

**Z11 — WEB VARLIKLARI ELLE İNDİRİLİR.** `sqlite3.wasm` → `simolus3/sqlite3.dart` release **`sqlite3-3.5.0`** (748.424 bayt); `drift_worker.js` → `simolus3/drift` release **`drift-2.34.0`**. Drift dokümanı wasm'ı yanlış yerde gösteriyor.
⚠ **`sqlite3.wasm` DART PAKET SÜRÜMÜNÜ TAŞIMAZ** — içindeki tek sürüm dizgesi `3.53.3`'tür (SQLite **C kütüphanesi**). ⇒ *"wasm sürümü ≤ paket sürümü"* diye bir assert **YAZILAMAZ**; kimlik **pinli sha256**'dır (T5).

**Z12 — COOP/COEP YOKSA KALICILIK DÜŞER — AMA BELLEĞE DEĞİL.** Drift zinciri: `opfsShared → opfsLocks → sharedIndexedDb → unsafeIndexedDb → inMemory`. Başlıklar yoksa **opfs ayakları elenir**, modern tarayıcıda **`sharedIndexedDb` seçilir ve bu KALICIDIR**. `inMemory` yalnız hiçbir kalıcılık API'si yokken seçilir.

**Z13 — `dart pub audit` YOKTUR.** `dart pub get` advisory basar ama **non-zero exit dönmez** (dart-lang/pub#4333 AÇIK).

**Z14 — LİSANS `dart pub deps`'te DE `/api/packages/<ad>`'de DE YOKTUR.** Tek makine-okunur yol: `GET /api/packages/<ad>/metrics` → `scorecard.panaReport.licenses[].spdxIdentifier`. ⚠ Bu uç **dokümantasyonsuz ve sürüm garantisizdir** (dart-lang/pub-dev#4717); kalkanı fixture altın kümesidir.

**Z15 — OSV HÜKMÜ `versions` DEĞİL `ranges` ÜZERİNDEN VERİLİR.** `versions` opsiyoneldir. `dio`'nun **iki** advisory'si var, biri (`GHSA-jwpw-q68h-r678`) **geri çekilmiş duplikat** ⇒ `withdrawn` okunmazsa yanlış-pozitif.

**Z16 — `flutter_test`'in HAZIR a11y guideline'ları:** `androidTapTargetGuideline` (48×48) · `labeledTapTargetGuideline` (tap eylemi olan her düğümde etiket) · `textContrastGuideline` (WCAG). Kullanım: `tester.ensureSemantics()` → `await expectLater(tester, meetsGuideline(...))` → `handle.dispose()`.
⚠ **`textContrastGuideline` GÖRÜNTÜ YAKALAR** (`layer.toImage`) ve `flutter_test`'te bunun `kIsWeb` koruması **yoktur**; aynı pakette *"captureImage is not supported on the web"* yazılıdır ⇒ **kontrast ölçümü `@TestOn('vm')`'dir.** VM'de üç guideline testi fiilen koşuldu ve **3/3 geçti**; `--platform chrome` koşumu **İKİ BAĞIMSIZ ÖLÇÜMDE DE** sonuç üretmedi — **ölçüm 1: 7 dakika** (red-team turu) · **ölçüm 2: 589 saniye ≈ 9,8 dakika** (oturum 30 [K57] itibarıyla en son, boş bir testle, ikinci ve **daha kötü** tekrar) ⇒ web durumu **`[DOĞRULANMADI]`**. *Tekrarlanmış ölçüm tek ölçümden güçlüdür; ikisi de burada bilerek duruyor.*

**Z17 — DÜRÜST SINIR:** Pub advisory havuzunda toplam **~11-13** kayıt var. G2'nin yeşil yanması **güvenlik garantisi değildir**; kapı bir **disiplin vitrinidir**. Bu cümle README'ye ve kapı çıktısına **aynen** girer.

---

## 2. Kapsam — NE VAR / NE YOK

**VAR:** `src/client/` Flutter projesi (`android` + `web`; `ios/` **korunur**, derlenmez) · `lib/design/` token+tema+metin katmanı · Drift ile yerel `gorevler` tablosu ve **TAM ÇEVRİMDIŞI CRUD** · `DESIGN.md` §3.1'in **8 görsel MUST bileşeni** + `MomentumTema` · §4'ün **8 durumu** · **durum vitrini** (F5) · **yedi kapı** G1…G7 · **yirmi üç mutant** (§6; `M2` → `M2a`/`M2b` ayrıldığı için **24 etiket**) · `KANIT/`.

**YOK — adlandırılmış erteleme:**
- **Sunucu ile hiçbir iletişim** (K42-d adım 3‑4). `http`/`dio`/`signalr_*` **eklenmez**.
- **Gerçek senkron durumları** — "kuyrukta"/"senkronize"/"çakışma" bu dilimde gerçek hayatta doğmaz; vitrinde ve testlerde görünür.
- **Çakışma çözüm sayfası** — rozet dokunulabilir, yer tutucu açar.
- **§3.2'nin 8 NICE bileşeni** · **yazı tipi ailesi** · **iOS derlemesi** · **üretim sunucusu başlık yapılandırması**.
- **Web'de kontrast ölçümü** (Z16) — `[DOĞRULANMADI]`, B‑6.
- **`DESIGN.md`'nin BD kusurları** (§10) — K46 gereği kapatılmaz.

---

## 3. KİLİTLİ TASARIM KARARLARI

**F1 — MCP KAPISI: ANDROID'DE 3 GERÇEK AYAK + 1 ÖN KOŞUL; WEB'DE 2 AYAK + 1 ÖN KOŞUL + 1 ÖLÇÜLMÜŞ MUAFİYET [K47 + K49'un geri düşüşü].**
DTD bağlantısı bir **ön koşuldur**, ayak değildir (A2 ve A3 zaten ona bağlıdır). `vm_service` de ayak değildir: çizen bir uygulamanın canlı isolate'i tanımı gereği vardır ⇒ bağımsız bilgi taşımaz. **Kapı "3/3 + ön koşul" der; "4/4" DEMEZ.**

**F2 — CVE KAPISI SAF PYTHON**, kaynak `pub.dev/.../advisories`, hüküm **`ranges`** üzerinden semver ile, **`withdrawn` atılır**, `ignored_advisories` **yutulmaz raporlanır**.

**F3 — DRIFT `drift_flutter` ÜZERİNDEN.** İki `+eol` paket transitif gelir, pubspec'e **elle yazılmaz**. Bu, *"neden ağaçta EOL paket var"* sorusunun **beyan edilmiş** cevabıdır; **lisans muafiyeti DEĞİLDİR** — ikisi de G3 tarafından taranır.

**F4 — SIFIR EK DURUM-YÖNETİMİ PAKETİ, AMA DİKİŞLİ.** Riverpod/BLoC/provider eklenmez; Drift'in `watch()` akışı + `StreamBuilder` yeterlidir. Widget'lar Drift'in ürettiği satır sınıfını **doğrudan tüketmez**; araya tek dosyalık `GorevDeposu` arayüzü konur. *Gerekçe: adım 3'te beslenen tip değişir; dikiş yoksa dokuz bileşen birden yeniden yazılır.*

**F5 — DURUM VİTRİNİ ÖLÜ TUZAĞI ENGELLER, AMA ÖLÇÜMÜN TEK YERİ DEĞİLDİR.**
`--dart-define=DURUM_VITRINI=true`; sabit `saat`/`idUret` ile deterministik; 8 durum `ByValueKey('vitrin_<durum>')` ile bulunur.
🔴 **PAZARLIKSIZ:** G5, vitrinin **yanı sıra** gerçek `GorevListesiEkrani` üzerinde de koşar (boş · yerel · hata). *Gerekçe: vitrin kaydırılabilir sütundur, gerçek liste `ListView` kısıtı altındadır; vitrinde 48dp ölçen satır gerçekte 40dp olabilir, vitrinde imkânsız olan taşma gerçekte doğar.*
Sürüm derlemesinde vitrine yol kalmaması bir **iddiadır**, kriter **13**'te ölçülür.

**F6 — 13 KULLANICI DİZGESİ TEK YERDE.**
Görünür (8): "Yalnızca bu cihazda" · "Gönderiliyor" · "Çevrimdışısınız. Değişiklikler kaydedildi." · "Bu görev başka bir cihazda da değişti." · "Henüz görev yok. Aşağıdan ekleyin." · "Bir şeyler ters gitti." · "Yeniden dene" · "Yükleniyor".
**Semantics duyurusu (5):** "Görevler yükleniyor" · "Senkronize edildi" · "Çevrimdışı" · "Çakışma var" · "Hata".
Hepsi `lib/design/metinler.dart`'ta. Kilit anında `araclar/fixture/metinler-kilit.json`'a dondurulur; G5 `metinler.dart` ↔ fixture karşılaştırır (`DESIGN.md` **ayrıştırılmaz**).

**F7 — `flutter_driver` `dependencies` altında, bayrak korumalı.** `if (const bool.fromEnvironment('ENABLE_FLUTTER_DRIVER')) enableFlutterDriverExtension();` Ağaç sarsımının uzantıyı düşürmesi **iddiadır**, kriter **13**'te ölçülür.

**F8 — SAAT VE KİMLİK DİKİŞLİDİR.** `GorevDeposu` yapıcısı `DateTime Function() saat` ve `String Function() idUret` alır. Üretim: `() => DateTime.now().toUtc()` ve UUID v4. Vitrin ve testler **sabit** implementasyon geçirir.

**F9 — DOSYA SÖZLEŞMESİ.**
```
src/client/lib/
  design/   tokens.dart · tema.dart · metinler.dart     <- ham değer YALNIZ tokens.dart'ta
  veri/     veritabani.dart · veritabani.g.dart · gorev_deposu.dart
  sunum/    8 bileşen + gorev_listesi_ekrani.dart
  vitrin/   durum_vitrini.dart
test/                <- birim + widget testleri (VM)
integration_test/    <- cihaz/tarayıcı gerektirenler
```

---

## 4. Teslimat adımları

**T0 — ZEMİNİ DOĞRULA (kod yazmadan).** `python araclar\mcp-arac-probe.py -- cmd /c dart pub global run dart_mcp_server` → **1.1.0 · 14 araç**. `python araclar\pub-surum-olc.py drift drift_flutter drift_dev sqlite3 path_provider build_runner`.
🔴 **BU KARŞILAŞTIRMA İKİ AYRI ŞEYDİR — KARIŞTIRMA [K57/Z10b]:** araç **EN GÜNCEL** sürümü basar; Z10 **PİNLENMİŞ** sürümü yazar. **Beş paket** (`drift · drift_flutter · drift_dev · sqlite3 · path_provider`) için ikisi **eşleşmeli**; eşleşmezse **DUR ve raporla**. **`build_runner` BİLEREK AYRIKTIR:** araç `2.15.2` (en güncel) basacaktır, pin ise **`^2.15.1`**'dir — bu bir **sapma değil, ölçülmüş ve gerekçelendirilmiş pindir** (Z10b, `KANIT/slice-3b/T2-SAPMA.txt`). `build_runner` için **eşleşmemesi BEKLENEN davranıştır; DUR deme.** Bunun yerine **`flutter pub get`'in EXIT 0 döndüğünü ÖLÇ** — `build_runner` için gerçek kabul ölçütü **sayı eşleşmesi değil, ÇÖZÜLEBİLİRLİKTİR**.
**`flutter test --platform chrome`'un boş bir testle fiilen sonuç ürettiğini ÖLÇ** (Z16); üretmiyorsa kriter 2'nin web ayağı `[DOĞRULANMADI]` yazılır.

**T1 — İSKELET.** `flutter create --platforms=android,web --org com.momentum src/client`. `windows/`, `linux/`, `macos/` varsa silinir; **`ios/` SİLİNMEZ**. `flutter_lints` etkin. Build artefaktları `.gitignore`'da.

**T2 — BAĞIMLILIKLAR.**
`dependencies:` `flutter (sdk)` · `flutter_driver (sdk)` · `drift ^2.34.2` · `drift_flutter ^0.3.1` · `path_provider ^2.1.6`
`dev_dependencies:` `flutter_test (sdk)` · `drift_dev ^2.34.5` · **`build_runner ^2.15.1`** · `flutter_lints`
🔴 **`build_runner` PİNİ ^2.15.1'DİR VE YÜKSELTİLEMEZ [K57].** `^2.15.2` bu Flutter SDK'sıyla **yapısal olarak çözülemez** (`meta 1.18.0` ↔ `meta ^1.18.3` çakışması; tam zincir **Z10b** ve `KANIT/slice-3b/T2-SAPMA.txt`). `pub get` bir yükseltme önerirse **uygulama; DUR ve raporla.**
`sqlite3` **elle yazılmaz** (transitif gelir, `pubspec.lock` tek sürüme çözer). `sqlite3_flutter_libs` / `sqlcipher_flutter_libs` **elle eklenmez**. Başka paket **eklenmez**; ihtiyaç doğarsa **DUR ve sor**.

**T3 — TOKEN KATMANI.** `tokens.dart` — §1 `tokens` bloğundaki **tüm** semboller.
**İMZA SÖZLEŞMESİ:** renk sembolleri `MRenk.yuzey(BuildContext)` biçiminde, `Theme.of(context).brightness` üzerinden çözer. Bu erişimden **yalnız `tokens.dart` ve `tema.dart` muaftır** (D5); başka hiçbir dosya değil.
NICE token'lar da yazılır (tema tam olsun) — bu, `DESIGN.md` §0 KULLANIM KISITI'nın token tarafına **bilinçli olarak uygulanmadığı**, burada yazılı bir istisnadır.

**T4 — VERİ KATMANI.** `veri/veritabani.dart` Drift tablosu `gorevler`: `id` (metin, `idUret()`'ten) · `baslik` · `tamamlandi` (bool) · `olusturuldu`/`guncellendi` (DateTime **UTC**, `saat()`'ten) · `senkronDurumu` (metin + **CHECK kısıtı: yalnız `yerel`**) · `silindi` (bool, yumuşak silme).
`veri/gorev_deposu.dart` — F4'ün dikişi. **Görünür kayıtlara TEK erişim yolu `gorevlerGorunur()`'dur** (`silindi = false` filtresi orada, tek yerde). `.g.dart` repoya commit edilir.

**T5 — WEB VARLIKLARI.** `araclar/web-varlik-indir.py`: `sqlite3.wasm` ve `drift_worker.js` indirir, sha256'sını **`araclar/web-varlik.sha256`'daki pinli değerle** karşılaştırır, uyuşmazsa **exit≠0**. Bu dosya ayrıca her varlığın **kaynak deposunu ve release tag'ini** metin olarak taşır. ⚠ **Pinin ilk kaynağı ilk indirmedir (TOFU); bu bir güven varsayımıdır ve betiğin çıktısına BASILIR.** Sürüm karşılaştırması **yapılmaz** (Z11). İki ikili `web/` altına commit edilir ve **G3'ün kapsamına girer**.

**T6 — BİLEŞENLER.** §3.1'in 8 görsel bileşeni + `MomentumTema` (widget değil ⇒ ayrı birim testi: açık/koyu `ThemeData` çözümü).
🔴 **PAZARLIKSIZ DOKUNMA SINIRI:** `CakismaRozeti` **kendi `GestureDetector`'ını taşır** ve görünür metin düğümünün **dışındadır**; `GorevSatiri`'nın kendisi `onTap` taşımaz. *Gerekçe: dokunulabilir alan satır olursa metin semantics düğümüne girer ve M7 ısırmaz.*

**T7 — DURUM VİTRİNİ (F5).** `vitrin/durum_vitrini.dart`; deterministik; 8 durum anahtarlı.

**T8 — KAPI ARAÇLARI.** `araclar/pub-cve-kapisi.py` (G2) · `araclar/pub-lisans-kapisi.py` (G3) · `design-token-kapisi.py`'ye **D5 + D6 eklenir** (K34-f: aracı Cowork yazdı, **onaran el sensin** — meşru). **Her araç ÖNCE kendi altın kümesinde kanıtlanır** (K44-a), sonra gerçek koşum. Mevcut altın küme **12 vakadır** ve bozulmamalıdır.

**T9 — KAPILAR VE MUTANTLAR.** Yedi kapı, **yirmi üç mutant** (24 etiket: `M2` → `M2a`/`M2b`); çıktılar `KANIT/slice-3b/` altına.

---

## 5. KAPILAR

### G1 — MCP KAPISI: 3 GERÇEK AYAK + 1 ÖN KOŞUL [F1]
**Ön koşul:** `dtd` → `listDtdUris` → `connect`. **Ayak sayılmaz.**
**Koşum (Android):** `flutter run -d <emulator-id> --dart-define=ENABLE_FLUTTER_DRIVER=true --dart-define=DURUM_VITRINI=true --print-dtd` (**`--machine` YASAK**).

| ayak | araç | ölçtüğü |
|---|---|---|
| **A1** | `flutter_driver_command` → `command: screenshot` | uygulama çiziyor |
| **A2** | `widget_inspector` → `get_widget_tree` (`summaryOnly: true`), **İKİ yakalama** | iki ağacın **BİRLEŞİMİNDE 8 görsel bileşen adıyla** var |
| **A3** | `get_runtime_errors` | temizde **boş**, M3 altında **dolu** |

🔴 **A2 NEDEN İKİ YAKALAMA — ÖLÇÜLDÜ, gevşetme DEĞİL [K59]:** hiçbir **tek** yakalama 8 bileşeni gösteremez ve bunun sebebi **bu spec'in kendi §2 kapsam kararıdır**. Ölçüm: `GorevSatiri` içinde `SenkronRozeti` **koşulsuz**, `CakismaRozeti` ise **yalnız `cakismaVarMi == true`** iken doğar; `cakismaVarMi`'yi **sadece durum vitrini** `true` yapar, çünkü §2 *"'çakışma' bu dilimde gerçek hayatta doğmaz; vitrinde ve testlerde görünür"* diyor. Buna karşılık `GorevEkleAlani` ve `GorevListesiEkrani` **vitrinde yoktur**, yalnız gerçek ekranda vardır.
⇒ **ZORUNLU:** ① **durum vitrini** ağacı, ② **gerçek `GorevListesiEkrani`** ağacı. **HER İKİSİNİN HAM JSON'u** `KANIT/02.../01-G1-android/` altına **olduğu gibi** yazılır (özet değil — *"ham JSON şu dosyada"* deyip aynı dosyada prozayla anlatmak **kanıt değildir**). Birleşim **8 sınıf adını** kapsamıyorsa **kapı KIRMIZI'dır**. *Bu şart tek yakalamadan **daha pahalıdır**; kapı gevşetilmemiş, sağlanamaz olan sağlanabilir hale getirilmiştir.*
**A1 sahte-yeşil koruması:** *"PNG oluştu"* **yetmez**; ayrıca ağaçta `ErrorWidget` **bulunmayacak** ve görüntü boyutu cihaz çözünürlüğüyle uyuşacak.
**Widget seçimi:** önce `get_widget_tree`, sonra ağaçta **gerçekten görülen** metin/tip ile finder. **Tahmin YASAK** (Z2).
**Web:** `flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp --dart-define=DURUM_VITRINI=true --print-dtd`. A2 ve A3 koşar.
🔴 **G1/W — MUAFİYET İDDİA EDİLMEZ, ÖLÇÜLÜR:** web'de `flutter_driver_command: screenshot` **fiilen çağrılır**, dönen hata `KANIT/02-G1-web/MUAF-kanit.txt`'e yazılır. **Hata metni yoksa muafiyet geçersizdir ve kapı kırmızıdır.**
⚠ dart-lang/ai#356 `-d web-server`'da DTD'nin açılmadığını bildiriyor. `-d chrome` ile başla; bağlanmazsa **DUR** (B‑3).

### G2 — CVE KAPISI — `araclar/pub-cve-kapisi.py`
**Girdi:** `pubspec.lock` **ve** `pubspec.yaml` (`ignored_advisories`).
**Hüküm:** `/advisories` → `withdrawn` olan kayıt **atılır** → `affected[].ranges` `introduced`/`fixed` **semver** ile değerlendirilir (`versions` yalnız destekleyici delil). `ignored_advisories`'teki bulgu **"BASTIRILMIŞ" diye raporlanır**, yutulmaz. Çıkış: 0 · 1 · 3.
**ALTIN KÜME — AĞA ÇIKMAZ (fixture), 8 vaka:** ① temizde susar ② `dio 4.0.6` fixture'ında ısırır ③ `dio 5.0.0`'da susar ④ advisory'siz pakette susar ⑤ **`versions` boş, yalnız `ranges` dolu** kayıtta ısırır ⑥ **`withdrawn` kayıtta SUSAR** ⑦ bozuk JSON'da exit 3 ⑧ `ignored_advisories` raporlanır.
Kapının çıktısına **Z17 cümlesi aynen basılır**.

### G3 — LİSANS KAPISI — `araclar/pub-lisans-kapisi.py`
**Girdi:** `pubspec.lock`'taki tüm paketler (transitif dahil). **Kaynak (Z14):** `/api/packages/<ad>/metrics` → `scorecard.panaReport.licenses[].spdxIdentifier`.
**İzinli:** MIT · BSD‑2‑Clause · BSD‑3‑Clause · Apache‑2.0. Başkası ⇒ **BULGU**. **Boş/eksik `licenses` ⇒ BULGU** (*"bilinmeyen ≠ temiz"*).
**SDK paketleri** (`flutter`, `flutter_driver`, `flutter_test`) pub.dev'de yoktur ⇒ 404. **404 sessizce temiz sayılmaz**; `SDK — kapsam dışı, gerekçeli` diye **ayrı listelenir**.
**Vendored ikililer:** `drift_worker.js` → simolus3/drift, **MIT**. `sqlite3.wasm` → **sarmalayıcı MIT (simolus3/sqlite3.dart), gömülü SQLite çekirdeği PUBLIC DOMAIN** — ikisi ayrı satır olarak yazılır.
**BEYAN EDİLMİŞ SINIR (kapı çıktısına basılır):** *"`/metrics` ucu dokümantasyonsuz ve sürüm garantisizdir; pana'nın lisans tespiti kusursuz değildir. Bu bir disiplin kapısıdır, hukuki güvence değildir."*
**ALTIN KÜME (fixture), 4 vaka:** ① hepsi MIT ⇒ susar ② GPL‑3.0 ⇒ ısırır ③ `licenses` boş ⇒ ısırır ④ 404 ⇒ ayrı listeler, susmaz.

### G4 — DESIGN-TOKEN KAPISI (mevcut araç + D5/D6)
`python araclar\design-token-kapisi.py --altin-kume` (EXIT 0) → `python araclar\design-token-kapisi.py .`

| kod | ne yakalar |
|---|---|
| `D0`–`D4` | mevcut: blok biçimi · kullanılmayan MUST · ham literal · tanımsız sembol · gerekçesiz muafiyet |
| **`D5`** | `tokens.dart` ve `tema.dart` **dışında** `Theme.of(` ile renk/tipografi erişimi |
| **`D6`** | `lib/` altında `package:flutter/cupertino.dart` importu |

🔴 **D1 SIKILAŞTIRMASI VE ADIYLA MUAFİYETİ:** bir MUST token'ın **yalnız `lib/design/` içinde** kullanılması D1'i doyurmaz; en az bir kullanım `lib/design/` **dışında** olmalıdır.
**MUAF (4 token, ADIYLA):** `renk.yuzey.ikincil` · `renk.metin` · `hareket.hizli` · `olcu.odak.kalinlik`. **Gerekçe ölçüldü:** `DESIGN.md` §3.1'in sekiz bileşenine atanmış token'ların birleşimi 20'dir; bu dördü **hiçbir bileşene atanmamıştır** ve meşru yerleri `tema.dart`'tır. Sıkılaştırmayı bunlara uygulamak, builder'ı ya §8.7'yi ihlal etmeye ya süs kullanım yazmaya zorlar. Bu **BD‑7**'nin doğrudan sonucudur.
⚠ **D5'in kapsamı §8.7'den GENİŞTİR:** §8.7 muafiyeti *"yalnız `tokens.dart`"* der; D5 `tema.dart`'ı da muaf tutar, çünkü `ThemeData` çözümü orada yaşar. **Bu fark beyan edilmiştir.**
**Yeni kodların altın küme vakaları ZORUNLUDUR** (K40). Mevcut 12 vaka bozulmamalıdır.

### G5 — A11Y KAPISI — `test/a11y_kapisi_test.dart`, hüküm `flutter test`'in exit kodu

| kural | ölçüm |
|---|---|
| A11Y‑1 | `expectLater(tester, meetsGuideline(androidTapTargetGuideline))` |
| A11Y‑2 | `GorevEkleAlani`'nın `InputDecoration.focusedBorder.borderSide` → `width == MOlcu.odakKalinlik` ve `color == MRenk.birincil(context)` |
| A11Y‑3 | `expectLater(tester, meetsGuideline(labeledTapTargetGuideline))` |
| A11Y‑4 | `textScaler: TextScaler.linear(2.0)` altında **taşma** (`FlutterError`) **ve KIRPMA**: kırpma sessizdir ⇒ ayrıca `Text` düğümlerinde `overflow == ellipsis \|\| maxLines != null` **statik taraması** |
| A11Y‑5 | `disableAnimations: true` altında tüm sürelerin **0** olduğu assert'i |
| A11Y‑6 | her durumun semantics ağacında **ikon düğümü VE metin düğümü** taşıdığı assert'i |
| A11Y‑7 | `SemanticsService.announce` yakalanır; duyurulan dizge **F6'daki beşle birebir** |
| kontrast | `expectLater(tester, meetsGuideline(textContrastGuideline))` — **`@TestOn('vm')`** (Z16) |
| metin | `metinler.dart` ↔ `fixture/metinler-kilit.json` **13 dizge** birebir |

🔴 **KOŞUM YERİ:** her ölçüm **hem** durum vitrininde **hem** gerçek `GorevListesiEkrani`'nde (boş · yerel · hata) koşar; sonuçlar `KANIT/`'ta **ayrı ayrı**.
**WEB:** kontrast **hariç** aynı testler `flutter test --platform chrome` ile de koşar (T0'da bu koşumun çalıştığı ölçülmüş olmalı). Android sonucu web için **beyan edilmez**; fark çıkarsa `[DOĞRULANMADI]` yazılır.

### G6 — KALICILIK KAPISI
**Ölçüm:** açılışta seçilen depolama implementasyonu okunur ve `KANIT/`'a yazılır. Drift'in `WasmDatabase.open` sonucunun `chosenImplementation`/`missingFeatures` alanlarını **build eden el ÖNCE doğrular** (B‑1); tutmazsa `[DOĞRULANMADI]` yazıp **DURUR**.
**Eşik:** web'de beklenen **`opfsShared` veya `opfsLocks`**. `sharedIndexedDb`/`unsafeIndexedDb` ⇒ **KIRMIZI** (kalıcı olsa da COOP/COEP kaybıdır). `inMemory` ⇒ **KIRMIZI + uygulama FAIL-FAST**.
**Android:** yerel dosya yolu seçildiği ve dosyanın **fiilen oluştuğu** ölçülür.
**Varlık kimliği:** `araclar/web-varlik.sha256`'daki pinli sha256 doğrulanır. **Sürüm karşılaştırması YAPILMAZ** (Z11).

### G7 — VERİ KATMANI KAPISI — `test/veri_kapisi_test.dart`
Sabit `saat`/`idUret` ile deterministik: ① beş işlem uçtan uca (ekle · düzenle · tamamla/geri al · sil · listele) ② **yumuşak silme**: silinen kayıt `gorevlerGorunur()`'da yok, ham tabloda var ③ **boş durum** doğru zamanda ④ `olusturuldu`/`guncellendi` daima `isUtc == true` ⑤ `guncellendi` her yazımda ilerler, `olusturuldu` değişmez ⑥ `senkronDurumu`'na `yerel` dışı yazma **DB kısıtından düşer**.

---

## 6. MUTANTLAR — yirmi üç; KAPALI ve numaralı liste

> **Protokol:** mutantı uygula → kapıyı koş → **kırmızı çıktıyı kaydet** → geri al → yeşil. **Isırmıyorsa DUR ve raporla.**
> **Liste KAPALIDIR.** Mutant **icat etme**. Her kapı **ve her kural** en az bir mutant taşır.
>
> 🔴 **MALİYET SINIFI [K53] — SIRALAMA BUNA GÖRE YAPILIR:**
> - **Sınıf A — STATİK** (`design-token-kapisi.py` / betik koşumu, **derleme yok, emülatör yok**, saniyeler): **M1 · M2a · M2b · M8 · M11 · M12 · M14 · M20 · M21 · M22 · M23**
> - **Sınıf B — WIDGET/BİRİM TESTİ** (`flutter test`, **emülatör yok**, saniyeler): **M5 · M6 · M7 · M10 · M13 · M15 · M16 · M17 · M18 · M19**
> - **Sınıf C — KOŞAN UYGULAMA** (emülatör/tarayıcı + yeniden derleme, dakikalar): **M3 · M9 · M4** — **TAM ÜÇ. K53'ün tavanı 3'tür ve bu dilim tavandadır; DÖRDÜNCÜSÜ EKLENEMEZ.**
>
> **Koşum sırası PAZARLIKSIZ: önce A (hepsi tek oturumda), sonra B, EN SON C.** Gerekçe: A ve B sınıfı mutantlar ucuzdur ve C sınıfına geçmeden önce kodun büyük kısmını zaten doğrular; pahalı olanı sona bırakmak, ucuz bir kusur yüzünden emülatör turunu tekrarlamayı önler.

| # | mutant | kapı / kural | beklenen kırmızı |
|---|---|---|---|
| **M1** | `tokens.dart`'tan bir MUST sembolünü sil | G4 / D3 | `D3` |
| **M2a** | Bir bileşene `Color(0xFF123456)` ham literali koy | G4 / D2 | `D2` |
| **M2b** | Aynı literali **çok satırlı `/* */` bloğu içine** koy | G4 / D2 sınırı | ⚠ **ISIRMAYABİLİR** — `DESIGN.md` A‑4'ün beyan edilmiş sınırı. Sonuç ne olursa olsun `KANIT/05-G4/M2b.txt`'e yazılır; ısırmazsa **borç ölçülmüş** olur, başarısızlık değildir |
| **M3** | Vitrine `build()` içinde `throw StateError('mutant')` atan widget koy | G1 / A3 | `get_runtime_errors` **dolu** |
| **M4** | `--web-header=` bayraklarını kaldır | G6 | Seçilen implementasyon `opfs*` **değil** ⇒ kırmızı |
| **M5** | `GorevSatiri` dokunma hedefini 32dp'ye sabitle | G5 / A11Y‑1 | `androidTapTargetGuideline` FAIL |
| **M6** | `MediaQuery.disableAnimations` kontrolünü kaldır | G5 / A11Y‑5 | Süre ≠ 0 ⇒ FAIL |
| **M7** | `CakismaRozeti`nin `Semantics` etiketini sil | G5 / A11Y‑3 | `labeledTapTargetGuideline` FAIL |
| **M8** | `pubspec.lock`'a elle `dio 4.0.6` satırı enjekte et | G2 | `GHSA-9324-jv53-9cc8`, exit 1 |
| **M9** | `main()`'den `enableFlutterDriverExtension()` çağrısını kaldır | G1 / A1 | `screenshot` başarısız |
| **M10** | Bir bileşende `Metinler.bosDurum` yerine düz dizge yaz | G5 / metin | Metin assert'i FAIL |
| **M11** | `pubspec.lock`'a elle **GPL‑3.0 lisanslı, pub.dev'de VAR OLAN** bir paket satırı enjekte et | G3 | İzinsiz lisans bulgusu, exit 1 |
| **M12** | Bir bileşende `Theme.of(context).colorScheme.primary` kullan | G4 / D5 | `D5` |
| **M13** | `gorevlerGorunur()`'dan `silindi = false` filtresini kaldır | G7 | Silinen kayıt listede görünür ⇒ FAIL |
| **M14** | `pubspec.lock`'taki bir paketi `licenses` alanı BOŞ dönen bir sürüme çevir (fixture) | G3 | *"bilinmeyen ≠ temiz"* ⇒ bulgu |
| **M15** | Odak halkası kalınlığını 0 yap (`focusedBorder.borderSide.width = 0`) | G5 / A11Y‑2 | Kalınlık assert'i FAIL |
| **M16** | `GorevSatiri` başlığına sabit yükseklik + `maxLines: 1` ver | G5 / A11Y‑4 | Kırpma statik taraması FAIL |
| **M17** | Çevrimdışı rozetinden **metin düğümünü** sil, yalnız ikon+renk bırak | G5 / A11Y‑6 | İkon+metin assert'i FAIL |
| **M18** | `SemanticsService.announce` çağrısını kaldır (veya dizgeyi boz) | G5 / A11Y‑7 | Duyuru assert'i FAIL |
| **M19** | `renk.metin.ikincil`'i yüzeye çok yakın bir değere çek (`tokens.dart`) | G5 / kontrast | `textContrastGuideline` FAIL |
| **M20** | `lib/sunum/`'daki bir dosyaya `import 'package:flutter/cupertino.dart';` ekle | G4 / D6 | `D6` |
| **M21** | Bir MUST token'ın tek bileşen kullanımını `tema.dart`'a taşı | G4 / D1 sıkılaştırması | `D1` |
| **M22** | `DESIGN.md`'nin **kopyası** üzerinde `tokens` bloğunun bir satırını boz (`->` ayracını sil) | G4 / D0 | `D0` |
| **M23** | Bir bileşene **gerekçesiz** `// [DESIGN-LITERAL]` muafiyeti koy | G4 / D4 | `D4` |

**Kapı ↔ mutant:** G1 → M3·M9 · G2 → M8 · G3 → M11·M14 · G4 → M1·M2a·M2b·M12·M20·M21·M22·M23 · G5 → M5·M6·M7·M10·M15·M16·M17·M18·M19 · G6 → M4 · G7 → M13.
**Mutantsız kapı YOK; mutantsız KURAL da yok.**
🔴 **BU KAPSAMA İDDİA DEĞİL, ÖLÇÜLÜR:** `python araclar\spec-kapi-kapsama.py --altin-kume` (**13/13, EXIT 0** — K57'de yeniden ölçüldü; eski *"9/9"* rakamı **bayattı**, araç K53'te 9 → 13 vakaya çıkmıştı) → `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-slice-3b-istemci-iskeleti.md` (**EXIT 0**; K57 sonrası yeniden ölçüldü: **7 kapı · 16 kural · 24 mutant etiketi**, bulgu yok). *Bu araç ilk koşumunda `D0` ve `D4`'ün mutantsız olduğunu buldu — üç denetim turunun hiçbiri bulmamıştı. Aracın beyan edilmiş sınırı: mutantın **gerçekten ısırdığını** ölçmez, yalnız **kapsamayı** ölçer.*
⚠ **M22'ye dikkat:** `DESIGN.md`'nin **kendisi değiştirilmez** (K46). Mutant, `araclar/fixture/` altındaki bir **kopya** üzerinde koşar ve kapı o kopyaya yöneltilir.
⚠ **M11 için:** GPL‑3.0 lisanslı ve pub.dev'de var olan bir paket **ÖLÇÜLEREK** bulunur (`/metrics` ile doğrula) ve adı `KANIT/04-G3/`'e yazılır. Bulunamazsa mutant **fixture ayağıyla sınırlı kalır** ve bu **beyan edilir** — sessizce atlanmaz.

---

## 7. Kabul kriterleri

1. `flutter analyze --fatal-infos --fatal-warnings` — **0 bulgu**.
2. `flutter test` (VM) **ve** `flutter test --platform chrome` **ayrı ayrı** yeşil. Koşulsuz atlanan test **YOK**; `@TestOn` yalnız karşı platformda fiilen koşuyorsa meşrudur. Chrome koşumu T0'da çalışmadıysa bu ayak `[DOĞRULANMADI]` yazılır ve **gizlenmez**.
3. `flutter build apk --debug` ve `flutter build web` başarılı.
4. **G1 Android: A1·A2·A3 yeşil**, üçünün kırmızısı `KANIT/`'ta. **A2 için İKİ ham ağaç JSON'u** (vitrin + gerçek ekran) dosyada **olduğu gibi** durur ve **birleşimleri 8 sınıf adını kapsar** — kapsamıyorsa kapı **KIRMIZI**.
5. **G1 Web: A2·A3 yeşil + A1 muafiyeti `MUAF-kanit.txt` ile ÖLÇÜLMÜŞ** (hata metni yoksa FAIL).
6. **`python araclar\pub-cve-kapisi.py --altin-kume` EXIT 0 (8/8)**; gerçek tarama + **ham JSON yanıtları ve sorgu zaman damgası** `KANIT/`'ta.
7. **`python araclar\pub-lisans-kapisi.py --altin-kume` EXIT 0 (6/6)**; izinsiz lisans **0**; SDK paketleri ayrı listelenmiş; vendored ikililer kapsamda ve `sqlite3.wasm` iki satır hâlinde yazılmış; **metin-kanıtlı eşleşmelerin hepsi `ESLENDI` satırıyla basılmış** (kanıtsız eşleşme KIRMIZI).
8. **`python araclar\design-token-kapisi.py --altin-kume` EXIT 0 (18/18)** (12 mevcut + D1/D5/D6'nın 6 yeni vakası); gerçek koşumda `D0`–`D6` **hepsi 0**.
9. **G5**: dokuz ölçüm Android'de yeşil, **vitrinde VE gerçek ekranda**; web koşumu ayrı raporlanmış.
10. **G6**: web'de `opfsShared|opfsLocks` ölçülmüş; Android'de dosya fiilen oluşmuş; sha256 pinleri doğrulanmış.
11. **G7**: altı maddenin hepsi yeşil.
12. **Yirmi üç mutantın hepsi koşulmuş**; M2b hariç hepsi ısırmış, M2b'nin sonucu yazılmış; M11 fixture'a düştüyse beyan edilmiş.
12b. **`python araclar\spec-kapi-kapsama.py --altin-kume` EXIT 0 (13/13)** ve aynı araç bu spec üzerinde **EXIT 0** — mutantsız kapı/kural **YOK**, hayalet atıf **YOK**. ⚠ **Sayı ezberden yazılmaz, çıktıdan okunur:** araç yeni vaka kazandıysa buradaki rakam da güncellenir. Bu satır artık **mekanik olarak korunuyor** — `python araclar\sayi-tazeligi.py . <belge>` bayat rakamı ısırır (kabul kriteri **12c**).
12c. **`python araclar\sayi-tazeligi.py --altin-kume` EXIT 0 (16/16)** ve aynı araç bu spec + `DURUM.md` + `DESIGN.md` üzerinde **EXIT 0** — belgedeki hiçbir "altın küme N/M" iddiası bayat değil, ölçülemeyen her iddia **gerekçeli muafiyet** kaydı taşıyor.
13. **Sürüm derlemesi:** `flutter build apk --release` sonrası vitrine yol **yok**; `enableFlutterDriverExtension` sembolünün düştüğü **ÖLÇÜLÜR** — ölçülemezse `[DOĞRULANMADI]`.
14. **T0 çıktısı** `KANIT/00-ortam.txt`'te: MCP **1.1.0 · 14 araç**; **beş paket** (`drift · drift_flutter · drift_dev · sqlite3 · path_provider`) Z10 ile eşleşmiş; **`build_runner` için sayı eşleşmesi ARANMAZ** — bunun yerine **pin `^2.15.1`** ve **`flutter pub get` EXIT 0** yazılmış (Z10b); chrome test koşumunun durumu yazılmış.
15. `git --no-optional-locks status --porcelain` **temiz**; build artefaktı repoda yok; **`DESIGN.md` sha256 `534DFF68` DEĞİŞMEMİŞ** (`python araclar\dosya-kimlik.py DESIGN.md`).

---

## 8. KANIT protokolü

`KANIT/slice-3b/` → `00-ortam.txt` · `01-G1-android/` · `02-G1-web/` (+`MUAF-kanit.txt`) · `03-G2/` (altın küme · gerçek tarama · ham JSON · M8) · `04-G3/` (altın küme · lisans tablosu · SDK listesi · M11 · M14) · `05-G4/` (altın küme · gerçek hüküm · M1 · M2a · **M2b** · M12 · M20 · M21 · M22 · M23 · `spec-kapi-kapsama` çıktısı) · `06-G5/` (Android vitrin + Android gerçek ekran + web, **ayrı ayrı** · M5·M6·M7·M10·M15·M16·M17·M18·M19) · `07-G6/` (implementasyon ölçümü · sha256 · M4) · `08-G7/` (altı madde · M13) · `HUKUM.md`.

**KANIT kuralı (pazarlıksız):** bir kapı için hem yeşil hem **kırmızı** çıktı yoksa o kapı **geçmemiş sayılır**. `HUKUM.md` kendi beyanın değil, **çıktıya atıflı** olur.

---

## 9. Kırmızı çizgiler — bu dilimde YASAK

1. `PROJE_HAFIZA.md` · `CLAUDE.md` · **`DESIGN.md`** · `docs/ADR/*`'a yazmak (K46).
2. Spec'te adı geçmeyen paketi eklemek. İhtiyaç doğarsa **DUR ve sor**.
3. Ağ çağrısı yapan **uygulama** kodu (kapı betikleri `araclar/` altındadır, muaftır).
4. Kapıyı gevşetmek · mutantı değiştirmek · **mutant icat etmek** · test `skip` etmek.
5. `--print-dtd` ile `--machine`'i birlikte kullanmak.
6. Ölçmediğini ölçülmüş gibi yazmak.
7. Commit mesajında **çift tırnak**; `git push` (**push Onur'un işidir**).
8. Kullanıcı metnini veya semantics duyurusunu F6'dan farklı yazmak.
9. `tokens.dart`/`tema.dart` dışında `Theme.of` ile renk almak · `cupertino.dart` import etmek.

---

## 10. Açık kalemler / devir

**ÖNCE ÖLÇÜLECEKLER (kapatılmadan ilerlenmez):**

| # | kalem |
|---|---|
| **B‑1** | `WasmDatabaseResult.chosenImplementation` / `missingFeatures` alan adları doğrulanmadan G6 yazılmaz |
| **B‑2** | `flutter_driver`'ın sürüm derlemesinde düşüp düşmediği (kriter 13) |
| **B‑3** | `-d chrome` ile DTD'nin gerçekten bağlandığı — bağlanmazsa **DUR** |
| **B‑4** | `--print-dtd`'nin fiilen çıktı verdiği (Z8'in atıf sınırı) |
| **B‑5** | Web'de semantics (aria) davranışının Android'den farkı — fark varsa `[DOĞRULANMADI]` |
| **B‑6** | `flutter test --platform chrome`'un fiilen sonuç ürettiği (Z16). **İki bağımsız ölçüm de sonuç vermedi: 7 dk (ölçüm 1) ve 589 sn ≈ 9,8 dk (ölçüm 2, daha kötü tekrar).** Üçüncü kez denenecekse **süre sınırı önceden yazılır**; sınırsız bekleme ölçüm değildir |

**`DESIGN.md`'NİN ÖLÇÜLMÜŞ KUSURLARI — K46 gereği bu dilimde KAPATILMAZ (Onur: "borç kalsın"):**
**BD‑1** §1.1 koyu tema değerleri **tablodur**, `tokens` bloğunda değil ⇒ G4 okuyamaz, **koyu tema kapısız**. · **BD‑2** `renk.ayirici`'nin *"bir kontrolün tek tanımlayıcısı olamaz"* kuralı **A11Y numarası taşımıyor** ⇒ G5 kapsamı dışında, **ölü kural**; üstelik `GorevSatiri` onu satır ayırıcısı olarak kullanıyor. · **BD‑3** **odak halkası / birincil buton** kontrast çifti §2.1'de **yok** ⇒ ekle düğmesinde halka **1,00:1** olabilir. · **BD‑4** `MomentumTema` widget **değil**, "9 MUST bileşeni" sayımı yanlış (gerçek görsel sayı **8**). · **BD‑5** `tipo.baslik.l = 20/28`'de 28'in mutlak mı oran mı olduğu yazılı değil ⇒ mutlak uygulanırsa 2.0× ölçekte **sessiz kırpma**. · **BD‑6** §0 ve §10 *"altın küme 10/10"* diyor; araç fiilen **12 vaka** taşıyor ⇒ sayı bayat. · **BD‑7** §3.1 tablosu dört MUST token'ı (`renk.yuzey.ikincil` · `renk.metin` · `hareket.hizli` · `olcu.odak.kalinlik`) **hiçbir bileşene atamıyor**.

**DİĞER AÇIK BORÇLAR:** `pub.dev` uçlarının (`/advisories`, `/metrics`) dokümantasyonsuz ve sürüm garantisiz olması — kalkan fixture altın kümeleridir · **`pub-surum-olc.py`'ye ÇÖZÜMLENEBİLİRLİK AYAĞI** (Z10b'nin adlandırılmış boşluğu: araç sürümü ölçüyor, çözülebilirliği ölçmüyor — bu dilimin **en pahalı** kusuru buradan çıktı) · kontrast betiğinin kalıcı hâli (kod tarafı G5'in `textContrastGuideline` ayağıyla **kısmen** kapandı, web tarafı `[DOĞRULANMADI]`).
> ✅ **KAPANDI [K57]:** *"`radar.py`'nin R3 asgari örneklem koruması (ayrı el)"* kalemi bu listeden **düşürüldü** — `araclar/radar.py` 26 Tem 2026'da `proje-radari` plugin **0.2.0** ile bayt-bayt eşitlendi; R3 asgari örneklem koruması **VAR** ve altın kümesi **18/18, EXIT 0**. Ayrıca ürün-kodu kuralının adı `R7` → **`R8`** oldu (`R7` doktrinde *kapı granülerliği*ne aittir).

---

> **SONRAKİ:** Onur **kilitler** → Claude Code build eder → Cowork artefaktı **bağımsız doğrular** (builder'ın beyanına güvenmez, çıktıyı kendi söker). Ardından K42-d **adım 3**: senkron kuyruğu + `POST /v1/sync`.

# KABUL HÜKMÜ — `SS2` kriter 8 / başlık düzenleme UI (o68)

**Hükmü veren:** Cowork, **bağımsız koşumla** (`K26` — üreticinin beyanına güvenilmedi).
**Üreten:** Claude Code · commit **`2710db0`** (taban `5b0f259`).
**Tarih:** 10 Ağu 2026 (cihazdan ölçüldü).
**İş emri:** `GOREV_CLAUDE_CODE/IS-EMRI-o68-SS2-baslik-duzenleme-UI.md`.

## HÜKÜM: 🟢 **KABUL** — yedi ölçütün yedisi de Cowork'ün kendi koşumuyla geçti.

---

## 1. KOŞUM ORTAMI (beyanlı)

| | |
|---|---|
| Nerede | **Bulut konteyneri (Linux)** — `git archive HEAD src/client` ile alınan **commit'lenmiş** ağaç |
| Flutter | **3.44.6** · stable · **Dart 3.12.2** — `DURUM.md`'nin cihaz için beyan ettiği sürümlerin **aynısı** |
| Çalışma ağacı | `git diff -- src/client` **boş** ⇒ ölçülen ağaç = `2710db0` |

🔴 **BEYAN EDİLMİŞ SINIR:** `ORTAM.md`'nin *"kapı hükmü, koştuğu ortamın hükmüdür"* dersi
gereği — bu hüküm **Linux** koşumunun hükmüdür. Cowork `flutter`'ı **cihazda koşamaz**
(`flutter` Windows'ta `.bat`, Desktop Commander **beş oturumdur yok**) ⇒ **Windows koşumu
ÖLÇÜLEMEDİ**. SDK sürümleri özdeş olduğu için sapma riski düşüktür ama **sıfır değildir**.

---

## 2. ÖLÇÜTLER

| # | ölçüt | ölçüm | hüküm |
|---|---|---|---|
| **1** | `flutter analyze --fatal-infos` | `No issues found! (18.7s)` · **EXIT 0** | 🟢 |
| **2** | `flutter test` | **549/549 · All tests passed · EXIT 0** (taban 539 → **+10**) | 🟢 |
| **3** | `duzenle()` ürün yolundan çağrılıyor | `gorev_listesi_ekrani.dart:149` → `widget.depo.duzenle(...)`, `_yerelYaz` sarmalayıcısı **korunmuş** | 🟢 |
| **4** | **M7 ISIRIYOR** | mutant koşuldu (aşağıda) | 🟢 |
| **5** | **Yeni ikon etiketli** | mutant koşuldu (aşağıda) | 🟢 |
| **6** | `g14` yeniden hesaplandı, `M75`/`M77` hâlâ ısırıyor | mutant koşuldu (aşağıda) + yeni kaldıraç vakası eklendi | 🟢 |
| **7** | Satır **hâlâ `onTap` taşımıyor** | `gorev_satiri.dart`'ta `onTap` / `GestureDetector` / `InkWell` / `onLongPress` **yalnız `///` yorum satırlarında**; widget kökünde **yok** | 🟢 |

---

## 3. MUTANT BATARYASI — **BEŞİN BEŞİ DE ISIRDI**

Yöntem: ikili yedek → bayt düzeyinde yama → hedef test dosyaları koşuldu → yedekten geri
yazım → **sha256 özdeşliği ölçüldü**.

| mutant | ne yapıldı | sonuç | geri yükleme |
|---|---|---|---|
| **MU-1** | `CakismaRozeti`'nin `Semantics(label: …)` etiketi **silindi** (= **`M7`**) | **ISIRDI** (exit 1) | **ÖZDEŞ** |
| **MU-2** | Yeni `IconButton`'ın `tooltip: Metinler.baslikDuzenle` **silindi** | **ISIRDI** (exit 1) | **ÖZDEŞ** |
| **MU-3** | `_dikeyMi`'nin `sabitler` toplamından **yeni dokunma hedefi terimi silindi** | **ISIRDI** (exit 1) | **ÖZDEŞ** |
| **MU-4** | `baslikAsgari = 0` (= **`M75`**) | **ISIRDI** (exit 1) | **ÖZDEŞ** |
| **MU-5** | `TextPainter`'dan `textScaler` **düşürüldü** (= **`M77`**) | **ISIRDI** (exit 1) | **ÖZDEŞ** |

🟢 **ÖLÜ MUTANT YOK.** İş emrinin en büyük riski (§1.4: *"etiketsiz ikon eklenirse
`labeledTapTargetGuideline` zaten düşer ve `M7` ayırt edilemez ⇒ ÖLÜR"*) **gerçekleşmedi**:
MU-1 ve MU-2 **ayrı ayrı** ısırıyor, yani iki etiket **bağımsız olarak** ölçülüyor.

Geri yüklemeden sonra doğrulama koşumu: `a11y_kapisi` + `gorev_satiri_duzenleme` + `g14`
⇒ **30/30 · EXIT 0** ⇒ ağaç mutant kalıntısı taşımıyor.

---

## 4. ÜRETİCİNİN İYİ YAPTIĞI ÜÇ ŞEY (ölçüldü, beyan değil)

1. **Doğrulama kuralı PAYLAŞILDI, kopyalanmadı** — `lib/sunum/gorev_baslik_dogrulama.dart`
   (yeni, 17 satır); iş emri §3.3'ün `kanonik-kopya` uyarısı **karşılandı**.
2. **Ölçülmüş bir kusur kayda geçirilmiş:** dışarıdan saran
   `Semantics(label:, button:true, child: IconButton(...))` deseninin **işe yaramadığı**
   (IconButton kendi `container:true` düğümünü ürettiği için) kodda **yorum olarak
   ölçümüyle** yazılmış; çözüm `tooltip`.
3. **Yeni `g14` kaldıracı aritmetiğiyle gerekçelendirilmiş:** 370dp/1.0x seçimi —
   `onBaslikDuzenlendi` null iken `64+96+185,5 = 345,5 < 370` (yatay), doluyken
   `116+96+185,5 = 397,5 > 370` (dikey); aralığın **ortası**, iki uca ~25dp pay.

## 5. HACİM

`5b0f259..2710db0`, `src/` altında: **+564 / −15** satır.
Ürün (`lib/`): **+216** · Test: **+348**.

---

## 6. NE ÖLÇÜLEMEDİ (kapanmadı, gizlenmedi)

- **Windows koşumu** — Cowork `flutter`'ı cihazda koşamıyor (`.bat` + DC yok).
- **Android cihaz / emülatör koşumu** — `adb` Cowork'ten erişilemez ⇒ widget testi
  **uçtan uca değildir**; kullanıcının parmağıyla akış **denenmedi**.
- **`flutter test --platform chrome`** — bu ortamda sonuç üretmiyor (`ORTAM.md`) ⇒ web
  ayağı **`[DOĞRULANMADI]`**.
- **`SS2` kriter 8'in `title` alanı üzerinde uçtan uca yeniden koşumu** — iş emrinin
  **kapsamı dışındaydı**; bugün hâlâ tamamlanma anahtarıyla koşuyor. Artık **teknik olarak
  mümkün** (başlık mutasyonu ürün yolundan çağrılabiliyor), ama **koşulmadı**.

# IS-EMRI-o80 — uygulama özeti + tek ölçülmüş sapma

**El:** Claude Code.

## Ne yapıldı

`src/client/lib/sunum/gorev_satiri.dart` `_rozetler()`: `SenkronRozeti` artık
esneklik havuzundan (flex:1) **yalnız gerçekten bir şey çizerken** pay alıyor
(`SenkronRozeti.metinIcin(senkronDurumu) != null` — `_dikeyMi()`'nin zaten
kullandığı aynı yardımcı, ikinci bir eşleme tablosu yazılmadı).

## 🔴 ÖLÇÜLMÜŞ SAPMA — kilidin lafzından, kilidin AMACINDAN değil

İş emrinin kilidi şöyle diyordu: *"Rozet çizmiyorsa `_rozetler()` listesine
HİÇ girmesin."* Bu HARFİYEN uygulandığında (`if (metinIcin != null) Flexible(
...)`, rozet `senkronize` iken **listeden tamamen çıkarılır**) `flutter test`
**ölçülebilir bir regresyon** verdi:

- `a11y_kapisi_test.dart` — A11Y-7 duyuru testi **düştü**: `SenkronRozeti`
  bir `StatefulWidget`dır ve `senkronize`/`cevrimdisi`/`gonderilmemis`e
  **geçişte** bir kerelik semantics duyurusu yollar (`didUpdateWidget`,
  `senkron_rozeti.dart:87-92`). Widget'ı listeden tamamen çıkarmak, tam da
  geçiş anında (`kuyrukta`→`senkronize`) State'i **dispose eder** — "Senkronize
  edildi" duyurusu hiç yollanmadı (ölçüldü: `Actual` dizisinde eksikti).
- `g13_rozet_tasma_kapisi_test.dart` — aynı kök nedenden ikinci bir düşüş.

**Düzeltme (kilidin AMACINI — boş rozetin genişlik yutmaması — birebir
koruyarak):** widget **aynı konumda** kalır (State korunur, duyuru
mekanizması bozulmaz), yalnız `Flexible` sarmalayıcısı koşulludur:

```dart
final rozetCiziyor = SenkronRozeti.metinIcin(senkronDurumu) != null;
...
rozetCiziyor
    ? Flexible(child: SenkronRozeti(durum: senkronDurumu))
    : SenkronRozeti(durum: senkronDurumu),
```

Boşken `SenkronRozeti.build()` zaten `SizedBox.shrink()` (0,0 intrinsik
boyut) döndürüyor — `Flexible` OLMADAN Row'da flex payı talep etmiyor,
`Expanded(_baslikVeMeta)` tek flex katılımcı olarak kalan alanın **tamamını**
alıyor (kilidin aradığı sonuç birebir aynı). Aynı yardımcı (`metinIcin`)
kullanılmaya devam ediyor — ikinci eşleme tablosu yok, M77b riski doğmadı.

**Bu satır dışında** hiçbir bayta dokunulmadı; `_dikeyMi()`, rozet metinleri,
dokunma hedefleri, cakışma/düzenle/sil mantığı **DEĞİŞMEDİ** (§ "Sınır").

## Kabul ölçütleri (5/5)

1. ✅ `senkronize` satırda başlık çöp ikonuna kadar tüm genişliği kullanır —
   ölçüldü: 360dp'de başlık genişliği >250dp (yeni test, aşağıda).
2. ✅ Dolu durumlarda davranış birebir eskisi — ölçüldü: `Flexible` hâlâ
   `SenkronRozeti`'yi sarıyor (yeni test).
3. ✅ `_dikeyMi()` değişmedi — dokunulmadı, ayrıca 320dp/senkronize'de hâlâ
   YATAY olduğu ölçüldü (yeni test).
4. ✅ `_rozetler()` tek gövde kalmaya devam ediyor (yatay+dikey aynı listeyi
   kullanıyor).
5. ✅ Yeni şema/tel kanalı/kapı dosyası yok.

## Test ve mutant

Yeni dosya: `src/client/test/gorev_satiri_rozet_genislik_test.dart` (3 test).
Mutant koşucu: `KANIT/o80/_mutant_kosucu_o80.py` (referans:
`KANIT/A11/_mutant_kosucu.py`, `git restore` YASAK, bayt-düzeyi yama + sha256
özdeşlik).

| mutant | tanım | sonuç |
|---|---|---|
| M-o80-1 | koşul kaldırılır (rozet HER durumda `Flexible` ile eklenir) | KIRMIZI (beklenen) |
| M-o80-2 | koşul ters çevrilir (dallar takas edilir) | KIRMIZI (beklenen) |
| M-o80-3 | koşul `senkronize` yerine `yerel`e bağlanır | KIRMIZI (beklenen) |

**3/3 ısırdı.** Geri alma sonrası `gorev_satiri.dart` sha256 **özdeş**
(`46FA5C9B`, öncesi=sonrası). Ham çıktı: `KANIT/o80/03-MUTANT-*.txt`.

## Nihai ölçüm

`flutter analyze --fatal-infos` → **0 sorun**.
`flutter test` → **708/708**, EXIT 0.

## Ne ölçülemedi

- `a11y_statik_tasma_test.dart`'ın R4 Text( aday sayısı pini — bu turda
  DOKUNULMADI (kapsam dışı, `_rozetler()` hiç `Text(` çağrısı eklemedi/
  silmedi) — mevcut hâliyle test suite'in tamamı yeşil olduğu için bu turda
  bir çatışma **çıkmadı**; ayrı bir bulgu değildir.
- Gerçek cihazda (`2510ERA8BG`) görsel doğrulama — bu ölçüm masaüstü
  `flutter test` widget testleridir, cihazda ekran görüntüsü **alınmadı**.

# K65 — G6 AYAK6'da bulunan kusur, kök neden, kilitli düzeltme, yeniden ölçüm

## 1. Bulgu

T7 sırasında G6 AYAK6 ("cihaz saati +6 dk ileri alınır, iki ardışık başlık düzenlemesi
TEK turda gider → sunucudaki `title` SON değere eşit olmalı") ilk kez gerçek backend +
gerçek Postgres'e karşı koşulduğunda **aralıklı olarak** (yaklaşık %40-50) yanlış sonuç
verdi: sunucudaki `tasks.title` bazen **İLK** düzenlemede kaldı, SON değil.

Sekiz art arda koşumda gözlenen ham sonuçlar (`docker exec ... psql`, `tasks.title`):

```
RUN(seri-1, 1-7): SON, SON, SON, SON, SON, SON, SON
RUN1: İLK   RUN2: SON   RUN3: SON   RUN4: İLK   RUN5: İLK
RUN1(2.tur): SON  RUN2(2.tur): İLK  RUN3(2.tur): SON
```

İstemci tarafı her koşumda doğruydu: her iki op da `Applied` döndü, kuyruk boşaldı —
**hiçbir kapı kırmızı yanmadı**. Sorun tamamen sunucu tarafındaydı.

## 2. Kök neden (Onur, K65)

Spec'in kendi §1'i (satır 200-203) bu sınıf çarpışmayı ZATEN öngörmüştü:

> "...Sunucu ikisini de `receiveWall + 5dk`'ya kırpar ⇒ iki alan-HLC'si birebir aynı olur
> ⇒ `LwwRegister` tie-break'i `opId` dize-ordinal karşılaştırmasıdır ve `opId` **rastgele
> UUID v4**'tür ⇒ **%50 olasılıkla kullanıcının SON yazdığı değer kaybolur**... Tavan bu
> çakışmayı kaynağında keser."

Bu son cümle **yanlış** çıktı: istemci tavanı (D3) bu çarpışmayı kaynağında **kesmiyordu**,
çünkü:

1. Backend'in `HlcKey` karşılaştırması tie-break'in **zaman-sıralı** (UUIDv7) bir
   `OperationId` varsaydığını belgeliyor — ama D1/D7 `opId`'yi **UUID v4** (tamamen
   rastgele) olarak pinlemişti. İki alan-HLC'si sunucuda aynı `receiveWall+5dk` değerine
   kırpıldığında, tie-break rastgele bir dize karşılaştırmasına düşüyor — bir yazı-tura.
2. `HlcUretici.sonrakiHlc()`'nin eski `counter` mantığı (`wall == sonWall ? sonCounter+1
   : 0`) yalnız **wall DEĞİŞMEDİĞİNDE** counter'ı artırıyordu; wall değiştiğinde (iki
   ardışık `duzenle()` çağrısı arasında gerçek saat bir miktar ilerlediğinde) counter
   sıfırlanıyordu — bu da istemci tarafında bile ayırt edici bir counter farkı garanti
   etmiyordu.

## 3. Kilitli düzeltme (Onur, K65 — PAZARLIKSIZ, iki madde)

1. **`uretimIdUret()` (opId üreteci): UUID v4 → UUID v7** (RFC 9562, zaman-sıralı ön ek).
   Dosya: [`src/client/lib/veri/gorev_deposu.dart`](../../../src/client/lib/veri/gorev_deposu.dart)
2. **`HlcUretici.sonrakiHlc()`: `counter` HER damgada kesin artar**, wall eşitliğine
   bakılmaksızın (`final counter = sonCounter + 1;`). Dosya:
   [`src/client/lib/veri/hlc.dart`](../../../src/client/lib/veri/hlc.dart)

Etkilenen mevcut test: `test/g4_hlc_kapisi_test.dart`'ın iki testi eski ("counter wall
değişince 0'a döner") semantiğini varsayıyordu; yeni kilitli semantiğe göre yeniden
yazıldı (bkz. `04-G4-hlc/00-test-ciktisi.txt`, güncel koşum GREEN).

## 4. Yeniden ölçüm — 10/10 (kilit koşulu)

Düzeltme sonrası AYAK6, art arda **10 kez** koşuldu (`docker exec ... psql` ile her
seferinde `tasks.title` doğrudan okunarak):

```
RUN 1  entity=019fa541-565f-702b-... title=G6 Gorev E (SON duzenleme)
RUN 2  entity=019fa541-7e12-7209-... title=G6 Gorev E (SON duzenleme)
RUN 3  entity=019fa541-a58b-7725-... title=G6 Gorev E (SON duzenleme)
RUN 4  entity=019fa541-cae6-7a47-... title=G6 Gorev E (SON duzenleme)
RUN 5  entity=019fa541-eb91-72ab-... title=G6 Gorev E (SON duzenleme)
RUN 6  entity=019fa542-10d8-745c-... title=G6 Gorev E (SON duzenleme)
RUN 7  entity=019fa542-3368-709d-... title=G6 Gorev E (SON duzenleme)
RUN 8  entity=019fa542-5a1c-7e77-... title=G6 Gorev E (SON duzenleme)
RUN 9  entity=019fa542-7b81-7388-... title=G6 Gorev E (SON duzenleme)
RUN 10 entity=019fa542-a39e-704c-... title=G6 Gorev E (SON duzenleme)
```

**10/10 SON.** Kilit koşulu (Onur) karşılandı. Entity ID'lerin kendisi de artık UUIDv7
biçiminde (zaman-sıralı `019fa5..` ön eki, her koşumda bir öncekinden dize-ordinal
BÜYÜK) — üreteç değişikliğinin gerçekten devrede olduğunun ayrıca kanıtı.

## 5. Regresyon (düzeltme sonrası)

- `flutter analyze --fatal-infos` ⇒ **0 bulgu**.
- `flutter test` (tam, 79 test) ⇒ **All tests passed**.
- Mutant yeniden-doğrulama (bu düzeltmenin dokunduğu `hlc.dart` satırlarına en yakın
  ikisi): `M21` ("counter'ı daima 0 bırak") ve `M23` ("tavanı kaldır") YENİ kodda da
  KIRMIZI yaktı, geri alındı, YEŞİL doğrulandı (bkz. `09-MUTANT/`).
- `M13`/`M15`/`M34` bu değişiklikten etkilenmez (farklı dosya/satırlara bağlı; ID
  BİÇİMİNE değil).

## 6. Kapsam notu

Bu düzeltme **yalnız** K65'in iki maddesiyle sınırlı tutuldu — spec'in D0-D9/G1-G8'i
pazarlığa kapalı kaldı. Backend'e (`Momentum.Domain.Sync.HlcKey` vb.) **dokunulmadı**;
düzeltme tamamen istemci tarafında, `opId` biçimi ve `counter` semantiği üzerinden
yapıldı (§9 kural 6 ihlal edilmedi).

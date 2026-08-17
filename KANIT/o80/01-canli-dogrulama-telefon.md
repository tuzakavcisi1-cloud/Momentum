# KANIT — o80 · düzeltmenin CANLI doğrulaması (gerçek telefon)

**17 Ağu 2026 12:47 TSİ · `2510ERA8BG` · Android 16 · dikey · release APK (o80 kodu)**
Ölçümü Cowork yaptı (adb ekran görüntüsü), builder beyanına dayanmadı.

Kusur gerçek cihazda bulunmuştu (`KANIT/o79/04`); düzeltme **aynı yüzeyde** ölçüldü.
`flutter test` yeşili tek başına kabul sayılmadı — o79'un dersi buydu.

## Karşılaştırma (aynı cihaz, aynı konum, iki kare 924 px genişlikte gösterildi)

| ölçüm | ÖNCE (`o79/telefon-dikey.png`) | SONRA (`o80/telefon-dikey-3.png`) |
|---|---|---|
| başlığın çizilen genişliği | ~225 px | **~450 px** |
| çöp ikonu konumu | 600 | **828** |
| içeriğin bittiği yer | ~630 (%68) | **~860 (%93)** |
| sağdaki boş şerit | ~%32 | **kapandı** |

Başlık **iki katına** çıktı — kök neden analizinin öngörüsü birebir: boş rozet, esneklik
havuzundan payının yarısını alıyordu; `Flexible` koşullu olunca `Expanded` tek katılımcı kaldı.

- Satır 2 (*"yeni görev denemesi"*) **hiç kırpılmadan** sığıyor.
- Satır 1 (*"yarin 17:00 paket denemesi"*) hâlâ üç nokta gösteriyor ama **meşru**: metin gerçekten
  sığmıyor, boşa giden yer yok. (Kabul ölçütü 1.)
- **İki satırın da rozeti YOK** ⇒ ikisi de `senkronize` ⇒ düzeltmenin hedeflediği durum tam olarak
  bu karede ölçüldü. (Önceki iki deneme `yerel` ve `cevrimdisi` durumundaydı, ölçüm SAYILMADI.)

## Yan ürün: çift yönlü senkron iki gerçek istemcide

- Masaüstü tarayıcıda yazılan *"yarin 17:00 paket denemesi"* **sunucudan telefona indi**.
- Telefonda eklenen *"yeni görev denemesi"* **sunucuya çıktı**.
- Sabit `DEV_USER_ID` sayesinde iki istemci aynı kullanıcı; iddia artık ölçülü.

## Ölçüm sırasında çıkan yan bulgular

1. `flutter install` **eski sürümü kaldırıyor** ⇒ yerel veritabanı siliniyor. Telefon boş açıldı,
   veriler ancak çekmeyle geri geldi. Beklenen davranış, ama ölçüm sırası kurarken hesaba katılmalı.
2. İlk iki ekran görüntüsü **geçersizdi**: rozet `yerel` ("Bu cihazda") ve `cevrimdisi`
   ("Çevrimdışı") durumundaydı; kusur yalnız rozet BOŞken görünür. Docker Desktop kapalıydı.
   **Ders:** düzeltmeyi ölçmek, doğru DURUMU kurmayı gerektirir; ekranı görmek yetmez.

## NE ÖLÇÜLEMEDİ

1. **Yatay (landscape) konum** — hiç denenmedi.
2. **Diğer cihazlar / ekran genişlikleri / metin ölçekleri** — yalnız bu cihaz, 1.0x.
3. **A11Y-7 duyurusunun CİHAZDA fiilen yollandığı** — regresyon `flutter test` ile yakalandı ve
   orada düzeltildi; gerçek ekran okuyucuyla (TalkBack) doğrulanmadı.
4. **İmajdaki web istemcisi hâlâ o79 kodu** — imaj `--build` ile tazelenmedi; tarayıcı yüzeyinde
   düzeltme ölçülmedi. Push sonrası `paket` kapısı yeni kodla koşar.
5. **`flutter analyze` / `flutter test 708/708` beyanı** — builder'ın çıktısı; bu turda bağımsız
   koşulmadı, CI'ın doğrulaması bekleniyor.

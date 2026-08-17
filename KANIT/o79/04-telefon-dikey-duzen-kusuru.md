# KANIT — o79 · gerçek telefonda düzen kusuru (teslim kapısının bulduğu)

**17 Ağu 2026 ~00:40 TSİ · `2510ERA8BG` · Android 16 (API 36) · dikey · release APK**
Kusuru **Onur gördü**, kök nedeni Cowork ekran görüntüsü + kaynak okumasıyla ölçtü.

## Belirti

Ekran görüntüsü: `arsiv/_SILINECEKLER/o79/telefon-dikey.png` (1280×2772).

- Görev başlığı **`yarin 17:00 …`** — üç noktayla kırpık.
- Kalem ve çöp ikonları ekranın **ortasında**; sağda **~%30 boş** alan.
- Ayırıcı çizgi **tam genişlikte** ⇒ satır geniş, içindeki yerleşim dar.
- Aynı desen masaüstü tarayıcıda da vardı (içerik ~%62'de bitiyordu) ama geniş ekranda göze
  batmıyordu.

## Kök neden

`src/client/lib/sunum/gorev_satiri.dart` · `_rozetler()` →
`Flexible(child: SenkronRozeti(durum: senkronDurumu))`

`Flexible`, `Expanded(child: _baslikVeMeta(...))` ile aynı esneklik havuzundadır (ikisi de
`flex: 1`) ⇒ **boş genişlik ikiye bölünür**. `senkronize` durumunda rozet hiçbir şey çizmez
(`metinIcin(senkronize) == null`, `SizedBox.shrink`) **ama slotunu alır** ⇒ başlığa boşluğun
yarısı verilir, kalan yarısı boş çizilir.

## Neden bugüne kadar görünmedi — teslim kapısının değeri

Rozet ancak **backend çalışırken** `senkronize`ye ulaşır. Pages demosunda backend yoktur, rozet
hep doluydu ("Gönderiliyor"/"Çevrimdışı") ve `Flexible` gerçek bir çocuk taşıyordu. Satırların
`senkronize` olduğu **ilk yapılandırma o79 teslim paketidir**.
⇒ **Kusuru ortaya çıkaran şey, paketin kendisidir.** "Önce uygulamaya bakılacak" ölçütü
(ODEV §2) bu yüzden kâğıt denetimiyle değil, çalışan paketle karşılanır.

## Neden mevcut kapılar yakalamadı

`a11y_statik_tasma_test.dart` **taşma** arar (sarı-siyah şerit). Burada taşma yoktur; `ellipsis`
tanım gereği "doğru" davranıştır. Hiçbir kapı *"yer varken kırpılıyor mu"* diye sormuyordu.
Bu, kapı ailesinde **adlandırılmış bir boşluktur** ve o80 iş emri onu kapatır.

## Karar

**KİLİT [Onur, 17 Ağu 2026]:** rozet çizmiyorsa `_rozetler()` listesine hiç girmesin
(`SenkronRozeti.metinIcin(durum) == null` ⇒ ekleme). Ayrıntı ve kabul ölçütleri: o80 iş emri.
Kodu **Claude Code** yazar (CLAUDE.md §1 iş bölümü).

## NE ÖLÇÜLEMEDİ

1. **Yatay (landscape) konum** — telefonda denenmedi.
2. **Diğer ekran genişlikleri / metin ölçekleri** — yalnız bu cihazın dikey konumu görüldü.
3. **Düzeltmenin kendisi** — henüz yazılmadı; yukarıdaki kök neden okumayla saptandı, çalıştırılıp
   ölçülmedi (Flutter bu bulut ortamında yok).
4. **Ters yön senkron** (telefondan ekle → masaüstünde gör) — denenmedi.

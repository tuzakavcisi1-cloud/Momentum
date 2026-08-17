# İŞ EMRİ — o80 · boş senkron rozeti satırın yarısını yutuyor

**Yazan:** Cowork (tasarım + ölçüm) · **Yazacak:** Claude Code · **Kilit:** Onur, 17 Ağu 2026
**Kaynak ölçüm:** `KANIT/o79/04-telefon-dikey-duzen-kusuru.md`

## Kusur

Gerçek Android cihazda (`2510ERA8BG`, Android 16, dikey) görev başlığı **yer varken kırpılıyor**:
`yarin 17:00 …` üç noktaya düşüyor, kalem/çöp ikonları ekranın ortasında duruyor ve sağda
ekranın **~%30'u boş** kalıyor. Ayırıcı çizgi tam genişlikte ⇒ satır geniş, **yerleşim dar**.

## Kök neden (ölçüldü, okundu)

`src/client/lib/sunum/gorev_satiri.dart` · `_rozetler()`:

```dart
Flexible(child: SenkronRozeti(durum: senkronDurumu)),
```

`Flexible`, `Expanded(child: _baslikVeMeta(...))` ile **AYNI esneklik havuzundadır** (ikisi de
`flex: 1`). Satırdaki boş genişlik ikiye bölünür. Rozet `senkronize` durumundayken hiçbir şey
çizmez — `SenkronRozeti.metinIcin(senkronize) == null`, gövde `SizedBox.shrink` — **ama slotunu
yine de alır** (`FlexFit.loose`: çocuk küçük olabilir, ayrılan alan yine ayrılmıştır).
⇒ Başlığa boşluğun yarısı verilir, diğer yarısı boş çizilir.

**Neden bugüne kadar görünmedi:** rozet ancak backend çalışırken `senkronize`ye ulaşır. Pages
demosunda backend yok, rozet hep doluydu ("Gönderiliyor"/"Çevrimdışı") ve `Flexible` gerçek bir
çocuk taşıyordu. Satırların `senkronize` olduğu **ilk yapılandırma o79 teslim paketidir** — kusuru
ortaya çıkaran şey paketin kendisi.

**Neden mevcut kapılar yakalamadı:** `a11y_statik_tasma_test.dart` **taşma** arar (sarı-siyah
şerit). Burada taşma yok; `ellipsis` "doğru" davranıştır. Kimse *"yer varken kırpılıyor mu"* diye
sormuyordu.

## KİLİT [Onur, 17 Ağu 2026]

**Rozet çizmiyorsa `_rozetler()` listesine HİÇ girmesin.**
Koşul zaten var ve `_dikeyMi()` onu kullanıyor: `SenkronRozeti.metinIcin(durum) == null`.
**İkinci bir eşleme tablosu YAZILMAZ** (M77b sınıfı: ölçülen dizge ile çizilen dizge sessizce
ayrışır) — mevcut yardımcı doğrudan çağrılır.

*Reddedilen:* `Flexible`ı tümden kaldırmak — rozet metni uzunken küçülemez, dar ekranda taşma
riski doğar ve `_dikeyMi` formülü bu varsayım üzerine kuruludur.

## Kabul ölçütleri

1. `senkronize` durumundaki satırda başlık, **çöp ikonuna kadar** olan tüm genişliği kullanır;
   kırpma ancak metin gerçekten sığmadığında olur.
2. Rozet **dolu** olan durumlarda (`yerel`, `kuyrukta`, `cevrimdisi`, `gonderilmemis`) davranış
   **BİREBİR eskisi** kalır — küçülebilirlik korunur.
3. `_dikeyMi()` kararı değişmez (zaten `metinIcin == null` iken `false` dönüyor).
4. `_rozetler()` **TEK GÖVDE** kalır; yatay ve dikey düzen aynı listeyi kullanmaya devam eder.
5. YENİ ŞEMA YOK, YENİ TEL KANALI YOK, yeni kapı DOSYASI açılmaz (bütçe ihlalde).

## Test ve mutant (pazarlıksız)

- **Yeni widget testi:** dar bir genişlikte (ör. 360 dp) `senkronize` bir satır çizilir ve
  başlık `RenderParagraph`ının **çizilen genişliği** ölçülür; boş rozetin yarım boşluk yuttuğu
  eski davranışta bu ölçüm DÜŞMELİ.
  🔴 `find.text(...)` **YETMEZ** — metin bulunur ama kırpılmış olur. Ölçüm **genişlik** üzerinden
  yapılır.
- **En az üç mutant, üçü de ölmeli:**
  1. koşul kaldırılır (rozet her durumda eklenir) → eski kusur geri gelir
  2. koşul ters çevrilir (yalnız boşken eklenir)
  3. koşul `senkronize` yerine başka bir duruma bağlanır
- Mevcut `a11y_statik_tasma_test.dart` tabanı **kaymamalı**; kayarsa sebebi yazılır.

## Sınır

Bu dilim **yalnız yerleşimdir**. Rozet metinleri, senkron durumları, `_dikeyMi` formülü ve
dokunma hedefleri **DEĞİŞMEZ**.

# DURUM.md — Momentum

**BİTTİ: 9/10 · kutu 21 Ağu 2026 · arama dilimi KOD BİTTİ, CANLI TUR BEKLİYOR (10/10 ölçütü §Sıradaki iş). `ci #49` YEŞİL (676/676) · `pages #7` YEŞİL · doğal dil dilimi CANLI DOĞRULANDI (cihaz Chrome, 15 Ağu 13:44 TSİ).**

> Açılış ≤3 komut: ① `git --no-optional-locks log --oneline -1` + `status --porcelain -- src`
> ② bu dosya ③ CI durumu — **cihazdaki Chrome'dan okunur** (bulut tarayıcısı kanıt değildir).
> `arsiv/` AÇILMAZ. **Flutter komutları `src/client`'tan koşulur** (bilinen sınır 1).

## Oturum 74 · 76 · 77 (özet)

**TAKVİM GÜNÜ PİNİ:** `DateTime.utc(y,m,d)`, tek nokta `GorevSatiri.takvimGunu`. `intl` **0.20.2**
(kanonik sürüm `pubspec.lock`). **Etiket:** `gorev_etiketleri(...)` SALT-EKLEME, `Gorevler`e
dokunulmadı. Tel `sets.tags.{adds,removes}`; `sets` LWW meta'ya ASLA bağlanmaz. adds=insertOrIgnore ·
removes=observed başına iptal ⇒ idempotent + değişmeli. Tombstone TELE ÇIKMAZ.
**Doğal dil (o77):** `yarın 17:00 rapor gönder #iş !p1` → dört alan TEK `WireOp` + TEK `transaction`;
ayrıştırıcı SAF (`DateTime.now()` yok). 41 mutant öldü. Denetim İKİ ürün kusuru çıkardı: `int.parse`
64 bit taşması (VM/Android'de ekle düğmesi sessizce ölüyordu) → `int.tryParse`; yıl `0000` kabulü
(sunucu `Malformed`'a atar ⇒ **sınır ötesi sessiz kayıp**) → `yil < 1` reddi.
**DERS (o74, kanla):** kâğıt denetimi migration'ın **v1 yolunu KOŞAMAZ**. **DERS (o77):** `.toUtc()`
mutantı UTC koşan CI'da davranışla öldürülemez — ortamı değil **DİKİŞİ** ölç.

## Oturum 78 — başlıkta arama dilimi (KOD BİTTİ, canlı bekliyor)

Bulutta yazıldı/koşuldu (Flutter 3.44.6): `analyze --fatal-infos` temiz · **705/705** (taban 676) ·
**32 mutant öldü** (18 ilk tur + 11 denetim sağkalanı + 3 kilit turu), bilinen tek sağkalan `dispose`.
**YENİ ŞEMA YOK, YENİ TEL KANALI YOK.** Değişen altı dosya: `lib/sunum/arama_eslestirme.dart` (YENİ) ·
`test/arama_dilimi_test.dart` (YENİ) · `gorev_listesi_ekrani.dart` · `bos_durum.dart` ·
`design/metinler.dart` · `test/a11y_statik_tasma_test.dart` (R4 tabanı 29→30).

- **`arama_eslestirme.dart` SAF, sıfır bağımlılık.** Katlama tablosu (`I→ı`, `İ→i`) TEK KAYNAK;
  ham `toLowerCase` YASAK; **aksan KATLANMAZ**; alt dize; boş/boşluk sorgu = süzme yok (kırpılır).
- **Süzme TEK `where`da:** etiket çipi ile arama ÇARPILIR; ikinci süzme yolu açılmadı.
- **`BosDurum.eslesmeYok`:** ayrı metin + "Süzgeçleri temizle"; birinci varyantın ağacı BİREBİR
  eskisi (A8 taşma ölçümü ve vitrin testleri kaymasın diye).
- **İKİ BAĞIMSIZ DENETÇİ** koştu; ikisi de ürün kusuru buldu, hepsi kapatıldı (aşağıdaki sınırlar).

## Sıradaki iş — CANLI TUR (cihaz Chrome, Pages demosu)

Kod cihaza yazıldı; **commit/push ONUR'DA**, sonra canlı tur. **Bitti ölçütü:** arama yazılır liste
daralır · alan temizlenince geri gelir · etiket çipiyle ikisi birden uygulanır · süzgeç açıkken
eklenen görev GÖRÜNÜR. Üçü de yeşilse **10/10**. Canlı turda **Ctrl+Shift+R YAPMA** (sınır 22).

## Bilinen sınırlar

1. 🔴 **Flutter komutu repo kökünden koşulursa yalan söyler.** Doğru dizin `src/client`.
   PowerShell 5.1'de `&&` yok, `;` yaz.
2. **Canlı ölçümde tıklama tuzağı:** hover'sız sentetik tıklama çalışmaz; hover'lı tıklama bile bazen
   İKİ kez gerekir; diyalogdaki `İptal` tetiklenmez, modalı **Escape** kapatır.
3. **Kapı bütçesi ihlalde**; teslimi kırmamak bütçeyi kapatmaktan önce gelir ⇒ yeni kapı DOSYASI
   açılmaz (widget/birim testleri orana girmez, onlar üründür).
4. **Kimlik `devUserId` ile taşınıyor** ⇒ gerçek zamanlı işbirliği gösterilemez (kapsam dışı).
6. **Pages demosunda backend yok** ⇒ rozetler "Bu cihazda → Gönderiliyor → Çevrimdışı"ya düşer;
   "ikinci istemciye eşitlenir" ayağı Pages'te ASLA ölçülemez.
7. **Mount'a yazmanın tek yolu YERİNDE yazmaktır.** `device_commit_files` mount'a YAZAR, sha256
   birebir tutar — AMA `.github/workflows/*` **korumalıdır, reddedilir**; iş akışını Onur elle düzenler.
8. **`pub cache` boşalabiliyor** (`flutter pub get` çözer).
9. **Öncelik/son tarih/etiket için ÇAKIŞMA TESPİTİ kapsam dışı:** `kanonikDize` yalnız
   `fields:title` + `groups:completion` tanır. **Bilinmeyen `priority`** çizilmez ama EZİLMEZ.
14. **Etiketlerde BÜYÜK/KÜÇÜK HARF KATLAMASI YOK** (sunucu Ordinal karşılaştırır): `İş` ≠ `iş`.
    32 karakter sınırı YALNIZ İSTEMCİ kelepçesidir.
16. **[o77] Doğal dil sınırları (kilitli):** `Yarın`/ASCII `yarin` TANINMAZ · saat başlıkta kalır ·
    yılsız `03.01` GEÇMİŞE düşer · `#İş` ile `#iş` ayrı etikettir.
18. **[o77] `GorevDeposu.ekle` imzası** üç opsiyonel alan taşır ⇒ yeni sahte depo üçünü de kabul
    ETMEK ZORUNDADIR.
19. **[o77 ÖLÇÜLDÜ] `flutter test` `KANIT/slice-3c/02-G2/*.json`i her koşumda YENİDEN YAZAR.**
    Bu dört dosya commit'e GİRMEMELİ — `git add` yol belirterek yapılır.
21. **[o77] CI `istemci` işi `TZ: Europe/Istanbul` koşar.** `ekle`nin `sonTarih`i normalize EDİLMEZ.
22. 🔴 **[o77 ÖLÇÜLDÜ] Canlı turda Ctrl+Shift+R YAPMA.** Hard reload drift'in SharedWorker'ını
    öldürür, yeniden kurulamaz: ekran **bomboş** kalır ve **konsolda hata olmaz**. Çözüm: Chrome'u
    tamamen kapat–aç. Ek tuzak: CanvasKit canvas'ı `flt-glass-pane`in SHADOW ROOT'undadır ⇒
    `querySelectorAll('canvas')` onu GÖREMEZ.
23. **[o78 ÖLÇÜLDÜ] `'İ'.toLowerCase()` VM'de `[105]`, dart2js/Node'da `[105, 775]`** (i + U+0307)
    ⇒ katlama tablosundan `İ` girişini silen mutant **VM'de davranışla ÖLMEZ** ama WEB'de `iş`
    sorgusunu `İş görüşmesi`nden koparırdı. Test bu yüzden TABLOYU BİREBİR sınar (o77 dersinin aynısı).
24. **[o78 ÖLÇÜLDÜ] Katlama VM↔web ayrışması:** 1.112.064 kod noktası tarandı; `U+0000–U+024F`
    (Latin/Türkçe) aralığında ayrışan **SIFIR**, aralık dışında 465 kod noktası (Cherokee, Gürcüce
    Mtavruli, Adlam, Deseret…) FARKLI katlanır. Ürün dili Türkçe ⇒ bilinçli sınır.
25. **[o78 ÖLÇÜLDÜ] `hintText` hiçbir mevcut kapıya görünmez:** bir `Text(` olmadığı için R1/R2/R4
    statik tarayıcısı görmez; alanın semantik düğümünde label/value BOŞ olduğu için
    `textContrastGuideline` o düğümü **ATLAR**. İpucu metni + ipucu rengi + odak halkasının TEK pini
    `test/arama_dilimi_test.dart`tedir. Arama ipucu bu yüzden **'Ara'**ya kısaltıldı (320 dp'de
    'Görevlerde ara' 1.0x'te bile kırpılıyordu: çizilen 220 px / gereken 231 px).
26. **[o78 ÖLÇÜLDÜ] `dispose()` mutantı SAĞ KALIYOR** (flutter_test leak-tracking kapalı) — kapsanmayan
    sınıf, kapı yalanı değil. Yeni kapı kodu YAZILMADI (bütçe ihlalde).
27. 🔴 **[o78 İKİNCİ KEZ ISIRDI] `dart format lib/` YASAK** — depo format-temiz DEĞİL; 10 ilgisiz
    dosyayı yeniden biçimlendirdi ve `analyze` 4 yeni uyarı verdi. Yalnız DOKUNULAN dosyada koş.
28. **[o78 KİLİT — Onur, 16 Ağu] Ekleme süzgeçleri SIFIRLAR.** Süzgeç (arama ya da çip) açıkken
    eklenen görev listeye giriyor ama EKRANDA GÖRÜNMÜYORDU ve hiçbir geri bildirim yoktu (ölçüldü:
    depoda 2 görev / ekranda 1 satır / bildirim 0). Sıfırlama SENKRON ve yalnız `onEkle` ateşlenince
    (geçersiz girdi süzgeci düşürmez). Bu, çipin o76'dan gelen kusurunu da kapattı.

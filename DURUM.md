# DURUM.md — Momentum

**BİTTİ: 7/10 · kutu 21 Ağu 2026 · `ci #43` YEŞİL (589/589) · `pages #5` YEŞİL · canlı doğrulandı · son ölçüm 14 Ağu 2026, oturum 74**

> Açılış ≤3 komut: ① `git --no-optional-locks log --oneline -1` + `status --porcelain -- src`
> ② bu dosya ③ CI durumu — **Cowork bunu claude-in-chrome ile cihazdaki Chrome'dan okur**
> (kanonik ölçüm yeri cihazdır; bulut tarayıcısı değil). `arsiv/` AÇILMAZ.
> **Flutter komutları `src/client`'tan koşulur** (bilinen sınır 1).

## Ne yapıldı (oturum 74 · 14 Ağu 2026)

**Öncelik + son tarih dilimi KAPANDI — sayaç 6/10 → 7/10.** `analyze
--fatal-infos` *No issues found* · `flutter test` **589/589** · `ci #42` yeşil ·
`pages #4` yayınlandı · canlı tur koşuldu (aşağıda).

Kilitlenen tasarım (Onur): ① öncelik ÜÇ seviye + yok (`1=Yüksek, 2=Orta,
3=Düşük`) · ② son tarih YALNIZ GÜN · ③ kalem ikonu birleşik diyaloğa genişler,
**satıra YENİ İKON EKLENMEZ**, değerler başlık altındaki meta satırında görünür.

- **Şema v5→v6:** `Gorevler`e `oncelik` (`int?`) + `sonTarih` (`DateTime?`).
- **Depo:** `Oncelik` enum + saf dönüşümler; `Yazim<T>` ("değişmedi" ≠ "temizlendi");
  `ayrintilariGuncelle()` = TEK `WireOp` + TEK `transaction()`, **yalnız değişen
  alan tele konar** (değişmemişi yeniden damgalamak uzak yazımı LWW ile ezerdi).
- **Tel biçimi backend kaynağından ÖLÇÜLDÜ:** `priority` ondalık tamsayı dizesi,
  `dueAt` = `DateTime.utc(y,m,d)` ISO-8601.
- **TAKVİM GÜNÜ PİNİ:** tek normalizasyon noktası `GorevSatiri.takvimGunu()`;
  `isUtc`/`hour` iddialarıyla env-bağımsız ölçülüyor (CI UTC koşar, statik
  `.toLocal()` taraması tek başına yetmez).
- **Uzak yol:** `fields:priority`/`fields:dueAt` bağlandı; "geldi mi" bayrağı
  sayesinde uzaktan TEMİZLEME (`value:null`) düşmüyor.
- **R4 tabanı 20 → 25**, **`Gorev` alan pini 7 → 9** — ikisi de bilerek, ölçülerek.

### İki tur denetim — ikisi de bulgu üretti

**Tur 1 (2 bağımsız denetçi, kâğıt üstünde):** BLOKER yok; ikisi de **bağımsız
olarak aynı çökmeyi** buldu — `showDatePicker` `initialDate` aralık dışında
kalabiliyordu (uzak istemci herhangi bir tarih yazabilir) ⇒ tarih düğmesi ölüydü.
**Kelepçe eklendi.** Ayrıca: takvim pininin yazma ayağı korumasızdı, ekran
kablosu ölçülmüyordu, "meta yoksa çizilmez" boş iddiaydı, başlık "değişmedi"
kararı kırpmaya duyarlıydı — dördü de kapatıldı.

**Tur 2 (`flutter test` — KOŞAN ARTEFAKT):** 4 düşüş. 🔴 **Biri GERÇEK
REGRESYONDU ve tur 1 onu KAÇIRDI:** `v1→v2` adımındaki `alterTable`, güncel (v6)
Dart tanımıyla tablo yaratıp eski 7 sütunlu tablodan `oncelik`/`son_tarih` SELECT
ediyordu ⇒ **v1'den gelen kullanıcının veritabanı açılışta çöküyordu.**
`newColumns:` + `gorevlerYenidenYaratildi` koşulu eklendi (`ayarlar.imlecSahibi`
emsali). Kalan üçü bayat pindi (`Gorev` 7→9; iki "bayt bayt AYNI" testi — bunlar
adının aksine "o adım dokunmadı" değil "*bugüne kadar* dokunulmadı" ölçüyordu,
iddia aynı güçte yeniden yazıldı).

**DERS (kanla):** kâğıt denetimi migration'ın v1 yolunu KOŞAMAZ. "Denetim yalnız
koşan artefakta" kuralı bu turda kendi lehine kanıt üretti.

### Canlı tur (cihazdaki Chrome, Pages demosu, 14 Ağu 2026)

**Ölçülenler — hepsi yeşil:** v5→v6 migration OPFS'te FİİLEN koştu ve o72'den
kalan görev korundu · kalem ikonu *"Görevi düzenle"* birleşik diyaloğunu açtı
(başlık + dört öncelik çipi + son tarih) · *Yüksek* seçildi · tarih seçici açıldı,
21 Ağu seçildi, düğmede **21 Ağu 2026** göründü · Kaydet sonrası satırda meta:
**"Yüksek · 21 Ağu 2026"**, başlığın ALTINDA, yüksek öncelik renginde · **sekme
yenilendikten sonra da durdu ve GÜN KAYMADI** (21 → 21).

**ÖLÇÜLEMEDİ:** ölçütün üçüncü ayağı *"ikinci istemciye eşitlenir"* — Pages
demosunda backend YOKTUR (bilinen sınır 6), rozet *Gönderiliyor → Çevrimdışı*
akışına düştü. Senkron borusunun kendisi BİTTİ maddeleri 7 ve 8'in konusudur ve
iki yeni alanın o boruya bağlandığı 589 testte ölçülmüştür; **canlı değildir.**
Onur'un kararı (14 Ağu): sayaç 7/10, bu ayak sınır olarak yazılır.

**Turda çıkan bulgu — düzeltildi:** `showDatePicker` ürün Türkçe olmasına rağmen
*'Select date' / 'August 2026' / 'Cancel' / 'OK'* çiziyordu (delege verilmezse
Flutter yalnız en_US taşıyan `DefaultMaterialLocalizations`a düşer).
`flutter_localizations` (SDK paketi, pub.dev'de yok — /api 404) + sabit
`Locale('tr')` eklendi; `pages #5` sonrası CANLIDA DOĞRULANDI (takvim
"Tarih seçin / Ağustos 2026 / İptal / Tamam", hafta Pazartesi'den başlıyor). Kırmızı çizgi ölçüldü: transitif **`intl` · advisory 0
(paket geneli) · BSD-3-Clause** (dart-lang/i18n). *Erratum:* ilk beyan `0.20.3` (pub.dev'in
en günceli) diyordu; `pub get` **`0.20.2`** çözdü — kanonik `pubspec.lock`tur.

## Sıradaki iş

1. `pubspec.yaml` yorum erratumu + bu dosya commit BEKLİYOR (kod değişmedi).
2. Sonraki dilim (ODEV §4a): **etiket ekleme + etikete göre süzme** — backend
   `tags` OR-Set olarak zaten hazır (`FieldStrategyRegistry`); istemcide OR-Set
   kanalı `uzak_degisiklik_uygulayici.dart`ta BİLİNÇLİ OLARAK yok sayılıyor
   (`sets` kanalı, SINIR D2/1.4) ⇒ o sınır bu dilimde açılacak.

## Bilinen sınırlar

1. 🔴 **Flutter komutu repo kökünden koşulursa yalan söyler.** Doğru dizin
   `src/client`. PowerShell 5.1'de `&&` yok, `;` yaz.
2. **Canlı ölçümde tıklama tuzağı:** hover'sız sentetik tıklama ve odaklı düğmede
   Enter `TextButton`'ı tetiklemedi; **hover → tıklama** çalıştı. o74 EKİ: hover'lı
   tıklama bile bazen İKİ kez gerekiyor (ilki yalnız ODAK verir) ve diyalogdaki
   `İptal` hiç tetiklenmedi — modalı **Escape** kapattı.
3. **Kapı bütçesi ihlali**; teslimi kırmamak bütçeyi kapatmaktan önce gelir.
4. **Kimlik `devUserId` ile taşınıyor** ⇒ gerçek zamanlı işbirliği iki gerçek
   kullanıcıyla gösterilemez (kapsam dışı).
5. **`docs/ADR/0003` kilitli değil** — kâğıt denetlenmez, teslimi bloke etmez.
6. **Pages demosunda backend yok** ⇒ rozetler "Bu cihazda → Gönderiliyor →
   Çevrimdışı" akışına düşer; beklenen davranış. **Sonucu:** üç ayaklı canlı
   ölçütlerin "ikinci istemciye eşitlenir" ayağı Pages'te ASLA ölçülemez —
   ölçülmesi isteniyorsa yerel backend + iki istemci gerekir (mayın 6/7).
   Demoda o72/o74 ölçüm görevleri duruyor; değerlendirici onları görür.
7. **[o74'te ısırdı] Mount'a yazmanın tek yolu YERİNDE yazmaktır.** `unzip -o` ve
   mount'tan dışarı `mv` "Operation not permitted" verir (ikisi de önce SİLMEYİ
   dener). Çalışan yol: `/tmp`e açıp `cat > <hedef>`.
8. **[o74'te ısırdı] `pub cache` boşalabiliyor.** `dart run build_runner`
   *"Could not find bin\build_runner.dart"* dedi; ölçüldü: paket dizini **hiç
   yoktu** (Dart 3.12.2 geçişinde temizlenmiş). Çözüm `flutter pub get`.
   `--delete-conflicting-outputs` bayrağı da artık **kaldırılmış** (yok sayılıyor).
9. **Öncelik/son tarih için ÇAKIŞMA TESPİTİ kapsam dışı:** `kanonikDize` yalnız
   `fields:title` + `groups:completion` tanır; iki yeni alan LWW ile sessizce
   yakınsar, çakışma rozeti/ekranı onları göstermez.
10. Uzak yolda `DateTime.tryParse` sunucunun `TryParseExact`inden müsamahakârdır;
    sunucunun `MalformedFields` listesinin istemci karşılığı YOKTUR.
11. **Bilinmeyen `priority`** (ör. 4) ekranda çizilmez ama DB'de/telde dokunulmadan
    durur — başka istemcinin yazdığını ezmemek için.
12. **ÖLÇÜLMEDİ:** diyalog içi dokunma hedefleri (4 çip + tarih düğmesi) a11y
    kılavuzundan geçirilmedi; `snapshotUygula` ayağı yeni iki alan için test
    edilmedi (aynı `_kanalUygula`ya düşüyor).
13. **ÖLÇÜLDÜ, TEMİZ:** `kuyrukEnBuyuk`/`hamAlanHlcCikar` alan adı beyaz listesi
    tutmuyor ⇒ D5 koruması iki yeni kanalı da kapsıyor.

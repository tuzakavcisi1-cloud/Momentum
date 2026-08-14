# DURUM.md — Momentum

**BİTTİ: 6/10 · kutu 21 Ağu 2026 · `analyze` temiz · **589/589 test geçti** · commit BEKLİYOR · son ölçüm 14 Ağu 2026, oturum 74**

> Açılış ≤3 komut: ① `git --no-optional-locks log --oneline -1` + `status --porcelain -- src`
> ② bu dosya ③ CI durumu — **Cowork bunu claude-in-chrome ile cihazdaki Chrome'dan okur**
> (kanonik ölçüm yeri cihazdır; bulut tarayıcısı değil). `arsiv/` AÇILMAZ.
> **Flutter komutları `src/client`'tan koşulur** (bilinen sınır 1).

## Ne yapıldı (oturum 74 · 14 Ağu 2026)

**Öncelik + son tarih dilimi yazıldı, derlendi ve KOŞULDU:** `flutter analyze
--fatal-infos` → *No issues found*; `flutter test` → **589/589**. Canlı ayak
(web adresinde uçtan uca) HENÜZ ÖLÇÜLMEDİ ⇒ sayaç hâlâ **6/10**.

Kilitlenen tasarım (Onur): ① kodu Cowork yazar, commit+push Onur'da · ② öncelik
ÜÇ seviye + yok (`1=Yüksek, 2=Orta, 3=Düşük`) · ③ son tarih YALNIZ GÜN · ④ kalem
ikonu birleşik diyaloğa genişler, **satıra YENİ İKON EKLENMEZ**, değerler başlığın
altındaki meta satırında görünür.

- **Şema v5→v6:** `Gorevler`e `oncelik` (`int?`) + `sonTarih` (`DateTime?`).
- **Depo:** `Oncelik` enum + saf dönüşümler; `Yazim<T>` ("değişmedi" ≠ "temizlendi");
  `ayrintilariGuncelle()` = TEK `WireOp` + TEK `transaction()`, **yalnız değişen
  alan tele konar** (değişmemişi yeniden damgalamak uzak yazımı LWW ile ezerdi).
- **Tel biçimi backend kaynağından ÖLÇÜLDÜ:** `priority` = ondalık tamsayı dizesi,
  `dueAt` = `DateTime.utc(y,m,d).toIso8601String()`.
- **TAKVİM GÜNÜ PİNİ:** tek normalizasyon noktası `GorevSatiri.takvimGunu()`;
  `isUtc`/`hour` iddialarıyla env-bağımsız ölçülüyor (CI UTC koşar, statik
  `.toLocal()` taraması tek başına yetmez).
- **Uzak yol:** `fields:priority`/`fields:dueAt` bağlandı; "geldi mi" bayrağı
  sayesinde uzaktan TEMİZLEME (`value:null`) düşmüyor.
- **R4 tabanı BİLEREK 20 → 25**; **`Gorev` alan pini 7 → 9**. İkisi de varsayılmadı.

### İki tur denetim — ikisi de bulgu üretti

**Tur 1 (2 bağımsız denetçi, kâğıt üstünde):** BLOKER yok; ikisi de **bağımsız
olarak aynı çökmeyi** buldu — `showDatePicker` `initialDate` aralık dışında
kalabiliyordu (uzak istemci herhangi bir tarih yazabilir), tarih düğmesi hiçbir
şey yapmıyordu. **Kelepçe eklendi.** Ayrıca: takvim pininin yazma ayağı
korumasızdı, ekran kablosu hiç ölçülmüyordu, "meta yoksa çizilmez" boş iddiaydı,
başlık "değişmedi" kararı kırpmaya duyarlıydı — dördü de kapatıldı.

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

## Sıradaki iş

1. Commit (**yol belirterek**, `git add -A` YASAK) + push.
2. `pages` workflow_dispatch — o tek tıklama insanda.
3. **BİTTİ ÖLÇÜTÜ (canlı):** web adresinde bir göreve öncelik + son tarih verilir,
   sekme kapanıp açılınca DURUR, ikinci istemciye EŞİTLENİR. Yeşilse **7/10**.
   Otomasyonda **hover → tıklama** sırası (bilinen sınır 2).
4. Sonraki dilim (ODEV §4a): **etiket ekleme + etikete göre süzme** — backend
   `tags` OR-Set olarak zaten hazır (`FieldStrategyRegistry`).

## Bilinen sınırlar

1. 🔴 **Flutter komutu repo kökünden koşulursa yalan söyler.** Doğru dizin
   `src/client`. PowerShell 5.1'de `&&` yok, `;` yaz.
2. **Canlı ölçümde tıklama tuzağı:** hover'sız sentetik tıklama ve odaklı düğmede
   Enter `TextButton`'ı tetiklemedi; **hover → tıklama** çalıştı.
3. **Kapı bütçesi ihlali**; teslimi kırmamak bütçeyi kapatmaktan önce gelir.
4. **Kimlik `devUserId` ile taşınıyor** ⇒ gerçek zamanlı işbirliği iki gerçek
   kullanıcıyla gösterilemez (kapsam dışı).
5. **`docs/ADR/0003` kilitli değil** — kâğıt denetlenmez, teslimi bloke etmez.
6. **Pages demosunda backend yok** ⇒ rozetler "Bu cihazda → Gönderiliyor →
   Çevrimdışı" akışına düşer; beklenen davranış.
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

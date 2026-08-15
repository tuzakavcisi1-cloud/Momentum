# DURUM.md — Momentum

**BİTTİ: 7/10 · kutu 21 Ağu 2026 · `ci #44` YEŞİL (589/589) · `pages #5` YEŞİL · canlı doğrulandı · son ölçüm 14 Ağu 2026, oturum 76**

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

### İki tur denetim + canlı tur (o74) — özet

Tur 1 (kâğıt, 2 denetçi): `showDatePicker` `initialDate` aralık dışına düşüp tarih
düğmesini ÖLDÜREBİLİYORDU → kelepçe eklendi. **Tur 2 (`flutter test`) GERÇEK bir
regresyon buldu ve tur 1 onu KAÇIRDI:** v1→v2 `alterTable` v1'de olmayan sütunları
SELECT ediyordu ⇒ v1'den gelen kullanıcının DB'si açılışta çöküyordu (`newColumns`
ile kapatıldı). **DERS (kanla): kâğıt denetimi migration'ın v1 yolunu KOŞAMAZ.**
Canlı tur (cihaz Chrome, Pages): migration OPFS'te koştu, meta satırı **"Yüksek ·
21 Ağu 2026"** göründü, sekme yenilendi, GÜN KAYMADI. Takvim Türkçeleştirildi
(`flutter_localizations` + `Locale('tr')`, `intl` 0.20.2 · BSD-3 · advisory 0).
Ayrıntı: proje belgesi `claude/devir-oturum-75.md` ve o74 notları.

## Oturum 76 (14 Ağu 2026) — ETİKET DİLİMİ: KOD BİTTİ, CANLI ÖLÇÜM BEKLİYOR

Dilim BULUTTA yazıldı ve koşuldu: CI'nin pinlediği **Flutter 3.44.6** bulut
konteynerine kuruldu (cihazın Linux VM'inde flutter/dart YOK — ölçüldü).
`analyze --fatal-infos` *No issues found* · `flutter test` **628/628** (taban 589,
değiştirmeden önce de ölçüldü). 25 dosya cihaza yazıldı ve **sha256 ile bayt-bayt
doğrulandı**; commit + push + Pages ONUR'DA.

- **Şema v6→v7 (SALT-EKLEME):** `gorev_etiketleri(gorevId, etiket, addTag,
  iptalEdildi)`. `Gorevler`e DOKUNULMADI ⇒ v1 yolu etkilenmedi (v1→v7 zinciri test).
- **Tel:** `sets.tags.{adds,removes}` aynası (`el/tag/observed/hlc`) — sunucu
  `SyncContracts.cs`'ten ÖLÇÜLDÜ. `sets` kanalı LWW meta'ya (`UzakAlanDurumu`) ve
  `hamAlanHlcCikar`a ASLA bağlanmaz (OR-Set'te alan başına kazanan YOKTUR).
- **Birleştirme:** adds=insertOrIgnore (tombstone kalıcı, geç gelen add ÖLÜ DOĞAR) ·
  removes=observed başına satır açar + iptal eder ⇒ idempotent + değişmeli (test).
- **Snapshot:** tombstone TELE ÇIKMAZ (`SyncPuller` süzgeci) ⇒ snapshot'ta olmayan
  yerel tag, op'u hâlâ kuyruktaysa KORUNUR, değilse iptal edilir.
- **UI:** diyalogda etiket alanı + `InputChip`; satırda meta metnine `#etiket`;
  listenin üstünde TEK SEÇİM çip şeridi (Dart tarafında süzme, aynı stream).
- **Pinler ölçülerek güncellendi:** R4 25→29 · `Gorev` alan 9→10 · schemaVersion 6→7.
- **Bağımsız denetim (iki denetçi, 14 mutant): iki CİDDİ bulgu kapatıldı** — bant-içi
  ayraç (`group_concat`→`json_group_array`) + `_kuyruktakiTagler`'in iki mutantı.

## Sıradaki iş

1. **Etiket dilimini CANLIDA ölç** (ODEV §4a): commit + push → `ci` yeşil → `pages`
   workflow_dispatch (düğme İNSANDA) → cihaz Chrome'da: etiket ekle, çiple süz,
   sekmeyi kapat/aç → durdu mu. Yeşilse sayaç **8/10**. Tasarım kilidi ve adım
   sırası: `claude/devir-oturum-75.md` §4.

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
14. **Etiketlerde BÜYÜK/KÜÇÜK HARF KATLAMASI YOK** (bilinçli): sunucu OR-Set
    elemanlarını Ordinal karşılaştırır ⇒ `İş` ile `iş` AYRI etiketlerdir. Türkçe
    I/İ katlaması ayrı bir mayındır, kapsam dışı.
15. **Etiket 32 karakter sınırı YALNIZ İSTEMCİ kelepçesidir**; sunucu uzunluk
    kısıtlamaz ⇒ uzaktan gelen daha uzun etiket EZİLMEZ, çizilir. Etiketler
    `kanonikDize`ye girmez ⇒ çakışma ekranı onları göstermez (OR-Set'te
    "kaybeden değer" kavramı yoktur).
16. Etiket sıralaması KOD-BİRİMİ sırasıdır (`10`<`2`, `İş` sonda); Türkçe harmanlama YOK.

# DURUM.md — Momentum

**BİTTİ: 6/10 · kutu 21 Ağu 2026 · HEAD `ad369d9` · `ci #40` YEŞİL · `pages #3` YEŞİL · son ölçüm 14 Ağu 2026, oturum 73**

> Açılış ≤3 komut: ① `git --no-optional-locks log --oneline -1` + `status --porcelain -- src`
> ② bu dosya ③ CI durumu — **Cowork bunu claude-in-chrome ile cihazdaki Chrome'dan okur**
> (kanonik ölçüm yeri cihazdır; bulut tarayıcısı değil). `arsiv/` AÇILMAZ.
> **Flutter komutları `src/client`'tan koşulur** (bilinen sınır 1).

## Ne yapıldı (oturum 73 · 14 Ağu 2026)

- **Yeni esaslara geçildi.** `docs/ODEV.md` §4 kilidinden BİTTİ listesi türetildi ve Onur kilitledi:
  ORTA kapsam · kutu 21 Ağu · 10 madde. **71 dosya `arsiv/`'e** (hepsi `R100` saf yeniden adlandırma);
  `araclar/` ayrıldı (26 oturum aparatı arşive; CI'nın çağırdığı `verify.ps1` + bağımlılık/yayın
  araçları kökte); tek sayfa `CLAUDE.md` (8.146 b) + `DURUM.md`; README'nin bayat atıfları düzeltildi.
- **Sil dilimi kapandı — canlıda uçtan uca ölçüldü** (aşağıda). Sayaç 5/10 → **6/10**.
- Ölçülen boşluk (sıradaki dilimin gerekçesi): backend `TaskProjection` **12 alan** materyalize
  ediyor, istemci Drift tablosu **7 kolon** taşıyor, arayüzde **2** görünüyor.

## Sil dilimi — teslim turu KAPANDI (iki ayak da yeşil)

**Koşan artefakt:** `ci #40` **Success** (2m 43s) · `analyze --fatal-infos` geçti ·
**555 / 555 test geçti** (o71 tabanı 549 + sil turunun 6 testi).
**Canlı çıktı** (`pages #3` yayını, cihazdaki Chrome, 14 Ağu 2026): çöp ikonu arayüzde görünüyor ·
görev eklendi (*"Bu cihazda"* rozeti) · sil ikonu *"Görevi sil / Bu görev silinsin mi?"* diyaloğunu
açtı · **İptal hiçbir şey silmedi, görev listede kaldı** · onay sildi · **sekme yenilenince silinmiş
kaldı** (tombstone kalıcı).
**Kod ayağı:** `onSil` null ise ikon çizilmiyor · `tooltip: Metinler.gorevSil` zorunlu · `showDialog<bool>`
+ `if (onaylandi == true) onSil!()` · 🟢 **`_dikeyMi()` sabitler toplamına `onSil` terimi eklenmiş**
(`gorev_satiri.dart:112`) ⇒ ölçülen düzen ile çizilen düzen ayrışmıyor (M77b sınıfı kusur yok).
**Turda çıkan ve kapatılan tek bulgu:** `a11y_statik_tasma_test.dart` R4 pozitif kontrolünün pinli
tabanı bayatladı (`ci #39` kırmızı). Sil onay diyaloğu **4** yeni `Text(` ekledi; taban tarayıcının
kendi kuralıyla ölçülüp **16 → 20** güncellendi, ayrıca **beş** bayat sayı (test adı, `reason`,
gerekçe yorumu, dosya başlığı) tazelendi. Ürün kusuru değildi.

## Sıradaki iş

**Dilim: öncelik + son tarih** (`CLAUDE.md` §3). Drift tablosuna iki kolon + migration · satırda
görünür gösterim · düzenleme yüzeyi · senkron zarfına bağlanma. Bitti ölçütü canlı: web adresinde bir
göreve öncelik ve son tarih verilir, sekme kapanıp açılınca durur, ikinci istemciye eşitlenir.

**Önce toparlanacak küçük kalemler (commit'siz duruyor):** `KANIT/slice-3c/02-G2/*.json` dört dosya
değişmiş · `KANIT/o72/` ve `arsiv/PROJE-ESASLARI-SABLON.md` izlenmiyor (şablon taşındı ama izlenmediği
için commit'e girmedi).

## Bilinen sınırlar

1. 🔴 **Flutter komutu repo kökünden koşulursa yalan söyler [14 Ağu'da ısırdı].** Kökte `pubspec.yaml`
   YOK; kökten `analyze` **2866 issue** verdi — hepsi `uri_does_not_exist` ve ondan türeyenler
   (`package:drift/...` çözülemiyor). `src/client/.dart_tool/package_config.json` diskte **VAR** ⇒ ürün
   kusuru değil, çalışma dizini kusuru. **Doğru dizin `src/client`.** PowerShell 5.1'de `&&` yok, `;` yaz.
2. **Otomasyonla canlı ölçümde tıklama tuzağı:** Flutter web'de hover'sız sentezlenen tıklama ve odaklı
   düğmede Enter, `TextButton`'ı tetiklemedi; **hover → tıklama** çalıştı. İlk iki deneme ürünü değil
   otomasyonu ölçtü — canlı turda bu sıra kullanılır.
3. **Kapı bütçesi ihlal ve R4 bulgusu onun canlı örneği:** ürün her değiştiğinde sabit sayı pinli kapı
   kırılıyor. `KANIT/` (24 MB) yerinde — README'de 9, `docs/ADR/*`'da ~20 canlı bağlantı ona çıpalı;
   Onur'un kararı: teslimi kırmamak bütçeyi kapatmaktan önce gelir.
4. **Kimlik `devUserId` ile taşınıyor**, `WireOp.ActorId` istemci-beyanlı ⇒ gerçek zamanlı işbirliği
   iki **gerçek** kullanıcıyla gösterilemez (kapsam dışı yazıldı).
5. **`docs/ADR/0003` kilitli değil.** Yeni usulde kâğıt denetlenmez ⇒ teslimi bloke etmez, README'de
   kilitsiz olduğu beyan edilir.
6. **Pages demosunda backend yok** ⇒ rozetler *"Bu cihazda" → "Gönderiliyor" → "Çevrimdışı"* akışına
   düşer; bu beklenen davranıştır, kusur değil.
7. **Oturum 73 kapanışta 624k token** ölçüldü (eşik: ≥650k DUR + DEVİR) ⇒ öncelik + son tarih dilimi
   **temiz bir oturumda** başlamalı. Bu dosya devir notudur; ayrı devir defteri tutulmaz.

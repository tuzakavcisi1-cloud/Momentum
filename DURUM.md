# DURUM.md — Momentum

**BİTTİ: 5/10 (liste KİLİTLİ) · kutu 21 Ağu 2026 · HEAD `6e34270` · CI `ci #39` 🔴 (tek test) — düzeltmesi YAZILDI, commit BEKLİYOR · son ölçüm 14 Ağu 2026, oturum 73**

> Açılış ≤3 komut: ① `git --no-optional-locks log --oneline -1` + `status --porcelain -- src`
> ② bu dosya ③ CI durumu (GitHub Actions; Cowork claude-in-chrome ile **cihazdan** okuyabilir).
> **Flutter komutları `src/client`'tan koşulur** (bilinen sınır 2). `arsiv/` AÇILMAZ.

## Ne yapıldı (oturum 73 · 14 Ağu 2026)

- `docs/ODEV.md` §4 kilidi ile ürün karşılaştırıldı: backend `TaskProjection` **12 alan** materyalize
  ediyor, istemci Drift tablosu **7 kolon**, arayüzde **2**. BİTTİ listesi ODEV'den yeniden türetildi.
- Onur kilitledi: **ORTA kapsam** · kutu **21 Ağu** · 10 maddelik liste (`CLAUDE.md` §2), sayaç **5/10**.
- **71 dosya `arsiv/`'e** taşındı (hepsi `R100` saf yeniden adlandırma); `araclar/` ayrıldı (26 oturum
  aparatı `arsiv/araclar/`'a; CI'nın çağırdığı `verify.ps1` + bağımlılık/yayın araçları kökte kaldı);
  yeni tek sayfa `CLAUDE.md` (8.151 b) + `DURUM.md`; README'nin 6 bayat atıfı düzeltildi.
- Commit + push: `a2971aa..6e34270`, 79 dosya. **CI cihazdan okundu** (claude-in-chrome).

## SİL TURUNUN DENETİMİ — ölçüldü (teslim sınırı turu, 1/2 ayak tamam)

**Geçenler (ölçüldü):**
- `flutter analyze --fatal-infos` **geçti** (test adımına geçebildi; ci.yml sırası analyze → test).
- **554 / 555 test geçti**, `g14_dikey_donus_kapisi` dâhil. (o71 tabanı 549 + sil turunun 6 testi.)
- İş emrinin dört kritik deseni kodda: `onSil` null ise ikon çizilmiyor (`gorev_satiri.dart:217`) ·
  `tooltip: Metinler.gorevSil` (284) · `showDialog<bool>` + `if (onaylandi == true) onSil!()` (299/332) ·
  🟢 **en kritik kalem: `_dikeyMi()` sabitler toplamına `onSil` terimi EKLENMİŞ** (112) ⇒ ölçülen düzen
  ile çizilen düzen **ayrışmıyor**, M77b sınıfı kusur yok.

**Düşen (1 test) — ürün kusuru DEĞİL:**
- `test/a11y_statik_tasma_test.dart` → *R4: pozitif kontrol — tarayıcının bulduğu `Text(` aday sayısı*.
  `expect(adaylar.length, 16)`; sil onay diyaloğu yeni `Text(` düğümleri ekledi ⇒ taban bayatladı.
  Doktrin gereği **taban bilerek güncellenir** (aynı satır daha önce 8→12→13→16 güncellenmişti).
  Ham ölçüm: `lib/sunum` + `lib/vitrin` bugün **21** ham `Text(` taşıyor (tarayıcının kriteri daha dar);
  emsal o68 diyaloğu **+3** getirmişti ⇒ **[TAHMİN] 19**. Kesin sayı testin `reason` çıktısındadır.
- 🔴 **İkinci bulgu:** testin ADI *"aday sayisi = 12"* diyor, `expect` **16**. o68'de pin güncellenirken
  ad güncellenmemiş ⇒ CI çıktısı yanlış sayı raporluyor (bu oturumda ölçümü bir kez yanılttı).
- **Kırılma bu commit'ten geldi:** `ci #38` (`a2971aa`, sil öncesi) *completed successfully*, `ci #39` failed.

**Kalan ayak:** canlı doğrulama. `pages` son kez o71'de koştu ⇒ canlı adres hâlâ sil'siz sürümü
gösteriyor. Sıra: pin düzelt → CI yeşil → `pages` `workflow_dispatch` → canlı adreste dört eylem
(ekle/düzenle/tamamla/sil) **cihazdaki tarayıcıdan** ölçülür. Yeşil olunca sayaç **6/10**, README'den
*"silme arayüzde yok"* beyanı kalkar. *(Mutant koşumu ısrar edilmiyor — yeni usulde denetim canlı
çıktıya bakar, `MOD: NORMAL` ⇒ tek tur.)*

## Bilinen sınırlar

1. **CI kırmızı ve düzeltmesi commit edilmedi.** `test/a11y_statik_tasma_test.dart`'ta **beş** bayat
   sayı tazelendi (pin `16`→**20** · test adı `12`→20 · `reason` metni · gerekçe yorumu · dosya başlığı
   yorumu); aday sayısı **20** olarak tarayıcının kendi kuralıyla ölçüldü (`+4` = sil onay diyaloğunun
   başlık/gövde/İptal/Sil düğümleri). Dosya bayt-doğrulandı, CRLF=0. **Commit + push Onur'da.**
2. 🔴 **Flutter komutu repo kökünden koşulursa yalan söyler [14 Ağu'da ısırdı].** Kökte `pubspec.yaml`
   YOK; kökten `analyze` **2866 issue** verdi — hepsi `uri_does_not_exist` ve ondan türeyenler, çünkü
   `package:drift/...` çözülemiyor. `src/client/.dart_tool/package_config.json` diskte **VAR** ⇒ ürün
   kusuru değil, çalışma dizini kusuru. **Doğru dizin `src/client`.** PowerShell 5.1'de `&&` yok, `;` yaz.
3. **Kapı bütçesi ihlal ve bu bulgu onun canlı örneği:** ürün kodu her değiştiğinde sabit sayı pinli
   kapı kırılıyor. `KANIT/` (24 MB) da yerinde — README'de 9, `docs/ADR/*`'da ~20 canlı bağlantı ona
   çıpalı; Onur'un kararı: teslimi kırmamak bütçeyi kapatmaktan önce gelir.
4. **README bayat:** *"silme arayüzde yok"* (satır 93, 291) ve istemci test sayısı **549** — ikisi de
   canlı doğrulama turunda tazelenecek (gerçek sayı 555).
5. **Kimlik `devUserId` ile taşınıyor**, `WireOp.ActorId` istemci-beyanlı ⇒ gerçek zamanlı işbirliği
   iki **gerçek** kullanıcıyla gösterilemez (kapsam dışı yazıldı).
6. **`docs/ADR/0003` kilitli değil.** Yeni usulde kâğıt denetlenmez ⇒ teslimi bloke etmez, README'de
   kilitsiz olduğu beyan edilir.
7. **Kapanan kalemler:** push ölçüldü (`origin/main` = `6e34270`) · `flutter test` sayısı ölçüldü (555) ·
   `analyze` hükmü ölçüldü (geçti) · `KIMLIKLER.md` D1 bulgusu defter arşive indiği için düştü ·
   *"GitHub'a erişimim yok"* beyanı **yanlıştı** — claude-in-chrome cihazdan okuyor, kanonik ölçüm yeri.

# 09-HUKUM.md — GOREV-A9 (v3) · builder'ın kendi hükmü

> 🔴 Bu bir **Cowork onayı DEĞİLDİR** — K26 gereği builder'ın kendi beyanıdır; Cowork kendi
> denetimini koşmadan bunu **KABUL ETMEZ**.

**Kim:** Claude Code · **Ne zaman:** 1 Ağu 2026, oturum 43 · **Spec:** `GOREV_CLAUDE_CODE/GOREV-A9-cakisma-cozum-metin-kaybi.md` (kilit: Onur, sha8 `C57D737A`, 32.332 b)

## SONUÇ ÖZETİ

**13/14 kriter geçti. Kriter 12'de BİR DUR tetiklendi** — `iddia-kapisi.py` I1 kontrolü, **spec metninin
kendi prozasındaki** iki idiomatik Türkçe ifadeyi ("tek **bir mutant**", "v1 **6 mutant** yazdı") sayı
iddiası sanıp tablo satır sayısıyla (11) karşılaştırıyor ve **KIRMIZI/EXIT 1** veriyor. Bu, **spec dosyası
değiştirilerek düzeltilemez** (builder'a "spec'e tek bayt yazma" yasağı var) ve araç da builder'ın işi
değil (K34-f). Ayrıntı aşağıda kriter 12'de.

## Kabul kriterleri — sırayla, atlanmadı

| # | Kriter | Sonuç | Kanıt |
|---|---|---|---|
| 1 | R1 taban + refactor + R2 KIRMIZI (tam iki konum) | ✅ R1 taban 2/2 yeşil; refactor sonrası R2 tam `cakisma_rozeti.dart:77,82`'de kırmızı, başka konum yok | `00-R1-ONCE.txt`, `00-ONCE-KIRMIZI.txt` |
| 2 | Probe harness `sarmalayici`'yi doğrudan kullanır | ✅ `_sarmalayici` → public `sarmalayici` yapıldı (Dart görünürlüğü dosya-bazlı, private cross-file import edilemez); probe kendi kurulumunu YAZMADI | `00-PROBE.dart.txt` |
| 3 | Y7 sayı ölçümü, tavan 8 | ✅ **N = 6** (dokuz noktanın hepsinde N=6'da didExceedMaxLines=false); tavan altında, DUR **tetiklenmedi** | `00-OLCUM.txt` |
| 3b | Y6 rota+semantik (EN RİSKLİ NOKTA) | ✅ (a) didExceedMaxLines=**true** (gerçekten kırpılıyor, 232px genişlikte) — ölçüm, hüküm değil (b) semantik etiket **TAM METNİ TAŞIYOR** ("Çakışma var" birebir) ⇒ DUR **tetiklenmedi**, Y6=1 **savunulabilir** | `00-Y6-ROTA.txt` |
| 4 | Ürün + G16 genişletme + YEŞİL | ✅ `flutter test` 476/476 EXIT 0; G16 tek başına: **A0=1 · A1=45 · A2=63 · A3=54 · A4=45 = 208**, hedefle BİREBİR | `01-SONRA-YESIL.txt`, `03-TEST.txt` |
| 5 | Refactor regresyonu (R1 taban vs şimdi) | ✅ R1 her iki ölçümde de BOŞ (1/1→1/1 yeşil); M104 R1'i GERÇEKTEN `senkron_rozeti.dart:178`'de ısırttı (kriter 6'dan) | `06-REGRESYON.txt` |
| 6 | M98–M108 (11 mutant) | ✅ Hepsi doğrulandı, ısırmayan mutant YOK. M105 tersten okunur doğrulandı: R1 KIRMIZI (8 sahte ihlal) VE R2 SESSİZCE KÖR (0) — "ikisi birden" DEĞİL | `02-MUTANT/M98.txt`…`M108.txt` |
| 7 | FİNAL YEŞİL (mutasyonlar geri alındıktan sonra) | ✅ `flutter test` 476/476 EXIT 0; `_a9_probe_test.dart` içinde `test(` çağrısı **0** | `01b-FINAL-YESIL.txt` |
| 8 | `flutter analyze --fatal-infos` | ✅ EXIT 0, "No issues found!" | `04-ANALYZE.txt` |
| 9 | `design-token-kapisi.py` | ✅ EXIT 0, "TEMİZ" | `05-DESIGN-TOKEN.txt` |
| 10 | Regresyon kapıları (7 dosya, ayrı ayrı) | ✅ Hepsi EXIT 0: g13=76 · g14=7 · g15=11 · a11y_kapisi=13 · sunum_bilesenleri=13 · a11y_statik_tasma=4 · g16=208 | `06-REGRESYON.txt` |
| 11 | `spec-kapi-kapsama.py` (dosya yoluyla) | ✅ EXIT 0 — KAPI(2): G5,G16 · MUTANT(11) · BULGU YOK | `_SILINECEKLER/06-SPEC-KAPSAMA.txt` (dizin dışı) |
| **12** | `iddia-kapisi.py --kanit KANIT\A9` | 🔴 **DUR — EXIT 1 (KIRMIZI)**, aşağıda ayrıntı | `07-IDDIA.txt` |
| 13 | Diff ölçümü (ellipsis TAM 8) | ✅ `git status`+`git diff` (tam metin) ölçüldü; `lib/sunum` ellipsis sayımı **TAM 8** | `08-GIT-STATUS.txt` |
| 14 | HÜKÜM | ✅ bu belge | — |

## 🔴 KRİTER 12 DUR — TAM AÇIKLAMA

`python araclar\iddia-kapisi.py GOREV_CLAUDE_CODE\GOREV-A9-cakisma-cozum-metin-kaybi.md --kanit KANIT\A9`
⇒ **EXIT 1**, `HÜKÜM: KIRMIZI`.

**Blokaj — I1 (KIRMIZI, EXIT'i belirleyen):**
```
[KIRMIZI] I1: SAYI<->LISTE TUTARSIZLIGI: belge 'bir mutant' diyor (yazi), tabloda 11 mutant satiri var.
[KIRMIZI] I1: SAYI<->LISTE TUTARSIZLIGI: belge '6 mutant' diyor (rakam), tabloda 11 mutant satiri var.
```
Kaynak (spec dosyasının KENDİSİ, satır numaralarıyla ölçüldü):
- **satır 307:** *"🔴 DUR: ısırmayan **tek bir mutant** bile varsa DUR."* — burada "bir" sayı iddiası
  DEĞİL, "even a single one" anlamında idiomatik kullanım; araç ayırt edemiyor.
- **satır 18** (§0 tablosu, v1'in REDDEDİLEN halini anlatan tarihsel bölüm): *"3 | **6 mutant** yazdı,
  §6b'ye iki borç koydu..."* — bu, **v1'in** (reddedilmiş taslağın) ne yaptığını anlatan TARİHSEL bir
  cümle, **bu spec'in (v3) kendi mutant sayısı iddiası DEĞİL**; araç bunu da ayırt edemiyor.

Bu iki eşleşme `python -c` ile `iddia-kapisi.py`'nin kendi `iddialar()` fonksiyonu DOĞRUDAN çağrılarak
doğrulandı (spekülasyon değil, ölçüm): `[('yazi', 1, 'bir mutant'), ('rakam', 6, '6 mutant'), ('aralik', 11, 'M98–M108')]`.

**Neden DÜZELTİLEMEZ (builder tarafından):**
1. **"Spec'e tek bayt yazma"** — bu görevin PAZARLIKSIZ sınırı; satır 307/18'i yeniden yazmak bu sınırı
   ihlal eder.
2. **Aracı onarmak builder'ın işi değil (K34-f)** — `iddia-kapisi.py`'nin Türkçe idiom/tarihsel-bölüm
   ayırt etme kabiliyeti yok; bu bir araç sınırlaması, spec ya da build kusuru değil.
3. **`--kanit` tarafında düzeltilecek bir şey YOK** — I1 tamamen `iddialar(metin)` (spec'in kendi
   prozası) ile `tablodaki_mutantlar(metin)` (spec'in kendi tablosu) karşılaştırmasıdır; `KANIT/A9`
   içeriği bu hesaba hiç girmez.

**İkincil (SARI, EXIT'i etkilemez ama şeffaflık için not edildi) — I3 hayalet kanıt:**
`M10`/`M16`/`M75` için "kanıt var ama tabloda yok" uyarısı — bunlar A9'un mutant kimlikleriyle
İLGİSİZ, ham `flutter test` çıktılarında GEÇEN başka (eski, ilgisiz) test adlarının alt-dizge
çakışmasıdır (`a11y_statik_tasma_test.dart`'ın kendi F6/M10 ve M16 referanslı test adları;
`g14_dikey_donus_kapisi_test.dart`'ın "M75 kaldıracı" adlı test vakası — `01b-FINAL-YESIL.txt:124`).
Bu dosyalar **ham kanıt** olarak BİLEREK dokunulmadan bırakıldı (elle düzenlemek kanıtı sahteleştirir);
I1 zaten EXIT'i KIRMIZI'ya çektiği için bu SARI'ların ayrıca temizlenmesi sonucu değiştirmezdi.

**Sonuç:** Kriter 12 **DUR** durumundadır. Cowork'e bildirilir — karar şıkları: (a) spec satır 307/18'in
idiomatik/tarihsel doğasını **Onur onayıyla** netleştirecek şekilde spec'i **Cowork** düzeltir, ya da
(b) `iddia-kapisi.py`'ye Türkçe idiom/tarihsel-bölüm ayrımı eklemek **ayrı bir araç ele (K34-f)** açılır,
ya da (c) bu iki yanlış-pozitif **beyan edilmiş sınır** olarak kabul edilip A9 bu haliyle kapatılır.
Builder bu üçünden **hiçbirini kendi başına seçemez**.

## Ölçülen N değerleri

- **Y7 (`kCakismaGovdesiMaxSatir`) = 6** — probe sweep, dokuz noktanın hepsi.
- **Y6 (`kCakismaBasligiMaxSatir`) = 1** — SABİT, spec'in kendi kilidi (ölçülmez).

## Değişen dosyalar (git status, kriter 13'ten)

```
 M src/client/lib/sunum/cakisma_rozeti.dart
 M src/client/test/a11y_statik_tasma_test.dart
 M src/client/test/g16_metin_kaybi_kapisi_test.dart
?? KANIT/A9/
?? src/client/lib/sunum/_a9_m102_gecici.dart   (bkz. aşağıda)
?? src/client/test/_a9_probe_test.dart          (bkz. aşağıda)
```
(`HUKUM.md`, `KANIT/R9/…`, `KANIT/slice-3c/…`, `KANIT/slice-3d/…`, `src/client/test/_a8_*`,
`_debug_join_test.dart`, `_tmp_sqlite_version_test.dart` bu build'DEN ÖNCE de untracked'tı — bu
oturumun ürünü değil.)

## 🔴 Build sırasında bulunan İKİ ortam kısıtlaması (gizlenmedi)

1. **`src/client/lib/sunum/_a9_m102_gecici.dart` SİLİNEMEDİ.** M102 mutant'ı bu dosyayı oluşturmayı
   gerektiriyordu ve spec "mutant sonrası GERİ ALINIR (silinir)" diyor. Bu ortamda hem `rm` hem
   PowerShell `Remove-Item` bu oturumda **REDDEDİLDİ** (CLAUDE.md güvenlik kuralı: kalıcı silme yasak,
   iki ayrı araç denendi, ikisi de reddedildi — tekrar denenmedi). Dosya bu yüzden **BOŞALTILDI** (0
   `Text(`, 0 ellipsis, 0 maxLines) — `R1`/`R2`/`R4` aday sayımını ve `design-token-kapisi.py`'yi
   ETKİLEMİYOR (doğrulandı, `M102.txt`). `git diff` bu dosyayı GÖSTERMEZ (untracked); yalnız
   `git status`'ta `??` olarak görünür. Onur elle silebilir.
2. **`src/client/test/_a9_probe_test.dart` SİLİNEMEDİ** — aynı kısıtlama, aynı çözüm (A8'in
   `_a8_probe_test.dart`/`_a8_olcum_test.dart` husk'larıyla AYNI desen). `test(` çağrısı **0** olduğu
   ölçüldü (kriter 7).

## Dosya kimlikleri (`dosya-kimlik.py`, bu belgenin YAZIMINDAN SONRA ölçülecek)

Aşağıdaki komutla ayrı bir adımda ölçüldü, çıktı bu bölümün ALTINA eklendi:
`python araclar\dosya-kimlik.py GOREV_CLAUDE_CODE\GOREV-A9-cakisma-cozum-metin-kaybi.md src\client\lib\sunum\cakisma_rozeti.dart src\client\test\a11y_statik_tasma_test.dart src\client\test\g16_metin_kaybi_kapisi_test.dart KANIT\A9\09-HUKUM.md`

<!-- DOSYA-KIMLIK:BAS -->
```
DOSYA                                                BAYT      SHA8   FFFD   CRLF
----------------------------------------------------------------------------------
GOREV-A9-cakisma-cozum-metin-kaybi.md               32332  C57D737A      0      0
cakisma_rozeti.dart                                  3956  94B1A951      0      0
a11y_statik_tasma_test.dart                          8869  E659279E      0      0
g16_metin_kaybi_kapisi_test.dart                    16551  688D17BE      0      0
----------------------------------------------------------------------------------
HUKUM: TEMIZ
```
🔴 **Spec kimliği `32332 b · C57D737A` — kilitte beyan edilenle (32.332 b · sha8 C57D737A) BİREBİR
AYNI.** Bu, spec dosyasına tek bayt yazılmadığının MEKANİK kanıtıdır (beyan değil, ölçüm).
(`09-HUKUM.md`'nin kendi kimliği bu tabloya girmedi — ölçüm bu ekten ÖNCE alındığı için, eklemenin
kendisi dosyanın hash'ini kaçınılmaz olarak değiştirir; bu bilinen ve kabul edilen bir sınırdır.)
<!-- DOSYA-KIMLIK:SON -->

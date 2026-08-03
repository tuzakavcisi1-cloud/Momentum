# SS2 v3 — KİLİT KANITI (`K133`) · oturum 55, 3 Ağu 2026

**Kilitlenen:** `GOREV_CLAUDE_CODE/GOREV-SS2-cakisma-cozumu.md` **v3**
**Kimlik (son yazımdan SONRA ölçüldü):** **46.003 b · `420E9F91`** · U+FFFD **0** · CRLF **0**
**Önceki (GEÇERSİZ):** v1 28.801 b `90314998` · v2 34.504 b `66CC4AAE`
**Kilidi veren:** Onur (oturum 55) · **Yazan el:** Cowork · **Build eden el:** Claude Code

---

## K127 — BAĞIMSIZ DENETİM ÇIKTI YOLLARI (zorunlu alan)

| tur | çıktı yolu | bulgu |
|---|---|---|
| 1 | `KANIT/SS2/00-DENETIM-kilit-oncesi.md` | 13 bloker + 31 major + 15 minor (3 denetçi) |
| 2 | `KANIT/SS2/02-DENETIM-tur2.md` | **5 bloker + 13 major + 5 minor** (D5 tam, D4/Bölüm-B) |

🔴 **ÜÇÜNCÜ TUR KOŞULMADI — bilinçli, gerekçesi yazılı.** `K53/1`: *"ikinci tur ancak birincisi
**mimariyi değiştiren** bir bloker bulduysa"*; tur 2 öyle bir bloker **bulmadı** (kendi hükmü:
*"kalan blokerların hiçbiri mimariyi değiştirmiyor"*). Ayrıca `K53/4`'ün **`R8` sert durağı** oturum
53–54'te **0 satır ürün kodu** ölçtü ⇒ oturum 55 ürün koduyla açılmak zorundaydı. v3'ün onarımları
**mekanik kapılarla** doğrulandı (aşağıda). Bu, K127'nin *"yoksa açıkça yazar"* şıkkının kullanımıdır.

---

## BEŞ BLOKER — HİÇBİRİ BORÇLANAMADI, BEŞİ DE KAPATILDI

`K53/3` **"KAPI borçlanamaz, yalnız kural"** gereği sınıflama önce yapıldı:

| bloker | sınıf | neden borçlanamaz | kapanış |
|---|---|---|---|
| **B2-1** `M172` hâlâ eşdeğer | **KAPI** (`G32/a` kör) | Eşdeğer mutant kapının ısırdığını kanıtlayamaz ⇒ `G32/a` fiilen mutantsız | Mutasyonun hedefi **yazım sırası değil OKUMA KAYNAĞI** yapıldı: `kaybedenDeger` yazımdan **sonra DB'den yeniden okunan** satırdan alınır |
| **B2-2** `M176` `G10`'u düşüremez | **KABUL KRİTERİ** (kendini imkânsız kılıyor) | Kriter 4 hiçbir koşulda sağlanamıyordu ⇒ kabul yapısal olarak engelli | `M176` **statik**e indi (`G33/c`), `G10` şartı **`M176` için kaldırıldı** (`M183` için KALDI); fan-out yükü **yeni `G33/d` + `M176b`** ile davranışsal ölçülür |
| **B2-3** `M171b` sıfır-bilgi | **KAPI** (`G31/a` kör) | Yorumu atan da atmayan araç da yeşil ⇒ ayak ölçülmüyor | Mutant **tersine çevrildi** (gerçek satır `=> 4`, doğru değer yalnız yorumda ⇒ KIRMIZI); yanlış-pozitif kontrolü **`M171c`**'ye ayrıldı |
| **B2-4** `D-SS2-3/e` şart 3'ü atlıyor | **ÜRÜN — VERİ KAYBI** | Kırmızı çizgi sınıfı; ürün kapısı borçlanamaz | `/e` artık **şart 3'ü ARAR**; echo turu `/e`'yi ateşlemez. Yeni ayak **`G32/e2`**, mutant **`M180b`** |
| **B2-5** `g2` testi `schemaVersion == 4` pinli | **SPEC İÇİ ÇELİŞKİ** | `T1` bump ediyor, `T2` "regresyon yok" diyor ⇒ builder kilitlenir | `T1`'e zorunlu güncelleme + **dump sırası** yazıldı; `T2` bu satırı **hariç tutar** |

**Bağımlılık ölçüldü:** B2-4'ün onarımı **MAJOR-1**'e bağımlıydı — şart 3'ün iki ön koşulu
(`_GorevGuncellemesi`'nin kanal başına kazanan anahtar/`clientHex` taşıması ve
`UzakDegisiklikUygulayici`'nın cihazın `clientId`'sini alması) **kodda yoktu** ve v2'nin *"üç-kanal
eşlemesi `g` içinde hazır"* gerekçesi ölçümle **çürüktü**. İkisi de `D-SS2-2`'ye `T3`'ün parçası
olarak yazıldı.

## ONUR'UN KİLİTLEDİĞİ İKİ TASARIM KARARI (oturum 55)

1. **B2-2 →** yeni `G33/d` ayağı + `M176b` mutantı **eklendi** (alternatif: ölçümü borç yazmaktı;
   reddedildi çünkü `K53/3` KAPI borçlanmasına izin vermiyor).
2. **MAJOR-8 →** `cakismaCoz` **dış transaction açar**, iç metotlar savepoint'e düşer; `G34/f` +
   `M177` kilidi **korunur**. 🔴 Beyan edilmiş sınır **`S11`**: drift'in iç içe transaction'ı
   savepoint'e indirgediği **ÖLÇÜLMEDİ**; `T6` ölçer, indirgemiyorsa builder **durur**.

## 13 MAJOR — BORÇLANDI (kilit KAPANMAMIŞ SINIRLARLA verildi, `A13`/`K130` emsali)

Spec içine **beyan edilmiş sınır** olarak: `S11` (iç içe transaction ölçülmedi) · `S12`
(`rozetDikisi` patlama yarıçapı — `T4` kapsamı genişletildi) · `S13` (zorunlu `entityId` iki testi
derlenemez yapar) · `S14` (`G31/c` reçetesi doğrulanmadı). Kalanlar `BORCLAR.md` → `B-SS2-4`.

---

## MEKANİK KAPI ÇIKTILARI (hepsi v3 üzerinde, cihazda koşuldu)

| kapı | çıktı | hüküm |
|---|---|---|
| `spec-kapi-kapsama.py <spec yolu>` | 4 kapı / 11 kural / **23 mutant** (v2'de 20) / 3 gerekçeli borç · `[S0]/[S1]/[S2]` **yok** | **EXIT 0** |
| `kapi-ad-teklik-kapisi.py .` | `N1`/`N2` yok; 9 × `N3` bilgi (SS2 dışı, önceden var) | **YEŞİL, EXIT 0** |
| `dosya-kimlik.py <spec>` | 46.003 b · `420E9F91` · U+FFFD **0** · CRLF **0** | **TEMİZ** |
| `tek-kopya-kapisi.py .` | 11 dosya, HEAD'e göre sapma **+0** | **YEŞİL, EXIT 0** |

🔴 **BEYAN EDİLMİŞ SINIR — bu kanıtın kendi sınırı:** `spec-kapi-kapsama.py` *"mutant VAR mı"*
sorar, ***"mutant ISIRIR mı"* SORMAZ**. v3'ün üç onarımı (`M172`, `M171b`, `M176`) tam da bu boşluk
yüzünden iki tur boyunca kaçtı. Isırma yalnız **`T7`'de koşan kodla** kanıtlanır; bu kilit onu
kanıtlamaz, **koşulmasını şart koşar**. Sınıfın mekanik kapısı **hâlâ yoktur** (borç `B-SS2-4`) ve
bu, üç tur üst üste aynı dersin alıntılanıp uygulanmadığı vakadır:
`A13/M167` → v1 `M172/M173/M175` → v2 `M172`.

## SIRADAKİ

`T0` (araç, **ürün kodu SAYILMAZ**) → **`T1` ürün kodu başlar** ⇒ `R8` bu oturumda söner.
Yama betiği: `KANIT/SS2/_ss2_v3_yama.py` (16/16 yama, K60 atomik yazım, tekrarlanabilir).

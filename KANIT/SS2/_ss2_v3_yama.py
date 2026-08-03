# -*- coding: utf-8 -*-
# SS2 v2 -> v3 YAMA (oturum 55). Tur-2 denetiminin BES BLOKERINI kapatir.
# K60: atomik yazim (uc adimli yedekli takas -- os.replace bu makinede WinError 5 verir).
import sys, os, hashlib
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

YOL = r"C:\dev\Momentum\GOREV_CLAUDE_CODE\GOREV-SS2-cakisma-cozumu.md"

with open(YOL, "rb") as f:
    ham = f.read()
metin = ham.decode("utf-8")
print("GIRDI :", len(ham), "bayt · sha8", hashlib.sha256(ham).hexdigest()[:8].upper())

YAMALAR = []

def yama(ad, eski, yeni):
    YAMALAR.append((ad, eski, yeni))

# ---------------------------------------------------------------- B2-4 (VERI KAYBI)
yama("B2-4 /e sart 3",
"""🔴 **BAYATLAMA KURALI (`/e`):** o `(entityId, alan)` için **kayıt zaten VARSA**, şart 2–4
aranmaksızın **`kazananDeger` ve `kazananClientHex` GÜNCELLENİR**, `kaybedenDeger` **korunur**.""",
"""🔴 **BAYATLAMA KURALI (`/e`):** o `(entityId, alan)` için **kayıt zaten VARSA**, şart **2 ve 4**
aranmaksızın — **ama şart 3 ARANARAK** — **`kazananDeger` ve `kazananClientHex` GÜNCELLENİR**,
`kaybedenDeger` **korunur**.

🔴 **ŞART 3 `/e`'DE DE ARANIR — PAZARLIKSIZ [tur 2 denetimi `B2-4`; `KANIT/SS2/02-DENETIM-tur2.md`].**
v2 *"şart 2–4 aranmaksızın"* yazmıştı ve bu **YENİ bir veri kaybı** doğuruyordu (ölçülmüş senaryo):
kayıt varken kullanıcı yerel `C` düzenlemesi yapar → itilir → **kendi echo'su** döner (`Ö8` gereği op
`changesUygula`'dan **önce** silinmiştir ⇒ echo projeksiyonu kazanır) ⇒ şart 1 sağlanır ⇒ `/e` ateşler
ve `kazananDeger = C` yazılır. Ekran *"Benimki: `B1` / Onlarınki: `C`"* gösterir; **`C` kullanıcının
KENDİ EN YENİ yazımıdır** ve *Benimkini tut* onu **yok eder**. Şart 3 (*kazanan biz değiliz*) `/e`'de
de arandığında echo turu `/e`'yi **hiç ateşlemez**. → `SS2/G32/e2`, mutant `M180b`.""")

# ---------------------------------------------------------------- MAJOR-1 (sart 3'un on kosulu)
yama("MAJOR-1 veri akisi",
"""Gerekçe (`Ö5`): `mevcut` satır orada **zaten okunuyor** (`:209`) ⇒ ekstra `SELECT` yok, erken
`return` sorunu yok, üç-kanal eşlemesi `g` içinde hazır. INSERT dalı **kapsam dışıdır**: yeni
entity'de ezilecek yerel değer **yoktur** (`:213`'ün kendi gerekçesi).""",
"""Gerekçe (`Ö5`): `mevcut` satır orada **zaten okunuyor** (`:209`) ⇒ ekstra `SELECT` yok, erken
`return` sorunu yok. INSERT dalı **kapsam dışıdır**: yeni entity'de ezilecek yerel değer **yoktur**
(`:213`'ün kendi gerekçesi).

🔴 **ŞART 3'ÜN İKİ ÖN KOŞULU KODDA YOK — `T3`'ÜN PARÇASIDIR [tur 2, MAJOR-1].** v2 *"üç-kanal
eşlemesi `g` içinde hazır"* diyordu; **ölçüm bunu çürüttü**. `_projeksiyonYaz`'da şart 3
hesaplanabilsin diye **ikisi de eklenir**:

1. **`_GorevGuncellemesi` kanal başına kazanan anahtarı taşır** — `AlanAnahtari` (dolayısıyla
   `clientHex`) `_kanalUygula`'da biliniyor ama `_projeksiyonYaz`'a **taşınmıyor**; kanal→anahtar
   eşlemesi `g` ile birlikte taşınır. `G34/d`'nin `kazananAnahtar` operandı da **buradan** okunur
   (tur 2, MAJOR-2: v2 kazanan HLC sütunlarını sildiği için operandın kaynağı belirsiz kalmıştı).
2. **`UzakDegisiklikUygulayici` kurucusu cihazın kendi `clientId`'sini alır** — bugün **almıyor** ⇒
   *"kazanan biz miyiz"* karşılaştırması yapılamaz. `normHex`'i `D-SS2-3/3` ile aynı fonksiyondan
   üretilir.

🔴 Bu **iki alanın varlığı** `SS2/G32/c` ve `SS2/G32/e2` ayaklarının ön koşuludur: taşınmazsa şart 3
sessizce **daima doğru** olur ve echo elemesi v1'deki gibi **ters çalışır**.""")

# ---------------------------------------------------------------- B2-1 (M172 esdeger)
yama("B2-1 M172",
"""| M172 | birim | `SS2/G32/a` · `D-SS2-2` | `_projeksiyonYaz`'da çakışma kaydı, `write(companion)` çağrısından **SONRA**ya taşınır | `G32/a` **KIRMIZI** — `kaybedenDeger` kazananla eşitlenir |""",
"""| M172 | birim | `SS2/G32/a` · `D-SS2-2` | `kaybedenDeger`, bellekteki `mevcut` nesnesinden **DEĞİL**, `write(companion)` çağrısından **SONRA DB'den YENİDEN OKUNAN** satırdan alınır | `G32/a` **KIRMIZI** — kaybeden değer kazananla **bayt-özdeş** olur ⇒ ekran iki aynı değeri gösterir |""")

# ---------------------------------------------------------------- B2-3 (M171b sifir-bilgi)
yama("B2-3 M171b + M171c",
"""| M171b | statik | `SS2/G31/a` | Kod bozulmaz; dosyaya **yorum satırı** olarak `// schemaVersion => 5` eklenir | `ss2-kapisi.py` **SUSMALI** — yorum-atlama yanlış-pozitif kontrolü |""",
"""| M171b | statik | `SS2/G31/a` | **Gerçek kod satırı** `schemaVersion => 4` yapılır, doğru değer **yalnız yorumda** bırakılır (`// schemaVersion => 5`) | `ss2-kapisi.py` **KIRMIZI** — yorum-atlamanın **yük taşıdığını** ölçer: yorumu koda sayan araç burada **susar** ve yakalanır |
| M171c | statik | `SS2/G31/a` | Kod **bozulmaz**; dosyaya fazladan **yorum satırı** eklenir (`// schemaVersion => 4`) | `ss2-kapisi.py` **SUSMALI** — yanlış-pozitif kontrolü (v2'nin `M171b`'si **buydu** ve tek başına **sıfır-bilgiydi**: gerçek satır korunduğu için yorumu atan da atmayan araç da yeşil dönüyordu — tur 2 `B2-3`) |""")

# ---------------------------------------------------------------- B2-2 (M176 G10'u dusuremez) -- Onur kilitledi
yama("B2-2 M176 + M176b",
"""| M176 | birim | `SS2/G33/c` · `D-SS2-5` | `gorevlerGorunur()` sorgusundaki `count(...)` çağrılarından `distinct: true` silinir | `G33/c` **KIRMIZI** **ve** mevcut `G10` sayım testleri **KIRMIZI** — fan-out gerçek |""",
"""| M176 | **statik** | `SS2/G33/c` · `D-SS2-5` | `gorevlerGorunur()` sorgusundaki `count(...)` çağrılarından `distinct: true` silinir | `ss2-kapisi.py` **KIRMIZI** (desen ayağı). 🔴 *Mevcut `G10` testlerini düşürme şartı **KALDIRILDI** — tur 2 `B2-2`; sınıfı da `birim`→`statik` düzeltildi (tur 2 MINOR).* |
| M176b | birim | `SS2/G33/d` · `D-SS2-5` | **Aynı** mutasyon (`distinct: true` silinir), ama ölçüm **çakışma kaydı DOLU** iken koşar | `G33/d` **KIRMIZI** — `ucusta/bekleyen/zehirli` sayıları fan-out ile **şişer** (D5 sqlite'ta ölçtü: `2 → 4`). `distinct`'in **bugün yük taşıdığını** davranışsal olarak kanıtlayan tek ayak budur |""")

# ---------------------------------------------------------------- G32/e2 ayagi (B2-4'un kapisi)
yama("G32/e2 ayagi",
"""- **f)** *(INSERT dalı)* Yeni entity (`mevcut == null`) ⇒ **0 kayıt** (`D-SS2-2`). → **mutantsız,
  beyanlı**""",
"""- **e2)** *(bayatlamada şart 3)* Kayıt varken **kendi echo'muz** gelir (kazanan `clientHex` =
  cihazın kendi `normHex`'i) ⇒ `kazananDeger` **DEĞİŞMEZ**, `kaybedenDeger` **değişmez**, kayıt sayısı
  **1 kalır**. *Ölçüm:* birim testi — `/e` öncesi ve sonrası iki sütun da **tam dize** eşlenir.
  → `M180b`
- **f)** *(INSERT dalı)* Yeni entity (`mevcut == null`) ⇒ **0 kayıt** (`D-SS2-2`). → **mutantsız,
  beyanlı**""")

# ---------------------------------------------------------------- G33/d ayagi (B2-2'nin kapisi)
yama("G33/d ayagi",
"""- **c)** `gorevlerGorunur()` sorgusundaki **her** `count(...)` çağrısı `distinct: true` taşır.
  *Ölçüm:* `ss2-kapisi.py` — `count(` geçen her satırda `distinct: true` **aranır**; sayı pini
  **YOK** (v1'in pinsiz-sayı kusuru), **desen-başına-koşul** ölçülür. → `M176`""",
"""- **c)** `gorevlerGorunur()` sorgusundaki **her** `count(...)` çağrısı `distinct: true` taşır.
  *Ölçüm:* `ss2-kapisi.py` — `count(` geçen her satırda `distinct: true` **aranır**; sayı pini
  **YOK** (v1'in pinsiz-sayı kusuru), **desen-başına-koşul** ölçülür.
  🔴 **Reçete satır-bazlı DEĞİLDİR [tur 2, MAJOR-10]:** kaynakta `count(` bir satırda, argümanları
  **sonraki** satırdadır (`gorev_deposu.dart:178-186`) ⇒ araç `count(`'un **açılan parantezinden
  kapananına kadar** olan aralığı tarar, tek satırı değil. Satır-bazlı bir araç doğru kodda bile
  KIRMIZI verir. → `M176`
- **d)** 🔴 **FAN-OUT DAVRANIŞSAL AYAĞI [tur 2 `B2-2`; Onur kilitledi, oturum 55]:** **çakışma kaydı
  DOLU** iken (aynı entity için **iki** farklı alanda kayıt) `ucusta`/`bekleyen`/`zehirli` sayıları
  `distinct`'siz duruma göre **şişmez** ve tek kayıtlı duruma **eşit** kalır. *Ölçüm:* birim testi —
  kayıt sayısı 0 → 1 → 2 yapılırken üç sayım da **sabit** ölçülür. Ölçülmüş gerekçe: çakışma satırı
  **0 iken** `distinct`'li ve `distinct`'siz sayımlar **özdeştir** ⇒ `G33/c` tek başına `distinct`'in
  **gerekli** olduğunu kanıtlayamaz, yalnız **yazıldığını** kanıtlar. → `M176b`""")

# ---------------------------------------------------------------- G31/a atif + M180b
yama("G31/a atif",
"""  birden aranır. → `M171`, `M171b`""",
"""  birden aranır. → `M171`, `M171b`, `M171c`""")

yama("M180b mutanti",
"""| M180 | birim | `SS2/G32/e` · `D-SS2-3/e` | Bayatlama dalı silinir (kayıt varsa `kazananDeger` güncellenmez) | `G32/e` **KIRMIZI** — ekran bayat kazanan gösterir |""",
"""| M180 | birim | `SS2/G32/e` · `D-SS2-3/e` | Bayatlama dalı silinir (kayıt varsa `kazananDeger` güncellenmez) | `G32/e` **KIRMIZI** — ekran bayat kazanan gösterir |
| M180b | birim | `SS2/G32/e2` · `D-SS2-3/e` | `/e` dalından **şart 3 elemesi** silinir (v2'nin *"şart 2–4 aranmaksızın"* hâli) | `G32/e2` **KIRMIZI** — kendi echo'muz `kazananDeger`'i kullanıcının **en yeni** yazımıyla ezer ve *Benimkini tut* onu yok eder (tur 2 `B2-4`: **yeni** veri kaybı) |""")

# ---------------------------------------------------------------- kriter 4 (B2-2 + MAJOR-4 aralik)
yama("kriter 4",
"""4. `M171`–`M186` **hepsi ısırır**; `M171b` **susar**. Isırmayan mutant ⇒ **kabul YOK**.
   🔴 `M176` ve `M183`'ün **mevcut `G10` testlerini de** düşürmesi **beklenen** sonuçtur — yalnız
   yeni ayağı düşürüp `G10`'u düşürmüyorlarsa **hedefleri yanlış etiketlenmiştir**.""",
"""4. `M171`–`M188` — **`M171b`, `M171c`, `M176b`, `M178b`, `M180b` DÂHİL** (tur 2 MAJOR-4: v2'nin
   *"`M171`–`M186`"* aralığı `M187`/`M188`'i **dışarıda** bırakıyordu) — **hepsi ısırır**;
   **YALNIZ `M171c` susar** (yanlış-pozitif kontrolü). Isırmayan mutant ⇒ **kabul YOK**.
   🔴 **`M183` için** mevcut `G10` testlerini **de** düşürmek **beklenen** sonuçtur: `g10:153` D4
   kilidini bugün fiilen taşıyor (tur 2 denetiminde doğrulandı).
   🔴 **`M176` İÇİN BU ŞART KALDIRILDI [tur 2 `B2-2`; Onur kilitledi, oturum 55].** Ölçülmüş gerekçe:
   `g10_rozet_kapsami_test.dart`'ın **altı ayağının hiçbiri** çakışma kaydı yazmaz ve **hiçbiri sayım
   ölçmez** (sayım testleri **`g11`**'dedir); çakışma satırı **0 iken** `distinct`'li ve `distinct`'siz
   sayımlar **özdeştir** (D5 sqlite ile ölçtü) ⇒ `M176` mevcut hiçbir testi **hiçbir koşulda**
   düşüremez ve şart, kabulü **kendi kuralıyla** engelliyordu. `distinct`'in yükü artık **`G33/d` +
   `M176b`** ile davranışsal ölçülür.""")

# ---------------------------------------------------------------- T1 (B2-5 + MAJOR-9 sira tuzagi)
yama("T1 sira + g2 pini",
"""| **T1** | `CakismaKayitlari` + `schemaVersion` 4→5 + migration (`D-SS2-1`). `drift_dev`: **dump + generate** (iki ayrı komut). | `flutter test` yeşil |""",
"""| **T1** | `CakismaKayitlari` + `schemaVersion` 4→5 + migration (`D-SS2-1`). 🔴 **SIRA PAZARLIKSIZ [tur 2, MAJOR-9]:** ① `drift_dev schema dump` **`schemaVersion` HÂLÂ 4 iken** koşar ② sonra `=> 5` bump ③ sonra `drift_dev schema generate`. Ters sırada v4 dump'ı **bir daha alınamaz** ve `G31/c` **ölür**. 🔴 **`test/g2_migration_kapisi_test.dart:47-51`'deki `expect(db.schemaVersion, 4)` → `5` GÜNCELLENİR [tur 2, `B2-5`]:** bu **zorunlu** bir düzenlemedir, `T2`'nin *"regresyon yok"* ölçütü bu satırı **hariç tutar** — aksi hâlde builder zorunlu değişikliği regresyon sanar. | `flutter test` yeşil **ve** `g2_migration_kapisi_test` yeşil |""")

# ---------------------------------------------------------------- MAJOR-8: ic ice transaction (Onur kilitledi)
yama("MAJOR-8 dis transaction",
"""- 🔴 **Yazma ÖNCE, silme SONRA, ikisi de AYNI `transaction`** — ters sıra, uygulama arada ölürse
  hem çakışmayı hem yazımı kaybettirir. `M177` ısırır.""",
"""- 🔴 **Yazma ÖNCE, silme SONRA, ikisi de AYNI `transaction`** — ters sıra, uygulama arada ölürse
  hem çakışmayı hem yazımı kaybettirir. `M177` ısırır.
- 🔴 **İÇ İÇE TRANSACTION: DIŞ TRANSACTION AÇILIR [tur 2 MAJOR-8; Onur kilitledi, oturum 55].**
  `cakismaCoz` **kendi** `_db.transaction()`'ını açar; içinden çağrılan `duzenle`/`tamamlaGeriAl`
  kendi `transaction()`'larını (`gorev_deposu.dart:266, 300`) **iç içe** açar. Bu depoda iç içe
  transaction örneği **yoktur** ⇒ **beyan edilmiş sınır (`S11`)**: *drift'in iç içe `transaction()`
  çağrısını savepoint'e indirgediği bu spec'te **ÖLÇÜLMEMİŞTİR**.* `T6` bunu **ölçer ve ham çıktıyı
  `KANIT/SS2/` altına yazar**; indirgemiyorsa builder **durur** ve Onur'a döner — sessizce ikinci
  boynuza (transaction'sız `cakismaCoz`) **geçmez**, çünkü o boynuz `G34/f` kilidini kırar.""")

# ---------------------------------------------------------------- 6d: v2'nin uc kusurunun onarimi
yama("6d bolumu",
"""🔴 **Ders (kanıt dosyasında da yazılı):** *bir dersi alıntılamak, o dersten korunmak değildir.*
v1 `A13`/`M167` dersini metninde taşıyordu ve yine üç kopyasını üretti.""",
"""🔴 **Ders (kanıt dosyasında da yazılı):** *bir dersi alıntılamak, o dersten korunmak değildir.*
v1 `A13`/`M167` dersini metninde taşıyordu ve yine üç kopyasını üretti.

## 6d. v2'NİN ÜÇ KUSURU NASIL ONARILDI (tur 2 denetimi · `KANIT/SS2/02-DENETIM-tur2.md`)

| mutant | v2'de neden ölçmüyordu | v3'te ne değişti |
|---|---|---|
| `M172` | *"kaydı `write(companion)`'ın altına taşı"* — kaybeden değer `_projeksiyonYaz:209`'daki **bellekteki `mevcut`** nesnesinden okunuyor; yazımı aşağı taşımak `mevcut`'u **yeniden okumaz** ⇒ `kaybedenDeger` **bayt-özdeş** kalır. Aynı ders **üçüncü kez** alıntılanıp uygulanmamıştı (`A13/M167` → v1 `M172/M173/M175` → v2 `M172`) | Mutasyonun hedefi **yazım sırası değil OKUMA KAYNAĞI**: `kaybedenDeger` artık yazımdan **sonra DB'den yeniden okunan** satırdan alınır ⇒ kaybeden **gerçekten** kazanana eşitlenir |
| `M171b` | `G31/a` **varlık** araması yapıyor ve mutant gerçek `=> 5` satırını **koruyup** üstüne yorum ekliyordu ⇒ yorumu atan da atmayan araç da **YEŞİL** dönüyordu: **sıfır bilgi** | Mutant **tersine çevrildi** (gerçek satır `=> 4`, doğru değer yalnız yorumda ⇒ **KIRMIZI**) ve yanlış-pozitif kontrolü **`M171c`** olarak **ayrı** mutanta taşındı. İki mutant birlikte yorum-atlamanın **hem yükünü hem sessizliğini** ölçer |
| `M176` | Kriter 4 *"mevcut `G10`'u da düşürmeli"* diyordu; ölçüm bunun **hiçbir koşulda** sağlanamayacağını gösterdi (çakışma satırı 0 iken `distinct`'li/`distinct`'siz sayımlar özdeş; `g10`'un altı ayağı ne çakışma kaydı yazar ne sayım ölçer) ⇒ kriter kabulü **kendi kuralıyla** engelliyordu | `M176` **statik** ayağa (`G33/c`) indirildi ve `G10` şartı kaldırıldı; fan-out'un **yükü** yeni **`G33/d` + `M176b`** ile *çakışma kaydı DOLU iken* davranışsal ölçülür |

🔴 **Bu turun kendi dersi:** bir mutant *"kod değişti"* diye değil, **ölçtüğü sayı değişti** diye
ısırır. `spec-kapi-kapsama.py` *"mutant VAR mı"* sorar, *"mutant ISIRIR mı"* **sormaz** — bu sınıfın
mekanik kapısı **hâlâ yoktur** ve borç `BORCLAR.md`'dedir (`B-SS2-4`).""")

# ---------------------------------------------------------------- S11..S14 beyan edilmis sinirlar
yama("S11-S14",
"""- **S10** — Bu spec ekranın **piksel** düzenini ölçmez; `DESIGN.md` v2 **tüketilir, değiştirilmez**
  (`K46`).""",
"""- **S10** — Bu spec ekranın **piksel** düzenini ölçmez; `DESIGN.md` v2 **tüketilir, değiştirilmez**
  (`K46`).
- **S11** — 🔴 **İÇ İÇE TRANSACTION `[ÖLÇÜLMEDİ]`:** `cakismaCoz`'un dış transaction'ı içinde
  `duzenle`/`tamamlaGeriAl`'ın kendi `transaction()`'larının savepoint'e indirgendiği **bu spec'te
  ölçülmemiştir**; depoda iç içe transaction örneği yoktur. `T6` ölçer ve ham çıktıyı yazar;
  indirgemiyorsa builder **durur** (`D-SS2-6`).
- **S12** — 🔴 **`rozetDikisi` İMZA DEĞİŞİKLİĞİNİN PATLAMA YARIÇAPI `[ÖLÇÜLMEDİ]` [tur 2, MAJOR-6]:**
  doğrudan çağrı yerleri `g11_rozet_turetme_kapisi_test.dart` (14+), `a11y_kapisi_test.dart:119`,
  `g5_karantina_kapisi_test.dart:227`; `T4`'ün regresyon ölçütü yalnız `G10`'a bakıyor, oysa `G10` bu
  fonksiyonu **hiç doğrudan çağırmıyor**. `T4` bu üç dosyayı da **kapsamına alır**.
- **S13** — 🔴 **ZORUNLU `entityId` İKİ MEVCUT TESTİ DERLENEMEZ YAPAR [tur 2, MAJOR-7]:**
  `g16_metin_kaybi_kapisi_test.dart:155,168` ve `sunum_bilesenleri_test.dart:183`. `T5` bunları
  **günceller**; `T2`/`T4`'ün *"regresyon yok"* ölçütü bu üç satırı **hariç tutar** (`B2-5` ile aynı
  sınıf: zorunlu değişikliği regresyon sanma tuzağı).
- **S14** — 🔴 **`G31/c` REÇETESİ `[DOĞRULANMADI]` [tur 2, MAJOR-9]:** `g2`'nin gerçek yolu
  `SchemaVerifier(GeneratedHelper()) + schemaAt(3) + v3.DatabaseAtV3`'tür ve dosya başlığı
  **`NativeDatabase.memory()` YASAK — PAZARLIKSIZ** der; v2 *"bellek DB'si"* yazıp
  `SchemaVerifier`/`GeneratedHelper`/`DatabaseAtV4`'ü **hiç anmıyordu**. `T1` mevcut deseni
  **birebir izler**; sapacaksa gerekçesini `KANIT/SS2/` altına yazar.""")

# ---------------------------------------------------------------- baslik v3
yama("baslik v3",
"""# GOREV-SS2 — ÇAKIŞMA ÇÖZÜM EKRANI (DAR KAPSAM) · **v2**

> **Durum:** 🔓 **KİLİT ADAYI v2** — tasarım Onur tarafından **3 Ağu 2026, oturum 54**'te onaylandı;
> **v1 KİLİTLENEMEDİ.** Üç bağımsız denetçi (K26) **13 bloker + 31 major + 15 minor** buldu ve
> üçü de **aynı kök blokeri** ayrı yollardan bulmuştu.
> **v1 (GEÇERSİZ):** 28.801 b · `90314998` → `KANIT/SS2/01-SPEC-v1-KILITLENEMEDI.md`
> **Denetim çıktısı (K127):** **`KANIT/SS2/00-DENETIM-kilit-oncesi.md`**""",
"""# GOREV-SS2 — ÇAKIŞMA ÇÖZÜM EKRANI (DAR KAPSAM) · **v3**

> **Durum:** 🔒 **KİLİTLİ — Onur kilitledi, 3 Ağu 2026, oturum 55 (`K133`).**
> **Kilit KAPANMAMIŞ SINIRLARLA verildi** (`A13`/`K130`'un emsali): tur 2'nin **beş blokeri
> KAPATILDI**, **13 majoru** `S11`–`S14` + `BORCLAR.md` (`B-SS2-4`…) olarak **borçlandı**.
> **v1 (GEÇERSİZ):** 28.801 b · `90314998` → `KANIT/SS2/01-SPEC-v1-KILITLENEMEDI.md`
> **v2 (GEÇERSİZ):** 34.504 b · `66CC4AAE` → `KANIT/SS2/02-DENETIM-tur2.md`
> 🔴 **BAĞIMSIZ DENETİM ÇIKTI YOLLARI (K127 — zorunlu alan):**
> tur 1 → **`KANIT/SS2/00-DENETIM-kilit-oncesi.md`** (13 bloker) ·
> tur 2 → **`KANIT/SS2/02-DENETIM-tur2.md`** (5 bloker + 13 major).
> 🔴 **ÜÇÜNCÜ DENETİM TURU KOŞULMADI** ve bu **bilinçlidir:** `K53/1` üçüncü kâğıt turunu yasaklar
> (*"ikinci tur ancak birincisi **mimariyi değiştiren** bir bloker bulduysa"* — tur 2 öyle bir bloker
> **bulmadı**; kalan beşi mutant kalitesi ve nokta düzeltmesiydi) ve `K53/4`'ün **`R8` sert durağı**
> oturum 53–54'te **0 satır ürün kodu** ölçtü. v3'ün onarımları **mekanik kapılarla** doğrulandı:
> `spec-kapi-kapsama.py` · `kapi-ad-teklik-kapisi.py` · `dosya-kimlik.py` (çıktılar `KANIT/SS2/`).""")

# ---------------------------------------------------------------- 9. kimlik
yama("9 kimlik",
"""| durum | bayt | sha8 |
|---|---|---|
| v1 — **KİLİTLENEMEDİ** (`KANIT/SS2/01-SPEC-v1-KILITLENEMEDI.md`) | 28.801 | `90314998` |
| v2 — kilit adayı, **ikinci denetimden önce** | *(ölçülecek)* | *(ölçülecek)* |""",
"""| durum | bayt | sha8 |
|---|---|---|
| v1 — **KİLİTLENEMEDİ** (`KANIT/SS2/01-SPEC-v1-KILITLENEMEDI.md`) | 28.801 | `90314998` |
| v2 — **KİLİTLENEMEDİ** (`KANIT/SS2/02-DENETIM-tur2.md`) | 34.504 | `66CC4AAE` |
| **v3 — KİLİTLİ (`K133`)** | 🔴 **BURAYA YAZILMAZ** | 🔴 **`DURUM.md` §9'da ÖLÇÜLÜR** |

🔴 **Geçerli sürümün kimliği bu dosyaya YAZILMAZ.** Ölçülmüş gerekçe: kimlik *son yazımdan sonra*
alınır; onu **bu dosyanın içine** yazmak dosyayı yeniden değiştirir ve yazılan sha'yı **aynı anda
geçersiz kılar** (`kanonik-kopya` kusurunun özyinelemeli hâli — bu projede kimlik tablosunda **üç kez**
ısırdı). Kanonik yer **`DURUM.md` §9**'dur; `A13`'ün (`9C7213F2`) izlediği desenin aynısı.""")


# ================================================================= MOTOR
hata = 0
for ad, eski, yeni in YAMALAR:
    n = metin.count(eski)
    if n != 1:
        print("  [HATA] '%s': eslesme sayisi %d (1 olmali)" % (ad, n))
        hata += 1
    else:
        metin = metin.replace(eski, yeni, 1)
        print("  [OK]   %s" % ad)

if hata:
    print("\nHUKUM: YAMA UYGULANMADI -- %d yama eslesmedi. Dosyaya DOKUNULMADI." % hata)
    sys.exit(2)

yeni_ham = metin.encode("utf-8")          # ONCE encode (K60: encode patlarsa dosya bozulmasin)
if b"\r\n" in yeni_ham:
    print("HUKUM: CRLF girdi -- iptal."); sys.exit(3)
if "�" in metin:
    print("HUKUM: U+FFFD var -- iptal."); sys.exit(4)

tmp  = YOL + ".tmp"
yedk = YOL + ".yedek"
with open(tmp, "wb") as f:
    f.write(yeni_ham)
if os.path.exists(yedk):
    os.remove(yedk)
os.rename(YOL, yedk)                       # ORTAM.md: os.replace bu makinede WinError 5 verir
try:
    os.rename(tmp, YOL)
except Exception as e:
    os.rename(yedk, YOL)                   # geri al
    print("HUKUM: takas patladi, YEDEK GERI ALINDI:", e); sys.exit(5)

with open(YOL, "rb") as f:
    son = f.read()
if son != yeni_ham:
    os.remove(YOL); os.rename(yedk, YOL)
    print("HUKUM: sha uyusmadi, YEDEK GERI ALINDI."); sys.exit(6)
os.remove(yedk)

print("\nCIKTI :", len(son), "bayt · sha8", hashlib.sha256(son).hexdigest()[:8].upper())
print("DELTA :", len(son) - len(ham), "bayt")
print("HUKUM: %d/%d YAMA UYGULANDI -- ATOMIK YAZIM TAMAM." % (len(YAMALAR), len(YAMALAR)))

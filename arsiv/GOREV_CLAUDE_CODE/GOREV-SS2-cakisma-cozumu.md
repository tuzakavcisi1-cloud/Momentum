# GOREV-SS2 — ÇAKIŞMA ÇÖZÜM EKRANI (DAR KAPSAM) · **v3**

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
> `spec-kapi-kapsama.py` · `kapi-ad-teklik-kapisi.py` · `dosya-kimlik.py` (çıktılar `KANIT/SS2/`).
> **Yazan el:** Cowork. **Build eden el:** Claude Code. **Biçim:** K81 + K126 (`hedef` = **3. sütun**).
> **Kapı kimlikleri (K108):** `SS2/G31`–`SS2/G34`; atıf **daima** `SS2/` önekli. Mutantlar `M171`+.

---

## 0. v1 NEDEN DÜŞTÜ — VE v2 NEYİ DEĞİŞTİRİYOR

v1'in kök blokeri **cebirseldi**: koşul
`kazandiMi(gelen, eskiMeta) != kazandiMi(gelen, enBuyuk(eskiMeta, kuyrukTabani))` yazılmıştı.
`enBuyuk(...) >= eskiMeta` ve `kazandiMi` **kesin** büyüklük olduğu için `(false, true)` çifti
**üretilemez** ⇒ koşul **yalnız uzak yazım kaybettiğinde** ateşliyordu ⇒ spec, `Ö4`'te tarif
ettiği veri kaybını **tam da o yönde çözmüyordu**. *(D1: 49.284 üçlü tüketici koşuldu; koşulun
tuttuğu 8.436 vakanın 8.436'sı yanlış yönde.)*

**v2'nin altı yapısal değişikliği** — her biri en az bir blokeri **kökten** kapatır:

| # | v1 | v2 | kapattığı |
|---|---|---|---|
| 1 | Tespit `_kanalUygula`'da, **cebirsel karar-farkı** ile | Tespit **`_projeksiyonYaz`**'da, **bağımsız kuyruk sorgusu** ile | BLOKER-1, 4 · MAJOR-4 |
| 2 | **İki yön** | **TEK yön: yalnız YEREL kaybettiğinde** — K95'in sorduğu şey buydu | BLOKER-1 · MAJOR-20 |
| 3 | Echo elemesi **HLC karar farkına** dayalı (tersi çalışıyordu) | Echo elemesi **`clientHex` karşılaştırması** | BLOKER-2 |
| 4 | `kaybedenDeger` bir yönde tel değeri, diğerinde projeksiyon (`'done'` vs `'true'`) | **İkisi de projeksiyon temsilinde**, tek kanonik dize fonksiyonundan | MAJOR-1 |
| 5 | Çözüm eylemi **yalnız kuyruğa** yazıyordu | Çözüm eylemi **projeksiyonu DA** yazar | BLOKER-6 |
| 6 | `ss2-kapisi.py` zorunlu, üreten adım **yok** | **`T0`: aracı Claude Code yazar**, Cowork koşar ve altın kümesini denetler | BLOKER-7 |

Ayrıca **`fields:isDeleted` kapsamdan ÇIKTI** (`Ö13`) ⇒ **iki kanal** kaldı.
🔴 **Kabul kriteri 8 yeniden kuruldu** — v1'in senaryosu çakışma penceresine **hiç girmiyordu** (`Ö8`).

---

## 1. AMAÇ

Bir görevin **aynı alanı** başka bir cihazda değiştirilmiş ve **bizim bekleyen yazımımız** LWW ile
yenilmişse: sessizce ezilen **yerel değeri saklamak**, kullanıcıya **yan yana** göstermek ve
seçimini **kuyruğa normal bir yazma** olarak geri koymak.

---

## 2. ÖLÇÜLMÜŞ TABAN (oturum 54 · üç bağımsız denetçinin satır satır doğruladığı okuma)

| # | ölçülen gerçek | kaynak |
|---|---|---|
| **Ö1** | Bugünkü `senkronDurumu='cakisma'` bir **LWW çakışması DEĞİLDİR**: üç yazım noktası da *"op sunucuya geçmedi"* der. | `senkron_dongusu.dart:337, 386, 433` |
| **Ö2** | `cakismaVarMi = zehirli > 0 \|\| senkronDurumu == 'cakisma'` — rozet **türetiliyor**. | `gorev_deposu.dart:98` |
| **Ö3** | Reddedilen/zehirli kuyruk satırı **SİLİNMEZ**. | `senkron_dongusu.dart:324-337` |
| **Ö4** | 🔴 **Gerçek LWW çakışmasında hiçbir DEĞER saklanmıyor:** kaybeden kanal `if (!projeksiyonKazandi) return;` ile atılır; `UzakAlanDurumu` yalnız **HLC** tutar. | `uzak_degisiklik_uygulayici.dart:182` · `veritabani.dart:84-95` |
| **Ö5** | 🔴 **v1 BUNU YANLIŞ OKUDU:** eski projeksiyon değeri `_kanalUygula`'da bellekte **DEĞİL**; `_projeksiyonYaz` içinde, döngü bittikten sonra, **entity başına bir kez** okunur. | `uzak_degisiklik_uygulayici.dart:106, 157, 209` |
| **Ö6** | `kuyrukTabaniSaglayici` üretimde **CANLI**. | `senkron_dongusu.dart:75` |
| **Ö7** | `kuyrukEnBuyuk` yalnız **`bekliyor`+`gonderildi`** tarar; `zehirli` dışarıda. | `kuyruk_tabani.dart:71` |
| **Ö8** | 🔴 **İtme turu çakışma penceresini KAPATIR:** `Applied`/`Duplicate` kuyruk satırını `changesUygula`'dan **ÖNCE**, aynı transaction'da siler. | `senkron_dongusu.dart:256-296, 307-309` |
| **Ö9** | `kazandiMi` **kesin** büyüklük ister (echo koruması, D6). | `alan_anahtari.dart:58` |
| **Ö10** | `v3→v4` **salt-ekleme** deseni kanıtlı. | `veritabani.dart:102, 126-134` |
| **Ö11** | `CakismaCozumSayfasi` **yer tutucu**, public, iki sabit taşır. 🔴 `kCakismaGovdesiMaxSatir=6` **tam genişlikte, ortalanmış, TEK `Text`** üzerinde ölçüldü. | `cakisma_rozeti.dart:79-113` |
| **Ö12** | `rozetDikisi` **SAF**tır; rozet sorgusu **TEK sorgu / TEK `watch()`** kilidinde — ikinci stream **YASAK**. | `gorev_deposu.dart:67-70, 168-170, 188-203` |
| **Ö13** | `gorevlerGorunur()` **silinmiş görevi listelemez**; `GorevDeposu`'da **undelete yolu YOK**. | `gorev_deposu.dart:52-65, 197, 312-330` |
| **Ö14** | `GorevDeposu` **enjekte saat** taşır; `UzakDegisiklikUygulayici` **taşımaz**. | `gorev_deposu.dart:143` |
| **Ö15** | `completion` **REPLACE**tir: `status` + `completedAt` **daima birlikte**. | `gorev_deposu.dart:280-296` |

---

## 3. KARARLAR (`D-SS2-1`…`D-SS2-10`)

### D-SS2-1 — DEPOLAMA: `CakismaKayitlari` (salt-ekleme, `schemaVersion` 4 → 5)

```dart
@DataClassName('CakismaKaydiRow')
class CakismaKayitlari extends Table {
  TextColumn get entityId => text()();
  TextColumn get alan => text()();          // 'fields:title' | 'groups:completion' -- BAŞKASI YOK
  TextColumn get kaybedenDeger => text()(); // YEREL değer, ezilmeden ÖNCE -- kanonik dize
  TextColumn get kazananDeger => text()();  // UZAK değer -- AYNI kanonik dize fonksiyonundan
  TextColumn get kazananClientHex => text()();
  DateTimeColumn get olusturuldu => dateTime()();
  @override Set<Column> get primaryKey => {entityId, alan};
}
```

- **PK `(entityId, alan)` ⇒ alan başına TEK kayıt** — çakışma geçmişi `K95`'te kapsam dışı.
- `entityType` **YOK**: bu dilimde tek entity türü (`task`) vardır ve sütun hiçbir yerde
  okunmayacaktı ⇒ **ölü sütun yazılmaz** (v1'in `olusturuldu` dışındaki dört ölü sütunu budandı).
- 🔴 **`kaybedenDeger` ve `kazananDeger` NULL OLAMAZ** ve **aynı** `kanonikDize()` fonksiyonundan
  geçer (`D-SS2-4`) — v1'de biri tel değeri biri projeksiyondu ve `'done'` ile `'true'`
  karşılaştırılıyordu.
- Migration: `if (from < 5) { await m.createTable(cakismaKayitlari); }` — `Gorevler`'e
  **DOKUNULMAZ**, `alterTable` **çağrılmaz** (`Ö10`).
- `olusturuldu` **enjekte saatten** gelir (`D-SS2-9`), `DateTime.now()` **yasak**.

### D-SS2-2 — TESPİT NOKTASI: `_projeksiyonYaz`'ın **UPDATE dalı** (INSERT dalı DEĞİL)

Gerekçe (`Ö5`): `mevcut` satır orada **zaten okunuyor** (`:209`) ⇒ ekstra `SELECT` yok, erken
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
sessizce **daima doğru** olur ve echo elemesi v1'deki gibi **ters çalışır**.

### D-SS2-3 — ÇAKIŞMA TANIMI (PAZARLIKSIZ · dört şart, hepsi AND)

Kanal `k ∈ {fields:title, groups:completion}` için, UPDATE dalında yazımdan **ÖNCE**:

1. **Kanal bu partide kazandı** — `g`'nin ilgili alanı `null` değil (yani uzak yazım projeksiyonu
   değiştirecek).
2. **Bu entity için kuyrukta BEKLEYEN yerel yazım var** — `kuyrukEnBuyuk(db, entityId, k) != null`
   (`Ö7`: `bekliyor`+`gonderildi`; `zehirli` **dışarıda**).
3. **Kazanan BİZ DEĞİLİZ** — kazanan anahtarın `clientHex` değeri **cihazın kendi `clientId`'sinin
   `normHex`'i değil**. 🔴 v1'in echo elemesi **tersi çalışıyordu**; bu şart onu doğrudan öldürür.
4. **Değerler farklı** — `kanonikDize(mevcutYerel) != kanonikDize(yeniUzak)` (ordinal, tam dize).

Dördü de sağlanırsa: `kaybedenDeger = kanonikDize(mevcutYerel)`,
`kazananDeger = kanonikDize(yeniUzak)`, `kazananClientHex = <kazananın clientHex'i>`.

🔴 **BAYATLAMA KURALI (`/e`):** o `(entityId, alan)` için **kayıt zaten VARSA**, şart **2 ve 4**
aranmaksızın — **ama şart 3 ARANARAK** — **`kazananDeger` ve `kazananClientHex` GÜNCELLENİR**,
`kaybedenDeger` **korunur**.

🔴 **ŞART 3 `/e`'DE DE ARANIR — PAZARLIKSIZ [tur 2 denetimi `B2-4`; `KANIT/SS2/02-DENETIM-tur2.md`].**
v2 *"şart 2–4 aranmaksızın"* yazmıştı ve bu **YENİ bir veri kaybı** doğuruyordu (ölçülmüş senaryo):
kayıt varken kullanıcı yerel `C` düzenlemesi yapar → itilir → **kendi echo'su** döner (`Ö8` gereği op
`changesUygula`'dan **önce** silinmiştir ⇒ echo projeksiyonu kazanır) ⇒ şart 1 sağlanır ⇒ `/e` ateşler
ve `kazananDeger = C` yazılır. Ekran *"Benimki: `B1` / Onlarınki: `C`"* gösterir; **`C` kullanıcının
KENDİ EN YENİ yazımıdır** ve *Benimkini tut* onu **yok eder**. Şart 3 (*kazanan biz değiliz*) `/e`'de
de arandığında echo turu `/e`'yi **hiç ateşlemez**. → `SS2/G32/e2`, mutant `M180b`.
Gerekçe ölçülmüş bir kusurdur: aksi hâlde kullanıcı listede `C`, çakışma ekranında `B` görür ve
*Benimkini tut* ile **iki kuşak eski** bir değeri diriltir (denetim MAJOR-12).

### D-SS2-4 — `kanonikDize()`: TEK TEMSİL ALANI (PAZARLIKSIZ)

```
fields:title       -> baslik (String) OLDUĞU GİBİ
groups:completion  -> tamamlandi ? 'tamamlandi' : 'acik'
```

🔴 Hem kaybeden hem kazanan **bu fonksiyondan** geçer. v1'de gelen değer tel temsilindeydi
(`'done'`/`'true'`), projeksiyon ise `bool`du ⇒ eşitlik elemesi **hiç tetiklenmiyordu** ve ekran
kullanıcıya `"true"` gösteriyordu (denetim MAJOR-1).
**Ekranda gösterilen metin bu dize DEĞİLDİR** — `Metinler`'den gelen yerelleştirilmiş etiket
kullanılır (`D-SS2-8`); dize yalnız **karşılaştırma ve depolama** birimidir.

### D-SS2-5 — ROZET: ÜÇÜNCÜ KANAL, **TEK SORGUDA**, `distinct` ZORUNLU

`gorevlerGorunur()` sorgusuna `leftOuterJoin(cakismaKayitlari, cakismaKayitlari.entityId.equalsExp(gorevler.id))`
eklenir ve `rozetDikisi` üçüncü kanalı okur:
`cakismaVarMi = zehirli > 0 || senkronDurumu == 'cakisma' || cakismaKaydiSayisi > 0`.

🔴 **PAZARLIKSIZ:** ikinci join entity başına **birden çok satır** üretir (`PK` alan bazlı) ⇒
**mevcut `count(opId)` sayımlarının HEPSİ `distinct: true` olmak zorundadır**, yoksa
`ucusta/bekleyen/zehirli` sayıları **şişer** ve `A11`/`R10`'un kabul edilmiş `G10` rozet testleri
kırılır (denetim MAJOR-3). `M176` bunu ısırır.
🔴 `Ö12`'nin **TEK sorgu / TEK `watch()`** kilidi **aynen durur** — ikinci stream + `combineLatest`
**YASAK**. `rozetDikisi` **SAF** kalır: sayıyı parametre olarak alır, DB'ye dokunmaz.

### D-SS2-6 — ÇÖZÜM EYLEMİ: `GorevDeposu.cakismaCoz(entityId, secim)`

**Sahibi `GorevDeposu`dur** (v1'de tanımsızdı — denetim MAJOR-11). Gerekçe: `duzenle`/
`tamamlaGeriAl` orada, transaction disiplini orada, **enjekte saat** orada (`Ö14`).

| `secim` | davranış |
|---|---|
| `benimkiniTut` | Her kayıt için `kaybedenDeger`, **mevcut yerel-yazma akışıyla** uygulanır: `fields:title` ⇒ `duzenle`, `groups:completion` ⇒ `tamamlaGeriAl`. **Bu akış projeksiyonu DA yazar** (`gorev_deposu.dart:266-275`). Sonra kayıtlar silinir. |
| `onlarinkiniAl` | Yazma **YOK** (projeksiyon zaten uzağın değerini taşıyor); yalnız kayıtlar silinir. |

- 🔴 **Yazma ÖNCE, silme SONRA, ikisi de AYNI `transaction`** — ters sıra, uygulama arada ölürse
  hem çakışmayı hem yazımı kaybettirir. `M177` ısırır.
- 🔴 **İÇ İÇE TRANSACTION: DIŞ TRANSACTION AÇILIR [tur 2 MAJOR-8; Onur kilitledi, oturum 55].**
  `cakismaCoz` **kendi** `_db.transaction()`'ını açar; içinden çağrılan `duzenle`/`tamamlaGeriAl`
  kendi `transaction()`'larını (`gorev_deposu.dart:266, 300`) **iç içe** açar. Bu depoda iç içe
  transaction örneği **yoktur** ⇒ **beyan edilmiş sınır (`S11`)**: *drift'in iç içe `transaction()`
  çağrısını savepoint'e indirgediği bu spec'te **ÖLÇÜLMEMİŞTİR**.* `T6` bunu **ölçer ve ham çıktıyı
  `KANIT/SS2/` altına yazar**; indirgemiyorsa builder **durur** ve Onur'a döner — sessizce ikinci
  boynuza (transaction'sız `cakismaCoz`) **geçmez**, çünkü o boynuz `G34/f` kilidini kırar.
- 🔴 **Projeksiyon yazımı atlanamaz:** v1 yalnız kuyruğa yazıyordu ⇒ kullanıcı butona basıyor,
  listede hiçbir şey değişmiyor, rozet kayboluyordu (denetim BLOKER-6). `M179` ısırır.
- Karar **entity başınadır**: ekrandaki tek buton o entity'nin **tüm** kayıtlarına uygulanır.
- `groups:completion` için `tamamlaGeriAl` `completedAt`'i **kendi enjekte saatinden** yeniden
  üretir (`Ö15`, REPLACE kilidi) — uzağın `completedAt`'i **korunmaz**. **Beyan: `S3`.**

### D-SS2-7 — ESKİ `cakisma` KANALI **DOKUNULMAZ**

`Ö1`'in üç yazım noktası olduğu gibi kalır. `SS2` **üçüncü bir rozet kaynağı** ekler, dördüncü bir
kanal **eklemez**. Rozet **iki farklı olayı** aynı ikonla gösterir; ayrıştırma **borçtur** (`S5`).

### D-SS2-8 — EKRAN: `CakismaCozumSayfasi(entityId)` — DOLDURULUR

- Sayfa **`entityId` alır**; `CakismaRozeti` de `entityId` alır ve geçirir. 🔴 İkisinin de bugünkü
  `const` kurucuları ve çağrı yerleri (`gorev_satiri.dart`) **değişir** (denetim MINOR-5).
- Kayıtlar üzerinde **döngü**: her çakışan alan için yerel ↔ uzak **yan yana**, alan adı vurgulu.
  İki buton **listenin altında, tümüne** uygulanır.
- 🔴 **BOŞ DURUM ZORUNLU:** rozet eski kanaldan gelmiş olabilir (`D-SS2-7`) ⇒ **0 kayıtla** açılış
  **normal** hâldir. Ekran o zaman `Metinler.cakismaKaydiYok` gösterir ve **butonlar görünmez**.
  v1 bunu tanımsız bırakmıştı (denetim MAJOR-14).
- 🔴 **`kCakismaGovdesiMaxSatir` YENİDEN ÖLÇÜLÜR (`T5`), "korunur" DENMEZ:** `6` sabiti *tam
  genişlikte, ortalanmış, TEK `Text`* üzerinde ölçülmüştü (`Ö11`); yan yana / yarım genişlik
  **başka bir ölçümdür**. Sabiti taşımak bayat bir sayıyı kilit sanmaktır (denetim MAJOR-13).
  `kCakismaBasligiMaxSatir = 1` 🔒 **sabit kalır** (`AppBar` kelepçesi, ölçülmez).
- A11Y: iki buton **48 dp** + `Semantics(button: true)` + **ayrı** etiketler.

### D-SS2-9 — SAAT DİKİŞİ

`UzakDegisiklikUygulayici` **enjekte saat alır** (`DateTime Function() saat`, varsayılan
`() => DateTime.now().toUtc()`); `olusturuldu` **ondan** yazılır. `DateTime.now()`'ın doğrudan
çağrılması **yasaktır** — `GorevDeposu`'nun disiplininin aynısı (`Ö14`).

### D-SS2-10 — KAPSAM DIŞI

Alan-bazlı birleştirme · üç-yollu merge · **çakışma geçmişi** · toplu çözüm · kimlik ·
**`fields:isDeleted`** (`Ö13`) · **ters yön** (uzak kaybettiğinde kayıt — `S2`).
🔴 Ekranın alanları yan yana göstermesi *alan-bazlı birleştirme* **değildir**: kayıt alan bazlıdır,
**karar entity başınadır**.

### D-SS2-11 — ÇAKIŞMA PENCERESİ: TABAN, TURUN **BAŞINDA** ANLIK GÖRÜNTÜ OLARAK ALINIR

🔴 **Bu karar `Ö8`'in doğrudan sonucudur ve v1'de YOKTU** — denetim onsuz kabul kriteri 8'in
**hiç tetiklenmeyeceğini** ölçtü (BLOKER-5).

`/v1/sync` **tek çağrıda** hem iter hem çeker; `_tekSonucIsle` `Applied`/`Duplicate` satırını
`changesUygula`'dan **önce siler** ⇒ değişiklikler uygulanırken kuyruk **boştur** ⇒ canlı
`kuyrukEnBuyuk` sorgusu **daima `null`** döner ve çakışma **hiç görülmez**.

**Çözüm:** `UzakDegisiklikUygulayici` yeni bir sağlayıcı alır:

```dart
final Future<bool> Function(String entityId, String alan) bekleyenYerelYazimVarMi;
```

`SenkronDongusu` bunu **turun BAŞINDA**, itme yanıtı işlenmeden **önce** alınan anlık
görüntüden cevaplar: *o turda gönderilen oplar* **∪** *hâlâ `bekliyor` olanlar*
(`zehirli` **hariç**, `Ö7` ile aynı sınır). Anlık görüntü tur bitince atılır.
Varsayılan (test/T3 aşaması): `(_, _) async => false` ⇒ **çakışma yok** — sessiz yanlış-pozitif
üretmez.

🔴 **`kuyrukTabaniSaglayici` (D5) DEĞİŞMEZ** — o LWW kararının parçasıdır ve `A11`'in kabul
edilmiş kapılarına bağlıdır. Bu **ayrı** bir sağlayıcıdır; ikisi karıştırılamaz.

---

## 4. YAPILACAKLAR (sıra PAZARLIKSIZ — K53/5 + K44-a)

| adım | iş | biter göstergesi |
|---|---|---|
| **T0** | 🔴 **`araclar/ss2-kapisi.py` YAZILIR (Claude Code)** — `SS2/G31/a,b` ve `SS2/G33/c` statik ayaklarını ölçer; **kendi altın kümesini** taşır. **K44-a: önce araç, sonra belge.** K26: aracı **builder yazar**, **Cowork koşar ve altın kümesini denetler**. | `--altin-kume` **EXIT 0** |
| **T1** | `CakismaKayitlari` + `schemaVersion` 4→5 + migration (`D-SS2-1`). 🔴 **SIRA PAZARLIKSIZ [tur 2, MAJOR-9]:** ① `drift_dev schema dump` **`schemaVersion` HÂLÂ 4 iken** koşar ② sonra `=> 5` bump ③ sonra `drift_dev schema generate`. Ters sırada v4 dump'ı **bir daha alınamaz** ve `G31/c` **ölür**. 🔴 **`test/g2_migration_kapisi_test.dart:47-51`'deki `expect(db.schemaVersion, 4)` → `5` GÜNCELLENİR [tur 2, `B2-5`]:** bu **zorunlu** bir düzenlemedir, `T2`'nin *"regresyon yok"* ölçütü bu satırı **hariç tutar** — aksi hâlde builder zorunlu değişikliği regresyon sanar. | `flutter test` yeşil **ve** `g2_migration_kapisi_test` yeşil |
| **T2** | `bekleyenYerelYazimVarMi` sağlayıcısı + `SenkronDongusu`'nda **tur-başı anlık görüntü** (`D-SS2-11`). | mevcut `G3`/`G5`/`G10` testleri **hâlâ yeşil** |
| **T3** | `kanonikDize()` (`D-SS2-4`) + `_projeksiyonYaz` UPDATE dalında tespit ve yazım (`D-SS2-2`, `D-SS2-3` dört şart + bayatlama) + **enjekte saat** (`D-SS2-9`). | `SS2/G32` yeşil |
| **T4** | `gorevlerGorunur()`'a ikinci join + **tüm sayımlara `distinct: true`** + `rozetDikisi` üçüncü kanal (`D-SS2-5`). | `SS2/G33` yeşil · **`G10` testleri hâlâ yeşil** |
| **T5** | `CakismaCozumSayfasi(entityId)` + `CakismaRozeti(entityId)` + çağrı yerleri + **boş durum** + `kCakismaGovdesiMaxSatir`'ın **YENİDEN ÖLÇÜMÜ** (`D-SS2-8`). | `SS2/G34/a,b,c,g,h` yeşil |
| **T6** | `GorevDeposu.cakismaCoz` (`D-SS2-6`) — projeksiyon **ve** kuyruk, tek transaction, yazma önce. | `SS2/G34/d,e,f` yeşil |
| **T7** | `M171`–`M186` koşulur; her biri **ısırdığını** kanıtlar, `M171b` **susar**. | §6 tablosunun tamamı ölçüldü |
| **T8** | `KANIT/SS2/` altına ham çıktılar; `spec-kapi-kapsama.py` **bu spec'in yoluyla** koşulur. | `[S0]/[S1]/[S2]` yok |

🔴 **`T0` ürün kodu SAYILMAZ (K53/4).** Ürün kodu `T1`'de başlar; `R8` bu dilimde **canlıdır**
(oturum 53 = 0 satır, oturum 54 = 0 satır **ölçüldü**).

---

## 5. KAPILAR

> Her ayak **nasıl ölçüldüğünü** yazar; yazmayan ayak **kördür**. Mutantı olmayan her ayak
> `## 6b`'de **gerekçesiyle** beyan edilir (v1'de 21 ayağın 12'si sessizce mutantsızdı).

### G31 — DEPOLAMA VE MİGRATION SALT-EKLEME

- **a)** `schemaVersion => 5` **ve** `@DriftDatabase(tables:[…])` listesinde `CakismaKayitlari`
  **var**. *Ölçüm:* `ss2-kapisi.py` — **kod satırında** (yorum satırları **atılarak**) iki desen
  birden aranır. → `M171`, `M171b`, `M171c`
- **b)** `onUpgrade`'in `from < 5` bloğu **yalnız `createTable`** çağırır; o bloğun **metin
  aralığında** `alterTable(` ve `gorevler` **geçmez**. *Ölçüm:* `ss2-kapisi.py`, blok-aralığı
  araması (dosya geneli `from < 2`'deki **meşru** `alterTable`'ı yakalar ⇒ yanlış-pozitif). → `M181`
- **c)** v4 verisi v5'e yükseltilince `gorevler` satırları **korunur**. *Ölçüm:* `drift_dev schema
  dump/generate` ile üretilen **v4 fikstürü** üzerinden migration testi (tek `Veritabani` sınıfıyla
  koşulamaz — `schemaVersion` sabit getter'dır). → **mutantsız, `## 6b`'de beyanlı**

### G32 — TESPİT: DOĞRU DURUMDA YAZAR, DÖRT ŞARTIN HER BİRİ AYRI ELER

Altı ayak da `select(cakismaKayitlari).get().length` ile **sayı olarak** ölçülür.

- **a)** *(pozitif)* Dört şart sağlanır ⇒ **1 kayıt**; `kaybedenDeger` = **ezilmeden önceki yerel
  değer**, `kazananDeger` = uzak değer, `kazananClientHex` = uzağın client'ı. → `M172`
- **b)** *(şart 2)* Kuyrukta bekleyen yerel yazım **yok** ⇒ **0 kayıt**. → `M173`
- **c)** *(şart 3)* Kazanan **bizim `clientId`'miz** (echo) ⇒ **0 kayıt**. → `M175`
- **d)** *(şart 4)* `kanonikDize` değerleri **aynı** ⇒ **0 kayıt**. → `M174`
- **e)** *(bayatlama, `/e`)* Kayıt varken aynı alana **çakışmasız** uzak yazım gelir ⇒ kayıt sayısı
  **1 kalır**, `kazananDeger` **güncellenir**, `kaybedenDeger` **DEĞİŞMEZ**. → `M180`
- **e2)** *(bayatlamada şart 3)* Kayıt varken **kendi echo'muz** gelir (kazanan `clientHex` =
  cihazın kendi `normHex`'i) ⇒ `kazananDeger` **DEĞİŞMEZ**, `kaybedenDeger` **değişmez**, kayıt sayısı
  **1 kalır**. *Ölçüm:* birim testi — `/e` öncesi ve sonrası iki sütun da **tam dize** eşlenir.
  → `M180b`
- **f)** *(INSERT dalı)* Yeni entity (`mevcut == null`) ⇒ **0 kayıt** (`D-SS2-2`). → **mutantsız,
  beyanlı**
- **g)** *(saat dikişi)* `olusturuldu`, **enjekte saatin** döndürdüğü sabit değere **birebir
  eşittir** (`DateTime.now()` çağrılmamıştır). *Ölçüm:* birim testi — sabit saat enjekte edilir,
  DB'den okunan sütun **dize olarak** karşılaştırılır. → `M188`
- **h)** *(kanonik temsil)* `kaybedenDeger` **ve** `kazananDeger` **aynı** `kanonikDize()`
  çıktısıdır: `groups:completion` çakışmasında ikisi de `'tamamlandi'`/`'acik'` alanındadır,
  **hiçbiri** ham tel değeri (`'done'`) ya da `'true'` **değildir**. *Ölçüm:* birim testi — iki
  sütun da beklenen kümeye karşı **tam dize** eşlenir. → `M187`

### G33 — ROZET: TÜRETİLİR, YAZILMAZ, SAYIMLAR ŞİŞMEZ

- **a)** Çakışma kaydı olan görevde `GorevGorunum.cakismaVarMi == true`; kayıt silinince `false`.
  *Ölçüm:* **`gorevlerGorunur()` akışı üzerinden** (saf `rozetDikisi` değil — v1'in kör noktası
  buydu). → `M182`
- **b)** 🔴 `_projeksiyonYaz`'ın **UPDATE dalı** `senkronDurumu`'na **yazmaz** (D4 kilidi):
  çakışma kaydı yazıldıktan sonra görevin `senkronDurumu` sütunu **yazımdan önceki değeriyle
  birebir aynıdır**. *Ölçüm:* aynı testte önce/sonra dize karşılaştırması. → `M183`
- **c)** `gorevlerGorunur()` sorgusundaki **her** `count(...)` çağrısı `distinct: true` taşır.
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
  **gerekli** olduğunu kanıtlayamaz, yalnız **yazıldığını** kanıtlar. → `M176b`

### G34 — EKRAN VE ÇÖZÜM EYLEMİ

- **a)** `CakismaCozumSayfasi` **ve** `CakismaRozeti` `entityId` alır; `gorev_satiri.dart` onu
  geçirir. *Ölçüm:* statik — parametresiz kurucular kaynakta **kalmamıştır**. → `M184`
- **b)** Çakışan alanın **iki değeri de** ekranda. *Ölçüm:* widget testi — `find.text` **ve**
  ayrıca ilgili `Text` düğümlerinde `didExceedMaxLines == false`. → `M178`
- **c)** İki buton **48 dp** + `Semantics(button: true)` + **ayrı** etiket. → `M178b`
- **d)** *Benimkini tut* ⇒ kuyruğa **1 yeni op** (yeni `opId`, HLC **kazananın anahtarından
  büyük**) **VE** `Gorevler` projeksiyonu `kaybedenDeger`'e döner. *Ölçüm:* kuyruk sayısı +
  `AlanAnahtari.compareTo(kazananAnahtar) > 0` + projeksiyon dize karşılaştırması. → `M179`
- **e)** *Onlarınkini al* ⇒ kuyruğa **yeni op GİRMEZ**, projeksiyon **değişmez**, kayıtlar silinir.
  → `M185`
- **f)** Yazma **önce**, silme **sonra**, ikisi de **aynı transaction**. *Ölçüm:* `GorevDeposu`'na
  enjekte edilen gözlemci `Veritabani` sarmalayıcısıyla çağrı sırası + transaction sınırı. → `M177`
- **g)** **Boş durum:** 0 kayıtla açılışta `Metinler.cakismaKaydiYok` görünür ve **butonlar
  görünmez**. → `M186`
- **h)** Metin düğümleri taşmaz; `kCakismaGovdesiMaxSatir` **bu düzende yeniden ölçülmüş** N'dir
  ve ölçüm çıktısı `KANIT/SS2/` altındadır. → **mutantsız, beyanlı**

---

## 6. MUTANTLAR

**Maliyet sınıfı (K53/3):** **koşan uygulama** isteyen mutant **YOKTUR** ⇒ tavan (3) kullanılmaz.
Hepsi *statik* / *birim testi* / *widget testi* — **tavansız**.
🔴 **Sütun düzeni PAZARLIKSIZ: `hedef` ÜÇÜNCÜ SÜTUNDUR** (K126, `hucreler[2]`).
🔴 **Her mutant, hedeflediği ayağın `beklenen` sütununda ADIYLA geçen bir ölçümü düşürür.**
v1'de üç mutant (`M172`/`M173`/`M175`) **eşdeğerdi**; v2'de üçü de **yeniden kuruldu** ve gerekçesi
`## 6c`'de yazılıdır.

| mutant | sınıf | hedef | ne bozulur | beklenen |
|---|---|---|---|---|
| M171 | statik | `SS2/G31/a` · `D-SS2-1` | `veritabani.dart`'ta `schemaVersion => 5` → `=> 4` (tablo tanımı KALIR) | `ss2-kapisi.py` **KIRMIZI** |
| M171b | statik | `SS2/G31/a` | **Gerçek kod satırı** `schemaVersion => 4` yapılır, doğru değer **yalnız yorumda** bırakılır (`// schemaVersion => 5`) | `ss2-kapisi.py` **KIRMIZI** — yorum-atlamanın **yük taşıdığını** ölçer: yorumu koda sayan araç burada **susar** ve yakalanır |
| M171c | statik | `SS2/G31/a` | Kod **bozulmaz**; dosyaya fazladan **yorum satırı** eklenir (`// schemaVersion => 4`) | `ss2-kapisi.py` **SUSMALI** — yanlış-pozitif kontrolü (v2'nin `M171b`'si **buydu** ve tek başına **sıfır-bilgiydi**: gerçek satır korunduğu için yorumu atan da atmayan araç da yeşil dönüyordu — tur 2 `B2-3`) |
| M181 | statik | `SS2/G31/b` · `D-SS2-1` | `from < 5` bloğuna `await m.alterTable(TableMigration(gorevler));` eklenir | `ss2-kapisi.py` **KIRMIZI** |
| M172 | birim | `SS2/G32/a` · `D-SS2-2` | `kaybedenDeger`, bellekteki `mevcut` nesnesinden **DEĞİL**, `write(companion)` çağrısından **SONRA DB'den YENİDEN OKUNAN** satırdan alınır | `G32/a` **KIRMIZI** — kaybeden değer kazananla **bayt-özdeş** olur ⇒ ekran iki aynı değeri gösterir |
| M173 | birim | `SS2/G32/b` · `D-SS2-3/2` | `bekleyenYerelYazimVarMi` şartı koşuldan silinir | `G32/b` **KIRMIZI** — kuyruk boşken kayıt üretilir |
| M175 | birim | `SS2/G32/c` · `D-SS2-3/3` | `clientHex` echo elemesi silinir | `G32/c` **KIRMIZI** — kendi echo'muz kayıt üretir |
| M174 | birim | `SS2/G32/d` · `D-SS2-3/4` | `kanonikDize` eşitlik elemesi silinir | `G32/d` **KIRMIZI** |
| M180 | birim | `SS2/G32/e` · `D-SS2-3/e` | Bayatlama dalı silinir (kayıt varsa `kazananDeger` güncellenmez) | `G32/e` **KIRMIZI** — ekran bayat kazanan gösterir |
| M180b | birim | `SS2/G32/e2` · `D-SS2-3/e` | `/e` dalından **şart 3 elemesi** silinir (v2'nin *"şart 2–4 aranmaksızın"* hâli) | `G32/e2` **KIRMIZI** — kendi echo'muz `kazananDeger`'i kullanıcının **en yeni** yazımıyla ezer ve *Benimkini tut* onu yok eder (tur 2 `B2-4`: **yeni** veri kaybı) |
| M182 | birim | `SS2/G33/a` · `D-SS2-5` | `rozetDikisi`'nden üçüncü kanal (`cakismaKaydiSayisi > 0`) silinir | `G33/a` **KIRMIZI** |
| M183 | birim | `SS2/G33/b` · `D-SS2-5` | `_projeksiyonYaz`'ın **UPDATE** dalına `senkronDurumu: Value('cakisma')` eklenir | `G33/b` **KIRMIZI** **ve** mevcut `G10` rozet testleri **KIRMIZI** — D4 kilidinin bugün yük taşıdığını ölçer |
| M176 | **statik** | `SS2/G33/c` · `D-SS2-5` | `gorevlerGorunur()` sorgusundaki `count(...)` çağrılarından `distinct: true` silinir | `ss2-kapisi.py` **KIRMIZI** (desen ayağı). 🔴 *Mevcut `G10` testlerini düşürme şartı **KALDIRILDI** — tur 2 `B2-2`; sınıfı da `birim`→`statik` düzeltildi (tur 2 MINOR).* |
| M176b | birim | `SS2/G33/d` · `D-SS2-5` | **Aynı** mutasyon (`distinct: true` silinir), ama ölçüm **çakışma kaydı DOLU** iken koşar | `G33/d` **KIRMIZI** — `ucusta/bekleyen/zehirli` sayıları fan-out ile **şişer** (D5 sqlite'ta ölçtü: `2 → 4`). `distinct`'in **bugün yük taşıdığını** davranışsal olarak kanıtlayan tek ayak budur |
| M184 | statik | `SS2/G34/a` · `D-SS2-8` | `CakismaRozeti`'nin `entityId` parametresi kaldırılır, `const` kurucu geri konur | `ss2-kapisi.py` **KIRMIZI** (derleme de kırılır — **ikisi de beklenir**) |
| M178 | widget | `SS2/G34/b` · `D-SS2-8` | Ekrandan **uzak sürüm** metin düğümü silinir | `G34/b` **KIRMIZI** |
| M178b | widget | `SS2/G34/c` | İki butonun `Semantics` etiketi **aynı** dizeye çevrilir | `G34/c` **KIRMIZI** |
| M179 | birim | `SS2/G34/d` · `D-SS2-6` | `cakismaCoz`'da *Benimkini tut* dalı **yalnız kuyruğa** yazar (projeksiyon yazımı atlanır) | `G34/d` **KIRMIZI** — v1'in BLOKER-6'sının mutantı |
| M185 | birim | `SS2/G34/e` · `D-SS2-6` | *Onlarınkini al* dalı da kuyruğa yazma yapar | `G34/e` **KIRMIZI** |
| M177 | birim | `SS2/G34/f` · `D-SS2-6` | Çözüm eyleminde **önce silme, sonra yazma** (sıra ters) | `G34/f` **KIRMIZI** |
| M186 | widget | `SS2/G34/g` · `D-SS2-8` | Boş durumda butonlar **görünür** bırakılır | `G34/g` **KIRMIZI** |
| M187 | birim | `SS2/G32/h` · `D-SS2-4` | `kanonikDize()`'nin `groups:completion` dalı **ham tel değerini** (`'done'`/`null`) döndürür — kaybeden projeksiyondan, kazanan telden gelir | `G32/h` **KIRMIZI** **ve** `G32/d` **KIRMIZI** — bu, v1'in MAJOR-1 kusurunun ta kendisidir: iki farklı temsil alanı karşılaştırılınca eşitlik elemesi **hiç tetiklenmez** |
| M188 | birim | `SS2/G32/g` · `D-SS2-9` | `olusturuldu`, enjekte saat yerine `DateTime.now().toUtc()` ile yazılır | `G32/g` **KIRMIZI** — sabit saatle koşan test determinizmi kaybeder |

## 6b. MUTANT BORCU

> Biçim **pazarlıksız** (`spec-kapi-kapsama.py`/`borclar()`): satır başında
> `- KURAL: <ad> | GEREKCE: <en az 20 karakter>`. **Tablo OKUNMAZ.** **KAPI borçlanamaz.**

- KURAL: D-SS2-7 | GEREKCE: Bu bir DEGISMEZLIK kuralidir (eski `cakisma` kanali dokunulmaz). Mutanti "kanali sil" olurdu; o mutant A11'in KABUL EDILMIS testlerini dusururdu, yani olctugu sey SS2 degil A11 olurdu -- hedefi yanlis etiketlenmis mutant (A13/M167 dersi). Kapanis yolu: A11'in testleri bu kanali ZATEN pinliyor; SS2 onlara dokunmadigini T2/T4'un regresyon olcumuyle gosterir.
- KURAL: D-SS2-10 | GEREKCE: Bu bir YAPMAMA kararidir (alan-bazli birlestirme, uc-yollu merge, cakisma gecmisi, toplu cozum, kimlik, fields:isDeleted ve TERS YON kapsam disi) ve bir yapmama kararinin mutanti yoktur: olmayan is bozulamaz. Kapanis yolu: bu ozelliklerden biri kapsama girerse KENDI mutantiyla girer.
- KURAL: D-SS2-11 | GEREKCE: Tur-basi anlik goruntunun mutanti "canli kuyruk sorgusuna geri don" olurdu; bu mutant KOSAN CIHAZ ister (itme+cekme ayni /v1/sync cagrisinda olmali) ve K53/3'un kosan-uygulama tavanini bu dilimde SIFIRDAN acardi. Kapanis yolu: kabul kriteri 8 bu kurali UCTAN UCA olcer -- anlik goruntu olmazsa kriter 8 SIFIR kayit uretir ve DUSER; yani kural mutantsiz degil, KABUL KRITERIYLE olculur.

🔴 **MUTANTSIZ KAPI AYAKLARI (üçü de, gerekçesiyle — v1'de 12 ayak sessizce mutantsızdı):**
`SS2/G31/c` — mutantı `drift_dev` şema fikstürünü bozmak olurdu; fikstür **üretilmiş** dosyadır,
elle bozmak aracın kendisini test eder, migration'ı değil.
`SS2/G32/f` — `_projeksiyonYaz`'ın INSERT dalında ezilecek yerel değer **yoktur**; mutantı
*"INSERT dalına da kayıt yaz"* olurdu ve o dal `mevcut == null` olduğu için `kaybedenDeger`
üretemez ⇒ **derlenmeyen mutant**, ölçüm değil.
`SS2/G34/h` — taşma ayağı bir **ölçüm sonucudur** (`N`'in kendisi `T5`'te ölçülür); mutantı
*"N'i küçült"* olurdu ve o, ayağı değil **ölçümün kendisini** bozar ⇒ döngüsel.

## 6c. v1'İN ÜÇ EŞDEĞER MUTANTI NASIL ONARILDI (denetim BLOKER-3)

| mutant | v1'de neden eşdeğerdi | v2'de ne değişti |
|---|---|---|
| `M172` | *"okuma satırını `_kanalUygula`'da aşağı taşı"* — o metot `Gorevler`'e **hiç dokunmaz**, projeksiyon yazımı `_projeksiyonYaz`'dadır ⇒ hiçbir konumdan yapılan okuma değişmez | Tespit **`_projeksiyonYaz`**'a taşındı (`D-SS2-2`) ⇒ orada **gerçek bir `write` vardır** ve mutant onun **önüne/arkasına** düşer |
| `M173` | *"`kuyrukTabani != null` şartını sil"* — `enBuyuk(eskiMeta, null) == eskiMeta` olduğu için şart **cebirsel olarak fazladandı** | Şart artık **bağımsız bir sorgu** (`bekleyenYerelYazimVarMi`, `D-SS2-11`); silinince koşul gerçekten gevşer |
| `M175` | *"iki kararı karıştır"* — mutasyon yalnız `metaYaz` koşulunu değiştiriyordu, **dönüş ifadesi aynı kalıyordu** ⇒ hiçbir sayı değişmiyordu | Hedef değişti: artık **`clientHex` echo elemesi** silinir (`D-SS2-3/3`) ve echo **doğrudan** sahte kayıt üretir |

🔴 **Ders (kanıt dosyasında da yazılı):** *bir dersi alıntılamak, o dersten korunmak değildir.*
v1 `A13`/`M167` dersini metninde taşıyordu ve yine üç kopyasını üretti.

## 6d. v2'NİN ÜÇ KUSURU NASIL ONARILDI (tur 2 denetimi · `KANIT/SS2/02-DENETIM-tur2.md`)

| mutant | v2'de neden ölçmüyordu | v3'te ne değişti |
|---|---|---|
| `M172` | *"kaydı `write(companion)`'ın altına taşı"* — kaybeden değer `_projeksiyonYaz:209`'daki **bellekteki `mevcut`** nesnesinden okunuyor; yazımı aşağı taşımak `mevcut`'u **yeniden okumaz** ⇒ `kaybedenDeger` **bayt-özdeş** kalır. Aynı ders **üçüncü kez** alıntılanıp uygulanmamıştı (`A13/M167` → v1 `M172/M173/M175` → v2 `M172`) | Mutasyonun hedefi **yazım sırası değil OKUMA KAYNAĞI**: `kaybedenDeger` artık yazımdan **sonra DB'den yeniden okunan** satırdan alınır ⇒ kaybeden **gerçekten** kazanana eşitlenir |
| `M171b` | `G31/a` **varlık** araması yapıyor ve mutant gerçek `=> 5` satırını **koruyup** üstüne yorum ekliyordu ⇒ yorumu atan da atmayan araç da **YEŞİL** dönüyordu: **sıfır bilgi** | Mutant **tersine çevrildi** (gerçek satır `=> 4`, doğru değer yalnız yorumda ⇒ **KIRMIZI**) ve yanlış-pozitif kontrolü **`M171c`** olarak **ayrı** mutanta taşındı. İki mutant birlikte yorum-atlamanın **hem yükünü hem sessizliğini** ölçer |
| `M176` | Kriter 4 *"mevcut `G10`'u da düşürmeli"* diyordu; ölçüm bunun **hiçbir koşulda** sağlanamayacağını gösterdi (çakışma satırı 0 iken `distinct`'li/`distinct`'siz sayımlar özdeş; `g10`'un altı ayağı ne çakışma kaydı yazar ne sayım ölçer) ⇒ kriter kabulü **kendi kuralıyla** engelliyordu | `M176` **statik** ayağa (`G33/c`) indirildi ve `G10` şartı kaldırıldı; fan-out'un **yükü** yeni **`G33/d` + `M176b`** ile *çakışma kaydı DOLU iken* davranışsal ölçülür |

🔴 **Bu turun kendi dersi:** bir mutant *"kod değişti"* diye değil, **ölçtüğü sayı değişti** diye
ısırır. `spec-kapi-kapsama.py` *"mutant VAR mı"* sorar, *"mutant ISIRIR mı"* **sormaz** — bu sınıfın
mekanik kapısı **hâlâ yoktur** ve borç `BORCLAR.md`'dedir (`B-SS2-4`).

---

## 7. KABUL KRİTERLERİ (hepsi **Cowork'ün KENDİ koşumuyla** — K26)

1. `flutter analyze` **0 sorun**.
2. `flutter test` **tamamı yeşil**; toplam sayı **ölçülür**, spec'e **yazılmaz**.
3. `SS2/G31`–`SS2/G34`'ün **her ayağı** geçer; her ayağın **nasıl ölçüldüğü** kanıtta yazılıdır.
4. `M171`–`M188` — **`M171b`, `M171c`, `M176b`, `M178b`, `M180b` DÂHİL** (tur 2 MAJOR-4: v2'nin
   *"`M171`–`M186`"* aralığı `M187`/`M188`'i **dışarıda** bırakıyordu) — **hepsi ısırır**;
   **YALNIZ `M171c` susar** (yanlış-pozitif kontrolü). Isırmayan mutant ⇒ **kabul YOK**.
   🔴 **`M183` için** mevcut `G10` testlerini **de** düşürmek **beklenen** sonuçtur: `g10:153` D4
   kilidini bugün fiilen taşıyor (tur 2 denetiminde doğrulandı).
   🔴 **`M176` İÇİN BU ŞART KALDIRILDI [tur 2 `B2-2`; Onur kilitledi, oturum 55].** Ölçülmüş gerekçe:
   `g10_rozet_kapsami_test.dart`'ın **altı ayağının hiçbiri** çakışma kaydı yazmaz ve **hiçbiri sayım
   ölçmez** (sayım testleri **`g11`**'dedir); çakışma satırı **0 iken** `distinct`'li ve `distinct`'siz
   sayımlar **özdeştir** (D5 sqlite ile ölçtü) ⇒ `M176` mevcut hiçbir testi **hiçbir koşulda**
   düşüremez ve şart, kabulü **kendi kuralıyla** engelliyordu. `distinct`'in yükü artık **`G33/d` +
   `M176b`** ile davranışsal ölçülür.
5. `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-SS2-cakisma-cozumu.md`
   ⇒ `[S0]/[S1]/[S2]` **yok**.
6. `python araclar\ss2-kapisi.py --altin-kume` **EXIT 0** *(aracı `T0`'da **Claude Code** yazar;
   altın kümeyi **Cowork denetler** — K26/K44-a)*.
7. Backend **etkilenmemiştir**: `powershell -ExecutionPolicy Bypass -File araclar\verify.ps1`
   **EXIT 0**. 🔴 *(v1 `python araclar\verify.ps1` yazmıştı — `.ps1` `python` ile koşulmaz.)*
   🔴 Koşum sırası: cihaz kanıtı (backend ÇALIŞIR) → backend **KAPATILIR** (`netstat -ano | findstr
   :5298` **boş** ölçülür) → `verify.ps1` (`ORTAM.md`, oturum 50).
8. **UÇTAN UCA (yeniden kuruldu — v1'in senaryosu çakışma penceresine hiç girmiyordu, `Ö8`):**
   ① `docker start momentum-postgres` → `healthy` görülene kadar **yoklanır**
   ② backend ayrı pencerede: `ASPNETCORE_ENVIRONMENT=Development` ·
      `ASPNETCORE_URLS=http://0.0.0.0:5298` · `ConnectionStrings__Momentum=…`; hazır olduğu
      **`/health/live` 200 + `/health/ready` 200 + `POST /v1/sync` başlıksız 401 → başlıkla 200**
      ile ölçülür, **portla değil** (`clientId` **geçerli GUID** olmak zorunda)
   ③ emülatör: `flutter emulators --launch <avd>` → `adb devices` ile **doğrulanır** (K80'in üçüncü
      adımı — v1'de **eksikti**)
   ④ **Cihaz B çevrimdışına alınır** (`adb shell svc wifi disable` / uçak modu), başlık `B1` yapılır
      ⇒ op **kuyrukta**
   ⑤ **Cihaz A** (ikinci emülatör ya da `flutter run -d chrome`) aynı görevin başlığını `A1` yapar
      ve **senkronize olur**
   ⑥ B çevrimiçi olur; **bekleyen op'u varken** bir tur koşar ⇒ `D-SS2-11`'in anlık görüntüsü
      sayesinde çakışma **görülür**: B'de rozet çıkar, ekran `B1` ↔ `A1` gösterir
   ⑦ *Benimkini tut* ⇒ B'nin listesinde `B1` görünür (**projeksiyon da yazıldı**) ve **A'ya ulaşır**
   🔴 **Kaybedenin hangi cihaz olacağı HLC ile belirlenir** ⇒ koşum, A'nın yazımının B'ninkini
   yenmesini **garanti etmek için** A'yı **sonra** yazdırır ve iki `clientId`'yi kanıta yazar.
   🔴 **Ortamı Claude Code kaldırır, Cowork yalnız ölçer** (K80).
9. `KANIT/SS2/` altında her kriterin **ham** çıktısı vardır; özet dosyası kanıt **sayılmaz**.

---

## 8. BEYAN EDİLMİŞ SINIRLAR

> *"Ölç ya da `[DOĞRULANMADI]` yaz"* — `DURUM.md` §5. Beyan edilmiş sınır kabul edilir,
> **gizlenmiş sınır edilmez**.

- **S1** — Kayıt **alan bazlı**, karar **entity başına**: kullanıcı alan alan seçemez (`K95`).
- **S2** — 🔴 **TERS YÖN KAPSAM DIŞI:** uzak yazım kaybettiğinde (yerel kuyruk yener) kayıt
  **yazılmaz**; uzağın değeri sessizce atılır. `K95`'in sorusu *"kaybeden **yerel** sürüm"*
  içindi. İleride açılırsa **kendi mutantıyla** açılır.
- **S3** — `groups:completion` çözümünde `completedAt` **yeniden üretilir** (`Ö15`, REPLACE
  kilidi): uzağın zaman damgası korunmaz. Ayrı bir gönderim yolu açmak `K95`'in *"normal bir
  yazma"* kilidini kırardı.
- **S4** — İki kanal: `fields:title`, `groups:completion`. `fields:isDeleted` **kapsam dışı**
  (`Ö13`: silinmiş görev listeden düşer ⇒ rozet erişilemez; undelete yazma yolu **yok**).
  `order:*` ve `sets` de kapsam dışı (`order` için gerçek tel örneği bu depoda **hiç ölçülmedi**).
- **S5** — Rozet **iki farklı olayı** aynı ikonla gösterir (`D-SS2-7`); ayrıştırma **borç**
  (`BORCLAR.md` → `B-SS2-2`).
- **S6** — Web ayağı **`[DOĞRULANMADI]`**: `flutter test --platform chrome` bu ortamda sonuç
  üretmiyor (7 dk ve 9,8 dk — `ORTAM.md`). Kriter 8 **Android** üzerinde koşar.
- **S7** — v3→v5 migration zinciri **`[DOĞRULANMADI]`**: `G31/c` yalnız **v4→v5**'i ölçer.
  Mutant borcu **değil**, **ölçüm boşluğu** ⇒ `BORCLAR.md` → `B-SS2-1`.
- **S8** — Görev **silinirse** kaydı **yetim kalır**: `sil()` çakışma kayıtlarını **temizlemez** ve
  bu dilimde temizlenmez. Ölçülmüş gerekçe: `sil` akışına dokunmak `A11`/`R10`'un kabul edilmiş
  yollarını değiştirir. Borç: `BORCLAR.md` → `B-SS2-3`.
- **S9** — Kullanıcı **seçim yapmadan çıkarsa** kayıtlar ve rozet **durur** (kasıtlı: karar
  ertelenebilir olmalı). Ekran açıkken kayıt değişirse ekran **yeniden çizilir** (`watch()`).
- **S10** — Bu spec ekranın **piksel** düzenini ölçmez; `DESIGN.md` v2 **tüketilir, değiştirilmez**
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
  **birebir izler**; sapacaksa gerekçesini `KANIT/SS2/` altına yazar.

---

## 9. DOSYA KİMLİĞİ

🔴 Kimlik **DAİMA son yazımdan SONRA** ölçülür ve kilit satırı yazılınca **yeniden** alınır.

| durum | bayt | sha8 |
|---|---|---|
| v1 — **KİLİTLENEMEDİ** (`KANIT/SS2/01-SPEC-v1-KILITLENEMEDI.md`) | 28.801 | `90314998` |
| v2 — **KİLİTLENEMEDİ** (`KANIT/SS2/02-DENETIM-tur2.md`) | 34.504 | `66CC4AAE` |
| **v3 — KİLİTLİ (`K133`)** | 🔴 **BURAYA YAZILMAZ** | 🔴 **`DURUM.md` §9'da ÖLÇÜLÜR** |

🔴 **Geçerli sürümün kimliği bu dosyaya YAZILMAZ.** Ölçülmüş gerekçe: kimlik *son yazımdan sonra*
alınır; onu **bu dosyanın içine** yazmak dosyayı yeniden değiştirir ve yazılan sha'yı **aynı anda
geçersiz kılar** (`kanonik-kopya` kusurunun özyinelemeli hâli — bu projede kimlik tablosunda **üç kez**
ısırdı). Kanonik yer **`DURUM.md` §9**'dur; `A13`'ün (`9C7213F2`) izlediği desenin aynısı.

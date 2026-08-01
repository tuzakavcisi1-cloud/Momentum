# GOREV — `araclar/iddia-kapisi.py` **1.2.0 → 1.3.0** · `D5` KÖR KAPI onarımı · **v1 TASLAK**

> **Yazan el:** Cowork (tasarım + ölçüm). **Yapan el:** Claude Code. **K34-f gereği ayrıdır** —
> `iddia-kapisi.py`'yi Cowork yazdı (K97'de ölçüldü, `ebf7f62`), bu yüzden **onaran el Claude Code'dur**.
> **Bu spec Onur kilitlemeden Claude Code'a VERİLMEZ.**

---

## 0. NEDEN — ölçülmüş **tek** kusur (A9b'nin kapanmamış borcu)

`GOREV-A9b` §6b *"BORÇ YOK"* dedi. **Çürüdü** — K100'de ölçüldü, K101'de mekanizması açıldı:

**`LISTE_ESIGI_PIN_VAKALARI = (16, 17)` HİÇBİR MANTIKTA KULLANILMIYOR.** Sabit yalnızca
`altin_kume()`'nin başında ekrana basılıyor (satır 505–506):

```
LISTE_ESIGI=8 -- LISTE_ESIGI_PIN_VAKALARI=(16, 17) [D5]
```

Yani **yorum-sınıfı bir sabittir**. `M119` onu `(13, 14)` yapınca aracın davranışı hiç değişmez;
altın küme haklı olarak **26/26 GEÇER**, `EXIT 0` verir. Onu yakalaması beklenen **kriter 11**'in iki
`findstr` ayağı ise sabitin **ADINI** ve eski yanlış metnin **YOKLUĞUNU** ölçer, **SAYISAL DEĞERİNİ ölçmez**.
Bu, builder'ın kendi kanıt dosyasında da (`KANIT\A9b\02-MUTANT\00-DOGRULAMA.txt`) **dürüstçe**
yazılıdır: *"kriter 11 bu spesifik mutantı YAKALAMAZ"*.

🔴 **Sonuç: `D5`'in *"atıf artık MEKANİK"* iddiası SAHTEDİR.** Sabit sessizce bayatlayabilir; kimse görmez.
Bu projenin **kör-kapı** tanımının ta kendisidir ve `radar.py` `R1`'de bu sınıf **beş turdur** tekrarlıyor.

**Reddedilen ucuz onarım (kayda geçsin):** *"kriter 11'e üçüncü `findstr` ayağı, çıktıda `(16, 17)` dizgesi
aransın."* `M119`'u yakalardı **ama** ① **KİLİTLİ** `GOREV-A9b` spec'ini değiştirmeyi gerektirirdi,
② kapı **kâğıtta** kalırdı (radar 0.2.0 doktrini: *"kâğıtta doğrulanan bir kapı, doğrulandığını
KANITLAYAMAZ"*), ③ `(16, 17)` ikinci bir dosyaya kopyalanırdı ⇒ **`kanonik-kopya`** yüzeyi büyürdü.
**Onur `A` şıkkını kilitledi (1 Ağu 2026, oturum 45): sabit YÜK TAŞITICI yapılır.**

---

## 1. KAPSAM

**DEĞİŞECEK:** `araclar/iddia-kapisi.py` (**yalnız bu dosya**), sürüm `1.2.0 → 1.3.0`.

**DEĞİŞMEYECEK — tek bayt yazılmaz:**

- `GOREV_CLAUDE_CODE/GOREV-A9b-iddia-kapisi-onarim.md` (**30.046 b · `AF624471`** — K98/K99 kilidi)
- `araclar/iddia-muafiyet.json` · `araclar/tazelik-muafiyet.json`
- `DESIGN.md` (K46) · `docs/ADR/0003-*` (K41) · `tek-kopya-kapisi.py` kapsamındaki **hiçbir** dosya
- `KANIT\A9b\**` — **tarihtir, düzeltilmez.** Yeni kanıt `KANIT\A9c\` altına yazılır.

`iddia-kapisi.py` `tek-kopya-kapisi.py` kapsamında **DEĞİLDİR** (açılışta ölçüldü) ⇒ bu değişiklik
**hiçbir kilidi bozmaz**.

---

## 2. YAPILACAK DEĞİŞİKLİK — `D8`

### D8 — `LISTE_ESIGI_PIN_VAKALARI` **YÜK TAŞITICI** olur

**Amaç:** sabit, *hangi altın küme vakalarının `LISTE_ESIGI` eşiğini pinlediğini* **iddia eder**;
altın küme bu iddiayı **kendi içinde ölçer**. Dizge araması **YOK**, spec'e bağımlılık **YOK**.

**D8-a — `_vaka()` opsiyonel `pin` etiketi alır.**
`_vaka(ad, metin, beklenen, kanitli=None, muafiyetler=None, olmamali=(), belge_yolu=None, pin=None)`.
`pin` verildiğinde vaka, **etiketinden ayrıştırılan vaka numarasıyla** birlikte modül düzeyinde bir
kayda (`_PINLI`) yazılır. Numara etiketin başındaki `^(\d+[a-z]?)\)` deseninden okunur — **ikinci bir
yere elle yazılmaz** (aksi hâlde aynı sayının iki kopyası doğar: `kanonik-kopya`).
🔴 Desen `20b)` / `22b)` gibi harfli numaraları **kırmadan** ayrıştırmalı; ayrıştıramazsa
`AssertionError` atmalı — **sessiz atlama YASAK** (kör kapı bu şekilde doğar).

**D8-b — Vaka 16 ve 17 `pin="LISTE_ESIGI"` taşır.** Başka hiçbir vaka bu etiketi taşımaz.

**D8-c — Yeni vaka 27 (`[D8]`) sabiti vakalarla KARŞILAŞTIRIR.**
`altin_kume()`'nin **sonunda**, diğer vakalar koştuktan sonra:

```
olculen  = _PINLI.get("LISTE_ESIGI", set())          # etiketten toplanan, ör. {"16","17"}
beklenen = {str(n) for n in LISTE_ESIGI_PIN_VAKALARI}
ok       = (olculen == beklenen)
```

Vaka etiketi: `27) [D8] LISTE_ESIGI_PIN_VAKALARI gercekten pinli vakalari adlandiriyor mu`.
Çıktı **her iki kümeyi de** basmalı (`beklenen: ... - olculen: ...`), aksi hâlde düştüğünde teşhis edilemez.
🔴 **İki yönlü ısırmalı:** ① sabit yanlış numara söylerse (`M119`), ② bir vakadan `pin` etiketi
düşerse (`M123`). Tek yönlü bir kontrol bu borcun yarısını açık bırakır.

**D8-d — Sürüm `1.3.0`.** `D6` kuralı yürürlükte: **tek değer, üç yer** (`SURUM` sabiti + modül
docstring'i + basılan satır sabitten türer). `1.2.0` dizgesi kodda **hiç kalmamalı**.

**D8-e — Basılan `[D5]` satırı korunur** ama artık **ölçülmüş** bir iddiadır; satır aynı kalır,
anlamı değişir. Satırın yanına `[D8]` etiketi **eklenmez** — `sayi-tazeligi.py`'nin desenlerini
gereksiz yere sarsmamak için.

---

## 3. SAYI GÜNCELLEMELERİ — altın küme **26 → 27**

Bu değişikliğin **ölçülmüş bedeli** budur ve gizlenmez:

| yer | eski | yeni | kim yazar |
|---|---|---|---|
| `altin_kume()` çıktısı `ALTIN KUME: GECTI (n/26)` | 26 | **27** | otomatik (türetilir) |
| `DURUM.md` §4, `K89–K100` satırı — `iddia-kapisi.py` altın küme **26/26** | 26/26 | **27/27** | **Cowork** (kabulde) |
| `DURUM.md` §6 araç tablosu, `iddia-kapisi.py` satırı | **26/26** | **27/27** | **Cowork** (kabulde) |
| `KANIT\A9b\**` | 26 | **DEĞİŞMEZ** | — (tarihtir) |

🔴 `sayi-tazeligi.py` bu iddiaları **aracı gerçekten koşarak** doğrular ⇒ Claude Code build'i bitirince
sayılar güncellenmeden `DURUM.md` **KIRMIZI** verir. Sıra: **önce araç, sonra belge** (K44-a).

---

## 4. KABUL KRİTERLERİ

| # | kriter | nasıl ölçülür |
|---|---|---|
| 1 | altın küme yeşil | `python araclar\iddia-kapisi.py --altin-kume` ⇒ `ALTIN KUME: GECTI (27/27)` · **EXIT 0** |
| 2 | `A9` regresyon | `iddia-kapisi.py GOREV_CLAUDE_CODE\GOREV-A9-cakisma-cozum-metin-kaybi.md --kanit KANIT\A9` ⇒ **EXIT 0**, `HUKUM: TEMIZ`, `I3` satırı **tam 0**, `[KIRMIZI] I1` **tam 0**, `[BILGI] I1: MUAFIYET UYGULANDI` **tam 2** |
| 3 | `A8` regresyon | aynı araç, `A8` belgesi + `KANIT\A8` ⇒ **EXIT 0**, `HUKUM: TEMIZ` |
| 4 | `A7` regresyon | aynı araç, `A7` belgesi + `KANIT\A7` ⇒ **EXIT 0**, `HUKUM: TEMIZ` |
| 5 | **`M123` ısırır** | `KANIT\A9c\02-MUTANT\M123.txt`: `[KALDI] 27)` satırı · `ALTIN KUME: KALDI (26/27)` · `EXIT=1` |
| 6 | **`M119` ARTIK ISIRIR** | `KANIT\A9c\02-MUTANT\M119.txt`: `[KALDI] 27)` satırı · `ALTIN KUME: KALDI (26/27)` · `EXIT=1` — **A9b'de bu mutant `26/26 GECTI` veriyordu; fark bu spec'in tek varlık sebebidir** |
| 7 | `G17` mutantları yeniden | `GOREV-A9b` §6 tablosundaki **her** mutant `KANIT\A9c\02-MUTANT\` altında **yeniden** koşulur; beklenen `[KALDI]` kümeleri `GOREV-A9b` §6 ile **aynı**, yalnız payda `26 → 27` olur (`M120` hâlâ altın kümeyi bozmaz ⇒ `27/27`). **Ölçü:** `KANIT\A9c\02-MUTANT\` altındaki `M*.txt` sayısı = `GOREV-A9b` §6 tablosunun satır sayısı **+ 1** (`M123`); sayı **türetilir, kopyalanmaz** |
| 8 | sürüm | `findstr /C:"1.2.0" /C:"1.1.0" araclar\iddia-kapisi.py` ⇒ **EXIT 1** (hiç eşleşme yok) |
| 9 | öz-tutarlılık | `iddia-kapisi.py` **kendi dosyasını** denetler ⇒ **EXIT 0** |
| 10 | kapı-kapsama | `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-A9c-D5-kor-kapi-onarimi.md` ⇒ **EXIT 0** (`D8` mutantsız görünmemeli). 🔴 Bu araç **DOSYA** yolu ister; `.` verilirse `ORTAM HATASI ... Permission denied` ve `EXIT 3` döner (oturum 45'te ölçüldü) |
| 11 | tek-kopya | `python araclar\tek-kopya-kapisi.py .` ⇒ **EXIT 0** |
| 12 | `A9b` spec'i **bozulmadı** | `python araclar\dosya-kimlik.py GOREV_CLAUDE_CODE\GOREV-A9b-iddia-kapisi-onarim.md` ⇒ **30.046 b · `AF624471`** |
| 13 | git | `.git\index.lock` **yok**; `git status --porcelain` beklenen dosyalar dışında değişiklik göstermez |

🔴 **Kriter 6 bu spec'in ÖLÇÜSÜDÜR.** `M119` A9c'de ısırmıyorsa iş **BİTMEMİŞTİR** — ne kadar kod
yazılmış olursa olsun.

---

## 5. KAPILAR

### G18 — `iddia-kapisi.py` **1.3.0**'ın `D8` kapısı (altın küme vaka **27**)

| kural | ne garanti eder |
|---|---|
| `D8` | `LISTE_ESIGI_PIN_VAKALARI` **yük taşır**: sabit ile `pin` etiketli vakalar **birebir** eşleşmezse altın küme düşer; atıf **string** değil **küme** karşılaştırmasıyla ölçülür |

---

## 6. MUTANTLAR

| mutant | mutasyon | kural | beklenen |
|---|---|---|---|
| **M119** | `LISTE_ESIGI_PIN_VAKALARI` **(13, 14)** yapılsın | `G18` / `D8` | vaka **27** KALIR ⇒ **26/27**, `EXIT 1` |
| **M123** | vaka **17**'den `pin="LISTE_ESIGI"` etiketi **kaldırılsın** | `G18` / `D8` | vaka **27** KALIR ⇒ **26/27**, `EXIT 1` |

🔴 **`G17`'nin (yani `D0`–`D7`'nin) mutantları bu tabloda YOKTUR** çünkü onlar `GOREV-A9b` §6'da
tanımlıdır — **burada yeniden tanımlanmazlar** (`kanonik-kopya` kusuru bu projede altı kez ısırdı).
Yine de **hepsi yeniden koşulur**: mutasyonlar `GOREV-A9b` §6'daki ile **aynı**, beklenen `[KALDI]`
kümeleri **aynı**, yalnız payda `26 → 27` olur. Ölçüsü **kriter 7**'dir.

🔴 **SAYI BURAYA KOPYALANMAZ — TÜRETİLİR.** Kaç mutant koşulacağı bu belgeye **rakamla yazılmaz**;
`GOREV-A9b` §6 tablosunun satır sayısından **okunur**. Gerekçe bu spec'in kendi tezidir: kopyalanan
sayı bayatlar, türetilen sayı bayatlamaz — `D5` kusurunun ta kendisi budur.

**Yöntem — A9b'deki `mutant_runner.py` deseni korunur:** her mutant **tek başına** uygulanır,
`PYTHONIOENCODING=utf-8` ile koşulur, **HAM** çıktı `M<n>.txt`'e yazılır, mutant **geri alınır**,
geri alma sonrası dosya **sha256** ile mutasyon öncesiyle bit-bit karşılaştırılır.

### 6b. MUTANT BORCU

**BORÇ YOK — ve bu kez ölçüyle:** `D8`'in **iki yönü de** mutantla kanıtlanır (`M119` sabit yönü,
`M123` etiket yönü). A9b'nin *"BORÇ YOK"* iddiası tek yönlüydü ve çürüdü; **bu satır çürütülebilir
biçimde yazılmıştır: kriter 5 veya 6 kırmızıysa bu iddia yanlıştır.**

---

## 7. ORTAMI KİM KALDIRIR (K80)

- `python` stdout bu makinede **cp1254** ⇒ her koşumda `PYTHONIOENCODING=utf-8`.
- EXIT okunacak her yerde `cmd /v:on /c "... & echo !ERRORLEVEL!"` — `%ERRORLEVEL%` **kördür**.
- Commit **yalnız** yol belirterek (`git add -A` **YASAK**, K55), mesajda **çift tırnak yok**,
  her `git` çağrısında `--no-optional-locks`. **PUSH ONUR'DA.**
- 🔴 **Claude Code tek yanıtta 64.000 çıktı token sınırına çarpabiliyor** — büyük dosya yazımı
  **parçalara bölünmeli** (oturum 44 dersi).

---

## 8. BEYAN EDİLMİŞ SINIRLAR (gizlenmiyor)

1. **`D8` yalnız `LISTE_ESIGI` pinini ölçer.** Kod tabanındaki **diğer** çapraz-atıfların (yorumların
   işaret ettiği başka vaka/kural numaraları) mekanik kapısı **YOKTUR**. Genel bir "çapraz-atıf kapısı"
   bu spec'in **kapsamı dışındadır** ve kayıtlı bir borç olarak `BORCLAR.md`'ye yazılacaktır.
2. **Vaka numarası etiketten ayrıştırılır.** Bir vakanın etiketi numarasız yazılırsa ve o vaka `pin`
   taşımıyorsa, kontrol bunu **görmez** (yalnız `pin` taşıyanlar ayrıştırılır). Bu bilinçli bir
   daraltmadır: alternatifi her vakanın numarasını zorunlu kılmaktı, bu da 26 vakayı elden geçirirdi.
3. **Vaka 20b hâlâ İKİ bağımsız şey ölçüyor** (`D7` seviye-duyarlılığı + muafiyet tavanının üstten
   pini). Oturum 45'te ölçüldü ve **bu spec'te DÜZELTİLMİYOR** — bölmek altın kümeyi `27 → 28`
   yapardı ve `D5` onarımıyla karışırdı. Kayıtlı borç.
4. **`GOREV-A9b`'nin kriter 11'i olduğu gibi kalır.** Artık **gereksizdir** (kâğıt kontrolün yerini
   koşan kod aldı) ama spec **kilitlidir** ve tarih **düzeltilmez**; bu, K73 doktrininin gereğidir.

# GOREV — `araclar/iddia-kapisi.py` **1.2.0 → 1.3.0** · `D5` KÖR KAPI onarımı · **v2**

> **Yazan el:** Cowork (tasarım). **Yapan el:** Claude Code. **K34-f gereği ayrıdır** — `iddia-kapisi.py`'yi
> Cowork yazdı (K97, `ebf7f62`) ⇒ **onaran el Claude Code'dur.** Bu spec Onur kilitlemeden verilmez.
>
> 🔴 **v1 KIRILDI.** Bağımsız denetçi (Cowork'ten ayrı el, K26) v1'i **kâğıtta okumakla yetinmedi**:
> aracı kopyalayıp `D8`'i gerçekten uyguladı ve mutantları koştu. **4 bloker + 6 major + 5 minor.**
> v2 bunların **hepsini** ya kapatır ya da §8'de **ölçülmüş sınır** olarak beyan eder. Denetimin
> mimariyi değiştiren bulgusu **BLOKER 1**'dir: v1 yanlış fonksiyonu hedefliyordu.

---

## 0. NEDEN — ölçülmüş kusur (`A9b`'nin kapanmamış borcu)

`LISTE_ESIGI_PIN_VAKALARI = (16, 17)` **hiçbir mantıkta kullanılmıyor**; yalnız `altin_kume()` başında
ekrana basılıyor (satır 505–506) ⇒ **yorum-sınıfı sabit**. `M119` onu `(13, 14)` yapınca aracın davranışı
değişmez, altın küme **haklı olarak 26/26 GEÇER**. Onu yakalaması beklenen **kriter 11**'in iki `findstr`
ayağı sabitin **ADINI** ve eski metnin **YOKLUĞUNU** ölçer, **DEĞERİNİ** ölçmez. Builder bunu kendi kanıt
notunda (`KANIT\A9b\02-MUTANT\00-DOGRULAMA.txt`) dürüstçe yazdı: *"kriter 11 bu spesifik mutantı YAKALAMAZ"*.

⇒ `D5`'in *"atıf artık MEKANİK"* iddiası **sahtedir**. `GOREV-A9b` §6b'nin *"BORÇ YOK"*u **çürüdü**.

**REDDEDİLEN ucuz onarım** (kriter 11'e üçüncü `findstr`): ① **KİLİTLİ** A9b spec'ini değiştirir
② kapı **kâğıtta** kalır (radar 0.2.0: *"kâğıtta doğrulanan bir kapı, doğrulandığını KANITLAYAMAZ"*)
③ `(16,17)` ikinci dosyaya kopyalanır ⇒ **`kanonik-kopya`** yüzeyi büyür.
**Onur şık A'yı kilitledi (1 Ağu 2026, oturum 45): sabit YÜK TAŞITICI yapılır.**

---

## 1. KAPSAM

**DEĞİŞECEK:** `araclar/iddia-kapisi.py` (**yalnız bu dosya**), `1.2.0 → 1.3.0`.
**YENİ DİZİNLER:** `KANIT\A9c\` ve `KANIT\A9c-REGRESYON\` (ayrılma gerekçesi §4 kriter 9'da).

**DEĞİŞMEYECEK — tek bayt yazılmaz:** `GOREV-A9b-iddia-kapisi-onarim.md` (**30.046 b · `AF624471`**,
K98/K99 kilidi — denetçi bu kimliği **bağımsız doğruladı**) · `araclar/iddia-muafiyet.json` ·
`araclar/tazelik-muafiyet.json` · `DESIGN.md` (K46) · `docs/ADR/0003-*` (K41) · `KANIT\A9b\**` (**tarihtir**)
· `tek-kopya-kapisi.py` kapsamındaki hiçbir dosya. `iddia-kapisi.py` o kapsamda **DEĞİLDİR** (ölçüldü)
⇒ bu değişiklik **hiçbir kilidi bozmaz**.

---

## 2. YAPILACAK DEĞİŞİKLİK — `D8`

### D8-a — `pin` etiketi **HER İKİ** vaka yardımcısına eklenir

🔴 **v1'İN BLOKER'I BURADAYDI:** v1 yalnız `_vaka()`'ya `pin` eklemeyi söylüyordu. **Vaka 13, 14, 15,
16, 17 `_vaka()` DEĞİL `_vaka_kanit()` kullanıyor** (denetçi 26 çağrının tamamını ayrıştırarak ölçtü,
satır ~581–590). v1 uygulansaydı `pin` vaka 16/17 için **hiç çalışmazdı** ve mutantsız kod bile
kriter 1'i düşürürdü (denetçi ölçtü: `beklenen: ['16','17'] - olculen: []`, `26/27`, `EXIT=1`).

**Yapılacak — iki imza birden:**

```
def _vaka(ad, metin, beklenen, kanitli=None, muafiyetler=None, olmamali=(), belge_yolu=None, pin=None)
def _vaka_kanit(ad, adlar, beklenen_kanitli, beklenen_envanter=(), beklenen_elenen=(), pin=None)
```

`pin` verildiğinde vaka, **etiketinden ayrıştırılan** numarayla modül düzeyinde bir kayda (`_PINLI`,
`dict[str, set[str]]`) yazılır. Numara `^(\d+[a-z]?)\)` deseniyle okunur — **ikinci bir yere elle
yazılmaz** (aksi hâlde `kanonik-kopya` doğar). Desen `20b)` / `22b)` gibi harfli numaraları
**kırmadan** ayrıştırır (denetçi 26/26 etiketle ölçtü). Ayrıştırılamazsa **`AssertionError`** atılır —
**sessiz atlama YASAK**; kör kapı böyle doğar. Bu kural `M124` ile kanıtlanır.

🔴 `_PINLI` **her `altin_kume()` çağrısının başında SIFIRLANIR** — modül düzeyinde birikirse ikinci
çağrı yanlış ölçer.

### D8-b — Vaka **16** ve **17** `pin="LISTE_ESIGI"` taşır

Başka hiçbir vaka bu etiketi taşımaz. (Vaka 16 eşik **değerini** reddeder, vaka 17 eşiğin **bir altını**
kabul eder — `iddia-kapisi.py` satır 64'teki yorumun ölçtüğü çift budur.)

### D8-c — Yeni **vaka 27** sabiti vakalarla KARŞILAŞTIRIR

`altin_kume()`'nin **sonunda**, diğer 26 vaka koştuktan sonra, **üçüncü bir yardımcı** ile:

```
def _vaka_pin(ad, etiket):
    olculen  = _PINLI.get(etiket, set())
    beklenen = {str(n) for n in LISTE_ESIGI_PIN_VAKALARI}
    ok = (olculen == beklenen)
    _yaz(("[GECTI] " if ok else "[KALDI] ") + ad)
    _yaz("    beklenen: %s - olculen: %s" % (sorted(beklenen), sorted(olculen)))
    return ok
```

Sonuç **`s`'e eklenir** (`s.append(...)`) ⇒ payda otomatik **27** olur (`kaldi = s.count(False)`
mantığı denetçi tarafından okundu, doğru çalışır). Etiket:
`27) [D8] LISTE_ESIGI_PIN_VAKALARI gercekten pinli vakalari adlandiriyor mu`.
Baskı biçimi `_vaka()` ile **aynı** olmalıdır (`[GECTI]`/`[KALDI] <ad>`), çünkü kriter 5/6 bu biçimi arar.

🔴 **Tek etiket kilidi:** `_vaka_pin` çağrılmadan önce `assert set(_PINLI) <= {"LISTE_ESIGI"}` konur.
Gerekçe ölçüldü (denetçi): `beklenen` her hâlükârda `LISTE_ESIGI_PIN_VAKALARI`'ndan türüyor; ikinci bir
`pin` etiketi eklenirse fonksiyon onu **yanlış sabitle** karşılaştırır ve **sessizce** yanlış ölçer.
Bugün tek etiket var; assert bu varsayımı **beyan değil kural** yapar.

### D8-d — Sürüm `1.3.0`

`GOREV-A9b` `D6`'nın **gerçek üç yeri**: ① modül docstring'i (satır 3) ② `SURUM` sabiti (satır 59)
③ **`DURUM.md` §6 araç tablosu**. 🔴 v1 üçüncü yeri yanlış yazmıştı (*"basılan satır"* — o zaten
`SURUM`'dan türüyor, ayrı bir yer değil; üstelik `--altin-kume` kipi **hiçbir sürüm satırı basmıyor**,
bu tam olarak A9b §6b'nin *"v1'in fiilen yanlış `D6` borcu"* diye gömdüğü hatadır). `1.2.0` ve `1.1.0`
dizgeleri **kodda hiç kalmamalı**; `1.3.0` **tam iki kez** geçmeli (docstring + `SURUM`).

### D8-e — Basılan `[D5]` satırı **aynen korunur**

Satır değişmez, **anlamı** değişir: artık ölçülmüş bir iddiadır. `[D8]` etiketi eklenmez —
`sayi-tazeligi.py`'nin desenleri gereksiz yere sarsılmasın.

---

## 3. SAYI VE SÜRÜM GÜNCELLEMELERİ — ölçülmüş bedel

| yer | eski | yeni | kim |
|---|---|---|---|
| `altin_kume()` çıktısı `ALTIN KUME: ... (n/26)` | 26 | **27** | otomatik (türetilir) |
| `DURUM.md` §4 — `iddia-kapisi.py` altın küme | **26/26** | **27/27** | Cowork (kabulde) |
| `DURUM.md` §6 araç tablosu — altın küme sütunu | **26/26** | **27/27** | Cowork (kabulde) |
| `DURUM.md` §6 araç tablosu — **sürüm** | **1.2.0** | **1.3.0** | Cowork (kabulde) |
| **`DURUM.md` §3 CANLI DURUM (İstemci hücresi)** — sürüm | **1.2.0** | **1.3.0** | Cowork (kabulde) |
| **`DURUM.md` §3 CANLI DURUM** — *"`M119` ISIRMIYOR — `D5` kör kapı borcu"* | var | **`M119` ISIRIYOR (vaka 27)** | Cowork (kabulde) |
| `KANIT\A9b\**` | 26 | **DEĞİŞMEZ** | — (tarihtir) |

🔴 Sürüm satırı v1'de **unutulmuştu** (denetçi buldu): araç `1.3.0` olurken `DURUM.md` `1.2.0` demeye
devam edecekti ve **hiçbir kapı görmeyecekti** — `D6`'nın üçüncü yeri tam olarak orasıdır.

---

## 4. KABUL KRİTERLERİ

| # | kriter | nasıl ölçülür |
|---|---|---|
| 1 | altın küme yeşil | `python araclar\iddia-kapisi.py --altin-kume` ⇒ `ALTIN KUME: GECTI (27/27)` · **EXIT 0**. 🔴 **Bu kriter, kriter 5/6/7'nin ÖN ŞARTIDIR** (aşağıdaki uyarı) |
| 2 | `A9` regresyon | `iddia-kapisi.py GOREV_CLAUDE_CODE\GOREV-A9-cakisma-cozum-metin-kaybi.md --kanit KANIT\A9` ⇒ **EXIT 0** · `HUKUM: TEMIZ` · `I3` satırı **tam 0** · `[KIRMIZI] I1` **tam 0** · `[BILGI] I1: MUAFIYET UYGULANDI` **tam 2** |
| 3 | `A8` regresyon | aynı araç, `A8` belgesi + `KANIT\A8` ⇒ **EXIT 0** · `HUKUM: TEMIZ` |
| 4 | `A7` regresyon | aynı araç, `A7` belgesi + `KANIT\A7` ⇒ **EXIT 0** · `HUKUM: TEMIZ` |
| 5 | **`M119` ARTIK ISIRIR** | `KANIT\A9c\02-MUTANT\M119.txt`: `[KALDI] 27)` · **`beklenen: ['13', '14']`** · **`olculen: ['16', '17']`** · `ALTIN KUME: KALDI (26/27)` · `EXIT=1`. 🔴 **Yön dikkat:** `M119` **SABİTİ** mutasyona uğratır ⇒ değişen taraf `beklenen`'dir (sabitten türer); `olculen` (etiketlerden toplanır) **değişmez**. *(v2 bunu TERS yazmıştı; denetçi uygulayıp ölçerek buldu — doğru uygulanmış bir build v2'nin kriter 5'ini geçemezdi.)* 🔴 **İki değer satırı da ZORUNLUDUR** — onsuz bu kriter, `D8` ölüyken de yeşil yanar |
| 6 | **`M123` ısırır** | `KANIT\A9c\02-MUTANT\M123.txt`: `[KALDI] 27)` · `beklenen: ['16', '17']` · `olculen: ['16']` · `ALTIN KUME: KALDI (26/27)` · `EXIT=1` |
| 7 | **`M124` ısırır** | `KANIT\A9c\02-MUTANT\M124.txt`: çıktı `AssertionError` içerir · `EXIT` **0 DEĞİL** (çökme kabul edilir; sessiz geçiş **kabul edilmez**) |
| 8 | `G17` mutantları **içerikle** | `GOREV-A9b` §6'daki **her** mutant `KANIT\A9c-REGRESYON\` altında yeniden koşulur. **Her `M<n>.txt`** şunları taşır: `[KALDI]` satırlarının kümesi A9b §6'daki beklenen küme ile **birebir** · `ALTIN KUME: KALDI (<n>/27)` · `EXIT=1`. **İstisnalar:** `M120` altın kümeyi bozmaz ⇒ `GECTI (27/27)` (öldürücüsü A9c'de **kriter 10**'dur); **`M119` bu dizine YAZILMAZ** — onun A9c'deki beklentisi **kriter 5** tarafından **EZİLİR**, A9b §6'nın `M119` satırı A9c'de **GEÇERSİZDİR** |
| 9 | kanıt kirliliği yok | Kriter 8'in çıktıları **ayrı dizindedir** (`KANIT\A9c-REGRESYON\`), çünkü A9c §6 tablosu yalnız `M119`/`M123`/`M124` taşır ve hepsi tek dizinde olsaydı kapı **12 hayalet kanıt (`I3`)** üretirdi (denetçi ölçtü). Ölçü: `iddia-kapisi.py GOREV_CLAUDE_CODE\GOREV-A9c-D5-kor-kapi-onarimi.md --kanit KANIT\A9c` ⇒ **EXIT 0** · `HUKUM: TEMIZ` · `I3` satırı **tam 0** · `[KIRMIZI]` satırı **tam 0** |
| 10 | sürüm — **iki ayak** | ① `findstr /C:"1.2.0" /C:"1.1.0" araclar\iddia-kapisi.py` ⇒ **EXIT 1** (hiç eşleşme) ② `findstr /C:"1.3.0" araclar\iddia-kapisi.py` ⇒ **EXIT 0** ve **tam 2** eşleşme. 🔴 v1'de pozitif ayak yoktu: sürüm satırı tamamen silinse kriter geçerdi |
| 11 | sayı tazeliği | `python araclar\sayi-tazeligi.py .` ⇒ **EXIT 0** · `HUKUM: TEMIZ`. Bu, §3'teki **`26 → 27`** güncellemesinin zorlayıcısıdır — **sürümün DEĞİL** (aşağıdaki uyarı). 🔴 **TEK EL KURALI:** bu araç `tek-kopya-mutant.py`'yi çağırır ve o **canlı depoyu geçici olarak MUTASYONA UĞRATIR**; başka bir el aynı anda yazarken koşulursa **sahte kırmızı** verir. Kırmızı görürsen **önce tek elle tekrar koş** |
| 12 | kapı-kapsama | `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-A9c-D5-kor-kapi-onarimi.md` ⇒ **EXIT 0**. 🔴 Bu araç **DOSYA** yolu ister; `.` verilirse `ORTAM HATASI ... Permission denied` + `EXIT 3` (oturum 45'te ölçüldü) |
| 13 | tek-kopya | `python araclar\tek-kopya-kapisi.py .` ⇒ **EXIT 0** |
| 14 | `A9b` spec'i bozulmadı | `python araclar\dosya-kimlik.py GOREV_CLAUDE_CODE\GOREV-A9b-iddia-kapisi-onarim.md` ⇒ **30.046 b · `AF624471`** |
| 15 | git | `.git\index.lock` **yok**. `git --no-optional-locks status --porcelain` **yalnız** şunları göstermeli: `araclar/iddia-kapisi.py` · `KANIT/A9c/**` · `KANIT/A9c-REGRESYON/**` · `DURUM.md` · `GOREV_CLAUDE_CODE/GOREV-A9c-D5-kor-kapi-onarimi.md`. Başka yol çıkarsa **DUR ve raporla** |
| 16 | `DURUM.md` sürüm ve iddia tazeliği | ① `findstr /C:"1.2.0" DURUM.md` ⇒ **EXIT 1** (hiç eşleşme) ② `findstr /C:"1.3.0" DURUM.md` ⇒ **EXIT 0** ③ `findstr /C:"M119 ISIRMIYOR" DURUM.md` ⇒ **EXIT 1**. 🔴 **Neden AYRI kriter:** ölçüldü — `sayi-tazeligi.py` **kendi beyanıyla** *"yalnız ALTIN KÜME SAYISINI ölçer; paket SÜRÜM tazeliğini ÖLÇMEZ"*; deseni `N/M`'dir ve `1.2.0` dizgesiyle **hiç eşleşmez**. v2 sürüm güncellemesini yanlışlıkla kriter 11'e yıkmıştı ⇒ araç `1.3.0` olurken `DURUM.md` sessizce `1.2.0` demeye devam ederdi |

🔴 **KRİTER 1 ÖN ŞARTTIR — ATLANAMAZ.** Denetçi ölçtü: `D8` yanlış fonksiyona takılırsa taban koşum
`[KALDI] 27) ... olculen: []`, `26/27`, `EXIT=1` verir; bu çıktı kriter 5/6'nın beklediğiyle **biçimsel
olarak aynıdır**. Bu yüzden kriter 5 ve 6, `olculen` **değerini** de aramak zorundadır (yukarıda) ve
kriter 1 **önce** yeşil olmalıdır. Aksi hâlde `D8` tamamen ölüyken üç kriter birden yeşil yanar.

🔴 **A9b KRİTER NUMARALARI A9c'DE GEÇERSİZDİR** (denetçi buldu: belgeler arası çarpışma).
Eşleme: A9b **kriter 11** → A9c'de **yok** (yerini **vaka 27** aldı) · A9b **kriter 14** → A9c **kriter 10**.

🔴 **Kaç mutant koşulacağı bu belgeye RAKAMLA YAZILMAZ, TÜRETİLİR:**
`findstr /R /C:"| \*\*M" GOREV_CLAUDE_CODE\GOREV-A9b-iddia-kapisi-onarim.md | find /c /v ""` çıktısı
kadar mutant, **eksi 1** (`M119` hariç tutulur, kriter 5'e taşındı). v1'in *"tablo satır sayısı"*
ifadesi **belirsizdi** (denetçi ölçtü: başlık+ayraç dâhil 16, yalnız veri satırı 14).

---

## 5. KAPILAR

### G18 — `iddia-kapisi.py` **1.3.0**'ın `D8` kapısı (altın küme vaka **27**)

| kural | ne garanti eder |
|---|---|
| `D8` | `LISTE_ESIGI_PIN_VAKALARI` **yük taşır**: sabit ile `pin` etiketli vakalar **birebir** eşleşmezse altın küme düşer; karşılaştırma **string arama değil KÜME** karşılaştırmasıdır ve numara **etiketten türetilir** |

---

## 6. MUTANTLAR

| mutant | mutasyon | kural | beklenen |
|---|---|---|---|
| **M119** | `LISTE_ESIGI_PIN_VAKALARI` **(13, 14)** yapılsın | `G18` / `D8` | vaka **27** KALIR · `beklenen: ['13', '14']` · `olculen: ['16', '17']` ⇒ **26/27**, `EXIT 1` |
| **M123** | vaka **17**'den `pin="LISTE_ESIGI"` etiketi **kaldırılsın** | `G18` / `D8` | vaka **27** KALIR · `olculen: ['16']` ⇒ **26/27**, `EXIT 1` |
| **M124** | vaka **16**'nın etiketindeki `16)` **numarası silinsin** (etiket numarasız kalsın) | `G18` / `D8` | ayrıştırma **`AssertionError`** ile çöker, `EXIT` **0 değil** |

🔴 **`G17`'nin (yani `D0`–`D7`'nin) mutantları bu tabloda YOKTUR** — `GOREV-A9b` §6'da tanımlıdır ve
**burada yeniden tanımlanmazlar** (`kanonik-kopya` bu projede altı kez ısırdı). Yine de **hepsi
yeniden koşulur**; ölçüsü **kriter 8**'dir ve o ölçü **içerik okur, dosya saymaz**.

**Yöntem:** `KANIT\A9b\02-MUTANT\00-DOGRULAMA.txt`'te anlatılan `mutant_runner.py` deseni korunur —
her mutant **tek başına** uygulanır, `PYTHONIOENCODING=utf-8` ile koşulur, **HAM** çıktı `M<n>.txt`'e
yazılır, mutant **geri alınır**, geri alma sonrası dosya **sha256** ile bit-bit karşılaştırılır.
*(v1 bu deseni yanlışlıkla A9b spec'ine atfediyordu; `mutant_runner` o spec'te **0 kez** geçiyor.)*

🔴 **`KANIT\A9c-REGRESYON\00-DOGRULAMA.txt` ZORUNLUDUR** ve `KANIT\A9b\02-MUTANT\00-DOGRULAMA.txt` ile
**aynı biçimde** bir tablo taşır: `mutant | KALDI vaka(lar) | n/27 | EXIT | beklenen (A9b §6) | ESLESIYOR MU`.
Gerekçe: kriter 8'in *"birebir"* ayağının A9b §6 tarafı **düzyazıdır**, makine okunur bir kaynağı yoktur
⇒ karşılaştırma elle transkripsiyon ister ve **transkripsiyon kanıt bırakmadan yapılamaz**. Bu tablo o
kanıttır. *(Denetçi ölçtü: `<n>` değeri `[KALDI]` kümesinden zaten türer, ayrıca yazılması tutarlılık kontrolüdür.)*

### 6b. MUTANT BORCU — **ÇÜRÜTÜLEBİLİR biçimde**

`D8`'in **üç yönü** mutantla kanıtlanır: sabit yönü (`M119`) · etiket yönü (`M123`) · ayrıştırma yönü
(`M124`). **İDDİA: kriter 5, 6 veya 7 kırmızıysa bu satır yanlıştır.**

🔴 **AMA BORÇ SIFIR DEĞİLDİR** — §8/1'e bak. `D8` *etiketi* ölçer, *bağımlılığı* ölçmez; bağımlılığı
ölçen zincir `M111`/`M112` → **kriter 8'in içerik ayağıdır**. A9b §6b'nin *"BORÇ YOK"* hatasını
tekrarlamamak için bu cümle burada duruyor.

---

## 7. ORTAMI KİM KALDIRIR (K80)

- `python` stdout bu makinede **cp1254** ⇒ her koşumda `PYTHONIOENCODING=utf-8`.
- EXIT okunacak her yerde `cmd /v:on /c "... & echo !ERRORLEVEL!"` — `%ERRORLEVEL%` **kördür**.
- Commit **yol belirterek** (`git add -A` **YASAK**, K55), mesajda **çift tırnak yok**, her `git`
  çağrısında `--no-optional-locks`. **PUSH ONUR'DA.**
- 🔴 Claude Code tek yanıtta **64.000 çıktı token** sınırına çarpabiliyor ⇒ büyük dosya yazımı
  **parçalara bölünür** (oturum 44 dersi).
- 🔴 **`sayi-tazeligi.py` CANLI DEPOYU MUTASYONA UĞRATIR [oturum 45'te ölçüldü].** `DURUM.md`'deki
  `tek-kopya-mutant.py 11/11` iddiasını doğrulamak için o aracı **gerçekten koşar**; o araç da arşivi
  **0 bayta düşürür**, satır siler, `.tmp` bırakır ve sonra geri alır. ⇒ **TEK EL KURALI:** başka bir
  el (Cowork/Claude Code/editör) aynı anda yazarken koşulmaz. Bu oturumda iki el aynı anda koştu ve
  **sahte bir `T1b` kırmızısı** doğdu; tek elle üç kez tekrarlandığında **EXIT 0 / `TEMIZ`** ve
  `tek-kopya-mutant.py` **11/11** ölçüldü. Kırmızı gördüğünde **önce tek elle tekrar koş**, sonra rapor et.

---

## 8. BEYAN EDİLMİŞ SINIRLAR (gizlenmiyor — dördü denetçi tarafından ölçüldü)

1. 🔴 **`D8` ETİKETİ ölçer, BAĞIMLILIĞI ölçmez.** Denetçi bir "koparma" mutantıyla ölçtü: vaka 17'nin
   fikstürü 7 kimlikten 3'e indirilip `pin` etiketi **bırakılırsa** altın küme `27/27 GECTI` der **ve**
   `M112` de ısırmaz olur. Yani etiket, sabitin bir üst katına taşınmış hâlidir ve **aynı şekilde
   bayatlayabilir**. Bu boşluğu kapatan tek şey **kriter 8'in içerik ayağıdır** (`M111`/`M112`'nin
   beklenen `[KALDI]` kümesini gerçekten üretmesi). **Zincir budur; kriter 8 gevşetilirse boşluk açılır.**
2. **Vaka numarası etiketten ayrıştırılır** ve yalnız `pin` taşıyan vakalar ayrıştırılır. `pin`
   taşımayan bir vakanın etiketi numarasız yazılırsa kontrol bunu **görmez** — bilinçli daraltma;
   alternatifi 26 vakanın tamamını elden geçirmekti.
3. **Sabit `int` demetidir** ⇒ `str(n)` asla `"20b"` üretemez; `D8` ileride **harfli** bir vakayı
   (`20b`, `22b`) pinleyemez. Bugün zararsız (16/17 tamsayı), kayda geçti.
4. **Vaka 20b hâlâ İKİ bağımsız şeyi ölçüyor** (`D7` seviye-duyarlılığı + muafiyet tavanının üstten
   pini) ⇒ düştüğünde hangi sözleşmenin kırıldığı tek başına belli olmaz. Bu spec'te **düzeltilmiyor**
   (bölmek altın kümeyi `27 → 28` yapar ve `D5` onarımıyla karışır). Kayıtlı borç.
5. **Genel bir çapraz-atıf kapısı YOKTUR.** `D8` yalnız `LISTE_ESIGI` pinini ölçer; koddaki diğer
   yorum-atıfları ölçülmez. `BORCLAR.md`'ye yazılacak.
6. **`GOREV-A9b`'nin kriter 11'i olduğu gibi kalır** — artık gereksizdir (kâğıt kontrolün yerini koşan
   kod aldı) ama spec **kilitlidir** ve tarih düzeltilmez (K73).
7. **Kriter 9'un "kendi dosyasını denetle" hâli KALDIRILDI.** Denetçi ölçtü: kapı kendi `.py`'sine
   koşulduğunda `HUKUM: KIRMIZI` (6 adet `[KIRMIZI] I1`) veriyor — çünkü altın küme fikstürü `_TEMIZ`
   sahte mutant tablosu ve `M` önekli kimlik dizgeleri taşıyor. Bu **1.2.0'da da böyleydi**; kriter
   doğuştan sağlanamazdı. Öz-tutarlılık artık **spec belgesi üzerinden** ölçülür (kriter 9).

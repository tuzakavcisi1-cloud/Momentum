# GOREV — `araclar/iddia-kapisi.py` **1.1.0 → 1.2.0** onarımı (A9 **kriter 12**'yi kapatır) · **v2**

> **Yazan el:** Cowork · **Build:** Claude Code · **Doğrulama:** Cowork, bağımsız (K26).
> **Neden bu bölünme PAZARLIKSIZ (K34-f):** aracı **Cowork yazdı** — ölçüldü, çıkarım değil:
> `git log --diff-filter=A -- araclar/iddia-kapisi.py` ⇒ tek commit **`ebf7f62`** (28 Tem 2026 07:31 +03:00);
> `git show --stat ebf7f62` o commit'in **`PROJE_HAFIZA.md` (+212 satır) · `DURUM.md` · `PROJE_RADAR.jsonl`**
> ile **birlikte** geldiğini gösteriyor ve hafıza/durum/defter yazmak `CLAUDE.md` rol bölümüne göre
> **Cowork'ün işidir**. `PROJE_HAFIZA.md` K74 de aynısını yazmış. ⇒ **Onaran el Claude Code'dur.**

> ### v1 → v2 (aynı gün, oturum 44)
> v1 (**18.890 b · `8C195031`**) **bir** bağımsız denetim turu gördü; tur **iki mercekle** koştu
> (araç tekniği · ölçülebilirlik) ve **14 bloker + 14 majör** buldu. Denetçiler kâğıtla yetinmedi:
> iddiaları aracın gerçek kodu üzerinde **koşarak** ölçtüler. **Dördü mimariyi değiştirdi** ⇒ v2:
>
> | # | v1'in kusuru | ölçüm | sonuç |
> |---|---|---|---|
> | 1 | Kriter 2 *"`I3` KIRMIZI bulgu YOK"* diyordu | `iddia-kapisi.py:293` `I3`'ü **daima SARI** basar; `:462` hüküm yalnız KIRMIZI'ya bakar. Üç hayalet `I3` varken ölçülen çıktı: `HUKUM: TEMIZ`, EXIT 0 | 🔴 Kriter **yanlışlanamazdı**: `D1` hiç uygulanmasa bile yeşil yanardı ⇒ onarımın **asıl sebebi denetimsizdi**. Kriter artık **sayımla** ölçülür |
> | 2 | Yeni altın küme vakalarını mevcut harness'a bıraktı | `_vaka()` yalnız `denetle()` çağırıyor; vaka 13–17 `kanit_mutantlari()` içinde yaşıyor (diske bakar), vaka 20–21'in beklediği `I4`'ü `denetle()` **hiç üretmiyor** (ölçüldü: sıfır kez) | 🔴 **Yeni vakaların çoğu ifade edilemezdi.** `D0` doğdu: saf çekirdek ayrımı **spec'te adlandırıldı** |
> | 3 | `_vaka()`'nın seviye körlüğünü görmedi | `kodlar = sorted({k for _s, k, _m2 in bulgular})` — `[BILGI] I1` ile `[KIRMIZI] I1` **ayırt edilemiyor**. Dahası mevcut vaka 10 `beklenen=[], olmamali=()` yazılmış ⇒ `all([]) and not any(())` **daima True**; denetçi muafiyet mekanizmasını **tamamen sildi**, vaka yine `[GECTI]` dedi | 🔴 Altın kümede **bugün boş bir vaka var**. `D7` doğdu |
> | 4 | `satir_sha`'yı *"satır metni"*nden hesaplattırıyordu | `iddialar()` metni üç ayrı şekilde normalize ediyor (`_sadelestir_koruyarak` · `.lower()` · ham). Denetçi üç adayı ölçtü: **üç farklı sha** | 🔴 Build'de ölçülen sha ile koşumda hesaplanan farklı olursa muafiyet **sessizce ölür**. `D4` artık kaynağı **adıyla** söyler |
>
> **K53/1 gereği kâğıt turu KAPANDI.** v2 kilitlenir; kalan belirsizlik **build'e devredilir**.

---

## 0. NEDEN — ölçülmüş **dört** kusur

A9 kabul denetiminde kapı **5 bulgu** üretti; **beşi de yanlış-pozitif**, gerçek bulgu **0**. Kapı yanlış
konuşuyor ⇒ A9 kriter 12 kapanamıyor. Ölçüm (1 Ağu 2026, oturum 44):

| # | kusur | ölçülen kanıt |
|---|---|---|
| **K-1** | `I3` hayalet kanıt (3 yanlış-pozitif) | `kanit_mutantlari()` kimliği hem dosya adından **hem dosya İÇERİĞİNDEN** topluyor. A9'da `M10`/`M16`/`M75` **başka testlerin** ham loglardaki kendi kimlikleridir; A9 tablosunda böyle satır yok ⇒ *"hayalet kanıt"* |
| **K-2** | `I1` (2 yanlış-pozitif) | A9 spec satır **307**: *"ısırmayan tek bir … bile varsa DUR"* kalıbı → **deyim**, sayı iddiası değil. Satır **18** → **reddedilen v1'i anlatan tarihsel** cümle. Tablo **11** satır taşıyor. 🔴 Kapının yakaladığı iki ifade bu spec'e **dizge olarak yazılmadı** — sebebi §8/S7 |
| **K-3** | dairesel-kanıt filtresi **ön-ek kusuru** | `_ad.startswith("hukum"/"ozet")` yüzünden **`09-HUKUM.md`** (A7·A8·A9), **`T8-OZET.md`**, **`T9-ILERLEME-OZETI.md`**, **`TASIMA-00-OZET.md`** filtreden **kaçıyor**. A9'da yakalanmasının sebebi ad filtresi **değil**, **envanter eşiği** (tam **8**, sınırda) — 7 kimlik taşısaydı dairesel kanıt **sızardı** |
| **K-4** | **kör eşik** | Kodun kendi yorumu: *"eşik K40 gereği uydurulmadı: altın kümede **13. ve 14. vaka** ile pinlendi."* `altin_kume()` içinde **12 vaka** vardır; **13-14 yoktur**. `LISTE_ESIGI = 8` **hiç pinlenmemiş** — kapının belgesi **olmayan bir kanıta** atıf yapıyor |

🔴 **K-3 ve K-4 bu oturumda YENİ ölçüldü.** A9 devir notundaki *"dairesel-kanıt kalkanı SAĞLAM, ona
dokunma"* beyanı **yanlıştır**: kalkan A9'da **şans eseri** tuttu.

---

## 1. KAPSAM

**YAPILACAK:** `araclar/iddia-kapisi.py` **1.2.0** · `araclar/iddia-muafiyet.json` (yeni) · altın küme
**12 → 26 vaka** · `DURUM.md` §6 tablosundaki sayının tazelenmesi.

**KAPSAM DIŞI (beyan edilir, gizlenmez):**
- Türkçe **morfoloji/deyim çözümleme** — regex Türkçe'nin biçimbilgisini taşımaz; bu yol **denenmeyecek**.
- `LISTE_ESIGI` **değerinin** değiştirilmesi — 8 kalır; yalnız **pinlenir** (K-4).
- `I3`'ün SARI'dan KIRMIZI'ya **yükseltilmesi** — ayrı bir doktrin kararıdır (§8/S10).
- `oturum-sagligi.py`'nin ayrı ve **kayıtlı** yanlış-pozitifi (*alıntı ≠ beyan*) — **başka bir iştir**.
- `KANIT/slice-3c` altındaki eski kanıtların yeniden üretilmesi.

---

## 2. YAPILACAK DEĞİŞİKLİKLER

### D0 — **SAF ÇEKİRDEK AYRIMI** (v2'de doğdu)

Kapının ölçtüğü her kural **diske dokunmadan** test edilebilir olmalıdır. Bugün üç ayak bu şartı bozuyor.

1. `kanit_mutantlari(dizin)` **ikiye bölünür**:
   `kanit_topla(adlar) -> (kanitli, envanterler, elenen)` **saf fonksiyon** (girdi: dosya **adı** dizisi)
   **artı** ince bir disk sarmalayıcısı (`os.walk` yapar, adları toplar, saf fonksiyonu çağırır).
2. `denetle()` imzasına **`belge_yolu`** eklenir — muafiyetin `dosya` alanı bu değerle eşleşir.
3. `I1` muafiyet doğrulaması (**gerekçe · borç · tavan · sha · ölülük**) **saf çekirdeğe taşınır**;
   `muafiyet_yukle()` bundan sonra **yalnız yükler ve JSON hatasını bildirir**.
   *(Bugün `I4` yalnız `muafiyet_yukle()` içinde üretiliyor — ölçüldü: `denetle()` içinde **sıfır** kez.)*

### D1 — kanıt eşlemesi **YALNIZ DOSYA ADINDAN**

Bir mutantın kanıtlı sayılması için **dosya adının** onun kimliğini taşıması gerekir
(`02-MUTANT/M100.txt` → `M100`). **Dosya içeriği ARTIK TARANMAZ.**

- 🔴 **Kimlik çıkarımı HAM dosya adına uygulanır.** `_sadelestir()` sonunda **`.lower()`** vardır
  (ölçüldü) ve küçük harfe inen bir adda `M\d` deseni **hiç eşleşmez** — kimliği sadeleştirilmiş ada
  uygulayan tek satırlık bir refaktör kapıyı **tamamen körleştirir**.
- 🔴 **Desen sağlamlaştırılır:** `(?i)(?<![0-9A-Za-z])M(\d{1,3}[a-z]?)(?![0-9A-Za-z])`.
  Ölçülmüş gerekçe: bugünkü `\bM(\d{1,3}[a-z]?)\b` deseni **`_tmp_diff_M26.txt`** ve **`M12_kirmizi.txt`**
  adlarını **kaçırıyor** (`_` bir `\w` karakteridir, `\b` sağlanmaz) ve **`2026-M4.txt`** gibi bir tarih
  önekini **yanlışlıkla** `M4` sanıyor.

🟢 **Bu kapıyı SIKILAŞTIRIR, gevşetmez** ve ölçüldü: mutant kimliği taşıyan dosya adları
**A7** (`M74…M87.txt`) · **A8** (`M88…M97.txt`) · **A9** (`M98…M108.txt`) · **R9** (`MUTANT\M41…M45.txt`) ·
**R10** (`M46-{diff,kirmizi,yesil}.txt`) · **slice-3b** (`M3.txt`…) · **slice-3d** (`M1-ops-alani-yok.txt`…) ·
**slice-3e-G12** (`M58-diff.txt`…) dizinlerinin **tamamında** vardır. Bu envanter **kriter 13**'te yeniden ölçülür.
🔴 **`KANIT/slice-3c` altında mutant kimliği taşıyan dosya YOKTUR** ⇒ orada kapı **daha sıkı** olacaktır.
Bu **doğru davranıştır**: aracın var oluş sebebi zaten slice-3c'nin *36 beyan / 8 ham çıktı* kaçağıdır.

### D2 — dairesel-kanıt filtresi: `startswith` → **ad içinde geçiyor**

**Sadeleştirilmiş** dosya adı (`_sadelestir(ad)`) `ozet` **ya da** `hukum` dizgesini **içeriyorsa** o dosya
kanıt sayılmaz. Ön ek numarası (`09-`, `00-`, `T8-`, `TASIMA-00-`) artık kaçış yolu **değildir**.
🔴 **D1'den sonra da gereklidir:** bir kanıt dosyası `M98-M108-OZET.md` diye adlandırılırsa dosya adı
**iki kimlik** taşır ve filtre olmadan dairesel kanıt **yine sızar**.
🔴 **Ayrım net:** kimlik **ham** addan, eleme **sadeleştirilmiş** addan okunur.

### D3 — envanter reddi **dosya adına** taşınır ve **iki yönlü pinlenir**

`LISTE_ESIGI = 8` **değişmez**. Bir dosya **adı** `LISTE_ESIGI` veya daha fazla **farklı** mutant kimliği
taşıyorsa o dosya bir **envanterdir**, kanıt sayılmaz ve **`[ENVANTER REDDI]`** olarak basılır.
Eşik altın kümede **iki vaka** ile pinlenir (vaka 16: eşik değeri **reddedilir** · vaka 17: eşiğin **bir altı**
kabul edilir) ve **iki mutantla** kanıtlanır (M111 üst yön · M112 alt yön) — K-4 borcu böyle kapanır.

### D4 — `I1` için **satır-sha anahtarlı** muafiyet

Muafiyet kaydı `dosya` + `satir_sha` + `ham_sha` üçlüsüyle eşleşir. **Her alanın kaynağı adıyla yazılıdır**
— v1'in en ağır belirsizliği buydu:

- 🔴 **`satir_sha` = HAM DOSYA SATIRINDAN.** `sha256(metin.split("\n")[satir_no-1].strip().encode("utf-8")).hexdigest()[:16]`.
  *"Sadeleştirilmiş"* ya da *"küçük harfe indirilmiş"* satır **kullanılmaz**.
- 🔴 **`ham_sha` = `iddialar()`'ın DÖNDÜRDÜĞÜ `ham` alanından.** `sha256(ham.strip().encode("utf-8")).hexdigest()[:16]`.
  Bu alan `_sadelestir_koruyarak` (ve `yazi` türlerinde `.lower()`) sonrası hâldir; **başka normalizasyon uygulanmaz**.
- 🔴 **Tarama TÜM METİN üzerinde kalır**; satır numarası `metin.count("\n", 0, m.start()) + 1` ile **türetilir**.
  Ölçülmüş gerekçe: `_YAZI_TERS` deseni **satır sınırını aşabiliyor** (`"MUTANTLAR --\notuz alti"` bugün
  yakalanıyor) ve aracın kendi yorumu bu ters-sıra desenini *"slice-3c'nin GERÇEK kaçağı"* diye anıyor.
  Satır satır tarayan bir yeniden yazım o yeteneği **sessizce öldürür**.
- 🔴 **`dosya` karşılaştırması normalize edilir:** iki taraf da depo köküne göreli hâle getirilip
  `os.path.normpath(...).replace("\\", "/")` ile karşılaştırılır. Ölçülmüş gerekçe: JSON `/` ile yazılır,
  kriterler `\` ile çağırır ⇒ düz karşılaştırma Windows'ta **hiçbir zaman** tutmaz.
- `gerekce` en az **20 karakter**, `borc` **boş olamaz** ⇒ yoksa **`I4` KIRMIZI**.
- 🔴 **TAVAN: `dosya` alanına göre gruplanmış TÜM `I1` kayıtları üzerinde en çok 3.** Sayım **denetlenen
  belgeden bağımsızdır** — aksi hâlde başka bir belgeye yazılan yedi muafiyet **hiç görünmezdi**.
- Uygulanan muafiyet **`[BILGI] I1: MUAFIYET UYGULANDI [borc …]`** diye **gürültülü** basılır.
- 🔴 **`I5` (ölü muafiyet) `I1` için erken dönüşten ÖNCE ve YALNIZ denetlenen belgeye ait kayıtlar için**
  değerlendirilir. Ölçülmüş gerekçe: bugünkü `I5` döngüsü `kanitli is None` erken dönüşünün **ardında**;
  `--kanit` verilmeden koşan her denetimde ölü muafiyet **görünmez**. Kapsam sınırlaması olmadan ise A9'a
  ait muafiyetler A7 denetlenirken **ölü** sanılırdı.
- 🔴 **Kayıt türü `kod` alanıyla ayrılır** (`"I1"` / `"I2"`); `kod` yoksa **`I2` varsayılır** (eski biçim korunur).

### D5 — `LISTE_ESIGI` yorumu **yeniden yazılır** ve mekanik olarak pinlenir

Koda **`LISTE_ESIGI_PIN_VAKALARI = (16, 17)`** sabiti eklenir; yorum **bu sabiti anar** ve altın küme
koşumu sabiti çıktıya **basar**. Yorumun eski gövdesi de yeniden yazılır: bugünkü gerekçe eşiği bir dosyanın
**içeriğine** dayandırıyor, ama D1'den sonra içerik **hiç okunmayacak** ⇒ o gerekçe, artık koşmayan bir yola
atıf yapan **ikinci bir kör atıf** olurdu. K-4'ün sınıfı tam olarak budur.

### D6 — **tek sürüm dizgesi**

Bugün sürüm **üç yerde** yazılı ve **iki farklı değer** taşıyor: modül başlığı `1.0.0`, `SURUM` sabiti
`1.1.0`, `DURUM.md` §6 `1.1.0`. Üçü de **`1.2.0`** olur. *(v1 bu satırda **kendi sayı iddiasını** yanlış
yazmıştı — sayı iddialarını denetleyen bir spec'in kendi sayısı tutmuyordu; düzeltildi.)*

### D7 — `_vaka()` **seviye-duyarlı** hâle gelir

Altın küme vakaları artık **`(SEVIYE, KOD)` çiftleri** üzerinde karşılaştırır. Ölçülmüş gerekçe iki katlıdır:
**(a)** bugünkü `_vaka()` seviyeyi **atıyor** ⇒ *"`I1` susar ama `[BILGI]` basılır"* ifade **edilemiyor**;
**(b)** `beklenen=[]` ve `olmamali=()` yazılan bir vaka `all([]) and not any(())` yüzünden **daima geçer** —
denetçi muafiyet mekanizmasını **tamamen silip** mevcut vaka 10'u koşturdu ve vaka **yine geçti**.
🔴 **Bu bir regresyon onarımıdır:** mevcut altın kümenin **boş vakası** bu değişiklikle kapanır.

---

## 3. `araclar/iddia-muafiyet.json` — ŞEMA ve BAŞLANGIÇ İÇERİĞİ

Dosya bir **JSON dizisidir**. `I2` (mutant) kayıtları **eski şemayı korur** (`kod` alanı yoksa `I2`
varsayılır); `I1` kayıtları yenidir.

```json
[
  {
    "kod": "I1",
    "dosya": "GOREV_CLAUDE_CODE/GOREV-A9-cakisma-cozum-metin-kaybi.md",
    "satir_sha": "<olculecek>",
    "ham_sha": "<olculecek>",
    "borc": "ARAC-YANLIS-POZITIFI",
    "gerekce": "A9 spec satir 307 bir DEYIMDIR; Turkcede 'bir' burada sayi degil belirsiz tanimliktir. Kapinin I1 ayagi deyimi toplam iddiasindan ayirt edemiyor. Olculdu: bu kalip tum GOREV_CLAUDE_CODE/*.md icinde YALNIZ o dosyada geciyor, yani sinif tekrar etmiyor; regex daraltmak kapsama kaybi olurdu. Satir degisirse bu muafiyet OLUR."
  },
  {
    "kod": "I1",
    "dosya": "GOREV_CLAUDE_CODE/GOREV-A9-cakisma-cozum-metin-kaybi.md",
    "satir_sha": "<olculecek>",
    "ham_sha": "<olculecek>",
    "borc": "ARAC-YANLIS-POZITIFI",
    "gerekce": "A9 spec satir 18, o spec'in 0. bolumunde REDDEDILEN v1'in ne yaptigini anlatan TARIHSEL bir cumledir; yururlukteki tablonun toplami degildir. Kapi tarihsel anlatimi yururlukteki iddiadan ayirt edemiyor. Satir degisirse bu muafiyet OLUR."
  }
]
```

🔴 **`satir_sha` ve `ham_sha` DEĞERLERİ BU SPEC'E YAZILMAZ — BUILD SIRASINDA ÖLÇÜLÜR.** Sebebi
ölçülmüştür: spec'e yazılan bir sha, spec ile disk arasında **bayat-kimlik** sınıfını doğurur (bu projede
beş kez ısırdı). Builder ikisini de A9 spec'inin **diskteki** hâlinden, **D4'te adı geçen kaynaklardan**
üretir; yakalanan ifadeyi kapının kendi çıktısından alır (kapıyı `--kanit` olmadan A9 spec'ine koşup
`I1` bulgularındaki ifadeyi okur) — spec'e **dizge olarak yazmaz**.

🔴 **`borc` alanı `BORCLAR.md`'ye YAZILMAZ — Onur'un kilidi (1 Ağu 2026).** Emsal `tazelik-muafiyet.json`
3. kaydıdır. İki gerekçe: **(a)** aynı borcu iki dosyaya yazmak, bu projede **beş kez ısırmış**
`kanonik-kopya` sınıfını davet eder; **(b)** `BORCLAR.md` payı **1.046 b**, T2 SARI eşiği **819 b** ⇒
~230 b üstü her ekleme kapıyı SARI yakardı. Muafiyet **her koşumda gürültülü basıldığı** için bu
**gizlenmiş sınır değildir**.

---

## 4. KABUL KRİTERLERİ

**Her kriterin GEÇME KOŞULU mekaniktir** (exit kodu ya da satır sayımı). İnsan yargısıyla geçilen kriter
yoktur — v1'in beş kriteri bu şartı sağlamıyordu, düzeltildi. Ham çıktılar `KANIT/A9b/` altına yazılır;
**koşum anında dosyaya yazılmayan çıktı sonradan üretilemez.**

| # | kriter | GEÇME KOŞULU (mekanik) | kanıt |
|---|---|---|---|
| 1 | `iddia-kapisi.py --altin-kume` | **EXIT 0** ve çıktıda `ALTIN KUME: GECTI (26/26)` | `00-ALTIN-KUME.txt` |
| 2 | Kapı, A9 spec'i + `KANIT\A9` üzerinde | **EXIT 0** · `I3` dizgesi taşıyan satır **tam 0** · `[KIRMIZI] I1` satırı **tam 0** · `[BILGI] I1: MUAFIYET UYGULANDI` satırı **tam 2** | `03-A9-YESIL.txt` |
| 3 | Kapı, A8 spec'i + `KANIT\A8` üzerinde | **EXIT 0.** EXIT ≠ 0 ⇒ kriter **KALDI**, dilim kapanmaz, ham çıktı + soru Cowork'e gider | `04-A8-REGRESYON.txt` |
| 4 | Kapı, A7 spec'i + `KANIT\A7` üzerinde | **EXIT 0.** Aynı kural | `05-A7-REGRESYON.txt` |
| 5 | Muafiyet dosyası | **tam 2** kayıt, ikisi de `kod: "I1"`; **denetçi sha'ları A9 spec'inin diskteki hâlinden BAĞIMSIZ yeniden hesaplar** ve JSON'daki değerlerle **bit-bit** eşleşir; komut + iki çıktı yazılır | `01-SATIR-SHA.txt` |
| 6 | `sayi-tazeligi.py .` | **EXIT 0** (`DURUM.md` §6 satırı **26/26** yazmalı) | `06-SAYI-TAZELIGI.txt` |
| 7 | `spec-kapi-kapsama.py <bu spec>` | **EXIT 0** (araç **dizin kabul etmez**, K81) | `07-KAPI-KAPSAMA.txt` |
| 8 | **ÖZ-TUTARLILIK:** kapı, **bu spec** + `KANIT\A9b` üzerinde | **EXIT 0** · `I3` dizgesi taşıyan satır **tam 0** · `[KIRMIZI]` satırı **tam 0**. 🔴 **Kriter 9'dan SONRA ve mutantlar geri alınmışken** koşulur | `08-OZ-TUTARLILIK.txt` |
| 9 | `M109`–`M122` mutantları | **On dördünün her biri** için `M<n>.txt` şunları taşır: `[KALDI]` satırları **tam olarak** §6'daki beklenen küme kadar · `ALTIN KUME: KALDI (<n>/26)` satırı · `EXIT=1` satırı. Doğrulama `findstr` ile yapılır | `02-MUTANT\M<n>.txt` + `02-MUTANT\00-DOGRULAMA.txt` |
| 10 | `tek-kopya-kapisi.py .` | **EXIT 0** | `09-TEK-KOPYA.txt` |
| 11 | `LISTE_ESIGI` pin sabiti | `findstr /C:"LISTE_ESIGI_PIN_VAKALARI" araclar\iddia-kapisi.py` **EXIT 0** ve `findstr /C:"13. ve 14." araclar\iddia-kapisi.py` **EXIT 1** (hiç eşleşme yok) | `10-KOR-ESIK.txt` |
| 12 | git | `Test-Path .git\index.lock` ⇒ **`False`**. `status --porcelain` çıktısı **bilgi amaçlıdır**; kirli ağaç kriteri düşürmez | `11-GIT.txt` |
| 13 | ad envanteri | `KANIT\A7 A8 A9 R9 R10 slice-3b slice-3d slice-3e-G12` dizinlerinde `dir /b /s` çıktısı yazılır; **her dizinde en az bir dosya adı** yeni desenle kimlik veriyor | `12-AD-ENVANTERI.txt` |
| 14 | sürüm | `findstr /C:"1.2.0"` **üç yerde** (modül docstring · `SURUM` · `DURUM.md` §6) EXIT 0; `findstr /C:"1.1.0" /C:"1.0.0" araclar\iddia-kapisi.py` **EXIT 1** | `13-SURUM.txt` |

---

## 5. KAPILAR

### G17 — `iddia-kapisi.py` 1.2.0 kendi kanıtı (altın küme) + gerçek depo koşumu

**KURAL ENVANTERİ** — bu kapının zorladığı adlandırılmış kurallar:

| kural | ne zorlar |
|---|---|
| `D0` | saf çekirdek ayrımı: `kanit_topla(adlar)` saf · `denetle(belge_yolu)` · muafiyet doğrulaması çekirdekte |
| `D1` | kanıt eşlemesi **yalnız HAM dosya adından**, sağlamlaştırılmış desenle; içerik **taranmaz** |
| `D2` | dairesel-kanıt filtresi **sadeleştirilmiş** adın **içinde** arar |
| `D3` | envanter reddi dosya **adına** uygulanır; `LISTE_ESIGI = 8` **iki yönlü** pinlenir |
| `D4` | `I1` muafiyeti: kaynakları adlandırılmış sha'lar · yol normalizasyonu · tavan · kapsamlı `I5` |
| `D5` | `LISTE_ESIGI` yorumu **var olan** vaka numaralarına, **sabit üzerinden** atıf yapar |
| `D6` | tek sürüm dizgesi `1.2.0` — üç yer, tek değer |
| `D7` | `_vaka()` **(SEVIYE, KOD)** çiftleriyle karşılaştırır; boş-beklenti vakası imkânsızlaşır |

Kapı **iki ayakla** ölçülür ve **ikisi de** yeşil olmadan geçmez:

- **G17-a (altın küme, 26 vaka).** Vakaların **tamamı saf fonksiyonlar** üzerinde koşar — bu ancak `D0`
  uygulandıktan **sonra** doğrudur ve v1'in en ağır kusuru bu şartı sağlamadan iddia etmesiydi.
  Yeni vakalar:

  | vaka | ne ölçer | beklenen |
  |---|---|---|
  | 13 | ad `M100.txt`, içerik `M10` taşıyor (D1) | **hayalet YOK** — `I3` susar |
  | 14 | kanıt adı `09-HUKUM.md` — ön ek **numaralı** (D2) | **elenir**, kanıt sayılmaz |
  | 15 | kanıt adı `T8-OZET.md` — ön ek **harfli** (D2) | **elenir**, kanıt sayılmaz |
  | 16 | dosya **adı** 8 farklı kimlik taşıyor (D3, eşik) | **`[ENVANTER REDDI]`**, kanıt sayılmaz |
  | 17 | dosya **adı** 7 farklı kimlik taşıyor (D3, eşiğin altı) | **kabul edilir** ⇒ eşik alttan pinlendi |
  | 18 | `I1` muafiyeti: üç alan da tutuyor (D4) | **`("BILGI","I1")` VAR · `("KIRMIZI","I1")` YOK** |
  | 19 | `satir_sha` tutmuyor (D4) | muafiyet **ölür**, `("KIRMIZI","I1")` |
  | 20 | tavan aşıldı: bir belgede 4 muafiyet (D4) | **`("KIRMIZI","I4")`** |
  | 20b | tavan sınırında: bir belgede 3 muafiyet (D4) | **`I4` YOK** ⇒ tavan üstten pinlendi |
  | 21 | `gerekce` 20 karakterden kısa (D4) | **`("KIRMIZI","I4")`** |
  | 22 | muafiyet hiçbir iddiayı örtmüyor, **aynı** belge (D4) | **`("SARI","I5")`** |
  | 22b | muafiyet **başka** belgeye ait, bu belge denetleniyor (D4) | **`I5` YOK** ⇒ kapsam pinlendi |
  | 23 | `ham_sha` tutmuyor, `satir_sha` tutuyor (D4) | muafiyet **ölür**, `("KIRMIZI","I1")` |
  | 24 | muafiyetteki yol `/`, denetlenen yol `\` (D4) | **eşleşir** ⇒ muafiyet uygulanır |

- **G17-b (gerçek depo):** kriter 2, 3, 4, 8, 13. **Altın küme geçtikten SONRA** koşulur.
  🔴 Bu sıra **pazarlıksızdır**: aracın kendi doğuş anında altın küme geçmiş, gerçek `KANIT/slice-3c/`
  üzerinde koşulunca **iki dairesel-kanıt yolu** ortaya çıkmıştı (K67). Altın küme **yeterli değildir**,
  yalnız **gerekli**dir.

---

## 6. MUTANTLAR

**On dört mutant; hepsi statik ⇒ K53/3 gereği tavansız.** Her mutant uygulanır, altın küme koşulur,
`[KALDI]` satırları ve `EXIT=1` ölçülür, mutant **geri alınır**, ham çıktı `KANIT/A9b/02-MUTANT/M<n>.txt`
dosyasına yazılır. **Beklenen düşen vaka kümesi tam olarak aşağıdadır** — fazlası da eksiği de kriter 9'u düşürür.

| # | mutant | kapı / kural | beklenen gözlem |
|---|---|---|---|
| **M109** | `kanit_topla` dosya **içeriğini** de tarasın | `G17` / `D1` | vaka **13** KALIR ⇒ `25/26` |
| **M110** | dairesel filtre `startswith`e döndürülsün | `G17` / `D2` | vaka **14** ve **15** KALIR ⇒ `24/26` |
| **M111** | `LISTE_ESIGI` **999** yapılsın | `G17` / `D3` | vaka **16** KALIR ⇒ `25/26` |
| **M112** | `LISTE_ESIGI` **7** yapılsın | `G17` / `D3` | vaka **17** KALIR ⇒ `25/26` |
| **M113** | `satir_sha` karşılaştırması atlansın | `G17` / `D4` | vaka **19** KALIR ⇒ `25/26` |
| **M114** | muafiyet tavanı kaldırılsın | `G17` / `D4` | vaka **20** KALIR ⇒ `25/26` |
| **M115** | `gerekce` uzunluk denetimi kaldırılsın | `G17` / `D4` | vaka **21** KALIR ⇒ `25/26` |
| **M116** | kullanılmayan muafiyet sessizce atılsın | `G17` / `D4` | vaka **22** KALIR ⇒ `25/26` |
| **M117** | `ham_sha` karşılaştırması atlansın | `G17` / `D4` | vaka **23** KALIR ⇒ `25/26` |
| **M118** | yol normalizasyonu kaldırılsın | `G17` / `D4` | vaka **24** KALIR ⇒ `25/26` |
| **M119** | `LISTE_ESIGI_PIN_VAKALARI` **(13, 14)** yapılsın | `G17` / `D5` | **kriter 11** KIRMIZI (altın küme etkilenmez) |
| **M120** | `SURUM` **1.1.0** bırakılsın | `G17` / `D6` | **kriter 14** KIRMIZI (altın küme etkilenmez) |
| **M121** | `denetle()`'den `belge_yolu` parametresi kaldırılsın; muafiyet `dosya` alanına **bakmasın** | `G17` / `D0` | vaka **22b** ve **24** KALIR ⇒ `24/26` |
| **M122** | `_vaka()` karşılaştırması **yalnız KOD** kümesine döndürülsün (seviye atılsın) | `G17` / `D7` | vaka **18** ve **20b** KALIR ⇒ `24/26` |

🔴 **M121 ve M122 neden gerekliydi (v2'de eklendi):** v2'nin ilk hâli `D0` ve `D7` için *"mutantı, vakaların
varlığının kendisidir"* diye yapısal bir gerekçe yazmıştı. `spec-kapi-kapsama.py` bunu **kabul etmedi** ve
`[S2] MUTANTSIZ KURAL` verdi — **haklı olarak**: gerekçe biçimli bir borç kaydı değildi ve *"kapı borçlanamaz,
yalnız kural borçlanabilir"* kuralının kenarından dolaşıyordu. Ölçüm kazandı, gerekçe kaybetti; iki kural
artık **gerçek mutantla** kanıtlanıyor.

🔴 **`M<n>.txt` dosyası, mutant uygulanmışken alınan HAM terminal çıktısını taşır** — özet değil.
Dosya adı kimliği taşımak **zorundadır** (D1'den sonra kapının kanıt ölçüsü budur).

## 6b. MUTANT BORCU

**BORÇ YOK.** v1'de `D5` ve `D6` mutantsız beyan edilmişti; v2'de ikisi de **M119** ve **M120** ile
kapandı ve ölçümleri kriter **11** ve **14**'e bağlandı. *(v1'in `D6` borcu ayrıca **fiilen yanlıştı**:
gerekçesi ölçümü `--altin-kume` çıktısındaki sürüm satırına dayandırıyordu, ama o kip **hiçbir sürüm
satırı basmıyor** — denetçi ölçtü. Gerekçenin yanlışlığını hiçbir kapı görmedi, çünkü
`spec-kapi-kapsama.py` borcu **yalnız uzunluğuyla** kabul ediyor.)*

---

## 7. ORTAMI KİM KALDIRIR (K80)

🟢 **Bu spec cihaz, emülatör, veritabanı ya da canlı sunucu İSTEMEZ** ve bu bir varsayım değil, kapsamın
sonucudur: değişen tek şey **saf Python** bir betik ve bir **JSON** dosyasıdır; ağ, DB, Flutter ve Android
**kullanılmaz**. Gereken tek ortam: `python` + depo kökü.

🔴 **Yine de ölçülecek üç ortam gerçeği (K80'in ruhu — beyan değil ölçüm):**
1. `python --version` çıktısı `KANIT/A9b/00-ortam.txt`'e yazılır **(kriter 9'un doğrulama dosyası bunu anar)**.
2. Betikler **`PYTHONIOENCODING=utf-8`** ile koşulur — bu makinede `python` stdout **cp1254**'tür ve
   `⇒` gibi bir karakter `UnicodeEncodeError` ile **kabuğu öldürür** (ölçülmüş, `DURUM.md` §7).
3. EXIT kodu okunacak her yerde **`cmd /v:on /c "… & echo !ERRORLEVEL!"`** kullanılır;
   **`%ERRORLEVEL%` KÖRDÜR** ve sahte `0` verir (ölçülmüş, `DURUM.md` §7).
   🔴 **Boru (`|`) kullanılan yerde `!ERRORLEVEL!` son komutun kodudur** — `findstr` ile doğrulama yapan
   kriterlerde bu **kasıtlıdır** (kriter 11 ve 14 zaten `findstr`'ın kodunu ister), ama kriter 1–8'de
   **boru kullanılmaz**; çıktı dosyaya yönlendirilir ve EXIT ayrıca basılır.

---

## 8. BEYAN EDİLMİŞ SINIRLAR (gizlenmiyor)

- **S1.** D1'den sonra kapı, kanıtın **VARLIĞINI** ölçmeye devam eder; mutantın gerçekten **ısırdığını**
  ölçmez. Bu sınır 1.1.0'da da vardı ve **kalkmıyor**.
- **S2.** D1, kanıt disiplinini **dosya adına** bağlar. Bir dilim mutant çıktısını tek bir toplu dosyaya
  yazarsa kapı onu **kanıtsız** sayacaktır. Bu **kasıtlıdır**; `KANIT/slice-3c` bugün bu durumdadır.
- **S3.** `I1` muafiyeti **satır bazlıdır**. Aynı deyim **başka bir satıra** taşınırsa muafiyet ölür ve
  kapı yeniden ısırır — istenen davranış budur, ama bakım maliyeti **vardır** ve saklanmıyor.
- **S4.** Muafiyet tavanı (3) bugün bilinen ihtiyacın (**2**) bir üstüdür. v1 bunu *"ölçülmedi"* diye
  beyan edip geçiyordu; **bu bir borcu sınır kılığında saklamaktı.** v2'de tavan altın kümede **iki yönlü
  pinlendi** (vaka 20 üstten, vaka 20b sınırdan) ⇒ artık uydurulmuş değil, **ölçülen** bir eşiktir.
- **S5.** Bu spec `oturum-sagligi.py`'nin **ayrı** yanlış-pozitifini (*alıntı ≠ beyan*) **kapatmaz**;
  o kusur `PROJE_HAFIZA.md` K97'de adıyla kayıtlıdır ve onarımı yine **ayrı el** ister.
- **S6.** `spec-kapi-kapsama.py` bu spec'te yalnız `## 5. KAPILAR` ve `## 6. MUTANTLAR` başlıklarını okur;
  **`## 4. KABUL KRİTERLERİ` bölümüne KÖRDÜR** ve **borcun doğruluğunu değil yalnız uzunluğunu** ölçer
  (v1'in yanlış `D6` gerekçesi tam bu körlükten geçmişti). Kriter 7'nin `EXIT 0` vermesi *"her kriter
  kapsandı"* demek **değildir**.
- **S7. 🔴 ALINTI ≠ BEYAN — BU SPEC'İN YAZIMINDA ÖLÇÜLDÜ.** v1'in ilk hâli, kapının A9'da yakaladığı iki
  ifadeyi **dizge olarak** taşıyordu (kusuru anlatmak için). Kapı o metin üzerinde koşulduğunda **dört
  `I1` KIRMIZI** verdi: alıntıları **yeni birer sayı iddiası** sandı. Yani belgeyi düzelten metnin kendisi
  kapıyı tetikliyordu. ⇒ **`ham_sha` tasarımının gerçek sebebi budur.** Aynı sınıfın ikinci örneği aynı gün
  `oturum-sagligi.py`'de ölçüldü (K97/§2b) — **ortak kök: ölçüm araçları alıntı ile beyanı ayırt etmiyor.**
  Bu sınır **kalkmıyor**: bu spec de, onarılan kapı da *"kapının yakaladığı dizgeyi belgede tekrar etme"*
  kuralına uymak zorundadır. Kriter 8 tam olarak bunu ölçer.
- **S8. Eşiğin ALANI değişti, değeri yeniden ölçülmedi.** `LISTE_ESIGI = 8` bir dosyanın **içeriğinde**
  kaç kimlik geçtiğine göre kalibre edilmişti; D3 aynı sayıyı **dosya adına** taşıyor. Vaka 16/17 eşiği
  **mutant-yakalanabilir** kılar (≤7 ⇒ vaka 17 kırılır, ≥9 ⇒ vaka 16 kırılır) ama *"8, ad alanı için doğru
  sayıdır"* iddiası **ölçülmedi**. Gerçek depoda bugün ad alanında eşiğe ulaşan **hiçbir dosya yok**.
- **S9. Dizin adındaki kimlik görünmez.** D1 yalnız **dosya** adına bakar; `KANIT/x/M58/cikti.txt` gibi
  bir düzen kanıtsız sayılır. Bugünkü depoda böyle bir düzen **yok** (kriter 13 bunu ölçer).
- **S10. `I3` SARI kalıyor.** Hayalet kanıt hükmü KIRMIZI'ya **yükseltilmedi** — bu ayrı bir doktrin
  kararıdır ve Onur'un kilidini ister. Bu spec bunun yerine kriter 2 ve 8'i **satır sayımıyla** ölçer:
  `I3` dizgesi taşıyan satır **tam 0** olmalıdır. 🔴 **Sonuç aynı, yol farklı:** kapı hâlâ hayalet kanıtta
  EXIT 0 verebilir, ama **kabul kriteri** artık bunu yakalar.
- **S11. Aşırı-eleme ölçülmedi.** D2 adında `ozet`/`hukum` geçen **her** dosyayı eler; meşru bir kanıt
  `M95-ozet-diff.txt` diye adlandırılırsa **sessizce elenir**. Bu bilinçli bir tercihtir (dairesel kanıt,
  eksik kanıttan daha tehlikelidir) ama bir vakayla pinlenmedi.
- **S12.** `_RAKAM`/`_RAKAM_TERS` desenleri **büyük harfle yazılmış bölüm başlıklarındaki** ters-sıra sayı
  iddialarını kaçırıyor; aynı başlık küçük harfle yazılsa yakalanıyor (denetçi ölçtü). D4 bu fonksiyonlara
  dokunuyor ama bu boşluk **kapsam dışıdır** ve burada **adı konuyor**.
  🔴 **Bu maddenin kendisi S7'yi bir kez daha ısırttı:** v2'nin ilk hâli kusuru **örnek dizgeyle** anlatıyordu
  ve kapı o örneği **yeni bir sayı iddiası** sandı. Örnek kaldırıldı. *"Kapının yakaladığı dizgeyi belgede
  tekrar etme"* kuralı, bu spec'in yazımında **iki kez** ölçülerek doğrulandı.

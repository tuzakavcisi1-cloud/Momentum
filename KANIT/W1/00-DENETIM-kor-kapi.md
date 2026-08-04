# W1 KİLİT ÖNCESİ BAĞIMSIZ DENETİM — mercek: KÖR KAPI + EŞDEĞER MUTANT

> **Denetçi:** bağımsız ajan (spec'i YAZMADI) · **Tarih:** 4 Ağu 2026 · **K127 gereği kilitten ÖNCE**
> **Denetlenen:** `GOREV_CLAUDE_CODE\GOREV-W1-web-yuruyen-iskelet.md` (19.941 b, 283 satır, mtime 12:52:14Z)
> **Hüküm:** 🔴 **KİLİTLENMEZ** — 3 BLOKER · 6 MAJOR · 3 MINOR

Bu denetim **yalnız** `## 5. KAPILAR` ve `## 6. MUTANTLAR` bölümlerini iki mercekle kırdı.
Her iddia için artefakt **fiilen açıldı** ve **birebir alıntılandı**; ölçülemeyenler `## NE ÖLÇÜLEMEDİ`
altında sayılıdır (o bölüm **boş değildir**).

---

## ÖZET TABLO

| # | sınıf | başlık |
|---|---|---|
| B1 | BLOKER | `G37/b` KÖR: "kalıcı" iddiası **açılış çekmesinden** ayırt edilemiyor |
| B2 | BLOKER | `G36/b`'yi düşüren **hiçbir mutant yok**; `M196` bu ayak bakımından **EŞDEĞER** |
| B3 | BLOKER | `D-W1-2`'nin `AddCors` yarısı **hiçbir ayakta ölçülmüyor**, mutantı da yok |
| M1 | MAJOR | `## 6b` "tavan TAM DOLU" **aritmetiği tutmuyor** ⇒ dört ayağın borcu **gerekçesiz** |
| M2 | MAJOR | `spec-kapi-kapsama.py` bu spec'te `## 6b`'yi **HİÇ okumuyor**; kriter 5 ≈ sıfır-bilgi |
| M3 | MAJOR | `M197`'nin beklentisi bir **YOKLUK** ve **pozitif kontrolü yok** (spec kendi kuralını çiğniyor) |
| M4 | MAJOR | `M191`'in reçetesi `T1`'in **yapılandırma yolu** ile çelişiyor ⇒ doğaçlama mutant riski |
| M5 | MAJOR | `M193b` **bilgi taşımıyor**; asıl yanlış-pozitif riski taşıyan ayak (`G35/c`) **kontrolsüz** |
| M6 | MAJOR | Kriter 7'nin **bayt-özdeşlik** iddiası `M197` için **boş** (kaynak dosyaya dokunmuyor) |
| m1 | MINOR | Başlık satırındaki mutant aralığı **bayat**: `M189`–`M197`, oysa `M198`/`M198b` var |
| m2 | MINOR | `G37/d`'nin ölçüm reçetesi **blok-aralığı demiyor** (`G35/b` diyor) — asimetrik titizlik |
| m3 | MINOR | `cors-kapisi.py` **iki dilli** olmak zorunda; `T2` altın kümesinde Dart vakası şartı yok |

**Sayı tutarlılığı sorusu (kriter 6 ↔ 7): ÖLÇÜLDÜ, TUTUYOR.** Tablo sayımı:
statik = `M189, M190, M191, M192, M193, M193b, M194, M198, M198b` = **9** ✔ ·
koşan = `M195, M196, M197` = **3** ✔ · kriter 6'nın adlandırdığı 8 ısıran + `M193b` susan = **9** ✔.
Burada kusur **yok**; kusur `M1`'de (sınıflandırmanın kendisi).

---

## 🔴 B1 — BLOKER · `G37/b` KÖR: "KALICI" İDDİASI SUNUCU ÇEKMESİNDEN AYIRT EDİLEMİYOR

**Nerede:** spec `## 5` → `### G37` → ayak **b** (spec satır ~146)

**Spec ne diyor (birebir):**
> **b)** Görev eklenir → **sayfa yenilenir (F5)** → görev **hâlâ listededir**. *Ölçüm:* yenileme
> **sonrası** ikinci `MOMENTUM-G6-KANIT` satırı + ekran görüntüsü + listedeki başlığın metni.
> 🔴 "Kalıcı" iddiası **ancak bu ayak geçerse** yazılır.

**Ölçülen ürün gerçeği** — `src\client\lib\main.dart:43-56` (birebir):
```dart
  if (!const bool.fromEnvironment('DURUM_VITRINI')) {
    final kurulum = await _uretimKurulumOlustur();
    ...
    // KAPALI LISTE'nin 1. tetikleyicisi (acilis cekme turu) koşulur; ikisi
    unawaited(kurulum.dongu.turCalistir());
    unawaited(kurulum.dongu.cekmeTuruCalistir());
  }
```
Spec'in kendi `D-W1-5`'i de bunu yazıyor (birebir): *"Web'de tazeleme yolu: **açılış çekmesi +
Yenile + yerel yazma**."*

**Kusurun mekaniği (kanıt zinciri kapalı):**
1. `G38` **koşan backend** ister (`## 4b` ③ ile aynı oturumda ölçülüyor) ⇒ F5 anında sunucu **AYAKTA**.
2. F5 ⇒ `main.dart:56` **açılış çekme turu** koşar ⇒ görevler **sunucudan** iner.
3. İmleç aynı veritabanındadır — `main.dart:112` (birebir):
   `final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);`
   ve `main.dart:137`: `baslangicCursorJson: ayarlar.nextCursorJson,`
4. ⇒ **Yerel kalıcılık TAMAMEN çökerse imleç de kaybolur**, çekme **baştan** koşar, sunucu **tüm**
   görevleri geri verir ve görev listede **yine görünür**.

**Sonuç:** `G37/b` tarif edildiği gibi ölçülürse, **OPFS hiç çalışmayan** (ör. `chosenImplementation`
bellek-içi'ne düşmüş) bir ürün de **YEŞİL** geçer. Bu tam da kör kapı tanımıdır: kapı koşar, yeşil
döner, hedeflediği kuralı (*yerel kalıcılık*) **fiilen ölçmez**. `G37/c` (`missingFeatures` boş
değilse beyan et) bunu **kurtarmaz** — beyan bir ölçüm değildir ve `b`'nin hükmü zaten yazılmıştır.

**Kapatma yolu (bedava, koşan mutant istemez):** `G37/b` ölçümü **backend KAPALIYKEN** koşar.
Kapanış zaten repoda ölçülü bir adım: `netstat -ano | findstr :5298` **boş**. Sıra:
`G38` (backend AÇIK) → backend KAPAT (`netstat` ile ölç) → `G37/b` F5 (backend KAPALI) →
`verify.ps1`. Bu, projenin taç iddiası olan **çevrimdışı-öncelikliliği** de aynı anda ölçer.

**GÜVEN: KESİN** (üç dosya açıldı, üç birebir alıntı).

---

## 🔴 B2 — BLOKER · `G36/b`'Yİ DÜŞÜREN HİÇBİR MUTANT YOK; `M196` BU AYAK BAKIMINDAN EŞDEĞER

**Nerede:** `### G36` ayak **b** + `M191` + `M196` (spec satır ~135, ~201)

**Spec ne diyor (birebir):**
> **b)** *(negatif — kapının DARALTTIĞINI kanıtlar)* Aynı preflight `Origin: http://evil.local` ile
> ⇒ `Access-Control-Allow-Origin` **DÖNMEZ**. 🔴 Bu ayak olmadan `AllowAnyOrigin` de yeşil dönerdi;
> yani `G36` bu ayak olmadan **kördür**. → `M191` (statik) + `M196` (koşan)

**Sana sorulan 6. soru — ayak gerçekten yük taşıyor mu? İki katmanlı cevap:**

**(i) Spec'in gerekçesi YANLIŞ.** `G36/a` birebir şunu istiyor:
> ⇒ **2xx** **ve** yanıtta `Access-Control-Allow-Origin: http://localhost:5000` (🔴 **`*` DEĞİL**)

ASP.NET Core'da `AllowAnyOrigin()` yanıtı `Access-Control-Allow-Origin: *` olarak döner. `G36/a`
`*`'ı **zaten açıkça yasaklıyor** ⇒ düz `AllowAnyOrigin` **`b` olmadan da** `a` tarafından
kırmızıya düşürülür. Spec'in *"bu ayak olmadan `AllowAnyOrigin` de yeşil dönerdi"* cümlesi
**ölçülmeden yazılmış** bir gerekçedir.

**(ii) Ayak yine de yük taşır — ama spec'in yazdığı tehdide karşı değil.** `b`'nin gerçekten
yakaladığı sınıf **origin'i yankılayan** politikadır (`SetIsOriginAllowed(_ => true)`,
`.WithOrigins(...).SetIsOriginAllowed(...)`, ya da yapılandırmaya `"*"` yazmak): bu durumda
`localhost:5000` isteğine **tam da `http://localhost:5000`** döner ⇒ **`G36/a` YEŞİL**, ve yalnız
`evil.local` ayağı ısırır. **Spec bu sınıfı hiç adlandırmıyor ve o sınıfı üreten hiçbir mutant yok.**

**Asıl kusur — `M196` EŞDEĞER:**
> | M196 | **koşan** | `W1/G36/a` · `W1/G36/b` | İzinli origin `http://localhost:5001` yapılır,
> backend yeniden başlatılır | `G36/a` **KIRMIZI** (5000 artık izinli değil) — **negatif ayağın yük
> taşıdığını** kanıtlar |

İzin listesi `5001` yapıldığında `evil.local` preflight'ı **yine** başlık almaz ⇒ **`G36/b` YEŞİL
KALIR**. `M196` kapıyı `a` ayağından kırmızıya düşürür, `b`'nin çekirdek iddiasını (*politika
listede olmayan origin'i FİİLEN reddediyor*) **hiç yanlışlamaz**. Beklenen sonuç sütunu bunu kendi
yazıyor: *"`G36/a` KIRMIZI"* — `b` hiç anılmıyor. **Bu, eşdeğer mutantın tam tanımıdır**, ve
`M196`'nın kendi iddiası (*"negatif ayağın yük taşıdığını kanıtlar"*) **ölçmediği bir şeyi
kanıtladığını söylüyor**.

`M191` de kurtarmıyor: sınıfı **statik**, beklentisi *"`cors-kapisi.py` KIRMIZI"*. Canlı prob hiç
koşmuyor, backend yeniden başlatılmıyor ⇒ `G36/b` `M191` altında da **ölçülmüyor**.

**Kapatma yolu:** `M196`'yı, izin listesini `5001` yapmak yerine **origin yankılayan** politikaya
çevir (`.SetIsOriginAllowed(_ => true)`), beklenen: **`G36/a` YEŞİL kalır, `G36/b` KIRMIZI**.
Aynı maliyet (backend restart), ama artık `b`'nin çekirdek iddiasını düşürüyor. Not: bu değişiklik
`M196`'nın `G36/a` ayağını boşaltır — `M195` (politika tamamen kaldırılır) `a`'yı zaten örtüyor.

**GÜVEN: KESİN** (spec metni birebir; `AllowAnyOrigin ⇒ *` davranışı ASP.NET Core sözleşmesidir —
**bu makinede canlı ölçülmedi**, bkz. `## NE ÖLÇÜLEMEDİ`/2).

---

## 🔴 B3 — BLOKER · `D-W1-2`'NİN `AddCors` YARISI HİÇBİR AYAKTA ÖLÇÜLMÜYOR

**Nerede:** `D-W1-2` ↔ `G35/a` + `G35/b` ↔ `M189`/`M190`/`M193`/`M193b`

**Karar ne diyor (birebir, spec `## 3`):**
> **`D-W1-2` — POLİTİKA YALNIZ `Development`'ta KAYDEDİLİR VE KULLANILIR.**
> `builder.Services.AddCors(...)` **ve** `app.UseCors(...)` **ikisi de** `IsDevelopment()` koşulunun
> içindedir. Desen `K61`'in aynısıdır: üretimde politika **var olmaz**, susturulmaz.

**Kapı ne ölçüyor (birebir, `G35/b`):**
> **b)** `UseCors` çağrısı `IsDevelopment()` **koşul bloğunun metin aralığındadır**; dosya genelinde
> aramak yetmez (`D-W1-2`). *Ölçüm:* blok-aralığı araması. → `M190`

**Kusur:** ayak yalnız **`UseCors`**'u konumlandırıyor. `AddCors`'un nerede olduğunu **hiçbir ayak
ölçmüyor**. `builder.Services.AddCors(...)` `IsDevelopment()` bloğunun **dışında** (yani üretimde de)
kaydedilirse:
- `G35/a` yeşil (`AddCors` **geçiyor**, `UseCors` **geçiyor**),
- `G35/b` yeşil (`UseCors` hâlâ dev bloğunda),
- `G36` canlı kapısı Development'ta koşuyor ⇒ **yeşil**,
- ⇒ **`D-W1-2` ihlal edilmiş ürün, dört kapıdan da YEŞİL geçer.**

Kararın kendi gerekçesi *"üretimde politika **var olmaz**"* — ve *"var olma"* fiilinin öznesi
`AddCors` **kaydıdır**, `UseCors` değil. Yani ayak (b), kararın **asıl** yarısını ıskalıyor.

**İkinci katman — `G35/a`'nın `AddCors` koşulu da MUTANTSIZ.** Ayak (a) bir **AND**'dir
(*"`AddCors` **ve** `UseCors` **ikisi de**"*), ama ona bağlı üç mutantın **üçü de** yalnız
`UseCors`'u kurcalıyor:
> | M189 | ... | `app.UseCors(...)` satırı **silinir** |
> | M193 | ... | Gerçek `app.UseCors(...)` **silinir**, doğru satır **yalnız yorumda** bırakılır |
> | M193b | ... | Kod **bozulmaz**; dosyaya yalnız **fazladan yorum** eklenir |

⇒ `AddCors`'u **hiç aramayan** bir `cors-kapisi.py` **dokuz statik mutantın dokuzunu da** beklendiği
gibi geçer. AND'in yarısı **ölçülmemiş ve mutantsız**dır.

**Ölçülmüş bağlam (kör noktayı büyüten gerçek):** `Program.cs`'te **zaten** bir `IsDevelopment()`
bloğu var — `src\backend\Momentum.Api\Program.cs:49` (birebir):
```
49:if (builder.Environment.IsDevelopment())
51:    builder.Services.AddScoped<ICurrentUser, DevCurrentUser>();
```
Yani dosyada **en az iki** `IsDevelopment()` bloğu olacak (biri servis, biri middleware). Referans
uygulama `araclar\ss2-kapisi.py`'deki `_blok_ayikla` **İLK eşleşmeyi** alır (birebir docstring):
> `acilis_deseni` ile eslesen **ilk yerden** baslayip, o noktadaki acik suslu parantezle eslesen
> kapanisa kadar olan ARALIGI dondurur

Spec **hangi** `IsDevelopment()` bloğunun kastedildiğini yazmıyor. Bu `K126`'nın reçete-belirsizliği
sınıfının aynısıdır.

**Kapatma yolu:** `G35/b`'yi *"`AddCors(` **ve** `UseCors(` **ikisi de** `IsDevelopment()` blok
aralığındadır"* diye yaz (ve hangi blok — `builder.Environment` mi `app.Environment` mi —
adlandırılsın); `M190`'ın yanına **`M190b`** ekle: *`AddCors` dev bloğunun dışına taşınır, `UseCors`
yerinde kalır* ⇒ beklenen **KIRMIZI**. Statik sınıf **tavansızdır** (`K53/3`), bedeli saniyedir.

**GÜVEN: KESİN** (spec + `Program.cs:49` + `ss2-kapisi.py` docstring birebir okundu).

---

## 🟠 M1 — MAJOR · "TAVAN TAM DOLU" ARİTMETİĞİ TUTMUYOR ⇒ DÖRT AYAĞIN BORCU GEREKÇESİZ

**Spec ne diyor (birebir, `## 6` başı ve `## 6b`):**
> **Maliyet sınıfı (`K53/3`):** **koşan uygulama** isteyen mutant **3** ⇒ tavan **TAM DOLU**.
> ...
> Gerekçe: kalıcılığı düşürecek bir mutant ... **koşan uygulama** ister ve o sınıfın tavanı
> (3) `M195`–`M197` ile **doludur**.

**`K53/3`'ün kanonik metni (`CLAUDE.md`, birebir):**
> **Koşan uygulama** isteyen mutant (**emülatör/tarayıcı + yeniden derleme**) tavanı: **3 / dilim.**

**Ölçüm — üç "koşan" mutantın sınıfı:**

| mutant | tarayıcı gerekiyor mu | yeniden derleme gerekiyor mu | gerçek maliyet |
|---|---|---|---|
| `M195` (politika kaldırılır, backend restart) | **HAYIR** — `_preflight.py` bir Python probudur | HAYIR (backend restart) | ucuz |
| `M196` (izinli origin 5001, backend restart) | **HAYIR** — aynı prob | HAYIR; `T1` gereği değer **JSON'da** ⇒ salt restart | ucuz |
| `M197` (`--dart-define` kaldırılır) | **EVET** | **EVET** (`flutter run` yeniden) | pahalı |

⇒ `K53/3`'ün tanımladığı sınıfta **1** mutant var, **3** değil. **Tavan DOLU DEĞİL; 2 yuva boş.**
`## 6b`'nin tek gerekçesi bu aritmetiktir ⇒ **`G37/a`, `G37/b`, `G37/c` ve `G38/b` borcu
gerekçesizdir** (`K53/3`: *"gerekçesiz borç reddedilir"*).

**Ve boş yuvaya sığan somut bir mutant VAR** (spec *"yazılabilirdi ama eşdeğer olurdu"* diyor —
bu örnek eşdeğer değil): **`web/drift_worker.js` (ya da `web/sqlite3.wasm`) sunulan dizinden
kaldırılır/adı değiştirilir.** Dart **yeniden derlenmez** (bunlar statik varlıklardır; §2 tablosu
ikisinin de `src/client/web/` altında olduğunu ölçmüş). Beklenen: drift kalıcı olmayan
implementasyona **düşer** ⇒ `missingFeatures` **dolar** (`G37/c` ısırır) **ve** F5 sonrası görev
**kaybolur** (`G37/b` ısırır). Tek mutant, **iki mutantsız ayağı** birden kapatır — ve `B1`'in
önerdiği "backend KAPALI" ölçümüyle birleşince `G37`'nin taç iddiası ilk kez **gerçekten** ölçülür.

🔴 **`B1` + `M1` birleşince ağırlaşıyor:** `## 6b` şunu yazıyor —
> 🔴 **`G37` KAPISININ KENDİSİ BORÇLU DEĞİLDİR** — `G37/d` ayağı `M198`/`M198b` ile örtülüdür.

`G37`'nin başlığı *"WEB'DE AÇILIYOR VE **KALICI** (koşan tarayıcı)"*. `M198`/`M198b` bir **`print`
önekini** düşürüyor. Kapı kırmızı olur, ama düşen şey kapının **çekirdek iddiası değildir** ⇒
`G37` düzeyinde bunlar **eşdeğer mutantlardır**. `## 6b` bunun mekanik kapıyı susturmak için
eklendiğini kendisi itiraf ediyor (*"`[S1] MUTANTSIZ KAPI: G37`* verip EXIT 1 dönmesi üzerine
eklendi"*). Sonuç: **araç susturuldu, iddia ölçülmeden kaldı.**

**GÜVEN: KESİN** (spec + `CLAUDE.md` K53/3 birebir; maliyet sınıflaması `_preflight.py`'nin bir
Python probu olduğu spec beyanına dayanıyor — `T3`'te henüz yazılmadı, bkz. `## NE ÖLÇÜLEMEDİ`/3).

---

## 🟠 M2 — MAJOR · `spec-kapi-kapsama.py` BU SPEC'TE `## 6b`'Yİ HİÇ OKUMUYOR

**Spec ne iddia ediyor (birebir, `## 6b`):**
> `spec-kapi-kapsama.py` gerekçesiz borcu **reddeder**.

**Aracın gerçeği** — `araclar\spec-kapi-kapsama.py`, `borclar()` (birebir):
```python
    Bicim (satir basi): '- KURAL: <ad> | GEREKCE: <en az 20 karakter>'
    ...
        m = re.match(r"^\s*-\s*KURAL:\s*([^|]+)\|\s*GEREKCE:\s*(.*)$", s)
```

**W1'in `## 6b` satırı (birebir):**
> - **`W1/G37/a` · `W1/G37/b` · `W1/G37/c` — mutantsız.** Gerekçe: kalıcılığı düşürecek bir mutant

`KURAL:` öneki **yok**, `|` ayracı **yok** ⇒ regex **hiç eşleşmiyor** ⇒ `borclar()` **`{}` döndürür**.
`S4` (gerekçesiz borç), `S5` (kapı borçlanamaz), `S6` (gereksiz borç) **hiçbiri koşamaz**.
İddia bu belge için **ÖLÜ BEYAN**dır.

**Daha ağırı — `kurallar` kümesi de BOŞ.** Araç kuralları iki yerden çıkarır:
`envanter()` §5'teki **`|` ile başlayan tablo satırlarının 1. sütunundan**, `uc_baslik_kurallari()`
§3'teki **`### ` başlıklarından**. W1'de §5 **tamamen madde imli** (tablo satırı yok) ve §3
kararları **`### ` değil kalın paragraf** (`**\`D-W1-1\` — ...**`). ⇒ `kurallar = ∅` ⇒ `S2` de
imkânsız.

⇒ **Kriter 5'in (`spec-kapi-kapsama.py` EXIT 0) W1 üzerinde ölçtüğü TEK şey:** dört `G<n>` başlığının
her birine mutant tablosundan **en az bir atıf** olması + hayalet atıf yokluğu. Kapı başına **bir
bit**. `D-W1-1`…`D-W1-7` kararlarının **hiçbiri** kapsama ölçümüne girmiyor.

Bu, `K81` (başlık şeması) ve `K126` (sütun sırası) ile **aynı sınıfın üçüncü ısırışıdır**: spec,
aracın ayrıştıramadığı bir biçimde yazılıyor ve araç **hata vermek yerine sessizce temiz** dönüyor.

**Kapatma yolu (ucuz):** `## 6b`'deki dört borcu aracın biçimine çevir —
`- KURAL: W1/G37/b | GEREKCE: <≥20 karakter>` — **ve** `D-W1-1`…`D-W1-7`'yi §5'te bir tablo
sütununa ya da §3'te `### D-W1-1 — ...` başlığına taşı ki kapsama ölçümü kararları da görsün.
🔴 Ama önce `M1`: borç **gerekçesiz** olduğu için asıl doğru hamle borcu **biçimlendirmek değil,
kapatmaktır**.

**GÜVEN: KESİN** (aracın kaynağı ve spec metni birebir okundu; araç W1 üzerinde **koşturulmadı** —
bkz. `## NE ÖLÇÜLEMEDİ`/1).

---

## 🟠 M3 — MAJOR · `M197`'NİN BEKLENTİSİ BİR **YOKLUK** VE POZİTİF KONTROLÜ YOK

**Spec ne diyor (birebir):**
> | M197 | **koşan** | `W1/G38/a` | `--dart-define=SENKRON_SUNUCU_URL` **kaldırılır** (web
> `10.0.2.2`'ye gider) | `psql` sayımı **artmaz** ⇒ `G38/a` **KIRMIZI** |

**Spec'in kendi kuralı (birebir, `G35` pozitif kontrolü):**
> yokluk ölçen her ayak bir **varlık** kontrolü koşmak zorundadır.

ve `ORTAM.md:26` (birebir, ölçülmüş):
> ⇒ **`findstr` ile YOKLUK ölçen her ayak, AYNI dosyada bir VARLIK pozitif kontrolü koşmak
> ZORUNDADIR**

`M197`'nin beklenen sonucu **saf bir yokluktur** ("sayım artmaz") ve **hiçbir varlık kontrolü
şart koşulmuyor**. Aynı gözlemi üreten en az dört prosedür kusuru var: tarayıcı hiç açılmadı ·
görev eklenmedi (metin girildi ama `onSubmitted` tetiklenmedi) · `psql` yanlış tabloyu/filtreyi
saydı · uygulama hiç derlenmedi. Hepsi **"sayım artmadı"** verir ⇒ mutant **kendi prosedür
kusuruyla ayırt edilemez** şekilde "ısırmış" görünür. Bu, **eşdeğer mutantın kardeş sınıfıdır**:
kapı kırmızı, ama kırmızının sebebi iddia değil.

**Kapatma yolu (bedava):** `M197` koşumu **tek turda üç ölçüm** yapsın —
① define KALDIRILMIŞ hâlde **`W1-M197-A`** başlıklı görev eklenir ⇒ `psql`'de **YOK** ·
② define **geri konur**, uygulama yeniden koşar, **`W1-M197-B`** başlıklı görev eklenir ⇒ `psql`'de
**VAR** (pozitif kontrol) · ③ iki başlık **birebir** `KANIT/W1/`'e yazılır. Ayrıca `M197`'nin
gerçekten bir CORS/senkron kusuru ürettiğini ayırt etmek için tarayıcı konsolundaki ağ hatası da
yakalanmalı — yoksa `10.0.2.2`'ye giden istek tarayıcıda **CORS hatası** olarak değil **bağlantı
hatası** olarak düşer ve bu iki sınıf karıştırılır.

**GÜVEN: KESİN** (spec + `ORTAM.md:26` birebir).

---

## 🟠 M4 — MAJOR · `M191`'İN REÇETESİ `T1`'İN YAPILANDIRMA YOLUYLA ÇELİŞİYOR

**`T1` ne diyor (birebir):**
> **T1 — ÜRÜN KODU:** `src/backend/Momentum.Api/Program.cs`'e `D-W1-1`/`D-W1-2`'ye uyan CORS
> politikası; izinli origin listesi **`appsettings.Development.json`'da `Cors:AllowedOrigins`**.

**`M191` ne diyor (birebir):**
> | M191 | statik | `W1/G35/c` · `W1/G36/b` | `WithOrigins("http://localhost:5000")` →
> `AllowAnyOrigin()` | `cors-kapisi.py` **KIRMIZI** |

`T1` origin listesini **JSON'a** koyuyor; `M191` ise `Program.cs` içinde **birebir bir dize
literali** varsayıyor. Yapılandırma yolu seçilirse kod muhtemelen
`.WithOrigins(builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [])`
olur ve **`M191`'in mutasyon reçetesi uygulanamaz** ⇒ builder **doğaçlar** ⇒ doğaçlanan mutant
denetlenmemiştir; eşdeğerlik tam buradan sızar (`K127`'nin `M167` dersi).

**İkinci katman:** `G35/c` iki yolu da kabul ediyor (birebir):
> izinli origin `WithOrigins(` ile **açık dizeyle** ya da yapılandırma anahtarıyla verilir

⇒ **hiçbir statik ayak, izin listesinin gerçekten `http://localhost:5000` içerdiğini ölçmüyor.**
`D-W1-7` (spec'in *"en kolay kör noktası"* dediği şey) yalnız `G36/a` canlı ayağıyla ölçülüyor.
Kabul edilebilir bir tasarım, **ama beyan edilmemiş**: `## 8`'de bu sınır yazılı değil.

**Ölçülmüş bağlam:** `src\backend\Momentum.Api\` altında bugün **yalnız `appsettings.json` var**
(`dir /b appsettings*.json` ⇒ `appsettings.json`). `appsettings.Development.json` **YOK**, `T1` onu
oluşturacak. 🟢 `.gitignore` onu **dışlamıyor** (satır 10-11 yalnız `appsettings.*.Local.json` ve
`appsettings.Local.json`) ⇒ dosya repoya girecek; bu yönde kusur **yok** (ölçüldü).

**Kapatma yolu:** `T1`'de **hangi yolun** seçileceğini kilitle; `M191`'i seçilen yola göre yaz.
Yapılandırma yolu seçilirse `G35/c`'nin ikinci yarısını *"`Cors:AllowedOrigins` anahtarı okunur"*
diye **tek biçimde** yaz ve `## 8`'e *"izin listesinin DEĞERİ statik olarak ölçülmez, yalnız
`G36/a` canlı ölçer"* sınırını ekle.

**GÜVEN: KESİN** (dizin listesi ve `.gitignore` fiilen koşuldu).

---

## 🟠 M5 — MAJOR · `M193b` BİLGİ TAŞIMIYOR; ASIL RİSKLİ AYAK (`G35/c`) KONTROLSÜZ

**Sana sorulan 4. soru.** Spec (birebir):
> | M193b | statik | `W1/G35/a` | Kod **bozulmaz**; dosyaya yalnız **fazladan yorum** eklenir
> (`// app.UseCors(...)`) | `cors-kapisi.py` **SUSMALI** — yanlış-pozitif kontrolü; `M193` tek
> başına sıfır-bilgidir (`K133`/`M171c` dersi) |

**Ölçüm — bilgi asimetriktir:** `G35/a` bir **VARLIK** (presence) kontrolüdür. Bir varlık kontrolü
ancak dizgeyi **bulamazsa** kırmızı olur. Dosyaya **fazladan bir geçiş** eklemek bir varlık
kontrolünü kırmızıya düşüremez — yorum atlansa da, atlanmasa da. ⇒ `M193b`'nin "SUSMALI"
beklentisi, aracın yorum işleme kalitesinden **neredeyse bağımsız olarak** gerçekleşir. (Sıfır
değil: yorum ayıklayıcısı **yıkıcıysa** — ör. `//` görünce dosyanın kalanını yutuyorsa — ısırır.
Ama bu, `M193b`'nin adlandırdığı sınıf değil.)

**Asıl yanlış-pozitif riski `G35/c`'dedir** — o bir **YOKLUK** (absence) kontrolüdür (birebir):
> **c)** `AllowAnyOrigin` **hiç geçmez**

Bir yorumda geçen `// AllowAnyOrigin() YASAK — D-W1-1` satırı, yorum-kör bir aracı **DOĞRU ürün
üzerinde KIRMIZIYA** düşürür. `M191` bunu ölçmez (gerçek kodu değiştiriyor) ⇒ **`G35/c`'nin yorum
atlaması tamamen mutantsızdır.** Bu, `K135`'in ısırdığı sınıfın **aynadaki hâlidir** ve `D-W1-1`'in
metni gereği böyle bir yorumun yazılması **çok olası**.

**Kapatma yolu (statik, tavansız, saniyeler):** `M191b` ekle — *kod bozulmaz; `Program.cs`'e yalnız
`// AllowAnyOrigin() YASAK (D-W1-1)` yorumu eklenir* ⇒ beklenen **SUSMALI**. Bu, `M193b`'nin
almaya çalıştığı bilgiyi **gerçekten** taşır. `M193b` kalabilir (zararsız), ama tek başına
`## 6`'nın "yanlış-pozitif kontrolü var" iddiasını **karşılamıyor**.

🟢 Karşılaştırma için: **`M198`/`M198b` çifti sağlamdır** — `M198b` (gerçek `print` silinir, önek
yalnız yorumda kalır) `M193`'ün şeklindedir ve **ısırması beklenir**; bu bilgi taşıyan bir çifttir.

**GÜVEN: KESİN** (spec birebir; `ss2-kapisi.py`'nin ayıklayıcısının yıkıcı olmadığı ölçüldü —
`_yorumsuz_satirlar` tırnak-duyarlıdır).

---

## 🟠 M6 — MAJOR · KRİTER 7'NİN BAYT-ÖZDEŞLİK İDDİASI `M197` İÇİN BOŞ

**Sana sorulan 5. soru.** Kriter 7 (birebir):
> 7. **Üç koşan mutantın üçü de ısırır** ve her biri geri alındıktan sonra kaynak **bayt-özdeştir**
> (🔴 `git restore` **YASAK** — `core.autocrlf` onu bayt-özdeşlik için **kör** kılar; ikili yedek →
> bayt düzeyinde yama → yedekten `wb` geri yazma → `sha256` ölçümü. Referans:
> `KANIT/A11/_mutant_kosucu.py`).

**Ölçüldü — dayanaklar SAĞLAM:**
- `git --no-optional-locks config --get core.autocrlf` ⇒ **`true`** ✔ (iddia doğru)
- `KANIT\A11\_mutant_kosucu.py` **var** ve iddia edilen yöntemi uyguluyor (birebir):
  `5:sha256 ile BAYT-OZDESLIK dogrula. \`git restore\` KULLANILMAZ (ORTAM.md:` ·
  `39:    with io.open(p, "rb") as f:` · `44:    with io.open(p, "wb") as f:` ·
  `49:    return hashlib.sha256(b).hexdigest()[:8].upper()` ✔

**Kusur:** `M197` **hiçbir kaynak dosyaya dokunmuyor** — bir **komut satırı bayrağını** kaldırıyor
(`--dart-define=SENKRON_SUNUCU_URL`). ⇒ "geri alındıktan sonra kaynak bayt-özdeştir" `M197` için
**boş bir doğrudur** (vacuous) ve `_mutant_kosucu.py` ona **uygulanamaz**. Kriter 7 "üç mutantın
üçü" diyor ama fiilen **2/3** ölçüyor; üçüncüsü sessizce geçiyor.

Ayrıca `M196`, `T1` gereği muhtemelen **`appsettings.Development.json`'u** değiştirecek — yani
bayt-özdeşlik ölçümü **`.cs` dışında bir dosyayı** da kapsamalı. Spec bunu yazmıyor; `git status`
ile ölçen bir kabul adımı da yok.

**Kapatma yolu:** kriter 7'yi ikiye böl — *"**kaynak dosyaya dokunan** mutantlar (`M195`, `M196`)
için `sha256` bayt-özdeşliği; `M197` için **geri alma ölçümü = koşum komutunun birebir kaydı** ve
mutant sonrası `git --no-optional-locks status --porcelain` **boş**"*. Böylece üçüncü mutantın geri
alınması da **ölçülür**, varsayılmaz.

**GÜVEN: KESİN** (üç komut fiilen koşuldu, çıktıları yukarıda).

---

## 🟡 MINOR BULGULAR

**`m1` — Başlık satırındaki mutant aralığı BAYAT.** Spec satır 4 (birebir):
> **Kapılar:** `W1/G35`–`W1/G38` (K108: atıf daima kapsam önekli) · **Mutantlar:** `M189`–`M197`

Tabloda `M198` ve `M198b` **var** ve `## 6b` bunların sonradan eklendiğini kendisi anlatıyor;
başlık **güncellenmemiş** ⇒ `kanonik-kopya` sınıfı (K58 dersi). Düzelt: `M189`–`M198b`.

**`m2` — `G37/d`'nin ölçüm reçetesi `G35/b`'ye göre asimetrik.** `G35/b` açıkça *"blok-aralığı
araması"* diyor; `G37/d` ise yalnız (birebir) *"`cors-kapisi.py`, yorum satırları **atılarak**"*
diyor — oysa iddiası konumsal: *"`DriftWebOptions`'ın **`onResult` gövdesi** kod satırında
`MOMENTUM-G6-KANIT` önekini basar"*. Dosya-geneli arama, `print`'i ölü bir fonksiyona taşıyan
bir değişikliği **yeşil** geçirir. Ölçülen ürün (`veritabani.dart:180-183`, birebir):
`onResult: (sonuc) {` · `// ignore: avoid_print` · `print(` ·
`'MOMENTUM-G6-KANIT chosenImplementation=${sonuc.chosenImplementation} '`
⇒ önek `onResult:`ten **3 satır sonra**; satır-bazlı reçete zaten yetmez. Düzelt: `G37/d`'ye
*"`onResult:` açılışından kapanışına blok aralığı"* yaz (`ss2-kapisi.py`'nin `_blok_ayikla`'sı
bunu zaten yapıyor).

**`m3` — `cors-kapisi.py` İKİ DİLLİ olmak zorunda ama `T2` bunu şart koşmuyor.** Araç hem C#
(`Program.cs` → `G35/a-d`) hem Dart (`veritabani.dart` → `G37/d`; `signalr_json_sinyal.dart` →
`G38/c`) ayrıştıracak. İki fark: (i) Dart **iç içe blok yorumu** (`/* /* */ */`) destekler, C#
desteklemez — referans `_blok_yorumsuz` `metin.find("*/")` ile iç içe geçmeyi **görmez**;
(ii) C#'ta `@"..."` ve `"""..."""` dizeleri satır aşabilir, referans ayıklayıcı tırnak durumunu
**her satır başında sıfırlar**. `T2` yalnız *"kendi altın kümesi"* diyor; **her iki dil için de**
vaka şartı yazılmalı. 🟢 İyi haber: `ss2-kapisi.py` **tırnak-duyarlıdır** (`_yorumsuz_satirlar`'da
`tek`/`cift` izleniyor) ⇒ `WithOrigins("http://localhost:5000")` içindeki `//` yanlışlıkla yorum
sayılmaz — **eğer o desen kopyalanırsa**. Spec bu yeniden kullanımı şart koşmuyor; koşsun.

---

## 🟢 DOĞRULANAN İDDİALAR (beyanla yetinilmedi — artefakt açıldı)

| spec iddiası | ölçüm | sonuç |
|---|---|---|
| `G35` pozitif kontrol dizgesi `builder.Services.AddMediator` **gerçek** | `findstr` | ✔ `Program.cs:38:builder.Services.AddMediator();` |
| `G38/c` + `M194` hedefi `if (kIsWeb)` **gerçek** | `findstr` | ✔ `signalr_json_sinyal.dart:100:    if (kIsWeb) {` |
| §2: `kIsWeb` tüm `lib/`'de **yalnız 2**, ikisi de o dosyada | `findstr /s` | ✔ satır 5 (import) + 100 |
| `G37/d` + `M198` hedefi `MOMENTUM-G6-KANIT`, `onResult` içinde | dosya okundu | ✔ `veritabani.dart:180-186` |
| `D-W1-4`: `_senkronSunucuUrl` zaten `String.fromEnvironment` | dosya okundu | ✔ `main.dart:23-24` |
| `ORTAM.md`: `findstr` aynı dosyada dizge kaçırıyor | `ORTAM.md:26` | ✔ birebir var |
| `ORTAM.md`: `verify.ps1` çalışan backend'le EXIT 1 + 36 `MSB3026` | `ORTAM.md:37` | ✔ birebir var |
| `ORTAM.md`: `flutter test --platform chrome` sonuç üretmiyor | `ORTAM.md:29` | ✔ birebir var |
| `ORTAM.md`: prob `clientId` GUID olmazsa **500** | `ORTAM.md:43` | ✔ birebir var |
| `core.autocrlf` aktif (kriter 7'nin dayanağı) | `git config` | ✔ `true` |
| `KANIT/A11/_mutant_kosucu.py` var, `rb`/`wb`/`sha256` yapıyor | dosya okundu | ✔ |
| `.gitignore` `appsettings.Development.json`'u dışlamıyor | `findstr` | ✔ satır 10-11 yalnız `*.Local.json` |
| `## 8`/7'nin kendi testi: görev ekleme **fiilen yapılabiliyor mu?** | `findstr` | ✔ `sunum\gorev_ekle_alani.dart:11 class GorevEkleAlani` · `:43 child: TextField(` · `:45 onSubmitted: (_) => _gonder(),` · `gorev_listesi_ekrani.dart:133 GorevEkleAlani(` ⇒ **`SS2`'nin "koşulamaz kabul şartı" kusuru TEKRARLANMAMIŞ** |
| Kriter 6/7 sayı tutarlılığı | tablo sayıldı | ✔ 9 statik + 3 koşan; kriter 6'nın 8+1'i tutuyor |

---

## 🔴 NE ÖLÇÜLEMEDİ (BU BÖLÜM BOŞ OLAMAZ — "temiz" DEMEK DEĞİLDİR)

1. **`spec-kapi-kapsama.py` W1 üzerinde KOŞTURULMADI.** `M2`'deki hüküm aracın **kaynağı**
   okunarak (regex + `envanter()`/`borclar()` gövdeleri) türetildi, koşumla değil. Spec `## 6b`
   ilk koşumun `[S1] MUTANTSIZ KAPI: G37` verdiğini yazıyor; **o çıktıyı görmedim**. Koşulmalı:
   `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-W1-web-yuruyen-iskelet.md`
   ⇒ beklentim **EXIT 0** (ve bu, `M2`'nin *"sıfır-bilgi"* iddiasının doğrulaması olur).
2. **`AllowAnyOrigin() ⇒ Access-Control-Allow-Origin: *` davranışı bu makinede canlı ÖLÇÜLMEDİ.**
   `B2`'nin (i) katmanı ASP.NET Core sözleşmesine dayanıyor. Backend ayakta değildi ve `K80`
   gereği **Cowork ortamı kaldırmaz**. Bu ölçüm `M195`/`M196` koşumunda **ücretsiz** düşer.
3. **`_preflight.py` ve `cors-kapisi.py` HENÜZ YOK** (`dir` ile ölçüldü: `araclar\cors-kapisi.py`
   ⇒ `File Not Found`). Kapı ayaklarının körlüğü **tarife göre** değerlendirildi, koşan koda göre
   değil. `M1`'deki maliyet sınıflaması da `_preflight.py`'nin bir Python probu olduğu **spec
   beyanına** dayanıyor.
4. **`## 4b`'deki ortam hiç kaldırılmadı** — `docker ps`, `netstat :5298`, `netstat :5000`,
   `adb devices` **koşulmadı**. `G36`/`G37`/`G38`'in *fiilen* koşup koşmayacağı **[DOĞRULANMADI]**.
5. **`radar.py`, `verify.ps1`, `flutter analyze`, `flutter test` koşulmadı** ⇒ kriter 1, 2, 3, 10
   hakkında **hiçbir hükmüm yok**.
6. **`BORCLAR.md` açılmadı** ⇒ `B-W1-1`/`B-W1-2` kayıtlarının var olup olmadığı ölçülmedi.
   `PROJE_HAFIZA.md` de açılmadı (K53 gereği); `K108`, `K133`, `K135`, `K126`, `K127` atıflarının
   **içeriğini** doğrulamadım — yalnız `CLAUDE.md`'de yazılı olan `K53`, `K80`, `K81`, `K126`,
   `K127`, `K58` metinlerini kullandım.
7. **Drift'in `chosenImplementation` değerleri ile kalıcılık ilişkisi** (hangi implementasyon
   sayfa yenilemesinde hayatta kalır) **ölçülmedi**; `M1`'deki `drift_worker.js` mutant önerisi
   drift'in **belgelenmiş** düşme davranışına dayanıyor, bu depoda koşarak doğrulanmadı.

---

## BAĞIMSIZ EKSİKLİK KRİTİĞİ (kendi denetimime)

- **Kanıtsız kabul ettiğim iddialar:** ① `_preflight.py`'nin bir Python probu olacağı (spec beyanı;
  `M1`'in maliyet aritmetiği buna dayanıyor — builder bunun yerine tarayıcıdan `fetch` ile ölçerse
  `M195`/`M196` gerçekten "koşan uygulama" sınıfına girer ve `M1` **zayıflar**). ② `## 2` ölçüm
  tablosunun tamamı (`flutter build web` EXIT 0, `main.dart.js` bayt sayıları, `_o57_*.py`
  betiklerinin çıktıları) — **hiçbirini yeniden koşmadım**, yalnız `kIsWeb`/CORS satırlarını
  bağımsız doğruladım. ③ Backend'de `AddCors`/`UseCors`'un gerçekten **hiç** olmadığı (§2'nin
  92-dosya taraması) — ben yalnız `Program.cs`'i taradım, 92 dosyanın tamamını değil.
- **Hiç açmadığım dosyalar:** `BORCLAR.md`, `DURUM.md`, `PROJE_HAFIZA.md`, `araclar\radar.py`,
  `araclar\verify.ps1`, `KANIT\o57\*`, `KANIT\W1\_denetim_olcum.py` (dizinde **var**, içeriğini
  okumadım), `src\client\lib\veri\senkron_dongusu.dart` (yalnız `findstr` ile satır numarası
  gördüm), `signalr_json_sinyal.dart`'ın `kIsWeb` dalının **gövdesi**.
- **Hiç denemediğim yol:** mutantların **fiilen uygulanması**. `B2`'nin *"`M196` `G36/b`'yi yeşil
  bırakır"* hükmü **muhakemeyle** türetildi; `M196` koşulup `_preflight.py` çıktısı görülseydi
  **KESİN**den de öte, **KANITLI** olurdu. `K53/1` gereği kâğıt turu tavanı 1'dir ve bu tur
  odur — ama bu bulguların **hepsi** ilk koşumda mekanik olarak da doğrulanabilir; `B2` ve `B3`
  için bunu **kilit sonrası ilk koşumda** ölçmenizi öneririm.
- **Merceğimin dışında bıraktıklarım:** `## 1`–`## 4b`, `## 7` (kriter 6/7 sayımı ve kriter 7'nin
  bayt-özdeşliği hariç), `## 8`, `## 9` **sistematik olarak taranmadı** — görev `## 5` ve `## 6`
  merceğiydi. `## 4b`'nin ortam reçetesi ile `ORTAM.md` arasındaki uyum **örneklemle** (dört atıf)
  doğrulandı, tamamıyla değil.
- **Yanılıyor olabileceğim en olası yer:** `B1`. Eğer `G37/b` ölçümü **backend kapalıyken**
  yapılacaksa (spec bunu yazmıyor ama builder böyle yapabilir), `B1` düşer. Bu yüzden `B1`'in
  çözümü metne **tek cümle** eklemektir; maliyeti sıfır, faydası taç iddianın kurtulmasıdır.

---

## HÜKÜM

🔴 **BU SPEC KİLİTLENMEZ.** Üç bloker de **koşan kod gerektirmeden**, tek bir okuma turunda
bulundu — `K127`'nin doğuş gerekçesinin aynısı. Üçünün de düzeltmesi **metin düzeyindedir**
(bir ayak cümlesi, bir mutant reçetesi, bir ek statik mutant) ve **koşan mutant tavanını
harcamaz**. `K53/1` ihlali yoktur: bu **birinci ve tek** kâğıt turudur; ikinci tur ancak bu
turun bulguları **mimariyi değiştirirse** açılır — `B1`'in çözümü (ölçüm sırası: `G38` → backend
kapat → `G37/b`) `## 4b`'nin sırasını değiştirdiği için **bu eşiğe yakındır**, kararı Onur verir.

**Düzeltme sonrası yeniden denetim gerektirenler:** `B1` (yeni ölçüm sırası), `B3` (yeni ayak
metni + `M190b`), `B2` (`M196`'nın yeni reçetesi).

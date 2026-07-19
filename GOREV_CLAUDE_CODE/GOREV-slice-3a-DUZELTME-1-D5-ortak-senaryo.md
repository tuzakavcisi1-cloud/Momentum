# GÖREV (Claude Code) — slice-3a DÜZELTME-1: D5'in ORTAK SENARYOSU  [v5 — KİLİT ONUR'DA]

> **v4'ün kusurları — DÖRDÜNCÜ TUR, 2 BLOKER + 5 MAJÖR. Turun ASIL sorusu şuydu ve cevabı EVET çıktı:**
> *"Cowork bu oturumda bir sayı ÖLÇÜP KANIT'a yazmış ama SPEC'e taşımayı atlamış başka vaka var mı?"*
> 1. **[MAJÖR→ERRATA-2] `mutant-13` AYNI SINIFTAN İKİNCİ VAKA.** Cowork ölçtü: yalnız canlılık assert'i
>    kırıldı (SyncCore 39/40 = 1 test). v5 §5:400 hâlâ "üç-kova assert'i de kırılır" diyor ve kendi
>    §D2b:223'üyle de çelişiyor. `mutant-16`'nın aynası: orada spec **eksik**, burada **fazla** söylüyordu.
> 2. **[BLOKER] §6 kendi sırasıyla çelişiyordu** — mutant-16 maddesi "4 adımlı" diyordu, sıra 6 adımdı
>    (v4 sırayı uzatırken sayıyı güncellememişti). Aynı §2↔§6 dikişinin **üçüncü** kırılması.
> 3. **[BLOKER] Adım 5'in "bloğu geri çıkar"ı DETERMİNİST DEĞİLDİ** — sınır işareti yoktu ⇒ builder kendi
>    ad-hoc çıkarıcısını yazacaktı; **SAPMA-3'ü doğuran araç-hattı sınıfının ta kendisi**, üstelik
>    "kanıt adımı" diye emredilmiş hâli. Sınır satırları (`<<<BEGIN RAW DIFF`) pinlendi.
> 4. **[MAJÖR] `git diff … > dosya` PowerShell 5.1'de UTF-16LE+CRLF yazar** ⇒ adım 5/6 garantili patlardı;
>    ayrıca `--whitespace` `git apply`'ın seçeneğidir, `git diff`'in değil. `--output=` pinlendi.
> 5. **[MAJÖR] KANIT'ların ÖZET bölümü sıraya dâhil değildi** — `mutant-10` ve `mutant-11`'in gerekçeleri
>    ("D5-a isDeleted hiç yazmadığı için…", "tag EKLER ama KALDIRMAZ") birleşik senaryoda **yanlışlanıyor**.
> 6. **[MAJÖR] §2'nin "kalan 6 mutant v5 tablosundakidir" cümlesi `mutant-1`'i yanlış sayıya bağlıyordu.**
> 7. **[MAJÖR] Ara dosyaların silinmesi emredilmemişti** ⇒ 16 izlenmeyen dosya, kriter 4 ("temiz ağaç") düşerdi.

> **v3'ün kusurları — ÜÇÜNCÜ TUR, 2 BLOKER + 3 MAJÖR (ikisi de v3'ün KENDİ düzeltmesinin yan etkisiydi):**
> 1. **[BLOKER] §2 ile §6 `mutant-16` üzerinde ÇELİŞİYORDU** — §2 "yeniden koşulur, KANIT güncellenir",
>    §6 "DOKUNMA, yeniden koşma". v3'ün §2'ye yeniden-koşum kuralını eklerken §6'yı güncellememesinden;
>    v2'de kırılan §2↔§3 çelişkisinin §6'ya kaymış hâli.
> 2. **[BLOKER] `mutant-16` BUGÜN ZATEN 3 test kırıyor** (adım 7 + adım 8 + **D0-c yan hasarı**) ama v5 §5:385
>    beklenen olarak **2** yazıyor ⇒ v3'ün "fazla kırılırsa DUR" muhafızı **garantili YANLIŞ DUR** üretirdi.
>    Cowork bunu bu oturumda kendi koşumuyla ölçmüştü; spec'e taşımayı atlamıştı.
> 3. **[MAJÖR] `git apply --check` yalnız `mutant-1`'e bağlıydı** ama 8 KANIT yeniden üretiliyor ⇒ kalan 7'de
>    "elle yazılmış diff" kusuru serbestçe geri gelebilirdi.
> 4. **[MAJÖR] Doğrulama YANLIŞ ARTEFAKTI sınıyordu** — `<temp>.patch` doğrulanıyordu, oysa onarılan kusur
>    **KANIT'a yapıştırılan bloğun** elle üretilmiş olmasıydı; yapıştırma bozulsa check yine exit 0 verirdi.
> 5. **[MAJÖR] 4 adımlı sıra KANIT v2.1 (c)'yi (revert sonrası tam suite yeşil) düşürüyordu.**
> Ayrıca: tombstone gerekçesi hâlâ lafzen yanlıştı (eleman-kapsamlı **ve** tag-anahtarlı) · `Adim9`'un assert
> BİÇİMİ pinsizdi (güçlendirilirse `mutant-14`'ün sayısı bozulur) · kova (iii) "ölçülmez" diyordu, doğrusu
> "assert edilir ama ayırt edici değil" · kriter `5b.` madde işareti render'da kayboluyordu.

> **v2'nin kusurları — DELTA DENETİMİ, 1 BLOKER + 4 MAJÖR:**
> 1. **[BLOKER] v2, `mutant-14`'ün yayılma alanının GENİŞLEDİĞİNİ göremezdi** ve "diğer 15 mutant yeniden
>    koşulmaz" diyerek bunu **tespit edilemez** kılıyordu ⇒ repoda **fiilen yanlış bir KANIT** kalırdı
>    ("YAN ISIRMA: YOK"). Cowork ölçerek doğruladı. Düzeltme: §2'nin yeniden-koşum kuralı + `mutant-14` uyarısı.
> 2. **[MAJÖR] §2 ile §3 çelişiyordu:** §3 "fazla test kırılırsa DUR" muhafızını koyuyor, §2 onu 16 mutantın
>    15'i için uygulanamaz kılıyordu.
> 3. **[MAJÖR] E3 kova (ii)'de `notes` YANLIŞ KOVADAYDI** — adım 1b op'u `"notes"` anahtarını taşır, `mutant-1`
>    kolonu yazar ⇒ bayat değildir. v2'nin kendi "ayrışırsa DUR" kuralı **yanlış bir DUR** üretirdi.
> 4. **[MAJÖR] Kriter 5'in "D5-a" ifadesi sayısal olarak belirsizdi** — D5-a **iki** `[Fact]`'tir, `mutant-1`
>    yalnız Task ayağını düşürür (TaskList dalı mutasyonsuz) ⇒ beklenen kırık sayısı **2**, 3 değil.
> 5. **[MAJÖR] `git apply --check` teyidi sırasızdı** ⇒ mutasyon uygulanmışken koşulup yanlış sonuç verirdi.
> Ayrıca: adım 3'ün `Observed` listesi pinsizdi · tombstone gerekçesi eleman düzeyinde yazılmıştı (tag
> düzeyindedir) · "yazım" ile "op" karışıyordu · süre tahmini kaynaksızdı.

> **Bu bir düzeltme dilimidir.** Ana spec `GOREV-slice-3a-materyalizasyon.md [v5]` yürürlükte kalır; burası onun
> **§D5 bölümünü ikame eder** ve §D5'in senaryosuna **errata** getirir (dokuz adım → **on bir adım: 0..10**).
> Çelişkide **BU DOSYA** geçerlidir; başka her şeyde v5.
>
> **v1'in kusurları — BİR BAĞIMSIZ DENETİM TURU, 3 BLOKER + 6 MAJÖR (hepsi gerçek):**
> 1. **v1'in "onarım" iddiası FİZİKSEL OLARAK ÜRETİLEMEZDİ.** `is_deleted` ve `has_delete_edit_conflict`'in
>    "adım 4→9 tarihinin sonucu, varsayılan değil" olacağı yazılmıştı. `EntityState.cs:63-65` `IsDeleted`'ı
>    **Ordinal** `"true"` ile ölçer, `:77-79` `HasDeleteEditConflict`'i `if (!IsDeleted) return false;` ile
>    **kısa devre** yapar ⇒ adım 9'un `"True"` yazımından sonra ikisi de **zorunlu olarak `false`** = kolon
>    varsayılanı. v1 onarmadığı bir şeyi onardığını iddia ediyordu.
> 2. **v1 D5-a'yı BUGÜNKÜNDEN ZAYIF hâle getiriyordu.** Dokuz adım `priority`/`projectId`/`remindAt`/
>    `recurrenceRule` **hiç yazmaz** ve `dueAt`'i yalnız **bozuk** değerle yazar; bugünkü D5-a ise
>    `priority=3`, geçerli `dueAt`, `projectId` yazıyordu ⇒ **üç kolonda net regresyon**, `ReadTimestampAsync`
>    yardımcısı ölü koda dönüyordu. SAPMA-1'in saydığı 6 kolonun yalnız 2'si onarılıyordu.
> 3. **v1'in §6 SAPMA-3'ü VAR OLMAYAN bir kusuru PAZARLIKSIZ emrediyordu** (aşağıda §6, Cowork hatası).
> Ayrıca: tag tombstone'u `tags` kolonunu boşaltıyordu · adım 6'da B'nin ne yazdığı pinsizdi · D5-b'nin
> izolasyon kaybı bedel olarak adlandırılmamıştı · yazım literalleri pinsizdi (D5-a `'redo'`, D5-b `'done'`
> yazıyor — kurucu yanlışını seçse D5-b **yanlış sebeple** kırmızı olurdu) · `stopAfterStep` muhafızı kapısızdı.

- **Rol:** Sen build edersin. `PROJE_HAFIZA.md` ve `docs/ADR/*`'a **DOKUNMA**. Cowork bağımsız doğrular.
- **Dil:** Kod/isimler İngilizce; commit mesajı **ASCII**. Testler Docker İSTER.

## 0. Önce oku
`CLAUDE.md` · v5 **§D5 (309-347)**, **§5 mutant tablosu**, **§7 kırmızı çizgiler** ·
`KANIT/slice-3a/cowork-bagimsiz-dogrulama.txt` **SAPMA-1 ve SAPMA-3** ·
`tests/Momentum.Persistence.Tests/`: `LiteralOracleD5bTests.cs` · `MaterializationRoundTripTests.cs` · `TestSupport.cs` ·
`src/backend/Momentum.Domain/Sync/State/EntityState.cs` **(63-79 kritik)** · `Crdt/OrSetField.cs` **(92 kritik)**.

## 1. NE YANLIŞTI (yeniden keşfetme; doğrula ve geç)

v5 §D5:311 **PAZARLIKSIZ** bir pin koyuyordu: *"ORTAK SENARYO — DOKUZ adım"*, D5-a ve D5-b **AYNI** senaryoyu okur.
İnşa edilen: iki ayrı dosya, **11 bağımsız test**, her biri kendi kurulumuyla. D5-a'nın Task senaryosu dokuz adımın
**altısını** içermiyordu ⇒ karşılaştırdığı 15 kolonun 6'sı **varsayılan** değerinde eşleniyordu; TaskList ayağı
`name`'i hiç değiştirmiyordu ⇒ bayat-`name` görünmezdi.
**Kök neden:** `mutant-1`'in D5-a'yı ısırmaması testin zayıflığı değil **spec-uyum sapmasının semptomuydu**;
§5'in "DUR ve bildir" kuralı yerine eksik adımlardan **yalnız biri** eklenip devam edildi (`6c2774c`).

## 2. KAPSAM — NE VAR / NE YOK

**VAR:** tek paylaşılan senaryo kurucusu (adım 0..10) · D5-a ve D5-b'nin onun üzerine bağlanması ·
`mutant-1`'in **yeniden ölçülmesi** · KANIT onarımı (§6).

**YOK [PAZARLIKSIZ]:**
- **`src/**` altında TEK SATIR değişiklik yok.** Dokunman gerektiğini düşünüyorsan **DUR ve Cowork'e sor**.
- Yeni uç/kolon/migration/bağımlılık **YOK**. Test **SAYISI** değişmez ⇒ **110/110** korunur (kriter 3).

**MUTANT YENİDEN KOŞUMU — v3'ÜN DÜZELTMESİ [PAZARLIKSIZ].**
v2 "diğer 15 mutant yeniden koşulmaz" diyordu. **BU YANLIŞTI ve delta denetimi somut kurbanını buldu.**
Senaryoları birleştirmek, D5'te kapısı olan mutantların **yayılma alanını değiştirebilir**; değiştirdiğinde
repoda **fiilen yanlış bir KANIT** kalır. Kural:

- **YENİDEN KOŞULUR (8):** `mutant-1, 2, 7, 9, 10, 11, 14, 16` — kapıları D5-a/D5-b'dedir.
  Her birinin KANIT'ı ölçüme göre **güncellenir**; yayılma alanı değişen varsa v5 §5'in "ısırması ZORUNLU"
  hücresi de errata ile düzeltilir.
- **KOŞULMAZ (8):** `mutant-3, 4, 5, 6, 8, 12, 13, 15` — kapıları D0-b/D0-c/D3b/D2b/D2d'dedir, D5'e
  dokunulmasından **etkilenmezler** (Cowork 16/16'yı kendi koşumuyla ölçtü, KANIT'ta).

**BİLİNEN VE ÖNGÖRÜLEN DEĞİŞİKLİK — `mutant-14` [ölçüldü, tahmin değil]:**
`mutant-14`'ün mutasyonu (`KANIT/…/mutant-14-…txt`) `notes` register'ı **durum 2**'deyken **her projeksiyonda**
`malformed`'a `"notes"` ekler. Birleşik senaryoda `notes` adım 1b'de `null`'a çekilir ve **bir daha yazılmaz**
⇒ N≥1'in **hepsinde** sızar. `Adim5` ise `ShouldBe(["dueAt"])` ile **TAM DİZİ EŞİTLİĞİ** assert eder
(`LiteralOracleD5bTests.cs:106`) ve `FinalizeMalformed` Ordinal sıralar (`"dueAt" < "notes"`) ⇒
**`mutant-14` artık `Adim1` VE `Adim5`'i birden kırar (2 test).**
- Bu **beklenen** bir genişlemedir; §E4'ün "FAZLA test kırılırsa DUR" kuralı `mutant-14` için **bu iki teste
  kadar** askıya alınır. **Üçüncü bir test kırılırsa DUR ve bildir.**
- `mutant-14`'ün KANIT dosyasındaki **`"YAN ISIRMA: YOK. … başka hiçbir senaryo notes'u null'a çekmiyor"`
  cümlesi birleştirmeden sonra YANLIŞTIR ve DÜZELTİLMELİDİR** — yeni ham çıktıyla değiştir.
- v5 §5 satır 383'ün `mutant-14` hücresi **"D5-b adım 1 FAIL"** → **"D5-b adım 1 + adım 5 FAIL"** olarak
  errata edilir.

**BİLİNEN VE ÖNGÖRÜLEN #2 — `mutant-16` BUGÜN ZATEN 3 TEST KIRIYOR [ölçüldü, birleştirmeden BAĞIMSIZ]:**
v5 §5:385 beklenen olarak **2** test yazıyor (adım 7 + adım 8) ama gerçek **3**'tür — üçüncüsü
`TaskMaterializationD0Tests.D0c_keyset_pagination_crosses_the_null_boundary_without_gaps_or_repeats`
(mutasyon `list_pos`'u sessizce NULL yaptığı için keyset senaryosunun 3 non-NULL + 3 NULL kurgusu çöker).
Cowork bunu **kendi koşumuyla ölçtü** (`KANIT/slice-3a/cowork-bagimsiz-dogrulama.txt`, mutant-16 satırı) ve
builder'ın KANIT'ında da kayıtlı. **`mutant-16` için beklenen TAM liste ÜÇTÜR; DÖRDÜNCÜ test kırılırsa DUR.**
D0-c bu dilimde **değişmez** (`TaskMaterializationD0Tests.cs`'e dokunulmaz, `D5Scenario`'yu kullanmaz)
⇒ yan hasar birleştirmeden etkilenmez. v5 §5:385 hücresi de buna göre errata edilir.

**MUHAFIZIN DOĞRU OKUNUŞU:** §3'ün "fazla/az kırılırsa DUR" kuralı şu beklenen sayılara göre uygulanır:
`mutant-14` = **2** · `mutant-16` = **3** (yukarıdaki iki öngörülen genişleme) · `mutant-1` = **2**
(**§E4'ün TAM adlı pini geçerlidir, v5 §5:370'in gevşek okunuşu DEĞİL — o 3 sanılabilir**) ·
kalan 5 (`2,7,9,10,11`) = **1'er test**, v5 §5 tablosundaki gibi.

## 3. KİLİTLİ KARARLAR (Onur, 19-20 Tem 2026)

**K1 — PAYLAŞILAN KURUCU + `stopAfterStep`.** Senaryo TEK yerde tanımlanır; D5-b'nin 9 testi N'inci adıma kadar
koşup **yalnız o adımın** literallerini assert eder; D5-a **tam senaryoyu (N=10)** koşup round-trip yapar.
*Reddedilen:* tek metot + checkpoint (adım 3 düşerse 4-10 ölçülmez; `mutant-16`'nın adım 7 ve 8'i **ayrı ayrı**
düşürdüğü ayrım kaybolur — Cowork bunu ölçtü) · kurucuyu paylaşıp D5-b'yi olduğu gibi bırakmak (pin tam sağlanmaz).

**K2 — SENARYO 0..10'A GENİŞLETİLİR (v5 §D5'e ERRATA).** Gerekçe: dokuz adım D5-a'nın kolonlarının yarısını
varsayılanda bırakıyor (v1 kusuru 2). **Adım 0 ve adım 10 bir mutanta değil, ÖNCEDEN İLAN EDİLMİŞ BİR ÖLÇÜM
HEDEFİNE hizmet eder** ⇒ §E4'ün "senaryoyu mutanta uydurma" yasağını ihlal etmez.

**BEDELLER [ikisi de adlandırıldı ve kabul edildi]:**
- **Süre:** artış **ÖLÇÜLMEMİŞTİR**, tahmin verilmiyor. Persistence.Tests'in baskın maliyeti test başına
  **DB create+migrate**'tir (kurulum sayısı 11 → 11, **değişmiyor**); eklenen yük yalnız ~100 ek op'tur.
  **Ölç ve rapora yaz.** *(v2 "~2 dk" diyordu — kaynaksız tahmindi, muhtemelen fazla yüksekti.)*
- **Atfedilebilirlik:** D5-b'nin bugünkü "her adım kendi entity'sinde" izolasyonu **kaybolur**; N'inci adımın
  kırmızısı artık 1..N'deki herhangi bir regresyondan gelebilir. Karşılığı D5-a'nın senaryo-uyum garantisidir.
  **Telafi [PAZARLIKSIZ]:** bu bedel ancak **ölçümle** karşılanabilir ⇒ D5'te kapısı olan **8 mutant yeniden
  koşulur** (§2), her KANIT'ta kırılan testlerin **TAM listesi** yazılır ve **beklenenden fazla/az test
  kırılırsa DUR ve bildir**. *(v2 bu muhafızı koyup §2 ile uygulanamaz kılmıştı — v3'ün düzeltmesi.)*

## 4. TESLİMATLAR

---

**E1 — PAYLAŞILAN SENARYO KURUCUSU.**

**YER PİNİ:** **YENİ** dosya `tests/Momentum.Persistence.Tests/D5Scenario.cs`. `TestSupport.cs`'e **EKLEME**
(v5 §D0 ORDER KANALI PİNİ gereği oraya ekleme adlandırılmış sapmadır; yeni test dosyası sapma değildir, kriter 6(b)).

**İMZA PİNİ:**
```csharp
internal static async Task<D5Ids> BuildAsync(SyncTestApp app, int stopAfterStep)
```
- `connectionString` parametresi **YOKTUR** — kurucu yalnız op push eder, DB'yi çağıran okur (v1'de ölü parametreydi).
- `D5Ids` **tam** alan listesi (gevşek "en az" YOK): `Guid TaskId`, `Guid TaskListId`, `Guid ActorA`, `Guid ActorB`,
  `Guid Tag3`, `Guid Tag4`, `Guid ProjectId`.
- **Adım 0 HER ZAMAN koşar** (kuruluş). `stopAfterStep` **1..10**; kurucu 1'den N'e kadar sırayla koşar.
- **Aralık muhafızı:** `stopAfterStep < 1 || > 10` ⇒ `ArgumentOutOfRangeException`.
  **BEYAN [ZORUNLU]: bu muhafız bir KAPI DEĞİLDİR, savunmacı koddur; mutantı YOKTUR ve olması beklenmez.**
  Ölçen bir `[Fact]` **EKLENMEZ** (kriter 3'ün test sayısı pini korunur). *(v1 bunu sessiz bırakmıştı ⇒ "kör kapı
  yok" ilkesinde delik görüntüsü veriyordu; beyanla kapatıldı — D6/D7/D8'in "mutantsız çıpa" kalıbı.)*

**DAMGA PİNİ [PAZARLIKSIZ]:** **TÜM op'lar** tek, global, **monoton artan** bir sayaç kullanır; iki **OP** aynı
sayacı **asla** paylaşmaz. *("Yazım" = bir **OP**'tur. Bir op içindeki birden çok alan aynı `Hlc`'yi paylaşabilir
— `Wire.TaskFields` zaten öyle yapar, `TestSupport.cs:228-231`; çakışmazlar çünkü ayrı register'lardır.)*
Adım 0 sayacın **en altını**, adım 10 **en üstünü** alır.
*Gerekçe:* `Wire.Hlc(clientId, counter, …)`'ın ilk parametresi **client**'tır (`TestSupport.cs:211`) ve
`Hlc.CompareTo` eşit `WallMs`+`Counter`'da **ClientId hex**'ine düşer ⇒ rastgele Guid'lerle determinizm kaybolur.

**YAZIM LİTERALLERİ PİNİ [PAZARLIKSIZ — v1'de yoktu, D5-a `'redo'`/D5-b `'done'` çakışıyordu]:**

| adım | yazılan | değer |
|---|---|---|
| **0** | `priority`, `projectId`, `remindAt`, `recurrenceRule` | `"2"`, `<D5Ids.ProjectId>`, `"2026-07-20T09:00:00Z"`, `"FREQ=DAILY"` |
| 1 | `title`, `notes` → sonra `notes` | `'x'`, `'y'` → **`null`** |
| 2 | grup `completion` → daha AZ üyeli REPLACE | `{status:'done', completedAt:'2026-07-19T10:00:00Z'}` → **yalnız `{status:'done'}`** |
| 3 | tag ekle → **remove** | eleman `el0`, tag `Tag3` |
| 4 | `isDeleted:'true'` + ondan büyük damgalı **yalnız tags** op'u | tags op'u **YENİ eleman `el1`**, tag `Tag4` |
| 5 | `dueAt` (ayrıştırılamaz) | `"07/19/2026"` |
| 6 | **kimliği doğrulanmış B** — `app.SyncAsync(ActorB, …)` | **YALNIZ `title` = `'b-edit'`**; başka kolon dokunulmaz |
| 7 | `listPos`, `boardPos` (biri sonradan değişir) | `'p1'` → `'p2'`, `'b1'` |
| 8 | TaskList `name`, `pos`, sonra `name` **DEĞİŞİR** | `'Original'`, `'z1'`, → `'Renamed'` |
| 9 | `isDeleted='True'` (büyük T) + ondan büyük damgalı `title` | `'True'`, `title='final'` |
| **10** | **geçerli** `dueAt` + **bozuk** `remindAt` | `"2026-07-21T08:30:00Z"`, `"not-a-date"` |

**ADIM 3 REMOVE PİNİ:** remove op'u `Observed = [Tag3]` taşır. `OrSetField.ApplyRemove` (`OrSetField.cs:89-93`)
**yalnız `Observed` içindeki tag'leri** iptal eder; `Observed` boş verilirse `el0` **canlı kalır** ve `Adim3`
**yanlış sebeple** kırmızı olur.

**ADIM 4 TOMBSTONE PİNİ [PAZARLIKSIZ]:** adım 4'ün tags op'u **YENİ bir eleman (`el1`, tag `Tag4`)** ekler.
*Gerekçe — DOĞRU BİÇİMİYLE:* tombstone **eleman-KAPSAMLI ve tag-ANAHTARLIDIR** — `Cancelled`,
`ElementState`'in **içinde** bir `HashSet<Guid>` tag kümesidir (`OrSetField.cs:51-52,92`). Yani:
`el0`+`Tag3` **ölü doğar**; `el0`+yeni tag **canlı doğar**; `el1`+herhangi bir tag **canlı doğar**.
Yeni eleman seçilmesinin sebebi ayrım netliğidir:
`el0`'ın canlanması D5-b `Adim3`'ün "boş küme" hikâyesiyle kavramsal olarak çakışır. C4 bayrağı her hâlükârda
adım 4'te yanar (`MaxStamp()` ölü doğan add'ın damgasını da sayar, `OrSetField.cs:229-236`).
*v2 gerekçeyi eleman düzeyinde yazmıştı — yanlıştı; karar aynı kalıyor.*
**SIRALAMA SINIRI [beyan]:** N=10'da `task_tags` **tek satırlıdır** ⇒ D5-a'nın DB `ORDER BY tag` ↔ projeksiyon
`OrderBy(Ordinal)` karşılaştırması **hiçbir sıralama farkını ölçmez**. Bu bugün de böyleydi (regresyon değil);
`mutant-6`'nın `tag` collation ayağı D5'te **görünmez kalır** — kapısı D3b'dir.

**ADIM 10 — İKİ TUZAK [PAZARLIKSIZ]:**
1. Adım 10 **`completion` grubuna DOKUNMAZ.** `mutant-1`'in D5-a'daki tek ısırma yüzeyi, adım 2'nin küçültücü
   REPLACE'inden sonra `completed_at`'in **bayat** kalmasıdır. Sonraki herhangi bir adım o gruba yazarsa
   **kapı ölür**. (Adım 3-9 da dokunmaz; bunu bozma.)
2. Adım 10 geçerli `dueAt` yazdığı için `dueAt` **artık malformed değildir**; `malformed_fields`'ın boş kalmaması
   için **bozuk `remindAt`** aynı adımda yazılır ⇒ N=10'da `malformed_fields = {remindAt}`, `remind_at = NULL`.
   *(Bu, adım 0'ın `remindAt` değerini bilinçli olarak feda eder; karşılığında `due_at` non-NULL ölçülür ve
   `ReadTimestampAsync` ölü koda dönmez.)* **D5-b'nin hiçbir adımı adım 10'u görmez** (N≤9'da durur), `Adim5`
   bozuk `dueAt`'i aynen ölçmeye devam eder.

**ORDER KANALI PİNİ (v5'ten aynen):** `Wire`'da Order yardımcısı YOKTUR; `listPos`/`boardPos`/`pos` Order
kanalıdır, `Fields`'e konursa op `RejectedRegistryViolation` ile elenir ve test **yanlış sebeple** kırmızı olur.
`WireOp` **inline** kurulur. **ACTOR PİNİ: adım 6 DIŞINDAKİ TÜM op'lar `ActorA` ile push edilir**
(adım 0 dâhil — adım 0'ın actor'ı `Adim6`'nın "ilk yazan sahiplenir" assert'ini belirler).
**ADLANDIRMA UYARISI:** `task_tags.tag` kolonu **ELEMANI** tutar (`PresentElements()`), tag Guid'ini değil;
`D5Ids.Tag3/Tag4` isimleri tersini çağrıştırır — kova (i)'deki beklenen değer `el1`'dir.
**YARDIMCI TAŞIMA PİNİ:** `OrderOp` **her iki** test dosyasından (`LiteralOracleD5bTests.cs:190-193` ve
`MaterializationRoundTripTests.cs:92-95`) ve `TaskListFieldOp` (yalnız D5-b'de) **SİLİNİR**, kurucuya taşınır.
`ReadTagsAsync` (her iki dosyada) ve `ReadTimestampAsync` (D5-a'da) **KALIR** — okuma yardımcılarıdır.

---

**E2 — D5-b YENİDEN BAĞLANIR (`LiteralOracleD5bTests.cs`).**

Dokuz test **metodu ve ADI AYNEN KORUNUR** (`Adim1_…`…`Adim9_…`) — KANIT/mutant eşlemesi bozulmasın.
Her metot: `D5Scenario.BuildAsync(app, stopAfterStep: N)` → **ham SQL** ile v5 §D5-b tablosundaki **literal** assert.
`TaskProjection.From`/`TaskListProjection.From` **ÇAĞRILMAZ**. **Beklenen değerler v5'ten değiştirilmeden taşınır.**

**ASSERT BİÇİMİ PİNİ [PAZARLIKSIZ]:** `Adim9`'un `malformed_fields` assert'i **`ShouldNotContain("isDeleted")`
biçiminde KALIR** (`LiteralOracleD5bTests.cs:186`), tam-dizi eşitliğine **ÇEVRİLMEZ**. Birleşik senaryoda N=9'da
`malformed_fields` determinist olarak `{dueAt}`'tır; assert'i "güçlendirmek" `mutant-14`'ün beklenen sayısını
2'den 3'e çıkarır ve §2'nin pinini geçersiz kılar. Genel kural: **hiçbir mevcut assert'in BİÇİMİ değiştirilmez**,
yalnız kurulum ortak kurucuya devredilir.

---

**E3 — D5-a YENİDEN KURULUR (`MaterializationRoundTripTests.cs`).**

İki test metodu korunur; her ikisi `D5Scenario.BuildAsync(app, stopAfterStep: 10)` ile **tam senaryoyu** koşar,
sonra `HydrateAsync` → `…Projection.From` → **DB satırıyla alan alan**. Bugünkü elle kurulmuş push'lar **silinir**.
**KARŞILAŞTIRMA PİNİ (v5):** `record ==` **KULLANILMAZ** (koleksiyonlarda referans eşitliği ⇒ her zaman FAIL);
alan alan, koleksiyonlarda `SequenceEqual`.
**BEYAN [ZORUNLU]:** bu kapı **kalıcılık zincirini** ölçer; **projeksiyon fonksiyonunu ÖLÇMEZ**. Mutantı: `mutant-1`.

**KOLON SINIFLANDIRMASI [ZORUNLU — raporda ÜÇ KOVA hâlinde, gizleme yok]:**
- **(i) VARSAYILAN-DIŞI ölçülür:** `title`(`'final'`) · `priority`(2) · `project_id` · `recurrence_rule` ·
  `due_at`(non-NULL) · `list_pos`(`'p2'`) · `board_pos`(`'b1'`) · `status`(`'done'`) · `malformed_fields`(`{remindAt}`) ·
  `tags`(`el1`) · `task_lists.name`(`'Renamed'`) · `task_lists.pos`(`'z1'`).
- **(ii) Değeri varsayılanla ÖZDEŞ ama `mutant-1` onu İHLAL EDER (anlamlı NULL) — TEK ÜYE:** `completed_at`
  (NULL — adım 2'nin küçültücü REPLACE'i). **`mutant-1`'in D5-a'daki tek ihlal yüzeyi budur.**
  *v2 buraya `notes`'u da koymuştu — YANLIŞTI: adım 1b op'u `"notes"` anahtarını taşır, `mutant-1`'in
  `touched` kümesine girer, kolon yazılır ⇒ `NULL` doğrudur, bayat değildir. `notes` kova (iii)'tedir.*
- **(iii) ASSERT EDİLİR ama AYIRT EDİCİ DEĞİL (varsayılan ↔ varsayılan) [açık beyan]:** *(bu kolonlar D5-a'da
  fiilen karşılaştırılır — "ölçülmez" demek yanlış olurdu; ayırt edici olmayan bir karşılaştırma yaparlar.)*
  `is_deleted` ve `has_delete_edit_conflict` — adım 9'un `"True"`
  yazımı adım 4'ün silmesini ezer (`EntityState.cs:63-65,77`) ⇒ N=10'da **zorunlu olarak `false`** = varsayılan.
  **Kapıları D5-b `Adim4` (N=4, `true`) ve `Adim9` (N=9, `false`)'dur** · `remind_at`(NULL, adım 10) ·
  `notes`(NULL — adım 1 durum 2; `mutant-1` yüzeyi DEĞİL, kapısı `mutant-14`/`Adim1`'dir) ·
  `task_lists.is_deleted` / `task_lists.has_delete_edit_conflict` / `task_lists.malformed_fields`.
**Ölçümü koş ve raporda bu üç kovayı GERÇEK değerlerle doldur.** Beklentiyle ölçüm ayrışırsa **DUR ve bildir**.

---

**E4 — `mutant-1` YENİDEN ÖLÇÜLÜR.**

v5 §5'in diff pini geçerli ("dokunulmuşluk **anahtar düzeyinde**": `op.Fields` ∪ `op.Order` anahtarları +
`op.Groups[g].Fields` üye anahtarları). **EK PİN [v2]:** türetilmiş kolonlar (`is_deleted`,
`has_delete_edit_conflict`, `malformed_fields`) mutasyonda **HER ZAMAN yazılır** (kanal-bağımsızdırlar);
aksi hâlde mutant `Adim4`/`Adim5`'i de düşürür ve yayılma alanı spec'in iddiasından farklı olur.
**ISIRMASI ZORUNLU — TAM TEST ADLARIYLA, TOPLAM 2, BAŞKA YOK:**
1. `MaterializationRoundTripTests.Task_materialization_round_trips_field_by_field_against_the_hydrated_projection`
2. `LiteralOracleD5bTests.Adim2_group_replace_with_fewer_members_deletes_the_unwritten_member`

**`MaterializationRoundTripTests.TaskList_materialization_round_trips_…` YEŞİL KALMALIDIR** — `mutant-1`
yalnız `MaterializeTaskAsync`'i mutasyona uğratır, TaskList dalına **dokunmaz**. *("D5-a" gevşek okunursa
beklenen sayı 3 sanılır; §3'ün "FAZLA/AZ kırılırsa DUR" muhafızı tam olarak bu sayıya bağlıdır.)*
Bayat kalan kolon **`completed_at`** olmalıdır; KANIT'a assert mesajıyla yaz.

**KIRMIZI ÇİZGİ [PAZARLIKSIZ — geçen sefer tam burada kaybedildi]:**
> `mutant-1` yeniden kurulan D5-a'yı **ısırmıyorsa** senaryoyu **AYARLAMA, ADIM EKLEME, testi değiştirme.**
> **DUR ve Cowork'e bildir.** Geçen sefer kök neden testin zayıflığı değil **spec-uyum sapmasıydı**; senaryoyu
> mutanta uydurmak o teşhisi ikinci kez kaçırmak olur. **İSTİSNA YOKTUR.**
> Beklenenden **FAZLA** test kırılırsa da DUR (bkz. §3 atfedilebilirlik bedeli).

## 5. KABUL KRİTERLERİ

1. `git diff --name-only -- src` **BOŞ**. Rapora yapıştır.
2. Build `-warnaserror` **0/0**.
3. **110/110 yeşil**; test sayısı değişmedi (D5-b 9 + D5-a 2; `D5Scenario.cs`'te `[Fact]` YOK).
   *Ölçüm kaynağı: Persistence.Tests 53 `[Fact]`, `[Theory]` yok; 5+12+40+53=110.*
4. `araclar/verify.ps1` **DEĞİŞMEDEN** geçer (Docker açık), **exit 0**.
5. `mutant-1` **tek koşumda TAM 2 test** düşürür (§E4'teki tam adlar); `TaskList_materialization_round_trips_…`
   **YEŞİL** kalır. KANIT'ta **ham** çıktı + `git apply --check` exit 0 (§6'nın sırasıyla).
   - **5b.** **D5'te kapısı olan 8 mutant** (`1,2,7,9,10,11,14,16`) yeniden koşuldu; her KANIT'ta kırılan
     testlerin **TAM listesi** ve §6'nın (5)/(6) doğrulama çıktıları var. Öngörülen iki genişleme ölçümle
     teyit edildi (**`mutant-14` = 2 test · `mutant-16` = 3 test**) ve v5 §5 tablosunun ilgili hücreleri
     errata edildi. Diğer 8 mutanta (`3,4,5,6,8,12,13,15`) dokunulmadı — gerekçe raporda; ayrıca bu 8'in
     KANIT'ındaki (c) yeşil özetlerinin **D5 gövdesi değişmeden önce** alındığı, kapı yüzeyleri
     değişmediği için geçerli kaldığı beyan edilir.
6. D5-b'nin beklenen literalleri ve test adları **değişmemiş** — `git diff` ile göster.
7. E3'ün **üç kovalı** kolon ölçümü raporda, gerçek değerlerle.
8. Persistence.Tests süresi ölçülüp rapora yazıldı (§3 bedeli tahmindi, ölçüm değildi).
9. CVE temiz; sır yok; `PROJE_HAFIZA`/`docs/ADR` dokunulmamış.

## 6. KANIT ONARIMI

**SAPMA-3 [TEŞHİS DÜZELTİLDİ — COWORK HATASI, kayda geçti].** Cowork'ün ilk teşhisi — *"mutant-1 ve mutant-16'nın
diff'lerinde `+` öneki düşmüş, `+++ b/` → `++ b/`"* — **YANLIŞTIR.** Bağımsız denetim kırdı, Cowork kaynak
dosyadan kendi yeniden ölçtü: her iki dosyada da `^++ ` satırı **0**, `+++ b/` yerinde. Gördüğü bozukluk
**Cowork'ün kendi yama-çıkarma/görüntüleme hattının artefaktıydı**; kaynağı doğrulamadan KANIT'a kusur diye
yazılmış ve pazarlıksız emre çevrilmişti.
- **`mutant-16-order-channel-read-from-fields.txt`'in diff BLOĞU TEMİZDİR** (gerçek hash'ler
  `a8e52a5..75f98a7`) — **SAPMA-3 gerekçesiyle yeniden YAZILMASI gerekmez.** Ama bu dosya **§2 gereği
  YENİDEN KOŞULUR** (kapısı D5'tedir): KANIT'ın **(b) ham kırmızı** ve **(c) yeşil-sonrası** bölümleri
  yeni ölçümle değiştirilir, diff bloğu aşağıdaki **6 adımlı** sırayla **taze üretilir**.
  **BEDAVA KONTROL:** `src/**` değişmediği için taze `git diff` çıktısı mevcut blokla **bayt özdeş** olmalıdır;
  ayrışırsa **DUR ve bildir**.
  *(v3 "dokunma, yeniden koşma" diyordu — §2 ile çelişiyordu; v4 sırayı 6'ya çıkarırken burada "4 adımlı"
  yazmayı unutmuştu — aynı dikişin üçüncü kırılması, v5'in düzeltmesi.)*
- **`mutant-1-materializer-delta-columns.txt`'in diff bloğu GERÇEKTEN bozuktur ama sebebi başkadır:**
  `index xxxxxxx..yyyyyyy 100644` **yer tutucu** blob hash'leridir ⇒ blok `git diff` çıktısı değil **elle
  yazılmıştır**; ayrıca `@@ -36,9 +36,26 @@` hunk sayaçları gövdeyle uyuşmaz ⇒ blok parse edilemez.
  İhlal edilen kural: KANIT v2.1 (a) *"HAM çıktı YAPIŞTIRILIR, yeniden yazılmaz"*.
  **Onarım — SIRA PİNLİ [PAZARLIKSIZ] · §2'nin YENİDEN KOŞULAN 8 MUTANTININ HEPSİ İÇİN GEÇERLİ:**
  `git apply --check` yamanın **mevcut ağaca** uygulanabilirliğini sınar; mutasyon hâlâ uygulanmışken
  koşulursa "does not apply" verir ve builder **ikinci bir sahte KANIT satırı** yazar (düzeltilmeye
  çalışılan kusurun aynısı). Sıra:
  1. mutasyonu uygula → **`git diff --output=<temp>.patch -- <dosya>`**
     *[PAZARLIKSIZ: `>` YÖNLENDİRMESİ KULLANMA. PowerShell 5.1'in `>` operatörü **UTF-16LE + CRLF** yazar;
     adım 5 her satırı farklı gösterir, adım 6 "does not apply" verir. `--output` baytları git'e yazdırır.]*
  2. `<temp>.patch`'in **ham içeriğini** KANIT'ın diff bölümüne yapıştır — **SINIR SATIRLARI ARASINA**:
     ```
     <<<BEGIN RAW DIFF
     …git diff çıktısı, tek karakter değiştirilmeden…
     >>>END RAW DIFF
     ```
     *[PAZARLIKSIZ: sınır satırları olmadan "geri çıkarma" deterministik değildir ve builder kendi ad-hoc
     çıkarıcısını yazar — **SAPMA-3'ü doğuran araç-hattı sınıfının ta kendisi**. Sınır satırları arasında
     diff'ten başka HİÇBİR karakter olmaz.]*
  3. `dotnet build` + **TAM SUITE** koş → ham kırmızı KANIT'ın (b) bölümüne;
  4. `git checkout -- <dosya>` ile **revert et**, `dotnet build` + **TAM SUITE** koş → ham yeşil özet
     KANIT'ın (c) bölümüne *(KANIT v2.1 kuralı (c); sıradan düşerse atlanır)*;
  5. bloğu geri çıkar: `sed -n '/^<<<BEGIN RAW DIFF$/,/^>>>END RAW DIFF$/p' <kanit> | sed '1d;$d' > <kanit>.extracted`
     sonra **`git diff --no-index --ignore-cr-at-eol <temp>.patch <kanit>.extracted`** → çıktı **BOŞ** ve
     **exit 0** olmalı *(asıl onarılan kusur, KANIT'a yazılan bloğun elle üretilmiş olmasıdır; yalnız
     `<temp>.patch`'i doğrulamak yapıştırma bozulmasını GÖREMEZ)*;
  6. temiz ağaçta **`git apply --check --whitespace=nowarn <kanit>.extracted`** → **exit 0**
     *(`--whitespace` `git apply`'ın seçeneğidir, `git diff`'in DEĞİL — adım 5'e verme)*;
  7. `<temp>.patch` ve `<kanit>.extracted` **SİLİNİR**; `git status` boş olduğu rapora yazılır
     *(ana spec kriter 4: "temiz ağaçta kalıntı yok"; 8 mutant × 2 dosya = 16 izlenmeyen dosya olurdu)*.
  **(5), (6) ve (7)'nin çıktısını her KANIT'a ayrı ayrı yaz.**

**KANIT ÖZET BÖLÜMLERİ DE YENİDEN YAZILIR [PAZARLIKSIZ].** Yeniden koşulan 8 dosyanın
`4) OZET — KIRILAN TESTLER` bölümü (`HEDEF` / `YAN ISIRMA` / `TOPLAM: Failed: N`) yeni ölçümle güncellenir.
**D5-a'nın ESKİ senaryosuna atıf yapan GEREKÇELER yanlışlanmıştır ve düzeltilmelidir:**
`mutant-10`'un *"D5-a'nin Task testi isDeleted hic yazmadigi icin…"* ve `mutant-11`'in *"D5-a'nin Task testi
bir tag EKLER ama hic KALDIRMAZ"* cümleleri — birleşik senaryoda D5-a adım 4/9'da `isDeleted` **yazar** ve
adım 3'te tag **kaldırır**. *(Sonuç yine 1 test kalır; çöken şey gerekçedir — ama yanlış gerekçe KANIT'ta
kalamaz.)* `mutant-14`'ün `TOPLAM: Failed: 1` satırı **2** olur.

**SAPMA-4 [zorunlu].** `KANIT/slice-3a/verify-run-raw.txt` ve `verify-run-full.txt` **silinir** (artık dosyalar).
Kanonik `verify-run.txt` tam ve `EXIT_CODE=0` içerir — **dokunma**.

**ERRATA-1 [v5 kriter 6(b)].** Listeye `Domain/Sync/Projection/ProjectionFields.cs` eklenir (Cowork SAPMA-2:
dosya 5(a)'nın `Sync/Projection/*` jokerince zaten kapsanıyordu, 6(b)'nin sayımı eksikti).

**ERRATA-2 [v5 §5:400 — `mutant-13`]. ÖLÇÜMLE YANLIŞLANMIŞ HÜCRE.** v5 §5:400 *"Üç-kova assert'i de kırılır —
KANIT'ın kırılan-test listesi ikisini de gösterecektir"* diyor. **Cowork kendi koşumuyla ölçtü: YALNIZ
canlılık assert'i kırıldı (SyncCore 39/40 = TEK test).** Builder'ın KANIT'ı da bunu doğruluyor. Üstelik v5
kendi §D2b:223'üyle de çelişiyordu (üç-kova kuralı donmuş numaralandırmayı **göremez**). **Cümle SİLİNİR;
beklenen tam liste TEK testtir:** `FieldStrategyRegistryCoverageTests.DescribeFieldKeys_derives_live_…`.
*`mutant-13` yeniden KOŞULMAZ (kapısı D2b, `D5Scenario`'yu kullanmaz) — errata yalnız metinseldir.*
**Bu, `mutant-16` vakasının aynası ve AYNI SINIFI:** orada spec **eksik** sayıyordu (yanlış "FAZLA ⇒ DUR"),
burada **fazla** söylüyor (yanlış "AZ ⇒ DUR"). İkisi de bu oturumda ölçülüp spec'e taşınmamıştı.

**ERRATA-3 [v5 kriter 9].** Kriter hangi veritabanında ölçüleceğini yazmıyordu (Cowork SAPMA-5).
Eklenir: *"ölçüm **kalıcı compose volume'ünde** (`momentum_momentum-pgdata`) yapılır, efemeral
Testcontainers DB'sinde değil."*

**KANIT KURALI v2.1 aynen yürürlükte:** `DOTNET_CLI_UI_LANGUAGE=en` · **ham** koşucu özeti + kırılan testlerin
koşucudan kopyalanmış tam adları · hiçbir karakter değiştirilmez · her KANIT: (a) tam diff, (b) ham kırmızı,
(c) revert sonrası **TAM SUITE** yeşil ham özeti, (d) `--blame-hang-timeout 120s`.

## 7. TESLİM PROTOKOLÜ

1. `araclar/verify.ps1` (Docker açık) — TÜM çıktı rapora.
2. Commit (ASCII): `test(d5): rebuild D5-a and D5-b on one shared eleven-step scenario`
   + ayrı: `docs(kanit): repair mutant-1 diff block and drop verify artifacts`. **Push YAPMA** (Cowork).
3. Rapor: (a) `git diff --name-only -- src` (boş), (b) test sayıları + süre ölçümü, (c) verify exit,
   (d) mutant-1 ham kırmızısı + `git apply --check` teyidi, (e) E3'ün **üç kovalı** ölçümü,
   (f) sapma/varsayım TAM listesi, (g) §6 onarımının teyidi (mutant-16'ya dokunulmadığı dâhil).

## 8. AÇIK BULGULAR

**A** — registry'de `Task→TaskList` bağı YOK (icat edilmez, F6). **B** — **KAPANDI:** `mutant-6` yalnız şema
beyanını ısırır (Cowork ampirik ölçtü). **C** — `outbox_messages.owner_id` doğrulanmamış (auth dilimi).
**D** — `task_lists` bağlantısız tablo (A'ya bağlı).

# GÖREV (Claude Code) — slice-3a DÜZELTME-2: KANIT DİFF BÜTÜNLÜĞÜ  [v1 — KİLİT ONUR'DA]

> **Bu görev DÜZELTME-1'den AYRILDI (Onur kararı, 20 Tem 2026).** Gerekçe: DÜZELTME-1'in §6'sındaki
> 7 adımlı diff-onarım ritüeli iki denetim turunda **6 kusur** üretti (v4'te 2, v5'te 4) ve hiçbirinde
> çalışır hâle gelmedi. Kök sebep spec'in yazımı değil **mekanizmaydı**: metin dosyasına yapıştırılmış
> bir diff'i `sed` ile geri çıkarıp bayt bayt doğrulamak PowerShell 5.1'de doğası gereği kırılgandır
> (`>` operatörü UTF-16LE+CRLF yazar; boş bağlam satırlarının tek boşluğu metne yapıştırılırken sıyrılır).
> **Bu görev diff'i metne HİÇ YAPIŞTIRMAZ** — dosya olarak bırakır. Doğrulama tek satıra iner.

- **Rol:** Sen build edersin. `PROJE_HAFIZA.md` ve `docs/ADR/*`'a **DOKUNMA**. Cowork bağımsız doğrular.
- **ÖNKOŞUL [PAZARLIKSIZ]:** DÜZELTME-1 tamamlanmış ve **Cowork tarafından doğrulanmış** olmalıdır.
  Ağaç temiz değilse **DUR**. *Gerekçe — sıra **teknik** değil **düzenleme-çakışması** kaynaklıdır:
  mutasyonlar yalnız `src/**`'te, DÜZELTME-1 yalnız `tests/**`'i değiştirir ⇒ mantıksal bağımlılık yok;
  ama iki görev **aynı 16 KANIT dosyasının farklı bölümlerine** yazar ((b)/(c)/ÖZET ↔ (a)) ve bu görevin
  adım 3'ü DÜZELTME-1'in ürettiği **güncellenmiş ÖZET listesini** okur. DÜZELTME-1 §2'nin "önkoşul
  değildir" cümlesi bu ayrımı kasteder; **işletim sırası yine de bağlayıcıdır.***
- **Dil:** commit mesajı **ASCII**. **Bu görev test suite'ini BAŞTAN SONA koşmaz** (aşağıya bak).

## 1. NE YANLIŞ

**SAPMA-3'ün GERÇEK kusuru** (Cowork'ün ilk teşhisi yanlıştı, düzeltildi ve kayda geçti):
`KANIT/slice-3a/mutant-1-materializer-delta-columns.txt`'in diff bloğu `index xxxxxxx..yyyyyyy 100644`
**yer tutucu** blob hash'leri taşıyor ⇒ blok `git diff` çıktısı değil, **elle yazılmış**; ayrıca
`@@ -36,9 +36,26 @@` hunk sayaçları gövdeyle uyuşmuyor ⇒ blok **parse edilemez**.
İhlal edilen kural: **KANIT v2.1 (a)** — *"HAM çıktı YAPIŞTIRILIR, yeniden yazılmaz."*

**İKİNCİ KUSUR — BOŞLUK SIYRILMASI [Cowork ölçtü, 20 Tem 2026].** Ölçüm, **diff bloğunun İÇİ** kapsamında
(`sed -n '/^diff --git/,/^====/p' <dosya> | cat -A`, sonra `grep -c '^ $'` ve `grep -c '^$'`):

| dosya | tek-boşluk bağlam satırı | blok içi tam-boş satır |
|---|---|---|
| `mutant-1-materializer-delta-columns.txt` | **0** | 3 |
| `mutant-16-order-channel-read-from-fields.txt` | **0** | 5 |

`git diff` boş bir bağlam satırını `" "` (tek boşluk) olarak yazar ve iki dosya bloğu arasına boş satır
**koymaz**. Bu iki dosyada gömülü blok bayt düzeyinde geçerli bir yama **değildir**.
**KAPSAM DÜRÜSTLÜĞÜ [beyan]:** kalan 14 dosya bu eksende **ÖLÇÜLMEDİ**; aynı üretim hattından çıktıkları
için aynı kusurun beklenmesi makuldür ama bu bir **tahmindir**. Bu görev zaten 16'sının hepsini
yeniden üretir ⇒ ayrıca ölçmeye gerek yok, ama **"hepsi bozuk" diye yazma.**

**ÜÇÜNCÜ KUSUR — `mutant-6`'da `index` SATIRI HİÇ YOK [Cowork ölçtü].** 16 dosyanın `index` satır sayımı:
15 dosyada **1**, `mutant-16`'da **2**, **`mutant-6-position-no-collate.txt`'te 0.** `git diff` her blob
değişikliği için `index <eski>..<yeni> <mod>` yazar ⇒ o blok da `git diff` çıktısı değildir.
*(Bu, kriter 5'in neden `index` üzerinden ölçülemeyeceğini de gösterir — bkz. kriter 5.)*

## 2. KAPSAM

**VAR:** `KANIT/slice-3a/`'daki **16 mutantın hepsi** için uygulanabilirliği kanıtlanmış bir yama dosyası
üretmek ve KANIT metnindeki (a) bölümünü ona bağlamak.

**YOK [PAZARLIKSIZ]:**
- **`src/**` ve `tests/**` altında kalıcı TEK SATIR değişiklik yok.** Mutasyonlar uygulanır ve **revert edilir**.
- **(b) ham kırmızı, (c) yeşil özet ve ÖZET bölümlerine DOKUNULMAZ** — onlar DÜZELTME-1'in ürünüdür.
- Yeni test, yeni kapı, yeni mutant **YOK**. Test **sayısı değişmez (110/110)**.
- **Mutant başına TAM SUITE koşulmaz** — adım 3 yalnız ÖZET'te adı geçen testleri `--filter` ile koşar.
  *(Tam suite yalnız EN SONDA, kriter 7'nin `verify.ps1` koşumunda bir kez görülür — çelişki değil,
  kapsam farkı: 16 × tam suite yerine 1 × tam suite.)*

## 3. TESLİMAT — HER MUTANT İÇİN 6 ADIM

Yeni dizin: `KANIT/slice-3a/patch/`. Dosya adı KANIT ile birebir: `mutant-<N>-<slug>.patch`.

1. Mutasyonu uygula. **Kaynak:** ilgili KANIT'ın gömülü diff bloğu (yer/niyet için) + `scope` satırı.
2. **`git diff --output=KANIT/slice-3a/patch/mutant-<N>-<slug>.patch -- <mutasyona uğrayan TÜM dosyalar>`**
   *[PAZARLIKSIZ: `>` YÖNLENDİRMESİ KULLANMA — PowerShell 5.1'de UTF-16LE+CRLF yazar. `--output`
   baytları git'e yazdırır.]*
   **[PİN] `mutant-16` İKİ dosyalıdır:** `Domain/Sync/Projection/TaskProjection.cs` **ve**
   `Domain/Sync/Projection/TaskListProjection.cs`. Kalan 15 mutant tek dosyalıdır — **doğrula, varsayma:**
   üretilen yamadaki `diff --git` satır sayısı beklenen dosya sayısına eşit olmalı; değilse **DUR**.
3. **KİLİT ADIM — yama gerçekten ısırıyor mu?** Mutasyon HÂLÂ uygulanmışken, **ÖNCE DERLE**, sonra o
   KANIT'ın **`4) ÖZET`** bölümünde adı geçen **TÜM** testleri — `HEDEF` başlığındakiler **ve** varsa
   beyan edilmiş yan ısırma (`mutant-16`'nın `DURUSTLUK BEYANI` altındaki `D0c_keyset_pagination_...`'ı
   gibi) — tek tek koş:
   ```powershell
   & dotnet build Momentum.sln --nologo            # PAZARLIKSIZ: bu satır olmadan sonraki komut
                                                    # MUTASYONSUZ ikili dosyalara koşar ve YEŞİL geçer
   $env:DOTNET_CLI_UI_LANGUAGE = 'en'
   & dotnet test Momentum.sln --no-build --nologo --blame-hang-timeout 120s --filter "FullyQualifiedName~<test adı>"
   ```
   *[PAZARLIKSIZ — v1'in kendi blokeri: `--no-build` yalnız kendinden ÖNCE `dotnet build` koşmuşsa
   geçerlidir (`araclar/verify.ps1:50,53` bu sırayı kullanır). Ayrıca `VAR=deger komut` öneki **POSIX**
   sözdizimidir, PowerShell 5.1'de çalışmaz — `$env:` biçimi pinlidir.]*
   ⇒ **hepsi FAIL vermeli.** Biri yeşil geçerse yama orijinal mutasyonu yeniden üretmiyordur ⇒ **DUR ve bildir.**
   **İSTİSNA — `mutant-8` ORTAM-BAĞIMLIDIR [beyan, KANIT'ın kendi cümlesi]:** *"bir UTC CI konteynerinde
   ISIRMAZDI"*. Bu mutantın hedef testi ancak `TimeZoneInfo.Local` UTC **değilse** kırmızı olur. Adım 3'ten
   önce `[TimeZoneInfo]::Local.Id`'yi ölç ve rapora yaz; UTC ise `mutant-8` adım 3'ten **muaftır** (adım
   2/4/5/6 yine koşulur) ve muafiyet raporda **açıkça** beyan edilir. *(Ana spec §5:377 zaten "ortam-bağımlı"
   diyor; koşulsuz kapıya çevirmek garantili yanlış DUR üretirdi.)*
   **BU ADIMIN NE KANITLADIĞI — NE KANITLAMADIĞI [dürüstlük beyanı, PAZARLIKSIZ]:** adım 3 yamanın
   **KANIT'ta kayıtlı öldürme listesini yeniden ürettiğini** kanıtlar; yamanın orijinal mutasyonla
   **bayt özdeş** olduğunu **KANITLAMAZ** (orijinal bayt kaydı zaten yok — onarılan kusur budur).
   İddia bu sınırla yazılır; daha güçlüsü yazılırsa KANIT yine yalan söyler.
4. `git checkout -- <o dosyalar>` ile **revert et**, ardından **`& dotnet build Momentum.sln --nologo`**
   ile yeniden derle *(yoksa mutasyonlu ikili dosyalar sonraki mutanta ve kriter 7'ye kirli devreder)*;
   `git diff --stat -- src` **BOŞ** olmalı.
5. **Temiz ağaçta** `git apply --check --whitespace=nowarn KANIT/slice-3a/patch/mutant-<N>-<slug>.patch`
   → **exit 0**. *(`--whitespace` `git apply`'ın seçeneğidir, `git diff`'in DEĞİL.)*
   Çıktıyı KANIT'ın (a) bölümüne yaz (adım 6).

**6. KANIT (a) BÖLÜMÜNÜN YENİ BİÇİMİ [PAZARLIKSIZ].** Gömülü diff bloğu **SİLİNİR** ve yerine tam olarak
şu üç satır yazılır (başka hiçbir şey; blok metne bir daha yapıştırılmaz):

```
YAMA: KANIT/slice-3a/patch/mutant-<N>-<slug>.patch
DOSYALAR: <mutasyona ugrayan dosyalarin tam yollari>
DOGRULAMA: git apply --check --whitespace=nowarn <yama> -> exit 0 (temiz agacta, <tarih>)
```

## 3b. ERRATA — YÜRÜRLÜKTEKİ İKİ HÜKÜM BU GÖREVLE DEĞİŞİR [açık ilan]

**ERRATA-A [KANIT KURALI v2.1 (a)].** Yürürlükteki kural: *"her KANIT: **(a) mutasyonun tam diff'i**"*
(ana spec:366; ana spec kriter 4: *"16 mutant, KANIT KURALI v2.1'e birebir uygun"*; DÜZELTME-1:427).
**Yeni hâli:** *"(a) mutasyonun **uygulanabilirliği kanıtlanmış yama dosyası** (`KANIT/slice-3a/patch/…`)
ve KANIT metninde ona işaret eden üç satırlık kayıt."* **Gerekçe:** metne gömülü diff, tam da bu kuralın
korumak istediği şeyi (ham, değiştirilmemiş kanıt) **koruyamadı** — 16 dosyanın en az 3'ünde blok elle
yazılmış ya da bozulmuş çıktı (§1). Yama dosyası aynı garantiyi **makine tarafından sınanabilir** hâle
getirir. Kural **zayıflatılmıyor, uygulanabilir kılınıyor.** DÜZELTME-1:427'nin *"(a) OLDUĞU GİBİ KALIR"*
notu **bu göreve kadar** geçerlidir; bu görev tamamlanınca yerini yukarıdaki metne bırakır.

**ERRATA-B [`mutant-16` "ONARILMAZ" hükmü].** `KANIT/slice-3a/cowork-bagimsiz-dogrulama.txt:133,139`
*"mutant-16'nın KANIT diff'i TEMİZDİR ve DOKUNULMAMALIDIR"* / *"mutant-16 ONARILMAZ (kusursuz)"* diyor.
**Bu hüküm SAPMA-3'ün (yanlış çıkan) `++ b/` teşhisine cevaptı ve o eksende hâlâ doğrudur.** Ama sonraki
ölçüm başka bir eksende kusur buldu: aynı blokta tek-boşluk bağlam satırı **0** ve iki dosya bloğu arasında
gerçek bir boş satır var (§1) ⇒ blok bayt düzeyinde uygulanabilir **değil**. **Hüküm dar kapsamda kaldırılır:**
`mutant-16` bu görevde diğer 15'le **aynı** işleme tabidir. *(Kaldırma gerekçesi ölçümdür, kanaat değil.)*

## 4. KABUL KRİTERLERİ

1. `git diff --name-only -- src tests` **BOŞ** (hiçbir mutasyon kalıntısı yok). Rapora yapıştır.
2. `KANIT/slice-3a/patch/` altında **16 yama dosyası**; adları KANIT dosyalarıyla birebir eşleşiyor.
3. **16/16 yama** temiz ağaçta `git apply --check --whitespace=nowarn` ile **exit 0**. Ham çıktı rapora.
4. **ÖZET'te adı geçen TÜM testler adım 3'te FAIL verdi** — her mutant için test adı + sonuç rapora.
   `mutant-16` = **3** (2 hedef + D0-c yan ısırması) · `mutant-1` = **2** · `mutant-14` = **2**
   (DÜZELTME-1 sonrası ÖZET'lerden okunur) · kalan **13** mutant **1'er**. Sayı ÖZET'le ayrışırsa **DUR**.
   **`mutant-8` ORTAM-BAĞIMLI:** `[TimeZoneInfo]::Local.Id` raporda; UTC ise adım 3'ten muaf ve muafiyet
   beyan edilmiş (adım 3'ün istisnası). Yani kapı **15/15 + koşullu 1**'dir, koşulsuz 16/16 değil.
5. **16 KANIT'ın (a) bölümü yeni üç satırlık biçimde**; hiçbirinde `diff --git`, `@@` veya `+++ b/`
   satırı kalmadı — `grep -c` ile göster (beklenen **0**).
   *[`index ` ile ÖLÇME: `mutant-6`'nın bloğunda `index` satırı **zaten yok** (§1, üçüncü kusur) ⇒ o
   dosyada kriter boş yere geçerdi. `diff --git` 16/16'da mevcuttur, ayırt edici olan odur.]*
6. **(b), (c) ve ÖZET bölümleri BAYT OLARAK DEĞİŞMEDİ** — `git diff -- KANIT` çıktısında değişen satırlar
   yalnız (a) bölümünde olmalı. **Bu kriteri raporda kanıtla.**
7. `araclar/verify.ps1` **DEĞİŞMEDEN** geçer (Docker açık), **exit 0**, **110/110**.
8. `.gitignore` yama dosyalarını **elemiyor** (`git status` onları görüyor). `CLAUDE.md` kırmızı çizgi 5
   ("build artefaktları git-ignore") ile çelişmez: bunlar build artefaktı değil **kanıt artefaktıdır**.
   Teyidi rapora yaz.

## 5. TESLİM PROTOKOLÜ

1. `araclar/verify.ps1` (Docker açık) — TÜM çıktı rapora.
2. Commit (ASCII): `docs(kanit): store mutant diffs as verifiable patch artifacts`. **Push YAPMA** (Cowork).
3. Rapor: (a) kriter 1'in çıktısı, (b) 16 yamanın `apply --check` ham çıktısı, (c) 16 mutantın hedef-test
   FAIL kanıtı, (d) kriter 6'nın `git diff -- KANIT` kanıtı, (e) sapma/varsayım **TAM** listesi.

## 6. KIRMIZI ÇİZGİ

> Bir yama `git apply --check`'ten geçmiyorsa, ya da adım 3'te hedef test **yeşil** kalıyorsa:
> **yamayı elle DÜZENLEME, KANIT'ı yeniden YAZMA, "yaklaşık aynı" deme. DUR ve Cowork'e bildir.**
> Bu görevin varlık sebebi tam olarak **elle yazılmış kanıtı ortadan kaldırmaktır**; elle onarım
> düzeltmeye çalıştığı kusuru yeniden üretir. **İSTİSNA YOKTUR.**

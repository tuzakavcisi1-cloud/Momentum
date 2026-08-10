# BAĞIMSIZ DENETİM — `IS-EMRI-o69-backend-CI-TASLAK.md`

**Denetçi:** taslağı yazan el DEĞİL. **Tarih:** 10 Ağu 2026. **Erişim:** cihaz mount'u salt-okunur
(`/sessions/rcw-01nspiuevsjnvgtrxjnu2yvh/mnt/Momentum`), hiçbir dosya değiştirilmedi, `.git/index.lock`
tur başında ve sonunda **YOK** (ölçüldü: `ls -la .git/index.lock` ⇒ yok).

**Özet hüküm:** taslak **8 BLOKER · 6 MAJOR · 6 MINOR** taşıyor. İki mutanttan ikisi **eşdeğer**
(üçün ikisi), iki kapsam kapısının ikisi de **kör**, taban sayısı **yanlış** ve iş emri başlığındaki
iki borç iddiasından biri **gövde tarafından açıkça reddediliyor**.

---

## BLOKER

### B1 — Taban `33` YANLIŞ; ölçüm **32**. Kriter 1, Claude Code hiçbir şeye dokunmadan KIRMIZI yanar.

**Nerede:** taslak başlık bloğu (*"Taban **33 · 6 · 41** (`git ls-files`); büyürse **DUR**"*) ve §4 kriter 1.

**Ne ile ölçtüm:**
```
git --no-optional-locks ls-files GOREV_CLAUDE_CODE | wc -l   =>  32
git --no-optional-locks ls-files docs/ADR          | wc -l   =>   6
git --no-optional-locks ls-files araclar           | wc -l   =>  41
```

`docs/ADR` ve `araclar` **doğru**. `GOREV_CLAUDE_CODE` **32**, taslağın dediği 33 değil.

**Kök neden ölçüldü:** dizinde **izlenmeyen bir dosya** var:
```
git --no-optional-locks status --porcelain GOREV_CLAUDE_CODE
?? GOREV_CLAUDE_CODE/GOREV-ADR0004-KAPISI-ONARIM-1-INDEKS.md
```
32 izlenen + 1 izlenmeyen = 33. `DURUM.md`:81 `K175`② de aynı sayıyı taşıyor (birebir):
*"taban **33·6·41** (o68, `ls-files`), büyürse **DUR**"* — yani **kaynak belgedeki sayı da bugün
üretilemiyor.** Taslak onu kopyaladı ve **doğrulamadı**.

**Sonuç:** Claude Code kriter 1'i turun başında koşar, 32 ≠ 33 görür ve `DUR` der. **t=0'da yanlış kırmızı.**

**GÜVEN: KESİN** · **BLOKER**

---

### B2 — Kriter 1 ve kriter 2 **KÖR KAPI**: ikisi de izlenmeyen dosyayı GÖREMEZ — `K175`②'nin tam olarak koruduğu sınıf.

**Nerede:** §4 kriter 1 (*"⇒ **33 · 6 · 41** (izlenmeyenler dâhil)"*) ve kriter 2.

**Ne ile ölçtüm — depoda canlı kanıt:**
```
git --no-optional-locks ls-files GOREV_CLAUDE_CODE
  -> 32 satır; GOREV-ADR0004-KAPISI-ONARIM-1-INDEKS.md LİSTEDE YOK

git --no-optional-locks ls-files --others --exclude-standard GOREV_CLAUDE_CODE
  -> GOREV_CLAUDE_CODE/GOREV-ADR0004-KAPISI-ONARIM-1-INDEKS.md
```

`git ls-files` **yalnız izlenen** dosyaları listeler. Kriter 1'in parantezi — *"(izlenmeyenler dâhil)"* —
**komut hakkında yanlış bir beyandır**: aracın yapmadığı bir şeyi yaptığını söylüyor. Bu, taslağın
kendi aradığı **"ölçülmemiş iddia"** sınıfının birebir örneğidir.

**Kör kalan senaryo:** Claude Code `GOREV_CLAUDE_CODE/` altına yeni bir `.md` açar ve `git add` etmez
⇒ `ls-files` **32** kalır ⇒ kapı **YEŞİL** ⇒ `K175`② ihlali **görünmez**. Depoda **şu anda tam olarak
bu durumda bir dosya duruyor** ve iki kapının ikisi de onu görmüyor.

Kriter 2 aynı körlüğü tekrarlıyor: `git --no-optional-locks diff --name-only HEAD` **yalnız izlenen
dosyalardaki değişikliği** gösterir; yeni izlenmeyen dosya çıktıda **hiç görünmez**.

**Düzeltme yönü:** `git ls-files --cached --others --exclude-standard <dizin> | wc -l` (ya da
`git status --porcelain` ile `??` sayımı). Sayı düzeltilirse taban **33** olur ama o taban **zaten
ihlal eden bir dosyayı** meşrulaştırır — Onur'un o dosya hakkında ayrı karar vermesi gerekir.

**GÜVEN: KESİN** · **BLOKER**

---

### B3 — Kriter 1'in komutu **üç sayı üretemez**; tek sayı üretir ve o da tutmuyor.

**Nerede:** §4 kriter 1, birebir:
> `git ls-files GOREV_CLAUDE_CODE docs/ADR araclar | wc -l` ⇒ **33 · 6 · 41**

**Ne ile ölçtüm:**
```
git --no-optional-locks ls-files GOREV_CLAUDE_CODE docs/ADR araclar | wc -l   =>  79
```

Tek `wc -l` **tek sayı** döndürür. `33 · 6 · 41` bu komutun döndürebileceği bir değer **değildir**.
Toplansa bile: ölçülen **79**, taslağın ima ettiği 33+6+41 = **80**. Kriter yazıldığı hâliyle
**koşturulamaz** — builder kendi yorumunu uydurmak zorunda kalır.

**GÜVEN: KESİN** · **BLOKER**

---

### B4 — `M-o69-3` **EŞDEĞER MUTANT** ve kriter 6 **KÖR + YANLIŞ**: testler `services: postgres`'i hiç kullanmıyor, **Testcontainers ile kendi konteynerini açıyor**.

**Nerede:** §3 ayak 1/2/6, §4 kriter 6, §5 `M-o69-3`.

**Ne ile ölçtüm:**
```
tests/Momentum.Persistence.Tests/Momentum.Persistence.Tests.csproj:9
  <PackageReference Include="Testcontainers.PostgreSql" Version="4.13.0" />

tests/Momentum.Persistence.Tests/TestSupport.cs:20-23
  public Testcontainers.PostgreSql.PostgreSqlContainer Container { get; } =
      new Testcontainers.PostgreSql.PostgreSqlBuilder("postgres:17-alpine").Build();
  public Task InitializeAsync() => Container.StartAsync();
```
Bağlantı dizesi **hiçbir ortam değişkeninden** gelmiyor; her testte `fixture.Container.GetConnectionString()`
üzerinden üretilip `UseSetting("ConnectionStrings:Momentum", connectionString)` ile enjekte ediliyor
(`TestSupport.cs:41,49` · `EndpointTests.cs:54,56` · `DevKimlikKapisi200Testleri.cs:29` ·
`RealtimeMembershipTests.cs:99` · `ScopeAndDriftAnchorTests.cs:87` · `TaskMaterializationD0Tests.cs:57,60,150`).

**Dört ayrı sonuç:**

1. **`services: postgres` hiçbir test tarafından aranmıyor.** Tasarımın merkezindeki blok ölü ağırlık.

2. **`M-o69-3` eşdeğerdir.** Taslağın beklentisi birebir: *"CI **KIRMIZI**; `pg_isready` yoklaması
   **tavanda düşer**, `dotnet test` bağlantı hatası verir"*. İkinci yarısı **YANLIŞ** — `dotnet test`
   kendi konteynerini açar ve **geçer**. Mutant yalnız *aynı spec'in az önce eklediği* `pg_isready`
   adımının varlığını ölçer: **kendi kendine referans veren totoloji**. Hedefi (*"kriter 6 / DB ayağı"*)
   ıskalıyor. Bu, taslağın §5'te **kendi yasakladığı** `M167` sınıfıdır.

3. **Kriter 6 kör VE yanlış.** Birebir: *"`dotnet test` sonucu **gerçek PostgreSQL'e karşı** alındı —
   servisin ayakta olduğu `pg_isready` çıktısıyla **aynı logda** kanıtlanır."* İki satırın aynı logda
   bulunması nedensellik kurmaz; burada üstelik **atıf fiilen yanlıştır** — testler `services:`
   konteynerine değil, **Testcontainers'ın açtığı başka bir PostgreSQL'e** bağlanıyor. Kapı YEŞİL
   yanarken iddia YANLIŞ olur.

4. **§3 ayak 6 yanlış öncüle dayanıyor:** *"Bağlantı dizesi Ö3'te ölçülen ad ile ortam değişkeni olarak
   verilir."* Böyle bir ad **yok**. Ö3 bunu arayacak ve bulamayacak — ama §3 ayak 6 zaten *"verilir"*
   diye emir kipinde yazılmış, yani ölçümün sonucu ne olursa olsun uygulanacak bir talimat.

**Not (bu turu KURTARAN gerçek):** Testcontainers ubuntu-latest'te Docker olduğu için çalışır; yani
backend işi `services:` bloğu **hiç olmadan** yeşil koşabilir. Doğru tasarım kararı muhtemelen
`services:` bloğunu **tamamen çıkarmak** ve kriter 6'yı *"testler kendi Testcontainers konteynerini
açtı"* diye **gerçekten ölçülebilir** bir iddiaya çevirmektir.

**GÜVEN: KESİN** · **BLOKER**

---

### B5 — `M-o69-1` **EŞDEĞER MUTANT**: `-warnaserror` zaten gereksiz, `TreatWarningsAsErrors=true` MSBuild'de açık.

**Nerede:** §5 `M-o69-1` ve altındaki gerekçe.

Taslak birebir şunu iddia ediyor:
> `M-o69-1` bu yüzden **`-warnaserror`'ın kendisini** hedefler, linter'ı değil.

**Ne ile ölçtüm:**
```
src/backend/Directory.Build.props:16   <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
tests/Directory.Build.props:14         <TreatWarningsAsErrors>true</TreatWarningsAsErrors>

ls src/   =>  backend  client
ls src/backend/  =>  Momentum.Api  Momentum.Application  Momentum.Domain  Momentum.Infrastructure
```

Momentum.sln'deki **her** .NET projesi ya `src/backend/**` ya `tests/**` altında; ikisinin de
`Directory.Build.props`'u uyarıları **zaten hataya çeviriyor**. Dolayısıyla `verify.ps1:50`'deki
CLI bayrağı (`& $dotnet build $solution -warnaserror --nologo`) **tamamen gereksizdir**.

**Sonuç:** ürün koduna kasıtlı bir uyarı eklemek, `-warnaserror` bayrağı **olsa da olmasa da** build'i
kırar. Mutant, hedeflediğini iddia ettiği mekanizmayı **ayırt edemez**. Log'daki hata `-warnaserror`
kaynaklı mı, `TreatWarningsAsErrors` kaynaklı mı — **log bunu söylemez**, dolayısıyla taslağın
beklentisi (*"log'da `-warnaserror` kaynaklı hata"*) **ölçülemez bir beklentidir**.

Mutantın *bir şey* ölçtüğü doğru ("build ayağı koştu ve uyarı build'i kırıyor"), ama **beyan edilen
çekirdek iddiayı** ölçmüyor — taslağın kendi tanımıyla (§5, birebir: *"bir mutant hedeflediği ayağın
**çekirdek iddiasını** ölçmüyorsa ölüdür"*) **ölüdür**. Taslak, yasağı yazdığı paragrafın iki satır
üstünde yasağı ihlal ediyor.

**GÜVEN: KESİN** · **BLOKER**

---

### B6 — Başlıktaki `B-O63-2` kapatma iddiası **gövde tarafından reddediliyor**; `D-A13-4`'ün kapanış eylemi ise **iş emrinde hiç yok**.

**Nerede:** taslak başlığı (*"İŞ EMRİ (o69) — BACKEND CI · `D-A13-4` + `B-O63-2`"*) ↔ §0 ↔ §6.

**`B-O63-2` — doğrudan çelişki. Ne ile ölçtüm:**
```
BORCLAR.md:127  "B-O63-2 — --no-web-resources-cdn CI'DA ZORLANMIYOR ... CI'ya bağlanmadı."
docs/ADR/0004-web-capraz-koken-izolasyonu.md:145
   "⇒ B-O63-2 AÇIK; bağlanması D-A13-4 turuna aittir."
```
Ama taslak §0: *"**Kapsam:** yalnız **backend**. Web yayın işi ve belge kapıları **bu turda YOK**."*
ve §6: *"`B-W3b-6`…`10` ve `B-O63-x` **açık kalır**."*

⇒ **Başlık kapattığını söylediği borcu gövde açıkça kapatmayı reddediyor.** Üstelik §1 aynı borcun
konusunu ölçüyor (`--no-web-resources-cdn` **0** eşleşme) ve hiçbir şey yapmıyor.

**`D-A13-4` — kapanış eylemi eksik. Ne ile ölçtüm** (`GOREV_CLAUDE_CODE/GOREV-A13-ios-iskeleti-ci.md:296`,
birebir):
> KURAL: D-A13-4 | GEREKCE: bu bir YAPMAMA kararidir ... **Kapanis yolu: backend CI'ya girdigi
> dilimde (planlanan: 9) bu satir silinir ve gercek bir kapi+mutant yazilir.** Borc BEYAN
> EDILMISTIR, gizlenmemistir.

Yani `D-A13-4`'ün **kendi beyan ettiği kapanış yordamı** `GOREV-A13-ios-iskeleti-ci.md`'nin §6b
satırını **silmeyi** gerektiriyor. Taslakta böyle bir adım **yok** ve kriter 2 değişebilecek tek
dosyayı `ci.yml` ile sınırlıyor. Borç, kapandığı iddia edilen turdan sonra da **açık metinde** kalır.

Ayrıca bu tura **üç ayrı belge** işaret ediyor ve hiçbiri güncellenmeyecek:
```
GOREV_CLAUDE_CODE/GOREV-W3b-web-yayina-alma.md:89   "CI'ya bağlama — D-A13-4 turunda"
GOREV_CLAUDE_CODE/GOREV-W3b-web-yayina-alma.md:372  "CI'ya bağlanması D-A13-4 turundadır."
GOREV_CLAUDE_CODE/GOREV-W3b-web-yayina-alma.md:376  "... CI'nın bu kapıyı ... koşup koşmayacağı D-A13-4'e aittir."
```
`CLAUDE.md` K58 dersi bunu tam olarak yasaklıyor (birebir): *"**bir sınırı kapatan el, o sınırı BEYAN
EDEN her kopyayı aynı anda kapatmak zorundadır** — yoksa kapanan borç belgede açık görünmeye devam eder."*
Burada tersi olacak: **kapanmayan borç kapanmış gibi başlıklanacak.**

**Düzeltme yönü:** ya başlıktan `B-O63-2` çıkarılır ve `D-A13-4` için satır-silme adımı eklenir
(kriter 2 buna izin verecek şekilde yazılır), ya da tur kapsamı gerçekten genişletilir. **Onur'un kararı.**

**GÜVEN: KESİN** · **BLOKER**

---

### B7 — §6 (*"`verify.ps1` **değişir**"*) ile kriter 2 (*"`ci.yml` dışında ürün dosyası yok"*) **doğrudan çelişiyor**; ve `verify.ps1`'in Linux'ta koşması **kuşkulu**.

**Nerede:** §6 son madde ↔ §4 kriter 2 ↔ §0 tasarım kilidi.

**Ölçülen `verify.ps1` gerçekleri:**
```
araclar/verify.ps1:1   #requires -Version 5.1
araclar/verify.ps1:11  $ErrorActionPreference = 'Stop'
araclar/verify.ps1:12  Set-StrictMode -Version Latest
araclar/verify.ps1:26  $preferred = Join-Path $env:ProgramFiles 'dotnet\dotnet.exe'
araclar/verify.ps1:57  $env:MOMENTUM_KANIT_DIZIN = Join-Path $repoRoot 'KANIT\slice-3d\07-G7-backend-zorlama'
araclar/verify.ps1:59  New-Item -ItemType Directory -Force -Path $env:MOMENTUM_KANIT_DIZIN | Out-Null
```

**İki Linux tehlikesi:**

- **Satır 26 — muhtemel ölümcül.** Linux'ta `$env:ProgramFiles` tanımsızdır ⇒ `Join-Path`'in zorunlu
  `-Path` parametresine `$null` bağlanır. PowerShell bunu parametre-bağlama hatasıyla reddeder ve
  `$ErrorActionPreference='Stop'` altında bu **sonlandırıcı** olur — script daha ilk adıma gelmeden ölür.
  🔴 **Bu hükmü ÖLÇEMEDİM** (aşağıya bak) — PowerShell semantiğinden **türetilmiştir**. **GÜVEN: ZAYIF.**

- **Satır 57 — kesin, ters eğik çizgi yol literali.** Linux'ta bu, adının içinde ters eğik çizgi geçen
  **tek bir dizin** yaratır (`KANIT\slice-3d\07-G7-backend-zorlama`). Bu değişken yük taşıyor:
  ```
  tests/Momentum.Persistence.Tests/D9OwnerIdVisibilityTests.cs:52-53
    var kanitDizini = Environment.GetEnvironmentVariable("MOMENTUM_KANIT_DIZIN")
        ?? throw new InvalidOperationException("MOMENTUM_KANIT_DIZIN ortam degiskeni ayarli degil ...");
  ```
  **GÜVEN: KESİN** (kod ölçüldü; Linux'taki sonucu türetildi).

**Asıl kusur ölçüm değil, SIRA.** §0 tasarımı **kilitlemiş**: *"`ubuntu-latest` + `services: postgres`
+ **pwsh ile MEVCUT `araclar/verify.ps1`**"* ve *"🔴 **İKİNCİ BİR ZİNCİR YAZILMAYACAK**"*. Ama
uygulanabilirliği ölçecek olan Ö2/Ö4 **§2'de, kilitten SONRA** duruyor. `CLAUDE.md` K53/5 birebir:
*"**YÜRÜYEN İSKELET ÖNCE, KAPILAR SONRA.** Koşan kod üzerindeki kapı kendini doğrular; kâğıt üzerindeki
kapı doğrulanamaz."* Burada tasarım, **ölçülmemiş bir varsayım üzerine kilitlenmiş**.

**Ve çelişki:** §6 uyumsuzluk hâlinde `verify.ps1`'in **değişeceğini** söylüyor; kriter 2 `ci.yml`
dışında dosya değişmesini yasaklıyor. İkisi aynı anda tutamaz. Taslak bunu çözmüyor, üstelik
*"Onur'dan kilit iste"* diyerek Claude Code'u **turun ortasında kilitleniyor** — devir yordamı yazılmamış.

**GÜVEN: verify.ps1 içeriği KESİN · Linux davranışı ZAYIF · çelişki KESİN** · **BLOKER**

---

### B8 — Mutantlar **push gerektiriyor**, kriter 10 **"PUSH ONUR'DA"** diyor: iş emri Claude Code tarafından **tamamlanamaz**.

**Nerede:** §4 kriter 4/5/6/7/8 ↔ kriter 10.

**Ne ile ölçtüm** — `.github/workflows/ci.yml` tetikleri (birebir):
```yaml
on:
  workflow_dispatch: {}
  push:
    branches: [main]
```

Kriter 4 (backend işi yeşil koştu), 5 (üç ayak logda), 6 (DB), 7 (üç mutant eksiksiz koştu) — hepsi
**gerçek CI koşumu** ister. Üç mutant + geri yüklemeler + taban koşumu ⇒ **en az dört, gerçekçi olarak
yedi** koşum. Kriter 10 ise birebir: *"**PUSH ONUR'DA.**"*

Taslak bu döngüyü **hiç tarif etmiyor**: kim, kaç kez, hangi sırayla, hangi dala push eder;
Claude Code her mutant sonrası nasıl bekler; Onur'a ne teslim edilir. **Uygulanamaz talimat.**

**Ek tehlike:** kriter 8 `gh run list --branch <dal>` zorunlu kılıyor, yani yan dal ima ediliyor.
Ama `push: branches: [main]` yüzünden **yan dala push CI'yı TETİKLEMEZ**; yalnız `workflow_dispatch`
tetikler. Taslak dal stratejisini yazmadığı için mutant koşumlarının nasıl tetikleneceği belirsiz.
🔴 `workflow_dispatch`'in yan dalda fiilen çalışıp çalışmayacağını **ölçemedim** — **GÜVEN: ZAYIF**
(tetikleyici bloğunun kendisi **KESİN**).

**GÜVEN: tetikler KESİN · push döngüsü boşluğu KESİN · dal davranışı ZAYIF** · **BLOKER**

---

## MAJOR

### M1 — `araclar/ci-kapisi.py` **VAR** ve tam da bu dosyayı statik kapılıyor; iş emri onu **hiç anmıyor**.

**Ne ile ölçtüm:** `ls araclar/` ⇒ `ci-kapisi.py` mevcut, **418 satır**. Docstring birebir:
> `ci-kapisi.py` -- GOREV-A13 icin CI dosyasi + iOS iskeleti STATIK denetimi. ...
> OLCER : A13/G28/a,b (istemci isi) * A13/G29/a (ios isi) * A13/G30/a,b,c ...

Değiştirilecek artefaktın **mevcut regresyon kapısı** §4'te yok. Bu, kriter 3'ün (*"istemci ve ios
bayt-özdeş"*) **en ucuz ve en mekanik** kanıtıdır: statik, koşan CI istemez, saniyeler sürer —
`CLAUDE.md` K53/3'ün *"statik mutantlar **tavansız**"* dediği tam sınıf. Kapıyı koşturmamak, elde
duran ölçüm aracını kullanmamaktır.

**GÜVEN: KESİN** · **MAJOR**

### M2 — Kriter 3'ün ölçüm **yöntemi tanımsız** — "YAML gövdesi"nin sha256'sı nasıl alınacak yazılmamış.

`ci.yml` **tek dosyadır**; bir "iş gövdesi"ni ayıklayıp sha256 almanın yordamı belirtilmemiş.
Builder kendi ayıklamasını tanımlar ⇒ kriter **yanlışlanamaz** hâle gelir (ayıklamayı istediği gibi
seçen el daima yeşil üretir).

Elde hazır ve deterministik alternatif **ölçüldü**:
```
sha256sum .github/workflows/ci.yml
283d785e9fc3ee91d65ba2f0eee0764bb111c6c7e8e1ad0604a8563269ec22d1
```
artı `ci-kapisi.py` yeşil (M1) artı satır-aralığı diff'i.

**İlgili ölçüm — satır sonu tuzağı YOK:** `.gitattributes:2` ⇒ `* text=auto eol=lf`, yani `ci.yml`
hem depoda hem çalışma ağacında **LF**. `ORTAM.md`:38'in `core.autocrlf` uyarısı `ci.yml` için
ısırmaz. 🔴 **Ama `.gitattributes:8` ⇒ `*.ps1 text eol=crlf`** — §6'daki `verify.ps1` düzeltmesi
yapılırsa o dosya **CRLF**'tir ve `ORTAM.md`:38'in ikili-yedek yordamı **zorunlu** olur.

**GÜVEN: KESİN** · **MAJOR**

### M3 — §3 ayak 4'ün ikinci şıkkı kriter 3'ü kırar (belirsiz kapsam).

§3/4 birebir: *"mevcut `defaults` bloğu iş düzeyinde ezilir **ya da tüm adımlarda açık
`working-directory` verilir**"*. "Tüm adımlar" depo genelinde okunursa üstteki `defaults` bloğu
kalkar ve `istemci`/`ios` gövdeleri **değişir** ⇒ kriter 3 düşer. Yalnız **iş düzeyinde ezme**
şıkkı kriter 3 ile uyumludur; taslak bunu pinlemiyor.

Ölçülen mevcut blok:
```yaml
defaults:
  run:
    working-directory: src/client
```

**GÜVEN: KESİN** · **MAJOR**

### M4 — §3 ayak 7 `ASPNETCORE_ENVIRONMENT`: **değer verilmemiş**, gerekçe **yanlış bağlamdan** taşınmış, ve pratikte **gereksiz**.

§3/7 birebir: *"`ASPNETCORE_ENVIRONMENT` **açıkça** set edilir (`K61`; aksi hâlde `NullCurrentUser`
⇒ **401**)."* — **hangi değere** set edileceği yazılmamış.

`K61`'in gerekçesi **API'yi sunucu olarak koşturmakla** ilgilidir. Bu iş `verify.ps1` koşuyor;
`verify.ps1` **API'yi hiç ayağa kaldırmıyor** — ölçüldü: yalnız `build` (satır 50), `test` (satır 62)
ve CVE kapısı. Kural **başka bir bağlamdan taşınmış**.

Testler zaten ortamı **kendileri pinliyor** (ölçüldü):
```
tests/Momentum.Api.Tests/DevKimlikKapisiTestleri.cs:29  .WithWebHostBuilder(b => b.UseEnvironment("Development"))
tests/Momentum.Api.Tests/DevKimlikKapisiTestleri.cs:59  .WithWebHostBuilder(b => b.UseEnvironment("Production"))
tests/Momentum.Api.Tests/ProblemDetailsTests.cs:20      builder.UseEnvironment("Production")
tests/Momentum.Persistence.Tests/DevKimlikKapisi200Testleri.cs:28  b.UseEnvironment("Development")
```
ve `DevKimlikKapisiTestleri.cs:51-52` bunun **neden** böyle olduğunu birebir yazıyor:
> GOREV kirmizi uyari (G1): WAF varsayilani Development'tir -- pinlenmezse bu ayak kendiliginden
> gecer ve kapi korlesir.

⇒ Ortam değişkeni **en iyi ihtimalle etkisiz**; pinlemeyen herhangi bir test için ise **sessizce
davranış değiştirir**. Değeri yazılmamış bir talimat, builder'a kör bir seçim bırakıyor.

**GÜVEN: KESİN** · **MAJOR**

### M5 — Kriter 7'nin geri-yükleme ayağı **kör**: yalnız `ci.yml`'i ölçüyor, ama `M-o69-1`/`M-o69-2` `ci.yml`'e **hiç dokunmuyor**.

Kriter 7 birebir: *"her mutant sonrası `ci.yml` **bayt-özdeş** geri yüklendi (sha256 ile)"*.

- `M-o69-1` → `src/backend/**` altında ürün kodunu değiştirir.
- `M-o69-2` → `tests/**` altında bir testi değiştirir.
- `M-o69-3` → **tek** `ci.yml`'e dokunan mutant.

Üç mutantın ikisinde `ci.yml`'in sha256'sı **dokunulmamış bir dosyayı ölçtüğü için otomatik yeşildir**;
**fiilen değiştirilen dosyaların geri yüklenmesi ise hiç ölçülmez**. Kirli ağaç bırakan iki mutant
kapıdan geçer.

**GÜVEN: KESİN** · **MAJOR**

### M6 — Kriter 2'deki **"ürün dosyası" tanımsız**; `K53`/4'ün yürürlükteki tanımıyla araç/betik/belge **ürün değildir** ⇒ kapı geniş bir sınıfa kör.

Kriter 2 birebir: *"...çıktısında **`.github/workflows/ci.yml` DIŞINDA** ürün dosyası yok (kanıt ve
`KANIT/CI/**` hariç)"*.

`CLAUDE.md` K53/4 birebir: *"**Araç/betik/belge SAYILMAZ.**"* Bu tanım altında `araclar/*.py`,
`araclar/verify.ps1` ve tüm `*.md` **"ürün dosyası" değildir** ⇒ kriter 2 bunların sessizce
değiştirilmesine **izin verir**. §6 zaten bu boşluktan içeri giriyor (`verify.ps1` düzeltmesi, B7).

**GÜVEN: KESİN** · **MAJOR**

---

## MINOR

### m1 — §1'in Testcontainers ölçümü **koşuldu ama yanlış okundu**.

§1 birebir: *"`grep -rl \"Testcontainers\\|Npgsql\\|ConnectionString\" tests/` ⇒
`Momentum.Persistence.Tests` **Npgsql kullanıyor**."*

Desen **"Testcontainers" kelimesini zaten içeriyordu**; `-l` (yalnız dosya adı) hangi alternatifin
eşleştiğini yutar. Turun **en belirleyici gerçeği** (B4) ölçümün kendi çıktısının içindeydi ve
yazıma geçerken düştü. Bu, *"ölçüldü damgalı ama ölçülmemiş"* değil, daha incesi:
**ölçüldü, okunmadı.**

**GÜVEN: KESİN**

### m2 — §1'in geri kalan sayıları **DOĞRU** (tek tek ölçüldü).

| §1 iddiası | ölçüm | hüküm |
|---|---|---|
| `ci.yml` = 580 b | `wc -c` ⇒ **580** | ✅ |
| iki iş: `istemci` + `ios` | `cat` ⇒ tam olarak bu ikisi | ✅ |
| `flutter analyze --fatal-infos` · `flutter test` · `flutter build ios --no-codesign` | `cat` ⇒ üçü de aynen var | ✅ |
| `dotnet` 0 · `verify` 0 · `--no-web-resources-cdn` 0 · `postgres` 0 | `grep -c` ⇒ 0 · 0 · 0 · 0 | ✅ |
| `global.json` ⇒ 10.0.302 / latestPatch | `cat` ⇒ `"version": "10.0.302"`, `"rollForward": "latestPatch"` | ✅ |
| `tests/` altında dört proje | `ls tests/` ⇒ dördü de var | ✅ (+ `Directory.Build.props`, taslakta anılmamış) |
| taban `6` (docs/ADR) · `41` (araclar) | `ls-files` ⇒ 6 · 41 | ✅ |
| taban `33` (GOREV) | `ls-files` ⇒ **32** | ❌ **B1** |

🔴 Anılmayan `tests/Directory.Build.props` masum değildi — **B5'in kanıtı oradaydı**.

**GÜVEN: KESİN**

### m3 — §3 ayak 1: postgres sürümü zaten iki yerde **bağımsız olarak** pinli.

`docker-compose.yml` (ölçüldü): `image: postgres:17-alpine` · `POSTGRES_DB: momentum` ·
`POSTGRES_USER: ${POSTGRES_USER:-momentum}` · `POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-momentum_dev}`.
`TestSupport.cs:21` (ölçüldü): `new ...PostgreSqlBuilder("postgres:17-alpine")`.

*"Oku, uydurma"* talimatı ruhen doğru ama **gerçek risk adlandırılmamış**: aynı sürüm **iki ayrı
kaynakta elle** duruyor ve birbirinden habersiz kayabilir. (B4 kabul edilirse `services:` blok
tümden kalkar ve bu madde konusuz kalır.)

**GÜVEN: KESİN**

### m4 — Kriter 5'in *"ayrı ayrı görünür"* ölçüm yöntemi yazılmamış.

Hangi dizge aranacak belirtilmemiş. `verify.ps1` kullanılabilir çapalar üretiyor (ölçüldü):
`--- build -warnaserror ---` · `--- test ---` · `--- CVE gate (dotnet list package --vulnerable) ---` ·
`CVE gate clean: 0 vulnerable packages.` · `== VERIFY PASSED ==`. Taslak hiçbirini adlandırmıyor.

**GÜVEN: KESİN**

### m5 — `K53`/4 · `R8` beyanı yok.

Bu turun tek ürün artefaktı bir CI iş akışı. `CLAUDE.md` K53/4 birebir: *"**Araç/betik/belge
SAYILMAZ.**"* Taslak, `ci.yml`-only bir turun `urun_kodu_satiri` sayılıp sayılmayacağını
**beyan etmiyor**. `DURUM.md`:5 şu an: *"radar KIRMIZI-yapısal, **`R8` susuyor**"* — yani bugün
ısırmıyor, ama iki tur sonra ısırırsa gerekçesi bu turda yazılmamış olacak.

**GÜVEN: metin KESİN · R8'in gelecekteki hükmü ÖLÇÜLEMEDİ**

### m6 — §2'nin `[DOĞRULANMADI]` beyanı **doğru yazılmış** — düzeltme turunda silinmesin.

§2'deki *"🔴 Ö5 hakkında Cowork'ün bir iddiası var ama ÖLÇMEDİ ... `[DOĞRULANMADI]`"* bloğu,
taslakta **belgeye dayalı bilgiyi ölçülmüş olgudan ayıran tek yerdir** ve doğru yapılmıştır.
Kusur listesine karşı denge olarak kayda geçiyorum.

**GÜVEN: KESİN**

---

## NE ÖLÇÜLEMEDİ

1. **`verify.ps1`'in Linux/pwsh 7 altındaki gerçek davranışı.** `pwsh` bu konteynerde **kurulu değil**
   (`which pwsh` ⇒ boş çıktı; `pwsh --version` ⇒ çalışmadı) ve cihazda **salt-okunur** çalıştığım için
   mount'ta script koşturmadım. B7'nin satır-26 hükmü PowerShell parametre-bağlama semantiğinden
   **türetilmiştir, ÖLÇÜLMEMİŞTİR** ⇒ **GÜVEN: ZAYIF**. Bu tam olarak Ö2'nin işidir — **ama tasarım
   §0'da zaten kilitlenmiştir**, kusur budur.
2. **`ubuntu-latest` imajında `pwsh` var mı.** GitHub runner imajının içeriğini bu ortamdan ölçemem.
   (Ö4 zaten soruyor; not: hüküm ne çıkarsa çıksın §0 kilidi ölçümden önce verilmiştir.)
3. **`actions/setup-dotnet` + `global-json-file`'ın `10.0.302`'yi fiilen çekip çekmediği.** Ağ/servis
   ölçümü yapmadım. (Ö6 zaten soruyor.)
4. **`services:` bloğunun bu depoda çalışıp çalışmadığı** — koşan CI olmadan ölçülemez. B4 bunu
   büyük ölçüde **konusuz** kılıyor (testler kendi konteynerini açıyor), ama blok yazılırsa
   çalışacağını **ölçmedim**.
5. **`workflow_dispatch`'in yan dalda gerçekten tetiklenip tetiklenmeyeceği.** `gh` çağrısı yapmadım
   (salt-okunur çalıştım; depo erişimini ölçmedim). B8'in bu ayağı **ZAYIF**; tetikleyici bloğunun
   kendisi **KESİN**.
6. **`ci-kapisi.py`'nin 81–418. satırları.** Docstring'i ve `g28a`/`g28b`/`_yorumsuz_satirlar`
   fonksiyonlarını okudum; `g29a`/`g30*` gövdelerini **okumadım**. Yeni `backend` işinin
   `g28b_flutter_surumu`'nun *"ilk `flutter-version:` eşleşmesinde dön"* mantığını bozup bozmayacağını
   **ölçmedim** (backend işi `flutter-version` taşımayacağı için risk düşük görünüyor — **ama ölçülmedi**).
7. **`Momentum.sln`'in proje listesi.** B5'in *"solution'da başka .NET projesi yok"* ayağını
   `ls src/` + `ls src/backend/` + `ls tests/` **dizin ölçümüyle** kurdum; `.sln` dosyasını
   **ayrıştırmadım**. Dizin ölçümü KESİN, `.sln` ayrıştırması **yok**.
8. **`33` sayısının o68'de hangi komutla alındığı.** `PROJE_HAFIZA.md` **açılmadı** (`K53`/`K83`
   gereği; 1,24 MB). Bugünkü ölçüm **32**'dir; o68'in yöntemi **ölçülmedi**.
9. **`_SILINECEKLER/o69/` içeriği** ve o69'da `GOREV_CLAUDE_CODE/`'dan dosya taşınıp taşınmadığı.
   **Ölçmedim** — 32↔33 farkının B1'de verdiğim açıklamaya alternatif bir açıklaması olabilir.
10. **`M-o69-2`'nin hangi testi hedefleyeceği.** Taslak *"tek bir testin iddiasını tersine çevir"*
    diyor ama testi **adlandırmıyor**; hangi testin seçileceğine göre eşdeğerlik riski değişir
    (örn. Docker gerektiren bir Persistence testi seçilirse başka sebeple de kırmızı yanabilir).
    **Ölçülemez** — spec'te ad yok.

---

## HÜKÜM

**DÜZELT** — 8 bloker. Kilitlenemez.

**Kilitten önce en az şunlar düzelmeli:** ① taban sayısı ve sayım komutu (B1+B2+B3) · ② `services:`
tasarımının Testcontainers gerçeğine göre yeniden kararı ve kriter 6'nın yeniden yazımı (B4) ·
③ `M-o69-1` ve `M-o69-3`'ün değiştirilmesi — üç mutantın ikisi ölü (B4+B5) · ④ başlıktaki borç
iddialarının gövdeyle uzlaştırılması (B6) · ⑤ `verify.ps1`'in Linux uyumunun **kilitten ÖNCE**
ölçülmesi ve §6↔kriter 2 çelişkisinin çözülmesi (B7) · ⑥ push/mutant döngüsünün operatörüyle
birlikte yazılması (B8).

🔴 **`K127` notu:** bu denetim **kilitten ÖNCE** koştu ve bulguların **hiçbiri koşan kod
gerektirmedi** — hepsi bir okuma turuyla bulunabilirdi ve bulundu. Kilitlenecek sürüm bu denetimin
çıktı yolunu (`/home/claude/DENETIM-o69-is-emri.md`) checkpoint'inde **taşımak zorundadır**.

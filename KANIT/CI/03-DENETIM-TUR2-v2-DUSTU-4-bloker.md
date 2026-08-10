# BAĞIMSIZ DENETİM — `IS-EMRI-o69-backend-CI-v2.md` (turun **İKİNCİ** denetçisi)

**Denetçi:** taslağı yazan el DEĞİL; v1'i denetleyen el de DEĞİL. **Tarih:** 10 Ağu 2026.
**Erişim:** cihaz mount'u salt-okunur (`/sessions/rcw-01nspiuevsjnvgtrxjnu2yvh/mnt/Momentum`),
**hiçbir dosya değiştirilmedi**; her git çağrısı `--no-optional-locks` ile ve dar yapıldı
(`ORTAM.md`:44). `.git/index.lock` tur başında **YOK**, tur sonunda **YOK** (ölçüldü:
`ls -la .git/index.lock` ⇒ `No such file or directory`, iki kez).

🟢 **v1'in en büyük ÖLÇÜLEMEDİ'si bu turda KAPANDI:** bu konteynerde **pwsh 7.4.6 KURULU**
(`which pwsh` ⇒ `/usr/local/bin/pwsh`). v1 `verify.ps1:26` hükmünü *"türetilmiştir, GÜVEN: ZAYIF"*
diye yazmıştı; ben onu **koşarak** ölçtüm. Aşağıda birebir çıktı var.

**Özet hüküm:** v2, v1'in sekiz blokerinden **beşini gerçekten kapatmış**, üçünü **kısmen**
kapatmıştır. Buna karşılık **4 YENİ BLOKER · 4 MAJOR · 4 MINOR** üretmiştir. İki blokeri
kontrollü ölçümle **mekanik olarak kanıtladım** (kriter 3'ün körlüğü bir depoda koşturuldu;
`verify.ps1:26` pwsh'te koşturuldu).

---

# BÖLÜM A — v1 BLOKERLERİNİN KAPANIŞ TABLOSU

| # | konu | hüküm | ölçüm |
|---|---|---|---|
| **B1** | taban `33` yanlış | 🟢 **KAPANDI** | üç dizin ayrı ayrı ⇒ **32 · 6 · 41**; kök neden fiilen giderilmiş |
| **B2** | sayım komutu izlenmeyene kör | 🟡 **KISMEN** | kriter 1 kapandı; kriter 2'de **yeni bir körlük** doğdu (→ `Y3`) |
| **B3** | komut üç sayı üretemiyor | 🟢 **KAPANDI** | "üç dizin için **ayrı ayrı** koşar" — koşturdum, üç sayı geldi |
| **B4** | `services:` / Testcontainers | 🟢 **KAPANDI** | `services:` tasarımdan çıktı; yeni `M-o69-3`'ün ayırt ediciliği **ölçüldü ve geçerli** |
| **B5** | `-warnaserror` eşdeğer mutant | 🟢 **KAPANDI** | yeni `M-o69-1`'in `--- test ---` çapası **pwsh'te koşturuldu**, gerçekten hiç görünmüyor |
| **B6** | borç iddiası çelişkisi | 🟡 **KISMEN** | başlık düzeldi, `:296` doğru; ama **sarkan atıf sayısı YANLIŞ** — üç değil, **altı** (→ `Y3`) |
| **B7** | `verify.ps1` Linux + kriter çelişkisi | 🟡 **KISMEN** | Linux hükmü artık **KESİN**; çelişki çözüldü; ama kriter 4'ün Windows ayağı **kör** (→ `Y7`) |
| **B8** | push döngüsü | 🟢 **KAPANDI** | mutantlar CI'dan yerele alındı, tek gerçek koşum kaldı — **ama bedel ortam maddesine kaydı** (→ `Y1`) |

---

## B1 — 🟢 KAPANDI (KESİN)

**Ne ile ölçtüm** (cihaz, mount):
```
git --no-optional-locks ls-files --cached --others --exclude-standard GOREV_CLAUDE_CODE | wc -l  => 32
git --no-optional-locks ls-files --cached --others --exclude-standard docs/ADR           | wc -l  =>  6
git --no-optional-locks ls-files --cached --others --exclude-standard araclar            | wc -l  => 41
```
v2 §0.4 birebir: *"**Taban 32 · 6 · 41**, sayım komutu **`ls-files --cached --others --exclude-standard`**"*
⇒ **ölçümle birebir uyuşuyor.**

**Kök neden de fiilen giderilmiş** (v1'in bulduğu izlenmeyen dosya artık orada değil):
```
git --no-optional-locks ls-files --others --exclude-standard GOREV_CLAUDE_CODE   =>  (BOŞ)
ls _SILINECEKLER/o69/  =>  GOREV-ADR0004-KAPISI-ONARIM-1-INDEKS.md  (+4 dosya)
```
Ve kanonik kaynak da düzeltilmiş — `DURUM.md`:81 birebir:
> *"② **YENİ ARTEFAKT YASAĞI** … taban **32·6·41** 🔴 **[o69'da DÜZELTİLDİ]** — o68 **33** yazmıştı,
> `ls-files` bugün **32** ölçüyor; fark, `ADR 0004` parkıyla **öksüz kalan izlenmeyen** onarım
> indeksiydi (Onur `_SILINECEKLER/o69/`'a aldırdı). 🔴 **Sayım
> `ls-files --cached --others --exclude-standard` ile yapılır**…"*

⇒ Beyan **kaynağa da işlenmiş**; `K58` dersi bu ayakta doğru uygulanmış. **GÜVEN: KESİN**

## B2 — 🟡 KISMEN (KESİN)

**Kriter 1 kapandı.** Komut artık `--others --exclude-standard` taşıyor; izlenmeyeni **gördüğünü**
kontrollü olarak ölçtüm (yukarıdaki boş çıktı, dosya varken v1'in ölçümünde dolu dönüyordu).

**Kriter 2'de körlük SINIF DEĞİŞTİRDİ, kapanmadı.** `git status --porcelain -- <yol>` izlenmeyeni
`??` ile gösterir ⇒ o ayak düzeldi. Ama kriter 2 bir **evrensel** iddia kuruyor (*"Başka hiçbir yol
yok"*) ve onu **beyaz listeye bakarak** ölçüyor. Ayrıntı `Y3`'te; **ölçülmüş kanıt orada.**

## B3 — 🟢 KAPANDI (KESİN)

Kriter 1 birebir: *"üç dizin için **ayrı ayrı** koşar ⇒ **32 · 6 · 41**. 🔴 Çıplak `ls-files`
**KULLANILMAZ** (izlenmeyene kör)."* Komut yazıldığı hâliyle **koşturulabilir** — koşturdum, üç ayrı
sayı üretti. v1'in *"tek `wc -l` tek sayı döndürür"* itirazı artık konusuz.

## B4 — 🟢 KAPANDI (KESİN) — ve yeni mutantın ayırt ediciliğini **ÖLÇTÜM**

`services:` tasarımdan tamamen çıktı (§0.1). Depoda doğrulama:
```
grep -c services .github/workflows/ci.yml   =>  0
tests/Momentum.Persistence.Tests/Momentum.Persistence.Tests.csproj
    <PackageReference Include="Testcontainers.PostgreSql" Version="4.13.0" />
tests/Momentum.Persistence.Tests/TestSupport.cs:20-21
    public Testcontainers.PostgreSql.PostgreSqlContainer Container { get; } =
        new Testcontainers.PostgreSql.PostgreSqlBuilder("postgres:17-alpine").Build();
```
⇒ v2 §7'nin `M-o69-3` hedefi (*"`TestSupport.cs:21` imaj etiketini geçersiz yap"*) **doğru satırı**
gösteriyor: 21 tam olarak imaj etiketi satırı. **Satır numarası KESİN.**

**Ayırt edici kanıt sütununu ayrı ayrı ölçtüm — GEÇERLİ.** `Momentum.ArchitectureTests.csproj`
**birebir** (tam dosya okundu):
```
<PackageReference Include="Microsoft.NET.Test.Sdk" ... />
<PackageReference Include="xunit" ... />  <PackageReference Include="xunit.runner.visualstudio" ... />
<PackageReference Include="NetArchTest.Rules" Version="1.3.2" />
<PackageReference Include="Shouldly" ... />
<ProjectReference> x4  -> Momentum.{Domain,Application,Infrastructure,Api}
```
⇒ **Testcontainers YOK, Npgsql YOK, DB fixture YOK.** İmaj etiketi bir **çalışma-zamanı dizesidir**
(derleme etkilenmez), dolayısıyla `Momentum.ArchitectureTests` derlenir ve geçer; yalnız
`Momentum.Persistence.Tests` konteyner açarken düşer. **Ayrım gerçek.**

**`--no-build` etkisi ölçüldü ve mutantı bozmuyor:** `verify.ps1:50` `dotnet build` zinciri **önce**
koşar, `:62` `dotnet test $solution --no-build` onun çıktısını kullanır ⇒ mutant kaynağı **derlenmiş
olur**. `--no-build` burada bir engel değil.

🔵 **Bonus (v2'nin iddiasından güçlü):** `Momentum.Api.Tests` ve `Momentum.SyncCore.Tests` csproj'ları
da Testcontainers **taşımıyor** — ayırt edici üç projedir, v2 yalnız birini adlandırıyor. Kusur değil.

**GÜVEN: KESİN**

## B5 — 🟢 KAPANDI (KESİN) — çapayı **koşturarak** ölçtüm

Uyarı politikası doğrulandı, **satır numaraları birebir tuttu**:
```
src/backend/Directory.Build.props:16   <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
tests/Directory.Build.props:14         <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
```
**Ve v1'in `[ÖLÇÜLEMEDİ #7]` bıraktığı `.sln` ayağını (Ö4) kapattım** — `Momentum.sln` ayrıştırıldı:
`Momentum.Domain` · `Momentum.Application` · `Momentum.Infrastructure` · `Momentum.Api`
(hepsi `src\backend\`) + `Momentum.ArchitectureTests` · `Momentum.Api.Tests` · `Momentum.SyncCore.Tests`
· `Momentum.Persistence.Tests` (hepsi `tests\`). **Başka .NET projesi YOK** ⇒ v2 §1'in
*"`-warnaserror` bayrağı **gereksiz**"* hükmü **artık dizin ölçümüyle değil, `.sln` ayrıştırmasıyla
KESİN**. (⇒ v2'nin `Ö4` görevi bu turda **fazlalıktır**; cevabı burada.)

**Yeni `M-o69-1`'in ayırt edici kanıtını KOŞTURDUM.** `verify.ps1:39-47`'nin `Invoke-Step` mantığını
birebir kopyalayıp pwsh 7.4.6'da düşen bir adımla koşturdum:
```
--- build -warnaserror ---
error CS1002: ; expected
FAILED: build -warnaserror (exit 1)
===EXIT=1===
```
⇒ **`--- test ---` HİÇ BASILMADI.** Sebep ölçüldü: `Invoke-Step` fonksiyonunun içindeki
`exit $LASTEXITCODE` (satır 45) **betiği** sonlandırıyor, fonksiyonu değil. v2'nin
*"🔴 **`--- test ---` HİÇ görünmez**"* beklentisi **doğru ve ayırt edici**. **GÜVEN: KESİN**

🔵 **Yan ölçüm (bir riski kapattı):** pwsh 7.4.6'da `$PSNativeCommandUseErrorActionPreference`
değeri **`False`** (ölçüldü). Yani `$ErrorActionPreference='Stop'` altında bile düşen bir yerli komut
**fırlatmaz**; `if ($LASTEXITCODE -ne 0)` dalı çalışır ve `FAILED:` satırı **basılır**. v2'nin
beklediği *"sonra `FAILED`"* kanıtı Linux'ta da geçerli.

## B6 — 🟡 KISMEN (KESİN)

**Kapanan yarı:** başlık artık yalnız `D-A13-4` taşıyor; §0.3 birebir *"`B-O63-2` **açık kalır ve
BEYAN EDİLİR** — başlıkta kapatma iddiası **yok**"*. §3d kapanış eylemini (satır silme) ekliyor.
**Atıf satırı doğru:** `GOREV-A13-ios-iskeleti-ci.md:294` = `## 6b. MUTANT BORCU`, **:296** = `D-A13-4`
satırı — v2'nin verdiği numara **birebir tuttu**. `GOREV-W3b-web-yayina-alma.md`'nin **89 · 372 · 376**
satırları da **birebir tuttu** (üçünü tek tek `sed -n '89p;372p;376p'` ile okudum).

**Kapanmayan yarı:** v2 §3d birebir *"Ölçülmüş **üç** sarkan atıf da aynı turda düzeltilir"* diyor.
**Ölçtüm: üç değil, ALTI.** Ayrıntı ve birebir çıktı `Y3`'te. Sarkan atıflardan biri kriter 2'nin
**beş dosyasının dışında** bir dosyada. **GÜVEN: KESİN**

🟢 **Yan doğrulama:** `D-A13-4` **`BORCLAR.md`'de, `DURUM.md`'de ve `CLAUDE.md`'de GEÇMİYOR**
(`grep -n "D-A13-4" BORCLAR.md DURUM.md CLAUDE.md` ⇒ **boş**). Yani `BORCLAR.md`'yi bu tur için
düzenleme zorunluluğu **yok** — kriter 2'nin listesi bu ayakta doğrudur.

## B7 — 🟡 KISMEN

**Linux hükmü artık KESİN — v1 türetmişti, ben KOŞTURDUM.** `verify.ps1:26`'nın birebir yeniden
üretimi, pwsh 7.4.6:
```
PSVersion    : 7.4.6
ProgramFiles : []
Join-Path: /tmp/o69/t1.ps1:8
   8 |  $preferred = Join-Path $env:ProgramFiles 'dotnet\dotnet.exe'
     |                         ~~~~~~~~~~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is null.
EXIT=1
```
Bir sonraki satırdaki `Write-Host "BURAYA ULASTI"` **hiç basılmadı** ⇒ **sonlandırıcı.** v2 §1'in
birebir çıktısı (*"SONLANDIRICI HATA: ParameterBindingValidationException"*) **doğrulandı.**

**Çelişki çözüldü:** `verify.ps1` artık kriter 2'nin değişebilir dosya listesinde ⇒ v1'in §6↔kriter 2
çakışması yok.

**Ve v1'in bir endişesi ölçümle DÜŞTÜ:** `araclar/verify.ps1` `tek-kopya-kapisi.py`'nin `kilitli`
sınıfında **DEĞİL**. Sınıf listesi (ölçüldü, satır 53-58): `DESIGN.md` · `GOREV-slice-3b` ·
`GOREV-slice-3c` · `GOREV-slice-3d` · `araclar/radar.py` · `araclar/adr-kapi-taramasi.py`.
⇒ v2'nin bu maddeyi düşürmesi **haklıdır** (ama gerekçesini yazmamıştır — `MINOR Y10`'a değil,
sadece nota geçiyorum).

**Kapanmayan yarı:** kriter 4'ün **Windows ayağı** hâlâ kör ve yanlış ortama havale edilmiş → `Y7`.

## B8 — 🟢 KAPANDI (KESİN) — ama bedel yer değiştirdi

Kriter 7 birebir: *"**Koşan mutantlar** …, **CI'sız, `verify.ps1` YEREL koşumuyla**"*; kriter 9
birebir: *"**TEK gerçek CI koşumu**"*; kriter 10 birebir: *"**PUSH ONUR'DA** — kriter 9 dışındaki
hiçbir kriter push gerektirmez (v1 yedi push gerektiriyordu ve **tamamlanamazdı**)."*
⇒ Döngü artık **tutarlı ve tamamlanabilir**. `--branch` filtresi kriter 9'da **zorunlu** yazılmış.
v1'in *"yan dala push CI'yı tetiklemez"* tehlikesi de konusuz kaldı (tetikleyicilere dokunulmuyor,
`gh run list --branch main`).

🔴 **AMA:** üç mutant artık **Onur'un/Code'un makinesinde canlı bir Docker daemon'ı** ve **kapalı bir
`Momentum.Api`** istiyor — ve v2'de **`K80` ortam maddesi YOK.** Bu, kapanan blokerin **doğurduğu**
yeni blokerdir → `Y1`.

---

# BÖLÜM B — v2'NİN YENİ ÜRETTİĞİ KUSURLAR

## 🔴 BLOKER `Y1` — `K80` İHLALİ: kriter 7 canlı ortam istiyor, spec'te **ortamı kaldırma maddesi YOK**

**Nerede:** §4 kriter 7 (*"CI'sız, `verify.ps1` YEREL koşumuyla"*) ↔ §5.1 (*"Claude Code … kriter …
7 … **kendi koşar**"*) ↔ §2 (`Ö2` yalnız `ubuntu-latest` için `docker info`).

**Ne ile ölçtüm:**
```
tests/Momentum.Persistence.Tests/Momentum.Persistence.Tests.csproj
    <PackageReference Include="Testcontainers.PostgreSql" Version="4.13.0" />
araclar/verify.ps1:62   Invoke-Step 'test' { & $dotnet test $solution --no-build --nologo }
```
`verify.ps1`'in test adımı **çözünümde** Testcontainers'a girer ⇒ **yerel Docker daemon şart.**
Ve `ORTAM.md`:37 birebir:
> 🔴 **`verify.ps1` ÇALIŞAN BİR `Momentum.Api` VARKEN KOŞULAMAZ [ölçüldü, oturum 50].** Backend
> ayakta iken `verify.ps1` **EXIT 1** ve **36 hata** verdi; hepsi `MSB3026`/`MSB3027` … **Ürün kusuru
> DEĞİL.** ⇒ **Sıra: cihaz kanıtı (backend ÇALIŞIR) → backend KAPATILIR → `verify.ps1`.** Kapatma
> **ölçülür** (`netstat -ano | findstr :5298` **boş** dönmeli), varsayılmaz.

`CLAUDE.md` `K80` birebir (**PAZARLIKSIZ**):
> **Cihaz ya da canlı-sunucu kanıtı isteyen HER spec, ortamı KENDİ kaldırma maddesini taşımak
> ZORUNDADIR.**

v2'de böyle bir madde **hiç yok**. `Ö2` (`docker info`) yalnız **iş akışına eklenecek bir CI adımı**
olarak yazılmış; **yerel koşumun ön koşulunu ölçmüyor.**

**Somut düşme senaryosu (v2'nin ayırt edemeyeceği iki yanlış-pozitif):**
- Docker Desktop kapalıyken `M-o69-3` koşarsa: `Momentum.Persistence.Tests` **zaten** düşer,
  `Momentum.ArchitectureTests` **zaten** geçer ⇒ ayırt edici sütun **mutant olmadan da sağlanır**
  ⇒ mutant **hiçbir şey ölçmemiş olur ama YEŞİL raporlanır.** Bu, v2'nin kendi yasakladığı eşdeğer
  mutant sınıfının **ortam kaynaklı** hâlidir.
- `Momentum.Api` ayaktayken taban koşumu yapılırsa: `EXIT 1` + 36 `MSB3026` gelir ve *"zincir
  düşüyor"* diye okunur — `ORTAM.md` bunun **ürün kusuru olmadığını** açıkça yazmıştır.

**Düzeltme yönü:** §3'e (ya da §4'e) sıralı ve **yoklamalı** bir ön koşul maddesi: ① `docker info`
sıfır çıkışa kadar yoklanır (tavanlı, **sabit `sleep` yasak** — `K80`) → ② `netstat -ano | findstr
:5298` **boş** ölçülür → ③ ancak sonra `verify.ps1`. Her mutant koşumundan **önce** tekrarlanır.

**GÜVEN: KESİN** (kural metni + `ORTAM.md` ölçümü + csproj birebir okundu) · **BLOKER**

---

## 🔴 BLOKER `Y2` — kriter 3 **KÖR**: `-` satırı taşımadan `istemci`/`ios` davranışı değiştirilebilir (mekanik olarak KANITLADIM)

**Nerede:** §4 kriter 3 birebir:
> *"`git --no-optional-locks diff -U0 -- .github/workflows/ci.yml` çıktısındaki **her hunk yalnız
> EKLEME** taşır (`-` ile başlayan satır **0 adet**, `---` başlığı hariç). 🔴 v1'in *"YAML gövdesinin
> sha256'sı"* kriteri **yanlışlanamazdı**, bu kriter yanlışlanabilir."*

Kriter **yanlışlanabilir** olmuştur — bu doğru ve v1'e göre ilerlemedir. Ama **hedeflediği sınıfı
ölçmüyor.** YAML/Actions'ta bir işin davranışı **tek bir `+` satırıyla** yok edilebilir.

**Ne ile ölçtüm — türetmedim, KOŞTURDUM.** Kendi konteynerimde temiz bir git deposu kurdum, gerçek
`ci.yml`'in yapısını birebir kopyaladım ve **yalnız ekleme** yaptım:

```
########## git diff -U0 ##########
@@ -10,0 +11 @@ defaults:
+    shell: pwsh
@@ -19,0 +21 @@ jobs:
+    if: false
@@ -23,0 +26,10 @@ jobs:
+
+  backend:
+    runs-on: ubuntu-latest
...
########## KRITER 3 OLCUMU: '-' ile baslayan satir ('---' haric) ##########
0
```

İki saldırı, **toplam iki `+` satırı**, **sıfır silme**:
1. `defaults.run.shell: pwsh` **kürsel bloğa** eklendi ⇒ `istemci` ve `ios`'un **her `run` adımının
   kabuğu değişti** (bash → pwsh). v2 §3b bunu yasaklıyor (*"Üstteki global blok **değişmez**"*) ama
   kriter 3 **ihlali göremez**.
2. `ios:` altına `if: false` eklendi ⇒ **iOS işi tamamen devre dışı.** `ci.yml`'in en pahalı işi
   sessizce ölür; kriter 3 **YEŞİL** yanar.

**İkinci ayak da kör:** v2 *"Ek kanıt: `ci-kapisi.py` **YEŞİL**"* diyor. Onu da ölçtüm — kapı
`g28a`'da *"`flutter analyze` + `--fatal-infos` aynı yorumsuz satırda mı"*, `g29a`'da
*"`--no-codesign` var mı"* diye bakıyor. `if: false` **hiçbirini silmiyor** ⇒ kapı **YEŞİL kalır.**
Kriter 3'ün **iki ayağı da** aynı sınıfa kör.

**Düzeltme yönü (mekanik ve ucuz):** ekleme-yönlülüğe değil **KONUMA** bak. `git diff -U0` çıktısında
**tek bir hunk** olmalı ve o hunk **dosyanın sonuna** eklenmeli:
`@@ -<EOF>,0 +<EOF+1>,<M> @@` — yani hiçbir `+` satırı mevcut `istemci`/`ios` gövdelerinin satır
aralığına **düşmemeli**. Bu deterministiktir, koşan CI istemez ve `if: false` saldırısını **ısırır**.

**GÜVEN: KESİN** (kontrollü depoda koşturuldu) · **BLOKER**

---

## 🔴 BLOKER `Y3` — kriter 2'nin **beş dosyası EKSİK**, sarkan atıf sayısı **YANLIŞ**, ve *"Başka hiçbir yol yok"* **ölçülemez**

### (a) Sarkan atıf: v2 **üç** diyor, ölçüm **altı** veriyor

**Ne ile ölçtüm:** `grep -rn "D-A13-4" docs/ GOREV_CLAUDE_CODE/ araclar/ README.md` — birebir çıktı:
```
docs/ADR/0004-web-capraz-koken-izolasyonu.md:145: ⇒ `B-O63-2` **AÇIK**; bağlanması `D-A13-4` turuna aittir. Bu ADR o turu **karara bağlamaz**.
GOREV_CLAUDE_CODE/GOREV-A13-ios-iskeleti-ci.md:87:  ### `D-A13-4` — BACKEND `verify` ZİNCİRİ BU DİLİMDE CI'YA **GİRMEZ**
GOREV_CLAUDE_CODE/GOREV-A13-ios-iskeleti-ci.md:296: - KURAL: D-A13-4 | GEREKCE: … (kapatılacak satır)
GOREV_CLAUDE_CODE/GOREV-A13-ios-iskeleti-ci.md:367: 1. **Backend CI'da DEĞİL** (`D-A13-4`) ⇒ CI yeşili …
GOREV_CLAUDE_CODE/GOREV-W3b-web-yayina-alma.md:89 · :372 · :376
```
v2 §3d yalnız **W3b'nin üçünü** listeliyor. **Ölçülmemiş üç atıf daha var:**
- `GOREV-A13-ios-iskeleti-ci.md:87` — bu bir **karar başlığıdır** (*"BU DİLİMDE CI'YA GİRMEZ"*),
  yani kararın kendisi. `:296`'yı silip `:87`'yi bırakmak, borcu kapatıp **kararı açık metinde
  bırakmaktır**.
- `GOREV-A13-ios-iskeleti-ci.md:367` — *"Backend CI'da DEĞİL"* gerekçesiyle CI yeşilinin **ne
  kanıtlamadığını** anlatıyor; bu tur o cümleyi **yanlışlıyor**.
- 🔴 `docs/ADR/0004-web-capraz-koken-izolasyonu.md:145` — **kriter 2'nin beş dosyasının DIŞINDA.**

v2 §3d bu turda `K58`'i **kendi alıntılıyor**:
> *"🔴 **`K58` DERSİ ZORUNLU:** *'bir sınırı kapatan el, o sınırı BEYAN EDEN her kopyayı aynı anda
> kapatmak zorundadır.'*"*

**Kuralı alıntılayıp üç kopyayı dışarıda bırakmıştır.** Üstelik `ADR 0004` `K175`① ile **PARK**
edilmiştir (`DURUM.md`:73 birebir: *"🔒 **`ADR 0004` KAPSAM DIŞI (`K175`①, o68):** gövde ·
`adr-hukum-kapisi.py` onarımı · kapı zinciri **PARK**"*) ⇒ **kapsam ile K58 doğrudan çatışıyor** ve
v2 bu çatışmayı **hiç görmüyor**. Bu çatışmanın çözümü **Onur'un kararıdır**, spec'in değil — ama
spec onu **beyan etmek** zorundadır.

### (b) *"Başka hiçbir yol yok"* iddiası, yazıldığı yöntemle **yanlışlanamaz**

Kriter 2 birebir: *"Değişen dosya kümesi **TAM OLARAK şu beştir** (`git … status --porcelain --
<yol>`, **dizin dizin, tam-ağaç koşulmaz**)… **Başka hiçbir yol yok.**"*

Beyaz listeye bakarak *"listede olmayan yol yok"* **ölçülemez.** Ve bu soyut değil — **şu anda
ihlal ediliyor:**
```
git --no-optional-locks status --porcelain -- DURUM.md BORCLAR.md PROJE_RADAR.jsonl PROJE_HAFIZA.md README.md
 M DURUM.md
 M PROJE_HAFIZA.md
 M PROJE_RADAR.jsonl
 M README.md

git --no-optional-locks status --porcelain -- .github/workflows/ci.yml araclar/verify.ps1 \
    araclar/ci-kapisi.py GOREV_CLAUDE_CODE docs/ADR
(BOŞ)
```
⇒ Claude Code **hiçbir şeye dokunmadan** kriter 2'yi koşarsa **TEMİZ** görür, oysa beyaz listenin
dışında **dört kirli dosya** vardır. Üstelik bu turda **daha da artacak**: `CLAUDE.md` checkpoint'i
`PROJE_HAFIZA.md`'ye **anında** yazmayı, `K40` her checkpoint'te `PROJE_RADAR.jsonl`'a **bir satır**
eklemeyi **PAZARLIKSIZ** kılıyor. Yani kriter 2'nin sözlük anlamı **turun kurallarınca zaten
imkânsızdır**; ölçüm yöntemi de bunu **gizler**.

**Düzeltme yönü:** ya kriter 2'yi *"aşağıdaki beş yol DIŞINDA **ÜRÜN/ARAÇ** dosyası değişmedi;
hafıza defterleri (`DURUM.md` · `PROJE_HAFIZA.md` · `PROJE_RADAR.jsonl` · `README.md`) **beyanlı
istisnadır**"* diye yaz, ya da tam-ağaç yerine **beyaz listenin tümleyeni** üzerinde dar bir tarama
tanımla (`ls-files -m` + `ls-files --others --exclude-standard`, üst-düzey dizin dizin).

**GÜVEN: KESİN** · **BLOKER**

---

## 🔴 BLOKER `Y4` — §6'nın CVE mutant borcu, **alıntıladığı `K155`'in yasakladığı şeydir**; ve borcun yazılacağı yer **yok**

**Nerede:** §6 madde 2 birebir:
> *"🔴 **CVE ayağının mutantı YOK** (`K53`/3 koşan-mutant tavanı **3** ve dolu). Yani *'CVE kapısı
> ısırıyor'* bu turda **ÖLÇÜLMEDİ** … **`## 6b. MUTANT BORCU`'na gerekçesiyle yazılır** (`K53`/3;
> **KAPI borçlanamaz, yalnız KURAL** — `K155`)."*

**Ne ile ölçtüm** — `PROJE_HAFIZA.md`:598 birebir (dar `grep -n "K155"` + `sed` ile pencere okundu;
`K53`/`K83` gereği dosya **açılmadı**, yalnız atıf doğrulandı):
> *"🔴 **`K26`: KAPIYI GÖVDEYİ YAZAN EL YAZAMAZ** ⇒ … `K155` de geçerli: **mutantı olmayan ayak
> spec'ten çıkarılır ya da mutantı yazılır.**"*

`K155` **iki şık** tanır: **çıkar** ya da **yaz**. *"Borç olarak beyan et"* **üçüncü bir şık
değildir.** Ve `CLAUDE.md`:15 birebir: *"**KAPI borçlanamaz**, yalnız kural."*

**CVE bu turda bir KAPI ayağıdır** — kriter 9 birebir onu **zorunlu** kılıyor:
> *"Log'da `verify.ps1`'in **üç çapası** aranır (birebir dizge): `--- build -warnaserror ---` ·
> `--- test ---` · `--- CVE gate (dotnet list package --vulnerable) ---`"*

⇒ v2, **kapı ayağına borç yazıyor** ve bunu yaparken tam da yasaklayan iki kuralı **aynı parantezde
alıntılıyor**. (Üç çapayı `verify.ps1`'den birebir doğruladım: `:41` `--- $Name ---`, `:50` Name=
`build -warnaserror`, `:62` Name=`test`, `:65` `--- CVE gate (dotnet list package --vulnerable) ---`,
`:93` `== VERIFY PASSED ==`. **Dördü de birebir tuttu.**)

**Üstelik "tavan dolu" gerekçesi de ÖLÇÜLMEMİŞ.** `K53`/3'ün tavanı *"**koşan uygulama** isteyen
mutant (emülatör/tarayıcı + yeniden derleme)"* sınıfına aittir. Bir CVE mutantı (bilinen zafiyetli
bir `PackageReference` ekle) **emülatör/tarayıcı istemez**; `dotnet list package --vulnerable` bir
restore işidir. v2 bu mutantın hangi maliyet sınıfına düştüğünü **ölçmeden** tavana saymıştır —
`K53`/3'ün açıkça *"sayıya göre değil, **maliyet sınıfına göre**"* dediği yerde.

**Ve borcun yazılacağı DOSYA yok.** `## 6b. MUTANT BORCU` başlığını depoda taradım: **yalnız
`GOREV_CLAUDE_CODE/*.md` spec dosyalarında** var (13 spec). v2 **dosya değil, sohbet bloğudur**
(§ başlık, `K175`②) ⇒ kendi `§6b`'si **yoktur** ve v2 hangi spec'e yazılacağını **söylemiyor**.
`CLAUDE.md` `K81` gereği `spec-kapi-kapsama.py` **bir spec dosyası yolu** ister (*"dizin kabul etmez"*)
⇒ *"gerekçesiz borcu reddeder"* mekanizması bu tura **hiç uygulanamaz.** Yani borç yazılsa bile
**hiçbir kapı onu ölçmez.**

**GÜVEN: KESİN** · **BLOKER**

---

## 🟠 MAJOR `Y5` — `_CI_TEMIZ` **ikinci bir `ci.yml` kopyasıdır** ve gerçek dosyadan **ZATEN SAPMIŞ**; §3c bunu hiç anmıyor

**Ne ile ölçtüm** — `araclar/ci-kapisi.py:174` `_CI_TEMIZ` gövdesi (birebir) vs gerçek `ci.yml`:

| | gerçek `.github/workflows/ci.yml` | `ci-kapisi.py:174` `_CI_TEMIZ` |
|---|---|---|
| kürsel `defaults:` bloğu | **VAR** (`defaults: / run: / working-directory: src/client`) | **YOK** |
| adım düzeyi `working-directory` | **YOK** | **VAR** (üç `run` adımının üçünde de) |

Altın küme vakalarının **hepsi** `_CI_TEMIZ` üzerinden kurulur (`_vaka(... _CI_TEMIZ ...)`), vaka 1
birebir *"**1) TEMIZ -- yanlis-pozitif kontrolu**"*. §3c'nin yeni ayaklarından biri birebir
*"**iş düzeyi `defaults` ezmesi var**"* ⇒ bu ayak, **hiç `defaults` taşımayan** bir fikstüre karşı
ölçülecek ⇒ **vaka 1 KIRMIZI yanar** ve builder ya ayağı köreltir ya fikstürü elle senkronlar.

🔴 **Hiçbir kriter `_CI_TEMIZ ≡ ci.yml` eşitliğini ölçmüyor** ve v2 fikstürün varlığını **hiç
anmıyor**. Bu tam olarak v1 §0'ın uyardığı sınıftır — v1 birebir: *"🔴 **İKİNCİ BİR ZİNCİR
YAZILMAYACAK** — `kanonik-kopya` sınıfı bu projede **beş kez** ısırdı."* **v2 bu cümleyi silmiş,
ama sınıfın canlı örneği aracın 174. satırında duruyor.**

**GÜVEN: KESİN** · **MAJOR**

---

## 🟠 MAJOR `Y6` — yeni kapı ayaklarının **KİMLİĞİ YOK** ⇒ kriter 5 sayılamaz, `K108`/`kapi-ad-teklik` ölçemez

§3c birebir yedi ayak sayıyor: *"`backend` işi **var** · `runs-on: ubuntu-latest` · `verify.ps1`
**çağrılıyor** · `shell: pwsh` · `services:` **YOK** · iş düzeyi `defaults` ezmesi **var** ·
`istemci`/`ios` işleri **duruyor**"* — ve *"`A13/G28`… ailesine **kapsam önekli** (`K108`)"* diyor
ama **tek bir kimlik yazmıyor** (`A13/G31/a` gibi).

**Neden bu mekanik bir engel:** aracın kendi altın küme motoru **kod listesi** karşılaştırıyor
(ölçüldü, `_vaka(...)` çağrıları: `["G28a"]`, `["G30c"]`, `["G28a","G30c"]`; `denetle()` `(kod, mesaj)`
çiftleri döndürüyor). **Kimliksiz ayak bu araca yazılamaz.**

Sonuçlar:
- Kriter 5 birebir *"**her yeni ayak** için **en az bir ısıran vaka**. Kör ayak **yok**."* — *"her
  yeni ayak"* **sayılamaz**; builder yediden beşini yapıp `M/M` raporlayabilir ve kimse fark etmez.
- Kriter 6 yalnız **üç** statik mutant + bir pozitif kontrol adlandırıyor (`S1` backend işi sil ·
  `S2` `verify.ps1` çağrısını sil · `S3` `services:` ekle · `S4` `flutter-version` değiştir) ⇒
  `runs-on: ubuntu-latest`, `shell: pwsh` ve *"`istemci`/`ios` duruyor"* ayaklarının **adlandırılmış
  ısıran vakası yok.**
- `kapi-ad-teklik-kapisi.py` (`K108`'in mekanik kapısı, ölçüldü: *"Canli belgede KAPSAM ONEKSIZ
  'G<n>' atfi var VE o kimlik BELIRSIZ"*) **canlı belgeleri** tarar; iş emri **sohbet bloğu** olduğu
  için bu kapı da bu turu **görmez**.

**GÜVEN: KESİN** · **MAJOR**

---

## 🟠 MAJOR `Y7` — kriter 4'ün **Windows ayağı** adsız gözlem üstüne kurulu; ve bulut koşumu `ORTAM.md`'ye göre **kapı hükmü olamaz**

**Nerede:** §3a (*"Windows'taki mevcut davranış **bayt olarak değil, DAVRANIŞ olarak** korunmalı
(64-bit `dotnet.exe` tercihi Windows'ta aynen sürsün)"*) ↔ kriter 4 (*"**Windows'ta davranış
korunuyor**. Kanıt her iki ortamdan da **birebir çıktı** olarak yazılır. 🔴 Bu kriteri **Cowork**
ölçer"*).

**İki ayrı kusur:**

**(i) Gözlem adlandırılmamış ⇒ yanlışlanamaz.** *"Davranış korundu"* ne demek, hangi dizge, hangi
karşılaştırma? Gözlem **vardır ama v2 onu yazmamıştır** — `verify.ps1:35` birebir
`Write-Host "dotnet   : $dotnet"` basar; korunmuşluk *"onarım öncesi ve sonrası bu satır **aynı yolu**
gösteriyor"* diye ölçülebilirdi. Yazılmadığı için builder/Cowork **gözle bakıp yeşil ilan eder** —
v2'nin kendi *"'geçti' beyanı kabul edilmez"* şartını ihlal eder. Dahası, tercihin **fiilen ateşlendiğini**
göstermek `C:\Program Files\dotnet\dotnet.exe`'nin **var olmasına ve `--list-sdks` döndürmesine**
bağlıdır (`verify.ps1:27-29`) — bu **ölçülmemiştir**; makinede o yol yoksa "davranış" zaten
`$dotnet='dotnet'`tir ve onarım **hiçbir şeyi değiştirmez**, kriter yine yeşil yanar. **Kör.**

**(ii) Ortam yanlış.** `ORTAM.md`:47 birebir:
> 🔴 **ORTAM-DUYARLI ARACI BULUT KOPYASINDA KOŞMA — KANONİK ÖLÇÜM YERİ CİHAZDIR [o65'te ölçüldü].**
> … ⇒ **Kapı hükmü, koştuğu ortamın hükmüdür.** Bulut kopyası … **okuma ve ajan denetimi** için
> doğrudur; **kapı hükmü için cihazda tekrar koşulur.**

Kriter 4, bir **bulut konteynerindeki pwsh 7.4.6 koşumunu kabul hükmü** yapıyor. Kanonik ortam
`ubuntu-latest`'tir ve `Ö1` (*"`ubuntu-latest` imajında **pwsh** var mı"*) **v2'nin kendi
kabulüyle ölçülmemiştir** ⇒ bulut-yeşili ile CI-yeşili arasında **kurulmuş bir zincir yok**.
(Ben bugün 7.4.6'da koşturdum; bu **teşhis** için yeterlidir, **kabul** için değil — kendi
denetimimi de bu kurala tabi tutuyorum.)

**GÜVEN: KESİN** (kural metni + `verify.ps1` birebir) · **MAJOR**

---

## 🟠 MAJOR `Y8` — §5 iş bölümü ↔ `K80`: Cowork'e kriter 7'yi *"yeniden koş"* deniyor

§5.2 birebir: *"**Cowork:** kriter **4**'ü bağımsız ölçer (bulut pwsh) ve **hiçbir kriteri
builder'ın beyanıyla kabul etmez** (`K26`) — **1, 3, 5, 6, 7, 8'i yeniden koşar.**"*

Kriter **7** = üç **koşan** mutant (canlı Docker daemon + yerel `verify.ps1` + `dotnet build/test`).
Kriter **8** = her mutant sonrası **ikili yedek → bayt yaması → `wb` geri yazım** — yani **cihaza
yazma**.

`CLAUDE.md` `K80` birebir: *"**Cowork ortamı KALDIRMAZ, DOĞRULAR.** … Cowork yalnız **ölçer** ve
sonucu raporlar."* Ve `ORTAM.md`:37 birebir: *"🔴 **Kapatmayı Cowork YALNIZ Onur'un açık izniyle
yapar; YENİDEN BAŞLATMAZ (K80 ayakta).**"*

⇒ §5.2, Cowork'e **ortam kaldırtan** ve **dosya yazdıran** bir görev veriyor. `K26`'nın gerektirdiği
şey *"builder'ın beyanına güvenme"*dir; bunun `K80`'e uyan karşılığı **ürünün kendisini bağımsız
ölçmektir** (ör. mutant sonrası `sha256` özdeşliğini Cowork'ün **okuyarak** doğrulaması, kanıt
loglarının **iç tutarlılığının** ölçülmesi), mutantı **yeniden koşmak** değil.

**GÜVEN: KESİN** · **MAJOR**

---

## 🟡 MINOR `Y9` — `.gitattributes` satır numarası **yanlış**: 8 değil **7**

§3a birebir: *"🔴 **`.gitattributes:8` ⇒ `*.ps1 text eol=crlf`**"*. Ölçüm:
```
5  *.bat   text eol=crlf
6  *.cmd   text eol=crlf
7  *.ps1   text eol=crlf
8  (BOŞ SATIR)
```
Kural **7. satırda**; 8 boş. Hüküm (CRLF) **doğru**, atıf **yanlış**. Kaynağı da ölçülebiliyor:
v1 denetim raporu `M2`'de aynı *":8"* yazıyor ⇒ v2 **kopyalamış, yeniden ölçmemiş**. Bu, v2'nin §1
tablosunun tam olarak **önlemek için** var olduğu sınıftır. **GÜVEN: KESİN** · **MINOR**

## 🟡 MINOR `Y10` — §1'in *"satır 57"* alıntısı `if` koşulunu düşürüyor

§1 birebir: *"İkinci Windows bağımlılığı **satır 57**: `Join-Path $repoRoot 'KANIT\slice-3d\…'`"*.
Ölçüm (`verify.ps1:56-59`):
```
56  if (-not $env:MOMENTUM_KANIT_DIZIN) {
57      $env:MOMENTUM_KANIT_DIZIN = Join-Path $repoRoot 'KANIT\slice-3d\07-G7-backend-zorlama'
58  }
59  New-Item -ItemType Directory -Force -Path $env:MOMENTUM_KANIT_DIZIN | Out-Null
```
Atama **koşulludur**. Sonuç değişmiyor (CI'da değişken tanımsızdır ⇒ dal ateşlenir), ama alıntı
eksik ve onarımı yazacak el `if`'i görmeden yamalarsa **ikinci bir kusur** doğar. Ayrıca 57
onarılırsa **59 kendiliğinden** düzelir — §3a *"başka hiçbir satıra dokunulmaz"* derken bunu
belirtmemiş. **GÜVEN: KESİN** · **MINOR**

## 🟡 MINOR `Y11` — mutant yedeklerinin ve koşucusunun **YERİ** yazılmamış ⇒ kriter 1'i kırma riski

Kriter 8 birebir yordamı veriyor (*"ikili yedek → bayt yaması → `wb` geri yazım → ölç"*) ve
`ORTAM.md 38`'e atıf yapıyor — **atıf doğru** (ölçüldü: `ORTAM.md`:38 tam olarak `git restore` yasağı;
referans koşucu `KANIT/A11/_mutant_kosucu.py`). Ama **yedeklerin ve yeni bir koşucunun nereye
yazılacağı** yazılmamış. Koşucu `araclar/` altına düşerse **kriter 1 KIRMIZI** yanar (42 ≠ 41) ve
`K175`② ihlal edilir. **Tek cümlelik çözüm:** *"tüm ara ürünler `KANIT/CI/` altındadır."*
**GÜVEN: KESİN** · **MINOR**

## 🟡 MINOR `Y12` — `Ö4` bu turda **fazlalık**; cevabı bu denetimde ölçüldü

§2 `Ö4` birebir: *"`Momentum.sln`'in proje listesi | `B5`'in *'başka .NET projesi yok'* ayağı dizin
ölçümüyle kurulmuştu, `.sln` **ayrıştırılmadı**"*. Ayrıştırdım (yukarıda, `B5`): sekiz proje, hepsi
`src\backend\` ya da `tests\` altında. Görev bırakılabilir ama **cevabı spec'e yazılmalı**, yoksa
builder aynı ölçümü tekrarlar. **GÜVEN: KESİN** · **MINOR**

---

# BÖLÜM C — ÇÜRÜTMEYE ÇALIŞTIM VE **ÇÜRÜTEMEDİM** (denge kaydı)

Bunlar bulgu değildir; kusur aramaya nereye bakıp **bulamadığımı** kayda geçiriyorum.

1. **`M-o69-1`'in çapası GERÇEK.** Koşturdum: build düşünce `--- test ---` **basılmıyor** (`exit`
   fonksiyondan değil **betikten** çıkıyor). Ayırt edicilik **ölçülmüş**.
2. **`M-o69-3`'ün ayırt ediciliği GERÇEK.** `Momentum.ArchitectureTests.csproj` Testcontainers'dan
   **tamamen bağımsız** (tam dosya okundu). `--no-build` mutantı **bozmuyor** (`verify.ps1:50` önce
   derliyor). `TestSupport.cs:21` **doğru satır**.
3. **`K175`② ihlali YOK.** §3c'nin altın kümesi `ci-kapisi.py` **içinde satır içi** duruyor
   (`_CI_TEMIZ` :174, `altin_kume()` :329) ⇒ yeni fikstür **dosyası gerekmiyor**. Beş yolun beşi de
   **mevcut dosyalar**; `KANIT/CI/**` yasağın dışında. Kriter 1 zaten kaçağı **ısırır**.
4. **`ci-kapisi.py` = 418 satır · altın küme = 13 vaka.** İkisini de saydım (`wc -l` ⇒ 418;
   `altin_kume()` içinde **13** `_vaka(...)` çağrısı, `HUKUM: %d/%d`). §3c'nin iddiası **doğru**.
5. **§1 tablosunun geri kalanı doğru:** `ci.yml` **580 b** (`wc -c`) · iki iş `istemci`/`ios` ·
   `grep -c` ⇒ `dotnet` **0**, `verify` **0**, `postgres` **0** (`services` de **0**) ·
   `global.json` ⇒ `"version": "10.0.302"`, `"rollForward": "latestPatch"` ·
   `Directory.Build.props` **16** ve **14** · `TestSupport.cs:20-23` · `verify.ps1:50` ·
   `DevKimlikKapisiTestleri.cs:29` (`UseEnvironment("Development")`) ve **:59** (`"Production"`) —
   **hepsi birebir tuttu.** `GOREV-A13…:296` ve `W3b:89/372/376` de tuttu. Yanlış çıkan **tek** atıf
   `.gitattributes:8` (→ `Y9`).
6. **§3b'nin `jobs.backend.defaults.run.working-directory: .` çözümü** — şema olarak geçerli:
   iş düzeyi `defaults` kürsel `defaults`'u anahtar anahtar ezer, `working-directory` yalnız `run:`
   adımlarına uygulanır (`uses:`'a değil), ve `verify.ps1`'in kendi kök çözümü
   (`$PSScriptRoot` → `Split-Path -Parent`) çalışma dizininden **bağımsızdır**. **Kusur bulamadım.**
   🔴 Çalışma zamanı **ÖLÇÜLEMEDİ** (aşağıda).
7. **`ASPNETCORE_ENVIRONMENT` set ETMEME kararı doğru.** `verify.ps1`'in 94 satırının tamamını okudum:
   **API hiç ayağa kaldırılmıyor** (yalnız build/test/CVE), ve testler ortamı `UseEnvironment` ile
   **kendileri pinliyor**. v2'nin v1'i burada tersine çevirmesi **ölçüme dayanıyor**.
8. **`verify.ps1` `tek-kopya-kapisi.py`'nin `kilitli` sınıfında DEĞİL** ⇒ v1'in *"Onur'dan kilit iste"*
   endişesi konusuz; v2'nin onu düşürmesi haklı.
9. **`D-A13-4` `BORCLAR.md`'de yok** ⇒ kriter 2'nin listesinde `BORCLAR.md`'nin olmaması **doğru**.

---

# NE ÖLÇÜLEMEDİ

1. **`ubuntu-latest` imajının içeriği** — `pwsh` var mı (`Ö1`), Docker daemon var mı (`Ö2`). GitHub
   runner imajına bu ortamdan erişemem. v2'nin `[DOĞRULANMADI]` beyanı bu ayakta **doğru yazılmıştır**.
2. **`actions/setup-dotnet` + `global-json-file`'ın `10.0.302`'yi fiilen çekmesi** (`Ö3`). Ağ/besleme
   ölçümü yapmadım.
3. **`working-directory: .`'ın Actions koşucusunda çalışma zamanı davranışı.** Şemadan **türettim**,
   **koşturmadım** — GitHub Actions çalıştıramam. `Y2`'deki depo deneyi yalnız `git diff` semantiğini
   ölçtü, Actions'ı değil. **GÜVEN: şema ZAYIF/türetilmiş.**
4. **`dotnet test <sln> --no-build`'ın bir derleme düştükten sonra kalan derlemeleri koşup koşmadığı.**
   `M-o69-3`'ün ayırt ediciliği buna dayanıyor; ben yalnız **bağımlılık grafiğini** ölçtüm
   (ArchitectureTests Testcontainers'sız). .NET SDK bu konteynerde yok; cihazda koşmak **yazma
   tarafıdır ve salt-okunur çalıştım.** VSTest'in derleme başına raporlama davranışından
   **türetilmiştir** — **GÜVEN: ZAYIF.**
5. **Bugünkü tabanın YEŞİL olup olmadığı** — `verify.ps1`'i hiç koşturmadım (Docker + .NET yok,
   salt-okunur). Mutantların *"öncesi geçiyordu"* öncülü **ölçülmedi**.
6. **`ci-kapisi.py`'nin 60–173 ve 215–320. satırları** (`g28b`, `g29a`, `g30a/b/c`, `denetle`).
   Docstring'i, `_yorumsuz_satirlar`'ı, `_CI_TEMIZ`'i, `altin_kume()`'yi ve `main()`'i okudum;
   ortayı **okumadım** ⇒ `Ö5`'in sorduğu *"`backend` işi `g28b`'nin 'ilk `flutter-version` eşleşmesinde
   dön' mantığını bozar mı"* sorusunu **ÖLÇMEDİM**. (Yeni iş `flutter-version` taşımayacağı için risk
   düşük **görünüyor** — ama bu bir tahmindir, ölçüm değildir.)
7. **`sayi-tazeligi.py`'nin altın küme büyüdükten sonraki hükmü.** Aracın işaretlerini okudum
   (*"basligi 'altin kume' iceren bir tablonun HER SATIRI iddia sayilir"*) ve `DURUM.md`:148 birebir
   *"| `ci-kapisi.py` [`A13`] | … | **13/13** |"* diyor ⇒ §3c'nin *"`DURUM.md` §6'ya **yazılmaz** —
   `sayi-tazeligi.py` onu koşarak doğrular"* talimatının **bilerek bayat bir sayı bırakacağı**
   kuvvetle muhtemel. 🔴 **Ama aracı KOŞTURMADIM** ve `ORTAM.md`:47 bulut koşumunu zaten kapı hükmü
   saymıyor ⇒ **hüküm vermiyorum, ölçüm görevi olarak bırakıyorum.** *(Bu, v2'nin en muhtemel
   dokuzuncu kusurudur; ölçmediğim için bulgu listesine ALMADIM.)*
8. **`_SILINECEKLER/` git-ignore'lu mu** — bakmadım. `Y3`(b)'nin *"tümleyen tarama"* önerisinin
   maliyetini etkiler.
9. **`docs/ADR/0004`'e dokunmanın `K175`① PARK kilidiyle nasıl uzlaşacağı** — bu bir **politika**
   sorusudur, ölçüm değil. **Onur'un kararı.**
10. **`PROJE_HAFIZA.md` bütün olarak okunmadı** (`K53`/`K83`). `K108`, `K155`, `K34-f` atıfları
    yalnız **dar `grep` + pencere** ile doğrulandı; `K34-f`'in tam metnini **okumadım** (yalnız dizin
    satırları ⇒ atfın **var olduğu** kesin, **kapsamı** ölçülmedi). v2 §3a'nın *"beyan edilmiş sapma"*
    kurgusunun `K34-f`'e uygunluğu ⇒ **ÖLÇÜLEMEDİ.**
11. **Dört kirli dosyanın (`DURUM.md`, `PROJE_HAFIZA.md`, `PROJE_RADAR.jsonl`, `README.md`) içeriği**
    — kimin, ne zaman değiştirdiğini `diff` ile ölçmedim; yalnız **kirli olduklarını** ölçtüm
    (`Y3`(b) için yeterli).
12. **Onarılmış `verify.ps1`'in davranışı** — onarım henüz yok. Kriter 4'ün *"satır 26'yı geçiyor"*
    ayağı ancak onarımdan sonra ölçülebilir.

---

# HÜKÜM

**DÜZELT** — v1'in sekizinden beşi gerçekten kapandı, ama **4 YENİ BLOKER** doğdu. Kilitlenemez.

**Kilitten önce en az şunlar düzelmeli (hepsi bir okuma/yazma turuyla kapanır, koşan kod istemez):**
① `K80` ortam maddesi eklenir — `docker info` + `netstat :5298` **yoklamalı**, her mutanttan önce
(`Y1`) · ② kriter 3 **konum tabanlı** yazılır (*"tek hunk, dosya sonuna"*), yoksa `if: false` ile
`ios` sessizce ölür (`Y2`) · ③ kriter 2'nin listesi `docs/ADR/0004…md`'yi ya **kapsar** ya
**gerekçesiyle dışlar**; sarkan atıf sayısı **üç değil altı** olarak düzeltilir; *"başka hiçbir yol
yok"* ya tümleyen taramayla ölçülür ya **hafıza defterleri beyanlı istisna** yazılır (`Y3`) ·
④ CVE ayağı ya kriter 9'dan **çıkarılır** ya **mutantı yazılır** — `K155` üçüncü şık tanımıyor;
borç yazılacaksa **hangi spec dosyasının `§6b`'sine** yazılacağı adlandırılır (`Y4`).

**Ayrıca kilitten önce yazılması ucuz, atlanması pahalı:** `_CI_TEMIZ` senkron maddesi (`Y5`) ·
yedi ayağın **kimlikleri** (`Y6`) · kriter 4'ün Windows **gözlem dizgesi** (`Y7`).

🔴 **`K127` notu:** bu denetim **kilitten ÖNCE** koştu. Dört blokerin **üçü** hiçbir koşan kod
gerektirmedi (okuma turu); **biri** (`Y2`) 15 satırlık bir kabuk deneyiyle kanıtlandı. Kilitlenecek
sürüm bu denetimin çıktı yolunu — `/home/claude/DENETIM-o69-is-emri-v2.md` — checkpoint'inde
**taşımak zorundadır**; v1'inkiyle **birlikte** (`/home/claude/DENETIM-o69-is-emri.md`).

🔴 **`K53`/1 notu:** bu **ikinci** kâğıt turudur ve tavanı zorlar. Gerekçesi yazılıdır: v1 turu
**mimariyi değiştiren** bir bloker buldu (`services:` bloğu tasarımın merkezinden çıkarıldı, `B4`)
⇒ `K53`/1'in *"ikinci tur ancak birincisi MİMARİYİ DEĞİŞTİREN bir bloker bulduysa açılır"* şartı
**sağlanmıştır**. 🔴 **ÜÇÜNCÜ TUR AÇILMAMALIDIR.** Yukarıdaki dört bloker düzeltildikten sonra
doğru hamle yeni bir kâğıt turu değil, **`Y2`'de gösterdiğim gibi mekanik kontroldür** — nitekim bu
turun en sert iki bulgusu (`Y2` ve `verify.ps1:26`'nın kesinleşmesi) **proza okumakla değil, 15
satırlık iki betikle** çıktı. `K53`'ün açılıştaki iddiası bu denetimde **bir kez daha ölçüldü.**

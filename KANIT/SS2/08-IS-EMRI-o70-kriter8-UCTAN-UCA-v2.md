# İŞ EMRİ v2 — `SS2` kabul kriteri **8**: UÇTAN UCA çakışma koşumu (oturum 70)

> 🔴 **BU BİR SPEC DEĞİLDİR, YENİ TUR AÇMAZ.** Kaynak: **kilitli** `GOREV-SS2-cakisma-cozumu.md`
> §7 kriter 8 (`K133`/`K136`) + `K80` + `ORTAM.md`. Yeni `G<n>` / `D-<x>` / mutant kimliği ilan edilmez.
>
> **v1 `K127` denetiminde DÜŞTÜ** — iki bağımsız denetçi, **17 bloker**; rapor:
> **`KANIT/SS2/07-DENETIM-TUR1-o70-kriter8-v1-DUSTU-17-bloker.md`**. v1 `KANIT/SS2/06-…` olarak durur.
>
> **EL BÖLÜMÜ (Onur kilitledi):**
> - **ONUR** — arayüzü **fiilen sürer** (başlığı `B1`/`A1` yapar, çözüm ekranını açar, *Benimkini tut*'a basar).
> - **CLAUDE CODE** — ortamı **kaldırır**, her adımda **ölçer ve ham kanıt üretir**. UI'a dokunmaz.
> - **COWORK** — ortama **dokunmaz** (`K80`); yalnız ham kanıtı okuyup **hüküm** verir (`K26`).
>
> 🔴 **Bu belgeye commit/push durumu, `R8` rengi ve `flutter test` taban sayısı YAZILMAZ** —
> üçü de **ölçülür** (`DURUM.md` §2/7 `K82-b` · §3 radar satırı · `ORTAM.md` *"kapı hükmü, koştuğu
> ortamın hükmüdür"*). v1 üçünü de yazmıştı; **doktrin ihlaliydi, düzeltildi.**

---

## 0. MAYIN TABLOSU — her biri bu projede EN AZ BİR KEZ ısırdı

| mayın | kural |
|---|---|
| **Kabuk cinsi** | Her komut bloğunun üstünde **hangi kabukta** koşacağı yazılıdır. `$env:X="Y"` **YALNIZ PowerShell**'dir; Git Bash'te sessizce hiçbir şey yapmaz |
| Sabit `sleep` | **ölçüm değildir** — koşula kadar **yoklanır**; bu belgede her yoklamanın **aralığı + deneme sayısı + tavan aşımı davranışı** yazılıdır |
| `cmd /c "... %VAR%"` | **sahte `EXIT=0`** ⇒ `cmd /v:on /c "... !VAR!"`; `set` sonrası da `!VAR!`. 🔴 Ham `cmd /c` **PowerShell'den** koşulur (Git Bash `/c`'yi `C:/` diye yeniden yazar). 🔴 `adb shell` komutunda `^\|` yazılırsa pipe **cihazda** çalışır ve **cihazda `findstr` YOKTUR** — boru **host tarafında** kurulur |
| `flutter` | **`.bat`** ⇒ `$FLUTTER = "C:\src\flutter\bin\flutter.bat"`. **Bu belgedeki HER çağrı `$FLUTTER` ile yapılır** |
| `adb` | **PATH'te YOK** ⇒ `$ADB = "C:\Users\gulci\AppData\Local\Android\Sdk\platform-tools\adb.exe"`. **HER çağrı `$ADB` ile** |
| `flutter test` | Kabukta **`%PROGRAMFILES(X86)% environment variable not found`** ile çökebilir ⇒ alt sürece `PROGRAMFILES(X86)=C:\Program Files (x86)` **enjekte edilir**. Bu bir **ORTAM** kusurudur, regresyon **değildir** |
| `findstr` ile **yokluk** ölçmek | **AYNI çağrıda bir VARLIK pozitif kontrolü** koşmak **ZORUNDADIR**; yoksa boş dönüş *"kapalı"* mı *"kör"* mü ayrılamaz |
| `uiautomator dump` | uygulama çizilmeden çağrılırsa **dosya oluşmaz** (`"dumped to"` yoklanır) **ve** Flutter tuvaline **kör olabilir** ⇒ §6'daki **pozitif kontrol** zorunludur; **birincil kanıt `screencap`tir** |
| `python` stdout | **cp1254** ⇒ her betiğe `sys.stdout.reconfigure(encoding="utf-8", errors="replace")` |
| Kanıt kodlaması | PowerShell 5.1'de `>` **UTF-16LE** üretir ⇒ **`\| Out-File -Encoding utf8`**. Her kanıt dosyası **UTF-8 + LF**; yazımdan sonra `python araclar\dosya-kimlik.py <dosya>` ile **ölçülür** |
| `verify.ps1` | **çalışan `Momentum.Api` varken KOŞULAMAZ** (36 `MSB3026`) ⇒ §7 sökme adımı **zorunludur** |
| `os.replace` | Windows'ta `WinError 5` verebilir ⇒ `K60` takası **üç adımlı yedekli** |
| git | `--no-optional-locks` **zorunlu** · `git add -A` **YASAK** · mesajda **çift tırnak yok** · her git turunun sonunda **`.git\index.lock` yoklanır** · **PUSH ONUR'DA** |

---

## 1. ÖN KOŞUL ÖLÇÜMLERİ — **hepsi §3'ten ÖNCE, hepsi `00-onkosul.txt`'ye**

🔴 **Her madde bir ÖLÇÜMDÜR. Herhangi biri sağlanmazsa: DURULUR, ham çıktı yazılır, ONUR'A DÖNÜLÜR.**
Sessizce ikinci bir yola geçilmez.

*(PowerShell, `C:\dev\Momentum`)*

| # | ölçüm | geçme şartı | sağlanmazsa |
|---|---|---|---|
| **Ö1** | `git --no-optional-locks log --oneline -1` · `git --no-optional-locks status --porcelain -- src` | ağaç `src` altında **temiz** | DUR |
| **Ö2** | `git --no-optional-locks merge-base --is-ancestor 2710db0 HEAD; $LASTEXITCODE` | **0** — başlık düzenleme UI'ı (`K174`) tabanda **var** | DUR: adım ④ koşulamaz |
| **Ö3** | `Test-Path $FLUTTER` · `Test-Path $ADB` · `Test-Path KANIT\A11\_backend_dogrula.py` | **üçü de True** | DUR |
| **Ö4** | `& $FLUTTER emulators` | **en az İKİ ayrı AVD** listeleniyor | DUR — `S6` Android şart koşuyor, tek AVD ile bu tur koşulamaz |
| **Ö5** | `docker inspect --format '{{json .State.Health}}' momentum-postgres` *(PowerShell; tırnak `cmd`'de bozulur)* | çıktı **`null` değil** ⇒ healthcheck **var** | healthcheck **yoksa** yedek ayak: `docker exec momentum-postgres pg_isready -U momentum` (bu **beyan edilir**, gizlenmez) |
| **Ö6** | `Test-Path src\backend\Momentum.Api\Properties\launchSettings.json` + varsa içeriğinde `applicationUrl` araması | dosya yoksa **bilgi**; varsa `--no-launch-profile` gerekçesi **ölçülmüş** olur | — (§3② zaten bayrağı taşır) |
| **Ö7** | 🔴 **İSTEMCİNİN TABAN URL'si NASIL VERİLİYOR:** `src\client\lib` altında `10.0.2.2` / `5298` / `baseUrl` / `dart-define` aranır; **bulunan yol kanıta yazılır** | **iki emülatörün de aynı backend'e** hangi adresle gideceği **ölçülmüş** olur | Taban URL **derleme zamanı sabiti** ise ve iki istemci için değiştirilmesi gerekiyorsa ⇒ **ÜRÜN KODU değişikliği** ⇒ §8 kilidi ⇒ **DUR, ONUR'A DÖN** |
| **Ö8** | 🔴 **BACKEND LOGU `clientId` ve HLC'yi GÖSTERİYOR MU:** backend ayağa kalktıktan sonra `_backend_dogrula.py`'nin `/v1/sync` çağrısı yapılır ve **backend penceresinin çıktısında** `clientId`/HLC aranır | **görünüyor** | 🔴 **DUR, ONUR'A DÖN.** Onur'un kilidi *"iç durum backend logundan okunur"* idi; log gövdeyi yazmıyorsa bu kilit **ölçümle düşer** ve iki kalan şık (cihaz sqlite'ı / uygulamaya hata-ayıklama çıktısı = ürün kodu) **yeniden Onur'a sunulur.** Sessizce yol değiştirilmez |

---

## 2. ORTAM — sırayla; **her adım ölçülür, hiçbiri varsayılmaz**

### ① PostgreSQL *(PowerShell)*
```powershell
docker start momentum-postgres
docker ps -a
```
🔴 **Yoklama:** `2 sn aralık · en fazla 30 deneme (≈60 sn)`; koşul `docker inspect --format '{{.State.Health.Status}}' momentum-postgres` ⇒ **`healthy`**
(Ö5'te healthcheck yoksa koşul `docker exec momentum-postgres pg_isready -U momentum` ⇒ **EXIT 0**).
**Tavana çarparsa: DUR**, ham çıktıyı yaz, Onur'a dön.
🔴 `docker ps -a` da yazılır: o42'de bu konteyner **`Exited (255)`** çıkmıştı ve belge *"Up (healthy)"* diyordu.

### ② Backend — **ayrı pencerede, açık kalır, LOGU DOSYAYA AKAR** *(PowerShell)*
```powershell
$backendLog = "C:\dev\Momentum\KANIT\SS2\T8-uctan-uca\09-backend-log.txt"
Start-Process powershell -ArgumentList @(
  "-NoExit","-Command",
  "cd C:\dev\Momentum\src\backend\Momentum.Api; " +
  "`$env:ASPNETCORE_ENVIRONMENT='Development'; " +
  "`$env:ASPNETCORE_URLS='http://0.0.0.0:5298'; " +
  "`$env:ConnectionStrings__Momentum='Host=localhost;Port=5432;Database=momentum;Username=momentum;Password=momentum_dev'; " +
  "dotnet run --no-launch-profile 2>&1 | Tee-Object -FilePath '$backendLog'"
)
```
- 🔴 **`--no-launch-profile` PAZARLIKSIZ:** `launchSettings.json`'ın `applicationUrl`'ü kalıtılan
  `ASPNETCORE_URLS`'i **ezebilir** ⇒ backend `localhost`'a bağlanır ve **emülatör hiç ulaşamaz**.
- 🔴 Ortam değişkenleri **çocuk sürecin İÇİNDE** set edilir — dış kabuktaki `$env:` alt pencereye geçmez.
- 🔴 `ASPNETCORE_ENVIRONMENT=Development` yoksa `NullCurrentUser` ⇒ **her istek 401** (`K61`).
- 🔴 Bağlantı dizesi verilmezse host **DB'siz** açılır: port **yine LISTENING** gösterir, Postgres'e **hiç bağlanmaz**.
  Değerler `docker inspect momentum-postgres` ⇒ `POSTGRES_DB/USER/PASSWORD` ile **teyit edilir**.
- 🔴 **Bind adresi ölçülür:** `netstat -ano | findstr :5298` çıktısı **`0.0.0.0:5298`** göstermeli.
  `127.0.0.1:5298` ⇒ **KIRMIZI, DUR.** *(Pozitif kontrol: aynı `netstat` çıktısında bilinen başka bir
  LISTENING satırının görüldüğü de yazılır — boş dönüş "kapalı" mı "kör" mü ayrılsın.)*

### ③ Hazır olma — **PORTLA ÖLÇÜLMEZ**
`python KANIT\A11\_backend_dogrula.py` — zorunlu üçlü:
1. `GET /health/live` ⇒ **200** · 2. `GET /health/ready` ⇒ **200** (503 ⇒ bağlantı dizesi yok/yanlış)
3. `POST /v1/sync` **başlıksız ⇒ 401**, `X-Momentum-Dev-User` ile ⇒ **200**
🔴 `clientId` **geçerli GUID olmak zorunda** — dize gönderilirse uç **500** döner ve bu **PROBUN** kusurudur.
🔴 **Yoklama:** `2 sn · en fazla 30 deneme`. Tavana çarparsa **DUR**.
🔴 Bu adımın hemen ardından **Ö8** koşulur (backend logu `clientId`/HLC gösteriyor mu).

### ④ İki Android emülatör — 🔒 **`S6`: kriter 8 ANDROID üzerinde koşar** *(PowerShell)*
```powershell
& $FLUTTER emulators --launch <avd-B>
& $FLUTTER emulators --launch <avd-A>
& $ADB devices
```
- AVD adları **Ö4'te ölçülendir**, varsayılmaz.
- 🔴 `& $ADB devices` **İKİ ayrı seri** göstermeli. Tek seri ⇒ **DUR** (ikinci emülatör kalkmadı; RAM olabilir).
  **Yoklama:** `3 sn · en fazla 40 deneme`; her cihaz için `& $ADB -s <seri> shell getprop sys.boot_completed` ⇒ **`1`**.
- 🔴 **Uygulama BU TURDA, BU AĞAÇTAN kurulur:** her iki cihaza `& $FLUTTER run -d <seri>` (ham log kanıta).
  Aksi hâlde aylar önce kurulmuş bir APK ölçülür ve hüküm **hiçbir commit'e atfedilemez**.

---

## 3. ADIM ⓪ — TOHUMLAMA *(v1'de YOKTU; denetimin B-A blokeri)*

🔴 **Bu adım olmadan kriter 8 HİÇ TETİKLENMEZ:** görev B'de yoksa çekiş `G32/f` **INSERT dalına**
düşer ⇒ **0 kayıt** ⇒ kriter kırmızı olur ve bu **ürün kusuru sanılır**. v1'i düşüren `Ö8`/BLOKER-5
sınıfının aynısıdır.

**Onur sürer, Claude Code ölçer.** Ham çıktı → `02-taban-durum.txt`

1. **A'da bir görev yaratılır** (başlık: `T0`).
2. **A senkronize olur**, ardından **B senkronize olur**.
3. 🔴 **ÖLÇÜLÜR:** görev **B'de görünüyor** ve **iki taraftaki `entityId` AYNI** (backend logundan).
4. 🔴 **ÖLÇÜLÜR:** **iki kuyruk da BOŞ** — bayat bir bekleyen op `bekleyenYerelYazimVarMi`'yi
   **yanlış sebeple** doğrular. (Ölçüm: tohumlama turundan sonra iki cihazın da telde başka op göndermemesi.)
5. 🔴 **ÖLÇÜLÜR:** iki `clientId` **FARKLI** ve iki `X-Momentum-Dev-User` (**`UserId`**) **AYNI**.
   `UserId` ⟂ `ClientId` (`K61`); farklı `UserId` ⇒ cihazlar birbirinin görevini **hiç görmez** ve
   ⑤–⑦ **sessizce boş üretir**. Kaynak: **backend istek logu**.
6. 🔴 **ÖLÇÜLÜR:** iki cihazın saati — `& $ADB -s <seri> shell date` ↔ `Get-Date`. Fark kanıta yazılır.
   **Fark 5 sn'yi aşarsa senkronize edilir**; aşan fark HLC yarışını **ters çevirebilir** (denetim M-11).

---

## 4. SENARYO — kriter 8'in ④–⑦ adımları

> 🔴 **PENCERE TEK ATIMLIKTIR.** B'nin turu bittiği an op kuyruktan düşer,
> `bekleyenYerelYazimVarMi` sonsuza dek `false` olur. **Kaçırılan pencere geri gelmez** ⇒
> **adım ⓪'dan yeni bir görevle baştan başlanır.** Bu bir başarısızlık değil, yordamdır.

**④ B çevrimdışına alınır** *(Claude Code ölçer)*
```powershell
& $ADB -s <seri-B> shell svc wifi disable
& $ADB -s <seri-B> shell svc data disable
```
🔴 **POZİTİF ÖLÇÜM ZORUNLU** (denetim B-H): cihazdan backend'e bir istek denenir ve **başarısız
olduğu ölçülür** — `& $ADB -s <seri-B> shell curl -m 5 http://10.0.2.2:5298/health/live` (ya da eşdeğeri)
**başarısız** dönmeli. Başarılı dönerse **B ÇEVRİMDIŞI DEĞİLDİR ⇒ DUR**, senaryo koşulmaz.
Ardından **Onur** B'de başlığı **`B1`** yapar. Op **kuyrukta** kalır.
🔴 **İkinci ölçüm:** `60 sn` boyunca backend logunda B'nin `clientId`'sinden **hiçbir istek görülmez**.

**⑤ A yazar ve senkronize olur** *(Onur sürer)* — başlık **`A1`**.
🔴 **A, B'den SONRA yazar.** Kazananı HLC belirler; **HLC backend logundan OKUNUR** ve
`04-adim5-A-yazdi.txt`'ye yazılır. 🔴 **A kazanmazsa bu bir KURULUM kusurudur, ürün kusuru DEĞİLDİR** ⇒
tur **geçersizdir**, adım ⓪'dan tekrarlanır (saat farkı ölçümü gözden geçirilir).

**⑥ B çevrimiçi olur ve BEKLEYEN OP'U VARKEN bir tur koşar**
```powershell
& $ADB -s <seri-B> shell svc wifi enable
& $ADB -s <seri-B> shell svc data enable
```
🔴 **Turun tetikleyicisi TEK YOLA sabitlenir ve YAZILIR:** bu projede **yoklama YASAKTIR** (`K68`) ⇒
tur olaya bağlıdır. Kullanılan tetikleyici (uygulamayı ön plana alma / açık yenileme / SignalR sinyali)
kanıta **birebir** yazılır. 🔴 **Backend logundan TAM BİR turun koştuğu ölçülür.**
Beklenen: B'de **rozet çıkar**, `CakismaCozumSayfasi` **`B1` ↔ `A1`** gösterir.
🔴 **Rozet tek başına yeterli DEĞİLDİR** — `S5`: rozet **iki farklı olayı** aynı ikonla gösterir
(`D-SS2-7`); yükü taşıyan ayak **ekran içeriğidir**.

**⑦ "Benimkini tut"** *(Onur basar)* ⇒ `cakismaCoz(entityId, benimkiniTut)`
Beklenen: B'nin **listesinde `B1` görünür** (🔴 **projeksiyon DA yazıldı** — v1'de yazılmıyordu,
kullanıcı basıyor liste değişmiyordu) **ve `A1` üzerine yazarak A'ya ULAŞIR**.
🔴 **A'ya ulaşma ayrı bir adımdır:** A'da senkron **Onur tarafından** tetiklenir, tetikleyici yazılır,
A'nın listesi `screencap` ile kanıtlanır ve backend logunda B'nin yazımının A'ya gittiği görülür.
🔴 **`S11` BEYAN:** `cakismaCoz`'un dış transaction'ı içinde `duzenle`/`tamamlaGeriAl`'ın kendi
`transaction()`'larının **savepoint'e indirgendiği bu spec'te ÖLÇÜLMEMİŞTİR.** Belirti *"liste değişti
ama A'ya ulaşmadı"* olursa bu **`S11`'in ilk canlı ölçümüdür** — ham log yazılır, **DURULUR, Onur'a dönülür.**

---

## 5. KANIT — `KANIT/SS2/T8-uctan-uca/` altına, **HAM**, **UTF-8 + LF**

🔴 Özet dosyası kanıt **sayılmaz**. Her dosyanın başında: **cihazdan ölçülmüş tarih**
(`Get-Date -Format 'yyyy-MM-dd HH:mm'` — bulut UTC'dir, `ORTAM.md`), **komut**, **çıkış kodu**, **el**.

| dosya | içerik |
|---|---|
| `00-onkosul.txt` | §1'in **sekiz** ölçümü (Ö1–Ö8) ham |
| `01-ortam.txt` | `docker ps -a` · health yoklama turları · `netstat` (`0.0.0.0:5298` + pozitif kontrol) · `adb devices` (**iki seri**) · `boot_completed` · `flutter run` kurulum logları |
| `02-taban-durum.txt` | adım ⓪'ın **altı** ölçümü (entityId aynı · kuyruklar boş · clientId'ler farklı · UserId aynı · saat farkı) |
| `03-adim4-B-cevrimdisi.txt` | kesme komutları + **pozitif çevrimdışılık ölçümü** + 60 sn sessizlik ölçümü |
| `04-adim5-A-yazdi.txt` | A'nın yazımı + senkron yanıtı + **HLC değerleri** (backend logundan) |
| `05-adim6-cakisma-gorundu.txt` | tur tetikleyicisi + backend log kesiti + **`screencap` PNG** + `uiautomator` XML |
| `06-adim7-benimkini-tut.txt` | çözüm sonrası B'nin listesi (**`B1`**) + A'ya ulaşma ölçümü + iki `screencap` |
| `07-regresyon.txt` | `$FLUTTER test` (**`PROGRAMFILES(X86)` kalkanıyla**, `src\client` dizininde) + `$FLUTTER analyze --fatal-infos` |
| `08-sokme.txt` | §7'nin ölçümleri |
| `09-backend-log.txt` | backend penceresinin **tam** çıktısı (`Tee-Object`) |

🔴 **`uiautomator dump` POZİTİF KONTROLÜ:** aynı dump'ta **ekranda kesinlikle bulunan bilinen bir
metin** (ör. `AppBar` başlığı) da aranır. Bulunmuyorsa dump **KÖR ilan edilir** ve
*"çakışma yok"* **DENMEZ** — hüküm `screencap` PNG'lerine dayanır.

---

## 6. SÖKME *(v1'de YOKTU; denetim M-4)*

1. İki emülatördeki uygulamalar kapatılır (emülatörler açık kalabilir).
2. **Backend kapatılır** — `Momentum.Api` penceresi `Ctrl+C` / kapatılır.
   🔴 `netstat -ano | findstr :5298` **BOŞ** ölçülür (**pozitif kontrol** ile birlikte).
   Aksi hâlde bir sonraki `verify.ps1` **36 `MSB3026`** ile düşer.
   🔴 **Kapatmayı Cowork yapmaz** (`ORTAM.md`: yalnız Onur'un açık izniyle, ve **yeniden başlatmaz**).
3. `docker` konteyneri **açık bırakılır ya da durdurulur** — hangisi yapıldıysa **yazılır**.
4. `git --no-optional-locks status --porcelain` + **`Test-Path .git\index.lock`** koşulur.

---

## 7. DOKUNULMAYACAKLAR (kilitli)

- 🔒 **ÜRÜN KODUNA TEK BAYT YAZILMAZ** — bu bir **ÖLÇÜM** turudur.
  🔴 Kod değişikliği **zorunlu** hâle gelirse (Ö7 taban URL · Ö8 backend logu) ⇒ **DURULUR ve ONUR'A DÖNÜLÜR.**
- 🔒 `S6` — kriter 8 **Android** üzerinde koşar; **web şıkkı YOKTUR** (v1'in ihlali).
- 🔒 `K46` `DESIGN.md` · `K61` dev-kimlik kalkanı · `K60` atomik yazım · `D-SS2-11`'in
  `bekleyenYerelYazimVarMi`'si ile `kuyrukTabaniSaglayici` (D5) **AYRI** şeylerdir.
- 🔒 **Commit:** önce `git --no-optional-locks config user.email` **ÖLÇÜLÜR** (`K149`/2) → yol belirterek
  `add` (`add -A` YASAK) → mesajda çift tırnak yok → sonra **`status --porcelain` + `Test-Path .git\index.lock`**
  (`CLAUDE.md` errata, **PAZARLIKSIZ**). **PUSH ONUR'DA.**

---

## 8. KABUL ÖLÇÜTLERİ — Cowork **bağımsız** ölçer (`K26`)

| # | ölçüt | eşik (**kör olmayacak biçimde**) |
|---|---|---|
| **1** | Ön koşullar | `00-onkosul.txt`'de **Ö1–Ö8'in sekizi de** ham; hiçbiri "atlandı" değil |
| **2** | Ortam | health **yoklanarak** `healthy`/`pg_isready` · `netstat` **`0.0.0.0:5298`** (127.0.0.1 ⇒ KIRMIZI) · `/health/live`+`/health/ready`+`/v1/sync` 401→200 · `adb devices` **İKİ seri** · her ikisinde `boot_completed=1` |
| **3** | Ağaç çivilendi | `status --porcelain -- src` **boş** · `merge-base --is-ancestor 2710db0 HEAD` ⇒ **0** · uygulama **bu turda** `flutter run` ile kuruldu (ham log) |
| **4** | Taban durum | `entityId` iki tarafta **aynı** · iki kuyruk **boş** · iki `clientId` **farklı** · iki `UserId` **aynı** · saat farkı **≤ 5 sn** — **beşi de backend logundan/ölçümden**, beyandan değil |
| **5** | B **gerçekten** çevrimdışıydı | cihazdan backend'e istek **başarısız** ölçüldü **ve** 60 sn boyunca B'nin `clientId`'sinden **hiç istek yok** |
| **6** | A, B'den **sonra** ve **kazanan** | **HLC değerleri** `04-…`'te ham; A'nın damgası B'ninkinden **büyük** |
| **7** | 🔴 **ÇAKIŞMA GÖRÜLDÜ** | ekran **`B1` ↔ `A1`** gösterdi — kanıt **`screencap` PNG**; `uiautomator` XML **pozitif kontrolü geçtiyse** ikincil ayak. Rozet **tek başına yetmez** (`S5`) |
| **8** | 🔴 **Benimkini tut ÇALIŞTI** | B'nin **listesinde `B1`** (projeksiyon yazıldı, `screencap`) **ve** A'da `B1` göründü (`screencap`) **ve** backend logunda B'nin yazımı görüldü |
| **9** | Regresyon | `07-regresyon.txt`'de **cihazda ölçülen** `N/N · 0 fail · EXIT 0` **ve** `analyze --fatal-infos` **0**. 🔴 Taban sayı **bu belgeye yazılmaz, ölçülür**; `KANIT/SS2/05`'in **549**'u **Linux/bulut** hükmüdür, `DURUM.md` §3 **539** der — ikisi de **beklenti**, eşik değil |
| **10** | Sökme | backend kapandı, `netstat :5298` **boş** (pozitif kontrolle) · `.git\index.lock` **YOK** |
| **11** | Ham kanıt tam | §5'teki **on** dosya var, **UTF-8+LF** (`dosya-kimlik.py` ile ölçülü), her biri **tarih+komut+çıkış kodu+el** başlığı taşıyor; en az **üç `screencap` PNG** var |

🔴 **7 ve 8 olmadan 1–6 bir ölçüm DEĞİLDİR.** *"Ortam kuruldu, senaryo koştu"* **geçme demek değildir** —
v1'in tam kusuru buydu ve `KANIT/SS2/07` bunu 17 blokerle ölçtü.

---

## 9. NE ÖLÇÜLEMEZ — **peşinen beyan** (kapanmadı, gizlenmedi)

- **Cowork bu ortamı kaldıramaz ve cihazdan hiçbir şey ölçemez** (`K80`): Desktop Commander **altıncı
  oturumdur yok**, `device_bash` ayrı bir Linux VM (ağ ad alanı ayrı, Android SDK yok), `computer_*`
  terminalde yalnız 'click' kipinde. ⇒ Cowork hükmü **ham kanıt dosyalarına** dayanır; bu, `K26`'yı
  **biçimsel** olarak karşılar, **fiilen** karşılamaz — bu yüzden §8'in ölçütleri **makine üretimi
  artefakt** (PNG, XML, backend logu) ister, elle yazılmış `.txt` yetmez.
- **`flutter test --platform chrome`** bu ortamda sonuç üretmiyor (7 dk ve 9,8 dk) ⇒ web ayağı **[DOĞRULANMADI]**.
- **`--no-web-resources-cdn`'in `run -d chrome` için gerekliliği** ölçülmemiştir (`B-O63-2` **AÇIK**) —
  bu turda **kapsam dışı** (`S6`: Android).
- **Ters yön** (uzak kaybettiğinde kayıt) `D-SS2-10` ile **kapsam dışıdır** (`S2`).
- **`S11`** — iç içe transaction indirgeme **ÖLÇÜLMEMİŞTİR**; bu tur onun **ilk canlı temasıdır**.
- **`S5`** — rozet iki farklı olayı aynı ikonla gösterir; ölçüt 7'nin yükü **ekran içeriğindedir**.
- 🔴 **Denetim `src/` görmeden koştu** ⇒ beş bloker (**taban URL · iç durum okuma · HLC damgalama yeri ·
  tur tetikleyicisi · `uiautomator`'ın Flutter'ı görmesi**) **mekanizmadan türetilmiş şüphedir, ölçüm değildir.**
  v2 bunları **Ö7 · Ö8 · ⑤ · ⑥ · §5 pozitif kontrolü** olarak **ölçüm adımına** çevirmiştir — *"bilinen kusur"* olarak değil.

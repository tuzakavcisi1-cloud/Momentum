# DENETİM TUR 2 — `SS2` kriter 8 iş emri **v2 DÜŞTÜ** · 🔴 **TUR 3 YASAK** (o70)

**Denetlenen:** `KANIT/SS2/08-IS-EMRI-o70-kriter8-UCTAN-UCA-v2.md` (21.244 b · sha8 `23AE07C7`)
**Zamanlama:** `K127` — kilitten **ÖNCE**. **Meşruiyet:** tur 1 **mimariyi değiştiren** blokerler bulmuştu (`K53`/1).
**Denetçiler:** iki bağımsız, taze bağlamlı ajan — kapanış denetçisi `a026ff5139252d878` (170.097 token) ·
red-team `a61d98d5a40c2dceb` (157.871 token).

## HÜKÜM: 🔴 **v2 DÜŞTÜ — 19 yeni bloker.** 🔴 **TUR 3 AÇILMAZ.**

**`K53`/1 uygulandı.** Tavan bir turdur; ikinci tur ancak birincisi **mimariyi değiştiren** bir bloker
bulduysa açılır — buldu, açıldı. **Üçüncü tur için o şart YOKTUR:** tur 2'nin blokerlerinin **hiçbiri
mimariyi değiştirmiyor**. Kapanış denetçisinin kendi cümlesi:

> *"bulguların neredeyse tamamı tek satırlık komut kusurudur (eksik `mkdir`, eksik `cd`, yanlış cmdlet,
> yanlış dosya), yani üçüncü bir **proza** turu değil, **v3 + koşum öncesi mekanik kontrol** gerekir."*

Bu, `K53`/2'nin kendi reçetesidir: **koşulamayan iddialar KODA/BUILD'e devredilir.** Tur 2'nin
blokerlerinin çoğu **kâğıtta çözülemez** — çünkü cevabı **makinededir**: `$PSVersionTable` kaç?
emülatörde `curl` var mı? `adb shell` `\r` üretiyor mu? `Tee-Object` hangi kodlamayı yazıyor?
`Program.cs` istek gövdesini logluyor mu? Bunları **kâğıtta tahmin eden** her satır yeni bir
`olcum-aracinin-varsayimi` kusurudur. **Ölçecek el Claude Code'dur; o makinededir, biz değiliz.**

---

## 1. TUR 1'İN KAPANIŞ TABLOSU (kapanış denetçisinin hükmü)

**KAPANDI (9):** `B-B` taban URL · `B-C` `--no-launch-profile` · `B-E` `S6` doktrin ihlali ·
`B-I` UI sürüşü · `B-J` `uiautomator` körlüğü · `B-K` ağaca çivileme · `B-M` tavanlar ·
`B-N` `flutter test` mayını · **M-1 · M-2 · M-3 · M-4 · M-6 · M-7 · M-8 · M-10** (sekiz major).

**KISMEN (6):** `B-A` (tohumlama girdi ama *"kuyruk boş"* ayağı ölçülemez) · `B-D` (kuyruk okuma yolu
hâlâ yok) · `B-F` (HLC karşılaştırması **yanlış dosyaya** çivilenmiş) · `B-G` (tetikleyici **seçilmemiş**,
koşum anına ertelenmiş) · `B-H` (kör kapı **yeni kılıkta** geri geldi) · `B-L` (`flutter run` süreç
yönetimi hâlâ yok) · `B-O` (`X-Momentum-Dev-User` **başlıktır**, `Ö8`'in kapsamında değil) ·
**M-5 · M-9 · M-11**.

🔴 **Ders:** dokuz bloker kapandı, altısı **kısmen** — ve kısmen kapananların **hepsi** aynı sebepten:
**kâğıt, makinede ölçülmesi gereken bir şeyi kâğıtta çözmeye çalıştı.**

---

## 2. TUR 2'NİN BLOKERLERİ — **CLAUDE CODE'UN KOŞUM ÖNCESİ ÖLÇECEĞİ LİSTE**

🔴 **Bunlar "belgeyi düzelt" maddeleri DEĞİL, "makinede ÖLÇ ve ölçtüğünü yaz" maddeleridir.**
Her maddenin cevabı Claude Code'un elindedir. **Ölçülmeden koşum başlamaz.**

| # | ölçülecek | neden |
|---|---|---|
| **1** | `KANIT\SS2\T8-uctan-uca\` dizini **yaratılır** (`New-Item -Force`) ve `Test-Path` ile ölçülür | Dizin yoksa `Tee-Object` yazamaz ⇒ `09-backend-log.txt` **hiç doğmaz** ⇒ ölçüt **4·5·6·8** sessizce ölçümsüz kalır |
| **2** | `$PSVersionTable.PSVersion` **ölçülür** ve kanıta yazılır | PS 5.1'de `Tee-Object`'in **`-Encoding` parametresi YOKTUR** ⇒ log UTF-16LE iner ve ölçüt 11 **tanım gereği** kırmızı olur. PS 7 ise bu ayak düşer |
| **3** | Kanıt yazımının **gerçek** kodlaması ölçülür (`dosya-kimlik.py`) | PS 5.1'de `Out-File -Encoding utf8` **BOM + CRLF** yazar ⇒ *"UTF-8+LF"* şartı **kesin** düşer. Çalışan yol: kanıtı **Python** yazar (`open(yol,"wb")` / `newline="\n"`) |
| **4** | `& $ADB shell` çıktısının **`\r` taşıyıp taşımadığı** ölçülür | Taşıyorsa `getprop sys.boot_completed` `-eq "1"` **daima False** ⇒ `boot_completed` yoklaması tavana çarpar ve ortam **hiç kurulmaz**. Aynı kusur `date`, `which`, `"dumped to"` yoklamalarında da koşar ⇒ **her `adb shell` çıktısı `.Trim()`/`-replace "\r",""`** |
| **5** | Emülatörde **`curl` var mı** (`shell which curl` / `toybox`) | Yoksa `curl: not found` ile **başarısız** döner ve belge bunu *"B çevrimdışı"* diye okur ⇒ `B-H` geri gelir. **Pozitif kontrol zorunlu:** aynı komut **kesmeden ÖNCE** koşulur ve **başarılı** olduğu ölçülür |
| **6** | `Program.cs` / `appsettings*.json` — **istek gövdesi loglanıyor mu** | `clientId` ve HLC **gövdededir**; varsayılan ASP.NET Core logu gövdeyi yazmaz. 🔴 Yazmıyorsa **Onur'un 2. kilidi ölçümle DÜŞER** ⇒ **DUR, ONUR'A DÖN** (kalan iki şık: cihaz sqlite'ı / hata-ayıklama çıktısı = ürün kodu) |
| **7** | `Ö8` **üçe ayrılır** ve **gerçek istemci isteğiyle** ölçülür: `clientId` · **HLC** · `X-Momentum-Dev-User` **başlığı** | v2 yalnız ilk ikisini arıyor ama ⓪/3 `entityId`'yi, ⓪/5 **başlığı** aynı logdan okuyor ⇒ builder Ö8'i **geçip ⓪'da takılır**. Ayrıca sentetik probun gövdesinde HLC olmayabilir ⇒ *"ölçüm aracının kusurunu ürüne yazma"* |
| **8** | `<seri>` ↔ **AVD** ↔ **Onur'un baktığı pencere** eşlemesi ölçülür (`shell getprop ro.boot.qemu.avd_name` / `emu avd name`) | Yanlış eşleme ⇒ **A'nın** radyosu kesilir, Onur **çevrimiçi** cihaza `B1` yazar ⇒ op kuyrukta kalmaz, tur boş üretir ve **ürün kusuru sanılır** |
| **9** | `$FLUTTER` · `$ADB` · `$backendLog` **her kabukta atanır** | v2'de tanım yalnız §0'ın **proza hücresinde**; `Test-Path $FLUTTER` tanımsız değişkenle **parametre bağlama hatası** verir, `False` değil. Değişkenler **pencere-yereldir** |
| **10** | `flutter run` yerine: `build apk --debug` **bir kez** → her cihaza `install` → `shell monkey -p <applicationId>` ile başlat; `applicationId` **`android/app/build.gradle`'dan ÖLÇÜLÜR** | `flutter run` ön planda ve süresizdir, kabuğu bloke eder, iki eşzamanlı koşum Gradle kilidini çakıştırır ⇒ ölçüt 3'ün ham logu **üretilemez** |
| **11** | `screencap` ve `uiautomator` **çekme** komutları: `shell screencap -p /sdcard/<ad>.png` → **`pull`** | v2 PNG'yi *"birincil kanıt"* ilan edip **komutu vermemiş**; `shell screencap -p > x.png` PowerShell metin akışında **bozulur**. XML için de `pull` adımı yok |
| **12** | `${env:PROGRAMFILES(X86)} = 'C:\Program Files (x86)'` — **doğru sözdizimi** | `$env:PROGRAMFILES(X86)="…"` PowerShell'de **ParserError**'dır (parantez değişken adını böler) ⇒ regresyon adımı ilk komutta düşer ve **ortam kusuru regresyon sanılır** |
| **13** | Backend süreci `-PassThru` ile **PID yakalanır**, sökmede `Stop-Process -Id` | `-NoExit` penceresine `Ctrl+C` gönderilemez; boru hattı `dotnet run`'ın çocuğunu öldürmeyebilir ⇒ `netstat :5298` boşalmaz, bir sonraki `verify.ps1` **36 `MSB3026`** ile düşer |
| **14** | HLC karşılaştırması `04-adim5-A-yazdi.txt`'te **KOŞULAMAZ** | B çevrimdışıyken yazdığı için **B'nin damgası ⑤ anında telde YOKTUR**; karşılaştırma **⑥'dan sonra** `05-…`/`09-…` üzerinden yapılır. Ölçüt 6'nın kaynağı düzeltilir |
| **15** | *"İki kuyruk da BOŞ"* backend logundan **ÖLÇÜLEMEZ** | Log yalnız **gönderileni** gösterir; gönderilmemiş `bekliyor` op ile boş kuyruk logda **aynı görünür**, `zehirli` op **hiç** görünmez. ⇒ ⓪/2'nin tur **isteklerindeki op listesi** ölçülür; `zehirli` **açık sınır** olarak beyan edilir |
| **16** | *"60 sn sessizlik"* **KÖRDÜR** ve sabit `sleep`tir | Bu projede **yoklama YASAK** (`K68`) ⇒ **çevrimiçi boşta** cihaz da 60 sn sıfır istek gönderir. ⇒ **tetiklenmiş sessizlik** ölçülür: kesmeden önce tetikleyici → log **dolu** (pozitif kontrol), kestikten sonra aynı tetikleyici → log **boş** |
| **17** | Saat karşılaştırması **epoch↔epoch** (`shell date -u +%s` ↔ host UTC epoch) | `shell date` **cihaz TZ**'sinde, `Get-Date` **host TZ**'sinde ⇒ **3 saatlik** fark ölçülür ve *"5 sn"* eşiği yanlış tetiklenir (`ORTAM.md`'nin UTC dersi birebir tekrarlanır) |
| **18** | `Ö5` **yanlış alanı** ölçüyor: healthcheck **varlığı** `.Config.Healthcheck`'tedir, `.State.Health` **durumdur** | Konteyner durdurulmuşken `.State.Health` `null` döner ⇒ healthcheck **varken** *"yok"* hükmü verilir. Ö5 `docker start`'tan **SONRA** koşar |
| **19** | `Ö7`/`Ö6` arama yöntemi: **`findstr /s` çıplak dizin yolu SESSİZCE 0 döner** (`ORTAM.md`) | ⇒ *"taban URL sabit değil"* yanlış yeşili ve ürün-kodu kilidi **hiç tetiklenmez**. Tarama **Python** ile yapılır (`ORTAM.md`: *"filtreleme/tarama işi için `.py` yaz"*) + **pozitif kontrol** |

### Ayrıca (major sınıfı, koşum öncesi düzeltilir)
- **Kabuğa giriş yolu ölçülür:** Claude Code hangi kabukta oturuyor? Git Bash üzerinden geçen bir
  `powershell -Command "<blok>"` backtick'i **komut ikamesine**, `$backendLog`'u **boş dizeye** çevirir
  ⇒ `ASPNETCORE_ENVIRONMENT` düşer ⇒ **her istek 401** ve bu **ürün kusuru sanılır**.
  `ORTAM.md`: *"`$` gönderme, **Python betiği yaz**."* ⇒ sürücü bir **dosya** olur, tek satırlık argüman değil.
- 🔴 **Sürücü betikler `KANIT\SS2\T8-uctan-uca\` altına yazılır** — `K175`② yasağı yalnız
  `GOREV_CLAUDE_CODE`/`docs/ADR`/`araclar` içindir; taban **32·6·41** korunur.
- **İKİ EL ARASINDA EL SIKIŞMA PROTOKOLÜ**: beş adımda sıra Onur'da, ölçüm Claude Code'da ve pencere
  **tek atımlık**. Her adım için **HAZIR → ŞİMDİ YAP → YAPTIM** + `HH:mm:ss` damgası kanıta yazılır;
  `screencap`'in **hangi anda** alınacağı yazılır.
- **v2'de dört SARKAN BÖLÜM ATFI** (v1'e §3 eklenince numaralar kaydı): satır 31 *"§6'daki pozitif
  kontrol"* → **§5** · satır 34 *"§7 sökme"* → **§6** · Ö7 *"§8 kilidi"* → **§7** · §5 tablosu
  *"§7'nin ölçümleri"* → **§6**. Ayrıca §5 *"altı ölçüm"* ↔ parantez **beş** ↔ §3'te **dört** madde.
- **Ö2**: `merge-base --is-ancestor` **128** (ölü nesne) ile **1** (ata değil) ayrılmıyor ⇒ önce
  `rev-parse --verify 2710db0^{commit}`. Birincil ayak **içerik** olmalı (başlık düzenleme `IconButton` +
  `Semantics`), hash ikincil — `K149-b`'nin uyardığı sınıf.
- **Tohum başlığı `T0` SEÇİLMEZ** — `T0` bu projede kapı/araç kimliğidir (`SS2/T0`); `SEED-1` kullanılır.

---

## 3. NE ÖLÇÜLEMEDİ — **iki denetçinin de zorunlu bölümü**

Denetçilere yine **`src/` ve `.git` VERİLMEDİ** (yalnız `CLAUDE.md`·`DURUM.md`·`ORTAM.md`·`GOREV-SS2`·
`KANIT/SS2/{05,06,07,08}`·`oturum-sagligi.py`). Bunun bedeli **kayda geçirilmiştir**:

- **`Program.cs`'in istek gövdesini loglayıp loglamadığı ÖLÇÜLMEDİ** ⇒ madde 6/7 **mekanizmadan
  türetilmiş gerekçeli şüphedir**, bu depoda ölçülmüş bir kusur değildir.
- `launchSettings.json` · istemci taban URL'si · `applicationId` · `_backend_dogrula.py`'nin gövdesi ·
  `dosya-kimlik.py`'nin BOM/CRLF hükmü · `2710db0`'ın ulaşılabilirliği — **hiçbiri ölçülmedi**.
- Cihaz/ortam tarafında **tek bir ölçüm yapılmadı**: PowerShell sürümü · `Tee-Object`'in kodlaması ·
  `curl`/`svc data`/`getprop` davranışı · `adb`'nin `\r`'si · `T8-uctan-uca` dizininin varlığı.
- 🔴 **Claude Code'un varsayılan kabuğu ÖLÇÜLMEDİ** — ve red-team'in kendi cümlesiyle:
  *"Claude Code doğrudan PowerShell'de oturuyorsa B1'in yükü düşer, **ama düşüp düşmediği belgede
  hiçbir yerde ölçülmüyor — asıl kusur budur.**"*
- Red-team tur 1'in bulgularını **kasten tekrarlamadı** ⇒ v2'nin tur 1'i kapatıp kapatmadığını
  **madde madde doğrulamadı**; onu kapanış denetçisi yaptı (§1).
- Tur 1 raporu başlıkta **17 bloker** diyor, tablosunda **15** (`B-A`…`B-O`) sayıyor ⇒ **sayı ↔ liste
  tutarsızlığı**; ham ajan çıktıları dosyaya alınmadığı için o **iki** blokerin kapanışı ölçülemedi.
  *(Kaynak: 15 bloker + 2, `M-1`/`M-2` doktrin ihlalleri bloker sayılmıştı — raporun kendi hatası,
  burada beyan ediliyor.)*

---

## 4. SONUÇ — kâğıt turu **BİTTİ**

İki tur, dört bağımsız denetçi, ~636k ajan token'ı. Tur 1 **mimariyi** düzeltti (tohumlama · topoloji ·
`S6` · ağaca çivileme). Tur 2 **mekaniği** ortaya döktü ve mekaniğin **kâğıtta çözülemeyeceğini** gösterdi.
`K53`'ün ölçülmüş gerekçesi bu turda **birebir tekrarlandı**:

> *"tur 1 → 13 bloker, tur 2 → 4, tur 3 → 0; ve üç turun hiçbirinin bulamadığı iki kusuru 100 satırlık
> bir betik ilk koşumda buldu. Prozayı LLM'e okutmak pahalı ve yüksek varyanslı; mekanik kontrol ucuz
> ve deterministik."*

🔴 **KARAR ONUR'DA.** Cowork'ün ölçülmüş önerisi: **v3 PROZA YAZILMAZ.** v2 + bu liste Claude Code'a
verilir; Claude Code **makinede ölçerek** 19 maddeyi kapatır, sürücüyü `KANIT\SS2\T8-uctan-uca\` altına
**koşan bir betik** olarak yazar (kâğıt değil, **kendini kanıtlayan kod**) ve ancak ondan sonra Onur UI'ı sürer.

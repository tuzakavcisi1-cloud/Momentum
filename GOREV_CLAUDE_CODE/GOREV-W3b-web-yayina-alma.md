# GOREV-W3b — Web Build'i YAYINA ALMA (`T1`+`T2`+yapılandırma)

**v3 — 🔒 KİLİTLENDİ (Onur, 8 Ağu 2026, oturum 66).** Cowork yazdı, oturum 65; v1 `K127` turunda **düştü**, §0'a bak.
Kilitlenirken Onur denetçinin **iki açık sorusunu da kapattı** — `§0b`.
Önceki dilim: `GOREV-W3` **v2 — `K150` ile denetimde DÜŞTÜ, kilitlenmedi.** Bu görev o spec'in
**yalnız `T1`/`T2` adımlarını** ve onların yapılandırmasını kapsar; `W3`'ün geri kalanı **açılmaz**.

🔴 **Bu belge KASTEN KISADIR.** `ADR 0004` gövdesi iki turda düştü ve o63'ün kapı taslağı da düştü;
üç turun ortak teşhisi: **var olmayan artefaktlar üzerine kâğıt yazıldı.** `K53/5` gereği önce
**koşan en küçük şey** yazılır.

---

## 0. KİLİT ÖNCESİ BAĞIMSIZ DENETİM (`K127` — PAZARLIKSIZ)

| tur | ne zaman | çıktı yolu | durum |
|---|---|---|---|
| 1 | v1, kilitten ÖNCE | Cowork projesi → `oturum-65-GOREV-W3b-denetimi.md` · agentId `a0fe359b259f347d8` | ✅ **KOŞTU — v1 DÜŞTÜ:** `KİLİTLENEMEZ`, **5 bloker + 15 major** |

🔴 **v1'in beş blokeri ve neyle kapandığı (bu metin v2'dir):**
`B1` `K81` biçim ihlali — kapı başlıkları `### W3b/G48` yazılmıştı, araç `[S0] BİÇİM` ile **EXIT 3**
verdi (denetçi **ve** üretici bağımsız ölçtü) ⇒ başlıklar `### G48`–`### G51` yapıldı, atıflar `K108`
gereği **önekli kaldı**; `§6b`'nin ikinci alanı Türkçe ek taşıyordu (`D-W3b-1'in`) ⇒ **kural adına**
indirildi. **Şimdi: `spec-kapi-kapsama.py` EXIT 0** (4 kapı · 5 kural · 18 mutant · 5 beyanlı borç).
`B2` `W3b/G51/b` **yokluk** ölçüyordu ⇒ **her temiz build'i kırmızı yakardı** (dizge bootstrap'ın üçlü
işlecinde zaten geçiyor; düşen taslak `06-…o63.py`:28-34 bu tuzağı adıyla yazmıştı ve o dosya
**okunmamıştı**) ⇒ ölçüt **ATAMAYA** çevrildi + `b2` taban pini + `M263`.
`B3` `§4c` *"docker gerekmez"* diyordu ama kriter 6'nın `verify.ps1`'i `Testcontainers.PostgreSql` ile
**gerçek konteyner** kaldırıyor ⇒ `K80` üç adımı yazıldı.
`B4` `W3b/G50/d` *"alan dolu mu"* ölçüyordu ⇒ **karşılaştırmaya** çevrildi ve `kaynakSha` üretim kuralı
`D-W3b-4`'te **tanımlandı**.
`B5` kriter 5 tüm-ağaç `git status` istiyordu (`ORTAM.md`'nin iki kez ısırmış mayını) ⇒ **dar komuta**
çevrildi ve el atandı.
🔴 **TUR 2 KARARI ONUR'UNDUR** (`K53/1`): denetçinin kendi değerlendirmesi *"`B1` ve `B5` mekanik/metinsel
düzeltmelerdir ve tur açmaz"*; `B2`/`B3`/`B4` onarımları **ölçüt ve kabul şartı** değiştirdi.
🔒 **ONUR TUR 2 AÇMADI ve v3'ü KİLİTLEDİ (oturum 66).**

### 0b. ONUR'UN KİLİT KARARLARI (oturum 66, 8 Ağu 2026)

| denetçinin açık sorusu | Onur'un kararı | belgeye etkisi |
|---|---|---|
| **MJ9** — `D-W3b-1` **hiç ölçülmemiş** bir değeri kilitliyor | **KİLİTLE + ölçümü GÖREVE AL** | `B-W3b-1`'in *"AYRI TUR"* borcu **kabul kriteri 8**'e **terfi etti**; canlı HTTP ölçümü **AYNI TURDA** koşar (negatif kontrolüyle) |
| **MJ11** — `R8`'in ölçülen getirisi **ince** | **YETER — beyan et, koş** | `§8/7` yazıldı: `R8` **teknik olarak söner** (`appsettings.json` `src/` altındadır) ama **getiri İNCEDİR**; beyan kapanış checkpoint'ine de girer |
| Desktop Commander **üç oturumdur yok** ⇒ Cowork commit **atamıyor**, ortamı **ölçemiyor** | **Claude Code yapsın** | `§4b`'ye **iki satır** eklendi |

---

## 1. NEDEN — ölçülmüş bağlam (o65, cihazda ve depo kopyasında)

**N1 — `T3` ve `T4` FİİLEN VAR.** `src/backend/Momentum.Api/Web/IzolasyonBasliklari.cs` (COOP/COEP,
`OnStarting`) ve `Web/IstemciServisi.cs` — **bugün diskte 128 satır · 6.671 b · sha256/16 `eeddf193542b53b7`**
(o65'te ölçüldü; `KANIT/W3/05` §2 ile birebir. 🔴 `KANIT/W3/04` §1'in **113 / 5.753 b /
`1bf90719eb4a83ce`** değerleri `/v{version}` onarımından **ÖNCEKİ** sürümdür ve o64/o65'te iki kez
yanlış taşındı) — `UseDefaultFiles`:111 · `UseStaticFiles`:112 · `MapFallbackToFile`:122. `Program.cs`:117 → :124 → :132 (`UseRouting` **açıkça**) → :139 (`UseCors`).
⇒ Statik servis **yazılmış** ve o63'te gerçek tarayıcıda `crossOriginIsolated = true` ölçülmüş.

**N2 — `T1` ve `T2` YOK.** Ölçüldü (o65): `src/backend/Momentum.Api/wwwroot` **dizini yok** ·
`.gitignore`'da `wwwroot` dizgesi **yok** (grep exit 1) · `araclar/web-yayina-al.py` **yok**.

**N3 — 🔴 `Istemci:KokDizin` HİÇBİR YERDE TANIMLI DEĞİL.** `Program.cs`:123 birebir
`var istemciKokDizini = builder.Configuration[IstemciServisi.KokDizinAnahtari];` — anahtar dizgesi
`IstemciServisi.cs`:43'te `const`'tur (`"Istemci:KokDizin"`), `Program.cs`'te **dizge olarak geçmez**; `appsettings.json` ve
`appsettings.Development.json`'da anahtar **yok** ⇒ bugün ara katman **hiç kurulmuyor** ve
`UseIstemciServisi` **`false` dönüyor**. Yani izolasyon ara katmanı ayakta ama **sunulacak istemci yok**.

**N4 — Kök çözümü ÇALIŞMA DİZİNİNE göredir.** `IstemciServisi.cs`:90 `Path.GetFullPath(kokDizin)`
kullanıyor (`ContentRootPath` **değil**). Dizin diskte yoksa uyarı loglanır ve ara katman **kurulmaz**
(`:91-95`) ⇒ kill switch bedava, ama **yanlış dizinden koşulan bir sunucu sessizce istemcisiz kalır**.

**N5 — 🔴 `--no-web-resources-cdn` BAYRAĞINI ÖLÇEN KAPI YOK** (`B-O63-2`). `araclar/izolasyon-olc.py`
yalnız `H` (yanıt başlıkları, stdlib) ve `T` (playwright) ayaklarını taşır; başlıkları **ara katman**
yazar ⇒ bayrak unutulsa da `H` **YEŞİL** verir. 🔴 Aracın `ÖLÇÜLEMEDİ` davranışı **sınıfa göre ayrışıyor** (o65'te iki vakayla koşturuldu):
ulaşılamayan adres ⇒ `HUKUM: OLCULEMEDI` + **EXIT 3** (**doğru**); yalnız `T` ayağı ölçülemediğinde
(`--http-only`) ⇒ *"TAM YEŞİL DEĞİL"* yazıp **EXIT 0** (**kusur**). Bu görevin kapıları **hiçbir
sınıfta** sıfır dönmez (`W3b/G51/e` + §5 çıkış kodu sözleşmesi).

---

## 2. KAPSAM

**İÇERİDE:** ① `wwwroot` + `.gitignore` girdisi ② `Istemci:KokDizin` yapılandırması
③ `araclar/web-yayina-al.py` (build + kopyalama + `_BUILD.json`) ④ dört statik kapı + mutantları.

**DIŞARIDA, gerekçeli:**
- **`ADR 0004` gövdesi** — Onur **park etti** (o65); `T1`/`T2` koştuktan **sonra** ölçülmüş gerçeklerle yazılır.
- **`W3/G43`–`G47` kapılarının implementasyonu** — o kapıların kapsamı (*"YALNIZ `Program.cs`"*) bugünkü
  ürüne **kör** (statik servis ayrı dosyada). Kapsam düzeltmesi `W3` spec'inin bir sonraki sürümüne aittir.
- **Canlı HTTP ve tarayıcı ölçümü** — `K80`: ortamı Cowork kaldırmaz. Bu görev **statik** kapılarla sınırlıdır.
- **CI'ya bağlama** — `D-A13-4` turunda; bu görev kapıyı **yazar**, CI'ya **koymaz**.

---

## 3. KARARLAR

### D-W3b-1 — `Istemci:KokDizin` = `appsettings.json`'da **göreli `"wwwroot"`** 🔒 (Onur kilitledi, o65)
```json
"Istemci": { "KokDizin": "wwwroot" }
```
**Ölçülmüş gerekçe:** ürün kodu **değişmez** (`IstemciServisi.cs`'in o63'te denetimden geçmiş 128
satırına dokunulmaz, `M-W3-2` yeniden ölçülmez); `ORTAM.md`'nin backend reçetesi zaten
`cd C:\dev\Momentum\src\backend\Momentum.Api` sonra `dotnet run` diyor ⇒ göreli yol doğru çözülür.
🔴 **BEYAN EDİLMİŞ BEDEL (`N4`):** başka bir dizinden koşulan sunucuda `wwwroot` bulunamaz, ara katman
**kurulmaz** ve uygulama **istemcisiz** ayağa kalkar — log uyarır (`IstemciServisi.cs`:92) ama
**hiçbir kapı kırmızı vermez**. Alternatif (`ContentRootPath`'e demirlemek) **REDDEDİLDİ**: ürün kodu
değişir ⇒ denetimden geçmiş dosyanın kimliği ve mutantı yeniden ölçülmelidir.
🔒 **o66 EKİ (Onur kilitledi) — `MJ9`'un kapanışı:** bu değer **hiç ölçülmemişti**; o63'ü mümkün kılan
yapılandırma **repoda yok** (`launchSettings.json` · `.csproj` · CI · `docker-compose` — dördü de
ölçüldü, o65). Karar **kilitlendi ama KÂĞITTA BIRAKILMADI**: doğrulaması `§7` **kabul kriteri 8**'dir
ve **aynı turda** koşar. `N4`'ün beyan ettiği bedel artık **beyan değil, ölçülen bir ayaktır**.

### D-W3b-2 — `wwwroot` BUILD ÇIKTISIDIR, repoya girmez
`.gitignore`'a **tam yol** yazılır: `src/backend/Momentum.Api/wwwroot/`. 🔴 **Çıplak `wwwroot` deseni
KABUL EDİLMEZ** — deponun başka yerlerinde aynı adlı bir dizin doğarsa sessizce yutulur.
`CLAUDE.md` kırmızı çizgi 5 (*"build artefaktları git-ignore"*).

### D-W3b-3 — Build komutu İKİ BAYRAĞI DA TAŞIR
```
flutter build web --release --no-web-resources-cdn --dart-define=SENKRON_SUNUCU_URL=http://localhost:5298
```
- `--no-web-resources-cdn` 🔒 **`K159-b`, Onur'un kilidi — DURUYOR.** 🔴 **o65 ÖLÇTÜ: gerekçesi COEP
  bloklaması DEĞİLDİR.** o63'ün pozitif/negatif kontrolü `127.0.0.1:5299`'da **sentetik** bir CORP'suz
  kaynağı ölçtü, `gstatic`'i **hiç test etmedi**; `gstatic` **8 Ağu 2026 09:50 UTC'de de**
  `CORP: cross-origin` gönderiyordu (bağımsız denetçi ölçtü) ve `GOREV-W3` §1 `O3` (5 Ağu, dokuz istek)
  aynısını ölçmüştü. **Bayrağın ölçülmüş değeri:** üçüncü-taraf CORP politikasına bağımlılığın kalkması
  (o politikayı Google belirler, bu depo değil) + çevrimdışı çalışabilirlik + tedarik zinciri yüzeyi.
- `--dart-define=SENKRON_SUNUCU_URL=http://localhost:5298` **ZORUNLU.** 🔴 **BEYAN EDİLMİŞ SINIR —
  KÖKEN UYUŞMAZLIĞI:** değer **mutlaktır**; sayfa `http://127.0.0.1:5298`'den açılırsa istekler
  **çapraz-köken** olur ve `appsettings.Development.json`'ın izin listesi bugün yalnız
  `["http://localhost:5000"]` ⇒ **her senkron düşer**. Aynı kökenden servis **göreli yolu** mümkün
  kılar; mutlak değer **bilerek** seçildi (istemci `String.fromEnvironment` ile derleme anında okur,
  `main.dart`:24-26) ama **hangi host'tan açılacağı kapıyla ölçülemez** (`B-W3b-3`). Gerekçe: `_senkronSunucuUrl` varsayılanı `http://10.0.2.2:5298`
  (Android emülatör takma adı) ⇒ bayraksız web build'de **her senkron isteği düşer** (`W1`/`M197` bunu
  bir kez yakalamıştı).

### D-W3b-4 — Betik `_BUILD.json` YAZAR, kapı onu **KARŞILAŞTIRIR**
`wwwroot/_BUILD.json` şeması **tam olarak** şudur:
```json
{ "kaynakSha": "<64 hex>", "zaman": "<ISO 8601, TZ'li>", "flutterSurum": "<x.y.z>", "bayraklar": ["--release","--no-web-resources-cdn","--dart-define=SENKRON_SUNUCU_URL=..."] }
```
🔴 **`kaynakSha` ÜRETİM KURALI (belirsiz bırakılamaz — iki el iki değer üretirse kapı ikisini de geçer):**
`src/client/lib/**` + `src/client/web/**` + `src/client/pubspec.yaml` + `src/client/pubspec.lock`
dosyaları **depo köküne göreli POSIX yoluna göre sıralanır**; her dosya için `sha256(yol + "\n" + içerik)`
hesaplanır ve **ardışık** bir sha256'ya beslenir. `build/`, `.dart_tool/`, gizli dosyalar **hariç**.
**Kapı aynı kuralı uygular ve sonucu `_BUILD.json`'daki değerle karşılaştırır** (`W3b/G50/d`).
🔴 **`_BUILD.json` statik kökte durur ⇒ `/_BUILD.json` olarak FİİLEN SUNULUR** (`ServeUnknownFileTypes=true`,
`IstemciServisi.cs`:107) — build sha'sı, zamanı ve bayrakları dışarı açılır. **Beyan edilmiş sınırdır**
(§8/7); gizlemek isteniyorsa `wwwroot` dışına taşınması **ayrı bir karardır**, bu turda alınmadı.

### D-W3b-5 — `T3`'ün KOPYALAMA SEMANTİĞİ: temizle-ve-kopyala, `_BUILD.json` EN SON
Kaynak `src/client/build/web`, hedef `src/backend/Momentum.Api/wwwroot`. Sıra **zorunludur**:
① hedef **varsa içeriği boşaltılır** (bayat artık dosya sınıfı ⇒ eski `main.dart.js` kalırsa tarayıcı
onu yükleyebilir) ② build çıktısı kopyalanır ③ **`_BUILD.json` EN SON yazılır** — böylece yarım kalan
bir kopyalama `_BUILD.json`'suz kalır ve `W3b/G50/d` **KIRMIZI** verir (yarım build **yeşil geçemez**).
🔴 **Betik Onur'un makinesinde koşar** (Claude Code); mount üzerinden koşulursa `os.remove`/`unlink`
**yasaktır** (`ORTAM.md`) ve adım ① **patlar** — bu betik **mount'tan koşulmaz**.

---

## 4. YAPILACAKLAR

| # | iş | dosya / komut |
|---|---|---|
| `T1` | `.gitignore`'a `src/backend/Momentum.Api/wwwroot/` **tam yolu** | `.gitignore` |
| `T2` | `appsettings.json`'a `"Istemci": { "KokDizin": "wwwroot" }` | `src/backend/Momentum.Api/appsettings.json` |
| `T3` | Yayına alma betiği: build (D-W3b-3) → çıktıyı `wwwroot`'a kopyala → `_BUILD.json` yaz | `araclar/web-yayina-al.py` |
| `T4` | Dört statik kapı + altın küme | `araclar/yayin-kapisi.py` |
| `T5` | Mutant koşucusu (ikili yedek → bayt düzeyinde yama → kapı → geri yükleme → sha) | `KANIT/W3b/_mutant_kosucu.py` |
| `T6` | Ham çıktılar + kabul hükmü | `KANIT/W3b/` |

### 4b. EL DAĞILIMI
| iş | KİM | gerekçe |
|---|---|---|
| `T1`–`T3` (ürün + betik) | **Claude Code** | rol bölümü (`CLAUDE.md`); `flutter build` uzun ömürlü, `K80` |
| `T4` kapı + altın küme | **Claude Code** yazar, **Cowork** koşar | `K26` üreten ≠ denetleyen |
| `T5` mutant koşumu | **Cowork** (hepsi statik) | `K53/3`: statik mutant **tavansız** |
| Kabul hükmü | **Cowork** | `K26` |
| **Commit** (bekleyen **8 izlenen + 3 yeni** dosya dâhil) | **Claude Code** | 🔒 Onur kilitledi (o66). Desktop Commander **üç oturumdur YOK** ⇒ Cowork commit **atamaz** (`ORTAM.md`: mount üzerinden `git add`/`commit` **YASAK**). Author **daima** `onurkesimbjk@gmail.com` (`K149/2`); **PUSH ONUR'DA** |
| **Ortam ölçümü** (`docker ps` · `netstat -ano \| findstr :5298` · `adb devices` **tam yolla**) | **Claude Code** | 🔒 Onur kilitledi (o66). `K80`: Cowork ortamı **kaldırmaz, ölçer** — o66'da **ölçemedi de**: `device_bash` Onur'un makinesinde **izole bir Linux VM**'dir (ölçüldü: `/mnt/c` **yok** · `docker` **yok** · `adb` **yok**), `computer_*` ise **'click' kipinde** — yazamaz |

### 4c. ORTAMI KİM KALDIRIR (`K80` — bu görev kendi maddesini TAŞIR)
🟢 **`T1`–`T5` canlı sunucu ya da cihaz İSTEMEZ** — `flutter build web` dışında koşan bir şey yok;
backend/emülatör **gerekmez**.
🔴 **AMA KABUL KRİTERİ 6 (`verify.ps1`) DOCKER İSTER — ölçüldü:** `verify.ps1` `dotnet test $solution`
koşar; `tests/Momentum.Persistence.Tests` `Testcontainers.PostgreSql 4.13.0` kullanır ve
`TestSupport.cs`:18-21 `PostgreSqlBuilder("postgres:17-alpine")` ile **gerçek konteyner** kaldırır.
⇒ Kriter 6 koşulmadan önce **sırayla**: ① `docker start momentum-postgres` — `healthy` görünene kadar
**YOKLANIR** (sabit `sleep` bir ölçüm değildir, `K80`) ② `netstat -ano | findstr :5298` **BOŞ** dönmeli
(çalışan `Momentum.Api` varken `verify.ps1` **EXIT 1** verir, `ORTAM.md`) ③ `verify.ps1`.
🔴 Bu adımları **Onur ya da Claude Code** koşar — **Cowork ortamı KALDIRMAZ, ÖLÇER** (`K80`). Flutter sürümü **ölçülür, varsayılmaz**:
`C:\src\flutter\bin\flutter.bat --version` (`K86`: `flutter` bu makinede `.bat`, `PATHEXT` çözülmez).
🔴 Build **Onur'un makinesinde** koşar; depo `DURUM.md` **3.44.6** diyor, o63 ölçümleri **3.44.9**'du ⇒
**yama farkı ölçülür ve `_BUILD.json`'a yazılır.**

---

## 5. KAPILAR

> 🔴 **Her ayak NASIL ölçüldüğünü yazar; yazmayan ayak KÖRDÜR.** Kapsam her ayakta yazılıdır.
> 🔴 **ÇIKIŞ KODU SÖZLEŞMESİ (dört kapı TEK betikte koşar — `araclar/yayin-kapisi.py`):**
> **0 = YEŞİL** · **1 = SARI** (yalnız `W3b/G51/b2` ve `W3b/G51/c` sapması) · **2 = KIRMIZI** (bulgu) ·
> **3 = ORTAM HATASI / ÖLÇÜLEMEDİ**. Birden fazla sınıf aynı koşumda oluşursa **EN YÜKSEK kod** döner
> (3 > 2 > 1 > 0) ve hüküm metni **hepsini** listeler. `radar.py`'nin 0/1/2 konvansiyonu esas alındı;
> `belge-tavan-kapisi.py`'nin *"SARI da 0"* deseni **bilerek reddedildi** (SARI'yı 0 yapmak CI'da
> sessizleştirir). 🔴 Kabul kriteri 1 **EXIT 0** ister — SARI **yeşil sayılmaz**.
> 🔴 **`ÖLÇÜLEMEDİ` ⇒ SIFIR-OLMAYAN ÇIKIŞ KODU** (`W3b/G51/e`) — `izolasyon-olc.py`'nin o65'te ölçülen
> kusuru (ÖLÇÜLEMEDİ'de EXIT 0) bu kapıda **tekrarlanmaz**; `B-O63-5`'in kapanmamış maddelerinden biri budur.

### G48 — Yapılandırma (statik; kapsam: **YALNIZ** `src/backend/Momentum.Api/appsettings.json`)
- **a)** `appsettings.json` **geçerli JSON** olarak ayrıştırılır (metin araması **değil**) ve
  `Istemci.KokDizin` anahtarı **VAR**.
- **b)** Değeri **boş değil** ve `"wwwroot"` (tam eşitlik; `D-W3b-1`).
- **c)** **POZİTİF KONTROL:** `appsettings.json` içinde bilinen bir anahtar (`Logging`) bulunur — *"aradım
  bulamadım"* ile *"dosyayı hiç okumadım"* ayrılır. 🔴 **Kapsam `appsettings.Development.json`'ı İÇERMEZ**
  (ölçüldü: o dosya yalnız `Cors` taşıyor, `Logging` **yok** ⇒ glob'a uygulanan pozitif kontrol **sahte
  ORTAM HATASI** verirdi).

### G49 — `.gitignore` (statik; kapsam: `.gitignore`)
- **a)** `src/backend/Momentum.Api/wwwroot/` **tam yolu** satır olarak VAR.
- **b)** 🔴 **POZİTİF KONTROL ZORUNLU** (`ORTAM.md` `findstr` dersi): aynı dosyada bilinen bir dizge
  (`bin/`) aranır ve **bulunur**; bulunmazsa **ORTAM HATASI**.
- **c)** Çıplak `wwwroot` deseni (yol öneki olmadan) **varsa** kapı **KIRMIZI** (`D-W3b-2`).

### G50 — Build çıktısı bütünlüğü (statik; kapsam: `src/backend/Momentum.Api/wwwroot/**`)
- **a)** `index.html` VAR **ve** içinde `flutter_bootstrap.js` **referansı** geçiyor (yer tutucu dosya geçemez).
- **b)** `flutter_bootstrap.js` VAR, **boş değil**, içinde `_flutter` dizgesi geçiyor.
- **c)** `canvaskit/` dizini VAR ve içinde en az bir `.wasm` (yerelleştirme **fiilen** oldu).
- **d)** `_BUILD.json` VAR, geçerli JSON; `kaynakSha` **kapının KENDİ hesapladığı** kaynak sha ile
  **TUTUYOR** ve `zaman` ISO 8601 olarak ayrıştırılabiliyor. 🔴 *"Alan dolu mu"* ölçümü **YETMEZ** —
  `"kaynakSha": "x"` de doludur; **bayat build üstünde yeşil kabul ancak KARŞILAŞTIRMAYLA engellenir**
  (`GOREV-W3`'ün `G43/f` ayağının aynısı; W3b ilk yazımında bunu zayıflatmıştı, denetimde düzeltildi).
  Sha üretim kuralı `D-W3b-4`'te **tanımlıdır** ve kapı **aynı kuralı** uygular.
- **e)** `10.0.2.2` dizgesi `wwwroot/**` içindeki `.js`/`.mjs`/`.html`/`.json` dosyalarında **YOK**
  (`D-W3b-3`). 🔴 Bu **yokluk** ayağı `b`'nin pozitif kontrolüne **bağlıdır**: `b` kırmızıysa `e`'nin
  yeşili **hükümsüzdür**.
- **f)** 🔴 `wwwroot` **YOKSA** kapı **ORTAM HATASI** (çıkış **3**) — **YEŞİL DEĞİL, ATLAMA DEĞİL**.

### G51 — 🔴 BAYRAK İZİ (statik; kapsam: `wwwroot/flutter_bootstrap.js` + `wwwroot/flutter.js`)
> **Bu kapı `B-O63-2`'nin kapanış yoludur.** Ölçtüğü şey **çalışma zamanı bayrağıdır**, dizge yokluğu değil.
- **a)** `flutter_bootstrap.js` içinde `useLocalCanvasKit` ataması **`true`** (`KANIT/W3/04` §5'te
  `--no-web-resources-cdn` çıktısında **fiilen ölçülmüştü**).
- **b)** 🔴 `canvasKitBaseUrl` **ÇAPRAZ-KÖKENE ATANMIŞ DEĞİL.** 🔴 **YOKLUK ÖLÇMEK YANLIŞ-POZİTİFTİR
  ve ölçülmüştür:** dizge **her temiz build'de** bootstrap'ın üçlü işlecinde geçer
  (`KANIT/W3/04` §5, birebir: `i.canvasKitBaseUrl ? i.canvasKitBaseUrl : (…!e.useLocalCanvasKit…)`)
  ⇒ *"geçiyorsa ısır"* diyen bir ayak **HER build'i kırmızı yakar**. Düşen taslak bu tuzağı adıyla
  yazmıştı (`KANIT/W3/06-…o63.py`:28-34). **Doğru ölçüt ATAMADIR:** `canvasKitBaseUrl` bir
  **`http(s)://` ya da protokol-göreli (`//`) değere ATANIYOR mu** — üç yazım da (tek tırnak, çift
  tırnak, protokol-göreli) kapsanır. **Salt okuma (üçlü işleç) ısırmaz.**
- **b2)** **TABAN PİNİ:** temiz bir build'de `canvasKitBaseUrl` dizgesinin geçiş sayısı ölçülür ve
  **pinlenir** (ilk koşumda yazılır); sapma **SARI** verir. Pin olmadan `b` kör kalır — `c`'nin
  gstatic pini ile **simetriktir**.
- **c)** `www.gstatic.com/flutter-canvaskit` dizgesi **SAYILIR ve RAPORLANIR, KIRMIZI VERMEZ** —
  bayrak baytı çıkarmaz, `flutter.js`(1) + `flutter_bootstrap.js`(1) = **2** yerde durur (`K151/④`
  pinli sayan-raporlayan deseni). Sayı **2 değilse** kapı **SARI** verir ve sayıyı yazar.
- **d)** **POZİTİF KONTROL:** aynı dosyada `_flutter` dizgesi bulunur ve dosya boş değildir; yoksa
  **ORTAM HATASI**.
- **e)** 🔴 **Herhangi bir ayak ölçülemezse (dosya yok, JSON bozuk, dizin okunamıyor) çıkış kodu
  SIFIR OLAMAZ.** Hüküm metni `ÖLÇÜLEMEDİ` yazar ve *"TEMİZ"* **demez**.

---

## 6. MUTANTLAR — kapıların ISIRDIĞININ KANITI

> Taksonomi: `gözlenen ⊇ hedef` ⇒ **ERRATUM** · `gözlenen ⊉ hedef` ⇒ **KÖR KAPI (BLOKER)** ·
> `gözlenen = {}` (beklenirken) ⇒ **ÖLÜ MUTANT**, kusur mutanttadır.
> **KOŞUM DİSİPLİNİ (`K118`):** ikili yedek → **bayt düzeyinde** yama → kapı → geri yükleme → **sha
> doğrulaması**. Yamanın fiilen uygulandığı ölçülmeden koşum geçersizdir.
> 🔴 **MOUNT KISITI — DÖRT MUTANT COWORK'TEN KOŞULAMAZ:** `M250` (`.gitignore` boşaltılır), `M253`
> (dizin yeniden adlandırılır), `M256` (`wwwroot` yeniden adlandırılır), `M262` (dosya **silinir**)
> dosya sistemi **yapısına** dokunuyor; mount `unlink`'e izin vermiyor (`ORTAM.md`: `PermissionError:
> Operation not permitted`) ve `K118`'in ikili-yedek disiplini **içerik** mutantı içindir. ⇒ **Bu dördü
> Onur'un makinesinde, Claude Code tarafından** koşulur; kalan **16'sı içerik mutantıdır ve Cowork
> koşar.** `mv` ile yeniden adlandırma mount'ta **çalışır** (o65'te ölçüldü) ama geri alma da `mv`
> ile yapılır ve **sha doğrulaması zorunludur**.

| # | mutant | hedef (beklenen KIRMIZI) | maliyet |
|---|---|---|---|
| `M246` | `appsettings.json`'dan `Istemci` bloğu silinir | `W3b/G48/a` | ucuz |
| `M247` | `KokDizin` değeri `"wwwroot2"` yapılır | `W3b/G48/b` | ucuz |
| `M248` | `appsettings.json` geçersiz JSON'a çevrilir | `W3b/G48` = **ORTAM HATASI (çıkış 3)**; 🔴 yeşil dönerse **BLOKER** | ucuz |
| `M249` | `.gitignore`'daki tam yol → çıplak `wwwroot` | `W3b/G49/a` **ve** `W3b/G49/c` | ucuz |
| `M250` | `.gitignore` boşaltılır | `W3b/G49/b` = **ORTAM HATASI** (pozitif kontrol düşer) | ucuz |
| `M251` | `wwwroot/index.html` yer tutucuyla değiştirilir | `W3b/G50/a` | ucuz |
| `M252` | `wwwroot/flutter_bootstrap.js` **boşaltılır** | `W3b/G50/b` **ve** 🔴 `W3b/G50/e`'nin yeşili **HÜKÜMSÜZ** ilan edilmeli | ucuz |
| `M253` | `wwwroot/canvaskit/` yeniden adlandırılır | `W3b/G50/c` | ucuz |
| `M254` | `_BUILD.json`'dan `kaynakSha` silinir | `W3b/G50/d` | ucuz |
| `M255` | Bir `.js`'e `http://10.0.2.2:5298` enjekte edilir | `W3b/G50/e` | ucuz |
| `M256` | `wwwroot` dizini geçici olarak yeniden adlandırılır | `W3b/G50/f` = **ORTAM HATASI (çıkış 3)**; 🔴 yeşil/atlandı dönerse **BLOKER** | ucuz |
| `M257` | 🔴 **DİLİMİN ÇEKİRDEK KUSURU:** `useLocalCanvasKit` değeri `false` yapılır | `W3b/G51/a` | ucuz |
| `M258` | `flutter_bootstrap.js`'e `canvasKitBaseUrl:"https://x/"` eklenir | `W3b/G51/b` | ucuz |
| `M259` | Aynı ekleme **tek tırnakla** yapılır: `canvasKitBaseUrl:'https://x/'` | `W3b/G51/b` (**ikinci yazım**) | ucuz |
| `M260` | Aynı ekleme **protokol-göreli**: `canvasKitBaseUrl:"//x/"` | `W3b/G51/b` (**üçüncü yazım**) | ucuz |
| `M261` | `flutter.js`'teki `www.gstatic.com/flutter-canvaskit` dizgesi silinir (sayı 2 → 1) | `W3b/G51/c` = **SARI** (KIRMIZI **değil**) | ucuz |
| `M262` | `flutter_bootstrap.js` **silinir** | `W3b/G51/d` = **ORTAM HATASI**; 🔴 **çıkış kodu SIFIR OLAMAZ** (`W3b/G51/e`) | ucuz |
| `M263` | `flutter_bootstrap.js`'ten `canvasKitBaseUrl` dizgesinin **bir geçişi silinir** (taban sayı düşer) | `W3b/G51/b2` = **SARI** (KIRMIZI **değil**) | ucuz |
| `MW23` | **SUSMALI:** `flutter_bootstrap.js`'e `// canvasKitBaseUrl` **yorumu** eklenir | **hiçbir kapı düşmemeli** (`{}`); düşerse `W3b/G51/b` sahte-pozitif ⇒ **BLOKER** | ucuz |
| `MW24` | **SUSMALI:** `appsettings.Development.json`'a alakasız bir anahtar eklenir | **hiçbir kapı düşmemeli** (`{}`) | ucuz |

**Toplam: 18 kusurlu + 2 susmalı = 20.** 🔴 **Sayı kabul koşumunda betikle ÖLÇÜLÜR, elle sayılmaz**
(`GOREV-W3` §6'nın dersi: elle sayım *"24+2=26"* deyip yanlış çıkmıştı). Hepsi **statik** ⇒ `K53/3`
uyarınca **tavansız**; koşan uygulama isteyen mutant **YOK**.

---

## 6b. MUTANTSIZ KURALLAR — BEYANLI BORÇ

> Her satır **DÖRT** alanlıdır: `ID | KURAL | NEDEN MUTANT YOK | KAPATMA YOLU`.
> Bir kural bu listede **değilse** ve mutantı da **yoksa**, o kural **KÖR**'dür ve denetim onu
> **BLOKER** saymalıdır.

```
B-W3b-1 | D-W3b-1 | kararin kendisi bir YAPILANDIRMA degeridir: M246/M247 kapi AYAGINI olcer, kararin CALISMA DIZININE baglilik bedelini (N4) olcen mutant YAZILAMAZ -- statik kapi kosum anini goremez | canli HTTP olcumu: GET / => 200 ve govdede flutter_bootstrap.js. KABUL KRITERI 8'e TERFI ETTI (Onur kilitledi, o66): AYNI TURDA kosar, negatif kontrolu zorunlu. El: Claude Code (K80)
B-W3b-2 | D-W3b-2 | M249/M250 .gitignore METNINI olcer; kararin DAVRANISSAL yarisi (izlenmeyen dosya cikmamasi) statik mutantla olculemez | kabul kriteri 5'in dar git komutu bu yarisi olcer ve AYNI turda kosar
B-W3b-3 | D-W3b-3 | --dart-define'in DOGRU degeri wwwroot ciktisindan olculemiyor: derlenmis JS'te dizge parcalanabilir; olculen yalniz 10.0.2.2'nin YOKLUGU (M255) | canli HTTP yarisi kabul kriteri 8'de AYNI TURDA kosar (o66); TARAYICI yarisi (calisma anindaki --dart-define degeri) ACIK KALIR -- playwright Onur'un makinesinde yok (B-O62-3)
B-W3b-4 | D-W3b-4 | M254 alanin SILINMESINI olcer; "sha DOLU ama YANLIS" sinifi ancak kaynak degistirilip kapi yeniden kosularak olculur ve o mutant T3 betigi YAZILMADAN kurulamaz | T3 kosar kosmaz M254b eklenir: src/client altinda bir dosyaya bir bayt eklenir, kapi KIRMIZI vermeli -- KABUL KOSUMUNDA ZORUNLU
B-W3b-5 | D-W3b-5 | sira ve temizleme semantigi BETIGIN ICINDEDIR; statik kapi yalniz CIKTIYA bakar, betigin ADIMLARINI goremez -- bayat artik dosya sinifi ancak iki ardisik build ile olculur | T3 kosar kosmaz M264 eklenir: wwwroot'a sahte bir eski dosya (eski-main.dart.js) birakilir, betik YENIDEN kosulur, o dosya KALMAMALI -- KABUL KOSUMUNDA ZORUNLU
```

---

## 7. KABUL KRİTERLERİ

1. `W3b/G48` · `W3b/G49` · `W3b/G50` · `W3b/G51` **YEŞİL** — **Cowork koşar** (`K26`), ham çıktı `KANIT/W3b/`'ye.
2. `araclar/yayin-kapisi.py --altin-kume` **EXIT 0**; altın küme **her ayak için en az bir temiz + bir
   kirli vaka** taşır. 🔴 **Bu şartı zorlayan MEKANİK KAPI YOKTUR** — `sayi-tazeligi.py` yalnız belgedeki
   *"altın küme N/M"* iddiasını aracı koşarak doğrular, **vakaların kapsamını ölçmez** (aracın kendi
   beyanı). Şart **insan disiplinidir** ve denetim turunda **elle** doğrulanır. Kabul koşumunda sayı
   **çıktıdan okunur** ve belgeye o zaman yazılır; ezberden yazılan sayı `sayi-tazeligi.py`'ye takılır.
3. **20 mutantın 20'si** hükmü verir: **18** kusurlunun her biri `hedef`ini düşürür, **2** susmalının
   **hiçbiri hiçbir kapıyı düşürmez**. Sapma taksonomiyle **yazılı olarak** sınıflanır.
4. `dotnet build src/backend/Momentum.Api` ⇒ **0 uyarı / 0 hata** (`appsettings.json` değişikliği
   derlemeyi bozmamalı).
5. **İZLENMEYEN DOSYA ÖLÇÜMÜ — DAR KOMUT ZORUNLU:**
   `git --no-optional-locks ls-files --others --exclude-standard -- src/backend/Momentum.Api/wwwroot`
   çıktısı **BOŞ** dönmeli (`D-W3b-2` fiilen çalışıyor). 🔴 **TÜM-AĞAÇ `git status --porcelain` YASAK**
   — mount'ta `device_bash`'in 45 sn tavanını aşar, **EXIT 124** verir ve ardında `.git/index.lock`
   bırakır (`ORTAM.md`, o63'te ölçüldü, o64'te tekrarlandı; `B-O64-4`). Bu ölçümü **Cowork** koşar. 🔴 Bu, `W3b/G49`'un **statik** iddiasının **davranışsal**
   doğrulamasıdır; ikisi ayrı ölçümdür.
   🔴 **o66'DA YENİ ÖLÇÜLDÜ — `ORTAM.md`:44 bunu BİLMİYOR:** bu dar komut **tek başına** koşulduğunda
   kilit **bırakmaz** (üç kontrollü izolasyon testi, o66: `diff --name-only -- <tek dosya>` ·
   `ls-files --others -- <dizin>` · `log --oneline -1` — üçü de temiz). **AMA 23 dar git çağrısı arka
   arkaya** koşulduğu turda 0 baytlık bir `.git/index.lock` **OLUŞTU** ve hangi çağrının bıraktığı
   **İZOLE EDİLEMEDİ** — `[TAHMİN]`: `timeout` bir git sürecini index yenileme ortasında öldürdü.
   ⇒ **Bu ölçümden SONRA `.git/index.lock` varlığı YOKLANIR**; varsa `_SILINECEKLER/<oturum>/`'e `mv`
   edilir (sandbox **silemez**, kalıcı silme Onur'dadır).
6. 🔴 **`verify.ps1` EXIT 0** — backend **kapatıldıktan** sonra (`ORTAM.md`: çalışan `Momentum.Api`
   varken `verify.ps1` **EXIT 1** verir). Bu, `B-O62-2`'nin **dördüncü** oturumdur açık olan borcuna
   dokunur; koşarsa borç **kapanır**.
7. **Bağımsız denetim turu 1** koşmuş ve **kabul** demiş olmalı (`§0`).
8. 🔒 **CANLI HTTP ÖLÇÜMÜ — `B-W3b-1`'DEN TERFİ ETTİ (Onur kilitledi, o66; `MJ9`'un kapanışı).**
   `D-W3b-1`'in göreli `"wwwroot"` değeri **hiç ölçülmemişti**. Bu turda **ÖLÇÜLÜR**:
   `ORTAM.md`'nin backend reçetesiyle sunucu **`src/backend/Momentum.Api` dizininden** kaldırılır →
   ① `GET /` ⇒ **200** ve gövdede **`flutter_bootstrap.js` dizgesi geçer** → ② `GET /_BUILD.json` ⇒ **200**.
   🔴 **③ NEGATİF KONTROL ZORUNLU** (yoksa ayak **kördür**): sunucu **başka bir çalışma dizininden**
   kaldırılır, `GET /` **200 DÖNMEMELİ** — `N4`'ün beyan ettiği bedelin **fiilen var olduğunu** yalnız
   bu ayak kanıtlar. 🔴 **El: Claude Code** (`K80` — Cowork ortamı kaldırmaz, ölçer).
   Üçü de ham çıktı olarak `KANIT/W3b/`'ye iner. **Kapatır:** `B-W3b-1`.

---

## 8. BEYAN EDİLMİŞ SINIRLAR — *"neyi ölçmüyoruz"*

1. 🔴 **DÜZELTİLDİ (o66) — bu satır v2'de *"hiçbir canlı HTTP ölçümü yok"* diyordu ve kilitle birlikte
   ÖLÜ BEYAN olacaktı.** Görev artık **tek bir canlı HTTP ölçümü taşır** (kabul kriteri 8: `GET /` ⇒ 200
   + `flutter_bootstrap.js` + **negatif kontrol**). 🔴 **TARAYICI ölçümü YİNE YOKTUR:**
   `crossOriginIsolated`, gerçek `main.dart.js` yürütmesi ve `--dart-define`'ın **çalışma anındaki**
   değeri **bu turda ÖLÇÜLMEZ** (`B-W3b-3` açık kalır; playwright Onur'un makinesinde **yok** —
   `B-O62-3`).
2. 🔴 **`W3/G43`–`G47` kapıları bu turda da YAZILMIYOR.** Kapsamları (*"YALNIZ `Program.cs`"*) bugünkü
   ürüne **kör**; düzeltme `W3` spec'inin sonraki sürümüne aittir. Bu görev **ayrı kimlikli** (`W3b/G48`–`G51`)
   kapılar yazar — `K108` gereği atıflar **daima kapsam öneklidir**.
3. 🔴 **`--no-web-resources-cdn`'in CI'da zorlanması bu turda YAPILMAZ** (`B-O63-2` açık kalır).
   `W3b/G51` kapıyı **yazar**; CI'ya bağlanması `D-A13-4` turundadır.
4. 🔴 **`gstatic`'in CORP politikası ölçülmez ve ölçülemez** — üçüncü taraftır. `D-W3b-3`'ün gerekçesi
   zaten *"o politikaya bağımlı kalmamak"*tır; kapı **bayrağın izini** ölçer, uzak sunucuyu değil.
5. 🔴 **Windows/NTFS dışında hiçbir ortamda ölçülmedi** ve `wwwroot` **CI'da yoktur** ⇒ `W3b/G50/f`
   orada **ORTAM HATASI** verir. CI'nın bu kapıyı build **sonrasında** koşup koşmayacağı `D-A13-4`'e aittir.
6. 🔴 **Kullanıcı verisi / OPFS seçimi bu görevin konusu DEĞİLDİR.** `ADR 0004` park edilmiştir.
7. 🔴 **`R8`'İN GETİRİSİ İNCEDİR — ölçüldü, Onur beyanla kabul etti (o66; `MJ11`'in kapanışı).**
   `radar.py`:41-42 ürün yolu `["src/","lib/","app/"]`, hariç `araclar/` ⇒ `T1` (`.gitignore`)
   **sayılmaz**, `T3`/`T4` (`araclar/*.py`) **hariç**, `T5` (`KANIT/**`) **sayılmaz**. Geriye **yalnız**
   `src/backend/Momentum.Api/appsettings.json`'daki **1–3 satır JSON** kalır; o yol `src/` altında
   olduğu için `R8` **teknik olarak söner**. 🔴 **Beyan: bu, `K53/4`'ün LAFZINA uyan ama RUHUNA ince
   gelen bir sönmedir.** Kapanış checkpoint'i sayıyı **ezberden yazmaz**, `radar.py --olc-urun-kodu <sha>`
   ile **git'ten ölçer** ve inceliği **yazılı** kaydeder. Alternatif (*spec'i genişlet*) **REDDEDİLDİ**:
   kilitlenmiş spec'i yeniden açmak `K127` denetimini de yeniden gerektirirdi.

---

## 9. NE ÖLÇÜLEMEDİ *(v1 yazımı sırasında)*

- **`flutter build web` bu ortamda koşmadı** — çıktının gerçek dosya listesi, `_BUILD.json`'un tam alan
  adları ve `W3b/G51/c`'nin pin değeri (**2**) `T3` koştuğunda **kesinleşir**; bugünkü değerler
  `KANIT/W3/02` ve `04`'ün **3.44.9** ölçümlerinden alındı (`B-W3b-3`, `B-W3b-4`).
- **`appsettings.json`'ın bugünkü tam içeriği** yalnız *"`Istemci` anahtarı yok"* diye ölçüldü; şema
  bütünü okunmadı.
- **`verify.ps1` Windows'ta hiç koşmadı** (`B-O62-2`) — kriter 6 bu yüzden **koşulludur**, iddia değildir.
- 🟢 **DÜZELTİLDİ (o66): bu satır ÖLÜ BEYANDI.** `spec-kapi-kapsama.py` bu dosyaya karşı o65'in denetim
  turunda **koştu** (**EXIT 0**) ve `kapi-ad-teklik-kapisi.py` **YEŞİL** verdi; ikisi o66'da kilitten
  **sonra yeniden** koşuldu — sayılar kapanış ölçümünden okunur, **ezberden yazılmaz**.

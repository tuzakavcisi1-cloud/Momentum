# W3 v2 — BAĞIMSIZ DENETİM TURU 2 (`K127`) — **v2 DÜŞTÜ**

**Koşum:** 6 Ağu 2026, oturum 60. **Denetlenen:** `GOREV-W3-capraz-koken-izolasyonu.md` v2
(`D0143461`, 32.712 b). **Üreten:** Cowork. **Denetleyen:** üç **bağımsız** ajan, üç ayrı mercek
(`K26` — üreten ≠ denetleyen). `K53/1` tavanı **aşılmadı**: bu **tek turdur**, üç ajan turun
*içindedir*.

| # | mercek | hüküm |
|---|---|---|
| D1 | Ölçülebilirlik / kör kapı | 🔴 **REDDET** |
| D2 | Olgusal doğrulama | 🟠 **DÜZELT** |
| D3 | Yapılabilirlik / red-team | 🔴 **REDDET** |

🔴 **HÜKÜM: v2 KİLİTLENEMEZ. v3 GEREKİR.**
🟢 **Turun değeri:** D2 ve D3 **fiilen iş koştu** — bir `flutter build web --no-web-resources-cdn`
(44,3 s), bir `flutter test`, üç headless Chrome koşumu, bir `dart run` derleme denemesi. Bulguların
çoğu **kâğıt muhakemesi değil, ölçüm**.

---

## A. ÜÇ AJANIN BİRDEN BULDUĞU (en yüksek güven)

### 🔴 B-1 — `MapHub` **0 değil 1**. §8/7 bir sınırı YANLIŞ ÖLÇÜMLE sildi
*(D1/BLOKER-5 · D2/MAJOR-3 · D3/MAJOR-1 — **üç yönlü yakınsama**)*

v2 §8/7: *"`Program.cs`'te `MapHub` **0** ölçüldü; olmayan bir şeyin sınırı yazılmaz."*
**Ölçülen:** `Program.cs:182` → `app.MapHub<SyncHub>("/hubs/sync"); // slice-2b2 D4: payload-less
realtime signal` · `:62` → `builder.Services.AddSignalR();` ⇒ `MapHub` = **1**.

🔴 Dosyanın kimliği (**8.662 b / sha8 `1E31F5B4`**) v2'nin `O1`'de kendi alıntıladığıyla **aynı** —
yani spec bu dosyayı **ölçtü** ve yine de **0** yazdı. **Bu, v1'i düşüren `B2` sınıfının birebir
tekrarıdır:** *"ölçüldü" damgalı bir iddia, ölçülünce tersi çıktı.* Bir "ölçüldü" yanlışsa
**hiçbiri güvenilmez** — v3'te tüm "ölçüldü" damgaları yeniden koşulmalıdır.

**Ürün sonucu:** `/hubs/sync` canlı bir uç nokta. `D-W3-4` CORP kapsamını yalnız `/v1/**` ve
`/health/**` üzerinden tanımlıyor, `G46/g` yalnız `POST /v1/sync`'i ölçüyor ⇒ **yeni başlık ara
katmanının SignalR'a ne yaptığı ölçülmüyor ve beyan da edilmiyor.** Üstelik kabul kriteri 6,
`ADR 0004`'ün *"COEP SignalR'ı etkiler mi"* alt-sorusunun **kapanmasını** şart koşuyor ⇒ spec aynı
anda hem *"SignalR yok"* diyor hem *"SignalR sorusunu ölç ve kapat"* diyor.

---

## B. İKİ AJANIN BULDUĞU

### 🔴 B-2 — `T5`, KABUL EDİLMİŞ `W2`'nin kapısını KIRIYOR (`flutter test` + CI kırmızı)
*(D2/BLOKER-3 · D3/BLOKER-5)*

`MOMENTUM-G6-KANIT` print'i ve `depolamaBildirimiYaz` çağrısı — ikisi de `K142`/`K144` ile
**PAZARLIKSIZ** kilitli (`D-W2-6`, `D-W2-8`) — `veritabani.dart:186-203`'te
`driftDatabase(… web: DriftWebOptions(… onResult: (sonuc) {…}))` **içinde** yaşıyor.
Onları ölçen kapı bir Flutter testidir ve **`onResult:` anahtar dizgesine** bağlıdır:
`w2_dikis_kapisi_test.dart:70-72` → `final anahtarIndex = yorumsuzKaynak.indexOf('onResult:');
if (anahtarIndex < 0) return null;`

`WasmDatabase.open`'ın **`onResult` parametresi YOKTUR** (`drift_flutter/web.dart:26` sonucu kendisi
işler). ⇒ `driftDatabase(` bırakılınca `onResult:` çapası **düşer**, **dört test** birden
*"ORTAM HATASI"* ile patlar.
**Bugünkü taban ölçüldü:** `flutter test` → `ExitCode=0`, `00:00 +4: All tests passed!`
**Sonuç:** `G47/d` **KIRMIZI** · kabul kriteri 5 **tatmin edilemez** · `.github/workflows/ci.yml`
**kırmızı**. v2 bu üçünün hiçbirini görmüyor.
🔴 **Daha ağırı:** `depolamaBildirimiYaz` çağrılmazsa `W2`'nin **kabul edilmiş görünür şeridi**
sessizce ölür ⇒ **`B1`'in ikinci kopyası, bu kez `W2`'de.**

### 🔴 B-3 — Kabul kriteri 1, `T0`'ın kendi hüküm tablosuyla ÇELİŞİYOR
*(D1/BLOKER-2 · D3/BLOKER-2)*

- `opfsShared`: §7/1 onu **KABUL** sayıyor; `D-W3-0` ve `T0` talimatı onu **DİLİM İPTAL** sinyali
  sayıyor.
- `sharedIndexedDb`: §7/1 *"görünüyorsa KABUL EDİLMEZ"* diyor; oysa `T0`'ın **tek ✅ başarı yolu**
  koşum 1 ve 2'de `sharedIndexedDb` görmeyi **gerektirir** (dilimin varlık sebebi `O2` budur).
  ⇒ **Doğru doldurulmuş her hüküm tablosu kriter 1'i düşürür.**
- Zamanlama: `T0`, `T5`'ten **önce** koşar ⇒ tablodaki `chosenImplementation` **hiçbir koşulda**
  ürünün son davranışını ölçemez. Kriter **yanlış artefaktı** ölçüyor.

---

## C. TEK AJANIN BULDUĞU — AMA FİİLEN ÖLÇÜLMÜŞ

### 🔴 B-4 — `T0` reçetesi ÇALIŞMIYOR: bayrak izolasyon vermiyor *(D3/BLOKER-1)*
`localhost:5111` (başlıksız), headless Chrome **151.0.7922.75**, `[crossOriginIsolated, typeof SharedArrayBuffer]`:

| koşum | sonuç |
|---|---|
| bayraksız | `false \| undefined` |
| `--enable-features=SharedArrayBuffer` | **`false \| function`** |
| `--enable-blink-features=SharedArrayBuffer` | **`false \| function`** |

Bayrak yalnız **yapıcıyı** geri getiriyor; `crossOriginIsolated` **başlıklardan** türer.
⇒ Talimatın kendi kuralı gereği koşum 2 **her seferinde `[ÖLÇÜLEMEDİ]`** olur ⇒ `D-W3-0` gereği
`T1`–`T10` **hiçbir zaman başlayamaz**. **Dilim kendi ön-koşulunda kilitleniyor.**
🟢 **D3 çalışan alternatifi ÖLÇTÜ:** iki başlığı gönderen 15 satırlık statik Python sunucusu,
**bayrak yok** → `SONUC = true | function`. Kanıt: `C:\temp\rt-w3\probe2.py`.

### 🔴 B-5 — `G45/d` TATMİN EDİLEMEZ: `fonts.gstatic.com` dersinin iki satır yukarıda uygulanmamış hâli *(D2/BLOKER-1)*
**Fiilen build koşuldu** (`flutter build web --no-web-resources-cdn`, 44,3 s, depo dışına):
`www.gstatic.com/flutter-canvaskit` → `flutter.js` **1** + `flutter_bootstrap.js` **1** = **2 KALIYOR**.
Sebep: `flutter.js` SDK'dan **bayt-özdeş** kopyalanıyor (SHA256 `A483FD28…` = `flutter_web_sdk/flutter_js/flutter.js`)
ve dizge bir **çalışma-zamanı dalında** gömülü:
`e.engineRevision&&!e.useLocalCanvasKit?I("https://www.gstatic.com/flutter-canvaskit",e.engineRevision):"canvaskit"`
Bayrak `useLocalCanvasKit`'i **çalışma zamanında** çevirir, **baytı çıkarmaz**.
🔴 v2 bu dersi `Y2`'de `fonts.gstatic.com` için **doğru öğrendi** ama **aynı mekanizmayı iki satır
yukarıdaki `G45/d`'ye uygulamadı** ⇒ kabul kriteri 2 tatmin edilemez.
⇒ **`M237` ÖLÜ MUTANT** (`D-W3-6` taksonomisi: kusur mutantta değil, **ayakta**).

### 🔴 B-6 — `WasmDatabase.open` VM'de DERLENMİYOR *(D3/BLOKER-4)*
`dart run --packages=<istemci package_config> …` →
`drift-2.34.3/lib/wasm.dart:10:8: Error: Dart library 'dart:js_interop' is not available on this platform.`
`veritabani.dart` VM'de derlenen bir dosyadır ⇒ `WasmDatabase.open(` oraya konursa **tüm test paketi
derlenmez** (`G47/d` + kriter 5 imkânsız). Koşullu import'a kaçılırsa çağrı **başka dosyaya** iner
⇒ `G47/a` kırmızı. **İki ayak birbirini dışlıyor.**
🔴 `D-W3-7`'nin beyan ettiği bedel (*"yol çözümü, mobil dallanma elle yazılır"*) **eksik**; gerçek
bedel **koşullu-import dosya bölmesidir** ve hiç yazılmamış. *(drift'in kendi mimarisi bunu
dayatıyor: `connect.dart:4-6` `export 'unsupported.dart' if (dart.library.js_interop) 'web.dart'
if (dart.library.ffi) 'native.dart';`)*

### 🔴 B-7 — `G47/c`, KABUL EDİLMİŞ `W1/G37/d` ile MANTIKEN ÇELİŞİYOR *(D2/BLOKER-2)*
`araclar/cors-kapisi.py:232-241` → `blok = _parantez_blogu_bul(kod, r"driftDatabase\(")` ·
`if blok is None: return False, "driftDatabase( cagrisi bulunamadi"`.
`W1/G37/d` dizgenin **VAR olmasını** şart koşuyor; `W3/G47/c` **YOK olmasını**. İkisi aynı anda
yeşil olamaz. Spec'te `cors-kapisi`/`G37`/`G42` dizgeleri **0 kez** geçiyor ⇒ v2, `K138` ile kabul
edilmiş bir kapıyı **haberi olmadan** kırmızıya çekiyor.

### 🔴 B-8 — Projenin KANONİK aracı v2'de **EXIT 1** veriyor — v1'e göre REGRESYON *(D1/BLOKER-1)*
`python araclar\spec-kapi-kapsama.py <W3-v2>` ⇒ **EXIT 1**, dokuz `[S2] MUTANTSIZ KURAL: … mutanti
da yok, BEYAN EDILMIS BORCU da yok` (`D-W3-0,1,2,3,5,6,7,8,10`). Araç **sıfır** borç okudu.
Sebep: aracın deseni `^\s*-\s*KURAL:\s*([^|]+)\|\s*GEREKCE:\s*(.*)$` (`:145`); v2'nin §6b'si
**dört alanlı `ID | KURAL | NEDEN | KAPATMA`** biçiminde ⇒ araca **görünmez**.
🔴 v1 bu aracı **GEÇİYORDU** (o60 raporu, `MAJOR-10`). Kabul edilmiş emsal `W2` de geçiyor
(`## 6b. MUTANT BORCU` + `- KURAL: D-W2-5 | GEREKCE: …`, EXIT 0).
**Ders: v2 kendi biçimini KENDİ yazdığı `_v2_olc.py` ile doğruladı — kanonik araçla değil.
Üreten ≠ denetleyen ilkesinin ÖLÇÜM KATMANINDAKİ ihlali.**

### 🔴 B-9 — `G46/e` KÖR AYAK **ve** `_v2_olc.py` bunu YANLIŞ-NEGATİF verdi *(D1/BLOKER-3)*
D1 kendi ayrıştırıcısını yazdı (`_denetci_kapsama.py`, **hedef sütununu** okuyor):
`TANIMLI AYAK = 32` · `HEDEF SÜTUNUNDA GEÇEN = 30` · `MUTANT HEDEFİ OLMAYAN = G46/e, G46/h`.
`G46/h`'nin borcu var (`B-W3-8`); **`G46/e`'nin ne mutantı ne borcu var** ⇒ spec'in **kendi §6b
kuralınca** BLOKER.
🔴 **Sebep benim betiğimde:** `_v2_olc.py:49` → `hedefler = set(re.findall(r"G4[3-7]/[a-h]", txt))`
— hedefleri **hedef sütunundan değil TÜM BELGEDEN** grepliyor. `G46/e` yalnız §9'da
(*"NE ÖLÇÜLEMEDİ"*) geçiyor ve betik onu **mutant hedefi sanıyor**.
**Bu, v1'in `B4` kusurunun (*"kapı kendi spec'ini ölçer"*) ölçüm aracının içinde yeniden
doğmuş hâlidir** — ve v2 §5 önsözü tam bu sınıfı kapattığını iddia ediyor.
⇒ **§6/§7-4'ün kanıt tabanı olarak `_v2_olc.py` çıktısı KULLANILAMAZ.**

### 🟠 B-10 — `O5` OLGUSAL OLARAK YANLIŞ *(D2/MAJOR-2)*
v2 `O5`: *"Bugünkü `chosenImplementation=` / `missingFeatures=` ham satırı **hiçbir belgede birebir
yazılı değil**."* **Ölçülen:** en az **8** belgede birebir var, ör.
`KANIT/W1/G37a-ilk-acilis-log-anlik.txt:17` →
`MOMENTUM-G6-KANIT chosenImplementation=WasmStorageImplementation.sharedIndexedDb missingFeatures={…}`
(ayrıca `_flutter_run_log.txt:17`, `G37b-ikinci-acilis-kaniti.txt:2,4`, `T6-M199-kaydi.md:14`,
`KANIT/slice-3b/07-G6/web-kalicilik-kaniti.txt:8` → **`opfsLocks`**).
🔴 `O5`, §1'in tek **kaynaksız** olgusuydu ve yanlış çıktı. `D-W3-0`/`K148` bu gerekçeyle **ayakta
duramaz**. 🟢 **Kararın kendisi kurtarılabilir, gerekçesi değişmeli:** mevcut alıntılar `:5000`
**izolasyonsuz** yolda alındı ⇒ izolasyon **sonrası** değeri ölçmüyorlar.

### 🟠 B-11 — Veri taşıması KOPYALAMIYOR, **TAŞIYOR: kaynağı SİLİYOR** *(D3/MAJOR-6)*
`drift/lib/src/web/wasm_setup/indexeddb_to_opfs.dart:71-77` →
`await existingVfs.close(); await IndexedDbFileSystem.deleteDatabase(databaseName);`
v2 `D-W3-7` *"kopyalanır"* diyor — **eksik beyan**. Kopyalama **atomik değil**; sekme yarıda
kapanırsa OPFS'te **kısmi** veritabanı kalır ve `_selectExistingDatabase` bir sonraki açılışta
OPFS'i *mevcut* sayıp oradan devam eder ⇒ **IndexedDB'deki sağlam kopya öksüz kalır**.
Spec'te ne yedek adımı, ne §8 sınırı, ne kapı/mutant var (`M240` yalnız kaynak metnindeki bayrağı
çeviriyor).

---

## D. KALAN MAJOR/MINOR (v3'te kapatılacak, özet)

| kod | bulgu | kaynak |
|---|---|---|
| `M-a` | `G45/c` **KÖR**: `canvaskit/*.wasm` bayrak**sız** build'de de var (6 `.wasm` ölçüldü) ⇒ *"yerelleştirme fiilen oldu"*u kanıtlayamaz | D2 |
| `M-b` | Kriter 6'nın aracı `araclar/adr-doldurulmus-mu.py` **diskte YOK** ve onu üreten `T` maddesi de yok | D1 · D3 |
| `M-c` | `T6`'nın *"altın küme içeriği §5'te pinli"* beyanı **YANLIŞ** — §5'te altın küme geçmiyor (v1 `M-14` kapanmamış) | D1 |
| `M-d` | §4c hazır-olma üçlüsü `G46/f`'nin Production koşumunda **tatmin edilemez** (`NullCurrentUser` ⇒ 401, 200 gelmez) | D1 |
| `M-e` | `G43/f`: *"dizinin sha'sı"* **tanımsız**; `core.autocrlf` aktif; `build/web` `.gitignore`'da ⇒ temiz klonda **hesaplanamaz** | D1 · D3 |
| `M-f` | `G47` *"statik"* etiketli ama `G47/d` süreç koşuyor; `4b`'de eli **atanmamış**; `ORTAM.md`'nin `flutter test` mayınları (`.bat` tam yolu + `PROGRAMFILES(X86)`) taşınmamış | D1 · D3 |
| `M-g` | `MW22` yaptırımsız: `fonts.gstatic.com` için **hiç kod içermeyen** kapı `MW22`'yi boş yere geçer | D1 |
| `M-h` | `G43` başlığı yedi ayağın **tümü** için `Program.cs` kapsamı ilan ediyor; `d`–`g` başka dosyaları ölçüyor | D1 |
| `M-i` | `4b` el dağılımı **12 mutantı sahipsiz** bırakıyor (`M217–M235` aralığı `M236`–`M245` + `MW21/22`'yi kapsamıyor) ve pahalı olanları yanlış ele veriyor | D3 |
| `M-j` | `D-W3-10` yaptırımı **yanlış ayağa** atıf yapıyor (`G45/e` yerine `G45/a` olmalı) | D3 |
| `MIN-1` | `veritabani.dart` **8.920 b** (spec 8.918 yazdı) | D2 |
| `MIN-2` | engine `configuration.dart` satır aralığı **361-362** (spec 362-368 yazdı; metin doğru) | D2 |
| `MIN-3` | aspnetcore satır no'ları **`main` dalında** tuttu ama spec dalı yazmıyor | D2 |
| `MIN-4` | `G44/h` *"üç blok"* şartı **yalnız yorum atıldıktan sonra** doğru (ham dosyada `:100` yorumu ile **dört**) | D3 |
| `MIN-5` | `verify.ps1` kökte değil → `araclar/verify.ps1` | D3 |
| `MIN-6` | `T8` koşucu sözleşmesi **dizin mutantlarını** (`M223`, `M236`) kapsamıyor — bayt yaması uygulanamaz | D3 |
| `MIN-7` | `4c` `ORTAM.md`'nin *"`clientId` geçerli GUID olmalı, yoksa 500"* mayınını taşımıyor | D3 |
| `MIN-8` | `G45` kapsamı `.wasm`'ı dışlıyor; `--wasm`'a geçilirse `G45/a` **sessizce körelir** | D2 |

---

## E. YANLIŞ-POZİTİFLER (v2'nin DOĞRU çıkan yerleri — v3'te bozulmasın)

- ✅ **K81 biçim standardı ve K126 sütun sırası UYUYOR.** `spec-kapi-kapsama.py` spec'i ayrıştırabildi;
  `[S0] BİÇİM` hatası **yok**. Kusur yalnız §6b **satır biçimindedir**.
- ✅ **v1'in `B4`'ü spec METNİNDE gerçekten kapatılmış** — beş kapı başlığının **beşi de** kapsam
  beyanı taşıyor. *(Ama kusur ölçüm aracına göç etti — `B-9`.)*
- ✅ **§6b'nin dört alanlı olduğu iddiası DOĞRU** — sekiz borcun sekizi de tam dört alan.
- ✅ **`O1` tamamen doğrulandı** — `Program.cs` 8.662 b / `1E31F5B4`; `UseStaticFiles`/`UseDefaultFiles`/
  `MapFallback*` = **0**; `wwwroot` **yok**; `AddMediator` = **1**.
- ✅ **`O2` satır numarasına kadar doğrulandı** — drift 2.34.3 `wasm.dart:163` `= false`;
  `drift_flutter 0.3.1` `web.dart:19` bayrağı geçirmiyor; `connect.dart:24,30,37,39` dört alan;
  `veritabani.dart:180,182`; `pubspec.lock:179,195` sürümler tuttu.
- ✅ **`O3` doğrulandı** — 5 canvaskit + roboto woff2 → **200**, `CORP: cross-origin`;
  MDN COEP *"requests made in `cors` mode won't be blocked by COEP"* **birebir**, *Mar 6, 2026*.
- ✅ **`D-W3-1` doğrulandı** — `FallbackEndpointRouteBuilderExtensions.cs:79` `Order = int.MaxValue`
  **birebir**; `EndpointComparer.cs:29-32` **birebir**.
- ✅ **`D-W3-8` doğrulandı** — MDN SharedArrayBuffer alıntısı **birebir**, *Feb 10, 2026*.
- ✅ **`D-W3-10` doğrulandı** — `main.dart:24-26` `defaultValue: 'http://10.0.2.2:5298'`;
  dart-define'sız build'in `main.dart.js:8187,8195`'inde dizge **fiilen var**.
- ✅ **`O4` doğrulandı** — chrome PATH'te yok, playwright yok, selenium yok, node `v24.18.0`, npx `11.16.0`.

---

## F. NE ÖLÇÜLEMEDİ *(üç ajanın birleşik listesi — BOŞ DEĞİL)*

1. **`T0`'ın kendisi** — tanım gereği koşmadı. v2/v3'ün tüm OPFS iddiaları ona koşulludur.
2. **Canlı `G46`'nın sekiz ayağının HİÇBİRİ** — backend kaldırılmadı (`K80`). Production koşumunun
   fiilen başlayıp başlamadığı **ÖLÇÜLMEDİ**.
3. **`--dart-define` ile build koşulmadı** ⇒ `G45/a`'nın **tatmin edilebilirliği ÖLÇÜLMEDİ**.
   🔴 dart-define verildiğinde varsayılan dizgenin dart2js çıktısından **tamamen düşüp düşmediği**
   bilinmiyor; düşmezse `G45/a` **`G45/d` ile aynı kadere düşer**. `T2`'nin ilk build'inde
   **kilitten önce** ölçülmeli.
4. **`/scalar/v1`'in `require-corp` altındaki davranışı** — `Program.cs:170`
   `app.MapScalarApiReference()` **her ortamda** haritalanıyor. Scalar.AspNetCore **2.16.15**
   içinde `.js`/`.html` varlığı **yok**, DLL'de `jsdelivr`/`unpkg`/`cdn.` dizgeleri **bulunamadı**
   ⇒ UI varlıklarının nereden geldiği **ÖLÇÜLEMEDİ**. Çapraz-köken bir `<script src>` (`no-cors`)
   kullanıyorsa **COEP onu bloklar** ve `verify.ps1`'in scalar testi bunu **görmez**.
   🔴 **Kilitten önce ölçülmeli.**
5. **`/hubs/sync`'in COOP/COEP + WebSocket yükseltmesi altındaki davranışı** (`B-1`'in fonksiyonel yarısı).
6. **31 mutantın hiçbiri** — `araclar/izolasyon-kapisi.py`, `araclar/_izolasyon_http_olc.py`,
   `KANIT/W3/_mutant_kosucu.py` **henüz yok**. Tüm kapı bulguları spec'in **lafzına** dayanıyor.
7. **`flutter_service_worker.js` `require-corp` altında** (`B-W3-4` borcu — üç ajan da ölçemedi).
8. **`B-2`'nin "dört test düşer" hükmü** test dosyasının **kaynağından** çıkarıldı, fiilen mutasyon
   koşularak değil.
9. **Headless ↔ headed Chrome farkı** — `B-4`'ün üç koşumu da `--headless=new` ile yapıldı.
10. **`docs/ADR/0004-*.md`'nin içeriği okunmadı** — yalnız var olduğu ölçüldü.
11. **aspnetcore `release/9.0`/`release/10.0` dallarında** satır no'ları ölçülmedi (yalnız `main`).
12. **`G44/c`'nin etki-alanı bulucusunun uygulanabilirliği** deneyerek ölçülmedi (prototip yazılmadı).

**Denetim artefaktları (depo DIŞINDA, `C:\dev\Momentum` değiştirilmedi):**
`C:\Users\gulci\AppData\Local\Temp\w3denetim` (ölçüm build'i) · `C:\temp\rt-w3\probe2.py`
(çalışan izolasyon probu) · `C:\dev\Momentum\KANIT\W3\_denetci_kapsama.py` (hedef sütunu ayrıştırıcı).

---

## G. HÜKÜM

🔴 **v2 REDDEDİLDİ — KİLİTLENEMEZ, v3 GEREKİR.**

**v3'ün açması gereken dört mimari soru** (biçim düzeltmesi değil, **karar** gerektirenler):
1. **`T5` nasıl yazılacak?** `WasmDatabase.open` VM'de derlenmiyor ⇒ **koşullu import + dosya
   bölmesi** şart. `W2`'nin `onResult` dikişi (`D-W2-6`/`D-W2-8`, PAZARLIKSIZ) yeni yolda
   **birebir korunmalı** ve `w2_dikis_kapisi_test.dart`'ın çapası **gerekçeli** güncellenmeli.
2. **`T0` nasıl ölçülecek?** Bayrak yolu **ölü**; başlık gönderen yerel sunucu **ölçülerek çalıştı**.
3. **`G45/d` ne olacak?** Tatmin edilemez ⇒ ya `G45/e` gibi **sayan-raporlayan** ayağa insin, ya
   kapsamı `flutter.js`'i **dışlasın** (ve bu beyan edilsin).
4. **SignalR + Scalar kapsama girecek mi?** İkisi de canlı, ikisi de COEP yüzeyinde, ikisi de
   ölçülmemiş.

🟢 **v3, v2'yi sıfırdan yazmaz:** §1'in `O1`–`O4`'ü, `D-W3-1`/`D-W3-8`/`D-W3-10`'un birincil kaynak
alıntıları ve §5'in kapsam disiplini **bağımsız olarak doğrulandı** — korunur.

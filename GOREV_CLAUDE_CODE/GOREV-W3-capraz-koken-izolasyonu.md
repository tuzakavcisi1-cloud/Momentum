# GOREV-W3 — Web Çapraz-Köken İzolasyonu + OPFS'e GEÇİŞ

**v2 — KİLİTLENMEDİ.** Cowork yazdı, oturum 60 (5 Ağu 2026). **Kilit Onur'dan gelir.**
Önceki dilim: `GOREV-W2` v3 (`K142`), **KABUL EDİLDİ** (`K144`). Bu dilim `W2`'nin **görünür
kıldığı** geri-düşüşü **onarır**.

🔴 **v1 `GEÇERSİZDİR`** (`61119601`). `K127` turunda **6 bloker + 14 major** ile düştü (`K146`).
v2 bunların **her birini adıyla** kapatır ya da **beyanlı borç** olarak yazar — sessiz geçen yok.

---

## 0. KİLİT ÖNCESİ BAĞIMSIZ DENETİM (`K127` — PAZARLIKSIZ)

| tur | ne zaman | çıktı yolu | durum |
|---|---|---|---|
| 1 | v1, kilitten ÖNCE | `KANIT/W3/00-DENETIM-o60.md` | ✅ **KOŞTU — v1 DÜŞTÜ** (6 bloker + 14 major) |
| 2 | v2, kilitten ÖNCE | `KANIT/W3/03-DENETIM-v2-o61.md` | 🔴 **HENÜZ KOŞULMADI** |

🔴 **Tur 2 `K53/1` tavanını AŞMAZ:** tavan *"birincisi **mimariyi değiştiren** bir bloker
bulduysa ikinci tur açılır"* der. Tur 1 **iki tane** buldu (`B1`: dilim hedefine ulaşmıyordu ·
`B2`: gerekçe olgusal olarak yanlıştı). Tur 2 **meşrudur ve zorunludur**.
🔴 **Tur 2'ye verilecek dosya kümesi GENİŞ olacak** — tur 1'in kendi eksiklik kritiği bunu istedi:
`KANIT/W1/`, `KANIT/W2/`, `.gitignore`, `veritabani.dart`, CI iş akışı, `araclar/izolasyon-kapisi.py`.
*(Tur 1'e yalnız dört dosya verildi; raporun "doğrulanamadı" listesi bunun doğrudan bedeliydi.)*

---

## 1. NEDEN — ölçülmüş bağlam

🔴 **v1'in §1'i kısmen YANLIŞTI. Aşağıdaki beş olgunun HER BİRİ ölçülmüştür ve kaynağı yazılıdır.**

**O1 — `Momentum.Api` web istemcisini SUNMUYOR.** `Program.cs` (**8.662 b**, sha8 `1E31F5B4`):
`UseStaticFiles` **0**, `UseDefaultFiles` **0**, `MapFallback*` **0**, `wwwroot` dizini **YOK**.
Pozitif kontrol: `AddMediator` **1** (tarayıcı kör değil). ⇒ COOP/COEP'i yalnız API'ye eklemek
**işe yaramaz**: `crossOriginIsolated` **belgeyi getiren yanıtın** başlıklarıyla belirlenir.
*(v1'de de vardı, bağımsız denetimde **doğrulandı**.)*

**O2 — 🔴 DİLİMİN ASIL SEBEBİ: drift mevcut veritabanını TAŞIMIYOR.** `drift 2.34.3`
`lib/wasm.dart` `WasmDatabase.open`, birebir:
```
bool moveExistingIndexedDbToOpfs = false,        // <- VARSAYILAN
...
if (!didMove) {
  selectedImplementation = availableImplementations.firstWhere((e) => e.storageApi == currentDb);
}
```
Kaynaktaki yorum: *"If we have an existing database in storage, we want to keep using that format
to avoid data loss."* `drift_flutter 0.3.1` `lib/src/web.dart:19` bu bayrağı **geçirmiyor** ve
`DriftWebOptions`'ın alanları yalnız `sqlite3Wasm` · `driftWorker` · `onResult` ·
`initializeDatabase` ⇒ **geçirecek alan YOK**.
🔴 **Ölçüldü:** `src/client/lib/veri/veritabani.dart` **8.918 b**, satır **180-182**:
`return driftDatabase( name: 'momentum', web: DriftWebOptions(` ⇒ proje **tam o yolda**.
⇒ **Sunucu tarafı kusursuz olsa bile drift `sharedIndexedDb`'de KALIR.** Bu yüzden bu dilim
**istemci kodu değişikliği İÇERMEK ZORUNDADIR** (`D-W3-7`) — v1 bunu içermiyordu ve bu yüzden
*"kapılar yeşil, ürün ölü"* bitirecekti.

**O3 — 🔴 v1'in *"çapraz-köken alt-kaynaklar bloklanır"* iddiası YANLIŞTI.** Canlı ölçüm
(2026-08-05, dokuz istek, hepsi HTTP/2 **200**): `www.gstatic.com/flutter-canvaskit/*`
(`canvaskit.js`, `canvaskit.wasm`, `skwasm.js`, `skwasm.wasm`, `chromium/canvaskit.js`) **ve**
`fonts.gstatic.com/s/roboto/*.woff2` — **hepsi `cross-origin-resource-policy: cross-origin`**
gönderiyor. MDN COEP (*son değişiklik Mar 6, 2026*), birebir: *"Note that requests made in `cors`
mode won't be blocked by COEP or trigger COEP violations, but must still be permitted by CORS."*
⇒ CanvasKit/font yerelleştirmesi **zorunlu onarım DEĞİL**, **isteğe bağlı sertleştirmedir**
(`D-W3-3`) ve **kritik yoldan ÇIKARILMIŞTIR**. *(v1'de kritik yoldaydı ve `G45/a`'yı tatmin
edilemez yapıyordu.)*

**O4 — Gerçek tarayıcı ölçüm aracı bu makinede YOK.** `playwright` YOK · `selenium` YOK ·
`chrome` PATH'te YOK (`node v24.18.0`, `npx 11.16.0` var). `ORTAM.md`: `flutter test --platform
chrome` **sonuç üretmiyor** (iki ölçüm: 7 dk ve 9,8 dk). ⇒ Ölçüm katmanı `D-W3-5`'te; tarayıcı
ayağı **`T0`'da ELLE**, bir kez, kayda geçerek koşulur.

**O5 — TEŞHİS HENÜZ ALINTILANMADI.** Bugünkü `chosenImplementation=` / `missingFeatures=` ham
satırı hiçbir belgede **birebir** yazılı değil. `missingFeatures` `workerError` ya da
`fileSystemAccess` içeriyorsa **izolasyon tek başına hiçbir şeyi değiştirmez**. ⇒ `T0` bunu ölçer;
`T0` yeşil gelmeden **build başlamaz** (`K148`).

---

## 2. KAPSAM

**İÇERİDE:** ① `T0` ön-koşul ölçümü ② `Momentum.Api`'nin web build çıktısını **aynı kökenden**
sunması ③ COOP/COEP'in **her ortamda** gönderilmesi ④ **istemci depolama kararının OPFS'e
taşınması** (`D-W3-7`) ⑤ statik + canlı HTTP kapıları ⑥ `ADR 0004` gövdesinin **ölçülmüş**
yanıtlarla yazılması.

**DIŞARIDA, gerekçeli:**
- **Otomatik tarayıcı ölçümü** — araç yok (`O4`). `T0` **elle** koşar ve **tekrarlanabilir
  değildir**; borç `B-W3-1`. Kapatma yolu Playwright'tır ve **bu dilimde yapılmaz**.
- **Üretim dağıtımı / CDN topolojisi** — bu depoda dağıtım hedefi yok; karar `ADR 0004` gövdesine.
- **Service worker / PWA** — `flutter_service_worker.js` üretiliyor; `require-corp` altındaki
  davranışı **[ÖLÇÜLMEDİ]**, bu dilim ona dokunmaz (§8/3).
- **Mobil istemci** — Android/iOS belge yükü taşımaz, COEP/CORP uygulanmaz. Ölçülmez, **iddia da
  edilmez**. 🔴 Ama `D-W3-7` **paylaşılan koda** dokunur ⇒ mobilin bozulmadığı `G47/d` ile ölçülür.
- **`W1`'in `flutter run -d chrome --web-port=5000` akışı** — kaldırılmaz; `D-W3-2`'de kapsamı
  **açıkça** yazılır (v1'de yazılmamıştı, `MAJOR-3`).

---

## 3. KARARLAR

### D-W3-0 — `T0` ÖN-KOŞULDUR: ölçüm yeşil gelmeden BUILD BAŞLAMAZ
🔒 **`K148` (Onur, oturum 60):** `K147`'nin *"önce ölç"* kilidi **kaldırılmadı, YERİ DEĞİŞTİ** —
ölçüm artık spec yazmanın değil **build'in** önündedir. `T0` üç koşumu
(`KANIT/W3/01-OLCUM-TALIMATI-o61.md`) koşulur, sonuç `02-OLCUM-SONUC-o61.md`'ye yazılır.
**Hüküm tablosundan `opfsShared` satırı çıkarsa bu dilim İPTAL edilir** ve `ADR 0004` bunu kaydeder.
🔴 `T0`'ı **Onur ya da Claude Code** koşar — **Cowork DEĞİL** (`K80`).

### D-W3-1 — API, web build çıktısını AYNI KÖKENDEN sunar
`wwwroot` → `UseDefaultFiles()` + `UseStaticFiles()` + `MapFallbackToFile("index.html")`.
🔴 **v1'in *"sıra PAZARLIKSIZ"* GEREKÇESİ YANLIŞTI ve KALDIRILDI** (`Y1`): `dotnet/aspnetcore`
`FallbackEndpointRouteBuilderExtensions.cs:79` — `((RouteEndpointBuilder)b).Order = int.MaxValue;`
ve `Matching/EndpointComparer.cs:29-32` uç nokta seçimini **kayıt sırasına değil `Order`'a** bağlar
⇒ `MapFallbackToFile` **hiçbir kayıt sırasında** API'yi yutamaz; desen ayrıca `{*path:nonfile}`'dır.
**GERÇEK risk** `MapFallbackToFile` yerine **düşük `Order`'lı bir yakala-hepsi rota** yazmaktır
(`app.Map("/{**path}", …)`, `Order = 0`) — `M224` **artık onu** hedefler.

### D-W3-2 — COOP/COEP HER ORTAMDA etkindir (🔒 Onur kilitledi, oturum 60)
`Cross-Origin-Opener-Policy: same-origin` + `Cross-Origin-Embedder-Policy: require-corp`,
**hiçbir ortam koşulu OLMADAN**, tüm yanıtlarda. Değerler **TAM EŞİTLİKLE** ölçülür,
**alt-dizgeyle DEĞİL** (`MAJOR-2`: `same-origin-allow-popups` alt-dizge olarak `same-origin`
içerir ama **izolasyon vermez**).
🔴 **KAPSAM (v1'de yazılmamıştı, `MAJOR-3`):** kanonik web koşum yolu bu dilimden sonra
**`:5298`/`wwwroot`**'tur. `W1`'in `flutter run -d chrome --web-port=5000` akışı **geliştirme
kolaylığı için durur ama İZOLE DEĞİLDİR** ve bu **beyan edilmiştir** — o yolda `sharedIndexedDb`
görülmesi **kusur değildir**.
**Ölçülmüş gerekçe (kapsam ayrımı neden yok):** `W1`'in *"CORS yalnız Development"* kararı bağımsız
denetimde **bloker** çıktı (`B-W1-5`: mutantsız **ve** kapısız). Ayrıca kalıcılık **ürünün
davranışıdır**: Development'ta OPFS, üretimde IndexedDB olsaydı **iki farklı ürün** test edilirdi.

### D-W3-3 — CanvasKit yerelleştirmesi: SERTLEŞTİRME, kritik yol DEĞİL
Web build `--no-web-resources-cdn` ile üretilir. 🔴 **Gerekçe `O3` ile DÜZELTİLDİ:** bu, COEP
bloklamasını önlemek için **gerekli değildir** (gstatic `CORP: cross-origin` gönderiyor); değeri
**çevrimdışı çalışabilirlik ve tedarik-zinciri yüzeyinin daralması**dır.
🔴 **`fonts.gstatic.com` KIRMIZI VERMEZ.** Flutter engine `configuration.dart:362-368` birebir:
`String get fontFallbackBaseUrl => _configuration?.fontFallbackBaseUrl ?? 'https://fonts.gstatic.com/s/';`
⇒ dizge **motorda derlenmiş sabittir**, bayrak onu çıkarmaz. `G45` bunu **ölçer ve RAPORLAR**,
kırmızı vermez (`Y2`: v1'de kırmızı veriyordu ve kabul kriterini **tatmin edilemez** kılıyordu).

### D-W3-4 — CORP: YALNIZ `wwwroot` STATİKLERİNE
`Cross-Origin-Resource-Policy: same-origin` **yalnız statik dosya yanıtlarına** yazılır;
`/v1/**` ve `/health/**` yanıtlarına **YAZILMAZ**. 🔴 v1 bunu **söylemeden** genel yapıyordu
(`MAJOR-8`); zararsızdı ama **bilinçli değildi**. `G46/g` bu ayrımı **ölçer**.

### D-W3-5 — ÖLÇÜM KATMANI: HTTP + bir kerelik ELLE tarayıcı ölçümü
Kapılar **yeni bağımlılık KULLANMAZ**: statik tarama (Python) + canlı HTTP (`urllib`).
🔴 **BEYAN EDİLMİŞ SINIR:** `T0` dışında *"Chrome `crossOriginIsolated` oldu ve drift `opfsLocks`
seçti"* iddiası **OTOMATİK OLARAK ÖLÇÜLMEZ**; `T0` **elle**, **bir kez** koşar ve
**regresyonu yakalamaz**. Borç `B-W3-1`.

### D-W3-6 — Mutant `hedef` sütunu BEKLENENDİR — ÜÇ sınıflı taksonomi
🔴 v1'de **iki** sınıf vardı ve `Y1` bunun **eksik** olduğunu gösterdi. Kanonik taksonomi:
- `gözlenen ⊇ hedef` ⇒ **AŞIRI-YAKALAMA**, kusur DEĞİL ⇒ **ERRATUM** (`K145` emsali).
- `gözlenen ⊉ hedef` ⇒ **KÖR KAPI** ⇒ **BLOKER**, kusur **kapıdadır**.
- 🆕 `gözlenen = {}` (mutant hiçbir kapıyı düşürmedi) ⇒ **ÖLÜ/EŞDEĞER MUTANT** ⇒ kusur
  **MUTANTTADIR**, kapı suçlanmaz; mutant **değiştirilir**, spec yeniden açılmaz.

### D-W3-7 — 🔴 İSTEMCİ: `driftDatabase()` BIRAKILIR, `WasmDatabase.open` DOĞRUDAN ÇAĞRILIR
`O2`'nin **tek** çözümü budur: web yolunda
`WasmDatabase.open(databaseName: 'momentum', sqlite3Uri: …, driftWorkerUri: …,
moveExistingIndexedDbToOpfs: true)`.
🔴 **Bu kararın bedeli beyan edilir:** `drift_flutter`'ın sağladığı kolaylıklar (yol çözümü,
yerel/mobil dallanma) **elle yazılır**; mobil/masaüstü yolu **değişmez** ve bunun bozulmadığı
`G47/d` ile ölçülür. 🔴 **Veri taşınması geri alınamaz** — kullanıcı verisi IndexedDB'den OPFS'e
kopyalanır; `T0`'ın üçüncü koşumu bu yüzden **temiz kökende** (`:5001`) yapılır.

### D-W3-8 — GÜVENLİ BAĞLAM: sayfa yalnız `localhost` ya da HTTPS'ten açılır
MDN `SharedArrayBuffer` (*son değişiklik Feb 10, 2026*), birebir: *"To use shared memory your
document must be in a **secure context** and cross-origin isolated."*
⇒ `http://localhost:5298` güvenli bağlamdır, `http://192.168.x.x:5298` **DEĞİLDİR**. Başka
host/IP'den yapılan her ölçüm **`[ÖLÇÜLMEDİ]`** sayılır. *(v1'de bu şart **hiç geçmiyordu** —
`MAJOR-1`.)*

### D-W3-9 — BAŞLIK ARA KATMANI `UseStaticFiles`'TAN ÖNCE, BAŞLIKLARI `next`'TEN ÖNCE YAZAR
`UseStaticFiles` yanıtı **kısa devre eder**; sonra kaydedilen bir başlık ara katmanı
`index.html`'e **hiç yazmaz** ve `G44`'ün tamamı yeşil kalır (`MAJOR-2`). Aynı şekilde başlıklar
`await next(context)`'ten **sonra** yazılırsa yanıt başlamış olur ve atama **sessizce kaybolur**.

### D-W3-10 — BUILD, SUNUCU ADRESİNİ AÇIKÇA GEÇİRİR
Web build `--dart-define=SENKRON_SUNUCU_URL=<aynı köken>` ile üretilir.
🔴 **Ölçülmüş gerekçe (`B3`):** `_senkronSunucuUrl` varsayılanı **`http://10.0.2.2:5298`**
(Android emülatör takma adı, `W1` §2'de ölçüldü) ve `W1`'in `M197`'si bunu bir kez yakalamıştı.
v1'in `T2` komutu bu bayrağı **taşımıyordu** ⇒ web sayfası izole yüklenir, **her senkron isteği
düşerdi** ve 14 mutantın hiçbiri bunu görmezdi. `G45/e` artık ölçüyor.

---

## 4. YAPILACAKLAR

| # | iş | dosya / komut |
|---|---|---|
| **T0** | 🔴 **ÖN-KOŞUL ÖLÇÜMÜ** — üç `flutter run` koşumu; `crossOriginIsolated` + `MOMENTUM-G6-KANIT` satırı **birebir** kaydedilir | `KANIT/W3/01-OLCUM-TALIMATI-o61.md` → `02-OLCUM-SONUC-o61.md` |
| `T1` | `wwwroot` dizini + `.gitignore` girdisi (**tam yol**, çıplak desen değil) | `src/backend/Momentum.Api/wwwroot/` · `.gitignore` |
| `T2` | Web build + kopyalama betiği. Komut: `flutter build web --no-web-resources-cdn --dart-define=SENKRON_SUNUCU_URL=<aynı köken>` ⇒ çıktı `wwwroot`'a; betik `wwwroot/_BUILD.json`'a **kaynak sha + zaman damgası** yazar | `araclar/web-yayina-al.py` |
| `T3` | Başlık ara katmanı: COOP/COEP (her yanıt) + CORP (**yalnız statikler**); `UseStaticFiles`'tan **ÖNCE**, başlıklar `next`'ten **ÖNCE** (`D-W3-9`) | `Program.cs` |
| `T4` | `UseDefaultFiles` + `UseStaticFiles` + `MapFallbackToFile("index.html")` | `Program.cs` |
| **T5** | 🔴 **ÜRÜN KODU ÇEKİRDEĞİ:** web yolunda `driftDatabase()` bırakılır, `WasmDatabase.open(..., moveExistingIndexedDbToOpfs: true)` çağrılır; mobil/masaüstü yolu **değişmez** | `src/client/lib/veri/veritabani.dart` |
| `T6` | Statik kapı + **altın küme** (içeriği §5'te adıyla pinli) | `araclar/izolasyon-kapisi.py` |
| `T7` | Canlı HTTP kapısı; **iki ortamda** koşar (`Development` **ve** `Production`) | `araclar/_izolasyon_http_olc.py` |
| `T8` | Mutant koşucusu (ikili yedek + bayt düzeyinde yama + sha doğrulaması) | `KANIT/W3/_mutant_kosucu.py` |
| `T9` | `ADR 0004` gövdesi **ölçülmüş** yanıtlarla; alt-soru 1·2·3 kapanır, 4·5 borç kalır | `docs/ADR/0004-*.md` |
| `T10` | Ham çıktılar + kabul hükmü | `KANIT/W3/` |

### 4b. EL DAĞILIMI 🔴 *(v1'de YOKTU — `B6`; `W1` §4c'nin eşdeğeri)*

| iş | KİM koşar | gerekçe |
|---|---|---|
| `T0` üç tarayıcı koşumu | **Onur ya da Claude Code** | `K80` — Cowork ortam kaldırmaz; `flutter run` uzun ömürlü süreçtir, köprü sahiplenemez |
| `T1`–`T9` build | **Claude Code** | rol bölümü (`CLAUDE.md`) |
| Statik kapılar + altın küme koşumu | **Cowork** | `K26` — üreten ≠ denetleyen; Code'un beyanı kanıt değil |
| `M217`–`M235` mutant koşumu | **Cowork** (statikler) · **Claude Code** (backend yeniden başlatma isteyenler: `M220`–`M224`, `M230`) | `K80`: backend'i Cowork **başlatmaz** |
| Canlı `G46` (iki ortam) | **Claude Code** ya da Onur; **Cowork ÖLÇER, kaldırmaz** | `ORTAM.md`: *"Kapatmayı Cowork YALNIZ Onur'un açık izniyle yapar; YENİDEN BAŞLATMAZ"* |
| `verify.ps1` | **Claude Code**, backend **kapatıldıktan** sonra | `ORTAM.md`: çalışan `Momentum.Api` varken `verify.ps1` **EXIT 1** verir |
| Kabul hükmü | **Cowork** | `K26` |

### 4c. ORTAMI KİM KALDIRIR (`K80` — bu spec kendi maddesini TAŞIR)
① `docker start momentum-postgres` → `healthy` görünene kadar **yoklanır** (tavanlı; sabit `sleep`
**bir ölçüm değildir**) ② backend ayrı pencerede, `ORTAM.md` reçetesiyle — `ASPNETCORE_ENVIRONMENT`
· `ASPNETCORE_URLS` · `ConnectionStrings__Momentum` **açıkça** set edilir (verilmezse host **DB'siz
açılır**, port yine dinler) ③ hazır olma **portla değil** şu üçlüyle ölçülür:
`/health/live` **200** · `/health/ready` **200** · `POST /v1/sync` **başlıksız 401 VE
`X-Momentum-Dev-User` ile 200**.
🔴 **Üçlünün ikinci yarısı PAZARLIKSIZDIR** — v1 onu düşürmüştü (`B6-ek`): kısaltılmış üçlü
`Production`'da da geçer (`NullCurrentUser` ⇒ 401) ve **canlı koşumun hangi ortamda yapıldığını
ölçemez hâle getirir**.
🔴 Sıra: canlı ölçüm (backend ÇALIŞIR) → backend **kapatılır** (`netstat -ano | findstr :5298`
**boş** dönmeli, **ölçülür**) → `verify.ps1`.

---

## 5. KAPILAR

> 🔴 **Her ayak NASIL ölçüldüğünü yazar; yazmayan ayak KÖRDÜR.** Mutantı olmayan her ayak/kural
> `## 6b`'de **gerekçesiyle** beyan edilir. *(v1'de bu önsöz yoktu — `MAJOR-4`/`MAJOR-9`.)*
> 🔴 **KAPSAM PAZARLIKSIZ:** her ayak hangi **dosya/dizin** üzerinde çalıştığını yazar. `.md`
> dosyaları ve `KANIT/**` **her ayakta dışlanır** — v1'de `G44`'ün kapsamı yazılmamıştı ve kapı
> **kendi spec'ini** ölçüp dört mutantı öldürüyordu (`B4`).

### G43 — API web'i AYNI KÖKENDEN sunuyor (statik; kapsam: `src/backend/Momentum.Api/Program.cs`)
- **a)** `UseStaticFiles(` **VAR** (dizge; yorumlar atılmış metinde).
- **b)** `UseDefaultFiles(` **VAR** ve satır numarası `UseStaticFiles`'ınkinden **KÜÇÜK**.
- **c)** `MapFallbackToFile(` **VAR** ve argümanı `index.html`.
- **d)** `wwwroot/index.html` **diskte VAR** **ve** içinde `flutter_bootstrap.js` **referansı**
  geçiyor (yer tutucu bir dosya bu ayağı geçemez — `MAJOR-9`).
- **e)** `.gitignore` **`src/backend/Momentum.Api/wwwroot/`** tam yolunu içeriyor (çıplak `wwwroot`
  deseni **KABUL EDİLMEZ** — `MINOR-5`). 🔴 Bu ayak **yokluk değil varlık** ölçer; yine de
  `ORTAM.md`'nin `findstr` dersi gereği aynı dosyada bilinen bir dizge (`bin/`) **pozitif kontrol**
  olarak aranır.
- **f)** `wwwroot/_BUILD.json` **VAR** ve içindeki kaynak sha, `src/client/build/web`'in **bugünkü**
  sha'sıyla **TUTUYOR** (bayat build üstünde yeşil kabul engellenir — `MAJOR-13`).
- **g)** 🔴 `wwwroot` **YOKSA** kapı **`ORTAM HATASI`** verir (çıkış 3) — **YEŞİL DEĞİL, ATLAMA
  DEĞİL** (`MAJOR-5`/`MAJOR-9`: temiz klonda/CI'da sessiz yeşil **kör kapıdır**).

### G44 — COOP/COEP/CORP başlıkları (statik; kapsam: **YALNIZ** `Program.cs`)
- **a)** `Cross-Origin-Opener-Policy` **VAR** ve değeri **TAM EŞİTLİKLE** `same-origin`
  (`same-origin-allow-popups` **REDDEDİLİR** — `MAJOR-3`).
- **b)** `Cross-Origin-Embedder-Policy` **VAR** ve değeri **TAM EŞİTLİKLE** `require-corp`.
- **c)** 🔴 Başlıkları yazan satırların **hiçbiri** bir **ortam-koşullu yapının** etki alanında
  değil. Aranan yapılar (v1 yalnız `IsDevelopment()` bloğunu arıyordu ve **dört yazımla** geçiliyordu
  — `B5`): `IsDevelopment` · `IsProduction` · `IsStaging` · `IsEnvironment` · `EnvironmentName` ·
  `UseWhen` · `MapWhen` · **ternary (`?`/`:`) aynı satırda** · `Configuration.GetValue`/`GetSection`
  ile okunan bir bayrağın koşulu.
- **d)** 🔴 **BAŞLIK YAZAN BAŞKA DOSYA YOK:** `src/backend/**/*.cs` içinde `Program.cs` **dışında**
  `Cross-Origin-` dizgesi geçmiyor (ayrı sınıfa taşıma kaçağı — `B5`/④).
- **e)** `Cross-Origin-Resource-Policy` **VAR** ve değeri `same-origin`.
- **f)** 🔴 Başlık bloğunun satır numarası `UseStaticFiles`'ınkinden **KÜÇÜK** (`D-W3-9`, `MAJOR-2`).
- **g)** 🔴 Kapı `//` **ve** `/* */` yorumlarını **satır sayısını KORUYARAK** atar (yorumu boşlukla
  değiştirir — `MINOR-3`: satır silmek `c` ve `f`'nin satır aritmetiğini bozar) ve bunu bir
  **pozitif kontrolle** kanıtlar.
- **h)** 🔴 **POZİTİF KONTROL:** kapı `Program.cs`'te en az **üç** `IsDevelopment()` bloğu bulmalıdır
  (bugün `:49`, `:102`, `:115`'te ölçüldü); bulamazsa **`ORTAM HATASI`** verir — *"aralık bulucu
  sıfır blok buldu"* ile *"temiz"* ayrılır (`MAJOR-7`).

### G45 — Build çıktısı (statik; kapsam: `wwwroot/**` içinde `.js`, `.mjs`, `.html`, `.json`)
- **a)** 🔴 **`10.0.2.2` dizgesi YOK** (`D-W3-10`, `B3`). Şema aranmaz — kaçak `http://`'tir.
- **b)** **POZİTİF KONTROL:** aynı taramada `flutter_bootstrap.js` **bulunur, boş değildir** ve
  içinde `_flutter` dizgesi **geçer**; geçmezse kapı **KIRMIZI** (*"aradım bulamadım"* ≠ *"aramadım"*).
- **c)** `wwwroot/canvaskit/` **VAR** ve içinde en az bir `.wasm` (yerelleştirme **fiilen** oldu).
- **d)** `www.gstatic.com/flutter-canvaskit` dizgesi **YOK** (`D-W3-3` sertleştirmesi fiilen koştu).
- **e)** 🔴 `fonts.gstatic.com` **ÖLÇÜLÜR ve RAPORLANIR, KIRMIZI VERMEZ** (`D-W3-3`/`Y2`; motor
  sabiti, bayrakla çıkarılamaz). Kapı sayıyı yazar; §8/2 borcu bununla **canlı** kalır.
- 🔴 **`G45` YOKLUK ÖLÇEN HER AYAĞI (`a`, `d`) `b`'nin pozitif kontrolüne BAĞLIDIR** — `b` kırmızıysa
  `a` ve `d`'nin yeşili **hükümsüzdür**.

### G46 — CANLI HTTP (backend ayakta; kapsam: `http://localhost:5298`)
- **a)** `GET /` → **200** **ve** `Cross-Origin-Opener-Policy: same-origin` **ve** gövde
  `flutter_bootstrap.js` içeriyor (404 da izole olabilir — `MINOR`; v1 durum kodu ölçmüyordu).
- **b)** `GET /` → `Cross-Origin-Embedder-Policy: require-corp`.
- **c)** `GET /sqlite3.wasm` → **200** · `Cross-Origin-Resource-Policy: same-origin` ·
  `Content-Type: application/wasm`. Aynısı `GET /drift_worker.js` için (tip: `text/javascript`).
- **d)** `POST /v1/sync` **başlıksız 401** (HTML **değil**) **ve** `X-Momentum-Dev-User` ile
  **200** ⇒ `K61` kalkanı canlı, fallback API'yi yutmuyor.
- **e)** `GET /bilinmeyen-rota` → **200** + `index.html`. 🔴 **Beyan:** `{*path:nonfile}` gereği
  `/bilinmeyen.rota` **404** döner; bu ayak **uzantısız** yolları ölçer (`MINOR-3`).
- **f)** 🔴 **AYNI ÖLÇÜM `ASPNETCORE_ENVIRONMENT=Production` İLE DE KOŞAR** ve `a`–`c` **aynen**
  geçer. *(v1'de canlı katman yalnız Development'ta koşuyordu ⇒ "her ortamda" iddiası **mantıken
  yanlışlanamıyordu** — `B5`.)*
- **g)** 🔴 `POST /v1/sync` yanıtında `Cross-Origin-Resource-Policy` **YOK** (`D-W3-4` kapsamı).
- **h)** `GET /health/live` → **200**; `Content-Type` **ölçülür ve kaydedilir** — beklenen değer
  **iddia edilmez** (`MAJOR-8`: ASP.NET varsayılanı `text/plain`'dir ve bunu değiştirmek `§2`
  kapsamı dışıdır).

### G47 — İSTEMCİ depolama kararı (statik; kapsam: `src/client/lib/**`)
- **a)** `veritabani.dart`'ta `WasmDatabase.open(` **VAR**.
- **b)** Aynı çağrıda `moveExistingIndexedDbToOpfs: true` **VAR**.
- **c)** Web yolunda `driftDatabase(` **YOK** (kaçak: eski yol bırakılmadan yenisi eklenirse
  hangisinin koştuğu belirsizleşir). **POZİTİF KONTROL:** dosyada `DriftWebOptions`'ın kalan
  kullanımları ya da `sqlite3Uri` dizgesi bulunmalı.
- **d)** 🔴 Mobil/masaüstü yolu **BOZULMADI:** `flutter test` **EXIT 0** ve `flutter analyze
  --fatal-infos` **EXIT 0** (`D-W3-7`'nin beyan edilmiş bedeli bu ayakla ölçülür).

---

## 6. MUTANTLAR — kapıların ISIRDIĞININ KANITI

> `D-W3-6` taksonomisi geçerlidir: `gözlenen ⊇ hedef` ⇒ **ERRATUM** · `gözlenen ⊉ hedef` ⇒
> **BLOKER** · `gözlenen = {}` (beklenirken) ⇒ **ÖLÜ MUTANT**, kusur mutanttadır.
> 🔴 **`SUSMALI` mutantlar** (`MW`) tersini ölçer: **hiçbir kapı düşmemelidir**; düşerse kapı
> **sahte-pozitif** üretiyordur ve bu **BLOKER**'dır.
> 🔴 **KOŞUM DİSİPLİNİ (`K118`):** her mutant **ikili yedek** → **bayt düzeyinde yama** →
> kapı koşumu → **geri yükleme** → **sha doğrulaması**. Yamanın **fiilen uygulandığı**
> ölçülmeden koşum geçersizdir (*"yama tutmadı, kapı yeşil kaldı"* ≠ *"kapı kör"*).

| # | mutant | hedef (beklenen KIRMIZI) | maliyet |
|---|---|---|---|
| `M217` | `UseStaticFiles(` satırı silinir | `G43/a` | ucuz |
| `M218` | `UseDefaultFiles()` `UseStaticFiles`'tan **sonraya** taşınır | `G43/b` | ucuz |
| `M219` | `MapFallbackToFile("index.html")` → `("bulunamadi.html")` | `G43/c` | ucuz |
| `M220` | `wwwroot/index.html` **yer tutucu** dosyayla değiştirilir (`flutter_bootstrap.js` referansı yok) | `G43/d` | ucuz |
| `M221` | `.gitignore`'daki tam yol → çıplak `wwwroot` deseni | `G43/e` | ucuz |
| `M222` | `wwwroot/_BUILD.json` içindeki kaynak sha bozulur | `G43/f` | ucuz |
| `M223` | `wwwroot` dizini geçici olarak yeniden adlandırılır | `G43/g` = **ORTAM HATASI (çıkış 3)**; 🔴 **yeşil ya da "atlandı" dönerse BLOKER** | ucuz |
| `M224` | 🔴 **v1'de ÖLÜYDÜ, DEĞİŞTİRİLDİ.** `MapFallbackToFile` yerine düşük `Order`'lı yakala-hepsi: `app.Map("/{**path}", …)` | `G46/d` (canlı: `POST /v1/sync` **HTML** döner) | **pahalı** — backend yeniden başlatma |
| `M225` | COOP değeri → `same-origin-allow-popups` | `G44/a` (**alt-dizge tuzağı**, `MAJOR-2`) | ucuz |
| `M226` | COEP değeri → `credentialless` | `G44/b` | ucuz |
| `M227` | Başlık bloğu `if (app.Environment.IsDevelopment())` içine alınır | `G44/c` | ucuz |
| `M228` | Başlık bloğu `app.UseWhen(ctx => !ctx.Request.Path.StartsWithSegments("/v1"), …)` içine alınır | `G44/c` (**ikinci yazım**) | ucuz |
| `M229` | Başlık değeri tek satırda ternary'ye bağlanır: `app.Environment.IsDevelopment() ? "same-origin" : "unsafe-none"` | `G44/c` (**üçüncü yazım**) | ucuz |
| `M230` | Başlıklar ayrı `IzolasyonBaslikAraKatmani.cs` dosyasına taşınır, `Program.cs`'ten çağrılır | `G44/d` (🔴 v1'de bu kaçak **hiç kapatılmıyordu**) | ucuz |
| `M231` | `Cross-Origin-Resource-Policy` satırı silinir | `G44/e` | ucuz |
| `M232` | Başlık bloğu `UseStaticFiles`'tan **sonraya** taşınır | `G44/f` **ve** `G46/a`+`G46/b` (`D-W3-9`) | **pahalı** |
| `M233` | COOP satırı `//` ile yorumlanır | `G44/a` (🔴 kapı yorumu atıp *"yok"* demeli — **yorum atmanın ısırdığının kanıtı**) | ucuz |
| `MW21` | **SUSMALI:** `Program.cs`'e `/* Cross-Origin-Opener-Policy: same-origin */` **yorumu** eklenir | **hiçbir kapı düşmemeli** (`{}`) — düşerse `G44/g` sahte-pozitif üretiyordur ⇒ **BLOKER** | ucuz |
| `M234` | `wwwroot`'taki bir `.js`'e `http://10.0.2.2:5298` dizgesi enjekte edilir | `G45/a` (`B3`) | ucuz |
| `M235` | `wwwroot/flutter_bootstrap.js` **boşaltılır** | `G45/b` **ve** 🔴 `G45/a`+`G45/d`'nin yeşili **HÜKÜMSÜZ** ilan edilmeli | ucuz |
| `M236` | `wwwroot/canvaskit/` dizini yeniden adlandırılır | `G45/c` | ucuz |
| `M237` | Bir `.js`'e `www.gstatic.com/flutter-canvaskit` dizgesi enjekte edilir | `G45/d` | ucuz |
| `MW22` | **SUSMALI:** bir `.js`'e `https://fonts.gstatic.com/s/` dizgesi enjekte edilir | **hiçbir kapı KIRMIZI vermemeli** (`{}`); `G45/e` yalnız **sayar ve raporlar** (`D-W3-3`/`Y2`) | ucuz |
| `M238` | Statik dosya sunumu yalnız Development'a bağlanır: `if (app.Environment.IsDevelopment()) app.UseStaticFiles();` | `G44/c` **ve** `G46/f` (Production koşumu `a`–`c`'de düşer) | **pahalı** — iki ortam |
| `M239` | CORP **tüm** yanıtlara yazılır (`/v1` dahil) | `G46/g` (`D-W3-4` kapsamı) | **pahalı** |
| `M240` | `moveExistingIndexedDbToOpfs: true` → `false` | `G47/b` (🔴 **dilimin çekirdek kusuru budur — `O2`**) | ucuz |
| `M241` | `WasmDatabase.open` eklenir **ama** `driftDatabase(` de bırakılır | `G47/c` | ucuz |
| `M242` | `veritabani.dart`'ta mobil/masaüstü dalı bozulur (tanımsız sembol) | `G47/d` (`flutter analyze` **EXIT ≠ 0**) | orta |
| `M243` | `Program.cs`'teki **üç** `IsDevelopment()` bloğu da kaldırılır | `G44/h` = **ORTAM HATASI**; 🔴 *"aralık bulucu sıfır blok buldu"* ile *"temiz"* ayrılmalı (`MAJOR-7`) | ucuz |
| `M244` | `wwwroot/sqlite3.wasm` yeniden adlandırılır | `G46/c` (**404**) | orta — backend **ayakta**, yeniden başlatma **gerekmez** |
| `M245` | `veritabani.dart` v1 hâline döndürülür (yalnız `driftDatabase(`) | `G47/a` **ve** `G47/b` **ve** `G47/c` — üçü birden | ucuz |

**Toplam: 29 kusurlu + 2 susmalı = 31.** 🔴 *(Sayım `_v2_olc.py` ile **ölçüldü**, elle sayılmadı —
ilk yazımda "24+2=26" yazmıştım ve **yanlıştı**.)* Pahalı olan **dört** tanesidir (`M224`, `M232`,
`M238`, `M239`), `M244` **orta**; hepsini `4b`'ye göre **Claude Code** koşar.

---

## 6b. MUTANTSIZ KURALLAR — BEYANLI BORÇ

> 🔴 Bu başlık **`W1`'in ayırıcı biçimini** taşır (`MAJOR-10`): aşağıdaki her satır **makinece
> okunabilir** **DÖRT** alanlıdır — `ID | KURAL | NEDEN MUTANT YOK | KAPATMA YOLU`.
> *(İlk yazımda "üç alanlı" yazmıştım; `_v2_olc.py` **dört** ölçtü ve **ölçüm haklıydı** — biçim
> beyanı düzeltildi, veri değil.)* Bir kural bu listede **değilse** ve mutantı da **yoksa**, o kural
> **KÖR**'dür ve denetim onu **BLOKER** saymalıdır.

```
B-W3-1 | D-W3-5 tarayıcı ölçümü (crossOriginIsolated + opfsLocks) | otomatik araç yok (O4); T0 ELLE koşar, regresyonu yakalamaz | Playwright kurulumu — AYRI DİLİM, bu dilimde YAPILMAZ
B-W3-2 | G45/e fonts.gstatic.com yalnız raporlar | motor sabiti (configuration.dart:362), bayrakla çıkarılamaz; kırmızı verirse kapı TATMİN EDİLEMEZ olur (Y2) | fontFallbackBaseUrl'i runtime config ile ezmek — ölçülmedi, AYRI DİLİM
B-W3-3 | D-W3-8 güvenli bağlam şartı | kapı, sayfanın HANGİ host'tan açıldığını ölçemez (sunucu tarafı bunu bilmez) | T0 talimatı adresi BİREBİR yazar; ihlal ÖLÇÜLMEDİ sayılır
B-W3-4 | §2 service worker davranışı | flutter_service_worker.js'in require-corp altındaki davranışı hiç ölçülmedi | canlı tarayıcı ölçümü — B-W3-1'e bağlı
B-W3-5 | G44/g yorum atma parserı | kaba tarayıcıdır: dizge içindeki "//" dizisini yorum sanabilir | MW21 sahte-pozitifi ölçer; TAM parser için Roslyn — AYRI DİLİM
B-W3-6 | §2 mobil istemcinin COEP'ten etkilenmemesi | mobil belge yükü taşımaz; ölçüm yüzeyi YOK | iddia EDİLMİYOR; G47/d yalnız "bozulmadı"yı ölçer
B-W3-7 | T0'ın üç koşumunun tekrarlanabilirliği | elle koşulur, çıktı kopyala-yapıştırdır; sha ile mühürlenmez | 02-OLCUM-SONUC-o61.md'ye ham konsol çıktısı BİREBİR yapıştırılır — insan disiplini, ölçüm değil
B-W3-8 | G46/h /health/live Content-Type ayağı | GÖZLEM ayağıdır, hüküm vermez (MAJOR-8: beklenen değer iddia EDİLMİYOR); mutasyonu anlamsız — 200 kısmı zaten 4c hazır-olma üçlüsünde ölçülüyor | Content-Type'ı sabitleme kararı alınırsa ayak hükme döner ve mutantı yazılır — bu dilimde ALINMADI
```

---

## 7. KABUL KRİTERLERİ

🔴 **Hiçbiri "kopyalanmış sayı" kabul etmez** (`MINOR-4`: v1 `539` sayısını `W2`'den kopyalıyordu;
kapı **kendi ölçümünü** yazar).

1. **`T0` YEŞİL** — `02-OLCUM-SONUC-o61.md` üç koşumun **ham konsol çıktısını** taşır; hüküm
   tablosunda `crossOriginIsolated=true` **ve** `chosenImplementation` **`opfsLocks`** ya da
   **`opfsShared`** görünür. 🔴 `sharedIndexedDb` görünüyorsa dilim **KABUL EDİLMEZ**.
2. `G43` · `G44` · `G45` · `G47` **YEŞİL** (statik) — Cowork koşar, ham çıktı `KANIT/W3/`'e.
3. `G46` **YEŞİL**, **Development ve Production'ın İKİSİNDE de** — iki ayrı ham çıktı dosyası.
4. **31 mutantın 31'i** hükmü verir: **29** kusurlunun her biri `hedef`ini düşürür, **2** susmalının
   **hiçbiri hiçbir kapıyı düşürmez**. Sapma `D-W3-6` taksonomisiyle **yazılı olarak** sınıflanır.
   🔴 **Sayı `_v2_olc.py` ile ölçülür, elle sayılmaz** — kabul koşumunda betik yeniden koşar ve
   tablodaki mutant sayısı bu kriterle **birebir tutmalıdır**.
5. `flutter test` **EXIT 0** · `flutter analyze --fatal-infos` **EXIT 0** · `verify.ps1` **EXIT 0**
   (backend **kapatıldıktan** sonra, `4c`).
6. `ADR 0004` gövdesi yazılı: alt-soru **1·2·3 KAPANIR** (ölçülmüş yanıtla), **4·5 borç kalır**
   (gerekçesiyle). 🔴 **Ölçüm aracı:** `araclar/adr-doldurulmus-mu.py` — `0004`'te `[YAZILACAK]`
   / `TBD` / boş `##` bölümü **kalmadığını** ölçer. *(v1'de bu kriterin aracı yoktu; `MAJOR-11`
   uyarınca ya araç yazılır ya kriter borca iner — **araç yazılır**.)*
7. **Bağımsız denetim turu 2** koşmuş ve **kabul** demiş olmalı (`§0`).

---

## 8. BEYAN EDİLMİŞ SINIRLAR — *"neyi ölçmüyoruz"*

1. 🔴 **Regresyon koruması YOK.** `T0` bir kerelik elle ölçümdür; birisi yarın `require-corp`'u
   `credentialless` yaparsa `G44/b` yakalar, ama drift'in **fiilen** hangi API'yi seçtiğini
   **hiçbir otomatik kapı görmez** (`B-W3-1`).
2. `fonts.gstatic.com` istekleri **kalır** (`B-W3-2`). Çevrimdışı ilk açılışta font düşer;
   uygulama **çalışır**, tipografi geri düşer. Ölçüldü, kabul edildi.
3. **Service worker** `require-corp` altında **[ÖLÇÜLMEDİ]** (`B-W3-4`).
4. 🔴 **Güvenli bağlam kapı tarafından ölçülemez** (`B-W3-3`) — `192.168.x.x`'ten açılan sayfa
   sessizce izolasyonsuz kalır ve **hiçbir kapı kırmızı vermez**.
5. 🔴 **`G44/g` yorum atıcısı tam bir C# parserı DEĞİLDİR** (`B-W3-5`).
6. 🔴 **`wwwroot` CI'da yoktur.** `G43/g` orada **ORTAM HATASI** verir; CI iş akışının bu kapıyı
   **koşup koşmayacağı bu dilimde KARARA BAĞLANMADI** — `T9`'da `ADR 0004`'e yazılır.
7. 🔴 **v1'in §8'indeki *"SignalR henüz yok"* satırı KALDIRILDI** (`MAJOR-12`): `Program.cs`'te
   `MapHub` **0** ölçüldü; olmayan bir şeyin sınırı yazılmaz. `W4`+ dilimlerinin sorunudur.
8. **Üretim dağıtım topolojisi** (CDN, ters vekil, ayrı statik host) bu dilimde **yok**; ters vekil
   COOP/COEP'i **ezebilir** ve bu **ölçülmez**.

9. 🔴 **VERİ GÖÇÜ BİLEREK KAPSAM DIŞIDIR — `K158` ZORUNLU BEYANI (Onur kilitledi, oturum 62).**
   **MEVCUT `sharedIndexedDb` deposu olan bir tarayıcı OPFS'e GEÇMEZ**; verisi IndexedDB'de kalır.
   `T5` (`WasmDatabase.open(..., moveExistingIndexedDbToOpfs: true)`) **ERTELENDİ ve YAZILMAYACAK.**
   Üç ölçülmüş gerekçe: ① COOP/COEP başlıkları **temiz kurulumu** zaten `opfsLocks`'a taşıyor
   (gerçek `flutter build web`, iki koşul, üründe tek bayt değişmedi) ② **kalıcı profille üç koşum:**
   izolasyon açık, `chosenImplementation` yine `sharedIndexedDb`, **OPFS BOŞ** ⇒ göç hiç başlamadı
   ③ **sürüm yükseltme yolu ÖLÜ:** drift 2.34.3 `wasm.dart:163` bayrağı taşıyor ama
   `drift_flutter` 0.3.1 `web.dart:19-24` **geçirmiyor** ve pub.dev `/api` ölçümü
   `latest = 0.3.1` (11 Tem 2026) diyor.
   **Beyan edilmiş bedel:** bayrağın koruduğu şey **mevcut kullanıcı verisidir**; bu depo private ve
   sahada kullanıcı **yok** ⇒ kazanç teorik, bedel gerçek. 🔴 **`B-11` (atomik olmayan göç) HÂLÂ
   ÖLÇÜLMEDİ** (`B-O62-8`); `T5` bir gün açılırsa **ÖNCE o ölçülür**, sıra tersine çevrilemez.
   Kanıt: `KANIT/W3/02-O2-OLCUMU-o62.md` (ERRATUM'lu) + `03-VERI-GOCU-OLCUMU-o62.md`.

10. 🔴 **WEB BUILD `--no-web-resources-cdn` OLMADAN ALINAMAZ — `K159-b` (oturum 63).**
    Flutter'ın **varsayılan** `flutter build web` çıktısı CanvasKit'i
    `https://www.gstatic.com/flutter-canvaskit/<engineRevision>` adresinden çeker. Birincil kaynak
    `flutter_bootstrap.js`'in kendi üçlü işleci:
    `canvasKitBaseUrl ? … : (engineRevision && !useLocalCanvasKit ? <gstatic> : "canvaskit")`;
    bayrak yalnız `--no-web-resources-cdn` ile `true` olur
    (`flutter_command.dart:1479` + `build_info.dart:1098`). o63'te **pozitif+negatif kontrollü**
    ölçüldü: `require-corp` altında CORP'**suz** çapraz-köken betik **BLOKLANDI**, CORP'**lu** olan
    **YÜKLENDİ**. ⇒ Bayrak bir tercih değil **KAPI ŞARTIDIR**; onsuz derlenen bir sürümde bu
    spec'in izolasyon iddiası **çürür**. 🔴 **CI'da zorlanmıyor** (`B-O63-2`).
    Kanıt: `KANIT/W3/04-ISTEMCI-IZOLASYONU-o63.md` §5.

---

## 9. NE ÖLÇÜLEMEDİ *(v2 yazımı sırasında)*

- `T0`'ın kendisi — **tanım gereği** henüz koşmadı (`D-W3-0`). v2'nin tüm `OPFS` iddiaları
  `T0`'a **koşulludur**.
- `wwwroot/_BUILD.json` şeması — `T2` betiği henüz yazılmadı; `G43/f`'nin **tam alan adları**
  `T2`'de kesinleşir.
- `M242`'nin `flutter analyze` süresi — `ORTAM.md`'de ölçüm yok; **orta** maliyet **tahmindir**.
- `MapFallbackToFile`'ın `{*path:nonfile}` deseninin `.` içeren uzantısız yollarda davranışı
  (`/v1.5/x`) — kaynak okundu, **canlı ölçülmedi**; `G46/e` beyanı bu yüzden dar tutuldu.

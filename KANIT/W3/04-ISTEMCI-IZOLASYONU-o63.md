# KANIT/W3/04 — İSTEMCİNİN İZOLASYONU (aynı kökenden servis) · oturum 63

**Ölçüm tarihi:** 7 Ağu 2026, 16:20–17:25 UTC (**19:20–20:25 +03**, cihazdan `TZ='Europe/Istanbul' date` ile ölçüldü — `ORTAM.md` UTC maddesi).
**Ölçen el:** Cowork (bulut konteyneri). **K80 Onur'un makinesi için AYNEN AYAKTA** — aşağıdaki hiçbir süreç Onur'un makinesinde başlatılmadı.
**Karar dayanağı:** `K158` sonrası devir notunun "SIRADAKİ İŞ / 2" maddesi; kapsamı Onur bu oturumda kilitledi (yapılandırmadan okunan yol · her ortamda · iskelet+ölçüm+1 mutant · kodu Cowork yazar).

---

## 0. ORTAM BEYANI (ölçüldü, beyan değil)

| ne | ölçülen |
|---|---|
| .NET SDK | `10.0.302` (`global.json` pini ile birebir) |
| Flutter | `3.44.9` stable, framework `6b182d2c75` · 🔴 **depo `DURUM.md` 3.44.6 diyor — YAMA FARKI VAR** |
| tarayıcı | Playwright Chromium (headless), `--lang=en-US` + `locale="en-US"` (`ORTAM.md`: konteynerde locale yok ⇒ Flutter `RangeError` atar) |
| PostgreSQL | 🔴 **YOK.** Bağlantı dizesi verilmedi ⇒ host DB'siz açıldı (slice-2b1 `D1` sözleşmesi). `/v1/tasks` bu yüzden **500** döner; bu **ortam** sonucudur, ürün kusuru değil. |
| önbellek | Her ölçüm **TAZE tarayıcı bağlamıyla** koştu (o62 dersi: kalıcı profil + HTTP önbelleği = **KÖR ÖLÇÜM**). |
| süreç yönetimi | Başlatma/durdurma **ayrı `.sh` dosyalarında** (o62 dersi: `pkill -f <dll yolu>` kendi kabuğunu öldürüyor, EXIT 144). |
| hazır olma | Sabit `sleep` YOK — `/health/live` **200** görülene kadar **yoklandı**, tavan 40 sn (`K80`). |

---

## 1. ÜRÜN KODU

| dosya | durum | satır | bayt | sha256 (ilk 16) |
|---|---|---|---|---|
| `src/backend/Momentum.Api/Web/IstemciServisi.cs` | **YENİ** | 113 | 5.753 | `1bf90719eb4a83ce` |
| `src/backend/Momentum.Api/Program.cs` | değişti | +15 | 10.195 | `0cd45daf474d7812` |

**Toplam ürün kodu: 128 satır.** `R8` sayısı bu belgeden değil, `radar.py --olc-urun-kodu <sha>` ile **git'ten** türetilir (`K55`).
Derleme: `dotnet build Momentum.Api.csproj` ⇒ **0 uyarı / 0 hata** (`TreatWarningsAsErrors=true`, `EnableNETAnalyzers=true`).

### Tasarım kilidi (Onur, o63)
1. Kök dizin **yapılandırmadan** okunur: `Istemci:KokDizin` (`W1/D-W1-1` deseni — yol koda gömülmez).
2. Anahtar boş ya da dizin diskte yoksa ara katman **hiç kurulmaz** ⇒ **kill switch bedava gelir**.
3. **Her ortamda** açık (yalnız-Development değil): `Program.cs`'te ÜÇÜNCÜ bir `IsDevelopment()` bloğu doğmasın — denetimin `BLOKER-3`'ü tam bunu işaretlemişti.
4. Sıra **zorunludur**: `UseIzolasyonBasliklari` → `UseIstemciServisi` → `UseRouting`.

---

## 2. ÖLÇÜM 1 — HTTP düzeyi (21 vaka, `_http_olc.py`)

**Hüküm: BAŞLIKSIZ YANIT SAYISI = 0 · KABUK DÖNEN API YOLU = YOK.**

| yol | kod | bayt | COOP | COEP | content-type |
|---|---|---|---|---|---|
| `/` · `/index.html` | 200 | 1.546 | same-origin | require-corp | text/html |
| `/main.dart.js` | 200 | 2.772.541 | same-origin | require-corp | text/javascript |
| `/canvaskit/canvaskit.wasm` | 200 | 7.229.467 | same-origin | require-corp | **application/wasm** |
| `/canvaskit/skwasm.wasm` | 200 | 3.580.947 | same-origin | require-corp | application/wasm |
| `/sqlite3.wasm` | 200 | 748.424 | same-origin | require-corp | application/wasm |
| `/drift_worker.js` | 200 | 354.758 | same-origin | require-corp | text/javascript |
| `/assets/AssetManifest.bin` | 200 | 2 | same-origin | require-corp | application/octet-stream |
| `/assets/NOTICES` | 200 | **1.380.683** | same-origin | require-corp | application/octet-stream |
| `/health/live` · `/health/ready` | 200 | 7 | same-origin | require-corp | text/plain |
| `/openapi/v1.json` | 200 | 9.925 | same-origin | require-corp | application/json |
| `/scalar/v1` | 200 | 624 | same-origin | require-corp | text/html |
| `/v1/tasks` **başlıksız** | **401** | 0 | same-origin | require-corp | — |
| `/v1/tasks` + `X-Momentum-Dev-User` | 500 | 201 | same-origin | require-corp | application/problem+json |
| `/v1/BULUNMAYAN-UC` | **404** | 0 | same-origin | require-corp | — |
| `POST /hubs/sync/negotiate` **başlıksız** | **401** | 0 | same-origin | require-corp | — |
| `POST /hubs/sync/negotiate` + başlık | 200 | 316 | same-origin | require-corp | application/json |

**Ne kanıtlandı:** ① dört API yüzeyinin (`/v1/**`, `/health/**`, `/hubs/sync`, `/scalar/v1`) hiçbiri **gölgelenmiyor** ② `K61` dev-kimlik kalkanı **canlı** (başlıksız 401) ③ slice-2b2 `D4` hub kalkanı **canlı** ④ statik yanıtlar da izolasyon başlıklarını **taşıyor**.

---

## 3. ÖLÇÜM 2 — gerçek tarayıcı (`_tarayici_olc.py`)

```
crossOriginIsolated : True     (BEKLENEN: true)
SharedArrayBuffer   : function
Flutter çizildi     : True
ağ isteği           : 10 | BAŞARISIZ(>=400): YOK
pageerror           : YOK
```

🟢 **`IzolasyonBasliklari.cs`'in kendi beyan edilmiş sınırı KAPANDI.** O dosya şunu yazıyordu: *"Momentum.Api bugün statik dosya SUNMUYOR ⇒ Flutter web istemcisi başka bir kökenden servis edildiği sürece BU başlıklar istemciyi izole ETMEZ."* Artık ediyor ve bu **ölçüldü**.

---

## 4. MUTANT `M-W3-2` — KÖR KAPI YOK

**Kurgu:** istemci **AYNI kökenden** sunulmaya devam eder, yalnız `Izolasyon:Etkin=false`.

```
crossOriginIsolated : False    (BEKLENEN: false)   ⇒ ISIRDI
SharedArrayBuffer   : undefined
Flutter çizildi     : True     (uygulama yine açıldı — mutant izolasyonu öldürdü, uygulamayı değil)
```

**Ne kanıtlandı:** izolasyon **ürün kodunun yazdığı başlıklardan** doğuyor; aynı kökenden servis etmek tek başına yetmiyor. Ölçüm ısırıyor.

---

## 5. ÖLÇÜM 3 — `require-corp` fiilen blokluyor mu? (pozitif **ve** negatif kontrollü)

İkinci bir köken (`127.0.0.1:5299`) kuruldu: `korplu.js` **CORP taşır**, `korpsuz.js` **taşımaz**. İzole belge ikisini de `<script>` ile yüklemeyi denedi.

```
POZİTİF KONTROL (ikinci köken erişilebilir mi): True
crossOriginIsolated                           : True
CORP'SUZ çapraz-köken betik: BLOKLANDI   (BEKLENEN: BLOKLANDI)
CORP'LU  çapraz-köken betik: YÜKLENDİ    (BEKLENEN: YÜKLENDİ)
```

🔴 **BU ÖLÇÜMÜN ÜRÜN SONUCU — BUILD BAYRAĞI ZORUNLUDUR.** Flutter'ın **varsayılan** `flutter build web` çıktısı CanvasKit'i `https://www.gstatic.com/flutter-canvaskit/<engineRevision>` adresinden çeker. Birincil kaynak, `flutter_bootstrap.js`'in kendi ifadesi:

```js
i.canvasKitBaseUrl ? i.canvasKitBaseUrl
                   : (e.engineRevision && !e.useLocalCanvasKit
                        ? I("https://www.gstatic.com/flutter-canvaskit", e.engineRevision)
                        : "canvaskit")
```

`useLocalCanvasKit` yalnız `--no-web-resources-cdn` ile `true` olur (birincil kaynak: `flutter_tools/lib/src/runner/flutter_command.dart:1479` + `build_info.dart:1098`). Bu belgedeki **tüm ölçümler** `flutter build web --release --no-web-resources-cdn` çıktısı üzerinde koştu ve o çıktının bootstrap'ında `useLocalCanvasKit":true` **ölçüldü**.

> ⇒ **Web sürümü `--no-web-resources-cdn` OLMADAN derlenirse izolasyon iddiası ÇÜRÜR.** Bu bayrak bir tercih değil, **kapı şartıdır** ve CI'a girmesi gerekir (borç).

---

## 6. TUR İÇİNDE ÖLÇÜLEN VE DÜZELTİLEN İKİ KUSUR

İkisi de ilk yazımda vardı, **ölçüm buldu**, aynı turda kapatıldı ve **yeniden ölçüldü**.

**K1 — `/v1/BULUNMAYAN-UC` ⇒ 200 + `index.html`.** `MapFallbackToFile`'ın `/{*path:nonfile}` deseni uzantısız her yolu yakalıyor; eşleşen uç noktalar korunuyor ama **eşleşmeyen** API yolları SPA kabuğuna düşüyordu. Bir API'nin bilinmeyen uç nokta için HTML dönmesi kusurdur.
**Düzeltme:** `SpaDisiOnEkler = ["/v1","/health","/hubs","/scalar","/openapi"]` için `MapFallback(... => Results.NotFound())`. Daha **özgül desen** catch-all'dan önce eşleşir. **Yeniden ölçüm: 404.** ✅

**K2 — `/assets/NOTICES` ⇒ 200 + `index.html`** (1.546 b, oysa dosya diskte **1.380.683 b**). İlk denemem (`ServeUnknownFileTypes=true`) **İŞE YARAMADI** ve bu da ölçüldü. Kök neden birincil kaynakta: `StaticFileMiddleware`, **eşleşmiş bir uç nokta varsa dosyayı hiç sunmaz** (`ValidateNoEndpoint`); `WebApplication` ise `UseRouting`'i **ardışık hattın en başına** kendisi ekler ⇒ statik ara katman yönlendirmeden **sonra** koşuyordu ve uzantısız yol zaten geri-düşüşle eşleşmişti.
**Düzeltme:** `Program.cs`'te `app.UseRouting()` **açıkça** çağrıldı — statik dosyalardan **sonra**, `UseCors`'tan **önce** (`D-W1-3` korunur: `UseCors` hâlâ `UseRouting` ile uç nokta yürütmesi arasında). **Yeniden ölçüm: 1.380.683 b.** ✅

> **Ders:** `ServeUnknownFileTypes` düzeltmesi **kâğıtta doğru, koşumda ölü**ydü. Ölçüm koşmasaydı repoya *bir şey yaptığını sanan* bir yapılandırma satırı girecekti. `K53/5`'in kendi gerekçesi.

---

## 7. 🔴 NE ÖLÇÜLEMEDİ (K40/§4 gereği BOŞ OLAMAZ)

1. **`gstatic.com` CORP taşıyor mu — ÖLÇÜLEMEDİ.** Konteynerin `gstatic`'e ağı yok (`fonts.gstatic.com` isteği `ERR_CONNECTION_RESET` ile düştü). Dolayısıyla *"CDN'li build gerçekten kırılır mı"* **doğrudan ölçülmedi**; §5 mekanizmayı yerel ikinci kökenle kanıtlar, ama gstatic'in kendi başlıklarını **kanıtlamaz**. `--no-web-resources-cdn` şartı bu belirsizliğin **güvenli tarafıdır**.
2. **Roboto web fontu** aynı sebeple yüklenemedi. `require-corp` altında `fonts.gstatic.com`'un davranışı **ÖLÇÜLMEDİ**.
3. **Onur'un makinesinde DERLENMEDİ.** `verify.ps1` + 120 test bu değişiklikle **koşulmadı** (`B-O62-2`'nin kardeşi). Bu belgedeki *"0 uyarı"* **bulut** ölçümüdür.
4. **PostgreSQL yok** ⇒ `/v1/**` uçlarının **200 gövdesi** hiç görülmedi; yalnız *gölgelenmedikleri* ölçüldü. Çevrimdışı/OPFS akışı, drift senkronu, `W2`'nin depolama görünürlüğü bu turda **hiç egzersiz edilmedi**.
5. **Gölgeleme kapısı YAZILMADI.** İstemci kökünde `v1`/`health`/`hubs`/`scalar` **adında bir dosya** bulunursa uç nokta gölgelenir; ölçüm bir kez koştu, **mekanik kapı yok** ⇒ borç.
6. **`SpaDisiOnEkler` listesinin tazeliği ölçülmüyor.** Yeni bir kök yol eklenirse (örn. `/metrics`) liste sessizce bayatlar; bunu ölçen kapı **yok** ⇒ borç.
7. **`--no-web-resources-cdn` CI'da zorlanmıyor** ⇒ borç.
8. **`index.html` önbellek başlığı yok.** SPA kabuğu `no-store` göndermiyor; kullanıcı bayat kabukla kalabilir. Ölçülmedi, **karar verilmedi** ⇒ borç.
9. **Flutter yama farkı:** ölçüm 3.44.9 ile koştu, depo 3.44.6 diyor. Farkın etkisi **ölçülmedi**.
10. **`--altin-kume` yok:** `izolasyon-olc.py` bu turda **genişletilmedi**; bu belgedeki ölçümler tek seferlik koşucularla yapıldı (`K53/5`: kapılar sonra).

---

## 8. KOŞUCULAR (hepsi bulut konteynerinde)

| dosya | ne yapar |
|---|---|
| `_api_baslat.sh` / `_api_durdur.sh` | süreç yönetimi **ayrı dosyada** (o62 EXIT 144 dersi) |
| `_hazir_bekle.py` | `/health/live` 200'e kadar **yoklar**, tavan 40 sn |
| `_http_olc.py` | 21 vaka; COOP/COEP + gölgeleme + kabuk-sha karşılaştırması |
| `_tarayici_olc.py` | Playwright; `crossOriginIsolated`, `SharedArrayBuffer`, ağ/konsol/`requestfailed`; **ölçüleni beklenene karşı doğrular**, tutmazsa EXIT 2 |
| `_capraz_sunucu.py` | ikinci köken (5299): `korplu.js` CORP taşır, `korpsuz.js` taşımaz |

🔴 **Bu koşucular Onur'un diskine YAZILMADI** — bulut konteyneri oturumla birlikte kaybolur. Yeniden üretilmeleri gerekiyorsa bu belgedeki tanımlar yeterlidir; kalıcılaştırma kararı Onur'undur (borç).

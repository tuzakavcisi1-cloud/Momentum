# GOREV-W3 — Web Çapraz-Köken İzolasyonu (API web'i SUNAR + COOP/COEP)

**v1 — KİLİTLENMEDİ.** Cowork yazdı, oturum 60 (5 Ağu 2026). **Kilit Onur'dan gelir.**
Önceki dilim: `GOREV-W2-depolama-gorunurlugu.md` v3 (`K142`), **KABUL EDİLDİ** (`K144`).
Bu dilim, `W2`'nin **görünür kıldığı** geri-düşüşü **onarır**.

---

## 0. KİLİT ÖNCESİ BAĞIMSIZ DENETİM (`K127` — PAZARLIKSIZ)

| tur | ne zaman | çıktı yolu | durum |
|---|---|---|---|
| 1 | kilitten **ÖNCE** | `KANIT/W3/00-DENETIM-o60.md` | 🔴 **KOŞTU — v1 KİLİTLENEMEZ** |

🔴 **TUR 1 SONUCU:** iki bağımsız ajan (K26), **6 bloker sınıfı + 14 major**. İkisi bağımsız
olarak **aynı iki kusurda** buluştu. En ağırı `B1`: `drift_flutter 0.3.1` `moveExistingIndexedDbToOpfs`
bayrağını **geçiremiyor** ve `veritabani.dart:180` tam da o yolu kullanıyor (Cowork cihazda ölçtü)
⇒ **izolasyon kusursuz sağlansa bile drift `sharedIndexedDb`'de kalır, ürün davranışı DEĞİŞMEZ.**
Ayrıca `B2`: §1/2'nin *"ölçülmüş olgu"* dediği iddia ölçüldüğünde **tersi çıktı** (gstatic
`CORP: cross-origin` gönderiyor). **Bu ikisi MİMARİYİ DEĞİŞTİREN blokerdir ⇒ `K53/1` gereği
ikinci tur MEŞRUDUR.** v2 kapsamı Onur'un kilidini bekliyor.

🔴 Bu tablo kilit checkpoint'ine **olduğu gibi** taşınır. Yol boşsa checkpoint
*"denetim KOŞULMADI"* diye **açıkça** yazar; sessiz geçmek yasaktır.

---

## 1. NEDEN — ölçülmüş bağlam (hiçbiri tahmin değil)

`ADR 0004` iskeleti (`06BE5761`) açık soruyu sabitledi: sunucu COOP/COEP göndermiyor ⇒ Chrome'da
`opfsLocks` **erişilemez**, istemci `sharedIndexedDb`'ye düşer. Bu dilim o soruyu **ölçerek** kapatır.

**Oturum 60'ta ölçülen üç olgu (spec'in taşıyıcı kolonları):**

1. 🔴 **`Momentum.Api` web istemcisini SUNMUYOR.** `src/backend/Momentum.Api/Program.cs` (8.662 b)
   içinde `UseStaticFiles` **YOK**, `UseDefaultFiles` **YOK**, `MapFallback*` **YOK**;
   `wwwroot` dizini **YOK**. ⇒ **COOP/COEP'i yalnız API'ye eklemek işe YARAMAZ:**
   `crossOriginIsolated` **belgeyi getiren yanıtın** başlıklarıyla belirlenir, `/v1/sync`'in
   başlıklarıyla değil. *(Bu ölçüm, "sadece middleware ekleyelim" yolunu **eledi**.)*

2. 🔴 **Bugünkü web build'i ÜÇ dosyada çapraz-köken URL taşıyor** (`src/client/build/web`'de ölçüldü):
   `flutter.js` ve `flutter_bootstrap.js` → `https://www.gstatic.com/flutter-canvaskit`;
   `main.dart.js` → `https://www.gstatic.com/flutter-canvaskit/83675ed…/` **ve**
   `https://fonts.gstatic.com/s/`. ⇒ `COEP: require-corp` açıldığı anda bu alt-kaynaklar
   **CORP olmadan bloklanır**. İzolasyonu açıp bunu onarmamak, **çalışan sayfayı kırmaktır.**
   *(Dizinde yerel bir `canvaskit/` klasörü VAR — yani yerelleştirme yolu zaten mevcut,
   eksik olan **bootstrap'ın hangi tabanı kullandığıdır**.)*

3. 🔴 **Gerçek tarayıcı ölçüm aracı bu makinede YOK:** `playwright` YOK · `selenium` YOK ·
   `chrome` PATH'te YOK (`node v24.18.0`, `npx 11.16.0` var). `ORTAM.md`: `flutter test
   --platform chrome` bu ortamda **sonuç üretmiyor** (iki ölçüm: 7 dk ve 9,8 dk).
   ⇒ Ölçüm katmanı kararı **buradan** doğdu (`D-W3-5`).

---

## 2. KAPSAM

**İÇERİDE:** ① `Momentum.Api`'nin web build çıktısını **aynı kökenden** sunması ② COOP/COEP
başlıklarının **her ortamda** gönderilmesi ③ çapraz-köken alt-kaynakların **kaynağında** yok
edilmesi ④ bunların **statik + canlı HTTP** kapılarıyla ölçülmesi ⑤ `ADR 0004` gövdesinin
**ölçülmüş** yanıtlarla yazılması.

**DIŞARIDA, gerekçeli:**
- **Gerçek tarayıcıda `crossOriginIsolated` ve drift'in seçtiği implementasyon** — araç yok
  (§1/3). Borç `B-W3-1`; `D-W3-5`'te beyan edilir, **gizlenmez**.
- **Üretim dağıtımı / CDN topolojisi** — bu depoda dağıtım hedefi yok; karar `ADR 0004` gövdesine.
- **Service worker / PWA stratejisi** — `flutter_service_worker.js` üretiliyor ama bu dilim
  ona dokunmaz; etkisi `§8`'de beyanlı sınırdır.
- **Mobil istemci** — Android/iOS bu başlıklardan etkilenmez (belge yükü yok). Ölçülmez, **iddia da edilmez**.

---

## 3. KARARLAR

### `D-W3-1` — API, web build çıktısını AYNI KÖKENDEN sunar
`Momentum.Api` `wwwroot`'tan `UseDefaultFiles()` + `UseStaticFiles()` ile sunar ve
`MapFallbackToFile("index.html")` ile SPA yönlendirmesi yapar.
🔴 **Sıra PAZARLIKSIZ:** API uç noktaları (`/v1/**`, `/health/**`) fallback'ten **ÖNCE**
eşleşir. Aksi hâlde `/v1/sync`'e gelen bir istek `index.html` alır ve **`K61` dev-kimlik
kalkanı sessizce ölür** (401 yerine 200 + HTML). Bunu `G46/d` ve `M224` ölçer.

### `D-W3-2` — COOP/COEP HER ORTAMDA etkindir (🔒 Onur kilitledi, oturum 60)
`Cross-Origin-Opener-Policy: same-origin` + `Cross-Origin-Embedder-Policy: require-corp`,
**`IsDevelopment()` ayrımı OLMADAN**, tüm yanıtlarda.
**Ölçülmüş gerekçe:** `W1`'in *"CORS yalnız Development"* kararı bağımsız denetimde **bloker**
çıktı (`B-W1-5`: mutantsız **ve** kapısız). Aynı sınıfı tekrarlamamak için kapsam ayrımı
**yok**; olsaydı, ayrımın kendisi bir mutant ve bir kapı isterdi. Ayrıca kalıcılık **ürünün
davranışıdır**: Development'ta OPFS, üretimde IndexedDB olsaydı **iki farklı ürün** test edilmiş olurdu.

### `D-W3-3` — CanvasKit ve font geri-düşüşü AYNI KÖKENDEN gelir
Web build `--no-web-resources-cdn` ile üretilir; `canvaskit` **yerel** dizinden yüklenir.
**Ölçülmüş gerekçe: §1/2.** 🔴 **Beyan:** bu bayrak **CanvasKit'i** yerelleştirir;
`main.dart.js`'teki `https://fonts.gstatic.com/s/` **CanvasKit'in font geri-düşüşüdür** ve
bayrağın onu da kapattığı **[ÖLÇÜLMEDİ]** ⇒ `G45` **ikisini AYRI AYRI** ölçer ve
bulursa **KIRMIZI** verir. Kalırsa çözüm `§8/2`'de beyanlı sınır olarak yaşar, **susturulmaz**.

### `D-W3-4` — Statik varlıklar `Cross-Origin-Resource-Policy: same-origin` taşır
Aynı köken `require-corp` için zaten yeterlidir; bu başlık **derinlemesine savunmadır** ve
varlıkların başka bir siteye gömülmesini engeller. Ucuz, ölçülebilir, geri alınabilir.

### `D-W3-5` — ÖLÇÜM KATMANI: HTTP (🔒 Onur kilitledi, oturum 60)
Kapılar **yeni bağımlılık KULLANMAZ**: statik tarama (Python) + canlı HTTP ölçümü (`urllib`).
🔴 **BEYAN EDİLMİŞ SINIR — bu dilimin en büyük deliği:** *"Chrome gerçekten `crossOriginIsolated`
oldu ve drift `opfsLocks` seçti"* iddiası **ÖLÇÜLMEZ**. Bu dilim **sunucunun izolasyonu
sağladığını** kanıtlar, **tarayıcının onu kullandığını değil.** Borç `B-W3-1`; kapatma yolu
Playwright kurulumudur (lisans + CVE kapısı, kırmızı çizgi 3) ve **bu dilimde yapılmaz**.

### `D-W3-6` — Mutant `hedef` sütunu BEKLENENDİR, ERRATUM yolu ŞİMDİDEN açıktır
🔴 `K145`'in dersi buraya **önden** uygulanır: *mutant tablosunun `hedef` sütunu, kodun dal
yapısını bilmeden yazılamaz.* §6'daki `hedef` kümeleri **beklentidir**; build sonrası ölçülen
küme farklıysa ve fark `gözlenen ⊇ hedef` (**aşırı-yakalama**) ise bu **kusur DEĞİLDİR** —
düzeltme yolu bir **ERRATUM**'dur ve kilitli spec'e dokunulmaz. `gözlenen ⊉ hedef` (**kör kapı**)
ise **BLOKER**'dır. *(W2'de bu ayrım kabul turunda elde yapıldı; burada spec'in kendisi taşıyor.)*

---

## 4. YAPILACAKLAR

| # | iş | dosya |
|---|---|---|
| `T1` | `wwwroot` oluştur; web build çıktısı oraya kopyalanır (build adımı `T2`) | `src/backend/Momentum.Api/wwwroot/` |
| `T2` | `flutter build web --no-web-resources-cdn` → çıktı `wwwroot`'a. Kopyalama **betikle** yapılır, elle değil | `araclar/web-yayina-al.py` |
| `T3` | COOP/COEP/CORP başlık middleware'i; **kapsam ayrımı YOK** (`D-W3-2`) | `Program.cs` |
| `T4` | `UseDefaultFiles` + `UseStaticFiles` + `MapFallbackToFile`; **API uçları ÖNCE** (`D-W3-1`) | `Program.cs` |
| `T5` | Statik kapı: `izolasyon-kapisi.py` (`G43`·`G44`·`G45`) + **altın küme** | `araclar/izolasyon-kapisi.py` |
| `T6` | Canlı HTTP kapısı: `_izolasyon_http_olc.py` (`G46`) — backend ayakta iken koşar | `araclar/_izolasyon_http_olc.py` |
| `T7` | `wwwroot` **git-ignore** edilir (kırmızı çizgi 5: build artefaktı repoya girmez); kapı bunu ölçer | `.gitignore` |
| `T8` | `ADR 0004` gövdesi **ölçülmüş** yanıtlarla yazılır; alt-soru 1·2·3 kapanır, 4·5 borç kalır | `docs/ADR/0004-*.md` |

🔴 **ORTAMI KİM KALDIRIR (`K80` — bu spec kendi maddesini TAŞIR):**
① `docker start momentum-postgres` → `healthy` görünene kadar **yoklanır** (tavanlı, sabit `sleep` DEĞİL)
② backend ayrı pencerede, `ORTAM.md`'nin reçetesiyle (`ASPNETCORE_ENVIRONMENT` · `ASPNETCORE_URLS`
· `ConnectionStrings__Momentum` **açıkça** set edilir; aksi hâlde host DB'siz açılır ve port yine dinler)
③ hazır olma **portla değil** üçlüyle ölçülür: `/health/live` 200 · `/health/ready` 200 ·
`POST /v1/sync` başlıksız **401** (`K61` kalkanı canlı).
🔴 **`verify.ps1` çalışan `Momentum.Api` VARKEN KOŞULAMAZ** (`ORTAM.md`) ⇒ sıra:
canlı ölçüm (`G46`) → backend **kapatılır** (`netstat` ile **ölçülür**) → `verify.ps1`.

---

## 5. KAPILAR

### G43 — API web'i AYNI KÖKENDEN sunuyor (statik)
- **a)** `Program.cs`'te `UseStaticFiles(` **VAR**.
- **b)** `UseDefaultFiles(` **VAR** ve `UseStaticFiles`'tan **ÖNCE** çağrılıyor (sıra ölçülür, varlık değil).
- **c)** `MapFallbackToFile(` **VAR** ve argümanı `index.html`.
- **d)** `wwwroot/index.html` **diskte VAR** ve `flutter_bootstrap.js` referansı taşıyor
  (yani gerçek bir Flutter çıktısı, boş bir yer tutucu değil).
- **e)** `.gitignore` `wwwroot`'u kapsıyor. 🔴 **`ORTAM.md`'nin `findstr` dersi:** bu **yokluk**
  ölçen ayak, **aynı dosyada** bir **varlık pozitif kontrolü** koşmak zorundadır.

### G44 — COOP/COEP/CORP başlıkları, KAPSAM AYRIMI OLMADAN
- **a)** `Cross-Origin-Opener-Policy` dizgesi **VAR** ve değeri `same-origin`.
- **b)** `Cross-Origin-Embedder-Policy` **VAR** ve değeri `require-corp`.
- **c)** 🔴 **Başlıkları yazan blok, `IsDevelopment()` koşulunun İÇİNDE DEĞİL.** Kapı,
  başlık satırının bulunduğu satır numarasının hiçbir `IsDevelopment()` bloğunun aralığına
  düşmediğini ölçer — dizge araması **yetmez** (`B-W1-5`'in tam olarak kaçırdığı şey).
- **d)** `Cross-Origin-Resource-Policy` **VAR** ve değeri `same-origin` (`D-W3-4`).
- **e)** Kapı `//` **ve** `/* */` yorumlarını atar ve bunu **pozitif kontrolle** kanıtlar
  (`ss2-kapisi.py`'nin oturum 56'da onarılan kör kapısı burada tekrarlanmayacak).

### G45 — Çapraz-köken alt-kaynak YOK (build çıktısında)
- **a)** `wwwroot/**` içindeki `.js`/`.html`/`.json` dosyalarında **`gstatic.com`** dizgesi **YOK**.
- **b)** **POZİTİF KONTROL:** aynı taramada `flutter_bootstrap.js` **bulunmalı ve boş olmamalı**;
  bulunamazsa kapı **KIRMIZI** verir (*"aradım, bulamadım"* ile *"aramadım"* ayrılır).
- **c)** `wwwroot/canvaskit/` dizini **VAR** ve içinde en az bir `.wasm` dosyası bulunuyor
  (yerelleştirmenin **fiilen** olduğunu ölçer, bayrağın yazıldığını değil).
- **d)** Hiçbir dosyada `https://` ile başlayan, `localhost` olmayan **çalışma zamanı** kaynak URL'si yok
  (beyaz liste: `schema.org`, `w3.org` gibi **yüklenmeyen** ad alanları — liste kapıda yazılıdır).

### G46 — CANLI HTTP ölçümü (backend ayakta)
- **a)** `GET /` yanıtı `Cross-Origin-Opener-Policy: same-origin` taşıyor.
- **b)** `GET /` yanıtı `Cross-Origin-Embedder-Policy: require-corp` taşıyor.
- **c)** `GET /sqlite3.wasm` ve `GET /drift_worker.js` **200** dönüyor ve `CORP: same-origin` taşıyor.
- **d)** 🔴 **FALLBACK API'Yİ YUTMUYOR:** `POST /v1/sync` başlıksız **401** döner
  (`index.html` + 200 **DEĞİL**) ve `GET /health/live` **200** + `Content-Type: application/json`
  (metin/html değil). `K61` kalkanının canlı olduğunu bu ayak kanıtlar.
- **e)** `GET /bilinmeyen-rota` **200** + `index.html` döner (SPA yönlendirmesi **fiilen** çalışıyor).

---

## 6. MUTANTLAR

🔴 **ÜÇÜNCÜ SÜTUN `hedef`TİR** (`K126`; araç `hucreler[2]`'den okur).
🔴 **`hedef` kümeleri BEKLENENDİR — `D-W3-6` yürürlükte:** build sonrası ölçülen küme
**geniş** çıkarsa (`gözlenen ⊇ hedef`) bu **aşırı-yakalamadır, kusur değildir** ve
**ERRATUM** ile düzeltilir; **dar** çıkarsa (`gözlenen ⊉ hedef`) **kör kapıdır, BLOKER**'dır.

| mutant | ne yapar | hedef (BEKLENEN) | beklenen sonuç | sınıf |
|---|---|---|---|---|
| M217 | `app.UseStaticFiles();` satırı silinir | `G43/a` · `D-W3-1` | G43/a KIRMIZI | statik |
| M218 | `MapFallbackToFile` satırı silinir | `G43/c` · `D-W3-1` | G43/c KIRMIZI | statik |
| M219 | `UseDefaultFiles`, `UseStaticFiles`'tan **SONRAYA** alınır | `G43/b` · `D-W3-1` | G43/b KIRMIZI | statik |
| M220 | `Cross-Origin-Opener-Policy` satırı silinir | `G44/a` · `G46/a` · `D-W3-2` | **ikisi de** KIRMIZI | statik + canlı |
| M221 | COEP değeri `require-corp` → `unsafe-none` | `G44/b` · `G46/b` · `D-W3-2` | **ikisi de** KIRMIZI | statik + canlı |
| M222 | 🔴 başlık bloğu `if (app.Environment.IsDevelopment()) { … }` içine alınır | `G44/c` · `D-W3-2` | G44/c KIRMIZI | statik |
| M223 | `Cross-Origin-Resource-Policy` satırı silinir | `G44/d` · `G46/c` · `D-W3-4` | **ikisi de** KIRMIZI | statik + canlı |
| M224 | 🔴 `MapFallbackToFile`, API uç eşlemelerinden **ÖNCEYE** alınır | `G46/d` · `D-W3-1` | G46/d KIRMIZI (401 yerine 200+HTML) | canlı |
| M225 | `wwwroot/flutter_bootstrap.js`'e `https://www.gstatic.com/x` eklenir | `G45/a` · `D-W3-3` | G45/a KIRMIZI | statik |
| M226 | 🔴 `wwwroot/flutter_bootstrap.js` **0 bayta** düşürülür (kapının kendi körlüğü) | `G45/b` · `D-W3-5` | G45/b KIRMIZI | statik |
| M227 | `wwwroot/canvaskit/` dizini geçici olarak yeniden adlandırılır | `G45/c` · `D-W3-3` | G45/c KIRMIZI | statik |
| M228 | başlık satırları `/* … */` bloğuna alınır (yorum kaçağı) | `G44/a` · `G44/b` · `G44/d` · `D-W3-5` | **üçü de** KIRMIZI | statik |
| M229 | `.gitignore`'dan `wwwroot` satırı silinir | `G43/e` · `D-W3-1` | G43/e KIRMIZI | statik |
| MW21 | 🔴 **NEGATİF KONTROL — hiçbir değişiklik yok** | — | **hiçbir kapı düşmez** | kontrol |

🔴 **GERİ ALMA — `ORTAM.md` PAZARLIKSIZ:** `git restore` **YASAK** (`core.autocrlf` bayt-özdeşliği
kör kılar). Doğru yol: `rb` ile ikili yedek → yamayı **bayt düzeyinde** uygula (dosya CRLF ise
desendeki `\n`'ler `\r\n`'e çevrilir) → kapıyı koş → **yedekten `wb` ile** geri yaz →
`sha256` ile özdeşliği **ÖLÇ**. Referans: `KANIT/A11/_mutant_kosucu.py`.

🔴 **MALİYET SINIFI (`K53/3`):** yukarıdakilerin **hiçbiri koşan uygulama (emülatör/tarayıcı +
yeniden derleme) istemez** — `M220`–`M224` yalnız **backend'in yeniden başlatılmasını** ister.
Koşan-uygulama mutant tavanı (3/dilim) bu dilimde **kullanılmamıştır**.

## 6b. MUTANT BORCU

- KURAL: D-W3-6 | GEREKCE: Bu bir META-KURALDIR: mutant SONUCLARININ nasil yorumlanacagini soyler, urunun ya da kapinin bir davranisini degil. Onu ihlal eden bir KOD degisikligi tanimlanamaz; ihlali ancak bir ELIN yanlis siniflandirma yapmasi olurdu ve bunun kapisi KANIT/W3 kabul hukmunun kendisidir. K145 bu kurali doguran vakadir.
- 🔴 **`G45/d` (beyaz listeli çalışma-zamanı URL taraması) MUTANTSIZDIR.** Gerekçe: beyaz listenin
  kendisi bu dilimde yazılıyor; bir mutant, listeyi test eden değil **listeyi tarif eden** olurdu
  (eşdeğer mutant sınıfı — `M167` vakası, `K130`). Kapatma yolu: liste ikinci bir dilimde
  gerçek bir dış bağımlılıkla sınandığında.
- 🔴 **`G46/e` (SPA yönlendirmesi) MUTANTSIZDIR.** Gerekçe: onu düşürecek tek değişiklik `M218`'dir
  ve o zaten `G43/c`'yi hedefliyor; ayrı bir mutant **eşdeğer** olurdu.

---

## 7. KABUL KRİTERLERİ (Cowork **kendi** koşar — `K26`; Code'un beyanı kanıt değildir)

1. `flutter analyze --fatal-infos` → **EXIT 0**.
2. `flutter test` → **EXIT 0**; taban **539** (oturum 60'ta ölçüldü) ⇒ sayı **kopyalanmaz, ölçülür**.
3. `python araclar/izolasyon-kapisi.py --altin-kume` → **EXIT 0**; küme **temizde susar, kirlide ısırır**.
4. `python araclar/izolasyon-kapisi.py .` → **EXIT 0** (`G43`·`G44`·`G45` yeşil).
5. `python araclar/spec-kapi-kapsama.py GOREV_CLAUDE_CODE/GOREV-W3-capraz-koken-izolasyonu.md` → **EXIT 0**.
6. **13 mutant + `MW21`**: her biri hedefini düşürür, `MW21` **hiçbir kapıyı düşürmez**,
   geri almalar **bayt-özdeş** (sha8 ile ölçülür). Sapma varsa `D-W3-6` sınıflandırması uygulanır.
7. **CANLI:** ortam `K80` maddesiyle kaldırılır → `_izolasyon_http_olc.py` → `G46/a`–`e` **yeşil**.
8. `verify.ps1` (backend **kapatıldıktan sonra**, `netstat` ile **ölçülerek**) → **EXIT 0**.
9. Dört açılış kapısı + `radar --olc-urun-kodu <taban-sha>` → **`urun_kodu_satiri > 0`**
   ⇒ 🔴 **`R8` bu dilimle düşer** (oturum 60 = 0 ölçüldü; bu dilim ürün kodu üretmezse `R8` yanar).
10. `git status --porcelain` → `wwwroot` **görünmez** (`.gitignore` fiilen çalışıyor).
11. `ADR 0004` gövdesi yazılmış; alt-soru **1·2·3 ölçümle KAPALI**, **4·5 borç olarak AÇIK**.
12. Ham çıktılar `KANIT/W3/` altında; kabul hükmü `KANIT/W3/…-COWORK-KABUL-HUKMU.md`.

---

## 8. BEYAN EDİLMİŞ SINIRLAR (kabul bunları KAPATMAZ)

1. 🔴 **`B-W3-1` — TARAYICI AYAĞI ÖLÇÜLMEZ.** Bu dilim **sunucunun izolasyonu sağladığını**
   kanıtlar; *"Chrome `crossOriginIsolated` oldu ve drift `opfsLocks` seçti"* iddiası
   **[ÖLÇÜLMEDİ]** kalır (`D-W3-5`). Bu, dilimin **en büyük** deliğidir ve gizlenmemiştir.
2. 🔴 **`fonts.gstatic.com` geri-düşüşü:** `--no-web-resources-cdn`'in onu da kapattığı
   **[ÖLÇÜLMEDİ]**. `G45/a` bulursa **KIRMIZI** verir; kapanmazsa borç yazılır ve
   *"izolasyon açık ama font geri-düşüşü bloklanıyor"* durumu **beyan edilir**.
3. 🔴 **Service worker / PWA:** `flutter_service_worker.js` üretiliyor; `require-corp` altındaki
   davranışı **[ÖLÇÜLMEDİ]**, bu dilim ona dokunmaz.
4. 🔴 **SignalR:** `require-corp`'un WebSocket/uzun-yoklamaya etkisi yalnız `G46`'nın dolaylı
   ölçümüyle görülür; **ayrı bir kapısı YOKTUR** (`ADR 0004` alt-soru 2, kısmen açık).
5. 🔴 **`G44/c`'nin ölçüm biçimi:** satır-aralığı analizi bir **ayrıştırıcı değildir**;
   iç içe koşullar veya `switch` gibi biçimlerde yanılabilir. `M222` onu **bir** biçim için
   kanıtlar, **her** biçim için değil.
6. 🔴 **`wwwroot` git-ignore edilir** ⇒ depoyu klonlayan biri `flutter build web` koşmadan
   siteyi göremez. Bu **bilinçlidir** (kırmızı çizgi 5) ve README borcunun bir parçasıdır.

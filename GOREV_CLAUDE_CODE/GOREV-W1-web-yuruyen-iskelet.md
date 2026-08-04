# GOREV-W1 **v2** — WEB YÜRÜYEN İSKELETİ (CORS + tarayıcıda çalışma kanıtı)

> **Yazan:** Cowork, oturum 57 (4 Ağu 2026) · **Koşacak el:** Claude Code · **Kapsam kilidi:** Onur, şık **B**
> **Kapılar:** `W1/G35`–`W1/G38` (K108: atıf daima kapsam önekli) · **Mutantlar:** `M189`–`M199`
> **v1 kimliği `DFA8FF77` (19.941 b) GEÇERSİZDİR.**
>
> 🔒 **K137 — ONUR KİLİTLEDİ (4 Ağu 2026, oturum 57).** Kilit satırından
> **ÖNCEKİ** kimlik `606F04F5` (32.801 b) **GEÇERSİZDİR**; kanonik kimlik `DURUM.md` §9'dadır.
> Değişen her bayt kilidi bozar. Denetim çıktı yolları `## 0`'dadır (`K127` şartı ÖDENDİ).
>
> 🔴 **`K127` — KİLİTTEN ÖNCE BAĞIMSIZ DENETİM KOŞTU.** İki denetçi, iki ayrı mercek:
> - `KANIT/W1/00-DENETIM-kosulabilirlik.md` (33.763 b · `6000E9A4`) — **3 bloker · 7 major · 5 minor**
> - `KANIT/W1/00-DENETIM-kor-kapi.md` (34.690 b · `269D1F22`) — **3 bloker · 6 major · 3 minor**
>
> 🔴 **`K53/1` — TUR TAVANI 1.** Altı blokerin **hiçbiri mimariyi değiştirmiyor** (her biri bir
> bayrak, bir başlık adı ya da bir ölçüm sırası) ⇒ **ikinci tur AÇILMAZ**: düzelt → kilitle.

---

## 0. TUR 1 DENETİMİ NE BULDU — ALTI BLOKER NASIL KAPANDI

| # | denetçi | bloker | v2'de kapanışı |
|---|---|---|---|
| K1 | koşulabilirlik | **`Content-Type` unutulmuş.** `http_senkron_agi.dart` isteği `Content-Type: application/json` gönderiyor; v1'de bu kelime **hiç geçmiyordu** ve `G35/d` + `M192` `AllowAnyHeader()`'ı **yasaklıyordu** ⇒ dört kapı da YEŞİL kalırken **Chrome isteği bloklardı** | `D-W1-8` · `G35/d` iki başlığı da **adıyla** ister · `G36/a` preflight'ta ikisini birden sorar · `M192` + `M192b` |
| K2 | koşulabilirlik | **`G38/b` koşulamaz.** İstemci `devUserId`'yi **rastgele** üretiyor, hiçbir yere basmıyor; sunucu `owner_id` kapsamlı ⇒ *"sunucuda üret, web'e insin"* adımının **sahibi belirsizdi** | `D-W1-9` · `## 4b` ③ artık `--dart-define=DEV_USER_ID=<sabit GUID>` taşıyor · `G38/a`/`G38/b` sorguları **owner_id ile** yazıldı |
| K3 | koşulabilirlik | **Koşan mutantları, F5'i ve ekran görüntüsünü KİMİN koşacağı yazılı değildi.** `## 7` *"hepsi Cowork'ün koşumuyla"* derken `K80` *"Cowork ortamı KALDIRMAZ, YENİDEN BAŞLATMAZ"* diyor — spec kendi içinde çelişiyordu | Yeni **`## 4c` EL DAĞILIMI**: Code **koşar**, Cowork **ham çıktıdan ölçer** · `G37`'ye artefakt atandı (`KANIT/W1/_web_kanit.py`) |
| B1 | kör kapı | **`G37/b` KÖRDÜ.** `main.dart:56` her açılışta `cekmeTuruCalistir()` koşuyor ve imleç **aynı Drift DB'sinde** ⇒ yerel kalıcılık **tamamen çökse bile** imleç de kaybolur, sunucu görevleri geri verir, F5 sonrası görev **görünür** | `G37/b` artık **backend KAPALIYKEN** ölçülür; kapanış `netstat` ile **ÖLÇÜLÜR** · `M199` |
| B2 | kör kapı | **`M196` EŞDEĞERDİ.** İzin listesini 5001 yapmak `G36/b`'yi değil `G36/a`'yı düşürüyordu; `b`'nin gerçek hedefi **origin-yankılayan** politikadır | `M196` yeniden kuruldu: `SetIsOriginAllowed(_ => true)` ⇒ `evil.local` başlık **alır** ⇒ `G36/b` **ısırır** |
| B3 | kör kapı | **`AddCors` yarısı hiçbir ayakta ölçülmüyordu.** `G35/b` yalnız `UseCors`'u konumlandırıyordu; `AddCors` üretimde de kaydedilse dört kapı da yeşildi. Ayrıca `Program.cs`'te **zaten** bir `IsDevelopment()` bloğu var, spec hangisi olduğunu yazmıyordu | `D-W1-2` işaret yorumunu (`// W1/D-W1-2`) zorunlu kıldı · `G35/b` **ikisini birden** blok aralığında arar · `M190` + `M190b` |

🟢 **Denetimin lehte bulguları da ölçülmüştür:** `## 2` taban tablosunun **7/7 satırı** bağımsız
doğrulandı. **`SS2`'nin `KOŞULAMAZ KABUL ŞARTI` kusuru TEKRARLANMAMIŞ**: *"görev ekle"*
(`GorevEkleAlani`) ve *"Yenile"* (`ValueKey('elle_yenile_dugmesi')`) etkileşimleri üründe
**gerçekten var** ve üretim yolunda etkin.

---

## 1. AMAÇ

Web hedefini **koşan** hâle getirmek: tarayıcıda uygulama açılır, görev eklenir, **sayfa yenilenince
durur**, backend açıkken **senkron olur**. Bunun önündeki tek ölçülmüş bloker **backend'de CORS
politikasının hiç olmamasıdır** — ve bu kusur **derleme başarısıyla GÖRÜNMEZ**.

🔴 Bu spec `K53/5`'in ürünüdür: **YÜRÜYEN İSKELET ÖNCE, KAPILAR SONRA.** Tam web spec'i (⑨'un
orijinal hâli) **bilerek yazılmadı** — 100k token, 0 ürün kodu demekti ve oturum 57'de **mutantla
kanıtlandı** ki sıfır ürün koduyla kapanmak `R8` sert durağını yakar (`KANIT/o57/_o57_r8_mutant.py`:
kontrol ⇒ R8 susuyor · mutant ⇒ *"son 2 oturumda (oturum [56, 57]) tek satır ÜRÜN kodu projeye
girmedi. SERT DURAK"*).

---

## 2. ÖLÇÜLMÜŞ TABAN (**4 Ağu 2026, oturum 57** · 7/7 satır **bağımsız denetçi tarafından yeniden ölçüldü**)

| ölçüm | sonuç | kanıt |
|---|---|---|
| `flutter build web` | **EXIT 0**, 57,3 s · `main.dart.js` 2.742.074 → **2.769.788 b**, mtime **15:38:03** | `KANIT/o57/_o57_web_olcum.py` |
| Drift web bağlantısı | **TAM BAĞLI**: `driftDatabase(name:'momentum', web: DriftWebOptions(sqlite3Wasm:'sqlite3.wasm', driftWorker:'drift_worker.js', onResult: …))` | `lib/veri/veritabani.dart` |
| ölçüm kancası | `onResult` **zaten** `MOMENTUM-G6-KANIT chosenImplementation=… missingFeatures=…` basıyor | aynı dosya |
| `web/sqlite3.wasm` · `web/drift_worker.js` | **yerinde** | `src/client/web/` |
| `kIsWeb` | tüm `lib/` içinde **yalnız 2**: `:5` `import … show kIsWeb;` ve `:100` `if (kIsWeb) {` | `KANIT/o57/_o57_web_yuzey.py` |
| **backend CORS** | 🔴 **92 backend dosyasının HİÇBİRİNDE** `AddCors`/`UseCors`/`WithOrigins`/`AllowAnyOrigin` **YOK** (pozitif kontrol geçti: `builder.Services` 1 · `app.Map` 6 · `using` 58) | `KANIT/o57/_o57_cors.py` |
| `_senkronSunucuUrl` | varsayılan `http://10.0.2.2:5298` — **Android emülatör takma adı**; `String.fromEnvironment('SENKRON_SUNUCU_URL')` ile ezilebiliyor | `lib/main.dart` |

🔴 **Neden bloker:** tarayıcı `http://localhost:5000`'de, API `:5298`'de ⇒ **farklı origin**. İstek
hem `Content-Type: application/json` hem `X-Momentum-Dev-User` taşıdığı için tarayıcı **önce
preflight `OPTIONS`** atar; politika yoksa preflight boş döner ve **her senkron isteği daha gövde
gitmeden düşer**.

---

## 3. KARARLAR

### D-W1-1 — CORS DAR OLUR, AÇIK OLMAZ; İZİN LİSTESİ **YAPILANDIRMADAN** OKUNUR

`AllowAnyOrigin()` **ve** origin-yankılayan her desen (`SetIsOriginAllowed(_ => true)`) **YASAK**.
İzinli origin listesi `appsettings.Development.json` → `Cors:AllowedOrigins` dizisinden okunur;
liste **boşsa politika hiç kaydedilmez**. Kodda çıplak literal origin **yazılmaz** (denetim MAJOR-4:
v1 bu noktada kendi `T1` maddesiyle çelişiyordu).
🔴 Ölçülmüş gerekçe: `K61` dev-kimlik kalkanı `X-Momentum-Dev-User` gören her isteğe **200** dönüyor.
`AllowAnyOrigin` + bu kalkan birlikte, kullanıcının açtığı **herhangi bir web sayfasının** onun görev
verisini okuyabilmesi demektir. Kırmızı çizgi 2 (PII minimumda). → `M191`, `M191b`, `M196`

### D-W1-2 — `AddCors` **VE** `UseCors` İKİSİ DE YALNIZ `Development` BLOĞUNDA; BLOK **İŞARETLİDİR**

İkisi de `IsDevelopment()` koşulunun **içindedir** ve o blok **`// W1/D-W1-2`** yorum işaretini taşır.
🔴 İşaret zorunludur çünkü `Program.cs`'te **zaten başka bir `IsDevelopment()` bloğu var** (`:49`,
`K61` dev-kimlik kalkanı) ve kapı hangi bloğa bakacağını **tahmin edemez** (denetim BLOKER-3).
Üretimde politika **var olmaz**, susturulmaz — `K61`'in deseninin aynısı. → `M190`, `M190b`

### D-W1-3 — SIRA DERLEMEDE GÖRÜNMEZ ⇒ PREFLIGHT **CANLI** ÖLÇÜLÜR

`UseCors`, uç nokta yürütmesinden **önce** çalışmalıdır. Minimal API'de ara katman sırası
**örtüktür** ve yanlış sıra **derlemeyi hiç bozmaz**; preflight sessizce boş döner.
🔴 v1'in gerekçesi `UseRouting`'e atıfla yazılmıştı ve **YANLIŞTI**: `Program.cs`'te `UseRouting`
**hiç geçmiyor** (denetim MAJOR-7). Sonuç aynı, gerekçe düzeltildi. → `M195`

### D-W1-4 — `main.dart`'a TEK BAYT YAZILMAZ

Web `--dart-define` ile koşulur. `_senkronSunucuUrl` ve `devUserIdEzmesi` **zaten**
`String.fromEnvironment`; ikinci bir derleme-zamanı okuma eklemek `K77`'nin açıkça yasakladığı
şeydir (`main.dart` içindeki yorum bunu yazıyor). → `M197`

### D-W1-5 — SIGNALR WEB'DE KAPALI KALIR

`if (kIsWeb)` dalı **korunur**. Borç değil, `K77/3`'te **beyan edilmiş sınırdır**: tarayıcı WS
upgrade'ine özel başlık koyamaz. Web'de tazeleme: **açılış çekmesi + Yenile + yerel yazma**.
→ `M194`

### D-W1-6 — "KALICI" İDDİASI **BACKEND KAPALIYKEN** YAZILIR

🔴 Denetim BLOKER-1: `main.dart:56` her açılışta `cekmeTuruCalistir()` koşuyor ve imleç
(`nextCursorJson`) **aynı Drift veritabanında** duruyor ⇒ yerel depo **tamamen çökse bile** imleç de
kaybolur, sunucu görevleri baştan verir ve F5 sonrası görev **listede görünür**. Yani backend açıkken
yapılan bir F5 testi **kalıcılığı değil senkronu** ölçer. Ölçüm **backend KAPALIYKEN** koşulur;
kapanış `netstat -ano | findstr :5298` **boş** dönerek **ölçülür**. → `M199`

### D-W1-7 — WEB PORTU `5000`'e SABİTLENİR (`--web-port=5000`)

🔴 `flutter run -d chrome` varsayılan olarak **rastgele port** seçer; sabit port yazan bir izin
listesi kapıyı **yanlış-negatif** yapar ve bunu *"web çalışmıyor"* diye okuruz. Port **sabitlenir**,
`Cors:AllowedOrigins` **aynı portu** yazar, `G36/b` listenin **gerçekten daralttığını** kanıtlar.

### D-W1-8 — İZİNLİ BAŞLIKLAR **İKİ TANEDİR** VE İKİSİ DE **ADIYLA** YAZILIR

`Content-Type` **ve** `X-Momentum-Dev-User`.
🔴 Denetim BLOKER-1: `http_senkron_agi.dart` isteği `Content-Type: application/json` ile gönderiyor.
Bu, tarayıcının *"basit istek"* tanımının **dışındadır** ⇒ tek başına bile preflight tetikler.
v1 `AllowAnyHeader()`'ı yasaklayıp yalnız `X-Momentum-Dev-User`'ı istiyordu: **dört kapı da YEŞİL
kalırken Chrome isteği bloklardı.** Kapının kendisi kusuru üretiyordu. → `M192`, `M192b`

### D-W1-9 — WEB VE SUNUCU-TARAFI PROB **AYNI SABİT KİMLİĞİ** KULLANIR

Web `--dart-define=DEV_USER_ID=<sabit GUID>` ile koşulur; `G38`'in `psql` sorguları ve
`POST /v1/sync` probu **aynı GUID'i** kullanır.
🔴 Denetim BLOKER-2: istemci `devUserId`'yi **rastgele üretiyor** ve hiçbir yere basmıyor; sunucu
tarafı `owner_id` kapsamlı ve tabloda **zaten onlarca sahip** var ⇒ sabit kimlik olmadan
*"web'de eklediğim satır sunucuda görünüyor mu"* sorusu **cevaplanamaz**, yalnız *"bir satır arttı"*
denebilirdi. `ayarlari_hazirla.dart` bu ezmeyi **zaten uyguluyor** ve GUID formatını `SS3/c` ile
zorluyor. → `M197`

---

## 4. YAPILACAKLAR (sıra PAZARLIKSIZ — `K53/5` + `K44-a`)

1. **T1 — ÜRÜN KODU:** `src/backend/Momentum.Api/Program.cs`'e `D-W1-1`/`D-W1-2`/`D-W1-8`'e uyan CORS
   politikası (`// W1/D-W1-2` işaretli blok içinde) + **`appsettings.Development.json`** (bugün
   **YOK** — denetim MAJOR-3) → `Cors:AllowedOrigins: ["http://localhost:5000"]`.
2. **T2 — ÖNCE ARAÇ (`K44-a`):** `araclar/cors-kapisi.py` + **kendi altın kümesi**. Araç **iki
   dillidir**: `.cs` ve `.dart` tarar; yorum atlama **hem `//` hem `/* */`** yolunu keser
   (`ss2-kapisi.py`'nin `K135`'te onarılan mantığı **yeniden yazılmaz, oradan alınır**).
3. **T3 — CANLI PROB:** `KANIT/W1/_preflight.py` — `G36`'nın üç ayağını ölçer, ham istek/yanıt
   başlıklarını dosyaya yazar.
4. **T4 — ORTAM (`## 4b`) kurulur ve web koşulur.**
5. **T5 — `G37` + `G38` ölçümü:** `KANIT/W1/_web_kanit.py` konsolu yoklar, `MOMENTUM-G6-KANIT`
   satırını **birebir** yakalar; ham çıktılar `KANIT/W1/`'e.
6. **T6 — MUTANTLAR** (`## 6`), sonra kabul koşumu.
7. **T7 — BORÇLAR:** `B-W1-1` · `B-W1-2` `BORCLAR.md`'ye yazılır. 🔴 `BORCLAR.md` **bugün SARI**
   (31.923 / 32.768, pay **845 b**, eşik 1.638) ⇒ yazım kapıyı **KIRMIZI** yapabilir; o an
   **budama/tavan kararı `K40` gereği ONUR'DAN** istenir, spec kendi başına tavana dokunmaz.

---

## 4b. ORTAMI KİM KALDIRIR [`K80` — PAZARLIKSIZ]

**Ortamı Claude Code kaldırır. Cowork KALDIRMAZ, yalnız ÖLÇER.** Üç adım **sırayla**:

① `docker start momentum-postgres` → `docker ps` çıktısında **`(healthy)`** görünene kadar
**yoklanır** (tavanlı). 🔴 **Sabit `sleep` bir ölçüm değildir** (oturum 35: 22 sn beklenip yanlış
KIRMIZI verildi).

② Backend **ayrı pencerede**, `ORTAM.md` reçetesiyle:
`cd C:\dev\Momentum\src\backend\Momentum.Api` → `ASPNETCORE_ENVIRONMENT=Development` (🔴 `K61`;
yoksa **her istek 401**) → `ASPNETCORE_URLS=http://0.0.0.0:5298` →
`ConnectionStrings__Momentum=Host=localhost;Port=5432;Database=momentum;Username=momentum;Password=momentum_dev`
→ `dotnet run`.
🔴 **HAZIR OLMA PORTLA ÖLÇÜLMEZ.** Zorunlu üçlü: `/health/live` **200** · `/health/ready` **200** ·
`POST /v1/sync` başlıksız **401**, `X-Momentum-Dev-User` ile **200**. Hazır betik:
`KANIT/A11/_backend_dogrula.py`. 🔴 Probdaki `clientId` **geçerli GUID** olmalıdır — dize
gönderilirse uç **500** döner ve bu **backend'in değil PROBUN kusurudur** (`ORTAM.md`).

③ Tarayıcı — **tam yolla ve kalkanla** (`ORTAM.md`: `flutter` bu makinede `.bat`'tir, Python
`subprocess` PATHEXT'i çözmez; DC kabuğunda `PROGRAMFILES(X86)` **enjekte edilmezse** çöker):
`cd C:\dev\Momentum\src\client` →
`C:\src\flutter\bin\flutter.bat run -d chrome --web-port=5000 --dart-define=SENKRON_SUNUCU_URL=http://localhost:5298 --dart-define=DEV_USER_ID=<sabit GUID>`

🔴 **PID, port ve "çalışıyor" beyanı hiçbir belgeye YAZILMAZ — ÖLÇÜLÜR:** `docker ps` ·
`netstat -ano | findstr :5298` · `netstat -ano | findstr :5000`.
🔴 **`verify.ps1` ÇALIŞAN BACKEND VARKEN KOŞULAMAZ** (`ORTAM.md`, oturum 50: EXIT 1 + 36 `MSB3026`).
**Sıra: `G36`+`G38` (backend ÇALIŞIR) → `G37/b` (backend KAPALI, `D-W1-6`) → `verify.ps1`.**

---

## 4c. EL DAĞILIMI [denetim BLOKER-3'ün kapanışı]

v1 *"hepsi Cowork'ün kendi koşumuyla"* diyordu ama `K80` *"Cowork ortamı KALDIRMAZ, YENİDEN
BAŞLATMAZ"* diyor — **spec kendi içinde çelişiyordu.** Ayrım:

| iş | KİM |
|---|---|
| docker/backend/tarayıcı kaldırma, **yeniden başlatma**, F5, ekran görüntüsü | **Claude Code** |
| koşan mutantlar (`M195`–`M197`, `M199`) — backend/derleme yeniden başlatma gerektirenler | **Claude Code** |
| statik kapılar, statik mutantlar, `--altin-kume` koşumları, bayt-özdeşlik ölçümü | **Cowork** |
| `_preflight.py` / `_web_kanit.py` **ham çıktılarının** okunması ve hüküm | **Cowork** |
| `verify.ps1`, `flutter analyze`, `flutter test` | **Cowork** (backend KAPALI iken) |

🔴 **Kabul, ham çıktıdan verilir — beyandan değil.** Code *"koştu, geçti"* derse Cowork o cümleyi
**kanıt saymaz**; `KANIT/W1/` altındaki dosyayı **kendisi açar** (`K26`).

---

## 5. KAPILAR

> Her ayak **nasıl ölçüldüğünü** yazar; yazmayan ayak **kördür**. Mutantı olmayan her ayak/kural
> `## 6b`'de **gerekçesiyle** beyan edilir.

### G35 — CORS POLİTİKASI VAR, DAR VE YALNIZ DEVELOPMENT

Ayaklar `araclar/cors-kapisi.py` ile **kod satırında** ölçülür — 🔴 `//` **ve** `/* */` yorumları
**atılarak**. (`K135`: `ss2-kapisi.py`'nin **blok yorum** kör kapısı bu projede ısırdı; yorumdaki
bir dize kod sanılıp kapı yeşil döndü. Denetim MAJOR-2: v1'in üç yorum mutantı da `//` yoluydu ⇒
`K135`'in **asıl** kusurunu ölçmüyorlardı.)

- **a)** `AddCors` **ve** `UseCors` **ikisi de** kod satırında geçer. → `M189`, `M189b`, `M193`, `M193b`, `M193c`
- **b)** **İkisi de** `// W1/D-W1-2` işaretli `IsDevelopment()` bloğunun **metin aralığındadır**
  (`D-W1-2`). Dosya geneli araması **yetmez** — `Program.cs:49`'da **başka** bir `IsDevelopment()`
  bloğu vardır. *Ölçüm:* işaretten başlayan blok-aralığı araması. → `M190`, `M190b`
- **c)** `AllowAnyOrigin` **ve** `SetIsOriginAllowed` kod satırında **hiç geçmez**; izinli origin
  `Cors:AllowedOrigins` yapılandırmasından okunur (`D-W1-1`). → `M191`, `M191b`
- **d)** İzinli başlıklar arasında **`Content-Type` ve `X-Momentum-Dev-User`** **adıyla** geçer
  (`D-W1-8`). 🔴 Yalnız `AllowAnyHeader()` **yetmez**; yalnız biri de **yetmez**. → `M192`, `M192b`
- 🔴 **POZİTİF KONTROL (PAZARLIKSIZ):** kapı, aynı dosyada **var olduğu bilinen** bir dizgeyi
  (`builder.Services.AddMediator` — `Program.cs:38`'de ölçüldü) de arar. Bulamazsa **`ORTAM HATASI`**
  verir ve **YEŞİL DEMEZ**. Gerekçe `ORTAM.md`: bu makinede bir tarayıcı aynı dosyada bir dizgeyi
  bulup diğerini **kaçırdı**; yokluk ölçen her ayak bir **varlık** kontrolü koşmak zorundadır.

### G36 — PREFLIGHT **CANLI** ÖLÇÜLÜR (koşan backend)

`KANIT/W1/_preflight.py` ile ölçülür; ham istek/yanıt başlıkları **dosyaya yazılır**.

- **a)** *(pozitif)* `OPTIONS /v1/sync` · `Origin: http://localhost:5000` ·
  `Access-Control-Request-Method: POST` ·
  `Access-Control-Request-Headers: content-type, x-momentum-dev-user`
  ⇒ **204 ya da 200** (ASP.NET Core CORS ara katmanı **204** döner) **ve** yanıtta
  `Access-Control-Allow-Origin: http://localhost:5000` (🔴 **`*` DEĞİL**) **ve**
  `Access-Control-Allow-Headers` **her iki başlığı da** içerir. → `M189`, `M192`, `M195`
- **b)** *(negatif — kapının DARALTTIĞINI kanıtlar)* Aynı preflight `Origin: http://evil.local` ile
  ⇒ `Access-Control-Allow-Origin` **DÖNMEZ**. 🔴 Bu ayağın gerçek hedefi **origin-yankılayan**
  politikadır (`SetIsOriginAllowed(_ => true)`) — düz `AllowAnyOrigin`'i `a` zaten yakalar
  (denetim BLOKER-2: v1'in `M196`'sı bu yüzden **eşdeğerdi**). → `M196`
- **c)** Gerçek `POST /v1/sync` · `Origin: http://localhost:5000` ·
  `Content-Type: application/json` · `X-Momentum-Dev-User: <sabit GUID>` · gövdede `clientId`
  **geçerli GUID** ⇒ **200** ve yanıtta `Access-Control-Allow-Origin`. → `M195`

### G37 — WEB'DE AÇILIYOR VE **KALICI** (koşan tarayıcı)

- **a)** Uygulama `## 4b` ③ komutuyla açılır; konsolda
  `MOMENTUM-G6-KANIT chosenImplementation=<X> missingFeatures=<Y>` satırı **birebir** yakalanır ve
  `KANIT/W1/` altına **ham** yazılır. *Artefakt:* `KANIT/W1/_web_kanit.py`. 🔴 Sabit `sleep` YOK —
  satır görünene kadar **yoklanır**, tavanlı (`ORTAM.md`, `uiautomator dump` dersi). → `M199`
- **b)** 🔴 **BACKEND KAPALIYKEN** (`D-W1-6`; kapanış `netstat -ano | findstr :5298` **boş** dönerek
  ölçülür): görev eklenir → **F5** → görev **hâlâ listededir**. *Ölçüm:* yenileme **sonrası** ikinci
  `MOMENTUM-G6-KANIT` satırı + ekran görüntüsü + listedeki başlığın **birebir metni**.
  🔴 Backend AÇIKKEN yapılan aynı test **kalıcılığı değil senkronu** ölçer ve yerel depo tamamen
  çökse bile YEŞİL döner — v1'in kör noktası buydu. → `M199`
- **c)** `missingFeatures` **boş değilse** hangi özelliğin eksik olduğu ve hangi implementasyona
  **düşüldüğü** `KANIT/W1/`'de ve kabul hükmünde **açıkça** yazılır. Sessiz geçmek YASAK.
  → `M199`
- **d)** *(statik — ÖLÇÜM KANCASI KODDA DURUR)* `lib/veri/veritabani.dart`'ta `DriftWebOptions`'ın
  `onResult` gövdesi **kod satırında** `MOMENTUM-G6-KANIT` önekini basar. *Ölçüm:* `cors-kapisi.py`,
  `//` **ve** `/* */` atılarak, **blok aralığı** `driftDatabase(` çağrısıyla sınırlı.
  🔴 Bu ayak `G37`'nin **tamamının** dayandığı kanıt zincirini korur: önek silinirse `a`, `b`, `c`'nin
  **hiçbiri ölçülemez** ve kapı **sessizce kanıtsız** kalır. → `M198`, `M198b`

### G38 — WEB ↔ BACKEND SENKRON (koşan uçtan uca)

Sorgular `DEV_USER_ID` ile **aynı sabit GUID'i** kullanır (`D-W1-9`).

- **a)** Web'de eklenen görev **sunucu veritabanında görünür**. 🔴 *Ölçüm ekrandan DEĞİL:*
  `docker exec momentum-postgres psql -U momentum -d momentum -t -c "select count(*) from tasks where owner_id = '<GUID>' and title = '<W1-DENEME-BASLIK>';"`
  ⇒ **1**. **POZİTİF KONTROL:** aynı sorgu ekleme **öncesi** koşulur ve **0** döner; iki ölçüm de
  `KANIT/W1/`'e yazılır (denetim MAJOR-3: saf yokluk ölçen bir beklenti kendi kuralımızı çiğnerdi).
  → `M197`
- **b)** Sunucuda **aynı GUID sahibiyle** üretilen bir değişiklik (doğrudan `POST /v1/sync`) web'de
  **Yenile** (`ValueKey('elle_yenile_dugmesi')`) sonrası **iner**. → **mutantsız, `## 6b`'de beyanlı**
- **c)** Web'de gerçek zamanlı sinyalin **KAPALI** olduğu **statik olarak** ölçülür:
  `ag/signalr_json_sinyal.dart`'ta **`if (kIsWeb) {` satırı** durur (`D-W1-5`). 🔴 Çıplak `kIsWeb`
  dizgesi aranmaz — o dizge `:5`'teki `import … show kIsWeb;` satırında da geçer ve dal silinse bile
  kapı **susardı** (denetim MAJOR-1). → `M194`

---

## 6. MUTANTLAR

**Maliyet sınıfı (`K53/3`) — v1'in aritmetiği YANLIŞTI (denetim MAJOR-1).** `M195`/`M196` yalnız
**backend yeniden başlatma** ister (derleme/tarayıcı **istemez**) ⇒ *koşan uygulama* sınıfında
değildir. O sınıfta yalnız **`M197` ve `M199`** vardır ⇒ **2 / 3**, tavan **DOLU DEĞİL**. Statikler
**tavansızdır**.
🔴 **Sütun düzeni PAZARLIKSIZ: `hedef` ÜÇÜNCÜ SÜTUNDUR** (`K126`; `A13`'te dördüncü sütuna yazıldığı
için **sekiz mutantın hiçbiri hiçbir kapıya bağlanmadı**).

| mutant | sınıf | hedef | ne bozulur | beklenen |
|---|---|---|---|---|
| M189 | statik | `W1/G35/a` | `app.UseCors(...)` satırı **silinir** | `cors-kapisi.py` **KIRMIZI** |
| M189b | statik | `W1/G35/a` · `D-W1-2` | `builder.Services.AddCors(...)` **silinir** (`UseCors` kalır) | `cors-kapisi.py` **KIRMIZI** — `a`'nın **AND**'inin ikinci yarısı; v1'de bu yarı **hiç ölçülmüyordu** (denetim BLOKER-3) |
| M190 | statik | `W1/G35/b` · `D-W1-2` | `UseCors` `// W1/D-W1-2` bloğunun **dışına** taşınır (dosyada hâlâ VAR) | `cors-kapisi.py` **KIRMIZI** — dosya-geneli arama burada **susar**, blok-aralığı araması ısırır |
| M190b | statik | `W1/G35/b` · `D-W1-2` | `AddCors` bloğun **dışına** taşınır (üretimde de kaydedilir) | `cors-kapisi.py` **KIRMIZI** |
| M191 | statik | `W1/G35/c` · `D-W1-1` | `WithOrigins(yapılandırma)` → `AllowAnyOrigin()` | `cors-kapisi.py` **KIRMIZI** |
| M191b | statik | `W1/G35/c` · `D-W1-1` | Kod **bozulmaz**; `AllowAnyOrigin` dizgesi **yalnız yorumda** geçer | `cors-kapisi.py` **SUSMALI** — 🔴 yokluk ölçen `c` ayağının **yanlış-pozitif kontrolü**; v1'de yokluk ayağı **kontrolsüzdü** (denetim MAJOR-5) |
| M192 | statik | `W1/G35/d` · `D-W1-8` | İzinli başlıklardan **`Content-Type`** çıkarılır (`X-Momentum-Dev-User` kalır) | `cors-kapisi.py` **KIRMIZI** — 🔴 v1'in **BLOKER-1**'i tam olarak buydu ve **hiçbir kapı yakalamıyordu** |
| M192b | statik | `W1/G35/d` · `D-W1-8` | İzinli başlıklardan **`X-Momentum-Dev-User`** çıkarılır | `cors-kapisi.py` **KIRMIZI** |
| M193 | statik | `W1/G35/a` | Gerçek `app.UseCors(...)` **silinir**, doğru satır **yalnız `//` yorumunda** bırakılır | `cors-kapisi.py` **KIRMIZI** — `//` yorum-atlamanın yük taşıdığını ölçer |
| M193b | statik | `W1/G35/a` | Kod **bozulmaz**; yalnız **fazladan `//` yorum** eklenir | `cors-kapisi.py` **SUSMALI** — yanlış-pozitif kontrolü |
| M193c | statik | `W1/G35/a` | Gerçek `app.UseCors(...)` **silinir**, doğru satır **yalnız `/* … */` BLOK yorumunda** bırakılır | `cors-kapisi.py` **KIRMIZI** — 🔴 `K135`'in **asıl** kusuru blok yoldu; v1'in üç yorum mutantı da `//` olduğu için o yolu **hiç ölçmüyordu** (denetim MAJOR-2) |
| M194 | statik | `W1/G38/c` · `D-W1-5` | `signalr_json_sinyal.dart`'ta **`if (kIsWeb) {` dalı silinir**, `import … show kIsWeb;` **bırakılır** | `cors-kapisi.py` **KIRMIZI** — çıplak dizge arayan bir kapı burada **susar** ve yakalanır |
| M198 | statik | `W1/G37/d` | `veritabani.dart`'ta `onResult` gövdesindeki `MOMENTUM-G6-KANIT` öneki **değiştirilir** (kod derlenir) | `cors-kapisi.py` **KIRMIZI** |
| M198b | statik | `W1/G37/d` | Gerçek `print` **silinir**, önek **yalnız `/* … */` blok yorumunda** bırakılır | `cors-kapisi.py` **KIRMIZI** |
| M195 | koşan sunucu | `W1/G36/a` · `W1/G36/c` · `D-W1-3` | CORS politikası kaldırılır, backend **yeniden başlatılır** | `_preflight.py` **KIRMIZI**: `Access-Control-Allow-Origin` **dönmez** |
| M196 | koşan sunucu | `W1/G36/b` · `D-W1-1` | Politika `SetIsOriginAllowed(_ => true)` yapılır (origin **yankılanır**), backend yeniden başlatılır | `G36/b` **KIRMIZI**: `evil.local` **başlık ALIR** — negatif ayağın **gerçek** hedefi budur (denetim BLOKER-2) |
| M197 | koşan uygulama | `W1/G38/a` · `D-W1-4` · `D-W1-9` | `--dart-define=SENKRON_SUNUCU_URL` **kaldırılır** (web `10.0.2.2`'ye gider), yeniden derlenir | `psql` sayımı ekleme öncesi **0**, sonrası **yine 0** ⇒ `G38/a` **KIRMIZI**. Pozitif kontrol aynı koşumda: dart-define **varken** 0 → 1 |
| M199 | koşan uygulama | `W1/G37/a` · `W1/G37/b` · `W1/G37/c` · `D-W1-6` | `src/client/web/drift_worker.js` geçici olarak **kaldırılır**, web yeniden derlenip açılır | `chosenImplementation` **değişir** / `missingFeatures` **dolar** ve backend KAPALIYKEN **F5 sonrası görev KAYBOLUR** ⇒ üç ayak da **KIRMIZI** |

---

## 6b. MUTANT BORCU

🔴 **Bu bölümün ilk satırı MAKİNE OKUNURDUR.** `spec-kapi-kapsama.py` yalnız şu biçimi tanır:
`- KURAL: <ad> | GEREKCE: <en az 20 karakter>` · **`KAPI` borçlanamaz** (`S5`), gerekçesiz borç
reddedilir (`S4`), envanterde olmayan ada borç **hayalet borçtur** (`S6`).
*(Denetim MAJOR-2: v1'in `## 6b`'si serbest prozaydı ve araç onu **hiç okumamıştı** — `KURAL (0)`
çıkmasının sebebi buydu. `K81`/`K126` sınıfının **üçüncü ısırışı**: aracın kabul ettiği biçimi
**tahmin etmek**, beyanı sessizce ölü yapar.)*

- KURAL: D-W1-7 | GEREKCE: web portunun 5000'e sabitlenmesi bir YAPILANDIRMA kararidir, urun kodunda karsiligi yoktur; onu dusurecek mutant komutun kendisini degistirmek olurdu ve bu mutant kapiyi degil kosum satirini olcerdi (esdeger mutant). Sapma G36/b negatif ayagiyla dolayli olarak yakalanir: yanlis porttan kosulursa preflight izin listesiyle eslesmez ve G36/a kirmizi doner.

**Ayak düzeyi borçlar (araç bunları OKUMAZ — `## 5`'te `mutantsız` diye işaretli, burada gerekçeli):**

- **`W1/G38/b`** *(sunucudaki değişiklik Yenile ile iner)* — mutantsız. Gerekçe: bu ayağı düşürecek
  mutant **koşan uygulama** sınıfındadır ve o sınıfta `M197` + `M199` zaten var; üçüncüsü, `Yenile`
  düğmesinin kendi mantığını (`elleYenile` → `turCalistir` + `cekmeTuruCalistir`) bozmak olurdu ki
  bu **`K112`'nin kapsamıdır, `W1`'in değil**. Borç: `BORCLAR.md` → **`B-W1-1`**.
- **`W1/G37/c`** *(`missingFeatures` boşsa beyan)* — `M199` ayağı **düşürüyor** ama *"beyan yazıldı
  mı"* kısmının mekanik kapısı yok; bu bir **belge** disiplinidir, kapı değil.
  Borç: `BORCLAR.md` → **`B-W1-2`**.

🔴 `B-W1-1` ve `B-W1-2` **henüz `BORCLAR.md`'ye YAZILMADI** ⇒ şu an **sarkan atıftır** (denetim
MAJOR-4). `T7` bunu kapatır; `BORCLAR.md` **SARI** olduğu için yazım kapıyı **KIRMIZI**
yapabilir ve o an **tavan kararı `K40` gereği Onur'a** gider.

---

## 7. KABUL KRİTERLERİ

🔴 **`## 4c` gereği: koşan işi Claude Code koşar, HÜKMÜ Cowork ham çıktıdan verir (`K26`).**
Code'un *"koştu, geçti"* beyanı **kanıt sayılmaz**.

1. `araclar\verify.ps1` **EXIT 0**. 🔴 **backend KAPALIYKEN**; kapanış `netstat -ano | findstr :5298`
   **boş** dönerek ÖLÇÜLÜR (`ORTAM.md`).
2. `flutter analyze --fatal-infos` ⇒ **0**.
3. `flutter test` ⇒ **sayı yazılmaz, ÖLÇÜLÜR** (buraya kopyalamak bayat-iddia üretir).
4. `python araclar\cors-kapisi.py --altin-kume` **EXIT 0** *ve* `python araclar\cors-kapisi.py .`
   **EXIT 0**. 🔴 Altın küme **hem `.cs` hem `.dart`** vakası taşır ve **`//` ile `/* */`** yollarının
   **ikisini de** pinler.
5. `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-W1-web-yuruyen-iskelet.md`
   **EXIT 0**. 🔴 `K81`: araç **dizin kabul etmez**. 🔴 **BEYAN EDİLMİŞ SINIR:** bu araç
   *"mutantın gerçekten ısırdığını"* **ölçmez**, yalnız **kapsamayı** ölçer — kriter 6 ve 7 onun
   yerine geçmez.
6. **On dört statik mutantın on dördü de** beklendiği gibi davranır: `M191b` ve `M193b` **SUSMALI**,
   kalan on ikisi (`M189`, `M189b`, `M190`, `M190b`, `M191`, `M192`, `M192b`, `M193`, `M193c`,
   `M194`, `M198`, `M198b`) **ISIRMALI**.
7. **İki koşan sunucu mutantı** (`M195`, `M196`) ve **iki koşan uygulama mutantı** (`M197`, `M199`)
   ısırır. Kaynak dosyaya dokunan her mutant geri alındıktan sonra **bayt-özdeştir**
   (🔴 `git restore` **YASAK** — `core.autocrlf` bu depoda **aktif** ve onu bayt-özdeşlik için
   **kör** kılar; ikili yedek → bayt düzeyinde yama → yedekten `wb` geri yazma → `sha256` ölçümü.
   Referans: `KANIT/A11/_mutant_kosucu.py`). 🔴 `M197`/`M199` kaynak dosyaya **dokunmaz**
   (biri komut satırını, biri `web/` varlığını değiştirir) ⇒ onlarda ölçülen şey **geri alma
   sonrası davranışın eski hâline dönmesidir**, bayt-özdeşlik değil (denetim MAJOR-6).
8. `G36`'nın üç ayağı **canlı** ölçülür; ham istek/yanıt başlıkları `KANIT/W1/`'de.
9. `G37` + `G38` tarayıcıda ölçülür; `MOMENTUM-G6-KANIT` satırı **birebir** kayıtlı;
   `G37/b` **backend KAPALIYKEN** koşulmuş ve kapanış `netstat` ile **ölçülmüş**tür.
10. `python araclar\radar.py . --olc-urun-kodu <oturum-başı-sha>` ⇒ **> 0**. 🔴 `R8`'in söndüğü
    **git'ten türetilir**, elle yazılmaz (`K55`).
11. `python araclar\tek-kopya-kapisi.py .` · `belge-tavan-kapisi.py .` · `sayi-tazeligi.py .` ·
    `kapi-ad-teklik-kapisi.py .` — hepsi kabul koşumunda **yeniden** koşulur.

---

## 8. BEYAN EDİLMİŞ SINIRLAR

> *"Beyan edilmiş sınır kabul edilir, gizlenmiş sınır edilmez."*

1. **Web'de gerçek zamanlı sinyal YOKTUR** (`D-W1-5`, `K77/3`). Tazeleme yalnız açılış çekmesi +
   `Yenile` + yerel yazma. Bu spec o borcu **açmaz**.
2. **CORS yalnız `Development` içindir.** Üretim CORS'u, origin yönetimi ve `credentials` politikası
   **kapsam dışıdır** — `ADR 0004`'ün konusudur.
3. **`--web-port=5000` SABİTTİR** (`D-W1-7`). Başka porttan koşulursa `G36/a` **kırmızı** verir ve bu
   bir ürün kusuru **değildir**; koşum satırı hatasıdır.
4. **`flutter test --platform chrome` bu ortamda SONUÇ ÜRETMİYOR** (`ORTAM.md`, iki ölçüm: 7 dk ve
   9,8 dk) ⇒ web **birim testi** ayağı `[DOĞRULANMADI]` kalır. Bu spec onu **açmaz**.
5. **`G37`/`G38` bir ÖRNEKLEMDİR** — tek tarayıcı (Chrome), tek makine, tek sekme. Firefox/Safari,
   OPFS'siz ortam ve **iki sekmenin aynı OPFS deposunu paylaşması** ölçülmez.
6. **iOS ve Windows masaüstü kapsam dışıdır.**
7. **`WebApplicationFactory` riski `[ÖLÇÜLMEDİ]`** (denetim MAJOR-3): backend testleri API'yi
   `UseEnvironment("Development")` ile ayağa kaldırıyor; `Cors:AllowedOrigins` test ortamında **boş**
   olacağı için `D-W1-1`'in *"liste boşsa politika kaydedilmez"* şıkkı devreye girer. Bunun
   `verify.ps1`'i düşürüp düşürmediği **koşulmadan bilinemez** ⇒ `T1`'den hemen sonra **ölçülür**;
   düşerse çözüm politikayı gevşetmek **değil**, testin yapılandırmasına boş listeyi **açıkça**
   yazmaktır.
8. 🔴 **Bu spec `SS2`'nin `KOŞULAMAZ KABUL ŞARTI` kusurunu tekrarlamamak için yazıldı** (oturum 56:
   kriter 8 *"başlık B1/A1 yapılır"* diyordu ama üründe **başlık düzenleyen etkileşim yoktu**; iki
   kâğıt denetim turu bunu görmedi). Bağımsız denetçi **`## 7`'nin her maddesini üründe aradı** ve
   *"görev ekle"* (`GorevEkleAlani`) ile *"Yenile"* (`ValueKey('elle_yenile_dugmesi')`)
   etkileşimlerinin **gerçekten var** olduğunu ölçtü. Denetçinin ilk sorusu bundan böyle **budur**:
   ***"bu adım tarayıcıda fiilen yapılabiliyor mu?"***
9. **Denetim kâğıt üzerindedir.** Her iki denetçi de uygulamayı **fiilen koşmadı** (`K80`) ⇒
   `Content-Type` blokerı **kod okumasıyla** kesindir, **canlı preflight'la değil**. İlk canlı ölçüm
   `T3`'te yapılır ve **spec'i yanlışlayabilir**.

---

## 9. DOSYA KİMLİĞİ

🔴 **Kimlik `sha256` + bayttır ve DAİMA son yazımdan SONRA ölçülür:**
`python araclar\dosya-kimlik.py GOREV_CLAUDE_CODE\GOREV-W1-web-yuruyen-iskelet.md`

Bu spec **KİLİTLİDİR** (`K137`, Onur, 4 Ağu 2026). `K127` şartı **ÖDENDİ**: kilitten önce
bağımsız denetim koştu ve çıktı yolları **`## 0`'da yazılıdır**
(`KANIT/W1/00-DENETIM-kosulabilirlik.md` · `KANIT/W1/00-DENETIM-kor-kapi.md`).

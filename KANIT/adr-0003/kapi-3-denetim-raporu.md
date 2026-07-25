# ADR 0003 v3 — ÜÇÜNCÜ BAĞIMSIZ KAPI — DENETİM RAPORU

- **Tarih:** 25 Tem 2026 (oturum 18)
- **Denetlenen:** `docs/ADR/0003-kimlik-cekirdegi.md` — TASLAK v3 (95.967 bayt · 645 satır)
- **Önceki tur:** `KANIT/adr-0003/kapi-2-denetim-raporu.md` (v2, 15 bloker · ~20 majör)
- **Kapı kurulumu:** A turu üç bağımsız denetçi **paralel** (mimari/tutarlılık · ölçüm/gerçeklik · mutant/kapı) → B turu **RED-TEAM EN SON**, A'nın bulgularını **çürütmekle** görevli → ana oturum **adjudikasyon + karar-taşıyıcı iddiaların kaynaktan yeniden ölçümü**.
- **Üreten ≠ denetleyen:** v3'ü oturum 17 yazdı. Bu oturum **tek satır yazmadı**, yalnız denetledi.

---

## HÜKÜM: 🔴 **KİLİTLENEMEZ**

**9 BLOKER · ~20 MAJÖR.** Dört denetçi de bağımsız olarak "kilitlenemez" dedi; red-team A turunun 20 blokerinin **4'ünü çürüttü**, **9'unu majöre indirdi/daralttı**, **7'sini ayakta bıraktı** ve **2 yeni bloker** getirdi.

**v3'ün 15 blokerden dürüst kapatma sayımı: 10/15 kapandı (bunun 5'i temiz), 5'i kapanmadı.**

| durum | blokerler |
|---|---|
| **Temiz kapandı (5)** | #9 (3b devri) · #10 (soğuk açılış — belgenin en iyi yeni maddesi) · #12 (`alg` beyanı) · #14 (M17 saat ilerletme) · #15 (M32) |
| **Esasta kapandı, yeni kusur doğurdu (5)** | #2 (dal önceliği yok) · #4 (anahtar kaynağı + aile bağı kapısı yok) · #5 (mekanizma inşa edilebilir ama **kapısız**) · #6 (okuma yönü yok, M28 kör) · #11 (NIST atfı yanlış, M21'in bir ayağı öldü) |
| **KAPANMADI (5)** | #1 (inşa edilemez) · #3 dal (b) (**ölçüldü — aşağıda**) · #3 dal (a)'nın kapısı (M33) · #7'nin handler ayağı · #8'in kapısı (M8b) + #13 (M22'nin iki ayağı) |

---

## 0. ANA OTURUMDA KAYNAKTAN YENİDEN ÖLÇÜLENLER

> **Kural (K13 emsali):** alt-ajan beyanı **aktarılmaz**; hükmü taşıyan her iddia ana oturumda bağımsız doğrulanır.

| # | iddia | ölçüm | sonuç |
|---|---|---|---|
| **1** | **`RemoteIpAddress` Docker'da gerçek istemci IP'si midir?** | **Onur'un makinesinde GERÇEK KOŞU** (Docker 29.6.1 / compose v5.3.0): `docker run --rm -d -p 18080:80 nginx:alpine` → üç ayrı yoldan istek → nginx access log | **HAYIR.** `http://localhost` → **172.17.0.1** · `http://127.0.0.1` → **172.17.0.1** · `http://192.168.0.41` (LAN) → **172.17.0.1**. Konteyner içi: `default via 172.17.0.1 dev eth0`. **Üç yolda da köprü ağ geçidi; gerçek istemci IP'si hiçbirinde yok.** |
| **2** | K14-a'nın "kayıtlı halef **aynen** döndürülür" kuralı inşa edilebilir mi? | Belgenin tamamı tarandı (`ham·SHA-256·token_hash·halef`) | **HAYIR.** K3-C2 (167): *"istemciye ham gider, **DB'ye yalnız SHA-256 özeti** yazılır"* · şema (170): ham değer için **kolon yok** · **M12 (505) bunu ayrıca ZORLUYOR**. Ham `T2` sunucuda **yoktur**. |
| **3** | `OnRejected` / `RejectionStatusCode` handler limitlerini kapsar mı? | `dotnet/aspnetcore release/9.0` `RateLimiterOptions.cs` + `RateLimitingMiddleware.cs` | **HAYIR.** İkisi de `RateLimiterOptions` üyesi; `context.Response.StatusCode = _rejectionStatusCode;` ve `await thisRequestOnRejected(...)` **yalnız middleware'de**. |
| **4** | `ValidateOnBuild` her ortamda açık mı? | `dotnet/runtime release/9.0` `HostingHostBuilderExtensions.cs` | **HAYIR:** `bool isDevelopment = context.HostingEnvironment.IsDevelopment();` → `ValidateScopes = isDevelopment, ValidateOnBuild = isDevelopment` |
| **5** | `WebApplicationFactory` ortamı zorlar mı? *(A3-B8'i çürüten ölçüm)* | `dotnet/aspnetcore release/9.0` `Mvc.Testing/WebApplicationFactory.cs` | **EVET —** üç ayrı yolda `UseEnvironment(Environments.Development)`. ⇒ **A3-B8'in ortam ayağı çürütüldü**, M19 `TS` seviyesinde ısırır. |
| **6** | `MapFallbackToFile` üst seviye `UseStaticFiles`'a bağımlı mı? | `release/9.0` `StaticFilesEndpointRouteBuilderExtensions.cs` | **HAYIR.** `context.Request.Path = "/" + filePath;` · `context.SetEndpoint(null);` · **kendi `app.UseStaticFiles()`'ını kurar**. Varsayılan kalıp **`{*path:nonfile}`**. |
| **7** | `System.Text.Json` varsayılanı `+` karakterini kaçırır mı? | `release/9.0` `AllowedBmpCodePointsBitmap.cs` | **EVET:** `ForbidChar('+'); // technically not HTML-specific, but can be used to perform UTF7-based attacks` ⇒ gövdeye **`+`** yazılır. |
| **8** | `ProblemDetails` gövdesine `traceId` koşulsuz mu yazılır? | `release/9.0` `DefaultProblemDetailsWriter.cs` | **EVET, koşulsuz:** `var traceId = Activity.Current?.Id ?? httpContext.TraceIdentifier; context.ProblemDetails.Extensions["traceId"] = traceId;` |
| **9** | NIST SP 800-63B asgari parola uzunluğu | NIST SP 800-63B-4 (Final) birebir | *"**SHALL** require passwords that are used as a **single-factor** authentication mechanism to be a minimum of **15 characters**"* (MFA bileşeni: 8). Karmaşıklık: *"**SHALL NOT** impose other composition rules"* ✔ · azami: *"**SHOULD** permit … at least 64"* ✔ |

---

## 1. BLOKERLER (kilit öncesi kapatılması ZORUNLU, önem sırasıyla)

### B1 — K14-a İNŞA EDİLEMEZ: kayıtlı halefin ham değeri sunucuda YOKTUR ⇒ bloker #1 kapanmadı
**Sınıf:** inşa edilemeyen mekanizma (v2'nin bloker #5'iyle **birebir aynı sınıf**) · **Taç kararını vuruyor.**

K3-C6(3) birebir: *"tüketilmiş `T1` yeniden sunulduğunda … `T1`'in **kayıtlı halefi aynen** döndürülür"*. Ama sunucunun elinde döndürecek bir değer yok — **üç bağımsız karar bunu kapatıyor:**
1. K3-C2: *"Değer: **256 bit CSPRNG**; istemciye ham gider, **DB'ye yalnız SHA-256 özeti** yazılır."*
2. Şema: `refresh_tokens(id, user_id, token_hash, family_id, created_at, expires_at, consumed_at, replaced_by_id, revoked_at, revoked_reason)` — **ham değer için kolon yok.**
3. **M12 bunu ayrıca zorluyor:** *"DB'deki `token_hash`, istemciye verilen token'ın **SHA-256 özetine EŞİTTİR**"*.

SHA-256 tersine çevrilemez; token **CSPRNG**'dir, `HMAC(key, row_id)` gibi yeniden hesaplanabilir bir yapı değildir. Dal (c) hem web (`Set-Cookie`) hem native (gövde) kanalında ham `T2` gerektirir.

**Sonucu:** bloker #1 (RT-B1) **kapanmamıştır** ve **M29 · M30 · M1'in üçü de inşa edilemez bir davranışa çıpalıdır.**

**Öneri (biri kilitlenmeli):** (a) `refresh_tokens`'a kısa-TTL'li, uygulama anahtarıyla şifreli `successor_secret_enc` kolonu (60 sn sonra `NULL`) — bir **şema kararıdır, bu belgenin işidir**; (b) dal (c) *"yeni token üretilir ama `T1`'in halefi olarak kaydedilir, `expires_at` devralınır"* diye yeniden yazılır (o zaman *"yeni döndürme yapılmaz"* cümlesi düşer); (c) K3-C2'nin *"yalnız özet"* kararı gevşetilir ve bedeli (DB sızıntısı = kullanılabilir token) açıkça yazılır.

---

### B2 — `RemoteIpAddress` beyanı, belgenin ZORUNLU KILDIĞI dağıtımda YANLIŞ ⇒ bloker #3 dal (b) kapanmadı, TAŞINDI
**Sınıf:** kör kapı · **ÖLÇÜLDÜ (gerçek koşu, Onur'un makinesi).**

K3-L4/K14-e birebir: *"**`RemoteIpAddress` GERÇEK istemci IP'sidir ⇒ `UseForwardedHeaders` hiç gerekmez ve K3-J2(1) yaşar.** Bu, blokerin en sinsi ayağını **doğmadan** kapatır."*

**Ölçüm (bkz. §0/1):** üç yolun **üçünde de** konteyner `172.17.0.1` (köprü ağ geçidi) gördü — `localhost`, `127.0.0.1` **ve LAN IP'si dâhil**. Mekanizma: Docker port yayımlama **NAT**'tır ve resmî `dockerd` referansı `--userland-proxy`'yi *"Use userland proxy for **loopback traffic**"* varsayılan **`true`** olarak tanımlar; Docker Desktop'ta trafik ayrıca VM sınırından geçer. RT-M1 zaten **`http://localhost:PORT`'u ZORUNLU** kılıyor ⇒ trafik tam olarak proxy'lenen yola sokuluyor.

**Sonuçları:**
- K3-J2(1)'in IP partition'ı fiilen **tek partition**tır ⇒ **tüm kullanıcılar aynı 10/5dk kovasını paylaşır**. Belgenin *"tüm kullanıcılar tek partition'a düşer … M11/M23 `TestServer`'da YEŞİL kalırdı = **tam anlamıyla kör kapı**"* diye tarif ettiği şey, **konteynerin kendisinde** oluyor.
- K3-J5'in *"tavanı anlamlı kılan şey IP penceresidir"* cümlesi ve §6 Risk #5 **yanlış**.
- **K14-e'nin reverse-proxy'yi reddetme gerekçesinin üçte biri hatalı bir olguya dayanıyor** — bir Onur kilidi yanlış ölçüm üzerine kuruldu.
- R2'nin topolojik ikizi kapanmadı, adı değişti: *"partition'ı saldırgan seçer"* → *"partition'ı **Docker'ın kendisi** siler."*

**Öneri:** (a) iddiayı **geri çek**, *"tek konteyner dağıtımında `RemoteIpAddress` köprü ağ geçididir; kontrol 1 **küresel** bir hız sınırıdır, IP-anahtarlı değildir"* diye **adlandırılmış sınır** yaz ⇒ M11/M23'ün kill sinyalleri ve `limit == "ip"` beyanı yeniden yazılır, K14-i sayıları çok-istemcili demo için yeniden değerlendirilir; **veya** (b) `UseForwardedHeaders` + `KnownProxies` geri gelir (K14-e yeniden açılır). **Her hâlde §6'ya yeni risk maddesi ve K3-J6'nın NAT paragrafına Docker eklenmeli.**

---

### B3 — `F5 = /refresh` × tek partition × istemci sözleşmesinde `429` dalı YOK ⇒ demo ortasında tanımsız durum
**Sınıf:** ODEV §2'nin birinci ölçütünü vuruyor · hiçbir kapı görmüyor · **kaynak: red-team**

Üç kararın kesişimi, hiçbiri tek başına görünmüyor:
1. K3-L2: *"Erişim token'ı web'de de **yalnız bellektedir** (sekme-yerel)"* ⇒ **her F5 bir `/refresh`'tir.**
2. K3-J2(1): `/login` + `/refresh` + `/register` **tek politika**, **10 istek / 5 dk**, `QueueLimit=0` — ve **B2 gereği tek partition**.
3. K3-L8 `/refresh` sonucunu **yalnız ikiye** ayırıyor: ağ hatası → çevrimdışı-yetkili · `401`/`reuse_detected` → "oturum gerekli". **`429` hiçbir dala düşmüyor.**

ODEV §4(b)-2 (**gerçek zamanlı işbirliği**) tanımı gereği **iki eşzamanlı kullanıcı** ister. Değerlendirici A'yı kaydeder+girer (2) → B'yi kaydeder+girer (4) → uçak modu açıp kapatır, her seferinde F5 (5,6,7…) → iki pencerede birkaç yenileme (8,9,10) → **11. istek `429`**. İstemci davranışı **tanımsız**: `429`'u `401` olmayan bir hata sayıp "oturum gerekli"ye geçerse **demo ortasında giriş ekranı**. Bloker #10 tam olarak bunun için ayrı bir karar istemişti.

**Öneri:** K3-L8'e üçüncü dal — *"`429`/`5xx` = **geçici**; `Retry-After`'a uyulur, istemci **çevrimdışı-yetkili kalır**, 'oturum gerekli'ye GEÇMEZ"* + mutantı (**M-L9**, DART); `/refresh` `/login`'den ayrı ve gevşek bir politikaya alınır (K14-i zaten *"gözden geçirilebilir"*).

---

### B4 — M8b ÖLDÜRÜLEMEZ: mutasyon shell giriş betiğinde, seviye `B` (saf birim)
**Sınıf:** kör kapı — ve belgenin kendi cümlesiyle *"bu ikinci ayak olmadan **bootstrap'ın kendisi bir güvenlik açığı kapısıdır**"*

K3-I3 birebir: *"**Konteynerin giriş betiği**, `ASPNETCORE_ENVIRONMENT=Development` **ve** anahtar dosyası yoksa, CSPRNG ile 32 bayt üretip … yazar"*. M8b'nin mutasyonu bu betiğin ortam koşulunu siler; **seviyesi `B`**. Hiçbir C# birim/`TestServer` testi konteynerin ENTRYPOINT'ini gözlemleyemez ve §3'ün seviye sözlüğünde (B/D/TS/TC/NA/DART) **konteyner seviyesi yoktur**. Builder `B`'yi okur, var olmayan bir sınıfa test yazar, **yeşil geçer**; gerçek yol kapısız kalır.

**Öneri:** seviye sözlüğüne **KON** (konteyner/E2E) eklenir ve M8b oraya taşınır — *"`docker run -e ASPNETCORE_ENVIRONMENT=Production` ile anahtarsız açılan konteyner sıfırdan farklı çıkış kodu verir **ve** `.secrets/jwt-signing.key` **oluşmaz**"*; **veya** bootstrap `Program.cs`'e taşınır (`IHostEnvironment.IsDevelopment()`) ve seviye `TS` olur — o zaman K3-I3'ün *"giriş betiği"* cümlesi düzeltilmelidir. Anahtar dosyasının kodlaması (ham 32 bayt mı, base64 mü) da yazılmalı — K3-I2'nin *"32 bayttan kısa"* kontrolü buna bağlı.

---

### B5 — M28 KÖR: JSON kodlayıcısı `+`'yı `+` yapıyor **ve** token kodlaması pinlenmemiş
**Sınıf:** kör kapı — **flaky** (baseline daima yeşil ⇒ hiç gürültü üretmez) · **ÖLÇÜLDÜ**

M28 birebir: *"yanıtların **ham gövde metni** yenileme token'ının değerini **içermez**"* + *(test gövdeyi dize olarak tarar)*. Ölçüm: `AllowedBmpCodePointsBitmap.ForbidHtmlCharacters()` **`ForbidChar('+')`** içeriyor ve `JavaScriptEncoder.Default` `System.Text.Json`'ın varsayılanıdır ⇒ **standart Base64 token'ındaki `+` gövdeye `+` olarak yazılır** ⇒ ham dize taraması token'ı **ıskalar**. 43 karakterlik bir değerde en az bir `+` bulunma olasılığı **≈ %49**.

Kök neden daha geniş: **token'ın kodlaması hiçbir yerde pinlenmemiştir** (*"256 bit CSPRNG"* dışında hiçbir şey yazılı). Aynı belirsizlik **M12'yi de** vuruyor: *"SHA-256 özetine EŞİTTİR"* — **neyin** özeti, ham baytların mı kodlanmış dizenin mi?

**Öneri:** K3-C2'de **`Base64Url` (dolgusuz)** pinlenir *(hem M12'yi hem M28'i tek kararla kapatır)* **ve** sinyal güçlendirilir: *"gövde JSON olarak ayrıştırılır, tüm dize değerleri **özyinelemeli** taranır; ayrıca ham gövde token'ın **hem düz hem JSON-kaçışlı** biçimi için taranır"*.

---

### B6 — M33 AYIRT EDİCİ DEĞİL + baseline'ı yok
**Sınıf:** kör kapı (1. ayak) + ölü tuzak (baseline) · **ÖLÇÜLDÜ**

Ölçüm: `MapFallbackToFile` `CreateRequestDelegate` içinde `context.Request.Path = "/" + filePath;` yapar, `context.SetEndpoint(null);` çağırır ve **kendi `app.UseStaticFiles()`'ını kurar**; varsayılan kalıp **`{*path:nonfile}`**'dır.

- `GET /tasks` → fallback ucu eşleşir (`AllowAnonymous`) ⇒ `index.html` **fallback'in kendi statik middleware'inden** gelir ⇒ **üst seviye `UseStaticFiles`'ın yeri sinyali etkilemez** ⇒ mutasyon uygulandığında da `200` = **kör**.
- Farkın gerçekte yaşadığı yer **test edilmiyor:** `GET /main.dart.js` gibi **dosya-benzeri** bir yol `{*path:nonfile}`'a **düşmez** ⇒ endpoint `null` ⇒ statik middleware auth'tan sonraysa `FallbackPolicy` `401` verir. Doğru kill sinyali budur ve M33'te **yok**.
- **Baseline:** `slice-3c` `slice-3b`'den **önce** koşuyor (K14-h'nin kendi kabulü) ⇒ `wwwroot/index.html` **henüz yok** ⇒ fallback `404` ⇒ **baseline kırmızı**. ADR bir fixture şart koşmuyor.
- Ayrıca mekanizma tarifi eksik: `AllowAnonymousAttribute` `IAuthorizeData` **değildir**; `AuthorizationPolicy.CombineAsync` yine fallback'e düşer — kurtaran şey `AuthorizationMiddleware`'in **ayrı** `IAllowAnonymous` kontrolüdür.

**Öneri:** **M33a** (`AllowAnonymous` kaldırılır → `GET /tasks` `401`) ve **M33b** (`UseStaticFiles` sonraya alınır → *"kimliksiz `GET /main.dart.js` `200` döner ve gövdesi `index.html` **değildir**"*) diye **ikiye böl**; K3-J1'e *"test derlemesinde `wwwroot/index.html` + en az bir dosya-benzeri varlık yer tutucu olarak bulunur"* satırı eklenir. **K3-J1'in gerekçesi de düzeltilmeli: SPA'yı kurtaran şey `UseStaticFiles`'ın yeri değil, fallback ucundaki `AllowAnonymous`'tur.**

---

### B7 — Kontrol 2 (e-posta penceresi) TÜMÜYLE KAPISIZ ve §3.1'de de yok ⇒ bloker #5 kanıtsız kapatılmış
**Sınıf:** tamlık iddiasının ihlali · kapısız mekanizma

K14-f, bloker #5'i kapatmak için kilitlenen çataldır: *"e-posta limiti handler içinde `PartitionedRateLimiter<string>`; **5 deneme / 15 dk**"*. Mutant tablosunda **kontrol 2'yi kaldıran hiçbir mutant yoktur** (M11 → kontrol 1, M22 → kontrol 3, M23 → IP partition) ve §3.1'in *"mutantsız olduğu açıkça yazılanlar"* listesinde de **geçmiyor**. §3 birebir *"Bu tablo … spec'in mutant listesinin **kimlik-çekirdeği yarısıdır**"* diyerek tamlık iddia ediyor; §3.1 *"**Bu liste, tablonun tamlık iddiasının sınırıdır**"* diyor. ⇒ *"kapattım"* denen bir bloker, **kapısız bir mekanizmayla** kapatılmış sayılıyor.

**Öneri:** *"aynı e-posta ile **6.** deneme `429` ve `limit == "email"`; **aynı IP'den farklı e-postalarla** gelen 6. istek `429` **ALMAZ**"* — ikinci ayak R2'yi de korur.

---

### B8 — CSRF HMAC anahtarının VARLIĞI / KAYNAĞI / BOOTSTRAP'ı hiçbir yerde yazılmamış
**Sınıf:** kararlaştırılmamış çatal + gizlenmiş sınır (bloker #11'in rütbe gerekçesiyle aynı) · kırmızı çizgi #1'e temas

K3-L3(3) birebir: *"Sunucu … HMAC'i **kendi anahtarıyla** yeniden hesaplar"*. **Hangi anahtar?** K3-I1/I2/I3 **yalnız JWT imzalama anahtarını** düzenliyor; §2-M'nin `ICsrfTokenService` satırı yalnız *"`System.Security.Cryptography`"* diyor; §3.1 kalemi hiç anmıyor. Belgenin doktrini *"sessiz varsayılan yoktur"* ve JWT anahtarı için **üç madde** yazılmışken ikinci bir sır hakkında **sıfır satır** var.

**Asıl kırılma (red-team'in sivriltmesi):** K3-I3'ün açık vaadi *"Sonraki açılışlar **aynı** anahtarı okur ⇒ mevcut oturumlar restart'ta düşmez"*. İkinci anahtar **efemer** seçilirse `docker compose restart` sonrası her web kullanıcısının `__Host-mct` çerezi doğrulanamaz ⇒ `/refresh` reddedilir ⇒ değerlendirici *"oturum düştü"* görür. **M25/M35 hangi anahtar seçilirse seçilsin yeşil kalır** ⇒ hiçbir kapı bunu yakalamaz.

**Öneri:** K3-I'ye dördüncü madde — `Momentum:Csrf:SigningKey` **ayrı** anahtardır (anahtar-amaç ayrımı), K3-I2'nin fail-fast'i **iki anahtarı da** kapsar, K3-I3'ün bootstrap'ı **iki dosya** üretir; M8a/M8b'nin sinyalleri çoğula genişletilir.

---

### B9 — `X-Client-Kind`'ın OKUMA YÖNÜ yazılmamış: güvenlik modunu istemci seçiyor
**Sınıf:** kararlaştırılmamış çatal — K14-f'in **adlandırarak reddettiği** hata sınıfının kardeşi

K3-L10'un *"PAZARLIKSIZ İKİ KURAL"*ı yalnız **yanıt** yönünü düzenliyor. **İstek yönü tanımsız:** sunucu `/refresh`'te token'ı çerezden mi gövdeden mi okur, iki kanal birden doluysa ne olur, CSRF doğrulaması `native`'de koşar mı? CSRF doğrulaması zorunlu olarak `X-Client-Kind == web`'e koşulludur ⇒ **istemcinin gönderdiği bir başlık sunucunun güvenlik modunu seçer** — K14-f'in birebir reddettiği şey: *"anahtarı istemci seçer ⇒ R2'nin kapattığı hata sınıfı aynen geri gelir"*. Builder *"çerez varsa çerezden, yoksa gövdeden oku"* (en doğal seçim) yazarsa `X-Client-Kind: native` gönderen bir istek CSRF katmanını **tümüyle atlar** ve tarayıcı `__Host-mrt`'yi otomatik ekler.

**Dürüst daraltma:** red-team saldırıyı tarayıcıda kurmayı denedi ve **kuramadı** — `X-Client-Kind` CORS-safelisted **değildir** ⇒ çapraz-origin istekler preflight tetikler ⇒ K3-L4 gereği CORS politikası **hiç yok** ⇒ tarayıcı bloklar. **Bugün sömürülebilir değil; savunma kazara duruyor.** Bloker sebebi karar boşluğudur, saldırı değil.

**Öneri:** K3-L10'a üçüncü PAZARLIKSIZ kural: *"Sunucu girdi kanalını **yalnız** `X-Client-Kind`'dan seçer: `web` ⇒ **yalnız** çerez okunur (gövde yok sayılır) **ve CSRF doğrulaması zorunludur**; `native` ⇒ **yalnız** gövde okunur, çerez **okunmaz**."* + M28'e ikinci ayak. **Yan kazanç, belgenin lehine ve yazılmalı:** zorunlu `X-Client-Kind`, CORS politikası olmadığı için **kendi başına** bir CSRF savunmasıdır.

---

## 2. MAJÖRLER (bloker değil, v4'te kapanmalı)

| # | bulgu |
|---|---|
| **Ma-1** | **M39 ↔ K14-a ölü tuzağı.** Paralel iki `/refresh`'te kaybeden istek **dal (c)**'ye düşer ⇒ **ikisi de `200`** alır ⇒ *"tam olarak biri 200"* baseline'da asla sağlanamaz. K3-L9 aynı olguyu **tersinden** yazıyor. *Düzeltme:* *"iki yanıt da `200` ise dönen token'lar **özdeştir** ve ailenin satır sayısı **tam olarak 1** artmıştır"*. |
| **Ma-2** | **K3-C6(2)'nin dal ÖNCELİĞİ yazılmamış.** `consumed_at` + `revoked_at` birlikte dolu olabilir (refresh → logout) ⇒ builder (c)'yi önce ayrıştırırsa `/logout`'tan sonra **60 sn boyunca çalışan bir oturum geri verilir**; M26 bunu görmez. *(`expires_at` ayağı **çürütüldü**: pencere `consumed_at`'e çıpalı, 30 gün zorlaması delinmiyor.)* *Düzeltme:* *"(a)→(b)→(c)→(d) sırayla; `revoked_at`/`expires_at` sağlanıyorsa replay-idempotency **hiç** değerlendirilmez"* + mutantı. |
| **Ma-3** | **`OnRejected` kontrol 2/3'ü kapsamıyor** (ölçüldü). `limit == "email"/"concurrency"` değerleri **üretilemez** ⇒ M22 baseline'da kırmızı. *Düzeltme:* K3-J4 ikiye ayrılır — middleware ayağı (`limit="ip"`, `Retry-After` `FixedWindowLease`'ten) + **handler ayağı** (`429` + aynı `ProblemDetails` şekli + `limit="email"/"concurrency"`). **`ConcurrencyLease` `RetryAfter` TAŞIMIYOR (ölçüldü)** ⇒ §6 Risk #12 ve §3.1'in `[DOĞRULANMADI]` etiketi artık kapatılabilir. |
| **Ma-4** | **M37 ölü tuzağı:** `DefaultProblemDetailsWriter` **koşulsuz** `Extensions["traceId"]` yazıyor (ölçüldü) ⇒ *"bayt bayt aynı"* yapısal olarak imkânsız. *Düzeltme:* K3-B5'e karar satırı (*"bu uçta `traceId` yazılmaz"*) veya sinyal *"`traceId` hariç"*. |
| **Ma-5** | **M21'in `Trim` ayağı ölü + K3-A2'nin 1. adımı erişilemez hâle geliyor.** K3-B6 format doğrulamayı **normalizasyondan önce** koyuyor ⇒ `" a@x.com"` `400` alır ⇒ *"aynı hesaba düşer"* kurulamaz. **v2'nin "KIRILAMAYAN YERLER" listesindeki bir kalemi (K3-A2 zinciri) v3'ün yeni kararı bozuyor.** *Düzeltme:* sıra `Trim()` → **format doğrulama** → NFC → `ToLowerInvariant` + doğrulayıcının pinlenmesi. |
| **Ma-6** | **§3.1'in tamlık iddiası yanlış.** Kapısız **ve** beyansız kalemler: K3-L10'un *"başlık yoksa `400`"* · native-çerez-yok kuralı · K3-B6'nın e-posta 254+format ayakları · K3-L3(3)'ün **aile bağı** (M35 yalnız imzayı ölçer) · K3-L2'nin **`HttpOnly`/`SameSite`/`Max-Age`** (M36 yalnız `__Host-`/`Domain`) · K3-J6'nın 20/5dk politikası · K3-C6(2) dal (a) · K3-B4'ün **sabit-zaman özelliği** (elle erken-çıkışlı döngü M6+M6b'yi geçer) · §2-M'nin `ICurrentUser`/`Microsoft.AspNetCore.*` kuralı. |
| **Ma-7** | **§3.1'in `iss`/`aud`/`RequireSignedTokens` muafiyeti kendi kendini yalanlıyor.** *"Çerçevenin kendi doğrulamasıdır"* yanlış — `ValidateIssuer=false` benim kodumdaki tek satırlık yapılandırmadır, `ClockSkew` ile **aynı sınıf**. Belge `RequireSignedTokens`'ı *"**`alg:none`'ı kapatan asıl ayardır**"* ilan ediyor ⇒ **en kritik ilan edilen satır kapısız**. |
| **Ma-8** | **Bloker #15 yarım:** §2-M `Microsoft.IdentityModel.*` ve `Microsoft.AspNetCore.*` için **yeni** NetArchTest kuralları getiriyor ama §3.1 *"yalnız `Konscious.*` kuralı yenidir"* diyor. *(0001 K-H1 ihlali iddiası **kanıtlanamadı** — ADR 0001 bağlı klasörde yok; v4 bunu 0001'den birebir alıntıyla kanıtlamalı.)* Somut ve kanıtlı kusur: §2-M'nin `ICurrentUser` satırındaki kural §3.1'in muafiyet listesinde **hiç geçmiyor**. |
| **Ma-9** | **RT-M4: NIST atfı yanlış.** SP 800-63B-4 tek faktör için **`SHALL` 15 karakter** (ölçüldü); belge *"NIST çizgisi ≥10"* diyor. Karmaşıklık-yok ve ≤128 ayakları **doğru**. Belgenin kendi cümlesiyle: *"güncel literatürü bilen değerlendiricide eksi sinyal."* *Düzeltme:* ya 15'e çık, ya *"NIST-4'ün `SHALL` 15 çizgisinden **adlandırılmış sapma**"* diye yaz + sınır-değer testi. |
| **Ma-10** | **RT-M1: halef `INSERT`'ünün atomikliği yazılmamış.** K3-C6(1) yalnız `UPDATE … RETURNING`'i pinliyor; *önce `INSERT`, sonra `UPDATE`* sırası yarışı kaybeden istekte ailede **sahipsiz ama geçerli** bir satır bırakır. M39 yalnız yanıt kodlarını ölçüyor. |
| **Ma-11** | **RT-M2: PAZARLIKSIZ middleware sırasında `UseRateLimiter` YOK.** Blok `UseForwardedHeaders`'ın **yokluğunu** bile yazıyor ama §2-J'nin tamamının dayandığı çağrıyı anmıyor. Yeri anlam taşır: `UseRouting`'den önce ⇒ uca bağlı politikalar hiç uygulanmaz; statik dosyalardan önce global limit ⇒ web build'inin asset istekleri kovayı ilk saniyede tüketir. |
| **Ma-12** | **RT-M3: `/logout` yenileme çerezini silmiyor.** K3-L3 *"`/logout`'ta silinir"* diyor — **yalnız CSRF çerezi** için. `__Host-mrt` `Path=/` gereği çıkıştan sonra 30 güne kadar **her** isteğe takılmaya devam eder. Ma-8'i kapattığını ilan eden bölümde yaşam döngüsünün son adımı eksik. |
| **Ma-13** | **M19'un seviyesi (`D`) yanlış:** `ValidateOnBuild` bir **çalışma-zamanı host-build** doğrulamasıdır, analizör değil. *(A3'ün "ortam kapalı" ayağı **çürütüldü**: `WebApplicationFactory` üç yolda `UseEnvironment(Development)` çağırıyor — ölçüldü.)* Koşum biçimi (`WebApplicationFactory` mi çıplak `ServiceCollection` mi) pinlenmeli; ikincisinde mutant sessizce hayatta kalır. |
| **Ma-14** | **M24'ün "gerçek `AddJwtBearer` boru hattı" pini yok** ⇒ sahte `TestAuthHandler` ile mutant hayatta kalır. M14'te uç adı pinlendi, burada pinlenmedi = belgenin kendi standardıyla asimetri. *(A3'ün *"UserId'yi dereference eden uç yok"* ayağı **çürütüldü**: `/logout-all` `sub`'a dayanıyor.)* |
| **Ma-15** | **M22'nin farklı-IP önkoşulu ADR'de yazılmamış.** TestHost `RemoteIpAddress`'i **null** bırakır; `UseRateLimiter`'dan önce tek satırlık test-only middleware ile kurulabilir — kusur *"imkânsız"* değil, **"yazılmamış"**. *(A3'ün M11/M23 için aynı iddiası **çürütüldü**: ikisi null IP altında da ısırır.)* |
| **Ma-16** | Diğerleri: `alg` ayağının üç yerde üç statüsü · K3-J6 sayaç belirsizliği (ayrı mı ortak mı) · `/logout-all` ve `/register`'ın `X-Client-Kind` statüsü · M4 tek commit'te iki ayağını kanıtlayamaz · M6b ayırt edici değil · M30'un *"pencere İÇİNDE"* koşulu pinlenmemiş · M35 negatif iddiaya karşı korumasız · M32'nin mutasyon biçimi belirsiz (kullanılmayan `using` referans yazmaz) · M23'ün ifadesi K14-f sonrası güncellenmemiş · M-L5'in web ayağı DART'ta inşa edilemez · **§0'ın "açık çatal yoktur" beyanı K14-i'nin kendi cümlesiyle çelişiyor**. |

---

## 3. DÜŞEN / ÇÜRÜTÜLEN BULGULAR (red-team turu — dürüstlük)

| bulgu | hüküm | neden |
|---|---|---|
| *"M19 kör: `Production`'da `ValidateOnBuild` kapalı"* | **ÇÜRÜTÜLDÜ** | `WebApplicationFactory` üç ayrı yolda `UseEnvironment(Environments.Development)` çağırıyor (**ana oturumda ölçüldü**) ⇒ `TS`'te doğrulama **açık**, mutant ısırır. Yalnız seviye etiketi majör kalır. |
| *"M22: TS'te farklı IP kurulamaz"* | **ÇÜRÜTÜLDÜ** | `UseRateLimiter`'dan önce tek satırlık test-only middleware önkoşulu kurar; standart teknik. |
| *"M11/M23 null IP yüzünden ölü tuzak"* | **ÇÜRÜTÜLDÜ** | Tek partition altında M11 yeşil doğar; M23'ün mutasyonu rastgele e-postalarla **hiç ret üretmez** ⇒ null IP altında bile ısırır. |
| *"Dal önceliği M27'nin 30 gününü deliyor"* | **ÇÜRÜTÜLDÜ** | Pencere `consumed_at`'e çıpalı; 30 gün sonra `now > consumed_at + 60 sn` ⇒ dal (c) açılmaz. |
| *"M24: UserId'yi dereference eden uç yok"* | **ÇÜRÜTÜLDÜ** | `/logout-all` *"kullanıcının **tüm** ailelerini"* iptal ediyor ⇒ `sub` zorunlu. |
| *"K3-C1'in 15 dk ömrü beyansız kapısız"* | **ÇÜRÜTÜLDÜ** | §3.1 bunu açıkça beyan ediyor. |
| *"K14-a RFC 9700'ün `MUST`'ını ihlal ediyor"* | **RÜTBE DÜŞÜRÜLDÜ → MİNÖR** | RFC 9700 §4.14.2'de `MUST` yalnız *"replay tespit yöntemlerinden birini kullan"* için; iptal cümlesi **betimleyicidir**. Momentum rotation+reuse-detection uyguluyor ⇒ ihlal yok. Tek satırlık **adlandırma borcu** kalır. |
| *"`__Host-` × localhost belgede hiç ele alınmamış"* | **DARALTILDI → MİNÖR** | Satır 422 `Secure` × `localhost` kısıtını adlandırıyor. Ayakta kalan: **WebKit/Safari** ayağı (ölçülmedi) ⇒ teslim paketine *"Chromium tabanlı tarayıcı"* notu tek satırlık telafi. |
| *"M16'nın HS512 ayağı ölü tuzak"* | **DÜŞTÜ (denetçi kendi hipotezini çürüttü)** | `SymmetricSignatureProvider` yalnız 128 bit asgarisi uygular ⇒ 32 baytlık anahtar HS512 imzalar ⇒ **M16 SAĞLAM, iki ayak da ısırıyor**. |
| *"M1 ile M29 aynı testle ölüyor"* | **DÜŞTÜ** | İki mutasyonun tek testle ölmesi kusur değildir. |

---

## 4. DÜRÜSTLÜK BEYANI — KIRILAMAYAN YERLER

Dört denetçi de saldırdı, kıramadı:

- **K14-a'nın v1 zarafet penceresinden ayrımı yapısaldır ve DOĞRUDUR.** Sonsuz zincir kurulmaya çalışıldı: pencere `T1.consumed_at`'e çıpalı, dalda **yeni token üretilmiyor**, `expires_at` devralınıyor ⇒ zincir **yapısal olarak** doğmuyor. Beş eksenli tablo doğru. *Sorun tasarım değil, **saklama sonucudur** (B1).*
- **K3-C6(1)'in yüklemi TAM.** `token_hash` + `consumed_at IS NULL` + `revoked_at IS NULL` + `expires_at > @now` dörtlüsünde eksik koşul bulunamadı; check-then-act yasağı doğru yerde. **Bloker #2 esasta kapandı.**
- **K3-L8 (soğuk açılış + ağ hatası ≠ `401`) belgenin en iyi yeni maddesi.** Uçak modu akışı adım adım yürütüldü: `compose up` → giriş → uçak modu → F5 → aktif profil kaydıyla yerel DB açılır → `/refresh` ağ hatası → **çevrimdışı-yetkili kalır** → geri dön → çalışır. **Akış sağlam** — yalnız B3'ün `429` dalında kırılıyor.
- **`__Host-` öneki, çerez enjeksiyonuna yapısal cevaptır** (rfc6265bis §5.7 + MDN + OWASP üçü de doğruladı) ve `Path=/` bedeli dürüstçe yazılmış. **RT-B2'ye verilen cevap doğru kurulmuş.**
- **`SameSite=Strict` × kardeş alt alan teşhisi doğru**; §5.2.1 ayağı da temiz (yüklü sayfanın kendi origin'ine `fetch`'i same-site).
- **`MapInboundClaims=false`'un üç yüzeyi de kaynaktan birebir doğrulandı** — abartı yok.
- **MS Learn `FallbackPolicy` × statik dosya alıntısı birebir doğru** ve **çözüm gerçekten çalışıyor** (yalnız mutant ayrımı kusurlu — B6).
- **M16 · M15 · M26 · M27 · M29 · M30 · M31 · M34 · M36 · M38 · M5 · M7 · M12 · M23 ısırıyor.** M7'nin *"süre değil çağrı sayılır"* ölçütü tablonun en olgun cümlesi.
- **`[DOĞRULANMADI]` doktrini YİNE KAZANDI.** `ConcurrencyLease`'in `RetryAfter` taşımadığı bu turda ölçüldü — belgenin **koşullu** yazımı doğru çıktı. Ölçülmemişi ölçülmemiş diye yazmak bu belgenin en güvenilir alışkanlığı.
- **Kapsam kayması yok.** K3-K3 ODEV §6.1'in kesin üst kümesi; her ek kalem §6'da gerekçeli. Ters yönde de sızıntı yok.
- **Numara bütünlüğü TAM.** M1–M39 = 39 numara; 0004'e ait beşi (M2·M3·M9·M10·M20) düşülünce **tam 34** kalır ve hepsi tabloda var. Kayıp yok, çift yok. **M13 VOID işlemesi yine örnek.** *(Tek kozmetik kusur: §3'ün numara sözleşmesi cümlesi M-L8'i saymıyor.)*
- **0003/0004 bölünme sınırı sağlam.**

---

## 5. ÖLÇÜLEMEYENLER

- **ADR 0001'in K-A1/K-H1 tam metni** — bağlı klasörde `docs/ADR/` yalnız `0003`'ü içeriyor ⇒ §2-M'nin NetArchTest kurallarının *"yeni"* mi *"mevcut ailenin uzantısı"* mı olduğu settle edilemedi. **v4, §3.1'in o cümlesini 0001'den birebir alıntıyla kanıtlamalıdır.**
- **moby `docker-proxy` kaynak satırı** — `cmd/proxy/tcp_proxy.go` fetch'i 404. **Ama sonuç bundan bağımsız kesindir:** B2 gerçek koşuyla ölçüldü.
- **WebKit/Safari'nin `http://localhost` üzerinde `Secure`/`__Host-` davranışı** — tarayıcı kaynağından ölçülmedi.
- **Builder'ın koşum tercihleri** (minimal API mi controller mı, `AddProblemDetails()` çağrılıyor mu, `WebApplicationFactory` mi çıplak `TestServer` mi) — M37 ve M19'un kesin sonucu buna bağlı; **ADR bunu yazmıyor** ve bu başlı başına bir eksikliktir.
- Argon2id 270 ms · Konscious/NSec yerel koşu beyanları · `flutter_secure_storage` Windows yöntemi — uzaktan yeniden ölçülemez (v2'den devralındı, değişmedi).
- **`GOREV-slice-3c-auth` spec'i hâlâ yok** ⇒ *"spec'te çözülür"* savunmaları bu turda da test edilemedi ve **kabul edilmedi**.

---

*Bu rapor bir denetim çıktısıdır. v3'ü yazan el bu hükmü veremezdi; bu oturum v3'e tek satır dokunmadı. **K13-a yürürlükte: bloker sıfırlanana kadar tur.** Sıradaki iş v4 — ve v4 **temiz ve ayrı bir oturumda** yazılır (dolu bağlamda ADR yazma yasağı).*

# ADR 0003 v2 — İKİNCİ VE SON BAĞIMSIZ KAPI — DENETİM RAPORU

- **Tarih:** 25 Temmuz 2026 · **Oturum:** 16 (Cowork) · **Denetlenen:** `docs/ADR/0003-kimlik-cekirdegi.md` (311 satır, 48.924 bayt)
- **Üreten ≠ denetleyen:** belgeyi oturum 15 yazdı; bu oturum yalnız **denetledi**, tek satır bile yazmadı.
- **Kapı kurulumu:** A turu = üç bağımsız denetçi **paralel** (mimari/tutarlılık · ölçüm/gerçeklik · mutant/kapı) → B turu = **RED-TEAM EN SON**, A'nın bulguları elinde ve onları **çürütmekle görevli**.
- **Ağaç durumu (denetim anında, kaynaktan ölçüldü):** `## main...origin/main [ahead 15]` · ` M PROJE_HAFIZA.md` · ` M docs/ODEV.md` · `?? arsiv/0003-…-v1-….md` · `?? docs/ADR/0003-kimlik-cekirdegi.md` · HEAD `060a37a` · `origin/main` `56362ed` · **push yok**.

## HÜKÜM: 🔴 **KİLİTLENEMEZ**

Dört denetçi de **bağımsız olarak** aynı hükme vardı. Birleşik **15 bloker**; bunların **7'si kör kapı** (mutant öldürülmüyor, baseline yeşil ⇒ sahte kapı olarak sessizce teslim edilirdi).

**Red-team A turunu çürütemedi:** A'nın 9 blokerinin **hiçbiri düşmedi**. 1'i kapsamca daraltıldı (çevrimdışı soğuk açılış), 1'i MAJÖR'e indirildi (M7 pin), 1'i MAJÖR'den **BLOKER'a yükseltildi** (e-posta partition), 2'si mekanizma düzeltilerek **güçlendirildi** (fallback policy, `/refresh` yüklemi).

---

## 0. TAKSONOMİ (adjudikasyon ölçütü — red-team'in getirdiği ayrım)

| sınıf | tanım | tehlike | rütbe |
|---|---|---|---|
| **Ölü tuzak** | mutasyon UYGULANMADAN baseline **KIRMIZI** | gürültülü, ilk koşuda yakalanır, konuşmaya zorlar | MAJÖR (karar eksikse BLOKER) |
| **Kör kapı** | mutant öldürülmüyor, baseline **YEŞİL** | **sessiz** — sahte kapı olarak teslim edilir | **BLOKER** |

A turunun üç denetçisi de bu ikisini aynı kefeye koymuştu; red-team ayırdı ve rütbeler buna göre yeniden verildi.

---

## 1. COWORK'ÜN KENDİ ÖLÇÜMLERİ
> *Alt-ajan beyanı doğrulanmadan aktarılmaz (yürürlükteki kural). Karar-taşıyıcı üç olgu iddiası ana oturumda, kaynaktan yeniden okundu.*

| # | iddia | ölçüm | kaynak |
|---|---|---|---|
| 1 | `RateLimiterOptions.RejectionStatusCode` varsayılanı **429 değil 503** | Birebir: `public int RejectionStatusCode { get; set; } = StatusCodes.Status503ServiceUnavailable;` · XML doc: *"Defaults to StatusCodes.Status503ServiceUnavailable"* · durum kodu `OnRejected` **çağrılmadan önce** set edilir, `OnRejected` onu ezebilir | `dotnet/aspnetcore` `release/9.0` → `src/Middleware/RateLimiting/src/RateLimiterOptions.cs` |
| 2 | `PartitionedRateLimiter` atıl partition'ları **temizliyor** | `private static readonly TimeSpan s_idleTimeLimit = TimeSpan.FromSeconds(10);` · timer periyodu `TimeSpan.FromMilliseconds(100)` · `if (idleDuration > s_idleTimeLimit) { _cacheInvalid = true; _limiters.Remove(rateLimiter.Key); _limitersToDispose.Add(...); }` + `await limiter.DisposeAsync()` | `dotnet/runtime` `release/9.0` → `System.Threading.RateLimiting/.../DefaultPartitionedRateLimiter.cs` |
| 3 | `FallbackPolicy` statik dosyaları/fallback ucunu da vurur | Birebir: *"For requests served by other middleware after the authorization middleware, such as **static files**, the policy applies to **all requests**."* | MS Learn, ASP.NET Core 9 authorization |

**Sonuçları:** (1) K3-J4'ün `429` kararı **override yazılmadan gerçekleşmez** ⇒ M11/M22/M23'ün kill sinyalleri baseline'da kırmızı. (2) K3-J5'in `[DOĞRULANMADI]` açık kalemi **kapatılabilir** — ama *"sıfır bellek"* diye değil, **"tavan ≈ istek hızı × 10 sn, ve tavanı anlamlı kılan şey K3-J2(1) IP penceresi"** diye. (3) K3-L4'ün aynı-origin kararı gerçek bir dağıtım çatalı bırakıyor.

---

## 2. BİRLEŞİK BLOKER LİSTESİ (kilit öncesi kapatılması ZORUNLU, önem sırasıyla)

### 1. RT-B1 — Kayıp yanıt: K3-L5 kendisine yüklenen görevi YAPISAL OLARAK yapamaz  *(taç kararı vuruyor)*
**Kırılma (saldırgan gerekmez, aktör = ağ):** İstemci `/refresh` gönderir (`T1`) → sunucu K3-C6'nın atomik UPDATE'ini **commit eder** (`T1.consumed_at` dolar, `T2` doğar) → **yanıt istemciye ulaşmaz** (uçak modu, hücresel el değiştirme, TCP reset, Android Doze/process kill) → istemcinin elinde hâlâ `T1` var, `T2`'yi hiç görmedi → yeniden dener → `consumed_at` dolu → **aile `reuse_detected` ile iptal, kullanıcı düşer.**

**Tek-uçuşluluk bunu kapsamaz:** K3-L5 *eşzamanlı* çağrıları serileştirir, *ardışık yeniden denemeyi* değil — 2. adımda uçuş zaten bitmiştir. Çatal adlandırılmamış ve **iki dalı da kötü**: (i) yeniden dener ⇒ aile düşer · (ii) denemez ⇒ K3-L6 gereği "oturum gerekli" ⇒ **tek ağ kesintisi 30 günlük oturumu zorunlu yeniden girişe çevirir** — çevrimdışı-öncelikli vitrinin tam ortası (ODEV §2 + §4(b)-1: değerlendirici uçak modunu açıp kapatacaktır).

**Kanıt:** RFC 9700 §4.14.2 bunu bir **maliyet** olarak kabul eder, telafi vaat etmez: *"…This stops the attack at the cost of forcing the legitimate client to obtain a fresh authorization grant."* ⇒ K3-L5'in *"meşru istemcinin kendini hırsız ilan ettirmemesi bu mekanizmaya bağlıdır"* cümlesi **yanlış beyandır** — ve belge yine de *"AÇIK ÇATAL KALMADI"* demektedir.

**Öneri:** (a) **Sınırlı replay-idempotency penceresi** — v1'in reddedilen zarafet penceresi DEĞİL: *"tüketilmiş `T1` yeniden sunulursa, `T1.consumed_at + N sn` içindeyse **ve** `T1.replaced_by_id`'nin işaret ettiği token **henüz tüketilmemişse**, kayıtlı halef aynen döndürülür; yeni döndürme yapılmaz."* R1'in kırdığı sonsuz zincir doğmaz (pencere `T1`'e çıpalı, ömür uzamıyor, yeni token yok) ve reuse-detection **ısırmaya devam eder**. · (b) dal (ii)'yi seç ve **adlandırılmış sınır** olarak yaz · (c) `/refresh`'te `Idempotency-Key`.

### 2. D1-B2 — `/refresh` yükleminde `revoked_at`/`expires_at` yok ⇒ `/logout` FİİLEN NO-OP
`/logout` aileyi `revoked_at` ile işaretler ama ailenin güncel token'ı **tüketilmemiştir**. K3-C6'nın tek yüklemi `WHERE id = @id AND consumed_at IS NULL` ⇒ **eşleşir** ⇒ döndürme başarılı ⇒ **çıkış hiç olmamış gibi devam eder**. Aynı yüklem `expires_at`'e de bakmadığı için **mutlak 30 gün ömür zorlanmıyor**.

Bu bir "yazılmamış adım" değil, **yanlış bir tamlık iddiasıdır**: K3-C6 birebir *"Etkilenen satır **0** ise token **ya tüketilmiştir** … **ya yoktur**"* diyor — sonuç uzayı hakkında **kapalı bir disjonksiyon**, ve şemada `revoked_at`/`expires_at` varken **yanlış**. "Önce SELECT ile doğrularız" savunması K3-C6'nın kendi check-then-act yasağıyla kapalı.

**Kapı deliği:** M18 yalnız *diğer* ailenin yaşadığını test eder ⇒ **`/logout` tamamen no-op olsa M18 YEŞİL kalır.**
**Öneri:** `WHERE token_hash = @h AND consumed_at IS NULL AND revoked_at IS NULL AND expires_at > @now` + 0-satır dalını üçe ayır (tüketilmiş ⇒ reuse · iptal/süresi geçmiş ⇒ düz `401`, aile iptali YOK · yok ⇒ `401`). **M26** (logout sonrası `401`) ve **M27** (`expires_at` geçmiş `401`) zorunlu.

### 3. D1-B1 (a)+(b) — "AÇIK ÇATAL KALMADI" beyanı YANLIŞ: K3-L4 iki dallı ve iki dal da bir kontrolü kırıyor
K3-L4 *"API statik dosyaları verir **veya** ikisi tek reverse-proxy altında birleşir"* diyor — **iki farklı dağıtım, farklı güvenlik sonuçları, karar yok**.

- **Dal (a):** `FallbackPolicy = RequireAuthenticatedUser` fallback ucunu ve (middleware sırasına göre) statik dosyaları da vurur ⇒ `GET /` ve SPA'nın her derin linki (`/tasks`, `/settings`) **401** ⇒ giriş ekranına fiziksel olarak ulaşılamaz (ODEV §2 ilk saniyede düşer). Kaçış yolu (`UseDefaultFiles`+`UseStaticFiles` auth'tan önce **ve** fallback ucuna açık `AllowAnonymous`) belgede yok. **M14 bu yönü ısırmaz** — M14 tersini test eder.
- **Dal (b):** reverse-proxy arkasında `RemoteIpAddress` **proxy'nin IP'sidir**; `UseForwardedHeaders` + `KnownProxies/KnownNetworks` kararı belgede **yok** ⇒ **tüm kullanıcılar tek partition** ⇒ K3-J2(1) — DoS'u durduran iki ayaktan biri — sessizce ölür. **M11/M23 `TestServer`'da (tek loopback IP) YEŞİL kalır ⇒ tam anlamıyla kör kapı.** Bu, R2'nin kapattığı hata sınıfının topolojik ikizidir: *"partition'ı saldırgan seçer"* → ***"partition'ı dağıtım siler"***.

### 4. RT-B2 — Naif double-submit, TUTULMA GEREKÇESİ OLAN vektöre karşı geçersiz
**Saldırı:** Saldırgan kardeş alt alan adını ele geçirir (`eski-blog.momentum.app`; DNS takeover / unutulmuş statik site / oradaki bir XSS) → `Set-Cookie: csrf=SALDIRGAN; Domain=momentum.app; Path=/` yazar (çerezler **origin** değil **domain** kapsamlıdır) → kurbanı o alt alandaki bir sayfaya çeker → sayfa `https://app.momentum.app/v1/auth/refresh`'i `X-CSRF-Token: SALDIRGAN` ile çağırır → `SameSite=Strict` yenileme çerezini **taşır** (istek same-site) → sunucu çerez==başlık karşılaştırır → **EŞLEŞİR** → geçer. `/logout-all` ile kurban tüm cihazlardan düşer; `/refresh` ile RT-B1 zinciri tetiklenir.

**Kanıt:** Belgenin kendisi K3-L4 notunda bu vektörü adlandırıyor ve double-submit'i **tam da ona karşı** tutuyor. OWASP CSRF Prevention Cheat Sheet: naif double-submit *"bypassable by an attacker who can write cookies on the target domain (e.g., via a vulnerable sibling subdomain, DNS takeover…)"* · *"For new code, use the Signed Double-Submit Cookie pattern above. **The naive pattern is documented for reference only.**"* — K3-L3(2) tam olarak naif varyantı tarif ediyor (imza yok, oturum bağı yok, `__Host-` yok).

**Öneri:** **`__Host-` öneki** (MDN: *"must not have a `Domain` attribute… only sent to the host that set them"*) ⇒ çerez enjeksiyonunu **yapısal olarak** engeller · CSRF token'ı **HMAC'li ve aileye bağlı** (signed double-submit) · **M25'in kill sinyali güncellenmeli** — bugünkü hâli (*"eksik/yanlış token reddedilir"*) naif implementasyonda da yeşil geçer ⇒ kör kapı.

### 5. RT-B3 (= D1-Ma-2, yükseltildi) — K3-J2(2) SEÇİLEN MEKANİZMAYLA İNŞA EDİLEMEZ
E-posta istek **gövdesindedir**; `RateLimiterOptions.AddPolicy` partitioner'ı **senkron** bir delegedir (`Func<HttpContext, RateLimitPartition<T>>`; üç aşırı yüklemenin üçü de senkron, `ValueTask` varyantı yok) ⇒ gövde `await` edilemez, `EnableBuffering` + senkron okuma Kestrel'in `AllowSynchronousIO=false` varsayılanına çarpar. Builder'ın kaçınılmaz seçimi limiti handler'ın içine koymaktır — bu da **K3-J3'ün bağlayıcı sırasını fiilen bozar** (handler'a girildiğinde middleware zinciri bitmiştir) ve M23'ün baseline'ını belirsizleştirir.
**Öneri:** K3-J2(2)'yi handler içinde `PartitionedRateLimiter<string>` olarak konumlandır ve K3-J3'ün sırasını *"middleware: IP penceresi → handler: e-posta penceresi → eşzamanlılık limiti → Argon2"* diye yeniden yaz; ya da anahtarı gövdeden değil başlıktan al.

### 6. D1-B3 + D1-B4 + D3 "token kaynağı" — TEK BULGU: yenileme token'ının taşıma kanalı platform başına kararlaştırılmamış
- **`/logout`'un "sunulan token"ı tanımsız:** K3-J1 `/logout`'u kimlik-ister yapıyor ⇒ istek `Bearer <JWT>` taşır; JWT talepleri `sub, jti, iat, exp, sstamp` — **`family_id` yok**, `jti↔aile` eşlemesi yok ⇒ hangi ailenin iptal edileceği **hesaplanamaz**. Tek çıkış yolu tüm aileleri düşürmektir = K11-d'nin **reddettiği** davranış (M18'i kırar).
- **Teslim kanalı:** `/login` ve `/refresh` tek uçtur; native **ham değer** ister, web **almamalıdır**. Sunucunun web/native'i nasıl ayırt ettiği yazılmamış ⇒ en doğal builder seçimi ("hep gövdede + web'e ayrıca `Set-Cookie`") **K3-L2'nin *"tek XSS yenileme token'ını okuyamaz"* gerekçesini doğrudan yalanlar.**
**Öneri:** uç sözleşmesine ayırt edici (`X-Client-Kind: web|native` ya da ayrı alt yol) + PAZARLIKSIZ kural: web modunda yenileme token'ı **yanıt gövdesinde hiç görünmez**. `/logout` girdisi kilitlenir (yenileme token'ı gövde/çerez **veya** JWT'ye `fid` talebi). **M28** eklenir.

### 7. D2-#12/13/14 — `RejectionStatusCode` varsayılanı **503**; K3-J4 kararı verdi ama override'ı yazmadı
`429` açıkça yapılandırılmazsa gelmez; `Retry-After` otomatik değildir (`OnRejected` gerekir). Bu, belgenin §4'teki kendi manşet tezinin (*"bir ADR'nin işi sessiz varsayılanların hangisinin kabul edildiğini yazmaktır"* — `ClockSkew` için titizlikle uygulanmış) **birebir ihlalidir**. Ayrıca 503 semantik olarak yanlıştır ve Flutter istemcisinin retry politikasını *"sunucu çökmüş"* diye yorumlatır. M11/M22/M23'ün kill sinyalleri düzeltilmeli.
> **[DOĞRULANMADI]** `ConcurrencyLease`'in `MetadataName.RetryAfter` taşıyıp taşımadığı bu turda ana oturumda ölçülmedi (bir denetçi *"taşımıyor, yalnız `ReasonPhrase` var"* dedi; teyit edilmedi). K3-J4'ün eşzamanlılık yolunda `Retry-After` vaat edip edemeyeceği buna bağlıdır.

### 8. RT-B4 — İmzalama anahtarının BOOTSTRAP'ı yok ⇒ değerlendiricinin makinesinde AÇILMAZ, ya da sır repoya girer
K3-I2 anahtarsız başlangıcı patlatıyor (doğru karar), K3-I1 gömülü anahtarı yasaklıyor (doğru karar) — ama `dotnet user-secrets` **klonla gelmez**. Değerlendirici `docker compose up` der, **hiçbir şey ayağa kalkmaz**; aynı-origin kararı (K3-L4) yüzünden web de kalkmaz. ODEV §2 (*"kesinlikle çalışan bir uygulama… önce uygulamaya bakılacak"*) doğrudan vurulur. Compose'a anahtar yazmak **kırmızı çizgi #1** ihlalidir. Belge bu ikilemi **hiç kurmuyor**.
**Öneri:** `.env.example` + compose'un ilk açılışta rastgele dev anahtarı üretip git-ignore'lu dosyaya yazması; **yalnız `Development`'ta**, üretimde eksik anahtar hâlâ patlar. **M8 iki ayaklı olur:** *"Production'da anahtarsız başlangıç patlar"* + *"Development bootstrap'ı üretim yolunda ASLA koşmaz"*.

### 9. D3-B4 — K3-L5/L6/L7 hem KAPISIZ hem DEVİRSİZ
K3-C5 tüm sunucu-tarafı duruşunu K3-L5'e yükledi; L5/L6/L7'nin ne mutantı var ne devir kalemi. **Ölçüt belgenin kendi emsalidir:** 0004'e giden her mekanizma *"kaybolmasın diye adlandırılmış"* (M2·M3·M9·M10·M20 + pull-authz + imleç, D-1..D-6 ile eşlenmiş); 3b'ye giden **hiçbiri** adlandırılmamış. §7'nin *"Sonra: slice-3b"* cümlesi bir bağımlılık notudur, devir değil. **Asimetri belgenin kendi standardıdır ⇒ ihlal.**
**Öneri (saf Dart birim testleri, ucuz):** **M-L5** tek-uçuşlu kilit kaldırılır → *"eşzamanlı N adet 401 karşısında TAM OLARAK 1 kez `/refresh` çağrılır"* FAIL · **M-L6** 401'de kuyruk temizlenir → *"gönderilmemiş op'lar diskte kalır ve yeniden girişte gönderilir"* FAIL · **M-L7** tek DB dosyasına dönülür → *"A çıkıp B girince A'nın görevleri okunamaz VE A yeniden girince kuyruğu duruyor"* FAIL.

### 10. D1-B5 (daraltıldı) — Soğuk açılışta `userId` nereden gelecek, kararlaştırılmamış
Üç karar birlikte bir **şema sonucu** üretiyor: erişim token'ı yalnız bellekte (K3-L1/L2) + yerel dosya adı `momentum_{userId}.sqlite` (K3-L7) + `userId`'nin tek kaynağı doğrulanmış JWT'nin `sub`'ı (K3-D2) ⇒ **ağsız açılışta yerel DB açılamaz.** *("Çevrimdışı kullanıcı hangi ekranı görür" 3b'nin işidir; `userId`'nin nereden geldiği 0003'ün işidir — §1 dilimi zaten "bir ŞEMA kararıdır" diye tanımlıyor.)*
**Öneri (§2-L'ye tek satır):** son oturum açan `userId` (sır değildir) DB dosyalarının dışında kalıcı bir "aktif profil" kaydında tutulur; yerel DB ağ olmadan onunla açılır. Ayrıca `/refresh`'in **ağ hatası** dalı **401** dalından ayrılır: ağ hatasında istemci **çevrimdışı-yetkili** kalır (yerel DB tam okunur/yazılır, yalnız senkron durur); *"oturum gerekli"* yalnız sunucu `401`/`reuse_detected` dönerse tetiklenir.

### 11. RT-B5 — Parola politikası + girdi doğrulama ne karara bağlanmış ne kapsam dışı ⇒ GİZLENMİŞ SINIR
`/register` parolası `"a"` olabilir — asgari uzunluk/karmaşıklık kuralı yok, azami uzunluk yok, e-posta format/uzunluk doğrulaması yok. K3-K3'ün kapsam-dışı listesinde de yok, ODEV §6.1'de de yok. Argon2id'nin `m=19456, t=2` yatırımı `123456` parolasına karşı hiçbir şey satın almaz. Ek yüzey: sınırsız uzunlukta `email_normalized` btree index sınırına çarpıp `500` üretirse K3-B5'in *"tek tip ProblemDetails"* garantisi de kırılır.
**Öneri:** §2-B'ye iki satır (asgari ≥10, karmaşıklık kuralı YOK — NIST SP 800-63B çizgisi, gerekçesiyle; azami 128; e-posta azami 254 / RFC 5321 + format doğrulama) + bir mutant; **ya da** açıkça kapsam dışı ilan et. Sessiz bırakma doktrine aykırı.

### 12. D3-B2 + RT-M3 — M16'nın `alg` ayağı ISIRMIYOR **ve** K3-C7'nin beyanı yanlış
Simetrik anahtarla RS256/ES256 **yapısal olarak** reddedilir (`SymmetricSignatureProvider` yalnız `HmacSha256/384/512` + `Aes*CbcHmacSha*`); `alg:none`'ı kapatan `ValidAlgorithms` değil **`RequireSignedTokens`**'tır. ⇒ Testi `alg:none` veya RS256 ile yazan bir builder'da mutant **hayatta kalır** = kör kapı. Pinlemenin kapattığı **tek** şey aynı anahtarla HS384/HS512 ikamesidir — **ve o anahtara sahip saldırgan zaten HS256 imzalayabilir** ⇒ düzeltilmiş M16 bile *kapı* değil **hijyen**.
**Öneri:** ayarı **tut** (ileride asimetrik anahtar eklenirse kritik), K3-C7'nin *"algoritma-karıştırma sınıfını tek satırla kapatır"* cümlesini **düzelt**, `alg` ayağını kapı saymaktan vazgeç veya HS512 varyantına pinle.

### 13. D3-B1 — M22 ISIRMIYOR + hız sınırlama SAYILARI hiç kararlaştırılmamış
K3-J3 sırayı bağlayıcı kılıyor, K3-J4 yanıtı tek tip yapıyor ⇒ M22'nin testi eşzamanlılık limitini doldurmak için gönderdiği isteklerle **önce IP penceresini** doldurur ⇒ mutasyon uygulandığında test **hâlâ ret alır ve YEŞİL kalır**. Ters yönde: sahte hasher hızlıysa eşzamanlılık limiti hiç dolmaz ⇒ **baseline'da ret gelmez = ölü tuzak**. Üstelik K3-J2 ne pencere süresi, ne izin sayısı, ne `QueueLimit` veriyor — ama M11/M22/M23 *"N+1'inci istek"* diyor.
**Öneri:** sayıları belgede kararlaştır · M22 ayrı IP'ler (veya o test için yükseltilmiş IP limiti) kullansın · `IPasswordHasher`'ın **bloke eden sahte** implementasyonu (test kontrollü semafor) · reddin kaynağını ayırt eden bant-dışı ölçüt (`OnRejected`'ın yazdığı ayırt edici `ReasonPhrase`/hata kodu).
> **Ölçüm notu:** `System.Threading.RateLimiting.ConcurrencyLimiter` **public sealed**tir ⇒ DI'a konup `AcquireAsync` ile **yalnız Argon2 çağrısı** sarılabilir; `SemaphoreSlim` gerekmez. Ama middleware politikası bunu yapamaz — belge hangisini seçtiğini yazmalı.

### 14. D3-B3 — M17 donmuş `FakeTimeProvider` altında ISIRMIYOR
0001 K-C5 `TimeProvider`'ı pazarlıksız kılıyor ⇒ deterministik testin doğal biçimi **donmuş** `FakeTimeProvider`'dır (varsayılanı da donmuş). Saat ilerletilmezse `/login` ve `/refresh` aynı `now`'u görür ⇒ mutant ("yeni mutlak son kullanma verilir") **aynı** `expires_at`'i üretir ⇒ eşitlik assert'i geçer, test **YEŞİL** = kör kapı.
**Öneri (tek satır):** kill sinyaline *"aile doğduktan sonra saat ileri alınır ve `expires_at` TAM EŞİTLİK ile karşılaştırılır"* eklenir. Ayrıca `expires_at` devralmanın **değişmezi** yazılır: *"aynı `family_id`'nin tüm satırları özdeş `expires_at` taşır; yeni satır sunulan satırdan kopyalar."*

### 15. D3-B6 — K3-B2'nin NetArchTest kuralı MUTANTSIZ (en ucuz bloker)
ADR 0001 **K-H1** birebir: *"NetArchTest — gerçekten ihlal-edilebilir kurallar: … **Her kural commit'li negatif/mutant testle ısırdığını kanıtlar.**"* Bu **kilitli** bir ADR'nin "Her" içeren kuralıdır ve K3-B2 **yeni** bir kural ekliyor. *"Mutant tablosu spec'e aittir"* savunması burada çalışmaz: §3'ün kendi giriş cümlesi tabloyu spec listesinin *"kimlik-çekirdeği **yarısı**"* ilan ederek **tamlık iddia ediyor**.
**Öneri (bir satır):** *Mutasyon:* Application katmanındaki bir sınıfa `Konscious.Security.Cryptography` referansı eklenir. *Kill:* `"Konscious.* Domain/Application/Api'de görünmez"` NetArchTest kuralı **FAIL**.

---

## 3. MAJÖR BULGULAR (bloker değil ama v3'te kapanmalı)

| # | bulgu |
|---|---|
| Ma-1 | Eşzamanlılık limiti `/register`'ın Argon2 **hash**'ini kapsamıyor (tanım *"parola doğrulama işi"*) ⇒ Risk #4'ün telafi cümlesi `/register` yolunda yanlış. Kontrol 3 *"her Argon2 çağrısı (hash + verify)"* olmalı. |
| Ma-3 | K3-C1 talep listesinde **`iss`/`aud` yok** ama K3-C7 ikisini de zorunlu kılıyor ⇒ liste harfiyen uygulanırsa her istek `401`. |
| Ma-4 | **PHC string'in AYRIŞTIRILMASI hiç yazılmamış** — bozuk/tanınmayan format ⇒ `FormatException` ⇒ `500` ⇒ K3-B5'in tek-tip yanıt garantisi kırılır (bilinen/bilinmeyen e-posta yanıt kodundan ayırt edilir). Rehash karşılaştırmasının hangi alanlar üzerinden yapıldığı da yok. |
| Ma-5 / RT-M4 | **`security_stamp` / `sstamp` ÖLÜ ALAN:** kolon var, claim var, **doğrulaması yok**, hiçbir olayda değişmiyor. *Sunulmamış ödünleşim:* `/logout-all` `security_stamp`'i artırıp doğrulama karşılaştırsaydı **Risk #3'ün 15 dakikalık penceresi sıfıra inerdi** (bedeli: istek başına bir DB okuması). Ya kanca kurulsun ya *"bugün ölü alan, bilinçli"* diye beyan edilsin. |
| Ma-6 | **Port envanteri eksik:** JWT üretimi kim yapar (hangi katman?), `Microsoft.IdentityModel.Tokens` nerede referanslanır, `refresh_tokens` ham SQL'i hangi port arkasında, `ICurrentUser` impl Api'de mi Infrastructure'da mı — ve hangi NetArchTest kuralları yazılacak. K9'un *"paket değişimi tek sınıfı etkiler"* ilkesi kimliğin yarısında geçersiz kalıyor. |
| Ma-7 | §7'nin devir listesinde **`M-C` (`clientId → principal`) borcunun karşılığı YOK** — D-6 yalnız `sync_client_clock.user_id` **kolonunu** ekliyor, zorlama kuralını (bir `clientId` başka bir principal tarafından kullanılırsa ne olur) hiçbir D maddesi taşımıyor. **D-7** olarak adlandırılmalı. Aynı şekilde **M20 (sahiplik TOCTOU)**'un iniş yeri de zayıf. |
| Ma-8 | **Çerez öznitelikleri hiç yazılmamış:** ad, `Path`, `Domain`, ömür. `Path=/` ⇒ yenileme çerezi her API isteğinde tele çıkar; `Path=/v1/auth/refresh` ⇒ `/logout` çerezi hiç almaz. Ömür yazılmadığı için oturum çerezi (F5 = çıkış, **reddedilen şıkka geri dönüş**) ile 30 günlük kalıcı çerez arasında karar yok. |
| Ma-9 | CSRF ikinci hattının **kapsamı tutarsız** (K3-L3 `/logout`'u sayıyor ama K3-J1 onu Bearer'lı yapıyor) ve CSRF çerezinin yaşam döngüsü (ne zaman set/rotate, adı, `SameSite`'ı) yok; M25 yalnız `/refresh`'i test ediyor, `/logout-all` hiç anılmıyor. |
| RT-M1 | **`Secure` çerez `http://localhost` DIŞINDA reddedilir** ⇒ değerlendirici `http://192.168.1.x:8080` üzerinden açarsa çerez hiç set edilmez, `/refresh` sessizce çalışmaz. K3-L4'ün kendi bulduğu hata sınıfının (*"ancak canlı web demosunda fark edilirdi"*) tekrarı. `localhost` ya da HTTPS zorunluluğu yazılmalı, teslim paketine bağlanmalı. |
| RT-M2 | **Web'de tek-uçuşlu refresh SEKMELER ARASI olmak zorunda.** Yenileme çerezi origin'in tüm sekmelerinde ortak, erişim token'ı sekme-yerel ⇒ iki sekmede eşzamanlı F5 → biri tüketir, diğeri **reuse** üretir → **aile düşer, iki sekme birden çıkar.** Dart `Completer` mutex'i sekme-yereldir; gereken **Web Locks API / `BroadcastChannel`**. |
| RT-M5 | Aynı-origin kararının **XSS sonucu adlandırılmamış:** XSS'in yenileme token'ını *okumasına* gerek yok — sayfa açıkken `/refresh`'i çağırıp (çerez otomatik, CSRF çerezi okunabilir) her 15 dk'da bir taze erişim token'ı sızdırabilir. `HttpOnly`'nin satın aldığı şey gerçek ama sınırlıdır; belge alt-alan vektörünü paragraflarla adlandırırken bunu yazmıyor. |
| RT-M6 | `/logout` ve `/logout-all` **hız sınırı kapsamında değil** (çalınmış token'la DB yazma fırtınası); ters yönde CGNAT/ofis NAT'ı arkasındaki tüm meşru kullanıcılar tek partition'a düşer — **yanlış-pozitif tarafı hiç adlandırılmamış**. |
| D2-#21 | `flutter_secure_storage` Windows'ta **DPAPI kullanmıyor** (bir denetçi: AES-GCM + Windows Credential Manager; red-team bunu doğrulayamadı, README yöntemi söylemiyor). Lisans **BSD-3-Clause** (0001 K-H2'nin izinli ailesinde ⇒ kırmızı çizgi 3 tetiklenmiyor). Web ayağı README'de *"**experimental**… **use at your own risk**"* + LocalStorage ⇒ **K3-L2'nin web reddi ölçümle DOĞRULANDI.** |
| D3 | Mutant tablosunda **TEST SEVİYESİ sütunu yok** ve §Bağımlılık'ın *"saf çekirdek DB'siz kanıtlanır"* iddiası tutmuyor: 19 canlı mutantın **≥9'u** DB istiyor, 2'si derleme, yalnız **2'si** saf birim. · **"Mutantsız olduğu açıkça yazılanlar" dürüstlük beyanı bölümü yok** (K3-C7'nin 5 satırı, K3-C4'ün ≤15 dk sınırı, K3-J4, K3-A3, K3-L1/L2 sessizce kapısız). · **M6'nın `==` yarısı yanlış sinyal** (`byte[] ==` referans karşılaştırmasıdır, BannedApiAnalyzers'la ifade edilemez). · **M19'un mutasyon biçimi kararsız** (ya tüm suite düşer ya hiç ısırmaz). · **M14'ün hedef ucu tanımsız.** · **M24'ün test seviyesi yazılmamış** (sahte `TestAuthHandler` ile ısırmaz). · **M12 fazla gevşek** (SHA-256 pinlenmiyor). · **K3-B5'in "aynı yanıt" ayağı KAPISIZ.** · **K3-C6'nın ATOMİKLİK iddiası test edilmiyor** (paralel `/refresh` yarışı; 0002 K2-H12 emsali var). · **K3-C3 `family_id` doğum anı** yalnız tesadüfen kapsanıyor, M18 ayırt edici değil. · **0004'ün mutant numaralandırması pinlenmemiş** (aynı spec'te iki `M1` riski) ⇒ *"0004 M26'dan devam eder"* yazılmalı. |
| D2-#5 | `MapInboundClaims=false`'un **üçüncü yüzeyi:** `NameClaimType`/`RoleClaimType` bağımsızdır, `ClaimTypes.Name` kalır ⇒ `User.Identity.Name` **null**. Bu kapsamda etkisiz (token'da `name` yok, roller kapsam dışı) ama **işbirliği diliminde canlanır** ⇒ adlandırılmalı. |
| Mi-1 | **Ad çakışması: `slice-3a` ZATEN VAR** — 0002 K2-I3 *"slice-3a = sunucu materyalizasyonu + okuma API'si"* ve `KANIT/slice-3a/` klasörü dolu. Bu proje "aynı numara iki anlam" hatasını iki kez yedi. `slice-3c-auth` ya da `slice-4-auth` önerilir. |

---

## 4. DÜRÜSTLÜK BEYANI — KIRILAMAYAN YERLER

Denetçiler bu alanlarda **kusur aradı ve bulamadı**:

- **Oturum sabitleme (session fixation)** — K3-C3 her `/login`'de yeni `family_id` doğurup çerezi üzerine yazdığı için saldırganın diktiği çerez etkisiz. **v1'e göre gerçek kazanç, doğru kurulmuş.**
- **K3-A2 normalizasyon zinciri** — Türkçe `İ/ı`, Kelvin işareti (U+212A), ayrık/birleşik aksan ve `Trim` boşluğu üzerinden kırılmaya çalışıldı; **sıra doğru** (NFC → sonra küçültme) ve `COLLATE "C"` + `ToLowerInvariant` + BannedApiAnalyzers üçlüsü kapatıyor. Frontend kardeşinin (Dart `toUpperCase()`) adlandırılması iyi iş.
- **K3-C2'nin bilinçli asimetrisi** (yenileme token'ında Argon2 değil SHA-256) — 256-bit CSPRNG'e sözlük saldırısı yok; gerekçe doğru ve açık.
- **K3-A4 ↔ D-3 zinciri** — `User`'ın global filtre dışında tutulması gerçek bir mayın, doğru yerde adlandırılmış, kapısı devredilmiş. *"Karar var, kapı yok, devir de yok"* kalıbı burada **yok**.
- **K3-D1** — `Guid.Empty` yerine `UnauthenticatedException`; M15 gerçekten ısırıyor (tablonun en temiz satırı, saf birim).
- **K3-L4'ün `SameSite` × CORS teşhisi** — teşhis doğru ve önemli; alt-alan sınırının adlandırılması da doğru. Sorun sınırın kendisi değil, ona karşı seçilen savunmanın yetersizliği (RT-B2).
- **K3-L2'nin `flutter_secure_storage`'ı web'de reddetmesi** — paket README'siyle **doğrulandı**.
- **K3-J5'in `[DOĞRULANMADI]` etiketi** — doktrin tam olarak çalışmış: ölçülmemiş bir şey ölçülmemiş diye yazılmış. Ölçüldü, iddia doğru çıktı.
- **K3-B1'in risk beyanı + izolasyon cevabı** — paketi savunmak yerine port arkasına almak doğru refleks; §4'ün bu paragrafı belgenin en iyi yeri.
- **K3-C7'nin dört ölçüm ayağı** — `ClockSkew` 300 sn · `MapInboundClaims` `true` · `InboundClaimTypeMap` `sub→NameIdentifier` · `DefaultUserIdProvider` — hepsi kaynaktan **birebir doğrulandı**, abartı yok. (`MapInboundClaims` tuzağı da patlamadı: `JsonWebTokenHandler`'ın kendi varsayılanı `false` ama `JwtBearerOptions` handler'ı `true`'ya zorluyor.)
- **Numara bütünlüğü TAM** — M1..M25 = 20 (bu belge) + 5 (0004'e devir) = 25. Kayıp yok, çift yok. **M13 VOID işlemesi örnek** (satır duruyor, gerekçesi yazılı, sessizce kaybolmamış).
- **M1 gerçekten canlandı** (pencere kalktığı için baseline yeşil, mutant kırmızı) · M23 tablonun en iyi mutantı, R2'yi gerçekten kanıtlıyor · M4'ün "derleme kırılır" sinyali 0001 K-H1'e karşı doğrulandı · M5/M8/M11/M15/M18/M21 ısırıyor.
- **v1 bulgu izi ölçülebilir** — R1..R7, B1..B5, M1/M4/M6/M7/M13 tek tek izlendi; **sessizce düşürülmüş bulgu yok**.
- **Kapsam kayması yok** — K3-K3'ün kapsam-dışı listesi ODEV §6.1'in üst kümesi; her ek §6'da gerekçesiyle adlandırılmış.
- **0003/0004 bölünme sınırı sağlam** — sınırda kararsız kalmış kimlik-çekirdeği maddesi bulunamadı; tek eksiklik devir listesinin **eksikliğidir** (Ma-7), bölünmenin yeri değil.
- **`SameSite=Strict` + harici link şüphesi TEMİZ** — RFC 6265bis §5.2.1: sayfa yüklendikten sonra aynı origin'e giden `fetch` **same-site**'tır, çerez gider. Belgenin suskunluğu haklı; yine de bir cümleyle yazılmalı (bir sonraki denetçi de aynı yere saldıracak).

## 5. ÖLÇÜLEMEYENLER

- Isopoh lisans belirsizliği · NSec-libsodium'un OWASP parametrelerinde koşmaması · Argon2id 270 ms — **yerel koşu beyanları**, uzaktan yeniden ölçülemez.
- `ConcurrencyLease`'in `MetadataName.RetryAfter` taşıyıp taşımadığı.
- `flutter_secure_storage`'ın Windows şifreleme yöntemi (README söylemiyor; ne "DPAPI" ne "AES-GCM + Credential Manager" ana oturumda doğrulandı).
- Postgres btree index anahtar boyutu sınırının sınırsız `email_normalized` ile etkileşimi.
- `GOREV-slice-3a-auth` spec'i henüz yok ⇒ *"spec'te çözülür"* savunmaları spec'e karşı test edilemedi.

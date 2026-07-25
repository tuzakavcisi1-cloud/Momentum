# KAPI-4 DENETİM RAPORU — ADR 0003 v4 (`docs/ADR/0003-kimlik-cekirdegi.md`)

> **Oturum 20 · 25 Tem 2026 · DENETİM OTURUMU.** Bu oturum ADR'ye **tek satır yazmadı**.
> Üreten ≠ denetleyen: v4'ü oturum 19 yazdı, bu oturum yalnız denetledi.
> **Bu 4. kapı turudur** (K13-a: bloker sıfırlanana kadar tur; tur sayısı raporlanır, sınırlanmaz).

## 🔴 HÜKÜM: KİLİTLENEMEZ — **9 BLOKER · ~27 MAJÖR · ~28 MİNÖR**

Dört denetçinin dördü de bağımsız olarak aynı hükme vardı.

---

## 0. Denetlenen artefakt — kimlik ölçümü (ana oturum, kaynaktan)

| ölçüm | değer |
|---|---|
| dosya | `docs/ADR/0003-kimlik-cekirdegi.md` |
| bayt · satır | **170.261 · 885** |
| sha256 (Onur'un diski) | `b85ce0b3c899641ce7d434994222189015bac2cd7609bb811d8f23327e0c45d0` |
| sha256 (denetim kopyası) | **aynı** ⇒ denetim gerçek artefakt üzerinde koştu |
| kodlama | UTF-8 geçerli · BOM yok · U+FFFD **0** · mojibake **0** · 10.562 Türkçe harf |
| `git status` | ` M PROJE_HAFIZA.md` · ` M docs/ODEV.md` · `?? KANIT/adr-0003/` · `?? arsiv/…v1/v2/v3…` · `?? docs/ADR/0003-kimlik-cekirdegi.md` · HEAD `060a37a` · `origin/main` `56362ed` · **ahead 15, push yok** — devir notuyla **birebir** uyuştu |

## 0.1 Kapı kurulumu

**A turu — üç bağımsız denetçi, PARALEL** (birbirlerinin bulgularını görmediler):
- **A1 — mimari / iç tutarlılık** · **A2 — ölçüm / gerçeklik (birincil kaynak)** · **A3 — mutant / kapı**
- Üçü de belgenin **885 satırının tamamını** okudu; okuma aralıklarını raporlarında beyan ettiler.

**B turu — RED-TEAM, EN SON.** Görevi A'yı onaylamak değil **çürütmekti**. Sonuç: 3 bulgu + 1 premis **çürütüldü**, 3 bloker majöre **indirildi**, 4 majör minöre **indirildi**, red-team **1 yeni bloker + 3 yeni majör** getirdi.

**Ana oturum — adjudikasyon.** Alt-ajan beyanı **aktarılmadı**: hükmü taşıyan **9 blokerin 9'u da** ana oturumda kaynaktan **yeniden ölçüldü** (dosya+satır ve/veya birincil kaynak URL'i). Aşağıdaki her bloker satırındaki ölçümler ana oturumun kendi ölçümleridir.

---

## 1. AYAKTA KALAN 9 BLOKER

### B-1 · `M11` ÖLÜ TUZAK — kill sinyali bayat tavana pinli
**Ölçüm (ana oturum):** satır **686** birebir: *"aynı IP'den **11.** `/login` denemesi `429` alır ve `problem.Extensions[\"limit\"] == \"ip\"`"* **FAIL**. Satır **429** (politika 1a) birebir: **30 istek / 5 dk**.
⇒ 11. istek baseline'da `429` **almaz** ⇒ test **kırmızı doğar** = belgenin kendi tanımıyla ölü tuzak (satır 741).
**Kardeşi düzeltilmiş, kendisi unutulmuş:** satır **697** `M23` birebir *"**31.** … **[K16-b]** sayı 11→31 (tavan 30/5 dk)"*.
**İkinci bağımsız kırılma:** test aynı e-posta ile koşarsa kontrol 2 (5/15 dk) **6.** istekte ısırır ⇒ `limit == "email"` döner ⇒ `== "ip"` assert'i **yine** FAIL.
**Ağırlaştırıcı:** §0.1/§0.3 bu kalemi **yapılmış ilan ediyor**; `PROJE_HAFIZA` K15 satırı M11'i **adıyla** istemişti.
**v5 ne yapmalı:** sinyali `31.` yapmak yetmez — önkoşula *"her istekte FARKLI e-posta"* eklenmeli (M23'teki gibi), çıpa `K3-J2(1)` yerine 1a'ya güncellenmeli ve *"aynı IP'den"* ifadesi K15-b'den sonra **yanlış** olduğu için düzeltilmeli (`RemoteIpAddress` `TestHost`'ta `null`).

### B-2 · `M46` KÖR — mutasyon gözlemlenebilir fark üretmiyor (birincil kaynaktan)
**Ölçüm (ana oturum):** satır **724** birebir kill sinyali: *"kimliksiz **40 statik dosya** isteğinden **sonra** `/v1/auth/login` isteği **`429` ALMAZ**"* **FAIL**.
**Belge-içi tarama:** küresel (global) limiter kararı belgede **yoktur**; `global` kelimesi yalnız satır **404**'te *varsayımsal* bir cümlede geçer. Satır **429-433**: üç politika da **uç-bazlıdır** (`RequireRateLimiting`).
**Birincil kaynak — `RateLimitingMiddleware` (aspnetcore `release/9.0`), birebir:**
> `// If this endpoint has no EnableRateLimitingAttribute & there's no global limiter, don't apply any rate limits.`
> `if (enableRateLimitingAttribute is null && _globalLimiter is null) { return _next(context); }`
⇒ Statik dosya isteği hiçbir kovayı **tüketemez** — ne baseline'da ne mutasyonda. Assert **her iki durumda da sağlanır** ⇒ test **hiçbir zaman kırılamaz**.
**İkinci ayak:** satır **405**'in gerekçesi (*"onlarca asset isteği kovayı ilk saniyede tüketir"*) **yapısal olarak imkânsız** bir olgu iddiasıdır ⇒ belgenin kendi §4 kuralının ihlali ⇒ Ma-11'in kapanma iddiası karşılıksız.
**v5 ne yapmalı:** ya küresel limiter bir **karar** olarak yazılır (o zaman M46 ısırır), ya M46 gözlemlenebilir başka bir davranışa çıpalanır (ör. `UseRouting` öncesi ⇒ `/refresh` ile `/login` ayrımının kaybı — bu **gerçekten** gözlemlenebilir), ya da kalem §3.1'e **kapısız** diye yazılır. Üçüncü seçenek yok.

### B-3 · §3.1'in TAMLIK İDDİASI ÜÇÜNCÜ KEZ YANLIŞ — kapısız-ve-beyansız liste 10 kalem
**Ölçüm (ana oturum):** §3.1'in "kapısız kalan" tablosu (satır **744-775**) **tam** okundu. Aşağıdakiler **ne mutant tablosunda ne §3.1'de** var:
1. **K3-I4'ün "kök anahtar doğrudan kullanılmaz" kararı** — §3.1'de muaf tutulan şey yalnız `info` **etiketleridir**; *türetmenin kendisi* değil. M42'nin mutasyonu **bileşiktir** (türetme + efemer üretim), türetme ayağı tek başına ısırmaz.
2. **K15-a'nın "şifreli" özelliği** — `successor_secret_enc`'in şifreli olduğunu hiçbir mutant ölçmüyor; oysa §6 Risk #13'ün kabul gerekçesinin tamamı buna dayanıyor.
3. **K3-C6(5)'in tembel/fırsatçı silme ayağı** (*"İKİ MEKANİZMA, İKİSİ DE ZORUNLU"* denmiş; M40 yalnız süpürücüyü ısırtıyor).
4. **Süpürme periyodu (60 sn)** — Risk #13'ün *"en kötü 120 sn"* aritmetiğinin yarısı ölçülmüyor.
5. **Parola NFC normalizasyonu** (M21 yalnız **e-posta** NFC'sini ısırtıyor).
6. **Kontrol 1b/1c sayıları (120/60)** — K16-b'nin üç sayısından **ikisi** hiçbir mutantla ölçülmüyor.
7. **`RefreshSecretSweeper`'ın DI scope'u** (K3-D3 tuzağı).
8. **K3-A3'ün `COLLATE "C"` + `409` ayağı** (K3-A3 §3.1'de var ama yalnız *sayım oracle'ı* gerekçesiyle).
9. **K3-D4.**
10. **K3-L8(1) aktif profil kaydı.**
**Bu kök neden ÜÇÜNCÜ turdur bloker üretiyor** (kapı-2 #15 → kapı-3 B7 → kapı-4 B-3+B-6).
**v5 ne yapmalı:** ya §3.1'in *"bu liste, tablonun tamlık iddiasının sınırıdır"* cümlesi **geri çekilir**, ya §2'nin her **KARAR/PAZARLIKSIZ** maddesinin ya mutant tablosunda ya §3.1'de bir satırı olduğu **mekanik olarak** (araçla) doğrulanır. Aksi hâlde 5. tur aynı bulguyu üretir.

### B-4 · "handler" HANGİ KATMAN — karar boşluğu; bir dalda `M32b`'nin baseline'ı KIRMIZI doğar
**Ölçüm (ana oturum):**
- §2-M port envanteri (satır **637-648**) **dokuz** satırdır; kontrol 2/3 ve `RateLimitProblemFactory` için **tek satır yok**. **`users` kalıcılığı için de satır yok** — oysa bölümün açılış cümlesi kimliğin *"yarısında geçersiz kalıyordu"* diyor ve kimliğin yarısı `users`'tır.
- Satır **432/433**: kontrol 2 ve 3 **"handler içi"**. Satır **465-469** sözde-kodu: `handler:` gövde deserialize → doğrulama → e-posta penceresi → eşzamanlılık limiti.
- **"handler" iki katmanı birden gösteriyor:** ADR 0001 satır **27** *"`Momentum.Application` | **CQRS handler**"*; ADR 0001 satır **80** (K-H1) *"**Api endpoint/handler** ⊥ Infrastructure somut tipleri"*. ADR 0003 §3.2(4) uç stilini *"minimal API handler'ları"* diye pinliyor. **Belge hangisini kastettiğini hiçbir yerde yazmıyor.**
- **Birincil kaynak:** `ProblemDetails.cs` (aspnetcore `release/9.0`) birebir: `namespace Microsoft.AspNetCore.Mvc;` / `public class ProblemDetails`.
⇒ **Dal (a) = Application CQRS handler:** K3-J4(b) handler'da `ProblemDetails` ürettiriyor ⇒ v4'ün **kendi yeni yazdığı** `M32b` kuralı (`Microsoft.AspNetCore.*` ⊥ Application) gerçek kodda ihlal edilir ⇒ **M32b'nin baseline'ı kırmızı doğar.**
⇒ **Dal (b) = Api minimal API delegesi:** M32b kurtulur ama K3-J3'ün **bağlayıcı sırası** iki katmana yayılır ve 0001 K-B1'in CQRS akışı auth için fiilen atlanır.
**Belge iki daldan birini SEÇMİYOR.** Bu, kapı-3'ün B9'uyla (*"`X-Client-Kind`'ın okuma yönü yazılmamış"*) **aynı sınıftır** ve o tur bloker sayılmıştı.

### B-5 · AES-256-GCM NONCE ÜRETİMİ/TEKİLLİĞİ YAZILMAMIŞ — mutantı yok, §3.1'de beyanı yok
**Ölçüm (ana oturum):** `nonce` belgede **iki** yerde geçiyor: satır **202** (yalnız düzen: *"`nonce ‖ ciphertext ‖ tag`, 12+32+16 = 60 bayt"*) ve satır **548** (**CSRF** nonce'u — başka bir şey). `grep RandomNumberGenerator` ⇒ **0 eşleşme**. AAD (associated data) ⇒ **yok**. Nonce'un nasıl üretileceği, tekilliğinin nasıl sağlanacağı, sayaç mı rastgele mi ⇒ **hiçbir yerde**.
**`K_rt` tek ve kalıcıdır** (K3-I4 deterministik türetme + K3-I3'ün *"aynı anahtarı okur"* vaadi) ⇒ nonce tekrarı teorik bir kaygı değil, **yazılmadığı için varsayılan** risktir.
**Birincil kaynak — `AesGcm` (runtime `release/9.0` ref), birebir:** `public void Encrypt(ReadOnlySpan<byte> nonce, ReadOnlySpan<byte> plaintext, Span<byte> ciphertext, Span<byte> tag, ReadOnlySpan<byte> associatedData = default)` ⇒ **nonce çağırandan gelir, sınıf üretmez.**
⇒ **K3-K2'nin *"primitifi yazmayız"* muafiyeti geçmez:** nonce seçimi belgenin kendi tanımıyla **akıştır**, primitif içi değil.
**Karşı kaynak — NIST SP 800-38D:** aynı anahtarla nonce tekrarı hash alt anahtarının ifşasına götürür (Appendix A) ve tekrar olasılığı `2^-32`'yi aşmamalıdır (§8).
**A1↔A2 çelişkisi karara bağlandı** (A1 MAJÖR, A2 BLOKER demişti): ölçüm A2'yi haklı çıkardı ⇒ **nonce = BLOKER**, **AAD eksikliği = ayrı MAJÖR**.

### B-6 · K3-B6'nın E-POSTA AYAĞI KAPISIZ — üstelik iki yerde "kapandı" ilan edilmiş
**Ölçüm (ana oturum):** satır **705** `M31` — mutasyon: *"**Parola** asgari/azami uzunluk doğrulaması kaldırılır"*; dört ayak: 14→`400` · 15→`201` · 129→`400` · *"gösterim-adlı e-posta (`\"Ad <a@x.com>\"`) `400`"*.
⇒ **4. ayak (e-posta formatı) parola mutasyonuna DUYARSIZDIR** — mutasyon uygulansa da ayak yeşil kalır.
⇒ **254 karakter sınırının assert'i HİÇ YOK:** `grep 254|255` ⇒ satır 123 (`cp1254`, locale), 166/172 (kuralın kendisi), **60 ve 758 (kapanma İDDİALARI)**. Ölçüm satırı yok.
**Ağırlaştırıcı:** muafiyet §3.1'den **çıkarıldığı** için kalem artık **ne kapılı ne beyanlıdır** — v3'ten daha kötü bir durumdur.

### B-7 · HIZ-SINIRLAYICI TEST İZOLASYONU PİNSİZ + §3.2(5)'in `FakeTimeProvider`'ı LİMİTER'I İLERLETEMEZ (birincil kaynaktan)
**Ölçüm (ana oturum):** §3.2(5) birebir: *"**`TimeProvider` her testte `FakeTimeProvider`'dır** (K-C5)"*.
**Birincil kaynak — `FixedWindowRateLimiter` (runtime `release/9.0`):** `private readonly Timer? _renewTimer;` + `_idleSince = _lastReplenishmentTick = Stopwatch.GetTimestamp();` + `long nowTicks = Stopwatch.GetTimestamp();` ⇒ **`TimeProvider`'dan beslenmiyor; `FakeTimeProvider` enjekte edilemiyor.**
⇒ Hız sınırı penceresi testte **ilerletilemez**. Kontrol 1 tek partition'dır (K15-b ölçümü: `TestHost`'ta `RemoteIpAddress` `null`) ⇒ paylaşılan `WebApplicationFactory`'de M23'ün **31 isteği** + M11'in istekleri + M31'in `/register` çağrıları **aynı kovayı** doldurur ⇒ **M41(2) ve M46'nın negatif assert'leri (`429` ALMAZ) sıra bağımlı olarak kırılır.**
**§3.2 bu izolasyonu (fabrika ömrü, kova sıfırlama, sınıf başına yeni host) hiçbir yerde pinlemiyor** — oysa §3.2'nin varlık sebebi tam olarak budur.

### B-8 · `M22` ÖLÜ TUZAK — önkoşul kontrol 2'yi hesaba katmıyor
**Ölçüm (ana oturum):** satır **696** `M22` önkoşulu: *"**her istek FARKLI IP'den** gelir (kontrol 1 tetiklenmez) **ve** `IPasswordHasher` **bloke eden sahte** implementasyondur"* — **e-postaya tek kelime yok**. Assert: `limit == "concurrency"`.
Satır **465-469** (K3-J3 bağlayıcı sıra): `handler: e-posta penceresi (kontrol 2)` **önce**, `handler: eşzamanlılık limiti (kontrol 3)` **sonra**. Satır 432: kontrol 2 = **5 deneme / 15 dk**, normalize e-posta anahtarlı. Satır 433: kontrol 3 reddi için `izin = ProcessorCount` + `QueueLimit = 2×ProcessorCount` ⇒ **≥ 3×ProcessorCount+1 (≥ 7)** eşzamanlı istek gerekir.
⇒ Testte aynı e-posta kullanılırsa **6.** istek `limit == "email"` alır ⇒ `"concurrency"` assert'i **baseline'da kırılır**.
**Asimetri kusurun kanıtıdır:** M23'ün önkoşulu *"her istekte FARKLI rastgele e-posta"* diyor, M22'ninki demiyor. **v4'ün kendi yeni kapısı (M41) M22'yi geriye dönük bozdu.**

### B-9 · [RED-TEAM'İN YENİ BULGUSU] TESTLERİN `Momentum:MasterKey`'İ NEREDEN ALACAĞI YAZILMAMIŞ
**Ölçüm (ana oturum):** §3.2(1) birebir: *"`TS` seviyesindeki her test **`WebApplicationFactory<Program>`** ile ayağa kalkar — çıplak `new TestServer(...)` **YASAKTIR**"* ⇒ **gerçek `Program` boot eder** ⇒ **K3-I2 fail-fast koşar** (satır **352**: *"Eksik veya çözülmüş hâli 32 bayttan kısa kök anahtarda başlangıçta `InvalidOperationException`"*).
Üç kaynağın **üçü de kapalı:** (1) `dotnet user-secrets` — belgenin **kendi cümlesi**, satır **371**: *"**`dotnet user-secrets` klonla gelmez**"*; (2) bootstrap dosyası — **konteynerin giriş betiğindedir** (satır 374), test sürecinde koşmaz; (3) ortam değişkeni — **belgede hiçbir yerde yazılı değil** (`grep` ile tarandı).
⇒ **`TS` + `TC` etiketli ~34 mutantın baseline'ı temiz bir klonda KIRMIZI doğar** — bu, §3.2(8)'in *"baseline kuralı"*nın doğrudan ihlalidir.
**Karar boşluğudur, yazım detayı değildir:** dal (a) sabit test anahtarı ⇒ K3-I1'in *"**Varsayılan/gömülü anahtar YOKTUR**"* cümlesi ve kırmızı çizgi #1 ile yüzleşilmeli; dal (b) test başına CSPRNG ⇒ M42'nin kalıcılık iddiası ve anahtar-bağımlı assert'ler yeniden yazılmalı.
**[DÜRÜST MUHALEFET — kayda geçiyor]** Bu kalem *"fixture ayrıntısı, spec'te çözülür"* diye savunulabilir. Ana oturum bu savunmayı **kabul etmedi**: §3.2'nin **varlık sebebi** testlerin nasıl ayağa kalkacağını pinlemektir ve bölüm iki ikameyi (`TestAuthHandler`, özel `IProblemDetailsWriter`) **adıyla yasaklarken** sırrın kaynağını atlıyor.

---

## 2. RED-TEAM'İN ÇÜRÜTTÜKLERİ ve İNDİRDİKLERİ (dürüstlük — bulgu şişirmesi engellendi)

**ÇÜRÜTÜLENLER (3 + 1 premis):**
- *"Pinlenen `UPDATE` SQL'inde `successor_secret_enc` yok ⇒ değişmez çelişiyor"* → **ÇÜRÜTÜLDÜ.** Değişmez *"aynı **transaction** içinde"* diyor, *"aynı ifadede"* demiyor; `READ COMMITTED` pinli ⇒ *"halef var ama sırrı yok"* ara durumu **her iki yazımda da imkânsız**. → MİNÖR (artefakt eksikliği).
- *"Kontrol 2 fiilen hesap kilitlemesidir; belge 'kilitleme YOKTUR' diyor"* → **ÇÜRÜTÜLDÜ.** NIST SP 800-63B-4 §3.2.2 taksonomisinde **throttling kilitlemenin karşıtıdır** (*"reduce the likelihood that an attacker will lock the legitimate claimant out"*). → MİNÖR.
- *"M33a'nın `GET /` ayağı mutasyona duyarsız"* → **ÇÜRÜTÜLDÜ.** Mekanizma teşhisi doğru, hüküm yanlış: baseline yeşil, mutasyonda `GET /tasks` **401** ⇒ **mutant ölür**. → MİNÖR (anlatım kusuru).
- *"`TS` tanım gereği veri katmanı olmayan seviyedir"* → **PREMİS ÇÜRÜTÜLDÜ.** Belgede böyle bir cümle yok (satır 673 `TS`'i *"`TestServer` entegrasyonu"* = **host kurulumu** diye tanımlıyor) ve `Npgsql`'in in-memory sağlayıcısı yoktur.

**BLOKER → MAJÖR indirilenler (3):** `TS` seviyesinin kalıcılık portlarının sahtelenebilirliği (gerçek kusur: §3.2 iki ikameyi yasaklarken kalıcılık portları hakkında sessiz) · **M40**'ın mutasyon biçiminin pinsizliği (ikinci varyant **ısırıyor** ⇒ kapı kör değil) · §3.1'deki **`RequireSignedTokens`** muafiyetinin gerekçesinin olgusal yanlışlığı (*ölçüldü:* `JwtHeader` birebir `if (signingCredentials == null) this[JwtHeaderParameterNames.Alg] = SecurityAlgorithms.None;` ⇒ imzasız token elle üretilebilir ⇒ gerekçe yanlış — **ama kalem §3.1'de açıkça beyanlı** ⇒ tamlık iddiası ihlal edilmiyor; kardeş kalem `iss`/`aud` kapı-3'te MAJÖR sayılmıştı).

## 3. BAŞLICA MAJÖRLER (~27; tam liste alt-raporlarda)

1. **AAD yok** — `successor_secret_enc` şifrelemesi `family_id`/`token_hash`'e bağlanmıyor (B-5'ten ayrıldı).
2. **`+` kaçışının gerçek biçimi yazılmamış — belge kendi hatasını üretiyor.** Satır 195 birebir: *"kodlayıcısı `+` karakterini `+`'ye çevirdiği için"* — **aynı karakteri iki kez yazan bir totoloji**; okuyucu neyin neye çevrildiğini öğrenemez. Gerçek çıktı **altı karakterlik `\u002B` dizisidir** (ters bölü + `u002B`): `ForbidChar('+')` ⇒ karakter allowlist dışıdır ⇒ `JavaScriptEncoder` `\uXXXX` üretir. Belgede `grep -c "u002"` ⇒ **0 eşleşme** ⇒ M28'in *"JSON-kaçışlı biçimi de tara"* talimatı **hedefsizdir**: tarayıcı hangi diziyi arayacağını bilmiyor.
   **[ÖLÇÜLEMEDİ: denetim ortamında `dotnet` SDK yok ⇒ çıktı fiilen koşturulamadı; hüküm `AllowedBmpCodePointsBitmap.ForbidHtmlCharacters()` → `ForbidChar('+')` kaynak satırının okunmasına dayanıyor.]** v5 bu diziyi **koşarak** ölçmeli ve birebir yazmalıdır.
3. **60 sn replay penceresi yanlış karara atfediliyor** (satır 267 ve Risk #11 *"[K16-b]"* diyor; K16-b'nin tam metni **yalnız hız sınırı tavanlarıdır**; pencerenin sahibi **K14-a**'dır). → red-team MİNÖR'e indirdi, ana oturum **MAJÖR'de tuttu**: §4'ün *"her olgu iddiası ölçülür"* kuralı etiketleri de kapsar.
4. **`Retry-After` kapısı yok** — §3.1 kapanışı M11/M41'i gösteriyor ama ikisinin de kill sinyalinde `Retry-After` geçmiyor.
5. **M40'ın mutasyon biçimi pinsiz** + süpürme periyodu ölçülmüyor + fırsatçı silme kapısız.
6. **NIST SP 800-63B-4 §3.2.2'nin `SHALL`'ı karşılanmıyor ve adlandırılmış sapma olarak yazılmamış** (*"the verifier **SHALL** limit consecutive failed authentication attempts … to no more than 100 by disabling that authenticator"*). Belge her diğer sapmayı adlandırıyor, bunu hiç anmıyor. **A turunun üçü de kaçırdı.**
7. **`/refresh`'te CSRF doğrulamasının tüketim `UPDATE`'ine göre sırası yazılmamış** (`/login` için PAZARLIKSIZ sıra var). CSRF sonra koşarsa başarısız istek token'ı **zaten tüketmiş** olur ⇒ 60 sn'yi aşarsa `reuse_detected` ⇒ **aile düşer**.
8. **§2-M'de `users` kalıcılığı satırı yok** (B-4'ün ikinci ayağı).
9. **M41 ayak 2 · M43 ayak 3 · M31 ayak 4 · M36'nın 7 assert'inden 5'i** — kendi mutasyonları altında **ölmüyor** (çoklu-assert mutantlarının klasik kusuru: tek mutasyon tüm ayakları kapsamıyor).
10. **M42'nin mutasyonu bileşik** (türetme + efemer üretim); türetme yarısı hiçbir testle gözlemlenemiyor. **+ M42 × §3.2(7) çelişkisi:** `KON`'un gözlem yüzeyi *"çıkış kodu, stderr, dosya sistemi"* diye pinli, M42'nin sinyali ise **HTTP 200**.
11. **M19**'un kill sinyali bir assert değil, tüm `TS` suite'ini düşürüyor ⇒ ayırt edicilik zayıf.
12. **CI yok** (ODEV §8(4); planda 11-12 Ağu) ama `KON` seviyesi *"CI'da ayrı bir job"* varsayıyor — `slice-3c` CI'dan **önce** koşuyor.
13. **HKDF `info` etiketlerinin bayt kodlaması pinsiz** (`HKDF.Expand(..., byte[]? info)`), §3.1 etiketleri mutanttan muaf tutuyor ⇒ hiçbir yerde sabitlenmiyor. B5'in (*"neyin özeti"*) birebir kardeşi.
14. **HKDF-Extract atlama gerekçesi** (*"kök anahtar CSPRNG çıktısıdır"*) üretim yolunda **zorlanmıyor** — fail-fast yalnız **uzunluk** ölçüyor.
15. **Anahtar rotasyonu yarım** — mekanizma yok, kapsam dışı da denmemiş.
16. **CSRF nonce'unun uzunluğu/entropi kaynağı ve CSRF token'ının ömrü pinsiz.**

## 4. MİNÖRLERİN EN ÖNCELİKLİSİ

**Mutant tablosu satır 715'te bölünmüş ve ikinci tablonun başlık satırı yok.** Ölçüldü: satır **715 boş**, satır **716** doğrudan `| **M32b** |` ile başlıyor ⇒ GFM'de **render olmaz**; düz metin akar. Bilgi kaybı yok (ham metin sağlam) ⇒ **MİNÖR** — ama render olmayan blok tam olarak **v4'ün bütün yeni kapılarıdır (M32b · M32c · M40–M48, 11 satır)** ve bu bir **portfolyo belgesidir**.

Diğerleri: K3-L8'in 3. dalına 4 atıftan 3'ü *"(4)"* diyor · emekli `K3-G*` etiketine canlı atıf (D-5) · `sstamp`'in ilk değeri yazılmamış · Risk #13'ün *"120 sn"*i sürecin ayakta olmasını varsayıyor ama yazmıyor · demo kimlik bilgisi ↔ K3-I3'ün optik red gerekçesi asimetrisi.

## 5. KIRILAMAYAN YERLER [DÜRÜSTLÜK — bu bölüm raporun güvenilirliğidir]

- **DIŞ ATIFLAR SAĞLAM.** 23 bağımsız birincil-kaynak ölçümü yapıldı (NIST ×2, RFC ×4, OWASP ×2, WHATWG, dotnet kaynak kodu ×8, NuGet, ADR 0001). **Hiçbir dış atıf yanlış çıkmadı.** v3'ün NIST hatasının muadili **yoktur**: 15 `SHALL` · karmaşıklık yasağı · ≤128 · NFC — dördü de doğru. RFC 9700 §4.14.2 alıntısı **birebir**. OWASP CSRF alıntıları **kelimesi kelimesine**. RFC 5869 §3.3 Extract atlamayı meşrulaştırıyor. Konscious 1.3.1 / MIT — üç sayı da bugün doğru.
- **K14-a × K15-a birleşimi YAPISAL OLARAK DOĞRU** — sonsuz zincir kurulmaya çalışıldı, **doğmuyor**; B1 gerçekten kapatılmış.
- **M12** — `Base64Url` + ham bayt pini *"neyin özeti"* sorusunu kapattı ve iddia artık yalnız `token_hash`'i bağladığı için `successor_secret_enc` ile **çelişmiyor**.
- **M8b** — B4 gerçekten kapandı; öldürülemezlik `KON`'a **taşınmadı**: `.secrets/momentum-master.key` **OLUŞMAZ** assert'i dosya sistemine çıpalı ve §3.2(7)'nin gözlem yüzeyiyle **uyuşuyor**.
- **M44** — turun en temiz yeni kapısı; M26'nın görmediği yeri gerçekten görüyor. **M33a/M33b** — B6 kapandı, fixture önkoşulu ölü tuzağı kaldırdı. **M48** — Ma-7 kapandı.
- **Saat ekseninin dördü sağlam:** M29 · M30 · M17 · M27. Ayrıca M5 · M6b · M7 · M15 · M16 · M18 · M21 · M23 · M24 · M25 · M26 · M32/32b/32c · M34 · M35 · M37 · M38 · M39 **ısırıyor**.
- **`FakeTimeProvider` × gerçek Postgres çelişkisi YOK** (yazarın kendi şüphe listesindeki kalem): hem tüketim hem süpürme SQL'i uygulamadan gelen `@now`'a bağlı, DB `now()` hiç kullanılmıyor. **Belge bu ayrımı fiilen yapmış.**
- **`ADR 0001 K-H1` alıntısı karakter karakter doğru** ve yeni/mevcut kural sınıflandırması doğru ⇒ **Ma-8 temiz kapandı**.
- **§0.4 (geri çekilen iddialar) dürüst** — sessizce düzeltilmiş tek iddia bulunamadı.
- **KAPSAM KAYMASI YOK** — K3-K3'ün kapsam dışı listesi ODEV §6.1'in kesin üst kümesi; ters yönde düşürme de yok.
- **MUTANT NUMARA BÜTÜNLÜĞÜ TAM** — M1–M48, kayıp/çift yok; eksik beş numara tam olarak **M2·M3·M9·M10·M20** = 0004 rezervi; M13 VOID korunmuş; **K16-d pini tutuyor**; M50 pini iki yerde tutarlı. (**Tek sapma ADR'de değil hafızadadır:** `PROJE_HAFIZA` K16-d `M8c` ve *"8 yeni kapı"* diyor; ADR `M8c`'yi düşürmüş ve *"dokuz"* diyor — M40–M48 = 9 ✓. Ayrıca hafıza *"YENİ MUTANTLAR (11)"* deyip 14 kalem sayıyor.)
- **KODLAMA TAM:** U+FFFD 0 · mojibake 0 · UTF-8 geçerli · BOM yok.
- **`[DOĞRULANMADI]` DOKTRİNİ YİNE DÜRÜST:** 2 canlı etiket, ikisi de gerçekten uzaktan ölçülemez; **ölçülebilecekken etiketle geçiştirilmiş kalem bulunamadı**.

## 6. ÖLÇÜLEMEYENLER [uydurulmadı]

- **`tests/` · `src/` · `Dockerfile` · compose · giriş betiği denetim ortamında YOKTU** (yalnız `CLAUDE.md`, `PROJE_HAFIZA.md`, `docs/`, `KANIT/` bağlıydı) ⇒ **§3.2'nin mevcut test altyapısıyla uyumu ölçülemedi.** Ölçülmesi gerekenler, tek tek: `Program`'ın `WebApplicationFactory<Program>` için görünürlüğü (`InternalsVisibleTo` / `public partial class Program`) · `TS`/`TC`/`NA`/`KON` proje ayrımının bugünkü hâli · mevcut testlerde `TestAuthHandler` kullanımı (artık **YASAK**) · `FakeTimeProvider` paketinin lisans+CVE kapısı (kırmızı çizgi #3) · Testcontainers'ın yerel koşusu · `docker compose restart`'ın CI maliyeti.
- Argon2id **270 ms** yerel koşusu · WebKit/Safari'nin `http://localhost` `__Host-` davranışı · `flutter_secure_storage`'ın Windows şifreleme yöntemi · `FixedWindowRateLimiter`'ın `_retryAfter`'ı hangi ret senaryolarında doldurduğu.
- `GOREV-slice-3c-auth` spec'i **henüz yok** ⇒ *"spec'te çözülür"* savunması bu turda da **kabul edilmedi**.

## 7. KÖK NEDEN TESPİTİ ve YAPISAL ÖNERİ

Bu turun **dokuz blokerinden beşi** (B-1, B-3, B-5, B-6, B-9) **tek kaynaktan** doğuyor:

> **v4, bir blokeri kapatırken doğan YENİ mekanizmayı kapıya bağlamayı ya da §3.1'de beyan etmeyi sistematik olarak atlıyor** — ve kapanma tablolarında (§0.1/§0.3) o kalemi **yapılmış ilan ediyor.**

Bu **üçüncü** turdur ki aynı kök neden bloker üretiyor: kapı-2 #15 → kapı-3 B7 → kapı-4 B-3 + B-6.
Ayrıca **iki bloker (B-1, B-8) "kardeş kalem güncellendi, kendisi unutuldu" sınıfındandır** ve bu, belgenin **boyutunun** doğrudan sonucudur: aynı sayı/kural 3-7 ayrı yerde tekrarlanıyor (kontrol 1 sayısı **7 yerde**, M28 sinyali 3, B2 ölçümü 6 yerde).

**Öneri (v5 yazılmadan ÖNCE karara bağlanmalı):**
1. §3.1'in *"bu liste, tablonun tamlık iddiasının sınırıdır"* cümlesi ya **geri çekilir** ya **mekanik olarak** doğrulanır (her `**K3-…**` başlığı ↔ mutant tablosu / §3.1 satırı eşlemesi bir betikle çıkarılır — bu **ölçüm aracıdır**, ve `turkce-kapilar` doktrini gereği **önce kendini altın kümede kanıtlamalıdır**).
2. Tekrarlanan sayılar (tavanlar, ömürler, uzunluklar) **tek bir kanonik tabloya** çekilir; gövde metni o tabloya **atıf yapar**, sayıyı **kopyalamaz**. B-1 ve B-8 bu kuralla doğamazdı.
3. §0'ın kapanma tabloları ve *"v3'te şöyleydi"* anlatıları **KANIT'a taşınır** (belgenin ~%12-15'i, ≈20-25 K saf tekrardır) — ADR karar belgesi olarak kalır, denetim izi KANIT'ta yaşar.

---

*Rapor: Cowork oturum 20, 25 Tem 2026. A turu 3 bağımsız denetçi + B turu red-team + ana oturum adjudikasyonu. Alt-raporlar oturum eki olarak tutulmuştur. **Hükmü taşıyan 9 iddianın 9'u da ana oturumda kaynaktan yeniden ölçülmüştür.***

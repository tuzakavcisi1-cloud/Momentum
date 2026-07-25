# ADR 0003 — Kimlik Çekirdeği (`slice-3c-auth`, 1/2)

- **Durum:** 🟡 **TASLAK v3 — KİLİTLİ DEĞİL.** v2'ye ikinci bağımsız kapı koştu ve hüküm **KİLİTLENEMEZ** oldu (**15 bloker · ~20 majör**, dört bağımsız denetçi). Bu sürüm o 15 blokeri kapatır. **K13-a yürürlükte: "bloker sıfırlanana kadar tur; tur sayısı raporlanır, sınırlanmaz."** *Üreten ≠ denetleyen: bu ADR'yi yazan el onu onaylayamaz.* Kilit Onur'dadır.
- **Tarih:** 2026-07-25 (v3) · v2: 2026-07-25, arşiv: `arsiv/0003-kimlik-cekirdegi-TASLAK-v2-2026-07-25.md` · v1: 2026-07-25, arşiv: `arsiv/0003-kimlik-ve-yetkilendirme-TASLAK-v1-2026-07-25.md`
- **Denetim izi:** v2'nin tam denetim raporu `KANIT/adr-0003/kapi-2-denetim-raporu.md` (171 satır). Bu belgedeki her kapatma o rapordaki bir bulguya çıpalıdır.
- **Karar verenler:** Onur (sahip) · Cowork (mimar) · bağımsız denetçi ajanlar (kapı bekliyor)
- **⚠ DİLİM ADI DEĞİŞTİ [K14-h]:** `slice-3a-auth` → **`slice-3c-auth`**. *Gerekçe:* `slice-3a` **zaten vardır** (ADR 0002 K2-I3 = sunucu materyalizasyonu + okuma API'si; `KANIT/slice-3a/` klasörü dolu) ve bu proje "aynı numara iki anlam" hatasını daha önce iki kez yedi. **Bilinen ve kabul edilen kusur:** kimlik dilimi `slice-3b`'den **önce** koşar ⇒ harf sırası kronolojiyi yalanlar; "3 ailesi = istemciyi ayaklandıran işler" anlamı korunduğu için kabul edildi. *Reddedilenler:* `slice-4-auth` · `slice-auth` (numarasız).
- **Kapsam (K11-h ile daraltıldı):** kullanıcı varlığı · parola + **girdi politikası** · token yaşam döngüsü · token doğrulama parametreleri · `ICurrentUser` sözleşmesi · sırlar + **dev bootstrap** · kimlik uçları + kaba kuvvet · **istemci token/kuyruk sözleşmesi** · **port envanteri**.
- **Kapsam DIŞI (ADR 0004'e taşındı):** owner EF global query filter + `IgnoreQueryFilters` yasağı · push-authz · pull-authz · `outbox_messages.owner_id` · SignalR hub kimliği · `clientId → principal` **ve onun zorlama kuralı (D-7)**.
- **Bağımlılık:** ADR 0001 (§C, §D, §G, §H) · ADR 0002 (K2-E3, K2-E5, K2-A4, §6/7).

> **Onur'un kilitlediği çatallar:** K8-a…K8-d · K9 · **K11-c/d/e/f/g/h** · K12-d (aynı origin) · **K13-a (K6 tavanı kaldırıldı)** · **K14-a…K14-h (bu sürümün dokuz çatalı — §0.2)**.
>
> **AÇIK ÇATAL DURUMU — v2'nin "AÇIK ÇATAL KALMADI" BEYANI YANLIŞTI ve bu sürümde DÜZELTİLMİŞTİR.** v2 bu cümleyi yazarken K3-L4 iki dallıydı (bloker #3), K3-L5 kendisine yüklenen görevi yapısal olarak yapamıyordu (bloker #1) ve token taşıma kanalı kararlaştırılmamıştı (bloker #6). **v3'te bu üçü de kilitlendi.** Bu belgede bugün açık çatal yoktur; **ama bu cümle bir DENETİM SONUCU DEĞİL, bir YAZAR İDDİASIDIR** — v2'nin aynı cümlesi denetimde çürütüldüğü için burada böyle etiketlenmiştir.

---

## 0. v2 → v3 değişim kaydı (denetim izi)

### 0.1 — 15 BLOKERİN NEREDE KAPANDIĞI

| # | bloker (rapordaki adıyla) | sınıf | v3'te ne oldu | nerede |
|---|---|---|---|---|
| 1 | **RT-B1** kayıp yanıt: K3-L5 görevini yapısal olarak yapamaz | çatal | **KARAR K14-a:** sınırlı replay-idempotency (60 sn, halef tüketilmemişse) | **K3-C6**, K3-L5, M29/M30 |
| 2 | **D1-B2** `/refresh` yükleminde `revoked_at`/`expires_at` yok ⇒ `/logout` no-op | kör kapı | yüklem tamamlandı, **0-satır dalı DÖRDE ayrıldı** | **K3-C6**, M26/M27 |
| 3 | **D1-B1** K3-L4 iki dallı; (a) SPA 401'lenir (b) proxy IP partition'ı öldürür | çatal + kör kapı | **KARAR K14-e:** API statik dosyaları servis eder, proxy YOK ⇒ dal (b) doğmadan kapanır | **K3-L4**, K3-J1, M33 |
| 4 | **RT-B2** naif double-submit alt-alan vektörüne karşı geçersiz | kör kapı | `__Host-` öneki + **HMAC'li, aileye bağlı** CSRF token; M25 kill sinyali düzeltildi | **K3-L3**, M25/M35 |
| 5 | **RT-B3** K3-J2(2) senkron partitioner ile İNŞA EDİLEMEZ | inşa hatası | **KARAR K14-f:** e-posta limiti handler içinde `PartitionedRateLimiter<string>`; K3-J3 sırası yeniden yazıldı | **K3-J2/J3** |
| 6 | **D1-B3 + D1-B4 + D3** token taşıma kanalı platform başına kararlaştırılmamış; `/logout` girdisi tanımsız | çatal | **KARAR K14-c:** `X-Client-Kind` başlığı + JWT'ye `fid` talebi | **K3-C1**, K3-L10, M28 |
| 7 | **D2-#12/13/14** `RejectionStatusCode` varsayılanı **503**, `429` yazılmamış | ölü tuzak | override + `OnRejected` + `Retry-After` açıkça yazıldı; kill sinyalleri düzeltildi | **K3-J4** |
| 8 | **RT-B4** imzalama anahtarı bootstrap'ı yok ⇒ değerlendiricinin makinesinde açılmaz | ODEV §2 × kırmızı çizgi #1 | **KARAR K14-b:** compose ilk açılışta rastgele dev anahtarı üretir; **M8 iki ayaklı** | **K3-I3**, M8 |
| 9 | **D3-B4** K3-L5/L6/L7 hem kapısız hem devirsiz | asimetri | **M-L5/M-L6/M-L7** adlandırıldı ve `slice-3b`'ye **devredildi** | **§7 devir listesi** |
| 10 | **D1-B5** soğuk açılışta `userId` nereden gelir | şema sonucu | **aktif profil kaydı** + `/refresh`'in **ağ hatası** dalının `401` dalından ayrılması | **K3-L8** |
| 11 | **RT-B5** parola politikası + girdi doğrulama = gizlenmiş sınır | gizlenmiş sınır | **KARAR K14-g:** NIST SP 800-63B çizgisi (≥10, karmaşıklık yok, ≤128, e-posta ≤254 + format) | **K3-B6**, M31 |
| 12 | **D3-B2 + RT-M3** M16'nın `alg` ayağı ısırmıyor; K3-C7 beyanı yanlış | kör kapı | ayar TUTULDU, **beyan düzeltildi**, `alg` ayağı **kapı olmaktan çıkarıldı** (hijyen ilan edildi) | **K3-C7**, M16 |
| 13 | **D3-B1** M22 ısırmıyor + hız sınırlama SAYILARI yok | kör kapı + ölü tuzak | **sayılar kararlaştırıldı (K14-i)** · M22 ayrı IP + **bloke eden sahte hasher** · reddin kaynağı ayırt edilir | **K3-J2**, M22 |
| 14 | **D3-B3** M17 donmuş `FakeTimeProvider` altında ısırmıyor | kör kapı | kill sinyaline **saat ilerletme + tam eşitlik**; `expires_at` devralma **değişmezi** yazıldı | **K3-C2**, M17 |
| 15 | **D3-B6** K3-B2'nin NetArchTest kuralı mutantsız (0001 K-H1 ihlali) | doktrin ihlali | mutant yazıldı | **M32** |

### 0.2 — ONUR'UN BU SÜRÜMDE KİLİTLEDİĞİ DOKUZ ÇATAL (K14)

| kilit | karar | reddedilenler [adlandırılmış] |
|---|---|---|
| **K14-a** | Sınırlı replay-idempotency: `T1.consumed_at + 60 sn` **ve** halef tüketilmemişse **kayıtlı halef aynen döndürülür** | telafisiz adlandırılmış sınır (uçak modu demosunun ortasında yeniden giriş) · `Idempotency-Key` (yeni tablo + TTL + temizleme = aynı sonuç, daha pahalı) |
| **K14-b** | Compose ilk açılışta **rastgele** dev anahtarı üretir, git-ignore'lu dosyaya yazar; **yalnız Development** | `.env.example` + README adımı (tek komut yetmez) · repoda DEV-ONLY sabit anahtar (kırmızı çizgi #1'e temas) |
| **K14-c** | `X-Client-Kind: web\|native` + JWT'ye **`fid`** talebi | ayrı alt yollar `/v1/auth/web/*` (uç sayısı ×2) · her platformda çerez (K3-L1 düşer) |
| **K14-d** | `security_stamp` **ölü alan olarak beyan edilir** | canlandırma (istek başına 1 DB okuması + K3-K3'ün kapsam kararını sessizce geri alır) · tamamen kaldırma (ileriye kanca kalmaz) |
| **K14-e** | **API statik dosyaları servis eder; reverse-proxy YOK** | reverse-proxy (`KnownProxies` + `X-Forwarded-For` testleri zorunlu olurdu) · ikisini de destekle (kapı yükü ×2, "hangisi kanıtlandı" açık kalır) |
| **K14-f** | E-posta limiti **handler içinde** `PartitionedRateLimiter<string>` | anahtarı başlıktan almak (**anahtarı istemci seçer ⇒ R2'nin hata sınıfı geri gelir**) · limiti tamamen kaldırmak |
| **K14-g** | NIST SP 800-63B çizgisi | kapsam dışı ilan etmek (azami uzunluk yoksa Argon2 DoS açık kalır) · klasik karmaşıklık kuralları (NIST/OWASP önermiyor) |
| **K14-h** | Dilim adı **`slice-3c-auth`** | `slice-4-auth` · `slice-auth` |
| **K14-i** | Hız sınırlama sayıları (aşağıda) — **⚠ COWORK ÖNERDİ, ONUR İTİRAZ ETMEDİ; bu bir Onur kilidi DEĞİLDİR ve kilit turunda gözden geçirilebilir** | — |

### 0.3 — MAJÖRLERİN NEREDE KAPANDIĞI

| majör | v3'te |
|---|---|
| **Ma-1** eşzamanlılık limiti `/register` hash'ini kapsamıyor | K3-J2(3) tanımı *"her Argon2 çağrısı (hash **ve** verify)"* olarak düzeltildi |
| **Ma-3** K3-C1 talep listesinde `iss`/`aud` yok ama K3-C7 zorunlu kılıyor | K3-C1 listesine eklendi |
| **Ma-4** PHC string'in **ayrıştırılması** hiç yazılmamış | **K3-B7** yeni; bozuk format `500` değil `401` (M34) |
| **Ma-5** `security_stamp` ölü alan | **K3-C8** — K14-d ile açıkça beyan edildi |
| **Ma-6** port envanteri eksik | **§2-M** yeni bölüm (JWT üretimi, `refresh_tokens` portu, `ICurrentUser` yeri, NetArchTest kuralları) |
| **Ma-7** `M-C` zorlama kuralının karşılığı yok | **D-7** olarak adlandırıldı (§7) |
| **Ma-8** çerez öznitelikleri hiç yazılmamış | **K3-L2** — ad, `Path`, ömür, `Domain` yasağı yazıldı |
| **Ma-9** CSRF kapsamı tutarsız | K14-c **yapısal olarak çözdü**: `/logout` ve `/logout-all` artık Bearer + `fid` ⇒ CSRF yüzeyi **yalnız `/refresh`** |
| **RT-M1** `Secure` çerez `http://localhost` dışında reddedilir | **K3-L4** — `localhost` zorunluluğu + teslim paketi bağı; adlandırılmış sınır |
| **RT-M2** web'de tek-uçuşluluk **sekmeler arası** olmak zorunda | **K3-L9** — Web Locks API / `BroadcastChannel`; **M-L5**'in web ayağı |
| **RT-M5** aynı-origin kararının XSS sonucu adlandırılmamış | **§6 Risk #10** |
| **RT-M6** `/logout` + `/logout-all` hız sınırı dışında; NAT yanlış-pozitifi | **K3-J6** yeni |
| **D2-#5** `MapInboundClaims=false`'un üçüncü yüzeyi (`User.Identity.Name` null) | **K3-D4** |
| **D2-#21** `flutter_secure_storage` Windows yöntemi doğrulanamadı | **K3-L1** — `[DOĞRULANMADI]` etiketiyle yazıldı, DPAPI iddiası **geri çekildi** |
| **D3** mutant tablosunda test seviyesi yok · mutantsızlar beyan edilmemiş · M6/M12/M14/M19/M24 kusurları · 0004 numaralandırması | **§3** yeniden yazıldı: **test seviyesi sütunu** + **§3.1 mutantsızlık beyanı** + tek tek düzeltmeler + **0004 M40'tan başlar** |
| **Mi-1** `slice-3a` ad çakışması | K14-h |

> **⚠ ETİKET EMEKLİLİĞİ (v2'den devralındı, hâlâ yürürlükte):** v1'in `K3-E*` · `K3-F*` · `K3-G*` · `K3-H*` etiketleri **emeklidir**; ADR 0004 aynı konuları `K4-*` ile yeniden yayımlar. Bir gelecek oturum `K3-E1` görürse **v1 arşivine** bakıyordur.

---

## 1. Bağlam

Bugüne kadar Momentum'un backend'i **kimliksiz** çalıştı. Bu iki ADR'de sessiz bırakılmadı, **adlandırıldı** — ve v1 denetimi sayımın eksik olduğunu ortaya çıkardı: borç **dört değil BEŞTİR**.

| pin | ertelenmiş gereksinim | kaynak (birebir) | nerede kapanır |
|---|---|---|---|
| **K-D5** | `ICurrentUser` impl + owner query-filter | `0001` §D: *"`ICurrentUser` portu (Application) slice-1'de arayüz olarak tanımlanır; implementasyonu + owner query-filter kimlik dilimiyle kodlanır."* | **sözleşme + impl: 0003 (§2-D)** · filtre: **0004** |
| **M-G** | push-authz | `0002` K2-E3: *"ingest, her op için 'actor bu entity'yi **yazabilir mi**' kontrolü yapmalı. Mekanizma auth diliminde."* | **0004** |
| **K2-E3** | pull-authz | `0002` K2-E3: *"`changes` yalnız actor'ın görebildiği entity'lerle sınırlı"* + tombstone muafiyeti | **0004** |
| **M-C** | `clientId → principal` | `0002` §6/7: *"`clientId` kimlik-doğrulaması ertelenmiş… auth diliminde aktive edilecek"* | **0004 (D-6 + D-7)** |
| **B4** | `outbox_messages.owner_id` doğrulanmamış | `PROJE_HAFIZA:145` AÇIK BULGU C | **0004** |

**Bu dilim bir özellik değil, bir ŞEMA kararıdır.** Çevrimdışı-öncelikli Flutter istemcisinde dört soru Drift şemasını ve depo katmanını belirler: *"bu yerel satır kimin"* · *"token nerede duruyor"* · *"401 gelince kuyruktaki yazımlar ne oluyor"* · *"çıkışta yerel DB'ye ne oluyor"*. v1 yalnız birincisini karara bağlamıştı; v2 kalan üçünü §2-L'de kapattı; **v3 §2-L'ye bir beşinci soruyu ekliyor: *"ağ yokken yerel DB hangi kimlikle açılır"*** (bloker #10 — üç kararın birleşiminin ürettiği, hiçbirinin tek başına görünmediği bir şema sonucu).

**Ayrıca bir güvenlik yüzeyi kapanır.** Bugün `WireOp.ActorId` **istemci-beyanlıdır** ve doğrulanmış actor push yoluna hiç girmez. Auth olmadığı için sömürülemez; **auth gelince sömürülebilir hâle gelir.** Bu belge kimliği üretir, **ADR 0004 onu yetki kararına bağlar** — ikisi birlikte kapatır, tek başına hiçbiri kapatmaz.

**Neden iki belge?** K11-h'nin gerekçesi *"her belge küçük ⇒ tek turda geçme şansı yüksek"*ti. **Bu beklenti iki kez tutmadı** (v2 = v1 × 1,8 ve 15 bloker taşıdı) ve K13-a ile **tavan kaldırıldı**. Bölünme kararı yine de duruyor, ama artık gerekçesi *"tek turda geçsin"* değil, **konu sınırının gerçekten orada olmasıdır**: v2 denetiminde *"0003/0004 bölünme sınırı sağlam — sınırda kararsız kalmış kimlik-çekirdeği maddesi bulunamadı"* diye ölçüldü.

---
## 2. Karar

### A. Kimlik modeli

**K3-A1 — `User` entity, asgari PII [kırmızı çizgi #2].** Alanlar: `id` (UUIDv7, `Guid.CreateVersion7()`, K-E1) · `email` (kullanıcının yazdığı hâl, gösterim) · `email_normalized` (eşsizlik/arama anahtarı) · `password_hash` · `created_at`/`updated_at` (yalnız `TimeProvider`, K-C5) · `security_stamp` (**bugün ölü alan — K3-C8**). **YOK:** ad, soyad, telefon, doğum tarihi, profil fotoğrafı, IP geçmişi, son giriş zamanı. Görev sahipliği `owner_id` çıpasıyla kurulur (K-C1); kullanıcı adı gösterimi işbirliği dilimine aittir.

**K3-A2 — Normalizasyon: `Trim` → NFC → `ToLowerInvariant` + `COLLATE "C"` unique index. [PAZARLIKSIZ]**
Sıra bağlayıcıdır ve üç adımın **üçü de** zorunludur:
1. **`Trim()`** — baştaki/sondaki boşluk (v1'de yoktu; **M21**).
2. **Unicode NFC** (`string.Normalize(NormalizationForm.FormC)`) — birleştirilmiş vs ayrık aksan (`é` = U+00E9 vs `e`+U+0301) aynı baytlara iner.
3. **`ToLowerInvariant()`** — ve **yalnız bu**.

> **⚠ TÜRKÇE LOCALE TUZAĞI — bu projede teorik değil, ÖLÇÜLMÜŞ bir risktir.**
> Geliştirme makinesinin sistem locale'i **tr-TR / cp1254**'tür (oturum 2 tanısı: bu locale Postgres `initdb`'yi fiilen kırdı). Türkçe kültüründe `"I".ToLower()` → **`"ı"`**, `"i".ToUpper()` → **`"İ"`**. Kültüre-duyarlı `ToLower()` kullanılırsa aynı e-posta sunucunun kültürüne göre **iki farklı** normalize değer üretir ⇒ (a) aynı adresle iki hesap açılabilir, (b) tr-TR makinede kayıt olan kullanıcı invariant makinede **giriş yapamaz**. DB tarafında unique index **`COLLATE "C"`** ile kurulur. `string.ToLower()` · `ToUpper()` · `ToLower(CultureInfo)` · `ToUpper(CultureInfo)` · kültüre-duyarlı `string.Compare` **BannedApiAnalyzers ile derleme-zamanı yasaklanır** (K-H1'in `DateTime.UtcNow` yasağıyla aynı mekanizma). **Kardeşi frontend'dedir:** Dart `toUpperCase()` de Türkçe i→İ dönüşümünü yapmaz ⇒ *kültüre-duyarlı büyük/küçük harf dönüşümü hiçbir katmanda kimlik/eşleştirme yolunda kullanılmaz* (K10 yakınsaması).

**K3-A3 — Kayıt açık; sayım oracle'ı ADLANDIRILMIŞ SAPMADIR [K11-e].** `POST /v1/auth/register` herkese açıktır ve e-posta zaten kayıtlıysa **bunu söyler** (`409`, ayırt edici mesaj). *Gerekçe:* e-posta doğrulama ODEV §6.1'de **kapsam dışıdır** ⇒ *"her durumda 202 döndür"* çözümünün kanonik ikinci ayağı (doğrulama maili) yok; kullanıcı neden giriş yapamadığını hiç öğrenemez ⇒ ODEV §2 zedelenir. **Bu bir sapmadır, bir çözüm değil**; `KANIT`'ta ve README'de açıkça beyan edilir. *Reddedilenler:* her durumda `202` · yalnız sıkı rate-limit (oracle'ı kapatmaz).

**K3-A4 — `User` SENKRONLANABİLİR KÖK DEĞİLDİR. [ADR 0004'ü BAĞLAYAN KISIT]** `User`'ın `owner_id`'si yoktur, `/sync` telinde geçmez, tombstone'u yoktur, CRDT birleştirmesine girmez. **Sonucu 0004 için hayatidir:** owner global query filter'ı `User`'a **UYGULANAMAZ** — uygulanırsa anonim `/login` isteğinde `ICurrentUser.UserId` `UnauthenticatedException` atar ve **giriş fiziksel olarak kilitlenir**. Kısıt burada tanımlanır, kapısı (**D-3**, §7) 0004'te kurulur.

### B. Parola

**K3-B1 — Hash = Argon2id, `Konscious.Security.Cryptography.Argon2` 1.3.1 [KAPI KOŞULDU, GEÇTİ].**
Parametreler **OWASP ikinci yapılandırması**: `m = 19456 KiB · t = 2 · p = 1`, 16 baytlık CSPRNG salt, 32 baytlık çıktı.
**Kapı kanıtı (Onur'un makinesinde, gerçek koşu, 25 Tem 2026):** lisans **MIT** · **CVE 0** · net9.0 build **0 uyarı 0 hata** · fiilen çalıştı: 32 baytlık hash, **270 ms**.
**⚠ ADLANDIRILMIŞ RİSK, GİZLENMİYOR:** paket **~25 ay hareketsiz** (`pushed_at = 2024-06-18`, 20 açık issue, 3 açık PR, GitHub'da release yok, arşivlenmemiş, 6.9M indirme). Bir CVE düşerse yamayı gönderecek bakımcı olmayabilir. **Telafi kapatma değil, İZOLASYONDUR → K3-B2/B3.**

**K3-B2 — `IPasswordHasher` portu [K9].** Arayüz **Application**'da, implementasyon **Infrastructure**'da. `Konscious.*` tipi Domain/Application/Api katmanlarının **hiçbirinde görünmez** — **NetArchTest kuralı** (K-A1 ailesine ek). Paket değişimi tek sınıfı etkiler. **Kuralın mutantı: M32** (0001 K-H1: *"Her kural commit'li negatif/mutant testle ısırdığını kanıtlar"* — v2 bunu ihlal ediyordu, bloker #15).

**K3-B3 — Hash string'i kendi kendini tarif eder [K9].** Depolanan format PHC benzeri:
`$argon2id$v=19$m=19456,t=2,p=1$<b64 salt>$<b64 hash>`
Algoritma kimliği ve parametreler **satırın içindedir**. Sonucu: (a) PBKDF2'ye ya da yeni parametreye geçiş **migration değil**, tek sınıf + doğrulama yolunda dallanmadır; (b) **başarılı girişte, depolanan parametreler güncel politikadan farklıysa parola sessizce yeniden hash'lenir** (rehash-on-login).

**K3-B4 — Doğrulama sabit-zamanlı.** `CryptographicOperations.FixedTimeEquals`; `SequenceEqual` **banned-API** (derleme kırılır). *(Not: `byte[] ==` referans karşılaştırmasıdır ve BannedApiAnalyzers ile ifade edilemez — bu ayak bir davranış testine devredildi, bkz. M6.)*

**K3-B5 — Kullanıcı-sayımı ve zamanlama sızıntısı: `/login` ve `/refresh` yolunda PAZARLIKSIZ, `/register`'da ADLANDIRILMIŞ SAPMA.**
`/login`: bilinmeyen e-posta ile yanlış parola **aynı** yanıtı döndürür (`401`, tek tip ProblemDetails) **ve aynı işi yapar** — kullanıcı bulunamazsa da bir **sahte (dummy) Argon2id doğrulaması** koşulur (sabit, uygulama açılışında bir kez üretilmiş geçerli formatlı bir hash'e karşı). Aksi hâlde yanıt süresi (≈270 ms vs ≈1 ms) hesabın varlığını ele verir.
**⚠ Sahte hash'in bir MALİYETİ vardır ve bu maliyet bir DoS çarpanıdır** — telafisi K3-J2/J3/J4'tür.
**"Aynı yanıt" ayağının kapısı [D3 majörü kapatılıyor]:** *"bilinmeyen e-posta ile yanlış parolanın yanıt gövdesi ve durum kodu **bayt bayt aynıdır**"* testi — **M37**.

**K3-B6 — GİRDİ POLİTİKASI: NIST SP 800-63B ÇİZGİSİ. [K14-g — bloker #11 kapanır]**
v2 bunu ne karara bağlamış ne kapsam dışı ilan etmişti ⇒ **gizlenmiş sınır**. Bugün `/register` parolası `"a"` olabiliyordu ve Argon2'ye 1 MB'lık bir parola gönderilebiliyordu.

| kural | değer | gerekçe |
|---|---|---|
| Parola asgari uzunluk | **10 karakter** | NIST SP 800-63B'nin uzunluk-öncelikli çizgisi. `123456` parolasına karşı Argon2id'nin `m=19456,t=2` yatırımı hiçbir şey satın almaz. |
| Parola **karmaşıklık kuralı** | **YOKTUR — bilinçli** | NIST SP 800-63B ve OWASP kompozisyon kurallarını (büyük/küçük/rakam/sembol zorunluluğu) **önermez**: kullanıcıyı tahmin edilebilir kalıplara (`Parola1!`) iter. **Bu bir eksiklik değil, adlandırılmış bir tercihtir.** |
| Parola azami uzunluk | **128 karakter** | **Argon2 DoS tavanı.** Sınırsız girdi, hash maliyetini saldırganın seçmesine izin verir. |
| E-posta azami uzunluk | **254 karakter** | RFC 5321 yol sınırı. Ayrıca `email_normalized` üzerindeki btree index'in anahtar boyutu sınırına çarpıp `500` üretmesini önler — aksi hâlde K3-B5'in *"tek tip ProblemDetails"* garantisi kırılırdı. |
| E-posta formatı | doğrulanır | Normalizasyondan **önce**; başarısızsa `400` (tek tip ProblemDetails). |

**Kapı: M31.** *Reddedilenler:* kapsam dışı ilan etmek (azami uzunluk yoksa Argon2 DoS yüzeyi açık kalır) · klasik karmaşıklık kuralları (güncel literatürü bilen değerlendiricide eksi sinyal).

**K3-B7 — PHC STRING'İ AYRIŞTIRMA SÖZLEŞMESİ. [Ma-4 kapanır]**
v2 formatı **yazmayı** tarif ediyordu ama **okumayı** hiç yazmamıştı ⇒ bozuk/tanınmayan bir `password_hash` `FormatException` → `500` üretirdi ve **bilinen/bilinmeyen e-posta yanıt kodundan ayırt edilebilirdi** (K3-B5'in garantisi kırılır).

- Ayrıştırma **savunmacıdır**: beş alan (`argon2id` · `v=` · `m=,t=,p=` · b64 salt · b64 hash) beklenir. Herhangi biri eksik/bozuksa **istisna dışarı sızmaz**: doğrulama `false` döner ⇒ `/login` normal `401` yolundan çıkar. Olay `Warning` seviyesinde loglanır (parola veya hash **loglanmaz**).
- **Rehash kararı yalnız `m`, `t`, `p` üçlüsü ve algoritma kimliği üzerinden verilir**; salt ve hash uzunluğu karşılaştırmaya girmez.
- Kapı: **M34**.

### C. Token modeli [K8-b]

**K3-C1 — Erişim token'ı = kısa ömürlü JWT (~15 dk), HS256.**
Talepler: `sub` (userId) · `jti` · `iat` · `exp` · **`iss`** · **`aud`** · **`fid`** (family_id, K14-c) · `sstamp` (bugün ölü alan, K3-C8).
> **[Ma-3 kapatıldı]** v2'nin talep listesinde `iss`/`aud` **yoktu** ama K3-C7 ikisini de zorunlu kılıyordu ⇒ liste harfiyen uygulansaydı **her istek `401`** olurdu.
> **[K14-c]** `fid` talebi `/logout`'un hangi aileyi iptal edeceğini **hesaplanabilir** kılar; v2'de bu bilgi hiçbir yerde taşınmıyordu (bloker #6).

İmzalama anahtarı simetrik; **tek servis** topolojisinde asimetrik imza (ES256) anahtar dağıtımı getirir, karşılığında hiçbir şey kazandırmaz. *Reddedilen: ES256 · uzun ömürlü tek JWT (iptal edilemez).*

**K3-C2 — Yenileme token'ı = OPAK, DB'de, DÖNDÜRMELİ, YENİDEN-KULLANIM TESPİTLİ. [taç mekanik]**
- Değer: **256 bit CSPRNG**; istemciye ham gider, **DB'ye yalnız SHA-256 özeti** yazılır. *(Yüksek-entropili rastgele bir sır sözlük saldırısına tabi değildir — bilinçli asimetri.)*
- Ömür: **mutlak 30 gün**, `family_id` doğduğu anda sabitlenir.
- **`expires_at` DEVRALMA DEĞİŞMEZİ [bloker #14'ün ikinci ayağı]:** *"aynı `family_id`'nin **tüm** satırları **özdeş** `expires_at` taşır; döndürmede üretilen yeni satır, sunulan satırın `expires_at`'ini **kopyalar**."* Bu bir cümle değil bir **değişmezdir**: testte tam eşitlikle (`==`) doğrulanır, "yaklaşık" karşılaştırma yasaktır.
- Tablo: `refresh_tokens(id, user_id, token_hash, family_id, created_at, expires_at, consumed_at, replaced_by_id, revoked_at, revoked_reason)`.
- **Döndürme:** her `/refresh` sunulan token'ı `consumed_at` ile tüketir ve **aynı `family_id`** altında yenisini üretir.
- **YENİDEN-KULLANIM TESPİTİ:** `consumed_at` dolu bir token yeniden sunulursa → **o ailenin tamamı derhal iptal** (`revoked_reason = 'reuse_detected'`), `401`. **İSTİSNA: K3-C6'nın replay-idempotency penceresi** (K14-a) — ve **yalnız o**.

**K3-C3 — `family_id` = GİRİŞ BAŞINA (bir cihaz/oturum) [K11-d].** Her başarılı `/login` **yeni** bir `family_id` doğurur; her `/refresh` **aynı** aileyi sürdürür. Reuse tespiti **yalnız o aileyi** düşürür. *Reddedilen:* kullanıcı başına tek aile.
**Doğum anının kapısı [D3 majörü kapatılıyor]:** M18 bunu yalnız tesadüfen kapsıyordu. Ayırt edici test: *"aynı kullanıcı iki kez `/login` yapar ⇒ dönen iki token **FARKLI** `family_id` taşır"* — **M38**.

**K3-C4 — Çıkış gerçektir, kapsamı AÇIKÇA YAZILIR [K11-d + K14-c].**
`POST /v1/auth/logout` **yalnız JWT'nin `fid` talebindeki aileyi** iptal eder. `POST /v1/auth/logout-all` kullanıcının **tüm ailelerini** iptal eder. Erişim token'ı her iki durumda da **≤15 dk** daha geçerli kalır — **bilinçli ve beyan edilmiş** sınır (kara liste tutulmuyor; K3-C8).
**⚠ v2'de bu uç FİİLEN NO-OP'TU** (bloker #2): iptal `revoked_at`'i yazıyordu ama `/refresh` yüklemi ona hiç bakmıyordu. Kapatma K3-C6'dadır; kapısı **M26**.

**K3-C5 — ZARAFET PENCERESİ YOKTUR. [K11-c]** v1'in *"aynı aileden, son 10 sn içinde üretilmiş token da kabul edilir"* penceresi **KALDIRILMIŞTIR**.
> **⚠ K14-a'NIN REPLAY-IDEMPOTENCY PENCERESİ BU DEĞİLDİR — FARK YAPISALDIR, aşağıda tabloyla yazılıyor (K3-C6).** v1'in penceresi *"ailenin herhangi bir yeni token'ını kabul et"* diyordu ⇒ saldırgan 5 sn'de bir `/refresh` çağırarak **sonsuz bir zarafet zinciri** kurar ve reuse-detection'a **yapısal olarak erişilemez** kılardı. K14-a'nınki *"bu tek token'ın kayıtlı halefini aynen tekrar ver"* diyor ⇒ zincir doğmaz.

**K3-C6 — TÜKETİM ATOMİKTİR; YÜKLEM TAMDIR; 0-SATIR DALI DÖRDE AYRILIR. [bloker #1 + #2 kapanır — bu belgenin en çok değişen maddesi]**

**v2'nin yüklemi eksikti ve tamlık iddiası YANLIŞTI.** v2 birebir şöyle diyordu: *"Etkilenen satır **0** ise token **ya tüketilmiştir** … **ya yoktur**"* — sonuç uzayı hakkında **kapalı bir disjonksiyon**, ve şemada `revoked_at`/`expires_at` varken **yanlış**. Sonucu: `/logout` fiilen no-op, mutlak 30 gün zorlanmıyor.

**(1) Atomik tüketim (yüklem tamamlandı):**
```sql
UPDATE refresh_tokens
   SET consumed_at = @now, replaced_by_id = @new
 WHERE token_hash  = @h
   AND consumed_at IS NULL
   AND revoked_at  IS NULL
   AND expires_at  > @now
RETURNING …;
```
Kontrol-sonra-yaz (check-then-act) **yasaktır**.

**(2) Etkilenen satır 0 ise — DÖRT dal, tek `SELECT` ile ayrıştırılır** *(bu `SELECT` bir check-then-act değildir: yazma zaten denenmiş ve başarısız olmuştur; okuma yalnız **hangi hata** olduğunu belirler)*:

| durum | sunum | aile iptali |
|---|---|---|
| **(a)** satır yok (`token_hash` bulunamadı) | `401` | **YOK** |
| **(b)** `revoked_at` dolu **veya** `expires_at ≤ now` | `401` | **YOK** — zaten ölü; ikinci kez iptal etmek `revoked_reason`'ı bozar |
| **(c)** `consumed_at` dolu **ve** replay-idempotency koşulları sağlanıyor (aşağıda) | **`200` — kayıtlı halef aynen döndürülür** | **YOK** |
| **(d)** `consumed_at` dolu, koşullar sağlanmıyor | `401` | **VAR — `reuse_detected`, ailenin tamamı** |

**(3) SINIRLI REPLAY-IDEMPOTENCY [K14-a — bloker #1 / **RT-B1**'in kapatılması].**
**Kırılan senaryo (saldırgan gerekmez; aktör = ağ):** istemci `/refresh` gönderir (`T1`) → sunucu tüketimi **commit eder** (`T2` doğar) → **yanıt istemciye ulaşmaz** (uçak modu, hücresel el değiştirme, TCP reset, Android Doze/process kill) → istemcinin elinde hâlâ `T1` var, `T2`'yi hiç görmedi → yeniden dener → v2'de **aile düşer, meşru kullanıcı kendini hırsız ilan eder**. Tek-uçuşluluk (K3-L5) bunu **kapsamaz**: o *eşzamanlı* çağrıları serileştirir, *ardışık yeniden denemeyi* değil — ikinci adımda uçuş zaten bitmiştir.

**Kural:** tüketilmiş `T1` yeniden sunulduğunda, **her iki koşul da** sağlanıyorsa `T1`'in **kayıtlı halefi aynen** döndürülür; yeni döndürme **yapılmaz**:
1. `now ≤ T1.consumed_at + 60 sn` **[K14-i sayısı — Onur kilidi değil, kilit turunda gözden geçirilebilir]**, **ve**
2. `T1.replaced_by_id`'nin işaret ettiği satırın `consumed_at`'i **hâlâ `NULL`** (halef henüz kullanılmamış).

**Neden bu, v1'in reddedilen zarafet penceresi DEĞİL:**

| eksen | v1 zarafet penceresi (REDDEDİLDİ) | K14-a replay-idempotency |
|---|---|---|
| Çıpa | **aileye** (*"ailenin son 10 sn'de üretilmiş herhangi bir token'ı"*) | **tek token'a** (`T1.consumed_at`) |
| Her çağrıda ne olur | **yeni token üretilir** ⇒ pencere ileri kayar | **hiçbir şey üretilmez** ⇒ pencere sabit, `T1` ile birlikte ölür |
| Sonsuz zincir | **MÜMKÜN** (5 sn'de bir `/refresh` ⇒ reuse-detection'a hiç varılmaz) | **YAPISAL OLARAK İMKÂNSIZ** |
| Halef kullanıldıysa | fark etmez, yine kabul | **REDDEDİLİR ⇒ aile düşer** (gerçek hırsızlık sinyali korunur) |
| Ömür | uzayabilir | `expires_at` devralındığı için **uzamaz** |

**Hırsızlık senaryosunda ne kaybediyoruz — dürüst muhasebe:** saldırgan `T1`'i çalıp **60 sn içinde ve meşru istemci `T2`'yi kullanmadan önce** sunarsa, aile düşmez ve saldırgan `T2`'yi alır. **Ama meşru istemci `T2`'yi kullandığı anda** — ki elinde `T2` varsa saniyeler içinde kullanır — saldırganın bir sonraki `/refresh`'i (d) dalına düşer ve **aile düşer**. Yani pencere reuse-detection'ı **kaldırmaz, 60 saniye geciktirir**. Bu maliyet, *"tek ağ kesintisi 30 günlük oturumu yeniden girişe çeviriyor"* maliyetine karşı bilinçli olarak seçilmiştir (K14-a).

**Kapılar: M29** (pencere dışında sunulan tüketilmiş token **aile düşürür**) · **M30** (halef tüketilmişse **aile düşürür**) · **M1** (replay-idempotency tamamen kaldırılırsa değil — reuse-detection kaldırılırsa).

**(4) ATOMİKLİK KAPISI [D3 majörü kapatılıyor].** v2 atomikliği **iddia ediyor ama test etmiyordu**. Emsal 0002 K2-H12'de var: *"aynı `T1` ile **paralel** iki `/refresh` — tam olarak **biri** `200`, diğeri `401`+`reuse_detected` alır; ikisi birden `200` alırsa test FAIL"* — **M39** (Testcontainers, gerçek Postgres; `TestServer` içi kilit bunu kanıtlamaz).

**K3-C7 — `TokenValidationParameters` AÇIKÇA YAZILIR — hiçbir varsayılana güvenilmez.**

| ayar | değer | neden |
|---|---|---|
| `ValidateIssuer` / `ValidIssuer` | `true` / yapılandırmadan | K3-C1'in `iss` talebiyle eşleşir |
| `ValidateAudience` / `ValidAudience` | `true` / yapılandırmadan | K3-C1'in `aud` talebiyle eşleşir |
| `ValidateLifetime` | `true` | — |
| **`ClockSkew`** | **`TimeSpan.Zero`** | **ÖLÇÜLDÜ:** `TokenValidationParameters.DefaultClockSkew = TimeSpan.FromSeconds(300)` ⇒ varsayılanla **beyan edilen ≤15 dk fiilen ≤20 dk** olurdu. |
| `ValidateIssuerSigningKey` / `IssuerSigningKey` | `true` / K3-I1'den | — |
| `ValidAlgorithms` | `[ "HS256" ]` | **⚠ AŞAĞIDAKİ DÜZELTMEYİ OKU — bu bir KAPI DEĞİL, HİJYENDİR.** |
| `RequireSignedTokens` / `RequireExpirationTime` | `true` / `true` | `RequireSignedTokens` **`alg:none`'ı kapatan asıl ayardır** |
| **`MapInboundClaims`** | **`false`** | Claim tipleri ham JWT adlarıyla kalır (`sub`, `jti`, `fid`, `sstamp`). |

> **🔴 v2'NİN `alg` BEYANI YANLIŞTI — DÜZELTİLİYOR [bloker #12].**
> v2 birebir *"Pinleme, algoritma-karıştırma sınıfını tek satırla kapatır"* diyordu. **Ölçüm bunu yalanlıyor:**
> 1. Simetrik anahtarla **RS256/ES256 yapısal olarak zaten reddedilir** (`SymmetricSignatureProvider` yalnız `HmacSha256/384/512` + `Aes*CbcHmacSha*` üretir) ⇒ testi RS256 ile yazan bir builder'da mutant **hayatta kalır = kör kapı**.
> 2. **`alg:none`'ı kapatan `ValidAlgorithms` değil `RequireSignedTokens`'tır** ⇒ testi `alg:none` ile yazan bir builder'da da mutant hayatta kalır.
> 3. Pinlemenin kapattığı **tek** şey **aynı anahtarla HS384/HS512 ikamesidir** — ve o anahtara sahip bir saldırgan zaten HS256 imzalayabilir.
> **Sonuç:** ayar **TUTULUR** (ileride asimetrik anahtar eklenirse kritik olur) ama **kapı sayılmaz**. M16'nın `alg` ayağı **HS512 ikamesine** pinlenir (tek gerçekten ısıran varyant); `ClockSkew` ayağı olduğu gibi kalır.

> **⚠ `MapInboundClaims=false`'UN ÖLÇÜLMÜŞ YAN ETKİSİ — ÜÇ YERİ VURUR (kaynaktan doğrulandı, 25 Tem 2026):**
> `ClaimTypeMapping.InboundClaimTypeMap` birebir `{ JwtRegisteredClaimNames.Sub, ClaimTypes.NameIdentifier }` girdisini taşır; `JwtBearerOptions.MapInboundClaims` varsayılanı **`true`**'dur ve `false` yapıldığında **çeviri hiç koşmaz** ⇒ `ClaimTypes.NameIdentifier` **DOLMAZ**.
> 1. **Bu belgede:** `ICurrentUser` `ClaimTypes.NameIdentifier` okursa **her istekte `UnauthenticatedException`** ⇒ **`"sub"` doğrudan okunur** (K3-D2, kapı **M24**).
> 2. **ADR 0004'te:** `DefaultUserIdProvider.GetUserId` = `connection.User.FindFirst(ClaimTypes.NameIdentifier)?.Value` ⇒ SignalR `Context.UserIdentifier` **`null`** düşer, `user:{id}` grubu **sessizce** hiçbir istemciye ulaşmaz. Özel `IUserIdProvider` **zorunludur** (**D-1**, §7).
> 3. **[YENİ — D2-#5] `NameClaimType`/`RoleClaimType` bağımsızdır** ⇒ `ClaimTypes.Name` eşlemesi de koşmaz, **`User.Identity.Name` `null` kalır.** Bu kapsamda etkisizdir (token'da `name` talebi yok, roller kapsam dışı) **ama işbirliği diliminde canlanır** — o dilim `User.Identity.Name`'e dayanırsa sessizce boş görünen kullanıcı adları üretir. **Adlandırıldı; 0004/işbirliği diliminin girdisidir.**

**K3-C8 — `security_stamp` BUGÜN ÖLÜ ALANDIR — BİLİNÇLİ VE BEYAN EDİLMİŞ. [K14-d — Ma-5 kapanır]**
Kolon (`User.security_stamp`) ve talep (`sstamp`) **vardır**; **doğrulaması yoktur** ve hiçbir olayda değişmez. Bu bir unutma değil, bir karardır.

- **Sunulmamış ödünleşim, artık sunuluyor:** `/logout-all` (ve ileride parola değişimi) `security_stamp`'i artırsaydı ve her korumalı istekte token'daki `sstamp` DB'dekiyle karşılaştırılsaydı, **Risk #3'ün 15 dakikalık penceresi sıfıra inerdi**. Bedeli: **istek başına bir DB okuması**.
- **Neden yapılmadı:** **K3-K3 zaten *"anlık erişim-token'ı iptali (kara liste)"* kalemini KAPSAM DIŞI ilan etmişti.** Doğrulamayı eklemek o kapsam kararını **sessizce geri almak** olurdu — ve bu belgenin doktrini *"beyan edilmiş sınır kabul edilir, gizlenmiş sınır edilmez"*dir.
- **Ne için duruyor:** ileride parola değiştirme ya da anlık iptal kapsama girerse **kancanın hazır olması** için. O gün geldiğinde eklenecek olan şey **doğrulamadır**, şema değişimi değil.
- *Reddedilenler:* canlandırma (istek başına 1 DB okuması + kapsam genişlemesi) · kolonu ve talebi **tamamen kaldırmak** (ileriye kanca kalmaz; K3-C4'ün *"kanca bırakır"* cümlesi de düzeltilmek zorunda kalırdı).
- **Kapısı yoktur ve bu §3.1'de açıkça beyan edilir** — ölü bir alanın mutantı da ölü olurdu.

### D. `ICurrentUser` sözleşmesi [K-D5'in sözleşme ayağı]

**K3-D1 — Şekil.** `Application` katmanında: `Guid UserId { get; }` — kimlik yoksa **`UnauthenticatedException` FIRLATIR**, `Guid.Empty` **DÖNDÜRMEZ** — ve `bool IsAuthenticated { get; }`. *Gerekçe:* `Guid.Empty` sessizce sorguya sızar ve "hiçbir şey döndürmeyen ama patlamayan" bir filtre kurar — **deny-by-default'un en sinsi ihlali**. Kapı: **M15**.

**K3-D2 — Implementasyon `HttpContext.User`'dan `"sub"` claim'ini okur, `scoped` ömürlüdür.** `ClaimTypes.NameIdentifier` **okunmaz**. Değer `Guid.TryParse` ile ayrıştırılır; ayrıştırılamazsa `UnauthenticatedException`.

**K3-D3 — ⚠ ARKA PLAN SERVİSİ TUZAĞI.** `OutboxDispatcher` bir `BackgroundService`'tir (singleton) ve **`HttpContext`'i yoktur**. Bir `scoped ICurrentUser`'ı oradan çözmek ya çalışma-zamanı hatası ya da **daha kötüsü** sessiz yanlış kimlik üretir. **Kural:** dispatcher owner-filtreli hiçbir sorguya dokunmaz; outbox okuması **açıkça filtresizdir**. *(İstisnanın allowlist'i ve filtre tarafı **0004**'ün işidir.)* Kapı: **M19**.

**K3-D4 — `User.Identity.Name` KULLANILMAZ. [D2-#5]** `MapInboundClaims=false` altında `ClaimTypes.Name` eşlemesi koşmaz ⇒ `User.Identity.Name` **`null`**'dur. Kullanıcıyı tanımlayan tek kaynak `ICurrentUser.UserId`'dir. *Bu kural bugün etkisizdir ama işbirliği dilimi için yazılmıştır: orada "kim yazdı" gösterimi `User.Identity.Name`'e dayanırsa **sessizce boş** görünür.*

### I. Sırlar [kırmızı çizgi #1]

**K3-I1 — İmzalama anahtarı repoya GİRMEZ.** Geliştirmede `dotnet user-secrets` **veya K3-I3'ün bootstrap dosyası**, üretimde ortam değişkeni. **Varsayılan/gömülü anahtar YOKTUR.**

**K3-I2 — Anahtar yoksa uygulama AÇILMAZ (fail-fast).** Eksik veya **32 bayttan kısa** anahtarda başlangıçta `InvalidOperationException`.

**K3-I3 — GELİŞTİRME BOOTSTRAP'I: COMPOSE İLK AÇILIŞTA RASTGELE ANAHTAR ÜRETİR. [K14-b — bloker #8 kapanır]**
**Kırılan senaryo:** K3-I2 anahtarsız başlangıcı patlatıyor (doğru), K3-I1 gömülü anahtarı yasaklıyor (doğru) — ama **`dotnet user-secrets` klonla gelmez.** Değerlendirici `docker compose up` der, **hiçbir şey ayağa kalkmaz**; K14-e gereği web de aynı süreçten servis edildiği için **uygulama hiç görünmez**. ODEV §2 (*"kesinlikle çalışan bir uygulama; önce uygulamaya bakılacak"*) doğrudan vurulur. Compose dosyasına sabit anahtar yazmak ise **kırmızı çizgi #1** ihlalidir. **v2 bu ikilemi hiç kurmuyordu.**

**Karar:**
- Konteynerin giriş betiği, `ASPNETCORE_ENVIRONMENT=Development` **ve** anahtar dosyası yoksa, **CSPRNG ile 32 bayt üretip** git-ignore'lu bir dosyaya yazar (ör. `./.secrets/jwt-signing.key`, mount edilmiş bir volume'de). Sonraki açılışlar **aynı** anahtarı okur ⇒ mevcut oturumlar restart'ta düşmez.
- **`Production` yolunda bu kod ASLA koşmaz.** Üretimde eksik anahtar **hâlâ patlar** (K3-I2 aynen geçerli).
- `.gitignore`'a `.secrets/` eklenir; `.env.example` yine bulunur (ortam değişkeni adlarını belgelemek için) ama **içinde anahtar yoktur**.

**M8 İKİ AYAKLI OLUR [bloker #8'in kapısı]:**
1. *"`Production`'da anahtarsız/kısa anahtarlı başlangıç **patlar**"* — mutasyon: fail-fast kaldırılır → FAIL.
2. *"`Development` bootstrap'ı **`Production` yolunda ASLA koşmaz**"* — mutasyon: ortam koşulu kaldırılır (her ortamda üretir) → **`Production`'da anahtarsız başlangıç artık patlamaz** → FAIL. **Bu ikinci ayak olmadan bootstrap'ın kendisi bir güvenlik açığı kapısıdır.**

*Reddedilenler:* `.env.example` + README adımı (en şeffaf, ama `docker compose up` tek başına yetmez ⇒ ODEV §2 değerlendiricinin README okumasına bağlanır) · repoda `DEVELOPMENT ONLY` etiketli sabit anahtar (en kolay açılış, ama kod kalitesi ölçen bir değerlendirici repoda sır görür — gerekçe yazılsa bile kötü sinyal).

### J. Uçlar + kaba kuvvet

**K3-J1 — Uçlar, deny-by-default ve STATİK DOSYA SIRASI. [K14-e ile birlikte okunur]**
Uçlar: `POST /v1/auth/register` · `/login` · `/refresh` · `/logout` · `/logout-all`. İlk üçü `AllowAnonymous`; **`/logout` ve `/logout-all` kimlik ister** (Bearer + `fid`). **Diğer her uç deny-by-default** — `FallbackPolicy = RequireAuthenticatedUser` (K-D5). `/health/live` ve `/health/ready` anonim kalır (K-D2).

> **🔴 v2'DE BU MADDE SPA'YI ÖLDÜRÜYORDU [bloker #3, dal (a)].** MS Learn birebir: *"For requests served by other middleware after the authorization middleware, such as **static files**, the policy applies to **all requests**."* ⇒ `FallbackPolicy` ile `GET /` ve SPA'nın her derin linki (`/tasks`, `/settings`) **`401`** döner ⇒ **giriş ekranına fiziksel olarak ulaşılamaz.** v2 bunu ne görüyor ne kaçış yolunu yazıyordu. **M14 bu yönü ısırmaz** — M14 tersini test eder.

**PAZARLIKSIZ MIDDLEWARE SIRASI (K14-e'nin doğrudan sonucu):**
```
UseForwardedHeaders  ❌ YOK (K14-e: proxy yok)
UseDefaultFiles      →  UseStaticFiles        ← auth'tan ÖNCE
UseRouting
UseAuthentication    →  UseAuthorization
MapControllers / MapGroup("/v1")
MapFallbackToFile("index.html").AllowAnonymous()   ← AÇIKÇA anonim
```
**Kapı: M33** — mutasyon: `UseStaticFiles` auth middleware'inden **sonraya** alınır **veya** fallback ucundan `AllowAnonymous` kaldırılır. Kill sinyali: *"kimliksiz `GET /` ve `GET /tasks` **`200`** döner ve `index.html` gövdesi gelir"* **FAIL**.

**K3-J2 — Kaba kuvvet savunması ÜÇ AYRI KONTROLDÜR; ÜÇÜ AYRI ŞEY KORUR; SAYILARI YAZILIR. [K11 kilidi + R2 + bloker #5 + bloker #13]**
`Microsoft.AspNetCore.RateLimiting` (middleware ayağı) + `System.Threading.RateLimiting` (handler ayağı) — **çerçevede yerleşik, yeni NuGet YOK** (kırmızı çizgi 3 tetiklenmez).

| # | kontrol | nerede koşar | anahtar | **sayı [K14-i]** | neyi korur | neyi KORUMAZ |
|---|---|---|---|---|---|---|
| **1** | Sabit pencere — `/login`, `/refresh`, `/register` | **middleware** | **yalnız istemci IP'si** (`RemoteIpAddress`) | **10 istek / 5 dk**, `QueueLimit=0` | **Maliyet/DoS** | Botnet/proxy havuzu (beyan edilir) |
| **2** | Sabit pencere — yalnız `/login` | **handler içi** (K14-f) | **normalize e-posta** | **5 deneme / 15 dk** | **Tek hesaba parola deneme** | **DoS'u KORUMAZ** — anahtarı saldırgan seçer |
| **3** | Eşzamanlılık limiti — **her Argon2 çağrısı (hash VE verify)** | **handler içi** | küresel (partition yok) | izin = `ProcessorCount`, `QueueLimit = 2×ProcessorCount` | **Argon2'nin bellek/CPU çarpanı** | — |

> **[Ma-1 kapatıldı]** v2 kontrol 3'ü *"parola **doğrulama** işi"* diye tanımlıyordu ⇒ `/register`'ın Argon2 **hash**'i kapsam dışı kalıyordu ve Risk #4'ün telafi cümlesi `/register` yolunda yanlıştı. Tanım artık **"her Argon2 çağrısı"**dır.

> **🔴 v2'NİN KONTROL 2'Sİ SEÇİLEN MEKANİZMAYLA İNŞA EDİLEMİYORDU [bloker #5].** E-posta istek **gövdesindedir**; `RateLimiterOptions.AddPolicy` partitioner'ı **senkron** bir delegedir (`Func<HttpContext, RateLimitPartition<T>>`; üç aşırı yüklemenin **üçü de** senkron, `ValueTask` varyantı yok) ⇒ gövde `await` edilemez, `EnableBuffering` + senkron okuma Kestrel'in `AllowSynchronousIO=false` varsayılanına çarpar. Builder'ın kaçınılmaz seçimi limiti handler'a taşımaktı — **ve bu, v2'nin K3-J3'teki bağlayıcı sırasını sessizce bozardı.**
> **[K14-f] Karar:** kontrol 2 **açıkça** handler içindedir; DI'dan alınan bir `PartitionedRateLimiter<string>` ile koşar (gövde o noktada zaten deserialize edilmiştir). *Reddedilenler:* anahtarı bir başlıktan almak (**anahtarı istemci seçer ⇒ R2'nin kapattığı hata sınıfı aynen geri gelir**) · kontrol 2'yi tamamen kaldırmak (tek hesaba yavaş parola denemesi sınırsız kalırdı).

**R2'nin kırdığı yer, kayda geçmeye devam ediyor:** v1'in anahtarı **IP + e-posta birleşimiydi**. Saldırgan her istekte rastgele bir e-posta yazarak **her seferinde yeni bir partition** yaratır ⇒ sayaç **hiç dolmaz**, ama her istek **270 ms + 19 MiB sahte Argon2** yakar. **Ayrım şudur: DoS'u durduran (1) ve (3)'tür; (2) hesabı korur ve bir DoS kontrolü olarak SAYILMAZ.**

**K3-J3 — BAĞLAYICI SIRA [K14-f ile yeniden yazıldı].**
```
middleware:  IP penceresi (kontrol 1)
     ↓  geçerse
handler:     gövde deserialize + girdi doğrulama (K3-B6)
     ↓
handler:     e-posta penceresi (kontrol 2)
     ↓
handler:     eşzamanlılık limiti (kontrol 3)
     ↓
             gerçek VEYA sahte Argon2  ← limit aşılmışsa BURAYA HİÇ GELİNMEZ
```
Sıra bağlayıcıdır: limit aşılmışsa **hiç Argon2 koşmaz**. Aksi hâlde K3-B5'in zamanlama savunması kendisini bir **DoS amplifikatörüne** çevirirdi. *(v2'de sıra middleware'de varsayılıyordu; K14-f onu tek bir kod yolunda **görünür** kıldı — bağlayıcılık zayıflamadı, aksine test edilebilir hâle geldi.)*

**K3-J4 — REDDİN YANITI: `429` AÇIKÇA YAZILIR; VARSAYILAN `503`'TÜR. [bloker #7 kapanır]**
> **🔴 ÖLÇÜM (dotnet/aspnetcore `release/9.0`, `RateLimiterOptions.cs`):** `public int RejectionStatusCode { get; set; } = StatusCodes.Status503ServiceUnavailable;` — XML doc birebir *"Defaults to StatusCodes.Status503ServiceUnavailable"*. Durum kodu `OnRejected` **çağrılmadan önce** set edilir; `OnRejected` onu ezebilir.
> **v2 `429` kararını verdi ama override'ı YAZMADI** ⇒ (a) gerçekte `503` dönerdi, (b) `Retry-After` **otomatik değildir**, (c) `503` semantik olarak yanlıştır ve Flutter istemcisinin retry politikasını *"sunucu çökmüş"* diye yorumlatır, (d) **M11/M22/M23'ün kill sinyalleri baseline'da kırmızı doğardı = ölü tuzak.** Bu, §4'teki kendi manşet tezinin (*"bir ADR'nin işi sessiz varsayılanların hangisinin kabul edildiğini yazmaktır"*) **birebir ihlaliydi** — `ClockSkew` için titizlikle yapılan iş burada yapılmamıştı.

**Karar:**
- `options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;` **açıkça yazılır**.
- `OnRejected` **yazılır** ve şunları yapar: (a) `Retry-After` başlığını, lease `MetadataName.RetryAfter` **taşıyorsa** ondan, taşımıyorsa pencere süresinden hesaplayarak set eder; (b) tek tip `ProblemDetails` gövdesi üretir; (c) **reddin kaynağını ayırt eden bant-dışı bir kod** yazar (`problem.Extensions["limit"]` = `"ip" | "email" | "concurrency"`).
- (c) şıkkı **kozmetik değildir**: M22/M23'ün *"hangi limit reddetti"* sorusunu ayırt etmesini sağlar (bloker #13).
- **Hesap KİLİTLEME YOKTUR** — kilitleme, saldırganın kurbanın hesabını kasten kilitlemesine izin verir ve K8-d ile kapsam dışıdır.

> **[DOĞRULANMADI — ölçülmedi, iddia edilmiyor]** `System.Threading.RateLimiting.ConcurrencyLease`'in `MetadataName.RetryAfter` taşıyıp taşımadığı bu belgede **ölçülmemiştir** (bir denetçi *"taşımıyor, yalnız `ReasonPhrase` var"* dedi; teyit edilmedi). Bu yüzden yukarıdaki (a) şıkkı **koşullu** yazılmıştır: taşımıyorsa `Retry-After` pencere süresinden hesaplanır. **Spec aşamasında kaynaktan ölçülür.**

**K3-J5 — ✅ KAPATILDI (v2'de `[DOĞRULANMADI]`, artık ÖLÇÜLDÜ).**
> **ÖLÇÜM (dotnet/runtime `release/9.0`, `DefaultPartitionedRateLimiter.cs`):** `private static readonly TimeSpan s_idleTimeLimit = TimeSpan.FromSeconds(10);` · timer periyodu `TimeSpan.FromMilliseconds(100)` · `if (idleDuration > s_idleTimeLimit) { _cacheInvalid = true; _limiters.Remove(rateLimiter.Key); _limitersToDispose.Add(...); }` + `await limiter.DisposeAsync()`.

**Sonuç, abartısız yazılıyor:** atıl partition'lar **temizlenir** ⇒ *"rastgele e-postalarla sınırsız bellek büyümesi"* endişesi **geçersizdir**. Ama bu **"sıfır bellek" demek değildir**: tavan ≈ **istek hızı × 10 sn** kadar canlı partition'dır, ve **tavanı anlamlı kılan şey kontrol 1'in IP penceresidir** (K3-J2/1 — o da K14-e sayesinde proxy arkasında ölmez). İkisi birlikte okunur; tek başına hiçbiri yeterli değildir.

**K3-J6 — `/logout` ve `/logout-all` DA HIZ SINIRI KAPSAMINDADIR; NAT YANLIŞ-POZİTİFİ ADLANDIRILIR. [RT-M6 kapanır]**
- v2'de bu iki uç hız sınırı dışındaydı ⇒ çalınmış bir JWT ile **DB yazma fırtınası** (her `/logout-all` bir kullanıcının tüm ailelerine `UPDATE`) mümkündü. **Karar:** ikisi de kontrol 1'in IP penceresine dâhildir (ayrı ve daha gevşek bir politika: **20 istek / 5 dk** — meşru kullanım tek hanelidir).
- **Yanlış-pozitif tarafı, ilk kez adlandırılıyor:** CGNAT ya da kurumsal NAT arkasındaki **tüm** meşru kullanıcılar **tek partition'a** düşer ⇒ bir ofisten aynı anda giriş yapan 11. kullanıcı `429` alır. Bu, IP-anahtarlı sabit pencerenin **kaçınılmaz** bedelidir ve tek-instance bir ödev dağıtımında **kabul edilmiştir**. Kapatmanın yolu (kullanıcı-anahtarlı ikinci bir katman + dağıtık sayaç) **K3-K3 ile kapsam dışıdır**.

### K. Elenen ve kapsam dışı [ADLANDIRILDI]

**K3-K1 — ASP.NET Core Identity KULLANILMAZ [K8-d].** *Gerekçe:* Identity, `DbContext`'i `IdentityDbContext`'e çevirir, Infrastructure tiplerini yukarı iter ve 7 tablosunun 5'i bu kapsamda kullanılmaz ⇒ **mevcut NetArchTest kapıları gevşetilir veya istisna alır. Kendi kurduğun kapıyı üçüncü parti için gevşetmek, kod kalitesi ölçen bir ödevde verilebilecek en kötü sinyaldir.** Kapsam darken elle implementasyon ~200-300 satırdır. *Reddedilen: melez `PasswordHasher<T>` — hash kararını fiilen PBKDF2'ye kilitlerdi.*

**K3-K2 — İLKE: KRİPTO PRİMİTİFİNİ YAZMAYIZ, AKIŞI YAZARIZ.** Argon2id, SHA-256, **HMAC-SHA256 (CSRF token'ı)**, JWT imzası, CSPRNG — hepsi dışarıdan (paket veya BCL). Elle yazılan yalnız **akıştır**. **Bu ADR'de hiçbir kriptografik primitif implemente edilmemektedir.**

**K3-K3 — Kapsam dışı [adlandırılmış]:** parola sıfırlama · parola **değiştirme** · e-posta doğrulama · OAuth/sosyal giriş · 2FA · RBAC/roller · hesap kilitleme · collaborator/paylaşım yetkisi (işbirliği dilimi) · **anlık erişim-token'ı iptali (kara liste) — K3-C8 bu kararın doğrudan sonucudur** · dağıtık (çok-instance) hız sınırlama sayacı · **kullanıcı-anahtarlı ikinci hız sınırlama katmanı (K3-J6'nın NAT yanlış-pozitifinin çözümü)** · **reverse-proxy dağıtımı (K14-e)**.

### L. İstemci sözleşmesi [K11-f/g + K14-a/c/e — v1'in cevapsız bıraktığı sorular]

> Bu bölüm backend'in **istemciye dayattığı** sözleşmedir. Flutter kodu `slice-3b`'de yazılır ama **bu kararlar Drift şemasını ve depo katmanını bugün belirler** — sonraya bırakmak migration demektir (§1).

**K3-L1 — Token deposu, native (Android/iOS/Windows): `flutter_secure_storage`.** Yenileme token'ı orada; erişim token'ı **yalnız bellekte**.
> **[D2-#21 — v2'nin DPAPI İDDİASI GERİ ÇEKİLİYOR]** v2 *"Keystore / Keychain / **DPAPI**"* diyordu. **Windows şifreleme yöntemi DOĞRULANAMADI**: paket README'si yöntemi söylemiyor; bir denetçi *"AES-GCM + Windows Credential Manager"* dedi, teyit edilemedi. **Bu belgede artık iddia edilmiyor: `[DOĞRULANMADI]`.** Android/iOS ayakları (Keystore/Keychain) README'de yazılıdır. **Web ayağı README'de birebir *"experimental… use at your own risk"* + LocalStorage'dır ⇒ K3-L2'nin web reddi ölçümle DOĞRULANMIŞTIR.**
> *Bağımlılık kapısı (lisans + CVE, kırmızı çizgi 3) `slice-3b` spec'inde koşar. **Lisans ölçüldü: BSD-3-Clause**, 0001 K-H2'nin izinli ailesinde ⇒ kırmızı çizgi 3 tetiklenmiyor. CVE ayağı 3b'de koşar; düşerse K3-L1 yeniden açılır.*

**K3-L2 — Token deposu, web: yenileme token'ı ÇEREZ; ÇEREZ ÖZNİTELİKLERİ TAM YAZILIR. [Ma-8 kapanır]**
v2 çerezi kararlaştırdı ama **adını, `Path`'ini, `Domain`'ini ve ömrünü hiç yazmadı** — dördü de güvenlik sonucu doğuran alanlardır.

| öznitelik | değer | gerekçe |
|---|---|---|
| **ad** | **`__Host-mrt`** (Momentum Refresh Token) | `__Host-` öneki: tarayıcı **`Domain` özniteliğini yasaklar** ve `Path=/` + `Secure` zorunlu kılar ⇒ **kardeş alt alan adı bu çerezi YAZAMAZ** (RT-B2'nin yapısal cevabı) |
| `HttpOnly` | `true` | JS okuyamaz ⇒ tek XSS yenileme token'ını **okuyamaz** |
| `Secure` | `true` | `__Host-` gereği zorunlu; ayrıca K3-L4'ün `localhost` notu |
| `SameSite` | **`Strict`** | klasik çapraz-site CSRF'i kapatır (K14-e sayesinde fiilen çalışır) |
| **`Path`** | **`/`** | `__Host-` öneki `Path=/` **zorunlu kılar** — seçim değil, önekin bedeli. **Sonucu dürüstçe yazılıyor:** yenileme çerezi **her** aynı-origin isteğinde tele çıkar (statik dosyalar dâhil). Kabul ediliyor çünkü `__Host-`'un çerez-enjeksiyonu bağışıklığı bu maliyetten daha değerli; ve K14-c gereği **sunucu çerezi yalnız `/refresh`'te okur**. |
| **`Domain`** | **YAZILMAZ** | `__Host-` bunu yasaklar |
| **ömür** | **`Max-Age` = ailenin kalan `expires_at`'i (≤30 gün)** — oturum çerezi **DEĞİL** | Oturum çerezi olsaydı **tarayıcı kapanınca çıkış** olurdu = K11-f'in **reddettiği** "F5 = çıkış" şıkkının kardeşi. Her `/refresh`'te `Max-Age` **yeniden hesaplanır** (uzatılmaz — `expires_at` sabittir, K3-C2). |

Erişim token'ı web'de de **yalnız bellektedir** (sekme-yerel).
*Reddedilenler:* web'de yalnız bellek (F5 = çıkış) · her platformda `flutter_secure_storage` (web'de LocalStorage'a düşer ⇒ "secure" adı yanıltıcı olur, README'nin kendisi *"use at your own risk"* diyor).

**K3-L3 — CSRF: İKİ KATMAN; İKİNCİ HAT İMZALIDIR VE AİLEYE BAĞLIDIR. [RT-B2 — bloker #4 kapanır]**

> **🔴 v2'NİN İKİNCİ HATTI, TUTULMA GEREKÇESİ OLAN VEKTÖRE KARŞI GEÇERSİZDİ.** Saldırı: saldırgan kardeş bir alt alan adını ele geçirir (DNS takeover / unutulmuş statik site / oradaki bir XSS) → `Set-Cookie: csrf=SALDIRGAN; Domain=momentum.app; Path=/` yazar (**çerezler origin değil domain kapsamlıdır**) → kurbanı o alt alandaki bir sayfaya çeker → sayfa `/v1/auth/refresh`'i `X-CSRF-Token: SALDIRGAN` ile çağırır → `SameSite=Strict` yenileme çerezini **taşır** (istek same-site'tır) → sunucu çerez == başlık karşılaştırır → **EŞLEŞİR** → geçer.
> **OWASP birebir:** naif double-submit *"bypassable by an attacker who can write cookies on the target domain (e.g., via a vulnerable sibling subdomain, DNS takeover…)"* · *"For new code, use the **Signed** Double-Submit Cookie pattern… **The naive pattern is documented for reference only.**"*
> **Belgenin kendisi bu vektörü K3-L4 notunda adlandırıyor ve double-submit'i TAM DA ONA KARŞI tutuyordu.**

**Karar — üç ayak birlikte:**
1. **Birinci hat — `SameSite=Strict`:** klasik çapraz-site CSRF'ini kapatır.
2. **Yapısal ayak — `__Host-` öneki (K3-L2):** yenileme çerezine **ve** CSRF çerezine (`__Host-mct`) uygulanır ⇒ kardeş alt alan adı **bu çerezleri yazamaz**; saldırının birinci adımı **yapısal olarak** imkânsızlaşır.
3. **İkinci hat — İMZALI double-submit:** CSRF çerezinin değeri rastgele bir dize **değil**, `value = nonce + "." + Base64Url(HMAC-SHA256(key, nonce + "|" + family_id))`'dir. Sunucu başlıktaki değeri alır, HMAC'i **kendi anahtarıyla** yeniden hesaplar **ve** `family_id`'nin **sunulan yenileme çerezinin ailesiyle aynı** olduğunu doğrular. ⇒ Saldırgan çerez yazabilse bile **geçerli bir imza üretemez**; başka bir ailenin token'ını da ödünç alamaz.

**CSRF çerezinin yaşam döngüsü [Ma-9'un ikinci yarısı]:** `/login` ve her `/refresh` yanıtında **yeniden set edilir** (aile değiştiği veya döndüğü için); `HttpOnly` **değildir** (istemci okumalı); `SameSite=Strict`, `Secure`, `__Host-` önekli. `/logout`'ta silinir.
**CSRF KAPSAMI — K14-c bunu YAPISAL OLARAK ÇÖZDÜ [Ma-9'un birinci yarısı]:** v2'de K3-L3 `/logout`'u da sayıyordu ama K3-J1 onu Bearer'lı yapıyordu ⇒ tutarsızdı. **Bugün `/logout` ve `/logout-all` yetkilerini JWT'nin `fid` talebinden alır** (K14-c) ⇒ otomatik gönderilen bir kimlikle çalışmazlar ⇒ **CSRF yüzeyi yalnız `/refresh`'tir.** Kapı **M25** ve **M35** yalnız orayı test eder; bu artık bir eksiklik değil, bir sonuçtur.

**K3-L4 — [KARAR — Onur] WEB DAĞITIM: AYNI ORIGIN **VE** API STATİK DOSYALARI SERVİS EDER; REVERSE-PROXY YOK. [K12-d + K14-e — bloker #3 kapanır]**

**v2'nin bıraktığı çatal:** *"API statik dosyaları verir **veya** ikisi tek reverse-proxy altında birleşir"* — iki farklı dağıtım, farklı güvenlik sonuçları, **karar yok**. İki dal da bir kontrolü kırıyordu (dal (a): SPA 401'lenir — K3-J1'de kapatıldı; dal (b): aşağıda).

**Karar [K14-e]: tek konteyner; Kestrel hem `/v1/*` API'sini hem Flutter web build'ini servis eder.** Sonuçları:
- **CORS `AllowCredentials` hiç gerekmez** — çapraz-origin isteği yoktur.
- **`SameSite=Strict` gerçekten çalışır.**
- **`RemoteIpAddress` GERÇEK istemci IP'sidir ⇒ `UseForwardedHeaders` hiç gerekmez ve K3-J2(1) yaşar.** Bu, blokerin en sinsi ayağını **doğmadan** kapatır: bir reverse-proxy arkasında `RemoteIpAddress` **proxy'nin IP'sidir** ⇒ **tüm kullanıcılar tek partition'a düşer** ⇒ DoS'u durduran iki ayaktan biri **sessizce ölür**, ve **M11/M23 `TestServer`'da (tek loopback IP) YEŞİL kalırdı = tam anlamıyla kör kapı.** *(R2'nin topolojik ikizi: "partition'ı saldırgan seçer" → **"partition'ı dağıtım siler"**.)*
- **Dağıtım tek birimdir** ⇒ `docker compose up` (K3-I3 ile birlikte) tek komutta çalışan bir uygulama verir (ODEV §2).

> **⚠ `Secure` ÇEREZİN TAŞIMA KISITI — ADLANDIRILMIŞ SINIR [RT-M1].** `Secure` çerezler **`http://localhost` dışında** düz HTTP üzerinden set edilmez. Değerlendirici uygulamayı `http://192.168.1.x:8080` gibi bir LAN adresinden açarsa **çerez hiç set edilmez ve `/refresh` sessizce çalışmaz.** **Karar:** teslim paketi ve README **`http://localhost:PORT`** kullanımını **zorunlu** kılar; alternatifi (self-signed HTTPS) tarayıcı uyarısı üretir ve demoyu zedeler. **Bu bir sınırdır, gizlenmiyor** — ve K3-L4'ün kendi bulduğu hata sınıfının (*"ancak canlı web demosunda fark edilirdi"*) tekrarıdır.

*Reddedilenler [adlandırılmış]:* **reverse-proxy** (daha gerçekçi üretim topolojisi; bedeli `UseForwardedHeaders` + `KnownProxies/KnownNetworks` yapılandırması **ve** M11/M23'ün `TestServer` yerine `X-Forwarded-For` enjekte eden testlere taşınması) · **ikisini de desteklemek** (kapı yükü ikiye katlanır, *"hangisi kanıtlandı"* sorusu denetçiye açık kalır) · **çapraz origin + `SameSite=None`** (CSRF yüzeyi genişler) · **web'de çerez yok** (F5 = çıkış).

> **⚠ `SameSite=Strict` HER ŞEYİ KAPATMAZ.** "Same-site" ≠ "same-origin": **kardeş bir alt alan adı** tarayıcı için hâlâ same-site'tır ve ondan gelen istek çerezi **taşır**. Aynı-origin dağıtım klasik çapraz-site CSRF'ini kapatır; **alt alan adı vektörünü kapatmaz.** Bu yüzden K3-L3 durur — ve v2'nin aksine artık **imzalı**dır.
> **`SameSite=Strict` + harici link şüphesi TEMİZ çıktı (bir sonraki denetçi de buraya saldıracağı için yazılıyor):** RFC 6265bis §5.2.1 gereği, sayfa yüklendikten **sonra** aynı origin'e giden `fetch` **same-site**'tır ⇒ kullanıcı e-postadaki bir linkten gelse bile, açılan SPA'nın kendi `/refresh` çağrısı çerezi **taşır**. Sorun yok.

**K3-L5 — Tek-uçuşlu (single-flight) refresh; SINIRI AÇIKÇA YAZILIR. [K11-c + bloker #1]**
İstemcide **aynı anda en çok BİR** `/refresh` uçuşu olur; 401 alan diğer istekler o tek uçuşun sonucunu **bekler**.
> **🔴 v2'NİN BEYANI YANLIŞTI — DÜZELTİLİYOR.** v2 birebir *"meşru istemcinin kendini hırsız ilan ettirmemesi **bu mekanizmaya** bağlıdır"* diyordu. **Tek-uçuşluluk bunu yapısal olarak yapamaz:** *eşzamanlı* çağrıları serileştirir, **ağ yüzünden kaybolan yanıttan sonraki ARDIŞIK yeniden denemeyi değil.** RFC 9700 §4.14.2 bu durumu bir **maliyet** olarak kabul eder, telafi **vaat etmez**: *"…This stops the attack at the cost of forcing the legitimate client to obtain a fresh authorization grant."*
> **Kayıp yanıt problemini çözen şey K3-C6(3)'ün sunucu-taraflı replay-idempotency penceresidir** (K14-a). Tek-uçuşluluk hâlâ gereklidir (eşzamanlı yarışı çözer ve gereksiz döndürmeyi önler) ama **tek başına yeterli değildir ve öyle beyan edilmez.**

Uçuş başarısızsa istekler kuyrukta kalır (K3-L6), **düşürülmez**. Kapı: **M-L5** (3b'ye devredildi, §7).

**K3-L6 — 401'de kuyruk BEKLER, DÜŞÜRÜLMEZ. [K11-g]** Tek-uçuşlu refresh denenir; başarısızsa gönderilmemiş yazımlar **diskte kalır** ve istemci "oturum gerekli" durumuna geçer. Kullanıcı yeniden giriş yapınca kuyruk **kaldığı yerden** gönderilir. *Gerekçe:* ODEV §6.1 bunu mimari zorunluluk ilan etti. Kapı: **M-L6** (3b'ye devredildi).

**K3-L7 — Çıkışta SİLME YOKTUR: kullanıcı-başına ayrı yerel DB dosyası. [K11-g]** Her kullanıcının Drift dosyası ayrıdır: **`momentum_{userId}.sqlite`**. Çıkışta yerel veri **silinmez**, yalnız o dosya kapatılır. Sonuçları: (a) izolasyon **dosya düzeyinde** — bir sorgu filtresi unutulsa bile sızmaz; (b) A'nın gönderilmemiş yazımları A yeniden girince devam eder; (c) **kırmızı çizgi 4 (kalıcı silme) hiç tetiklenmez**. Kapı: **M-L7** (3b'ye devredildi).

**K3-L8 — SOĞUK AÇILIŞ: AKTİF PROFİL KAYDI + AĞ HATASININ `401`'DEN AYRILMASI. [bloker #10 kapanır]**
**Kırılan senaryo — üç kararın birleşimi, hiçbirinin tek başına görünmediği bir şema sonucu:** erişim token'ı yalnız bellekte (K3-L1/L2) + yerel dosya adı `momentum_{userId}.sqlite` (K3-L7) + `userId`'nin tek kaynağı doğrulanmış JWT'nin `sub`'ı (K3-D2) ⇒ **ağsız açılışta yerel DB açılamaz.** Çevrimdışı-öncelikli bir uygulamada bu, vitrinin tam ortasıdır.

**Karar:**
1. **Aktif profil kaydı:** son oturum açan `userId` — **bir sır değildir** — DB dosyalarının **dışında**, kalıcı bir "aktif profil" kaydında tutulur (`shared_preferences` ya da eşdeğeri). Yerel DB **ağ olmadan** onunla açılır. Yenileme token'ı yine güvenli depodadır; **profil kaydı yalnız `userId` taşır**.
2. **`/refresh`'in AĞ HATASI dalı, `401` dalından AYRILIR — bu ayrım pazarlıksızdır:**
   - **Ağ hatası** (bağlantı yok, timeout, DNS): istemci **çevrimdışı-yetkili** kalır ⇒ yerel DB **tam okunur/yazılır**, kuyruk çalışır, **yalnız senkron durur**. "Oturum gerekli" durumuna **GEÇİLMEZ**.
   - **Sunucu `401` / `reuse_detected`**: *o zaman* "oturum gerekli" tetiklenir.
   - v2'de bu ayrım yoktu ⇒ uçak modundaki bir kullanıcı `/refresh` başarısız olduğu için giriş ekranına atılırdı.
3. *(Çevrimdışı kullanıcının hangi **ekranı** göreceği `slice-3b`'nin işidir; `userId`'nin **nereden geldiği** bu belgenin işidir — §1 dilimi zaten "bir ŞEMA kararıdır" diye tanımlıyor.)*

**K3-L9 — WEB'DE TEK-UÇUŞLULUK SEKMELER ARASI OLMAK ZORUNDADIR. [RT-M2 kapanır]**
Yenileme çerezi origin'in **tüm sekmelerinde ortaktır**, erişim token'ı ise **sekme-yereldir** ⇒ iki sekmede eşzamanlı F5: biri `T1`'i tüketir, diğeri aynı `T1`'i sunar ⇒ **replay-idempotency penceresi bunu yakalar (K14-a sayesinde artık aile düşmez)**, ama pencere dışındaysa **aile düşer ve iki sekme birden çıkar**. Dart `Completer` mutex'i **sekme-yereldir** ve bunu çözmez.
**Karar:** web'de tek-uçuşluluk **Web Locks API** (`navigator.locks.request`) ile, ona erişilemeyen ortamlarda `BroadcastChannel` tabanlı bir kilitle kurulur. **M-L5'in web ayağı budur** ve 3b devir kaleminde açıkça yazılır.
*(Not: K14-a'nın penceresi bu kilidi **gereksiz kılmaz** — pencereyi ikinci bir savunma hattı yapar. İkisi birlikte okunur.)*

**K3-L10 — `X-Client-Kind` VE YENİLEME TOKEN'ININ TESLİM KANALI. [K14-c — bloker #6 kapanır]**
**Kırılan yer:** `/login` ve `/refresh` **tek uçtur**; native istemci **ham değer** ister, web **almamalıdır** (yoksa `HttpOnly` çerezin bütün gerekçesi düşer). v2 sunucunun bu ikisini nasıl ayırt ettiğini **hiç yazmamıştı** ⇒ en doğal builder seçimi (*"hep gövdede + web'e ayrıca `Set-Cookie`"*) **K3-L2'nin *"tek XSS yenileme token'ını okuyamaz"* gerekçesini doğrudan yalanlardı.

**Karar:**
- Her `/login`, `/refresh`, `/logout` isteği **`X-Client-Kind: web` veya `X-Client-Kind: native`** başlığı taşır. Başlık **yoksa veya tanınmıyorsa** istek `400` alır — *"varsayılana düş"* yolu **yoktur** (sessiz varsayılan tam olarak bu belgenin karşı olduğu şeydir).
- **PAZARLIKSIZ İKİ KURAL:**
  1. `X-Client-Kind: web` ⇒ yenileme token'ı **yalnız `Set-Cookie`** ile gider; **yanıt gövdesinde HİÇ görünmez** (ne alan olarak, ne de başka adla).
  2. `X-Client-Kind: native` ⇒ yenileme token'ı **yalnız yanıt gövdesinde** gider; **çerez HİÇ set edilmez**.
- **Kapı: M28** — mutasyon: web modunda yenileme token'ı gövdeye de eklenir. Kill sinyali: *"`X-Client-Kind: web` ile gelen `/login` yanıtının gövdesi yenileme token'ını **hiçbir alanda** içermez"* **FAIL**. *(Test, gövdeyi ham dize olarak tarar; alan adına güvenmez.)*
- **`/logout`'un girdisi:** JWT'nin **`fid`** talebi (K3-C1). ⇒ çerez/gövde bağımlılığı yoktur, K11-d'nin *"yalnız o aile"* semantiği korunur ve v2'nin **"hangi aile iptal edilecek hesaplanamıyor"** çıkmazı kapanır.

*Reddedilenler:* ayrı alt yollar `/v1/auth/web/*` (uç sayısı ikiye katlanır, OpenAPI kontrat kapısı ve test yüzeyi büyür) · her platformda çerez (K3-L1 düşer, mobilde çerez kalıcılığı platform başına kırılgandır ve *"yenileme token'ı Keystore/Keychain'de"* vitrini kaybolur).

### M. PORT ENVANTERİ VE KATMAN YERLEŞİMİ [Ma-6 kapanır — YENİ BÖLÜM]

v2'de *"JWT'yi kim üretir, `Microsoft.IdentityModel.Tokens` nerede referanslanır, `refresh_tokens` ham SQL'i hangi portun arkasında, `ICurrentUser` implementasyonu nerede"* soruları **yazılmamıştı** ⇒ K9'un *"paket değişimi tek sınıfı etkiler"* ilkesi kimliğin yarısında **geçersiz** kalıyordu.

| iş | port (Application) | implementasyon | 3. parti tip nerede görünür | NetArchTest kuralı |
|---|---|---|---|---|
| Parola hash/verify | `IPasswordHasher` | Infrastructure | `Konscious.*` **yalnız** Infrastructure | `Konscious.*` Domain/Application/Api'de **görünmez** (**M32**) |
| JWT üretimi | `IAccessTokenIssuer` | Infrastructure | `Microsoft.IdentityModel.*` **yalnız** Infrastructure | `Microsoft.IdentityModel.*` Domain/Application'da **görünmez** |
| JWT doğrulama | *(port yok — çerçeve middleware'i)* | Api (`AddJwtBearer`) | Api | — |
| Yenileme token'ı üretimi + hash | `IRefreshTokenService` | Infrastructure | `System.Security.Cryptography` | — |
| `refresh_tokens` kalıcılığı (ham SQL) | `IRefreshTokenStore` | Infrastructure | `Npgsql`/`Dapper` **yalnız** Infrastructure | mevcut K-A1 ailesi |
| CSRF token imzalama | `ICsrfTokenService` | Infrastructure | `System.Security.Cryptography` | — |
| Kimlik taşıma | `ICurrentUser` | **Infrastructure** (Api değil) | `Microsoft.AspNetCore.Http` **yalnız** Infrastructure/Api | `Microsoft.AspNetCore.*` Domain/Application'da **görünmez** |

**`ICurrentUser` neden Api'de değil Infrastructure'da:** `HttpContext`'e bağımlıdır ve Api katmanı bu projede **ince** tutulur (0001 katman kararı); Api yalnız uçları ve DI kaydını taşır. **Bu bir tercih değil, mevcut katman kuralının sonucudur** — ve yukarıdaki NetArchTest satırı onu zorlar.

---
## 3. Isıran kapılar (KÖR KAPI YOK)

Her kapı, kaldırıldığında testi **kırdığını** mutantla kanıtlar. Bu tablo `GOREV-slice-3c-auth` spec'inin mutant listesinin **kimlik-çekirdeği yarısıdır**; diğer yarısı ADR 0004'tedir.

> **NUMARA SÖZLEŞMESİ [D3 majörü kapatılıyor]:** bu belge **M1–M39** aralığını kullanır (M2·M3·M9·M10·M20 **0004'e aittir**, burada yazılmaz; M13 **VOID**'dir). **ADR 0004'ün YENİ mutantları `M40`'tan başlar** — v2'nin *"0004 M26'dan devam eder"* varsayımı bu sürümde geçersizleşti, çünkü M26–M39 burada tüketildi. `M-L5/M-L6/M-L7` **harflidir ve numara tüketmez** (istemci tarafı, `slice-3b`).

> **TEST SEVİYESİ [D3 majörü kapatılıyor]:** v2'nin *"saf çekirdek DB'siz kanıtlanır"* iddiası tutmuyordu — canlı mutantların çoğu DB istiyor. Sütun eklendi ki **spec, hangi test altyapısının hangi mutant için gerektiğini tahmin etmek zorunda kalmasın.** Kısaltmalar: **B** = saf birim · **D** = derleme (analizör) · **TS** = `TestServer` entegrasyonu · **TC** = Testcontainers (gerçek Postgres) · **NA** = NetArchTest · **DART** = istemci birim testi (`slice-3b`).

| # | mutasyon | kill sinyali (ZORUNLU) | seviye | çıpa |
|---|---|---|---|---|
| **M1** | Yeniden-kullanım tespiti kaldırılır (tüketilmiş token kabul edilir) | *"tüketilmiş token **replay penceresi dışında** ikinci kez sunulunca **o aile** iptal olur"* **FAIL** | TC | K3-C2 |
| **M4** | `ToLowerInvariant` → kültüre-duyarlı `ToLower()` | **DERLEME KIRILIR** (BannedApiAnalyzers) · ayrıca tr-TR **zorlanmış kültür** testinde *"`I@x.com` ve `i@x.com` aynı hesaba düşer"* **FAIL** | D + TC | K3-A2 |
| **M5** | Rehash-on-login kaldırılır | *"eski parametreli hash başarılı girişten sonra güncel parametreye taşınır"* **FAIL** | TC | K3-B3 |
| **M6** | `FixedTimeEquals` → `SequenceEqual` | **DERLEME KIRILIR** (BannedApiAnalyzers) | D | K3-B4 |
| **M6b** | `FixedTimeEquals` → **`byte[] ==`** (referans karşılaştırması) | *"doğru parola ile giriş **başarılı** olur"* **FAIL** *(referans karşılaştırması her zaman `false` döner)* | B | **[D3 düzeltmesi]** `byte[] ==` BannedApiAnalyzers ile **ifade edilemez** ⇒ v2'nin M6'sının bu yarısı **yanlış sinyal taşıyordu**; davranış testine ayrıldı |
| **M7** | Bilinmeyen e-postada sahte (dummy) hash koşulmaz | *"bilinmeyen e-posta ile `/login` isteğinde `IPasswordHasher.Verify` **tam olarak 1 kez** çağrılır"* **FAIL** | TS | **YAPISAL ÖLÇÜT** — süre ölçülmez, çağrı sayılır |
| **M8a** | `Production`'da imzalama anahtarı yokken fail-fast kaldırılır | *"anahtarsız/32 bayttan kısa anahtarlı `Production` başlangıcı **patlar**"* **FAIL** | B | K3-I2 |
| **M8b** | Dev bootstrap'ın ortam koşulu kaldırılır (her ortamda anahtar üretir) | *"`Production` yolunda anahtar **üretilmez**; eksikse patlar"* **FAIL** | B | **K3-I3 — bu ayak olmadan bootstrap'ın kendisi bir açıktır** |
| **M11** | Hız sınırlayıcı (kontrol 1) tamamen kaldırılır | *"aynı IP'den **11.** `/login` denemesi `429` alır ve `problem.Extensions[\"limit\"] == \"ip\"`"* **FAIL** | TS | K3-J2(1) |
| **M12** | Yenileme token'ı DB'ye ham yazılır (hash'lenmez) | *"DB'deki `token_hash`, istemciye verilen token'ın **SHA-256 özetine EŞİTTİR** ve ham değere eşit değildir"* **FAIL** | TC | **[D3 düzeltmesi]** v2 yalnız *"eşit değil"* diyordu ⇒ Base64/ROT13 gibi herhangi bir dönüşüm de geçerdi; **SHA-256 artık pinlenmiştir** |
| **M13** | ~~Zarafet penceresi sınırı~~ | **VOID — KONUSU KALMADI** | — | Mekanizma K11-c ile kaldırıldı; **sessizce kaybolmasın diye satır duruyor** |
| **M14** | `FallbackPolicy` kaldırılır (deny-by-default kapatılır) | *"test için eklenmiş, **`[Authorize]` yazılmamış** `GET /v1/_probe/deny-default` ucu anonim erişime `401` döner"* **FAIL** | TS | **[D3 düzeltmesi]** v2 hedef ucu tanımsız bırakmıştı ⇒ builder mevcut bir ucu seçerse mutant ısırmayabilirdi. **Uç adı artık pinlidir** (yalnız test derlemesinde kayıtlı) |
| **M15** | `ICurrentUser.UserId` kimliksizken `Guid.Empty` döndürür | *"kimliksiz erişimde `UnauthenticatedException` atılır"* **FAIL** | B | K3-D1 |
| **M16** | `ClockSkew = TimeSpan.Zero` kaldırılır (varsayılan 5 dk) **veya** `ValidAlgorithms` **`HS512`'ye** genişletilir | *"süresi 1 dk önce dolmuş token `401`"* **FAIL** · *"**aynı anahtarla HS512** imzalanmış token reddedilir"* **FAIL** | TS | **[bloker #12 düzeltmesi]** `alg:none` ve RS256 ayakları **kaldırıldı** (ilkini `RequireSignedTokens`, ikincisini `SymmetricSignatureProvider` zaten kapatıyor ⇒ mutant hayatta kalırdı = kör kapı) |
| **M17** | Döndürmede yeni token'a **yeni** mutlak son kullanma verilir | **aile doğduktan sonra `FakeTimeProvider` İLERİ ALINIR**, sonra `/refresh` çağrılır: *"yeni satırın `expires_at`'i eski satırınkine **TAM EŞİTTİR**"* **FAIL** | TC | **[bloker #14 düzeltmesi]** donmuş saat altında v2'nin sinyali **yeşil kalıyordu** = kör kapı |
| **M18** | `/logout` kullanıcının **tüm** ailelerini iptal eder | *"iki cihazdan giriş: birinden `/logout`, diğerinin `/refresh`'i ÇALIŞMAYA DEVAM EDER"* **FAIL** | TC | K3-C4 |
| **M19** | `OutboxDispatcher`'ın kendi `IServiceScope`'u kaldırılıp `ICurrentUser` **doğrudan** singleton'a enjekte edilir | **DERLEME/DI DOĞRULAMASI KIRILIR** (`scoped` bağımlılık `singleton`'a enjekte edilemez; `ValidateOnBuild=true`) | D | **[D3 düzeltmesi]** v2'nin mutasyon biçimi kararsızdı (*"ya tüm suite düşer ya hiç ısırmaz"*); mutasyon artık **DI doğrulamasına** çıpalı |
| **M21** | Normalizasyondan `Trim()` **veya** NFC adımı çıkarılır | *"`\" a@x.com\"` ile `\"a@x.com\"` aynı hesaba düşer"* **FAIL** · *"NFC ayrık aksanlı e-posta birleştirilmiş hâliyle aynı hesaba düşer"* **FAIL** | TC | K3-A2 |
| **M22** | Eşzamanlılık limiti (kontrol 3) kaldırılır | **her istek FARKLI IP'den** gelir (kontrol 1 tetiklenmez) **ve** `IPasswordHasher` **bloke eden sahte** implementasyondur (test kontrollü semafor): *"limitin üstündeki eşzamanlı `/login` `429` alır, `problem.Extensions[\"limit\"] == \"concurrency\"` ve **Argon2 KOŞMAZ**"* **FAIL** | TS | **[bloker #13 düzeltmesi]** v2'de test kendi istekleriyle **önce IP penceresini** dolduruyordu ⇒ mutant uygulandığında da ret geliyordu = **kör kapı**; ters yönde hızlı sahte hasher'la limit hiç dolmuyordu = **ölü tuzak** |
| **M23** | IP partition'ı kaldırılır, yalnız e-posta partition'ı bırakılır | *"her istekte FARKLI rastgele e-posta ile gelen **11.** istek de `429` ve `limit == \"ip\"`"* **FAIL** | TS | **R2'nin tam kapısı** |
| **M24** | `ICurrentUser` `"sub"` yerine `ClaimTypes.NameIdentifier` okur | *"`MapInboundClaims=false` altında geçerli token ile korumalı uç `200` döner"* **FAIL** | TS | K3-C7'nin ölçülmüş yan etkisi |
| **M25** | Double-submit CSRF doğrulaması **tamamen** kaldırılır | *"geçerli yenileme çerezi + **EKSİK** `X-CSRF-Token` ile `/refresh` reddedilir"* **FAIL** | TS | K3-L3(3) |
| **M26** | `/refresh` yükleminden **`revoked_at IS NULL`** çıkarılır | *"`/logout` sonrası aynı yenileme token'ı ile `/refresh` **`401`** alır"* **FAIL** | TC | **[bloker #2]** bu ayak olmadan **`/logout` fiilen no-op'tur** ve M18 yine de yeşil kalır |
| **M27** | `/refresh` yükleminden **`expires_at > @now`** çıkarılır | `FakeTimeProvider` **31 gün ileri alınır**: *"süresi geçmiş yenileme token'ı `401` alır ve **aile iptal edilmez**"* **FAIL** | TC | **[bloker #2]** mutlak 30 gün ömrün tek zorlayıcısı |
| **M28** | Web modunda yenileme token'ı yanıt gövdesine **de** eklenir | *"`X-Client-Kind: web` ile gelen `/login` ve `/refresh` yanıtlarının **ham gövde metni** yenileme token'ının değerini **içermez**"* **FAIL** | TS | **[bloker #6]** test alan adına güvenmez, gövdeyi dize olarak tarar |
| **M29** | Replay-idempotency penceresi **sınırsızlaştırılır** (`consumed_at + 60 sn` koşulu kaldırılır) | `FakeTimeProvider` **61 sn ileri alınır**: *"tüketilmiş token yeniden sunulunca **aile iptal olur**"* **FAIL** | TC | **[K14-a]** pencerenin v1'in zarafet penceresine dönüşmesini engelleyen kapı |
| **M30** | Replay-idempotency'den **"halef tüketilmemiş olmalı"** koşulu kaldırılır | *"halef **kullanıldıktan sonra** eski token yeniden sunulursa **aile iptal olur**"* **FAIL** | TC | **[K14-a]** gerçek hırsızlık sinyalini koruyan kapı |
| **M31** | Parola asgari/azami uzunluk doğrulaması kaldırılır | *"`\"a\"` parolasıyla `/register` **`400`** alır"* **FAIL** · *"129 karakterlik parola **`400`** alır ve **Argon2 KOŞMAZ**"* **FAIL** | TS | **[bloker #11]** K3-B6 |
| **M32** | `Application` katmanındaki bir sınıfa `Konscious.Security.Cryptography` referansı eklenir | *"`Konscious.*` tipleri Domain/Application/Api'de **görünmez**"* NetArchTest kuralı **FAIL** | NA | **[bloker #15]** 0001 K-H1 birebir: *"**Her** kural commit'li negatif/mutant testle ısırdığını kanıtlar"* — v2 bunu ihlal ediyordu |
| **M33** | `UseStaticFiles` auth middleware'inden **sonraya** alınır **veya** fallback ucundan `AllowAnonymous` kaldırılır | *"kimliksiz `GET /` ve `GET /tasks` **`200`** döner ve `index.html` gövdesi gelir"* **FAIL** | TS | **[bloker #3 / K14-e]** |
| **M34** | PHC ayrıştırıcısının savunmacı dalı kaldırılır (bozuk format istisna atar) | DB'ye elle bozuk `password_hash` yazılır: *"`/login` **`401`** döner (`500` DEĞİL) ve gövde bilinen/bilinmeyen e-posta ile **aynıdır**"* **FAIL** | TC | **[Ma-4]** K3-B5'in tek-tip yanıt garantisinin kapısı |
| **M35** | CSRF token'ının **HMAC doğrulaması** kaldırılır (yalnız çerez == başlık karşılaştırılır) | *"**geçerli biçimli ama İMZASIZ/YANLIŞ İMZALI** bir CSRF değeri hem çerezde hem başlıkta gönderilirse `/refresh` **reddedilir**"* **FAIL** | TS | **[bloker #4]** v2'nin M25'i naif implementasyonda da **yeşil geçerdi** = kör kapı |
| **M36** | Çerezlerden **`__Host-`** öneki kaldırılır (veya `Domain` özniteliği eklenir) | *"`Set-Cookie` başlıkları **`__Host-`** ile başlar ve **`Domain=` içermez**"* **FAIL** | TS | **[bloker #4]** kardeş alt alan adının çerez yazmasını yapısal olarak engelleyen ayak |
| **M37** | `/login`'in bilinmeyen-e-posta dalı farklı bir gövde/kod döndürür | *"bilinmeyen e-posta + yanlış parola ile mevcut e-posta + yanlış parolanın yanıtları **bayt bayt aynıdır**"* **FAIL** | TS | **[D3]** K3-B5'in *"aynı yanıt"* ayağı v2'de **kapısızdı** |
| **M38** | `family_id` her `/login`'de yeniden üretilmez (kullanıcı başına sabit) | *"aynı kullanıcının iki ardışık `/login`'i **FARKLI** `family_id` üretir"* **FAIL** | TC | **[D3]** K3-C3'ün doğum anı v2'de yalnız **tesadüfen** kapsanıyordu; M18 ayırt edici değildi |
| **M39** | Atomik `UPDATE` yerine check-then-act (`SELECT` sonra `UPDATE`) yazılır | **gerçek Postgres'te paralel** iki `/refresh` aynı `T1` ile: *"**tam olarak biri** `200`, diğeri `401`+`reuse_detected`; ikisi birden `200` alırsa"* **FAIL** | TC | **[D3]** v2 atomikliği **iddia ediyor ama test etmiyordu**; emsal 0002 K2-H12 |

**ADR 0004'e ait mutantlar (burada YAZILMAZ, kaybolmasın diye adlandırılır):** M2 (`ActorId` ile yetki) · M3 (EF global filtre) · M9 (`client_id ↔ user_id`) · M10 (`IgnoreQueryFilters` allowlist dışı) · M20 (sahiplik TOCTOU) · **pull-authz mutantı** · **imleç opaklığı mutantı** · **D-7'nin zorlama mutantı**. **0004'ün yeni numaraları `M40`'tan başlar.**

**`slice-3b`'ye DEVREDİLEN mutantlar [bloker #9 kapanır — v2'de bunlar ne kapılıydı ne devirliydi]:**

| # | mutasyon | kill sinyali | seviye |
|---|---|---|---|
| **M-L5** | İstemcideki tek-uçuşlu kilit kaldırılır | *"eşzamanlı N adet 401 karşısında `/refresh` **TAM OLARAK 1 kez** çağrılır"* **FAIL** · **web ayağı:** *"iki sekmede eşzamanlı yenilemede `/refresh` tam olarak 1 kez çağrılır"* **FAIL** (Web Locks, K3-L9) | DART |
| **M-L6** | 401'de gönderilmemiş kuyruk temizlenir | *"gönderilmemiş op'lar diskte kalır ve yeniden girişte gönderilir"* **FAIL** | DART |
| **M-L7** | Kullanıcı-başına DB dosyasından tek DB dosyasına dönülür | *"A çıkıp B girince A'nın görevleri okunamaz **VE** A yeniden girince kuyruğu duruyor"* **FAIL** | DART |
| **M-L8** | Ağ hatası dalı `401` dalıyla birleştirilir | *"ağ hatasında istemci **çevrimdışı-yetkili** kalır; 'oturum gerekli'ye GEÇMEZ"* **FAIL** | DART |

> **Ölçüt, belgenin kendi emsalidir:** 0004'e giden her mekanizma *"kaybolmasın diye adlandırılmış"*tı; 3b'ye giden **hiçbiri** adlandırılmamıştı. **Asimetri belgenin kendi standardıydı ⇒ ihlaldi ⇒ kapatıldı.**

> **KURAL [K6/K13-a'ya TABİ DEĞİL]:** her mutant **gerçekten koşulur**; *"beklenir"* diye akıl yürütmeyle KANIT yazılmaz (slice-2b1 BULGU-1 dersi). Bir mutant baseline'da **kırmızı doğuyorsa** o bir **ölü tuzaktır** ve **mekanizma tartışılır**, test gevşetilmez (M1/M7 dersi). Bir mutant uygulandığında test **yeşil kalıyorsa** o bir **kör kapıdır** ve **bloker'dır** (v2 denetiminin taksonomisi).

### 3.1 — MUTANTSIZ OLDUĞU AÇIKÇA YAZILANLAR [DÜRÜSTLÜK BEYANI — YENİ BÖLÜM]

v2'de bir dizi karar **sessizce kapısız** kaldı; denetim bunu *"tamlık iddiası taşıyan bir tabloda sessiz boşluk"* diye bulguladı. Aşağıdakiler **bilinçli olarak mutantsızdır** ve gerekçesi yazılmıştır. **Bu liste, tablonun tamlık iddiasının sınırıdır.**

| kapısız kalan | neden mutant yazılmadı |
|---|---|
| **K3-C7'nin `iss`/`aud`/`RequireSignedTokens`/`RequireExpirationTime` satırları** | Çerçevenin kendi doğrulamasıdır; mutasyonu çerçeveyi mutasyona uğratmak olurdu. `ClockSkew` ve `alg` **istisnadır** çünkü ikisi de **sessiz varsayılanı** değiştirir (M16). |
| **K3-C4'ün ≤15 dk sınırı** | Bir **beyandır**, bir mekanizma değil. Mekanizması `exp`'tir ve onu M16 ısırır. |
| **K3-C8 `security_stamp`** | **Ölü alandır** (K14-d) — ölü bir alanın mutantı da ölü olurdu. Canlandırılırsa mutant **zorunlu** olur. |
| **K3-A3 `/register` sayım oracle'ı** | **Adlandırılmış sapmadır**; mutantı *"sapmayı geri al"* olurdu ve bu bir kapı değil bir karar değişimidir. |
| **K3-L1/L2'nin platform seçimi** | İstemci tarafıdır ve paket seçimidir; kapısı `slice-3b`'nin lisans+CVE kapısıdır (kırmızı çizgi 3). |
| **K3-J4'ün `Retry-After` ayağı** | Lease'in `MetadataName.RetryAfter` taşıyıp taşımadığı **[DOĞRULANMADI]**; ölçülmeden kapı yazmak bu belgenin doktrinine aykırıdır. **Spec'te ölçülür, sonra kapı yazılır.** |
| **K3-J6'nın NAT yanlış-pozitifi** | Kabul edilmiş bir bedeldir, bir mekanizma değil. |
| **K3-M port envanterinin `IAccessTokenIssuer`/`IRefreshTokenStore`/`ICsrfTokenService` satırları** | NetArchTest kuralları **mevcut K-A1 ailesinin** doğrudan uzantısıdır ve o aile zaten mutantlıdır; **yalnız `Konscious.*` kuralı yenidir ve M32 ile ısırtılır.** |

---
## 4. Gerekçe

**Bu belgenin değeri "kimlik doğrulama eklendi"de değil, üç yerdedir.**

**Birincisi: token modeli kanıtlanabilirlik için seçildi, konfor için değil.** Stateless bir yenileme JWT'si iptal edilemez — dolayısıyla üzerine **ısıran bir kapı kurulamaz**. Opak + DB + döndürme + yeniden-kullanım tespiti ise **ölçülebilir bir davranıştır**: mutantla kırılır, testle yakalanır. v1'in **zarafet penceresi** tam da bu ölçütten düştü: mekanizmanın kendisi kapıyı **yapısal olarak erişilemez** kılıyordu. Cevap testi gevşetmek değil, **mekanizmayı kaldırmak** oldu.

**İkincisi: parola tarafında asıl mimari iş paket seçimi değil, paketin İZOLASYONUDUR.** Kapı, **aktif bakımlı** adayın (NSec/libsodium) hedef platformda OWASP parametreleriyle **koşamadığını**, **~25 aydır dormant** adayın (Konscious) koştuğunu ölçtü — yani *"en iyi bakılanı seç"* sezgisi bu vakada **yanlış paketi seçerdi**. Buna verilen cevap paketi savunmak değil; `IPasswordHasher` portu + kendini tarif eden hash string'i + rehash-on-login ile **paketi yarın değiştirilebilir kılmaktır**.

**Üçüncüsü — v3'ün eklediği ders: BİR MEKANİZMANIN "DOĞRU" OLMASI, KENDİSİNE YÜKLENEN GÖREVİ YAPABİLDİĞİ ANLAMINA GELMEZ.**
v2 tek-uçuşlu refresh'i doğru tarif etti, doğru gerekçelendirdi, doğru yere koydu — ve sonra ona **yapısal olarak yapamayacağı bir görev yükledi**: *"meşru istemcinin kendini hırsız ilan ettirmemesi bu mekanizmaya bağlıdır."* Tek-uçuşluluk eşzamanlılığı çözer; **kaybolan yanıtı çözmez.** Aradaki fark bir uygulama hatası değil, bir **kategori hatasıdır** ve ancak *"bu mekanizma tam olarak hangi girdi uzayını kapsıyor"* diye sorulduğunda görünür.
**Aynı hata sınıfı bu belgede beş kez daha bulundu:** `FallbackPolicy` deny-by-default'u kurar ama **statik dosyaları da vurur** · `SameSite=Strict` çapraz-site CSRF'ini kapatır ama **kardeş alt alan adını kapatmaz** · naif double-submit token'ı doğrular ama **çerezi kimin yazdığını doğrulamaz** · `ValidAlgorithms` pinlemesi algoritma seçer ama **`alg:none`'ı `RequireSignedTokens` kapatır** · `revoked_at` kolonu iptali **kaydeder** ama `/refresh` yüklemi ona **bakmaz**.
**Bir ADR'nin işi mekanizmayı adlandırmak değil, KAPSAMINI yazmaktır.** v2'nin manşet tezi *"sessiz varsayılanların hangisinin kabul edildiğini yaz"*dı; v3 onu genişletiyor: **"ve her mekanizmanın neyi kapsamadığını da yaz."**

**Türkçe locale kararı (K3-A2) bu projeye özgü ve ÖLÇÜLMÜŞ bir risktir:** aynı makinede aynı locale Postgres `initdb`'yi zaten kırdı. Kültüre-duyarlı bir `ToLower()` çağrısı, testlerini invariant kültürde koşan bir CI'da **asla görünmeyecek** bir kimlik hatası üretirdi. Aynı tuzağın frontend ucu (Dart `toUpperCase()`) K10'da bağımsız olarak bulundu.

## 5. Alternatifler

| Eksen | Seçilen | Reddedilen (gerekçe) |
|---|---|---|
| Kimlik altyapısı | Elle ince implementasyon | ASP.NET Core Identity (katman baskısı, kullanılmayan 5 tablo, **kendi kapını gevşetme**) |
| Parola KDF | Argon2id (Konscious 1.3.1, izole) | Isopoh (**lisans belirsiz**) · NSec-libsodium (**OWASP parametrelerinde koşmadı**) · PBKDF2 (K8-c yedeği) |
| **Parola politikası** | **NIST SP 800-63B: ≥10, karmaşıklık YOK, ≤128** | Kapsam dışı ilan etmek (**Argon2 DoS tavanı açık kalır**) · klasik kompozisyon kuralları (NIST/OWASP önermiyor; tahmin edilebilir kalıplara iter) |
| Yenileme token'ı | Opak + DB + döndürme + reuse-detection | Stateless JWT-refresh (iptal edilemez) · tek uzun ömürlü JWT (çevrimdışı kuyruk kaybı) |
| **Kayıp yanıt telafisi** | **Sınırlı replay-idempotency (60 sn, halef tüketilmemiş)** | **Telafisiz adlandırılmış sınır** (RFC 9700 bunu maliyet sayar ama uçak modu demosunun ortasında yeniden giriş üretir) · **`Idempotency-Key`** (yeni tablo + TTL + temizleme; aynı sonuç, daha geniş yüzey) · **v1'in zarafet penceresi** (sonsuz zincir, K3-C6'daki tabloya bkz.) |
| JWT imzası | HS256 (simetrik) | ES256 (tek servis topolojisinde karşılıksız anahtar dağıtımı) |
| Yenileme yarışı | Sunucuda saf reuse-detection + **sınırlı replay** + istemcide tek-uçuşlu refresh | Katı tek-kullanım + istemci çözümü yok (meşru istemciyi hırsız ilan eder) |
| `family_id` kapsamı | Giriş başına (cihaz/oturum) | Kullanıcı başına tek aile (çok-cihaz demosu bozulur) |
| E-posta eşsizliği | `Trim` → NFC → `ToLowerInvariant` + `COLLATE "C"` | `ToLower()` (tr-TR'de İ/ı) · `citext` (Postgres'e kilitler) · normalizasyonsuz |
| `/register` sayım oracle'ı | Adlandırılmış sapma + beyan | Her durumda `202` · yalnız rate-limit |
| Kaba kuvvet | IP penceresi (middleware) + e-posta penceresi (**handler**) + eşzamanlılık limiti | Tek birleşik "IP+e-posta" anahtarı (**R2**) · **e-posta anahtarını başlıktan almak** (anahtarı istemci seçer) · hesap kilitleme (kurbanı kilitleten DoS) |
| **Dağıtım topolojisi** | **Tek konteyner; API statik dosyaları servis eder** | **Reverse-proxy** (`ForwardedHeaders` + `KnownProxies` zorunlu; M11/M23 `X-Forwarded-For` testlerine taşınmalı) · ikisini birden desteklemek (kapı yükü ×2) · çapraz origin + `SameSite=None` |
| **İmzalama anahtarı bootstrap'ı** | **Compose ilk açılışta rastgele üretir (yalnız Development)** | `.env.example` + README adımı (tek komut yetmez) · repoda DEV-ONLY sabit anahtar (kırmızı çizgi #1) |
| **Token teslim kanalı** | **`X-Client-Kind` başlığı + JWT'ye `fid`** | Ayrı alt yollar (uç sayısı ×2) · her platformda çerez (K3-L1 düşer) |
| **CSRF ikinci hattı** | **`__Host-` + HMAC'li, aileye bağlı double-submit** | **Naif double-submit** (OWASP: *"reference only"*; kardeş alt alan adı çerez yazar) · CSRF'i tamamen kaldırmak (`Strict` alt alan adını kapatmıyor) |
| Token deposu (web) | `HttpOnly` çerez (yenileme) + bellek (erişim) | `localStorage`/IndexedDB (tek XSS sızdırır) · yalnız bellek (F5 = çıkış) |
| Çıkışta yerel veri | Kullanıcı-başına DB dosyası, silme YOK | Tek DB + çıkışta silme (kuyrukta veri kaybı; kırmızı çizgi 4) |
| **`security_stamp`** | **Ölü alan, beyan edilmiş** | Canlandırma (istek başına 1 DB okuması + K3-K3'ün kapsam kararını sessizce geri alır) · tamamen kaldırma (ileriye kanca kalmaz) |

## 6. Riskler / açık noktalar

1. **`Konscious` ~25 ay hareketsiz** — adlandırılmış risk (K3-B1). Telafi **kapatma değil izolasyon**. **Tetikleyici:** CVE düşerse PBKDF2'ye geçiş **tek sınıflık** iştir.
2. **`/register` sayım oracle'ı** — **adlandırılmış sapma** (K3-A3). `KANIT` ve README'de beyan edilir. *"Sonra düzeltiriz" değil, "bilerek buradayız" kalemidir.*
3. **Erişim token'ı anlık iptal edilemez** (≤15 dk pencere) — beyan edilmiş sınır (K3-C4). **`security_stamp` bu pencereyi sıfırlayabilirdi ve bilinçli olarak KULLANILMIYOR** (K3-C8/K14-d). `ClockSkew=0` sayesinde pencere gerçekten 15 dk'dır, 20 değil.
4. **Argon2id 270 ms + 19 MiB / istek** — gerçek maliyet; sahte hash (K3-B5) bunu bilinmeyen e-postalarda **da** ödetir. Maliyeti sınırlayan **IP penceresi + eşzamanlılık limitidir**; e-posta penceresi buna **hiçbir şey katmaz**. Kalan yüzey: **botnet/proxy havuzu** — tek IP penceresi onu durdurmaz; eşzamanlılık limiti hizmeti ayakta tutar ama **gecikme artar**. Tek-instance bir ödev dağıtımında **kabul edilen ve beyan edilen** sınır.
5. **~~Rate limiter partition belleği~~ → ✅ KAPANDI** (K3-J5, ölçüldü: 10 sn atıl temizleme). **Kalan doğru ifade:** tavan ≈ istek hızı × 10 sn, ve tavanı anlamlı kılan şey IP penceresidir.
6. **RateLimiter'ın çok-instance davranışı** — bellek-içi sayaç **tek instance'a** özgüdür. Tek-instance dağıtımda sorun değil; K3-K3'te kapsam dışı.
7. **Web dağıtım topolojisi KİLİTLİ: tek konteyner, aynı origin, proxy yok** (K3-L4 / K14-e). **Kalan yüzeyler adlandırıldı:** (a) `SameSite=Strict` **kardeş alt alan adlarını** kapsamaz ⇒ K3-L3'ün imzalı ikinci hattı durur · (b) **`Secure` çerez `http://localhost` dışında set edilmez** ⇒ teslim paketi ve README `localhost` kullanımını **zorunlu** kılar (RT-M1) · (c) aynı-origin kararı **teslim paketini bağlar**: web build'i API ile birlikte servis edilmelidir (CI/CD ve paketleme adımında görünür gereksinim).
8. **`slice-3b` bağımlılığı:** `flutter_secure_storage`'ın **lisansı ölçüldü (BSD-3-Clause, izinli aile)**; **CVE ayağı 3b'de koşar** ve düşerse K3-L1 yeniden açılır. **Windows şifreleme yöntemi `[DOĞRULANMADI]`** — v2'nin DPAPI iddiası geri çekildi.
9. **Parola değiştirme yok** (K3-K3) ⇒ `/logout-all`'ın en doğal tetikleyicisi de yok. Uç yine de vardır ve testlidir (M18). **Fazladan yüzey olduğu kabul edilir**, gizlenmez.
10. **[YENİ — RT-M5] Aynı-origin kararının XSS SONUCU, adlandırılıyor:** `HttpOnly` çerez, XSS'in yenileme token'ını **okumasını** engeller — ama **kullanmasını engellemez.** Sayfa açıkken enjekte edilmiş bir betik `/refresh`'i çağırabilir (çerez otomatik gider, CSRF çerezi JS'e **okunabilir** olmak zorundadır) ve **her 15 dk'da bir taze erişim token'ı** elde edebilir. **`HttpOnly`'nin satın aldığı şey gerçektir ama sınırlıdır: token *dışarı sızdırılamaz*, ama *sayfa açıkken kullanılabilir*.** Kapatmanın yolu XSS'i hiç doğurmamaktır (CSP + Flutter web'in DOM'a ham HTML yazmaması); bu `slice-3b`'nin işidir ve orada adlandırılacaktır.
11. **[YENİ — K14-a'nın kabul edilmiş bedeli]** Replay-idempotency penceresi, çalınmış bir token için reuse-detection'ı **kaldırmaz ama 60 saniye geciktirir** (K3-C6(3)'ün dürüst muhasebesi). Pencere süresi **K14-i kapsamındadır: Cowork önerdi, Onur itiraz etmedi — bir Onur kilidi DEĞİLDİR ve kilit turunda gözden geçirilebilir.**
12. **[YENİ — DOĞRULANMADI]** `ConcurrencyLease`'in `MetadataName.RetryAfter` taşıyıp taşımadığı ölçülmedi ⇒ K3-J4'ün `Retry-After` ayağı **koşullu** yazıldı ve **kapısı yoktur** (§3.1). Spec aşamasında ölçülür.

## 7. İlgili

- **Öncül:** ADR 0001 (K-C1 `ownerId`, K-C5 `TimeProvider`, **K-D5**, K-E1 UUIDv7, **K-H1 banned-API + NetArchTest — "Her kural mutantla ısırdığını kanıtlar"**, K-H2 lisans ailesi) · ADR 0002 (**K2-E3** pull/push authz, K2-E5 op-başına txn + kısmi red, K2-A4 `sync_client_clock`, **K2-H12** paralel yarış testi emsali, §6/7 **M-C**).
- **⚠ BORÇ DURUMU — BEŞ BORÇ, bu belge tek başına HİÇBİRİNİ KAPATMAZ:**

| borç | bu belgede | ADR 0004'te | durum |
|---|---|---|---|
| **K-D5** `ICurrentUser` + owner filtre | sözleşme + impl (§2-D) + **port yerleşimi (§2-M)** | **global query filter** | 🟡 yarısı |
| **M-G** push-authz | — | tamamı | 🔴 açık |
| **K2-E3** pull-authz | — | tamamı + **eksik mutantı** | 🔴 açık |
| **M-C** `clientId → principal` | — | tamamı (**D-6 + D-7**) | 🔴 açık |
| **B4** `outbox_messages.owner_id` | — | tamamı | 🔴 açık |

- **ADR 0004'e DEVREDİLEN, KAYBOLMASIN DİYE ADLANDIRILAN İŞLER:**
  - **D-1** SignalR hub kimliği (K11-a) + **özel `IUserIdProvider` ZORUNLU** (K3-C7'nin ölçülmüş yan etkisi) + token'ın `?access_token=` query string'inden alınması.
  - **D-2** `outbox_messages.owner_id` `ICurrentUser.UserId`'den türer; ingest'te `op.ActorId ≠ token sub` ⇒ **istek reddedilir** (K11-b).
  - **D-3** Global query filter kurulurken **`User` KAPSAM DIŞI** bırakılmalıdır (K3-A4) — aksi hâlde anonim `/login` `UnauthenticatedException` alır ve **giriş fiziksel olarak kilitlenir**. Mutant zorunlu.
  - **D-4** Pull yolunun **ham SQL** olduğu ve `commit_xid`/`server_seq`'in EF'te map edilmediği ⇒ **global filtrenin oraya fiziksel olarak ERİŞEMEDİĞİ** yazılır. **Ayrı pull-authz mutantı zorunlu.**
  - **D-5** **K3-G2 düzeltmesi:** imleç yan-kanalı *"kapatılamaz"* DEĞİLDİR — `server_seq` bir `IDENTITY` kolonu olduğu için sızan şey **tam sayaçtır**. İmleç **opak/HMAC'li** döndürülür + **boş-sayfa `nextCursor` çatalı** kurulur.
  - **D-6** `sync_client_clock`'a `user_id` eklenmesi + backfill politikası.
  - **D-7 [YENİ — Ma-7 kapanır]** **`clientId → principal` ZORLAMA KURALI.** D-6 yalnız **kolonu** ekliyordu; *"bir `clientId` **başka bir principal** tarafından kullanılırsa ne olur"* sorusunun karşılığı hiçbir D maddesinde **yoktu** — yani `M-C` borcu 0004'te de yarım kapanacaktı. Kural yazılmalı (öneri: `sync_client_clock.user_id ≠ ICurrentUser.UserId` ⇒ **istek reddedilir**, cihaz kaçırma sinyali) ve **mutantı zorunlu**. Ayrıca **M20 (sahiplik TOCTOU)**'un iniş yeri 0004'te açıkça belirlenmeli.
  - **[NUMARA PİNİ]** 0004'ün yeni mutantları **`M40`'tan** başlar.
- **`slice-3b`'ye DEVREDİLEN mutantlar:** **M-L5** (tek-uçuşluluk + **web ayağı: Web Locks**, K3-L9) · **M-L6** (401'de kuyruk) · **M-L7** (kullanıcı-başına DB) · **M-L8** (ağ hatası ≠ 401, K3-L8). Ayrıca **XSS yüzeyinin CSP ayağı** (§6 Risk #10).
- **Sıradaki:** **bağımsız kapı** (architecture + red-team, **RED-TEAM EN SON**; üreten ≠ denetleyen — **bu belgeyi yazan oturum onu denetleyemez**) → **K13-a: bloker sıfırlanana kadar tur** → Onur kilidi → ayrı oturumda **ADR 0004** → **`GOREV-slice-3c-auth`** spec'i → Claude Code build → **Cowork TEMİZ OTURUMDA bağımsız doğrular**.
- **Sonra:** `slice-3b` (Flutter istemci) — §2-L'nin token/kuyruk/DB/profil kararları Drift şemasını ve depo katmanını **doğrudan** belirler.

---

*🟡 TASLAK v3 — KİLİTLİ DEĞİL. v2'nin 15 blokeri kapatıldı, dokuz çatal Onur tarafından kilitlendi (K14). **Bağımsız kapı koşmadı.** Bu ADR'yi yazan el onaylayamaz.*

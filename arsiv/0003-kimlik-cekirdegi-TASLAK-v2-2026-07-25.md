# ADR 0003 — Kimlik Çekirdeği (`slice-3a-auth`, 1/2)

- **Durum:** 🟡 **TASLAK v2 — KİLİTLİ DEĞİL.** İkinci ve **SON** bağımsız kapı (architecture + red-team) **henüz koşmadı** (K6 tavanı: bu ADR'nin bir turu v1'de harcandı). *Üreten ≠ denetleyen: bu ADR'yi yazan el onu onaylayamaz.* Kilit Onur'dadır.
- **Tarih:** 2026-07-25 (v2) · v1: 2026-07-25, arşiv: `arsiv/0003-kimlik-ve-yetkilendirme-TASLAK-v1-2026-07-25.md`
- **Karar verenler:** Onur (sahip) · Cowork (mimar) · bağımsız denetçi ajanlar (kapı bekliyor)
- **Kapsam (K11-h ile DARALTILDI):** kullanıcı varlığı · parola · token yaşam döngüsü · token doğrulama parametreleri · `ICurrentUser` sözleşmesi · sırlar · kimlik uçları + kaba kuvvet · **istemci token/kuyruk sözleşmesi**.
- **Kapsam DIŞI (ADR 0004'e taşındı):** owner EF global query filter + `IgnoreQueryFilters` yasağı · push-authz · pull-authz · `outbox_messages.owner_id` · SignalR hub kimliği · `clientId → principal`.
- **Bağımlılık:** ADR 0001 (§C, §D, §G, §H) · ADR 0002 (K2-E3, K2-E5, K2-A4, §6/7). Saf çekirdek (hash, token üretimi, normalizasyon, doğrulama parametreleri) **DB'siz** kanıtlanır; kalıcılık ayağı Postgres ister (Testcontainers).

> **Onur'un kilitlediği fork'lar:** K8-a tam aktivasyon (dilim düzeyinde; belge düzeyinde 0003+0004) · K8-b token modeli · K8-c Argon2id (kapı koşuldu, GEÇTİ) · K8-d Identity elemesi · K9 hash izolasyonu · **K11-c** zarafet penceresi KALDIRILDI · **K11-d** `family_id` = giriş başına · **K11-e** `/register` sayımı adlandırılmış kabul · **K11-f/g** istemci sözleşmesi · **K11-h** ADR bölünmesi.
>
> **AÇIK ÇATAL KALMADI.** v2 yazılırken bulunan tek çatal (**K3-L4** — web dağıtım topolojisi) **Onur tarafından 25 Tem 2026'da kilitlendi: AYNI ORIGIN.** Gerekçe ve reddedilenler §2-L'de.

---

## 0. v1 → v2 değişim kaydı (denetim izi)

v1'e bağımsız kapı **BİR TUR** koştu ve hüküm **KİLİTLENEMEZ** oldu: **9 bloker · 22 majör · 9 minör · 9 eksik mutant** (iki bağımsız denetçi). v2 bunların kimlik-çekirdeğine düşen kısmını kapatır.

| v1 bulgusu | v2'de ne oldu |
|---|---|
| **R1** zarafet penceresi ⇒ sonsuz zarafet zinciri, reuse-detection'a yapısal erişilemezlik | **KALDIRILDI** (K11-c). Yarış istemcide tek-uçuşlu refresh ile çözülür → K3-C5/C6, K3-L5 |
| **R2** hız sınırlama partition'ını saldırgan seçiyor; Risk #5'in telafi iddiası yanlış | **DÜZELTİLDİ** → K3-J2/J3/J4; Risk #5 metni de düzeltildi (§6) |
| **R3** `/register` sayım oracle'ı + K3-B5'in "PAZARLIKSIZ" iddiasının kendi içinde yanlışlanması | **ADLANDIRILMIŞ SAPMA** (K11-e) → K3-A3, K3-B5 |
| **R4** `TokenValidationParameters` hiç kararlaştırılmamış | **YENİ BÖLÜM §2-C7** — `ClockSkew=0`, `alg` pinleme, `MapInboundClaims=false` + **ölçülmüş yan etkisi** |
| **R5** `family_id` ne zaman doğuyor belirsiz; logout semantiği çelişik | **KİLİTLENDİ** (K11-d) → K3-C3/C4; v1'in *"tüm oturumlar düşer"* cümlesi **düzeltildi** |
| **R7** en tehlikeli mekanizmalar mutantsız | **M14 (deny-by-default) · M15 (`Guid.Empty`) · M16 (`ClockSkew`/`alg`)** eklendi; zarafet penceresi mutantı (M13) **konusuz kaldı → VOID** |
| **B5/R6** dilim kendini haklı çıkaran istemci sorularını cevaplamıyor | **YENİ BÖLÜM §2-L** (K11-f/g): token deposu · 401'de kuyruk · çıkışta yerel DB |
| **M1 ÖLÜ TUZAK** (baseline'da kırmızı doğuyordu) | **CANLANDI** — zarafet penceresi kalkınca baseline yeşil, mutant kırmızı olur (§3, M1) |
| **M7 pratikte ölü tuzak** (istatistiksel zamanlama eşiği ⇒ flaky ⇒ gevşetilir) | **YAPISAL ÖLÇÜTE ÇEVRİLDİ** — süre ölçmez, çağrı sayar (§3, M7) |
| **M4/M6 sinyali yanlış yazılmış** ("test FAIL" ≠ "derleme kırılır") | **DÜZELTİLDİ** — kill sinyali *derleme hatası* olarak yazıldı; davranış testi ayrıca ve ayrı isimle duruyor |
| **B1** hub kimliği · **B4** `outbox.owner_id` · **B2** `User` filtre tuzağı · **B3** pull-authz + mutantı · **G2** imleç yan-kanalı | **ADR 0004'e devredildi** — §7'de **D-1..D-6** olarak adlandırıldı, kaybolmadı |
| §7'nin *"dört borç ✓"* beyanı | **DÜZELTİLDİ: BORÇ SAYISI BEŞ** (B4 = `outbox_messages.owner_id`) ve bu belge **tek başına hiçbirini kapatmaz** — kapatan 0004'tür (§7) |

> **⚠ ETİKET EMEKLİLİĞİ [gelecek oturumların "aynı numara iki karar" hatasını önlemek için]:** v1'in **`K3-E*` (owner izolasyonu) · `K3-F*` (push-authz) · `K3-G*` (pull-authz) · `K3-H*` (`clientId→principal`)** etiketleri **BU BELGEDE EMEKLİYE AYRILDI**. ADR 0004 aynı konuları **`K4-*`** etiketleriyle yeniden yayımlayacaktır. Bir gelecek oturum `K3-E1` görürse, **v1 arşivine** bakıyordur.

---

## 1. Bağlam

Bugüne kadar Momentum'un backend'i **kimliksiz** çalıştı. Bu, iki ADR'de sessiz bırakılmadı, **adlandırıldı** — ve v1 denetimi sayımın **eksik** olduğunu ortaya çıkardı: borç **dört değil BEŞTİR**.

| pin | ertelenmiş gereksinim | kaynak (birebir) | nerede kapanır |
|---|---|---|---|
| **K-D5** | `ICurrentUser` impl + owner query-filter | `0001` §D: *"`ICurrentUser` portu (Application) slice-1'de arayüz olarak tanımlanır; implementasyonu + owner query-filter kimlik dilimiyle kodlanır."* | **sözleşme + impl: 0003 (§2-E)** · filtre: **0004** |
| **M-G** | push-authz | `0002` K2-E3: *"ingest, her op için 'actor bu entity'yi **yazabilir mi**' kontrolü yapmalı. Mekanizma auth diliminde."* | **0004** |
| **K2-E3** | pull-authz | `0002` K2-E3: *"`changes` yalnız actor'ın görebildiği entity'lerle sınırlı"* + tombstone muafiyeti | **0004** |
| **M-C** | `clientId → principal` | `0002` §6/7: *"`clientId` kimlik-doğrulaması ertelenmiş… auth diliminde aktive edilecek"* | **0004** |
| **B4 [v1 denetiminde BULUNDU]** | `outbox_messages.owner_id` doğrulanmamış | `PROJE_HAFIZA:145` AÇIK BULGU C: *"…bu dilim düzeltmez (**auth dilimi birleştirmeli**)"* | **0004** |

**Bu dilim bir özellik değil, bir ŞEMA kararıdır.** Çevrimdışı-öncelikli Flutter istemcisinde dört soru Drift şemasını ve depo katmanını belirler: *"bu yerel satır kimin"* · *"token nerede duruyor"* · *"401 gelince kuyruktaki yazımlar ne oluyor"* · *"çıkışta yerel DB'ye ne oluyor"*. **v1 yalnız birincisini karara bağlamıştı** (iki bağımsız denetçinin yakınsadığı bulgu: B5/R6); **v2 kalan üçünü §2-L'de kapatır.** `slice-3b`'den sonraya bırakmak migration + yeniden yazım demektir (K7-c).

**Ayrıca bir güvenlik yüzeyi kapanır.** Bugün `WireOp.ActorId` **istemci-beyanlıdır** ve doğrulanmış actor push yoluna hiç girmez (slice-3a denetimi, F5). Auth olmadığı için sömürülemez; **auth gelince sömürülebilir hâle gelir.** Bu belge kimliği üretir, **ADR 0004 onu yetki kararına bağlar** — ikisi birlikte kapatır, tek başına hiçbiri kapatmaz.

**Neden iki belge?** K6 tavanı bu ADR'ye **tek denetim turu** bırakıyor. Tek belgeye beş borç + hub + outbox + dokuz eksik mutant yüklemek, K6'nın *"tek devasa spec"* dersinin ADR düzeyinde tekrarı olurdu (K11-h). İki küçük belgenin her birinin tek turda geçme olasılığı, tek devasa belgeninkinden yüksektir. **Bedeli kayda geçti:** ~0,5-1 gün ek kapı yükü.

---

## 2. Karar

### A. Kimlik modeli

**K3-A1 — `User` entity, asgari PII [kırmızı çizgi #2].** Alanlar: `id` (UUIDv7, `Guid.CreateVersion7()`, K-E1) · `email` (kullanıcının yazdığı hâl, gösterim) · `email_normalized` (eşsizlik/arama anahtarı) · `password_hash` · `created_at`/`updated_at` (yalnız `TimeProvider`, K-C5) · `security_stamp`. **YOK:** ad, soyad, telefon, doğum tarihi, profil fotoğrafı, IP geçmişi, son giriş zamanı. Görev sahipliği `owner_id` çıpasıyla kurulur (K-C1); kullanıcı adı gösterimi işbirliği dilimine aittir.

**K3-A2 — Normalizasyon: `Trim` → **NFC** → `ToLowerInvariant` + `COLLATE "C"` unique index. [PAZARLIKSIZ]**
Sıra bağlayıcıdır ve üç adımın **üçü de** zorunludur:
1. **`Trim()`** — baştaki/sondaki boşluk. (v1'de yoktu; denetim **M21** olarak adlandırdı: `" a@x.com"` ile `"a@x.com"` iki hesap açardı.)
2. **Unicode NFC** (`string.Normalize(NormalizationForm.FormC)`) — birleştirilmiş vs ayrık aksan (`é` = U+00E9 vs `e`+U+0301) aynı baytlara iner. Aksi hâlde görsel olarak **aynı** iki e-posta iki ayrı hesap olur.
3. **`ToLowerInvariant()`** — ve **yalnız bu**.

> **⚠ TÜRKÇE LOCALE TUZAĞI — bu projede teorik değil, ÖLÇÜLMÜŞ bir risktir.**
> Geliştirme makinesinin sistem locale'i **tr-TR / cp1254**'tür (oturum 2 tanısı: bu locale Postgres `initdb`'yi fiilen kırdı). Türkçe kültüründe `"I".ToLower()` → **`"ı"`**, `"i".ToUpper()` → **`"İ"`**. Kültüre-duyarlı `ToLower()` kullanılırsa aynı e-posta sunucunun kültürüne göre **iki farklı** normalize değer üretir ⇒ (a) aynı adresle iki hesap açılabilir, (b) tr-TR makinede kayıt olan kullanıcı invariant makinede **giriş yapamaz**. DB tarafında unique index **`COLLATE "C"`** ile kurulur (ADR 0002'nin `COLLATE "C"` ailesiyle aynı). `string.ToLower()` · `ToUpper()` · `ToLower(CultureInfo)` · `ToUpper(CultureInfo)` · kültüre-duyarlı `string.Compare` **BannedApiAnalyzers ile derleme-zamanı yasaklanır** (K-H1'in `DateTime.UtcNow` yasağıyla aynı mekanizma). **Bu yasağın kardeşi frontend'dedir:** Dart `toUpperCase()` de Türkçe i→İ dönüşümünü yapmaz ⇒ *kültüre-duyarlı büyük/küçük harf dönüşümü hiçbir katmanda kimlik/eşleştirme yolunda kullanılmaz* (K10 yakınsaması).

**K3-A3 — Kayıt açık; sayım oracle'ı ADLANDIRILMIŞ SAPMADIR [K11-e].** `POST /v1/auth/register` herkese açıktır ve e-posta zaten kayıtlıysa **bunu söyler** (`409`, ayırt edici mesaj). *Gerekçe (açık):* e-posta doğrulama ODEV §6.1'de **kapsam dışıdır** ⇒ "her durumda 202 döndür" çözümünün kanonik ikinci ayağı (doğrulama maili) yok; kullanıcı neden giriş yapamadığını hiç öğrenemez ⇒ ODEV §2'nin *"kesinlikle çalışan uygulama"* ölçütü zedelenir. **Bu bir sapmadır, bir çözüm değil**; `KANIT`'ta ve README'de açıkça beyan edilir. *Reddedilenler:* her durumda `202` (yukarıdaki + timing için sahte hash yine gerekir) · yalnız sıkı rate-limit (oracle'ı kapatmaz, R2'nin partition sorununu `/register` yoluna taşır). **Doktrin:** beyan edilmiş sınır kabul edilir, gizlenmiş sınır edilmez.

**K3-A4 — `User` SENKRONLANABİLİR KÖK DEĞİLDİR. [ADR 0004'ü BAĞLAYAN KISIT]** `User`'ın `owner_id`'si yoktur, `/sync` telinde geçmez, tombstone'u yoktur, CRDT birleştirmesine girmez. **Sonucu 0004 için hayatidir:** owner global query filter'ı `User`'a **UYGULANAMAZ** — uygulanırsa anonim `/login` isteğinde `ICurrentUser.UserId` `UnauthenticatedException` atar ve **giriş fiziksel olarak kilitlenir** (v1 denetimi, B2). Kısıt burada tanımlanır, kapısı (**D-3**, §7) 0004'te kurulur.

### B. Parola

**K3-B1 — Hash = Argon2id, `Konscious.Security.Cryptography.Argon2` 1.3.1 [KAPI KOŞULDU, GEÇTİ].**
Parametreler **OWASP ikinci yapılandırması**: `m = 19456 KiB · t = 2 · p = 1`, 16 baytlık CSPRNG salt, 32 baytlık çıktı.
**Kapı kanıtı (Onur'un makinesinde, gerçek koşu, 25 Tem 2026):** lisans **MIT** (nuspec SPDX + GitHub `license.spdx_id`; geçişli `Blake2` 1.1.1 de MIT) · **CVE 0** (`dotnet list package --vulnerable --include-transitive`, zafiyet akışı 2026-07-24) · net9.0 build **0 uyarı 0 hata** · **fiilen çalıştı: 32 baytlık hash, 270 ms**.
**⚠ ADLANDIRILMIŞ RİSK, GİZLENMİYOR:** paket **~25 ay hareketsiz** (`pushed_at = 2024-06-18`, 20 açık issue, 3 açık PR, GitHub'da hiç release yok, arşivlenmemiş, 6.9M indirme). Bir CVE düşerse yamayı gönderecek bakımcı olmayabilir. **Telafi kapatma değil, İZOLASYONDUR → K3-B2/B3.**

**K3-B2 — `IPasswordHasher` portu [K9].** Arayüz **Application**'da, implementasyon **Infrastructure**'da. `Konscious.*` tipi Domain/Application/Api katmanlarının **hiçbirinde görünmez** — **NetArchTest kuralı** (K-A1 ailesine ek). Paket değişimi tek sınıfı etkiler.

**K3-B3 — Hash string'i kendi kendini tarif eder [K9].** Depolanan format PHC benzeri:
`$argon2id$v=19$m=19456,t=2,p=1$<b64 salt>$<b64 hash>`
Algoritma kimliği ve parametreler **satırın içindedir**. Sonucu: (a) PBKDF2'ye ya da yeni parametreye geçiş **migration değil**, tek sınıf + doğrulama yolunda dallanmadır; (b) **başarılı girişte, depolanan parametreler güncel politikadan farklıysa parola sessizce yeniden hash'lenir** (rehash-on-login) ⇒ veritabanı kendiliğinden ilerler.

**K3-B4 — Doğrulama sabit-zamanlı.** `CryptographicOperations.FixedTimeEquals`; `SequenceEqual`/`==` **banned-API** (derleme kırılır).

**K3-B5 — Kullanıcı-sayımı ve zamanlama sızıntısı: `/login` ve `/refresh` yolunda PAZARLIKSIZ, `/register`'da ADLANDIRILMIŞ SAPMA. [v1'in "her yerde PAZARLIKSIZ" iddiası DÜZELTİLDİ — R3]**
`/login`: bilinmeyen e-posta ile yanlış parola **aynı** yanıtı döndürür (`401`, tek tip ProblemDetails) **ve aynı işi yapar** — kullanıcı bulunamazsa da bir **sahte (dummy) Argon2id doğrulaması** koşulur (sabit, uygulama açılışında bir kez üretilmiş geçerli formatlı bir hash'e karşı). Aksi hâlde yanıt süresi (≈270 ms vs ≈1 ms) hesabın varlığını ele verir.
**⚠ Sahte hash'in bir MALİYETİ vardır ve bu maliyet bir DoS çarpanıdır** — telafisi K3-J2/J3/J4'tür ve v1'in bu konudaki telafi iddiası **yanlıştı** (§6, Risk #5).

### C. Token modeli [K8-b]

**K3-C1 — Erişim token'ı = kısa ömürlü JWT (~15 dk), HS256.** Talepler: `sub` (userId), `jti`, `iat`, `exp`, `sstamp` (security stamp). İmzalama anahtarı simetrik; **tek servis** topolojisinde asimetrik imza (ES256) anahtar dağıtımı getirir, karşılığında hiçbir şey kazandırmaz. *Reddedilen: ES256 · uzun ömürlü tek JWT (iptal edilemez).*

**K3-C2 — Yenileme token'ı = OPAK, DB'de, DÖNDÜRMELİ, YENİDEN-KULLANIM TESPİTLİ. [taç mekanik]**
- Değer: **256 bit CSPRNG**; istemciye ham gider, **DB'ye yalnız SHA-256 özeti** yazılır. *(Parola gibi Argon2id gerekmez: yüksek-entropili rastgele bir sır sözlük saldırısına tabi değildir — bilinçli ve gerekçeli asimetri.)*
- Ömür: **mutlak 30 gün**, `family_id` doğduğu anda sabitlenir. **Döndürme ömrü UZATMAZ** (v1 denetimi, M17): döndürmede üretilen yeni token ailenin **aynı** `expires_at`'ini devralır. Aksi hâlde 30 günlük mutlak ömür, 15 dakikada bir refresh eden bir istemcide **sonsuza** uzardı.
- Tablo: `refresh_tokens(id, user_id, token_hash, family_id, created_at, expires_at, consumed_at, replaced_by_id, revoked_at, revoked_reason)`.
- **Döndürme:** her `/refresh` sunulan token'ı `consumed_at` ile tüketir ve **aynı `family_id`** altında yenisini üretir.
- **YENİDEN-KULLANIM TESPİTİ:** `consumed_at` dolu bir token yeniden sunulursa → **o ailenin tamamı derhal iptal** (`revoked_reason = 'reuse_detected'`). Sunum: `401`. *Gerekçe:* tüketilmiş bir token'ın tekrar gelmesinin tek makul açıklaması çalınmış olmasıdır; hangi tarafın hırsız olduğunu bilemeyiz, **o oturum ailesinin ikisini de** düşürürüz.

**K3-C3 — `family_id` = GİRİŞ BAŞINA (bir cihaz/oturum) [K11-d, R5 kapanır].** Her başarılı `/login` **yeni** bir `family_id` doğurur; her `/refresh` **aynı** aileyi sürdürür. **v1'in *"o kullanıcının tüm oturumları düşer"* cümlesi YANLIŞTI ve düzeltilmiştir:** reuse tespiti **yalnız o aileyi** düşürür. *Reddedilen:* kullanıcı başına tek aile — bir cihazdaki hırsızlık şüphesi tüm cihazları düşürürdü ⇒ çok-cihaz/işbirliği demosunda kötü görünür.

**K3-C4 — Çıkış gerçektir, kapsamı AÇIKÇA YAZILIR [K11-d].** `POST /v1/auth/logout` **yalnız sunulan token'ın ailesini** iptal eder. `POST /v1/auth/logout-all` kullanıcının **tüm ailelerini** iptal eder (parola değişimi/cihaz kaybı senaryosunun cevabı; bu dilimde parola değişimi yok ama uç vardır ve testlidir). Erişim token'ı her iki durumda da **≤15 dk** daha geçerli kalır — **bilinçli ve beyan edilmiş** sınır (kara liste tutulmuyor; `sstamp` talebi ileride anlık iptale kanca bırakır).

**K3-C5 — ZARAFET PENCERESİ YOKTUR. [K11-c, R1 kapanır]** v1'de bulunan *"aynı aileden, son 10 sn içinde üretilmiş token da kabul edilir"* penceresi **KALDIRILMIŞTIR**. Sunucu tarafı **saf reuse-detection**'dır: tüketilmiş token = aile iptal, istisnasız.
*Gerekçe (denetçinin kırdığı yer):* pencerenin **yüklemi tanımsızdı**; saldırgan 5 sn'de bir `/refresh` çağırarak **sonsuz bir zarafet zinciri** kurabilir ve reuse-detection'a **yapısal olarak erişilemez** hâle getirebilirdi. Ayrıca pencere, M1 mutantını **ölü tuzağa** çeviriyordu: baseline'da bile test kırmızı doğuyor, "düzeltiliyor" ve mutant sessizce ölüyordu. Pencere kalkınca **M1 canlanır**.
*Reddedilenler:* pencereyi tutup yüklemini tanımlamak (ek sayaç + daha çok mutant + daha geniş saldırı yüzeyi) · pencere yok + istemcide de çözüm yok (401 ⇒ çıkışa atmak, çevrimdışı kuyruk vitrinini zedeler).

**K3-C6 — Tüketim ATOMİKTİR.** `UPDATE refresh_tokens SET consumed_at = @now, replaced_by_id = @new WHERE id = @id AND consumed_at IS NULL RETURNING …`. Etkilenen satır **0** ise token ya tüketilmiştir (⇒ reuse yolu) ya yoktur. Kontrol-sonra-yaz (check-then-act) **yasaktır**. **Meşru istemcinin yarışı sunucuda değil, istemcide çözülür → K3-L2 (tek-uçuşlu refresh).**

**K3-C7 — `TokenValidationParameters` AÇIKÇA YAZILIR — hiçbir varsayılana güvenilmez. [R4 kapanır]**
v1 bu ayarı hiç kararlaştırmamıştı; varsayılanlar sessizce belgeyi yalanlıyordu.

| ayar | değer | neden |
|---|---|---|
| `ValidateIssuer` / `ValidIssuer` | `true` / yapılandırmadan | — |
| `ValidateAudience` / `ValidAudience` | `true` / yapılandırmadan | — |
| `ValidateLifetime` | `true` | — |
| **`ClockSkew`** | **`TimeSpan.Zero`** | **ÖLÇÜLDÜ:** `TokenValidationParameters.DefaultClockSkew = TimeSpan.FromSeconds(300)` (IdentityModel kaynağı) ⇒ varsayılanla, **beyan edilen ≤15 dk fiilen ≤20 dk** olurdu. Belge ile davranış arasındaki bu fark tam olarak denetçinin aradığı şeydir. |
| `ValidateIssuerSigningKey` / `IssuerSigningKey` | `true` / K3-I1'den | — |
| **`ValidAlgorithms`** | **`[ "HS256" ]`** | `alg` pinlenmezse doğrulayıcı, anahtar tipiyle uyumlu **başka** bir algoritmayı kabul edebilir. Pinleme, algoritma-karıştırma sınıfını tek satırla kapatır. |
| `RequireSignedTokens` / `RequireExpirationTime` | `true` / `true` | — |
| **`MapInboundClaims`** | **`false`** | Claim tipleri ham JWT adlarıyla kalır (`sub`, `jti`, `sstamp`) — uzun WS-Federation URI'lerine çevrilmez. Belge ile kod aynı kelimeyi kullanır. |

> **⚠ `MapInboundClaims=false`'UN ÖLÇÜLMÜŞ YAN ETKİSİ — İKİ YERİ VURUR (kaynaktan doğrulandı, 25 Tem 2026):**
> `ClaimTypeMapping.InboundClaimTypeMap` birebir `{ JwtRegisteredClaimNames.Sub, ClaimTypes.NameIdentifier }` girdisini taşır; `JwtBearerOptions.MapInboundClaims` varsayılanı **`true`**'dur ve `false` yapıldığında **çeviri hiç koşmaz** ⇒ `ClaimTypes.NameIdentifier` **DOLMAZ**.
> 1. **Bu belgede:** `ICurrentUser` implementasyonu `ClaimTypes.NameIdentifier` okursa **her istekte `UnauthenticatedException`** atar ⇒ **`"sub"` doğrudan okunur** (K3-D2).
> 2. **ADR 0004'te:** `DefaultUserIdProvider.GetUserId` = `connection.User.FindFirst(ClaimTypes.NameIdentifier)?.Value` ⇒ SignalR `Context.UserIdentifier` **`null`** düşer ve `user:{id}` grubu **sessizce hiçbir istemciye ulaşmaz**. Özel `IUserIdProvider` **zorunludur** — bu bir hipotez değil, ölçümdür (**D-1**, §7).

### D. `ICurrentUser` sözleşmesi [K-D5'in sözleşme ayağı]

**K3-D1 — Şekil.** `Application` katmanında: `Guid UserId { get; }` — kimlik yoksa **`UnauthenticatedException` FIRLATIR**, `Guid.Empty` **DÖNDÜRMEZ** — ve `bool IsAuthenticated { get; }`. *Gerekçe:* `Guid.Empty` sessizce sorguya sızar ve "hiçbir şey döndürmeyen ama patlamayan" bir filtre kurar — **deny-by-default'un en sinsi ihlali**. Kimliksiz erişim **gürültülü** başarısız olur. (v1 bunu *"en sinsi ihlal"* ilan edip mutantsız bırakmıştı — **M15** eklendi.)

**K3-D2 — Implementasyon `HttpContext.User`'dan `"sub"` claim'ini okur, `scoped` ömürlüdür.** `ClaimTypes.NameIdentifier` **okunmaz** (K3-C7'nin ölçülmüş yan etkisi). Değer `Guid.TryParse` ile ayrıştırılır; ayrıştırılamazsa `UnauthenticatedException` — "bir şekilde devam et" yolu yoktur.

**K3-D3 — ⚠ ARKA PLAN SERVİSİ TUZAĞI [adlandırıldı].** `OutboxDispatcher` bir `BackgroundService`'tir (singleton) ve **`HttpContext`'i yoktur**. Bir `scoped ICurrentUser`'ı oradan çözmeye çalışmak ya çalışma-zamanı hatası ya da **daha kötüsü** sessiz yanlış kimlik üretir. **Kural:** dispatcher owner-filtreli hiçbir sorguya dokunmaz; outbox okuması **açıkça filtresizdir** — ADR 0002'nin "yayıncı Infrastructure" katman kararıyla tutarlı. *(Bu istisnanın allowlist'i ve filtre tarafı **0004**'ün işidir; burada yalnız sözleşme tarafı yazılır.)*

### I. Sırlar [kırmızı çizgi #1]

**K3-I1 — İmzalama anahtarı repoya GİRMEZ.** Geliştirmede `dotnet user-secrets`, üretimde ortam değişkeni. **Varsayılan/gömülü anahtar YOKTUR.**
**K3-I2 — Anahtar yoksa uygulama AÇILMAZ (fail-fast).** Eksik veya **32 bayttan kısa** anahtarda başlangıçta `InvalidOperationException`. *Gerekçe:* "geliştirme kolaylığı" için üretilen sessiz varsayılan anahtar üretime sızdığında **tüm kimlik sistemini geçersiz kılar**. Isıran kapı: **M8**.

### J. Uçlar + kaba kuvvet

**K3-J1 — Uçlar ve deny-by-default.** `POST /v1/auth/register` · `/login` · `/refresh` · `/logout` · `/logout-all`. İlk üçü `AllowAnonymous`; `/logout` ve `/logout-all` **kimlik ister**. **Diğer her uç deny-by-default** — `FallbackPolicy = RequireAuthenticatedUser` (K-D5). `/health/live` ve `/health/ready` anonim kalır (K-D2). *(v1 bu en geniş kontrolü mutantsız bırakmıştı — **M14** eklendi.)*

**K3-J2 — Kaba kuvvet savunması ÜÇ AYRI KONTROLDÜR ve ÜÇÜ AYRI ŞEY KORUR. [Onur kilidi + R2 düzeltmesi]**
`Microsoft.AspNetCore.RateLimiting` — **çerçevede yerleşik, yeni NuGet YOK** (kırmızı çizgi 3 tetiklenmez).

| # | kontrol | anahtar | neyi korur | neyi KORUMAZ |
|---|---|---|---|---|
| **1** | Sabit pencere — `/login`, `/refresh`, `/register` | **yalnız istemci IP'si** | **Maliyet/DoS.** Saldırganın tek IP'den açabileceği iş miktarını sınırlar. | Botnet/proxy havuzu (beyan edilir) |
| **2** | Sabit pencere — yalnız `/login` | **normalize e-posta** | **Tek hesaba parola deneme** (targeted brute force / credential stuffing). | **DoS'u KORUMAZ** — anahtarı saldırgan seçer |
| **3** | **Eşzamanlılık limiti** — parola doğrulama işi | küresel (partition yok) | **Argon2'nin bellek/CPU çarpanı.** En çok `ProcessorCount` eşzamanlı doğrulama + sınırlı kuyruk; aşımda `429`. | — |

**R2'nin kırdığı yer, aynen kayda geçiyor:** v1'in anahtarı **IP + e-posta birleşimiydi**. Saldırgan her istekte rastgele bir e-posta yazarak **her seferinde yeni bir partition** yaratır ⇒ sayaç **hiç dolmaz**, ama her istek **270 ms + 19 MiB sahte Argon2** yakar. Yani v1'in tek kontrolü hem DoS'u durdurmuyor hem de parola-püskürtmeyi hiç tetiklemiyordu. **Ayrım şudur: DoS'u durduran şey (1) ve (3)'tür; (2) hesabı korur ve bir DoS kontrolü olarak SAYILMAZ.**

**K3-J3 — Sahte (dummy) hash, limitlerin ARDINDA koşar.** Sıra bağlayıcıdır: rate limiter → eşzamanlılık limiti → (varsa) gerçek/sahte Argon2. Limit aşılmışsa **hiç Argon2 koşmaz**. Aksi hâlde K3-B5'in zamanlama savunması, kendisini bir DoS amplifikatörüne çevirirdi.

**K3-J4 — Kaba-kuvvet yanıtı da tek tiptir.** `429` + `Retry-After`; hesabın var olup olmadığını ele vermez (K3-B5 ile aynı ilke). **Hesap KİLİTLEME YOKTUR** — kilitleme, saldırganın kurbanın hesabını kasten kilitlemesine (DoS) izin verir ve K8-d ile kapsam dışıdır.

**K3-J5 — ⚠ AÇIK ÖLÇÜM [DOĞRULANMADI — spec aşamasında kaynaktan ölçülecek]:** e-posta-partition'lı limiter, **ayrık anahtar sayısı kadar** limiter nesnesi tutar; .NET'in `PartitionedRateLimiter` implementasyonunun **atıl partition temizleme** davranışı bu belgede **ölçülmemiştir**. Temizleme yoksa, rastgele e-postalarla **bellek büyümesi** ikinci bir DoS yüzeyidir. Spec'te ya kaynaktan ölçülür ya sınırlı bir anahtar kümesine (ör. hash'lenmiş + sınırlı kova) indirgenir. **Bugün iddia edilmiyor.**

### K. Elenen ve kapsam dışı [ADLANDIRILDI]

**K3-K1 — ASP.NET Core Identity KULLANILMAZ [K8-d].** *Gerekçe:* Identity, `DbContext`'i `IdentityDbContext`'e çevirir, Infrastructure tiplerini yukarı iter ve 7 tablosunun 5'i bu kapsamda kullanılmaz ⇒ **mevcut NetArchTest kapıları gevşetilir veya istisna alır. Kendi kurduğun kapıyı üçüncü parti için gevşetmek, kod kalitesi ölçen bir ödevde verilebilecek en kötü sinyaldir.** Kapsam darken (parola sıfırlama/2FA/kilitleme yok) elle implementasyon ~200-300 satırdır. *Reddedilen: melez `PasswordHasher<T>` — hash kararını fiilen PBKDF2'ye kilitlerdi.*

**K3-K2 — İLKE: KRİPTO PRİMİTİFİNİ YAZMAYIZ, AKIŞI YAZARIZ.** Argon2id, SHA-256, JWT imzası, CSPRNG — hepsi dışarıdan (paket veya BCL). Elle yazılan yalnız **akıştır**: kayıt, giriş, döndürme, yeniden-kullanım tespiti, kimlik taşıma. **Bu ADR'de hiçbir kriptografik primitif implemente edilmemektedir.**

**K3-K3 — Kapsam dışı [adlandırılmış]:** parola sıfırlama · parola **değiştirme** · e-posta doğrulama · OAuth/sosyal giriş · 2FA · RBAC/roller · hesap kilitleme · collaborator/paylaşım yetkisi (işbirliği dilimi) · anlık erişim-token'ı iptali (kara liste) · dağıtık (çok-instance) hız sınırlama sayacı.

### L. İstemci sözleşmesi [K11-f/g — v1'in cevapsız bıraktığı üç soru; B5/R6 kapanır]

> Bu bölüm backend'in **istemciye dayattığı** sözleşmedir. Flutter kodu `slice-3b`'de yazılır ama **bu kararlar Drift şemasını ve depo katmanını bugün belirler** — sonraya bırakmak migration demektir (§1).

**K3-L1 — Token deposu, native (Android/iOS/Windows): `flutter_secure_storage`.** Keystore / Keychain / DPAPI. Yenileme token'ı orada; erişim token'ı **yalnız bellekte** (uygulama yeniden açılınca refresh ile alınır). *Bağımlılık kapısı (lisans + CVE, kırmızı çizgi 3) `slice-3b` spec'inde koşulur; bu ADR paketi ONAYLAMAZ, yerini tarif eder.*

**K3-L2 — Token deposu, web: yenileme token'ı `HttpOnly` + `Secure` + **`SameSite=Strict`** ÇEREZ; erişim token'ı yalnız bellekte.** *(`Strict`'in fiilen çalışabilmesi K3-L4'ün aynı-origin kararına bağlıdır — çapraz-origin bir dağıtımda bu çerez hiç gönderilmezdi.)* Çerezi **sunucu set eder**; JavaScript'in ona erişimi yoktur ⇒ **tek bir XSS yenileme token'ını okuyamaz**. *Reddedilenler:* web'de yalnız bellek (F5 = çıkış; web demosunda göze batar) · her platformda `flutter_secure_storage` (web'de `localStorage`/IndexedDB'ye düşer ⇒ "secure" adı **yanıltıcı** olur, denetçinin bulduğu XSS yolu aynen açık kalır).

**K3-L3 — CSRF karşı önlemi: İKİ KATMAN, ROLLERİ AYRI YAZILIR.** Çerez tabanlı `/refresh` ve `/logout` **otomatik gönderilen** bir kimlikle çalışır ⇒ CSRF yüzeyi açılır.
1. **Birinci hat — `SameSite=Strict`:** klasik çapraz-site CSRF'ini kapatır (K3-L4 sayesinde fiilen çalışır).
2. **İkinci hat — double-submit token:** sunucu ayrıca **okunabilir** bir CSRF çerezi set eder; istemci onu `X-CSRF-Token` başlığında geri gönderir; sunucu ikisini karşılaştırır. **Kaldırılmaz**, çünkü `Strict` **alt alan adı** vektörünü kapatmaz (K3-L4 notu).
Bu bir **maliyettir ve kayda geçmiştir** — K11-f'in bedeli olarak zaten kabul edilmişti. **Yalnızca CORS `AllowCredentials` bedeli K3-L4 ile ortadan kalkmıştır.**

**K3-L4 — [KARAR — Onur, 25 Tem 2026] WEB DAĞITIM TOPOLOJİSİ = **AYNI ORIGIN**. [COWORK BULGUSU: K11-f'in iki bileşeni BİRBİRİYLE ÇELİŞİYORDU]**
**Bulgu:** K11-f *"`SameSite=Strict` + double-submit"* ve aynı cümlede *"CORS credentials"* diyordu. **Bu ikisi aynı anda çalışmaz:** `SameSite=Strict` (ve `Lax`) çerezi **çapraz-site** isteklerde **hiç göndermez** ⇒ Flutter web başka bir origin'den `/refresh` çağırsaydı çerez **gitmez**, web'de yenileme **hiç çalışmazdı** — ve bu, ancak canlı web demosunda fark edilirdi.

**Karar:** Flutter web build'i API ile **aynı origin**den servis edilir (API statik dosyaları verir veya ikisi tek reverse-proxy altında birleşir). Sonuçları:
- **CORS `AllowCredentials` hiç gerekmez** — çapraz-origin isteği yoktur; CORS yapılandırması ve origin allowlist yüzeyi doğmaz.
- **`SameSite=Strict` gerçekten çalışır** — çerez her `/refresh` ve `/logout` isteğinde gider.
- **Dağıtım tek birimdir** ⇒ değerlendiricinin makinesinde tek komutla ayağa kalkar (ODEV §2: *"kesinlikle çalışan bir uygulama"*).

*Reddedilenler [adlandırılmış]:* **(b) çapraz origin + `SameSite=None; Secure`** — çerez çapraz-site gider ⇒ CSRF yüzeyi genişler, CORS `AllowCredentials` + katı origin allowlist + double-submit'in **kritik** hâle gelmesi gerekir; daha gerçekçi bir üretim topolojisidir ama iki katı güvenlik yazımı ve iki katı mutant demektir · **(c) web'de çerez yok** (yenileme de yalnız bellekte) — XSS yüzeyi en dar ama **F5 = çıkış**; K11-f bunu zaten reddetmişti.

> **⚠ `SameSite=Strict` HER ŞEYİ KAPATMAZ — K3-L3 bu yüzden DURUYOR.** "Same-site" ≠ "same-origin": **kardeş bir alt alan adı** (ör. ele geçirilmiş bir `*.example.com`) tarayıcı için hâlâ same-site'tır ve ondan gelen istek çerezi **taşır**. Aynı-origin dağıtım klasik çapraz-site CSRF'ini kapatır; **alt alan adı vektörünü kapatmaz.** Bu yüzden double-submit token (K3-L3) **kaldırılmaz** — ama rolü *"tek savunma"* değil **ikinci savunma hattı** olarak yazılır. Gizlenmiş sınır değil, adlandırılmış sınır.

**K3-L5 — Tek-uçuşlu (single-flight) refresh. [K11-c'nin istemci ayağı]** İstemcide **aynı anda en çok BİR** `/refresh` uçuşu olur; 401 alan diğer istekler o tek uçuşun sonucunu **bekler**, kendileri `/refresh` çağırmaz. Sunucuda zarafet penceresi olmadığı için (K3-C5) meşru istemcinin kendini "hırsız" ilan ettirmemesi **bu mekanizmaya** bağlıdır. Uçuş başarısızsa istekler kuyrukta kalır (K3-L6), **düşürülmez**.

**K3-L6 — 401'de kuyruk BEKLER, DÜŞÜRÜLMEZ. [K11-g]** Tek-uçuşlu refresh denenir; başarısızsa gönderilmemiş yazımlar **diskte kalır** ve istemci "oturum gerekli" durumuna geçer. Kullanıcı yeniden giriş yapınca kuyruk **kaldığı yerden** gönderilir. *Gerekçe:* ODEV §6.1 bunu mimari zorunluluk ilan etti — *"erişim token'ı süresi dolduğunda kuyruktaki yazımların kaybolmaması"*. *Reddedilen:* 401'de kuyruğu düşürmek/çıkışa atmak.

**K3-L7 — Çıkışta SİLME YOKTUR: kullanıcı-başına ayrı yerel DB dosyası. [K11-g]** Her kullanıcının Drift dosyası ayrıdır: **`momentum_{userId}.sqlite`**. Çıkışta yerel veri **silinmez**, yalnız o dosya kapatılır. Sonuçları: (a) A çıkıp B girince A'nın verisi görünmez — izolasyon **dosya düzeyinde**, dolayısıyla bir sorgu filtresi unutulsa bile sızmaz; (b) A'nın **gönderilmemiş yazımları** A yeniden girince devam eder; (c) **kırmızı çizgi 4 (kalıcı silme) hiç tetiklenmez** ⇒ çıkışta onay akışı gerekmez. *Reddedilen:* tek DB dosyası + çıkışta silme (gönderilmemiş kuyrukta **veri kaybı** + her çıkışta onay). **Not:** oturum açılmadan yazma yoktur ⇒ "kullanıcısız kuyruk" durumu bu dilimde **oluşmaz**; oluşursa 3b'de adlandırılır.

---

## 3. Isıran kapılar (KÖR KAPI YOK)

Her kapı, kaldırıldığında testi **kırdığını** mutantla kanıtlar. Bu tablo `GOREV-slice-3a-auth` spec'inin mutant listesinin **kimlik-çekirdeği yarısıdır**; diğer yarısı ADR 0004'tedir. **Numaralar v1 ile aynıdır** — yeniden numaralandırma yapılmadı, çünkü bu proje daha önce "aynı numara iki anlam" hatasını yedi.

| # | mutasyon | kill sinyali (ZORUNLU) | not |
|---|---|---|---|
| **M1** | Yeniden-kullanım tespiti kaldırılır (tüketilmiş token kabul edilir) | *"tüketilmiş token ikinci kez sunulunca **o aile** iptal olur"* testi **FAIL** | **v1'de ÖLÜ TUZAKTI** (zarafet penceresi baseline'ı da kırmızı yapıyordu); K3-C5 pencereyi kaldırınca **canlandı** |
| **M4** | `ToLowerInvariant` → kültüre-duyarlı `ToLower()` | **DERLEME KIRILIR** (BannedApiAnalyzers) | v1 bunu *"test FAIL"* diye yazmıştı — **sinyal düzeltildi**. Ayrıca analizör listesi dışından aynı hata yapılırsa: tr-TR **zorlanmış kültür** testi *"`I@x.com` ve `i@x.com` aynı hesaba düşer"* **FAIL** |
| **M5** | Rehash-on-login kaldırılır | *"eski parametreli hash başarılı girişten sonra güncel parametreye taşınır"* **FAIL** | K9'un izolasyon vaadinin kapısı |
| **M6** | `FixedTimeEquals` → `SequenceEqual` | **DERLEME KIRILIR** (BannedApiAnalyzers) | sinyal v1'de yanlış yazılmıştı, düzeltildi |
| **M7** | Bilinmeyen e-postada sahte (dummy) hash koşulmaz | *"bilinmeyen e-posta ile `/login` isteğinde `IPasswordHasher.Verify` **tam olarak 1 kez** çağrılır"* **FAIL** | **YAPISAL ÖLÇÜT** — v1'in istatistiksel zamanlama eşiği flaky'di ⇒ gevşetilirdi ⇒ pratikte ölü tuzaktı. Süre ölçülmez, **çağrı sayılır** |
| **M8** | İmzalama anahtarı yokken varsayılan üretilir | *"anahtarsız/kısa anahtarlı başlangıç patlar"* **FAIL** | K3-I2 |
| **M11** | Hız sınırlayıcı tamamen kaldırılır | *"aynı IP'den N+1'inci `/login` denemesi `429`"* **FAIL** | K3-J2(1) |
| **M12** | Yenileme token'ı DB'ye ham yazılır (hash'lenmez) | *"DB'deki değer istemciye verilen token'a EŞİT DEĞİL"* **FAIL** | K3-C2 |
| **M13** | ~~Zarafet penceresi sınırı~~ | **VOID — KONUSU KALMADI** | Mekanizma K11-c ile kaldırıldı; mutant **bilinçli olarak yazılmaz**, sessizce kaybolmaz |
| **M14** | `FallbackPolicy` kaldırılır (deny-by-default kapatılır) | *"`[Authorize]` yazılmamış yeni bir uç anonim erişime `401` döner"* **FAIL** | v1'in **en geniş** kontrolü mutantsızdı (R7) |
| **M15** | `ICurrentUser.UserId` kimliksizken `Guid.Empty` döndürür | *"kimliksiz erişimde `UnauthenticatedException` atılır"* **FAIL** | v1'in *"en sinsi ihlal"* ilan edip mutantsız bıraktığı davranış (R7) |
| **M16** | `ClockSkew = TimeSpan.Zero` kaldırılır (varsayılan 5 dk) **veya** `ValidAlgorithms` pinlemesi kaldırılır | *"süresi 1 dk önce dolmuş token `401`"* **FAIL** · *"beklenmeyen `alg` ile imzalanmış token reddedilir"* **FAIL** | K3-C7; R4'ün kapısı |
| **M17** | Döndürmede yeni token'a **yeni** mutlak son kullanma verilir | *"döndürme mutlak 30 günlük ömrü UZATMAZ"* **FAIL** | K3-C2 |
| **M18** | `/logout` kullanıcının **tüm** ailelerini iptal eder | *"iki cihazdan giriş: birinden `/logout`, diğerinin `/refresh`'i ÇALIŞMAYA DEVAM EDER"* **FAIL** | K3-C3/C4; R5'in kapısı |
| **M19** | `OutboxDispatcher` içinde `scoped ICurrentUser` çözülür | *"dispatcher HTTP bağlamı olmadan çalışır"* entegrasyon testi **FAIL** | K3-D3 |
| **M21** | Normalizasyondan `Trim()` **veya** NFC adımı çıkarılır | *"`\" a@x.com\"` ile `\"a@x.com\"` aynı hesaba düşer"* **FAIL** · *"NFC ayrık aksanlı e-posta birleştirilmiş hâliyle aynı hesaba düşer"* **FAIL** | K3-A2 |
| **M22** | Parola doğrulama eşzamanlılık limiti kaldırılır | *"limitin üstündeki eşzamanlı `/login` isteği `429` alır ve Argon2 KOŞMAZ"* **FAIL** | K3-J2(3) — R2'nin maliyet ayağı |
| **M23** | IP partition'ı kaldırılır, yalnız e-posta partition'ı bırakılır | *"her istekte FARKLI rastgele e-posta ile gelen N+1'inci istek de `429`"* **FAIL** | **R2'nin tam kapısı** — v1'in fiilen bu durumda olduğunu kanıtlar |
| **M24** | `ICurrentUser` `"sub"` yerine `ClaimTypes.NameIdentifier` okur | *"`MapInboundClaims=false` altında geçerli token ile korumalı uç `200` döner"* **FAIL** | K3-C7'nin ölçülmüş yan etkisi |
| **M25** | Double-submit CSRF doğrulaması kaldırılır (yalnız `SameSite` kalır) | *"geçerli yenileme çerezi + EKSİK/YANLIŞ `X-CSRF-Token` ile `/refresh` reddedilir"* **FAIL** | K3-L3'ün ikinci hattı; `Strict` alt alan adı vektörünü kapatmadığı için gerçek bir kapıdır |

**ADR 0004'e ait mutantlar (burada YAZILMAZ, kaybolmasın diye adlandırılır):** M2 (`ActorId` ile yetki) · M3 (EF global filtre) · M9 (`client_id ↔ user_id`) · M10 (`IgnoreQueryFilters` allowlist dışı) · M20 (sahiplik TOCTOU) · **pull-authz mutantı** (v1'de hiç yoktu) · **imleç opaklığı mutantı** (K3-G2 düzeltmesi).

> **KURAL [K6 tavanına TABİ DEĞİL]:** her mutant **gerçekten koşulur**; *"beklenir"* diye akıl yürütmeyle KANIT yazılmaz (slice-2b1 BULGU-1 dersi). Bir mutant baseline'da **kırmızı doğuyorsa** o bir ölü tuzaktır ve **mekanizma tartışılır**, test gevşetilmez (M1/M7 dersi).

---

## 4. Gerekçe

**Bu belgenin değeri "kimlik doğrulama eklendi"de değil, iki yerdedir.**

**Birincisi: token modeli kanıtlanabilirlik için seçildi, konfor için değil.** Stateless bir yenileme JWT'si iptal edilemez — dolayısıyla üzerine **ısıran bir kapı kurulamaz**. Opak + DB + döndürme + yeniden-kullanım tespiti ise **ölçülebilir bir davranıştır**: mutantla kırılır, testle yakalanır. Bu projede bir mekanizmanın "kapı kurulabilir olması" onun seçilme gerekçelerinden biridir. v1'in **zarafet penceresi** tam da bu ölçütten düştü: mekanizmanın kendisi kapıyı **yapısal olarak erişilemez** kılıyordu (5 sn'de bir `/refresh` ⇒ reuse-detection'a hiç varılmaz). Cevap testi gevşetmek değil, **mekanizmayı kaldırmak** ve yarışı istemcide tek-uçuşlu refresh ile çözmek oldu (K3-C5/L5).

**İkincisi: parola tarafında asıl mimari iş paket seçimi değil, paketin İZOLASYONUDUR.** Kapı, **aktif bakımlı** adayın (NSec/libsodium) hedef platformda OWASP parametreleriyle **koşamadığını**, **~25 aydır dormant** adayın (Konscious) koştuğunu ölçtü — yani *"en iyi bakılanı seç"* sezgisi bu vakada **yanlış paketi seçerdi**. Buna verilen cevap paketi savunmak değil; `IPasswordHasher` portu + kendini tarif eden hash string'i + rehash-on-login ile **paketi yarın değiştirilebilir kılmaktır**. Değerlendiriciyi etkileyecek olan *"Argon2id kullandım"* değil, *"bağımlılığı ölçtüm, dormant olduğunu gördüm, arkasına port koydum"*dur (K8-d/K9 ölçütü).

**Türkçe locale kararı (K3-A2) bu projeye özgü ve ÖLÇÜLMÜŞ bir risktir:** aynı makinede aynı locale Postgres `initdb`'yi zaten kırdı. Kültüre-duyarlı bir `ToLower()` çağrısı, testlerini invariant kültürde koşan bir CI'da **asla görünmeyecek** bir kimlik hatası üretirdi. Aynı tuzağın frontend ucu (Dart `toUpperCase()`) K10'da bağımsız olarak bulundu — **iki bağımsız oturumun aynı mayına basması**, kuralın katmandan bağımsız yazılmasını gerektirdi.

**v1'den v2'ye asıl ders (§0'ın özeti):** dokuz blokerin çoğu *"yanlış karar"* değil, **kararı yazılmamış varsayılan** idi — `ClockSkew`, `alg`, `MapInboundClaims`, `family_id`'nin doğum anı, rate-limit anahtarının kimin elinde olduğu. Bir ADR'nin işi seçenekleri saymak değil, **sessiz varsayılanların hangisinin kabul edildiğini yazmaktır**. v2'nin fazladan yaptığı iş büyük ölçüde budur.

## 5. Alternatifler

| Eksen | Seçilen | Reddedilen (gerekçe) |
|---|---|---|
| Kimlik altyapısı | Elle ince implementasyon | ASP.NET Core Identity (katman baskısı, kullanılmayan 5 tablo, **kendi kapını gevşetme**) |
| Parola KDF | Argon2id (Konscious 1.3.1, izole) | Isopoh (**lisans belirsiz**: CC-BY / NOASSERTION / CC0) · NSec-libsodium (**OWASP parametrelerinde koşmadı**, `p` yalnız 1) · PBKDF2 (K8-c yedeği; kapı geçtiği için tetiklenmedi) |
| Yenileme token'ı | Opak + DB + döndürme + reuse-detection | Stateless JWT-refresh (iptal edilemez, kapı kurulamaz) · tek uzun ömürlü JWT (çevrimdışı kuyruk kaybı) |
| JWT imzası | HS256 (simetrik) | ES256 (tek servis topolojisinde karşılıksız anahtar dağıtımı) |
| **Yenileme yarışı** | **Sunucuda saf reuse-detection + istemcide tek-uçuşlu refresh** | **10 sn zarafet penceresi (v1) — sonsuz zarafet zinciri, kapıyı yapısal olarak erişilemez kılıyordu** · katı tek-kullanım + istemci çözümü yok (meşru istemciyi hırsız ilan eder) |
| `family_id` kapsamı | **Giriş başına (cihaz/oturum)** | Kullanıcı başına tek aile (bir cihazdaki şüphe tüm cihazları düşürür ⇒ çok-cihaz demosu bozulur) |
| E-posta eşsizliği | `Trim` → NFC → `ToLowerInvariant` + `COLLATE "C"` unique index | `ToLower()` (tr-TR'de İ/ı ⇒ çift hesap) · `citext` (Postgres'e kilitler, `COLLATE "C"` ailesiyle tutarsız) · normalizasyonsuz (Trim/NFC boşluğu, M21) |
| `/register` sayım oracle'ı | **Adlandırılmış sapma + beyan** | Her durumda `202` (kullanıcı neden giremediğini anlamaz; e-posta doğrulama kapsam dışı olduğu için ikinci ayak yok) · yalnız rate-limit (oracle'ı kapatmaz) |
| Kaba kuvvet | **IP penceresi + e-posta penceresi + eşzamanlılık limiti (üçü ayrı amaç)** | Tek birleşik "IP+e-posta" anahtarı (**R2: partition'ı saldırgan seçer**) · hesap kilitleme (kurbanı kilitleten DoS) · hiçbir şey |
| Token deposu (web) | `HttpOnly` çerez (yenileme) + bellek (erişim) | `localStorage` / IndexedDB (tek XSS sızdırır) · yalnız bellek (F5 = çıkış) |
| Çıkışta yerel veri | **Kullanıcı-başına DB dosyası, silme YOK** | Tek DB + çıkışta silme (gönderilmemiş kuyrukta veri kaybı; kırmızı çizgi 4) |

## 6. Riskler / açık noktalar

1. **`Konscious` ~25 ay hareketsiz** — adlandırılmış risk (K3-B1). Telafi **kapatma değil izolasyon**: port + kendini tarif eden hash + rehash-on-login. **Tetikleyici:** pakete bir CVE düşerse PBKDF2'ye geçiş **tek sınıflık** iştir (K8-c yedeği önceden onaylı).
2. **`/register` sayım oracle'ı** — **adlandırılmış sapma** (K3-A3). Bir saldırgan hangi e-postaların kayıtlı olduğunu öğrenebilir. Kapatmanın kanonik yolu e-posta doğrulamadır ve o **kapsam dışıdır** (ODEV §6.1). `KANIT` ve README'de beyan edilir. *Bu, "sonra düzeltiriz" değil, "bilerek buradayız" kalemidir.*
3. **Erişim token'ı anlık iptal edilemez** (≤15 dk pencere) — beyan edilmiş sınır (K3-C4). `sstamp` talebi ileride kanca bırakır. `/logout` sonrası eski erişim token'ı en fazla 15 dk daha geçerlidir; **`ClockSkew=0` sayesinde bu 20 dk DEĞİL, gerçekten 15 dk'dır** (K3-C7).
4. **Argon2id 270 ms + 19 MiB / istek** — gerçek bir maliyet, ve sahte hash (K3-B5) bunu bilinmeyen e-postalarda **da** ödetir. **v1'in *"hız sınırlama bu maliyeti bir DoS yüzeyi olmaktan çıkarır"* CÜMLESİ YANLIŞTI ve DÜZELTİLMİŞTİR** (R2): maliyeti sınırlayan şey **IP penceresi + eşzamanlılık limitidir** (K3-J2/1 ve /3); e-posta penceresi (K3-J2/2) buna **hiçbir şey katmaz**, çünkü anahtarını saldırgan seçer. Kalan yüzey: **botnet/proxy havuzu** — tek IP penceresi onu durdurmaz; eşzamanlılık limiti hizmeti ayakta tutar ama **gecikme artar**. Bu, tek-instance bir ödev dağıtımında **kabul edilen ve beyan edilen** sınırdır.
5. **Rate limiter partition belleği [DOĞRULANMADI]** — K3-J5. Ayrık e-posta sayısı kadar limiter nesnesi doğar; .NET'in atıl-partition temizleme davranışı **bu belgede ölçülmemiştir**. Spec aşamasında ölçülür veya sınırlı kova tasarımına indirgenir.
6. **RateLimiter'ın çok-instance davranışı** — bellek-içi sayaç **tek instance'a** özgüdür; yatay ölçekte dağıtık sayaç gerekir. Bu ödevin dağıtım modelinde (tek instance) sorun değil; **beyan edildi** ve K3-K3'te kapsam dışı olarak adlandırıldı.
7. **Web dağıtım topolojisi KİLİTLENDİ: aynı origin** (K3-L4, Onur, 25 Tem 2026). Kalan yüzey **adlandırıldı:** `SameSite=Strict` "same-site" tanımı gereği **kardeş alt alan adlarını** kapsamaz ⇒ ele geçirilmiş bir alt alan adından gelen istek çerezi taşır. Bu yüzden double-submit token **ikinci savunma hattı olarak durur** (K3-L3). Ayrıca aynı-origin kararı **teslim paketini bağlar**: web build'i API ile birlikte servis edilmelidir (CI/CD ve paketleme adımında görünür bir gereksinim).
8. **`slice-3b` bağımlılığı:** K3-L1'in `flutter_secure_storage` paketi **henüz lisans+CVE kapısından geçmedi** (kırmızı çizgi 3). Bu ADR paketi **onaylamaz**, yerini tarif eder; kapı `slice-3b` spec'inde koşulur ve **düşerse K3-L1 yeniden açılır**.
9. **Parola değiştirme yok** (K3-K3) ⇒ `/logout-all`'ın en doğal tetikleyicisi de yok. Uç yine de vardır ve testlidir (M18); *"ileride parola değişimi eklenirse bağlanacak kanca"* olarak beyan edilir. **Fazladan yüzey olduğu kabul edilir**, gizlenmez.

## 7. İlgili

- **Öncül:** ADR 0001 (K-C1 `ownerId`, K-C5 `TimeProvider`, **K-D5**, K-E1 UUIDv7, K-H1 banned-API + NetArchTest) · ADR 0002 (**K2-E3** pull/push authz, K2-E5 op-başına txn + kısmi red, K2-A4 `sync_client_clock`, §6/7 **M-C**).
- **⚠ BORÇ DURUMU — v1'İN *"DÖRDÜ DE ✓"* BEYANI DÜZELTİLDİ.** Borç **BEŞTİR** ve **bu belge tek başına HİÇBİRİNİ KAPATMAZ**; kimliği üretir, yetkiye bağlayan **ADR 0004**'tür:

| borç | bu belgede | ADR 0004'te | durum |
|---|---|---|---|
| **K-D5** `ICurrentUser` + owner filtre | sözleşme + impl (§2-D) | **global query filter** | 🟡 yarısı |
| **M-G** push-authz | — | tamamı | 🔴 açık |
| **K2-E3** pull-authz | — | tamamı + **eksik mutantı** | 🔴 açık |
| **M-C** `clientId → principal` | — | tamamı | 🔴 açık |
| **B4** `outbox_messages.owner_id` | — | tamamı | 🔴 açık |

- **ADR 0004'e DEVREDİLEN, KAYBOLMASIN DİYE ADLANDIRILAN İŞLER:**
  - **D-1** SignalR hub kimliği (K11-a) + **özel `IUserIdProvider` ZORUNLU** (K3-C7'nin ölçülmüş yan etkisi) + token'ın `?access_token=` query string'inden alınması (WebSocket el sıkışması `Authorization` başlığı taşımaz).
  - **D-2** `outbox_messages.owner_id` `ICurrentUser.UserId`'den türer; ingest'te `op.ActorId ≠ token sub` ⇒ **istek reddedilir** (K11-b; F5'in fiilen devreye girdiği yer).
  - **D-3** Global query filter kurulurken **`User` KAPSAM DIŞI** bırakılmalıdır (K3-A4) — aksi hâlde anonim `/login` `UnauthenticatedException` alır ve **giriş fiziksel olarak kilitlenir**. Mutant zorunlu.
  - **D-4** Pull yolunun **ham SQL** olduğu ve `commit_xid`/`server_seq`'in EF'te map edilmediği ⇒ **global filtrenin oraya fiziksel olarak ERİŞEMEDİĞİ** yazılır; v1'in *"tek sorgu bile sızdıramaz"* gerekçesi taç mücevher yolunda **geçersizdir**. **Ayrı pull-authz mutantı zorunlu.**
  - **D-5** **K3-G2 düzeltmesi:** imleç yan-kanalı *"kapatılamaz"* DEĞİLDİR — `server_seq` bir `IDENTITY` kolonu olduğu için sızan şey hacim çıkarımı değil **tam sayaçtır** (ve `commit_xid` üzerinden Postgres instance'ının **toplam txn hızıdır**). İmleç **opak/HMAC'li** döndürülür + **boş-sayfa `nextCursor` çatalı** kurulur (küresel ufuk ⇒ sızıntı; eski imleç ⇒ her boş ankette O(toplam yazma) tarama = DoS çarpanı).
  - **D-6** `sync_client_clock`'a `user_id` eklenmesi + backfill politikası (bugün üretim verisi yok, tablo pratikte boş).
- **Sıradaki:** **ikinci ve SON bağımsız kapı** (architecture + red-team, üreten ≠ denetleyen) → Onur kilidi → ayrı oturumda **ADR 0004** → `GOREV-slice-3a-auth` spec'i (**en çok İKİ denetim turu**, K6) → Claude Code build → **Cowork TEMİZ OTURUMDA bağımsız doğrular**.
- **Sonra:** `slice-3b` (Flutter istemci) — §2-L'nin token/kuyruk/DB kararları Drift şemasını ve depo katmanını **doğrudan** belirler.

---

*🟡 TASLAK v2 — KİLİTLİ DEĞİL. Açık çatal yok (K3-L4 kilitlendi); **ikinci ve SON bağımsız kapı koşmadı.** Bu ADR'yi yazan el onaylayamaz.*

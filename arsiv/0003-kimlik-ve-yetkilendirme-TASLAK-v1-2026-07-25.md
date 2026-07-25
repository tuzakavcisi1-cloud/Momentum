# ADR 0003 — Kimlik ve Yetkilendirme (`slice-3a-auth`)

- **Durum:** 🟡 **TASLAK v1 — KİLİTLİ DEĞİL.** Bağımsız kapı (architecture + red-team) **henüz koşmadı**. *Üreten ≠ denetleyen: bu ADR'yi yazan el onu onaylayamaz.* Kilit Onur'dadır.
- **Tarih:** 2026-07-25
- **Karar verenler:** Onur (sahip) · Cowork (mimar) · bağımsız denetçi ajanlar (kapı bekliyor)
- **Kapsam:** ADR 0001 ve 0002'nin auth dilimine **ADLANDIRARAK ertelediği dört gereksinimin** aktivasyonu + kimlik/parola/token mekaniği.
- **Bağımlılık:** ADR 0001 (§C, §D, §G, §H) · ADR 0002 (K2-E3, K2-E5, K2-A4, §6/7). Kalıcılık ayağı Postgres ister (Testcontainers); saf çekirdek (hash, token üretimi, normalizasyon) DB'siz kanıtlanır.

> **Onur'un kilitlediği fork'lar:** K8-a tam aktivasyon · K8-c Argon2id (kapı koşuldu) · K9 hash izolasyonu · owner filtresi = EF global filtre + `IgnoreQueryFilters` yasağı · kaba-kuvvet savunması KAPSAM İÇİ (RateLimiter).
>
> **Cowork kararları (gerekçesi denetlenebilir olsun diye tam yazıldı):** K8-b token modeli · K8-d Identity elemesi.

---

## 1. Bağlam

Bugüne kadar Momentum'un backend'i **kimliksiz** çalıştı. Bu, iki ADR'de **sessiz açık bırakılmadı, adlandırıldı**:

| pin | ertelenmiş gereksinim | kaynak (birebir) |
|---|---|---|
| **K-D5** | `ICurrentUser` impl + owner query-filter | `0001` §D: *"`ICurrentUser` portu (Application) slice-1'de arayüz olarak tanımlanır; implementasyonu + owner query-filter kimlik dilimiyle kodlanır (owner izolasyonu auth'a bağımlıdır, erken kodlanamaz)."* |
| **M-G** | push-authz | `0002` K2-E3: *"ingest, her op için 'actor bu entity'yi **yazabilir mi**' kontrolü yapmalı. Mekanizma auth diliminde; o zamana dek deny-by-default + `entityId` bir yetki-token'ı DEĞİLDİR."* |
| **K2-E3** | pull-authz | `0002` K2-E3: *"`changes` yalnız actor'ın görebildiği entity'lerle sınırlı (Application, `ICurrentUser`)"* + tombstone muafiyeti |
| **M-C** | `clientId → principal` | `0002` §6/7: *"`clientId` kimlik-doğrulaması ertelenmiş… auth diliminde aktive edilecek"* |

**Bu dilim bir özellik değil, bir ŞEMA kararıdır.** Çevrimdışı-öncelikli Flutter istemcisinde "bu yerel satır kimin", "token nerede duruyor", "401 gelince kuyruktaki yazımlar ne oluyor", "çıkışta yerel DB'ye ne oluyor" soruları Drift şemasını ve depo katmanını belirler. `slice-3b`'den sonraya bırakmak migration + yeniden yazım demektir (K7-c).

**Ayrıca bir güvenlik yüzeyi kapanır.** Bugün `WireOp.ActorId` **istemci-beyanlıdır** ve kimliği doğrulanmış actor push yoluna hiç girmez (slice-3a denetimi, F5). Auth olmadığı için sömürülemez; auth gelince sömürülebilir hâle gelir. **Bu ADR onu kapatır.**

---

## 2. Karar

### A. Kimlik modeli

**K3-A1 — `User` entity, asgari PII [red line #2].** Alanlar: `id` (UUIDv7, `Guid.CreateVersion7()`, K-E1) · `email` · `emailNormalized` · `passwordHash` · `createdAt`/`updatedAt` (yalnız `TimeProvider`, K-C5) · `securityStamp`. **YOK:** ad, soyad, telefon, doğum tarihi, profil fotoğrafı, IP geçmişi. Görev sahipliği `ownerId` çıpasıyla kurulur (K-C1) — kullanıcı adı gösterimi işbirliği diliminde ele alınır.

**K3-A2 — E-posta normalizasyonu: `ToLowerInvariant` + `COLLATE "C"` unique index. [PAZARLIKSIZ]**
Depolanan iki alan ayrıdır: `email` kullanıcının yazdığı hâlidir (gösterim), `emailNormalized` **eşsizlik ve arama anahtarıdır**.

> **⚠ TÜRKÇE LOCALE TUZAĞI — bu projede teorik değil, ölçülmüş bir risktir.**
> Geliştirme makinesinin sistem locale'i **tr-TR / cp1254**'tür (oturum 2 tanısı: bu locale Postgres `initdb`'yi fiilen kırdı). Türkçe kültüründe `"I".ToLower()` → **`"ı"`** (noktasız), `"i".ToUpper()` → **`"İ"`** (noktalı). Kültüre-duyarlı `ToLower()` kullanılırsa **aynı e-posta, sunucunun kültürüne göre iki farklı normalize değer üretir** ⇒ (a) aynı adresle iki hesap açılabilir, (b) tr-TR makinede kayıt olan kullanıcı invariant makinede giriş yapamaz. **Yalnız `ToLowerInvariant()`** kullanılır; DB tarafında unique index **`COLLATE "C"`** ile kurulur (ADR 0002'nin `COLLATE "C"` kararıyla aynı aile). `string.ToLower()`/`ToUpper()`/kültüre-duyarlı `Compare` çağrıları **BannedApiAnalyzers ile derleme-zamanı yasaklanır** (K-H1'in `DateTime.UtcNow` yasağıyla aynı mekanizma).

**K3-A3 — Kayıt açık.** `POST /v1/auth/register` herkese açıktır. *Gerekçe:* gerçek zamanlı işbirliği vitrini **iki gerçek kullanıcı ister** (K7-c) ve değerlendirici uygulamayı kendi hesabıyla denemelidir (ODEV §2). *Reddedilen:* tohumlanmış (seed) demo kullanıcılar — değerlendiriciye "gerçek akış yok" izlenimi verir.

### B. Parola

**K3-B1 — Hash = Argon2id, `Konscious.Security.Cryptography.Argon2` 1.3.1 [KAPI KOŞULDU, GEÇTİ].**
Parametreler **OWASP ikinci yapılandırması**: `m = 19456 KiB · t = 2 · p = 1`, 16 baytlık CSPRNG salt, 32 baytlık çıktı.
**Kapı kanıtı (Onur'un makinesinde, gerçek koşu):** lisans **MIT** (nuspec SPDX + GitHub `license.spdx_id`; geçişli `Blake2` 1.1.1 de MIT) · **CVE 0** (`dotnet list package --vulnerable --include-transitive`, zafiyet akışı 2026-07-24) · net9.0 build **0 uyarı 0 hata** · **fiilen çalıştı: 32 baytlık hash, 270 ms**.
**⚠ ADLANDIRILMIŞ RİSK, GİZLENMİYOR:** paket **~25 ay hareketsiz** (`pushed_at = 2024-06-18`, 20 açık issue, 3 açık PR, GitHub'da release yok). Bir CVE düşerse yamayı gönderecek bakımcı olmayabilir. **Telafi kapatma değil, izolasyondur → K3-B2/B3.**

**K3-B2 — `IPasswordHasher` portu.** Arayüz **Application**'da, implementasyon **Infrastructure**'da. `Konscious.*` tipi Domain/Application/Api katmanlarının hiçbirinde görünmez — **NetArchTest kuralı** (K-A1 ailesine ek). Böylece paket değişimi tek sınıfı etkiler.

**K3-B3 — Hash string'i kendi kendini tarif eder.** Depolanan format PHC benzeri:
`$argon2id$v=19$m=19456,t=2,p=1$<b64 salt>$<b64 hash>`
Algoritma kimliği ve parametreler **satırın içindedir**. Sonucu: (a) PBKDF2'ye ya da yeni parametreye geçiş **migration değil**, tek sınıf + doğrulama yolunda dallanmadır; (b) **başarılı girişte, depolanan parametreler güncel politikadan farklıysa parola sessizce yeniden hash'lenir** (rehash-on-login). Kullanıcı hiçbir şey fark etmez, veritabanı kendiliğinden ilerler.

**K3-B4 — Doğrulama sabit-zamanlı.** Karşılaştırma `CryptographicOperations.FixedTimeEquals` ile yapılır; `SequenceEqual`/`==` **yasak**.

**K3-B5 — Kullanıcı-sayımı (enumeration) ve zamanlama sızıntısı kapatılır. [PAZARLIKSIZ]**
Bilinmeyen e-posta ile yanlış parola **aynı** yanıtı döndürür (`401`, tek tip ProblemDetails, ayırt edici mesaj yok) **ve aynı işi yapar**: kullanıcı bulunamazsa da bir **sahte (dummy) Argon2id doğrulaması** koşulur. Aksi hâlde yanıt süresi (≈270 ms vs ≈1 ms) hesabın var olup olmadığını ele verir — parola hash'inin tüm maliyetini ödeyip yanında ücretsiz bir oracle dağıtmak anlamsızdır.

### C. Token modeli [K8-b]

**K3-C1 — Erişim token'ı = kısa ömürlü JWT (~15 dk), HS256.** Talepler (claims): `sub` (userId), `jti`, `iat`, `exp`, `sstamp` (security stamp). İmzalama anahtarı simetrik; **tek servis** olduğu için asimetrik imza (ES256) fazladan anahtar dağıtımı getirir, karşılığında bu topolojide hiçbir şey kazandırmaz. *Reddedilen: ES256 (kaynak sunucu ayrışması yok) · uzun ömürlü tek JWT (iptal edilemez).*

**K3-C2 — Yenileme token'ı = OPAK, DB'de, DÖNDÜRMELİ, YENİDEN-KULLANIM TESPİTLİ. [taç mekanik]**
- Değer: 256 bitlik CSPRNG rastgele; istemciye ham gider, **DB'ye yalnız SHA-256 özeti yazılır**. *(Parola gibi Argon2id gerekmez: yüksek-entropili rastgele bir sır, sözlük saldırısına tabi değildir; bu bilinçli ve gerekçeli bir asimetridir.)*
- Ömür: **mutlak 30 gün** (döndürme ömrü uzatmaz). Çevrimdışı pencere için kasıtlı geniş — K7-c'nin *"erişim token'ı dolunca kuyruktaki yazımlar kaybolmasın"* mimari zorunluluğu.
- Tablo: `refresh_tokens(id, user_id, token_hash, family_id, created_at, expires_at, consumed_at, replaced_by_id, revoked_at, revoked_reason)`.
- **Döndürme:** her `/refresh` çağrısı sunulan token'ı `consumed_at` ile tüketir ve **aynı `family_id`** altında yenisini üretir.
- **YENİDEN-KULLANIM TESPİTİ:** `consumed_at` dolu bir token yeniden sunulursa → **tüm aile derhal iptal edilir** (`revoked_reason = 'reuse_detected'`), o kullanıcının tüm oturumları düşer. Sunum: `401`. *Gerekçe:* tüketilmiş bir token'ın tekrar gelmesinin tek makul açıklaması çalınmış olmasıdır; hangi tarafın hırsız olduğunu bilemeyiz, ikisini de düşürürüz.
- **Eşzamanlılık [çevrimdışı istemcide GERÇEK bir senaryo]:** ağ geri geldiğinde birden çok kuyruk isteği aynı anda `/refresh` çağırabilir. Tüketim **tek bir atomik `UPDATE … WHERE consumed_at IS NULL … RETURNING`** ile yapılır; yarışı kaybeden istek `401` değil, **kısa bir zarafet penceresi** (aynı aileden, son 10 sn içinde üretilmiş geçerli token) ile karşılanır — aksi hâlde meşru istemci kendi kendini "hırsız" ilan ettirir. *(Bu pencere red-team'in özellikle kırmaya çalışması gereken yerdir; kayda geçirildi.)*

**K3-C3 — Çıkış (logout) gerçektir.** `POST /v1/auth/logout` yenileme token'ı ailesini iptal eder. Erişim token'ı ≤15 dk daha geçerli kalır — bu **bilinçli ve beyan edilmiş** bir sınırdır (kara liste tutmuyoruz; `sstamp` talebi ileride anlık iptal için kanca bırakır).

### D. `ICurrentUser` sözleşmesi [K-D5 aktivasyonu]

**K3-D1 — Şekil.** `Application`'da: `Guid UserId { get; }` (kimlik yoksa **`UnauthenticatedException` fırlatır**, `Guid.Empty` DÖNDÜRMEZ) + `bool IsAuthenticated { get; }`. *Gerekçe:* `Guid.Empty` sessizce sorguya sızıp "hiçbir şey döndürmeyen ama patlamayan" bir filtre kurar — deny-by-default'un en sinsi ihlali. **Kimliksiz erişim gürültülü başarısız olur.**

**K3-D2 — Implementasyon `HttpContext.User`'dan okur, `scoped` ömürlüdür.**

**K3-D3 — ⚠ ARKA PLAN SERVİSİ TUZAĞI [adlandırıldı].** `OutboxDispatcher` bir `BackgroundService`'tir (singleton) ve **`HttpContext`'i yoktur**. Bir `scoped ICurrentUser`'ı oradan çözmeye çalışmak ya çalışma-zamanı hatası ya da (daha kötüsü) sessiz yanlış kimlik üretir. **Kural:** dispatcher owner-filtreli hiçbir sorguya dokunmaz; outbox okuması **açıkça filtresizdir** (K3-E2'nin adlandırılmış istisnası). Bu, ADR 0002'nin "yayıncı Infrastructure" katman kararıyla tutarlıdır.

### E. Owner izolasyonu [Onur kilidi, 25 Tem 2026]

**K3-E1 — EF Core GLOBAL QUERY FILTER.** Senkronlanabilir her kök için `HasQueryFilter(e => e.OwnerId == _currentUser.UserId)`. *Gerekçe:* unutulan **tek** bir sorgu bile veri sızdıramaz; koruma programcının dikkatine değil altyapıya bağlanır.

**K3-E2 — Global filtrenin kör-kapı deliği KAPATILIR. [PAZARLIKSIZ]**
Global filtrenin bilinen iki zayıflığı vardır ve ikisi de açıkça ele alınır:
1. **`IgnoreQueryFilters()` filtreyi görünmez biçimde kapatır** → çağrısı **BannedApiAnalyzers ile yasaklanır**; yalnızca **adlandırılmış allowlist** (bugün tek kalem: outbox/dispatcher okuması, K3-D3) istisnadır ve her istisna gerekçesiyle birlikte yazılır.
2. **Sessiz çalışır ⇒ ısırdığı kanıtlanmalıdır.** Filtre bir mutantla test edilir (K3-M3): filtre kaldırıldığında *"B kullanıcısı A'nın görevini gördü"* testi **KIRILMALIDIR**. Yeşil kalırsa kapı ölüdür ve reddedilir.

**K3-E3 — Yazma yolu filtreye GÜVENMEZ.** Global filtre `SELECT` tarafını korur; `UPDATE`/`DELETE` için sahiplik **açıkça doğrulanır** (K3-F1). *Bir sorguyu filtrelemek onu yazmaya yetkilendirmez.*

### F. Push-authz [M-G aktivasyonu]

**K3-F1 — Ingest'te op-başına yetki.** `/v1/sync` push'unda her `WireOp` için: entity **varsa** → `owner_id == authenticated actor` olmalı; entity **yoksa** (create) → `owner_id := authenticated actor`. Eşleşmeyen op **tek başına** reddedilir (`403`, sebep kodu), **batch düşürülmez** — ADR 0002 K2-E5'in op-başına transaction + kısmi-red modeliyle tutarlı.

**K3-F2 — `WireOp.ActorId` YETKİ İÇİN KULLANILMAZ. [F5 kilidinin fiilen devreye girdiği yer]** İstemci-beyanlıdır; **tek yetki kaynağı doğrulanmış principal'dır** (`token.sub`). Alan telde kalır (teşhis/izleme) ama yetki kararına **hiçbir yolla** girmez. `entityId` bir yetki-token'ı değildir (0002 K2-E3).

**K3-F3 — Tombstone muafiyeti korunur.** ADR 0002 K2-C7'nin içeriksiz "kapsamdan çıktı" tombstone'u `old_scope_id` yetkisiyle geçmeye devam eder (K2-E3/Y1). Bu muafiyet **daraltılmaz ve genişletilmez**.

### G. Pull-authz [K2-E3 aktivasyonu]

**K3-G1 — `changes` actor kapsamına daralır.** `/v1/sync` pull'u yalnız actor'ın owner olduğu entity'lerin değişimlerini döndürür (bu dilimde **collaborator YOK** — işbirliği dilimine ait, K8-a). Filtre **Application** katmanındadır, dispatch yönlendirmesinden ayrıdır (K2-F1/G2).

**K3-G2 — ⚠ İMLEÇ SIZINTISI [yeni bulgu, ADR 0002'de ele alınmamıştı].** İmleç `(commit_xid, server_seq)` **küresel** bir sıradır; başka kullanıcıların yazımları da onu ilerletir. Yetki filtresi imlecin **kendisine değil**, döndürülen satırlara uygulanırsa, A kullanıcısı imlecin ne kadar sıçradığına bakarak **sistemdeki toplam yazma hacmini** çıkarabilir. Bu bir veri sızıntısı değil, bir **yan-kanal**dır; kapsamı düşüktür. **Karar: kabul edilir ve BEYAN EDİLİR** (imleç semantiği bozulmadan kapatılamaz — ufuk tabanlı imleç ADR 0002'nin taç mekaniğidir). *Gizlenmiş sınır değil, adlandırılmış sınır.*

### H. `clientId → principal` bağı [M-C aktivasyonu]

**K3-H1 — `sync_client_clock` kullanıcıya bağlanır.** Tabloya `user_id` eklenir; bir `client_id` ilk görüldüğü principal'a **bağlanır** ve başka bir principal tarafından kullanılamaz (`403`). *Gerekçe:* bağ olmadan B kullanıcısı A'nın `client_id`'siyle HLC saatini ileri sürüp (`MAX_FORWARD_SKEW` sınırları içinde) A'nın yazımlarını sistematik olarak kaybettirebilir — **çapraz-kullanıcı saat zehirlenmesi**. ADR 0002 §6/7 bunu "non-spoof varsayımı" diye adlandırmıştı; varsayım burada **kaldırılır**.

### I. Sırlar [red line #1]

**K3-I1 — İmzalama anahtarı repoya GİRMEZ.** Geliştirmede `dotnet user-secrets`, üretimde ortam değişkeni. **Varsayılan/gömülü anahtar YOKTUR.**
**K3-I2 — Anahtar yoksa uygulama AÇILMAZ (fail-fast).** Eksik veya 32 bayttan kısa anahtarda başlangıçta `InvalidOperationException`. *Gerekçe:* "geliştirme kolaylığı" için üretilen sessiz varsayılan anahtar, üretime sızdığında tüm kimlik sistemini geçersiz kılar. **Isıran kapı: anahtarsız başlatma denemesi patlamıyorsa test KIRILMALI.**

### J. Uçlar + kaba kuvvet

**K3-J1 — Uçlar.** `POST /v1/auth/register` · `/v1/auth/login` · `/v1/auth/refresh` · `/v1/auth/logout`. Bunlar `AllowAnonymous`; **diğer her uç deny-by-default** (K-D5). `/health/live`,`/health/ready` anonim kalır (K-D2).

**K3-J2 — Hız sınırlama [Onur kilidi, 25 Tem 2026].** `Microsoft.AspNetCore.RateLimiting` (**çerçevede yerleşik — yeni NuGet bağımlılığı YOK**, red line #3 tetiklenmez). `/login` ve `/refresh` için sabit pencere; anahtar = **IP + normalize e-posta** birleşimi. Aşımda `429` + `Retry-After`. *Hesap KİLİTLEME değildir* — kilitleme, saldırganın kurbanın hesabını kasten kilitlemesine (DoS) izin verir ve K8-d ile kapsam dışıdır.

**K3-J3 — Kaba-kuvvet yanıtı da tek tiptir.** `429`, kullanıcının var olup olmadığını ele vermez (K3-B5 ile aynı ilke).

### K. Elenen ve kapsam dışı [ADLANDIRILDI]

**K3-K1 — ASP.NET Core Identity KULLANILMAZ [K8-d].** *Gerekçe:* Identity, `DbContext`'i `IdentityDbContext`'e çevirir, Infrastructure tiplerini yukarı iter ve 7 tablosunun 5'i bu kapsamda kullanılmaz ⇒ **mevcut NetArchTest kapıları gevşetilir veya istisna alır. Kendi kurduğun kapıyı üçüncü parti için gevşetmek, kod kalitesi ölçen bir ödevde verilebilecek en kötü sinyaldir.** Kapsam darken (parola sıfırlama/2FA/kilitleme yok) elle implementasyon ~200-300 satırdır. *Reddedilen: melez `PasswordHasher<T>` — hash kararını fiilen PBKDF2'ye kilitlerdi.*

**K3-K2 — İLKE: KRİPTO PRİMİTİFİNİ YAZMAYIZ, AKIŞI YAZARIZ.** Argon2id, SHA-256, JWT imzası, CSPRNG — hepsi dışarıdan (paket veya BCL). Elle yazılan şey yalnız **akıştır**: kayıt, giriş, döndürme, yeniden-kullanım tespiti, yetki. Bu ADR'de **hiçbir kriptografik primitif implemente edilmemektedir.**

**K3-K3 — Kapsam dışı [adlandırılmış]:** parola sıfırlama · e-posta doğrulama · OAuth/sosyal giriş · 2FA · RBAC/roller · hesap kilitleme · collaborator/paylaşım yetkisi (işbirliği dilimi) · anlık erişim-token'ı iptali (kara liste).

---

## 3. Isıran kapılar (kör kapı YOK)

Her kapı, kaldırıldığında testi **kırdığını** mutantla kanıtlar. Aşağıdaki tablo `GOREV-slice-3a-auth` spec'inin mutant listesinin çekirdeğidir.

| # | mutasyon | ısırması ZORUNLU davranış |
|---|---|---|
| **M1** | Tüketilmiş yenileme token'ı kabul edilir (reuse-detection kaldırılır) | *"tüketilmiş token ikinci kez sunulunca aile iptal olur"* testi **FAIL** |
| **M2** | Yetki `token.sub` yerine `WireOp.ActorId`'den okunur (F5 ihlali) | *"sahte ActorId ile başkasının entity'sine yazma reddedilir"* **FAIL** |
| **M3** | EF global query filter kaldırılır | *"B kullanıcısı A'nın görevini görmez"* **FAIL** |
| **M4** | `ToLowerInvariant` → `ToLower()` (kültüre duyarlı) | tr-TR kültürü zorlanmış test: *"`I@x.com` ve `i@x.com` aynı hesaba düşer"* **FAIL** |
| **M5** | Rehash-on-login kaldırılır | *"eski parametreli hash girişten sonra güncel parametreye taşınır"* **FAIL** |
| **M6** | `FixedTimeEquals` → `SequenceEqual` | banned-API analizörü **derlemeyi kırar** |
| **M7** | Bilinmeyen e-postada dummy hash koşulmaz | *"var olan ve olmayan hesap için süre farkı eşiğin altında"* **FAIL** |
| **M8** | İmzalama anahtarı yokken varsayılan üretilir | *"anahtarsız başlangıç patlar"* **FAIL** |
| **M9** | `client_id ↔ user_id` bağı kaldırılır | *"başka kullanıcının client_id'siyle saat ileri sürme reddedilir"* **FAIL** |
| **M10** | `IgnoreQueryFilters()` allowlist dışında çağrılır | banned-API analizörü **derlemeyi kırar** |
| **M11** | Rate limiter kaldırılır | *"N+1'inci giriş denemesi 429"* **FAIL** |
| **M12** | Yenileme token'ı DB'ye ham yazılır (hash'lenmez) | *"DB'deki değer istemcideki token'a eşit değil"* **FAIL** |

> **KURAL [K6 tavanına TABİ DEĞİL]:** her mutant **gerçekten koşulur**; "beklenir" diye akıl yürütmeyle KANIT yazılmaz (slice-2b1 BULGU-1 dersi).

---

## 4. Gerekçe

Bu dilimin değeri "kimlik doğrulama eklendi"de değil, **iki ADR'nin adlandırarak biriktirdiği dört borcun aynı anda kapanmasında**dır. `ICurrentUser`, owner filtresi, push-authz ve pull-authz birbirinin önkoşuludur: owner filtresi kimliksiz kurulamaz, push-authz owner alanı doğrulanmış bir kaynaktan gelmeden anlamsızdır, pull-authz olmadan çok-kullanıcılı demo veri sızdırır. Dördünü ayrı dilimlere bölmek, aralarındaki her sınırı iki kez yazmak demekti.

Token modelinde **opak + DB + döndürme** seçimi konforu değil **kanıtlanabilirliği** hedefler: stateless bir yenileme JWT'si iptal edilemez, dolayısıyla üzerine ısıran bir kapı kurulamaz. Yeniden-kullanım tespiti ise ölçülebilir bir davranıştır — mutantla kırılır, testle yakalanır. Bu projede bir mekanizmanın "kapı kurulabilir olması" onun seçilme gerekçelerinden biridir.

Parola tarafında asıl mimari iş **paket seçimi değil, paketin izolasyonu**dur. Kapı, aktif bakımlı adayın (NSec) hedef platformda güvenli parametrelerle koşamadığını, dormant adayın (Konscious) koştuğunu ölçtü — yani "en iyi bakılanı seç" sezgisi bu vakada **yanlış paketi seçerdi**. Buna verilen cevap paketi savunmak değil, `IPasswordHasher` portu + kendini tarif eden hash string'i + rehash-on-login ile **paketi değiştirilebilir kılmak**tır.

Türkçe locale kararı (K3-A2) bu projeye özgü ve **ölçülmüş** bir risktir: aynı makinede aynı locale Postgres `initdb`'yi zaten kırdı. Kültüre-duyarlı bir `ToLower()` çağrısı, testleri invariant kültürde koşan bir CI'da **asla görünmeyecek** bir kimlik hatası üretirdi.

## 5. Alternatifler

| Eksen | Seçilen | Reddedilen (gerekçe) |
|---|---|---|
| Kimlik altyapısı | Elle ince implementasyon | ASP.NET Core Identity (katman baskısı, kullanılmayan 5 tablo, kapı gevşetme) |
| Parola KDF | Argon2id (Konscious, izole) | Isopoh (**lisans belirsiz**: CC-BY / NOASSERTION / CC0) · NSec-libsodium (**OWASP parametrelerinde koşmadı**, p yalnız 1) · PBKDF2 (K8-c yedeği; kapı geçtiği için tetiklenmedi) |
| Yenileme token'ı | Opak + DB + döndürme + reuse-detection | Stateless JWT-refresh (iptal edilemez, kapı kurulamaz) · tek uzun ömürlü JWT (çevrimdışı kuyruk kaybı) |
| JWT imzası | HS256 (simetrik) | ES256 (tek servis topolojisinde karşılıksız anahtar dağıtımı) |
| Owner izolasyonu | EF global filtre + `IgnoreQueryFilters` yasağı | Yalnız açık depo filtresi (unutulan tek sorgu = sızıntı) · ikisi birden (mutant tek katmanı kaldırınca test yeşil kalır ⇒ **ölü tuzak**) |
| Kaba kuvvet | Hız sınırlama (yerleşik) | Hesap kilitleme (kurbanı kilitleten DoS; K8-d dışı) · hiçbir şey (güvenlik denetçisinin ilk sorusu) |
| E-posta eşsizliği | `ToLowerInvariant` + `COLLATE "C"` unique index | `ToLower()` (tr-TR'de İ/ı ⇒ çift hesap) · `citext` (Postgres'e kilitler, `COLLATE "C"` ailesiyle tutarsız) |
| Yenileme yarışı | Atomik `UPDATE … WHERE consumed_at IS NULL` + 10 sn zarafet penceresi | Katı tek-kullanım (meşru istemciyi hırsız ilan eder) · kilitsiz kontrol-sonra-yaz (yarış) |

## 6. Riskler / açık noktalar

1. **`Konscious` ~25 ay hareketsiz** — adlandırılmış risk (K3-B1). Telafi: port + kendini tarif eden hash + rehash-on-login. **Tetikleyici:** pakete bir CVE düşerse PBKDF2'ye geçiş **tek sınıflık** iştir.
2. **Yenileme zarafet penceresi (10 sn)** — reuse-detection'ı zayıflatan yüzey. *Red-team'in özellikle kırmayı denemesi gereken yer.* Pencere içinde çalınmış token kullanılabilir; alternatifi meşru çevrimdışı istemciyi düşürmekti.
3. **İmleç yan-kanalı (K3-G2)** — kabul edildi ve beyan edildi; imleç semantiği bozulmadan kapatılamaz.
4. **Erişim token'ı anlık iptal edilemez** (≤15 dk pencere) — beyan edilmiş sınır; `sstamp` talebi ileride kanca bırakır.
5. **Argon2id 270 ms/istek** — giriş uçlarında CPU maliyeti gerçektir; dummy-hash (K3-B5) bunu bilinmeyen e-postalarda da ödetir. Hız sınırlama (K3-J2) bu maliyeti aynı zamanda bir DoS yüzeyi olmaktan çıkarır. **Bu iki kararın birbirini gerektirdiği kayda geçirilmiştir.**
6. **`sync_client_clock`'a `user_id` eklenmesi migration ister** — mevcut satırlar için backfill politikası spec'te netleşecek (bugün üretim verisi yok, pratikte boş tablo).
7. **RateLimiter'ın çok-instance davranışı** — bellek-içi sayaç tek instance'a özgüdür; yatay ölçekte dağıtık sayaç gerekir. Bu ödevin dağıtım modelinde (tek instance) sorun değil; **beyan edildi.**

## 7. İlgili

- **Öncül:** ADR 0001 (K-C1 `ownerId`, K-C5 `TimeProvider`, **K-D5**, K-H1 banned-API + NetArchTest) · ADR 0002 (**K2-E3** pull/push authz, K2-E5 op-başına txn + kısmi red, K2-A4 `sync_client_clock`, §6/7 **M-C**).
- **Kapatılan borçlar:** K-D5 ✓ · M-G ✓ · K2-E3 ✓ · M-C ✓ — **dördü de bu ADR'de aktive edildi** (K8-a).
- **Sıradaki:** bağımsız kapı (architecture + red-team) → Onur kilidi → `GOREV-slice-3a-auth` spec'i (**en çok İKİ denetim turu**, K6 tavanı) → Claude Code build → **Cowork TEMİZ OTURUMDA bağımsız doğrular**.
- **Sonra:** `slice-3b` (Flutter istemci) — bu ADR'in `IPasswordHasher`/token/owner kararları Drift şemasını ve depo katmanını doğrudan belirler.

---

*🟡 TASLAK v1 — KİLİTLİ DEĞİL. Bağımsız kapı koşmadı. Bu ADR'yi yazan el onaylayamaz.*

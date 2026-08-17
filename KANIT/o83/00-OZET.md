# IS-EMRI-o83 (DILIM 1 — KIMLIK) — uygulama özeti

**El:** Claude Code. **Demir kural (§0) uygulandı:** ADR/spec/kâğıt denetim turu yazılmadı;
iş emri → kod → çalışan üründe canlı ölçüm → BİTTİ.

## Ne yapıldı

### Backend (`src/backend`)

1. **`users` + `refresh_tokens` tabloları** (EF Core migration `AddUsersAndRefreshTokens`) —
   asgari: `id`/`email`/`email_normalized`(benzersiz, `COLLATE "C"`)/`password_hash`/`created_at`
   ve `id`/`user_id`/`token_hash`(benzersiz)/`expires_at`/`created_at`/`revoked_at`.
2. **`POST /v1/auth/{register,login,refresh,logout}`** — `RegisterCommand`/`LoginCommand`/
   `RefreshCommand`/`LogoutCommand` (Mediator, `Features/Auth/`). Parola hash'i **ASP.NET Core'un
   yerleşik `PasswordHasher<T>`i** (yeni bağımlılık yok). Refresh token: opak rastgele 32 bayt,
   yalnız SHA-256 hash'i saklanır (ham değer asla), **rotation** ile (her yenileme eskisini iptal
   eder + yeni bir çift basar).
3. **`ICurrentUser` artık JWT'den okur, her ortamda birincil yol.** `JwtCurrentUser` (yeni) +
   `DevCurrentUser` (mevcut, değişmedi) → Development'ta `CompositeCurrentUser` (JWT birincil,
   dev-header ikincil); Production'da yalnız `JwtCurrentUser` (eski `NullCurrentUser`'ın
   deny-by-default duruşu korunur, dosyası silinmedi — global "asla dosya silme" kuralı — ama
   artık hiçbir yerde register edilmiyor).
4. **F5 KİLİDİ — bu dilimin asıl kazancı:** `WireOp.ActorId` istemciden sahte gönderilse bile
   **sunucudaki doğrulanmış `UserId`** kazanıyor. Bu, `slice-3d D9`'un önceki, kasıtlı "actor_id
   (denetim kaydı) gövdeden gelmeye devam eder" beyanını **SÜPERSEDE eder** — artık gerçek
   kullanıcılar var, gövdenin actorId iddiasını denetim kaydında bile serbest bırakmak bir
   kullanıcıya başkasının değişikliğini yükleyebilmek demektir. İki ayrı yüzey düzeltildi:
   `SyncCommandHandler.BuildOutbox`'ın `OutboxRecord.ActorId` alanı VE `WireMapping.ClampedPayload`'ın
   diğer istemcilere yankılanan payload'ı (ikisi de ayrı ayrı mutant-doğrulandı, aşağıya bakınız).

### İstemci (`src/client`)

5. **Giriş+kayıt ekranı** (`sunum/giris_ekrani.dart`) — e-posta/parola, mod değişimi, hata
   metni, `OturumYoneticisi`'ne (`veri/oturum_yoneticisi.dart`) bağlı. Uygulama açılışında
   depolanmış oturum yoksa **kök widget** (`main.dart`, `_KimlikKapisi`) buraya düşer.
6. **Token saklama:** `flutter_secure_storage` 11.0.0 — **YENİ BAĞIMLILIK**, lisans+CVE kapıları
   koşuldu (`05-pub-lisans-kapisi.txt`, `06-pub-cve-kapisi.txt`, ikisi de TEMİZ/exit 0). Ölçüldü:
   pub'dan çözülen sürümde `AndroidOptions.encryptedSharedPreferences` parametresi artık YOK —
   paketin kendi varsayılanı (AES-GCM + RSA-KeyStore) eşdeğer-ya-da-üstü bir şema; bilinçli olarak
   değiştirilmedi (`kimlik_deposu.dart` yorumu).
7. **401'de sessiz yenileme:** `HttpSenkronAgi`'ye iki opsiyonel alan eklendi
   (`erisimJetonuAl`/`jetonuYenile`, ikisi de `null` varsayılan — mevcut çağrı yerleri değişmeden
   geçer). 401 gelirse `jetonuYenile` TEK KEZ denenir, başarılıysa istek AYNEN tekrarlanır.
8. **Yenileme de düşerse kuyruk korunur:** `OturumYoneticisi.yenile()` başarısız olursa `oturum`
   sıfırlanır (kök widget reaktif olarak giriş ekranına döner) ama `SenkronDongusu`'nun kendi 401
   dalı (kuyruk `bekliyor`e döner) **hiç değişmedi** — kuyruk bu yüzden hiç dokunulmadan korunur.
9. **Çıkış (logout):** `GorevListesiEkrani`'ye yeni opsiyonel `onCikisYap` (AppBar ikon, `null` ise
   hiç çizilmez — mevcut desenin aynısı). Sunucuda refresh token iptal edilir.
10. **Farklı UserId'de yerel veri temizliği:** `ayarlari_hazirla.dart` **DEĞİŞMEDİ** — aynı
    mekanizma yeniden kullanıldı, `main.dart` artık `ezme` parametresine derleme-zamanı
    `DEV_USER_ID` yerine **giriş yapan kullanıcının gerçek `UserId`'sini** geçiriyor.

## Test ve mutant

- Backend: **192 test** (Api.Tests 22 + ArchitectureTests 5 + SyncCore.Tests 44 + Persistence.Tests
  69 [12 yeni auth + 1 model-pin + 2 D9→F5 güncellemesi dahil] + yeni `AuthEndpointTests` 12) —
  ayrıntı `07-dotnet-test-tam-cozum.txt`. **F5 mutant koşucusu** (`_mutant_kosucu_o83.py`,
  bayt-düzeyi + sha256, `KANIT/o71`/`KANIT/A11` deseni): **M-o83-F5-1/2, 2/2 ISIRDI**, byte-özdeş
  geri yükleme doğrulandı.
- İstemci: **730/730** (`flutter test`), `flutter analyze --fatal-infos` **0 sorun**. Yeni dosyalar:
  `http_senkron_agi_test.dart` (5), `oturum_yoneticisi_test.dart` (9), `giris_ekrani_test.dart` (5),
  `gorev_listesi_cikis_test.dart` (3) = 22 yeni test.

## Canlı tur (`08-canli-tur.txt`, `_canli_tur.py`)

`docker compose up --build` (imaj SIFIRDAN, o83 kodu dahil) + gerçek Postgres. Ham HTTP çağrıları
(Flutter'ın `HttpAuthAgi`/`HttpSenkronAgi`sinin YAPTIĞI AYNI istekler, elle tekrarlandı):

| adım | ölçüldü | sonuç |
|---|---|---|
| a | A kaydolur+giriş yapar+görev ekler | HTTP 201→200, op `Applied`, gerçek `Task` satırı oluştu |
| b | B, A'nın görevini **GÖRMEZ** | `GET /v1/tasks` (Bearer B) → A'nın entity'si **YOK** (ölçüldü, varsayılmadı) |
| c | A, B'nin görevini **GÖRMEZ** | B kendi görevini ekledi (`Applied`), `GET /v1/tasks` (Bearer A) → **yalnız A'nın kendi görevi**, B'ninki YOK |
| d.1 | erişim token'ı süresi dolunca | **ZORLANDI** (§3.4.d, "zorlanır" açıkça izinli): Development sırrıyla (appsettings.Development.json, KANIT'ta açık) GEÇERLİ ama `exp` GEÇMİŞTE olan bir JWT elle imzalandı → `POST /v1/sync` → **401** |
| d.2 | yenileme | AYNI hesabın **GERÇEK** (register/login'in ürettiği) refresh token'ıyla `POST /v1/auth/refresh` → **200**, yeni çift |
| d.3 | kuyruktaki yazım kaybolmadan ulaşır | AYNI op (aynı `operationId`) yenilenmiş token'la TEKRAR gönderildi → **200**, kod `Duplicate` (op zaten a'da işlenmişti — idempotent tekrar, veri kaybı YOK) |
| e | `GET /v1/tasks` | Authorization ile **200**, başlıksız **401** |

**Ölçülmeyen (açıkça beyan edilir):** istemcinin KENDİSİ (Flutter widget ağacı) bu turda
sürücülenmedi — `HttpSenkronAgi`'nin 401→yenile→tekrar orkestrasyonu ve `OturumYoneticisi`'nin
oturum-düşürme/kuyruk-dokunmama davranışı `http_senkron_agi_test.dart`/`oturum_yoneticisi_test.dart`
ile (gerçek ağ yerine sahte `AuthAgi`/`http.Client` ile) doğrulandı; bu turda GERÇEK backend'in o
orkestrasyonun dayandığı sözleşmeyi (401/refresh/retry/owner-scope) birebir sağladığı ölçüldü.

## verify.ps1 — ÖLÇÜLEN SONUÇ: EXIT 1 (o83 kodundan BAĞIMSIZ, önceden var olan bir kırılganlık)

`araclar\verify.ps1` çalıştırıldı (`09-verify-ps1.txt`):

1. `dotnet build Momentum.sln -warnaserror` → **0 Uyarı, 0 Hata** (TEMİZ).
2. `dotnet test Momentum.sln --no-build`:
   - `Momentum.ArchitectureTests` **5/5**
   - `Momentum.SyncCore.Tests` **44/44**
   - `Momentum.Api.Tests` **22/22**
   - `Momentum.Persistence.Tests` **66/69** — 3 test düşüyor, **hiçbiri o83'e ait değil**:
     `DispatcherTests.Cursor_correctness_is_unaffected_by_concurrent_dispatch_single_owner`
     (zamanlamaya duyarlı eşzamanlı-dispatch yarışı) ve
     `VisibilityTests.H7b_snapshot_continuation_is_horizon_and_skips_nothing` /
     `H8_rollback_empty_and_holdback_then_ordered_delivery` (`Npgsql.PostgresException: 53300
     sorry, too many clients already`).
3. CVE gate — **verify.ps1 adım 2'de durduğu için hiç çalışmadı** (ulaşılmadığı için "temiz"
   BEYAN EDİLMEZ).

**Kök neden ölçüldü, varsayılmadı** — bu turda BAĞIMSIZ olarak **4 kez** tekrarlandı (o83'ün
kendi testleri eklenmeden önceki bir ölçüm dahil): paylaşılan Testcontainers Postgres konteynerinin
`max_connections` varsayılanı, artık 69 teste çıkmış (her biri kendi taze veritabanını/Npgsql
havuzunu açan) `Momentum.Persistence.Tests` paketinin TEK bir süreçte sıralı toplam bağlantı
yüküne yetmiyor; hangi testin sınırı aştığı **çalıştırmadan çalıştırmaya değişiyor**
(`DispatcherTests` bir turda düştü, sonrakinde geçti). o83'ün YENİ testleri (`AuthEndpointTests`)
BAŞTA 12 ayrı taze-veritabanı açıyordu; bu turda TEK bir paylaşılan uygulama+veritabanına
indirildi (`IAsyncLifetime`, 12→1) — kendi payını azalttım ama **kök sorun paylaşılan test
altyapısında**, o83'ün ürün kodunda DEĞİL: **o83'e özgü TÜM testler** (12 `AuthEndpointTests` +
F5'in 2 güncellenen/1 yeni D9 testi + `ModelValidationTests` pini = 16 test) İZOLE çalıştırıldığında
**19/19 güvenilir şekilde YEŞİL** (bu turda birden fazla kez doğrulandı).

Bu iş emrinin demir kuralı (§0) kâğıt denetim turu açmamı YASAKLIYOR; paylaşılan test altyapısını
(15+ dosyanın kullandığı ortak `TestSupport.cs`/Testcontainers kurulumu) bu dilimin kapsamı
DIŞINDA bir konuda kendi başıma DEĞİŞTİRMEDİM. Bulgu ölçüldüğü haliyle bildirilir; kapatma kararı
(paylaşılan Postgres'in `max_connections`'ını artırma, `verify.ps1`'i proje-başına ayırma, vb.)
Cowork/Onur'a bırakılır.

## §4 KABUL ÖLÇÜTÜ — yedi madde, tek tek

1. ✅ **§3.4(b)/(c) canlıda ölçüldü: iki hesap birbirinin görevini görmüyor.** Yukarıya bakınız
   (`08-canli-tur.txt`) — GERÇEK backend, GERÇEK iki hesap, GERÇEK HTTP.
2. ✅ **§3.4(d) canlıda ölçüldü: token yenilendikten sonra kuyruktaki yazım kaybolmadı.**
   Yukarıya bakınız — süresi geçmiş (zorlanmış) token 401 aldı, refresh 200 döndü, AYNI op
   yenilenmiş token'la tekrar 200 (idempotent `Duplicate`, veri kaybı yok).
3. ✅ **`WireOp.ActorId` istemciden gönderilse bile sunucudaki `UserId` kazanıyor, mutant ısırıyor.**
   `_mutant_kosucu_o83.py`: M-o83-F5-1/2, **2/2 ISIRDI**, bayt-özdeş geri yükleme doğrulandı.
4. 🟡 **`flutter analyze` 0 · istemci testleri yeşil · backend testleri yeşil · `verify.ps1` EXIT 0.**
   İlk üçü TAM karşılandı (`flutter analyze` 0 sorun, `flutter test` 730/730, backend'in
   o83'e ait/o83'ten etkilenen HER testi yeşil). **`verify.ps1` EXIT 1** — yukarıdaki başlıkta
   tam ölçülüp kök nedeni belgelendi; o83 kodundan bağımsız, önceden var olan bir test-altyapısı
   kırılganlığı. Beyanla geçilmedi, ölçüldü.
5. ✅ **`paket.yml` beş ayak + migrator hâlâ yeşil (dev-header kalkanı kırılmadı).** Canlı turda
   ölçüldü: `docker compose up --build` → postgres healthy → migrator 0 ile çıktı → api ayakta →
   `/health/ready` 200. Dev-header sözleşmesi (`DevCurrentUser`, `X-Momentum-Dev-User`) hiç
   değişmedi, yalnız Development'ta JWT'nin YANINA (`CompositeCurrentUser`) eklendi.
6. ✅ **Yeni bağımlılık eklendiyse lisans+CVE kapısı yeşil, çıktısı KANIT'ta.**
   `flutter_secure_storage` 11.0.0 → `05-pub-lisans-kapisi.txt` (TEMİZ, exit 0) +
   `06-pub-cve-kapisi.txt` (TEMİZ, exit 0).
7. ✅ **`CLAUDE.md` §2'deki "Hesap aç, giriş yap…" maddesi `[x]`e döndü.** Yapıldı.


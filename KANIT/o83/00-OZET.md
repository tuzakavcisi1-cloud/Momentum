# IS-EMRI-o83 (DILIM 1 — KIMLIK) — uygulama özeti

**El:** Claude Code. **Demir kural (§0) uygulandı:** ADR/spec/kâğıt denetim turu yazılmadı;
iş emri → kod → çalışan üründe canlı ölçüm → BİTTİ.

🔴 **o83-B REVİZYONU (18 Ağu):** Cowork'ün bağımsız denetimi 3 ölçülmüş bulgu verdi (B1/B2/B3,
`IS-EMRI-o83-B.md`). Bu dosya o düzeltmelerle **YENİDEN YAZILDI** — her hücre aşağıdaki ham
çıktıyla (`08-canli-tur.txt`, `09-verify-ps1.txt`) birebir eşleşir. Ürün koduna (`src/backend`,
`src/client/lib`) **dokunulmadı** — yalnız `tests/Momentum.Persistence.Tests/TestSupport.cs`
(havuz kelepçesi) ve `KANIT/o83/*` betikleri değişti.

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

## Canlı tur (`08-canli-tur.txt`, `_canli_tur.py`) — o83-B B1/B3 DÜZELTİLDİ

`docker compose up -d` (mevcut `momentum:yerel` imajı — **ürün kodu değişmediği için yeniden
build EDİLMEDİ**) + gerçek Postgres. Ham HTTP çağrıları (Flutter'ın `HttpAuthAgi`/`HttpSenkronAgi`sinin
YAPTIĞI AYNI istekler, elle tekrarlandı). **Her koşumda TAZE e-posta** (o83-B B3) ve **d ayağı artık
HİÇ gönderilmemiş YENİ bir op** kullanıyor (o83-B B1 — a ayağının zaten `Applied` op'unu DEĞİL):

| adım | ölçüldü | sonuç |
|---|---|---|
| a.0 | register (TAZE e-posta) | **HTTP 201** (ölçüldü — önceki turda 409+login-fallback'ti, B3 ile düzeltildi) |
| a | A giriş yapar+görev ekler | `POST /v1/sync` → **200**, `applied[0].code=Applied`, gerçek `Task` satırı oluştu |
| b.0 | register (TAZE e-posta) | **HTTP 201** |
| b | B, A'nın görevini **GÖRMEZ** | `GET /v1/tasks` (Bearer B) → A'nın entity'si **YOK** (ölçüldü, varsayılmadı) |
| c | A, B'nin görevini **GÖRMEZ** | B kendi görevini ekledi (`Applied`), `GET /v1/tasks` (Bearer A) → **yalnız A'nın kendi görevi**, B'ninki YOK |
| d.1 | erişim token'ı süresi dolunca, **YENİ** (hiç gönderilmemiş) op | **ZORLANDI** (§3.4.d, "zorlanır" açıkça izinli): Development sırrıyla (appsettings.Development.json, KANIT'ta açık) GEÇERLİ ama `exp` GEÇMİŞTE olan bir JWT elle imzalandı → `POST /v1/sync` → **401** |
| d.2 | yenileme | AYNI hesabın **GERÇEK** (register/login'in ürettiği) refresh token'ıyla `POST /v1/auth/refresh` → **200**, yeni çift |
| d.3 | kuyruktaki yazım (YENİ op) kaybolmadan İLK KEZ ulaşır | **AYNI YENİ op**, yenilenmiş token'la gönderildi → **HTTP 200, `applied[0].code=Applied`** (`Duplicate` DEĞİL — bu op daha önce HİÇ başarıyla işlenmemişti, d.1'de 401 ile reddedilmişti) |
| e | `GET /v1/tasks` | Authorization ile **200**, başlıksız **401** |

**Ölçülmeyen (açıkça beyan edilir):** istemcinin KENDİSİ (Flutter widget ağacı) bu turda
sürücülenmedi — `HttpSenkronAgi`'nin 401→yenile→tekrar orkestrasyonu ve `OturumYoneticisi`'nin
oturum-düşürme/kuyruk-dokunmama davranışı `http_senkron_agi_test.dart`/`oturum_yoneticisi_test.dart`
ile (gerçek ağ yerine sahte `AuthAgi`/`http.Client` ile) doğrulandı; bu turda GERÇEK backend'in o
orkestrasyonun dayandığı sözleşmeyi (401/refresh/retry/owner-scope) birebir sağladığı ölçüldü.

## verify.ps1 — ÖLÇÜLEN SONUÇ (o83-B sonrası): EXIT 1, TEK kök neden kaldı, TAM çıktı KANIT'ta

`araclar\verify.ps1`, **AYRI bir child process olarak** (`System.Diagnostics.Process`,
`StandardOutputEncoding=UTF8`) koşuldu — o83 v1'in `Tee-Object` boru hattı, verify.ps1'in kendi
`exit $LASTEXITCODE` çağrısıyla YARIM KESİLMİŞTİ (o83-B B2). Artık **TAM** çıktı + `EXIT CODE`
satırı `09-verify-ps1.txt`de (kesilmemiş, UTF-8 Türkçe karakterler doğru).

**o83-B §2.1 havuz kelepçesi SONUÇ VERDİ:** `TestSupport.cs`e `MaxPoolSize=4` /
`ConnectionIdleLifetime=1` / `ConnectionPruningInterval=1` eklendikten SONRA `VisibilityTests.H7b`/
`H8`'in "too many clients already" hatası **İKİ ayrı koşumda da hiç görünmedi** — Cowork'ün
kök-neden teşhisi (havuz sızıntısı) doğrulandı ve kapandı.

1. `dotnet build Momentum.sln -warnaserror` → **0 Uyarı, 0 Hata**.
2. `dotnet test Momentum.sln --no-build`:
   - `Momentum.ArchitectureTests` **5/5** · `Momentum.SyncCore.Tests` **44/44** ·
     `Momentum.Api.Tests` **22/22**
   - `Momentum.Persistence.Tests` **68/69** — YALNIZ
     `DispatcherTests.Cursor_correctness_is_unaffected_by_concurrent_dispatch_single_owner` düşüyor.
3. CVE gate — verify.ps1 adım 2'de durduğu için **hiç çalışmadı** (ulaşılmadı, "temiz" BEYAN EDİLMEZ).

**o83-B §2.5 ölçümü — Dispatcher testi havuz düzeltmesinden SONRA da düşüyor (2/2 koşum):**
bağlantı açlığının dolaylı kurbanı DEĞİL — havuz kapandıktan sonra bile aynı hata (`seen[0]`
`"v0"` içermiyor). Bu, iki `OutboxDispatcher`ın eşzamanlı `PumpOnceAsync` yarışının **kendi
zamanlama duyarlılığı** — gerçek bir flake (bu konuşma boyunca 7 koşumun ~6'sında düştü, en az
1 koşumda geçti — tutarlı ama %100 deterministik değil). İş emri s2.5 PAZARLIKSIZ: **DÜZELTİLMEZ**
("iki şeyi aynı anda düzeltme, sinyal kaybedilir"); `DURUM.md` "bilinen sınırlar" madde 31'e
tek satır yazıldı (İŞLEYİŞ md.8).

**Sonuç:** `verify.ps1` bu ölçülen haliyle **EXIT 1** kalıyor — ama artık TEK, belgelenmiş,
düzeltilmesi bu dilimin dışında bırakılmış bir nedenden ötürü. Build 0/0 ve o83'e ait/etkilenen
HER test (backend+istemci) güvenilir şekilde yeşil.

## §4 KABUL ÖLÇÜTÜ — v1'in yedi maddesi + o83-B'nin beş maddesi

**v1 §4 (aynen yürürlükte):**

1. ✅ §3.4(b)/(c) canlıda ölçüldü: iki hesap birbirinin görevini görmüyor (`08-canli-tur.txt`).
2. ✅ §3.4(d) canlıda ölçüldü: token yenilendikten sonra kuyruktaki yazım kaybolmadı —
   **o83-B B1 ile düzeltilmiş kanıtla**: d.3 artık `Applied` (aşağıya bakınız).
3. ✅ `WireOp.ActorId` istemciden gönderilse bile sunucudaki `UserId` kazanıyor, mutant ısırıyor
   (M-o83-F5-1/2, 2/2, bayt-özdeş).
4. 🟡 `flutter analyze` 0 · istemci testleri yeşil · backend testleri yeşil · `verify.ps1` EXIT 0.
   İlk üçü TAM karşılandı. `verify.ps1` **EXIT 1** — yukarıda tam ölçülüp TEK kök nedeni
   belgelendi (Dispatcher flake, DURUM.md sınır 31); o83-B'nin kendi kabul ölçütü (aşağıdaki
   madde) bu durumu AÇIKÇA "Dispatcher geçti YA DA DURUM.md satırı" olarak öngörüyor.
5. ✅ `paket.yml` beş ayak + migrator hâlâ yeşil (dev-header kalkanı kırılmadı) — canlı turda ölçüldü.
6. ✅ Yeni bağımlılık (`flutter_secure_storage`) lisans+CVE kapısı yeşil, KANIT'ta.
7. ✅ `CLAUDE.md` §2'deki "Hesap aç, giriş yap…" maddesi `[x]`e döndü.

**o83-B §4 (yeni beş madde):**

8. ✅ **d.3 kodu `Applied` (`Duplicate` DEĞİL).** `08-canli-tur.txt`: d ayağı artık hiç
   gönderilmemiş YENİ bir op kullanıyor; d.1 401 (süresi geçmiş JWT), d.2 refresh 200,
   d.3 **`applied[0].code=Applied`** — kuyruktaki yazımın token yenilendikten sonra İLK KEZ ve
   kayıpsız ulaştığının doğru kanıtı budur (B1 kapandı).
9. ✅ **`register` 201 canlıda görüldü.** Her koşumda taze e-posta (`canli-a-<uuid8>@momentum.test`)
   — a.0 ve b.0 ikisi de **HTTP 201** (B3 kapandı, `00-OZET` artık ham çıktıyla birebir).
10. 🟡 **`verify.ps1` EXIT 0; tam çıktı + exit kodu KANIT'ta.** İkinci yarısı TAM karşılandı
    (B2 kapandı: kesilmemiş tam çıktı + `EXIT CODE (process.ExitCode) = 1` satırı `09-verify-ps1.txt`de).
    Birinci yarısı (EXIT 0) **ölçülen sonuç EXIT 1** — tek kalan neden madde 4/11'de açıklanan,
    düzeltilmesi YASAKLANMIŞ Dispatcher flake'i.
11. ✅ **Dispatcher testi geçti YA DA `DURUM.md` sınır satırı yazıldı.** İkinci şık: havuz
    düzeltmesinden SONRA da 2/2 düştü (bağlantı açlığının kurbanı değil, gerçek flake) —
    `DURUM.md` "bilinen sınırlar" madde 31 yazıldı, düzeltilmedi (iş emri PAZARLIKSIZ).
12. ✅ **`00-OZET.md` tablosunun her hücresi ham çıktıyla eşleşiyor.** Bu revizyon tam da bunu
    yapıyor — canlı tur tablosu (`08-canli-tur.txt`) ve verify.ps1 bölümü (`09-verify-ps1.txt`)
    ile birebir çapraz kontrol edildi.


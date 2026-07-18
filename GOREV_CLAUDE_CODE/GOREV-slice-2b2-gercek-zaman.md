# GÖREV (Claude Code) — slice-2b2: Sinyal yayıncısı + SignalR + üyelik (gerçek zaman)  [v4]

> **DÖRT TUR bağımsız denetimden geçti:** v1 → (mimari denetçi + red-team: 8 bloker + 12 majör) → v2 → (hedefli doğrulama: 6 kalan bloker + 10 yeni bulgu) → v3 → (ikinci hedefli doğrulama: **4 kalan bloker + 6 bulgu**) → v4.
> v1'in kusuru: bu dilim 2b1'in **kör kapı** bulgusunu kapatmak için açılmıştı ama kendi amiral kapısını (H9/`SKIP LOCKED`) aynı körlükle yeniden üretiyordu.
> v2'nin kusuru daha incelikliydi: kapılar ölçülebilirdi ama **9 mutantın 3'ü ispatlanabilir biçimde ısırmıyordu** (biri, v2'nin kendi lease düzeltmesinin yan etkisiyle öldü) ve hub-reddi testinin assert yüzeyi SignalR'ın gerçek davranışıyla çelişiyordu.
> v3'ün kusuru daha da incelikliydi: düzeltmeler doğruydu ama **test-seed yolu** (`Db.cs`) yeni saat pinini deliyordu, D8-v'in ikinci fazı **append-only outbox'ta kurulamıyordu**, mutant-7'nin ısırması için gereken fixture satırı şart koşulmamıştı ve mutant-9'un interleaving'i pinlenmediği için **flake** olacaktı.
> **v4 dördünü de kapatır ve v3'ün "mutantsız" ilan ettiği iki kapıyı geri mutantlar** (kolaycılık düzeltmesi). Semantik pinleri BİREBİR uygula; kırmızı gördüğün testi sessizce zayıflatma.

- **Kaynak kararlar:** `docs/ADR/0002-senkron-mekanigi.md` (KİLİTLİ v3 — K2-C7, E3, F1/F2/F3, G1/G2/G3, H9) + `docs/ADR/0001-genel-mimari.md` (K-C4, K-D2, K-G1).
- **Rol:** Sen **build** edersin. `PROJE_HAFIZA.md` ve `docs/ADR/*`'a **DOKUNMA**. Cowork artefaktı bağımsız doğrular (H9'u, D0'ı ve TÜM mutantları KENDİ koşarak).
- **Dil:** Kod/isimler İngilizce; commit mesajı **ASCII**.
- **Onur kilidi (oturum 6):** (1) dispatcher SignalR'a doğrudan yazmaz → **`ISignalPublisher` portu**; (2) hub **deny-by-default**; (3) üyelik **`IScopeMembershipSource`** portu arkasında.
- Testler Docker İSTER; Docker'sız koşuda fail = doğru davranış (skip/kör-kapı YOK).

## 0. Önce oku
`CLAUDE.md` · `PROJE_HAFIZA.md` (oturum-6 devri) · ADR 0002 (tamamı) · `GOREV-slice-2b1-kalicilik-sync.md` · `KANIT/slice-2b1/cowork-bagimsiz-dogrulama.txt` (**§4 ve §5 — bu dilimin varlık sebebi**).

## 1. Kapsam — NE VAR / NE YOK

**VAR:** D0 GREATEST ayırt edici testi · `ISignalPublisher` · `OutboxDispatcher` (K2-F2, **lease'li talep**) · kısmi indeks migration'ı · SignalR hub (K2-G1 payload'suz dürtü) · grup yönlendirme `user:` + `scope:` + `scope:{old}` · `IScopeMembershipSource` + bağlantıda yeniden-hesap · C7 **sinyal ayağı** · G3 gerçek `HubConnection` ile · **H9 kapısı (gerçekten ısıran)** · **11 mutant** + KANIT.

**YOK — adlandırılmış erteleme (sessiz açık bırakma YASAK):**
- Gerçek kimlik/JWT + push-authz aktivasyonu (auth dilimi, K2-E3).
- **Redis backplane + yatay ölçek** (ADR §3).
- **K2-G2'nin "çıkarılan üye gruptan düşürülür" YARISI.** Gerekçe: `RemoveFromGroupAsync` **connectionId** ister; userId→connectionIds kayıt defteri + backplane gerektirir; ayrıca outbox'ta "çıkarılan üye" taşıyan kolon YOK (2b1 şeması: `owner_id`/`scope_id`/`old_scope_id`) ve collaborator op'u bu dilimde yok. **2b2 yalnız bağlantıda-yeniden-hesabı karşılar.**
- **K2-C7'nin pull ayağı (Y1 muafiyeti).** `SyncPuller.PullIncrementalAsync` hâlâ `owner_id = @actorId` ile filtreliyor; eski-scope üyesi tombstone'u **çekemez**. Bu dilim yalnız **sinyal ayağını** kapatır; hayalet tam olarak collab/auth diliminde kapanır.
- Outbox retention/budama · MessagePack · entity tabloları/CRUD · Flutter istemci.

## 2. Kesin yerleşim (kablolama DAHİL — v1 eksiğiydi)
- **Application:** `Abstractions/Sync/ISignalPublisher.cs` · `Abstractions/Sync/IScopeMembershipSource.cs` · `Features/Sync/SyncContracts.cs`'e `SignalEnvelope` (aşağıda).
- **Infrastructure:** `Sync/OutboxDispatcher.cs` (`BackgroundService`) · `Sync/OutboxClaimStore.cs` (**kendi `NpgsqlConnection`'ı**, aşağıda) · `Sync/ScopeMembershipSource.cs` · `Persistence/Migrations/*_DispatcherIndex.cs`.
- **Api:** `Realtime/SyncHub.cs` · `Realtime/SignalRSignalPublisher.cs` (portu `IHubContext<SyncHub>`'a bağlar — **yalnız Api**).
- **Kablolama:** `Api/Program.cs` (`AddSignalR`, `MapHub<SyncHub>("/hubs/sync")`, `ISignalPublisher`→`SignalRSignalPublisher`, **dispatcher kaydı yalnız DB yapılandırılmışsa** — D2-e) · `Infrastructure/DependencyInjection.cs` (`IScopeMembershipSource`, `OutboxClaimStore`).
- **Tests:** `tests/Momentum.Persistence.Tests/` (D0, dispatcher, H9, C7, G2, G3) · `tests/Momentum.Api.Tests/` (hub reddi).

## 3. Teslimatlar

**D0 — GREATEST ayırt edici testi [2b1'in KAPANIŞ KOŞULU — ÖNCE BUNU YAP].**
Cowork kanıtladı: `GREATEST(...)` → düz yazım, client-lock yerindeyken **21/21 testi yeşil bırakıyor** → K2-A4 pini **KÖR**.
- **Test:** `Client_clock_is_monotonic_at_storage_level_even_without_the_client_lock` (ad **kasten** eşzamanlılık ima etmez — bu tek-thread'li bir **depolama-değişmezi** testidir).
- **Kurgu:** (1) client C normal `/v1/sync` yolundan bir op yazar. **(2) Taban `sync_client_clock`'tan GERİ OKUNUR** (`H_base`) — gönderilen HLC değil! (clamp + düğüm-monoton bump nedeniyle ikisi farklıdır; taban okunmazsa test yanlış nedenle kırılır). (3) **Kilidi TUTMADAN** doğrudan `IClientClock.UpsertGreatestAsync(C, H_low)`, `H_low < H_base` → **assert: saat hâlâ `H_base`**. (4) **Ters yön:** `UpsertGreatestAsync(C, H_higher)` → saat `H_higher`.
- **Dürüstlük notu (spec-QA bulgusu):** adım-4'ün **bağımsız kapı yüzeyi yoktur** — GREATEST'in "yukarı" yönünü bozan mutasyonlar mevcut `H12_concurrent_same_client_ingest_no_lost_update` testini de kırar. D0'ın **yeni** kazancı adım-3'tür (mutant-1). Adım-4 yine de yazılır (regresyon değeri), ama KANIT'ta "bu mutant H12 üzerinden de ölüyor" **açıkça** yazılır.
- **D0-b (K2-A4'ün "atomik" iddiası — ayrı kapı). YARIŞ SIRASI KRİTİK [v3 düzeltmesi]:**
  conn1 `BEGIN` + `UpsertGreatestAsync(C, **H_high**)` (**commit YOK**) → conn2 `UpsertGreatestAsync(C, **H_low**)` (satır kilidinde bekler) → conn1 commit → conn2 çözülür → **assert: saat `H_high`** (yani conn2 saati geri çekemedi).
  GREATEST'te doğru. C#-tarafı oku-karşılaştır-yazda conn2 **kilitten önce bayat okur** (`SELECT` READ COMMITTED'da bloke olmaz), `H_low > bayat(boş/eski)` diye karar verir ve kilit çözülünce `H_low` yazar → **lost update → FAIL**.
  *(Ters sıra — conn1=`H_low`, conn2=`H_high` — ISIRMAZ: oku-karşılaştır-yaz da `H_high` yazardı. v2 bu hatalı sırayı yazmıştı.)*
  **INTERLEAVING PİNİ [v4 — KB-D, yoksa mutant-9 FLAKE olur]:** `Task.Run(conn2); await conn1.Commit();` YETMEZ — conn1 önce commit ederse conn2 **taze** okur, `H_low < H_high` görür, yazmaz → mutant ısırmaz **ve temiz koşum da yeşil olduğu için kırılganlık SESSİZ kalır**. Bu yüzden conn1 commit edilmeden **ÖNCE**, sınırlı bir bekleme döngüsüyle conn2'nin gerçekten satır kilidinde beklediği **doğrulanır**: `SELECT count(*) FROM pg_locks WHERE NOT granted` (veya `pg_stat_activity.wait_event_type = 'Lock'`) > 0 olana dek yokla, zaman aşımında testi FAIL et. Ancak ondan sonra conn1 commit edilir.
  **Altyapı notu:** `SyncTestApp`'te bugün "txn'i/scope'u açık tutan" bir yardımcı YOK; D0 adım-3 ve D0-b için eklenmesi gerekir (raporla).

**D1 — `ISignalPublisher` (Onur kilidi #1) — kısmi başarı ifade EDEBİLİR.**
```csharp
Task<IReadOnlyCollection<PublishFailure>> PublishAsync(
    IReadOnlyCollection<SignalEnvelope> signals, CancellationToken ct);
// PublishFailure { string Group }  — yalnız BAŞARISIZ gruplar döner; boş = tam başarı.
public sealed record SignalEnvelope(string Group, WireCursor CursorHint);
```
- **`Changed` alanı YOK** (v1'de daima `true` olan ölü alandı). `CursorHint` tipi **`WireCursor`** (Application'ın tel tipi) — Domain'in otoriter `SyncCursor`'ı **kullanılmaz**: "hint imleç değildir" pini böylece **tip düzeyinde** durur.
- Sinyal entity içeriği/payload/alan adı/aggregateId **TAŞIMAZ** (K2-G1).
- **Kısmi başarı ŞART:** 5 gruptan 3'ü yayınlanıp 2'si patlarsa, geri-açma **yalnız başarısız grupların satırlarına** uygulanır (v1 hepsini geri açıp `attempts`'i şişiriyordu).
- **Satır↔grup çözümü [v3 pin — YB-1]:** Bir satır **3 gruba kadar** yayınlanır (`user:`, `scope:`, `scope:{old}`). Kural: **bir satır, ait olduğu grupların HERHANGİ BİRİ başarısızsa KAPATILMAZ** (`signaled_at` NULL kalır, `available_at = @now + backoff`). Aksi halde başarısız gruba abone olan istemci için garanti **at-most-once**'a düşerdi ve D2-a'nın tüm gerekçesi çökerdi. Yinelenen sinyal payload'suz olduğu için zararsızdır; kayıp sinyal değildir.

**D2 — `OutboxDispatcher` (K2-F2) — RAW SQL; LEASE'li talep.**

**(a) Sıra — ADR K2-F2'nin ADLANDIRILMIŞ REFINEMENT'i.** ADR'nin literal sırası "yayınla → `signaled_at=now()`"dır. v1 bunu tersine çevirip (işaretle→yayınla) "at-least-once" diye etiketlemişti; **bu at-most-once'tır** (commit ile geri-açma arasında process ölürse satır kalıcı işaretli kalır, reaper yok). v2 **lease** kullanır:
```
-- Txn-1 (talep): satırı GÖRÜNMEZ yapar ama KAPATMAZ
UPDATE outbox_messages
   SET attempts = attempts + 1, available_at = @now + @lease
 WHERE id = ANY (SELECT id FROM outbox_messages
                  WHERE signaled_at IS NULL AND available_at <= @now
                  ORDER BY commit_xid, server_seq
                    FOR UPDATE SKIP LOCKED
                  LIMIT @batch)
RETURNING id, owner_id, scope_id, old_scope_id, commit_xid, server_seq;
COMMIT;
-- yayınla (D1) — txn DIŞINDA
-- Txn-2 (kapatma): yalnız BAŞARILI grupların satırları
UPDATE outbox_messages SET signaled_at = @now WHERE id = ANY(@okIds);
-- başarısız grupların satırları: available_at = @now + backoff(attempts) (lease kısaltılır/uzatılır)
```
Crash → **lease dolar → satır yeniden görünür → yeniden yayınlanır** (yinelenen sinyal payload'suz olduğu için zararsız) = **gerçek at-least-once**. `@lease = 30 sn`.
**Kalan arıza penceresi (adlandırılmış):** Txn-1 commit'i ile yayın arasında crash → satır lease süresi kadar gecikir, kaybolmaz.
**Yayının txn DIŞINDA olmasının gerekçesi (pin):** açık txn `pg_snapshot_xmin`'i pinler → `/v1/sync` imleç tazeliğini bozar (ADR §6 Risk#1). İleride kimse "yayını txn'e alalım" demesin.

**(b) TEK SAAT KAYNAĞI — SPEC-ERRATA. [v3'te GENİŞLETİLDİ — v2'nin en ölümcül açığı buradaydı]**
SQL'de **`now()` KULLANILMAZ**; `@now` parametresi `TimeProvider.GetUtcNow()`'dan gelir (talep, kapatma, backoff — hepsi).
**KRİTİK — kolon DEFAULT'u da yasağa dâhildir:** 2b1'de `outbox_messages.available_at` kolonunun **DB default'u `now()`**'dır (migration `20260718202450_InitialSync.cs`, `SyncConfigurations.cs`, ModelSnapshot — üç yerde). `OutboxWriter` bu kolonu yazmadığı için satır **DB saatiyle** doğar. Sahte saat (2000-01-01) ile DB saati (2026) karşılaştırıldığında talep koşulu `available_at <= @now` **daima FALSE** olur → dispatcher **0 satır** talep eder → **D8'in tüm dispatcher testleri mutasyondan ÖNCE kırılır**. Bu yüzden D6 migration'ı **default'u KALDIRIR** ve `OutboxWriter` `available_at = @now` yazar (EF configuration + ModelSnapshot da güncellenir). Doğrulama: `\d outbox_messages` çıktısında `available_at` satırında **Default sütunu BOŞ** olmalı — raporda göster.
Gerekçe: v1'de SQL `now()` + `TimeProvider` + "sleep yasak" üçlüsü aynı anda tutmuyordu. Bu, ADR K2-F2'nin literal `now()` yazımından **bilinçli sapmadır**. (`DateTime.UtcNow` yasağı SQL `now()`'ı görmez — bu boşluk burada kapanır.)

**(b2) Dağıtık-saat varsayımı (adlandırılmış).** Lease artık DB saatiyle değil **her process'in `TimeProvider`'ıyla** korunuyor. Bu dilim **tek-host**tur (Redis backplane/yatay ölçek §1'de YOK) → varsayım güvenlidir. Çok-host'ta saat kayması > `@lease` ise aynı satır çift talep edilir; sinyal payload'suz olduğu için **doğruluk bozulmaz**, yalnız yinelenir. Yatay ölçek diliminin yükümlülüğü olarak adlandırıldı.

**(c) Backoff:** `backoff(attempts) = min(2^attempts sn, 60 sn)`, `attempts` **artırıldıktan SONRAKİ** değerle (ilk hata → `attempts=1` → 2 sn). **`attempts` bir "talep sayacı"dır** (her Txn-1'de artar), hata sayacı DEĞİL — bu yüzden hiçbir assert "attempts arttı" üzerine kurulmaz (ölçmez).

**(d) Zehirli satır — kalıcı iskarta YOK; devre kesici de YOK.** v1 `attempts>=10 → kalıcı kapat` diyordu: yanlış arıza modeli (yayın hatası genelde satıra özgü değil publisher-geneldir → tüm kuyruk sessizce çöpe giderdi). v2 bunun yerine bir **devre kesici** icat etmişti; v3 onu da **kaldırır** çünkü (i) çivilenmiş tek Txn-1 SQL'iyle çelişiyordu (`attempts+1` koşulsuz) ve (ii) **hiçbir mutantı yoktu → kendisi kör bir kapıydı**. v3'ün kuralı sade: **hiçbir satır kalıcı iskartaya çıkarılmaz**; publisher-genelinde arıza tüm batch'i backoff'a sokar (tavan 60 sn) ve **WARN loglanır**. Yeni mekanizma yok → kör kapı yok.

**(e) Barındırma — mevcut testleri KIRMAMALI.** `OutboxDispatcher : BackgroundService` **singleton**'dır, sync portları `AddScoped`'tur → **doğrudan enjeksiyon YASAK**: dispatcher `IServiceScopeFactory` alır ve **her pump'ta `CreateAsyncScope()`** açar. Kayıt **yalnız gerçek bağlantı dizesi yapılandırılmışsa** yapılır (`Program.cs`; DB'siz host'ta kayıt YOK) ve `ExecuteAsync` **asla exception sızdırmaz** (yakala+logla+backoff) — aksi halde `BackgroundServiceExceptionBehavior.StopHost` DB'siz host'u öldürür ve `Api.Tests`'in 9 testi düşer. Test host'unda döngü **kapalıdır**; testler `PumpOnceAsync`'i elle sürer.

**(f) `PumpOnceAsync` sözleşmesi (KESİN — assert'ler ve mutant-8 buna dayanır):**
`public Task<int> PumpOnceAsync(CancellationToken ct)` → dönüş = **bu turda Txn-1'de TALEP EDİLEN (RETURNING'den dönen) satır sayısı**. Yayınlanan sinyal sayısı DEĞİL. Talep edilecek satır yoksa 0.
**İstisna sözleşmesi [v3 — mutant-8'in tek öldürme yolu]:** `PumpOnceAsync` istisnayı **SIZDIRIR, YUTMAZ** (DB hatası, `lock_timeout`, `CommandTimeout` → çağırana fırlar). Yalnız `ExecuteAsync` döngüsü yutar+loglar+backoff uygular (D2-e). Bu ayrım pazarlıksızdır: yutan bir `PumpOnceAsync` yazılırsa mutant-8 **sessizce geçer**.

**(g) `OutboxClaimStore` kendi `NpgsqlConnection`'ını açar** (paylaşımlı `SyncDbContext` bağlantısını KULLANMAZ). Gerekçe: iki dispatcher instance'ı aynı session'ı paylaşırsa kendi kilitlerini görmezler ve H9 **tautolojiye** döner.
**Zaman aşımı pinleri [v3]:** `lock_timeout` **bağlantı dizesinde** verilir — `Options=-c lock_timeout=5s` (oturum-başı `SET` havuzlanmış bağlantıda sıfırlanabilir, bu yüzden `SET` KULLANMA). Ayrıca `CommandTimeout = 10 sn`. Böylece mutant-8 **HANG değil, fırlayan istisna** üretir.

**(h) Poll aralığı:** boşta `1 sn + [0,250ms) jitter` (iki instance lockstep yoklamasın); iş varsa hemen tekrar.

**D3 — Grup yönlendirme (K2-F2 + C7).**
Satır başına gruplar: `user:{owner_id}` **her zaman** · `scope:{scope_id}` (NULL değilse) · `scope:{old_scope_id}` (NULL değilse — C7 çift-yayın).
**Aynı pump içinde** aynı gruba düşen satırlar **tek sinyale** indirgenir; `CursorHint` = o gruptaki **en büyük** `(commit_xid, server_seq)`. *(Pump-içi kural: LIMIT nedeniyle aynı grup ardışık pump'larda tekrar sinyallenebilir — zararsız, assert yazan yanılmasın.)* **Çok-instance'ta hint monoton DEĞİLDİR** (A `hint=10`, B `hint=5` yayınlayabilir) — zararsız, çünkü hint imleç değildir; adlandırıldı.

**D4 — SignalR hub (K2-G1/G3) + deny-by-default (Onur kilidi #2).**
- **`[Authorize]` KULLANMA.** Gerekçe (spec-QA, gerçek kod üzerinde doğrulandı): `Program.cs`'te `AddAuthentication`/`AddAuthorization` **yok** (dosya bunu bilinçli açıklıyor) → `[Authorize]`'lu endpoint **401 değil 500** üretir; şema eklemek auth dilimi işidir ve mevcut testleri kırar.
- **REDDİN YERİ = `negotiate` (v3 DÜZELTMESİ — v2 fiziksel olarak yanlıştı).** Doğrulayıcı denetçi ASP.NET Core 9 kaynağından kanıtladı: `HubConnectionHandler.OnConnectedAsync` **önce** handshake'i yazıp flush eder, **sonra** `Hub.OnConnectedAsync`'i çağırır. Yani `Context.Abort()` istemcinin `StartAsync`'ini **patlatmaz** — bağlantı başarıyla kurulur, sonra sessizce (`CloseMessage.Empty`) kapanır. v2'nin "assert yüzeyi `StartAsync` istisnası" pini **tutmuyordu**.
- **v4 pini (v3 "filtre veya middleware" diyordu — belirsizdi):** **MIDDLEWARE kullan, `AddEndpointFilter` DEĞİL.** Endpoint filtreleri route-handler ve controller builder'ları için belgelenmiştir; SignalR endpoint'i ham `RequestDelegate` üzerinden kurulur → `MapHub` üzerinde filtre desteklenen bir yol değildir. Yol-tabanlı `app.Use(...)`: `/hubs/sync` (+ `/negotiate`) için `context.RequestServices.GetRequiredService<ICurrentUser>()` çözülür, `UserId is null` → **401** ve kısa devre (auth şeması GEREKMEZ; `SyncEndpoints.HandleAsync`'in `Results.Unauthorized()` kalıbının rota-düzeyi karşılığı). Böylece `negotiate` 401 döner ve `HubConnection.StartAsync` **gerçekten** fırlatır → D8-vii ölçülebilir.
- `OnConnectedAsync` içindeki `Context.Abort()` **savunma-derinliği olarak KALIR**, ama **bağımsız kapı DEĞİLDİR** ve öyle raporlanmaz (2b1'in GREATEST dersi: kapı diye sunulan her şeyin ısırdığı kanıtlanmalı; kanıtlanamıyorsa savunma-derinliği diye adlandırılır).
- Testlerde kimlik **mevcut `FakeCurrentUser` + `ConfigureTestServices`** kalıbıyla verilir. **Test-only auth handler İCAT ETME** (v1'in "arch testi sızmayı doğrular" iddiası tautolojiydi: üretim assembly'si test assembly'sini zaten referans edemez).
- İstemciye giden tek çağrı: `Changed(SignalEnvelope)` — **payload YOK**.

**D5 — `IScopeMembershipSource` + bağlantıda yeniden-hesap (K2-G2 yarısı, Onur kilidi #3).**
`Task<IReadOnlyCollection<Guid>> GetScopesAsync(Guid userId, CancellationToken ct)`.
`OnConnectedAsync`: scope'lar **porttan yeniden hesaplanır** → `user:{userId}` + her `scope:{id}` grubuna eklenir.
**2b2 implementasyonu — SORGU BİREBİR PİNLİ (v3 DÜZELTMESİ):**
```sql
SELECT DISTINCT scope_id FROM outbox_messages
 WHERE owner_id = @userId AND scope_id IS NOT NULL;
```
v2 "`owner_id` **veya** `scope_id` olarak göründüğü" diyordu; `scope_id` bir **projectId**'dir, asla bir kullanıcı kimliği değildir → o dal **ÖLÜ**ydü ve onu hedefleyen mutant-7 hiçbir şey ısıramazdı. v3 sorguyu tek anlamlı hâle getirir.
**Bilinen davranışsal boşluk (spec-QA, açıkça adlandırılır):** paylaşılan bir projeye **hiç yazmamış salt-okur üye** hiçbir `scope:` grubuna girmez → yazana kadar gerçek-zamanlı sinyal almaz. Auth diliminde gerçek yetki tablosuna bağlanınca kapanır. Bu kod yorumuna DEĞİL, **rapora** da yazılır.
**İndeks:** sorgu `(owner_id, scope_id)` üzerinden gider → D6.

**D6 — Migration (yeni).**
1. **`available_at` DB-default'unu KALDIR** (`ALTER TABLE outbox_messages ALTER COLUMN available_at DROP DEFAULT;`) + `SyncConfigurations.cs`'teki `HasDefaultValueSql("now()")` kaldırılır + ModelSnapshot güncellenir. `OutboxWriter` artık `available_at` kolonunu `@now` (TimeProvider) ile **açıkça yazar**. **[D2-b'nin zorunlu tamamlayıcısı — bu yapılmazsa tüm dispatcher testleri sahte saat altında 0 satırla döner.]**
2. `CREATE INDEX ix_outbox_dispatch ON outbox_messages (commit_xid, server_seq) WHERE signaled_at IS NULL;` (talep sorgusu; kısmi indeks).
3. `CREATE INDEX ix_outbox_owner_scope ON outbox_messages (owner_id, scope_id) WHERE scope_id IS NOT NULL;` (D5 üyelik sorgusu).
`migrationBuilder.Sql` ile; EF model yalnız (1) için değişir. **Kabul:** `dotnet ef migrations has-pending-model-changes` **temiz** çıkmalı (elle ModelSnapshot düzenlemesi ile EF'in `AlterColumn` yolu çakışmasın).

**D6-b — TEST SEED'LERİ DE `now()` YASAĞINA TABİDİR [v4 — KB-A].**
`tests/Momentum.Persistence.Tests/Db.cs` içindeki `InsertOutboxAsync` yardımcısı bugün `available_at`'i **hiç yazmıyor** ve `occurred_at`'i SQL `now()` ile yazıyor. D6-1 default'u kaldırdığı anda bu helper **`23502 null value in column "available_at"`** verir → `VisibilityTests`'in 3 testi kırılır (kabul kriteri 2 spec'in kendi maddesi yüzünden ihlal edilir).
**Tuzak:** bunu "`available_at`'e `now()` ekleyerek" düzeltmek **KB-1'i test yolundan geri getirir** (satır DB saatiyle doğar, `@now` sahte saattir → dispatcher 0 satır talep eder) ve kabul kriteri 5b bunu **YAKALAMAZ** (default değil, açık değer).
**PİN:** `InsertOutboxAsync` hem `available_at` hem `occurred_at`'i **`TimeProvider`'dan gelen açık parametreyle** yazar. **Hiçbir test seed yolunda SQL `now()` KULLANILMAZ** (§5'in `now()` yasağı test yardımcılarını da kapsar).

**D7 — C7 **sinyal ayağı** (ADR K2-C7 — "uçtan uca" DEĞİL).**
Entity scope-A'dan scope-B'ye taşınır (2b1'in `H11_projectId_change_records_scope_and_old_scope_columns` testi kolonların yazıldığını zaten kanıtlıyor). **Assert: dispatcher HEM `scope:{A}` HEM `scope:{B}` gruplarına sinyal yayınlar.** Pull ayağı (Y1 muafiyeti) **bu dilimde YOK** — §1'de adlandırıldı; hayalet tam kapanmadı, kapanmış gibi raporlama.

**D8 — KAPILAR (hepsi ölçülebilir assert'lerle).**

**(i) H9 — çok-instance dispatcher [ADR K2-H9] — v1'in kör kapısı, YENİDEN TASARLANDI.**
Kurgu pinleri (hepsi ZORUNLU):
- **`@batch` üretimde = 100 (ADR K2-F2); testte 10'a düşürülür** (yapılandırmayla enjekte edilir — üretim değeri sessizce değişmesin). **N = 25 satır, 25 FARKLI `owner_id`** → satır↔grup **birebir ölçülebilir** (v1'de 50 satır tek owner'a düşebiliyor ve "kapsama TAM" assert'i ölçülemez oluyordu).
- İki `OutboxDispatcher` instance'ı, **her biri kendi scope'u/`NpgsqlConnection`'ı** ile (D2-g).
- **Determinist ÖRTÜŞME (üretim koduna kanca gerektirmez):** test **kendi bağlantısında** bir txn açar ve `SELECT id FROM outbox_messages WHERE signaled_at IS NULL ORDER BY commit_xid, server_seq LIMIT 10 FOR UPDATE SKIP LOCKED` ile 10 satırı **kilitli tutar**. Sonra `d1.PumpOnceAsync()` sürülür → **assert: bloke olmadan döner** ve talep ettiği küme kilitli kümeyle **KESİŞMEZ**. Test txn'i geri alınır → d1/d2 sırayla sürülür → kalanlar boşalır.
- **Ölçülebilir assert'ler:** (1) `PumpOnceAsync` dönüşlerinin **toplamı tam olarak N**; (2) drain sonrası fazladan pump **0** döner; (3) `count(*) WHERE signaled_at IS NULL = 0`; (4) yayınlanan **farklı grup** kümesi = 25 `user:` grubu, tam kapsama; (5) kilitli-küme kesişimi ∅; (6) drain döngüsü **üst sınırlı** (`maxPumps = ceil(N/batch)+3`, aşılırsa FAIL → mutant HANG değil FAIL üretir).
- **(i-b) İmleç doğruluğu yarısı [K2-H9'un atlanan yarısı] — AYRI FIXTURE (v3 düzeltmesi):** D8-i'nin fixture'ı **25 farklı owner** kullanır; `SyncPuller.PullIncrementalAsync` ise `owner_id = @actorId` filtreliyor → tek actor 25 değişimin **1**'ini görür, yani i-b o fixture'la **matematiksel olarak sağlanamaz**. Bu yüzden i-b **kendi fixture'ını** kullanır: **tek owner, N=25 satır**; iki dispatcher pump ederken `/v1/sync` artımlı `sinceCursor` döngüsü N değişimin **tamamını, sırayla, tam bir kez** döndürür.

**(ii) Payload sızıntısı YOK [K2-G1]:** yayınlanan `SignalEnvelope`'ların serileştirilmiş JSON'unda entity içeriği/alan adı/aggregateId yok — DTO şekli **ve** JSON üzerinde assert.

**(iii) Yayın hatası → lease ile yeniden yayın [D2-a]:** publisher ilk pump'ta **belirli bir grup için** patlar (kaydeden sahte publisher'a hata-listesi verilir — deterministik) → o grubun satırları **kapatılmaz** (`signaled_at IS NULL` — assert bunun üzerinedir, **`attempts` üzerine DEĞİL**: `attempts` bir talep sayacıdır, ölçmez); sahte saat backoff kadar ilerletilir; ikinci pump o satırları **yeniden talep eder ve yayınlar**. Başarılı grupların satırları **kapanmış kalır** (kısmi başarı, D1 + YB-1 kuralı).

*(v2'nin "devre kesici" kapısı v3'te KALDIRILDI — D2-d'ye bak: mutantsız olduğu için kendisi kör bir kapıydı.)*

**(v) G2 bağlantıda yeniden-hesap [D5] — arrange/act/assert AÇIK [v4'te iki pin eklendi]:**
**Arrange (ZORUNLU):** U kullanıcısı S kapsamında görünür olur (outbox satırı). **AYRICA ikinci bir kullanıcı V, ayrı bir scope T ile bir op yazar — bu "yabancı scope" satırı fixture'da ŞARTTIR** [KB-C]: `owner_id = @userId` filtresini kaldıran `mutant-7` ancak tabloda **başka kullanıcıya ait `scope_id NOT NULL` bir satır varsa** gözlemlenebilir bir fark üretir; `TestDatabase.CreateAsync` her teste taze DB verdiği için kazara bulaşma imkânsızdır. Bu satır yoksa mutant-7 **ısırmaz**.
**Faz-1:** U bağlanır → **eklendiği grup kümesi tam olarak `{user:U, scope:S}`** (T **girmemeli** — mutant-7'nin ısırma yüzeyi budur).
**Faz-2 [KB-B]:** U'nun S görünürlüğü kaldırılır. **Outbox append-only'dir** — task'ı başka projeye taşımak *yeni* satır ekler, eskisini silmez; dolayısıyla `SELECT DISTINCT scope_id WHERE owner_id=U` hâlâ `{S}` döner ve assert **temiz kodda bile FAIL ederdi**. Bu yüzden faz-2 arrange'ı **açık `DELETE FROM outbox_messages WHERE owner_id=@u AND scope_id=@s`** ile kurulur. *(Bu bir **test-arrange**'dır, dispatcher davranışı değil — §5'in "hiçbir outbox satırı kalıcı iskartaya çıkarılmaz" kuralı **dispatcher'ı** bağlar, testin fixture kurulumunu değil. Adlandırıldı.)* → U **yeniden bağlanır** → küme **`{user:U}`** (bayat değer değil, yeniden hesap).
**Gözlem mekanizması (pin, mock kütüphanesi GEREKMEZ):** `SyncHub` doğrudan örneklenir; `Hub.Groups`'a elle yazılmış **kaydeden `IGroupManager`**, `Hub.Context`'e sahte `HubCallerContext` atanır.

**(vi) G3 — gerçek `HubConnection` ile [K2-G3]:** istemci bağlanır → bağlantı **kesilir** → kesikken N op işlenir ve dispatcher sürülür → istemci **yeniden bağlanır** → **assert: hub yeniden-bağlanmada HİÇBİR ŞEY replay etmez (kaydeden istemci sahtesine 0 `Changed` çağrısı)**, buna karşılık `/v1/sync` `sinceCursor` ile N değişimin **tamamını** döndürür. *(v1'in versiyonu SignalR'a hiç dokunmuyordu → hub silinse bile yeşil kalırdı.)*

**(vii) Hub reddi:** kimlik yokken `HubConnection.StartAsync` **başarısız** (D4'teki `Context.Abort()` yolu).

**(viii) Dedup → tek sinyal [ADR K2-D3'ün bildirim yarısı]:** aynı `operationId` iki kez push edilir → 2b1 zaten tek outbox satırı garanti ediyor → dispatcher **tam 1** sinyal yayınlar.

**(ix) `CursorHint` = max [D3]:** tek gruba bilinen imleçlerle 3 satır → yayınlanan sinyalin hint'i **en büyüğü**.

**D9 — MUTANT KANITLARI (`KANIT/slice-2b2/`). Sayı değil KAPSAM pinlidir; aşağıdaki 11 zorunludur.**

**KANIT KURALI [PAZARLIKSIZ — 2b1'in BULGU-1'i tam burada doğdu]:**
KANIT dosyasına **yalnız gerçekten koşulmuş test-koşucu çıktısı** yazılır. Bir mutantı koşmadan "beklenir/ısırması gerekir" diye akıl yürütmeyle yazmak **YASAKTIR**. Her KANIT şunları içerir: (a) uygulanan mutasyonun tam diff'i, (b) **kırılan TÜM testlerin adı** + assertion satırı (yalnız hedef test değil), (c) `git checkout` sonrası yeşil koşum. Hedef test listede yoksa mutant **ısırmamıştır**. Hedef dışında kırılan testler varsa bu **açıkça** raporlanır (ayırt edicilik ölçüsü). Her mutant koşusu `--blame-hang-timeout 120s` ile sürülür.

1. `mutant-1-greatest-plain` — `GREATEST(excluded.hlc, sync_client_clock.hlc)` → `excluded.hlc` ⇒ **D0 adım-3 FAIL**. *(D0'ın gerçek yeni kapısı.)*
2. `mutant-2-greatest-never` — aynı ifade → `sync_client_clock.hlc` ⇒ **D0 adım-4 FAIL**. *(Bilinen: H12'yi de kırar — KANIT'a yaz.)*
3. `mutant-3-no-claim-guard` — talep alt-sorgusundan **`signaled_at IS NULL AND available_at <= @now` koşulunun TAMAMI** çıkar ⇒ **H9 assert-(1)/(2) FAIL** (dönüş toplamı N'i aşar / fazladan pump 0 dönmez). **[v3 DÜZELTMESİ:** v2 yalnız `signaled_at IS NULL`'ı kaldırıyordu; ama B1'in lease düzeltmesi sayesinde talep edilen satır `available_at = @now + 30sn` taşıdığından **ikinci filtre onu yine eliyordu** → mutant ısırmıyordu. Kendi düzeltmemin yan etkisiydi; doğrulayıcı yakaladı.]*
4. `mutant-4-no-reopen` — yayın hatasında geri-açma kaldırılır (satır kapatılır) ⇒ **D8-iii FAIL**.
5. `mutant-5-payload-in-signal` — `SignalEnvelope`'a outbox `payload`'u eklenir ⇒ **D8-ii FAIL**.
6. `mutant-6-no-old-scope-publish` — `scope:{old_scope_id}` yayını kaldırılır ⇒ **D7/C7 FAIL**.
7. `mutant-7-membership-no-owner-filter` — D5 sorgusundan **`owner_id = @userId`** koşulu çıkarılır (tüm scope'lar döner) ⇒ **D8-v FAIL** (U'nun grup kümesi `{user:U, scope:S}` olmalıyken yabancı scope'lar da girer). **[v3 DÜZELTMESİ:** v2'nin mutant-7'si `scope_id` dalını hedefliyordu ama o dal **ölüydü** (`scope_id` = projectId, asla userId değil) → ısırmıyordu. v1'inki ise hiç var olmayan bir "önbellek"i hedefliyordu.]*
8. `mutant-8-no-skip-locked` — `FOR UPDATE SKIP LOCKED` → düz `FOR UPDATE` ⇒ pump kilitli satırlara **bloke olur** → `lock_timeout` (5 sn, bağlantı dizesinde) → `PumpOnceAsync` **istisna fırlatır** (D2-f) ⇒ **H9 testi FAIL**. **[v3 netleştirmesi:** düz SELECT'te assert-(5) — kesişim ∅ — **kırılamaz**, çünkü bloke olan sorgu kilitli satırları zaten talep edemez; tek öldürme yolu **fırlayan istisnadır**. Bu yüzden D2-f'nin "yutmaz" sözleşmesi pazarlıksızdır.]* **ZORUNLU: bu dilimin bayrak mekanizmasının tek ısıran kanıtı.**
9. `mutant-9-clock-read-compare-write` — `UpsertGreatestAsync` SQL-GREATEST yerine C#'ta oku-karşılaştır-yaz ⇒ **D0-b FAIL** (lost update). **[v3 DÜZELTMESİ — yarış sırası TERS çevrildi:** v2 conn1=`H_low` / conn2=`H_high` diyordu; oku-karşılaştır-yazda conn2 bayat okusa bile `H_high > bayat` görüp yine `H_high` yazardı → **mutant ısırmazdı**. Doğru sıra: **conn1 = `H_high` (commit YOK), conn2 = `H_low`**; GREATEST'te sonuç `H_high`, oku-karşılaştır-yazda conn2 bayat okur ve `H_low` yazar → **lost update, FAIL**.]*

**D10 — Bağımlılıklar.** SignalR sunucusu ASP.NET Core içinde — sunucu paketi yok. Test tarafı (ikisi de MIT, nuspec SPDX'ten teyit et, **yalnız test projelerine**):
- `Microsoft.AspNetCore.SignalR.Client` — D8-vi/vii için; **`Persistence.Tests` VE `Api.Tests` ikisine de** (v2 "yalnız test projesine" diyordu, tekildi).
- `Microsoft.Extensions.TimeProvider.Testing` (`FakeTimeProvider`) — **D8-iii'ün zorunlu aracı**. v2 bunu kullanmayı şart koşup paketi yasaklıyordu (elde yazılmış `ManualTimeProvider` yalnız `SyncCore.Tests`'te ve `Persistence.Tests` onu referans etmiyor) → **spec kendi içinde tutmuyordu**. v3 paketi açıkça izinli kılar.
**YASAK:** Redis/backplane paketleri · MessagePack · yeni mock/mapper/assertion kütüphanesi (Moq/NSubstitute dâhil — kaydeden sahte sınıfları elle yaz).

**D10-b — Test altyapısı pinleri [v3, YB-8/YB-9].**
- **Sabit kimlik ŞART:** mevcut `FakeCurrentUser` kalıbı `services.AddScoped<ICurrentUser>(_ => new FakeCurrentUser(Guid.NewGuid()))` — **her scope çözümlemesinde YENİ Guid** üretir. Hub `OnConnectedAsync` bir scope'ta, `/v1/sync` başka scope'ta çözülür → **farklı kullanıcı** → G3/D8-v ölçülemez. Testler **test başına sabit** bir userId tutan bir `FakeCurrentUser` kaydı kullanır.
- **`HubConnection` ↔ `WebApplicationFactory` kablolaması pinlenir:** `HttpConnectionOptions.HttpMessageHandlerFactory = _ => server.CreateHandler()` **VE `WebSocketFactory` = `server.CreateWebSocketClient()`** — TestServer `IHttpWebSocketFeature` sunduğu için sunucu WebSockets'i ilan eder; `WebSocketFactory` verilmezse istemci WebSockets'i dener, düşer ve SSE/LongPolling'e geriler (çalışır ama yavaş+gürültülü). Aksi halde D8-vi/vii **kurulamaz**.
- **`FakeCurrentUser` yerleşimi (pin):** şu an `tests/Momentum.Persistence.Tests/EndpointTests.cs` içinde; iki test projesi birbirine referans **vermiyor**. Kopyalama YAPMA — ya paylaşılan bir `Momentum.TestSupport` projesi aç ya da `Compile Include` link kullan; **hangisini seçtiğini raporla** (§2 yerleşim listesine ekle).

**D11 — verify.** `araclar/verify.ps1` **DEĞİŞMEDEN** geçmeli (Docker açıkken).

10. `mutant-10-cursorhint-min` — D3'te grup sinyalinin `CursorHint`'i **en büyük** yerine **en küçük** `(commit_xid, server_seq)` yapılır ⇒ **D8-ix FAIL**. *(v3 bunu "davranışsal tercih" diye mutantsız bırakmıştı — gereksiz körlüktü.)*
11. `mutant-11-replay-on-connect` — `OnConnectedAsync`'e bir `Changed` çağrısı eklenir (yeniden-bağlanmada replay) ⇒ **D8-vi FAIL**. *(v3 bunu "kusuru önce kendin yaz kalıbı" diye reddetmişti; ama `mutant-5-payload-in-signal` de aynı kalıptır ve zorunludur — çelişki v4'te giderildi.)*

**D9-b — MUTANTSIZ KAPILAR: dürüstlük beyanı [v3 — 2b1'in GREATEST dersinin doğrudan uygulaması].**
Aşağıdakiler **test edilir ama MUTANTLA KORUNMAZ**. Bu, "kapı" değil **regresyon/belgeleyici test** demektir; raporda ve KANIT'ta böyle adlandırılır, "kapı geçti" diye sunulmaz:
- **D3'ün pump-içi indirgemesi:** davranışsal tercih; hint imleç olmadığı için yanlış değeri zarar üretmez.
- **NetArchTest "Infrastructure SignalR'a bağımlı olmaz":** **tautolojik olduğu KABUL EDİLİR** — `Momentum.Infrastructure.csproj` `Microsoft.NET.Sdk`'dir (Web değil) ve `FrameworkReference Microsoft.AspNetCore.App` yoktur → SignalR tipleri oradan zaten erişilemez, kural üretim kodu mutasyonuyla kırılamaz. Kuralı yaz (ucuz regresyon) ama **"kapı" sayma**. *(v3 bunu "kural gerçek" diye nitelendirmişti — v4 düzeltti; kendi kaldırdığı tautoloji sınıfının aynısıydı.)*
- **`OnConnectedAsync`'teki `Context.Abort()`:** savunma-derinliği (D4).
**[v4 — bu listeden ÇIKARILANLAR, doğrulayıcı haklıydı: "fazla cömert" davranıp kapıları gereksiz köreltiyordum]**
- **D8-ix (`CursorHint` = max)** artık **mutantlıdır** → `mutant-10-cursorhint-min` (`max` → `min`) ⇒ D8-ix FAIL. Tek satırlık mutasyon, kesin ısırır; "davranışsal tercih" gerekçesi kapıyı boşuna köreltiyordu.
- **D8-vi (G3)** artık **mutantlıdır** → `mutant-11-replay-on-connect` (`OnConnectedAsync`'te bir `Changed` gönder) ⇒ D8-vi FAIL. v3'ün "bu 'kusuru önce kendin yaz' kalıbı olur" gerekçesi **kendi D9'uyla çelişiyordu**: `mutant-5-payload-in-signal` tam olarak aynı ek-kusur kalıbıdır ve zorunlu tutulmuştur. Aksi hâlde G3, 2b1'in GREATEST'i gibi **kör** kalırdı.
Kural: bir mekanizmayı "kapı" diye sunmak, ısırdığını kanıtlamayı gerektirir. Kanıtlayamıyorsan bu listeye yaz — ama **önce gerçekten kanıtlanamaz olduğundan emin ol**; kolaycılıkla listeye ekleme.

## 4. Kabul kriterleri
1. Build `-warnaserror` 0/0. **Domain'e DOKUNULMAZ** — `git diff` Domain'de **BOŞ** olmalı; gerekiyorsa DUR ve Cowork'e sor.
2. 2b1'in **60 testi değişmeden yeşil** — özellikle **`Api.Tests` 9/9 DB'siz host'ta** (dispatcher kaydı D2-e ile korunmuş olmalı). Yeni testleri ayrı say ve raporla.
3. **D0 ayrı başlık altında raporlanır** (2b1'in kapanış koşulu): test + mutant-1 + mutant-2 + mutant-9 KANIT'ı.
4. **11 mutant** KANIT'ı, **D9 KANIT KURALI'na birebir uygun** (gerçek çıktı + kırılan tüm testler + hang-timeout). Temiz ağaçta kalıntı yok.
5. H9 **gerçekten ısırır**: `mutant-8` **fırlayan istisnayla** FAIL üretir (HANG değil); temiz kodda kilitli-küme kesişimi ∅ ve pump bloke olmadan döner; drain toplamı = N; sleep YOK.
5b. **`\d outbox_messages` çıktısında `available_at` satırının Default sütunu BOŞ** (D6-1) — raporda göster. Bu olmadan sahte-saat testlerinin hepsi yanlış nedenle geçer/kalır.
6. Sinyalde payload sızıntısı yok; hub kimliksiz bağlantıyı reddeder.
7. CVE temiz; sır yok; `PROJE_HAFIZA`/`docs/ADR` dokunulmamış; `bin/obj` ignore.

## 5. Kırmızı çizgiler
Sır repoya girmez · izinli lisans ailesi MIT/Apache/BSD-3 (+PostgreSQL License erratası) · kalıcı silme/para/güvenlik YOK · **Redis backplane / gerçek auth / entity CRUD / outbox budama BU DİLİMDE YOK** · `DateTime.UtcNow` üretimde yasak (`TimeProvider`) · **SQL'de `now()` de yasak** (D2-b: tek saat kaynağı) · **SQL'de ikinci LWW/CRDT implementasyonu YASAK** · Infrastructure **SignalR'a bağımlı olmaz** (NetArchTest ile gerçekten kurulabilir kural — koy) · **hiçbir outbox satırı kalıcı iskartaya çıkarılmaz**.

## 6. Teslim protokolü
1. `araclar/verify.ps1` (Docker açık) — TÜM çıktı rapora.
2. Commit (ASCII): `feat(realtime): slice-2b2 outbox dispatcher + signalr signal + scope membership`. **Push YAPMA** (Cowork).
3. Rapor: (a) test sayıları (60 + yeni ayrımı; `Api.Tests` 9/9 DB'siz ayrıca), (b) **D0 ayrı başlık**, (c) verify exit, (d) 11 mutant KANIT yolu + her mutantın kırdığı TÜM testler, (e) paket+lisans teyitleri, (f) Domain BOŞ diff kanıtı, (g) sapma/varsayım TAM listesi, (h) **D5'in salt-okur-üye boşluğunun** teyidi.

> Cowork beyanına güvenmez: H9'u, D0/D0-b'yi ve 11 mutantı **kendi koşusuyla** doğrulayacak; özellikle `mutant-8`'i kendi eliyle uygulayıp kesişim assert'ini kıracak. **Bir mutant ısırmıyorsa bu testin değil SPEC'in kusurudur — sessizce geçiştirme, bildir.**

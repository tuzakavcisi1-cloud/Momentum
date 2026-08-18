# İŞ EMRİ o83-B — DİLİM 1 KİMLİK'i KAPAT

`MOD: NORMAL` · kutu **18-21 Ağu 2026** · yazan: Cowork · koşacak: **Claude Code**
Kilit: [Onur, 18 Ağu 2026] — Cowork bağımsız denetimi 3 bulgu verdi; `verify.ps1` EXIT 1 kararı alındı.

---

## 0. DEMİR KURAL

🔴 **ADR YOK · SPEC YOK · kâğıt denetim turu YOK.** Bu bir **punch list**.
`IS-EMRI-o83-kimlik.md`in §4 KABUL ÖLÇÜTÜ ve §5 DOKUNMA LİSTESİ **aynen yürürlükte**.

---

## 1. NEDEN v2 — üç ölçülmüş bulgu

**B1 🔴 Kabul ölçütü 2 ölçülmemiş.** `_canli_tur.py` satır 98/151/160: d ayağı, adım (a)'da
**zaten `Applied`** olmuş op'u (aynı `op_id`) yeniden gönderiyor; sunucu **`Duplicate`** döndü.
`Duplicate` idempotent tekrarın kanıtıdır, **kuyruk hayatta kalmasının değil** — tam tersine
yazının token süresi dolmadan **önce** sunucuda olduğunu kanıtlar.

**B2 🔴 `09-verify-ps1.txt` kesik.** `Api.Tests` satırından sonra bitiyor: `Persistence.Tests`
sonucu YOK, çıkış kodu YOK. *"EXIT 1 · 66/69 · şu üç test"* beyanının arkasında **artefakt yok**.

**B3 🟡 `00-OZET` tablosu kanıttan sapıyor.** `a` için "HTTP 201→200" yazıyor; ham çıktı
`409 email already registered` → login 200. **Hesap bu turda açılmadı.**

---

## 2. YAPILACAK

### 2.1 Havuz sızıntısı — `verify.ps1` EXIT 1'in kökü  [Onur kilidi, 18 Ağu]

**Ölçüldü (Cowork, 18 Ağu 2026, cihazda):**

- `TestSupport.cs:13` `[assembly: CollectionBehavior(DisableTestParallelization = true)]`
  ⇒ testler **sıralı** koşuyor; gerçek eşzamanlı bağlantı ihtiyacı **yok**.
- `TestDatabase.CreateAsync` her teste taze `t_<guid>` veritabanı açıyor ⇒ her test
  **yeni connection string**.
- `AddDbContext(o => o.UseNpgsql(cs))` + `new OutboxClaimStore(cs)` ⇒ ikisi de Npgsql'in
  **global, connection-string ile anahtarlanan** havuzunu kullanıyor.
- `grep ClearPool|ClearAllPools|DROP DATABASE|MaxPoolSize|ConnectionIdleLifetime`
  → `src` + `tests`'te **0 eşleşme**.
- `SyncTestApp.DisposeAsync` yalnız `_provider.Dispose()` — global havuza dokunmaz.

⇒ Her test, kendi `t_<guid>`'sine açılmış **en az bir boşta bağlantıyı assembly sonuna kadar
canlı bırakıyor.** 69 test → ~69+ boşta backend; Postgres varsayılanı **100**.

**KARAR:**
❌ `max_connections` **ARTIRILMAZ** — tavanı yükseltmek sızıntıyı test sayısıyla doğrusal
büyütür; önümüzde **4 dilim daha** test ekleyecek, aynı kutuda tekrar ısırır.
❌ `verify.ps1` **BÖLÜNMEZ** — o79-80 kör kapı dersi.
✅ Havuz **kaynağında kelepçelenir**, TEK fonksiyonda:

`tests/Momentum.Persistence.Tests/TestSupport.cs` → `TestDatabase.CreateAsync`,
connection string kurulurken:

```csharp
var connectionString = new NpgsqlConnectionStringBuilder(fixture.Container.GetConnectionString())
{
    Database = databaseName,
    MaxPoolSize = 4,               // sirali kosumda fazlasi gerekmiyor
    ConnectionIdleLifetime = 1,    // saniye -- bosta baglanti budanir
    ConnectionPruningInterval = 1,
}.ConnectionString;
```

**Çağrı yeri DEĞİŞMEZ.** `TestSupport.cs` dışında hiçbir test dosyası düzenlenmez.
Sayılar yetmezse (hâlâ 53300) `MaxPoolSize`/`ConnectionIdleLifetime` ayarlanabilir —
ama `max_connections`a **dokunulmaz**.

### 2.2 Canlı tur d ayağı — YENİ op  (B1)

`_canli_tur.py` d ayağı, adım (a)'nın op'unu **değil**, hiç uygulanmamış **YENİ** bir op kullanır:

- **d.1** süresi geçmiş JWT + **YENİ op** → **401**
- **d.2** `POST /v1/auth/refresh` → **200**
- **d.3** **AYNI YENİ op**, yenilenmiş token → **200** ve kod **`Applied`**

🔴 `Duplicate` görülürse ayak **DÜŞMÜŞTÜR**, geçmiş sayılmaz.

### 2.3 Register canlıda 201  (B3)

Her koşumda **taze e-posta** (ör. `a+<uuid>@momentum.test`) ⇒ `register` **201** görülür.
201 görülmeden a ayağı yeşil sayılmaz.

### 2.4 `verify.ps1` tam çıktı  (B2)

`verify.ps1`in **TÜM** çıktısı **+ `$LASTEXITCODE` ayrı satır olarak**
`KANIT/o83/09-verify-ps1.txt`e yazılır. **Kesilmiş dosya kanıt değildir.**

### 2.5 Dispatcher testi — SIRAYLA, birlikte değil

2.1 indikten **SONRA** `verify.ps1` yeniden koşulur.

- `DispatcherTests.Cursor_correctness_is_unaffected_by_concurrent_dispatch_single_owner`
  artık **geçiyorsa**: bağlantı açlığının dolaylı kurbanıymış, kapanır.
- **hâlâ düşüyorsa**: gerçek bir flake. **DÜZELTİLMEZ**; `DURUM.md` "bilinen sınırlar"a
  tek satır yazılır (İŞLEYİŞ md.8) ve ayrı ele alınır.

🔴 İki şeyi aynı anda düzeltme — sinyali kaybedersin.

---

## 3. ÖLÇÜM

`IS-EMRI-o83-kimlik.md` §3 aynen. Ek olarak:

- `verify.ps1` → **EXIT 0**, tam çıktı + exit kodu KANIT'ta
- `08-canli-tur.txt`te `register` **201** VE d.3 **`Applied`** görünür
- Ham çıktılar `KANIT/o83/` altına (yeni koşum yeni içerik; eski dosya silinmez, üzerine yazılır)
- `00-OZET.md` **yeniden yazılır** ve tablodaki her hücre ham çıktıyla birebir eşleşir

## 4. KABUL ÖLÇÜTÜ

v1 §4'ün yedi maddesi **+**:

- [ ] d.3 kodu **`Applied`** (`Duplicate` DEĞİL)
- [ ] `register` **201** canlıda görüldü
- [ ] `verify.ps1` **EXIT 0**; tam çıktı + exit kodu KANIT'ta
- [ ] Dispatcher testi geçti **YA DA** `DURUM.md` sınır satırı yazıldı
- [ ] `00-OZET.md` tablosunun her hücresi ham çıktıyla eşleşiyor

## 5. DOKUNMA LİSTESİ

v1 §5 aynen **+**:

- ❌ **ÜRÜN KODU.** Bu iş emri yalnız **test altyapısı + KANIT betiklerine** dokunur.
  `src/backend` ve `src/client/lib` **DEĞİŞMEZ**. Değişmesi gerektiğini ölçersen
  (ör. d.3 YENİ op'la `Applied` dönmüyorsa) **DUR ve bildir** — bu gerçek bir ürün kusurudur.
- ❌ `max_connections` / Testcontainers komut satırı
- ❌ `verify.ps1`i projeye bölme
- ❌ `TestSupport.cs` dışında test dosyası düzenleme
- ❌ Push — push Onur'da.

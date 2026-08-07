# Momentum

Çok platformlu görev yönetimi (to-do) uygulaması — **çevrimdışı-öncelikli senkron** ve **gerçek
zamanlı işbirliği** vitrinli, işe-alım/portfolyo ödevi olarak geliştirilen bir mimari çalışması.

**Flutter** istemci (Android + Web; iOS yalnız CI'da derlenir) · **N-katmanlı .NET 10 / ASP.NET Core**
backend · **PostgreSQL**.

> Bu depo bir ürün değil, bir **mühendislik disiplini** gösterimidir. Ayırt edici tarafı özellik
> listesi değil, **her iddianın ölçülmüş olması** ve ölçülemeyenin **açıkça ölçülemedi diye
> yazılmış** olmasıdır. Ayrıntı: [Ölçüm disiplini](#ölçüm-disiplini).

---

## Bir bakışta

| katman | ne yapar |
|---|---|
| `src/backend/Momentum.Domain` | saf alan modeli; dış bağımlılığı yok |
| `src/backend/Momentum.Application` | CQRS (Mediator), doğrulama, işlem davranışı |
| `src/backend/Momentum.Infrastructure` | PostgreSQL kalıcılığı, outbox dağıtıcısı |
| `src/backend/Momentum.Api` | kompozisyon kökü: uç noktalar, SignalR hub'ı, sağlık, OpenAPI/Scalar |
| `src/client` | Flutter: Drift ile çevrimdışı CRUD, itme kuyruğu, çekme, çakışma rozeti |

**Senkron:** çift yönlü — yerel yazma → itme kuyruğu → `POST /v1/sync`; sunucu tarafında outbox +
imleç tabanlı çekme (snapshot/artımlı, `hasMore`). Çakışma çözümü yerel LWW + kullanıcıya görünür
rozet. **Gerçek zamanlı:** SignalR üzerinden **yüksüz sinyal** (veri taşımaz, yalnız "çek" der).

---

## Çalıştırma

Ölçülmüş sıra. Adımları atlamayın — her biri en az bir kez ısırdı.

### 1. PostgreSQL

```bash
docker compose up -d          # konteyner adı: momentum-postgres
docker ps                     # healthy görünene kadar YOKLA, sabit sleep verme
```

### 2. Backend

Bağlantı dizesi **repoda yoktur** (kırmızı çizgi 1: sırlar repoya girmez). Ortamdan verilir:

```powershell
cd src\backend\Momentum.Api
$env:ASPNETCORE_ENVIRONMENT = "Development"     # yoksa her istek 401 döner (dev-kimlik kalkanı)
$env:ASPNETCORE_URLS        = "http://0.0.0.0:5298"
$env:ConnectionStrings__Momentum = "Host=localhost;Port=5432;Database=momentum;Username=momentum;Password=<parola>"
dotnet run
```

> 🔴 **Bağlantı dizesi verilmezse host yine açılır ve port dinler** — ama Postgres'e hiç bağlanmaz.
> Hazır olmayı **portla ölçmeyin**; şu üçlüyü ölçün: `/health/live` **200** · `/health/ready`
> **200** · `POST /v1/sync` başlıksız **401**, `X-Momentum-Dev-User: <guid>` ile **200**.

### 3. Web istemcisi

```bash
cd src/client
flutter build web --release --no-web-resources-cdn
```

> 🔴 **`--no-web-resources-cdn` BİR TERCİH DEĞİL, ŞARTTIR.** Gerekçesi aşağıda
> [Zorunlu şartlar](#zorunlu-şartlar) bölümünde; **ölçülmüştür**, tercih değildir.

### 4. İstemciyi API ile aynı kökenden sun

```powershell
$env:Istemci__KokDizin = "<repo>\src\client\build\web"
```

Bu anahtar **boşsa** statik servis ara katmanı **hiç kurulmaz** (kill switch bedavadır). Ayarlıysa
`http://localhost:5298/` uygulamayı açar ve belge **çapraz-köken izole** olur.

### 5. Doğrulama zinciri

```powershell
.\araclar\verify.ps1          # build + test + CVE denetimi
```

> 🔴 **`verify.ps1`, çalışan bir `Momentum.Api` varken KOŞULAMAZ** — çalışan süreç `bin\` altındaki
> dll'leri kilitler ve derleme `MSB3026`/`MSB3027` ile düşer. Sıra: **cihaz/canlı kanıt → backend
> KAPAT (`netstat -ano | findstr :5298` boş dönmeli) → `verify.ps1`.**

**Son ölçüm (7 Ağu 2026, Linux konteyner, .NET SDK 10.0.302, gerçek PostgreSQL):**
`dotnet test Momentum.sln` ⇒ **120/120 geçti, 0 hata** · derleme **0 uyarı / 0 hata**
(`TreatWarningsAsErrors=true`). 🔴 Bu ölçüm **Windows'ta tekrarlanmadı**; `verify.ps1` PowerShell
zinciridir ve bu sürümle **koşulmamıştır**.

---

## Zorunlu şartlar

Bu iki madde ürünün davranışını belirler ve **ölçülerek** yazılmıştır.

### 1. Web build `--no-web-resources-cdn` ile alınır

API her yanıta `Cross-Origin-Opener-Policy: same-origin` + `Cross-Origin-Embedder-Policy:
require-corp` yazar; belge bu sayede **çapraz-köken izole** olur (ölçüldü: gerçek tarayıcıda
`crossOriginIsolated === true`, `SharedArrayBuffer` kullanılabilir).

`require-corp` altında, **CORP taşımayan çapraz-köken bir alt kaynak yüklenemez.** Bu, pozitif ve
negatif kontrolle ölçüldü: CORP'suz betik **bloklandı**, CORP'lu betik **yüklendi**.

Flutter'ın **varsayılan** `flutter build web` çıktısı ise CanvasKit'i
`https://www.gstatic.com/flutter-canvaskit/…` adresinden çeker. `--no-web-resources-cdn` bayrağı
CanvasKit'i **aynı kökene** taşır. **Bayraksız derlenen bir sürümde izolasyon iddiası çürür.**

🔴 Bu şart bugün **CI'da zorlanmıyor** — bilinen ve yazılı bir borçtur.

### 2. Veri göçü **bilerek** kapsam dışıdır

**Mevcut `sharedIndexedDb` deposu olan bir tarayıcı OPFS'e GEÇMEZ**; verisi IndexedDB'de kalır.

Ölçülmüş gerekçe: ① COOP/COEP başlıkları **temiz bir kurulumu** zaten OPFS'e taşıyor ② kalıcı
tarayıcı profiliyle üç koşumda izolasyon açıkken bile depo `sharedIndexedDb`'de **kaldı**, OPFS
**boş** ⇒ göç hiç başlamadı ③ göçü tetikleyecek bayrak (`moveExistingIndexedDbToOpfs`) `drift`
çekirdeğinde **var** ama `drift_flutter` **0.3.1** onu **geçirmiyor** ve bu, pub.dev'deki **en son**
sürümdür ⇒ sürüm yükseltme yolu **ölü**.

Beyan edilmiş bedel: bu kararın koruduğu şey **mevcut kullanıcı verisidir**; bu depoda saha
kullanıcısı yoktur. Karar **açıkça** alınmıştır, sessizce atlanmamıştır.

---

## Ölçüm disiplini

Bu depoda bir iddia üç yoldan biriyle yaşar: **ölçülmüştür**, **`[DOĞRULANMADI]` işaretlidir**, ya
da **borç olarak yazılmıştır**. Dördüncü yol yoktur.

- **Kapılar kendini kanıtlar.** `araclar/` altındaki her ölçüm aracının bir **altın kümesi** vardır
  ve `--altin-kume` ile koşar: temizde susmalı, kirlide ısırmalı. Kanıtlamayan araç kullanılmaz.
- **Kör kapı yoktur.** Bir kuralın kapısı varsa, o kapının **ısırdığını** bir **mutant** kanıtlar —
  kuralı bilerek bozan, kapının kırmızı verdiğini ölçen ve sonra geri alan bir değişiklik.
- **Üreten ≠ denetleyen.** Hiçbir çıktı kendi üreticisi tarafından onaylanmaz. Bu kural bu depoda
  **fiilen işledi**: bir ölçüm aracı kendi 25 vakalık altın kümesini ve dört gerçek mutantı geçtiği
  hâlde, bağımsız denetçiler onu kırdı ve araç **teslim edilmedi**.
- **Ölçemediğine hüküm verilmez.** Ölçülemeyen şey *"temiz"* değil **`ÖLÇÜLEMEDİ`**'dir.

Karar arşivi `PROJE_HAFIZA.md` (append-only), açık borçlar `BORCLAR.md`, canlı durum `DURUM.md`,
ortam mayınları `ORTAM.md`, ölçüm kanıtları `KANIT/`.

---

## Beyan edilmiş sınırlar

- **iOS yalnız CI'da derlenir** — geliştirme makinesinde macOS yok.
- **Windows masaüstü hedefi yok.**
- **Gerçek zamanlı sinyal web'de kapalı.** Dev-kimlik kalkanı bir HTTP başlığı istiyor, tarayıcı ise
  WebSocket el sıkışmasına başlık ekleyemiyor (ölçüldü; `negotiate` 200, WebSocket düşüyor —
  COOP/COEP **suçsuz**, pozitif kontrolle doğrulandı).
- **SignalR yeniden bağlanma yolu** bu depoda **hiç egzersiz edilmedi** (emülatör NAT'ı kurulu
  soketi koruyor).
- **`flutter test --platform chrome`** bu ortamda sonuç üretmiyor ⇒ web test ayağı `[DOĞRULANMADI]`.
- **Üretim dağıtım topolojisi** (CDN, ters vekil, ayrı statik host) kapsam dışı; ters vekil
  COOP/COEP'i ezebilir ve bu **ölçülmez**.

---

## Lisans ve kimlik

Bağımlılık eklenirken **lisans + CVE** denetimi zorunludur (`araclar/pub-lisans-kapisi.py`,
`araclar/pub-cve-kapisi.py`, `NuGetAudit`). Sırlar repoya girmez; build artefaktları `.gitignore`'dadır.

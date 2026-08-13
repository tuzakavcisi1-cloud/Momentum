# Momentum

Çok platformlu görev yönetimi (to-do) uygulaması — **çevrimdışı-öncelikli senkron** ve **gerçek
zamanlı işbirliği** vitrinli, işe-alım/portfolyo ödevi olarak geliştirilen bir mimari çalışması.

**Flutter** istemci (Android + Web; iOS yalnız CI'da derlenir) · **N-katmanlı .NET 10 / ASP.NET Core**
backend · **PostgreSQL**.

> Bu depo bir ürün değil, bir **mühendislik disiplini** gösterimidir. Ayırt edici tarafı özellik
> listesi değil, **her iddianın ölçülmüş olması** ve ölçülemeyenin **açıkça ölçülemedi diye
> yazılmış** olmasıdır. Ayrıntı: [Ölçüm disiplini](#ölçüm-disiplini).

---

## Nasıl görünüyor

**Çevrimdışı yazım → çakışma → kullanıcının kararı.** Vitrin bu: bağlantı yokken yazılan bir
değişiklik kuyrukta bekler, bağlantı gelince sunucudaki değerle **çakışır**, çakışma kullanıcıya
**görünür** ve kararı kullanıcı verir.

![Çevrimdışı senkron ve çakışma çözümü — üç adım](docs/gorseller/cevrimdisi-senkron-cakisma-akisi.png)

Üç kare de **gerçek Android emülatöründe** koşan uygulamanın ekran görüntüsünden **kırpılmıştır**;
montaj, yeniden çizim ya da düzeltme yoktur. Kazananı **HLC** belirledi: A, B'den **225.739 ms
sonra** yazdı ve alan-seviyesi LWW A'yı korudu; *Benimkini tut* yeni ve daha geç bir HLC ile yazıp
sunucuya ulaştı (`tasks.title` ⇒ `B1`, PostgreSQL'den ölçüldü).

🔴 **Bu akışın ölçülmeyen tek ayağı var ve yazılıdır:** çakışma çözüm ekranının *canlı cihazdaki*
görüntüsü yakalanmadı (iki değerin aynı anda gösterildiği `G34/b` widget testiyle, mutantla ölçülü).
Ayrıntı: `KANIT/SS2/13-KABUL-HUKMU-COWORK-kriter8-UCTAN-UCA.md` §3.

### Canlı demo (yalnız istemci)

**https://tuzakavcisi1-cloud.github.io/Momentum/** — GitHub Pages; `.github/workflows/pages.yml`
ile dağıtılır (elle tetiklenir, `workflow_dispatch`).

Ekleyin · başlığı düzenleyin · tamamlayın · sayfayı yenileyin: **veri durur.**

🔴 **İki sınır ölçülmüştür ve gizlenmemiştir** (14 Ağu 2026, gerçek tarayıcı; ham ölçüm
`KANIT/o71/16-pages-demo/07-canli-olcum-COWORK.md`):

1. **Çapraz-köken izolasyon YOK.** GitHub Pages COOP/COEP başlığı gönderemez ⇒ ölçüm birebir:
   `crossOriginIsolated === false`, `SharedArrayBuffer` tanımsız ve drift OPFS yerine
   `sharedIndexedDb` seçiyor — konsolda
   `chosenImplementation=WasmStorageImplementation.sharedIndexedDb missingFeatures={dedicatedWorkersInSharedWorkers, sharedArrayBuffers}`.
   Bu, [Zorunlu şartlar](#zorunlu-şartlar) bölümünün 1. maddesindeki
   `crossOriginIsolated === true` ölçümünü **çürütmez**: o ölçüm §Çalıştırma 4'ün kurulumuna
   (istemciyi API ile **aynı kökenden** sunmak) aittir. Bayrak **gereklidir, yeterli değildir**.
2. **Backend YOK ⇒ senkron düşer.** Yazılan her satır kuyrukta bekler ve satırda
   *"↑ Gönderiliyor"* rozeti kalır; uygulama **kilitlenmez**, hata ekranı çıkmaz
   (ölçüldü: 21 konsol kaydı, **0 hata**). Gerçek zamanlı sinyal web'de zaten kapalıdır:
   `[sinyal] web: gercek zamanli sinyal KAPALI (K79/2) -- elle yenileme tek yol`.

Demo, vitrinin **çevrimdışı yarısını** gösterir; senkron ve çakışma çözümü yukarıdaki ölçülmüş
görselle ve `KANIT/SS2/` altındaki ham kayıtlarla temsil edilir.

🔴 **Demo, `--no-web-resources-cdn` şartını mekanik olarak zorlar:** iş akışı, build çıktısında
`"useLocalCanvasKit":true` **varlığını** ve derlenmiş uygulama kodunda CDN adresinin
**yokluğunu** ölçer; ikisinden biri düşerse yayın **yapılmaz**. Kapının kör olmadığı **beş
mutantla** kanıtlandı (`KANIT/o71/16-pages-demo/01-mutant-kosumlari.txt`).

---

## Depo haritası — nereden başlamalı

🔴 **Bu depo alışılmadık bir bileşim taşır ve bu bilinçlidir.** Dosyaların **%75'i** ürün kodu
değil, **ölçüm kanıtıdır**. Ne aradığınıza göre:

| ne arıyorsanız | nereye bakın |
|---|---|
| **Ürün kodu** | `src/backend/` (.NET, 4 katman) · `src/client/lib/` (Flutter) |
| **Testler** | `tests/` (backend, **127** test) · `src/client/test/` (istemci, 549 test) |
| **Mimari kararlar** | `docs/ADR/` |
| **Ölçüm araçları (kapılar)** | `araclar/` — her biri `--altin-kume` ile **kendini kanıtlar** |
| **Ham ölçüm kanıtları** | `KANIT/` — **1.316 izlenen dosya, 23 MB** |
| **Süreç ve karar arşivi** | `PROJE_HAFIZA.md` (append-only) · `BORCLAR.md` · `DURUM.md` |

**`KANIT/` nedir:** her kabul hükmünün, her düşmüş denetimin ve her mutant koşumunun **ham
çıktısı**. Dosya adları arasında `…-DENETIMDE-DUSTU…`, `…-KILITLENEMEDI…` gibi kayıtlar görürsünüz —
bunlar **temizlenmemiştir ve bilerek durmaktadır**: bir spec'in üç kez düşmesi, bu deponun
gizlediği değil **belgelediği** bir olgudur.

---

## Bir bakışta

| katman | ne yapar |
|---|---|
| `src/backend/Momentum.Domain` | saf alan modeli; dış bağımlılığı yok |
| `src/backend/Momentum.Application` | CQRS (Mediator), doğrulama, işlem davranışı |
| `src/backend/Momentum.Infrastructure` | PostgreSQL kalıcılığı, outbox dağıtıcısı |
| `src/backend/Momentum.Api` | kompozisyon kökü: uç noktalar, SignalR hub'ı, sağlık, OpenAPI/Scalar |
| `src/client` | Flutter: Drift ile çevrimdışı CRUD (ekle · **başlık düzenle** · tamamla), itme kuyruğu, çekme, çakışma rozeti. 🔴 **Silme veri katmanında vardır** (`GorevDeposu.sil`, `silindi` tombstone, senkron protokolüne bağlı) **ama arayüzde tetikleyicisi yoktur** — beyan edilmiş sınır, canlı demoda ölçüldü (14 Ağu 2026). |

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

**Son ölçüm (13 Ağu 2026, Windows, `araclar\verify.ps1`, gerçek PostgreSQL):**
`verify.ps1` ⇒ **EXIT 0** · derleme **0 uyarı / 0 hata** (`TreatWarningsAsErrors=true`) ·
**127/127 test geçti** (5 mimari · 44 SyncCore · 22 API · 56 kalıcılık) · **CVE kapısı: 0 zafiyetli
paket**. 🟢 Zincir bu kez **Windows'ta koştu** — önceki sürümlerde yalnız Linux konteynerde
ölçülmüştü. Ham çıktı: `KANIT/o71/15-verify-CVE-pin-sonrasi.txt`.

**İstemci, son ölçüm (10 Ağu 2026, Linux, Flutter 3.44.6 / Dart 3.12.2):**
`flutter test` ⇒ **549/549 geçti** · `flutter analyze --fatal-infos` ⇒ **0 sorun**.
Ölçümü **üreten el değil** bağımsız bir el koştu ve aynı turda **beş mutant** koşuldu
(erişilebilirlik etiketi ×2, düzen aritmetiği ×3) — **beşi de ısırdı**, ölü mutant yok.
Kanıt: `KANIT/SS2/05-KABUL-HUKMU-COWORK-o68-baslik-duzenleme-UI.md`.
🔴 Widget testi **uçtan uca değildir**: gerçek Android cihazda/emülatörde **koşulmadı**.

---

## Zorunlu şartlar

Bu iki madde ürünün davranışını belirler ve **ölçülerek** yazılmıştır.

### 1. Web build `--no-web-resources-cdn` ile alınır

API her yanıta `Cross-Origin-Opener-Policy: same-origin` + `Cross-Origin-Embedder-Policy:
require-corp` yazar; belge bu sayede **çapraz-köken izole** olur (ölçüldü: gerçek tarayıcıda
`crossOriginIsolated === true`, `SharedArrayBuffer` kullanılabilir).

🟢 **o71'de eklendi:** `Cross-Origin-Resource-Policy: same-origin` **yalnız statik yanıtlara**
yazılır; `/v1/**`, `/health/**`, `/hubs/**`, `/scalar/**` bu başlığı **almaz**. Ayrım bilinçlidir
(`D-W3-4`) ve **yedi test + iki mutantla** ölçülür — biri başlığı silen, biri onu genele taşıyan.

`require-corp` altında, **CORP taşımayan çapraz-köken bir alt kaynak yüklenemez.** Bu, pozitif ve
negatif kontrolle ölçüldü: CORP'suz betik **bloklandı**, CORP'lu betik **yüklendi**.

Flutter'ın **varsayılan** `flutter build web` çıktısı ise CanvasKit'i
`https://www.gstatic.com/flutter-canvaskit/…` adresinden çeker. `--no-web-resources-cdn` bayrağı
CanvasKit'i **aynı kökene** taşır. **Bayraksız derlenen bir sürümde izolasyon iddiası çürür.**

🔴 **Tersi doğru değildir:** bayrak **gereklidir, yeterli değildir** — sunucu COOP/COEP
göndermiyorsa bayrak varken de izolasyon yoktur. Ölçülmüş karşı-örnek: yukarıdaki **Canlı demo** bölümü (`crossOriginIsolated === false`).

🟢 **o71'de kapandı (kısmen):** şart artık **Pages iş akışında mekanik olarak zorlanıyor**
(`pages.yml` → `kapi-cdn-ve-base-href`, beş mutantla kanıtlı). 🔴 `ci.yml`'de **hâlâ
zorlanmıyor** — kalan borç yazılıdır.

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

## Kapsam dışı — teslim beyanı

Bu üç madde **eksik değil, karardır**; gerekçeleriyle birlikte burada durur.

### 1. Kimlik doğrulama KAPSAM DIŞIDIR

Bu depoda gerçek kimlik doğrulama (JWT/OIDC, kullanıcı modeli, giriş ekranı) **yoktur ve bilerek
yazılmamıştır.** Ödevin odağı senkron mimarisi ve ölçüm disiplinidir.

Yerine duran şey bir **ölçüm iskelesidir** (`K61`): `Development` profilinde `X-Momentum-Dev-User`
başlığı `UserId`'yi taşır; başlık yok ya da bozuksa uç **401** döner, **sessiz varsayılan yoktur**.
🔴 **Üretim profilinde `NullCurrentUser` çalışır — deny-by-default.** Yani uygulama
`ASPNETCORE_ENVIRONMENT=Production` ile ayağa kalkar, port dinler, ama **hiçbir istek yetkilenmez**:
üretimde **kullanılamaz**, bu **tasarım gereğidir** ve bir **mutant** bunu kanıtlar.

Korunan ayrım: **`UserId` ⟂ `ClientId`** — kimlik kullanıcıya, senkron kimliği cihaza aittir; ikisi
hiçbir yerde birbirinin yerine geçmez. Gerçek kimlik eklendiğinde değişmesi gereken tek yer
`ICurrentUser` uygulamasıdır.

### 2. `GET /v1/task-lists` istemcide tüketilmiyor

Uç vardır ve çalışır; **istemcide karşılığı yoktur.** Bu, `slice-3a/D4`'ün ölçülmüş kararıdır:
bu dilimde **`Task` ↔ `TaskList` bağı UYDURULMADI** (`F6`). Bağ olmayınca listelerin arayüzde
yapacağı bir iş de yoktur. `by-id` karşılığının olmaması da aynı kararın parçasıdır —
**asimetri bilinçlidir**, yarım kalmış bir uç değildir.

### 3. Açık borçlar — sayı gizlenmiyor

`BORCLAR.md` teslim anında **97 işaretli satır** taşıyor; bunların **53'ü `B-…` kimlikli kalem**:
**23 🔴 · 27 🟡 · 3 🟢 (kapanmış)**. En kalabalık aileler `B-O62` (8) · `B-O63` (6) · `B-O53` (5) ·
`B-O64` (5) · `B-W3b` (5).

Bu liste **kısaltılmadı, yumuşatılmadı ve teslimden önce temizlenmedi.** Bu deponun sözleşmesi
şudur: *beyan edilmiş sınır kabul edilir, gizlenmiş sınır edilmez.* Bir borcun yazılı olması onun
**bilindiği** anlamına gelir; yazılı olmaması onu yok etmez, yalnız görünmez yapar.

---

## Beyan edilmiş sınırlar

- **iOS yalnız CI'da derlenir** — geliştirme makinesinde macOS yok.
- **Windows masaüstü hedefi yok.**
- **Gerçek zamanlı sinyal web'de kapalı.** Dev-kimlik kalkanı bir HTTP başlığı istiyor, tarayıcı ise
  WebSocket el sıkışmasına başlık ekleyemiyor (**yerel kurulumda** ölçüldü; `negotiate` 200,
  WebSocket düşüyor — COOP/COEP **suçsuz**, pozitif kontrolle doğrulandı). Pages demosunda sinyal
  **hiç başlatılmaz**; konsol birebir: `[sinyal] web: gercek zamanli sinyal KAPALI (K79/2)`.
- **SignalR yeniden bağlanma yolu** bu depoda **hiç egzersiz edilmedi** (emülatör NAT'ı kurulu
  soketi koruyor).
- **`flutter test --platform chrome`** bu ortamda sonuç üretmiyor ⇒ web test ayağı `[DOĞRULANMADI]`.
- **Üretim dağıtım topolojisi** (CDN, ters vekil) kapsam dışı; ters vekil COOP/COEP'i ezebilir ve
  bu **ölçülmez**. 🟢 **Ayrı statik host artık kapsam dışı değil:** Pages demosu tam olarak odur ve
  sonuçları **ölçülmüştür** (§Canlı demo).
- **Silme arayüzde yok.** `GorevDeposu.sil` ve `silindi` tombstone'u veri katmanında vardır ve
  senkron protokolüne bağlıdır; ekranda onu çağıran bir tetikleyici **yoktur** (ölçüldü, 14 Ağu 2026).

---

## Lisans ve kimlik

Bağımlılık eklenirken **lisans + CVE** denetimi zorunludur (`araclar/pub-lisans-kapisi.py`,
`araclar/pub-cve-kapisi.py`, `NuGetAudit`). Sırlar repoya girmez; build artefaktları `.gitignore`'dadır.

# Momentum v1.0.1 — teslim paketi

Çok platformlu görev yönetimi (to-do): **Flutter** istemci (Android + Web) · **N-katmanlı .NET 10 /
ASP.NET Core** · **PostgreSQL**. Vitrin: **çevrimdışı-öncelikli senkron ve çakışma çözümü**.

Paket iki parçadır: **çalışan sistem** (docker imajı — API ve web istemcisi *aynı kökende*) ve
**Android APK**. Aşağıdaki her sayı ölçülmüştür; ölçülmeyen şey "ölçülmedi" diye yazılıdır.

> **`v1.0.0`'dan farkı üç maddedir** — üçü de aynı gün, bağımsız bir gözden geçirmede bulundu:
> ① uygulamanın görünen adı `client`ken **`Momentum`** oldu (Android · iOS · web ana-ekran adı) ve
> `pubspec` açıklaması Flutter şablonundan çıkarıldı ② çalışma imajı yüzen `aspnet:10.0` etiketinden
> **`aspnet:10.0.11`**'e pinlendi (SDK zaten `10.0.302`'ye pinliydi — yapı zincirinin iki ucu artık
> aynı disiplinde) ③ README'de sekiz bayat/çelişkili satır ölçülerek düzeltildi.
> `v1.0.0` arşiv olarak durur; **kendi kaynağıyla tutarlıdır**, ekli APK'sı o kaynaktan derlenmiştir.

---

## 1. Tek komutla çalıştır

```bash
git clone https://github.com/tuzakavcisi1-cloud/Momentum.git
cd Momentum
docker compose up --build
```

Sonra tarayıcıda: **http://localhost:5298**

Sıra otomatiktir: `postgres` → `migrator` (şemayı EF bundle ile kurar) → `api` (aynı kökenden web
istemcisini de servis eder). Şemayı `api` **kurmaz**; ayrı bir migrator servisi kurar.

⏱ **İlk derleme ~27 dakika sürer** (ölçüldü: 1639,7 sn · Windows 11 + Docker Desktop, soğuk önbellek).
Flutter web derlemesi imajın içinde koşar. Sonraki açılışlar saniyeler içindedir.

Sağlık ucu: `GET /health/ready` → 200. Uygulama API'si `POST /v1/sync` ve `GET /v1/tasks`.

**Hiçbir şey kurmadan bakmak isterseniz:** <https://tuzakavcisi1-cloud.github.io/Momentum/> —
aynı istemci, ama **backend yoktur**: veriler yalnız tarayıcıda kalır ve yazılan satır kuyrukta
*"↑ Gönderiliyor"*da asılı durur. Senkron ve çakışma vitrini **yalnız** yukarıdaki docker paketinde
görülür.

---

## 2. Android APK (varlık: `momentum-v1.0.1-emulator.apk`)

| | |
|---|---|
| Boyut | **59.953.218 bayt** |
| sha256 | `ee3b4e0b28ea89fbf779bfa9730f37ca953906cb7b3b0b501bf3a69b41746b46` |
| ABI | armeabi-v7a · arm64-v8a · x86_64 (tek fat APK) |
| Derleme hedefi | `SENKRON_SUNUCU_URL=http://10.0.2.2:5298` |
| Demo kimliği | `DEV_USER_ID=deadbeef-0000-4000-8000-000000000001` |
| Derlendiği commit | `a332b25` — **bu etiketin ta kendisi** |

**Bu APK Android emülatörü içindir.** `10.0.2.2`, emülatörden host makinenin `localhost`'una giden
takma addır. Yani: aynı makinede `docker compose up` çalışırken emülatöre bu APK'yı kurun —
tarayıcıdaki istemci ile emülatördeki istemci **aynı kullanıcıdır** ve birbirini görür.

🔴 **Gerçek telefonda bu APK çalışmaz.** Telefon `10.0.2.2`'ye ulaşamaz; kendi ağınız için yeniden
derlemeniz gerekir (`src/client` dizininden):

```bash
flutter build apk --release \
  --dart-define=SENKRON_SUNUCU_URL=http://<backend-makinesinin-LAN-IPsi>:5298 \
  --dart-define=DEV_USER_ID=deadbeef-0000-4000-8000-000000000001
```

`localhost` **yazmayın** — telefon `localhost` dediğinde kendini kasteder.

🔴 **APK debug anahtarıyla imzalıdır.** `android/app/build.gradle.kts` içinde Flutter'ın varsayılan
`signingConfig = signingConfigs.getByName("debug")` satırı ve `TODO`'su duruyor; üretim imza zinciri
kurulmadı. Kurulumda "bilinmeyen kaynak" onayı isteyecektir. Bu bir gözden kaçma değil, yazılı bir
kapsam kararıdır. (Ölçüldü: APK'nin imza bloğunda sertifika sahibi `Android Debug`; v1/JAR imza
dosyası yok, imza APK Signature Scheme v2/v3'tedir.)

🔴 **`DEV_USER_ID` her iki istemcide aynı olmalıdır.** İstemci kimliği normalde kurulum başına
rastgeledir; iki istemcinin birbirini görmesi için `docker-compose.yml` ve APK aynı sabit demo
kimliğini kullanır. Farklı bir değer verirseniz ilk açılışta yerel görevler **ve** senkron kuyruğu
aynı transaction'da silinir (bilinçli: eski kullanıcının bekleyen op'ları yeni kimlikle sunucuya
itilmesin).

---

## 3. Ne ölçüldü

Gerçek makinede (Windows 11 + Docker Desktop) ve gerçek bir Android telefonda, 17 Ağustos 2026:

- **Çift yönlü senkron iki gerçek istemcide kanıtlandı** — masaüstü tarayıcı ↔ Android telefon.
- Tarayıcıda yazılan görev **PostgreSQL'e ulaştı** (`GET /v1/tasks` 200 ile doğrulandı).
- `crossOriginIsolated = true` (SharedArrayBuffer başlıkları imajda doğru servis ediliyor).
- Drift kalıcılık kipi: **opfsLocks** (GitHub Pages demosunda `sharedIndexedDb`).
- **Yatay (landscape) yerleşim gerçek telefonda ölçüldü:** taşma yok, satır binmesi yok, uzun başlık
  yatayda tam görünüyor. Tek gözlem: yatayda klavye açıkken liste görüntü alanı dışında kalıyor.
- **Çalışma imajı pinli:** `aspnet:10.0.11` — yüzen etiketin o an ne verdiği *koşan konteynerden*
  ölçüldü (`dotnet --list-runtimes`), MCR etiket listesiyle teyit edildi. SDK zaten `10.0.302`.
- İstemci testleri: **708/708 yeşil**, `flutter analyze` **0 uyarı**.
- CI kapıları yeşil: `ci #67` · **`paket #9`** (ikisi de `a332b25` — bu etiket) · `pages #10`.
  `paket`, pinli imajı beş ayak + migrator ile uçtan uca koşturur.

**NE ÖLÇÜLMEDİ:** gerçek arm64 donanımda paket kapısı koşulmadı (kırılma yalnız manifestle
gösterildi; arm64 makine yok) · erişilebilirlik duyuruları gerçek ekran okuyucuyla (TalkBack)
dinlenmedi — widget testinde `announce` mesajı yakalanarak ölçülür · çakışma çözüm ekranının canlı
cihazdaki görüntüsü yakalanmadı · iOS hiçbir cihazda koşmadı (yalnız CI'da derlenir).

---

## 4. Kapsam dışı — eksik değil, kesilmiş

Ödevin kapsam otoritesi `docs/ODEV.md`; kesilenler README'de de yazılıdır.

- **Gerçek zamanlı işbirliği vitrini teslim edilmedi.** Sinyal kanalı (SignalR hub + outbox
  dispatcher) kodda ve testlerde var, ama **çok kullanıcılı paylaşım/davet akışı yok** ve kimlik
  `devUserId` ile taşındığı için işbirliği gösterilemez.
- **Giriş ekranı / kimlik doğrulama yok** — istemci `devUserId` taşır, `WireOp.ActorId`
  istemci-beyanlıdır. Parola sıfırlama, e-posta doğrulama, OAuth, 2FA, RBAC kapsam dışıdır.
- **Windows masaüstü `.exe` yok.** `src/client/` yalnız `android`, `ios`, `web` hedefleri taşır.
  Windows'ta uygulama tarayıcıdan çalışır — aynı tek komut, `http://localhost:5298`.
- **iOS cihazda koşmadı** (Mac donanımı yok; yalnız CI'da derlenir).
- **Liste / proje / tekrar (RRULE) / hatırlatıcı** özellikleri kesildi.
- Doğal dil ayrıştırıcısı her şeyi yutarsa (`#iş !p1 yarın`) hata metni gösterilmez; metin alanda
  kalır. Sessiz kayıp yok, geri bildirim de yok.

---

## 5. Mimari nereden okunur

`README.md` — zorunlu şartlar, ölçülmüş sınırlar ve beyan edilmiş kısıtlar.
`docs/ODEV.md` — kapsam otoritesi. `docs/ADR/` — karar kayıtları.
`src/backend/` — dört katman: `Momentum.Domain` · `Momentum.Application` · `Momentum.Infrastructure`
· `Momentum.Api`. Testler `tests/` altında (127 test).
`src/client/lib/` — `sunum` · `vitrin` · `veri` ayrımı; senkron ve çakışma çözümü `veri` altında.
`KANIT/` — 1.352 izlenen dosya, 16,3 MiB ham ölçüm; düşmüş denetimler dahil, temizlenmemiş.

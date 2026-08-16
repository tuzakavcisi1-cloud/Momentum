# KANIT — o79 · teslim paketi (docker) ham ölçümler

Tarih: **16 Ağu 2026** (TSİ). Ortam: Cowork bulut konteyneri (docker daemon YOK) + GitHub
Actions `ubuntu-latest` + cihaz Chrome (GitHub Actions arayüzü okumak için).

---

## 1. Kapı koşumları (`.github/workflows/paket.yml`)

| koşum | commit | sonuç (arayüzden birebir) |
|---|---|---|
| 1 | `874819e` | `failed: Run 1 of paket.` |
| 2 | `0456537` | `completed successfully: Run 2 of paket.` — 2 dk 37 sn |
| 3 | `8b90c13` | `completed successfully: Run 3 of paket.` |
| 4 | `2b3a597` | `completed successfully: Run 4 of paket.` — **kör kapı sürümü, sayılmaz** |
| 5 | `d75cbe4` | `completed successfully: Run 5 of paket.` — **2 dk 43 sn**, düzeltilmiş kapı |

**Koşum 1 kırmızısı, birebir** (`Dockerfile:32`):

```
#7 [migrator internal] load metadata for ghcr.io/cirruslabs/flutter:3.44.6
#7 ERROR: ghcr.io/cirruslabs/flutter:3.44.6: not found
target migrator: failed to solve: ghcr.io/cirruslabs/flutter:3.44.6: not found
```

**Koşum 5 adımları** (hepsi geçti; her adım tutmayan iddiada `exit 1` verir):
`sistemi tek komutla kaldir` 2m32s · `migrator BITTI ve SEMANIN TAMAMI kuruldu mu` ·
`hazirlik` 3s · `AYAK 1 (VARLIKLAR)` · `AYAK 2 (COOP/COEP/CORP)` · `AYAK 3 (401→200)` ·
`AYAK 4 (ÜRÜN UCU /v1/tasks)` · `AYAK 5 (404, HTML değil)`. İş: **succeeded in 2m 43s**.

> Koşum 4 ile 5 arasındaki fark bir ders: düzeltilmiş kapı dosyası ilk denemede depoya
> **inmedi** (eski dosya kartı kaydedildi). sha256 ile yakalandı: depoda `dba09bf…`,
> olması gereken `f1e3026f…`. **Bir düzeltmenin yazılmış olması, indiği anlamına gelmez.**

---

## 2. CI turu harcanmadan bulutta yakalanan kusurlar

**(a) Flutter arşivi — birinci taraf, sha256 doğrulamalı.**
Kaynak: `storage.googleapis.com/flutter_infra_release/releases/releases_linux.json`, 16 Ağu 2026.

```json
{"surum":"3.44.6","kanal":"stable",
 "arsiv":"stable/linux/flutter_linux_3.44.6-stable.tar.xz",
 "sha256":"a6320fd72e9a2690c08e2a6a70874a30cb120dee7c78f49d2c628bd7c9e20525"}
```

**(b) SDK etiketi.** `mcr.microsoft.com/v2/dotnet/sdk/tags/list` okundu: toplam 6628 etiket;
`10.0` **var**, `10.0.302` **var**, `10.0.400` **var**. `global.json` `rollForward: latestPatch`
özellik bandı atlamaz ⇒ yüzen `10.0` etiketi restore'u kırabilirdi. SDK `10.0.302`'ye pinlendi.

**(c) EF bundle başlangıç projesi.** `Momentum.Api` ile birebir hata:

```
Build succeeded.
Your startup project 'Momentum.Api' doesn't reference Microsoft.EntityFrameworkCore.Design.
This package is required for the Entity Framework Core Tools to work.
```

Infrastructure (+ `SyncDbContextDesignTimeFactory`) ile paket üretildi.
Boyut: **self-contained 108.179.028 bayt** · **çerçeve-bağımlı 34.676.337 bayt** ⇒ çerçeve-bağımlı seçildi.

**(d) Paketin gerçek PostgreSQL'e karşı koşumu** (bulutta PostgreSQL 16.13, sıfırdan DB):

```
Applying migration '20260718202450_InitialSync'.
Applying migration '20260719072330_DispatcherIndexes'.
Applying migration '20260719162721_MaterializeTasksAndTaskLists'.
Done.                                  cikis=0
public tablo sayisi: 11
__EFMigrationsHistory outbox_messages processed_operations sync_client_clock
sync_gc_state sync_orset_removes sync_orset_tags sync_scalar_meta
task_lists task_tags tasks
```

İkinci koşum: *"No migrations were applied. The database is already up to date."*, çıkış **0**
⇒ migrator **idempotent**.

---

## 3. Bağımsız denetim (üreten ≠ denetleyen) — 3 BLOKER · 6 MAJÖR · 7 MİNÖR

Denetçi ürünü üretmedi; çürütmeye çalıştı ve **ölçerek** gösterdi.

**B1 — KÖR KAPI.** `Istemci:KokDizin`e yalnız `index.html` konup API kaldırıldı:

```
AYAK 1  YESIL   |  main.dart.js              -> 404
AYAK 2  YESIL   |  flutter_bootstrap.js      -> 404
AYAK 3  YESIL   |  flutter_service_worker.js -> 404
AYAK 4  YESIL
```

Kök neden: AYAK 1 servis edilen gövdede `flutter_bootstrap.js` **dizesini** arıyordu; o dize
`src/client/web/index.html:44` **şablonunda** zaten var. → Düzeltildi: varlıkların **kendisi**
çekilir, `"useLocalCanvasKit":true` aranır, `main.dart.js` **>100 KB** olmalı.

**B2 — Yarım şema kapıyı geçiyor.** Yalnız ilk migration koşuldu: çıkış **0**, **8 tablo**
(`tasks`/`task_lists` YOK), `/health/ready` **200**, ama `GET /v1/tasks` **500**.
→ Düzeltildi: sayı değil **ad** sorulur (sekiz tablo) + **AYAK 4 ürün ucunu** çağırır.

**B3 — arm64.** Flutter linux arşivi `dart_sdk_arch = x64`; manifestteki tüm arch değerleri
`{None, 'x64'}` — linux-arm64 yayını **yok**. Pin olmadan Apple Silicon'da sha256 tutar, sonra
`flutter --version` "cannot execute binary file" ile düşer; x64 runner bunu **göremez**.
→ Düzeltildi: `FROM --platform=linux/amd64`.

**M3 — `DEV_USER_ID`'nin mekanik kapısı yoktu.** → Düzeltildi: kapı derlenmiş `main.dart.js`
içinde demo GUID'ini arar.

**Denetçinin doğrulayıp DOĞRU bulduğu kararlar:** Flutter sha256 pini · SDK etiket gerekçesi ·
`DOTNET_ROOT=/usr/share/dotnet` (aspnet katmanları açılarak) · EF bundle başlangıç projesi ·
AYAK 4'ün `/v1` ile sınırlı olmaması. **Rastgele beyan doğrulaması:** (a) seçildi ve tuttu —
11 tablo, bağımsız olarak yeniden ölçüldü.

---

## 4. NE ÖLÇÜLEMEDİ

1. **`docker compose up --build`'in kendisi bulutta/cihazda** — iki ortamda da docker daemon yok.
   Tek ölçüm yeri CI; `depends_on` zinciri ve konteyner ağı yalnız orada doğrulandı.
2. **arm64'te fiilî kırılma.** Manifest kanıtıyla gösterildi, gerçek arm64 makinede koşulmadı.
3. **Tarayıcı davranışı:** `crossOriginIsolated === true`, `SharedArrayBuffer`, CanvasKit'in
   aynı kökenden yüklenmesi. `curl` bunları göremez; kapı da göremez.
4. **APK ve iki-istemci vitrini.** APK üretilmedi; `DEV_USER_ID`'nin iki istemcide *fiilen* aynı
   kullanıcıyı verdiği ölçülmedi (kapı yalnız define'ın derlemeye girdiğini ölçer).
5. **Kök dışı kullanıcı (uid 10001) altında yazma** — Data Protection anahtar dizini, `$HOME`, `/tmp`.
6. **`aspnet:10.0` yüzen etiketi** bilinçli bırakıldı (SDK pinlenirken çalışma zamanı pinlenmedi);
   roll-forward yerelde doğrulandı ama imajda ölçülmedi.

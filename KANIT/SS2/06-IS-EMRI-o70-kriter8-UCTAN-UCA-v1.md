# İŞ EMRİ — `SS2` kabul kriteri **8**: UÇTAN UCA çakışma koşumu (oturum 70)

> 🔴 **BU BİR SPEC DEĞİLDİR, YENİ TUR AÇMAZ.** Kaynak: **kilitli** `GOREV-SS2-cakisma-cozumu.md`
> §7 kriter 8 (`K133`/`K136`) + `K80` + `ORTAM.md`. Yeni `G<n>` / `D-<x>` / mutant kimliği
> **ilan edilmez**; bu belge yalnız **ölçülmüş ortam yordamını** ve **kilitleri** taşır.
>
> **El:** Claude Code — **ortamı KALDIRIR ve senaryoyu SÜRER** (`K80`: *"Ortamı Claude Code
> kaldırır, Cowork yalnız ölçer"*, kriter 8'in kendi satırı).
> **Hüküm:** Cowork, **bağımsız koşumla** (`K26`). Builder **hüküm vermez**.
> **Tarih:** 11 Ağu 2026 (cihazdan ölçüldü). **Taban HEAD:** `79c208c`.
>
> 🔴 **BEYAN EDİLMİŞ BEDEL — `R8` KIRMIZI.** o69 ve o70'te ürün kodu 0 ⇒ `radar.py` **SERT DURAK**
> veriyor. Bu belge `KANIT/` altındadır (`K175`② yasağı `GOREV_CLAUDE_CODE`/`docs/ADR`/`araclar`
> içindir) ve **yeni artefakt yasağını ihlal etmez**, ama `K154`'ün *"R8 kırmızıyken yeni belge
> turu açılmaz"* kuralına karşı **bilinçli bir istisnadır**: kriter 8 zaten **kilitli** bir
> kabul ölçütüdür, yeni bir tasarım turu değildir. **Onur onaylamadan Claude Code başlamaz.**

---

## 0. ÖNCE OKU — bu mayınların her biri bu projede EN AZ BİR KEZ ısırdı

| mayın | kural |
|---|---|
| Sabit `sleep` | **ölçüm değildir** — koşula kadar **yoklanır**, tavanlı (`ORTAM.md`; o35'te 22 sn beklenip yanlış KIRMIZI verildi) |
| `cmd /c "... %VAR%"` | **sahte `EXIT=0`** verir ⇒ `cmd /v:on /c "... !VAR!"`; `set` sonrası da `!VAR!` |
| `flutter` | bu makinede **`.bat`** ⇒ tam yol `C:\src\flutter\bin\flutter.bat` |
| `adb` | **PATH'te YOK** ⇒ `C:\Users\gulci\AppData\Local\Android\Sdk\platform-tools\adb.exe` |
| `uiautomator dump` | uygulama çizilmeden çağrılırsa **dosya oluşmaz**; çıktıda `"dumped to"` görünene kadar **yoklanır** |
| `python` stdout | **cp1254** ⇒ her betiğe `sys.stdout.reconfigure(encoding="utf-8", errors="replace")` |
| `verify.ps1` | **çalışan `Momentum.Api` varken KOŞULAMAZ** (36 `MSB3026`). Sıra: cihaz kanıtı → backend **KAPATILIR** (`netstat` **boş** ölçülür) → `verify.ps1` |
| `os.replace` | bu makinede `WinError 5` verebilir ⇒ K60 takası **üç adımlı yedekli** |
| git | `--no-optional-locks` **zorunlu** · `git add -A` **YASAK** · commit mesajında **çift tırnak yok** · **push Onur'da** |

---

## 1. ORTAM — sırayla, **her adım ölçülür, hiçbiri varsayılmaz**

### ① PostgreSQL
```powershell
docker start momentum-postgres
```
🔴 `healthy` **görülene kadar yoklanır** (`docker inspect --format '{{.State.Health.Status}}' momentum-postgres`),
tavanlı. Ham çıktı kanıta.
🔴 `docker ps -a` da yazılır: o42'de bu konteyner `Exited (255)` çıktı ve belge `Up (healthy)` diyordu.

### ② Backend — **ayrı pencerede, açık kalır**
```powershell
cd C:\dev\Momentum\src\backend\Momentum.Api
$env:ASPNETCORE_ENVIRONMENT="Development"
$env:ASPNETCORE_URLS="http://0.0.0.0:5298"
$env:ConnectionStrings__Momentum="Host=localhost;Port=5432;Database=momentum;Username=momentum;Password=momentum_dev"
dotnet run
```
- 🔴 `ASPNETCORE_ENVIRONMENT=Development` **açıkça set edilir** — yoksa `NullCurrentUser` ⇒ **her istek 401** (`K61`).
- 🔴 `0.0.0.0` **zorunlu** — emülatör `10.0.2.2` ile gelir; `localhost` dinlenirse cihaz **göremez**.
- 🔴 Bağlantı dizesi **verilmezse host DB'siz açılır**: port **yine LISTENING** gösterir ama Postgres'e **hiç bağlanmaz**.
  Değerler `docker inspect momentum-postgres` ⇒ `POSTGRES_DB/USER/PASSWORD` ile **teyit edilir**.

### ③ Hazır olma — **PORTLA ÖLÇÜLMEZ**
Hazır betik: **`KANIT/A11/_backend_dogrula.py`**. Zorunlu üçlü:
1. `GET /health/live` ⇒ **200**
2. `GET /health/ready` ⇒ **200** (503 ⇒ bağlantı dizesi yok/yanlış)
3. `POST /v1/sync` **başlıksız ⇒ 401**, `X-Momentum-Dev-User` ile ⇒ **200**
🔴 `clientId` **geçerli bir GUID olmak zorunda** — dize gönderilirse uç **500** döner ve bu
**backend'in değil PROBUN kusurudur** (o50'de ölçüldü).

### ④ İki istemci
- **Cihaz B — Android emülatör.** AVD adı **VARSAYILMAZ, ÖLÇÜLÜR**: `flutter.bat emulators`
  çıktısı kanıta yazılır, sonra `flutter.bat emulators --launch <avd>`.
  Ardından `adb.exe devices` ⇒ `emulator-XXXX  device` **görülür** (`K80`'in üçüncü adımı).
- **Cihaz A — ikinci emülatör YA DA `flutter run -d chrome`.**
  🔴 Web yolu seçilirse `--no-web-resources-cdn` **gereği ÖLÇÜLÜR, varsayılmaz**: bu bayrağın
  `flutter build web` dışında `run -d chrome` için de gerekip gerekmediği bu projede
  **[DOĞRULANMADI]** (`B-O63-2` açık). Gerekmiyorsa **öyle yazılır**; gerekiyorsa bayrakla koşulur.
- 🔴 **İki istemcinin `clientId`'si kanıta AYRI AYRI yazılır** — kriter 8'in kendi şartı.

---

## 2. SENARYO — kriter 8'in ④–⑦ adımları (spec'ten, kısaltılmadan)

> Neden bu sıra: `D-SS2-11`. `/v1/sync` **tek çağrıda** hem iter hem çeker ve `_tekSonucIsle`
> `Applied`/`Duplicate` satırını `changesUygula`'dan **önce siler** ⇒ canlı kuyruk sorgusu
> **daima `null`** döner. Çakışma **yalnız** turun **başında** alınan anlık görüntü sayesinde
> görülür. **Senaryo bu pencereye girmezse kriter 8 hiç tetiklenmez** (v1'in BLOKER-5'i).

4. **B çevrimdışına alınır** (`adb shell svc wifi disable` ya da uçak modu — hangisi kullanıldıysa
   **yazılır**), B'de görevin başlığı **`B1`** yapılır ⇒ op **kuyrukta** (`bekliyor`).
5. **A** aynı görevin başlığını **`A1`** yapar ve **senkronize olur**.
   🔴 **A, B'den SONRA yazar** — kaybedeni HLC belirler; A'nın B'yi yenmesi **garanti edilir**.
6. **B çevrimiçi olur** ve **bekleyen op'u varken** bir tur koşar ⇒ çakışma **görülür**:
   B'de **rozet çıkar**, `CakismaCozumSayfasi` **`B1` ↔ `A1`** gösterir.
7. **"Benimkini tut"** (`cakismaCoz(entityId, benimkiniTut)`) ⇒ B'nin **listesinde `B1` görünür**
   (🔴 **projeksiyon DA yazıldı** — v1'de yazılmıyordu, kullanıcı butona basıyor liste değişmiyordu)
   **ve `A1` üzerine yazarak A'ya ULAŞIR**.

---

## 3. KANIT — `KANIT/SS2/T8-uctan-uca/` altına, **HAM**

🔴 **Özet dosyası kanıt sayılmaz** (kriter 9). Her adımın **ham** çıktısı ayrı dosyaya:

| dosya | içerik |
|---|---|
| `00-ortam.txt` | `docker ps -a` · health yoklama turları · `netstat -ano \| findstr :5298` · `adb devices` · `flutter emulators` |
| `01-backend-hazir.txt` | `_backend_dogrula.py` ham çıktısı (üç ölçüm, GUID `clientId` görünür) |
| `02-clientid.txt` | A ve B'nin `clientId`'leri + hangi cihaz hangisi |
| `03-adim4-B-cevrimdisi.txt` | ağ kesme komutu + kuyruk durumu (`bekliyor` op görünür) |
| `04-adim5-A-yazdi.txt` | A'nın yazımı + senkron yanıtı |
| `05-adim6-cakisma-gorundu.txt` | B'nin tur logu + rozet + ekran içeriği (`uiautomator dump`, `"dumped to"` yoklanarak) |
| `06-adim7-benimkini-tut.txt` | çözüm sonrası B'nin listesi (**`B1`**) + A'ya ulaştığının ölçümü |
| `07-regresyon.txt` | `flutter.bat test` (taban **549/549**, düşemez) + `flutter.bat analyze --fatal-infos` **0** |

Her dosyanın başına **ne zaman, hangi komutla, hangi elle** ölçüldüğü yazılır.

---

## 4. DOKUNULMAYACAKLAR (kilitli)

- 🔒 **Ürün koduna tek bayt yazılmaz** — bu bir **ÖLÇÜM** turudur, build turu değil.
  Kod değişikliği gerektiren bir kusur bulunursa **DURULUR** ve Onur'a dönülür.
- 🔒 `K46` — `DESIGN.md`'ye tek bayt yazılmaz. 🔒 `K61` dev-kimlik kalkanı. 🔒 `K60` atomik yazım.
- 🔒 `D-SS2-11`'in `bekleyenYerelYazimVarMi` sağlayıcısı ile `kuyrukTabaniSaglayici` (D5)
  **AYRI** şeylerdir; karıştırılmaz.
- 🔒 Commit: yol belirterek, mesajda çift tırnak yok, author `onurkesimbjk@gmail.com`. **PUSH ONUR'DA.**

---

## 5. KABUL — Cowork **bağımsız** ölçer (`K26`)

| # | ölçüt | eşik |
|---|---|---|
| 1 | Ortam üçlüsü ölçüldü | `docker` healthy **yoklanarak** · `/health/live`+`/health/ready`+`/v1/sync` 401→200 · `adb devices` cihazı **gösteriyor** |
| 2 | İki istemci ve iki `clientId` | kanıtta **ayrı ayrı** yazılı |
| 3 | Adım 4 gerçekleşti | B çevrimdışıyken yazılan op kuyrukta **`bekliyor`** görünüyor |
| 4 | Adım 5 gerçekleşti | A'nın yazımı **B'den SONRA** ve senkronize oldu (HLC sırası kanıtta) |
| 5 | **ÇAKIŞMA GÖRÜLDÜ** | B'de rozet **çıktı** ve ekran **`B1` ↔ `A1`** gösterdi — `D-SS2-11` penceresi **fiilen tetiklendi** |
| 6 | **Benimkini tut ÇALIŞTI** | B'nin **listesinde** `B1` (projeksiyon yazıldı) **ve** `A1` üzerine yazılarak A'ya **ulaştı** |
| 7 | Regresyon kırılmadı | `flutter test` **≥ 549**, `analyze --fatal-infos` **0** |
| 8 | Ham kanıt tam | §3'teki sekiz dosya var ve **ham**; özet kanıt sayılmaz |

🔴 **5 ve 6 olmadan 1–4 bir ölçüm değildir.** Çakışma **görülmediyse** kriter 8 **GEÇMEDİ** —
"ortam kuruldu, senaryo koştu" **geçme demek değildir**; v1'in tam kusuru buydu.

---

## 6. NE ÖLÇÜLEMEZ — **peşinen beyan** (kapanmadı, gizlenmedi)

- **Cowork bu ortamı kaldıramaz** (`K80`): Desktop Commander **altıncı oturumdur yok**,
  `device_bash` ayrı bir Linux VM (ağ ad alanı ayrı, Android SDK yok), `computer_*` terminalde
  yalnız 'click' kipinde. ⇒ `docker`/`netstat`/`adb` Cowork'ten **ÖLÇÜLEMEZ**; Cowork **ham
  kanıt dosyalarını** okuyarak hüküm verir.
- **`flutter test --platform chrome`** bu ortamda sonuç üretmiyor (7 dk ve 9,8 dk) ⇒ web test
  ayağı **[DOĞRULANMADI]**.
- **`--no-web-resources-cdn`'in `run -d chrome` için gerekliliği** ölçülmemiştir (`B-O63-2`).
- **Ters yön** (uzak kaybettiğinde kayıt) `D-SS2-10` ile **kapsam dışıdır** (`S2`).

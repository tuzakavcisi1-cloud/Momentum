# DURUM.md — Momentum · CANLI DURUM (her oturumun TEK zorunlu okuması)

> **Bu dosya kısa kalmak ZORUNDADIR.** Hedef: **≤ 12 KB**. Aşarsa budanır, tarihçe `PROJE_HAFIZA.md`'ye taşınır.
> `PROJE_HAFIZA.md` artık **APPEND-ONLY KARAR ARŞİVİDİR**; oturum açılışında **okunmaz**, yalnız *"bu karar neden alındı?"* diye sorulduğunda açılır.
> **Son güncelleme:** 26 Tem 2026, oturum 29 (K53).

---

## 1. Proje

Çok platformlu görev yönetimi (to-do): **Flutter** istemci (Android + Web) + **N-katmanlı .NET 9 / ASP.NET Core** backend + **PostgreSQL**. İşe-alım/portfolyo ödevi; odak **mimari ve kod kalitesi**. Vitrin: **çevrimdışı-öncelikli senkron + gerçek zamanlı işbirliği**.

Kanonik kök: `C:\Users\gulci\Desktop\MEMO ÖDEV PROGRAMLAR\TO DO LİST\Momentum`

---

## 2. AÇILIŞ PROTOKOLÜ (sırayla, atlanmaz)

1. **Bu dosyayı** + `CLAUDE.md`'yi oku. *(`PROJE_HAFIZA.md`'yi okuma — gerekirse sonra bak.)*
2. `python araclar\radar.py --altin-kume` (EXIT 0) → `python araclar\radar.py .`
   **KIRMIZI ise yeni tur YASAK**; dört şık Onur'a sunulur, **varsayılan DEVRET**.
3. `git --no-optional-locks status --porcelain` + `Test-Path .git\index.lock`
4. §4'teki **SIRADAKİ İŞ**'ten devam et.

---

## 3. CANLI DURUM

| alan | durum |
|---|---|
| **Backend** | ✅ slice-1 → 3a bitti. `araclar\verify.ps1` ⇒ build 0 uyarı/0 hata · **test 110/110** · CVE 0 · EXIT 0 |
| **Veritabanı** | ✅ Docker 29.6.1, `momentum-postgres` Up (healthy) |
| **İstemci (Flutter)** | ⛔ **0 satır Dart.** Spec kilitli (K52), build **henüz başlamadı** |
| **Tasarım sistemi** | ✅ `DESIGN.md` v1 (15.742 b · `534DFF68`) — 32 token, 8 görsel bileşen, 8 durum, A11Y‑1…7 |
| **ADR 0003 (kimlik)** | 🧊 v7 **DONDURULDU** (K41). Kanonik v6. **DOKUNMA** |
| **Radar** | `GOREV-slice-3b-spec` KIRMIZI (kalan sınıf `esdeger-mutant`, build'e devredildi) · `slice-3b-istemci` YEŞİL · `docs/ADR/0003` KIRMIZI (park, beklenen) |
| **Git** | `origin/main`'e göre **ileride**, **PUSH ONUR'DA** |

**Ortam:** Flutter 3.44.6 · Dart 3.12.2 · Android SDK 36.1.0 ✓ · Chrome/web ✓ · .NET 9.0.316 · **Windows masaüstü ☠** (`%PROGRAMFILES(X86)%` yok) · dart MCP **1.1.0, 14 araç** (`.mcp.json` → `dart pub global run dart_mcp_server`).

---

## 4. SIRADAKİ İŞ

**Claude Code build eder:** `GOREV_CLAUDE_CODE\GOREV-slice-3b-istemci-iskeleti.md` (**KİLİTLİ, K52**) — Flutter iskeleti (Android+Web) + Drift + **tam çevrimdışı CRUD** + yedi kapı + mutantlar + `KANIT/slice-3b/`.
Claude Code **`Momentum` kökünden** açılır. Cowork **build etmez**; dönüşte artefaktı **bağımsız doğrular**.

Sonra: **K42-d adım 3** (senkron kuyruğu + `POST /v1/sync`) → **adım 4** (SignalR `SyncHub`).

---

## 5. YÜRÜRLÜKTEKİ KİLİTLER (tek satır; gerekçe `PROJE_HAFIZA.md`'de)

- **K53** — Verimlilik reformu: kâğıt denetim turu tavanı **1** · radar KIRMIZI'da varsayılan **DEVRET** · koşan-uygulama-mutant tavanı **3** · iki oturum 0 ürün kodu = **sert durak (R7)** · hafıza bölündü.
- **K52** — `GOREV-slice-3b` spec'i **KİLİTLİ**. Kilitli kimlik: **34.821 b · `1AB02B73`**. Değişen her bayt kilidi bozar.
- **K46** — `DESIGN.md`'ye **tek bayt yazılmaz** (BD‑1…BD‑7 borçları açık).
- **K42-d** — Taç mücevher dilimi dört adım, atlanmaz: (1)✅ Docker+verify → (2) Flutter+Drift+çevrimdışı CRUD → (3) senkron kuyruğu → (4) SignalR.
- **K41** — ADR 0003 v7 **DONDURULDU**; açılması üç şartın BİRLİKTE sağlanmasına + Onur'un açık onayına bağlı.
- **K44-a** — **Önce araç, sonra belge.**
- **K34-f** — Bir aracı **onaran el**, onu **yazan elden AYRI** olmalı.
- **K26** — Üretici kendi denetçisini spawn edemez. **Üreten ≠ denetleyen.**
- **K21** — Oturum sağlığı ÖLÇÜLÜR: 🟢<%55 · 🟡%55‑75 · 🔴>%75. **Ölçemezsen yeşil de kırmızı da varsayma.**
- **K40** — Radar KIRMIZI'da yeni tur YASAK; kilit **Onur'dan** gelir.
- **§4** — **Ölç ya da `[DOĞRULANMADI]` yaz.** "Beyan edilmiş sınır kabul edilir, gizlenmiş sınır edilmez."

---

## 6. ARAÇLAR (`araclar\`) — hepsi önce kendini kanıtlar

| araç | ne yapar | altın küme |
|---|---|---|
| `radar.py` **0.2.0** | kısır döngü teşhisi + **R7 ürün kodu durgunluğu** | **11/11** |
| `spec-kapi-kapsama.py` | spec'te **mutantsız kapı/kural** arar; borç beyanı okur | **13/13** |
| `design-token-kapisi.py` | `DESIGN.md` ↔ Dart token kapısı (`D0`–`D6`) | **12/12** |
| `dosya-kimlik.py` | bayt + sha256 + U+FFFD + CRLF ölçer | — |
| `mcp-arac-probe.py` | MCP sunucusunun **gerçek** araç listesi (`tools/list`) | — |
| `pub-surum-olc.py` | pub.dev `/api` sürüm + advisory | — |
| `lisans-yokla.py` | lisansın hangi uçta olduğunu ölçer | — |
| `adr-kapi-taramasi.py` | ADR 0003 kapısı (**dondurulmuş artefakt**, dokunma) | — |
| `verify.ps1` | backend build+test+CVE zinciri | — |

---

## 7. KANLA YAZILI ORTAM UYARILARI

- **Claude Code DAİMA `Momentum` kökünden açılır** (üst klasörden açarsan `.mcp.json` görünmez, dart MCP yüklenmez).
- **Cowork→PowerShell köprüsü `$` değişkenlerini SİLİYOR** ve iç içe tırnakları bozuyor ⇒ `$` gönderme, **Python betiği yaz**.
- **Commit mesajına ÇİFT TIRNAK yazma** (PowerShell argümanı böler, commit sessizce düşer). Her commit'ten sonra `git log --oneline -1` ile SHA'yı doğrula.
- **git'te `--no-optional-locks` ZORUNLU.** Commit **yalnız Desktop Commander** ile; `device_bash`/mount ile **YASAK**. **PUSH ONUR'DA.**
- **`device_stage_files` BAYAT KOPYA sunuyor** (ölçüldü: v2 stage'lendi, v1 göründü) ⇒ gerçeği **`desktop-commander read_file`** ile oku; denetçi ajanlara **kanonik yol** ver.
- **`.ps1`'e Türkçe yol literali yazma** (PowerShell 5.1 ANSI okur, `Test-Path` sessizce `False`).
- **pub.dev HTML sayfaları BAYAT veri döndürür** — kanıt yalnız `/api/` ucudur.
- **Kimlik ölçümü SON yazımdan SONRA alınır** (iki kez bayat kimlik yazıldı).
- `kasif` skill'ini **Cowork çağıramaz**; Onur `/kasif` yazar.

---

## 8. AÇIK BORÇLAR (adlandırılmış, gizlenmemiş)

- **`DESIGN.md` BD‑1…BD‑7** — koyu tema kapısız (§1.1 tablo, `tokens` bloğunda değil) · `renk.ayirici` kuralı numarasız/ölü · odak-halkası/birincil kontrast çifti ölçülmemiş · `MomentumTema` widget değil · `20/28` mutlak mı oran mı belirsiz · "10/10" bayat (araç 12 vaka) · §3.1 dört MUST token'ı hiçbir bileşene atamıyor. **K46 gereği kapatılmadı.**
- **`radar.py` kanonik-kopya borcu** — proje kopyası 0.2.0, **plugin sürümü bu düzeltmeleri taşımıyor**. Kanonik = proje içindeki.
- **`pub.dev` uçları** (`/advisories`, `/metrics`) dokümantasyonsuz ve sürüm garantisiz — kalkan: fixture altın kümeleri.
- **Kontrast betiğinin kalıcı hâli** `araclar/` dışında; kod tarafı G5'in `textContrastGuideline` ayağına girdi.
- **Açık `[DOĞRULANMADI]` (5):** flutter_secure_storage Windows şifrelemesi · WebKit `http://localhost` `__Host-` · Isopoh lisans ailesi · NIST SP 800-38D · Web'de `textScaler`/tema davranışının Android'den farkı.
- **Geçici artıklar (repo DIŞINDA, silme Onur'da):** `…\TO DO LİST\` altında `_cowork_*.ps1` · `%TEMP%\_cw_*`.

---

## 9. DOSYA KİMLİKLERİ (`sha256` ilk 8 · **son yazımdan sonra ölçülür**)

`python araclar\dosya-kimlik.py DURUM.md CLAUDE.md DESIGN.md PROJE_RADAR.jsonl GOREV_CLAUDE_CODE\GOREV-slice-3b-istemci-iskeleti.md`

| dosya | bayt | sha8 |
|---|---|---|
| `DESIGN.md` | 15.742 | `534DFF68` |
| `CLAUDE.md` | 8.936 | `8DA5338E` |
| `GOREV-slice-3b-istemci-iskeleti.md` | **36.337** | **`BE4581BA`** 🔒 **KİLİTLİ (K54)** |
| `araclar/radar.py` **0.2.0** | 21.257 | `D0D2A845` |
| `araclar/spec-kapi-kapsama.py` | 12.591 | `9A38BC62` |
| `araclar/adr-kapi-taramasi.py` | 50.582 | `A22841F2` |

⚠ **`Measure-Object -Line` boş satırları saymaz.** Kimlik `sha256`+bayttır, satır DEĞİL.

---

## 10. NEREDE NE VAR

`DURUM.md` (bu dosya, **canlı durum**) · `CLAUDE.md` (kalıcı kurallar) · `PROJE_HAFIZA.md` (**append-only karar arşivi**, K1…K53) · `DESIGN.md` (tasarım sistemi) · `PROJE_RADAR.jsonl` (ölçüm defteri) · `docs/ADR/` · `GOREV_CLAUDE_CODE/` (build spec'leri) · `araclar/` (kapılar) · `KANIT/` (kanıt) · `src/`, `tests/` (backend).

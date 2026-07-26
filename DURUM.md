# DURUM.md — Momentum · CANLI DURUM (her oturumun TEK zorunlu okuması)

> **Bu dosya kısa kalmak ZORUNDADIR.** Hedef: **≤ 12 KB**. Aşarsa budanır, tarihçe `PROJE_HAFIZA.md`'ye taşınır.
> `PROJE_HAFIZA.md` artık **APPEND-ONLY KARAR ARŞİVİDİR**; oturum açılışında **okunmaz**, yalnız *"bu karar neden alındı?"* diye sorulduğunda açılır.
> **Son güncelleme:** 26 Tem 2026, oturum 29 (K53).

---

## 1. Proje

Çok platformlu görev yönetimi (to-do): **Flutter** istemci (Android + Web) + **N-katmanlı .NET 9 / ASP.NET Core** backend + **PostgreSQL**. İşe-alım/portfolyo ödevi; odak **mimari ve kod kalitesi**. Vitrin: **çevrimdışı-öncelikli senkron + gerçek zamanlı işbirliği**.

**Kanonik kök: `C:\dev\Momentum`** 🔴 **[K56, 26 Tem 2026 — TAŞINDI]**
> Eski kök `…\MEMO ÖDEV PROGRAMLAR\TO DO LİST\Momentum` idi ve **yoldaki Türkçe karakterler (Ö/İ) DÖRT ayrı araç zincirini kırıyordu** (§7). Kök neden kaldırıldı; **junction kaldırıldı, `android.overridePathCheck` EKLENMEDİ** — hiçbir kapı susturulmadı.

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
| **İstemci (Flutter)** | 🟢 **T0→T7 BİTTİ** (son commit `3f043ca`). `tokens.dart` (32 sembol) · `veritabani.dart`+`gorev_deposu.dart` (F4 dikişi, UUID v4, paketsiz) · 8 bileşen + `MomentumTema` · durum vitrini (8 durum `ByValueKey` ile) · `main.dart` gerçek uygulamaya bağlı (F7 bayrak korumalı). **`flutter analyze` 0 bulgu · `flutter test` 20/20 yeşil · üretilen `.g.dart`'ta 0 mutlak yol.** **Sıradaki: T8 (kapı araçları) — taşımadan sonra.** |
| **Tasarım sistemi** | ✅ `DESIGN.md` v1 (15.742 b · `534DFF68`) — 32 token, 8 görsel bileşen, 8 durum, A11Y‑1…7 |
| **ADR 0003 (kimlik)** | 🧊 v7 **DONDURULDU** (K41). Kanonik v6. **DOKUNMA** |
| **Radar** | `GOREV-slice-3b-spec` KIRMIZI (kalan sınıf `esdeger-mutant`, build'e devredildi) · `slice-3b-istemci` YEŞİL · `docs/ADR/0003` KIRMIZI (park, beklenen) |
| **Git** | **PUSH DAİMA ONUR'DA** — Cowork ve Claude Code **asla push etmez**. İleri/geri durumu **yazılmaz, açılışta ÖLÇÜLÜR**: `git --no-optional-locks rev-list --left-right --count origin/main...HEAD` |

**Ortam:** Flutter 3.44.6 · Dart 3.12.2 · Android SDK 36.1.0 ✓ · Chrome/web ✓ · .NET 9.0.316 · **Windows masaüstü ☠** (`%PROGRAMFILES(X86)%` yok) · dart MCP **1.1.0, 14 araç** (`.mcp.json` → `dart pub global run dart_mcp_server`).

---

## 4. SIRADAKİ İŞ

**Claude Code build eder:** `GOREV_CLAUDE_CODE\GOREV-slice-3b-istemci-iskeleti.md` (**v4, KİLİTLİ, K54**) — Flutter iskeleti (Android+Web) + Drift + **tam çevrimdışı CRUD** + yedi kapı + 23 mutant + `KANIT/slice-3b/`. **T0·T1·T2 bitti ⇒ T3'ten devam.** Mutantlar §6'daki **maliyet sınıfı sırasıyla**: **A (statik) → B (widget) → C (koşan uygulama: M3·M9·M4)**.
Claude Code **`Momentum` kökünden** açılır. Cowork **build etmez**; dönüşte artefaktı **bağımsız doğrular**.

Sonra: **K42-d adım 3** (senkron kuyruğu + `POST /v1/sync`) → **adım 4** (SignalR `SyncHub`).

---

## 5. YÜRÜRLÜKTEKİ KİLİTLER (tek satır; gerekçe `PROJE_HAFIZA.md`'de)

- **K53** — Verimlilik reformu: kâğıt denetim turu tavanı **1** · radar KIRMIZI'da varsayılan **DEVRET** · koşan-uygulama-mutant tavanı **3** · iki oturum 0 ürün kodu = **sert durak (R7)** · hafıza bölündü.
- **K54** — `GOREV-slice-3b` spec'i **v4, KİLİTLİ**. Kilitli kimlik: **36.337 b · `BE4581BA`** (K52'nin `1AB02B73`'ü geçersizdir). Değişen her bayt kilidi bozar.
- **K55** — Başka bir el çalışırken `git add -A` **YASAK**; `urun_kodu_satiri` = *"o oturumda repoya giren ürün kodu, **hangi el olursa olsun**"*.
- **K56** — Kanonik kök **saf ASCII** olmak zorunda (`C:\dev\Momentum`). `android.overridePathCheck` **eklenmez**; junction **kullanılmaz**. Kapı susturmak yerine **kök neden kaldırıldı**.
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
- 🔴 **YOL SAF ASCII KALMAK ZORUNDA [K56].** Türkçe karakter (Ö/İ) **dört** araç zincirini kırdı: `build_runner` · `flutter analyze` (LSP çerçeveleme) · **AGP** · `.ps1` yol literali. Boşluk **suçsuz**, izole edildi. **Junction çözmez** (JVM reparse point'i gerçek yola çözer). `android.overridePathCheck` **eklenmez**. Ayrıntı: `KANIT/slice-3b/ORTAM-YOL-KISITI.txt` + `PROJE_HAFIZA.md` K56.
- **Git Bash/MSYS, `cmd /c`'deki `/c`'yi POSIX yol sanıp `C:/` diye YENİDEN YAZIYOR** (ölçüldü: gerçek komut `cmd C:/ dart pub …` olarak koştu, süreç dakikalarca takıldı) ⇒ ham `cmd /c` içeren komutlar **PowerShell'den** koşulur.
- **Başka bir el (Claude Code) çalışırken `git add -A` YASAK** — onun commit'lenmemiş işini kör olarak içeri alır (ölçüldü: `dee6dbc`). Yol belirterek `git add <yol>` yap ya da o el commit'ini atana kadar bekle.
- **`flutter test --platform chrome` bu ortamda SONUÇ ÜRETMİYOR** (iki bağımsız ölçüm: 7 dk ve 9,8 dk, boş testle bile `loading…`'de kaldı) ⇒ web test ayağı `[DOĞRULANMADI]`.
- **`.ps1`'e Türkçe yol literali yazma** (PowerShell 5.1 ANSI okur, `Test-Path` sessizce `False`).
- **pub.dev HTML sayfaları BAYAT veri döndürür** — kanıt yalnız `/api/` ucudur.
- **Kimlik ölçümü SON yazımdan SONRA alınır** (iki kez bayat kimlik yazıldı).
- `kasif` skill'ini **Cowork çağıramaz**; Onur `/kasif` yazar.

---

## 8. AÇIK BORÇLAR (adlandırılmış, gizlenmemiş)

- **`DESIGN.md` BD‑1…BD‑7** — koyu tema kapısız (§1.1 tablo, `tokens` bloğunda değil) · `renk.ayirici` kuralı numarasız/ölü · odak-halkası/birincil kontrast çifti ölçülmemiş · `MomentumTema` widget değil · `20/28` mutlak mı oran mı belirsiz · "10/10" bayat (araç 12 vaka) · §3.1 dört MUST token'ı hiçbir bileşene atamıyor. **K46 gereği kapatılmadı.**
- 🔴 **`radar.py` proje kopyası GERİDE [2 kalem]** — ① ürün-kodu kuralı **`R7`** adını taşıyor ama plugin doktrininde `R7` zaten *"kapı granülerliği"*; doğru ad **`R8`** (kod + defter + bu dosya düzeltilmeli). ② Plugin **0.2.0**'ın yenilikleri (defter dürüstlük kapısı `D1`–`D5`, `--olc-urun-kodu`, `radar.config.json`, altın küme 18 vaka) proje kopyasında **yok**; geri taşınmalı.
- 🔴 **Spec T2/Z10 kilit düzeltmesi [açık]** — `build_runner ^2.15.2` bu SDK'yla **çözülemiyor**; fiilen `^2.15.1` kullanıldı (`analyzer 13.0.0` · `meta 1.18.0`), sapma `KANIT/slice-3b/T2-SAPMA.txt`'te. **T2 + Z10 güncellenmeli, yeni kilit sha'sı ölçülmeli.** Adlandırılmış boşluk: *sürüm ölçümü ≠ çözümlenebilirlik ölçümü* (`pub-surum-olc.py`'ye çözümlenebilirlik ayağı).
- **`pub.dev` uçları** (`/advisories`, `/metrics`) dokümantasyonsuz ve sürüm garantisiz — kalkan: fixture altın kümeleri.
- **Kontrast betiğinin kalıcı hâli** `araclar/` dışında; kod tarafı G5'in `textContrastGuideline` ayağına girdi.
- **Açık `[DOĞRULANMADI]` (5):** flutter_secure_storage Windows şifrelemesi · WebKit `http://localhost` `__Host-` · Isopoh lisans ailesi · NIST SP 800-38D · Web'de `textScaler`/tema davranışının Android'den farkı.
- **Geçici artıklar (repo DIŞINDA, silme Onur'da):** `…\TO DO LİST\` altında `_cowork_*.ps1` · `%TEMP%\_cw_*`.

---

## 9. DOSYA KİMLİKLERİ (`sha256` ilk 8 · **son yazımdan sonra ölçülür**)

`python araclar\dosya-kimlik.py DURUM.md CLAUDE.md DESIGN.md PROJE_RADAR.jsonl GOREV_CLAUDE_CODE\GOREV-slice-3b-istemci-iskeleti.md`

🔴 **BURAYA YALNIZ *DONMUŞ* KİMLİKLER YAZILIR.** Sık değişen bir dosyanın sha'sını buraya yazmak `kanonik-kopya` kusurunu **garanti eder** — bu tabloda **üç kez** bayat kimlik oluştu (oturum 29). Değişken dosyaların kimliği **yazılmaz, ÖLÇÜLÜR**:

```powershell
python araclar\dosya-kimlik.py DURUM.md CLAUDE.md DESIGN.md PROJE_RADAR.jsonl GOREV_CLAUDE_CODE\GOREV-slice-3b-istemci-iskeleti.md
```

**DONMUŞ KİMLİKLER (bunlar SÖZLEŞMEDİR — değişirse bir kilit bozulmuş demektir):**

| dosya | bayt | sha8 | neden donmuş |
|---|---|---|---|
| `DESIGN.md` | 15.742 | `534DFF68` | **K46** — tek bayt yazılamaz |
| `GOREV-slice-3b-istemci-iskeleti.md` | **36.337** | **`BE4581BA`** | 🔒 **K54 kilidi** — değişen her bayt kilidi bozar |
| `araclar/adr-kapi-taramasi.py` | 50.582 | `A22841F2` | **K34-f** tutuyor; ADR donduruldu |

⚠ **`Measure-Object -Line` boş satırları saymaz.** Kimlik `sha256`+bayttır, satır DEĞİL.
⚠ **Kimlik ölçümü DAİMA son yazımdan SONRA alınır.**

---

## 10. NEREDE NE VAR

`DURUM.md` (bu dosya, **canlı durum**) · `CLAUDE.md` (kalıcı kurallar) · `PROJE_HAFIZA.md` (**append-only karar arşivi**, K1…K53) · `DESIGN.md` (tasarım sistemi) · `PROJE_RADAR.jsonl` (ölçüm defteri) · `docs/ADR/` · `GOREV_CLAUDE_CODE/` (build spec'leri) · `araclar/` (kapılar) · `KANIT/` (kanıt) · `src/`, `tests/` (backend).

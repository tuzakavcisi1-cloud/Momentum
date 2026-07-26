# DURUM.md — Momentum · CANLI DURUM (her oturumun TEK zorunlu okuması)

> **Bu dosya kısa kalmak ZORUNDADIR.** Hedef: **≤ 12 KB**. Aşarsa budanır, tarihçe `PROJE_HAFIZA.md`'ye taşınır.
> `PROJE_HAFIZA.md` artık **APPEND-ONLY KARAR ARŞİVİDİR**; oturum açılışında **okunmaz**, yalnız *"bu karar neden alındı?"* diye sorulduğunda açılır.
> **Son güncelleme:** 26 Tem 2026, oturum 30 (K57).

---

## 1. Proje

Çok platformlu görev yönetimi (to-do): **Flutter** istemci (Android + Web) + **N-katmanlı .NET 9 / ASP.NET Core** backend + **PostgreSQL**. İşe-alım/portfolyo ödevi; odak **mimari ve kod kalitesi**. Vitrin: **çevrimdışı-öncelikli senkron + gerçek zamanlı işbirliği**.

**Kanonik kök: `C:\dev\Momentum`** 🔴 **[K56 — TAŞINDI]** · Eski kökteki Türkçe karakterler dört araç zincirini kırıyordu (§7); kök neden kaldırıldı, **junction yok, `android.overridePathCheck` EKLENMEDİ** — hiçbir kapı susturulmadı.

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
| **İstemci (Flutter)** | 🟢 **T0→T7 BİTTİ** (`3f043ca`). `tokens.dart` (32 sembol) · `veritabani.dart`+`gorev_deposu.dart` (F4 dikişi, UUID v4) · 8 bileşen + `MomentumTema` · durum vitrini · `main.dart` bağlı (F7 bayraklı). **analyze 0 · test 20/20 · `.g.dart`'ta 0 mutlak yol.** `pubspec` `build_runner ^2.15.1` (ölçüldü). **Sıradaki: T8.** |
| **Tasarım sistemi** | ✅ `DESIGN.md` v1 (15.742 b · `534DFF68`) — 32 token, 8 görsel bileşen, 8 durum, A11Y‑1…7 |
| **ADR 0003 (kimlik)** | 🧊 v7 **DONDURULDU** (K41). Kanonik v6. **DOKUNMA** |
| **Radar** | `radar.py` **plugin 0.2.0 ile bayt-özdeş** — R8 · D1‑D5 · `--olc-urun-kodu` · altın küme **18/18**. Hüküm **KIRMIZI**: `GOREV-slice-3b-spec` (`esdeger-mutant`, build'e devredildi) · `docs/ADR/0003` (park) · diğer ikisi YEŞİL |
| **Git** | **PUSH DAİMA ONUR'DA.** İleri/geri durumu **yazılmaz, açılışta ÖLÇÜLÜR**: `git --no-optional-locks rev-list --left-right --count origin/main...HEAD` |

**Ortam:** Flutter 3.44.6 · Dart 3.12.2 · Android SDK 36.1.0 ✓ · Chrome/web ✓ · .NET 9.0.316 · **Windows masaüstü ☠** · dart MCP **1.1.0, 14 araç** (`.mcp.json` → `dart pub global run dart_mcp_server`).

---

## 4. SIRADAKİ İŞ

**Claude Code build eder:** `GOREV_CLAUDE_CODE\GOREV-slice-3b-istemci-iskeleti.md` (**v5, KİLİTLİ, K57**) — Flutter iskeleti (Android+Web) + Drift + **tam çevrimdışı CRUD** + yedi kapı + 23 mutant + `KANIT/slice-3b/`. **T0→T7 bitti ⇒ T8'den devam.** Mutantlar §6'daki **maliyet sınıfı sırasıyla**: **A (statik) → B (widget) → C (koşan uygulama: M3·M9·M4)**.
🔴 **TAŞIMA DOĞRULAMASI ÖNCE:** Claude Code T8'e geçmeden `flutter analyze` + `flutter test` **junction OLMADAN** koşar; Android tarafı `android.overridePathCheck` **OLMADAN** derlenir. Geçmezse **DUR ve raporla**.
Claude Code **`Momentum` kökünden** açılır. Cowork **build etmez**; dönüşte artefaktı **bağımsız doğrular**.

Sonra: **K42-d adım 3** (senkron kuyruğu + `POST /v1/sync`) → **adım 4** (SignalR `SyncHub`).

---

## 5. YÜRÜRLÜKTEKİ KİLİTLER (tek satır; gerekçe `PROJE_HAFIZA.md`'de)

- **K53** — Verimlilik reformu: kâğıt denetim turu tavanı **1** · radar KIRMIZI'da varsayılan **DEVRET** · koşan-uygulama-mutant tavanı **3** · iki oturum 0 ürün kodu = **sert durak (`R8` — K57'de `R7`'den yeniden adlandırıldı)** · hafıza bölündü.
- **K57** — Spec **v5, KİLİTLİ**: **42.395 b · `6056A5BB`** (`BE4581BA`, `1AB02B73` ve ara ölçüm `79A53AA3` **GEÇERSİZ**). On **bayat çapraz-atıf** düzeltildi; özü değişmedi. Onuncuyu, kilitten **sonra** doğan `sayi-tazeligi.py` buldu. Ayrıntı: `PROJE_HAFIZA.md` K57.
- **K57‑b** — `araclar/radar.py` **plugin 0.2.0 ile BAYT-ÖZDEŞ** (`46E3A8BC`); proje-yerel not **eklenmez** ⇒ sapma **tek sha ile** ölçülür.
- **K55** — Başka bir el çalışırken `git add -A` **YASAK**; `urun_kodu_satiri` = *"o oturumda repoya giren ürün kodu, **hangi el olursa olsun**"*.
- **K56** — Kanonik kök **saf ASCII** (`C:\dev\Momentum`); `android.overridePathCheck` **eklenmez**, junction **kullanılmaz**.
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
| `radar.py` **0.2.0** | kısır döngü + **R8 ürün kodu durgunluğu** + **defter dürüstlük kapısı D1‑D5** + `--olc-urun-kodu` (git'ten türetir) | **18/18** |
| `spec-kapi-kapsama.py` | spec'te **mutantsız kapı/kural** arar; borç beyanı okur | **13/13** |
| `sayi-tazeligi.py` **1.1.0** | belgedeki **"altın küme N/M"** iddiasını **aracı koşarak** doğrular; muafiyet `araclar/tazelik-muafiyet.json`'da ve **gerekçesiz olamaz** | **16/16** |
| `design-token-kapisi.py` | `DESIGN.md` ↔ Dart token kapısı (`D0`–`D6`) | **12/12** |
| `dosya-kimlik.py` | bayt + sha256 + U+FFFD + CRLF ölçer | — |
| `mcp-arac-probe.py` | MCP sunucusunun **gerçek** araç listesi (`tools/list`) | — |
| `pub-surum-olc.py` | pub.dev `/api` sürüm + advisory | — |
| `lisans-yokla.py` | lisansın hangi uçta olduğunu ölçer | — |
| `adr-kapi-taramasi.py` | ADR 0003 kapısı (**dondurulmuş artefakt**, dokunma) | — |
| `verify.ps1` | backend build+test+CVE zinciri | — |

---

## 7. KANLA YAZILI ORTAM UYARILARI

- **Claude Code DAİMA `Momentum` kökünden açılır** (üstten açarsan `.mcp.json` görünmez, dart MCP yüklenmez).
- **Cowork→PowerShell köprüsü `$` değişkenlerini SİLİYOR** ve iç içe tırnakları bozuyor ⇒ `$` gönderme, **Python betiği yaz**.
- **Commit mesajına ÇİFT TIRNAK yazma** (PowerShell argümanı böler, commit sessizce düşer). Her commit'ten sonra `git log --oneline -1` ile SHA'yı doğrula.
- **git'te `--no-optional-locks` ZORUNLU.** Commit **yalnız Desktop Commander** ile; `device_bash`/mount ile **YASAK**. **PUSH ONUR'DA.**
- **`device_stage_files` BAYAT KOPYA sunabiliyor** (oturum 28; oturum 30'da **tekrarlanmadı**) ⇒ stage'lenen kopyanın **sha'sını `Get-FileHash` ile karşılaştır**; tutmuyorsa `desktop-commander read_file` kullan.
- 🔴 **YOL SAF ASCII KALMAK ZORUNDA [K56].** Türkçe karakter dört zinciri kırdı: `build_runner` · `flutter analyze` · **AGP** · `.ps1` yol literali. Boşluk **suçsuz**. **Junction çözmez.** Ayrıntı: `KANIT/slice-3b/ORTAM-YOL-KISITI.txt`.
- **Git Bash/MSYS, `cmd /c`'deki `/c`'yi POSIX yol sanıp `C:/` diye YENİDEN YAZIYOR** ⇒ ham `cmd /c` içeren komutlar **PowerShell'den** koşulur.
- **Başka bir el çalışırken `git add -A` YASAK** — commit'lenmemiş işini kör alır (ölçüldü: `dee6dbc`). Yol belirterek `git add <yol>` yap.
- **`flutter test --platform chrome` bu ortamda SONUÇ ÜRETMİYOR** (iki ölçüm: 7 dk ve 9,8 dk) ⇒ web test ayağı `[DOĞRULANMADI]`.
- **`.ps1`'e Türkçe yol literali yazma** (PowerShell 5.1 ANSI okur, `Test-Path` sessizce `False`).
- **pub.dev HTML sayfaları BAYAT veri döndürür** — kanıt yalnız `/api/` ucudur.
- **Kimlik ölçümü SON yazımdan SONRA alınır** (iki kez bayat kimlik yazıldı).
- `kasif` skill'ini **Cowork çağıramaz**; Onur `/kasif` yazar.

---

## 8. AÇIK BORÇLAR (adlandırılmış, gizlenmemiş)

- **`DESIGN.md` BD‑1…BD‑7** — **K46 gereği kapatılmadı**; tam liste spec §10'da. BD‑6'nın bayat `10/10`'u artık `sayi-tazeligi.py`'de **gerekçeli muafiyet** olarak görünür.
- ✅ **KAPANDI [K57]:** *"`radar.py` kopyası GERİDE"* · *"Spec T2/Z10 kilit düzeltmesi"*.
- 🔴 **`pub-surum-olc.py`'ye ÇÖZÜMLENEBİLİRLİK AYAĞI [yeni, Z10b]** — araç **sürümü** ölçüyor, o sürümün bu SDK'yla **çözülüp çözülmediğini** ölçmüyor; `build_runner ^2.15.2` kusuru buradan çıktı. Kalkan gelene dek **her pin `pub get` ile doğrulanır**.
- 🔴 **Defter dürüstlük kusurları [D-kapısı ilk koşumda buldu]** — `D3`: `docs/ADR/0003` tur 8 kaydının zorunlu alanları eksik. `D2`: aynı defterde **tur 1 atlanmış**. Append-only ⇒ **düzeltme kaydı** yazılır.
- 🟡 **`D1` bu defterde FİİLEN KÖR** — artefakt adları çoğunlukla **etiket**, yol değil. Yeni kayıtlarda **gerçek yol** yazılır.
- 🟡 **`sayi-tazeligi.py` — İMZA↔SAYI YAKINLIĞI ÖLÇÜLMÜYOR [3 kez tetikledi]** — uzun satırlarda araçla ilgisiz bir oran iddia sanılıyor. **Eşik uydurulmadı** (K40); biri muafiyet, biri metin düzeltmesiyle kapandı. **Kalıcı onarım AYRI EL'e** (K34‑f).
- **`radar.config.json` YOK ve bu bir KARAR** — varsayılan yollar repoya birebir uyuyor. Eşik değiştiren K40 gereği **altın kümeye vaka ekler**.
- **`pub.dev` uçları** dokümantasyonsuz/sürüm garantisiz — kalkan: fixture altın kümeleri. · **Kontrast betiğinin kalıcı hâli** `araclar/` dışında.
- **Açık `[DOĞRULANMADI]` (5):** flutter_secure_storage Windows şifrelemesi · WebKit `__Host-` · Isopoh lisans ailesi · NIST SP 800-38D · Web'de `textScaler`/tema farkı.
- **Geçici artıklar (repo DIŞINDA, silme Onur'da):** `…\TO DO LİST\_cowork_*.ps1` · `%TEMP%\_cw_*` · `C:\dev\_cowork_tmp\`.

---

## 9. DOSYA KİMLİKLERİ (`sha256` ilk 8 · **son yazımdan sonra ölçülür**)

🔴 **BURAYA YALNIZ *DONMUŞ* KİMLİKLER YAZILIR.** Sık değişen bir dosyanın sha'sını buraya yazmak `kanonik-kopya` kusurunu **garanti eder** (bu tabloda üç kez bayat kimlik oluştu). Değişken dosyaların kimliği **yazılmaz, ÖLÇÜLÜR**:

```powershell
python araclar\dosya-kimlik.py DURUM.md CLAUDE.md DESIGN.md PROJE_RADAR.jsonl GOREV_CLAUDE_CODE\GOREV-slice-3b-istemci-iskeleti.md
```

**DONMUŞ KİMLİKLER (bunlar SÖZLEŞMEDİR — değişirse bir kilit bozulmuş demektir):**

| dosya | bayt | sha8 | neden donmuş |
|---|---|---|---|
| `DESIGN.md` | 15.742 | `534DFF68` | **K46** — tek bayt yazılamaz |
| `GOREV-slice-3b-istemci-iskeleti.md` | **42.395** | **`6056A5BB`** | 🔒 **K57 kilidi (v5)** — değişen her bayt kilidi bozar. `BE4581BA` ve ara ölçüm `79A53AA3` **geçersizdir** |
| `araclar/radar.py` | 28.878 | `46E3A8BC` | **K57‑b** — plugin 0.2.0 ile bayt-özdeş; sapma tek sha ile ölçülür |
| `araclar/adr-kapi-taramasi.py` | 50.582 | `A22841F2` | **K34-f** tutuyor; ADR donduruldu |

⚠ **Kimlik `sha256`+bayttır, satır DEĞİL** (`Measure-Object -Line` boş satırları saymaz) ve **DAİMA son yazımdan SONRA** ölçülür.

---

## 10. NEREDE NE VAR

`DURUM.md` (**canlı durum**) · `CLAUDE.md` (kalıcı kurallar) · `PROJE_HAFIZA.md` (**append-only arşiv**, K1…K57) · `DESIGN.md` · `PROJE_RADAR.jsonl` (ölçüm defteri) · `docs/ADR/` · `GOREV_CLAUDE_CODE/` · `araclar/` (kapılar) · `KANIT/` · `src/`, `tests/`.

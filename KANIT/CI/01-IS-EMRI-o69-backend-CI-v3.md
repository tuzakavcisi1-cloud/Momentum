# İŞ EMRİ (o69 · **v3**) — BACKEND CI · borç `D-A13-4`

> **İKİ bağımsız kâğıt turu koştu (`K127`), ÜÇÜNCÜ AÇILMADI (`K53`/1).**
> Tur 1 → **8 bloker** (`/home/claude/DENETIM-o69-is-emri.md`); biri **mimariyi değiştirdi**
> (`services:` tasarımı çöktü) ⇒ tur 2 meşru oldu.
> Tur 2 → **4 yeni bloker + 4 major** (`/home/claude/DENETIM-o69-is-emri-v2.md`); **hiçbiri mimariyi
> değiştirmedi** ⇒ `K53`/1 gereği **tur 3 YASAK**. v3, tur 2'nin bulgularını mekanik olarak karşılar
> ve kalanları **BEYAN EDER**. Bundan sonrası **koşan koda devredilir** (`K53`/2 · `K53`/5).
> 🔴 **BU BİR SOHBET BLOĞUDUR, DOSYA DEĞİLDİR** (`K175`②).

## 0. TASARIM KİLİDİ (Onur, o69)
1. **`services: postgres` YOK** — testler kendi konteynerini açıyor (Testcontainers).
2. **`araclar/verify.ps1` ONARILIR** — tek kanonik zincir; **ikinci zincir yazılmaz**.
3. **Kapsam yalnız `D-A13-4`.** `B-O63-2` **AÇIK kalır**, başlıkta kapatma iddiası **YOK**.
4. **Taban 32 · 6 · 41**, sayım `ls-files --cached --others --exclude-standard`.

## 1. ÖLÇÜLMÜŞ TABAN (komutuyla birlikte; her satır bugün cihazda koştu)
| ölçüm | sonuç |
|---|---|
| `wc -c .github/workflows/ci.yml` | **580 b**; iki iş: `istemci`, `ios` |
| `grep -c` | `dotnet` **0** · `verify` **0** · `postgres` **0** · `--no-web-resources-cdn` **0** |
| `cat global.json` | **10.0.302** / `latestPatch` |
| `Directory.Build.props` (backend :16, tests :14) | `TreatWarningsAsErrors` **true** ⇒ `verify.ps1:50`'deki `-warnaserror` **gereksiz** |
| `.csproj:9` + `TestSupport.cs:20-23` | **Testcontainers.PostgreSql 4.13.0**, `postgres:17-alpine` |
| `ls-files --cached --others --exclude-standard` | **32 · 6 · 41** |
| `cat -n .gitattributes` | 🔴 **satır 7** ⇒ `*.ps1   text eol=crlf` |
| pwsh **7.4.6** (bulut) | `verify.ps1` sözdizimi **0 hata**; **satır 26 SONLANDIRICI HATA** |

**Birebir (Cowork, bulut, pwsh 7.4.6):**
```
ProgramFiles tanimli mi: []
SONLANDIRICI HATA: ParameterBindingValidationException ::
  Cannot bind argument to parameter 'Path' because it is null.
```
🔴 **v2'nin bir kusuru düzeltildi:** v2 `.gitattributes:8` diyordu; **doğrusu 7**. Sayı v1'in denetim
raporundan **kopyalanmış ve yeniden ölçülmemişti** — bu turda **üçüncü kez** ısıran `bayat-iddia` sınıfı.

## 2. ÖLÇÜLMEMİŞ — SEN ÖLÇECEKSİN (`KANIT/CI/00-taban-olcum.txt`)
| # | ölçülecek |
|---|---|
| Ö1 | `ubuntu-latest`'te **pwsh** var mı (`pwsh --version` adımı) |
| Ö2 | `ubuntu-latest`'te **Docker daemon** var mı — Testcontainers'ın şartı. 🔴 Cowork *"vardır"* diye biliyor ama **ÖLÇMEDİ** ⇒ `[DOĞRULANMADI]` |
| Ö3 | `actions/setup-dotnet` + `global-json-file` **10.0.302**'yi çekiyor mu (çekemezse **DUR ve BİLDİR**) |
| Ö4 | `ci-kapisi.py`'nin `g28b_flutter_surumu` mantığı yeni işten etkileniyor mu |
| Ö5 | Depoda **PyYAML var mı** — yoksa kriter 3 zaten YAML ayrıştırıcısı istemiyor (aşağıya bak) |

## 3. YAPILACAK — DÖRT DOSYA (yeni dosya **AÇILMAZ**)

### 3a. `araclar/verify.ps1` — İKİ SATIR
🔴 **`.gitattributes:7` ⇒ dosya CRLF.** `ORTAM.md` 38'in **ikili yordamı zorunlu**: `rb` yedek →
bayt yaması (desendeki `\n` → `\r\n`) → `wb` geri yazım → `sha256` ölç. `git restore` **YASAK**.
- **satır 26** `$env:ProgramFiles` **null olabilir** ⇒ null-güvenli yaz.
- **satır 57** ters eğik çizgili yol literali ⇒ `Join-Path` zinciriyle platform-bağımsız.
- Başka satıra **dokunulmaz**; zincirin üç adımı **aynen kalır**.
- 🔴 **`K34-f` BEYAN EDİLMİŞ SAPMA:** `verify.ps1`'i yazan el de Claude Code'du. Karşılığı: onarımın
  **Linux ayağını Cowork bağımsız ölçer** (bulut pwsh), **Windows ayağını cihazda Onur/Code ölçer**
  (`== VERIFY PASSED ==`). 🔴 `ORTAM.md` 47 gereği **bulut koşumu KAPI HÜKMÜ DEĞİLDİR**, ön ölçümdür;
  kapı hükmü kriter 9'daki CI koşumundan gelir.

### 3b. `.github/workflows/ci.yml` — TEK YENİ İŞ: `backend`
- `runs-on: ubuntu-latest`. **`services:` YOK.**
- 🔴 `defaults.run.working-directory: src/client` **global bloğu DEĞİŞMEZ**; iş düzeyinde ezilir:
  `jobs.backend.defaults.run.working-directory: .`
- Adımlar: checkout → `pwsh --version` (Ö1) → `docker info` (Ö2) → `actions/setup-dotnet`
  (`global-json-file: global.json`; **sürüm iş akışına yazılmaz**) → `shell: pwsh` ile `./araclar/verify.ps1`.
- 🔴 **`ASPNETCORE_ENVIRONMENT` SET EDİLMEZ** — `verify.ps1` API'yi ayağa kaldırmıyor, testler ortamı
  `UseEnvironment` ile **kendileri pinliyor** (`DevKimlikKapisiTestleri.cs:29,59`). `K61` gerekçesi
  **başka bağlamdandı**; set etmek pinlemeyen bir testin davranışını **sessizce** değiştirir.
- Tetikleyicilere **dokunulmaz**. **Global `defaults`'a `shell:` EKLENMEZ** (kriter 3'ün karşı örneği).

### 3c. `araclar/ci-kapisi.py` — YENİ AYAKLAR (`A13/G31/a`–`g`) + ALTIN KÜME
Mevcut: **418 satır, altın küme 13/13** (ölçüldü). Yeni ayaklar **kapsam önekli** (`K108`):
| id | ölçer |
|---|---|
| `A13/G31/a` | `backend` işi **var** ve `runs-on: ubuntu-latest` |
| `A13/G31/b` | `./araclar/verify.ps1` **çağrılıyor** ve `shell: pwsh` |
| `A13/G31/c` | `services:` **YOK** (tasarım kararının kapısı) |
| `A13/G31/d` | iş düzeyi `defaults.run.working-directory` ezmesi **var** |
| `A13/G31/e` | **global** `defaults.run` altında `shell:` **YOK** ← *tur 2'nin karşı örneği* |
| `A13/G31/f` | `istemci` ve `ios` işlerinde `if:` **YOK** ← *tur 2'nin ikinci karşı örneği* |
| `A13/G31/g` | `ASPNETCORE_ENVIRONMENT` `ci.yml`'de **geçmiyor** |
🔴 **`_CI_TEMIZ` fikstürü ZATEN SAPMIŞ** (tur 2 ölçtü: gerçek `ci.yml`'de global `defaults` var,
fikstürde yok) ⇒ **fikstür gerçek yapıya hizalanır**, yoksa `d`/`e` ayakları **kör doğar**.
🔴 Her yeni ayak altın kümeye **temizde susan + kirlide ısıran** vaka kazanır (`K40`). Yeni sayı
`13/13` **değildir**; gerçek sayı koşumdan okunur. `DURUM.md` §6'daki **13/13 bilerek bayat kalır** ve
`sayi-tazeligi.py` bunu **KIRMIZI** verecektir ⇒ 🔴 **aynı turda `DURUM.md` §6 satırı da güncellenir**
(bu, `K58`'in *"bir sınırı kapatan el her kopyayı kapatır"* dersinin uygulanmasıdır).

### 3d. `D-A13-4` KAPANIŞI — borcun **kendi yazdığı** yordam
`GOREV-A13-ios-iskeleti-ci.md:296` birebir: *"…**bu satir silinir ve gercek bir kapi+mutant yazilir**."*
⇒ O `§6b` satırı **silinir**; yerine `A13/G31/a`–`g` ve mutantları **atıfla** yazılır.
🔴 **`K58`: sınırı kapatan el, onu BEYAN EDEN her kopyayı kapatır.** Ölçülmüş **yedi** atıf:
| yol | satır | ne yapılacak |
|---|---|---|
| `GOREV-A13-ios-iskeleti-ci.md` | **87** (karar başlığı) · **296** (§6b) · **367** | 87 ve 367 *"`D-A13-4` o69'da KAPANDI"* diye güncellenir; 296 **silinir** |
| `GOREV-W3b-web-yayina-alma.md` | **89** · **372** · **376** | *"`D-A13-4` kapandı; bu ayak **`B-O63-2` olarak AÇIK**"* diye düzeltilir |
| `docs/ADR/0004-…md` | **145** | 🔴 **DOKUNULMAZ — `K175`① ile PARK.** BEYAN EDİLİR: *"ADR 0004'teki `D-A13-4` atfı park nedeniyle güncellenmedi; sarkan atıf **bilinçlidir**."* |

## 4. KABUL KRİTERLERİ — hepsi ÖLÇÜLÜR
1. **Taban:** üç dizin için **ayrı ayrı** `ls-files --cached --others --exclude-standard | wc -l`
   ⇒ **32 · 6 · 41**. Çıplak `ls-files` **KULLANILMAZ**.
2. **Değişen yol kümesi — ölçüm İŞİN BAŞINDAKİ ANLIK GÖRÜNTÜYE karşı yapılır.** İş başlamadan önce
   `git --no-optional-locks status --porcelain -- <dizin>` **dizin dizin** koşulur (tam-ağaç **YASAK**,
   `ORTAM.md` 44) ve `KANIT/CI/00-taban-olcum.txt`'e yazılır. Bitişte **yalnız FARK** değerlendirilir ve
   fark tam olarak şu altı yoldan ibaret olmalıdır:
   `.github/workflows/ci.yml` · `araclar/verify.ps1` · `araclar/ci-kapisi.py` ·
   `GOREV_CLAUDE_CODE/GOREV-A13-ios-iskeleti-ci.md` · `GOREV_CLAUDE_CODE/GOREV-W3b-web-yayina-alma.md` ·
   `DURUM.md` (§6 altın küme satırı) — artı `KANIT/CI/**`.
   🔴 v2 *"başka hiçbir yol yok"* diyordu; o iddia **turun başında bile yanlıştı** (Cowork'ün o69 yazımları
   ağacı zaten kirletmişti). **Fark ölçümü bu kusuru yapısal olarak imkânsız kılar.**
3. **`istemci` ve `ios` DEĞİŞMEDİ — ÇIKARMA TESTİ (yanlışlanabilir):**
   `git --no-optional-locks show HEAD:.github/workflows/ci.yml` → `eski`. Yeni dosyadan **eklenen
   `backend` bloğu tek parça olarak çıkarılır** → sonuç `eski` ile **BAYT-ÖZDEŞ** olmalı (`sha256`).
   🔴 v2'nin *"her hunk yalnız ekleme taşır"* kriteri **KÖRDÜ** — tur 2 mekanik karşı örnek üretti:
   global `defaults.run.shell: pwsh` ve `ios:` altına `if: false`, **iki ekleme, sıfır silme**, kriter
   yine yeşil veriyordu. Çıkarma testi ikisini de **yakalar** (ikinci ekleme kalıntı bırakır).
   Ek kanıt: `A13/G31/e` ve `/f` ayakları + `ci-kapisi.py` mevcut ayaklarında **YEŞİL**.
4. **`verify.ps1` onarımı İKİ ORTAMDA ölçüldü:** ① **Linux/pwsh 7.4.6** — satır 26 **geçiyor**
   (birebir çıktı) ② **Windows/cihaz** — `== VERIFY PASSED ==` (birebir çıktı).
   🔴 **Windows ölçümünün ÖN KOŞULU (`ORTAM.md` 37):** `Momentum.Api` **KAPALI** olmalı; kapanma
   `netstat -ano | findstr :5298` **boş** dönerek **ölçülür**, varsayılmaz. Ayakta bırakılırsa
   `verify.ps1` **EXIT 1 / 36 `MSB3026` hatası** verir ve bu **ürün kusuru değildir**.
5. **`ci-kapisi.py` altın kümesi büyüdü ve GEÇTİ:** `M/M`, EXIT 0; **her yeni ayak için en az bir
   ısıran vaka**; `_CI_TEMIZ` fikstürü gerçek yapıya hizalandı. Kör ayak **yok**.
6. **Statik mutantlar (`K53`/3 — tavansız), dördü de ISIRDI:** `S1` `backend` işini sil ⇒ KIRMIZI ·
   `S2` `verify.ps1` çağrısını sil ⇒ KIRMIZI · `S3` `services:` bloğu ekle ⇒ KIRMIZI ·
   `S4` **pozitif kontrol**: `istemci`'nin `flutter-version`'ını değiştir ⇒ mevcut `g28b` KIRMIZI.
7. **Koşan mutantlar — `verify.ps1` YEREL koşumuyla, CI'sız.**
   🔴 **ÖN KOŞUL — `K80` ORTAM MADDESİ (tur 2'nin blokeri):** mutantlardan **ÖNCE** bir **TABAN
   (mutantsız) koşum** yapılır ve şu üçü **ölçülür**: ① `docker info` **başarılı** (koşula kadar
   yoklanır, **tavanlı**; sabit `sleep` bir ölçüm değildir) ② `netstat` ile `:5298` **boş**
   ③ taban koşumda **`Momentum.Persistence.Tests` GEÇİYOR**. 🔴 Bu üçü ölçülmeden `M-o69-3`'ün
   kanıtı **geçersizdir**: Docker kapalıyken aynı sinyal **mutant olmadan da** doğar.
   | id | mutant | çekirdek iddia | **ayırt edici** kanıt |
   |---|---|---|---|
   | `M-o69-1` | ürün kodunda **derleme HATASI** | build adımı koşuyor **ve düşerse zincir DURUYOR** | `--- build -warnaserror ---` sonra `FAILED`; 🔴 **`--- test ---` HİÇ görünmez** |
   | `M-o69-2` | tek testin iddiasını tersine çevir (**test adı kanıta yazılır**) | test adımı gerçekten koşuyor | build **geçer**, düşen testin **ADI** logda |
   | `M-o69-3` | `TestSupport.cs:21` imaj etiketini geçersiz yap | testler **GERÇEK** PostgreSQL'e karşı koşuyor | `Persistence.Tests` konteyner hatasıyla düşer; 🔴 **`ArchitectureTests` GEÇER** |
   | `M-o69-4` | **CVE kapısı**: bilinen açığı olan bir paket sürümü ekle | CVE ayağı **ısırıyor** | `--- CVE gate ---` altında **KIRMIZI**, `== VERIFY PASSED ==` **yok** |
   🔴 **`M-o69-4` `K53`/3 tavanını AŞMIYOR:** tavan **koşan uygulama** (emülatör/tarayıcı + yeniden
   derleme) mutantları içindir; `dotnet restore`/`list --vulnerable` o sınıf **değildir**. Tur 2 haklı
   olarak *"CVE ayağı mutantsız kalırsa `K155` ihlal edilir — ayak ya çıkarılır ya mutantı yazılır,
   üçüncü şık yok"* dedi. **Mutant yazıldı ⇒ mutant borcu YOK.**
8. **Geri yükleme — MUTANTIN DOKUNDUĞU dosya ölçülür** (v1 yalnız `ci.yml`'e bakıyordu, iki mutant ona
   dokunmuyordu bile): her mutant sonrası o dosya `sha256` ile **bayt-özdeş**. `git restore` **YASAK**.
9. **TEK gerçek CI koşumu:** Onur push ettikten sonra `main`'de **bir** yeşil koşum.
   `gh run list --branch main --workflow ci --limit 5` — 🔴 **`--branch` ZORUNLU** (`A11`/`A13`'te
   filtresiz çağrı kriter 7↔8 çelişkisini **iki kez** doğurdu). `run id` + dal kanıta yazılır.
   Log'da `verify.ps1`'in çapaları **birebir** aranır: `--- build -warnaserror ---` · `--- test ---` ·
   `--- CVE gate (dotnet list package --vulnerable) ---` · `== VERIFY PASSED ==`.
   🔴 **Sayılar log'dan OKUNUR, spec'ten kopyalanmaz.**
10. `.git/index.lock` **yok** (başta ve sonda). Commit `author` = `onurkesimbjk@gmail.com`. **PUSH ONUR'DA.**

## 5. İŞ BÖLÜMÜ
1. **Claude Code:** 3a→3d yazar; kriter 1, 2, 3, 5, 6, 7, 8, 10'u **kendi koşar**; kanıtlar `KANIT/CI/`.
2. **Cowork:** hiçbir kriteri builder'ın beyanıyla kabul etmez (`K26`). Kriter 4'ün **Linux ayağını**
   bulutta **kendi ölçer**; kriter 1, 2, 3, 5'i **yeniden koşar** (statik, ortam istemez).
   🔴 **Kriter 6, 7, 8'de Cowork ORTAM KALDIRMAZ (`K80`)** — Code'un ürettiği kanıt artefaktlarını
   (log dizgeleri, `sha256` geri yükleme kayıtları, taban koşum ölçümleri) **bağımsız denetler**;
   Docker/emülatör/backend **başlatmaz**. Tur 2 bu maddeyi haklı olarak blokerledi.
3. **Onur:** push. Sonra **Cowork** kriter 9'u ölçer ve kabul hükmünü yazar.

## 6. BEYAN EDİLMİŞ SINIRLAR
- 🔴 **`B-O63-2` AÇIK** — `--no-web-resources-cdn` CI'ya bağlanmıyor; web yayın işi bu turda **yok**.
  `B-W3b-6`…`10` ve `B-O63-1,3,4,5` de açık.
- 🔴 **`docs/ADR/0004-…md:145`'teki `D-A13-4` atfı GÜNCELLENMEYECEK** — `K175`① ile PARK. **Sarkan
  atıf bilinçlidir ve burada beyan edilmiştir.**
- 🔴 **`spec-kapi-kapsama.py` bu turu ÖLÇEMEZ** — iş emri bir **sohbet bloğudur**, `## 5. KAPILAR` /
  `## 6. MUTANTLAR` başlıklı bir spec dosyası değildir (`K81`). Bu, `K175`②'nin **kabul edilmiş
  bedelidir**. Yerine geçen mekanik kapı: **`ci-kapisi.py`'nin büyümüş altın kümesi** (kriter 5) —
  ve o kapı **mutantla** kanıtlanır (kriter 6).
- 🔴 **`K34-f` sapması** (3a) ve **`Ö2` `[DOĞRULANMADI]`** (Docker daemon) beyan edilmiştir.
- 🔴 Bu tur `ci.yml`+araç+belge üretir. **`K53`/4 gereği araç/betik/belge `urun_kodu_satiri` SAYILMAZ**
  ⇒ deftere yazılacak değer **0**'dır ve bu **bilinçlidir**; `R8`'in gelecekteki hükmü için gerekçe
  **burada** yazılıdır. 🔴 `R8` **iki oturum üst üste 0** görürse sert durak yanar — bir sonraki tur
  **ürün koduyla** başlamalıdır.
- 🔴 CI'nın **çevrimdışı senkron / SignalR / cihaz** ayağı **yoktur**; cihazda NAT nedeniyle yeniden
  bağlanma **hiç egzersiz edilmemiştir** ve bu tur bunu değiştirmez. `iOS` işi **dokunulmaz**.

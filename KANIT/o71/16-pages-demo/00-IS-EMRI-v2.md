# MOMENTUM — o71 İŞ EMRİ: PAGES DEMOSU (Cowork → Claude Code) · **v2**

> **K127 — KİLİT ÖNCESİ BAĞIMSIZ DENETİM KOŞTU.** v1 üç bağımsız denetçiye verildi ve
> **üçü de düşürdü** (hükümler: DÜZELT · DÜŞTÜ · ÖLÇÜM EKLE). Denetçi çıktı yolu:
> `KANIT/o71/16-pages-demo/00-IS-EMRI-DENETIMI.md`. v2 o bulguların kapatılmış hâlidir.
> Bu emir kilitlenmeden önce **Onur** onaylar.
>
> K192 (Onur, 13 Ağu 2026) yürürlükte: proje DONDURULDU. Bu iş bir **özellik değil, teslim
> altyapısıdır**.

---

## 0. ÖN KOŞULLAR — ikisi de sende değil, bekle

1. **Onur:** `Settings → Pages → Build and deployment → Source = "GitHub Actions"`.
   Ayarlanmadan `deploy-pages` hata verir.
2. **Onur'un "başla" onayı.** Onaydan önce **tek bayt yazma**.

---

## 1. KAPSAM — dokunacağın ÜÇ dosya, fazlası yok

| # | dosya | ne yapacaksın |
|---|---|---|
| 1 | `.github/workflows/pages.yml` | YENİ — §2'deki içerik |
| 2 | `src/client/web/index.html` | **yalnız** `<title>client</title>` → `<title>Momentum</title>` |
| 3 | `src/client/web/manifest.json` | **yalnız** `name`/`short_name` → `Momentum`, `description` → `Çevrimdışı öncelikli görev yönetimi — mimari vitrin` |

🔒 **2 ve 3, K192'ye ONUR'UN AÇTIĞI TEK SATIRLIK İSTİSNADIR** (13 Ağu 2026, ölçülmüş
gerekçe: `<title>` ve manifest adı Flutter şablonundan hiç değiştirilmemiş — `client` /
`A new Flutter project.` — ve inceleyenin gördüğü ilk şey sekme adıdır). Başka hiçbir ürün
dosyasına dokunma. Bu üç dizeden **başka** bir şey değiştirirsen istisna ihlal edilmiştir.

🔴 **Değişiklikten sonra ÖLÇ** (bu dizeler `lib/` altında değil ama ölçmeden geçme):
`flutter analyze --fatal-infos` · `flutter test` — ikisi de **koşacak**, çıktıları kanıta.
Sayı düşerse **DUR ve bildir**, düzeltme.

### Yasaklar — tam liste

🔴 **YENİ DOSYA AÇMA** (K175②): `GOREV_CLAUDE_CODE/`, `docs/ADR/`, `araclar/` altında.
Taban **32 · 6 · 41** (Cowork 13 Ağu'da ölçtü). Bitirmeden **sen de ölç**, aynı çıkmalı:

```powershell
git --no-optional-locks ls-files --cached --others --exclude-standard GOREV_CLAUDE_CODE | Measure-Object -Line
git --no-optional-locks ls-files --cached --others --exclude-standard docs/ADR | Measure-Object -Line
git --no-optional-locks ls-files --cached --others --exclude-standard araclar | Measure-Object -Line
```

🔴 **YAZMA — TAM LİSTE:** `README.md` · `DURUM.md` · `PROJE_HAFIZA.md` · `BORCLAR.md` ·
`ORTAM.md` · `KAPILAR.md` · `KIMLIKLER.md` · `DESIGN.md` (K46) · `docs/ADR/**` (K175①) ·
`araclar/**` (K34-f — bir araç ısırırsa **onarma**, bildir) · `.github/workflows/ci.yml` ·
`PROJE_RADAR.jsonl`. Belge ve hafıza **Cowork'ün**; araç onarımı **ayrı elin**.
Bir ortam mayınına çarparsan **raporunda söyle, belgeye yazma**.

🔴 **`gh` yalnız OKUMA** (`run list` · `run view`). `gh api` ile depo/Pages/environment
**ayarı değiştirmek YASAK**.

🔴 **README'ye demo adresini YAZMA.** Adresi ve sınırları, Cowork **anonim erişimle
ölçtükten sonra** Onur yazar (K26 + canlılık kapısı).

---

## 2. İŞ AKIŞI — `.github/workflows/pages.yml`

🔴 **Tetikleyici bu turda YALNIZ `workflow_dispatch`.** Ölçülmüş gerekçe (denetim, 13 Ağu):
`push: branches:[main]` olsaydı, `pages.yml`'i main'e taşıyan commit'in **kendisi** iş
akışını tetikler ve demo, Cowork daha hiçbir şey ölçmeden yayına girerdi — yani *"kilitliyorsa
yayınlanmaz"* şartı yapısal olarak imkânsız olurdu. `push:` tetiği, canlı ölçüm temiz çıkarsa
**ayrı ve iki satırlık bir turda** eklenir (Onur kilitledi).

```yaml
name: pages

on:
  workflow_dispatch: {}

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  demo:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.44.6

      - name: build
        working-directory: src/client
        run: flutter build web --release --no-web-resources-cdn --no-wasm-dry-run --base-href /Momentum/

      - name: kapi-cdn-ve-base-href
        working-directory: src/client
        shell: bash
        run: |
          set +e
          test -d build/web || { echo "KIRMIZI: build/web YOK"; exit 1; }
          # POZITIF KONTROL (kor kapi yasagi -- ORTAM.md): tarama gercekten dosya goruyor mu?
          grep -rlI -e 'flutter' build/web >/dev/null || { echo "KIRMIZI: pozitif kontrol dustu -- tarama kor"; exit 1; }
          # AYAK 1 (VARLIK) -- bayrak ciktiya indi mi?
          grep -q '"useLocalCanvasKit":true' build/web/flutter_bootstrap.js \
            || { echo "KIRMIZI: useLocalCanvasKit yok -- --no-web-resources-cdn dusmus"; exit 1; }
          # AYAK 2 (YOKLUK) -- derlenmis UYGULAMA kodunda CDN URL'si kaldi mi?
          #   flutter.js / flutter_bootstrap.js HARIC: yukleyici, KULLANILMAYAN CDN dalini
          #   her build'de dizge olarak tasir (olculdu: flutter 3.44.6, web_ui/flutter_js/src/utils.js:52)
          #   -a: ikili dosyalar da taranir (--binary-files=without-match KOR KAPI uretiyordu)
          grep -ra --exclude=flutter.js --exclude=flutter_bootstrap.js -e 'gstatic\.com/flutter-canvaskit' build/web
          rc=$?
          case "$rc" in
            0) echo "KIRMIZI: derlenmis ciktida CDN URL izi var"; exit 1 ;;
            1) : ;;
            *) echo "KIRMIZI: tarama hatasi (cikis $rc) -- OLCULEMEDI, YESIL DEGIL"; exit 1 ;;
          esac
          # AYAK 3 (VARLIK) -- base href ciktiya indi mi?
          grep -q '<base href="/Momentum/">' build/web/index.html \
            || { echo "KIRMIZI: --base-href ciktiya inmedi -- beyaz sayfa riski"; exit 1; }
          echo "YESIL: useLocalCanvasKit=true - CDN URL izi yok - base href /Momentum/"
          exit 0

      - uses: actions/upload-pages-artifact@v5
        with:
          path: src/client/build/web

      - id: deployment
        uses: actions/deploy-pages@v5
```

### Ölçülmüş gerekçeler

| madde | ölçüm · kaynak |
|---|---|
| `--base-href /Momentum/` | `origin` = `github.com/tuzakavcisi1-cloud/Momentum.git` (13 Ağu, `git remote -v`) ⇒ Pages yolu `/Momentum/`. `flutter build web` **baştaki ve sondaki `/`'ı zorunlu tutar** ve `$FLUTTER_BASE_HREF` yer tutucusu yoksa build'i **düşürür** (denetim ölçümü: `build_web.dart:250` + `:268-278`, flutter 3.44.6) ⇒ sessiz beyaz sayfa yerine gürültülü hata. `index.html`:17'de yer tutucu **duruyor** (13 Ağu, Cowork ölçtü). |
| `--no-web-resources-cdn` | README §Zorunlu şartlar 1'in şartı. README aynı yerde *"🔴 Bu şart bugün CI'da zorlanmıyor — bilinen ve yazılı bir borçtur"* diyor; `kapi-cdn-ve-base-href` bu borcu **bu iş akışı için** kapatır. |
| **AYAK 2'nin dışlaması** | 🔴 v1 burada **düştü**: `--no-web-resources-cdn` verilse **bile** `flutter.js`/`flutter_bootstrap.js` içinde `gstatic.com/flutter-canvaskit` dizgesi **kalır** — yükleyici CDN dalını çalışma-zamanı `if`'i olarak taşır (denetim ölçümü: `web_ui/flutter_js/src/utils.js:47-55`, tag 3.44.6). v1'in deseni **her build'de** ısırır, demo hiç yayınlanmazdı. |
| `--no-wasm-dry-run` | `flutter build web --release` varsayılan olarak **ek bir dart2wasm dry-run** derlemesi koşar (denetim ölçümü: `build_web.dart:118-120`, `defaultsTo: true`) — iki derleme, iki kat süre, kirli log. `--wasm` **verilmiyor** ⇒ çıktı JS + CanvasKit. |
| Flutter `3.44.6` | 🔴 v1'in *"üç işin üçünde de"* ifadesi **ölçümle yanlış çıktı**: `ci.yml`'de Flutter kullanan **iki** iş var (`istemci` L19 · `ios` L29); `backend` işi `setup-dotnet@v4` kullanır, Flutter yoktur. Pin ayrışması **yok**. |
| `checkout@v4` | `ci.yml` L16/26/38 ile birebir hizalı (bilinçli tutarlılık). 🔴 Ölçüldü (13 Ağu): `actions/checkout`'un en yüksek etiketi **v7.0.1**; `v4` üç ana sürüm geride. **Bilerek seçildi** (tek değişkenli tur). Node 20 kullanımdan kaldırma uyarısı gelirse **ölç ve bildir**, sessizce yükseltme. |
| `upload-pages-artifact@v5` · `deploy-pages@v5` | En son sürümler ölçüldü (13 Ağu, GitHub releases): ikisi de **v5.0.0**; `deploy-pages` Node 24 tabanlı, `upload-pages-artifact` `upload-artifact@v7` tabanlı. 🔴 **Beyan edilmiş risk:** GitHub'ın resmî starter'ı (`starter-workflows/pages/static.yml`, 13 Ağu) `upload-pages-artifact@v3` + `deploy-pages@v5` kullanır; **v5+v5 çifti resmî örnekte geçmiyor.** İlk koşum artefakt hatasıyla düşerse **ölç, logu yaz, DUR** — çifti sessizce değiştirme. |
| `configure-pages` **yok** | Ölçüldü (13 Ağu, `deploy-pages@v5` README): önerilen kullanımda geçmiyor, zorunlu değil; `enablement` varsayılanı `false` ⇒ Pages'i açmaz. Onur ayarı elle yapıyor. **Beyan edilmiş bedel:** depo yeniden adlandırılırsa `/Momentum/` sabiti bayatlar — AYAK 3 bunu build anında yakalar. |
| `.nojekyll` **yok** | Kaynak `GitHub Actions` iken Jekyll koşmaz. **[BİLİNEN DAVRANIŞ — ÖLÇÜLMEDİ]** etiketiyle durur; ilk koşumun çıktısı bunu doğrular. 🔴 Ayrıca `upload-pages-artifact@v5` gizli dosyaları **varsayılan olarak atar** (`include-hidden-files: false`, ölçüldü: `action.yml`, tag v5) ⇒ `.nojekyll` eklense bile artefakta **girmezdi**. |
| Drift web ikilileri | `src/client/web/sqlite3.wasm` (748.424 b) · `drift_worker.js` (354.758 b) **git'te izleniyor** (13 Ağu, `git ls-files`) ⇒ CI'da indirme adımı gerekmez. `veritabani.dart`:180-183 bunları **göreli** URI ile yükler ⇒ `/Momentum/` tabanında çözülmesi **[ÇIKARIM — canlıda Cowork ölçecek]**. |
| Derin bağlantı / 404 | Ölçüldü (13 Ağu, `grep`): `lib/` altında `UrlStrategy` · `GoRouter` · `Navigator.push` **hiç yok** ⇒ tek ekran, URL değişmiyor ⇒ SPA yeniden yazma ihtiyacı yok. `404.html` **eklenmez** (gereksiz artefakt). |

---

## 3. MUTANTLAR — kör kapı yasağı (K53/5)

🔴 **HÜKMÜ SEN VERMEZSİN (K26).** Ham çıktıyı yaz; *"ısırdı / geçti"* diye **yorum yazma**.
Vakaların çıkış kodlarını ve tam `stdout`'unu dök, dur. Hükmü Cowork verir.
🔴 **DESENİ SEN ONARMAZSIN (K34-f).** Bir vaka beklenen sonucu vermezse **DUR ve bildir**;
deseni değiştirme, iş akışını commit etme.

### 3.0 — Ön ölçüm (ilk iş)

`flutter build web` bu depoda **hiç ölçülmedi** (README yalnız `flutter test` 549/549 ve
`analyze` kaydediyor; CI'da web build işi yok). Önce **bayraklı build'i koş**:

```
C:\src\flutter\bin\flutter.bat build web --release --no-web-resources-cdn --no-wasm-dry-run --base-href /Momentum/
```
*(`flutter` bu makinede `.bat`'tir — ORTAM.md; çözülemeyen ad sessizce atlanan adımdır.)*

**Build düşerse DUR**, tam hatayı yaz. `pubspec.yaml`'a **dokunma** (K192).

### 3.1 — Tarama betiği

CI'daki kapı **bash+grep**; Windows'ta `grep` **yok** ve `findstr` aynı dosyada bir dizgeyi
bulup diğerini **kaçırabiliyor** (ORTAM.md, o46'da ölçüldü). Bu yüzden yerel ölçüm için
**tek kullanımlık bir Python betiği** yaz: `KANIT/o71/16-pages-demo/kapi-esdeger.py`
(🔴 `araclar/`'a **KOYMA** — K175② + K34-f). Betik §2'deki üç ayağın **semantik eşdeğerini**
koşar (dizin var mı · pozitif kontrol · AYAK 1/2/3), her ayağı ayrı satırda `YESIL/KIRMIZI`
basar ve toplam çıkış kodu döner. `sys.stdout.reconfigure(encoding="utf-8", errors="replace")`
**zorunlu** (ORTAM.md).

🔴 **Betiğe yazılacak BEYAN (kanıt dosyasının ilk satırı):** *"Yerel ölçüm `grep`'i değil
semantik eşdeğeri bir Python taramasını ölçtü. CI'daki `grep` ayağı yerelde ÖLÇÜLEMEDİ;
tek kanıtı ilk CI koşumunun logudur."*

### 3.2 — Beş vaka

| # | mutant | beklenen |
|---|---|---|
| `M-P1` | build **`--no-web-resources-cdn` OLMADAN** | AYAK 1 KIRMIZI **ve/veya** AYAK 2 KIRMIZI |
| `M-P2` | build **`--base-href` OLMADAN** | AYAK 3 KIRMIZI |
| `M-P3` | `build/web` dizinini geçici yeniden adlandır | *"build/web YOK"* KIRMIZI |
| `M-P4` | boş bir `build/web` dizini | pozitif kontrol KIRMIZI |
| `M-P5` | temiz build + `build/web/` altına **NUL baytı taşıyan** bir dosyaya `gstatic.com/flutter-canvaskit` dizgesi enjekte et | AYAK 2 KIRMIZI *(v1'in `--binary-files=without-match` deseni burada **ölçülmüş sahte yeşil** veriyordu)* |

Ayrıca **pozitif koşum**: bayraklı + base-href'li build ⇒ üç ayak da YEŞİL.
🔴 **Pozitif koşum KIRMIZI dönerse:** eşleşen dosya adlarını yaz ve **DUR** — desen yanlıştır,
build değil. Kendi başına daraltma.

Her mutant **geri alınır** (yeniden adlandırılan dizin eski adına, enjekte edilen dosya silinir,
son olarak temiz bayraklı build yeniden koşulur).

---

## 4. KANIT — `KANIT/o71/16-pages-demo/`

| dosya | içerik |
|---|---|
| `01-mutant-kosumlari.txt` | §3.2'nin altı koşumu (pozitif + `M-P1`…`M-P5`): komut · tam stdout · çıkış kodu. **Yorum yok.** |
| `02-taban-olcumu.txt` | §1'deki üç sayım. Not düş: *"41, `--cached --others --exclude-standard` kapsamıdır; DURUM.md §6'nın 31'i farklı bir sayımdır."* |
| `03-istemci-kapilari.txt` | `flutter analyze --fatal-infos` + `flutter test` ham çıktısı (§1'deki üç dize değişikliğinden **sonra**). |
| `04-ci-kapisi-pages.txt` | `python araclar\ci-kapisi.py .` ham çıktısı. 🔴 Araç `pages.yml`'i kapsamıyorsa **hüküm verme**: çıktıyı aynen yaz ve *"`ci-kapisi.py` `pages.yml`'i kapsamıyor — beyan edilmiş sınır"* de. Araca **DOKUNMA**. |
| `05-commit-ve-durum.txt` | Commit **öncesi** ve **sonrası** ölçüm (§6). |
| `06-is-akisi-logu.txt` | `gh run list --workflow pages.yml --limit 1 --json databaseId,conclusion,headSha,url` **sonra** `gh run view <databaseId> --log`. **İkisinin de** çıktısı. Koşum düştüyse **düşen logu** yaz. |
| `kapi-esdeger.py` | §3.1'in betiği. |

**Cowork'ün ölçecekleri — sen ölçme, iddia da etme:** anonim HTTP durumu · `crossOriginIsolated` ·
`MOMENTUM-G6-KANIT chosenImplementation=…` · `DepolamaSeridi`'nin görünüp görünmediği ve metni ·
CRUD + yenile turu · konsol hata hızı · ekran görüntüsü. *(Cowork'ün aleti ölçüldü: bulut
konteynerinde Chromium + Playwright kurulu, temiz profille anonim koşuyor.)*

---

## 5. BEYAN EDİLMİŞ SINIRLAR — gizleme, emirde dursun

**a) Çapraz-köken izolasyon YOK.** GitHub Pages COOP/COEP başlığı **gönderemez** (ölçüldü,
13 Ağu: Pages yanıtında bu başlıklar yok) ⇒ `crossOriginIsolated === false` beklenir ⇒ drift
**OPFS'e geçmez**. Masaüstünde `sharedIndexedDb`, **Android Chrome'da `unsafeIndexedDb`**
beklenir (drift belgesi, 13 Ağu: *"Chrome on Android: Shared workers aren't supported"*).
🔴 Servis-çalışanı ile COOP/COEP enjekte eden bilinen bir geçici çözüm (`coi-serviceworker`)
**vardır ve BİLEREK REDDEDİLMİŞTİR**: K192 + *"demo, üründe ne varsa onu gösterir"*.

**b) Backend YOK ⇒ senkron düşer.** `SENKRON_SUNUCU_URL` **verilmeyecek** (Onur, 13 Ağu):
`main.dart`:24-27 varsayılanı `http://10.0.2.2:5298` yürürlükte kalır. HTTPS sayfadan `http://`
+ **IP adresi** ⇒ tarayıcı yükseltmez, **mixed content ile bloklar** (MDN, 13 Ağu).

🔴 **Kâğıt ölçümünün KAPSAMI dardır — üç yol ölçülmedi, canlıda Cowork ölçecek:**
① `main.dart`:172-177 `SignalrJsonSinyal.baslat()` — `unawaited`, aynı adrese gider;
geri çekilme zamanlayıcısı vardır ve README'ye göre bu yol **hiç egzersiz edilmedi**.
② `main.dart`:46-59 — `runApp`'tan **ÖNCE** `await` edilen **depolama** zinciri (drift açılışı,
`ayarlariHazirla`, `gonderildiKurtar`); burada bir istisna **beyaz ekran** üretir ve `HataDurumu`
**hiç çizilmez**. Kilitlenmenin gerçek yolu budur, senkron değil.
③ `main.dart`:58-59 `unawaited` tur çağrılarının yakalanmamış hataları.
*(Ölçülen: `HttpSenkronAgi.gonder` istisnayı yakalar ⇒ `SenkronAgHatasi`; `HataDurumu`
**yalnız** yerel akış hatasında çizilir — `gorev_listesi_ekrani.dart`:113-116.)*

**c) Demoya özel hiçbir DAVRANIŞ yapılandırması eklenmez:** `--dart-define` yoktur, mantık
değişmez. Tek sapma `--base-href /Momentum/`'dur; bu bir **dağıtım-yolu** bayrağıdır ve
README §Çalıştırma 3'teki kanonik komuttan **bilerek** ayrılır. `<title>`/manifest değişikliği
Onur'un açtığı **beyanlı istisnadır** (§1).

**d) Vitrin ayağı ölçülmemiş platformda koşuyor:** deponun kendi beyanı — *"`flutter test
--platform chrome` bu ortamda sonuç üretmiyor ⇒ web test ayağı `[DOĞRULANMADI]`"* (README).
Demo bu ayağı **kapatmaz**; canlı CRUD turu (Cowork) tek karşılığıdır.

---

## 6. COMMIT — **PUSH YOK**

🔴 **PUSH DAİMA ONUR'DA** (`DURUM.md` §3 · `CLAUDE.md` ERRATA · `ORTAM.md`). Commit'i at,
**dur**, raporla. `git push` **YASAK** — Onur ayrıca yazılı yetki vermedikçe.

**Commit'ten ÖNCE ölç** (K82-b — bu emirdeki hiçbir sayıya güvenme, ölçüm bayatlamaz):

```powershell
git --no-optional-locks fetch origin
git --no-optional-locks log --oneline -1
git --no-optional-locks rev-list --left-right --count origin/main...HEAD
git --no-optional-locks status --porcelain
Test-Path .git\index.lock
git --no-optional-locks config user.email     # onurkesimbjk@gmail.com degilse DUR (K149)
```

🔴 **İleri fark ölçersen DUR ve bildir** — o commit'ler senin değil.

**Ekleme — tek tek, adıyla; dizin ekleme YOK:**

```powershell
git --no-optional-locks add .github/workflows/pages.yml
git --no-optional-locks add src/client/web/index.html
git --no-optional-locks add src/client/web/manifest.json
git --no-optional-locks add KANIT/o71/16-pages-demo/01-mutant-kosumlari.txt   # ... her kanit dosyasi tek tek
```

🔴 **YASAK:** `git add -A` · `git add .` · **`git commit -a` / `-am`** · `git stash` ·
`git restore` · `git checkout -- .`. Yerelde **Cowork'ün/Onur'un** commit edilmemiş dosyaları
var (`PROJE_HAFIZA.md` · `PROJE_RADAR.jsonl` · `README.md`); bu komutlar onları **kör alır**.

Commit mesajı: **çift tırnak yok**, tek satır, `oturum-71-...` deseni.

---

## 7. BİTİRME RAPORU

Tek rapor: hangi dosyalar değişti (üç dosya + kanıtlar) · altı mutant koşumunun çıkış kodları
(**yorum yok**) · taban sayımı · `analyze`/`test` sayıları · commit sha'sı · **ölçemediklerin
listesi (BOŞ OLAMAZ)**.

🔴 Canlı sayfa hakkında **hiçbir iddia yazma** — *"yayında"*, *"çalışıyor"*, *"demo hazır"*
demek ölçmediğin bir **durum iddiasıdır** (canlılık kapısı). İş akışını **sen tetikleme**;
`workflow_dispatch`'i Onur çalıştırır.

---

## 8. YAYIN-DURDURMA ŞARTLARI (Cowork ölçer, Onur karar verir — bilgin olsun)

Aşağıdakilerden **biri** bile yanarsa demo adresi README'ye yazılmaz:

1. Herhangi bir hedef tarayıcıda ilk kare çizilmiyor (beyaz sayfa).
2. Ekle · başlık düzenle · tamamla · sil dörtlüsünden biri çalışmıyor.
3. Sayfa yenilendiğinde veri kayboluyor (`inMemory`'ye düşmüş).
4. `HataDurumu` görünüp uygulamayı blokluyor.
5. "Yenile" kalıcı spinner bırakıyor.
6. Konsol hata hızı sönümlenmiyor (5 dk sonra da tekrar ediyor).
7. Canlı sayfada üçüncü-taraf ağ isteği > 0.
8. İş akışı `Success` değil **veya** pozitif koşum KIRMIZI.
9. README'ye yazılacak metin, demoyu README'nin mevcut iki ölçüm cümlesiyle çelişmeden
   çerçevelemiyor (*"`crossOriginIsolated === true` ölçüldü"* → o ölçüm §Çalıştırma-4
   kurulumuna aittir; *"`negotiate` 200"* → o ölçüm yerel kuruluma aittir).

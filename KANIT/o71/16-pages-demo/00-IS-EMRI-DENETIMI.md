# o71 — PAGES DEMOSU İŞ EMRİ · BAĞIMSIZ DENETİM ÇIKTISI (K127)

**Tarih:** 13 Ağu 2026 · **Denetlenen:** `is-emri-pages-v1.md` (Cowork üretti)
**Denetçi:** ÜÇ bağımsız ajan, Cowork'ün ürettiği metni görerek ama üretim bağlamını
paylaşmadan koştu (K26 — üreten ≠ denetleyen).
**Hükümler: DÜZELT · DÜŞTÜ · ÖLÇÜM EKLE — üçü de v1'i geçirmedi.**
Tam metinler oturum transkriptindedir; aşağıdaki yoğunlaştırma **bulgu kimliği + ölçüm
kaynağı + v2'de ne yapıldığı** üçlüsünü taşır.

---

## DENETÇİ A — GitHub Actions / CI (hüküm: **DÜZELT**)

| # | bulgu | ölçüm kaynağı | v2'de |
|---|---|---|---|
| A1 | 🔴 **v1'in CDN kapısı HER build'de ısırır** — `--no-web-resources-cdn` verilse bile `flutter.js`/`flutter_bootstrap.js` CDN dalını **dizge olarak** taşır ⇒ `exit 1` ⇒ `deploy-pages` hiç koşmaz, demo hiç yayınlanmaz | flutter `3.44.6` kaynağı: `web_ui/flutter_js/src/utils.js:47-55` (`return joinPathSegments("https://www.gstatic.com/flutter-canvaskit", buildConfig.engineRevision)`) + `build_system/targets/web.dart:743-753, 859-866` | KAPATILDI — kapı üç ayağa ayrıldı: AYAK 1 `"useLocalCanvasKit":true` **varlık**, AYAK 2 yükleyici dosyaları **hariç** `gstatic.com/flutter-canvaskit` **yokluk**, AYAK 3 base href varlık |
| A2 | 🟡 §3'te "pozitif kontrol KIRMIZI dönerse" dalı yok ⇒ builder ya kilitlenir ya deseni kendi daraltır (kör kapı) | — | KAPATILDI — §3.2: *"Pozitif koşum KIRMIZI dönerse DUR, kendi başına daraltma"* |
| A3 | 🟡 `grep` çıkış kodu **2** (dizin yok / okuma hatası) `if` tarafından **1 ile aynı** sayılıyor ⇒ kapı ölçmediğine "temiz" der | kabuk semantiği | KAPATILDI — `rc=$?` + `case` üçlüsü; 2 ⇒ *"OLCULEMEDI, YESIL DEGIL"* |
| A4 | 🟡 `gstatic\.com` deseni fazla geniş (Google Fonts yanlış-pozitifi) | — | KAPATILDI — desen `gstatic\.com/flutter-canvaskit`'e daraltıldı (aracın enjekte ettiği tek dize: `web.dart:122`) |
| A5 | 🟡 `upload-pages-artifact@v5` gizli dosyaları **varsayılan olarak atar** (v3'e göre sessiz davranış değişikliği) | `action.yml`, tag v5: `include-hidden-files … default: "false"` | BEYAN — §2 tablosu; `.nojekyll` eklense bile artefakta girmeyeceği yazıldı |
| A6 | 🟡 `v5+v5` çifti **resmî starter'da geçmiyor**; resmî örnek `upload-pages-artifact@v3 + deploy-pages@v5` | `starter-workflows/pages/static.yml` (birebir alıntı, 13 Ağu 2026) | BEYAN — risk yazıldı; ilk koşum düşerse **ölç ve DUR**, sessizce çift değiştirme yasak |
| A7 | 🟡 Service worker önbelleği canlı ölçümü **kirletir** (eski build servis edilir) | `web.dart:904-909` + `:703` (`offlineFirst`) | KAPATILDI — canlı ölçüm **temiz profil / gizli pencere** şartına bağlandı (Cowork'ün ölçüm yordamı) |
| A8 | 🟡 `--release` ek bir **dart2wasm dry-run** derlemesi koşar ⇒ iki kat süre, kirli log | `build_web.dart:118-120` (`wasm-dry-run`, `defaultsTo: true`) | KAPATILDI — `--no-wasm-dry-run` eklendi |
| A9 | 🟡 Derin bağlantı / 404 ölçülmedi (`PathUrlStrategy` ise F5 → 404) | — | ÖLÇÜLDÜ (Cowork, 13 Ağu): `lib/` altında `UrlStrategy`/`GoRouter`/`Navigator.push` **yok** ⇒ tek ekran ⇒ `404.html` gereksiz. §2 tablosuna yazıldı |
| A10 | ℹ `configure-pages` **zorunlu değil** (`enablement` varsayılanı `false`) | `deploy-pages@v5` README + `configure-pages@v5/action.yml` | BEYAN — eklenmedi, bedeli (depo yeniden adlandırması) yazıldı |
| A11 | ℹ `permissions` / `concurrency` / `environment` / `id: deployment` zinciri **doğru**; tek job meşru; `path:` doğru | resmî starter + deploy-pages README (*"either in the same job or a separate job…"*) | — (`timeout-minutes: 30` eklendi) |
| A12 | ℹ `--base-href` **gürültülü** düşer: yer tutucu yoksa build `throwToolExit` ile durur | `build_web.dart:250, 268-278` | BEYAN — §2 tablosuna yazıldı |
| A13 | ℹ GitHub Pages `.wasm`'ı **`content-type: application/wasm`** ile servis ediyor; aynı yanıtta **COOP/COEP yok** | canlı ölçüm 13 Ağu 2026 20:14 UTC (`mdn.github.io/…/add.wasm` başlıkları birebir) | §5a doğrulandı |

**Denetçi A — ölçemedikleri:** depo içeriği (taban sayımları, `origin/main`, `index.html`
gövdesi), gerçek build çıktısı (Flutter yok), `upload-artifact@v7 ↔ deploy-pages@v5` uyumu,
`github-pages` ortamının koruma kuralları.

---

## DENETÇİ B — Proje disiplini / kilitler (hüküm: **DÜŞTÜ**)

| # | bulgu | kaynak | v2'de |
|---|---|---|---|
| B1 | 🔴 **PUSH YASAĞI İHLALİ** — v1 `Push: main` diyordu | `DURUM.md` §3 *"PUSH DAİMA ONUR'DA"* · `CLAUDE.md` ERRATA · `ORTAM.md` | KAPATILDI — §6: **PUSH YOK**, commit at ve dur |
| B2 | 🔴 `on: push:[main]`, emrin **kendi** güvenlik şartını imkânsız kılıyor (commit = yayın) | — | KAPATILDI — ilk tur **yalnız `workflow_dispatch`** (Onur kilitledi); `push:` tetiği ölçüm temiz çıkarsa ayrı turda |
| B3 | 🔴 v1, `K82-b`'yi çiğneyip push durumunu **belgeye yazdı** ve yazdığı değer `DURUM.md`:5 (*"ÜÇ COMMIT İTİLMEDİ"*) ile **çelişti** | `DURUM.md` §2/7 + §3 | KAPATILDI — sayı silindi; §6 *"bu emirdeki hiçbir sayıya güvenme, commit'ten önce ÖLÇ"* + ileri fark ⇒ DUR. 🔴 **DURUM.md:5'in bayat satırı Cowork'ün budama borcudur** |
| B4 | 🔴 Kilitlenme hükmü **tek yola** dayanıyor; `runApp` **öncesi** depolama zinciri ve SignalR yolu hiç incelenmemiş (`K161`: vaka ölçmek sınıf kapatmaz) | `main.dart`:46-59, :58-59, :172-177 | KAPATILDI — §5b'ye üç ölçülmemiş yol **beyanlı** eklendi |
| B5 | 🔴 **Kapı üç vakada ÖLÇÜLMÜŞ SAHTE YEŞİL verdi** (kontrollü koşum): `build/web` yok · dizin boş · iz **NUL baytlı** dosyada (`--binary-files=without-match` yutuyor) | GNU grep 3.11, dört vaka koşuldu | KAPATILDI — `test -d` + pozitif kontrol + `-a` (ikili dâhil) + mutant `M-P3`/`M-P4`/`M-P5` |
| B6 | 🔴 `K26`/`K34-f` mutant tarafında **hiç işletilmemiş**: aynı el yazıyor, koşuyor, hüküm veriyor, onarıyor | `K26` · `K34-f` | KAPATILDI — §3 başı: **hüküm verme**, **desen onarma**; ham çıktı yaz ve dur |
| B7 | 🔴 Mutant **kanonik ortamda koşamaz**: Windows'ta `grep` yok, `findstr`'ın körlüğü o46'da ölçüldü; `flutter` `.bat` | `ORTAM.md`:26, :35, :23 | KAPATILDI — §3.1: tek kullanımlık **Python** eşdeğeri (KANIT altında, `araclar/`'a değil) + `flutter.bat` tam yol + stdout reconfigure + **beyan zorunlu** |
| B8 | 🔴 *"üç işin üçünde de `3.44.6`"* iddiası **ölçümle yanlış çıktı**: Flutter kullanan **iki** iş var; `backend` `setup-dotnet` kullanıyor | `ci.yml` L13/19/23/29/32/43 | KAPATILDI — §2 tablosu düzeltildi (Cowork'ün olgusal hatası, kabul edildi) |
| B9 | 🔴 `--base-href` **en kritik tek noktalı arıza** ama kapısı da mutantı da yok (`K155`) | — | KAPATILDI — AYAK 3 + mutant `M-P2` |
| B10 | 🔴 `ci-kapisi.py` (22/22) yeni iş akışına **hiç koşmuyor**; *"çağrılmayan kapı kör kapı kadar kördür"*, `envantersiz-kapı` sınıfı **üç kez** ısırmış | `DURUM.md`:22, :158, :168 | KAPATILDI — `04-ci-kapisi-pages.txt`; kapsamıyorsa **beyan edilmiş sınır**, araca dokunma |
| B11 | 🔴 `K127` emirde **hiç geçmiyor** (denetçi çıktı yolu yok) | `CLAUDE.md` K127 | KAPATILDI — **bu dosya** o yoldur; v2 başlığında atıf var |
| B12 | 🟡 README §Beyan edilmiş sınırlar: *"ayrı statik host kapsam dışı"* — Pages **tam olarak odur** ⇒ demo yayınlanınca satır yanlışlanır | `README.md`:247-248 | Onur'un README kalemine **üçüncü madde** olarak eklendi (§8/9) |
| B13 | 🟡 README'nin iki ölçüm cümlesi demoda tutmaz: *"bayraksız derlenen sürümde izolasyon iddiası çürür"* (bayrak **yeterli değil**) · *"`negotiate` 200"* (demoda backend yok) | `README.md`:161, :241-243 | §8/9 yayın-durdurma şartına bağlandı |
| B14 | 🟡 `PROJE_RADAR.jsonl` defter satırını kimin yazacağı yazılmamış (`K154`: yazılmayan ölçüm kaydı kapatılmayan kapıdır) | `CLAUDE.md` Radar · `DURUM.md`:119 | Cowork'ün checkpoint yükümlülüğü — `pages.yml` **ürün kodu sayılmaz**, `urun_kodu` 0 |
| B15 | 🟡 `R8` ayağı bu turda `--olc-urun-kodu` ile ölçülmedi | `DURUM.md`:44 | ÖLÇÜLDÜ (Cowork, 13 Ağu): `26c987a..HEAD` ⇒ `urun_kodu_satiri = 0`. 🔴 **Aralık HEAD..HEAD olduğu için bu anlamlı bir R8 ölçümü DEĞİLDİR**; o71'de ürün kodu yazıldığı (`CORP`, 23 satır, `K186`) `DURUM.md`'de kayıtlı |
| B16 | 🟡 `git add -A` yasaklı ama **`git commit -a`** boşluğu açık; `add <dizin>` de artıkları süpürür | `K55` · `ORTAM.md`:28 | KAPATILDI — §6: dosya dosya ekleme, `commit -a`/`-am`/`stash`/`restore` **yasak** |
| B17 | 🟡 Dokunma-yasağı listesi eksik: `ORTAM.md` · `KAPILAR.md` · `KIMLIKLER.md` · `ci.yml` korumasız; `gh api` ile ayar değişimi açık | `K60` · `K34-f` | KAPATILDI — §1'de **tam liste** + `gh` yalnız okuma |
| B18 | 🟡 `gh run view <id>`'de `<id>`'nin nasıl bulunacağı yazılmamış (o52'nin filtresiz `gh run list` tuzağı) | `CLAUDE.md` K127 gerekçesi | KAPATILDI — `--workflow pages.yml --limit 1 --json …` |
| B19 | 🟡 `web-varlik.sha256` pini demo yolunda hiç ölçülmüyor | `DURUM.md`:164 | **AÇIK BORÇ** — v2'ye alınmadı: `web-varlik-indir.py` ağ ister ve ikilileri **indirir**; K192 altında ürün varlığına dokunma riski, ölçüm faydasından büyük. Beyan: *ikililer git'te izlenen hâliyle yayınlanıyor, pin bu turda ÖLÇÜLMEDİ.* |
| B20 | 🟡 *"hiçbir yapılandırma eklenmez"* mutlak cümlesi `--base-href` ile kendi içinde çelişiyor | — | KAPATILDI — §5c: davranış bayrağı ≠ dağıtım-yolu bayrağı, sapma beyanlı |
| B21 | 🟡 `checkout@v4` sürüm ölçümü asimetrik (en yüksek etiket **v7.0.1**) | `git ls-remote --tags` (13 Ağu) | KAPATILDI — §2 tablosunda ölçüm + *"bilerek seçildi"* beyanı |
| B22 | 🟡 `flutter build web`'in bu depoda geçtiğine dair **kayıtlı ölçüm yok**; `flutter_driver` `dependencies` altında | `README.md`:127-138 · `pubspec.yaml`:33-34 | KAPATILDI — §3.0 ön ölçüm + *"build düşerse DUR"* |
| B23 | ℹ Sürüm iddiası **doğrulandı** (`deploy-pages` v5.0.0 · `upload-pages-artifact` v5.0.0) | `git ls-remote --tags` | — |
| B24 | ℹ Emrin güçlü tarafı: canlı sayfa için `K26` ayrımı örnek nitelikte | — | korundu |
| B25 | ℹ **Destek belgeler kendi içinde çelişkili**: `DURUM.md`:69↔70 (PUBLIC/PRIVATE) · :82↔83 (kriter 8 kapandı/AÇIK) — sarkan bayat satırlar | `DURUM.md` | 🔴 **Cowork'ün budama borcu** (Claude Code değil) |

---

## DENETÇİ C — Red-team: demo bozuk görünür mü (hüküm: **ÖLÇÜM EKLE**)

| # | bulgu | kaynak | v2'de |
|---|---|---|---|
| C1 | 🔴 **Gerçek kilitlenme yolu senkron değil, `runApp` öncesi depolama zinciri**: `await` edilen drift açılışı + `ayarlariHazirla` + `gonderildiKurtar`; timeout yok, try/catch yok ⇒ istisna ⇒ **beyaz sayfa**, `HataDurumu` hiç çizilmez | `main.dart`:45-63 | §5b'ye ② olarak yazıldı; yayın-durdurma şartı 1 |
| C2 | 🔴 Vitrin, deponun **kendi beyanıyla ölçülmemiş** platformda koşuyor (*"web test ayağı `[DOĞRULANMADI]`"*), CI'da web build **hiç yok** | `README.md`:246 · `ORTAM.md`:29 · `ci.yml` | §5d beyanı + canlı CRUD turu zorunluluğu (yayın-durdurma 2) |
| C3 | 🔴 **Android Chrome'da depo `sharedIndexedDb` değil `unsafeIndexedDb`** — shared worker yok; iki sekmede veri yarışı | drift belgesi (13 Ağu, birebir): *"Chrome on Android: Shared workers aren't supported"* | §5a'ya yazıldı; mobil ölçüm Cowork'ün |
| C4 | 🔴 README'nin iki ölçüm cümlesi demoda **gözle çürütülüyor**; `10.0.2.2` bir **IP** olduğu için mixed content **yükseltilmez, bloklanır** | MDN Mixed content (13 Ağu, birebir) | §5b + yayın-durdurma 9 |
| C5 | 🟡 Konsol hatası **azaltılamaz** (derleme-zamanı sabit), yalnız **çerçevelenebilir**. İyi haber: `Timer.periodic` **kaldırılmış** ⇒ senkron turu tekrarlamaz | `main.dart`:53-57 | çerçeveleme Onur'un README kalemine |
| C6 | 🟡 SignalR **geri çekilme** yolu: README *"hiç egzersiz edilmedi"* diyor; ilk canlı koşum inceleyenin konsolunda olacak | `README.md`:244-245 · `pubspec.yaml` K79/6 notu | yayın-durdurma 6 (5 dk hata hızı ölçümü) |
| C7 | 🟡 §4 Cowork'e **aleti ölçülmemiş** ölçümler yüklüyor (`playwright` Onur'un makinesinde YOK — `B-O62-3`) | `DURUM.md`:154 | KAPATILDI — ÖLÇÜLDÜ (13 Ağu): **bulut konteynerinde Chromium + Playwright (py+node) kurulu** ⇒ anonim, temiz profil ölçümü Cowork'te mümkün |
| C8 | 🟡 Kapı **dizge** ölçüyor, **ağ** ölçmüyor; gerçek iddia "üçüncü-taraf istek = 0" | flutter/flutter#148713 geçmişi | yayın-durdurma 7 (Network paneli / Playwright istek dinleyici) |
| C9 | 🟡 `DepolamaSeridi` vitrinde ne yazacak? | ÖLÇÜLDÜ (Cowork, 13 Ağu): `depolama_seridi.dart` — `kaliciOpfs` **ve** `olculmedi` sınıflarında şerit **hiç çizilmez**; `geriDusus` ⇒ *"Veriler tarayıcı deposunda tutuluyor."* · `kaliciDegil` ⇒ *"Veriler kalıcı DEĞİL: sekme kapanınca silinir."* | C9(b) **DÜŞTÜ** (şerit "ölçülmedi" yazmıyor, hiç görünmüyor); metin nötr. Yayın-durdurma 3 `inMemory` üzerinden korundu |
| C10 | 🟡 Sekme adı **"client"**, manifest adı "client", açıklama *"A new Flutter project."* | ÖLÇÜLDÜ (Cowork): `index.html` + `manifest.json` | **ONUR KİLİTLEDİ** — K192'ye tek satırlık istisna: üç dosyada dört dize `Momentum` olur (v2 §1) |
| C11 | 🟡 `flutter_driver` **`dependencies`** altında, `main.dart`:4 koşulsuz import; ağaç sarsımının web'de düşürdüğü **ölçülmemiş** | `pubspec.yaml`:33-34 | **AÇIK BORÇ** — v2'ye ölçüm olarak alınmadı (K192: `pubspec`'e dokunulmaz); beyan: bundle sembol taraması yapılmadı |
| C12 | 🟡 İlk boya: CanvasKit + `main.dart.js` + 1,1 MB drift ikilisi; Flutter varsayılan `index.html` **gösterge çizmez** ⇒ beyaz bekleme, C1'in beyaz sayfasından ayırt edilemez | — | Cowork'ün canlı ölçümü (ilk kare süresi) |
| C13 | 🟡 Service worker: ikinci ziyaret **bayat sürüm** gösterebilir | flutter/flutter#68449 (kapandı) | A7 ile aynı çözüm (temiz profil) |
| C14 | 🟡 **Safari/iOS: 7 gün etkileşimsizlikten sonra site verisi platform tarafından silinir** | WebKit blog (13 Ağu, birebir): *"after seven days of Safari use without user interaction"* | Onur'un README kalemine beyan |
| C15 | 🟡 §5a *"gönderemez"* eksik: `coi-serviceworker` ile Pages'te izolasyon **elde edilebilir** — bilen inceleyen "bilmiyorlar" der | tomayac blog (8 Mar 2025) + `gzuidhof/coi-serviceworker` | KAPATILDI — §5a: *"BİLİNMEKTEDİR ve K192 + 'demoya özel yapılandırma yok' gereği **bilerek reddedilmiştir**"* |
| C16 | ℹ Üç beyaz-sayfa korkusu **ölçümle düştü**: `.wasm` MIME doğru · `--wasm` verilmiyor ⇒ skwasm devrede değil · origin izolasyonu yerel kurulumu **bulaştırmıyor** | canlı `curl -sSI` + Flutter belgesi | — |
| C17 | 🔴 v1'in **tek** yayın-durdurma şartı vardı | — | KAPATILDI — v2 §8: **dokuz** şart |

**Denetçi C — ölçemedikleri:** `signalr_json_sinyal.dart` geri çekilme parametreleri ·
"Yenile" düğmesinin görsel durumu · canlı sayfanın kendisi (13 Ağu: **HTTP 404**, henüz yok) ·
`flutter build web`'in geçtiği · bundle boyutları · Firefox/Safari gizli pencere davranışı ·
`10.0.2.2`'nin fiilî bloklanma kipi (spesifikasyondan türetildi, tarayıcıda ölçülmedi).

---

## COWORK'ÜN KABUL ETTİĞİ KENDİ HATALARI

1. **B8** — *"üç işin üçünde de 3.44.6"*: `ci.yml`'de Flutter kullanan **iki** iş var. Olgusal hata, "hepsi ölçüldü" başlıklı tablonun içindeydi.
2. **A1** — CDN kapısının deseni **ölçülmemiş bir varsayıma** dayanıyordu; v1 koşsaydı demo hiç yayınlanmazdı.
3. **B1** — `Push: main` satırı, üç canlı belgede yazılı `PUSH DAİMA ONUR'DA` yasağını ihlal ediyordu.
4. **B3** — Push durumunu emre yazmak `K82-b`'nin doğrudan ihlaliydi.

## AÇIK KALAN BORÇLAR (v2'de kapatılmadı, beyanlı)

- `B-o71-PAGES-1` — `web-varlik.sha256` pini demo yolunda **ölçülmedi** (B19).
- `B-o71-PAGES-2` — `flutter_driver`'ın web bundle'ından düşüp düşmediği **ölçülmedi** (C11).
- `B-o71-PAGES-3` — `DURUM.md`'de iki sarkan bayat satır (:69↔70, :82↔83) **budanmadı** (B25) — Cowork'ün borcu.
- `B-o71-PAGES-4` — CI'daki `grep` ayağı yerelde **ölçülemez** (Windows); tek kanıtı ilk CI koşumudur (B7).

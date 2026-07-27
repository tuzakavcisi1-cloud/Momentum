# DURUM.md — Momentum · CANLI DURUM (her oturumun TEK zorunlu okuması)

> **Bu dosya kısa kalmak ZORUNDADIR.** Tavan: **≤ 32 KB** [K58; eski tavan 12 KB]. Aşarsa budanır, tarihçe `PROJE_HAFIZA.md`'ye taşınır. Gerekçe okuma kapasitesi değil **R4 freni + dikkat**; tavanı şu an **hiçbir kapı zorlamıyor** (beyan edilmiş zayıf kontrol, ilk ısırışta araç yazılır).
> `PROJE_HAFIZA.md` artık **APPEND-ONLY KARAR ARŞİVİDİR**; oturum açılışında **okunmaz**, yalnız *"bu karar neden alındı?"* diye sorulduğunda açılır.
> **Son güncelleme:** 27 Tem 2026, oturum 31 (K60 — **kapı yazıldı**).

---

## 1. Proje

Çok platformlu görev yönetimi (to-do): **Flutter** istemci (Android + Web) + **N-katmanlı .NET 9 / ASP.NET Core** backend + **PostgreSQL**. İşe-alım/portfolyo ödevi; odak **mimari ve kod kalitesi**. Vitrin: **çevrimdışı-öncelikli senkron + gerçek zamanlı işbirliği**.

**Kanonik kök: `C:\dev\Momentum`** 🔴 **[K56 — TAŞINDI]** · Eski kökteki Türkçe karakterler dört araç zincirini kırıyordu (§7); kök neden kaldırıldı, **junction yok, `android.overridePathCheck` EKLENMEDİ** — hiçbir kapı susturulmadı.

---

## 2. AÇILIŞ PROTOKOLÜ (sırayla, atlanmaz)

1. **Bu dosyayı** + `CLAUDE.md`'yi oku. *(`PROJE_HAFIZA.md`'yi okuma — gerekirse sonra bak.)*
2. `python araclar\tek-kopya-kapisi.py .` — **tek kopya dosya regresyon kapısı (K60).** KIRMIZI ise **önce dosyayı kurtar** (`git restore <yol>`), sonra iş yap.
3. `python araclar\radar.py --altin-kume` (EXIT 0) → `python araclar\radar.py .`
   **KIRMIZI ise yeni tur YASAK**; dört şık Onur'a sunulur, **varsayılan DEVRET**.
4. `git --no-optional-locks status --porcelain` + `Test-Path .git\index.lock`
5. §4'teki **SIRADAKİ İŞ**'ten devam et.

---

## 3. CANLI DURUM

| alan | durum |
|---|---|
| **Backend** | ✅ slice-1 → 3a bitti. `araclar\verify.ps1` ⇒ build 0 uyarı/0 hata · **test 110/110** · CVE 0 · EXIT 0 |
| **Veritabanı** | ✅ Docker 29.6.1, `momentum-postgres` Up (healthy) |
| **İstemci (Flutter)** | 🟢 **T0→T9 BİTTİ.** 8 bileşen + `MomentumTema` · durum vitrini · Drift çevrimdışı CRUD · **yedi kapı G1–G7 koştu** · **24 mutant etiketinin hepsi ısırdı** (A 11 → B 10 → C 3). **Cowork'ün KENDİ koşumu: `analyze --fatal-infos` 0 bulgu · `flutter test` 36/36 · EXIT 0.** Kriter 13 yöntem sağlamasıyla ölçüldü (release `libapp.so` ×3 mimari: vitrin/driver sembolü **0**; debug'da 4/2/10 ⇒ yanlış-negatif değil). **A2 = 8/8** — iki ham ağaç, birleşimi **Cowork kendi ayrıştırdı**. ✅ **slice-3b KAPANDI — commit `5df3caf`** (72 dosya, 91.005 satır). **Sıradaki: K42-d adım 3.** |
| **Tasarım sistemi** | ✅ `DESIGN.md` v1 (15.742 b · `534DFF68`) — 32 token, 8 görsel bileşen, 8 durum, A11Y‑1…7 |
| **ADR 0003 (kimlik)** | 🧊 v7 **DONDURULDU** (K41). Kanonik v6. **DOKUNMA** |
| **Radar** | `radar.py` **plugin 0.2.0 ile bayt-özdeş** — R8 · D1‑D5 · `--olc-urun-kodu` · altın küme **18/18**. Hüküm **KIRMIZI** ve bu **beklenen**: kâğıt artefaktlar (`docs/ADR/0003` park · `GOREV-slice-3b-spec` build'e devredildi) hâlâ defterde duruyor. `slice-3b-istemci` kapanış kaydı: bloker 0 · **`urun_kodu_satiri` = 61** ⇒ **R8 SUSTU** · `gorunen_cikti_yuzde` **ilk kez 0'ın üstünde (35, TAHMİN)**. Varsayılan cevap **DEVRET** — zaten yapılan bu |
| **Git** | **PUSH DAİMA ONUR'DA.** İleri/geri durumu **yazılmaz, açılışta ÖLÇÜLÜR**: `git --no-optional-locks rev-list --left-right --count origin/main...HEAD` |

**Ortam:** Flutter 3.44.6 · Dart 3.12.2 · Android SDK 36.1.0 ✓ · Chrome/web ✓ · .NET 9.0.316 · **Windows masaüstü ☠** · dart MCP **1.1.0, 14 araç** (`.mcp.json` → `dart pub global run dart_mcp_server`).

---

## 4. SIRADAKİ İŞ

✅ **K42-d ADIM 3 (`slice-3c`) BİTTİ ve BAĞIMSIZ DOĞRULANDI.** Spec `GOREV-slice-3c-senkron.md` (K64, **41.692 b · `537D0579`**) T1–T8 tamamlandı; **ürün kodu +7.602 / −160 satır, 45 dosya** — `R8` sert durağı kalktı.

**COWORK'ÜN KENDİ KOŞUMU (builder'ın beyanına güvenilmedi, K26):**

| ölçüm | sonuç |
|---|---|
| `flutter analyze --fatal-infos` | **No issues found!** · EXIT 0 |
| `flutter test` | **+79 All tests passed** · EXIT 0 |
| `araclar/verify.ps1` | build **0 uyarı/0 hata** · Architecture **5** + Api **15** + SyncCore **40** + Persistence **54** = **114/114** · CVE **0** · `VERIFY PASSED` |
| `spec-kapi-kapsama.py` | 8 kapı · 10 kural · 36 mutant · **bulgu yok** |
| `sayi-tazeligi` · `tek-kopya` · `design-token` | TEMİZ · YEŞİL · TEMİZ |

**36 mutant:** `09-MUTANT/00-OZET.md` yalnız **8'inin** ham çıktısını taşıyor; kalan 28'in dayanağı "oturum transkripti". Cowork bunu beyan olarak kabul etmedi — Claude Code transkriptini (**9.124.995 b** jsonl) kendi ayrıştırdı, her mutant için uygulama izi + test-başarısızlık izi aradı: **36/36'da ikisi de var.** 🟡 Bu ölçüm **yakınlık** ölçer, nedensellik kanıtlamaz; ham KANIT'ın yerini **tutmaz** (§8 borcu).

🔴 **K65 — G6 AYAK6 kusuru (Onur kilitledi):** sunucunun receive-time kırpması iki alan-HLC'sini eşitleyince tie-break `opId`'nin dize-ordinaline düşüyordu; `opId` **UUID v4** olduğu için bu bir **yazı-turaydı** (~%40‑50 kayıp). Düzeltme **yalnız istemcide**: `opId` → **UUIDv7**, `counter` **her damgada** artar. **10/10 ardışık koşum SON.** Backend'e tek satır dokunulmadı.
🔴 **Adlandırma düzeltmesi (K66/4):** bu bir **"backend kusuru" DEĞİLDİR.** Düzeltme tamamen istemcide yapıldı ve kusur kapandı — backend kusurlu olsaydı istemci düzeltmesi onu **maskelerdi**. Doğru sınıflandırma: **① spec kusuru** (`D1`/`D7` `opId`'yi v4 pinledi, backend `HlcKey`'in *"zaman-sıralı `opId` varsayar"* sözleşmesini ihlal etti — **kapandı**) · **② backend'de zorlanmamış varsayım** (zayıf kontrol — **AÇIK**, §8).

**KANIT:** `KANIT/slice-3c/` — `HUKUM.md` (**7.386 b · `E3F87A3D`**) · kök `00-OZET.md` (**3.147 b · `54D1570A`**) · `09-MUTANT/00-OZET.md` (**5.640 b · `4A5CEB71`**) · `06-G6-uctan-uca/03-K65-bulgu-ve-duzeltme.md` (**4.994 b · `84EC60B6`**).

**SIRADAKİ: K42-d adım 4 — SignalR / gerçek zamanlı işbirliği (`slice-3d`).** Devralınan borçlar: çekme (pull) uygulaması · iki cihaz yakınsaması · ADR 0003 kimlik · backend `opId` v7 zorlaması.

🟡 **ONUR'UN ELİNDE (izin katmanı `rm`'i reddetti, Cowork silmez):** `src/backend/Momentum.Api.Tests/` ve `src/backend/Momentum.Persistence.Tests/` (takipsiz, `.sln`'e bağlı **değil**, içerikleri nötrleştirildi) · boş `KANIT/slice-3c/02-G2/` · arka planda `http://localhost:5298`'de çalışan Development API.

## 5. YÜRÜRLÜKTEKİ KİLİTLER (tek satır; gerekçe `PROJE_HAFIZA.md`'de)

- **K61** — **Dev-kimlik kalkanı (şık 1) KİLİTLİ:** yalnız `Development`'ta `DevCurrentUser` (**`X-Momentum-Dev-User`** → `UserId`; başlık yok/bozuk ⇒ 401, sessiz varsayılan kullanıcı YOK); **üretimde `NullCurrentUser` korunur ve bunu bir MUTANT kanıtlar** (`Production` ⇒ 401). `UserId` ⟂ `ClientId`. ADR 0003 **donmuş kalır** (K41). Beyan edilen sınır: bu bir kimlik **çözümü değil**, ölçüm **iskelesidir**.
- **K62** — **slice-3c tasarım kilitleri (`D0`–`D9`), spec v2:** kanal eşlemesi (`tamamlandi` → `Groups["completion"]`, `isDeleted` = tam `"true"`, `status` ∈ {`done`,`open`}, grup yazımı **REPLACE**) · kuyruk gövdesi **üretim anında donar**, sıra `(wall, counter, opId)` · HLC **monoton + KALICI + TAVANLI** (`now+300000`) ve sunucu damgasıyla **birleşir** · batch **≤ 100** + **tek uçuş** · zehirli op **karantina**, `cakisma` **kilitlenir** · **`D7`** zarf (`operationId`/`clientId`/`entityId`/`actorId` boş-GUID olamaz; her yazımın **kendi HLC'si**) · **`D8`** `Gorevler`+kuyruk **tek transaction**, `gonderildi → bekliyor` **kurtarma** · **`D9`** HTTP sınıflandırma (400 ⇒ tur durur; deneme tavanı 8) · **yalnız push**, çekme **uygulanmaz**.
- **K64** — **Spec v2 KİLİTLİ: 41.692 b · `537D0579`** (Onur onayladı, 27 Tem 2026). Değişen her bayt kilidi bozar; dosya `tek-kopya-kapisi.py` kapsamında **`kilitli`** sınıfına alındı ⇒ sapma **açılış protokolü adım 2'de** ölçülür. **`5899A220` (v1) GEÇERSİZDİR.**
- **K63** — **Spec v1 (`5899A220`) GEÇERSİZ; v2 geçerlidir.** İki bağımsız denetçi v1'i kırdı: 10 bloker · 12 önemli · 8 not (30 kapatıldı, 3 sınır beyan edildi). **Kendi mutantlarımdan `M13` eşdeğerdi (iptal), `M14`'ün beklenen sonucu olgusal olarak yanlıştı** (`tasks` upsert'tir). Kural: **ısırmayan mutant kapıyı gevşetmez — önce kapı düzeltilir** (K60'ın M2b emsali).
- **K66** — **slice-3c KABUL EDİLDİ (Cowork'ün kendi koşumu, K26).** Dört bulgu kayda geçti: ① devir notundaki `00-OZET.md` kimliği **yanlış** (iki ayrı dosya karıştırıldı) · ② spec §8'in *"her mutant için kanıt"* şartı **tam karşılanmadı** (8/36 ham; kalanı transkriptten doğrulandı) · ③ **kabul kriteri 8'in ölçümü kör** — `git diff` **takipsiz dosyaları görmez**, doğru ölçüm `diff` **+** `status` · ④ K65 bir **backend kusuru değil**, spec kusuru + backend'de zorlanmamış varsayım.
- **K65** — **`opId` UUIDv7 + `counter` her damgada artar (Onur kilitledi).** Gerekçe: sunucu clamp'i iki alan-HLC'sini eşitleyince tie-break `opId` dize-ordinaline düşüyor; v4 rastgele olduğu için **yazı-tura** oluyordu (~%40‑50 kayıp). Düzeltme **yalnız istemcide**; backend'e tek satır dokunulmadı; **10/10** ardışık koşum SON.
- **K53** — Verimlilik reformu: kâğıt denetim turu tavanı **1** · radar KIRMIZI'da varsayılan **DEVRET** · koşan-uygulama-mutant tavanı **3** · iki oturum 0 ürün kodu = **sert durak (`R8` — K57'de `R7`'den yeniden adlandırıldı)** · hafıza bölündü.
- **K59** — Spec **v6, KİLİTLİ**: **44.560 b · `F0C3A75A`**. **`6056A5BB`, `79A53AA3`, `BE4581BA`, `1AB02B73` GEÇERSİZ.** ① **A2 iki yakalama** ister (vitrin + gerçek ekran, ham JSON, birleşimde 8 ad) — gevşetme **değil**, sağlanamaz şartın sağlanabilir ve **daha pahalı** hâli; gerekçe §5/G1'de ölçümle yazılı. ② Kriter **6·7·8**'e araç adı + ölçülen rakamlar (`8/8`, `6/6`, `18/18`) ⇒ `sayi-tazeligi.py` artık bu satırları **mekanik** doğruluyor, **muafiyet kalmadı**.
- **K57** — Spec v5 (`6056A5BB`): on **bayat çapraz-atıf** düzeltildi; özü değişmedi. Onuncuyu, kilitten **sonra** doğan `sayi-tazeligi.py` buldu. Ayrıntı: `PROJE_HAFIZA.md` K57.
- **K60** — **Tek kopya dosyaya yazan her betik ATOMİK yazar:** önce `metin.encode("utf-8")` (hata dosyaya **dokunmadan** patlar), sonra `.tmp`, en son `os.replace` ile takas. Gerekçe ucuz değil: oturum 31'de `io.open(yol,"w")` `PROJE_HAFIZA.md`'yi **önce boşalttı**, sonra encode hatası aldı ⇒ **542 KB arşiv 0 bayta düştü**; kurtaran şey kural değil **şanstı** (dosya 30 dk önce commit'liydi, `git restore` ile tam geri geldi). ✅ **ARTIK KAPISI VAR:** `tek-kopya-kapisi.py` (açılış protokolü adım 2). Kapı kuralın *uygulanıp uygulanmadığını* değil **dosyanın hâlini** ölçer — hangi el, hangi yöntem olduğu umurunda değildir. **Beyan edilen sınır:** kapı hasarı **önlemez**, sessiz kalmasını imkânsız kılar.
- **K57‑b** — `araclar/radar.py` **plugin 0.2.0 ile BAYT-ÖZDEŞ** (`46E3A8BC`); proje-yerel not **eklenmez** ⇒ sapma **tek sha ile** ölçülür.
- **K58** — `DURUM.md` tavanı **12 → 32 KB**. Gerekçe okuma kapasitesi **değil**: ① R4 freni, ② dikkat (3,5k token okunur, 40k *göz gezdirilir*). Gevşetmenin dayanağı: bayat-atıf sınıfı **mekanikleşti**. 🔴 Tavanı **hiçbir kapı zorlamıyor** — beyan edilmiş **zayıf kontrol**; ilk ısırışta `belge-tavan-kapisi.py` yazılır. Ayrıca `PROJE_HAFIZA.md`'ye **mekanik dizin** (`hafiza-dizin.py`); **yeni checkpoint `<!-- DIZIN:SON -->` ALTINA** eklenir.
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
| `radar.py` **0.2.0** | kısır döngü + **R8 ürün kodu durgunluğu** + **defter dürüstlüğü D1‑D5** + `--olc-urun-kodu` | **18/18** |
| `spec-kapi-kapsama.py` | spec'te **mutantsız kapı/kural** arar; borç beyanı okur | **13/13** |
| `sayi-tazeligi.py` **1.1.0** | belgedeki **"altın küme N/M"** iddiasını **aracı koşarak** doğrular; muafiyet `tazelik-muafiyet.json`'da ve **gerekçesiz olamaz** | **16/16** |
| `design-token-kapisi.py` **0.2.0** | `DESIGN.md` ↔ Dart token kapısı `D0`–`D6` (D1 sıkılaştırma + D5 + D6 T8'de) | **18/18** |
| `pub-cve-kapisi.py` (G2) | `pubspec.lock` ↔ `/advisories`; `withdrawn` atar, `ignored_advisories` **yutmaz** | **8/8** |
| `pub-lisans-kapisi.py` (G3) | `pubspec.lock` ↔ `/metrics` SPDX; *bilinmeyen ≠ temiz*; **metin-kanıtlı eşleşme** (`lisans-eslesme.json`, kanıtsız eşleşme KIRMIZI) | **6/6** |
| `tek-kopya-kapisi.py` **1.1.0** | tek kopya dosyaların **HEAD'e göre regresyonunu** ölçer (`S0`–`S10`); sınıf başına farklı kural: append-only **küçülmez**, kilitli **sapmaz**, canlı **%10 budanabilir**; muafiyet gerekçesiz olamaz, **ölü muafiyeti söyler** | **19/19** |
| `tek-kopya-mutant.py` | kapının **ölçüm ayağını** gerçek depoda kanıtlar: arşivi 0 bayta düşürür, satır siler, kilitli dosyayı **aynı boyutta** değiştirir, `.tmp` bırakır, UTF-8'i bozar, dosyayı siler — hepsinde kapının **ısırdığını** ölçer | **11/11** |
| `hafiza-dizin.py` **1.0.0** | `PROJE_HAFIZA.md`'nin başına **türetilmiş** checkpoint dizini yazar; **fikirli** (koşum 2–3'te sha sabit) ve kendi çıktısını doğrular | **7/7** |
| `dosya-kimlik.py` | bayt + sha256 + U+FFFD + CRLF | — |
| `mcp-arac-probe.py` | MCP'nin **gerçek** araç listesi (`tools/list`) | — |
| `pub-surum-olc.py` | pub.dev `/api` sürüm + advisory | — |
| `lisans-yokla.py` | lisansın hangi uçta olduğunu ölçer | — |
| `adr-kapi-taramasi.py` | ADR 0003 kapısı (**dondurulmuş**, dokunma) | — |
| `verify.ps1` | backend build+test+CVE zinciri | — |

---

## 7. KANLA YAZILI ORTAM UYARILARI

- **Claude Code DAİMA `Momentum` kökünden açılır** (üstten açarsan `.mcp.json` görünmez, dart MCP yüklenmez).
- **Cowork→PowerShell köprüsü `$` değişkenlerini SİLİYOR** ve iç içe tırnakları bozuyor ⇒ `$` gönderme, **Python betiği yaz**.
- **Commit mesajına ÇİFT TIRNAK yazma** (PowerShell argümanı böler, commit sessizce düşer); sonra `git log --oneline -1` ile SHA'yı doğrula.
- **git'te `--no-optional-locks` ZORUNLU.** Commit **yalnız Desktop Commander** ile; `device_bash`/mount **YASAK**. **PUSH ONUR'DA.**
- **`device_stage_files` BAYAT KOPYA sunabiliyor** (oturum 28; 30'da tekrarlanmadı) ⇒ stage'lenenin **sha'sını karşılaştır**; tutmuyorsa `read_file` kullan.
- 🔴 **YOL SAF ASCII KALMAK ZORUNDA [K56].** Türkçe karakter dört zinciri kırdı (`build_runner`, `flutter analyze`, AGP, `.ps1`). Boşluk suçsuz, junction çözmez. Ayrıntı: `KANIT/slice-3b/ORTAM-YOL-KISITI.txt`.
- **Git Bash/MSYS, `cmd /c`'deki `/c`'yi POSIX yol sanıp `C:/` diye YENİDEN YAZIYOR** ⇒ ham `cmd /c` içeren komutlar **PowerShell'den** koşulur.
- **Başka bir el çalışırken `git add -A` YASAK** — commit'lenmemiş işini kör alır (ölçüldü: `dee6dbc`). Yol belirterek `git add <yol>` yap.
- **`flutter test --platform chrome` bu ortamda SONUÇ ÜRETMİYOR** (iki ölçüm: 7 dk ve 9,8 dk) ⇒ web test ayağı `[DOĞRULANMADI]`.
- **pub.dev HTML sayfaları BAYAT** — kanıt yalnız `/api/` ucudur (spec Z10). · `.ps1`'e Türkçe yol literali yazma. · `kasif` skill'ini **Cowork çağıramaz**; Onur `/kasif` yazar.
- 🔴 **`git`'te `core.autocrlf` AKTİF** — `git restore` LF yazılmış 2.400 baytlık dosyayı **2.800 bayt** geri getirdi (ölçüldü). Çalışma kopyası ↔ HEAD blob **bayt karşılaştırması bu ortamda tek başına KÖRDÜR**; kimlik ölçen her araç LF'e normalize etmelidir.
- 🔴 **`io.open(yol,"w")` DOSYAYI ÖNCE BOŞALTIR** — encode hatası gelirse dosya **0 bayt** kalır (oturum 31: 542 KB arşiv gitti, `git restore` kurtardı). **Python'da `"\ud83d\udd3b"` iki `\u` kaçışı olarak yazılırsa BİRLEŞMEZ**, yalnız vekil karakter olur ve `encode` patlar; emoji için `\U0001F53B` yaz. Kural: **K60 atomik yazım**.
- **`flutter test` Desktop Commander kabuğunda ÇÖKÜYOR** — `%PROGRAMFILES(X86)% environment variable not found` (ölçüldü: değişken `os.environ`'da **yok**, dizin diskte **var**). ⇒ alt sürece `PROGRAMFILES(X86)=C:\Program Files (x86)` **enjekte et**; kalkanla test 36/36 geçti. Bu bir **ortam** kusurudur, ürün kusuru değil.

---

## 8. AÇIK BORÇLAR (adlandırılmış, gizlenmemiş)

- ✅ **KAPANDI [K63]:** *"slice-3c spec'i bağımsız denetimden geçmedi"* — Onur yanlış anlamayı düzeltti, **denetim koştu ve spec v1'i KIRDI** (10 bloker · 12 önemli · 8 not; 30 kapatıldı). **K26 SAĞLANDI.** Ders kayda geçti: *beyan edilmiş bir eksik, kapatılmamış bir eksiktir* — beyan onu ucuzlatmaz, yalnız görünür kılar.
- 🔴 **`KANIT/slice-3c/02-G2/` SİLİNEMEZ — G2 TESTİ ORAYA YAZMAYA DEVAM EDİYOR [K66/5, Cowork ölçtü]** — `g2_registry_zarf_kapisi_test.dart` **satır 64** `Directory('../../KANIT/slice-3c/02-G2')` ⇒ her `flutter test` koşumunda klasör **yeniden doğuyor** (Cowork'ün 23:47 koşumu doldurdu; mtime **23:48:28**). Devir notundaki *"boş, Onur silecek"* beyanı **yanlış**. `02-G2-registry-zarf/`'daki dört JSON testin canlı çıktısı **değil**, elle kopyalanmış donmuş kopya (sha'lar farklı). **Spec §8 şeması ile üretici kodun yolu uyuşmuyor.** Cowork `02-G2/`'yi commit'ten çıkardı; kalıcı düzeltme **üretici elin** işi. 🔴 Hiçbir araç *"KANIT dizini ile onu yazan kodun yolu aynı mı?"* diye sormuyor — mekanik kontrol **yok**.
- 🔴 **BACKEND `OperationId`'nin UUIDv7 OLDUĞUNU ZORLAMIYOR [K66/4, oturum 32]** — `HlcKey`'in tie-break'i zaman-sıralı `opId` **varsayar**; `SyncIngest.IsEnvelopeValid` yalnız *"boş GUID değil"* diye bakar. **v4 gönderen herhangi bir istemci K65'in yazı-turasını geri getirir ve hiçbir kapı yanmaz.** Bugün kapalı olmasının tek sebebi **istemcinin uslu davranması**. Kalıcı çözüm ADR 0002'nin işi (sürüm nibble'ını zarf geçerliliğinde zorlamak) ⇒ **slice-3d / ADR borcu**.
- 🔴 **MUTANT HAM ÇIKTISI KOŞULDUĞU ANDA YAZILMALI [K66/2]** — slice-3c'de 36 mutantın **8'inin** ham çıktısı KANIT'a yazıldı, **28'i yazılmadı** (dürüstçe beyan edildi, transkriptten doğrulandı). Ders: *koşum anında dosyaya yazılmayan ham çıktı sonradan yeniden üretilemez.* Sonraki dilimde mekanikleştirilir.
- 🔴 **`git diff` TAKİPSİZ DOSYALARI GÖRMEZ — "dokunulan yüzey" ölçümü tek başına KÖR [K66/3]** — slice-3c'nin kabul kriteri 8'i `diff --stat` ile ölçülüyordu ve `src/backend/` altındaki yeni `Auth/DevCurrentUser.cs` ile iki stray klasörün **hiçbirini** göstermedi. Bundan sonra "dokunulan yüzey" iddiası **`diff` + `status` birlikte** ölçülür.
- 🔴 **SAYI ↔ LİSTE TUTARSIZLIĞI: Cowork'ün TEKRAR EDEN kusuru, mekanik kapısı YOK [oturum 32, iki kez ölçüldü]** — v1'de *"on altı mutant · `M1`–`M16`"* denirken tabloda **17** satır vardı (denetçi buldu); v2'yi yazarken **aynı kusuru tekrar ürettim** (*"otuz iki"* ⇄ 36 satır) ve kapıyı koşmadan önce kendim yakaladım. `spec-kapi-kapsama.py` mutantları **sayar** ama belgenin **kendi sayı iddiasıyla** karşılaştırmaz; `sayi-tazeligi.py` yalnız `"altın küme N/M"` imzalı satırlara bakar ⇒ **ikisi de bu sınıfa kördür**. İlk ısırışta araç yazılır (K44-a: **önce araç, sonra belge**). Bu ısırış **ikinci**dir.
- 🟡 **Çekme (pull) yakınsaması slice-3c'de KANITLANMAYACAK** — `D6` beyan edilmiş sınırı: `changes`/`snapshot` Drift'e uygulanmaz, yalnız `nextCursor` saklanır. İki cihazın yakınsaması **slice-3d borcudur**.
- **`DESIGN.md` BD‑1…BD‑7** — **K46 gereği kapatılmadı**; liste spec §10'da. BD‑6'nın bayat sayısı `sayi-tazeligi.py`'de **gerekçeli muafiyet** olarak görünür.
- ✅ **KAPANDI [K57]:** `radar.py` kopyası GERİDE · Spec T2/Z10 kilit düzeltmesi.
- 🔴 **`pub-surum-olc.py`'ye ÇÖZÜMLENEBİLİRLİK AYAĞI [Z10b]** — araç **sürümü** ölçüyor, **çözülebilirliği** ölçmüyor. Kalkan gelene dek **her pin `pub get` ile doğrulanır**.
- 🔴 **Defter dürüstlük kusurları [D-kapısı buldu]** — `D3`: `docs/ADR/0003` tur 8 kaydının zorunlu alanları eksik. `D2`: aynı defterde **tur 1 atlanmış**. Append-only ⇒ **düzeltme kaydı**.
- ✅ **KAPANDI [K59]:** *"Spec kriter 6/7 ölçülmedi"* — araç adları yazıldı, rakamlar ölçüldü, muafiyet **silindi**.
- ✅ **KAPANDI [oturum 31]:** *A2 kanıtı eksik* — iki ham ağaç yazıldı (`widget-tree-vitrin.json` `574223D0` · `widget-tree-gercek-ekran.json` `6C5D431A`), **Cowork ikisini de `json.loads` ile ayrıştırdı**, birleşim **8/8**. `HUKUM.md` (`D6AC8377`) artık **düğüm kimliklerine** atıf yapıyor — beyan değil **çıktı**.
- 🟢 **`tek-kopya-kapisi.py`'nin BEYAN EDİLMİŞ SINIRI [S10]** — karşılaştırma **LF'e normalize** içerik üzerinden yapılır, çünkü `core.autocrlf` çalışırken çalışma kopyası ile HEAD blob'u **aynı içerikte bile farklı bayttadır** (mutant M2 ölçtü: 2.400 → 2.800). Sonuç: **yalnızca satır sonu karakterini** kaybeden bir dosya kapıyı geçer (M2b). İçerik kaybı **değildir**; gizlenmiş değil **beyan edilmiş** sınırdır.
- 🟡 **`radar.py` R5'in CÜMLESİ KAPSAMINI AŞIYOR [ölçüldü, oturum 31]** — R5 artefaktın **kendi son kaydındaki** `gorunen_cikti_yuzde` alanını okur ama *"**projenin** GÖRÜNEN ÇIKTISI hâlâ %0"* diye yazar. Yeni kayıt %35 derken park edilmiş eski artefaktlar hâlâ %0 bağırıyor. Kusur **metinde**, ölçümde değil. Onarım **üst akış plugin'inde** (K57‑b bayt-özdeşliği bozulmasın); ayrı el (K34‑f).
- 🟡 **`radar --olc-urun-kodu` ÇALIŞMA AĞACINI GÖRMEZ** — yalnız commit'lenmiş farkı sayar. İki elin eşzamanlı çalıştığı bu projede **R8'i yanlış-pozitif yapar** (oturum 31'de fiilen yaktı; gerçek ölçüm **61 satır**). R8 KIRMIZI yandığında **önce çalışma ağacı ölçülür**. Onarım ayrı ele (K34‑f); üst akış plugin'de de aynı boşluk var.
- 🟡 **`KANIT/slice-3b/04-G3/gercek-tarama.txt` 1,9 MB** — portfolyo reposuna 2 MB ham JSON kanıt değil **yüktür**; ilgili kesit + sha yeterdi.
- 🟡 **M2b beyanının tersi ölçüldü** — spec/DESIGN A‑4 *"çok satırlı `/* */` içindeki literal KAÇABİLİR"* diyordu; kapı onu **yakaladı** ⇒ `yorum_disi()` yorumu soymuyor, yani **yorum içindeki literali de kod sayıyor** (kaçırma değil, yanlış-pozitif yönü). A‑4 beyanı bu ölçüme göre yeniden okunmalı.
- 🟡 **`D1` bu defterde KÖR** — artefakt adları çoğunlukla **etiket**, yol değil. Yeni kayıtlara **gerçek yol** yazılır.
- 🟡 **`sayi-tazeligi.py` — İMZA↔SAYI YAKINLIĞI ÖLÇÜLMÜYOR [3 kez tetikledi]** — uzun satırlarda araçla ilgisiz bir oran iddia sanılıyor. **Eşik uydurulmadı** (K40); biri muafiyet, biri metin düzeltmesiyle kapandı. **Kalıcı onarım AYRI EL'e** (K34‑f).
- **`radar.config.json` YOK ve bu bir KARAR** — varsayılan yollar repoya birebir uyuyor. Eşik değiştiren K40 gereği **altın kümeye vaka ekler**.
- **`pub.dev` uçları** dokümantasyonsuz/garantisiz — kalkan: fixture altın kümeleri. · **Kontrast betiği** `araclar/` dışında.
- **Açık `[DOĞRULANMADI]` (5):** flutter_secure_storage Windows · WebKit `__Host-` · Isopoh lisansı · NIST SP 800-38D · web'de `textScaler`/tema farkı.
- **Geçici artıklar (repo DIŞINDA, silme Onur'da):** `%TEMP%\_cw_*` · `C:\dev\_cowork_tmp\`.

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
| `GOREV-slice-3b-istemci-iskeleti.md` | **44.560** | **`F0C3A75A`** | 🔒 **K59 kilidi (v6)** — değişen her bayt kilidi bozar. `6056A5BB` · `79A53AA3` · `BE4581BA` · `1AB02B73` **geçersizdir** |
| `GOREV-slice-3c-senkron.md` | **41.692** | **`537D0579`** | 🔒 **K64 kilidi (v2, Onur onayladı 27 Tem 2026)** — `5899A220` (v1) **GEÇERSİZDİR**. `tek-kopya-kapisi.py` kapsamında **`kilitli`** sınıfındadır ⇒ sapma **her açılışta ölçülür** |
| `araclar/radar.py` | 28.878 | `46E3A8BC` | **K57‑b** — plugin 0.2.0 ile bayt-özdeş; sapma tek sha ile ölçülür |
| `araclar/adr-kapi-taramasi.py` | 50.582 | `A22841F2` | **K34-f** tutuyor; ADR donduruldu |

⚠ **Kimlik `sha256`+bayttır, satır DEĞİL** (`Measure-Object -Line` boş satırları saymaz) ve **DAİMA son yazımdan SONRA** ölçülür.

---

## 10. NEREDE NE VAR

`DURUM.md` (**canlı durum**) · `CLAUDE.md` (kalıcı kurallar) · `PROJE_HAFIZA.md` (**append-only arşiv**, K1…K57) · `DESIGN.md` · `PROJE_RADAR.jsonl` (ölçüm defteri) · `docs/ADR/` · `GOREV_CLAUDE_CODE/` · `araclar/` (kapılar) · `KANIT/` · `src/`, `tests/`.

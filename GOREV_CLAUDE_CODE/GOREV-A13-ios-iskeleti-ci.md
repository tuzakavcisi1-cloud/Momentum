# GOREV-A13 — iOS İSKELETİ + İLK CI BORU HATTI (dar dikey dilim)

> **Durum:** KİLİT ADAYI — Onur onaylamadan Claude Code'a **verilmez**.
> **Dilim sınıfı:** 🟢 **ÜRÜN KODU** (K53/4). `flutter create --platforms=ios` çıktısı
> `urun_kodu_satiri`na girer; **niteliği burada beyan edilir: bu üretilmiş bir iskelettir,
> elle yazılmış bir özellik değildir.** Dilimin ürün değeri iskeletin kendisinde değil,
> **iskeletin CI'da gerçekten derlendiğinin ölçülmesindedir** (K53/5).
> **Kapı kimlikleri spec-yereldir (K108):** bu belgede `A13/G27`–`A13/G30`.

---

## 1. NE OKUNUR

`DURUM.md` §2 (açılış protokolü) · `CLAUDE.md` (K53 · K55 · K80 · K81 · K108) ·
`ORTAM.md` (tamamı — özellikle `flutter` **`.bat`**'tir, `$` gönderilmez, `findstr` yokluk ölçmez) ·
bu belge. `PROJE_HAFIZA.md` **açılmaz** (K53).

---

## 2. NEDEN — ÖLÇÜLMÜŞ KÖK NEDEN

Bu dilim iki **ölçülmüş** boşluğu kapatır:

1. 🔴 **`src/client/ios/` YOK** (3 Ağu 2026, oturum 52'de ölçüldü). Proje kendini
   *"çok platformlu (Android/iOS/Web/Windows)"* diye tanımlıyor; diskte **`android/` ve
   `web/` var, `ios/` yok**. Bu, belgede duran ama repoda karşılığı olmayan bir iddiadır —
   `bayat-iddia` sınıfının en pahalı hâli, çünkü iddiayı okuyan **işe alan taraftır**.
2. 🔴 **HİÇBİR CI YOK** (aynı ölçüm): `.github/` · `azure-pipelines.yml` · `.gitlab-ci.yml` ·
   `Makefile` — **dördü de YOK**. Bugüne kadar her kapı **tek bir makinede, tek bir elin
   iyi niyetiyle** koştu. Mac olmadığı için iOS derlemesi **hiç ölçülmedi**; CI, iOS'un
   ölçülebildiği **tek** yerdir.

**Neden şimdi ve neden DAR:** oturum 51 (`A12`) araç işiydi ve `urun_kodu_satiri` üretmedi.
Oturum 52 de kodsuz kapanırsa `R8` sert durağı yanar (K53/4). Aynı anda radar **KIRMIZI**
ve `R4` (artefakt büyümesi) **14 artefaktta SARI** ⇒ geniş bir dilim, ölçülmüş bir kusur
sınıfını bilerek beslemek olur. Bu yüzden backend'in CI'ya taşınması **bu dilimde YOKTUR**
ve bu bir atlama değil, **§9'da beyan edilmiş sınırdır**.

---

## 3. KİLİTLİ KARARLAR

### `D-A13-1` — iSKELET MEVCUT PROJEYE **EKLENİR**, YENİ PROJE AÇILMAZ

`cd src\client` → `C:\src\flutter\bin\flutter.bat create --platforms=ios .`
(nokta **zorunlu**: var olan `pubspec.yaml`'ın yanına yalnız `ios/` üretir).
🔴 **Yeni bir `flutter create momentum_ios` projesi açmak YASAK** — `lib/`, `test/`,
`pubspec.yaml` ve 500 test kaybolur. Üretilen `ios/` sürüm kontrolüne **girer**;
`ios/Pods/`, `ios/.symlinks/`, `ios/Flutter/Flutter.framework` gibi **build artefaktları
`.gitignore`'a girer** (kırmızı çizgi 5).

### `D-A13-2` — BUNDLE ID `com.momentum.client`, MİNİMUM iOS **13.0**

Flutter'ın varsayılanı `com.example.client`'tır ve **portfolyoda kusur olarak okunur**.
`PRODUCT_BUNDLE_IDENTIFIER` üç yapılandırmada da (`Debug`/`Release`/`Profile`)
`com.momentum.client` olur. `IPHONEOS_DEPLOYMENT_TARGET = 13.0`.
🔴 **Apple Developer hesabı, takım kimliği (`DEVELOPMENT_TEAM`) ve profil YAZILMAZ** —
hesap yok, yazılan her değer **doğrulanmamış bir beyandır**.

### `D-A13-3` — CI **İKİ İŞ**, TETİK `workflow_dispatch` + `push: main`

`.github/workflows/ci.yml`:
`istemci` (`ubuntu-latest`) → `flutter analyze --fatal-infos` **ve** `flutter test`.
`ios` (`macos-latest`) → `flutter build ios --no-codesign`.
🔴 **`--fatal-infos` PAZARLIKSIZ:** bu depoda analiz kapısı bugüne kadar
`--fatal-infos` ile koştu (`A11` kabulü: 0 sorun). CI'da bayrağı düşürmek, aynı kapıyı
**sessizce gevşetmektir**. 🔴 `pull_request` tetiği **YOK** (Onur kilitledi, oturum 52):
private repo kotası ölçülemedi ⇒ kendiliğinden koşan iş sayısı **asgaride** tutulur.

### `D-A13-4` — BACKEND `verify` ZİNCİRİ BU DİLİMDE CI'YA **GİRMEZ**

Gerekçe **ölçülmüştür, tembellik değildir**: backend ayağı Postgres service container +
.NET 10 SDK + `verify.ps1`'in bash eşleniği demektir; bu, tek dilimde **ikinci bir ürün**
açar. Radar `R4` şu an **14 artefaktta SARI** ve `R1` *"tekrar eden kusur sınıfı"* KIRMIZI.
⇒ ⑨'a bırakılır. **Mutantı yoktur ve olamaz** (bir *yapmama* kararının mutantı yoktur) ⇒
**§6b'de gerekçesiyle borç olarak yazılır.**

### `D-A13-5` — iOS DERLEMESİ **İMZASIZ** (`--no-codesign`)

İmzalı derleme Apple hesabı + saklanan sır ister; ikisi de yok (kırmızı çizgi 1).
`--no-codesign` bayrağı `ci.yml`'de **açıkça** bulunur; varsayılana güvenilmez.

### `D-A13-6` — CI'DA FLUTTER SÜRÜMÜ **PİNLENİR: 3.44.6**

`stable`/`latest` kanal kullanmak, build'i **bir gün sessizce** kırar ve o gün kusur
üründe sanılır. Yerel ölçüm **Flutter 3.44.6 / Dart 3.12.2**'dir (oturum 52'de ölçüldü);
CI aynı sürümü kullanır ⇒ CI ile yerel **karşılaştırılabilir** kalır.

### `D-A13-7` — `flutter test` CI'DA KOŞAR VE SAYISI **ÖLÇÜLÜR**

Yerelde `500/500` geçtiği ölçüldü (`A11`, K121). CI'daki sayı **spec'e yazılmaz, logdan
okunur**: iki sayı ayrılırsa bu bir bulgudur, gizlenmez.
🔴 **Beyan edilmiş risk:** Drift/sqlite3 Linux runner'da yerel kütüphane isteyebilir.
Patlarsa çözüm `istemci` işine `sudo apt-get install -y libsqlite3-dev` eklemektir;
**bu bir ürün kusuru değildir ve öyle raporlanmaz** (ORTAM.md'nin `PROGRAMFILES(X86)`
dersinin CI'daki kardeşi).

---

## 4. ORTAM — **KİM KALDIRIR** (K80, PAZARLIKSIZ)

Bu dilim **cihaz da canlı sunucu da İSTEMEZ**. Oturum 52 açılışında ölçüldü:
`momentum-postgres` **Exited (255)** · `:5298` **dinlemiyor** · `adb devices` **boş**.
🟢 **Üçü de bu dilim için gereksizdir ve AÇILMAZ** — açmak, ölçülmemiş bir maliyeti
sebepsiz ödemektir.

**Builder'ın kendi kaldıracağı tek ortam:** Flutter araç zinciri (`C:\src\flutter\bin\flutter.bat`
— **`flutter` PATH'te `.bat`'tir, K86**) ve `git`. Xcode **YOKTUR ve kurulmaz** (Mac yok);
iOS derlemesi **yalnız CI'da** ölçülür — bu dilimin varlık sebebi budur.

🔴 **PUSH ONUR'UNDUR.** CI ancak push'tan sonra koşar ⇒ bu dilimin kapıları
**Onur push ettikten sonra** ölçülür. Builder push etmez, Cowork push etmez.

🔴 **ÖN KOŞUL — TOKEN YETKİSİ [oturum 52'de ölçüldü, `[DOĞRULANMADI]` bırakıldı]:**
GitHub, `.github/workflows/` altına dosya ekleyen bir push'u, kullanılan token'da
**`workflow` yetkisi yoksa reddeder. `gh` token'ında bu yetki YOK** (`gist, read:org, repo`).
Push `gh`'yi değil **Git Credential Manager**'ı kullanıyor (`credential.helper=manager`) ve
GCM token'ının yetkisi buradan **ölçülemez**. Push reddedilirse çözüm **Onur'un** koşacağı
tek satırdır: `gh auth refresh -h github.com -s workflow`.
**Bu bir ürün kusuru değildir; kabul kriterlerini düşürmez, yalnız sırayı geciktirir.**

---

## 5. KAPILAR

> Kapılar **spec-yereldir** (K108) ⇒ atıf daima `A13/G27` biçiminde yapılır.
> `A13/G28`–`A13/G30`'un **statik ayakları** yeni araç `araclar\ci-kapisi.py` ile ölçülür;
> araç **kendi altın kümesini taşır** (K44-a: *önce araç, sonra belge*) ve
> **altın kümesi geçmeden hiçbir kapı yeşil sayılmaz** (KÖR KAPI YOK).

### G27 — CI GERÇEKTEN KOŞTU VE YEŞİL (beyan değil, `gh` ile ölçüm)

| ayak | ölçüm | geçme koşulu |
|---|---|---|
| a | `gh run list --workflow ci.yml --limit 5 --json conclusion,headSha,status` | en son koşumun `conclusion` = `success` |
| b | aynı çıktının `headSha`'sı ile `git --no-optional-locks rev-parse HEAD` | **eşit** — başka bir commit'in yeşili bu dilimi kanıtlamaz |
| c | `gh run view <id> --log` içinde **iki işin de** adı geçer | `istemci` **ve** `ios` işleri koşmuş olmalı |

🔴 **"Actions sekmesinde yeşil gördüm" BİR ÖLÇÜM DEĞİLDİR.** Kanıt `gh` çıktısının
**ham metnidir** ve `KANIT/A13/` altına yazılır. Kural: `D-A13-3`

### G28 — İSTEMCİ İŞİ GERÇEKTEN DENETLİYOR (statik + koşan)

| ayak | ölçüm | geçme koşulu |
|---|---|---|
| a | `ci-kapisi.py`: `ci.yml`'de `analyze` adımı **`--fatal-infos` taşıyor** | taşımıyorsa KIRMIZI |
| b | `ci-kapisi.py`: Flutter sürümü **`3.44.6` olarak pinli**, `stable`/`latest` **değil** | pin yoksa KIRMIZI |
| c | CI logunda `flutter analyze` çıkışı | **0 sorun** |
| d | CI logunda `flutter test` özeti | `N/N` geçti; **N logdan okunur, spec'ten değil** |

Kurallar: `D-A13-3` · `D-A13-6` · `D-A13-7`

### G29 — iOS GERÇEKTEN DERLENDİ (bu dilimin taç ayağı)

| ayak | ölçüm | geçme koşulu |
|---|---|---|
| a | `ci-kapisi.py`: `ci.yml`'de iOS adımı **`--no-codesign`** taşıyor | taşımıyorsa KIRMIZI |
| b | macOS işinin logunda `Xcode build done` benzeri tamamlanma satırı | **var** |
| c | log içinde `Runner.app` üretim satırı ve boyut | **> 0 bayt** |
| d | macOS işinin `conclusion`'ı | `success` |

🔴 **`--no-codesign` yüzünden `.ipa` ÜRETİLMEZ; kanıt `Runner.app`'tir.** `.ipa` arayan
bir kriter, bu dilimde **hiç geçemeyecek** bir kriterdir. Kurallar: `D-A13-5` · `D-A13-2`

### G30 — İSKELET DOĞRU YERDE VE REPO TEMİZ

| ayak | ölçüm | geçme koşulu |
|---|---|---|
| a | `ci-kapisi.py`: `ios/Runner.xcodeproj/project.pbxproj` içindeki **her** `PRODUCT_BUNDLE_IDENTIFIER` | `com.momentum.client` — `com.example` **bir kez bile** geçmemeli |
| b | `ci-kapisi.py`: `IPHONEOS_DEPLOYMENT_TARGET` | `13.0` |
| c | `ci-kapisi.py`: `.gitignore` iOS artefakt yollarını kapsıyor (`ios/Pods/`, `ios/.symlinks/`, `ios/Flutter/Flutter.framework`) — **varlık pozitif kontrolüyle** (ORTAM.md `findstr` dersi) | üçü de kapsanmalı |
| d | `src/client/lib`, `src/client/test`, `pubspec.yaml` **HEAD'e göre değişmemiş** | `git --no-optional-locks status --porcelain` bu yollarda **boş** |

🔴 **Ayak (d) `D-A13-1`'in gerçek kapısıdır:** *"yeni proje açılmadı"* iddiası ancak
**mevcut dosyaların dokunulmamış olmasıyla** kanıtlanır. Kurallar: `D-A13-1` · `D-A13-2`

---

## 6. MUTANTLAR

> **Maliyet sınıfına göre tavan (K53/3):** *koşan* mutant (CI koşumu isteyen) tavanı **3** —
> `M167`·`M168`·`M169` ile **tam doludur, dördüncüsü açılamaz**. *Statik* mutantlar
> (`ci-kapisi.py` + dosya düzenleme) **tavansızdır**; saniyeler sürer ve para harcamaz.

> 🔴 **SÜTUN DÜZENİ PAZARLIKSIZ — `hedef` ÜÇÜNCÜ SÜTUNDUR.** `spec-kapi-kapsama.py`
> mutant hedefini **`hucreler[2]`**'den okur (kaynak: `mutantlar()`, satır 124). Bu spec ilk
> yazımında `hedef`i 4. sütuna koydu ve araç **`[S1]` × 4 + `[S2]` × 5** ile durdu: sekiz
> mutantın hiçbiri hiçbir kapıya bağlanmadı. **Kusur builder'ın değil, spec'i yazan elindir**
> (K81'in aynısı, bir seviye derininde: K81 *bölüm başlıklarını* standartlaştırdı ama
> **sütun sırasını yazmamıştı**). Kapanış yolu `BORCLAR.md`'de.

| mutant | sınıf | hedef | ne bozulur | beklenen |
|---|---|---|---|---|
| M162 | statik | `A13/G28` · `D-A13-3` | `ci.yml`'deki `analyze` adımından `--fatal-infos` silinir | `ci-kapisi.py` **KIRMIZI** |
| M163 | statik | `A13/G28` · `D-A13-6` | `ci.yml`'de Flutter sürüm pini `3.44.6` → `stable` yapılır | `ci-kapisi.py` **KIRMIZI** |
| M164 | statik | `A13/G29` · `D-A13-5` | `ci.yml`'deki iOS adımından `--no-codesign` silinir | `ci-kapisi.py` **KIRMIZI** |
| M165 | statik | `A13/G30` · `D-A13-2` | `project.pbxproj`'de bir `PRODUCT_BUNDLE_IDENTIFIER` `com.example.client`'a döndürülür | `ci-kapisi.py` **KIRMIZI** (tek geçiş bile yeter) |
| M166 | statik | `A13/G30` · `D-A13-1` | `.gitignore`'dan `ios/Pods/` satırı silinir | `ci-kapisi.py` **KIRMIZI** |
| M167 | **koşan CI** | `A13/G27` · `A13/G28` · `D-A13-3` | `lib/main.dart`'a kullanılmayan bir `import` eklenir (dal: `mutant/A13-M167`) | `istemci` işi **failure** |
| M168 | **koşan CI** | `A13/G28` · `D-A13-7` | bir widget testinin beklentisi kasten ters çevrilir (dal: `mutant/A13-M168`) | `istemci` işi **failure** |
| M169 | **koşan CI** | `A13/G29` · `A13/G27` · `D-A13-2` | `ios/Runner/Info.plist` bozulur — kapatılmamış XML etiketi (dal: `mutant/A13-M169`) | `ios` işi **failure** |

🔴 **KOŞAN MUTANTLARIN PUSH DİSİPLİNİ — PAZARLIKSIZ:** üç mutant **ayrı dallara** yazılır
(`mutant/A13-M167` · `-M168` · `-M169`) ve `main`'e **asla** girmez. `ci.yml` tetiği yalnız
`workflow_dispatch` + `push: main` olduğu için bu dallara push **kendiliğinden CI koşturmaz**;
koşum `gh workflow run ci.yml --ref mutant/A13-M167` ile **elle** başlatılır.
⇒ Onur **tek** push yapar (`git push origin mutant/A13-M167 mutant/A13-M168 mutant/A13-M169`),
kota **üç koşum** kadar yenir, `main` hiç kirlenmez. **Dalların uzaktan silinmesi Onur'un
işidir** (kırmızı çizgi 4).

🔴 **`git restore` ile geri alma YASAK** (ORTAM.md, `core.autocrlf`): statik mutantlar
`rb` ikili yedek → bayt düzeyinde yama → kapı → `wb` geri yazım → `sha256` özdeşlik
ölçümü sırasıyla koşar. Referans koşucu: `KANIT/A11/_mutant_kosucu.py`.

## 6b. MUTANT BORCU

- KURAL: D-A13-4 | GEREKCE: bu bir YAPMAMA kararidir (backend verify zinciri bu dilimde CI'ya girmez) ve bir yapmama kararinin mutanti yoktur: "olmayan is" bozulamaz. Kapanis yolu: backend CI'ya girdigi dilimde (planlanan: 9) bu satir silinir ve gercek bir kapi+mutant yazilir. Borc BEYAN EDILMISTIR, gizlenmemistir.
🔴 **BURADAN BİR BORÇ ÇIKARILDI VE SEBEBİ YAZIYA GEÇİYOR:** ilk yazımda `D-A13-1` de borç
olarak beyan edilmişti; araç **`[S6] GEREKSIZ BORC: D-A13-1 — mutanti VAR, borc beyani
yaniltici`** ile ısırdı ve **haklıydı** — `M166` bu kuralı gerçekten hedefliyor. Beyan
yanlış yerdeydi: kastedilen şey *kuralın mutantsızlığı* değil, mutantın **kuralın yalnız bir
ayağını** ölçmesiydi. O beyan silinmedi, **§9/8'e taşındı**; sınır olarak yaşıyor, borç olarak
değil. *(Kapı susturulmadı, beyan doğru sınıfa taşındı.)*

---

## 7. KABUL KRİTERLERİ (SIRA PAZARLIKSIZ — kriterler birbirini ÖNCELER)

> 🔴 **`A11`'de ölçülmüş kusur:** kriter 7 ile 8 backend konusunda **çelişiyordu** ve bu ancak
> kabul koşumunda görüldü. Bu yüzden sıra burada **açıkça** yazılıdır ve her kriter,
> kendisinden öncekinin çıktısına dayanır. **Kriter atlanamaz, sırası değiştirilemez.**

1. **ÖNCE ARAÇ (K44-a):** `araclar\ci-kapisi.py` yazılır; **kendi altın kümesi** (`--altin-kume`,
   temizde susar / kirlide ısırır) **EXIT 0** verir. Bu geçmeden hiçbir kapı yeşil sayılmaz.
2. **iSKELET:** `flutter create --platforms=ios .` koşar; `src/client/ios/` üretilir.
   `flutter analyze --fatal-infos` **yerelde** 0 sorun (iskelet mevcut kodu kırmadı).
3. **HİJYEN:** `.gitignore` iOS artefakt yollarını kapsar; `project.pbxproj` `D-A13-2`'ye göre
   düzenlenir. **`A13/G30` (a·b·c·d) EXIT 0.**
4. **CI DOSYASI:** `.github/workflows/ci.yml` yazılır. **`A13/G28` (a·b) ve `A13/G29` (a) EXIT 0.**
5. **STATİK MUTANTLAR:** `M162`–`M166` **5/5 ISIRIR**; her birinden sonra dosyanın `sha256`'sı
   yedekle **özdeş** döner (ölçülür, varsayılmaz).
6. **COMMIT + PUSH:** builder commit eder (çift tırnaksız mesaj, `--no-optional-locks`);
   **push ONUR'undur.** Push reddedilirse §4'teki `workflow` yetkisi maddesi uygulanır.
7. **CI YEŞİL:** `A13/G27` (a·b·c) + `A13/G28` (c·d) + `A13/G29` (b·c·d) — hepsi **`gh` çıktısının
   ham metniyle** kanıtlanır. 🔴 Bu kriter **kriter 6 olmadan ölçülemez**; CI koşmadan
   "yeşil" yazan bir el, ölçmediğini beyan etmiş olur.
8. **KOŞAN MUTANTLAR:** `M167`–`M169` **3/3 ISIRIR** (§6'daki dal disipliniyle). 🔴 Bu kriter
   **kriter 7'den SONRA** gelir: kapının ısırdığını ölçmek için önce **ısırmadığı** hâlin
   yeşil olduğu ölçülmüş olmalıdır.
9. **KANIT:** `KANIT/A13/` altına ham çıktılar (§10 düzeni). Beyan yok, dosya var.

---

## 8. YASAKLAR

1. 🔴 **`flutter create` ile YENİ PROJE AÇMA** (`D-A13-1`). Yalnız `--platforms=ios .`
2. 🔴 **`git add -A` YASAK** (K55, ORTAM.md). Yol vererek `git add <yol>`; başka bir el
   çalışıyor olabilir. *(Oturum 51'de `git add KANIT/A12` builder'ın 24 ara çıktısını kör aldı —
   `git add <dizin>` de bir kör alımdır.)*
3. 🔴 **PUSH ETME.** Push Onur'undur; `main`'e mutant dalı birleştirme YASAK.
4. 🔴 **`DESIGN.md`'ye tek bayt yazma** (K46). Bu dilim tasarım sistemine dokunmaz.
5. 🔴 **ADR 0003'e dokunma** (K41, dondurulmuş).
6. 🔴 **Sır yazma:** `DEVELOPMENT_TEAM`, provisioning profili, Apple hesabı, API anahtarı —
   hiçbiri repoya girmez (kırmızı çizgi 1).
7. 🔴 **CI'ya `pull_request` tetiği ekleme** (`D-A13-3`, Onur kilitledi).
8. 🔴 **Kapı susturma:** `analysis_options.yaml`'a kural ekleyip `--fatal-infos`'u geçirmek,
   testi `skip` etmek, `continue-on-error: true` yazmak — üçü de aynı kusurun kılıklarıdır.
9. 🔴 **`git restore` ile mutant geri alma** (ORTAM.md, `core.autocrlf`).

---

## 9. BEYAN EDİLMİŞ SINIRLAR (gizlenmiş sınır kabul edilmez — §4 doktrini)

1. **Backend CI'da DEĞİL** (`D-A13-4`) ⇒ CI yeşili *"uygulama derleniyor ve testleri geçiyor"*
   demektir, *"sistem çalışıyor"* **demez**. ⑨'a borç (§6b).
2. **iOS yalnız DERLENİR, ÇALIŞTIRILMAZ.** Simülatörde açılış, ekran görüntüsü, davranış
   kanıtı **YOKTUR** — `flutter build ios --no-codesign` bir **derleme** kanıtıdır.
   *"iOS destekleniyor"* iddiası bu dilimle **kanıtlanmaz**, yalnız *"iOS hedefi derleniyor"*.
3. **İmzalama, TestFlight, App Store yolu ÖLÇÜLMEDİ** (`D-A13-5`) — Apple hesabı yok.
4. **Actions kotası ÖLÇÜLEMEDİ** (oturum 52: `gh` token'ında `user` yetkisi yok, faturalama
   ucu 404). Private repo'da ücretsiz kota **vardır** ama dakikası **[ÖLÇÜLMEDİ]**.
   Bilinen fiyat (GitHub, 2026): Linux **$0,006**/dk · macOS **$0,062**/dk (~10 kat).
5. **`workflow` token yetkisi [DOĞRULANMADI]** (§4). İlk push'ta ölçülecek.
6. **Web ve Windows hedefleri bu dilimde YOK.** `windows/`, `macos/`, `linux/` klasörleri
   diskte yoktur ve **üretilmez**; `web/` vardır ama CI'ya **girmez** (web test ayağı zaten
   `[DOĞRULANMADI]` — ORTAM.md: `flutter test --platform chrome` bu ortamda sonuç üretmiyor).
7. **`ci-kapisi.py` YAML'ı düz metin olarak tarar**, YAML ayrıştırıcısı değildir ⇒ aynı
   bayrağı yorum satırında taşıyan bir dosyayı yanlış-pozitif geçirebilir. Bu sınır aracın
   kendi çıktısında da **yazılıdır** ve altın kümesinde **yorum satırı vakası bulunur**.
8. **`D-A13-1`'in YANLIŞ-POZİTİF YÖNÜ ÖLÇÜLMÜYOR** *(§6b'den buraya taşındı — orada
   `[S6]` ile ısırıldı, çünkü kuralın mutantı `M166` ile gerçekten var).* `A13/G30/d` ve
   `M166`, kuralın *"artefakt commit edilmez"* ve *"mevcut dosyalar dokunulmadı"* ayaklarını
   ölçer; ama builder'ın **gerçekten yeni proje açıp `lib/` ve `test/`'i sildiği** hâli ölçen
   bir mutant **yoktur ve bilerek yazılmamıştır**: bedeli 500 testi ve tüm istemci kaynağını
   geçici olarak yok etmektir. ⇒ Bu kuralın ihlali **kapı tarafından değil, `git status`
   tarafından** yakalanır ve o yüzden kriter 3 ile 6 arasında **iki kez** ölçülür.

---

## 10. KANIT DÜZENİ (`KANIT/A13/`)

```
KANIT/A13/00-ortam.txt              flutter --version · git rev-parse HEAD · tarih (cihazdan ÖLÇÜLÜR)
KANIT/A13/01-arac-altin-kume.txt    ci-kapisi.py --altin-kume ham çıktı (kriter 1)
KANIT/A13/02-iskelet.txt            flutter create çıktısı + yerel analyze (kriter 2)
KANIT/A13/03-statik-kapilar.txt     A13/G28a-b · G29a · G30a-d ham çıktı (kriter 3-4)
KANIT/A13/04-MUTANT-statik/         M162–M166: her biri için önce/sonra + sha256 (kriter 5)
KANIT/A13/05-commit.txt             git log --oneline -1 + status --porcelain + index.lock (kriter 6)
KANIT/A13/06-ci-yesil/              gh run list/view ham JSON + log (kriter 7)
KANIT/A13/07-MUTANT-kosan/          M167–M169: dal adı + gh run çıktısı + conclusion (kriter 8)
KANIT/A13/08-OZET.md                madde madde PASS/FAIL + ölçülen sayılar
```

🔴 **Tarih `Get-Date -Format 'yyyy-MM-dd'` ile CİHAZDAN ölçülür** — Cowork bulutta **UTC**
koşuyor ve 00:00–03:00 arası bir gün geriye tarih yazar (ORTAM.md, oturum 39'da ısırdı).

---

## 11. ROL BÖLÜMÜ

- **Claude Code (builder):** §7'deki 1–6. kriterleri üretir; `ci-kapisi.py`'yi **yazar**.
- **Onur:** push eder (kriter 6), gerekirse `gh auth refresh -s workflow` koşar.
- **Cowork:** hiçbir artefaktı üreticisinin beyanıyla kabul etmez (K26); `gh` ve
  Desktop Commander ile **gerçek FS'ten ve gerçek Actions'tan** ölçer, kabul hükmünü yazar.
  🔴 **Cowork `ci-kapisi.py`'yi ONARAMAZ** (K34-f: onaran el, yazan elden ayrı olmalı) —
  kusur bulursa **raporlar**, düzeltmeyi builder yapar.

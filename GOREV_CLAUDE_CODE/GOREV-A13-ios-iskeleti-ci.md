# GOREV-A13 — iOS İSKELETİ + İLK CI BORU HATTI (dar dikey dilim)

> 🔒 **Durum: KABUL EDİLDİ — `K130`, Onur kilitledi 3 Ağu 2026 (oturum 53).**
> Kilit tarihçesi: `K126` (denetimsiz, oturum 52) → `K127` (kilit öncesi denetimle yenilendi,
> sha `BCD0AA81`) → 🔴 **oturum 53'te Onur KİLİDİ AÇTI**, çünkü **kabul öncesi bağımsız denetim
> (K127'nin kendi kuralı) spec'te ÖLÇÜMLE YANLIŞLANMIŞ iki gerekçe buldu**: `D-A13-3`'ün
> *"`--fatal-infos` taşıyıcıdır"* iddiası ve `§9/9`'un *"ölçülemedi"* beyanı. İkisi de gerçeğe
> çekildi, `§9`'a **11 yeni beyan edilmiş sınır** eklendi, spec **K130 ile yeniden kilitlendi**.
> Denetim kaydı: **`KANIT/A13/00-DENETIM-kabul-oncesi.md`** · kabul hükmü:
> **`KANIT/A13/10-COWORK-KABUL-HUKMU.md`**. Yeni kimlik `DURUM.md §9`'da **ölçülür**.
> *(Eski satır: "KİLİT ADAYI — Onur onaylamadan Claude Code'a verilmez." — dilim bitti, ölü beyan.)*
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
🔴 **`--fatal-infos` PAZARLIKSIZ — AMA GEREKÇESİ OTURUM 53'TE ÖLÇÜLEREK DÜZELTİLDİ.**
İlk yazım *"CI'da bayrağı düşürmek aynı kapıyı **sessizce gevşetmektir**"* diyordu.
**Bu, Flutter 3.44.6 için OLGUSAL OLARAK YANLIŞTIR.** Ham ölçüm (`flutter analyze --help`,
gerçek depo, oturum 53): `--[no-]fatal-infos … **(defaults to on)**`. Gerçek `main.dart`
üzerinde bayt düzeyinde ölçülen tablo — `KANIT/A13/07-MUTANT-kosan/40-BULGU-M167-esdeger-mutant.txt`:
`print('mutant')` **bayraksız EXIT 1** · `--fatal-infos` **EXIT 1** · `--no-fatal-infos` **EXIT 0**.
⇒ Bayrak bu sürümde **varsayılanı tekrar eden bir no-op'tur**; kapıyı gevşeten şey
`--no-fatal-infos`'tur. **Bayrak yine de yazılır**, çünkü değeri *bugünkü davranış* değil
**geleceğe karşı savunmadır**: varsayılan değişirse ya da başka bir araç sürümü koşarsa
niyet dosyada açıkça durur. **Varlığı statik `M162` ile korunur; çalışma anındaki
taşıyıcılığı hiçbir mutantla gösterilemez ve gösterilemezdi** (§9/11).
🔴 `pull_request` tetiği **YOK** (Onur kilitledi, oturum 52):
private repo kotası ölçülemedi ⇒ kendiliğinden koşan iş sayısı **asgaride** tutulur.

### `D-A13-4` — BACKEND `verify` ZİNCİRİ CI'YA GİRDİ 🟢 **(o69'da KAPANDI)**

Gerekçe (o zaman) **ölçülmüştü, tembellik değildi**: backend ayağı Postgres service
container + .NET 10 SDK + `verify.ps1`'in bash eşleniği demekti; bu, tek dilimde
**ikinci bir ürün** açardı. Radar `R4` o an **14 artefaktta SARI** ve `R1` *"tekrar eden
kusur sınıfı"* KIRMIZI'ydı. ⇒ ⑨'a bırakılmıştı.
🟢 **Kapanış (oturum 69, `IS-EMRI-o69-backend-CI-v3.md` / `K176`):** tasarım
`services:` container'ı DEĞİL, testlerin zaten kullandığı Testcontainers'ı esas aldı ⇒
ikinci bir ürün açmadı. `.github/workflows/ci.yml`'e `backend` işi eklendi (`ubuntu-latest`,
`services:` YOK, `./araclar/verify.ps1` `shell: pwsh` ile çağrılıyor) ve gerçek bir kapı +
mutant yazıldı: `araclar/ci-kapisi.py` `A13/G31/a`–`h` (8 statik ayak) + `S1`–`S4` (4
statik mutant, tavansız) + `M-o69-1`…`4` (4 koşan mutant, `verify.ps1` yerel koşumuyla).
Eski §6b satırı (borç beyanı) **silindi** — kapanış yolu kendi yazdığı yordamdı.

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
| a | `gh run list --workflow ci.yml --branch main --limit 5 --json conclusion,headSha,status,databaseId` | en son **`main`** koşumunun `conclusion` = `success` |
| b | aynı kaydın `headSha`'sı ile `git --no-optional-locks rev-parse main` | **eşit** — başka bir commit'in yeşili bu dilimi kanıtlamaz |
| c | `gh run view <databaseId> --log` içinde **iki işin de** adı geçer | `istemci` **ve** `ios` işleri koşmuş olmalı |

🔴 **`--branch main` PAZARLIKSIZ [oturum 52'de bağımsız denetim buldu].** Filtresiz `gh run list`
en son koşumu verir; kriter 8 mutant dallarını **kasten failure** koşturduğu için, kabul ölçümü
kriter 8'den sonra yapıldığında listenin başı **`M169`'un failure'ı** olur ⇒ **kriter 7 kabul anında
KIRMIZI olurdu, hâlbuki geçmişti.** Bu, `A11`'deki kriter 7↔8 çelişkisinin birebir tekrarıydı.
🔴 **Aynı sebeple `b` ayağı `HEAD` DEĞİL `main` ölçer:** builder mutant dallarındayken `HEAD`
mutant commit'idir ve `main`'in yeşil koşumuyla asla eşleşmez.
🔴 **"Actions sekmesinde yeşil gördüm" BİR ÖLÇÜM DEĞİLDİR.** Kanıt `gh` çıktısının
**ham metnidir** ve `KANIT/A13/` altına yazılır. Kural: `D-A13-3`

### G28 — İSTEMCİ İŞİ GERÇEKTEN DENETLİYOR (statik + koşan)

| ayak | ölçüm | geçme koşulu |
|---|---|---|
| a | `ci-kapisi.py`: `ci.yml`'de `analyze` adımı **`--fatal-infos` taşıyor** | taşımıyorsa KIRMIZI |
| b | `ci-kapisi.py`: **`flutter-version:` anahtarının değeri** tam olarak `3.44.6` | anahtar yoksa **veya** değeri `3.44.6` değilse KIRMIZI |
| c | CI logunda `flutter analyze` çıkışı | **0 sorun** |
| d | CI logunda `flutter test` özeti | `N/N` geçti; **N logdan okunur, spec'ten değil** |

🔴 **`b` ayağı `channel:` anahtarına BAKMAZ [oturum 52'de bağımsız denetim buldu].** İlk yazım
*"`stable`/`latest` geçmesin"* diyordu; oysa `subosito/flutter-action`'da `flutter-version: 3.44.6`
ile `channel: stable` **meşru ve yaygın** bir birlikteliktir ⇒ o kural **doğru dosyayı** kırmızı
yapardı. Ölçülen şey **pinin varlığı**dır, `stable` kelimesinin yokluğu değil.
Kurallar: `D-A13-3` · `D-A13-6` · `D-A13-7`

### G29 — iOS GERÇEKTEN DERLENDİ (bu dilimin taç ayağı)

| ayak | ölçüm | geçme koşulu |
|---|---|---|
| a | `ci-kapisi.py`: `ci.yml`'de iOS adımı **`--no-codesign`** taşıyor | taşımıyorsa KIRMIZI |
| b | macOS işinin logunda `Xcode build done.` dizgesi | **tam dizge** var. 🔴 **BU AYAK KÖRDÜR — oturum 53'te ÖLÇÜLDÜ, §9/12** |
| c | logda **`Built build/ios/iphoneos/Runner.app (`** ile başlayan satır + parantez içindeki boyut | satır **var** ve boyut **> 0** |
| d | macOS işinin `conclusion`'ı | `success` |

🔴 **`c` AYAĞI ÖNCE KÖRDÜ, ONARILDI [oturum 52'de bağımsız denetim buldu].** İlk yazım *"log içinde
`Runner.app` üretim satırı"* diyordu — **alt-dizge araması**. Xcode logu **başarısız** derlemede de
`Runner.app` içerir (ör. `ProcessInfoPlistFile …/Runner.app/Info.plist`, ki `M169`'un patlattığı
adımın ta kendisidir) ⇒ ayak bozukta da yeşil verirdi ve `M169` işi düşürdüğü için `G29/d` kırmızı
olup **kör ayağı MASKELERDİ**. Bu, `A11`/`M141` deseninin aynısıdır: mutantın ısırması, ısıran
ayağın **doğru ayak olduğunu** kanıtlamaz. Onarım: **tam satır pini + boyut**.
🔴 **YUKARIDAKİ GEREKÇENİN OLGUSAL AYAĞI OTURUM 53'TE ÖLÇÜLDÜ VE BU KOŞUMDA GERÇEKLEŞMEDİ.**
`M169`'un **başarısız** ios logunda `Runner.app` **alt-dizgesi 0**, `ProcessInfoPlistFile` **0**
(`30-BULGU-G29b-kor-ayak.txt`): `Info.plist` hatası derlemeyi `Runner.app` hiç anılmadan düşürüyor
⇒ **eski (alt-dizge) ayak da `M169`'da KIRMIZI verirdi.** Elde bulunan tüm örneklerde onarılmış ve
onarılmamış `c` **davranışsal olarak özdeştir**; onarımın değeri **hiçbir mutantla gösterilemedi**
(başka bir kırılma modunda — ör. geç link hatası — gösterilebilir, ama ölçülmedi). Onarım yine de
**korunur**: tam satır + boyut, alt-dizgeden **kesinlikle daha dar**dır. *Çürüdü demiyoruz,
**bu koşumda gözlenmedi** diyoruz.* ⇒ §9/14
🔴 **`--no-codesign` yüzünden `.ipa` ÜRETİLMEZ; kanıt `Runner.app`'tir.** `.ipa` arayan
bir kriter, bu dilimde **hiç geçemeyecek** bir kriterdir. Kurallar: `D-A13-5` · `D-A13-2`

### G30 — İSKELET DOĞRU YERDE VE REPO TEMİZ

| ayak | ölçüm | geçme koşulu |
|---|---|---|
| a | `ci-kapisi.py`: `project.pbxproj`'de **`Runner`** hedefinin **üç** yapılandırmasındaki `PRODUCT_BUNDLE_IDENTIFIER` | üçü de `com.momentum.client`; **`com.example` hiçbirinde geçmemeli** |
| b | `ci-kapisi.py`: `IPHONEOS_DEPLOYMENT_TARGET` | `13.0` |
| c | `ci-kapisi.py`: `.gitignore` iOS artefakt yollarını kapsıyor (`ios/Pods/`, `ios/.symlinks/`, `ios/Flutter/Flutter.framework`) — **varlık pozitif kontrolüyle** (ORTAM.md `findstr` dersi) | üçü de kapsanmalı |
| d | `git --no-optional-locks diff --stat <dilim-öncesi-sha>..HEAD -- src/client/lib src/client/test src/client/pubspec.yaml` | **çıktı BOŞ** (çıkış kodu **değil** — bu komut kirlide de 0 döner) |

🔴 **`a` AYAĞINDAKİ "HER" NİCELEYİCİSİ DARALTILDI [oturum 52, bağımsız denetim].** Flutter'ın iOS
şablonunda `RunnerTests` hedefinin **kendi** bundle id'si vardır (`…client.RunnerTests`); *"her
`PRODUCT_BUNDLE_IDENTIFIER` `com.momentum.client` olmalı"* kriteri ya **hiç geçemez** ya da
builder'ı Xcode projesini bozmaya iter. Ölçülen: **`Runner` hedefinin üç yapılandırması**.
🔴 **Beyan edilmiş sınır:** `RunnerTests`'in bundle id'si bu dilimde **ölçülmez** (şablon içeriği
`ios/` üretilmeden ölçülemedi ⇒ `[DOĞRULANMADI]`).

🔴 **`d` AYAĞI ÖNCE KÖRDÜ, ONARILDI [oturum 52, bağımsız denetim].** İlk yazım
`git status --porcelain`'in boş olmasını arıyordu; o komut *"dosyalar değişmedi"*yi değil
*"çalışma ağacı kirli değil"*i ölçer. `flutter create` `lib/main.dart`'ı yeniden üretir, builder
commit'ler, **kriter 6'daki ölçüm tertemiz döner** — oysa `lib/` değişmiştir. Üstelik §9/8
`D-A13-1`'in mutantsızlığını tam da bu ayağa yaslıyordu. **Ölçülmüş kanıt:** bu oturumda
`git status --porcelain` **EXIT 0** verdi ve çıktısı beş dosyayla **doluydu** ⇒ çıkış koduna bakan
bir el kirli ağacı yeşil sayar (ORTAM.md `findstr` dersinin birebir kardeşi).
Ayak (d) `D-A13-1`'in gerçek kapısıdır. Kurallar: `D-A13-1` · `D-A13-2`

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
| M163 | statik | `A13/G28` · `D-A13-6` | `ci.yml`'de `flutter-version:` değeri `3.44.6` → `3.43.0` yapılır | `ci-kapisi.py` **KIRMIZI** |
| M163b | statik | `A13/G28` · `D-A13-6` | `ci.yml`'de `channel: stable` **eklenir**, `flutter-version: 3.44.6` **korunur** | `ci-kapisi.py` **SUSMALI** — yanlış-pozitif kontrolü |
| M164 | statik | `A13/G29` · `D-A13-5` | `ci.yml`'deki iOS adımından `--no-codesign` silinir | `ci-kapisi.py` **KIRMIZI** |
| M165 | statik | `A13/G30` · `D-A13-2` | `project.pbxproj`'de `Runner`'ın bir yapılandırmasındaki `PRODUCT_BUNDLE_IDENTIFIER` `com.example.client`'a döndürülür | `ci-kapisi.py` **KIRMIZI** (tek geçiş bile yeter) |
| M166 | statik | `A13/G30` · `D-A13-1` | `.gitignore`'dan `ios/Pods/` satırı silinir | `ci-kapisi.py` **KIRMIZI** |
| M170 | statik | `A13/G27` | `KANIT/A13/06-ci-yesil/` altına kaydedilmiş `gh run list` JSON'ının `headSha`'sı tek karakter değiştirilir | `G27/b` ölçümü **KIRMIZI**. 🔴 **Hüküm oturum 53'te DARALTILDI:** ölçtüğü şey *"**kaydedilmiş kanıtın** karşılaştırma mantığı ayırt ediyor"*tur — *"kabul ölçümünün tamamı kör değildir"* **değil**; canlı `gh` yolunu ısırmaz (§9/13) |
| M167 | **koşan CI** | `A13/G28` | `lib/main.dart`'a **`print('mutant');`** eklenir (`avoid_print`, **INFO**) — dal: `mutant/A13-M167`. 🔴 Hedefi oturum 53'te **daraltıldı**: `D-A13-3` çıkarıldı (bayrak taşıyıcı değil, ölçüldü); ölçtüğü şey `G28/c`'nin **ayırt etme gücüdür** | `istemci` işi **failure** |
| M168 | **koşan CI** | `A13/G28` · `D-A13-7` | bir widget testinin beklentisi kasten ters çevrilir (dal: `mutant/A13-M168`) | `istemci` işi **failure** |
| M169 | **koşan CI** | `A13/G29` · `D-A13-1` | `ios/Runner/Info.plist` bozulur — kapatılmamış XML etiketi (dal: `mutant/A13-M169`) | `ios` işi **failure** |

🔴 **`M167` — ONARIM DENENDİ, ONARIM DA EŞDEĞER ÇIKTI [oturum 53'te ÖLÇÜLDÜ].**
Oturum 52'nin öyküsü şuydu: ilk yazım *"kullanılmayan `import`"* diyordu; `unused_import`
Dart'ta **WARNING**'dir ve `flutter analyze` zaten warning'lerde düşer ⇒ mutant
**`--fatal-infos` OLMADAN DA ısırırdı**. Onarım olarak `print()` (**INFO**) seçildi ve
*"yalnız `--fatal-infos` varsa işi düşürür"* denildi.
🔴 **ONARIM DA YANLIŞTI VE BU ÖLÇÜLDÜ** (`40-BULGU-M167-esdeger-mutant.txt`, gerçek depo):
Flutter 3.44.6'da `--fatal-infos` **varsayılan açıktır** ⇒ `print('mutant')` **bayraksız da**
`EXIT 1` verir. Yani WARNING→INFO değişimi hiçbir şeyi düzeltmedi: **her iki şiddet de
varsayılan ölümcüldür.** ⇒ `D-A13-3`'ün *"bayrak taşıyıcıdır"* iddiası **hiçbir koşan
mutantla ölçülemez** — çünkü bu sürümde **doğru değildir** (bkz. düzeltilmiş `D-A13-3`).
🟢 **`M167`'nin GERÇEKTE ÖLÇTÜĞÜ ŞEY, ve bu değerlidir:** *"CI'da `istemci` işinin analiz
adımı CANLIDIR ve INFO düzeyinde bir lint ihlalini yakalayıp işi düşürür"*. Kanıt
`0M167-log.txt`: `info • Don't invoke 'print' … lib/main.dart:34` + `istemci` **failure**,
`ios` **success** (izolasyon). Mutant **eşdeğer değildir, hedefi yanlış etiketlenmişti**.
🔴 **Bu ders K127'nin ikinci kanıtıdır:** kilit öncesi denetim bir kusuru bulabilir ama
**onarımın doğruluğunu ölçmezse** aynı sınıf ikinci kez geçer. Oturum 52 onarımı *okuyarak*
seçti (`analysis_options.yaml`), *koşarak* değil; oturum 53 `flutter analyze --help`'i
**koşturunca** gerçek çıktı. **Okunan onarım, ölçülmüş onarım değildir.**
🔴 **`M163b` bir YANLIŞ-POZİTİF mutantıdır:** kapının *"pin var mı"* ölçtüğünü, *"`stable` kelimesi
geçiyor mu"* ölçmediğini kanıtlar. Isırmaması **beklenen** sonuçtur.
🔴 **`M169`'un hedefi `D-A13-2` DEĞİL `D-A13-1`'e çevrildi:** `Info.plist`'i bozmak bundle id'yi ya
da deployment target'ı ölçmez; ölçtüğü şey **üretilen iskeletin gerçekten derlenebilir olduğudur**.

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

🟢 **`D-A13-4` borcu o69'da KAPANDI** (yukarıdaki karar başlığına bakınız) — bu satır
kendi yazdığı kapanış yordamı gereği **silindi**; yerine gerçek kapı + mutant geldi
(`ci-kapisi.py` `A13/G31/a`–`h` + `S1`–`S4` + `M-o69-1`…`4`). `K58`: sınırı kapatan el,
onu beyan eden kopyaları da kapatır.

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

1. **ÖNCE ARAÇ + DİLİM ÖNCESİ SHA (K44-a):** `araclar\ci-kapisi.py` yazılır; **kendi altın kümesi**
   (`--altin-kume`, temizde susar / kirlide ısırır) **EXIT 0** verir. Bu geçmeden hiçbir kapı yeşil
   sayılmaz. 🔴 **Aynı anda `git --no-optional-locks rev-parse HEAD` çıktısı `KANIT/A13/00-ortam.txt`'ye
   *dilim öncesi sha* olarak yazılır** — `A13/G30/d` bunu ister; sonradan hatırlanamaz.
   🔴 **Altın kümenin YORUM SATIRI vakası ZORUNLU ve beklenen hükmü BURADA yazılıdır:** `ci.yml`'de
   aranan bayrak **yalnız bir `#` yorum satırında** geçiyorsa kapı **KIRMIZI vermeli** (§9/7'nin
   düz-metin sınırı bu vakayla pinlenir). Bu satır olmadan builder aracı kendi lehine yazabilir ve
   **altın küme kendini onaylar**.
2. **iSKELET:** `flutter create --platforms=ios .` koşar; `src/client/ios/` üretilir.
   `flutter analyze --fatal-infos` **yerelde** 0 sorun (iskelet mevcut kodu kırmadı).
3. **HİJYEN:** `.gitignore` iOS artefakt yollarını kapsar; `project.pbxproj` `D-A13-2`'ye göre
   düzenlenir. **`A13/G30` a·b·c ⇒ `ci-kapisi.py` EXIT 0; ayak d ⇒ komutun ÇIKTISI BOŞ.**
   🔴 **İki farklı ölçü tek koşulda toplanmaz:** a·b·c bir *çıkış kodu*, d bir *boş çıktı* ister.
4. **CI DOSYASI:** `.github/workflows/ci.yml` yazılır. **`A13/G28` (a·b) ve `A13/G29` (a) EXIT 0.**
5. **STATİK MUTANTLAR:** `M162`–`M166` **5/5 ISIRIR** **ve** `M163b` **SUSAR** (yanlış-pozitif
   kontrolü — ısırırsa kapı yanlış şeyi ölçüyor demektir). Her mutanttan sonra dosyanın `sha256`'sı
   yedekle **özdeş** döner (ölçülür, varsayılmaz).
6. **COMMIT + PUSH (`main`):** builder commit eder (çift tırnaksız mesaj, `--no-optional-locks`);
   **push ONUR'undur.** Push reddedilirse §4'teki `workflow` yetkisi maddesi uygulanır.
7. **CI YEŞİL (`main` DALINDA):** `A13/G27` (a·b·c) + `A13/G28` (c·d) + `A13/G29` (b·c·d) — hepsi
   **`gh` çıktısının ham metniyle** kanıtlanır ve ham JSON `KANIT/A13/06-ci-yesil/` altına yazılır.
   🔴 Bu kriter **kriter 6 olmadan ölçülemez**; CI koşmadan "yeşil" yazan bir el, ölçmediğini beyan
   etmiş olur.
8. **KOŞAN MUTANTLAR + KABUL ÖLÇÜMÜNÜN KENDİ MUTANTI:** builder üç mutant dalını **yerelde** açar
   (`mutant/A13-M167` · `-M168` · `-M169`) → 🔴 **ONUR TEK PUSH yapar:**
   `git push origin mutant/A13-M167 mutant/A13-M168 mutant/A13-M169` → her dal için
   `gh workflow run ci.yml --ref <dal>` → `M167`–`M169` **3/3 ISIRIR**. Ardından `M170` kriter 7'nin
   kaydedilmiş JSON'ı üzerinde koşulur ve **`G27/b`'nin kör olmadığını** kanıtlar.
   🔴 Bu kriter **kriter 7'den SONRA** gelir: kapının ısırdığını ölçmek için önce **ısırmadığı**
   hâlin yeşil olduğu ölçülmüş olmalıdır. 🔴 **`A13/G27` bundan sonra da ölçülürse `--branch main`
   ile ölçülür** — mutant dallarının failure'ı `main`'in yeşilini geçersiz kılmaz.
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

1. 🟢 **Backend CI'ya GİRDİ (`D-A13-4` o69'da KAPANDI)** — `.github/workflows/ci.yml`'e
   `backend` işi eklendi (`ubuntu-latest`, `services:` YOK, `./araclar/verify.ps1`); CI
   yeşili artık backend `verify.ps1` zincirinin (build+test+CVE) de geçtiği anlamına gelir.
   Sınır yine de kalır: bu *"uygulama derleniyor ve testleri geçiyor"* demektir,
   *"cihazda/production'da çalışıyor"* **demez** — çevrimdışı senkron/SignalR/gerçek cihaz
   ayağı bu turun kapsamı DIŞINDADIR, `B-O63-2` ve `B-W3b-6`–`10` **AÇIK** kalır.
2. **iOS yalnız DERLENİR, ÇALIŞTIRILMAZ.** Simülatörde açılış, ekran görüntüsü, davranış
   kanıtı **YOKTUR** — `flutter build ios --no-codesign` bir **derleme** kanıtıdır.
   *"iOS destekleniyor"* iddiası bu dilimle **kanıtlanmaz**, yalnız *"iOS hedefi derleniyor"*.
3. **İmzalama, TestFlight, App Store yolu ÖLÇÜLMEDİ** (`D-A13-5`) — Apple hesabı yok.
4. **Actions kotası ÖLÇÜLEMEDİ** (oturum 52: `gh` token'ında `user` yetkisi yok, faturalama
   ucu 404). Private repo'da ücretsiz kota **vardır** ama dakikası **[ÖLÇÜLMEDİ]**.
   Bilinen fiyat (GitHub, 2026): Linux **$0,006**/dk · macOS **$0,062**/dk (~10 kat).
5. 🟢 **KAPANDI [oturum 53]. `workflow` token yetkisi ÖLÇÜLDÜ.** Push `gh`'nin değil **GCM**'in
   token'ını kullanıyor ve onda yetki **vardı**: `X-OAuth-Scopes = 'gist, repo, workflow'`
   (token hiçbir yere yazılmadı, yalnız kapsam başlığı okundu). Push **reddedilmedi**.
   §4'ün önerdiği çare (`gh auth refresh`) **yanlış token'ı** hedefliyordu: `gh` token'ında
   (`gist, read:org, repo`) `workflow` **yok** ve buna rağmen `gh workflow run` **çalıştı**
   ⇒ dispatch için `repo` yetiyor. Kanıt: `claude/oturum-53-*` + `06-ci-yesil/`.
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
   geçici olarak yok etmektir. ⇒ Bu kuralın ihlali **`A13/G30/d`'nin `git diff --stat` ölçümüyle**
   yakalanır ve o ölçüm **kriter 3'te BİR KEZ** koşulur. 🔴 *İlk yazım burada "kriter 3 ile 6
   arasında iki kez ölçülür" diyordu — §7 bunu bir kez zorluyordu ⇒ **beyan ile kriter
   çelişiyordu**, oturum 52'de bağımsız denetim buldu ve beyan gerçeğe çekildi.*
9. **`RunnerTests` HEDEFİNİN BUNDLE ID'Sİ ÖLÇÜLMEZ** (`A13/G30/a` yalnız `Runner`'ı ölçer).
   🔴 **GEREKÇE OTURUM 53'TE DÜZELTİLDİ.** Eski metin *"şablon içeriği `ios/` üretilmeden
   ölçülemedi ⇒ `[DOĞRULANMADI]`"* diyordu; `ios/` üretildikten sonra bağımsız denetçi **ölçtü**:
   `PRODUCT_BUNDLE_IDENTIFIER = com.momentum.client.RunnerTests` (3 yapılandırma), `com.example`
   **0 geçiş**. Doğru ifade: **ölçülemez DEĞİL, KAPSAM DIŞI BIRAKILDI** — `G30/a` bilerek yalnız
   `Runner`'ı ölçer (§5/G30'un daraltma gerekçesi). *Ölçülemediğini söyleyen bir beyan, ölçülünce
   düzeltilir; yoksa `bayat-iddia` olur.*
10. 🟢 **KAPANDI [oturum 53]. `ci-kapisi.py` YAZILDI** (418 satır); altın kümesi hem builder'ın
   hem **bağımsız denetçinin** koşumunda **13/13, EXIT 0** ve yorum-satırı vakası (vaka 3)
   kümede **var** ⇒ kriter 1'in pazarlıksız şartı iki ayrı elde karşılandı.

---

### 🔴 OTURUM 53'TE KABUL ÖNCESİ BAĞIMSIZ DENETİMİN (K127) DOĞURDUĞU YENİ SINIRLAR

> Üç bağımsız denetçi + Cowork'ün kendi doğrulaması. Tam kayıt: **`KANIT/A13/00-DENETIM-kabul-oncesi.md`**.
> Hiçbiri yanlış-YEŞİL üretmiyor; hepsi **fazlalık/aşırı-genel iddia** sınıfındadır.

11. **`--fatal-infos` BU SÜRÜMDE TAŞIYICI DEĞİLDİR** ve bu **hiçbir mutantla gösterilemez**
   (`D-A13-3`, §6/`M167`). Flutter 3.44.6'da varsayılan **açık**; gevşeten bayrak
   `--no-fatal-infos`'tur. Bayrağın **dosyadaki varlığı** statik `M162` ile korunur.
   Koşan mutant tavanı **3/3 dolu** ⇒ dördüncü mutant açılamaz; zaten ölçülecek bir şey yok.
12. 🔴 **`A13/G29/b` KÖR AYAKTIR.** `Xcode build done.` tam dizgesi `main` (ios **success**,
   91.9s) ve `M169` (ios **failure**, 43.7s) loglarının **ikisinde de** geçiyor ⇒ ayırt etme
   gücü **sıfır**. `G29`'u ısırtan yalnız **`c` ve `d`**'dir; ikisi de `M169` ile kanıtlı,
   dolayısıyla **yanlış-YEŞİL yoktur**. Ayak **bilerek bırakıldı** (silmek ölçüm tarihçesini
   kırar); onarımı/kaldırılması **builder'ın işidir (K34-f)** ⇒ borç `B-O53-1`.
13. **`M170` GERÇEK ÖLÇÜM YOLUNU DEĞİL KAYDEDİLMİŞ KANITI ISIRIR** (§6). Kriter 7 betiği
   `G27/b`'yi **canlı `gh` stdout'undan** ölçer; kaydedilen JSON yan-üründür. ⇒ *"kabul
   ölçümünün tamamı kör değildir"* **iddia edilemez**; ölçülen şey dardır.
14. **`G29/c` ONARIMININ DEĞERİ HİÇBİR MUTANTLA GÖSTERİLEMEDİ** (§5/G29). `M169`'da eski ve
   yeni ayak davranışsal olarak özdeş çıktı. Onarım korunur (daha dar), değeri **ölçülmedi**.
15. **MUTANTSIZ AYAKLAR:** `G27/a` · `G27/c` · `G30/b`. Üçü de ölçüldü ama hiçbirinin kendi
   mutantı yok ⇒ körlükleri **bilinmiyor**. Borç `B-O53-2`.
16. **KRİTER 7'NİN DİNAMİK AYAKLARININ KORUNMUŞ ARACI YOKTUR (K44-a).** `ci-kapisi.py` yalnız
   **statik** ayakları ölçer; `G27 a·b·c` + `G28 c·d` + `G29 b·c·d` saklanmamış betiklerle
   ölçüldü, altın kümesi yok. 🔴 **Kaçan tek kör ayağın (`G29/b`) tam da araçsız kümede
   olması tesadüf değildir.** Borç `B-O53-3`.
17. **`G28/d`'nin `N/N` BİÇİMİ LOGDA LAFZEN YOKTUR.** CI reporter'ı `🎉 500 tests passed.`
   basar, payda yazmaz; hüküm *"`failed` satırı 0"* kuralıyla verildi. 🔴 Gevşek
   `tests passed` arayan bir kapı `M168`'in `499 tests passed, 1 failed.` satırını **yeşil
   sayardı** ⇒ dizge pinlenmelidir. Borç `B-O53-4`.
18. **YASAK 8 (kapı susturma) HİÇBİR KAPIYLA ÖLÇÜLMÜYOR** — `G30/d`'nin yol listesi
   `analysis_options.yaml`'ı kapsamaz. *Fiilî ihlal yok* (ölçüldü: dosya bu dilimde değişmedi,
   `avoid_print` devre dışı değil), ama yasağın kapısı **yoktur**.
19. **AKSİYONLAR SHA'YA PİNLİ DEĞİL** (`actions/checkout@v4`, `subosito/flutter-action@v2`)
   ⇒ bu yeşil **inşa gereği bit-bazında tekrarlanabilir değildir**. `D-A13-6` Flutter'ı pinler,
   aksiyonları **pinlemez**. Borç `B-O53-5`.
20. **§9/9 DÜZELTİLDİ:** eski gerekçe *"şablon içeriği `ios/` üretilmeden ölçülemedi"* idi;
   `ios/` artık var ve ölçüldü — `RunnerTests` bundle id = `com.momentum.client.RunnerTests`,
   `com.example` **0 geçiş**. Doğru ifade: **ölçülemez değil, KAPSAM DIŞI BIRAKILDI.**
21. **§9/4 KISMEN KAPANDI:** Timing API ⇒ dört koşumun da **billable MACOS 0 ms / UBUNTU 0 ms**
   (ücretsiz kota içinde kalındı). **Kalan kontenjan hâlâ `[ÖLÇÜLMEDİ]`.**

---

## 10. KANIT DÜZENİ (`KANIT/A13/`)

```
KANIT/A13/00-ortam.txt              flutter --version · DİLİM ÖNCESİ SHA (rev-parse HEAD) · tarih (cihazdan ÖLÇÜLÜR)
KANIT/A13/01-arac-altin-kume.txt    ci-kapisi.py --altin-kume ham çıktı, yorum-satırı vakası DÂHİL (kriter 1)
KANIT/A13/02-iskelet.txt            flutter create çıktısı + yerel analyze (kriter 2)
KANIT/A13/03-statik-kapilar.txt     A13/G28a-b · G29a · G30a-d ham çıktı, d'nin ÇIKTISI dâhil (kriter 3-4)
KANIT/A13/04-MUTANT-statik/         M162–M166 (ısırdı) + M163b (sustu): önce/sonra + sha256 (kriter 5)
KANIT/A13/05-commit.txt             git log --oneline -1 + status --porcelain + index.lock (kriter 6)
KANIT/A13/06-ci-yesil/              gh run list --branch main / view ham JSON + log (kriter 7)
KANIT/A13/07-MUTANT-kosan/          M167–M169: dal adı + gh run çıktısı + conclusion; M170 (kriter 8)
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

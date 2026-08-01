# GOREV-A9 (v3) — `CakismaCozumSayfasi` metin kaybı + `ellipsis ⇒ maxLines` **SINIF KAPISI**

> **Kilit:** Onur, oturum 43 (1 Ağu 2026) — kapsam **TAM**, sayı **ÖLÇÜMLE**, görünürlük **public**, sınıf kuralı **G5'e**.
> **Builder:** Claude Code. **Denetleyen:** Cowork (K26). **Denetim turu: 1 (K53/1 — tavan doldu, ikinci tur AÇILMAZ).**
> 🔴 **BUILDER BU BELGEYE TEK BAYT YAZMAZ.** Bütün ölçüm sonuçları `KANIT/A9/09-HUKUM.md`'ye gider;
> `§6`/`§6b`/`§8` güncellemesi **Cowork'ün** kapanış işidir (rol bölümü + K26 + `tek-kopya-kapisi.py` `kilitli` sınıfı).

---

## 0. v1'İN ÖLDÜĞÜ YER (ölçülmüş — bu bölüm silinmez, sonraki eli korur)

v1 (oturum 43, aynı gün) bağımsız denetimde **15 bloker** aldı. Üçü mimariyi değiştirdi:

| # | v1'in yaptığı | ölçüm | sonuç |
|---|---|---|---|
| 1 | `_y6`'yı ölçüm ızgarasına sokmayı **dal seçimine** bağladı, gerekçe *"`NavigationToolbar` genişlik paylaşımı"* | `app_bar.dart:1091-1097` — `MediaQuery.withClampedTextScaling(maxScaleFactor: _kMaxTitleTextScaleFactor)`, **`= 1.34`** (`app_bar.dart:44`) | 🔴 **Gerekçe YANLIŞTI.** Genişlik **kararlıdır** (`navigation_toolbar.dart:131-135`; bu sayfada leading/actions yok ⇒ `g − 32`). Asıl engel **ölçek kelepçesi**: ızgaranın 1.5x/2.0x ayakları başlığa **ULAŞMAZ**, `_pompalaVeDogrula`'nın koşulsuz pozitif kontrolü ısırır ⇒ **A dalı imkânsız** |
| 2 | Y6'ya da *"en küçük N"* kuralını uyguladı | 320 dp × kelepçeli 1.34 ⇒ `titleLarge` 22 px → 29,5 px; kullanılabilir 288 px; *"Çakışma var"* ≈ 324-327 px ⇒ **N = 2** yazılmak zorunda kalırdı | 🔴 2 satır ≈ **75 px**, toolbar **64 px**. `_RenderAppBarTitleBox` (`app_bar.dart:2233-2237`) çocuğa `maxHeight: infinity` verip `constraints.constrain` + `ClipRect` ile **sessizce keser** — `RenderFlex` değildir, **istisna ATMAZ** ⇒ `A1`/`A3`/`A4` üçü de **kör**. v1, kapatmaya çalıştığı kusuru **üretecekti** |
| 3 | 6 mutant yazdı, §6b'ye iki borç koydu, `iddia-kapisi.py`'yi spec yolu olmadan çağırdı | A8 §6: `iddia-kapisi.py` `LISTE_ESIGI = 8`; A8 kriter 11 aracı **spec yoluyla** çağırıyor (v1'i dizinle çağırmak **EXIT 2** vermişti) | 🔴 A8'in **ölçerek kapattığı** dairesel-kanıt kapısı yeniden açılıyordu |

**Ders (yazıya geçti):** *bir ayağı ızgaraya sokmadan önce, ızgaranın o ayağa ULAŞTIĞI ölçülür.* A8 v1 bu
sınıftan ölmüştü (*"harness ızgarayı hedefe hiç ulaştırmıyordu"*); A9 v1 aynı sınıfı `AppBar`'ın kendi
`MediaQuery` sınırıyla geri getirdi.

---

## 1. AMAÇ VE ÖLÇÜLMÜŞ GEREKÇE

`GOREV-A8` (K90/K91) `lib/sunum`'daki **beş** ekranı kapattı ve `cakisma_rozeti.dart`'ı **açıkça** dışarıda
bıraktı. Bugün (1 Ağu 2026, oturum 43) ölçüldü ve **üç bağımsız denetçi** tarafından doğrulandı:

| ölçüm | sonuç |
|---|---|
| `cakisma_rozeti.dart` | **2.747 b** · **2 `Text`** · **2 `TextOverflow.ellipsis`** · **0 `maxLines`** |
| `flutter test` (A8 kapanışında, K91) | **428/428 YEŞİL** |
| ⇒ hüküm | **Yeşil tahta, canlı kusur.** Bu iki düğümü **hiçbir kapı ölçmüyor.** |

🔴 **Teorik değil, canlı:** gövde metni tam bir cümledir — `Metinler.cakismaVar` =
**"Bu görev başka bir cihazda da değişti."** (38 karakter). Ölçülmüş mekanizma
(`KANIT/A7/02-COZUM-OLCUM.txt` varyant A): `ellipsis` + `maxLines` yok ⇒ metin **fiilen tek satıra iner,
fazlası SESSİZCE atılır**. Kullanıcının çakışma rozetine dokununca gördüğü **tek açıklama** budur.

**İki amaç, ikincisi daha kalıcı:**

1. **Kaybı kapat** — iki `Text` düğümüne açık `maxLines`; `ellipsis` **kalır**.
2. 🔴 **SINIFI kapat** — kural dosyaya değil **sınıfa** bağlanır: `lib/sunum` + `lib/vitrin` altında
   `ellipsis` taşıyan **her** `Text`, `maxLines` de taşımak zorunda olur. Böylece ileride gelecek çakışma
   çözüm ekranı (SS2) da otomatik kapsanır ve bu emek, yer tutucu değiştirildiğinde boşa gitmez.

🔴 **SS2'nin SAHİBİ YOKTUR — bu bir açık borçtur (ölçüldü).** `cakisma_rozeti.dart:69` yorumu ve
`DURUM.md` §4/⑤ SS2'yi *"K42-d adım 3"*e atıyor; ama `DURUM.md` §3 **slice-3b→3e + R9/R10'un BİTTİĞİNİ**
kaydediyor — yani K42-d'nin 3. **ve** 4. adımı tamamlandı ve SS2'yi getirmedi. Atıf **bayattır ve dairesel
ertelemedir**. Bu görev SS2'yi planlamaz; borcu **adıyla beyan eder** (§8/S10) ve `:69` yorumunu düzeltir.

---

## 2. KAPSAM

**İÇİNDE (beş dosya + kanıt):**

| yol | ne olur |
|---|---|
| `src/client/lib/sunum/cakisma_rozeti.dart` | görünürlük + `{super.key}` + iki sabit + iki `maxLines` + `:69` yorum düzeltmesi |
| `src/client/test/a11y_statik_tasma_test.dart` | **G5'e `R2`**; gövde toplayıcı ortak yardımcıya çıkarılır |
| `src/client/test/g16_metin_kaybi_kapisi_test.dart` | `_y6` + `_y7` + `_a3Kapsami` + **kod içi kapsam koruması** |
| `src/client/test/_a9_probe_test.dart` | 🔴 **geçici ölçüm aracı** — kriter 3'ten sonra **0 `test(` kalacak biçimde BOŞALTILIR** (`rm` bu ortamda **izinli değil**, `BORCLAR.md`:121; A8 iki ölü husk üretmişti). Kriter 4'ün sayısı bu boşaltmayı **varsayar**, kriter 7 yeniden ölçer |
| `KANIT/A9/…` | §9 |

🔴 **`a11y_statik_tasma_test.dart` A8 §2'de `K34-f` gerekçesiyle AÇIKÇA DIŞLANMIŞTI** (*"değiştirilmez"*).
A9 o dışlamayı **adıyla anarak** kaldırıyor. Gerekçe: K34-f *"bir aracı **onaran** el, onu **yazan** elden
ayrı olmalı"* der — burada araç **onarılmıyor**, ölçülmüş bir **boşluğu** kapatan ikinci bir kural
ekleniyor ve o kuralın kendi mutantları var (M98, M102, M103, M105). Refactor riski **ölçülür**:
kriter 1'de `R1`'in refactor **öncesi** ham çıktısı alınır, kriter 5'te **karşılaştırılır**.

**DIŞINDA (tek bayt yazılmaz):** SS2 · kaydırma (A8/S5 kilidi **açılmaz**) · `DESIGN.md` (K46) ·
`DURUM.md` / `PROJE_HAFIZA.md` / `BORCLAR.md` (**Cowork'ün işi**) · G5'in tarama **kapsamı**
(bugünkü iki dizin neyse odur) · `lib/` altındaki başka hiçbir dosya.

🔴 **TEK İSTİSNA — MUTANT SIRASINDA GEÇİCİ DOKUNMA:** M104 `senkron_rozeti.dart`'a, M102 `lib/sunum`'a geçici bir dosyaya dokunur. Bu dokunuşlar **mutant koşumu içindedir, geri alınır** ve kriter 13'ün diff'i **temiz** olmak zorundadır. M104 birden çok kapıyı (G5/R1 + rozet kapıları) kırmızıya çevirebilir; **fazladan kırmızı DUR DEĞİLDİR**, `M104.txt` kırmızıların **hepsini** listeler.

---

## 3. ORTAM — kim kaldırır (K80)

🔴 **Bu dilim cihaz ya da canlı sunucu kanıtı İSTEMEZ** ve bu bir ihmal değil, **denetimde doğrulanmış**
bir gerçektir: bütün kapılar `flutter test` altında koşar (widget + `@TestOn('vm')` kaynak taraması);
`CakismaCozumSayfasi` **doğrudan** pompalandığı için `Navigator.push` ve `SemanticsService` yolları
devrede değildir. **Docker, backend ve emülatör GEREKMEZ; başlatılmaz, çalıştığı da beyan edilmez.**

**Zorunlu ortam kalkanları — her koşumda:**

- `flutter` bu makinede **`.bat`** ⇒ **tam yol** `C:\src\flutter\bin\flutter.bat` (K86) — `analyze` dâhil **her** çağrıda
- `flutter test` Desktop Commander kabuğunda `%PROGRAMFILES(X86)%` bulamaz ⇒ alt sürece
  `PROGRAMFILES(X86)=C:\Program Files (x86)` **enjekte edilir**
- Python için `PYTHONIOENCODING=utf-8` (stdout cp1254; `⇒` kabuğu öldürür)
- 🔴 **EXIT kodu okunacak HER yerde `cmd /v:on /c "... & echo !ERRORLEVEL!"`** — `%ERRORLEVEL%`
  **KÖRDÜR, SAHTE `EXIT=0` VERİR** (ölçüldü, oturum 33: üç kapı sahte 0 bildirdi). Bu görevin **altı**
  kriteri (4, 7, 8, 9, 11, 12) doğrudan EXIT koduna dayanır.
- `git`'in **her** çağrısında `--no-optional-locks`; `git add -A` **YASAK**, yol belirtilir (K55);
  commit mesajında **çift tırnak yok** (K86'da yeniden ısırdı); **PUSH ONUR'DADIR**
- Tarih **cihazdan** ölçülür (`Get-Date`), ortam beyanından okunmaz

---

## 4. ÜRÜN DEĞİŞİKLİĞİ — TASARIM KİLİDİ (Onur, oturum 43)

**4.1 Görünürlük.** `_CakismaCozumSayfasi` → **`CakismaCozumSayfasi`**, kurucu
**`const CakismaCozumSayfasi({super.key});`**.

- **Ölçülebilir zorunlu gerekçe:** `g16_metin_kaybi_kapisi_test.dart` bu dosyayı **hiç import etmiyor**;
  `_y6`/`_y7`'nin `olustur`'u sınıfı `package:` üzerinden kurmak zorunda ⇒ **private sınıf test edilemez.**
  *(v1 bu gerekçeyi "test edilebilirlik değil" diye reddedip ölçülemez bir stil iddiası yazmıştı —
  denetim bulgusu; ölçülebilir sebep ölçülemez sebebe tercih edilir.)* İkincil not: route hedefleri
  Flutter'da zaten public'tir.
- 🔴 **`{super.key}` PAZARLIKSIZ:** `use_key_in_widget_constructors` linti **yalnız public sınıfta** ısırır
  (`if (classElement.isPrivate) return;`). Alt çizgi kalkınca `key` almayan kurucu **info** üretir ve
  kriter 8 `--fatal-infos` ile **0 bulgu** ister ⇒ eklenmezse build kırmızıdır. `:64`'teki
  `const CakismaCozumSayfasi()` çağrısı etkilenmez.

**4.2 İki adlandırılmış sabit** — A8 deseni birebir (sınıf içi `static const int`, adı `k…MaxSatir`,
yorumunda **ölçüm dosyasına atıf**):

| kod | sabit | yer | değer |
|---|---|---|---|
| **Y6** | `kCakismaBasligiMaxSatir` | `AppBar.title` — `Metinler.duyuruCakismaVar` (*"Çakışma var"*, 11 krk) | 🔒 **1 — SABİT, ÖLÇÜLMEZ** (gerekçe §8/S1) |
| **Y7** | `kCakismaGovdesiMaxSatir` | gövde — `Metinler.cakismaVar` (38 krk) | **ÖLÇÜLÜR** (kriter 3); değeri bu belgeye **yazılmaz** |

🔴 **Y6 neden ölçülmez — ölçülemezliği ÖLÇÜLDÜ:** `AppBar` başlığı `1.34`'e kelepçelendiği için ızgaranın
1.5x/2.0x ayakları oraya **ulaşmıyor**; *"en küçük N"* kuralı uygulansa **N = 2** çıkar ve 2 satır 64 dp
toolbar'da **sessizce** kesilir (§0/2). Y6 böylece A8'in **`Y1` sınıfına** girer: başlıkta kayıp
**KABUL EDİLİR**, ama `ellipsis` ile **GÖRÜNÜR** olur. *"Ölç ya da `[DOĞRULANMADI]` yaz"* burada
**ölçülemez olduğunu ölçmek** biçiminde uygulanmıştır.

**4.3 `overflow: TextOverflow.ellipsis` HER İKİSİNDE DE KALIR** (M99 ısırtır) ve `:69` yorumundaki
*"K42-d adım 3'te gelir"* atfı **düzeltilir**: *"gerçek çakışma çözümü (SS2) AYRI bir dilimdir; K42-d'nin
dört adımı tamamlandı ve SS2'yi getirmedi — sahibi henüz yok."*

**4.4** 🔴 **`kCakismaGovdesiMaxSatir`'ın DEĞERİ bu belgeye yazılmaz** (Y6'nınki §4.2'de sabittir).
Elle seçilmiş bir gövde sayısıyla gelen build **REDDEDİLİR**. *(Bu kural yalnız `maxLines` sabitleri
içindir; §5'in test sayıları ve §1'in ölçümleri belgede **bilinçli** durur — `iddia-kapisi.py I1`
onları ölçer.)*

---

## 5. KAPILAR

### G5 — (GENİŞLETME) `lib/sunum` + `lib/vitrin` STATİK SINIF KAPISI

| kural | ne ölçer | mutant |
|---|---|---|
| **R1** *(mevcut, değişmez)* | `lib/sunum` + `lib/vitrin` altındaki **her** `Text(` / `Text.rich(` gövdesi `TextOverflow.ellipsis` taşır | M99 · M104 |
| **R2** *(YENİ)* | `ellipsis` taşıyan her gövde **`maxLines:` de taşır** | M98 · M102 · M103 |
| **R3** *(YENİ — araç kendini kanıtlar)* | gövde toplayıcı **çok satırlı** gövdeyi gerçekten toplar ve **yorumları ayıklar** | M105 · M107 |
| **R4** *(YENİ — POZİTİF KONTROL, altın küme mantığı)* | tarayıcının bulduğu **`Text(` aday sayısı = 8** (ölçüldü: `bos_durum` 1 · `cakisma_rozeti` 2 · `gorev_satiri` 1 · `hata_durumu` 2 · `senkron_rozeti` 1 · `yukleme_durumu` 1) | M108 |

- 🔴 **Gövde toplayıcı YENİDEN KULLANILIR, KOPYALANMAZ** — mevcut parantez-derinliği toplayıcısı aynı
  dosyada ortak bir yardımcıya çıkarılır, `R1` ve `R2` onu çağırır. *(`kanonik-kopya` bu projede beş kez ısırdı.)*
- 🔴 **YORUM AYIKLAMA PAZARLIKSIZ:** toplanan gövdeden `//`'dan sonrası **atılır** — aynı dosyadaki F6
  testi (`:107-110`) bunu **zaten yapıyor**, aynı yardımcı kullanılır. Aksi hâlde gövdedeki bir yorum
  (*"// maxLines'ı kaldırmak…"*) `R2`'yi yeşil tutar ve **M98 kör kalır**.
- 🔴 **ÖLÇÜM `contains` DEĞİL, REGEX:** `RegExp(r'\bmaxLines\s*:')` ve `RegExp(r'TextOverflow\.ellipsis')`.
- `R2` **ayrı bir `test(...)`** olarak yazılır ⇒ süite **+1 test**. `reason`'u her ihlali
  **`<dosya>:<satır>: <satır metni>`** biçiminde listeler — `R1` ile **birebir aynı biçim**.
- **Bugün ısıracağı yerler ÖLÇÜLDÜ (üç bağımsız simülasyon, oturum 43):** tam **iki** —
  `cakisma_rozeti.dart:77` ve `:82`. Başka hiçbir yer; `R1` ihlali bugün **0**.
  `lib/vitrin/durum_vitrini.dart`'ta **0 `Text`** ⇒ yan etki **yok**.
- 🔴 **`R4` PAZARLIKSIZ — `R1`'in refactor karşılaştırması KENDİ BAŞINA HİÇBİR ŞEY ÖLÇMEZ (denetimde
  çürütüldü):** `R1` bugün **0 ihlal** veriyor; refactor öncesi ve sonrası çıktı **aynı sabit dizgedir**.
  Toplayıcıyı körleştiren iki hâl bu karşılaştırmadan **sağ çıkar**: ① toplayıcı fazla toplarsa (ör. dosyanın
  tamamını döndürürse) `Text(` taşıyan **altı dosyanın hepsinde** `ellipsis` bulunur ⇒ `R1` **yeşil ve kör**;
  ② regex hiç eşleşmezse aday sayısı 0 olur ⇒ ihlal 0 ⇒ **yeşil ve kör**. Bu yüzden `R4` **aday sayısını**
  doğrular: `expect(adaylar.length, 8)`. Taban değişirse test kırmızıdır ve taban **bilerek** güncellenir.
  *(Projenin "ölçüm aracı ÖNCE KENDİNİ kanıtlar" doktrininin bu kapıdaki karşılığı budur.)*
- 🔴 **DUR (kriter 1):** kural ürün düzeltilmeden koşulur ve **KIRMIZI** vermek zorundadır, **tam bu iki
  konumu** raporlayarak. Kırmızı vermez ya da fazladan konum raporlarsa DUR.

### G16 — (GENİŞLETME) METİN KAYBI IZGARASI: `_y6` + `_y7`

Mevcut `_Bilesen` modeli ve dört grup (`A1`–`A4`) **değişmez**; iki girdi, bir liste ve bir koruma eklenir.

- **`_y7`** (gövde): `olustur: () => const CakismaCozumSayfasi()`,
  `bul: find.text(Metinler.cakismaVar)`, `beklenenGenislik: (g, s) => g - 2 * MBosluk.m`
  (**`MBosluk.m = 16` ölçüldü** ⇒ `g − 32`; `_y3`'ün formülüyle **birebir aynı**, yeni formül icat edilmez).
  Yapı doğrulandı: `Scaffold.body → Center(loosen) → Padding(all: MBosluk.m) → Text`.
  ⇒ **`_olcumKapsami`'na girer** (A1 + A4).
- **`_y6`** (AppBar başlığı): `olustur: () => const CakismaCozumSayfasi()`,
  `bul: find.text(Metinler.duyuruCakismaVar)`, `beklenenGenislik: null`.
  🔴 **YALNIZ `A2`** — `A1`/`A4`'e giremez (ölçek kelepçesi, §0/1), `A3`'e de girmez (§8/S4: `A3` `bul()`
  kullanmaz, `_y6` ile `_y7` aynı sayfayı ürettiği için `A3` testi **birebir aynı** olurdu).
- **Üç liste (kod içi, adları sabit):**
  `_hepsi` = `[_y1…_y5, _y6, _y7]` (**7**, `A2`) · `_a3Kapsami` = `[_y1…_y5, _y7]` (**6**, `A3`) ·
  `_olcumKapsami` = `[_y2, _y3, _y4, _y5, _y7]` (**5**, `A1` + `A4`)
- 🔴 **KOD İÇİ KAPSAM KORUMASI (yeni, `A0`):** ayrı bir `test('kapsam sayimi')` — 🔴 **UZUNLUK DEĞİL ÜYELİK**
  iddia eder (uzunluk iddiası bir **takası** — ör. `_olcumKapsami`'nda `_y7` yerine `_y1` — yakalamaz):
  `_hepsi` kodları **tam olarak** `['Y1','Y2','Y3','Y4','Y5','Y6','Y7']` ·
  `_a3Kapsami` kodları **tam olarak** `['Y1','Y2','Y3','Y4','Y5','Y7']` ·
  `_olcumKapsami` kodları **tam olarak** `['Y2','Y3','Y4','Y5','Y7']`. `reason:` dizgesi `_y6`'nın `A1`/`A3`/`A4`'te
  **neden** olmadığını (`_kMaxTitleTextScaleFactor = 1.34` kelepçesi + `A3` `bul()` kullanmaz) **taşır** —
  kapı kendi gerekçesini taşısın. *(M101/M106'nın ısırması aksi hâlde builder'ın **elle sayı
  karşılaştırmasına** kalırdı; bu bir kapı değil, alışkanlıktır.)* ⇒ süite **+1 test**.
- 🔴 **GRUP BAŞLIKLARI GÜNCELLENİR:** `A1`/`A2`/`A3`/`A4` grup dizgeleri ve dosya başlığı bugün *"Y1-Y5"* /
  *"beş yer"* diyor; v3'ten sonra gerçek kapsamlar `A1`/`A4` = Y2-Y5+Y7, `A2` = Y1-Y7, `A3` = Y1-Y5+Y7'dir.
  Güncellenmezse kapı **kendi kapsamı hakkında bayat beyan** taşır. 🔴 **Test ADLARI (`${b.kod}: …`)
  DEĞİŞMEZ**, yalnız grup dizgeleri değişir; kriter 4/10 **sayıya** bakar, ada değil.
- 🔴 **`bul()` DUR koşulu:** her finder **tam bir** düğüm bulmalıdır (`findsOneWidget`). *(Doğrulandı:
  iki dizge farklıdır ve sayfada birer kez geçer; `Semantics`/`DefaultTextStyle` **atadır**,
  `tester.widget<Text>()` ve `renderObject<RenderParagraph>()` bozulmaz.)*
- **İç içe `Scaffold` doğrulandı:** `Align → SizedBox(tight w) → ConstrainedBox` zinciri sonlu kısıt üretir,
  `MaterialApp` `MaterialLocalizations`ı sağlar ⇒ `takeException()` **null** beklenir. Değilse DUR ve
  gerçek sebebi yaz — sarmalayıcıyı *"çalışsın diye"* değiştirmek **YASAK** (beş yerin ortak zeminidir).

**BEKLENEN TEST SAYILARI (`iddia-kapisi.py I1` bunu ölçer):**

| ayak | kapsam | sayı |
|---|---|---|
| `A0` kapsam koruması | — | **1** |
| `A1` (`_olcumKapsami` × 9) | 5 | **45** |
| `A2` (`_hepsi` × 9) | 7 | **63** |
| `A3` (`_a3Kapsami` × 9) | 6 | **54** |
| `A4` (`_olcumKapsami` × 9) | 5 | **45** |
| **G16 TOPLAM** | | **208** |

Bugünkü taban **ölçüldü: G16 = 162** (36+45+45+36), süit **428**.
⇒ hedef süit = 428 + (208 − 162) + 2 (`R2` ve `R4`) = **476**.
🔴 **DUR:** koşulan sayı bu sayıya eşit değilse bir grup hedefe ulaşmıyordur ⇒ DUR.

---

## 6. MUTANTLAR

Her mutant **tek bir bozma** yapar, kapının **ısırdığını ölçer**, sonra **geri alınır**. Her mutant için
`KANIT/A9/02-MUTANT/M<n>.txt` şunları taşır: **① bozma sonrası HAM kırmızı çıktı** (hangi ayak/kural
kırmızı — ayak ayak) **② geri alma sonrası HAM yeşil çıktı**. Biri eksikse mutant **koşulmamış sayılır**.
K53/3: **statik ve widget mutantı TAVANSIZDIR**; bu görevde **koşan uygulama isteyen mutant YOKTUR**
⇒ 3'lük tavan **uygulanmaz**. Mutant sayısı **11'dir (≥ 8)** — `iddia-kapisi.py`'nin `LISTE_ESIGI = 8`
**envanter reddi ISIRSIN diye** (A8'in ölçtüğü dairesel-kanıt kapısı; v1 **6** ile eşiğin iki altındaydı).
🔴 **BEYAN EDİLMİŞ BELİRSİZLİK:** `LISTE_ESIGI`'nin **neyi** saydığı (mutant satırı mı, kanıt dosyası mı)
spec yazılırken **ölçülemedi** — araç kaynağı denetçiye verilmemişti. Kriter 12 bu yüzden `EXIT 0`'ın
yanında **çıktı içeriğini** de şart koşar; içerik görünmezse eşik ısırmamış demektir ⇒ DUR.

| # | mutasyon | ısırması **BEKLENEN** | tür |
|---|---|---|---|
| **M98** | `Y7`'nin `maxLines:` argümanını sil | **G5/R2** + **G16/A2** | statik + widget |
| **M99** | `Y7`'nin `overflow: TextOverflow.ellipsis`'ini sil | **G5/R1** + **G16/A2** *(ikisi de kırmızı olur; fazladan kırmızı DUR değildir)* | statik + widget |
| **M100** | `kCakismaGovdesiMaxSatir` = **ölçülen N − 1** | **G16/A1** (`didExceedMaxLines`) | widget |
| **M101** | `_y7`'yi `_olcumKapsami`'ndan çıkar | **G16/A0** (mekanik) + sayım 18 düşer | kapı-kapısı |
| **M102** | `lib/sunum`'a geçici dosya: `ellipsis` var, `maxLines` yok, **nötr dizge** | **G5/R2** — kuralın **dosyaya değil SINIFA** bağlı olduğunun pozitif kanıtı | statik |
| **M103** | `Y6`'nın `maxLines:` argümanını sil | **G5/R2** + **G16/A2** *(farklı konum: `const` + `AppBar`)* | statik + widget |
| **M104** | `senkron_rozeti.dart`'ın **çok satırlı** `Text` gövdesinden `ellipsis`'i sil | **G5/R1** — refactor regresyonu; toplayıcının **farklı bir şeklini** sınar | statik |
| **M105** | Ortak gövde toplayıcının satır penceresini **1**'e düşür | 🔴 **G5/R1 KIRMIZI** (7+ sahte ihlal) **ve G5/R2 SESSİZCE KÖR** (0 ihlal) — beklenen gözlem **budur**, *"ikisi birden ısırır"* DEĞİL | araç-kapısı |
| **M106** | `_y6`'yı `_hepsi`'den çıkar | **G16/A0** (mekanik) + `A2` sayımı 9 düşer | kapı-kapısı |
| **M107** | Ortak gövde toplayıcının satır penceresini **9**'a düşür | **G5/R2** — **cerrahi**: `R1` sekiz gövdenin hepsinde yeşil kalır, `R2` **yalnız `gorev_satiri.dart:143`**'te kırmızı olur *(ölçüldü: `ellipsis` en geç ofset 8 → `:151`, `maxLines` en geç ofset 9 → `:152`)* | araç-kapısı |
| **M108** | `R4`'ün aday regex'ini hiç eşleşmeyecek biçimde boz | **G5/R4** — aday sayısı 0'a düşer; `R1`/`R2` **yeşil ve tamamen kör** kalırdı | araç-kapısı |

🔴 **M100 dairesel kanıtı keser.** Sayı *"`A1`'i geçiren en küçük N"* diye seçildiği için `A1`'in geçmesi
**tanım gereğidir**; `N−1`'in ısırtması, sayının **en küçük yeterli** olduğunun tek mekanik kanıtıdır.
Isırmazsa ölçüm yanlıştır ⇒ DUR. **Not:** ölçülen `N = 1` çıkarsa `maxLines: 0` Flutter'ın
`assert(maxLines > 0)`'unu patlatır ⇒ M100 **koşulamaz**; o hâlde `maxLines` **silinir** (M98'e indirgenir)
ve bu `M100.txt`'e **açıkça yazılır**.

🔴 **M102 bu görevin asıl kazancını ölçer.** Isırmazsa kapı *"sınıf kapısı"* değil, iki satırlık bir yamadır.
Geçici dosya `design-token-kapisi.py` `D0`'ına (ham literal) ve F6 ham-dizge taramasına takılmayacak
**nötr** içerik taşır; M102 sırasında `design-token` **koşulmaz**.

## 6b. MUTANT BORCU

**YOKTUR.** *(v1'in buraya yazdığı iki borç `KURAL` değil `AYAK`/`KAPI` içindi; K53/3 **"KAPI borçlanamaz,
yalnız kural"** der ve A8 §6b bu aracın borcu yalnız envanterindeki bir kural için kabul ettiğini
**ölçmüştü**. Her iki sınır §8'e — `S1` ve `S2` — beyan edilmiş sınır olarak taşındı.)*

---

## 7. KABUL KRİTERLERİ (sırayla, atlanmaz)

1. **ÖNCE KIRMIZI + REFACTOR TABANI.** Önce `R1`'in bugünkü ham çıktısı alınır (`00-R1-ONCE.txt`).
   Sonra toplayıcı ortak yardımcıya çıkarılır ve `R2` eklenir; **ürüne dokunulmadan**
   `flutter test test/a11y_statik_tasma_test.dart` koşulur ⇒ **KIRMIZI**, raporunda **tam iki konum**:
   `cakisma_rozeti.dart:77` ve `:82`. → `00-ONCE-KIRMIZI.txt` (**ham**). 🔴 **DUR:** kırmızı değilse,
   ya da fazladan konum varsa DUR.
2. **PROBE HARNESS'I.** `_a9_probe_test.dart`, G16'nın **`_sarmalayici`'sini doğrudan kullanır**
   (gerekirse aynı dosyaya taşınır ya da import edilir); **kendi kurulumunu yazmak YASAKTIR**.
   🔴 Aksi hâlde ölçülen sayı, kapının gördüğü kutuya ait olmaz.
3. **Y7 SAYI ÖLÇÜMÜ.** Probe, `Y7` için dokuz ızgara noktasının (`320/360/411 dp × 1.0/1.5/2.0`)
   **hepsinde** `didExceedMaxLines == false` veren **EN KÜÇÜK N**'i ölçer (`N` 1'den artırılır).
   🔴 **TAVAN 8** (A8/kriter 2 ile aynı, aynı gerekçe): `N > 8` ⇒ **DUR** ve Cowork'e bildir —
   doğru cevap **kaydırmadır, bu dilim değil**. Döngü `N = 12`'de **koşulsuz durur** ve `[ÖLÇÜLEMEDİ]` yazar.
   → `00-OLCUM.txt` = probe'un **HAM stdout'u** (builder tablosu **değil**); probe kaynağı
   `00-PROBE.dart.txt` olarak arşivlenir. Sonra probe **0 `test(` kalacak biçimde boşaltılır.**
3b. 🔴 **Y6 ROTA + SEMANTİK ÖLÇÜMÜ (hüküm için ZORUNLU — §8/S1'in dayanağı budur).** Probe, sayfayı
   **`Navigator.push` ile açar** (yani `AppBar`'da **geri oku VARDIR** — doğrudan pompalanan sayfada yoktur ve
   başlığa ~56 dp fazla genişlik kalır) ve `320 dp`'de, `maxLines: 1` ile şu ikisini **ölçer**:
   **(a)** başlığın `didExceedMaxLines` değeri — **ne çıkarsa yazılır, bu bir hüküm değil ölçümdür**;
   **(b)** 🔴 başlığın **semantik düğüm etiketi TAM METNİ taşır mı** — yani kayıp **yalnız görsel** mi?
   → `00-Y6-ROTA.txt` (**ham**). 🔴 **DUR:** (b) sağlanmazsa `Y6 = 1` **savunulamaz** (ekranda kırpılan
   başlığın tam metnini taşıyan **hiçbir** yol kalmaz) ⇒ DUR ve Cowork'e bildir; doğru cevap sabit değil,
   **başlığın kısaltılması ya da bir `Semantics` taşıyıcısıdır**. *(Gerekçe denetimde ölçüldü: `Y1`'de kayıp
   kabul edilebilir çünkü tam metni `Semantics(label: gorev.baslik)` taşır — `gorev_satiri.dart:125`;
   `AppBar` başlığında **öyle bir açık taşıyıcı YOKTUR** ⇒ "Y6, Y1 ile aynı sınıftır" iddiası
   **ölçülmeden kabul edilemez**.)*
4. **ÜRÜN + YEŞİL.** §4 uygulanır. `flutter test` **EXIT 0** ve toplam **476**; ayrıca
   `flutter test test/g16_metin_kaybi_kapisi_test.dart` **ayrı** koşulur, `--reporter expanded` ile
   grup kırılımı ölçülür: `A0=1 · A1=45 · A2=63 · A3=54 · A4=45`, G16 toplam **208**.
   → `01-SONRA-YESIL.txt` (yalnız G16) + `03-TEST.txt` (tam süit, ham).
   🔴 **DUR:** toplam ya da **herhangi bir grup** sayısı tutmuyorsa DUR. *(Tek bir toplam sayı yetersizdir.)*
5. **REFACTOR REGRESYONU.** `R1`'in kriter 1'deki taban çıktısı ile şimdiki çıktısı karşılaştırılır:
   `R1` ihlal listesi **her ikisinde de boş** olmalı ve M104 (kriter 6) ısırmalıdır. → `06-REGRESYON.txt`
6. **MUTANTLAR M98–M108** (on bir adet) koşulur; her biri için **kırmızı + geri alma sonrası yeşil** ham
   çıktı `02-MUTANT/M<n>.txt`'e yazılır. 🔴 **DUR:** ısırmayan tek bir mutant bile varsa DUR.
7. 🔴 **FİNAL YEŞİL.** Bütün mutasyonlar geri alındıktan **sonra** `flutter test` **yeniden** koşulur:
   **EXIT 0** ve toplam **476** (kriter 4 ile aynı). Ayrıca `_a9_probe_test.dart`'ta `test(` sayısı **0**
   olduğu ölçülür. → `01b-FINAL-YESIL.txt`. 🔴 **DUR:** sayı sapmışsa bir mutasyon geri alınmamıştır.
8. `flutter analyze --fatal-infos` ⇒ **0 bulgu** (tam yolla). → `04-ANALYZE.txt`
9. `python araclar\design-token-kapisi.py .` ⇒ **TEMİZ / EXIT 0**. → `05-DESIGN-TOKEN.txt`
10. **REGRESYON KAPILARI.** `g13`, `g14`, `g15`, `a11y_kapisi`, `sunum_bilesenleri`,
    **`a11y_statik_tasma`**, **`g16`** dosyaları **ayrı ayrı** koşulur; her biri **EXIT 0** ve her birinin
    test sayısı `06-REGRESYON.txt`'e **ham** yazılır. 🔴 **DUR:** herhangi biri EXIT ≠ 0 ise DUR.
11. `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-A9-cakisma-cozum-metin-kaybi.md`
    ⇒ **EXIT 0** (K81: **dizin değil DOSYA YOLU**). 🔴 Çıktı **`_SILINECEKLER\06-SPEC-KAPSAMA.txt`**'e
    yazılır, **`KANIT/A9`'a KONMAZ** (dairesel kanıt yasağı, A8 deseni).
12. `python araclar\iddia-kapisi.py GOREV_CLAUDE_CODE\GOREV-A9-cakisma-cozum-metin-kaybi.md --kanit KANIT\A9`
    ⇒ **EXIT 0** ve çıktıda **`KANITLI MUTANT (11)`**. → `07-IDDIA.txt`
    🔴 Aracı **spec dosyası olmadan** çağırmak yasaktır (A8 ölçtü: dizinle çağrı **EXIT 2**).
13. **DİFF ÖLÇÜMÜ.** `git --no-optional-locks status --porcelain` **ve** `git --no-optional-locks diff`
    (**`--stat` DEĞİL, tam metin**) → `08-GIT-STATUS.txt`. 🔴 `lib/sunum` altındaki
    `TextOverflow.ellipsis` sayımı **TAM 8** olmalıdır (ne az ne çok — az ise `ellipsis` silinmiş, çok ise
    M102'nin geçici dosyası **geri alınmamış**). Komut:
    `git --no-optional-locks grep -c "TextOverflow.ellipsis" -- src/client/lib/sunum`
14. **HÜKÜM.** `09-HUKUM.md`: 1–13'ün her birinin sonucu · ölçülen `N` · hangi DUR tetiklendi (hiçbiri
    tetiklenmediyse **açıkça öyle yazılır**) · dosya kimlikleri (`dosya-kimlik.py`, **son yazımdan SONRA**).
    🔴 Bu dosya **builder'ın kendi hükmüdür; Cowork doğrulamadan KABUL ETMEZ** (K26).

---

## 8. BEYAN EDİLMİŞ SINIRLAR (gizlenen sınır kabul edilmez)

- **S1 — `Y6`'nın DEĞERİ ÖLÇÜLMEZ, SABİTTİR (`1`).** `AppBar` başlığı `_kMaxTitleTextScaleFactor = 1.34`
  ile kelepçelenir ⇒ ızgaranın 1.5x/2.0x ayakları oraya **ulaşmaz**; *"en küçük N"* uygulansa `N = 2`
  çıkar ve 2 satır 64 dp toolbar'da **sessizce** kesilir. `A1`/`A3`/`A4` Y6'yı **ölçmez**.
  🔴 **BU SINIR KOŞULLUDUR — dayanağı kriter 3b'nin ÖLÇÜMÜDÜR, benzetme DEĞİL.** v2 bu satırda
  *"Y6, A8'in `Y1` sınıfındadır"* diyordu; denetimde **çürütüldü**: `Y1`'de kayıp kabul edilebilir çünkü
  tam metni `Semantics(label: gorev.baslik)` **taşır** (`gorev_satiri.dart:125`), `AppBar` başlığında ise
  **öyle bir açık taşıyıcı YOKTUR**. Kayıp ancak semantik düğüm tam metni taşıyorsa (kriter 3b/b)
  *"görünür ve kurtarılabilir"* sayılır; taşımıyorsa `Y6 = 1` **savunulamaz** ve kriter 3b DUR verir.
- **S2 — `AppBar` DİKEY taşmasının mekanik kapısı YOKTUR.** `_RenderAppBarTitleBox` çocuğa
  `maxHeight: infinity` verir, `constrain` + `ClipRect` ile keser, **istisna atmaz** ⇒ `A3` (takeException)
  ve `A4` (intrinsic yükseklik) bu kaybı **göremez**. Bu bir **açık borçtur**, kapısı yoktur.
- **S3 — `spec-kapi-kapsama.py` `A0`–`A4` AYAKLARINA ve düz-metin kurallara KÖRDÜR.** Envanteri
  `### G<n>` başlıklarından ve `## 5.` tablosunun hücrelerinden doğar. Kriter 11'in **`EXIT 0`'ı
  "her ayak kapsandı" demek DEĞİLDİR** (A8/S6 ile aynı sınır).
- **S4 — `A3` `bul()` KULLANMAZ.** Yalnız `olustur()`'u pompalayıp `takeException()`'a bakar; bu yüzden
  `_y6` ile `_y7` `A3`'te **birebir aynı testi** üretirdi. `_y6` bu yüzden `_a3Kapsami`'ndan çıkarıldı —
  sayı **dekoratif test taşımaz**.
- **S5 — `A2`, `A3` ve `A0`'ın kendi mutantı vardır ama `A4`'ün YOKTUR** (A8/S7 ile aynı borç).
- **S6 — Sayfa hiç AÇILMADAN doğrulanır.** Hiçbir kriter rozete dokunmaz, `Navigator` kullanmaz. İki sonucu:
  ① gerçek akışta `AppBar`'ın **geri oku (leading)** vardır ve başlığın genişliğini yer — testte **yoktur**;
  ② `Y6` **`style` taşımaz**, stili temadan gelir ve harness'ta **tema yoktur** ⇒ ölçüm M3 varsayılan
  `titleLarge`'ı üzerinde yapılır, `MomentumTema`'nın `AppBarTheme`'i **[DOĞRULANMADI]**.
- **S7 — Test fontu cihaz fontundan FARKLI ölçer** ⇒ gerçek cihaz görünümü **[DOĞRULANMADI]** (A8/S2).
- **S8 — Izgara bir ÖRNEKLEMDİR** (320/360/411 × 1.0/1.5/2.0); ara genişlikler ve > 2.0 ölçek
  **ölçülmedi** (A8/S3). Ayrıca sarmalayıcının dikey bütçesi test yüzeyi tarafından **~600 px**'e
  kenetlenir ⇒ gerçek viewport yüksekliğindeki dikey kayıp **[DOĞRULANMADI]**.
- **S9 — Statik tarayıcı REGEX tabanlıdır** ve gövdeyi **25 satırlık** bir pencerede toplar
  (`a11y_statik_tasma_test.dart:42`). `Text` bir değişkene atanır ya da bir yardımcı fonksiyon üretirse
  **GÖRÜLMEZ**; 25 satırdan uzun bir gövde **kesilir**. Bu, mevcut `R1`'in **zaten taşıdığı** sınırdır;
  A9 onu ne büyütür ne küçültür — yalnız `R3`/M105 ile pencerenin **gerçekten çalıştığını** kanıtlar.
- **S10 — SS2'nin (gerçek çakışma çözüm ekranı) SAHİBİ YOKTUR.** K42-d'nin dört adımı tamamlandı ve
  SS2'yi getirmedi; *"K42-d adım 3'te gelir"* atfı **bayattır** (§1). Bu görev SS2'yi ne yapar ne planlar;
  borcu **beyan eder**. `BORCLAR.md`'ye taşımak **Cowork'ün** kapanış işidir.
- **S11 — Web ayağı `[DOĞRULANMADI]`** — `flutter test --platform chrome` bu ortamda sonuç üretmiyor
  (iki ölçüm: 7 dk ve 9,8 dk, `DURUM.md` §7).
- **S12 — Bu spec BİR (1) bağımsız denetim turu gördü** (üç mercek: Flutter tekniği · ölçülebilirlik ·
  doktrin uyumu). K53/1 gereği **ikinci tur AÇILMAZ**; kalan belirsizlik (`AppBar`'ın dikey davranışı,
  `N`'in gerçek değeri) **kâğıtta çözülemez ve BUILD'e devredilmiştir**.

---

## 9. KANIT DİZİNİ — `KANIT/A9/`

`00-R1-ONCE.txt` (kriter 1) · `00-ONCE-KIRMIZI.txt` (kriter 1) · `00-PROBE.dart.txt` (kriter 2) ·
`00-OLCUM.txt` (kriter 3, **probe'un ham stdout'u**) · `01-SONRA-YESIL.txt` (kriter 4, yalnız G16) ·
`00-Y6-ROTA.txt` (kriter 3b) · `01b-FINAL-YESIL.txt` (kriter 7) · `02-MUTANT/M98.txt … M108.txt` (kriter 6, **kırmızı + yeşil**) ·
`03-TEST.txt` (kriter 4, tam süit) · `04-ANALYZE.txt` · `05-DESIGN-TOKEN.txt` ·
`06-REGRESYON.txt` (kriter 5 + 10) · `07-IDDIA.txt` (kriter 12) · `08-GIT-STATUS.txt` (kriter 13) ·
`09-HUKUM.md` (kriter 14).

🔴 **Kanıt HAM ÇIKTIDIR.** Özet, tablo, hüküm ya da *"koştu ve geçti"* cümlesi kanıt **değildir**;
`iddia-kapisi.py` özet/hüküm dosyalarını kanıt saymaz (**dairesel kanıt yasağı**).
🔴 **Kriter 11'in çıktısı bu dizine KONMAZ** (`_SILINECEKLER\06-SPEC-KAPSAMA.txt`).
🔴 **`09-HUKUM.md` builder'ın kendi hükmüdür — Cowork bağımsız doğrulamadan KABUL ETMEZ (K26).**

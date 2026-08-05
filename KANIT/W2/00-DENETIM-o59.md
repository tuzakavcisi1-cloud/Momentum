# W2 — KİLİT ÖNCESİ BAĞIMSIZ DENETİM (`K127`) · oturum 59 · 5 Ağu 2026

> **Denetlenen artefakt:** `GOREV_CLAUDE_CODE/GOREV-W2-depolama-gorunurlugu.md` **v1**,
> **11.770 b · sha8 `C9BC8453`** (denetçi A kimliği bağımsız doğruladı).
> **Üreten el:** Cowork (oturum 59). **`K26` gereği üreten DENETLEMEDİ.**
> **İki bağımsız denetçi PARALEL koştu** (birbirlerinin çıktısını görmediler) — `o57` emsali:
> **Denetçi A** = spec/kural denetçisi · **Denetçi B** = red-team kırıcı ("spec'i geçen ama kusuru koruyan
> uygulamayı yaz").
> 🔴 **Bu, `K53/1`'in TEK kâğıt turudur.** İkinci tur açılmadı ve açılmayacak; bulgular doğrudan v2'ye işlenir.

---

## 0. ÖNCE — İKİ DENETÇİNİN DE BAĞIMSIZ DOĞRULADIĞI ŞEYLER (gizlenmiyor: spec'in sağlam yeri)

| iddia | kim, nasıl ölçtü | hüküm |
|---|---|---|
| drift alıntısı 1 (`opfsShared` iç içe worker: *"only implemented in Firefox … Chrome (crbug 1088481) and Safari don't support this yet"*) | A: Onur'un diskinden `drift-2.34.3/.../types.dart` açıldı | **BİREBİR** |
| drift alıntısı 2 (`opfsLocks`: *"It requires cross-origin isolation … Cross-Origin-Opener-Policy: same-origin / Cross-Origin-Embedder-Policy: require-corp"*) | A: aynı dosya | **BİREBİR** |
| çıkarım: ölçülen iki eksik yetenekle `sharedIndexedDb` **kaçınılmazdı** | A: `sharedWorkers` eksik DEĞİL ⇒ üçüncü yol ayakta | **ÇIKIYOR, koparılmamış** |
| `chosenImplementation` · `missingFeatures` · `storageApi` · `.name` gerçek mi | A: `final WasmStorageImplementation chosenImplementation;` · `final Set<MissingBrowserFeature> missingFeatures;` · `final WebStorageApi? storageApi;` | **DÖRDÜ DE GERÇEK** |
| `D-W2-4` kontrast sayıları (3,14 · 11,11 · 6,92) | **A ve B AYRI AYRI** WCAG formülünü kendi hesapladı: 3,142 · 11,107 · 6,921 | **ÜÇÜ DE DOĞRU** |
| `K81` başlıkları · `K126` 3. sütun = hedef | B: dosyada fiilen yerinde · A: araç 3 kapıyı ve 10 mutantı bağladı | **UYUYOR** |
| `spec-kapi-kapsama.py` | A **KOŞTU**: `KAPI(3) KURAL(9) MUTANT(10)` · `BULGU YOK` · **EXIT 0** | **GEÇER** |
| `kapi-ad-teklik-kapisi.py` | A **KOŞTU**: `HUKUM: YESIL`, EXIT 0 | **GEÇER** |
| `K53/3` mutant tavanı · `K80` | A: 10 mutantın hepsi birim/widget ⇒ tavansız; spec canlı ortam istemiyor | **İHLAL YOK** |
| `B-W1-2` · `B-W1-3` · `B-W1-7` · `G37b-kalicilik-KANIT.md` atıfları | A: dördü de **canlı**, metinleri spec'in dediğini diyor | **SARKAN ATIF YOK** |

---

## 1. BLOKER — v1 BU HÂLİYLE KİLİTLENEMEZ

### BL-1 · Dilimin TEK gerçek dikişi (`onResult` → bildirim) HİÇBİR kapı, mutant ya da borcun kapsamında değil
**Bulan: Denetçi B. GÜVEN: KESİN.** `G39` saf fonksiyonu, `G40` **sahte durumla** widget'ı, `G41` bir dize
listesini ölçer. `T2`'nin köprüsünü hedefleyen **mutant yok**, `## 6b`'de **borç yok**. Denetçi B'nin
saldırı kodu: `onResult` gövdesinde `print` durur, **bildirim satırı hiç yazılmaz** (ya da `T5` unutulur)
⇒ `analyze` yeşil · `flutter test` yeşil · **on mutantın onu da ısırır** · sekiz kabul kriteri de geçer
⇒ **kullanıcı şeridi HİÇBİR ZAMAN görmez.** Spec'in §1/④'te *"onardığı şey SESSİZLİKTİR"* dediği kusur,
spec'i **tam puanla** geçen bir uygulamada aynen yaşar. **`W1`'in kusur sınıfının birebir tekrarı.**

### BL-2 · "Şerit VAR / YOK" ölçüm yüklemi hiç tanımlanmamış; `Opacity(0)` saldırısı dört ayağı birden geçer
**Bulan: B. GÜVEN: KESİN.** `G40/a,b,c` ve `M203/M204/M207` tek bir tanımsız kavrama dayanıyor.
`Opacity(opacity: 0)` (ya da 0 yükseklik) `Offstage` **değildir** ⇒ `skipOffstage` koruması onu **atlamaz**:
`find.byType` · `find.text` · `find.byIcon` hepsi **bulur**, kullanıcı **hiçbir şey görmez**.
İkinci kaçak: widget testi şeridi **yalıtılmış** pump ederse `T4`'ün `GorevListesiEkrani`'na **hiç
bağlanmamış** olması ölçülmez.

### BL-3 · `Veritabani` imzası Dart'ta YAZILAMAZ; yazılabilen hâli 31 çağrıyı kırar
**Bulan: A (ölçtü) + B (MN1). GÜVEN: KESİN.** Gerçek satır — `src/client/lib/veri/veritabani.dart:116`:
`Veritabani([QueryExecutor? baglanti]) : super(baglanti ?? _uretimBaglantisi());`
Dart'ta bir fonksiyon **ya opsiyonel-konumsal ya adlandırılmış** parametre alır, ikisini birden **asla**.
A ölçtü: `Veritabani(` deseni `src/client` altında **43 yerde**, **31'i** executor'ı **konumsal** geçiyor.
Ayrıca spec'in gövdesinde `baglanti ??` **düşmüş** ⇒ her test üretim bağlantısı açardı.
**Doğrusu:** `Veritabani([QueryExecutor? baglanti, DepolamaBildirimi? bildirim]) : super(baglanti ?? _uretimBaglantisi(bildirim));`

### BL-4 · `D-W2-2`'de ad-dalı ile api-dalı arasında ÖNCELİK yok ⇒ spec kendi içinde tutarsız, ve tam puanla geçen bir uygulama kullanıcıya YALAN söyleyebilir
**İkisi de buldu (A/B4, B/BL3). GÜVEN: KESİN.** `('opfsQuantum', null)` girdisi `G39/b`'ye göre `geriDusus`,
`G39/d`'ye göre `kaliciDegil` olmalı — **aynı girdi, iki beklenen**. B'nin "api önce" gövdesi dört ayağı da
geçer ve iki gerçek kusur taşır: ① `('opfsQuantum','opfs')` ⇒ **`kaliciOpfs`** — Onur'un ②. kilidi
(*"bilinmeyen ad geri-düşüş sayılır"*) **düşer**; ② `('sharedIndexedDb', null)` ⇒ kullanıcıya
*"Veriler kalıcı DEĞİL"* — spec'in §1/③'te kendi ölçtüğü gerçeğin (F5 sonrası görev yaşadı) **tersi**.
**Sessizliği onarmaya çıkan dilim, yerine yanlış alarm koyar.**

### BL-5 · `G41` drift'i PİNLEMİYOR — kendi aynasını ölçüyor; kurulabilir hâli ise bu ortamda `--fatal-infos`'u düşürüyor
**İkisi de buldu (A/B3, B/BL5). GÜVEN: KESİN.** Dizi hem üründe hem testte **bizim** ⇒ drift `opfsLocks`'u
yarın yeniden adlandırsa **ikisi de değişmez, test YEŞİL kalır** ve ürün sessizce `geriDusus`a düşer.
A, kurulabilir yolu da ölçtü ve **kapalı** buldu: `package:drift/wasm.dart:10` `import 'dart:js_interop';`
⇒ **VM testinde import edilemez**; tek alternatif `package:drift/src/...` ve zincir
`analysis_options.yaml:10 → flutter_lints-6.0.0/flutter.yaml:3 → lints-6.1.0/recommended.yaml:26`
= **`implementation_imports`** ⇒ `--fatal-infos` altında **kriter 1 düşer**.
🔴 **`CLAUDE.md`: "KAPI borçlanamaz, yalnız kural."** ⇒ `G41` ya kurulur ya düşer; borçlanamaz.
**Bu, `D-W2-1`'in beyan ettiği bedelin karşılığının ÖDENMEDİĞİ anlamına gelir ⇒ karar yeniden fiyatlanmalı.**

### BL-6 · Kabul kriteri 4, `o58/MJ1` dersini ALINTILIYOR ama UYGULAMIYOR
**İkisi de buldu (A/B5, B/BL4). GÜVEN: KESİN.** *"Adı çıktıya yazmak"* ile *"yazılan adı `hedef` sütunuyla
**karşılaştırıp eşleşmezse GEÇMEDİ demek"* aynı şey değildir — `o58`'de `M193b` tam bu farktan sahte-geçti.
Ayrıca `G39/a–d` ayakları ayrı `test()` değilse **çıktıda hedef ayağın adı zaten yoktur** ⇒ kriter
fiziksel olarak ölçülemez. **Ek (B/MJ10): negatif kontrol yok** — on mutantın onunda da `ISIR` beklenen bir
kümede, sabit `ISIR` basan bir koşucu **10/10** verir.

### BL-7 · `R4` pozitif kontrolü taban koşumda KIRILIR; `T6` bunu hiç anmıyor
**İkisi de buldu (A/B2, B/MJ4). GÜVEN: KESİN — A gerçek repoda ölçtü.**
`src/client/test/a11y_statik_tasma_test.dart:157,175`: *"R4: pozitif kontrol — tarayicinin buldugu `Text(`
aday sayisi = **12** (arac kendini kanitlar)"* + `expect(adaylar.length, 12)`. Tarayıcı `lib/sunum`'u
**recursive** tarar. A'nın bağımsız sayımı: **`TEXT_ADAY=12 DOSYA=9`** ⇒ taban **tam dolu**.
`T3` yeni bir `Text(` ekler ⇒ **13** ⇒ `flutter test` **taban koşumda EXIT ≠ 0**; on mutant bozuk bir
tabanın üstünde koşar. Sayı sessizce güncellenirse **kilitli bir ölçüm aracına beyansız dokunulmuş** olur.

---

## 2. MAJOR

- **MJ-1 · `M207` EŞDEĞER** (ikisi de): mutasyon yeri `main.dart`; hiçbir test oraya bakmaz, widget testi
  kendi notifier'ını kurar ⇒ yama uygulanır, **hiçbir şey kırmızı olmaz**. Doğrusu: mutasyon
  `DepolamaDurumu.olculmedi()` sabitinin kendisine yapılmalı.
- **MJ-2 · `M205` büyük olasılıkla EŞDEĞER + `G40/e`'nin çifti tanımsız** (ikisi de). Üç ölçülmüş olgu:
  ① `a11y_kontrast_test.dart:22,47` `MaterialApp(home:)` — **`theme`/`darkTheme` YOK** ⇒ bugünkü kontrast
  kapısı **yalnız açık temayı** ölçüyor; ② `uyari` açık temada **5,93:1** ⇒ **geçer** (M205 yalnız koyu
  temada ısırır); ③ `tokens.dart:73` `uyari(BuildContext)` **context'i kullanmıyor**, `uyariIcin(Brightness)`
  **yok**. Ayrıca A: *"şerit rengi ile yüzey"* çifti **dolgu** okunursa koyu temada metin/dolgu
  **1,40:1** — felaket, ve `G40/e` bunu ölçmez bile. ⇒ `cevrimdisi` **METİN+İKON rengidir**, zemin
  `MRenk.yuzey`; ölçüm **pump edilmiş şerit üzerinde**, token çifti üzerinde değil.
- **MJ-3 · `M208` hedefinden BAŞKA ayaktan ısırır, `G40/d` muhtemelen boş** (ikisi de).
  `a11y_statik_tasma_test.dart:103-127` (R1) `lib/sunum` altındaki **her** `Text(`'i tarar ⇒ `ellipsis`
  kalkınca **R1** ısırır, `G40/d` değil. `G40/d` fiilen ısırmaz: şerit `Column`'da, liste `Expanded`
  (`gorev_listesi_ekrani.dart:94`) ⇒ fark emilir, `RenderFlex` taşması **oluşmaz**; DESIGN.md §8/4 sabit
  yüksekliği zaten **yasaklıyor**. 🔴 Projenin kendi kaydı (`a11y_statik_tasma_test.dart:4-7`):
  *"bir `Text()` düğümü textScaler 2.0 altında **görünmeden** kırpılabilir — bu, **çalışan bir widget
  testinin YAKALAYAMAYACAĞI** bir sessizlik türüdür."*
- **MJ-4 · İkon adlandırılmamış; `DESIGN.md` §6 anlam pini MUST'ı açıkta** (ikisi de).
  `DESIGN.md:184`: *"**Anlam pini [MUST]:** çevrimdışı = `cloud_off` … **Aynı ikon iki farklı anlam
  taşıyamaz.**"* `cevrimdisi` rengi seçildiği için en doğal tercih `cloud_off`'tur ve o **YASAK**.
  `G40/b` *"ikon var mı"* diye bakar, *"hangi ikon"* diye **bakmaz**.
- **MJ-5 · `D-W2-5`'in ÖNCÜLÜ YANLIŞ** (A). `DESIGN.md:4` birebir: *"🔴 **K46 AÇILDI (K75, Onur —
  28 Tem 2026):** bu belge **artık dokunulmaz değil** … **Açılma KAPSAMI bu iki maddedir**; başka
  değişiklik yine **Onur'un kilidini ister**."* ⇒ doğru cümle *"yazılamaz"* değil, ***"Onur'un tek bir
  kilidini ister"***. Spec, Onur'un **bu turda verebileceği** bir kararı yanlış öncülle borca çeviriyor.
- **MJ-6 · `D-W2-5` ↔ §8/3 birbirini çürütüyor** (B). `DESIGN.md:156` *"liste + üst şerit"* satırı aynı
  anda **ikon `cloud_off`**, **metin**, ve **`A11Y-7` duyurusu "Çevrimdışı"** kilitliyor. Spec, belge
  yazımından kaçmak için *"bu zaten var olan desen"*, a11y yükünden kaçmak için *"bu o desen değil"* diyor.
  **İkisi birden doğru olamaz.**
- **MJ-7 · Şerit metinleri `Metinler` tek kaynağına girmiyor** (ikisi de). `senkron_rozeti.dart:6` ev
  kuralını gösteriyor; `a11y_statik_tasma_test.dart:192-206` F6 kapısı **13 dizgelik sabit liste** taşır ve
  yeni metinleri **görmez**. Testin kendi uyarısı (`:26`): *"kanonik-kopya bu projede **beş kez ısırdı**"*.
  A ayrıca ölçtü: `a11y_kapisi_test.dart:180-217` karşılaştırması **anahtar-başına** ⇒ `Metinler`'e
  ekleme **hiçbir kapıyı kırmaz** (bedava güvenli yol).
- **MJ-8 · `T6`'nın *"`a11y_kontrast_test.dart`'a çift eklenir"* talimatı UYGULANAMAZ** (A). Dosyada
  **çift tablosu yok**; iki `testWidgets` var ve ikisi de `expectLater(tester, meetsGuideline(textContrastGuideline))`
  (`:23`, `:49`) — render edip piksel örnekleyen bir kılavuz. Ayrıca `G40` *"widget testi"* der ama `T6`
  onu **başka dosyaya** koyar ⇒ `M205`'in hangi dosyadan ısıracağı belirsiz.
- **MJ-9 · `G39/c` MUTANTSIZ ve borçsuz; `G39/a`'nın `opfs` yarısı da mutantsız** (B). Sayım: 10 mutant,
  `G40/b` **iki** alıyor, `G39/c` **sıfır**. `spec-kapi-kapsama.py` bunu **yakalayamaz** çünkü ayak
  (`G39/c`) değil kapı (`G39`) sayılır — `o58/MJ5`'in aynı kör noktası.
- **MJ-10 · `B-W2-1` ve `ADR 0004` YOK** (A ölçtü: `BORCLAR.md`'de `B-W2-1` **0 kez**; `docs/ADR`'de
  `0004` **hiçbir dosya**). Spec `B-W2-1`'e **üç**, `ADR 0004`'e **iki** yerde dayanıyor; §6b'deki
  `D-W2-5` borcu *"ölçüsü `B-W2-1`'in kapanmasıdır"* diyor — **var olmayan borç kapanamaz.** `ORTAM.md`'nin
  adlandırdığı **sarkan atıf** sınıfı.
- **MJ-11 · Mutant KOŞUCUSU `K26` kapsamına alınmamış** (A). `o58`'in üç blokeri tam da **koşucu
  denetlendiği için** bulunmuştu; spec o turdan yalnız `try/finally` dersini almış.
- **MJ-12 · `M209` `o58`'in ÖNEK tuzağını taşıyor** (B, GÜVEN: ZAYIF — yazıma bağlı).
  `opfsLocks → opfsLocksX` yamalanır ve karşılaştırma `contains`/`startsWith` ise mutant **sessizce KALIR**.
- **MJ-13 · §8/3'ün `A11Y-7` muafiyet GEREKÇESİ olguya aykırı** (ikisi de). *"Şerit açılışta bir kez
  belirir"* yanlış: `onResult` **ilk boyamadan sonra** döner ⇒ şerit listenin üstüne **sonradan girer**
  (yerleşim kayması) ve ekran okuyucu kullanıcısı bunu **hiç duymaz**. Muafiyet savunulabilir; **gerekçesi
  yanlış** — `o58/MN3`'ün ("sonuç doğru, gerekçe yanlış") aynı sınıfı.

## 3. MINOR

`MN1` `M204` ayrı kusur ölçmüyor, `G40/a`'nın pozitif kontrolüyle örtüşüyor · `MN2` `M206`/`M208`'in
"beklenen" hücresi ayağı adıyla yazmıyor (kriter 4'ün şikâyet ettiği kusurun tablodaki hâli) ·
`MN3` `DepolamaDurumu.eksikYetenekler` **ölü alan**: hiçbir kapı okumuyor, `G41` yedi `MissingBrowserFeature`
değerini pinlemiyor (proje emsali `veritabani.dart:100`: *"ölü sütun yazılmaz"*) · `MN4` §8/2
(`design-token-kapisi.py` ÖLÇÜLMEDİ) **kabul kriterlerinde yok** ⇒ koşulmadan kabul verilebilir ·
`MN5` kriter 2 beklenen test **sayısını** beyan etmiyor ⇒ bir testin silinerek yeşile boyanması mekanik
yakalanmaz · `MN6` `G39` ve `G41`'in pozitif kontrolü yok (`G40/a`'nınki var ve korunmalı) ·
`MN7` `D-W2-6` ↔ `DESIGN.md:206` ban-list #5 (*"`print` ile UI durum kaydı yok"*) gerilimine hiç
değinilmiyor (GÜVEN: ZAYIF).

---

## 4. NE ÖLÇÜLEMEDİ (iki denetçinin birleşik listesi — **boş değil, olamaz da**)

1. **`flutter analyze` ve `flutter test` HİÇ KOŞULMADI.** Denetçi B'nin kutusunda `flutter`/`dart` **yok**
   (`which` boş); denetçi A salt-okunur kaldı. ⇒ `BL-3`, `BL-7`, `MJ-2`, `MJ-3` hükümleri **dil kuralından
   ve ölçülmüş sayımlardan ÇIKARSANDI**, koşularak gözlenmedi.
2. Denetçi B **drift kaynağına erişemedi** ⇒ §1'in iki alıntısını **yalnız A** doğruladı (tek tanık).
3. Kriter 7'nin dört ayağından **yalnız ikisi** koşuldu (`spec-kapi-kapsama`, `kapi-ad-teklik`);
   `tek-kopya-kapisi.py` · `belge-tavan-kapisi.py` · `sayi-tazeligi.py` bu denetimde **koşulmadı**.
4. `design-token-kapisi.py`'nin **yeni bir sunum bileşenine** tepkisi **ÖLÇÜLEMEDİ** (bileşen henüz yok).
5. `radar.py --olc-urun-kodu`'nun *"> 0"* iddiası kod yazılmadan **ölçülemez**; `B-W1-3` gereği sayaç
   satıcı baytını ürün kodu sayıyor ⇒ kriterin *"elle yazılmış satır ayrı beyan edilir"* şartı **mekanizmasız**.
6. `meetsGuideline(textContrastGuideline)`'in `#8A5A00`/`#0F1319` çiftinde fiilen kırmızı verip vermediği
   **ölçülmedi**.
7. `D-W2-7`'nin *"native yolda `onResult` hiç çağrılmaz"* iddiası **doğrulanmadı** — `drift_flutter`'ın
   `driftDatabase()` gövdesi açılmadı. **Makul ama ölçülmemiş.**
8. Spec'in *"Onur'un bu turda verdiği dört kilit"* ve *"`ADR 0004` (Onur kilidi)"* beyanlarının repoda
   **karşılığı yok** ⇒ denetçi A bunları **doğrulayamadı** (spec'in kendi beyanıdır; bu dosya onları
   Cowork'ün oturum kaydına dayandırır).
9. `spec-kapi-kapsama.py`'nin **EXIT 0'ı hiçbir blokeri yalanlamaz** — aracın kendi beyanı birebir:
   *"bu betik mutantin GERCEKTEN ISIRDIGINI olcmez; esdeger-mutant tespiti calisan kod ister."*

---

## 5. HÜKÜM

| denetçi | hüküm |
|---|---|
| **A (spec/kural)** | **KİLİTLENEMEZ** — *"B3 kapanmadan `D-W2-1` yeniden fiyatlanmak zorundadır."* |
| **B (red-team)** | **DÜZELTİLİP KİLİTLENEBİLİR** — *"bu beşi metne girmeden verilecek kilit, `W1`'de olanı tekrar eder: yeşil bir zincirin altında hiç ölçülmemiş bir çekirdek."* |

🔴 **COWORK'ÜN HÜKMÜ: `v1` KİLİT İSTENMEZ.** İki denetçi de dilimin **çekirdeğinin ölçülmediğini**
bağımsız olarak buldu (`BL-1`) ve ikisi de aynı beş kusuru ayrı yollardan gördü. Bulguların **hiçbiri
koşan kod gerektirmiyordu** — `K127`'nin doğuş gerekçesinin birebir tekrarı.

🔴 **ONUR'A GİDEN ÜÇ KİLİT** (`K40`/`K46` gereği karar **Onur'undur**, bu dosya karar vermez):
① `G41`'in kaderi (gerçek enum + `// ignore: implementation_imports` · yoksa `G41` düşer ve `D-W2-1`
yeniden fiyatlanır) ② `DESIGN.md`'ye `DepolamaSeridi` + ikon satırı **eklensin mi** (`K75` açılma kapsamı
dışı ⇒ Onur'un kilidi şart) ③ `A11Y-7` duyurusu **uygulansın mı**.

**Bu dosya `K127`'nin istediği DENETÇİ ÇIKTI YOLUDUR.** `W2` kilit checkpoint'i buraya atıf yapar.

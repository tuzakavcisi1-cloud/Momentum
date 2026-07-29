# GOREV-A7 — ROZET METİN TAŞMASI + 2.0× ÖLÇEK AYAĞI (A11Y‑4)

> **Kilit:** Onur, 30 Tem 2026, oturum 39 — **K83/③** ve bu spec'in üç tasarım şıkkı.
> **Rol:** bu spec'i **Cowork** yazdı, build **Claude Code**'da. Üreten ≠ denetleyen (K26) ⇒ spec'in
> kabulü builder'ın beyanıyla değil, aşağıdaki kapıların **koşumuyla** olur.
> **Biçim:** K81 standardı — kapılar `## 5. KAPILAR` altında `### G<n>`, mutantlar `## 6. MUTANTLAR` altında.

---

## 1. AMAÇ VE ÖLÇÜLMÜŞ GEREKÇE

`DESIGN.md` açık kalemi **A‑7**: *"İki rozet yan yana durumunda A11Y‑4 (2.0× ölçek) ve A11Y‑1 (48dp)
yeniden ölçülmedi — dar ekranda taşma [DOĞRULANMADI]"*. Oturum 37 cihaz PNG'lerinde taban rozet metni
**1.0× ölçekte BİLE** kırpılmış görüldü (*"Gönderilmemiş de…"*, *"Çevrimdışısın…"*), **2.0× hiç ölçülmedi.**

### 1.1 🔴 KÖK NEDEN: MEVCUT A11Y‑4 KAPISI KÖRDÜR [oturum 39'da ÖLÇÜLDÜ]

`src/client/test/a11y_kapisi_test.dart:274` gövdesi **üç satırdır**:

```dart
testWidgets('A11Y-4: textScaler 2.0 altinda beklenmeyen tasma (FlutterError) yok', (tester) async {
  await tester.pumpWidget(_vitrinSarmalayici(textScale: 2.0));
  await tester.pump();
  expect(tester.takeException(), isNull);
});
```

**`TextOverflow.ellipsis` FlutterError ÜRETMEZ.** `takeException()` yalnız `RenderFlex overflow` gibi
**atılmış** istisnaları görür; ellipsis ise metni **sessizce** kırpar ve hiçbir istisna atmaz. Yani bu kapı
*"düzen patladı mı?"* diye soruyor, `DESIGN.md`'nin yasakladığı şeyi — **kırpmayı** — hiç sormuyor.
Kapı **yeşil** kalırken cihaz PNG'sinde kırpma **görünüyordu**; ikisi çelişti ve kimse çelişkiyi ölçmedi.
**Bu bir kör kapıdır** ve bu spec'in birinci işi onu ısıran bir kapıya çevirmektir.

#### 1.1.1 🔴 İDDİA KOD OKUMASIYLA DEĞİL **KOŞARAK** ÖLÇÜLDÜ [oturum 39, Cowork]

Geçici bir ölçüm dosyası (`_a7_olcum_test.dart`, koşuldu ve `_SILINECEKLER`'e alındı) aynı ağaçta
**iki şeyi birlikte** ölçtü: mevcut kapının gövdesi (`takeException()`) ve `RenderParagraph` intrinsic
genişliği. Metin: `Metinler.cevrimdisiKaydedildi` = *"Çevrimdışısınız. Değişiklikler kaydedildi."*

| ölçüm | kurulum | `takeException()` | istenen (px) | ayrılan (px) | kırpıldı? |
|---|---|---|---|---|---|
| **1** | 140dp kutu · **2.0×** | **`null`** | **1102,50** | **112,00** | **EVET** |
| **2** | 600dp kutu · 1.0× | — | 556,50 | **556,50** | hayır |
| **3** | **gerçek 320dp ekran** · 2.0× · gerçek satır düzeni (`Expanded` başlık + `Flexible` rozet) | **`null`** | **1102,50** | **104,00** | **EVET** |

**Üç sonuç, üçü de ölçüm:**
1. 🔴 **Kör kapı KANITLANDI.** Ölçüm 1 ve 3'te metin ayrılan alanın **~10,6 katını** istiyor — yani rozet
   metninin **%90'ından fazlası görünmüyor** — ve `takeException()` **`null`** dönüyor. Mevcut
   `a11y_kapisi_test.dart:274` bu ağaçta **hiçbir şey söylemez**. İddia artık kod okumasına değil
   **koşmuş bir sayıya** dayanıyor.
2. 🟢 **`G13`'ün ölçüm ayağı YANLIŞ-POZİTİF ÜRETMİYOR.** Ölçüm 2'de istenen ve ayrılan **birbirine eşit**
   (556,50 = 556,50) ⇒ kapı geniş alanda **susuyor**. Bu, `G13_TOLERANS = 0.5` seçiminin de gerekçesidir:
   eşitlik tam çıktığı için toleransın tek işi kayan nokta yuvarlamasıdır, kusur maskelemek değil.
3. 🔴 **Gerçek satır düzeninde rozete yalnız 104 px kalıyor** (ölçüm 3) — `Expanded` başlık + `Flexible`
   rozet flex paylaşımının 2.0×'te ne kadar yetersiz olduğunun doğrudan kanıtı (§1.3'ün sayısı).

> **BEYAN EDİLMİŞ SINIR (§8/S3'ün somut hâli):** 1102,50 px değeri `flutter_test`'in **test fontuyla**
> ölçülmüştür; cihazın gerçek yazı tipiyle sayı **farklı çıkar**. Kanıtlanan şey mutlak px değeri değil,
> **oranın büyüklüğü ve kapının sessizliğidir**. Cihazdaki gerçek görünüm `CM1`/`CM2` ile ölçülür.

### 1.2 🔴 İKİNCİ ÖLÇÜM: DOKTRİN ÇELİŞKİSİ (spec bu ayrımı YAZAR — Onur'un kilidi, şık 1)

- `a11y_statik_tasma_test.dart` **`TextOverflow.ellipsis`'i ZORUNLU** kılar (M16'nın öğrettiği: `maxLines`
  tek başına yetmez, `overflow` verilmezse Flutter varsayılanı `clip`'tir ⇒ **sessiz** kırpma).
- `DESIGN.md` **kırmızı çizgi 4**: *"Sabit yükseklikli metin kutusu yok — metin ölçeği 2.0×'te kırpma yasak"*.

İki kural **çelişmiyor ama hiçbir yerde AYRILMAMIŞ**. Kanonik ayrım — bundan sonra geçerli:

| kural | ne ölçer | kapı |
|---|---|---|
| **Ellipsis zorunluluğu** | *"kırpma SESSİZ olmasın"* — son çare göstergesi | `a11y_statik_tasma_test.dart` (statik) |
| **Kırpma yasağı** | *"kırpma HİÇ OLMASIN"* — tasarım hedefi | **`G13` (bu spec, yeni)** |

**Ellipsis'in varlığı bir başarı ölçüsü değildir; bir emniyet ağıdır.** İkisi de kalır: statik kapı ağın
delinmediğini, `G13` ağa hiç düşülmediğini ölçer.

### 1.3 🔴 ÜÇÜNCÜ ÖLÇÜM: KUSURUN MEKANİZMASI KODDA GÖRÜNÜR

`src/client/lib/sunum/gorev_satiri.dart:47‑68`:

```dart
Expanded(child: Text(gorev.baslik, ..., overflow: TextOverflow.ellipsis)),   // flex: 1, TIGHT
SizedBox(width: MBosluk.s),
if (cakismaVarMi) ...[ const CakismaRozeti(), SizedBox(width: MBosluk.xs) ], // 48dp SABİT
Flexible(child: SenkronRozeti(durum: senkronDurumu)),                        // flex: 1, LOOSE
```

Başlık `Expanded` (tight, flex 1), rozet `Flexible` (loose, flex 1) ⇒ kalan boşluk **eşit** bölünür.
Rozet metni (`MTipo.etiketS`, 13 px) 2.0×'te **26 px**'e çıkar; *"Çevrimdışısınız. Değişiklikler
kaydedildi."* gibi bir dizge o paya **hiçbir dar ekranda** sığmaz ⇒ `SenkronRozeti._rozet`'in
`Flexible(Text(..., ellipsis))`'i kırpar. **Bileşik satırda** (`cakismaVarMi == true`) sabit 48dp'lik
`CakismaRozeti` + `MBosluk.xs` daha da yer alır ⇒ pay küçülür, kırpma kesinleşir.

---

## 2. KAPSAM

**DAHİL:**
1. `G13` — kırpma ölçümü (`RenderParagraph` intrinsic genişliği; Onur'un kilidi, şık 1).
2. `G14` — dar alanda **dikey dönüş** (Onur'un kilidi, şık 2) + geniş alanda yatay kalma (yanlış‑pozitif).
3. `G15` — **bileşik satır** (çakışma + taban yan yana) ve dikeyde **A11Y‑1 (48dp)** korunması.
4. `M74`–`M81` mutantları (statik + widget ⇒ **tavansız**, K53/3) ve `CM1`–`CM3` cihaz mutantları (**tavan 3**).
5. `DurumVitrini`'ne **bileşik satır örneği** (çakışma + `gonderilmemis`) — hem PNG hem widget testi için tek kaynak.

**HARİÇ (bilinçli, gerekçeli):**
- 🔴 **`content-desc` çift okuma** (`Semantics(label:)` + `Text` çocuğu ⇒ ekran okuyucu tekrar okur).
  Onur bunu **bu dilimden çıkardı**; borç `BORCLAR.md`'de **açık kalır**. Bu dilimde ona dokunulmaz.
- **Başlık metninin kırpılması KABUL EDİLİR.** Gerekçe: dikey dönüşten sonra başlık **tam satır genişliği**
  alır; buna rağmen sığmayan başlık ellipsis ile kırpılır ve bu bilgi kaybı **değildir** (görevin kimliği
  bağlamdan ve dokunmayla açılan içerikten okunur), oysa *"Gönderilmemiş de…"* **anlamsızdır**. `G13`
  bu yüzden **yalnız rozet alt ağacını** ölçer — beyan edilmiş sınır, §8/S1.
- **Web ayağı.** `flutter test --platform chrome` bu ortamda sonuç üretmiyor (iki ölçüm: 7 dk ve 9,8 dk)
  ⇒ web `[DOĞRULANMADI]` kalır. `textScaler` davranışı web'de farklı olabilir (`DESIGN.md` A‑5).
- **iOS.** Mac yok ⇒ CI‑only.
- **Yeni token.** `K46` gereği `DESIGN.md`'ye **tek bayt yazılmaz** ⇒ eşik **mevcut** token'lardan türetilir
  (`MOlcu.dokunmaHedefi`, `MOlcu.ikon`, `MBosluk.*`). Yeni `MOlcu` sembolü eklemek `design-token-kapisi.py`
  `D1`/`D3` yüzeyini büyütür ve K46'yı açar — **YASAK**.

---

## 3. ORTAM — **BUILDER KALDIRIR, COWORK ÖLÇER** [K80, PAZARLIKSIZ]

`CM1`–`CM3` cihaz kanıtı ister. Builder şu sırayı **kendi** kaldırır ve her adımı **koşula kadar yoklar**
(🔴 **sabit `sleep` bir ölçüm değildir** — oturum 35'te 22 sn beklenip yanlış KIRMIZI verildi):

1. **Emülatör:** `flutter emulators --launch <avd>` ya da `emulator.exe -avd <avd>`; ardından
   `adb devices` çıktısında `device` durumu **görülene kadar** yoklanır (tavan: 180 sn, yoklama 3 sn).
2. **`flutter run -d <cihaz>`** ile `DurumVitrini` açılır.
3. 🟢 **`docker` ve backend BU DİLİMDE GEREKMEZ — beyan edilmiş sadeleştirme.** Gerekçe ölçüldü:
   `DurumVitrini` rozet durumlarını **sentetik** kurar (`vitrin/durum_vitrini.dart`), yani A‑7 görünümü
   canlı sunucu olmadan üretilebilir. **Bu bir istisna değil, kapsam ölçümüdür:** eğer builder bileşik
   satırı canlı veriyle üretmeyi seçerse **o zaman** `docker start momentum-postgres` (healthy görülene
   kadar yoklanır) → backend ayrı süreçte **`ASPNETCORE_ENVIRONMENT=Development` AÇIKÇA set edilerek**
   (yoksa `NullCurrentUser` ⇒ her istek **401**, K61) sırası **zorunlu** hâle gelir.
4. 🔴 **PID, cihaz adı ve "çalışıyor" beyanı hiçbir belgeye YAZILMAZ — ÖLÇÜLÜR** (`adb devices`,
   `docker ps`, `netstat -ano | findstr :5298`). Kanıt dosyası **ölçüm çıktısını** taşır, beyanı değil.

---

## 4. ÜRÜN DEĞİŞİKLİĞİ — TASARIM KİLİDİ

### D‑A7‑1 · Metin eşlemesi dışa açılır (tek kaynak korunur)

`SenkronRozeti`'ne **`static String? metinIcin(SenkronDurumTuru durum)`** eklenir; `build` **aynı**
fonksiyonu kullanır (kopya eşleme **YASAK** — `M77b` bunu ısırtır). `senkronize` için `null` döner
(o durumda rozet çizilmez: `SizedBox.shrink`, gürültü azaltma). Metin sabitleri **`metinler.dart`'ta
kalır** — `a11y_statik_tasma_test.dart`'ın F6 ham‑literal kapısı bozulmaz.

### D‑A7‑2 · Dikey dönüş eşiği (`GorevSatiri`, `LayoutBuilder`)

`build`, `LayoutBuilder` ile sarılır ve şu **ölçümü** yapar (tahmin yok, hepsi token veya ölçüm):

```
rozetMetni      = SenkronRozeti.metinIcin(senkronDurumu)            // null ⇒ dönüş GEREKMEZ
rozetMetinGen   = TextPainter(TextSpan(rozetMetni, MTipo.etiketS),
                              textScaler: MediaQuery.textScalerOf(context),
                              textDirection: TextDirection.ltr,
                              maxLines: 1)..layout()  ⇒ .maxIntrinsicWidth   // dispose() ZORUNLU
rozetIstedigi   = rozetMetinGen + MOlcu.ikon + MBosluk.xs
sabitler        = MOlcu.dokunmaHedefi + MBosluk.s + MBosluk.s
                  + (cakismaVarMi ? MOlcu.dokunmaHedefi + MBosluk.xs : 0)
baslikAsgari    = MOlcu.dokunmaHedefi * 2                            // 96dp — YENİ TOKEN DEĞİL, katı
DIKEY  ⇔  sabitler + baslikAsgari + rozetIstedigi > constraints.maxWidth
```

**Dikey düzen** (`DIKEY == true`):

```
Row(
  Semantics(label: baslik, Checkbox(...)),          // 48dp dokunma hedefi KORUNUR
  SizedBox(width: MBosluk.s),
  Expanded(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(baslik, style: MTipo.govdeM..., overflow: TextOverflow.ellipsis),
      SizedBox(height: MBosluk.xs),
      Row(mainAxisSize: MainAxisSize.min, children: [
        if (cakismaVarMi) ...[ const CakismaRozeti(), SizedBox(width: MBosluk.xs) ],
        Flexible(child: SenkronRozeti(durum: senkronDurumu)),
      ]),
    ])),
)
```

**Yatay düzen** (`DIKEY == false`): bugünkü ağaç **birebir korunur** (regresyon yüzeyi sıfır).

🔴 **`overflow: TextOverflow.ellipsis` HER `Text`'te KALIR.** Dikey dönüş kırpmayı *gereksiz* kılar,
`ellipsis` ise *emniyet ağıdır* (§1.2). Kaldırmak `a11y_statik_tasma_test.dart`'ı kırar — `M80` bunu ısırtır.

---

## 5. KAPILAR

### G13 · KIRPMA ÖLÇÜMÜ — ROZET METNİ SIĞMIYORSA KAPI ISIRIR

**Dosya:** `src/client/test/g13_rozet_tasma_kapisi_test.dart` · **tür:** widget testi (cihaz istemez).

**Ölçüm ayağı (Onur'un kilidi, şık 1):** her rozet `Text` düğümünün render nesnesi alınır ve
**intrinsic genişliği kendi ayrılmış genişliğiyle** karşılaştırılır:

```dart
final rp = tester.renderObject<RenderParagraph>(find.descendant(
    of: find.byType(SenkronRozeti), matching: find.byType(Text)));
final istenen = rp.getMaxIntrinsicWidth(double.infinity);
expect(istenen, lessThanOrEqualTo(rp.size.width + G13_TOLERANS),
       reason: 'rozet metni KIRPILDI: istenen=$istenen, ayrılan=${rp.size.width}');
```

**`G13_TOLERANS = 0.5` — dosyada `const` olarak KİLİTLİ.** Gerekçe: yalnız kayan nokta yuvarlamasını
soğurur. `M81` toleransı gevşetmenin kapıyı körleştirdiğini ısırtır.

| ayak | ölçüm | beklenen |
|---|---|---|
| **A1** | `textScale ∈ {1.0, 1.5, 2.0}` × `genişlik ∈ {320, 360, 411}` × `durum ∈ {yerel, kuyrukta, cevrimdisi, gonderilmemis}` × `cakismaVarMi ∈ {false, true}` — **96 kombinasyon**, hepsinde rozet `Text` intrinsic ≤ ayrılan | kırpma **YOK** |
| **A2** | `senkronize` durumunda rozet çizilmez (`SizedBox.shrink`) ⇒ ölçülecek `Text` **yok**, kapı **susar** ama *"ölçtüm"* de **demez** (`skip` değil, açık `isEmpty` beyanı) | boş küme, hüküm YOK |

### G14 · DİKEY DÖNÜŞ — DAR ALANDA İNER, GENİŞ ALANDA İNMEZ

**Dosya:** `src/client/test/g14_dikey_donus_kapisi_test.dart` · **tür:** widget testi.

| ayak | ölçüm | beklenen |
|---|---|---|
| **A4** | `320dp` + `2.0×` + `gonderilmemis` ⇒ `GorevSatiri` altında `Column` **VAR** | **DİKEY** |
| **A5** | `800dp` + `1.0×` + `yerel` ⇒ `GorevSatiri` altında `Column` **YOK** (yanlış‑pozitif kontrolü) | **YATAY** |
| **A6** | Eşik **deterministik**: aynı girdi iki kez `pump` edilince aynı düzen (titreme yok) | kararlı |
| **A7** | `senkronize` (metin `null`) ⇒ `320dp` + `2.0×`'te bile **YATAY** kalır (ölçülecek metin yok) | **YATAY** |
| **A8** | **STATİK:** `lib/sunum` altındaki her `TextPainter(` çağrısının aynı gövdesinde `.dispose()` bulunur (kaynak taraması, `a11y_statik_tasma_test.dart` deseni) | eşleşme tam |

### G15 · BİLEŞİK SATIR + A11Y‑1 (48dp) DİKEYDE DE KORUNUR

**Dosya:** `src/client/test/g15_bilesik_satir_kapisi_test.dart` · **tür:** widget testi.

| ayak | ölçüm | beklenen |
|---|---|---|
| **A9** | `cakismaVarMi=true` + `gonderilmemis`, `320dp`, `2.0×` ⇒ **her iki rozet de** ağaçta (`CakismaRozeti` **ve** `SenkronRozeti`) | ikisi de var |
| **A10** | Aynı kurulumda `Checkbox` ve `CakismaRozeti` dokunma hedefi **≥ `MOlcu.dokunmaHedefi`** (`tester.getSize`) | ≥ 48dp |
| **A11** | **A11Y‑6:** dikey düzende rozet **görünür metin düğümü KORUNUR** (`Text` bulunur) — metin gizlenerek çözüm **YASAK** | `Text` var |
| **A12** | **A11Y‑7 regresyonu:** durum geçişinde `SemanticsService.sendAnnouncement` bir kez çağrılır (`G11` davranışı **bozulmamış**) | 171/171 korunur |

---

## 6. MUTANTLAR

Statik + widget mutantları **tavansız** (K53/3 — saniyeler sürer). Cihaz mutantları **tavan 3**.

| # | mutasyon | ısırması BEKLENEN | tür |
|---|---|---|---|
| **M74** | `LayoutBuilder` kaldırılır, düz `Row` bırakılır (bugünkü kod) | `G13/A1` **ve** `G14/A4` | widget |
| **M75** | `baslikAsgari = 0` (eşik gevşetilir) | `G13/A1` (320dp/2.0×'te kırpma döner) | widget |
| **M76** | `DIKEY` daima `true` (eşik hep tetikler) | `G14/A5` (geniş ekranda yatay olmalı) | widget |
| **M77** | `TextPainter`'a `textScaler` verilmez (1.0× varsayılır) | `G13/A1` yalnız `2.0×` sütununda | widget |
| **M77b** | `metinIcin` yerine `build` içinde **kopya** eşleme yazılır ve biri değiştirilir | `G14/A4` (eşik yanlış dizgeyle ölçer) | widget |
| **M78** | Rozet metni `Text` yerine yalnız `Semantics(label:)` yapılır (metin gizlenir) | `G15/A11` | widget |
| **M79** | Dikey düzende `CakismaRozeti` düşürülür | `G15/A9` | widget |
| **M80** | `overflow: TextOverflow.ellipsis` kaldırılır | **`a11y_statik_tasma_test.dart`** (mevcut kapı) — §1.2 ayrımının kanıtı | statik |
| **M81** | `G13_TOLERANS = 0.5` → `100.0` | `M74` ile **birlikte** koşulur: gevşek tolerans `A1`'i **körleştirir** ⇒ bu mutant kapının **kendi eşiğini** kilitler | widget |
| **M82** | `Checkbox` dikey düzende `SizedBox(width: 24)` içine alınır | `G15/A10` (48dp) | widget |
| **M83** | `gorev_satiri.dart`'taki `TextPainter` `dispose()` satırı silinir | `G14/A8` (statik tarama) | statik |
| **CM1** | Cihazda `320dp` genişlik + sistem yazı tipi ölçeği **2.0×** (`adb shell settings put system font_scale 2.0`), `DurumVitrini` bileşik satırı ⇒ **PNG**: rozet metni **tam** görünür | görsel kanıt | cihaz |
| **CM2** | Aynı cihazda `font_scale 1.0` ⇒ **PNG**: düzen **yatay** (dönüşün koşullu olduğunun kanıtı) | görsel kanıt | cihaz |
| **CM3** | Cihazda dikey düzende `CakismaRozeti`'ne dokunulur ⇒ çözüm sayfası açılır (48dp hedef **gerçekten** dokunulabilir) | etkileşim kanıtı | cihaz |

> 🔴 **`font_scale` ayarı test SONUNDA `1.0`'a GERİ ALINIR** — bırakılan sistem ayarı sonraki dilimin
> ölçümünü sessizce bozar (bu projede *"bayat ortam"* sınıfı üç kez ısırdı).

## 6b. MUTANT BORCU

**YOK — bu spec'te mutantsız kural bırakılmadı.** İlk taslakta iki borç yazılıydı; **ölçüm ikisini de
gereksiz kıldı:** ① `G14/A8` (`TextPainter.dispose`) *"sızıntı raporlaması deterministik değil"* diye
borçlanmıştı — ayak **statik kaynak taramasına** çevrildi ve `M83` ile deterministik hâle geldi;
② `G13/A3` (`CakismaRozeti` metin taşımaz) bir **kapsam beyanıydı**, kapı ayağı değil ⇒ §8/S8'e taşındı.
🔴 **Ölçülmüş ders:** ilk taslak bu bölümü **tablo** olarak yazmıştı; `spec-kapi-kapsama.py` yalnız
`- KURAL: <ad> | GEREKCE: <...>` **satır biçimini** okur ⇒ borç beyanı **hiç ayrıştırılmadı** ve araç
sessizce *"borç yok"* saydı. Bu **K81'in aynı sınıfı** (aracın kabul etmediği belge biçimi) ve kusur
spec'i yazan eldedir. Bugün borç olmadığı için zarar doğmadı; **borç yazılacak olsaydı sessizce kaybolurdu.**

## 7. KABUL KRİTERLERİ (sırayla; her biri **ölçüm çıktısıyla** kanıtlanır)

1. `cd src/client && flutter analyze --fatal-infos` ⇒ **0** sorun.
2. `flutter test` ⇒ **mevcut 171 test BOZULMAZ** + `G13`/`G14`/`G15` yeşil. Toplam sayı **çıktıdan okunur**,
   ezberden yazılmaz (`sayi-tazeligi.py` bu sınıfı ölçüyor).
3. `M74`–`M82` **tek tek** uygulanır, ilgili kapının **ısırdığı** ölçülür, mutasyon **geri alınır**.
   Her mutant için `KANIT/A7/06-MUTANT/M<n>.txt` → mutasyon farkı + **başarısız test çıktısı**.
4. `M80` koşulurken **`a11y_statik_tasma_test.dart`** ısırmalı (mevcut kapı) — §1.2 ayrımının kanıtı.
5. **Ortam** §3'e göre builder tarafından kaldırılır; `adb devices` çıktısı `KANIT/A7/00-ortam.txt`.
6. `CM1`–`CM3` PNG/çıktıları `KANIT/A7/07-CIHAZ/`. **`font_scale` geri alındığı ölçülür** (`adb shell
   settings get system font_scale` ⇒ `1.0`).
7. `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-A7-rozet-tasma.md` ⇒ **kapsama tam**
   (borçlar §6b'de gerekçeli). 🔴 Araç **dizin kabul etmez** — **spec dosyasının yoluyla** çağrılır (K81).
8. `python araclar\design-token-kapisi.py .` ⇒ `D0`–`D6` **yeşil**; **yeni token eklenmediği** ölçülür (K46).
9. `python araclar\iddia-kapisi.py .` ⇒ bu spec'in beyan ettiği her mutantın **ham kanıtı** `KANIT/A7/`
   altında bulunur. 🔴 **Bilinen yanlış‑pozitif:** araç ikili dosyaları metin gibi tarıyor (`BORCLAR.md`)
   ⇒ PNG'lerden **hayalet kanıt** üretebilir; bu **beklenen** ve raporda **ayrıca beyan edilir**.
10. Kapanışta `DURUM.md` §3 ve `DESIGN.md` A‑7 satırı **ölçülen** sonuca göre güncellenir. `DESIGN.md`
    değişikliği **K46 kapsamındadır** ⇒ **Onur'un ayrı kilidi olmadan `DESIGN.md`'ye tek bayt YAZILMAZ**;
    yazılamıyorsa A‑7 *"kapandı"* **denmez**, `BORCLAR.md`'de **ölçüldü/kapanmadı** olarak durur.

---

## 8. BEYAN EDİLMİŞ SINIRLAR (gizlenmiş sınır kabul edilmez — §4/K40)

- **S1 · `G13` yalnız rozet alt ağacını ölçer.** Başlık `Text`'i **kapsam dışıdır** (§2 gerekçesi).
  Uzun başlık 2.0×'te hâlâ kırpılır ve bu **kabul edilmiştir**.
- **S2 · `RenderParagraph.getMaxIntrinsicWidth` bir Flutter render API'sidir.** Sürüm yükseltmesinde
  davranışı değişebilir; kapı o zaman **kırılır ve bu görünür olur** (sessizleşmez). Alternatif ayak
  (`didExceedMaxLines`) `maxLines` zorunluluğu getirdiği için **reddedildi** (Onur'un kilidi).
- **S3 · Widget testi cihazın yazı tipini kullanmaz.** `flutter_test` varsayılan test fontu (Ahem benzeri)
  taşır ⇒ intrinsic genişlikler **cihazdakiyle birebir aynı değildir**. Bu yüzden `CM1`/`CM2` **cihazda**
  ölçülür; `G13` **eşiğin doğru tarafta** olduğunu, cihaz mutantı **gerçek görünümü** kanıtlar. İkisi
  birbirinin yerine geçmez.
- **S4 · `320/360/411dp` kümesi bir ÖRNEKLEMDİR**, tüm cihaz genişliklerinin kanıtı değildir. 411dp
  yaygın bir Android genişliği, 320dp pratik alt sınır olarak seçildi; **ara değerler ölçülmedi.**
- **S5 · Web `[DOĞRULANMADI]`** (§2). `textScaler` ve font çözümü web'de farklı olabilir (`DESIGN.md` A‑5).
- **S6 · `content-desc` çift okuma bu dilimde ÇÖZÜLMEZ** ve `G15/A11` onu **maskeleyebilir**: A11Y‑6 için
  *"görünür metin korunuyor"* derken, aynı metnin `Semantics(label:)`'da **ikinci kez** bulunduğunu
  ölçmez. Borç `BORCLAR.md`'de **açık**.
- **S7 · `baslikAsgari = MOlcu.dokunmaHedefi * 2` (96dp) bir TASARIM SEÇİMİDİR**, ölçülmüş bir eşik
  değildir. Mevcut token'ın katı olarak yazıldı çünkü K46 yeni token yasağı yürürlükte. Eşiğin *doğru*
  değeri `CM1`/`CM2` PNG'leriyle **sınanır**; yanlışsa düzeltme **Onur'un kilidini** ister.

---

## 9. KANIT DİZİNİ

```
KANIT/A7/
  00-ortam.txt          adb devices + (varsa) docker ps + netstat ÖLÇÜMÜ
  00-OLCUM-kor-kapi.txt Cowork'un §1.1.1 olcumu (kor kapi kaniti) -- builder BU DOSYAYI SILMEZ
  01-analyze.txt        flutter analyze --fatal-infos
  02-test.txt           flutter test (toplam sayı ÇIKTIDAN)
  05-KAPI/              G13 / G14 / G15 koşum çıktıları
  06-MUTANT/            M74..M82 — mutasyon farkı + BAŞARISIZ test çıktısı
  07-CIHAZ/             CM1..CM3 PNG + adb font_scale get/put kayıtları
  09-HUKUM.md           madde madde PASS/FAIL + net karar
```

🔴 **Büyük ham çıktı dosyası (>200 KB) KANIT'a YAZILMAZ** — kesit + `sha256` yeterlidir
(`BORCLAR.md`: 1,9 MB ve 2 MB'lık iki dosya portfolyo yükü olarak kayıtlı).

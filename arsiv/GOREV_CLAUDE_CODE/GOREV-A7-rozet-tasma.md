# GOREV-A7 — ROZET METİN TAŞMASI + 2.0× ÖLÇEK AYAĞI (A11Y‑4) · **v4**

> **v4 — 30 Tem 2026.** v3, **bağımsız denetimde (K26) BLOKER aldı** ve iki temel kararı değişti.
> Değişim tarihçesi §1.2'de; **v1–v3 GEÇERSİZDİR.**
> **Kilit:** Onur — K83/③ + v1'in üç şıkkı + v4'ün iki şıkkı (§1.2.3).
> **Rol:** spec'i **Cowork** yazdı, denetimi **Claude Code** yaptı (ayrı el, K26), build **Claude Code**'da.
> **Biçim:** K81 — kapılar `## 5. KAPILAR` altında `### G<n>`, mutantlar `## 6. MUTANTLAR` altında.

---

## 1. AMAÇ VE ÖLÇÜLMÜŞ GEREKÇE

`DESIGN.md` açık kalemi **A‑7**: *"İki rozet yan yana durumunda A11Y‑4 (2.0× ölçek) ve A11Y‑1 (48dp)
yeniden ölçülmedi — dar ekranda taşma [DOĞRULANMADI]"*. Oturum 37 cihaz PNG'lerinde taban rozet metni
**1.0× ölçekte BİLE** kırpılmış görüldü.

### 1.1 KÖK NEDEN: MEVCUT A11Y‑4 KAPISI KÖRDÜR [ölçüldü, iki bağımsız el teyit etti]

`src/client/test/a11y_kapisi_test.dart:274` gövdesi tek `expect`'tir:
`expect(tester.takeException(), isNull)`. **`TextOverflow.ellipsis` FlutterError ATMAZ** ⇒ kapı
*"düzen patladı mı?"* sorar, `DESIGN.md`'nin yasakladığı **kırpmayı** hiç sormaz.

**Koşarak ölçüldü** (`KANIT/A7/00-OLCUM-kor-kapi.txt`, Cowork): gerçek 320dp ekranda + 2.0×'te metin
**1102,50 px** istiyor, **104,00 px** alıyor, `takeException()` ⇒ **`null`**. Rozet metninin
**%90'ından fazlası görünmüyor** ve kapı hiçbir şey söylemiyor.
**Bağımsız teyit** (`KANIT/A7/01-DENETIM.md` §3, Claude Code): aynı sayı **birebir** üretildi; ayrıca
*"belki bu kırpma değil sarmadır"* hipotezi **üç ayrı probla çürütüldü** — metin gerçekten tek satıra
sıkışıyor. **Kör kapı iddiası iki elden geçti ve güçlendi.**

### 1.2 🔴 v3'ÜN ÇÖZÜMÜ YETERSİZDİ — BAĞIMSIZ DENETİM BLOKER BULDU

#### 1.2.1 Bulgu (Claude Code, `01-DENETIM.md` §1)

v3'ün tek ürün çözümü **dikey dönüştü**. Denetim, D‑A7‑2 formülünü birebir uygulayıp 72 kombinasyonu
hesapladı: **61'i (%85) hâlâ kırpılıyor.** Aritmetik basit ve v3'te **hiç yapılmamıştı** — dikey dönüş
rozete en fazla `maxWidth − 56 ≈ 264–355 px` verir, `cevrimdisi` dizgesi 2.0×'te **1102,5 px** ister.
Dikey dönüş *"yarım kırpma"*yı *"biraz daha az kırpma"*ya çevirir, **"kırpma yok"a değil.**

🔴 **Bu Cowork'ün kusurudur ve sınıfı adlandırılmıştır: ÇÖZÜMÜN YETERLİLİĞİ ÖLÇÜLMEDİ.** v3 sorunu
ölçtü (104 px kalıyor), çözümün o sorunu kapatıp kapatmadığını **hesaplamadı**. Bir bölme işlemiydi.

#### 1.2.2 Cowork'ün doğrulaması — altı varyant, aynı koşulda (264 px alan, 2.0×, aynı dizge)

| varyant | yükseklik | satır | `didExceedMaxLines` | `intrinsic` |
|---|---|---|---|---|
| **A** `maxLines: null` + ellipsis **(v3'ün varsaydığı kod)** | 36,0 | 1,0 | 🔴 **true** | 1102,5 |
| **B** `maxLines: 10` + ellipsis | 216,0 | 6,0 | 🟢 **false** | 1102,5 |
| **C** `maxLines: 3` + ellipsis | 108,0 | 3,0 | 🔴 true | 1102,5 |
| **D** `maxLines: null`, overflow YOK | 216,0 | 6,0 | false | 1102,5 |
| **E** kısa dizge *"Çevrimdışı"* + `maxLines: 10` | 72,0 | 2,0 | 🟢 **false** | 262,5 |
| **F** gerçek `Row`+`Flexible` + `maxLines: 10` | 216,0 | 6,0 | 🟢 **false** | — |

**Üç sonuç:**
1. **A doğrular denetimi:** `maxLines: null` + `ellipsis` metni tek satıra indiriyor (bu Flutter
   sürümünde `ellipsis`, `maxLines` verilmemişse fiilen `maxLines: 1` gibi davranıyor).
2. **B/F kırpmayı kapatıyor** (`didExceedMaxLines = false`) ve `ellipsis` yerinde kaldığı için
   `a11y_statik_tasma_test.dart` de geçer — ama bedeli **6 satır / 216 px**.
3. 🔴 **`intrinsic` HER varyantta 1102,5** — B/D/F'de kırpma **yokken** de. Yani v3'ün ölçüm ayağı
   **sarmayı kırpma sanıyor**; her sarma çözümünü yanlış‑pozitifle reddederdi.

#### 1.2.3 Onur'un v4 kilitleri (30 Tem 2026)

| # | v3 (geçersiz) | **v4 (yürürlükte)** |
|---|---|---|
| ölçüm ayağı | `intrinsic <= size + 0.5` | **`didExceedMaxLines == false` hüküm verir**; `intrinsic`/`size` yalnız **teşhis için raporlanır**. `G13_TOLERANS` **kaldırıldı** (boolean eşik istemez). |
| ürün çözümü | yalnız dikey dönüş | **kısa görünür dizge + `maxLines` + tam metin `Semantics(label:)`'da** (dikey dönüş **korunur** ama tek başına yeterli sayılmaz). |

🔴 **v3 §8/S2 `didExceedMaxLines`'ı *"maxLines zorunluluğu getirdiği için"* reddetmişti. Ölçüm bunu
çürüttü:** `maxLines` çözümün **parçası**, engeli değil. Reddin gerekçesi yanlıştı.

### 1.3 DOKTRİN ÇELİŞKİSİ GERÇEKTİ — v3'ÜN "ÇELİŞMİYOR" DEĞERLENDİRMESİ YANLIŞTI

v3 §1.2 *"iki kural çelişmiyor, sadece ayrılmamış"* diyordu. Ölçüm gösterdi ki `overflow: ellipsis`
**`maxLines` verilmediğinde sarmayı fiilen engeller** ⇒ statik kapının ellipsis zorunluluğu, kırpma
yasağıyla **doğrudan çatışıyordu**. Kanonik ayrım (v4):

| kural | ne ölçer | kapı |
|---|---|---|
| **`overflow: ellipsis` zorunlu** | *"kırpma SESSİZ olmasın"* (M16: `clip` sessizdir) | `a11y_statik_tasma_test.dart` |
| **`maxLines` AÇIKÇA verilir** | *"ellipsis sarmayı öldürmesin"* — **v4'te doğdu** | **`G13/A3`** |
| **kırpma yasağı** | *"kırpma HİÇ OLMASIN"* | **`G13/A1`** (`didExceedMaxLines`) |

**Üçü birlikte tutarlıdır; ilk ikisi tek başına çatışır.** Eksik halka `maxLines`'tı.

### 1.4 MEKANİZMA (kodda görünür)

`gorev_satiri.dart:47‑68` — başlık `Expanded` (tight, flex 1), rozet `Flexible` (loose, flex 1) ⇒
kalan boşluk **eşit** bölünür. `senkron_rozeti.dart:134‑139` — `Flexible(Text(..., ellipsis))`,
**`maxLines` YOK** ⇒ tek satır + kırpma.

---

## 2. KAPSAM

**DAHİL:**
1. `G13` kırpma kapısı (`didExceedMaxLines`) · `G14` dikey dönüş · `G15` bileşik satır + A11Y‑1/6/7.
2. **F6 görünür dizgelerinin kısaltılması** (§4/D‑A7‑1) — üç dosyada **eşzamanlı**: `metinler.dart` ·
   `araclar/fixture/metinler-kilit.json` · `a11y_kapisi_test.dart`'ın gömülü `_fixtureGorunur` haritası.
3. 🔴 **`content-desc` ÇİFT OKUMA — v4'te KAPSAMA GİRDİ.** v3'te Onur bunu hariç tutmuştu; **kısa dizge
   kararı onu zorunlu kıldı:** görünür metin ile `Semantics(label:)` artık **farklı** dizgeler taşıyor
   ⇒ `ExcludeSemantics` olmadan ekran okuyucu *"Çevrimdışısınız. Değişiklikler kaydedildi. Çevrimdışı"*
   diye **iki kez** okur. Bu, hariç tutulan borcun **kötüleşmiş hâli** olurdu. Çözüm tek satırlıktır
   (§4/D‑A7‑1) ve **eski borcu da kapatır**.
4. `M74`–`M86` (statik/widget ⇒ **tavansız**, K53/3) + `CM1`–`CM3` (cihaz ⇒ **tavan 3**).
5. `DurumVitrini`'ne bileşik satır örneği (çakışma + `gonderilmemis`).

**HARİÇ (bilinçli, gerekçeli):**
- **Başlık metninin kırpılması KABUL EDİLİR.** `G13` yalnız **rozet alt ağacını** ölçer (§8/S1).
- **Web ayağı** — `flutter test --platform chrome` bu ortamda sonuç üretmiyor ⇒ `[DOĞRULANMADI]`.
- **iOS** — Mac yok, CI‑only. · **RTL** — uygulama genelinde yok; bu spec yeni bir RTL kusuru açmıyor
  ama RTL desteği **bu dilimin konusu değil** (`01-DENETIM.md` §7).
- **Yeni token** — K46: `DESIGN.md`'ye tek bayt yazılmaz; eşik mevcut token'lardan türetilir.

---

## 3. ORTAM — **BUILDER KALDIRIR, COWORK ÖLÇER** [K80, PAZARLIKSIZ]

1. **Emülatör:** `flutter emulators --launch <avd>`; `adb devices` çıktısında `device` **görülene kadar**
   yoklanır (tavan 180 sn, 3 sn aralık). 🔴 **Sabit `sleep` bir ölçüm değildir.**
2. `flutter run -d <cihaz>` ile `DurumVitrini`.
3. 🟢 **docker + backend BU DİLİMDE GEREKMEZ** — `DurumVitrini` rozet durumlarını **sentetik** kurar.
   Canlı veri seçilirse: `docker start momentum-postgres` (healthy görülene kadar yoklanır) → backend
   ayrı süreçte **`ASPNETCORE_ENVIRONMENT=Development` AÇIKÇA set** (yoksa her istek **401**, K61).
4. 🔴 **PID / cihaz adı / "çalışıyor" beyanı hiçbir belgeye YAZILMAZ — ÖLÇÜLÜR.**

---

## 4. ÜRÜN DEĞİŞİKLİĞİ — TASARIM KİLİDİ (Onur, v4)

### D‑A7‑1 · Görünür dizge KISALIR, tam metin `Semantics`'te kalır, çift okuma `ExcludeSemantics` ile biter

**Ölçülmüş bütçe:** dikey dönüşten sonra 320dp ekranda rozet metnine **236 px** kalır; hedef 2.0×'te
**en fazla 2 satır**. Aşağıdaki sayılar `flutter_test` fontuyla **ölçüldü** (tahmin yok):

| durum | görünür metin (**YENİ**) | intrinsic @2.0× | satır | `Semantics(label:)` — **tam metin, DEĞİŞMEZ** |
|---|---|---|---|---|
| `yerel` | **"Bu cihazda"** | 262,5 | 2,0 | "Yalnızca bu cihazda" *(498,8 → 3 satır)* |
| `kuyrukta` | "Gönderiliyor" **(değişmez)** | 315,0 | 2,0 | "Gönderiliyor" |
| `cevrimdisi` | **"Çevrimdışı"** | 262,5 | 2,0 | "Çevrimdışısınız. Değişiklikler kaydedildi." *(1102,5 → 6 satır)* |
| `gonderilmemis` | **"Gönderilmedi"** | 315,0 | 2,0 | "Gönderilmemiş değişiklik" *(630,0 → 3 satır)* |

Reddedilen adaylar (**ölçüldü, 3 satır**): "Çevrimdışı kaydedildi" 551,3 · "Yalnız bu cihazda" 446,3.

**Uygulama:**
```dart
Semantics(
  label: tamMetin,                       // F6 dizgesi — DEĞİŞMEZ, ekran okuyucu bunu okur
  child: Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(...),
    SizedBox(width: MBosluk.xs),
    Flexible(child: ExcludeSemantics(     // ÇİFT OKUMAYI BİTİREN SATIR
      child: Text(kisaMetin, style: MTipo.etiketS.copyWith(color: renk),
                  maxLines: MAX_SATIR, overflow: TextOverflow.ellipsis),
    )),
  ]),
)
```
`SenkronRozeti`'ne **`static String? metinIcin(SenkronDurumTuru)`** (görünür kısa metin) ve
**`static String? tamMetinIcin(SenkronDurumTuru)`** eklenir; `build` **aynı** fonksiyonları kullanır —
kopya eşleme **YASAK** (`M77b`). Her iki dizge de **`metinler.dart`'ta** yaşar (F6 tek kaynak kuralı).

### D‑A7‑2 · `maxLines` AÇIKÇA verilir

`MAX_SATIR = 3`, `senkron_rozeti.dart`'ta **`const`**. Gerekçe **ölçülmüş**: yeni dizgelerin hepsi
236 px'te **2 satır**; 3 bir emniyet payıdır (cihaz fontu test fontundan geniş ölçebilir — §8/S3).
`overflow: TextOverflow.ellipsis` **KALIR** — 3 satır da yetmezse kırpma **görünür** olur ve `G13`
ısırır. 🔴 **`maxLines`'ı kaldırmak `ellipsis`'i tek satıra indirir** (varyant A) — `M84` bunu ısırtır.

### D‑A7‑3 · Dikey dönüş (v3'ten korundu, ama artık **tek** çözüm değil)

`GorevSatiri` `LayoutBuilder` ile sarılır:
```
rozetIstedigi = TextPainter(kisaMetin, MTipo.etiketS, textScaler: MediaQuery.textScalerOf(context),
                            maxLines: 1)..layout() ⇒ .maxIntrinsicWidth
                + MOlcu.ikon + MBosluk.xs                       // dispose() ZORUNLU
sabitler      = MOlcu.dokunmaHedefi + MBosluk.s + MBosluk.s
                + (cakismaVarMi ? MOlcu.dokunmaHedefi + MBosluk.xs : 0)
baslikAsgari  = MOlcu.dokunmaHedefi * 2                          // 96dp — yeni token DEĞİL
DIKEY ⇔ sabitler + baslikAsgari + rozetIstedigi > constraints.maxWidth
```
Dikey düzende başlık üstte, rozet satırı altta (`Column`, `crossAxisAlignment: start`); `Checkbox` ve
`CakismaRozeti` kendi 48dp'lerini korur. **Amacı kırpmayı önlemek değil** (onu `D‑A7‑1`+`D‑A7‑2`
yapıyor), **satır yüksekliğini düşürmektir**: rozet tam genişlik alınca 2 satır yerine 1 satıra sığar.

---

## 5. KAPILAR

### G13 · KIRPMA KAPISI — `didExceedMaxLines`

**Dosya:** `src/client/test/g13_rozet_tasma_kapisi_test.dart` · **tür:** widget testi (cihaz istemez).

```dart
final rp = tester.renderObject<RenderParagraph>(find.descendant(
    of: find.byType(SenkronRozeti), matching: find.byType(Text)));
expect(rp.didExceedMaxLines, isFalse,
       reason: 'rozet metni KIRPILDI · intrinsic=${rp.getMaxIntrinsicWidth(double.infinity)} '
               'ayrilan=${rp.size.width} yukseklik=${rp.size.height}');
```
🔴 **Hüküm YALNIZ `didExceedMaxLines`'tan gelir.** `intrinsic`/`size`/`height` hata mesajında
**raporlanır ama hüküm vermez** — ölçüldü: sarma varken `intrinsic` büyük kalır (§1.2.2/B).

| ayak | ölçüm | beklenen |
|---|---|---|
| **A1** | `textScale ∈ {1.0, 1.5, 2.0}` × `genişlik ∈ {320, 360, 411}` × `durum ∈ {yerel, kuyrukta, cevrimdisi, gonderilmemis}` × `cakismaVarMi ∈ {false, true}` = **72 kombinasyon** (3×3×4×2; v3'ün "96"sı **yanlıştı**) | `didExceedMaxLines` her birinde **false** |
| **A2** | `senkronize` ⇒ rozet çizilmez (`SizedBox.shrink`) ⇒ ölçülecek `Text` **yok**; kapı susar ama *"ölçtüm"* **demez** (açık `isEmpty` beyanı) | boş küme |
| **A3** | **STATİK:** `lib/sunum` altındaki her rozet `Text`'i `maxLines` **taşır** — kaynak taraması. Gerekçe §1.3: `ellipsis` + `maxLines` yokluğu sarmayı öldürür | eşleşme tam |

### G14 · DİKEY DÖNÜŞ

**Dosya:** `src/client/test/g14_dikey_donus_kapisi_test.dart` · widget testi.

| ayak | ölçüm | beklenen |
|---|---|---|
| **A4** | `320dp` + `2.0×` + `gonderilmemis` ⇒ `GorevSatiri` altında `Column` **VAR** | DİKEY |
| **A5** | `800dp` + `1.0×` + `yerel` ⇒ `Column` **YOK** (yanlış‑pozitif kontrolü) | YATAY |
| **A6** | Aynı girdi iki kez `pump` ⇒ aynı düzen (titreme yok) | kararlı |
| **A7** | `senkronize` (metin `null`) ⇒ `320dp`+`2.0×`'te bile YATAY | YATAY |
| **A8** | **STATİK:** `lib/sunum`'daki her `TextPainter(` çağrısının gövdesinde `.dispose()` var | eşleşme tam |

### G15 · BİLEŞİK SATIR · A11Y‑1 · A11Y‑6 · A11Y‑7 · **ÇİFT OKUMA**

**Dosya:** `src/client/test/g15_bilesik_satir_kapisi_test.dart` · widget testi.

| ayak | ölçüm | beklenen |
|---|---|---|
| **A9** | `cakismaVarMi=true` + `gonderilmemis`, `320dp`, `2.0×` ⇒ her iki rozet de ağaçta | ikisi de var |
| **A10** | `Checkbox` ve `CakismaRozeti` dokunma hedefi ≥ `MOlcu.dokunmaHedefi` | ≥ 48dp |
| **A11** | **A11Y‑6:** rozetin **görünür `Text`'i KORUNUR** (metni gizleyerek çözüm YASAK) | `Text` var |
| **A12** | **A11Y‑7 regresyonu:** durum geçişinde duyuru bir kez (G11 davranışı bozulmamış) | korunur |
| **A13** | 🔴 **ÇİFT OKUMA:** rozetin semantics düğümünde **tam metin BİR KEZ** geçer; kısa görünür metin semantics ağacında **YOK** (`ExcludeSemantics`) | tek etiket |

---

## 6. MUTANTLAR

| # | mutasyon | ısırması BEKLENEN | tür |
|---|---|---|---|
| **M74** | `LayoutBuilder` kaldırılır, düz `Row` | `G14/A4` | widget |
| **M75** | `baslikAsgari = 0` | `G14/A4` | widget |
| **M76** | `DIKEY` daima `true` | `G14/A5` | widget |
| **M77** | `TextPainter`'a `textScaler` verilmez | `G14/A4` (2.0× sütunu) | widget |
| **M77b** | `metinIcin`/`tamMetinIcin` yerine `build` içinde **kopya** eşleme, biri değiştirilir | `G14/A4` veya `G15/A13` | widget |
| **M78** | Rozetin görünür `Text`'i kaldırılır, yalnız `Semantics` kalır | `G15/A11` | widget |
| **M79** | Dikey düzende `CakismaRozeti` düşürülür | `G15/A9` | widget |
| **M80** | `overflow: TextOverflow.ellipsis` kaldırılır | **`a11y_statik_tasma_test.dart`** (§1.3 ayrımı) | statik |
| **M82** | `Checkbox` dikeyde `SizedBox(width: 24)` içine alınır | `G15/A10` | widget |
| **M83** | `TextPainter` `dispose()` satırı silinir | `G14/A8` | statik |
| **M84** | 🔴 `maxLines: MAX_SATIR` **kaldırılır** (v3'ün hâli) | **`G13/A1`** (varyant A: tek satır + kırpma) **ve** `G13/A3` | widget |
| **M85** | `MAX_SATIR = 1` yapılır | `G13/A1` | widget |
| **M86** | Görünür dizge tam metne geri döndürülür (*"Çevrimdışısınız…"*) | **`G13/A1`** (6 satır > `MAX_SATIR` 3 ⇒ kırpma) | widget |
| **M87** | `ExcludeSemantics` kaldırılır | **`G15/A13`** (çift okuma) | widget |
| **CM1** | Cihazda `320dp` + `font_scale 2.0`, bileşik satır ⇒ **PNG**: rozet metni tam görünür | görsel | cihaz |
| **CM2** | Aynı cihazda `font_scale 1.0` ⇒ **PNG**: düzen yatay | görsel | cihaz |
| **CM3** | Dikey düzende `CakismaRozeti`'ne dokunulur ⇒ çözüm sayfası açılır | etkileşim | cihaz |

> 🔴 **`font_scale` test SONUNDA `1.0`'a GERİ ALINIR** ve geri alındığı **ölçülür**
> (`adb shell settings get system font_scale`). Bırakılan ayar sonraki dilimin ölçümünü sessizce bozar.
> 🔴 **v3'ün `M81`'i (tolerans gevşetme) DÜŞTÜ** — `G13_TOLERANS` kaldırıldı, ısırtacak eşik yok.

## 6b. MUTANT BORCU

**YOK.** Her kapı ayağının en az bir mutantı var. *(Biçim notu: bu bölüm okunacaksa
`spec-kapi-kapsama.py` yalnız `- KURAL: <ad> | GEREKCE: <...>` **satır biçimini** ayrıştırır — tablo
yazmak borcu sessizce görünmez kılar; v3'te bu olmuştu, K81'in aynı sınıfı.)*

---

## 7. KABUL KRİTERLERİ

1. `flutter analyze --fatal-infos` ⇒ **0**.
2. `flutter test` ⇒ mevcut testler + `G13`/`G14`/`G15` yeşil. **Toplam sayı ÇIKTIDAN okunur.**
   🔴 F6 dizgeleri değiştiği için `find.text` kullanan mevcut testlerin bir kısmı **kırılacaktır** —
   bunlar **görünür kısa metne** göre düzeltilir; `Semantics` etiketini sınayan testler **değişmez**.
3. **Üç dosya EŞZAMANLI güncellenir**: `metinler.dart` · `araclar/fixture/metinler-kilit.json` ·
   `a11y_kapisi_test.dart`'ın gömülü `_fixtureGorunur` haritası. Biri unutulursa F6 kapısı ısırır —
   **bu ısırma beklenen davranıştır ve kapının çalıştığının kanıtıdır.**
4. `M74`–`M87` tek tek uygulanır, ilgili kapının **ısırdığı** ölçülür, mutasyon **geri alınır**
   ⇒ `KANIT/A7/06-MUTANT/M<n>.txt` (mutasyon farkı + **başarısız test çıktısı**).
5. `CM1`–`CM3` ⇒ `KANIT/A7/07-CIHAZ/`; `font_scale` geri alındığı **ölçülür**.
6. `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-A7-rozet-tasma.md` ⇒ **EXIT 0**
   🔴 **dizin verme** — araç `.` ile `Permission denied` verir (K81).
7. `python araclar\design-token-kapisi.py .` ⇒ `D0`–`D6` yeşil, **yeni token eklenmediği** ölçülür (K46).
8. `KANIT/A7/00-OLCUM-kor-kapi.txt` ve `01-DENETIM.md` **korunur** — silinmez, üzerine yazılmaz.
9. Kapanışta `DESIGN.md` A‑7 satırı güncellenecekse: **K46 gereği Onur'un ayrı kilidi olmadan
   `DESIGN.md`'ye tek bayt YAZILMAZ.** Yazılamıyorsa A‑7 *"kapandı"* **denmez**, `BORCLAR.md`'de
   **"ölçüldü/kapanmadı"** olarak durur.

---

## 8. BEYAN EDİLMİŞ SINIRLAR

- **S1 · `G13` yalnız rozet alt ağacını ölçer.** Başlık kırpılması kabul edilir.
- **S2 · `RenderParagraph.didExceedMaxLines` ve `getMaxIntrinsicWidth` Flutter render API'leridir.**
  Ortam **ölçüldü**: Flutter 3.44.6 · Dart 3.12.2, ikisi de çalışıyor (`01-DENETIM.md` §3).
  Sürüm yükseltmesinde kırılabilir; kırılırsa **görünür** olur, sessizleşmez.
- **S3 · Widget testi cihaz fontunu kullanmaz.** Tüm px değerleri `flutter_test` fontuyla ölçüldü;
  cihazda **farklı çıkar**. `MAX_SATIR = 3`'ün 1 satırlık emniyet payı bu belirsizlik içindir.
  Gerçek görünüm `CM1`/`CM2` ile ölçülür; ikisi birbirinin yerine geçmez.
- **S4 · `320/360/411dp` bir ÖRNEKLEMDİR**, tüm genişliklerin kanıtı değil. Ara değerler ölçülmedi.
- **S5 · Web `[DOĞRULANMADI]`** — `textScaler` ve font çözümü web'de farklı olabilir (`DESIGN.md` A‑5).
- **S6 · `Checkbox`'ın `textScaler` davranışı [DOĞRULANMADI].** `D‑A7‑3` onu sabit 48dp sayıyor;
  Flutter'da `Checkbox` normalde ölçekten etkilenmez ama bu **koşularak doğrulanmadı**
  (`01-DENETIM.md` §7). Düşük risk; `CM1` dolaylı doğrular.
- **S7 · `baslikAsgari = 96dp` bir TASARIM SEÇİMİDİR**, ölçülmüş eşik değil. Mevcut token'ın katı
  olarak yazıldı çünkü K46 yeni token yasağı yürürlükte.
- **S8 · `CakismaRozeti` görünür metin taşımaz** (yalnız `Semantics(label:)`) ⇒ `G13` onu ölçmez.
  Kapsam beyanıdır, kusur değil.
- **S9 · Kısa dizgeler bir COPY KARARIDIR.** Ölçüm hangi dizgelerin **sığmadığını** söyler, hangi
  kelimenin **doğru** olduğunu söylemez. Seçilen dört metin Onur'un kilidini taşır; değişirse
  ölçüm (§4/D‑A7‑1 tablosu) **yeniden koşulur**, ezberden güncellenmez.

---

## 9. KANIT DİZİNİ

```
KANIT/A7/
  00-OLCUM-kor-kapi.txt   Cowork'un kor kapi olcumu (KORUNUR)
  01-DENETIM.md           Claude Code'un bagimsiz denetimi, BLOKER (KORUNUR)
  02-COZUM-OLCUM.txt      Cowork'un alti varyant + dizge olcumu (KORUNUR)
  00-ortam.txt            adb devices + (varsa) docker ps + netstat OLCUMU
  01-analyze.txt          flutter analyze --fatal-infos
  02-test.txt             flutter test (toplam sayi CIKTIDAN)
  05-KAPI/                G13 / G14 / G15 kosum ciktilari
  06-MUTANT/              M74..M87 — mutasyon farki + BASARISIZ test ciktisi
  07-CIHAZ/               CM1..CM3 PNG + font_scale get/put kayitlari
  09-HUKUM.md             madde madde PASS/FAIL + net karar
```

🔴 **>200 KB ham çıktı KANIT'a YAZILMAZ** — kesit + `sha256` yeterlidir.

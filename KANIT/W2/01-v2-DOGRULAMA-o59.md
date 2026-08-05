# W2 `v2` — BAĞIMSIZ KAPANMA DOĞRULAMASI (`K127`, ikinci tur) · oturum 59 · 5 Ağu 2026

> **Doğrulanan:** `GOREV-W2-...md` **v2** (18.156 b · `94124CE5`). **Üreten el (Cowork) doğrulamadı** (`K26`).
> **Tur gerekçesi (`K53/1`):** birinci tur **mimariyi değiştiren** bir bloker buldu (`BL-1` — dilimin tek
> dikişi hiç ölçülmüyordu; `v2` bunun için **yeni bir kapı, `G42`** doğurdu) ⇒ istisna şartı **karşılandı**.
> 🔴 **ÜÇÜNCÜ TUR YOKTUR** — radar `R1`: aynı artefakta üçüncü tur YASAK. `v3` bu raporla kapanır.

---

## 0. 🔴 ÖNCE — ORTAM KUSURU: `device_stage_files` **BAYAT KOPYA SUNDU** (ölçüldü, gizlenmiyor)

Doğrulayıcıya `v2` verildi; bulut kopyası **`v1`** çıktı (**11.770 b**, ilk satırı *"KİLİT ADAYI v1"*),
ve `KANIT/W2/` bulutta **hiç yoktu**. Doğrulayıcı bunu **kendisi ölçtü**, uydurmadı, ve tüm ölçümlerini
Onur'un diskinden (`C:\dev\Momentum`) yeniden aldı.

🔴 **Bu, `ORTAM.md`'nin adlandırdığı mayının ikinci ısırışıdır** (*"`device_stage_files` BAYAT KOPYA
sunabiliyor (oturum 28; 30'da tekrarlanmadı) ⇒ stage'lenenin **sha'sını karşılaştır**"*).
**Cowork bu turda sha'yı karşılaştırmadı ⇒ kusur ÜRETENİNDİR.** Ders (`ORTAM.md`'ye adayı):
**stage'lenen her dosyanın sha'sı, ajana verilmeden ÖNCE karşılaştırılır — bir kez doğru gelmesi
sözleşme değildir.** 🟢 Doğrulama yine de geçerlidir: doğrulayıcı **gerçek diski** okudu.

---

## 1. KAPANMA TABLOSU — v1'in 7 BLOKER + 13 MAJOR'ü

**Skor: 7 BLOKER → 3 KAPANDI · 4 KISMEN (biri YENİ KUSUR doğurdu). 13 MAJOR → 11 KAPANDI · 2 KISMEN.**

| id | hüküm | kanıt (özet) |
|---|---|---|
| `BL-1` dikiş ölçülmüyor | **KISMEN** | `G42` doğdu; çağrının **yokluğu** ölçülüyor, **argümanları** ölçülmüyor ⇒ `YB-1` |
| `BL-2` "şerit VAR" yüklemi | **KISMEN** | Dört koşul + `Opacity` yasağı geldi; `getSize` **yerleşim** ölçer, **boyama** değil ⇒ `YB-4` |
| `BL-3` `Veritabani` imzası | 🟢 **KAPANDI** | `T2` denetimin yazdırdığı satırı birebir taşıyor; `baglanti ??` geri geldi, **31 konumsal çağrı** korunuyor |
| `BL-4` ad/api önceliği | 🟢 **KAPANDI** | Doğrulayıcı sıralı listeyi **altı ayağın her girdisine elle uyguladı: çelişki YOK**. Çapraz teyit: `types.dart`'ta `opfsShared(WebStorageApi.opfs)` … `inMemory(null)` ⇒ ②'nin api koşulu üretimde **yanlış alarm üretemez** |
| `BL-5` `G41` kurulamaz | 🟢 **KAPANDI (import)** / **KISMEN (pin)** | `types.dart` başlığı birebir: *"This library **must not import web-specific APIs**, as it is also imported in **integration tests on a Dart VM**"*; importları yalnız `dart:async` · `package:drift/drift.dart` · `package:sqlite3/common.dart` ⇒ **VM'de import EDİLEBİLİR**. Ama pinin karşılaştıracağı ad kümesi `T1`'de üretilmiyordu ⇒ `YB-5` |
| `BL-6` kriter 4 karşılaştırmıyor | **KISMEN** | Karşılaştırma geldi ama **bağıntı** (eşitlik mi kapsama mı) tanımsızdı ⇒ `YB-6` |
| `BL-7` `R4` tabanı | **KISMEN + YENİ KUSUR** | `T8`'in iki sayısı **doğru ölçüldü**; ama `M208`'in ayrımı `R2`'de çöktü ⇒ `YB-2`; `Text(` sayısı pinsizdi ⇒ `YB-10` |

**MAJOR:** `MJ-1` (M207 eşdeğer) · `MJ-2` (M205/kontrast çifti) · `MJ-4` (ikon — doğrulayıcı `DESIGN.md`
§6 listesini açtı: `cloud_off · arrow_upward · schedule · error_outline · edit_outlined · delete_outline`
⇒ **`storage` YOK, çakışma YOK**; `lib` altında kullanımı **0**) · `MJ-5` · `MJ-6` · `MJ-8` · `MJ-9` ·
`MJ-10` · `MJ-11` · `MJ-12` · `MJ-13` ⇒ **hepsi KAPANDI**.
**KISMEN:** `MJ-3` (⇒ `YB-2`) · `MJ-7` (duyuru dizgesi pinsiz ⇒ `YB-7`).

---

## 2. YENİ BULGULAR — v2'nin KENDİ ÜRETTİĞİ KUSURLAR (radar `R3` sınıfı)

### 🔴 BLOKER

**`YB-1` · `G42/a` çağrının VARLIĞINI görür, ARGÜMANLARINI görmez ⇒ `BL-1`'in çekirdeği hayatta.**
(GÜVEN: KESİN.) Doğrulayıcının saldırı gövdesi:
`depolamaBildirimiYaz(bildirim, uygulamaAdi: 'opfsShared', depolamaApi: 'opfs');` — sabit dizge.
`G42/a` ✅ `G42/b` ✅ `G42/c` ✅ `G39` ✅ `G40` ✅ `G41` ✅ · **on beş mutantın hepsi ısırır**, `MW20` KALIR
⇒ gerçek tarayıcıda durum **her zaman `kaliciOpfs`**, **şerit ASLA çıkmaz**. Bu, `v2`'nin §8/2'deki
daraltılmış iddiasını **bile** yalanlar ⇒ beyan edilmiş sınır değil, **açık kusur**.

**`YB-2` · `M208` hedef ayaktan değil `R2`'den ısırır ⇒ v2'nin KENDİ kriter 4'üne göre GEÇMEZ.**
(GÜVEN: KESİN — gerçek dosyadan ölçüldü.) `a11y_statik_tasma_test.dart`: `R1` yüklemi
`cagri.govde.contains('TextOverflow.ellipsis')` ⇒ `maxLines`'a **bakmıyor** (v2'nin *"R1 SUSAR"* iddiası
**doğru**). Ama **`R2`** aynı dosyada: `ellipsisVar` **true** iken `maxLines` yoksa **ihlal yazıyor**
⇒ `M208` (*"yalnız `maxLines` kaldırılır"*) **`R2`'yi kırmızıya çevirir**, hedefi `G40/d`'dir ⇒ eşleşmez.

**`YB-3` · `G42` tarayıcısının **yorum körlüğü** ve **gövde sınırı** şart koşulmamış.**
(GÜVEN: KESİN.) `// depolamaBildirimiYaz(bildirim, ...)` biçiminde bir **yorum** `G42/a`'yı geçirir;
`M210`/`M211` *"silinir"* yerine **yoruma alınırsa** ısırmaz. Proje emsali: `R1`/`R2`/`F6` üçü de
yorumları atmak **zorunda kaldı**; `ss2-kapisi.py` ve `cors-kapisi.py` tam bu sınıftan **kör kaldı**.

### 🟠 MAJOR
`YB-4` "VAR" yüklemi **yerleşim** ölçer, **boyama** değil — `Transform.scale(0)` / `ClipRect` /
`ColorFiltered` / `SizedBox(0)` dört koşulu da geçer · `YB-5` `G41`'in karşılaştıracağı ad kümesi `T1`'de
**üretilmiyor**; ayrıca `M209` `G41/a`'yı değil `G39/a`'yı kırmızıya çevirir · `YB-6` kriter 4'ün bağıntısı
tanımsız **ve** `M204` satırı gevşek okumayı dayatıyor (hedef `G40/b`, beklenen *"G40/a **ve** G40/b"*) ·
`YB-7` `A11Y-7` **duyuru dizgesi** hiçbir yerde pinli değil, `F6` ona kör; **ayrıca `DESIGN.md` §4
matrisinin "semantics duyurusu" sütunu `T7`'de DOLDURULMUYOR** · `YB-8` duyuru yakalama yardımcısı
`a11y_kapisi_test.dart:62`'de **özel** (`_duyurulariYakala`) ⇒ yeni test onu **import edemez**, kopyalamak
zorunda kalır (`kanonik-kopya`).

### 🟡 MINOR
`YB-9` `G39` ayakları `a,b,c,d,**f**` — `e` **eksik** (v1→v2 düzenleme artığı) · `YB-10`
`DepolamaSeridi`'nin kaç `Text(` ekleyeceği **pinli değil** ⇒ `R4` tabanı 12→13 varsayımı kanıtsız ·
`YB-11` `uygulamaAdi == null` girdisi hiçbir ayakta yok.

---

## 3. `v3`'TE NE YAPILDI (üreten elin cevabı — **bu bölüm denetçinin değil, Cowork'ündür**)

| bulgu | v3'teki karşılığı |
|---|---|
| `YB-1` | `G42/a` artık **argümanları** da ölçüyor (`sonuc.chosenImplementation.name` / `.storageApi?.name` birebir); **`M215`** (sabit dizgeye çevir) eklendi |
| `YB-2` | `M208` **`maxLines: 2` → `maxLines: 5`** oldu: `ellipsis` da `maxLines` da **yerinde kalır** ⇒ `R1` **ve** `R2` susar, yalnız `G40/d` ısırır |
| `YB-3` | `G42`'ye **tarayıcı sözleşmesi** yazıldı (yorumdan arındır · yalnız `onResult` gövdesi · pozitif kontrol · bulamazsa `ORTAM HATASI`, **YEŞİL DEMEZ**); **`M216`** (çağrıyı **yoruma al**) eklendi |
| `YB-4` | `T3`'ün yasak sarmalayıcı listesi genişledi (`Transform` · `ClipRect` · `ColorFiltered` · `Offstage` · sabit yükseklik/genişlik); yükleme `width > 0` eklendi; **kalan sınır §8/6'da BEYAN EDİLDİ** |
| `YB-5` | `T1` `kaliciOpfsAdlari` / `geriDususAdlari` / `kaliciDegilAdi` kümelerini **dışa veriyor**, `depolamaSinifiCoz` **onları kullanıyor**; `M209`'un hedefi `G39/a · G41/a` (ikisi de) |
| `YB-6` | Kriter 4: **TAM EŞİTLİK** (`olculen == beklenen`, alt küme YETMEZ) + hedefteki `D-W2-*`/`A11Y-*` kodlarının **izlenebilirlik** olduğu yazıldı; `M204`'ün hedefi `G40/a · G40/b` |
| `YB-7` | `T6`'ya **üçüncü sabit** (`duyuruDepolamaGeriDususu`), `T8`'de `F6` **13 → 16**, `G40/f` yakalanan dizgeyi sabitle **birebir** karşılaştırıyor, `T7` §4'ün **duyuru sütununu dolduruyor** |
| `YB-8` | **`T9`** eklendi: yardımcı `test/destekler/duyuru_yakala.dart`'a çıkarılır ve `a11y_kapisi_test.dart` onu kullanır (tek kaynak) |
| `YB-9` | `f` → `e`; yeni `g` ayağı `(null,null)` için |
| `YB-10` | `T3`: **TEK BİR `Text(` düğümü** pinlendi |
| `YB-11` | `G39/g` eklendi |

---

## 4. NE ÖLÇÜLEMEDİ (doğrulayıcının listesi — **boş değil**)

1. **`flutter analyze` / `flutter test` KOŞULMADI** (salt-okunur denetim). `YB-2`, `YB-5`, `YB-10`
   **okunmuş kaynak + Dart semantiğinden** çıkarsandı; koşularak gözlenmedi.
2. `meetsGuideline(textContrastGuideline)`'in `#8A5A00`/`#0F1319` çiftinde **fiilen** kırmızı verip
   vermediği — **birinci tur da ölçemedi, `v2`/`v3` de kapatmadı**.
3. `Transform.scale(0)`'ın `G40/e`'yi yeşil bırakıp bırakmayacağı **ölçülemedi** ⇒ `YB-4`'ün şiddeti
   belirsiz.
4. `G40/d`'nin *"en fazla 2 satır"* ölçümünün bu Flutter sürümünde **yazılabilirliği** doğrulanmadı
   ⇒ `v3` §8/7'de **beyan edildi**.
5. `drift_flutter`'ın `driftDatabase()` gövdesi — `D-W2-7` iddiası **hâlâ ölçülmemiş**.
6. `package:drift/drift.dart` + `package:sqlite3/common.dart`'ın **transitif** import kapanışı
   yürütülmedi ⇒ `G41`'in kurulabilirliği `types.dart`'ın **yazılı VM sözleşmesi** üzerinden KESİN,
   tüketici zincirin tamamı üzerinden **ZAYIF**.
7. `spec-kapi-kapsama.py` · `design-token-kapisi.py` · `radar.py` ve dört açılış kapısı **`v2`'ye karşı
   koşulmadı** (Cowork `v3`'e karşı koştu — aşağıda).
8. Taban test sayısı: doğrulayıcının regex sayımı **240** eşleşme; bu `flutter test`'in bildirdiği toplam
   **DEĞİLDİR** ⇒ kriter 2'nin `N`'i build başında ölçülür (`v3` §8/8).

---

## 5. HÜKÜM

| tur | hüküm |
|---|---|
| **v1** (iki denetçi) | **KİLİTLENEMEZ** / **DÜZELTİLİP KİLİTLENEBİLİR** |
| **v2** (doğrulayıcı) | 🔴 **KİLİTLENEMEZ** — *"`YB-1`, `YB-2`, `YB-3` metne girerse DÜZELTİLİP KİLİTLENEBİLİR; üçü küçük ve mekaniktir."* |

🟢 **`v3` üç blokerin üçünü de metne aldı** (§3 tablosu) ve dokuz MAJOR/MINOR'ın hepsini işledi.
🔴 **`v3` BAĞIMSIZ DENETİMDEN GEÇMEDİ** — üçüncü tur radar `R1` ile **YASAKTIR**. Bu, gizlenen değil
**beyan edilen** bir sınırdır: `v3`'ün kilidi, *"bulgular metne alındı"* güvencesiyle istenir,
*"yeniden denetlendi"* güvencesiyle değil. Kalan risk **build turunda** ısırır ve orada ölçülür.

# İŞ EMRİ — SS2 başlık düzenleme UI'ı (oturum 68)

> 🔴 **BU BİR SPEC DEĞİLDİR, YENİ TUR AÇMAZ.** Kaynak: **kilitli** `GOREV-SS2` (`K133`/`K136`)
> ve `GOREV-slice-3b`'nin yazılı kuralları + Onur'un o68 kilitleri. Yeni `G<n>` / `D-<x>`
> kimliği **ilan edilmez**; bu belge yalnız **ölçülmüş durumu** ve **kilitleri** taşır.
>
> **Neden şimdi:** radar **`R8` KIRMIZI** — son iki oturumda (67, 68) sıfır **ürün** kodu.
> *"bir sonraki oturum ÜRÜN KODU ile başlar; yeni belge/ADR/spec/**araç** turu **AÇILMAZ**."*
> Onur `K40` kilidini verdi: **ürün koduna geç**. ⇒ **Bu turda yeni KAPI/ARAÇ yazılmaz.**
> Bekleyen `adr-hukum-kapisi.py` indeks onarımı (`GOREV-ADR0004-KAPISI-ONARIM-1-INDEKS.md`,
> kaynak HEAD `5b0f259`) **diskte bekler, bu turda AÇILMAZ.**
>
> **Tarih:** 10 Ağu 2026 (cihazdan ölçüldü). **El:** Claude Code. **Hüküm:** Cowork (`K26`).

---

## 1. ÖLÇÜLMÜŞ MEVCUT DURUM (varsayma, hepsi cihazda ölçüldü)

### 1.1 🟢 Veri ve senkron dikişi **ZATEN BİTMİŞ**

`src/client/lib/veri/gorev_deposu.dart:330–352`

```dart
Future<void> duzenle(String id, String yeniBaslik) async { … }
```

Tek `transaction` içinde: yerel `gorevler` tablosuna `baslik` + `guncellendi` yazıyor **ve**
kuyruğa `WireOp` düşüyor (`fields: {'title': WireFieldWrite(value: yeniBaslik, hlc: opHlc)}`,
`opHlc = hlc.sonrakiHlc()`). Soyut arayüzde de ilan edilmiş (`:77`).

### 1.2 🔴 Ama **ürün yolunda HİÇ çağrılmıyor**

`grep -rn "duzenle(" src/client/lib/` ⇒ `gorev_deposu.dart` dışında **sıfır** çağrı.
Yalnız testler çağırıyor. **Yazılmış ama kullanıcıya açılmamış bir mutasyon.**

### 1.3 🔴 `T6` — PAZARLIKSIZ DOKUNMA SINIRI (birebir alıntı)

`src/client/lib/sunum/gorev_satiri.dart:10–13` **ve** `GOREV-slice-3b:157`:

> *"`CakismaRozeti` **kendi `GestureDetector`'ını taşır** ve görünür metin düğümünün
> **dışındadır**; `GorevSatiri`'nın kendisi `onTap` taşımaz. Gerekçe: dokunulabilir alan
> satır olursa metin semantics düğümüne girer ve **M7 ısırmaz**."*

### 1.4 🔴 `M7` nedir — ölü mutant riski **buradadır**

`GOREV-slice-3b:264`:

| mutant | ne yapar | kapı | beklenen |
|---|---|---|---|
| **M7** | `CakismaRozeti`'nin `Semantics` etiketini **sil** | `G5` / `A11Y-3` | `labeledTapTargetGuideline` **FAIL** |

⇒ `labeledTapTargetGuideline` **tüm ağaçtaki** dokunma hedeflerine bakar.
🔴 **Etiketsiz yeni bir `IconButton` eklenirse kılavuz zaten FAIL eder ve M7 ile
etiketsiz-ikon ayırt edilemez hâle gelir — yani M7 ÖLÜR.**

### 1.5 🔴 `_dikeyMi` aritmetiği **doğrudan etkilenir**

`gorev_satiri.dart:66–89`:

```
sabitler = MOlcu.dokunmaHedefi(48) + MBosluk.s(8) + MBosluk.s(8)
         + (cakismaVarMi ? MOlcu.dokunmaHedefi(48) + MBosluk.xs(4) : 0)

DİKEY  ⟺  sabitler + baslikAsgari(96) + rozetIstedigi > maxGenislik
```

Yeni bir 48dp dokunma hedefi **`sabitler`'i büyütür**. `_dikeyMi` güncellenmezse
**ölçülen düzen ile çizilen düzen sessizce ayrışır** — `M77b`'nin uyardığı kusurun aynısı.
`_dikeyDuzen`'in girinti yorumu da (*"rozete ayrılan gerçek genişlik `maxWidth - 48 - 8`"*)
bayatlar. `src/client/test/g14_dikey_donus_kapisi_test.dart` vakaları (320dp/1.0 ⇒ `M75`
kaldıracı · 411dp/2.0 ⇒ `M77` kaldıracı) **yeniden hesaplanmalıdır**.

### 1.6 Mevcut tokenlar (K46: **yeni token YASAK**, `DESIGN.md`'ye tek bayt yazılmaz)

`MOlcu.dokunmaHedefi = 48` · `MOlcu.ikon = 24` · `MOlcu.ikonBuyuk = 32` ·
`MBosluk.xs/s/m/l/xl = 4/8/16/24/32`. **Yalnız bunlar kullanılır.**

---

## 2. ONUR'UN KİLİTLERİ (o68)

1. 🔒 **① Ayrı düzenle ikonu (`IconButton`)** — satırın kendisi `onTap` **TAŞIMAZ**;
   ikon **kendi 48dp dokunma hedefini** taşır. Yerinde `TextField` ve `onLongPress`
   **REDDEDİLDİ**.
   🔴 **Bedeli beyanlıdır:** `T6`'nın *"dokunulabilir tek alanlar Checkbox ve
   CakismaRozeti"* **lafzı** artık üç alana çıkar. Kuralın **gerekçesi** (metin semantics
   düğümüne girmesin) **korunur** — başlık metni dokunulamaz kalır.
2. 🔒 **Kabul: widget testi + `M7` ısırma ölçümü.** Yeni **kapı/araç yazılmaz** (`R8`);
   test **ürün kodunun parçasıdır**.

---

## 3. YAPILACAKLAR

1. **`gorev_satiri.dart`**
   - Yeni bir isteğe bağlı geri çağırım: `final ValueChanged<String>? onBaslikDuzenlendi;`
     (**null ise ikon ÇİZİLMEZ** — mevcut çağrı yerleri ve testler bunu hiç bilmez, `A13`/
     `D-SS2-8`'in `depo` alanındaki emsalin aynısı).
   - `_yatayDuzen` ve `_dikeyDuzen`'e **`Semantics` etiketi TAŞIYAN** bir `IconButton`
     eklenir (`MOlcu.dokunmaHedefi` hedef, `MOlcu.ikon` boyut).
     🔴 **Etiket zorunludur** — gerekçe §1.4.
   - **`_dikeyMi`'nin `sabitler` toplamı güncellenir** (ikon çizilecekse
     `+ MOlcu.dokunmaHedefi + MBosluk.xs`). Formül ile çizilen düzen **ayrışmamalıdır**.
   - `_dikeyDuzen`'in girinti yorumu **düzeltilir** (bayat sayı bırakılmaz).
2. **`gorev_listesi_ekrani.dart`** — `GorevSatiri(...)` çağrısına `onBaslikDuzenlendi`
   bağlanır; `onTamamlaDegisti`'nin **birebir aynı** deseniyle:
   `unawaited(_yerelYaz(() => widget.depo.duzenle(gorunum.gorev.id, yeniBaslik)))`.
   🔴 `_yerelYaz` sarmalayıcısı **atlanmaz** (hata/senkron dikişini o taşıyor).
3. **Düzenleme diyaloğu** — mevcut `gorev_ekle_alani.dart`'ın doğrulama kuralları
   (boş başlık, kırpma, azami uzunluk) **kopyalanmaz, PAYLAŞILIR**; iki yerde iki kural
   `kanonik-kopya` sınıfını doğurur (bu projede beş kez ısırdı).
4. **Testler** (`src/client/test/`)
   - Yeni widget testi: ikon görünür → basılır → `duzenle(id, yeniBaslik)` **çağrıldı**;
     `onBaslikDuzenlendi == null` iken ikon **çizilmiyor**.
   - **`M7` hâlâ ısırıyor mu** — ölçülür: `CakismaRozeti`'nin `Semantics` etiketi silinince
     `labeledTapTargetGuideline` **FAIL** etmeli; yeni ikon **etiketliyken** süit
     **yeşil** kalmalı. İkisi **birlikte** ölçülmezse M7'nin ölmediği **bilinemez**.
   - `g14_dikey_donus_kapisi_test.dart` yeni `sabitler` ile **yeniden hesaplanır**;
     `M75` ve `M77` kaldıraçlarının **hâlâ ısırdığı** gösterilir.

---

## 4. DOKUNULMAYACAKLAR (kilitli)

- 🔒 **`K46`** — `DESIGN.md`'ye **tek bayt yazılmaz**, **yeni token yok**.
- 🔒 **`D-W2-6` / `D-W2-8`** — `W2`'nin `onResult` dikişi **PAZARLIKSIZ**.
- 🔒 **`D2`** — completion **REPLACE**'tir; `tamamlaGeriAl`'a dokunulmaz.
- 🔒 **`SS2/G31`–`G34`** ve `ss2-kapisi.py`'nin statik ayakları.
- 🔒 **`K61`** dev-kimlik kalkanı · **`K60`** atomik yazım.
- 🔴 **`duzenle()`'nin gövdesi DEĞİŞTİRİLMEZ** — çalışıyor, ölçüldü; iş **UI + kablolama**.

---

## 5. KABUL — Cowork BAĞIMSIZ koşar (`K26`), ortam: cihaz

| # | ölçüt | eşik |
|---|---|---|
| 1 | `flutter analyze --fatal-infos` | **0** |
| 2 | `flutter test` | **tümü yeşil**; taban **539/539** (yeni testler bu sayıyı büyütür, **düşüremez**) |
| 3 | `duzenle()` ürün yolundan **çağrılıyor** | `grep -rn "duzenle(" src/client/lib/` ⇒ `gorev_deposu.dart` **dışında en az 1** |
| 4 | **M7 ISIRIYOR** | `CakismaRozeti` `Semantics` etiketi silinince süit **DÜŞER**; etiket yerindeyken **yeşil** |
| 5 | **Yeni ikon etiketli** | etiketi silinince süit **DÜŞER** (yani yeni dokunma hedefi de kör değil) |
| 6 | `g14` yeniden hesaplandı | `M75` ve `M77` kaldıraçları **hâlâ ısırıyor** |
| 7 | Satır **hâlâ `onTap` taşımıyor** | `gorev_satiri.dart`'ta widget kökünde `onTap`/`GestureDetector` **yok** |

🔴 **4, 5 ve 6 olmadan 1–3 bir ölçüm değildir:** bu projede *"yeşil veren ama hiçbir şey
ölçmeyen kapı"* (`kor-kapi`) **beş turdur** ve *"ölü mutant"* **üç turdur** tekrarlıyor.

---

## 6. NE ÖLÇÜLEMEDİ (kapanmadı, gizlenmedi)

- **Android cihazda** koşum — `adb` Cowork'ten erişilemez (Desktop Commander **beş
  oturumdur yok**); widget testi emülatörsüzdür, **uçtan uca değildir**.
- **`SS2` kriter 8'in `title` alanı üzerinde yeniden koşumu** — bu iş emrinin **kapsamı
  dışında**; başlık düzenleme açıldıktan **sonra** ayrı bir turda ölçülür. (`kriter 8`
  bugün **tamamlanma anahtarıyla** koşuyor; sınır `DURUM.md` §5'te yazılı.)
- **`flutter test --platform chrome`** bu ortamda sonuç üretmiyor (`ORTAM.md`) ⇒ web
  ayağı **`[DOĞRULANMADI]`**.

# T7 — 23 mutant kaydı (M171–M188, harfli varyantlar dahil)

Bu dosya, GOREV-SS2 §6 mutant tablosundaki 23 mutantın **her birinin** gerçek
üretim koduna uygulanıp koşulduğunu ve **byte-birebir** geri alındığını kanıtlar.
Aşağıdaki komut/çıktı alıntıları oturumun kendi transkriptinden (jsonl) aynen
alınmıştır — uydurulmamıştır.

**Taban sha256 (T7 başlangıcı, aşağıdaki komutla ölçüldü):**
```
cd "C:\dev\Momentum\src\client" && sha256sum lib/veri/veritabani.dart lib/veri/gorev_deposu.dart lib/senkron/uzak_degisiklik_uygulayici.dart lib/sunum/cakisma_rozeti.dart lib/sunum/gorev_satiri.dart
```
```
fe8f89b4558dbc5fd881e34080bf114e1a3390258e00f38c0e5eae7d0ee09c0f *lib/veri/veritabani.dart
b57bf8f0de1b21f631c17841a45c01603a021a039ac859cbc7d6459578e76855 *lib/veri/gorev_deposu.dart
eb207517912c6a4e23faa9c1d82a9595c0e3f093ebad0625acb8f45f73847536 *lib/senkron/uzak_degisiklik_uygulayici.dart
702dcbf6a0c742ba50b5bbc00d4d812f1f71d81a9dba2c810375dbe1220e3780 *lib/sunum/cakisma_rozeti.dart
42c534d11de84be78dd0eb238347e7b1b6ed0b620c4de84481cc89b197369d1e *lib/sunum/gorev_satiri.dart
```

Her mutant için: **dosya/değişiklik → koşulan test → sonuç → revert yöntemi
(Edit, `git restore` DEĞİL) → sha256 doğrulaması**. T7 sonunda tüm 5 dosyanın
sha256'sı yukarıdaki tabana **tekrar** eşitlendi (bkz. `son-sha256-taban-karsilastirma.txt`).

---

## M171 — `veritabani.dart`: `schemaVersion => 5` → `=> 4`
Statik kapı (`ss2-kapisi.py`) ile ölçüldü:
```
[G31a] SS2/G31/a: schemaVersion=>5 VE CakismaKayitlari tablo listesinde -- ikisi birden saglanmiyor
```
**ISIRDI.** Revert: `=> 5` geri yazıldı; sha256 tabanla eşleşti.

## M181 — `veritabani.dart`: `from < 5` bloğuna `alterTable(TableMigration(gorevler))` eklendi
```
[G31b] SS2/G31/b: from<5 blogunda alterTable( geciyor
```
**ISIRDI.** Revert + sha256 eşleşti.

## M171b — `veritabani.dart`: gerçek kod `=> 4`, yorumda `// schemaVersion => 5` (yanıltıcı yorum)
```
[G31a] SS2/G31/a: schemaVersion=>5 VE CakismaKayitlari tablo listesinde -- ikisi birden saglanmiyor
```
**ISIRDI** (yorum aracını kandırmadı — düz metin taraması gerçek kodu okur). Revert + sha256 eşleşti.

## M171c — `veritabani.dart`: kod DEĞİŞMEDİ (`=> 5` aynı kaldı), yalnız yorum eklendi (`// schemaVersion => 4`)
```
BULGU YOK: G31/a,b * G33/c hepsi gecti.
EXIT=0
```
**SESSİZ KALDI — beklenen tek istisna budur** (spec: "YALNIZ M171c susar"). Revert + sha256 eşleşti.

## M176 — `gorev_deposu.dart`: `ucustaSutunu` count'undan `distinct: true` çıkarıldı
```
[G33c] SS2/G33/c: distinct:true eksik -- satir(lar): 239
```
**ISIRDI** (statik kapı). Aynı mutasyonla **M176b** de birim testiyle ısırdığı doğrulandı:

## M176b — aynı mutasyon, `G33/d` birim testiyle ölçüldü
```
G33/d: cakisma kaydi DOLU iken (0->1->2) ucusta/bekleyen/zehirli sayilari SABIT kalir (distinct:true fan-out korumasi, M176b) [E]
  Expected: (int, int, int, int):<(1, 1, 1, 2)>
    Actual: (int, int, int, int):<(2, 1, 1, 2)>
```
**ISIRDI** (fan-out gerçekten 1→2 şişti). Revert (distinct:true geri eklendi) + sha256 eşleşti + statik kapı tekrar `BULGU YOK` verdi.

## M172 — `uzak_degisiklik_uygulayici.dart`: `kanonikEski` artık UPDATE'ten SONRA yeniden okunan satırdan hesaplanıyor (pre-write `mevcut` yerine)
Tam dosya koşumunda **G32/a, G32/e, G32/e2, G32/g, G32/h** hepsi düştü (şart 4 her zaman eşitlik verip çakışma kaydını tamamen bastırdığı için kollateral çöküş):
```
Failing tests:
  .../g32_cakisma_tespiti_test.dart: G32/a: dort sart saglanir ...
  .../g32_cakisma_tespiti_test.dart: G32/e2: bayatlamada sart 3 ...
  .../g32_cakisma_tespiti_test.dart: G32/e: bayatlama ...
  .../g32_cakisma_tespiti_test.dart: G32/g: saat dikisi ...
  .../g32_cakisma_tespiti_test.dart: G32/h: kanonik temsil ...
```
**ISIRDI** (hedeflenen G32/a dahil). Revert + sha256 eşleşti.

## M173 — `uzak_degisiklik_uygulayici.dart`: şart 2 (`bekleyenYerelYazimVarMi`) satırı silindi
```
G32/b: sart 2 -- kuyrukta bekleyen yerel yazim YOK -- 0 kayit [E]
  Expected: empty
    Actual: [CakismaKaydiRow: ...]
```
**ISIRDI.** Revert + sha256 eşleşti.

## M175 — `uzak_degisiklik_uygulayici.dart`: `kazananBiziz` sabit `false` yapıldı (şart 3/echo eleme devre dışı)
```
G32/c: sart 3 -- kazanan BIZIZ (echo) -- 0 kayit [E]
  Expected: empty
    Actual: [CakismaKaydiRow: ...]
```
**ISIRDI.** Revert + sha256 eşleşti.

## M174 — `uzak_degisiklik_uygulayici.dart`: şart 4 (`kanonikEski == kanonikYeni`) satırı silindi
```
G32/d: sart 4 -- kanonikDize degerleri AYNI -- 0 kayit [E]
  Expected: empty
    Actual: [CakismaKaydiRow: ...]
```
**ISIRDI.** Revert + sha256 eşleşti.

## M180 — `uzak_degisiklik_uygulayici.dart`: bayatlama (`/e`) dalı tamamen silindi
```
G32/e: bayatlama -- kayit varken cakismasiz uzak yazim gelir -- 1 kayit KALIR, kazanan GUNCELLENIR, kaybeden DEGISMEZ [E]
  ... kazanan GUNCELLENMELI
```
**ISIRDI.** Revert + sha256 eşleşti.

## M180b — `uzak_degisiklik_uygulayici.dart`: bayatlama dalından yalnız şart 3 (`kazananBiziz` echo kontrolü) çıkarıldı
```
G32/e2: bayatlamada sart 3 -- kayit varken KENDI ECHO'muz gelir -- kazanan/kaybeden DEGISMEZ, kayit sayisi 1 kalir [E]
  Expected: 'Birinci Uzak Baslik'
    Actual: 'Kendi Echomuz'
```
**ISIRDI.** Revert + sha256 eşleşti.

## M187 — `gorev_deposu.dart`: `kanonikDize()`'ın `groups:completion` dalı `'tamamlandi'/'acik'` yerine ham tel değerlerini (`'done'/'open'`) döndürüyor
```
G32/h: kanonik temsil -- ... [E]
  Expected: 'acik'
    Actual: 'open'
```
**ISIRDI** (hedeflenen G32/h). Not: spec'in "G32/h VE G32/d KIRMIZI" beklentisinden farklı olarak G32/d bu mutasyondan etkilenmedi — `kanonikDize()` implementasyonum kaybeden/kazanan için simetrik olduğundan (v1'in asimetrik tel-vs-projeksiyon kusuru burada yok) ve G32/d testi `fields:title` kanalını kullandığından. Mutant tablosunun `hedef` sütunu yalnız `SS2/G32/h`'ı adlandırıyor; o ayağın ısırması "ısırır" kriterini karşılar. Revert + sha256 eşleşti.

## M188 — `uzak_degisiklik_uygulayici.dart`: `olusturuldu: saat()` → `olusturuldu: DateTime.now().toUtc()` (enjekte saat yerine gerçek duvar saati)
```
G32/g: saat dikisi -- olusturuldu enjekte saatin sabit degerine BIREBIR esittir [E]
  Expected: '2026-01-01T12:00:00.000Z'
    Actual: '2026-08-03T22:31:18.400759Z'
```
**ISIRDI.** Revert + sha256 eşleşti.

## M182 — `gorev_deposu.dart`: `rozetDikisi()`'nden üçüncü kanal (`|| cakismaKaydiSayisi > 0`) çıkarıldı
```
G33/a: cakisma kaydi olan gorevde cakismaVarMi==true; ... [E]
  Expected: true
    Actual: <false>
```
**ISIRDI.** Revert + sha256 eşleşti.

## M183 — `uzak_degisiklik_uygulayici.dart`: UPDATE dalına `senkronDurumu: const Value('senkronize')` eklendi (D4 kilidi ihlali)
```
G33/b: UPDATE dali senkronDurumu'na YAZMAZ (D4 kilidi) ... [E]
  Expected: 'yerel'
    Actual: 'senkronize'
```
**ISIRDI** hedef ayakta. Ayrıca **beklenen kollateral** olarak mevcut `g10_rozet_kapsami_test.dart` dosyasındaki AYAK3/AYAK4 de düştü (spec'in kendi notu: "M183 için mevcut G10 testlerini de düşürmek BEKLENEN sonuçtur"):
```
AYAK3: MEVCUT cakisma satir uzak degisiklik alir -- rozet cakisma KALIR (P6 saglam) [E]
  Expected: 'cakisma'  Actual: 'senkronize'
AYAK4: MEVCUT yerel satir (bekleyen yerel yazim) echo alir -- rozet yerel KALIR (P7 kardesi) [E]
  Expected: 'yerel'  Actual: 'senkronize'
```
Revert + sha256 eşleşti; ardından hem `g33_rozet_uc_kanal_test.dart` hem `g10_rozet_kapsami_test.dart` tekrar tam yeşile döndü (bkz. tam regresyon).

## M184 — `cakisma_rozeti.dart`: `CakismaRozeti.entityId` alanı kaldırıldı, kurucu tekrar `const` yapıldı
Birim/widget testiyle DEĞİL, **derleme hatasıyla** ölçüldü (`flutter analyze`):
```
error - The getter 'entityId' isn't defined for the type 'CakismaRozeti' - lib\sunum\cakisma_rozeti.dart:78:62
error - The named parameter 'entityId' isn't defined - lib\sunum\gorev_satiri.dart:171:23
error - The getter 'entityId' isn't defined for the type 'CakismaRozeti' - test\g34_cakisma_ekrani_test.dart:69:18
```
**ISIRDI** (3 ayrı derleme hatası, G34/a'nın kendisi dahil). Revert + sha256 eşleşti.

## M178 — `cakisma_rozeti.dart`: kayıt satırından `kazananDeger` (Onlarınki) `_degerBlok`'u kaldırıldı
```
G34/b: cakisan alanin IKI degeri de ekranda, tasma yok [E]
  Found 0 widgets with text "Onlarin uzak basligi"
```
**ISIRDI.** Revert + sha256 eşleşti.

## M178b — `cakisma_rozeti.dart`: "Onlarınkini al" butonunun etiketi "Benimkini tut" ile aynı yapıldı
```
G34/c: iki buton 48dp + Semantics(button:true) + AYRI etiketler [E]
  Found 2 widgets with type "ElevatedButton" ... "Benimkini tut" — is too many
```
**ISIRDI.** Revert + sha256 eşleşti.

## M186 — `cakisma_rozeti.dart`: boş-durum dalı (`if (kayitlar.isEmpty)`) `if (false && ...)` ile devre dışı bırakıldı
```
G34/g: BOS DURUM -- 0 kayitla Metinler.cakismaKaydiYok gorunur, butonlar YOK [E]
  Found 0 widgets with text "Çakışan bir değişiklik bulunamadı."
```
**ISIRDI.** Revert + sha256 eşleşti.

## M179 — `gorev_deposu.dart` (`cakismaCoz`): `fields:title` dalında `duzenle()` çağrısı, projeksiyonu atlayıp yalnız kuyruğa yazan elle kurulmuş bir `_kuyrugaYaz(WireOp(...))` çağrısıyla değiştirildi
```
G34/d: benimkiniTut -- kuyruga 1 yeni op ... VE projeksiyon kaybedenDeger'e doner [E]
  Expected: 'Benim yerel basligim'
    Actual: 'Uzagin yazdigi baslik'
```
**ISIRDI** (v1'in BLOKER-6'sının mutantı — tam istendiği gibi). Revert + sha256 eşleşti.

## M185 — `gorev_deposu.dart` (`cakismaCoz`): `onlarinkiniAl` dalına da (gereksiz) bir kuyruk yazımı eklendi
```
G34/e: onlarinkiniAl -- kuyruga YENI OP GIRMEZ ... [E]
  Expected: empty
    Actual: [SenkronKuyruguRow: ...]
```
**ISIRDI.** Revert + sha256 eşleşti.

## M177 — `gorev_deposu.dart` (`cakismaCoz`): silme işlemi okuma/yazmadan ÖNCEye taşındı (sıra ters çevrildi)
```
G34/f: yazma ONCE, silme SONRA ... (M177) [E]
  Expected: 'Benim yerel basligim'
    Actual: 'Uzagin yazdigi baslik'
```
**ISIRDI** (silme önce koşunca `kayitlar` sorgusu boş döndü, yazma hiç gerçekleşmedi — testin kendisi tam bunu ölçüyor). Revert + sha256 eşleşti.

---

## Sonuç

**23/23 mutant** gerçek üretim koduna uygulandı, dokümante edilen sonucu verdi
(22'si ISIRDI, M171c beklenen tek istisna olarak SESSİZ kaldı), ve her biri
Edit aracıyla (asla `git restore` ile DEĞİL) byte-birebir geri alındı —
sha256 her seferinde tabanla karşılaştırıldı.

**Son doğrulama (tüm 23 mutant reverted sonrası):**
- `flutter test` → **522/522 yeşil** (bkz. `regresyon-son-testler.txt`)
- `flutter analyze --fatal-infos` → **0 sorun** (bkz. `regresyon-son-analyze.txt`)
- `ss2-kapisi.py .` → **BULGU YOK** (bkz. `ss2-kapisi-son.txt`)
- 5 dosyanın sha256'sı → T7 başlangıç tabanıyla **birebir eşit** (bkz. `son-sha256-taban-karsilastirma.txt`)

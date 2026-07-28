# GÖREV — `R9`: rozet kapsamı düzeltmesi (`P6`/`D4` DARALTMA)

> **Kilit:** K72 (Onur, 28 Tem 2026, oturum 35). Tasarım turu **tekrar açılmaz**.
> **Bu bir DARALTMA'dır, iptal değil:** `P6`/`D4`'ün *"uzak değişiklik rozete dokunmaz"* kuralı
> **UPDATE dalında AYNEN durur**. Yalnız **INSERT-from-pull** dalı kapsam dışına alınır.
> **v2 — bağımsız denetimden GEÇTİ** (K53/1, tek tur): 4 bloker + 3 önemli + 5 not; hepsi kapatıldı
> ya da gerekçesiyle beyan edildi. Denetim eli, yazan elden AYRI (K26).
> **Boyut beyanı:** bu spec kasten kısadır (K53/`R4` freni). Tasarım kararı **canlı ölçümle** alındı.

---

## 0. Önce oku

`DURUM.md` §4/§5/§8 · bu dosya. Kusurun ham kanıtı: `KANIT/slice-3d/10-KABUL9/` (`00-HUKUM.md` +
`06-soguk-acilis-listede.png`). Arşiv gerekçesi: `PROJE_HAFIZA.md` **K71** (kusurun doğuşu) ve
**K72** (kilit).

## 1. Kusur (ölçüldü, tahmin değil)

Sunucudan inen **iki** görevin ikisi de ekranda saat ikonuyla **"Yalnızca bu cihazda"** rozeti
taşıyor. Cümle **olgusal olarak yanlıştır**.

**Zincir:**
1. `uzak_degisiklik_uygulayici.dart:224` (`_projeksiyonYaz`, `mevcut == null` dalı):
   `// senkronDurumu YAZILMAZ -- sutun varsayilaniyla ('yerel') doGar (D4 BEYAN)`
2. `veritabani.dart` → `senkronDurumu … .withDefault(const Constant('yerel'))`
3. `senkron_rozeti.dart:51-57` → `case SenkronDurumTuru.yerel:` ⇒ `Metinler.yalnizcaBuCihazda`
4. `senkronize` durumunda rozet **hiç çizilmez** (`SizedBox.shrink()`) ⇒ kullanıcının gördüğü **tek**
   sinyal `yerel`'dir ve yanlış tarafa basar.

**`P6`/`D4`'ün gerekçesi bu vakayı kapsamıyor.** Korunan şey *bekleyen yerel yazımı olan* satırın
rozetinin uzak echo'yla ezilmemesidir. **Çekmeyle DOĞAN satırda bekleyen yazım YOKTUR** — kriter 9
ölçümünde `senkron_kuyrugu` **0 satır**. Kilit, INSERT-from-pull ile UPDATE-of-local'ı ayırmadan
yazıldığı için kapsamı dışına taştı.

## 2. Ölçülmüş zemin — yeniden keşfetme; doğrula ve geç

| iddia | ölçüm (dosya:satır) |
|---|---|
| CHECK kısıtı `senkronize`'ye **izin veriyor** | `veritabani.dart:18-25` `senkronDurumu.isIn(['yerel','kuyrukta','senkronize','cakisma','cevrimdisi'])`; `schema_v4.dart:52-61` aynısı |
| **MIGRATION GEREKMİYOR, şema v4 KALIR** | kısıt v1→v2'de genişletildi (slice-3c `D1`); `GorevlerCompanion.insert` `senkronDurumu`'nu **opsiyonel** alır (`veritabani.g.dart:388-397`, `requiredDuringInsert: false`) ⇒ `Value('senkronize')` derlenir |
| `senkronize` gerçek veriden **doğuyor** | yazan yer `senkron_dongusu.dart:274` → `_rozetYaz(satir.entityId, 'senkronize')`; yazıcı gövdesi **`:364`** |
| `changes` ve `snapshot` **aynı** yazıcıdan geçer | `changesUygula:106` ve `snapshotUygula:158` ikisi de `_projeksiyonYaz():203` çağırır |
| INSERT yorumu **`:224`**, UPDATE yorumu **`:235`** | `uzak_degisiklik_uygulayici.dart` |

🔴 **`senkron_rozeti.dart:9-11` DOKÜMAN YORUMU YANLIŞ** — *"'senkronize' hiçbir zaman gerçek veriden
doğmaz (T4'ün CHECK kısıtı yalnız 'yerel'e izin verir); bu değer yalnız vitrin/testler içindir."*
**Üç iddiasının üçü de ölçümle çürütüldü.** `T2`'de düzeltilir.

## 3. Teslimat adımları

### `T1` — INSERT-from-pull `senkronize` ile doğar
`uzak_degisiklik_uygulayici.dart` → `_projeksiyonYaz()` → `mevcut == null` dalı:
`GorevlerCompanion.insert(...)` çağrısına **`senkronDurumu: const Value('senkronize')`** eklenir;
`:224`'teki yorum düzeltilir (bugünkü metin artık yanlış olur).

🔴 **UPDATE dalına (`mevcut != null`, yorum `:235`) DOKUNULMAZ.** Oraya da yazmak kilidi ihlal eder;
`M42` bunu yakalar.

### `T2` — bayat doküman yorumu düzeltilir
`senkron_rozeti.dart:9-11`. Yeni metin şu **ölçülmüş** üç olguyu söylemeli: `senkronize` gerçek
veriden doğar (itme turu **`senkron_dongusu.dart:274`**, yazıcı **`:364`**; çekme INSERT'i `T1`) ·
CHECK kısıtı beş değere izin verir · rozetin çizilmemesi **gürültü azaltmadır** (DESIGN.md SS4),
*"yalnız vitrin"* değildir. 🔴 **`:186` YAZMA** — o satır BOŞTUR; eski spec'in yanlış atfıydı ve
denetim onu bloker olarak yakaladı.

### `T3` — çelişen MEVCUT test güncellenir  [PAZARLIKSIZ — `T1` bunu KIRAR]
`g3_ayristirici_kapisi_test.dart:162-172` bugün şunu iddia ediyor:
`test('D4: yerelde OLMAYAN entityId -- … senkronDurumu==yerel (varsayilan)')` +
`expect(yeni.senkronDurumu, 'yerel', reason: 'D4 BEYAN: yeni entity yerel ile dogar')`.
**Test adı, `expect`i ve `reason`u `'senkronize'`ye çevrilir**, gerekçesi K72'ye atıf yapar.
Test **silinmez**, tersine çevrilir — kapı ısırmaya devam etmelidir.

### `T4` — `G10` kapısı yazılır
`src/client/test/g10_rozet_kapsami_test.dart`. Widget ayakları için **hazır emsal var, uydurma:**
`a11y_kapisi_test.dart:100-131` — `_SabitDepo implements GorevDeposu` + `_gercekEkranSarmalayici`
ile `GorevListesiEkrani` sahte depoyla pumplanır.

## 4. `R9`'UN KAPSAM DIŞI BIRAKILAN AYAĞI — `R10` [BEYAN, gizleme DEĞİL]

Denetim şu kaçak yolu buldu: **çekilmiş `senkronize` bir satır yerelde düzenlenirse rozet
`senkronize` kalır ⇒ `SizedBox.shrink()` ⇒ HİÇBİR rozet görünmez** ve kullanıcı gönderilmemiş bir
değişikliği senkronize sanar. `gorev_deposu.dart`'ın dört yazma yolu (`ekle:91` · `duzenle:121` ·
`tamamlaGeriAl:145` · `sil:179`) `senkronDurumu`'na **yazmaz** (ölçüldü).

🔴 **BU DİLİMDE DÜZELTİLMEZ, ÇÜNKÜ ÖLÇÜLDÜ Kİ TASARIM KARARI GEREKTİRİYOR:** yerel yazma yollarına
*"rozeti `yerel` yap"* eklemek **iki mevcut kapıyı kırar** —
`g5_karantina_kapisi_test.dart:212-214` (`duzenle()` sonrası rozet **`cakisma` KALMALI**) ve
`:216-219`. Yani soru *"bir satır hem ÇAKIŞMALI hem BEKLEYEN ise rozet hangisini söyler?"*tir ve bu
bir **öncelik kilidi**dir — Onur'dan gelir, build'de uydurulamaz.

**Bugünkü durumla kıyas (dürüst):** bu sınıf `R9` düzeltmesinden **önce de vardı** (itilmiş
`senkronize` görevler için); `T1` onu **çekilmiş** görevlere de genişletir. Pencere, ilk başarısız
gönderim denemesi `cevrimdisi` yazana kadar sürer. **Net kötüleşme dar ama gerçektir ve gizlenmiyor.**

## 5. KAPILAR

### G10 — ROZET KAPSAMI KAPISI (Dart birim + widget testi; **koşan uygulama İSTEMEZ**)

| kod | ne |
|---|---|
| `P6-daraltma` | INSERT-from-pull `senkronize` ile doğar; UPDATE-of-local dokunulmaz |
| `bilgi-kaybi` | gerçekten `yerel` olan satır rozetini KAYBETMEZ |
| `iki-dal` | `changes` ve `snapshot` dalları AYRI AYRI ölçülür |

| ayak | ne ölçer | beklenen |
|---|---|---|
| `AYAK1` | `changesUygula` ile **YENİ** entity doğar | `senkronDurumu == 'senkronize'` |
| `AYAK2` | `snapshotUygula` ile **YENİ** entity doğar | `senkronDurumu == 'senkronize'` |
| `AYAK3` | **MEVCUT** `'cakisma'` satır uzak değişiklik alır | rozet **`cakisma` KALIR** (`P6` sağlam) |
| `AYAK4` | **MEVCUT** `'yerel'` satır (bekleyen yerel yazım) echo alır | rozet **`yerel` KALIR** (`P7` kardeşi) |
| `AYAK5` | widget: `senkronize` satır listede | `Metinler.yalnizcaBuCihazda` metni **YOK** |
| `AYAK6` | widget: **`DriftGorevDeposu.ekle()` ile üretilmiş** satır listede | `Metinler.yalnizcaBuCihazda` metni **VAR** |

🔴 **`AYAK6` PAZARLIKSIZ ve satırı SENTETİK OLARAK YAZILMAZ** — `ekle()` üretimdeki tek `'yerel'`
üreticisidir (`gorev_deposu.dart:91-115`, kolon varsayılanı). Elle `Value('yerel')` yazan bir test
yalnız dize eşlemesini ölçer (o zaten `sunum_bilesenleri_test.dart:70-81`'de var) ve düzeltmenin
*sustur* değil *doğru söylet* olduğunu **kanıtlamaz**.

🔴 **`AYAK3` ÜRETİM DURUMUYLA KURULUR:** `'cakisma'` üretimde gerçekten yazılır
(`senkron_dongusu.dart:289/317/346`). `'kuyrukta'` **hiçbir üretim yolunda yazılmıyor** (ölçüldü) —
o yüzden ayak `cakisma` ile kurulur, `kuyrukta` ile değil.

## 6. MUTANTLAR — beş; hepsi **statik/widget** ⇒ K53/3'ün koşan-uygulama tavanı (3) DEVREYE GİRMEZ

| # | mutant (kodda yapılan bozma) | kapı / kural | beklenen |
|---|---|---|---|
| **M41** | `T1`'in eklediği `Value('senkronize')` silinir | G10 / P6-daraltma | `AYAK1`+`AYAK2`+`AYAK5` düşer ⇒ **KIRMIZI** |
| **M42** | UPDATE dalına da `senkronDurumu: Value('senkronize')` eklenir | G10 / P6 | `AYAK3`+`AYAK4` düşer ⇒ **KIRMIZI** |
| **M43** | INSERT'e `Value('senkronize')` yerine `Value('yerel')` yazılır | G10 / P6-daraltma | `AYAK1`+`AYAK2`+`AYAK5` düşer ⇒ **KIRMIZI** |
| **M44** | `senkron_rozeti.dart`'ta `yerel` dalı `SizedBox.shrink()` döndürür | G10 / bilgi-kaybi | `AYAK6` düşer ⇒ **KIRMIZI** |
| **M45** | `snapshotUygula`'nın sonundaki `_projeksiyonYaz` çağrısı kaldırılır | G10 / iki-dal | `AYAK2` düşer, `AYAK1` **YEŞİL kalır** ⇒ **KIRMIZI** |

🔴 **`M42` ve `M44` MEVCUT TESTLERCE DE YAKALANIYOR — beyan edilmelidir, gizlenmemelidir.**
`M42` → `g3_ayristirici_kapisi_test.dart:158` ve `g5_yerel_koruma_kapisi_test.dart:330-331`;
`M44` → `sunum_bilesenleri_test.dart:79-80` ve `a11y_kapisi_test.dart:295`. İkisi de ısırır
(eşdeğer değiller) **ama `G10` olmadan da ısırırlardı**. `G10`'un **yalnız kendisine ait** yeni
kapsaması: `AYAK1` · `AYAK2` · `AYAK5` (`M41`/`M43`/`M45`).

**KURAL (K53/2, K60'ın M2b emsali):** ısırmayan mutant **kapıyı gevşetmez** — önce **kapı düzeltilir**.
Eşdeğer mutant iptal edilir ve `§8`'e **gerekçesiyle** yazılır.

## 7. Kabul kriterleri (hepsi ölçülür; beyan kabul edilmez)

1. `G10`'un **altı ayağı** da YEŞİL; çıkış kodu `cmd /v:on /c "... & echo !ERRORLEVEL!"` ile KANIT'ta.
2. `M41`–`M45` tek tek uygulandı, hedef ayak **KIRMIZI** yandı, geri alındı, kapı **YEŞİL** döndü.
   Her mutantın ham çıktısı **koşum anında** `KANIT\R9\MUTANT\` altına yazıldı. **Her mutant için,
   düşen ayağın YALNIZ `G10` sayesinde mi yoksa mevcut bir testle birlikte mi düştüğü BEYAN EDİLİR.**
3. `flutter analyze --fatal-infos` **0 bulgu** · `flutter test` EXIT 0. **Test sayısı 136 → 136+`G10`
   olur ve `g3_ayristirici_kapisi_test.dart`'ın bir testi `T3` ile GÜNCELLENMİŞTİR** — bu beyanla
   birlikte raporlanır; *"136 aynen durdu"* demek **YANLIŞ** olur.
4. `python araclar\tek-kopya-kapisi.py .` EXIT 0 · `python araclar\design-token-kapisi.py .` EXIT 0.
5. 🔴 **`schemaVersion == 4` DEĞİŞMEDİ** ve `test/generated_migrations/` altına yeni şema dosyası
   **EKLENMEDİ** — bu değişiklik migration istemez (§2'de ölçüldü).
6. 🔴 **UPDATE dalına dokunulmadı:** `git --no-optional-locks diff -- src/client/lib/senkron/uzak_degisiklik_uygulayici.dart`
   çıktısında `+`/`-` işaretli **hiçbir satır `mevcut != null` dalında (`:235` civarı) olmayacak**.
7. **Backend'e TEK SATIR dokunulmadı:** `git --no-optional-locks diff --stat -- src/backend/` **boş**.
8. `python araclar\iddia-kapisi.py GOREV_CLAUDE_CODE\GOREV-R9-rozet-kapsami.md --kanit KANIT\R9`
   EXIT 0 **ve** `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-R9-rozet-kapsami.md`
   EXIT 0. *(Bu araçlar mutantın ISIRDIĞINI ölçmez, yalnız kapsamayı ve iddia tutarlılığını ölçer —
   EXIT 0, kriter 2'nin yerine GEÇMEZ.)*
9. Cihaz üzerinde tekrar ölçüm: `KANIT/slice-3d/10-KABUL9/` kurgusu yeniden koşulur; yeni ekran
   görüntüsünde uzaktan gelen görevin **"Yalnızca bu cihazda" DEMEDİĞİ** görülür. 🔴 Ekran yakalama
   `adb shell screencap -p` + `adb pull` iledir — `> dosya.png` yönlendirmesi **ikiliyi BOZAR**
   (ölçüldü: 169.840 b bozuk ⇄ 84.550 b geçerli); her PNG'nin imzası doğrulanır.
10. **Ölçmediğin hiçbir şey "temiz" sayılmadı**; kalan sınırlar `§8`'e yazıldı.

## 8. Beyan edilmiş sınırlar / MUTANT BORCU

- 🔴 **`R10` (§4) BU DİLİMDE KAPATILMAZ** — öncelik kilidi Onur'dan gelmeden yerel yazma yollarına
  dokunulmaz; dokunan el iki mevcut kapıyı kırar.
- **`snapshot`/`changes` ayrımı için AYRIK mutasyon TANIMLANAMAZ** — `_projeksiyonYaz`
  tek parametre alır (`:203`) ve çağıranı ayırt etmez; öyle bir bozma **yapısal refactor** olurdu,
  mutasyon değil. Yerine `M45` (snapshot dalının yazıcıyı hiç çağırmaması) kondu; `AYAK2` birleşmenin
  kendisini ölçer. **[MUTANT BORCU — gerekçeli]**
- **`cakisma` INSERT dalında imkânsızdır** (dal yalnız `mevcut == null` için koşar; ayrıca
  `_rozetYaz('cakisma')` `applied` işlenirken, yani `changesUygula`/`snapshotUygula`'dan **ÖNCE**
  koşar ve o entity daima yerelde mevcuttur) ⇒ çakışma rozetinin ezilmesi bu değişiklikle **doğamaz**.
  Mutantı yoktur; gerekçe budur. **[MUTANT BORCU — gerekçeli]**
- **`cevrimdisi` rozeti etkilenmez** — yalnız ağ katmanı yazar (`senkron_dongusu.dart:157/302`
  `basariRozeti`), projeksiyon yazıcısı değil. **[MUTANT BORCU — gerekçeli]**
- **`silindi=true` gelen uzak görev** `senkronize` + `silindi=true` ile doğar ve `gorevlerGorunur()`
  onu zaten filtreler ⇒ rozet görünürlüğü sorunu doğmaz (ölçüldü).
- Bu spec `R9`'un **yalnız görünürlük** ayağını kapatır; görev düzenleme/tamamlama/silme yollarının
  **uzak yansıması** hâlâ `[DOGRULANMADI]`'dır (kriter 9 onları ölçmedi).

## 9. KANIT protokolü — `KANIT\R9\`  [ŞART: PAZARLIKSIZ]

`00-HUKUM.md` (ölçüm hükmü) · `01-G10\` (altı ayağın ham çıktısı + çıkış kodu) ·
`MUTANT\M41.txt` … `M45.txt` (ham çıktı, **koşum anında**, boş dosya YOK) ·
`02-cihaz\` (yeni ekran görüntüsü + cihaz DB dökümü + PNG imza doğrulaması).

## 10. Kırmızı çizgiler — bu dilimde YASAK

1. UPDATE dalına (`mevcut != null`) rozet yazmak.
2. `schemaVersion`'ı artırmak ya da yeni migration dosyası eklemek.
3. `gorev_deposu.dart`'ın dört yazma yoluna dokunmak (`R10`, §4 — kilit yok).
4. Backend'e tek satır yazmak.
5. `senkron_rozeti.dart`'ta `yerel` dalını susturmak (bilgi kaybı; Onur reddetti, `AYAK6` korur).
6. Çelişen testi **silmek** — `T3` onu **tersine çevirir**, silmez.

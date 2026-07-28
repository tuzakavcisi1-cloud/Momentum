# GOREV-R10 — Rozet KUYRUKTAN türetilir (`R10` kapanışı) · build spec

> **Kime:** Claude Code (build eli). **Kimden:** Cowork (tasarım/denetim eli).
> **Yetki:** **K75** (28 Tem 2026, oturum 36 — Onur kilitledi) · **K46 AÇILDI** (kapsamı K75'te tanımlı).
> **Ön koşul:** `DESIGN.md` **v2** (18.075 b · `3780ACA4`) — durum matrisi + bileşik gösterim orada.
> **PAZARLIKSIZ:** şema DEĞİŞMEZ (v4 kalır), **migration YOK**, `Gorevler.senkronDurumu` kolonuna
> yazan yollar **DEĞİŞMEZ**.

---

## 1. Kusur (ölçüldü, iddia edilmedi)

`Gorevler.senkronDurumu` kolonuna **yalnız** senkron döngüsü yazar (`senkron_dongusu.dart:364-370`
`_rozetYaz`). `gorev_deposu.dart`'ın dört yerel yazma yolu — `ekle` (`:91`), `duzenle` (`:121`),
`tamamlaGeriAl` (`:145`), `sil` (`:179`) — kolona **hiç dokunmaz**.

Sonuç: `'senkronize'` bir satır (çekmeyle inmiş ya da daha önce itilmiş) yerelde düzenlenince kolon
`'senkronize'` kalır; `SenkronRozeti` bu durumda `SizedBox.shrink()` çizer ⇒ **hiçbir rozet yok** ⇒
kullanıcı gönderilmemiş değişikliği senkronize sanır. Kusur `senkron_kuyrugu`'nda **görünür**
(`durum='bekliyor'` bir satır vardır) ama ekran o tabloyu **hiç okumaz**
(`gorev_deposu.dart:83-88` yalnız `gorevler`'i izler).

---

## 2. Kilitli tasarım — `D` kuralları

Görev başına sayımlar: **`U`** = `senkron_kuyrugu.durum='gonderildi'` · **`B`** = `'bekliyor'` ·
**`Z`** = `'zehirli'` · **`K`** = `Gorevler.senkronDurumu`.

- **D1 [PAZARLIKSIZ] Çakışma kanalı:** `cakismaVarMi = (Z > 0) || (K == 'cakisma')`.
  Yalnız `Z>0` **YANLIŞTIR**: `senkron_dongusu.dart:305-320` (401 dışı 4xx) satırı `bekliyor`
  bırakır, `denemeSayisi`'nı **artırmaz**, kolona `'cakisma'` yazar ⇒ zehirli satır **doğmaz**.
  `Z>0` ile bugün ekranda duran çakışma ikonu **kaybolur** ve satır asla zehirliye geçmediği için
  **geri gelmez**. Bu bir gerileme olurdu.
- **D2 Taban durum (ilk eşleşen kural kazanır):**
  1. `U > 0` ⇒ `kuyrukta` ("Gönderiliyor")
  2. `U = 0` ve `B > 0` ve `K == 'cevrimdisi'` ⇒ `cevrimdisi`
  3. `U = 0` ve `B > 0` ⇒ **`gonderilmemis`** ("Gönderilmemiş değişiklik") — YENİ DURUM
  4. `U = 0` ve `B = 0` ⇒ `K` eşlemesi: `senkronize`⇒rozet YOK · `yerel`⇒"Yalnızca bu cihazda" ·
     `cevrimdisi`⇒"Çevrimdışı kaydedildi" · `cakisma`⇒taban `yerel` · `kuyrukta`⇒`kuyrukta`
- **D3 [PAZARLIKSIZ] `K` ÖNCE doğrulanır.** Tanınmayan dize `ArgumentError` **fırlatır** — kurallar
  1-3 `K`'ya bakmadan kısa devre yapsa bile. Bugünkü invaryant (`gorev_listesi_ekrani.dart:36-37`,
  *"sessizce 'yerel'e düşmek YASAK"*) ölmez.
- **D4 `rozetDikisi` SAF kalır.** Yeni imza:
  `(SenkronDurumTuru, bool) rozetDikisi(String senkronDurumu, {required int ucusta, required int bekleyen, required int zehirli})`.
  DB'ye, `BuildContext`'e, saate **dokunmaz**.
- **D5 `Gorev` domain modeline sayım EKLENMEZ.** Gerekçe `gorev_deposu.dart:11-14`'teki F4 dikişi:
  widget'lar taşıma katmanı durumunu görmez. Yeni tip `GorevGorunum { Gorev gorev; SenkronDurumTuru
  senkronDurumu; bool cakismaVarMi; }`. **Ham `U`/`B`/`Z` veri katmanından DIŞARI ÇIKMAZ.**
  `GorevDeposu.gorevlerGorunur()` imzası `Stream<List<GorevGorunum>>` olur; `rozetDikisi` `veri/`
  katmanına taşınır, `g5_karantina_kapisi_test.dart:7` import'u güncellenir.
- **D6 [PAZARLIKSIZ] TEK sorgu, TEK `watch`.** İki ayrı stream + `combineLatest` **YASAK** — ara
  karede yanlış rozet doğurur. Şekil: `select(gorevler).join([leftOuterJoin(senkronKuyrugu,
  entityId.equalsExp(gorevler.id) & entityType.equals('Task'))])` + `addColumns([U,B,Z])` +
  `where(gorevler.silindi.equals(false))` + `groupBy([gorevler.id])` +
  `orderBy([olusturuldu ASC, gorevler.id ASC])`.
  - `Gorevler` **sürücü**, kuyruk **`leftOuterJoin`** — `innerJoin` kuyruk satırı olmayan (yani
    senkronize) her görevi listeden **düşürür**.
  - `groupBy(gorevler.id)` **PAZARLIKSIZ**: yoksa satır sayısı O(kuyruk satırı) olur ve 3 bekleyen
    op'lu görev listede **üç kez** görünür (`ValueKey` çakışır, `gorev_listesi_ekrani.dart:112`).
  - `orderBy`a **`gorevler.id` tie-break'i eklenir**: `saat()` aynı ms'i verebilir; farklı rozetli
    satırlar yer değiştirirse rozet başka satıra sıçrar.
  - **`customSelect` kullanılırsa `readsFrom: {gorevler, senkronKuyrugu}` PAZARLIKSIZDIR.** Unutulursa
    akış kuyruk değişikliklerinde **hiç yenilenmez**. Bu varsayımsal değil: `gonderildiKurtar()`
    (`:101-107`) ve toplu `gonderildi` yazımı (`:134-137`) `gorevler`'e **hiç dokunmayan**, her turda
    koşan gerçek yollardır.
  - `count(filter:)` SQLite `FILTER` gerektirir (>= 3.30). Sürüm **ölçülmedi** ⇒ patlarsa taşınabilir
    karşılık `SUM(CASE WHEN durum='...' THEN 1 ELSE 0 END)`. Hangisi kullanıldıysa build notunda
    **beyan edilir**.
- **D7 Bileşik gösterim.** `gorev_satiri.dart:59-62`'deki `if/else` **kalkar**: `cakismaVarMi` ise
  `CakismaRozeti` **VE** taban `SenkronRozeti` **birlikte** çizilir (önce çakışma ikonu, sonra
  taban). `DESIGN.md` v2 §4.
- **D8 Uçuş işareti tek transaction.** `gonderildiKurtar()` + toplu `gonderildi` yazımı (`:115-117`
  ve `:134-137`) **tek `_db.transaction()`** içine alınır. Gerekçe ölçüldü: bugün iki ayrı commit
  var ⇒ akış iki kez yayın yapar ⇒ her turda `U=0` ara karesi ⇒ rozet **titrer**. Bu bir **kuyruk**
  yazımıdır, kolon yazımı değildir; K75'in kilidini bozmaz.
- **D9 A11Y-7 duyurusu.** `senkron_rozeti.dart:34-51` duyuruyu `didChangeDependencies` içinde yapıyor;
  ebeveyn `durum` parametresini değiştirdiğinde bu **koşmaz** (`didUpdateWidget` koşar) ⇒ durum
  geçişlerinde duyuru **hiç yapılmıyor**. Mantık `didUpdateWidget`e taşınır ve *"önceki durum ≠ yeni
  durum"* koşuluna bağlanır.

---

## 3. Sunum katmanı

- `SenkronDurumTuru` enum'una **`gonderilmemis`** eklenir (beşinci değer).
- `Metinler`'e **`gonderilmemisDegisiklik = 'Gönderilmemiş değişiklik'`** ve
  **`duyuruGonderilmemisDegisiklik = 'Gönderilmemiş değişiklik var'`** eklenir.
- İkon: **`Icons.edit_outlined`** (`DESIGN.md` v2 §6 anlam pini). Renk `MRenk.metinIkincil` —
  **yeni token EKLENMEZ** (bilinçli: yeni MUST sembolü token kapısının yüzeyini büyütür).
- `GorevSatiri` iki parametresi (`senkronDurumu`, `cakismaVarMi`) **aynen kalır**; yalnız `if/else`
  bileşik hâle gelir (D7).

**Beşinci enum değerinin DERLEME ETKİSİ (ölçüldü — improvize edilmez):**

| yer | ne olur | ne yapılır |
|---|---|---|
| `senkron_rozeti.dart:55` `build()` switch | **DERLEME HATASI** — `default` yok, tüketici switch | `gonderilmemis` case'i eklenir: `Icons.edit_outlined` + `MRenk.metinIkincil` + `Metinler.gonderilmemisDegisiklik` |
| `senkron_rozeti.dart:38` duyuru switch-ifadesi | `_ => null` var, **derleme hatası vermez** — sessizce duyurusuz kalır | `gonderilmemis` ⇒ `Metinler.duyuruGonderilmemisDegisiklik` eklenir (D9 ile aynı elden) |
| `vitrin/durum_vitrini.dart:60-88` | derlenir ama **`DESIGN.md` v2 §4 ile ÇELİŞİR** (belge 5 durum, vitrin 4) | beşinci kart + **bileşik kart** (çakışma ikonu + taban rozet birlikte) eklenir |
| `test/sunum_bilesenleri_test.dart:75-113` | dört rozet testi var, beşinci yok | `gonderilmemis` rozeti testi eklenir |


---

## 4. Mevcut kapılara etki (ölçüldü)

**Semantik olarak bozulan iddia: SIFIR.** Kolon yazma yolları değişmediği için `G5` ve `G10`'un
**tüm kolon iddiaları aynen yeşil kalır** — `g5:212-214` ve `g5:216-219` (çakışma kilidi) dâhil.
Yalnız **imza/konum** güncellemesi gerekenler:

| yer | sebep |
|---|---|
| `g5_karantina_kapisi_test.dart:7` | `rozetDikisi` `veri/`ye taşındı ⇒ import |
| `g5_karantina_kapisi_test.dart:228` | `rozetDikisi('cakisma')` ⇒ adlandırılmış parametreler (sonuç `(yerel,true)` **değişmez**) |
| `g5_karantina_kapisi_test.dart:242` | aynı |
| `g10_rozet_kapsami_test.dart:180` | **POZİTİF İDDİA EKLENİR:** `findsNothing`'in yanına görev başlığının `findsOneWidget` olduğu — join yönü mutantı satırı tamamen kaybetse bile bugünkü iddia **geçiyordu** (kör) |

---

## 5. KAPILAR

### G11 — rozet türetme kapısı

`G11`'in zorladığı KURAL ENVANTERİ (§2'deki kilitli tasarımın makine-okunur özeti):

| kural | ne der | mutant |
|---|---|---|
| D1 | çakışma kanalı `Z>0 || K=='cakisma'` | M47 |
| D2 | dört taban kuralı, ilk eşleşen kazanır | M48 · M54 |
| D3 | tanınmayan `K` fırlatır | M51 |
| D4 | `rozetDikisi` SAF | M57 |
| D5 | sayim `GorevGorunum`da kalır, `Gorev` değişmez | M56 |
| D6 | tek join'li watch: leftOuter + groupBy + silindi + readsFrom | M46 · M49 · M50 · M53 |
| D7 | bileşik gösterim (if/else kalkar) | M52 |
| D8 | uçuş işareti tek transaction | — (§6b borcu) |
| D9 | duyuru `didUpdateWidget`e taşınır | M55 |

Dosya: `src/client/test/g11_rozet_turetme_kapisi_test.dart`. Ayakları:

| ayak | ne ölçer | kural |
|---|---|---|
| G11-A1 | `rozetDikisi` saf birim tablosu: dört kuralın her satırı ayrı `expect` | D2 |
| G11-A2 | `K` tanınmıyorsa `ArgumentError` | D3 |
| G11-A3 | R10 ASIL SENARYOSU: `'senkronize'` satır `duzenle()` ⇒ görünüm `gonderilmemis` | D2 |
| G11-A4 | İKİ GÖREV: A'nın bekleyen op'u var, B'nin yok ⇒ A'da metin VAR, B'de YOK | D6 |
| G11-A5 | YALNIZ KUYRUĞA YAZ: render sonrası `gonderildiKurtar()` ⇒ akış yeniden yayın yapar | D6 |
| G11-A6 | ASKILI AĞ: `Completer`'da bekleyen sahte ağ, `turCalistir()` await edilmeden ⇒ askıdayken taban `kuyrukta` | D2 |
| G11-A7 | BİLEŞİK: aynı görevde `zehirli` + `bekliyor` ⇒ `CakismaRozeti` VE taban rozet aynı anda | D7 |
| G11-A8 | 4xx: sunucu 400 ⇒ Z=0, K='cakisma' ⇒ çakışma ikonu hâlâ görünür | D1 |
| G11-A9 | `groupBy`: aynı göreve üç kuyruk satırı ⇒ listede tek `GorevSatiri` | D6 |
| G11-A10 | `silindi`: silinmiş görev listede yok, kuyruk satırı onu diriltmiyor | D6 |
| G11-A11 | duyuru: `yerel` → `senkronize` geçişinde BİR duyuru; ikinci pump'ta tekrar YOK | D9 |
| G11-A12 | ham sayım sızmıyor: `Gorev` alan sayısı DEĞİŞMEDİ, `rozetDikisi` saf | D4 / D5 |

**Widget ayaklarında `pumpAndSettle` KULLANILMAZ** — `kuyrukta` durumunun `_DonenOk`'u
`Timer.periodic` ile sonsuz kare planlar (`senkron_rozeti.dart:118-158`) ve `pumpAndSettle` zaman
aşımına düşer. `pump(Duration)` kullanılır ya da ağaç `MediaQuery(disableAnimations: true)` ile
sarılır. Bu ölçülmüş bir ortam kısıtıdır, üslup tercihi değil.

---

## 6. MUTANTLAR

Hepsi **statik/widget** sınıfıdır ⇒ K53/3 gereği **TAVANSIZ**; hiçbiri emülatör istemez, koşan-uygulama
mutant tavanı (3/dilim) **tüketilmez**. Her mutant: kodu boz → kırmızı çıktı
`KANIT/R10/09-MUTANT/M<n>-kirmizi.txt` · geri al → yeşil `M<n>-yesil.txt` · fark `M<n>-diff.txt`.

| # | bozulma | hedef |
|---|---|---|
| M46 | sayımdan `entityId` filtresi düşürülür (global sayım) | G11 / D6 |
| M47 | çakışma kanalından `K=='cakisma'` dalı düşürülür | G11 / D1 |
| M48 | `U` sayımı daima 0 döner | G11 / D2 |
| M49 | `.watch()` → `.get()` (ya da izlenen tablolardan kuyruk düşürülür) | G11 / D6 |
| M50 | `groupBy` düşürülür | G11 / D6 |
| M51 | `rozetDikisi`'nin `ArgumentError`'ı yutulur | G11 / D3 |
| M52 | bileşik çizim `if/else`'e geri döner | G11 / D7 |
| M53 | `silindi` filtresi düşürülür | G11 / D6 |
| M54 | kural 3 `gonderilmemis` yerine `yerel` döndürür | G11 / D2 |
| M55 | duyuru `didUpdateWidget`ten `didChangeDependencies`e geri alınır | G11 / D9 |
| M56 | `GorevGorunum` yerine `Gorev`'e sayım alanı eklenir | G11 / D5 |
| M57 | `rozetDikisi` içinden DB okunur (saflık bozulur) | G11 / D4 |

## 6b. MUTANT BORCU

- KURAL: D8 | GEREKCE: iki yazmanin AYNI transaction icinde oldugu iddiasi Drift'in disariya sizdirmadigi bir sinirdir; gozlemlenebilir sonucu (ara kare) yalniz zamanlama yarisiyla olculebilir ve bu kirilgan/flaky bir kapi uretir. Titreme sinifi bugun OLCULMUYOR -- borc beyan edilir, gizlenmez.

---

## 7. Kabul kriterleri (Cowork bağımsız doğrulayacak)

1. `flutter analyze --fatal-infos` ⇒ **0 bulgu**.
2. `flutter test` ⇒ mevcut testler + yeni ayaklar, **tümü yeşil**; düşen test **YOK**.
3. `G11-A1`–`G11-A12` yeşil; ham çıktılar `KANIT/R10/`.
4. `M46`–`M57` **on ikisinin on ikisi de ısırır**; her biri için kırmızı + yeşil + diff kanıtı.
5. `python araclar\design-token-kapisi.py .` ⇒ **TEMİZ** (yeni token eklenmediği için hüküm
   değişmemeli; değişirse ham literal kaçmış demektir).
6. `python araclar\tek-kopya-kapisi.py .` ⇒ commit sonrası **YEŞİL** (`DESIGN.md` kilitli sınıfta,
   HEAD ile tutarlı olmalı).
7. **Cihazda (emülatör), koşula kadar YOKLAYARAK — SABİT `sleep` YASAKTIR:**
   (a) sunucudan inmiş bir görev düzenlenir ⇒ **"Gönderilmemiş değişiklik"** görünür;
   (b) tur koşup başarılı olunca rozet **kaybolur**;
   (c) çakışmalı + bekleyen bir satırda **İKİ rozet birden** görünür.
   Ekran görüntüsü: `adb shell screencap -p` + `adb pull` (`> dosya.png` ikiliyi bozar).
8. Şema **v4** kalır, `migration` **yazılmaz**.

---

## 8. Beyan edilmiş sınırlar (gizlenmiyor — bu iş bunları KAPATMIYOR)

- **401 iki kez yanlış etiketlenir:** `:299-304` `basariRozeti:'cevrimdisi'` ⇒ cihaz çevrimiçiyken
  "Çevrimdışı kaydedildi"; `denemeSayisi>8` sonrası zehirli + `'cakisma'` ⇒ "Çakışma var". Doğru
  bilgi (`sonHataKodu='http-401'`) DB'de **duruyor**, türetme onu **okumuyor**. Kapsam DIŞI.
- **`K='cevrimdisi'` GEÇMİŞ ZAMAN kalıntısıdır** (op başına yazılır); kural 2 onu şimdiki-zaman
  bağlantı iddiasına çevirir. Rozet gerçek connectivity'yi **hiç ölçmez**.
- **Sözlükte "silme bekliyor" yok:** sayım op'un anlamına bakmaz; `title` düzenlemesi ile
  `isDeleted` op'u aynı `B`'ye düşer. **Çakışan silme kullanıcıya hiç görünmez** (satır listede yok).
- **`_bekleyenleriSec` `limit(100)`** (`:172`): 101. op yeniden seçilmez ⇒ rozeti kalıcı olarak
  kural 3'te kalır.
- **K74'ün sınırı aynen durur:** düzeltmeden **önce** inmiş satırlar `'yerel'` kalır (migration
  yasak) ⇒ emülatörde üç eski satır hâlâ "Yalnızca bu cihazda" der. **Bu doğrudur, kusur değildir.**
- **Web ayağı [DOĞRULANMADI]:** `flutter test --platform chrome` bu ortamda sonuç üretmiyor.
- **iOS [DOĞRULANMADI]:** Mac yok, CI-only.
- **A11Y-4 / A11Y-1 bileşik satırda yeniden ölçülmedi** — `DESIGN.md` v2 açık kalem A-7.

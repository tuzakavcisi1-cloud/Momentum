# GOREV-SS2 — ÇAKIŞMA ÇÖZÜM EKRANI (DAR KAPSAM)

> **Durum:** 🔓 **KİLİT ADAYI** — tasarım kararları (`D-SS2-1`…`D-SS2-9`) Onur tarafından
> **3 Ağu 2026, oturum 54**'te onaylandı ("önerini onaylıyorum"); spec kilidi **kilit öncesi
> bağımsız denetimden SONRA** verilir (K127).
> **Yazan el:** Cowork. **Build eden el:** Claude Code (rol bölümü, `CLAUDE.md`).
> **Biçim:** K81 + K126 — kapılar `## 5. KAPILAR` altında `### G<n>`, mutantlar
> `## 6. MUTANTLAR` altında ve **`hedef` ÜÇÜNCÜ SÜTUNDUR** (`spec-kapi-kapsama.py`
> `hucreler[2]`'den okur).
> **Kapı kimlikleri (K108):** bu spec `G31`–`G34` kullanır; atıf daima **`SS2/G31`** biçiminde
> öneklidir. Mutantlar `M171`+ (son kullanılan `M170`, `A13`).

---

## 0. BU SPEC NEDEN VAR — VE NEYİ DÜZELTİYOR

`K95` (oturum 43) `SS2`'yi *"DAR KAPSAM: tek ekran · yerel ↔ uzak sürüm yan yana · farklı
alanlar vurgulu · iki buton (Benimkini tut / Onlarınkini al); seçim kuyruğa **normal bir
yazma** olarak girer"* diye kilitlemiş ve **açık bir ölçüm borcu** bırakmıştı:

> *"Bir ölçüm tahmini ikiye katlayabilir: istemci çakışma anında **kaybeden sürümü saklıyor
> mu**? Saklıyorsa 2–3 oturum, saklamıyorsa önce küçük bir depolama dilimi ⇒ 4–5 oturum.
> **Henüz ÖLÇÜLMEDİ.**"*

🔴 **Oturum 54'te ÖLÇÜLDÜ ve cevap `K95`'in varsaydığı ikili değildi** — §2'de. Bu spec, o
ölçümün üzerine kuruludur ve `K95`'in kapsam kilidini **değiştirmez**, yalnız **hangi
çakışmayı** çözdüğünü ölçüme dayanarak sabitler.

---

## 1. AMAÇ

Bir görevin **aynı alanı** iki cihazda birbirinden habersiz değiştirildiğinde, LWW'nin
sessizce attığı **kaybeden değeri kalıcı olarak saklamak**, kullanıcıya **yan yana**
göstermek ve seçimini **kuyruğa normal bir yazma** olarak geri koymak.

**Bu dilim bitince ölçülebilir olan:** çevrimdışı iki cihazda aynı görevin başlığı
değiştirilir, ikisi de bağlanır, kaybeden cihazda **çakışma rozeti** çıkar, ekran **iki
sürümü de** gösterir, *Benimkini tut* seçilince kaybeden değer **yeni bir HLC ile** kuyruğa
girer ve karşı cihaza **ulaşır**.

---

## 2. ÖLÇÜLMÜŞ TABAN (oturum 54 · beyan değil, okunan kod)

**Kaynaklar:** `src/client/lib/veri/veritabani.dart` · `src/client/lib/senkron/uzak_degisiklik_uygulayici.dart`
· `src/client/lib/senkron/alan_anahtari.dart` · `src/client/lib/senkron/kuyruk_tabani.dart`
· `src/client/lib/veri/senkron_dongusu.dart` · `src/client/lib/veri/gorev_deposu.dart`
· `src/client/lib/sunum/cakisma_rozeti.dart`

| # | ölçülen gerçek | sonucu |
|---|---|---|
| **Ö1** | **Bugünkü `senkronDurumu='cakisma'` bir LWW çakışması DEĞİLDİR.** Rozeti yazan üç nokta da *"op sunucuya geçmedi"* demektir: `_tekSonucIsle` default dalı (`Rejected*` ⇒ `zehirli`) · `_httpHatasiIsle` 4xx-401-hariç dalı · `_bekliyorGeriDondurVeDenemeArtir` deneme tavanı. | Rozetin **adı** ile **anlamı** ayrışmış. `SS2` gerçek çakışmayı ekler; **eski kanal SİLİNMEZ** (`D-SS2-7`). |
| **Ö2** | `gorev_deposu.dart`: `cakismaVarMi = zehirli > 0 \|\| senkronDurumu == 'cakisma'`. | Rozet **türetiliyor**, yazılmıyor ⇒ üçüncü kanal buraya eklenir (`D-SS2-5`). |
| **Ö3** | Reddedilen/zehirli kuyruk satırı **SİLİNMEZ** (`_tekSonucIsle` default dalı), `govdeJson` üretim anındaki gövdeyi taşır. | O yolda yerel gövde **yaşıyor** — `SS2`'nin çözdüğü yol bu **değil**, ama veri orada. |
| **Ö4** | 🔴 **Gerçek LWW çakışmasında hiçbir DEĞER saklanmıyor:** `_kanalUygula` kaybeden kanalı `if (!projeksiyonKazandi) return;` ile atar; `UzakAlanDurumu` yalnız kazananın **HLC'sini + `winOpId`'sini** tutar. | `SS2`'nin **varlık sebebi**. |
| **Ö5** | 🟢 **Kaybeden değer karar anında BELLEKTEDİR:** uzak kazandıysa eski projeksiyon `_projeksiyonYaz`'da `mevcut` olarak okunuyor; yerel kazandıysa gelen değer `_kanalUygula`'ya parametre geliyor. | `K95`'in *"önce büyük depolama dilimi"* korkusu **küçüldü**: gereken tek şey **salt-ekleme bir tablo**. |
| **Ö6** | `senkron_dongusu.dart:75` — `kuyrukTabaniSaglayici: (entityId, alan) => kuyrukEnBuyuk(db, entityId, alan)`. **Üretimde CANLI** (spec'teki *"T5'te bağlanır"* notu gerçekleşmiş). | Çakışma tespiti kuyruk tabanına dayanabilir (`D-SS2-3`). **Ölçülmeseydi bu spec temelsiz olurdu.** |
| **Ö7** | `kuyrukEnBuyuk` yalnız **`bekliyor` + `gonderildi`** durumundaki opları tarar; **`zehirli` DIŞARIDA**. | Çakışma penceresi = *yanıtı henüz kesinleşmemiş yerel yazım*. `zehirli` op çakışma **üretmez** (beyan edilmiş sınır, §9/S3). |
| **Ö8** | `degerlendirVeMetaYaz` **iki ayrı karar** verir (D3/Ö1 kilidi): meta kararı yalnız eski meta'ya karşı; projeksiyon kararı `enBuyuk(eskiMeta, kuyrukTabani)`'ya karşı. Dışarı **tek `bool`** döner. | Çakışma bilgisi **hesaplanıyor ama atılıyor** ⇒ `D-SS2-4` bunu **raporlatır**, karar mantığına **dokunmaz**. |
| **Ö9** | `kazandiMi` **kesin büyüklük** ister (`>`, `>=` değil) — echo koruması (D6). | Kendi echo'muz çakışma **üretmez** (`D-SS2-3/c`). |
| **Ö10** | `schemaVersion = 4`; `v3→v4` **salt-ekleme** deseni kanıtlı (`uzakAlanDurumu` + `ayarlar.imlecSahibi`, `Gorevler`'e dokunulmadı). | `v4→v5` aynı deseni izler (`D-SS2-1`). |
| **Ö11** | `CakismaCozumSayfasi` **bugün bir yer tutucudur** (`cakisma_rozeti.dart`), public'tir ve iki ölçülmüş sabit taşır: `kCakismaBasligiMaxSatir=1` (🔒 sabit, gerekçesi spec `SS4/Y6`) · `kCakismaGovdesiMaxSatir=6` (ölçüldü, `KANIT/A9/00-OLCUM.txt`). | Ekran **sıfırdan yazılmaz, DOLDURULUR**; iki sabit **korunur** (`D-SS2-8`). |

---

## 3. KARARLAR (Onur onayladı, oturum 54 — `D-SS2-1`…`D-SS2-9`)

### D-SS2-1 — DEPOLAMA: `CakismaKayitlari` (salt-ekleme, `schemaVersion` 4 → 5)

```dart
@DataClassName('CakismaKaydiRow')
class CakismaKayitlari extends Table {
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get alan => text()();                    // KANAL-NİTELİKLİ: 'fields:title' | 'fields:isDeleted' | 'groups:completion'
  TextColumn get kaybedenDeger => text().nullable()(); // kanalın projeksiyon eşdeğeri, DİZE
  TextColumn get kazananDeger => text().nullable()();
  IntColumn  get kaybedenWall => integer()();
  IntColumn  get kaybedenCounter => integer()();
  TextColumn get kaybedenClientHex => text()();
  TextColumn get kaybedenOpHex => text()();
  IntColumn  get kazananWall => integer()();
  IntColumn  get kazananCounter => integer()();
  TextColumn get kazananClientHex => text()();
  TextColumn get kazananOpHex => text()();
  BoolColumn get kaybedenYerelMi => boolean()();      // true: kaybeden BİZİM bekleyen yazımımızdı
  DateTimeColumn get olusturuldu => dateTime()();
  @override Set<Column> get primaryKey => {entityType, entityId, alan};
}
```

- **PK `(entityType, entityId, alan)` ⇒ alan başına TEK kayıt** (son çakışma üstüne yazar,
  `insertOnConflictUpdate`). Gerekçe: **çakışma geçmişi `K95`'te KAPSAM DIŞIDIR**; geçmiş
  tutmak tabloyu büyütür ve ekranı `K95`'in yasakladığı *"çakışma geçmişi"* özelliğine iter.
- **`clientHex`/`opHex` DAİMA normalize saklanır** (`normHex`) — `UzakAlanDurumu` ile aynı
  disiplin; normalize etmeyi çağırana bırakmak D3'ün pazarlıksız kuralını gevşetirdi.
- Migration: `if (from < 5) { await m.createTable(cakismaKayitlari); }` — **`Gorevler`e
  DOKUNULMAZ**, `alterTable` **çağrılmaz** (`Ö10` deseni).
- `storeDateTimeAsText: true` yürürlükte ⇒ `olusturuldu` **UTC** yazılır.

### D-SS2-2 — YAZMA NOKTASI: `_kanalUygula`, her İKİ yönde

Bugün kaybeden **iki yönde de** sessizce atılıyor (`Ö4`). Kayıt şu eşlemeyle yazılır:

| durum | kaybeden | kazanan | `kaybedenYerelMi` |
|---|---|---|---|
| gelen uzak yazım kuyruk tabanını **yendi** | **eski projeksiyon değeri** (uzak yazım uygulanmadan ÖNCE okunur) | gelen değer | `true` |
| kuyruk tabanı gelen yazımı **yendi** | **gelen uzak değer** | mevcut projeksiyon değeri | `false` |

🔴 **Eski projeksiyon değeri `_kanalUygula` içinde, yazımdan ÖNCE okunur.** `_projeksiyonYaz`
sonrası okumak **kaybedeni değil kazananı** kaydeder — bu, bu spec'in en kolay yapılan
hatasıdır ve `M172` onu ısırır.

### D-SS2-3 — ÇAKIŞMA TANIMI (PAZARLIKSIZ — gürültünün tek freni)

Kayıt **YALNIZ** şu koşulda yazılır:

> `kuyrukTabani != null` **VE** `kazandiMi(gelen, eskiMeta) != kazandiMi(gelen, enBuyuk(eskiMeta, kuyrukTabani))`
> — yani **kararı değiştiren şey kuyruktur.**

- **(a) Her uzak güncelleme çakışma DEĞİLDİR.** `kuyrukTabani == null` (o alanda bekleyen
  yerel yazım yok) ⇒ bu **normal senkrondur**, kayıt **YAZILMAZ**.
- **(b) Eski yazım da çakışma değildir.** Gelen, eski meta'yı bile yenemiyorsa (`kazandiMi(gelen, eskiMeta) == false`)
  kararı kuyruk değiştirmemiştir ⇒ kayıt **YAZILMAZ**.
- **(c) Kendi echo'muz çakışma DEĞİLDİR.** `kazandiMi` kesin büyüklük ister (`Ö9`); kendi
  yazımımızın echo'su eşit anahtarla döner ve **kaybeder** ⇒ karar değişmez ⇒ kayıt **YAZILMAZ**.
- **(d) Değer aynıysa çakışma DEĞİLDİR.** `kaybedenDeger == kazananDeger` (ordinal, tam dize)
  ⇒ kayıt **YAZILMAZ**; kullanıcıya iki özdeş sürüm gösterilmez.

### D-SS2-4 — `degerlendirVeMetaYaz` KARARI **RAPORLAR**, mantığı DEĞİŞMEZ

Dönüş `bool` → **record**:

```dart
typedef KanalKarari = ({
  bool projeksiyonKazandi,
  bool cakismaVar,          // D-SS2-3'ün dört elemesinden GEÇTİ mi
  AlanAnahtari? kaybedenAnahtar,
  AlanAnahtari kazananAnahtar,
});
```

🔴 **D3'ün "iki karar ayrımı" kilidi (Ö8) AYNEN durur:** meta kararı hâlâ yalnız eski meta'ya,
projeksiyon kararı hâlâ `enBuyuk(eskiMeta, kuyrukTabani)`'ya karşı verilir. **Bu karar
karıştırılırsa D6 (echo) ölür** — `M175` bunu ısırır. Değişen tek şey: hesaplanan bilgi
**atılmıyor, döndürülüyor**.

### D-SS2-5 — ROZET **TÜRETİLİR, YAZILMAZ** (D4 dokunulmazlığı korunur)

`gorev_deposu.rozetDikisi` üçüncü kanalı okur:

```
cakismaVarMi = zehirli > 0 || senkronDurumu == 'cakisma' || cakismaKaydiVar
```

🔴 **`uzak_degisiklik_uygulayici` `senkronDurumu`'na ASLA yazmaz** — D4'ün pazarlıksız
kuralı bu dilimde de geçerlidir ve `M176` onu ısırır. `CakismaKayitlari`'na yazmak rozete
yazmak **değildir**; rozet okuma anında türetilir.

### D-SS2-6 — ÇÖZÜM EYLEMİ: seçim **kuyruğa normal bir yazma** olarak girer (K95 kilidi)

| buton | `kaybedenYerelMi == true` | `kaybedenYerelMi == false` |
|---|---|---|
| **Benimkini tut** | kaybeden (yerel) değer **YENİ HLC** ile kuyruğa girer | kazanan zaten yerelin ⇒ **yazma YOK** |
| **Onlarınkini al** | kazanan zaten uzağın ⇒ **yazma YOK** | kaybeden (uzak) değer **YENİ HLC** ile kuyruğa girer |

- Her iki durumda da entity'nin **TÜM** çakışma kayıtları silinir (entity başına tek karar).
- Yazma, mevcut yerel-yazma akışının **AYNISIDIR** (yeni `opId`, yeni HLC damgası, `bekliyor`);
  `SS2` **ayrı bir gönderim yolu açmaz** — `K95`'in *"normal bir yazma"* kilidi budur.
- 🔴 **Kayıt, yazma kuyruğa GİRDİKTEN SONRA silinir** (aynı `transaction`). Ters sıra, uygulama
  arada ölürse **hem çakışmayı hem yazımı** kaybettirir; `M177` bunu ısırır.

### D-SS2-7 — ESKİ `cakisma` KANALI **SİLİNMEZ, DOKUNULMAZ**

`Ö1`'deki üç yazım noktası (`Rejected*`, 4xx, deneme tavanı) **olduğu gibi kalır**. `SS2`
**dördüncü** bir kanal eklemez, **üçüncü** bir rozet kaynağı ekler. Gerekçe: o kanal gerçek bir
ürün davranışını (*yazımın sunucuya geçmemesi*) gösteriyor ve `A11`'in kabul edilmiş
kriterlerine bağlı; bu dilimde değiştirmek **kabul edilmiş işi geri almaktır**.
🔴 **Beyan edilmiş bedel:** rozet **iki farklı olayı** aynı ikonla gösterir. Ayrıştırma
`SS2` **kapsamı dışıdır** ve `BORCLAR.md`'ye borç olarak yazılır.

### D-SS2-8 — EKRAN: `CakismaCozumSayfasi` **DOLDURULUR**, sıfırdan yazılmaz

- İki ölçülmüş sabit **KORUNUR** (`Ö11`): `kCakismaBasligiMaxSatir = 1` (🔒 sabit, ölçülmez —
  `AppBar` `_kMaxTitleTextScaleFactor = 1.34`'e kelepçeli) · `kCakismaGovdesiMaxSatir = 6`
  (dokuz noktalı izgarada ölçülmüş en küçük N). **Yeni metin düğümleri kendi `maxLines`'ını
  ölçmek zorundadır** — `A8`/`A9`'un metin-kaybı disiplini (`G16`) bu ekranda da koşar.
- Sayfa **`entityId` alır** (bugün parametresiz). Rozet dokunuşu `entityId`'yi geçirir.
- Yerel ↔ uzak **yan yana**; **farklı alan vurgulu**; iki buton; `DESIGN.md` v2 token'ları
  (`K46` gereği `DESIGN.md`'ye **tek bayt yazılmaz**, yalnız **tüketilir**).
- A11Y: iki buton **48 dp** dokunma hedefi + `Semantics(button: true)` + ayırt edici etiket
  (*"Benimkini tut"* / *"Onlarınkini al"*), `A11Y-1…7` yürürlükte.

### D-SS2-9 — KAPSAM DIŞI (K95 kilidi, aynen)

Alan-bazlı birleştirme · üç-yollu merge · **çakışma geçmişi** · toplu çözüm · kimlik.
🔴 **Ekranın alanları yan yana göstermesi "alan-bazlı birleştirme" DEĞİLDİR:** kayıt alan
bazlıdır ama **karar entity başınadır** — kullanıcı alan alan seçim yapamaz.

---

## 4. YAPILACAKLAR (sıra PAZARLIKSIZ — K53/5: yürüyen iskelet önce, kapılar sonra)

| adım | iş | biter göstergesi |
|---|---|---|
| **T1** | `CakismaKayitlari` tablosu + `schemaVersion` 4→5 + migration (`D-SS2-1`). `drift_dev`: **dump + generate** (iki ayrı komut, `Ö6`/A11 dersi). | `veritabani.g.dart` üretildi, `flutter test` **yeşil** |
| **T2** | `KanalKarari` record'u + `degerlendirVeMetaYaz` **raporlama** (`D-SS2-4`). Karar mantığı **değişmez**. | mevcut `G3`/`G5`/`G10` testleri **hâlâ yeşil** (regresyon yok) |
| **T3** | `_kanalUygula`'da çakışma kaydı yazımı (`D-SS2-2` + `D-SS2-3` dört elemesi). Eski projeksiyon değeri **yazımdan önce** okunur. | `SS2/G32` yeşil |
| **T4** | `rozetDikisi` üçüncü kanal (`D-SS2-5`). | `SS2/G33` yeşil |
| **T5** | `CakismaCozumSayfasi` doldurulur; `entityId` parametresi; rozet dokunuşu geçirir (`D-SS2-8`). | `SS2/G34` statik ayakları yeşil |
| **T6** | Çözüm eylemi + tek `transaction` (`D-SS2-6`). | `SS2/G34` davranış ayakları yeşil |
| **T7** | Mutantlar `M171`–`M178` koşulur; her biri **ısırdığını** kanıtlar. | `## 6` tablosunun tamamı ölçüldü |
| **T8** | `KANIT/SS2/` altına ham çıktılar; `spec-kapi-kapsama.py` bu spec'in **yoluyla** koşulur (dizinle değil, K81). | `[S0]`/`[S1]`/`[S2]` **yok** |

🔴 **T1 ile T2 arasına ürün kodu girmeden T3'e geçilmez** — `R8` sert durağı bu dilimde
**canlıdır** (oturum 53 = 0 satır, oturum 54 = 0 satır ölçüldü; üçüncüsü K53/4'ü tetikler).

---

## 5. KAPILAR

> Kapı kimliği **spec-yereldir** (K108) — atıf daima `SS2/G31` biçiminde. Her kapı **ayak
> ayak** yazılır; bir ayak *"nasıl ölçüldüğünü"* söylemiyorsa **kördür** ve kabul edilmez
> (`A13`'ün `G29/b` dersi: *"'Xcode build done.' başarısız derlemede de basılır"*).

### G31 — DEPOLAMA VE MİGRATION GERÇEKTEN SALT-EKLEME

- **a)** `veritabani.dart`'ta `schemaVersion == 5` ve `@DriftDatabase(tables: [...])` listesinde
  `CakismaKayitlari` **var**. *Ölçüm:* `araclar/ss2-kapisi.py` — dosyada `schemaVersion => 5`
  deseni + tablo adı; **ikisi birden** aranır (tek dizge kör olurdu).
- **b)** `onUpgrade` içinde `from < 5` bloğu **yalnız `createTable`** çağırır; aynı blokta
  `alterTable(` **geçmez** ve `gorevler` **adı geçmez**. *Ölçüm:* aynı betik, `from < 5`
  bloğunun **metin aralığında** arama (dosya geneli değil — dosya geneli `from < 2`'deki
  meşru `alterTable`'ı yakalar ve **yanlış-pozitif** verir).
- **c)** **v4 verisi olan bir DB v5'e yükseltilince `gorevler` satırları KORUNUR.**
  *Ölçüm:* widget/birim testi — `schemaVersion 4` şemasıyla açılıp 2 görev yazılan bir bellek
  DB'si v5 ile yeniden açılır; **satır sayısı ve `baslik` dizeleri özdeş** döner.
- **d)** `CakismaKayitlari`'na yazılan `clientHex`/`opHex` **normalize**dir (tiresiz, küçük harf).
  *Ölçüm:* birim testi — tireli/büyük harfli GUID ile yazım yapılır, DB'den okunan sütun
  `normHex` çıktısıyla **birebir** karşılaştırılır.

### G32 — ÇAKIŞMA TESPİTİ: DOĞRU DURUMDA YAZAR, DİĞER HEPSİNDE SUSAR

- **a)** *(pozitif)* Kuyrukta bekleyen yerel yazım varken **onu yenen** uzak yazım gelir ⇒
  **1 kayıt**, `kaybedenYerelMi == true`, `kaybedenDeger` = **eski projeksiyon değeri**.
- **b)** *(pozitif, ters yön)* Kuyruktaki yerel yazım gelen uzak yazımı **yener** ⇒ **1 kayıt**,
  `kaybedenYerelMi == false`, `kaybedenDeger` = **gelen uzak değer**, projeksiyon **değişmez**.
- **c)** *(negatif)* Kuyruk **boş** iken uzak yazım gelir ⇒ **0 kayıt** (`D-SS2-3/a`).
- **d)** *(negatif)* Gelen yazım **eski meta'yı bile yenemiyor** ⇒ **0 kayıt** (`D-SS2-3/b`).
- **e)** *(negatif)* **Kendi echo'muz** (aynı anahtar) döner ⇒ **0 kayıt** (`D-SS2-3/c`, D6 canlı).
- **f)** *(negatif)* Kaybeden ve kazanan **değer aynı** ⇒ **0 kayıt** (`D-SS2-3/d`).
- **g)** `zehirli` kuyruk satırı çakışma **üretmez** (`Ö7`) ⇒ **0 kayıt**.
- *Ölçüm:* yedisi de `src/client/test/ss2_cakisma_kaydi_test.dart` içinde **ayrı** testlerdir;
  **sayı ile** ölçülür (`select(cakismaKayitlari).get().length`), *"kayıt var mı"* diye değil.

### G33 — ROZET TÜRETİLİR VE `senkronDurumu`'NA YAZILMAZ

- **a)** Çakışma kaydı olan görevde `GorevGorunum.cakismaVarMi == true`, kayıt silinince `false`.
  *Ölçüm:* birim testi, `rozetDikisi` üzerinden.
- **b)** 🔴 **`senkronDurumu` DOKUNULMAZ:** çakışma kaydı yazıldıktan **sonra** görevin
  `senkronDurumu` sütunu, yazımdan **önceki** değeriyle **birebir aynıdır**. *Ölçüm:* aynı testte
  önce/sonra dize karşılaştırması (D4 kilidi).
- **c)** `uzak_degisiklik_uygulayici.dart` kaynağında `senkronDurumu` **yalnız** bugünkü
  INSERT dalında geçer. *Ölçüm:* `ss2-kapisi.py` — sembol sayımı, **beklenen sayı pinli**
  (gevşek *"geçiyor mu"* araması `M176`'yı kaçırırdı).

### G34 — EKRAN VE ÇÖZÜM EYLEMİ

- **a)** `CakismaCozumSayfasi` **`entityId` alır** ve rozet dokunuşu onu **geçirir**.
  *Ölçüm:* statik — parametresiz kurucu kaynakta **kalmamıştır**; + widget testi.
- **b)** Ekran çakışan alanın **iki değerini de** gösterir. *Ölçüm:* widget testi —
  `find.text(yerelDeger)` **ve** `find.text(uzakDeger)` **ikisi de** bulunur.
- **c)** İki buton **48 dp** dokunma hedefi taşır ve `Semantics(button: true)` + **ayrı**
  etiketlere sahiptir. *Ölçüm:* widget testi, `tester.getSize` + semantics düğümü.
- **d)** *Benimkini tut* (`kaybedenYerelMi == true`) ⇒ kuyruğa **1 yeni op** girer, `opId`
  **yeni**, HLC damgası **öncekinden büyük**; kayıt **silinir**. *Ölçüm:* birim testi —
  kuyruk sayısı önce/sonra + `AlanAnahtari.compareTo > 0`.
- **e)** *Onlarınkini al* (`kaybedenYerelMi == true`) ⇒ kuyruğa **yeni op GİRMEZ**; kayıt silinir.
- **f)** Kayıt silme ile kuyruğa yazma **aynı `transaction`**tadır ve **yazma öncedir**.
  *Ölçüm:* `_GozlemciUygulayici` desenli çağrı-sırası testi (`g5_yerel_koruma_kapisi_test.dart`
  bu deseni **zaten kullanıyor**, kopyalanır).
- **g)** Metin düğümleri taşmaz: `didExceedMaxLines == false`, **dokuz noktalı** izgarada
  (`A9`/`G16` disiplini, `kCakismaGovdesiMaxSatir` **korunur**).

---

## 6. MUTANTLAR

**Maliyet sınıfına göre tavan (K53/3):** bu dilimde **koşan uygulama** (emülatör + yeniden
derleme) isteyen mutant **YOKTUR** — tavan (3) **hiç kullanılmaz**. Hepsi *statik* ya da
*widget/birim testi* sınıfındadır ⇒ **tavansız**, saniyeler sürer.

🔴 **SÜTUN DÜZENİ PAZARLIKSIZ — `hedef` ÜÇÜNCÜ SÜTUNDUR** (K126): `spec-kapi-kapsama.py`
mutant hedefini `hucreler[2]`'den okur. `A13` ilk yazımında `hedef`i 4. sütuna koydu ve
**sekiz mutantın hiçbiri hiçbir kapıya bağlanmadı**.

| mutant | sınıf | hedef | ne bozulur | beklenen |
|---|---|---|---|---|
| M171 | statik | `SS2/G31` · `D-SS2-1` | `veritabani.dart`'ta `schemaVersion => 5` → `=> 4` yapılır (tablo tanımı KALIR) | `ss2-kapisi.py` **KIRMIZI** |
| M171b | statik | `SS2/G31` | `schemaVersion => 5` korunur, tablo listesine `CakismaKayitlari` **eklenmiş** hâliyle bırakılır | `ss2-kapisi.py` **SUSMALI** — yanlış-pozitif kontrolü |
| M172 | birim testi | `SS2/G32` · `D-SS2-2` | `_kanalUygula`'da eski projeksiyon değeri **yazımdan SONRA** okunur (satır aşağı taşınır) | `G32/a` **KIRMIZI** — `kaybedenDeger` kazananla eşitlenir |
| M173 | birim testi | `SS2/G32` · `D-SS2-3/a` | Çakışma koşulundan `kuyrukTabani != null` şartı silinir | `G32/c` **KIRMIZI** — kuyruk boşken kayıt üretilir |
| M174 | birim testi | `SS2/G32` · `D-SS2-3/d` | Değer-eşitliği elemesi silinir | `G32/f` **KIRMIZI** |
| M175 | birim testi | `SS2/G32` · `D-SS2-4` | `degerlendirVeMetaYaz`'da meta kararı da `enBuyuk(eskiMeta, kuyrukTabani)`'ya karşı verilir (iki karar **karıştırılır**) | `G32/e` **KIRMIZI** + mevcut D6/echo testi **KIRMIZI** (iki kapı birden ısırır) |
| M176 | statik | `SS2/G33` · `D-SS2-5` | `uzak_degisiklik_uygulayici`'nin UPDATE dalına `senkronDurumu: Value('cakisma')` **eklenir** | `ss2-kapisi.py` `G33/c` **KIRMIZI** (sembol sayısı pinden sapar) + `G33/b` **KIRMIZI** |
| M177 | birim testi | `SS2/G34` · `D-SS2-6` | Çözüm eyleminde **önce kayıt silinir, sonra** kuyruğa yazılır (sıra ters çevrilir) | `G34/f` **KIRMIZI** — çağrı sırası testi |
| M178 | widget testi | `SS2/G34` · `D-SS2-8` | Ekrandan **uzak sürüm** metin düğümü silinir (yalnız yerel gösterilir) | `G34/b` **KIRMIZI** |
| M178b | widget testi | `SS2/G34` | İki butonun `Semantics` etiketi **aynı** dizeye çevrilir | `G34/c` **KIRMIZI** — ayırt edicilik ayağı |

🔴 **`M175` NEDEN İKİ KAPIYI BİRDEN ISIRMALI:** `A13`'ün `M167` dersi (*"eşdeğer mutant =
hedeflediği kuralın çekirdek iddiasını ölçmeyen mutant"*) burada **önlem olarak** yazılıdır.
`M175` yalnız `G32/e`'yi düşürseydi, D3'ün "iki karar ayrımı" kilidinin **hâlâ canlı** olduğunu
kanıtlamazdı. Mevcut D6/echo testinin de düşmesi, kilidin **bugün gerçekten yük taşıdığını**
ölçer. **Yalnız birini düşürüyorsa mutant eşdeğerdir ve hedefi yanlış etiketlenmiştir.**

🔴 **`M171b` ve `M178b` YANLIŞ-POZİTİF KONTROLLERİDİR** — bir kapının *ısırdığını* göstermek
yetmez, **susması gerektiğinde sustuğunu** da göstermek gerekir (`A13`/`M163b` deseni).

## 6b. MUTANT BORCU

> 🔴 **BİÇİM PAZARLIKSIZ:** `spec-kapi-kapsama.py`/`borclar()` **yalnız** satır başındaki
> `- KURAL: <ad> | GEREKCE: <en az 20 karakter>` desenini okur; **tablo OKUNMAZ**. Bu spec ilk
> yazımında borçları tabloya koydu ve araç **`[S2]` × 2** ile ısırdı — kusur builder'ın değil,
> **spec'i yazan elindir** (K81'in aynı dersi, K126'nın sütun-sırası vakasının kardeşi).
> **KAPI borçlanamaz, yalnız KURAL borçlanabilir** (S5).

- KURAL: D-SS2-7 | GEREKCE: Bu bir DEGISMEZLIK kuralidir (eski `cakisma` kanali dokunulmaz). Mutanti "kanali sil" olurdu; bu mutant A11'in KABUL EDILMIS testlerini dusururdu, yani olctugu sey SS2 degil A11 olurdu -- hedefi yanlis etiketlenmis mutant (A13/M167 dersi). Kapanis yolu: A11'in ilgili testleri bu kanali ZATEN pinliyor; SS2 onlara dokunmadigini T2'nin regresyon olcumuyle gosterir.
- KURAL: D-SS2-9 | GEREKCE: Bu bir YAPMAMA kararidir (alan-bazli birlestirme, uc-yollu merge, cakisma gecmisi, toplu cozum KAPSAM DISI -- K95 kilidi) ve bir yapmama kararinin mutanti yoktur: olmayan is bozulamaz. Kapanis yolu: bu ozelliklerden biri ileride kapsama girerse KENDI mutantiyla girer; o ana kadar kural yalniz SINIR olarak yasar.

🔴 **BORÇ OLMAYAN İKİ BEYAN — DOĞRU SINIFA TAŞINDI (`A13`/`D-A13-1` dersinin uygulanması).**
`D-SS2-3`'ün **`/b` alt-ayağı** ve `D-SS2-1`'in **v3→v5 zinciri** ilk yazımda borç sanılmıştı;
ikisi de borç **değildir**, çünkü kuralların kendisinin mutantı **VAR** (`M173`/`M174` ve
`M171`). Beyan edilen şey *kuralın mutantsızlığı* değil, **mutantın kuralın yalnız bir ayağını
ölçmesi**dir ⇒ ikisi de **§8'e sınır olarak** taşındı (`S7`, `S9`). *Kapı susturulmadı.*

---

## 7. KABUL KRİTERLERİ (hepsi **Cowork'ün KENDİ koşumuyla** ölçülür — K26)

1. `flutter analyze` **0 sorun** (`--fatal-infos`; 3.44.6'da varsayılan açık — `A13`/§9 dersi).
2. `flutter test` **tamamı yeşil** ve toplam sayı **artmıştır** (yeni testler eklendi;
   sayı **ölçülür**, spec'e **yazılmaz** — bayat sayı sınıfı).
3. `SS2/G31`–`SS2/G34` **her ayağı** geçer; her ayağın **nasıl ölçüldüğü** kanıtta yazılıdır.
4. `M171`–`M178b` **hepsi ısırır**; `M171b`/`M178b` **susar**. Isırmayan mutant ⇒ **kabul YOK**.
5. `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-SS2-cakisma-cozumu.md`
   ⇒ `[S0]`/`[S1]`/`[S2]` **yok**, mutantsız kural **yalnız `## 6b`'de gerekçeliler**.
6. `araclar\ss2-kapisi.py --altin-kume` **kendi altın kümesini geçer** (kör kapı yok, K44-a:
   **önce araç, sonra belge**).
7. `python araclar\verify.ps1` backend zinciri **etkilenmemiştir** (bu dilim istemci işidir;
   backend'e **tek bayt yazılmaz** — ölçülür, varsayılmaz).
8. Uçtan uca: iki istemci örneği (aynı `devUserId`, farklı `clientId`) aynı görevin başlığını
   çevrimdışı değiştirir; bağlanınca **kaybeden tarafta** rozet çıkar, ekran **iki değeri de**
   gösterir, *Benimkini tut* seçilince değer **karşı tarafa ulaşır**.
   🔴 Bu kriter **koşan ortam** ister (`K80`): `docker start momentum-postgres` → backend
   (`ASPNETCORE_ENVIRONMENT=Development`, `ConnectionStrings__Momentum`, `ASPNETCORE_URLS=http://0.0.0.0:5298`)
   → hazır olduğu **`/health/ready` 200 + `POST /v1/sync` 401→200** ile ölçülür, portla değil
   (`ORTAM.md`). **Ortamı Claude Code kaldırır, Cowork yalnız ölçer.**
9. `KANIT/SS2/` altında her kriterin **ham** çıktısı vardır; özet dosyası kanıt **sayılmaz**.

---

## 8. BEYAN EDİLMİŞ SINIRLAR (gizlenmiş sınır kabul edilmez — §4)

- **S1** — Çakışma **alan bazlı** saklanır ama karar **entity başınadır**; kullanıcı alan alan
  seçemez (`K95` kapsam dışı: alan-bazlı birleştirme).
- **S2** — **Çakışma geçmişi YOKTUR:** alan başına tek kayıt; ikinci çakışma birincinin
  üstüne yazar. `K95` kilidi.
- **S3** — `zehirli` op çakışma **üretmez** (`Ö7`): `kuyrukEnBuyuk` yalnız `bekliyor`+`gonderildi`
  tarar. Reddedilmiş yazım *"çakışma"* değil, *"geçmemiş yazım"*tır ve **eski kanalda** görünür.
- **S4** — `order:*` ve `sets` kanalları **kapsam dışı**: projeksiyon eşlemesi olan **üç** kanal
  (`fields:title`, `fields:isDeleted`, `groups:completion`) için kayıt yazılır. `order` için
  gerçek bir tel örneği bu depoda **hiç ölçülmedi** (`uzak_degisiklik_uygulayici`, [BEYAN]).
- **S5** — Rozet **iki farklı olayı** aynı ikonla gösterir (`D-SS2-7`); ayrıştırma **borçtur**.
- **S6** — Web ayağı **`[DOĞRULANMADI]`**: `flutter test --platform chrome` bu ortamda sonuç
  üretmiyor (iki ölçüm: 7 dk ve 9,8 dk — `ORTAM.md`). Kriter 8 **Android** üzerinde koşar.
- **S7** — v3→v5 migration zinciri **`[DOĞRULANMADI]`**: `G31/c` yalnız **v4→v5**'i ölçer.
  Bu bir **mutant borcu DEĞİLDİR** (`D-SS2-1`'in mutantı `M171` var), bir **ölçüm boşluğudur**
  ⇒ `BORCLAR.md`'ye `B-SS2-1` olarak yazılır.
- **S9** — `D-SS2-3/b` (*"eski yazım çakışma değildir"*) ayağını `G32/d` **ölçer** ama ayrı bir
  mutantı **yoktur**: `kazandiMi(gelen, eskiMeta)` şartını silmek `M173`'ün bozduğu **aynı
  koşul satırını** bozar ⇒ **eşdeğer mutant** olurdu (`A13`/`M167` dersi). Koşul iki ayrı
  satıra bölünürse ayrı mutant **anlamlı** olur; o zaman yazılır.
- **S8** — Bu spec `CakismaCozumSayfasi`'nın **görsel** tasarımını token düzeyinde sabitler ama
  **piksel** düzeyinde ölçmez; `DESIGN.md` v2 tüketilir, **değiştirilmez** (`K46`).

---

## 9. DOSYA KİMLİĞİ

🔴 **Kimlik DAİMA son yazımdan SONRA ölçülür** (`python araclar\dosya-kimlik.py <yol>`) ve
kilit satırı yazıldıktan sonra **yeniden** alınır — `A13`'te bu iki kez atlandı.

| durum | bayt | sha8 |
|---|---|---|
| kilit adayı (oturum 54, denetim **öncesi**) | *(§9'a denetimden sonra yazılır)* | *(aynı)* |

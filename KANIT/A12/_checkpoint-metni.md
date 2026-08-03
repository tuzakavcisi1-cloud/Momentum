## 🔒 CHECKPOINT — K124 · **`GOREV-A12` KABUL EDİLDİ** (Onur kilitledi, 3 Ağu 2026, oturum 51)

🔴 **Tarih cihazdan ÖLÇÜLDÜ: `2026-08-03 11:57 +03:00`.**

`K123`'ün üç şartı da tutuldu ve **yedi kriterin yedisi de ölçülerek** geçti. Hepsi **Cowork'ün
kendi koşumudur** (`K26`); builder'ın beyanı okundu ama **hiçbiri kanıt yerine sayılmadı**.
Hüküm: `KANIT/A12/04-COWORK-KABUL-HUKMU.md`. Ölçüm anındaki kimlikler:
`araclar/spec-kapi-kapsama.py` **17.100 b**/`DE87E43D` · `GOREV-A11` **35.255 b**/`9BB716DF` ·
`GOREV-A12` **15.219 b**/`70A6720A`.

**YEDİ KRİTER:**
**0** patlama yarıçapı — Cowork'ün bağımsız tabanı **önce `AF42E7E7` ↔ sonra `D26FA3F7`**: 23 spec,
bulgu **10 → 10**; **21 spec'in hükmü birebir aynı**, değişen tek şey `A11` `KURAL (0)→(6)` ve
`A12` `(0)→(3)`, ikisi de **EXIT 0** ⇒ envantere yeni giren kural sınıfı **dışında fark = 0** ✅ ·
**1** altın küme **21/21**, EXIT 0 (yeni vaka 14–21) ✅ · **2** 🔴 **`M156`–`M161` 6/6 ISIRDI**
(`_cowork_mutant.py`; ORTAM.md reçetesi: ikili yedek → **bayt yaması** → koşum → **yedekten** geri
yaz → sha). Her mutantta araç **`DE87E43D` bayt-özdeş** geri geldi; `M160` ayrıca **gerçek depoda**
ölçüldü: bulgu **10 → 265**. TEMİZ-ÖNCE **ve** TEMİZ-SONRA EXIT 0 ✅ · **3a** §6b kayıtlarından
**önce**: `A11` **EXIT 1 / tam 6** `[S2]`, `A12` **EXIT 1 / tam 3** `[S2]` — **kopya üzerinde**
ölçüldü, orijinallerin sha8'i önce/sonra **özdeş** (dosyalara dokunulmadı) ✅ · **3b** kayıtlardan
**sonra**: ikisi de **EXIT 0**, `[S2]` yok, `KURAL (0)` yazmıyor ✅ · **4** `sayi-tazeligi` **TEMİZ**
(`DURUM.md` araç tablosu `13/13 → 21/21` tazelendi) ✅ · **5** `tek-kopya` **YEŞİL** ✅.

**ÜÇ ŞART:** ① 9 borç kaydının **9'u da** `MUTANTSIZ DEGILDIR:` ile başlıyor, ısıran mutantı **adıyla
ve kapı-ayağıyla** veriyor; **hiçbiri "mutantı yok" demiyor** — fazlası da var (`D-A11-6` için
*"ÇİFT DOLAYLI"*, `D-A12-2` için alt-desenin kendi mutantı olmadığı ayrıca beyan edildi) ②
`D-A12-3` **daraltıldı** + errata · kriter 3 **3a/3b** oldu · *"sekiz"* → **10**, on spec **adıyla**
sayıldı ③ `git diff` ile ölçüldü: **`S2` üretimi değişmemiş**, yalnız envanterin **kaynağı** genişledi
(`uc_baslik_kurallari` eklendi, `kod_araligi_ac` deseni açıldı); kalan kör nokta `BORCLAR.md`
**`B-O51-1`** olarak yazıldı.

🔴 **BUILDER, COWORK'ÜN EŞLEME ÖNERİSİNİ İKİ NOKTADA ÇÜRÜTTÜ — VE HAKLIYDI.** `K123`'te Cowork dokuz
kural için mutant eşlemesi önermişti; builder ikisini reddedip **spec'in kendi metnini** kanıt
gösterdi, Cowork yeniden ölçüp **builder'ı doğruladı**: ① `M150` → `D-A11-3` **değil `D-A11-5`**
(`D-A11-5`'in gövdesi harfiyen *"`cekmeTuruCalistir`, `SenkronAgi` ve **`_yuvarlakDongusu`** yasak
kalır (denetim `B5`)"* diyor; mutant tam o kümeyi bozar) ② `M161` → `D-A12-2` **değil `D-A12-1`**
(mutant §5 ilk-sütun kaynağını kaldırır, o da `D-A12-1`'in *"§5 **korunur**"* yarısıdır) ③ ayrıca
`D-A11-5`'e **`M147`** eklendi — Cowork'ün listesinde yoktu ve `(dosya, sınıf)` çiftinin **en doğrudan**
testi oydu. **`K26` çift yönlü işledi: denetçi de denetlendi.** Kâğıtta kurulan eşlemeyi belgenin
kendi metni düzeltti — *"ölç ya da `[DOĞRULANMADI]` yaz"* kuralının Cowork'e uygulanmış hâli.

🟢 **`BORCLAR.md` BUDANDI — VE BU, `K117`'NİN ÖLÇÜMÜNÜ ÇÜRÜTMEZ, ŞARTINI NETLEŞTİRİR.**
Kapı **`T2` SARI** verdi (23.995/24.576, pay **581 b**, eşik 1.228: *"bir sonraki checkpoint tavanı
AŞAR"*). Onur budamayı seçti. Kapanan **tek** kalem çıkarıldı — `spec-kapi-kapsama.py`'nin kural
yarısı, yerine **üç satırlık** atıf (`K124` + `B-O51-1`). Ölçülen sonuç: **23.995 → 22.889 b
(−1.106)**, pay **581 → 1.687 b** ⇒ **YEŞİL**. 🔴 `K117` *"budama bu dosyada işe yaramıyor"* demişti
ve **haklıydı**: oturum 48'de **kapanan kalem yoktu**, budama anlatım kısaltmaya çalışıyordu (net
+258 b). Bu turda **gerçekten kapanan bir kalem vardı**. **Doğru kural şudur: bu dosyada budama
ancak bir borç KAPANDIĞINDA işe yarar; anlatımı kısaltarak yer açma girişimi ölçülerek başarısızdır.**

## 🔴 BU OTURUMUN KENDİ KUSURU — `K55` İHLALİ (Cowork, kendi beyanı)

`K122` yazımını commit'lerken (`5067246`) `git add … KANIT/A12` denildi. O dizinde **builder'ın o
anda çalışan, commit'lenmemiş 24 ara çıktısı** vardı (`CC-TABAN-ONCESI-tam.txt` + `onceki/`23) ve
hepsi commit'e girdi. `K55` *"başka bir el çalışırken `git add -A` YASAK"* der; `-A` kullanılmadı ama
**dizin verildi** ve sonuç aynı oldu — **kuralın lafzına uyulup ruhuna uyulmadı**.
**Ölçülen zarar:** dosyaların hiçbiri silinmedi/bozulmadı; hasar **sahiplik ve kayıt düzeyinde**,
veri düzeyinde **değil**. Cowork bunu fark ettiği anda Onur'a bildirdi ve **git'e dokunmayı bıraktı**
(builder çalışırken index'e girmek gerçek hasarı orada üretirdi); `K123` checkpoint'i bu yüzden
**commit'siz** yazıldı. **Ders: `git add <dizin>` de bir kör alımdır — yol verilen her şey, o yolun
ALTINDAKİ her şeydir.**

## AÇIK KALANLAR (kabulü engellemedi, **beyan edildi**)

1. 🔴 **`B-O51-1`** — `S2` dolaylı kapı-ayak→kural eşlemesini görmüyor. **Bilerek** kapatılmadı
   (Şart 3). Bedeli yazılı: bundan sonraki **her** spec aynı sınıfı üretecek ve her seferinde elle
   §6b borcu yazmayı gerektirecek.
2. 🔴 **`kriter-içi-çelişki` sınıfının mekanik kapısı YOK.** İki dilimde üst üste ısırdı
   (`A11` kriter 7↔8 · `A12` kriter 3) ve **ikisi de ancak kabul koşumunda** görüldü.
3. 🔴 **`A12` ürün kodu DEĞİLDİR** ⇒ `R8` sayacını **düşürmez**. Bir sonraki oturum da araç/belge işi
   olursa **sert durak yanar** ve o oturum ürün koduyla başlamak **zorundadır** (`K53`/4).

# SS2 v2 — İKİNCİ KİLİT ÖNCESİ DENETİM (K127) · HÜKÜM: **KİLİTLENEMEZ** (ama ilerleme ÖLÇÜLDÜ)

**Tarih:** 3 Ağu 2026, oturum 54 · **Denetlenen:** v2 — **34.504 b · `66CC4AAE`** (U+FFFD 0 · CRLF 0)
**Mekanik ön kapı:** `spec-kapi-kapsama.py` **EXIT 0** (4 kapı / 11 kural / **20 mutant** / 3 gerekçeli
borç) · `kapi-ad-teklik-kapisi.py` **YEŞİL** · `dosya-kimlik.py` **TEMİZ**
**K53/1 gerekçesi:** tur 1 **mimariyi değiştiren** bir bloker buldu (`D-SS2-3`'ün cebiri) ⇒ ikinci tur **meşru**.

---

## 🔴 ÖNCE BU TURUN KENDİ KUSURU — `device_stage_files` BAYAT KOPYA SUNDU, COWORK SHA'YI KARŞILAŞTIRMADI

**ÖLÇÜLDÜ:** buluta stage edilen dosya **28.801 b** (v1), cihazdaki gerçek dosya **34.504 b** (v2);
md5 `946e1d07…` — stage `18:19`'da, v2 yazımı `18:59`'da. **Üç denetçiden ikisi (D4, D6) v1'i okudu.**

🔴 `ORTAM.md` bunu **kanla yazılı madde olarak** taşıyor: *"`device_stage_files` BAYAT KOPYA
sunabiliyor (oturum 28; 30'da tekrarlanmadı) ⇒ stage'lenenin **sha'sını karşılaştır**;
tutmuyorsa `read_file` kullan."* **Cowork bu maddeyi okudu ve uygulamadı** — açılış protokolünün
1. adımında `ORTAM.md` TAM okunmuştu.
**Sınıf:** `olcum-aracinin-varsayimi`. **Bedel:** iki denetçi turu (~307k subagent token) **boşa gitti**.
**Ders:** *okunan mayın listesi, uygulanan mayın listesi değildir.* — `A13`/`M167`'nin
(*"okunan onarım, ölçülmüş onarım değildir"*) kardeşi.

**Geçerlilik hükmü:**
- **D5 — GEÇERLİ.** Bayatlığı **kendisi fark etti**, v2'yi **cihazdan** okudu (34.504 b / 453 satır),
  kaynak dosyaları md5 ile doğruladı. **5 bloker · 11 major · 5 minor.**
- **D4 — KISMEN GEÇERLİ.** *Bölüm A* (v1'e karşı) **geçersiz**; *Bölüm B*'nin **kaynağa karşı**
  ölçülen 5 maddesi **geçerli** (kaynak v1↔v2'de değişmedi).
- **D6 — GEÇERSİZ.** Tümü v1'e karşı. *(Bir istisna: K53/4 alıntısının doğruluğu — aşağıda.)*

---

## GEÇERLİ BULGULAR (D5 tam + D4/Bölüm-B)

### BLOKER

**B2-1 — `M172` HÂLÂ EŞDEĞER; v1'in BLOKER-3'ü kılık değiştirerek geri geldi.** (D5)
Kaybeden değer `_projeksiyonYaz:209`'daki **bellekteki `mevcut` nesnesinden** okunur. Kayıt yazımını
`write(companion)`'ın **altına taşımak** `mevcut`'u **yeniden okumaz** ⇒ `kaybedenDeger` bayt-özdeş
kalır ⇒ `G32/a` **YEŞİL**. §6c'nin onarım gerekçesi (*"orada gerçek bir `write` var"*) **yetersiz**:
gereken şey yazım değil, **yazımdan sonra yeniden OKUMA**.
🔴 **Bu, dersin ÜÇÜNCÜ kez alıntılanıp uygulanmadığı vakadır.**

**B2-2 — `M176` mevcut `G10` testlerini DÜŞÜREMEZ ⇒ kriter 4 kabulü kendi kuralıyla engelliyor.** (D5)
sqlite ile ölçüldü: çakışma satırı **0 iken** `distinct`'li ve `distinct`'siz sayımlar **özdeş**;
fan-out yalnız `cakismaKayitlari` **dolu** iken doğar (`2 → 4`). `g10_rozet_kapsami_test.dart`'ın
altı ayağının hiçbiri çakışma kaydı yazmaz — **üstelik hiçbiri sayım da ölçmez** (sayım testleri
**`g11`**'de). Kriter 4'ün *"`G10`'u düşürmüyorsa hedefi yanlış"* şartı **hiçbir koşulda** sağlanamaz.

**B2-3 — `M171b` yine sıfır-bilgi.** (D5) Mutant gerçek `schemaVersion => 5` satırını **koruyup**
üstüne yorum ekliyor; `G31/a` **varlık** araması yapıyor ⇒ yorumu atan da atmayan araç da **YEŞİL**
döner. Ayırt eden mutant **tersidir**: gerçek satır `=> 4` yapılıp doğru değer **yalnız yorumda**
bırakılmalı. Spec'in **tek** yanlış-pozitif kontrolü ölçmüyor.

**B2-4 — `D-SS2-3/e` (bayatlama) şart 3'ü ATLIYOR ⇒ YENİ VERİ KAYBI.** (D5)
`/e` *"şart 2–4 aranmaksızın güncellenir"* diyor. Kayıt varken yerel `C` düzenlemesi yapılır → itilir
→ echo döner (`Ö8` gereği op `changesUygula`'dan önce silinmiştir ⇒ echo projeksiyonu kazanır) ⇒
şart 1 sağlanır ⇒ `/e` ateşler ve `kazananDeger = C` yazılır. Ekran *"Benimki: B1 / Onlarınki: C"*
gösterir; **`C` kullanıcının kendi en yeni yazımıdır** ve *Benimkini tut* onu yok eder.
🔴 MAJOR-12'yi kapatırken **yeni bir kayıp** açıldı ve **mutantı yok**.

**B2-5 — `g2_migration_kapisi_test.dart` `schemaVersion == 4`'ü SABİT pinliyor ⇒ `T1` biter göstergesi
ulaşılamaz.** (D4/B-2, kaynağa karşı) `:47-51` → `expect(db.schemaVersion, 4)`. `T1` sürümü 5'e
çekince bu test **kesin FAIL**; spec bu testin güncelleneceğini **hiçbir yerde** söylemiyor ve `T2`
mevcut testleri *"regresyon yok"* diye ilan ediyor ⇒ builder **zorunlu** bir test düzenlemesini
regresyon sanar.

### MAJOR (seçilmiş — tamamı D5/D4 raporlarında)

1. **Şart 3 ve `kazananClientHex` için gereken iki veri kodda YOK:** `_GorevGuncellemesi` kanal başına
   **kazanan anahtar/clientHex taşımıyor**; `UzakDegisiklikUygulayici`'nın kurucusu cihazın kendi
   `clientId`'sini **almıyor** ⇒ `_projeksiyonYaz`'da şart 3 **hesaplanamaz**. `D-SS2-2`'nin
   *"üç-kanal eşlemesi `g` içinde hazır"* gerekçesi **eksik**.
2. **`G34/d`'nin `kazananAnahtar` operandı hiçbir yerde saklanmıyor** — v2 kazanan HLC sütunlarını
   **sildi** (`kazananWall/Counter/OpHex` yok) ⇒ ölçümün kaynağı belirsiz.
3. **`M187` v2 mimarisinde uygulanamaz:** tel→projeksiyon dönüşümü `_kanalUygula:196`'da biter;
   `_projeksiyonYaz`'a ulaşan iki operand da **bool**tur ⇒ `kanonikDize` ham teli hiç görmez.
4. **Kriter 4 ve `T7` aralığı `M171`–`M186`; `M187`/`M188` DIŞARIDA** (v1 MINOR-4'ün tekrarı).
5. **`M183` SS2 kodunu değil A11/R9 kodunu mutasyona uğratıyor** (`g10:153` zaten düşer) ⇒ spec'in
   **kendi** §6b ölçütüne göre hedefi yanlış etiketlenmiş.
6. **`rozetDikisi` imza değişikliğinin patlama yarıçapı ölçülmemiş:** doğrudan çağrılar
   `g11_rozet_turetme_kapisi_test.dart` (14+), `a11y_kapisi_test.dart:119`,
   `g5_karantina_kapisi_test.dart:227` — `T4` yalnız `G10`'a bakıyor, oysa `G10` bu fonksiyonu
   **hiç doğrudan çağırmıyor**.
7. **Zorunlu `entityId` iki mevcut test dosyasını derlenemez yapıyor:**
   `g16_metin_kaybi_kapisi_test.dart:155,168` ve `sunum_bilesenleri_test.dart:183`.
8. **`cakismaCoz` iç içe transaction üretir:** `ekle`/`duzenle`/`tamamlaGeriAl`/`sil` **dördü de**
   kendi `_db.transaction()`'ını açıyor (`gorev_deposu.dart:238, 266, 300, 324`) ve kod tabanında
   iç içe transaction örneği **yok**. Spec iki boynuzdan (iç içe kabul et / akışı yeniden yaz) birini
   **seçmiyor**.
9. **`G31/c` reçetesi mevcut altyapıyla uyumsuz + geri alınamaz SIRA TUZAĞI:** `g2` gerçek yolu
   `SchemaVerifier(GeneratedHelper()) + schemaAt(3) + v3.DatabaseAtV3` ve dosya başlığı
   **"`NativeDatabase.memory()` YASAK — PAZARLIKSIZ"**; spec *"bellek DB'si"* diyor ve
   `SchemaVerifier`/`GeneratedHelper`/`DatabaseAtV4`'ü **hiç anmıyor**. 🔴 `schemaAt(4)` yalnız
   **v4 dump'ı `schemaVersion` hâlâ 4 iken alınmışsa** çalışır; `T1` sırayı **belirtmiyor** — önce
   bump edilirse v4 dump'ı bir daha alınamaz ve `G31/c` **ölür**.
10. **`G33/c`'nin reçetesi satır-bazlı, kaynak çok satırlı** (`gorev_deposu.dart:178-186` —
    `count(` bir satırda, argümanlar sonrakinde) ⇒ doğru kodda bile KIRMIZI ya da araç yazarının
    keyfine kalmış (v1'in *"pinsiz sayı"* kusurunun kardeşi).
11. **`G34/a`'nın *"`gorev_satiri.dart` onu geçirir"* yarısı KÖR** — ölçüm yalnız *"parametresiz
    kurucular kalmamıştır"* diyor; **geçirmenin doğruluğu** için hiçbir ölçüm yok.
12. **`T0`'ın araç kapsamı `G34/a`'yı içermiyor** ama `M184` `ss2-kapisi.py`'nin kırmızısını bekliyor.
13. **`G34/f`'in *"aynı transaction"* yarısının mutantı YOK** ve §6b'de beyan da edilmemiş
    (v1 MAJOR-10 **kapanmadı**).

### MINOR
`M176`'nın sınıfı *"birim"* yazılmış, hedefi **statik** ayaktır · `G32/f`'in *"derlenmeyen mutant"*
gerekçesi yanlış (doğrusu *"erişilemez"*) · `D-SS2-11` anlık görüntüsü çok turlu boşaltmada bayatlar
ve **alan granülü** tanımsız (`hamAlanHlcCikar` gerekir, spec anmıyor) · kapı ayağı sayısı **22**
(3+8+3+8) · `G32/g`'nin *"dize olarak karşılaştırılır"* ifadesi yanlış (drift `DateTime` döndürür).

---

## 🟢 ÖLÇÜLEN İLERLEME (D5'in kendi *"SAĞLAM"* listesi — kıramadıkları)

- **`D-SS2-11` + kabul kriteri 8 ⑥ ÇALIŞIYOR:** anlık görüntü senaryoyu **gerçekten kurtarıyor** —
  itme turu koşar, `_tekSonucIsle` kuyruğu siler, ama *"o turda gönderilen oplar"* kümesi şart 2'yi
  sağlar ⇒ kayıt doğar. **v1'in BLOKER-5'i KAPANDI.**
- **`M173` kapandı** — şart 2 artık bağımsız sorgu; `enBuyuk(x,null)==x` cebiri yok.
- **`M174`, `M180`, `M181`, `M182`, `M178`, `M178b`, `M179`, `M185`, `M186`, `M188` SAĞLAM.**
- **`D-SS2-5`'in SQL'i sağlam:** `COUNT(DISTINCT x) FILTER (WHERE …)` sqlite 3.45'te geçerli
  (ölçüldü); fan-out `2→4` **gerçek**, `distinct` **doğru düzeltiyor**. Sorun yaklaşımda değil
  **ölçümünde** (`M176`).
- **Kriter 5 yeşil:** `spec-kapi-kapsama.py` v2 üzerinde **EXIT 0** (cihazda koşuldu).
- **D5'in hükmü:** *"v2 v1'in **mimari** blokerlerini (BLOKER-1/2/5/6/7) gerçekten kapatmış — bu
  ilerleme ölçülebilir."*

---

## HÜKÜM

🔴 **`GOREV-SS2` v2 KİLİTLENEMEZ.** Ama tur 1'den farkı **niteliksel**: kalan blokerların **hiçbiri
mimariyi değiştirmiyor** — beşi de **mutant kalitesi** (`M172`, `M176`, `M171b`) ya da **nokta
düzeltmesi** (`/e`'ye şart 3, `g2` test pini). K53/1 gereği **üçüncü kâğıt turu AÇILAMAZ**:
*"ikinci tur ancak birincisi **mimariyi değiştiren** bir bloker bulduysa"* — bu tur öyle bir bloker
**bulmadı**.

🔴 **K53/4 — R8 SERT DURAK:** oturum 53 = **0** satır ürün kodu, oturum 54 = **0** (ölçüldü).
*"İki oturum üst üste 0 ⇒ bir sonraki oturum **ürün koduyla başlar**; yeni belge/ADR/spec/araç turu
**AÇILMAZ**."* ⇒ **Oturum 55 spec düzeltmesiyle DEĞİL, ürün koduyla açılmak zorundadır.**

🔴 **ÜÇ TUR ÜST ÜSTE AYNI DERSİN ALINTILANIP UYGULANMAMASI (`M167` → v1 `M172/M173/M175` → v2
`M172`) bu projede bir SINIFTIR** ve mekanik kapısı yoktur: `spec-kapi-kapsama.py` *"mutant VAR mı"*
sorar, *"mutant ISIRIR mı"* **sormaz**. Kapanış yolu bir **araç**tır, bir tur daha değil.

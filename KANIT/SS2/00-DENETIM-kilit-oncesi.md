# SS2 — KİLİT ÖNCESİ BAĞIMSIZ DENETİM (K127) · HÜKÜM: **KİLİTLENEMEZ**

**Tarih:** 3 Ağu 2026 (cihazdan ölçüldü), oturum 54
**Denetlenen:** `GOREV_CLAUDE_CODE/GOREV-SS2-cakisma-cozumu.md` — 28.801 b · `90314998`
**Üreten el:** Cowork. **Denetleyen el:** üç **bağımsız** ajan (K26 — üreten ≠ denetleyen).
**Mekanik ön kapı:** `spec-kapi-kapsama.py` **EXIT 0** · `kapi-ad-teklik-kapisi.py` **YEŞİL** ·
`dosya-kimlik.py` **TEMİZ** (U+FFFD 0 · CRLF 0).
🔴 **Mekanik kapıların HEPSİ yeşildi ve spec yine de KİLİTLENEMEDİ** — kapsama ölçümü
*"mutant VAR mı"* diye sorar, *"mutant ISIRIR mı"* diye **sormaz**.

| denetçi | lens | bloker | major | minor |
|---|---|---|---|---|
| D1 | kod gerçeği (spec ↔ kaynak) | 3 | 7 | 6 |
| D2 | red-team: kör ayak + eşdeğer mutant | 6 | 11 | 4 |
| D3 | iç tutarlılık + doktrin + ürün davranışı | 4 | 13 | 5 |

🔴 **ÜÇÜ DE, BİRBİRİNDEN HABERSİZ, AYNI KÖK BLOKERİ BULDU.**

---

## BLOKER-1 (üç denetçide de) — ÇAKIŞMA KOŞULU SPEC'İN KENDİ AMACINI İMKÂNSIZ KILIYOR

Yazılan koşul: `kuyrukTabani != null && kazandiMi(gelen, eskiMeta) != kazandiMi(gelen, enBuyuk(eskiMeta, kuyrukTabani))`

**Cebir (`alan_anahtari.dart:56-66`):** `t = enBuyuk(eskiMeta, kuyrukTabani) >= eskiMeta` ve
`kazandiMi` kesin büyüklüktür ⇒ `kazandiMi(g,t)==true ⇒ kazandiMi(g,eskiMeta)==true`
⇒ **`(false,true)` çifti ÜRETİLEMEZ.** Koşul yalnız `(true,false)`'ta ateşler; o hâl **daima
`projeksiyonKazandi == false`** demektir.

**Ölü kalan parçalar:** `kaybedenYerelMi == true` hiç oluşamaz · rozet **kazanan** cihazda çıkar ·
§1 ve **kriter 8** senaryosu **0 kayıt** üretir · `G32/a`, `G34/d`, `G34/e`, `M172`,
`D-SS2-2` satır 1 ve `D-SS2-6`'nın *Benimkini tut* sütunu **ölü kod**.
🔴 **En ağırı: spec, `Ö4`'te tarif ettiği veri kaybını (uzak kazanır, yerel sessizce ezilir)
tam da o yönde ÇÖZMEZ.**
**D1'in sayısal kontrolü:** 49.284 üçlü tüketici koşuldu; koşulun tuttuğu **8.436** vakanın
**8.436'sında** `projeksiyonKazandi == false`, **0'ında** true.
🔴 K53/1'in *"mimariyi değiştiren bloker"* eşiğini **AŞAR** ⇒ ikinci kâğıt turu **meşrudur**.

## BLOKER-2 (D1+D2) — `D-SS2-3/c` TERSİ ÇALIŞIYOR: KENDİ YAZIMIMIZ SAHTE ÇAKIŞMA ÜRETİR

Echo'da `kuyrukTabani` ile `gelen` **aynı op**tur. `eskiMeta < gelen` iken
`kazandiMi(gelen,eskiMeta)=true`, `kazandiMi(gelen,enBuyuk(eskiMeta,gelen))=false` ⇒ **karar
DEĞİŞİR** ⇒ koşul ateşler. `/c`'nin gerekçesi (*"echo kaybeder ⇒ karar değişmez"*) yanlıştı:
kaybetmesinin **sebebi kuyruğun kendisidir**.
**Erişilebilir yol:** `op1 "A"` push+ack+silinir; `op2 "B"` 4xx ile `bekliyor`e döner
(`senkron_dongusu.dart:374-389`); çekme turu `op1`'in echo'sunu getirir ⇒ değerler farklı ⇒
`/d` de kurtarmaz ⇒ **kullanıcı kendi iki düzenlemesi arasında "çakışma" görür.**

## BLOKER-3 (üç denetçide de) — ÜÇ MUTANT EŞDEĞER ⇒ KABUL KRİTERİ 4 SAĞLANAMAZ

- **M172:** `_kanalUygula` `Gorevler`'e **hiç dokunmaz**; projeksiyon yazımı `_projeksiyonYaz`'dadır
  (`:207-241`) ve tüm döngüden sonra koşar ⇒ o metotta satır taşımak hiçbir şeyi değiştirmez.
- **M173:** `enBuyuk(eskiMeta, null) == eskiMeta` (`:64`) ⇒ `kuyrukTabani != null` şartı **cebirsel
  olarak fazladan**; silince `X != X` yine `false` ⇒ `G32/c` yeşil kalır.
- **M175:** mutasyon yalnız `metaYaz` koşulunu değiştirir, **dönüş ifadesi aynı kalır** ⇒
  `projeksiyonKazandi` de `cakismaVar` da değişmez. Ayrıca *"mevcut D6/echo testi"* spec'te
  **dosya/test adıyla verilmemiş** ⇒ *"iki kapıyı birden ısırmalı"* kriteri **ölçülemez**.

🔴 `A13`/`M167` dersinin **üç kopyası** — ve spec o dersi **alıntılayarak** yazıldı.

## BLOKER-4 (D1+D2) — `Ö5` YANLIŞ OKUNDU: KAYBEDEN DEĞER KARAR ANINDA BELLEKTE DEĞİL

`uzak_degisiklik_uygulayici.dart:209` — `final mevcut = await (_db.select(_db.gorevler)…)`
**`_projeksiyonYaz` içindedir**. `D-SS2-2` kanal başına **yeni bir `SELECT gorevler`** gerektirir;
spec bunu hiç anmıyor ⇒ `Ö5`'in *"gereken tek şey salt-ekleme bir tablo"* sonucu **eksik**.

## BLOKER-5 (D2) — KABUL KRİTERİ 8 ÇAKIŞMA PENCERESİNE HİÇ GİRMEZ

`senkron_dongusu.dart:256-296` tek transaction: `_tekSonucIsle` (`:307-309`) `Applied`/`Duplicate`
satırını **`changesUygula`'dan ÖNCE** siler ⇒ karşı tarafın değişikliği uygulanırken
`kuyrukEnBuyuk` **null** döner ⇒ kayıt yok. Canlı pencere yalnız *"bekleyen yazım varken
**çekme-only** tur"*tur; kriter 8 o hâle **hiç girmez**. `G32` testleri kuyruğu **elle** kurduğu
için bu boşluğu **hiçbir birim testi göremez**.

## BLOKER-6 (D3) — ÇÖZÜM EYLEMİ PROJEKSİYONU GÜNCELLEMİYOR

`D-SS2-6` yalnız kuyruğa yazıyor (karşılaştır: `gorev_deposu.dart:266-275` — `duzenle`
projeksiyonu **ve** kuyruğu birlikte yazar). Kullanıcı butona basar, listede hiçbir şey değişmez,
**rozet anında kaybolur** (kayıt silindiği için) ⇒ *"seçim yaptım, hiçbir şey olmadı."*
Çevrimdışıyken echo hiç dönmez.

## BLOKER-7 (D2+D3) — `araclar/ss2-kapisi.py`'Yİ YAZAN ADIM YOK

`G31/a`, `G31/b`, `G33/c` ve **kriter 6** bu araca bağlı; `T1`–`T8`'in hiçbiri onu üretmiyor ⇒
**K44-a (*önce araç, sonra belge*)** ihlali — spec'in kendi alıntıladığı kural. K26 de çatallanıyor.
🔴 Araç **ürün kodu sayılmaz** (K53/4) ⇒ oturumun bu işe gitmesi `R8`'in üçüncü sıfırını tetikler.

---

## MAJOR (birleştirilmiş, tekrarsız)

1. **`kaybedenDeger` dize kodlaması tanımsız/asimetrik:** `groups:completion`'da gelen bir **map**
   (`{status, completedAt}`), projeksiyon eşdeğeri **bool**; `fields:isDeleted` aynı ⇒ `/d` elemesi
   iki farklı temsil alanını karşılaştırır (`'done'` vs `'true'`) ⇒ **hiç tetiklenmez**
   (BLOKER-2'yi canlı tutan mekanizma) ve ekran kullanıcıya `"true"`/`"done"` gösterir.
2. **`fields:isDeleted` UI'da ERİŞİLEMEZ:** `gorev_deposu.dart:197` `..where(silindi.equals(false))`
   ⇒ silinmiş görev listeden düşer ⇒ rozete dokunulamaz ⇒ kayıt kalıcı yetim. `GorevDeposu`'nda
   **undelete yazma yolu YOK** ⇒ *Onlarınkini al* `D-SS2-6`'nın kilidiyle çelişen yeni yol ister.
3. **`D-SS2-5`'in üçüncü kanalı `R10/D6`'nın TEK-sorgu kilidinde fan-out üretir:**
   `gorev_deposu.dart:168-170` ikinci stream'i **yasaklıyor**; ikinci `leftOuterJoin` entity başına
   3 satır üretir, `count(opId)` sayımlarını **şişirir** ⇒ mevcut `G10` testleri kırılır.
   `G33/a` saf fonksiyonu test ettiği için **hiç göremez**.
4. **Kayıt yazımı `:182`'deki erken `return`'den ÖNCE olmak zorunda ⇒ üç-kanal filtresi tanımsız**
   ⇒ `fields:priority` gibi eşlemesiz her alan null değerli kayıt üretir ⇒ `S4` yalanlanır.
5. **`M176` düştüğünde sebebi yeni ayak değil MEVCUT D4 testleri olur;** ayrıca `_projeksiyonYaz`
   UPDATE dalı yalnız `herhangiBirKanalKazandi` iken koşar (`:207`) ⇒ erişilebilir yönde **hiç
   koşmaz** ⇒ `G33/b` yeşil kalır.
6. **`G33/c` ölçülemez ve iddiası bugün yanlış:** `senkronDurumu` kaynakta **3 kez** geçer
   (`:184` yorum · `:228` INSERT · `:239` yorum); pin değeri spec'te **yok** ⇒ builder mutasyon
   sonrası koda bakarak seçebilir. Kriter 2 *"sayı spec'e yazılmaz"* derken bu ayak pin dayatıyor.
7. **`G32`'nin yedi ayağı yedi bağımsız kanıt değil:** `c ≡ g` (aynı dal) · `d` cebirsel olarak
   zorunlu (`S9` itiraf ediyor) · `e` yalnız `/d` sayesinde yeşil ⇒ `e ≡ f`.
8. **21 kapı ayağının 12'sinin mutantı yok;** araç mutantı **kural** granülünde okuduğu için
   kriter 4/5 yeşilken ayakların yarısı ölçülmemiş kalır. En zor dal (`G32/b`) mutantsız.
9. **`M171b` bir SIFIR-MUTANTTIR** (teslim edilen kodun aynısı) ⇒ YP kontrolü değil, kriter 3'ün
   tekrarı. Gerçek YP kontrolü bitişik-ama-meşru varyant olmalıydı.
10. **`G34/f`'in *aynı transaction* yarısı ölçülmüyor, *çağrı sırası testi*nin dikişi yok:**
    atıf verilen desen `SenkronDongusu.uygulayici`'ya dayanır; çözüm eyleminin enjekte edilebilir
    dikişi **yok**. `M177` yalnız sırayı çeviriyor — transaction'ı kaldıran mutant yok.
11. **Çözüm eyleminin SAHİBİ tanımsız** (`GorevDeposu` 5. metot mu, yeni `CakismaDeposu` mu,
    widget mi) ⇒ DI, transaction sınırı ve gözlemci dikişi builder'a kalıyor.
12. **`kazananDeger` kayıt anında DONAR ve BAYATLAR:** sonraki çakışmasız yazım projeksiyonu
    değiştirir, kaydı değiştirmez ⇒ kullanıcı listede `C`, ekranda `B` görür; *Benimkini tut*
    **iki kuşak eski** değeri diriltir.
13. **Çok alanlı çakışmada** ekran düzeni/buton kapsamı/döngü tanımsız. `kCakismaGovdesiMaxSatir=6`
    **tam genişlikte, ortalanmış, TEK `Text`** üzerinde ölçülmüştü; yan yana düzen **başka bir
    ölçümdür** ⇒ sabiti *"KORUNUR"* ilan etmek bayat sayıyı kilit sanmaktır.
14. **Rozet eski kanaldan geldiğinde ekranın ne göstereceği tanımsız** — ve `D-SS2-7` gereği bu
    **baskın** durumdur ⇒ kullanıcının göreceği normal hâl **0 kayıtlı** bir ekrandır.
15. **K80 ihlali:** kriter 8'de ortam adımı ③ (emülatör + `adb devices`) **yok**; iki istemci
    örneğinin nasıl kaldırılacağı ve `clientId` ayrımı yazılı değil. Kaybedeni **HLC sırası**
    belirler ⇒ hangi ekranda rozet aranacağı koşum anında **belirsiz**.
16. **§6'nın maliyet beyanı kriter 8 ile çelişiyor** (*"koşan mutant YOK, tavan kullanılmaz"*
    denirken en pahalı kabul maddesi o sınıfta).
17. **`bool → record` çağrı yerleri ele alınmamış:** `:96` (sonuç atılır) ve `:175-182`
    (**derlenmez**) ⇒ `T2`'nin biter göstergesi `T3` yapılmadan **ölçülemez**.
18. **`olusturuldu` için saat dikişi yok** (karşılaştır `gorev_deposu.dart:143`) ⇒ determinizm
    kırılır; `S2` gereği geçmiş tutulmadığından sütun **ölü**.
19. **Seçim yapmadan çıkış / ekran açıkken üçüncü cihaz** tanımsız; çözümde entity'nin **TÜM**
    kayıtları silindiği için kullanıcının **hiç görmediği** bir çakışma sessizce yok olur.
20. **`G34/d`'nin `compareTo > 0` operandı adsız:** kaybedenin anahtarıyla karşılaştırılırsa ayak
    yeşil olur ama yazım karşı tarafta **yine kaybeder** ⇒ ürün kırık, kapı sessiz.
    `kaybedenYerelMi == false` sütununun **iki hücresinin de** ayağı yok.

## MINOR

1. `python araclar\verify.ps1` **koşamaz** (`.ps1` PowerShell betiğidir) — K81 dersinin aynısı.
2. `D-SS2-5`'in *"`senkronDurumu`'na ASLA yazmaz"* kuralı **yanlış**: INSERT dalı (`:228`)
   `'senkronize'` yazıyor. Doğrusu *"UPDATE dalı yazmaz"*; harfiyen uygulayan builder `:228`'i
   siler ve R9/T1 (K72) davranışını bozar.
3. §6 ve §8'de **~11 kapı atfı `SS2/` öneksiz** — spec §0'da ilan ettiği K108 kuralını çiğniyor.
4. **Mutant kümesi üç yerde farklı:** §4/T7 *"M171–M178"* · §6 tablosu 10 satır · kriter 4
   *"M171–M178b"* ⇒ T7'yi harfiyen uygulayan builder iki YP kontrolünü koşmaz.
5. **`CakismaRozeti` de parametresiz/`const`tır** (`:15-16`, `:64`); `entityId` taşıması gerektiği
   yazılmamış ⇒ rozet tarafı kapısız.
6. **`G31/c` tek `Veritabani` sınıfıyla koşulamaz** (`schemaVersion` sabit getter); `drift_dev
   schema dump/generate` yardımcıları gerekir, spec bağlamıyor.
7. **`G34/b`'nin `find.text` ölçümü görsel kırpmayı göremez** (`Text.data`'yı eşler).
8. **§8 sınır numaraları sırasız** (`S7`,`S9`,`S8`) ve §8'deki *"§4"* atfı **sarkan** — kastedilen
   `DURUM.md` §5'teki *"Ölç ya da [DOĞRULANMADI] yaz"*.

---

## DENETÇİLERİN KENDİ BEYAN ETTİĞİ SINIRLAR (denetim de denetlenir)

- Üçü de **`src/client/test/`**, **`araclar/*`** olmadan çalıştı ⇒ mevcut testlerdeki çağrı yeri
  sayıları ve araç-içi davranış iddiaları **kaynak semantiğinden türetildi, koşularak ölçülmedi**.
- D2: **`M171` eşdeğer DEĞİL** — `schemaVersion` düz getter, derleme kırılmaz; kırmızıyı gerçekten
  yalnız `G31/a` verir.
- D2: **`D-SS2-3/b` cebirsel olarak doğrudur**; `S9`'un itirafı yerindedir.
- D1: `Ö1`–`Ö4`, `Ö6`–`Ö11` **kaynakta birebir doğrulandı** (satır numaraları dâhil);
  `G31/b`'nin YP gerekçesi de doğru (`veritabani.dart:118`'de meşru `alterTable` var).

---

## HÜKÜM

🔴 **`GOREV-SS2` KİLİTLENEMEZ.** BLOKER-1 **mimariyi değiştirir**: `D-SS2-3`'ün formülü yeniden
kurulmalı; `D-SS2-2`, `D-SS2-6`, `G32`, `G34` ve dört mutant onunla birlikte yeniden yazılır
⇒ **K53/1 gereği ikinci kâğıt turu MEŞRUDUR.**

🔴 **K127'NİN İKİNCİ SINAVI VE İKİNCİ GALİBİYETİ.** Spec `A13`/`M167` dersini **alıntılayarak**
yazıldı ve yine üç eşdeğer mutant üretti; mekanik kapıların **hepsi yeşildi**.
**İki ders:** ① *Kapsama ölçümü ısırma ölçümü değildir* — araç *"mutant VAR mı"* sorar,
*"mutant ISIRIR mı"* sormaz. ② *Bir dersi alıntılamak, o dersten korunmak değildir.*

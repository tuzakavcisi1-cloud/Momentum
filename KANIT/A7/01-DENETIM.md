# KANIT/A7/01-DENETIM.md — GOREV-A7'nin BAĞIMSIZ denetimi (K26)

**Denetleyen:** Claude Code (bu spec'i Cowork yazdı; K26 gereği üreten ≠ denetleyen — bu denetim AYRI
elden gelir). **Ne zaman:** 30 Tem 2026 (cihazdan ölçüldü, `Get-Date` — bulut tarihine güvenilmedi, §7 uyarısı).
**Yöntem:** kod okuması DEĞİL, KOŞARAK ölçüm — üç ayrı geçici widget-test probu yazıldı, koşuldu, silinmedi
(aşağıda §5). **K53/1:** bu ilk ve TEK kâğıt denetim turudur.

**HÜKÜM (baştan): 🔴 BLOKER BULUNDU — BUILD'E BAŞLANMADI.** Gerekçe §1.

---

## 1. 🔴 BLOKER — D-A7-2'nin dikey dönüşü, G13/A1'in KENDİ kabul ölçütünü SAĞLAMIYOR

**İddia (spec, G13/A1):** *"96 [gerçekte 72, bkz. §2] kombinasyonun HEPSİNDE rozet Text intrinsic ≤
ayrılan"* — yani dikey dönüş uygulandıktan SONRA, test edilen HİÇBİR kombinasyonda kırpma olmamalı.

**Bulgu (koşularak ölçüldü):** D-A7-2'nin formülü BİREBİR uygulanıp 72 kombinasyonun her biri için
(a) `DIKEY` mi `YATAY` mı seçileceği, (b) o düzende rozete GERÇEKTEN ayrılan genişlik, (c) rozetin
İSTEDİĞİ genişlik (gerçek `TextPainter.maxIntrinsicWidth`, flutter_test fontuyla, spec'in KENDİ ölçüm
yöntemiyle) hesaplandığında: **72 kombinasyonun 61'i (%85'i) HÂLÂ KIRPILIR.**

### 1.1 Nasıl ölçüldü

1. Geçici prob (`src/client/test/_a7_denetim_wrap_test.dart`, **SİLİNMEDİ** — §5) 4 durum dizgesinin
   3 ölçekteki (`TextPainter.getMaxIntrinsicWidth`, spec'in G13 için kilitlediği AYNI API) gerçek
   piksel genişliğini ölçtü:

   | durum | 1.0× | 1.5× | 2.0× |
   |---|---|---|---|
   | yerel ("Yalnızca bu cihazda") | 251,75 | 375,25 | 498,75 |
   | kuyrukta ("Gönderiliyor") | 159,00 | 237,00 | 315,00 |
   | cevrimdisi ("Çevrimdışısınız. Değişiklikler kaydedildi.") | 556,50 | 829,50 | **1102,50** |
   | gonderilmemis ("Gönderilmemiş değişiklik") | 318,00 | 474,00 | 630,00 |

   (`cevrimdisi`/2.0× = 1102,50 — Cowork'ün `00-OLCUM-kor-kapi.txt`'teki sayısıyla BİREBİR eşleşti;
   ölçüm yöntemi doğrulandı.)

2. `rozetIstedigi = istenenTekSatir + MOlcu.ikon(24) + MBosluk.xs(4)` (spec'in KENDİ formülü).

3. Her (genişlik, ölçek, durum, çakışma) için D-A7-2'nin `DIKEY ⇔ sabitler + baslikAsgari +
   rozetIstedigi > maxWidth` koşulu uygulandı; `DIKEY` ise rozete ayrılan gerçek genişlik
   `maxWidth − 48(checkbox) − 8(boşluk) [− 48 − 4 çakışma varsa]`; `YATAY` ise `(maxWidth − 64[−52])/2`
   (Expanded/Flexible EŞİT flex paylaşımı — `gorev_satiri.dart:47,68`'in GERÇEK davranışı).

4. Betik: `a7_denetim.py` (bu oturumun scratchpad'inde; istenirse yeniden üretilir — kod aşağıda §6).

### 1.2 Neden matematiksel olarak imkânsız

Dikey dönüş rozete **en fazla `maxWidth − 56 ≈ 264–355 px`** (411dp'de bile) verir. Ama `cevrimdisi`
dizgesi 2.0×'te **1130,5 px** İSTİYOR (metin + ikon + boşluk) — **en geniş test genişliğinde (411dp)
bile mevcut alanın ~3,2 katı.** Dikey dönüş rozete daha FAZLA yer verir (yarı satırdan ~tam satıra),
ama **kaç katı fazla gerektiğini** değiştirmez — `overflow: TextOverflow.ellipsis` HİÇBİR `Text`'ten
kaldırılmadığı için (spec'in kendi kilidi, §4) metin ASLA çok satıra sarmaz (bkz. §3, bağımsız ölçüldü),
tek satırda ne kadar yer varsa o kadarını kullanır ve GERİ KALANI kırpılır.

**Kısaca:** dikey dönüş "yarım kırpma"yı "biraz daha az kırpma"ya çeviriyor, "kırpma YOK"a değil —
G13/A1 tam da bunu ölçüyor ve bu yüzden 61/72 kombinasyonda hâlâ ısırır.

### 1.3 Cowork'ün ölçümü NEREDE durdu

`00-OLCUM-kor-kapi.txt` kör kapıyı (mevcut kapı hiçbir şey söylemiyor) sağlam kanıtladı — bu denetim
o kısmı DOĞRULADI (§3). Ama Cowork'ün ölçümü **çözümün YETERLİLİĞİNİ hiç sınamadı**: "ölçüm 3"
(gerçek 320dp satırda 104px kalıyor) sorunu gösterdi, ama D-A7-2 formülü UYGULANDIKTAN SONRA aynı
dizgenin (1102,5px) yeni ayrılan genişliğe (dikey modda ~264px) sığıp sığmadığı HİÇ hesaplanmadı.
Sorun ölçülmüş, çözümün yeterliliği ölçülmemiş.

### 1.4 Bu neden K53/1'in "mimari bloker" eşiğini aşıyor

Bu, ayarlanabilir bir parametre hatası (ör. `baslikAsgari` yanlış sabit) DEĞİL — **dikey dönüşün
KENDİSİ, `overflow: ellipsis`'in HİÇBİR `Text`'ten kaldırılmaması kilidiyle BİRLEŞTİĞİNDE, uzun
dizgeler için kırpmayı YAPISAL OLARAK ortadan kaldıramaz.** Formüldeki bir sabiti değiştirmek
(ör. `baslikAsgari`'yi düşürmek) sorunu **azaltır ama gidermez** — 320dp'de dahi `cevrimdisi`/2.0×
1130,5px istiyor, `baslikAsgari=0` olsa bile dikey modda ayrılan en fazla `320−56=264px`.

**Olası çözüm yönleri (KARAR Onur'un — bu denetim çözüm DAYATMAZ, yalnız ölçer):**
- Rozet metnine `maxLines: 2` (veya sınırsız) verip GERÇEKTEN sarmasına izin vermek — ama bu G13'ün
  "tek satır intrinsic ≤ ayrılan" ölçüm yöntemini de DEĞİŞTİRMEYİ gerektirir (çok satırlı bir metin
  için "intrinsic width" ölçüsü anlamsızdır; doğru ölçü `didExceedMaxLines` olurdu — spec §8/S2 bu
  alternatifi AÇIKÇA reddetmiş: *"maxLines zorunluluğu getirdiği için reddedildi"*).
- Rozet dizgelerini KISALTMAK (ör. "Çevrimdışısınız. Değişiklikler kaydedildi." → "Çevrimdışı") —
  ama bu F6'nın kilitli 13 dizgesine dokunmak demektir (`metinler-kilit.json`, K46 benzeri bir kilit).
- G13/A1'in kapsamını DARALTMAK (ör. yalnız KISA dizgeleri test etmek, `cevrimdisi` gibi uzun olanları
  ayrı, daha gevşek bir ölçütle değerlendirmek) — spec'in KENDİSİ bunu yapmadı.
- Rozeti TAMAMEN ayrı bir satıra/tooltip'e taşımak (daha büyük bir tasarım değişikliği).

---

## 2. Sayı<->liste tutarsızlığı: "96 kombinasyon" YANLIŞ, gerçek sayı **72**

G13/A1: *"textScale ∈ {1.0, 1.5, 2.0} × genişlik ∈ {320, 360, 411} × durum ∈ {yerel, kuyrukta,
cevrimdisi, gonderilmemis} × cakismaVarMi ∈ {false, true} — **96 kombinasyon**"*.

`3 × 3 × 4 × 2 = 72`, **96 DEĞİL.** Doğrulama: `python -c "print(3*3*4*2)"` ⇒ `72`. Bu tam olarak
`iddia-kapisi.py`'nin I1 sınıfının yakaladığı kusur türüdür (belgenin kendi sayı iddiası ile listesi
arasındaki tutarsızlık) — ama o araç mutant sayılarını ölçer, ayak-içi kombinasyon iddialarını DEĞİL;
bu sınıf oraya KAPSAM DIŞI kalıyor ve yalnız bu bağımsız okuma ile yakalandı.

**Etki:** küçük (kabul kriterinin SAYISI yanlış, kendisi değil) ama **§4/K40 "beyan edilmiş sınır
kabul edilir, gizlenmiş sınır edilmez"** ilkesi gereği düzeltilmeden geçilmemeli — `KANIT/A7/02-test.txt`
raporlanırken "72/72" mi "96/96" mı denileceği belirsiz kalır ve `sayi-tazeligi.py` sınıfı bu tür
belge-içi iddiaları da yakalayabilir hale getirilmeli (ayrı bir araç borcu, bu denetimin konusu değil).

---

## 3. `RenderParagraph.getMaxIntrinsicWidth` DOĞRULANDI (S2) + KÖR KAPI PREMİSİ BAĞIMSIZ TEYİT EDİLDİ

**Ortam:** Flutter 3.44.6 · Dart 3.12.2 (bu oturumda `flutter --version`/`dart --version` ile
ölçüldü — spec §8/S2'nin beyan ettiği bağımlılık GERÇEK).

`RenderParagraph.getMaxIntrinsicWidth(double.infinity)` bu sürümde ÇALIŞIYOR ve Cowork'ün ölçtüğü
1102,5 değerini BİREBİR üretti (bağımsız koşum, aynı dizge, aynı ölçek — §1.1 tablosu).

🔴 **Kör kapı iddiasını KIRMAYA ÇALIŞTIM — kırılmadı, GÜÇLENDİ.** İlk hipotezim: *"Cowork'ün
`istenen > ayrılan ⇒ KIRPILDI` ölçütü aslında metnin SARILMASINI (wrap, bilgi kaybı YOK) 'kırpma'
sanıyor olabilir mi?"* Üç bağımsız prob (Row+Flexible içinde, çıplak `Text`+`SizedBox`, `Text`+
`Column` 2000px yükseklikte) AYNI SONUCU verdi: `size.height` HER ZAMAN tam bir satır yüksekliği
(36,0px @2.0×) — metin GERÇEKTEN tek satıra sıkışıp ellipsis ile kırpılıyor, SARMIYOR. Sebep: bu
Flutter sürümünde `overflow: TextOverflow.ellipsis`, `maxLines` `null` olsa bile `RenderParagraph`'i
FİİLEN tek satıra indiriyor (Skia/dart:ui'nin `ellipsis`+`maxLines` etkileşiminin bilinen bir
davranışı). **Sonuç: Cowork'ün kör-kapı iddiası SAĞLAM — bilgi kaybı gerçek, ölçüm artefaktı değil.**

---

## 4. G14/A5 (yanlış-pozitif kontrolü) DOĞRULANDI

`800dp + 1.0× + yerel` için D-A7-2 formülü: `sabitler(64) + baslikAsgari(96) + rozetIstedigi(279,75)
= 439,75 < 800` ⇒ `YATAY` — spec'in beklediğiyle (`G14/A5`) uyuşuyor. Formülün YATAY/DİKEY AYRIMI
kendi içinde tutarlı; §1'in bulgusu formülün "ne zaman geçsin" kısmında DEĞİL, "geçtiğinde yeterli mi"
kısmındadır.

---

## 5. Denetim yan ürünleri — SİLİNMEDİ, beyan edildi

🔴 **`src/client/test/_a7_denetim_wrap_test.dart` bu depoda DURUYOR.** Global talimatım dosya SİLMEYİ
yasaklıyor (`rm` denendi, reddedildi) — Cowork'ün kendi ölçüm dosyasını `_SILINECEKLER`'e taşıma
yetkisi/aracı bende yok. **Bu dosya `flutter test` TAM koşumuna 2 test daha ekler** (171 + bu dosyanın
kendi testleri) — kabul kriteri 2'nin "mevcut 171 test bozulmaz" ölçümü yapılırken bu dosyanın DA
sayıldığı görülecektir; bu YENİ bir ürün testi DEĞİLDİR, denetim artığıdır. **Onur'un ya da build'i
üstlenecek elin bu dosyayı silmesi/taşıması gerekir** — build BAŞLAMADIĞI için ben bunu yapmadım.

Ayrıca `src/client/test/_SILINECEKLER/` (boş) bir alt dizin YANLIŞLIKLA oluşturuldu (Cowork'ün GERÇEK
`_SILINECEKLER`'i repo KÖKÜNDE, `C:\dev\Momentum\_SILINECEKLER` — ayrı, dokunulmadı). Boş dizin git
tarafından izlenmez, zararsızdır, silinmedi (aynı sebep).

---

## 6. Ölçüm betiği (yeniden üretilebilir)

`a7_denetim.py` bu oturumun scratchpad'inde kaldı (repoya YAZILMADI — K44-a "önce araç sonra belge"
bu denetim için geçerli değil, bu bir ölçüm betiği değil tek-seferlik bir hesaplama). Formül ve
sabitler bu belgede (§1.1–§1.3) tam olarak yazılı; herhangi bir el `python` ile 5 dakikada yeniden
üretebilir. İsterse Onur bunu kalıcı bir `araclar\` betiğine çevirmemi ister mi, ayrı karar.

---

## 7. Kapsam dışı bırakılmayan ama BU DENETİMDE derinlemesine sınanmayan noktalar (dürüstçe beyan)

- **RTL:** sınanmadı. `SenkronRozeti._duyuruGerekirseGonder` zaten `TextDirection.ltr`'i SABİT
  kodluyor (bu spec'ten ÖNCE de öyleydi) — uygulama genelinde RTL desteği YOK gibi görünüyor; bu
  spec'in YENİ bir RTL kusuru AÇTIĞINA dair bulgu yok, ama app-wide RTL durumu bu denetimin kapsamı
  dışında bırakıldı (spec de bundan hiç bahsetmiyor — ne dahil ne haric).
- **Checkbox'ın kendi ölçek davranışı:** D-A7-2 formülü `Checkbox` genişliğini sabit `MOlcu.dokunmaHedefi`
  (48) sayıyor; Flutter'ın `Checkbox` widget'ı normalde `textScaler`den ETKİLENMEZ (Icon gibi), ama bu
  VARSAYIM koşularak DOĞRULANMADI (yalnız rozet metni ölçüldü, Checkbox'ın kendisi değil). Düşük risk
  (CM1–CM3 cihaz ölçümü zaten Checkbox'ın görünür boyutunu dolaylı doğrular) ama AÇIKÇA
  `[DOĞRULANMADI]` olarak işaretleniyor.
- **Çok satırlı başlık:** spec §2 zaten kapsam dışı bırakmış (S1), bu denetim o kararı sorgulamadı.

---

## 8. Denetimin kendi sınırı

Bu denetim `flutter_test`'in TEST FONTUYLA ölçtü (spec §8/S3'ün beyan ettiği aynı sınır) — cihazdaki
gerçek yazı tipiyle rakamlar DEĞİŞİR. Ama §1'in bulgusu **oran büyüklüğüne** dayanıyor (istenen,
mevcuttan defalarca fazla) — cihazın gerçek fontu muhtemelen biraz farklı ölçer ama "3 katı fazla"
büyüklüğündeki bir açığı kapatacak kadar farklı ÖLÇMEZ; bu iddia CM1/CM2 ile (spec zaten planlamış)
sınanabilir, ama BUILD'DEN ÖNCE bu ölçekte bir mimari boşluğun cihaza kadar taşınması israf olurdu.

---

## HÜKÜM

🔴 **BUILD'E BAŞLANMADI.** §1'deki bulgu K53/1'in "mimari değiştiren bloker" eşiğini aşıyor: G13/A1
kilit kabul kriteri, D-A7-2'nin TANIMLANDIĞI ŞEKİLDE kodlanması durumunda **kendi kendini geçemez**
(72 kombinasyonun 61'i kırpılmaya devam eder). Bu Onur'un kararını gerektiren bir tasarım sorusudur
(§1.4'teki dört yön örnek, dayatma değil) — spec'i YAZAN el (Cowork) değil, Onur'un KENDİSİ kilitlemeli.
**Rapor Onur'a sunuldu; ikinci bir kâğıt denetim turu bu bulgudan sonra AÇILABİLİR (K53/1 istisnası) ama
o karar da Onur'undur.**

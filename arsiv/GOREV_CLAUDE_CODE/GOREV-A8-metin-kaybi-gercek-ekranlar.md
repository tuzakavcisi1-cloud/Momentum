# GOREV-A8 (v2) — `lib/sunum`'da SESSİZ METİN KAYBI: beş **gerçek ekran**

> **Kilit:** Onur, oturum 42 · **Yazan:** Cowork · **Build:** Claude Code
> **v1 REDDEDİLDİ** — iki bağımsız denetçi **beş bloker** ölçtü; v1 `_SILINECEKLER\GOREV-A8-v1-REDDEDILDI-5-bloker.md`.
> 🔴 Bu **yeni kâğıt turu değil**: oturum 41–42'de repoya **0 satır ürün kodu** girdi, `CLAUDE.md` kuralı 4
> gereği sıra ürün kodundadır; spec ürün kodunun tek taşıyıcısıdır. İkinci tur K53/1'e uygundur çünkü
> birinci tur **MİMARİYİ DEĞİŞTİREN** bloker buldu (aşağıda §0).

---

## 0. v1'İN ÖLDÜĞÜ YER (ölçülmüş — bu bölüm silinmez, sonraki eli korur)

| # | v1'in yaptığı | ölçüm | sonuç |
|---|---|---|---|
| B1 | gövdeden `overflow: ellipsis` **kaldırıyordu** | `a11y_statik_tasma_test.dart:57` `lib/sunum` altındaki HER `Text(` için `ellipsis` **ZORUNLU** kılar (*"maxLines bunun YERİNE GEÇMEZ"*, satır 9-14). Denetçi o algoritmayı v1'in önerdiği koda koşturdu ⇒ `KORUNMASIZ: [(5, 'child: Text(')]` | v1 **yeşil bir kapıyı kırıyordu** ⇒ tasarım değişti: **`ellipsis` KALIR, `maxLines` EKLENİR** |
| B2 | manşet ayağı `didExceedMaxLines` | `sky_engine/lib/ui/text.dart:3047-3050`: yalnız `maxLines` verilmişse **ya da** (`maxLines` null **ve** `ellipsis` null değil) true olur | `overflow` kaldırılınca ayak **ölü doğuyordu**; `maxLines` eklenince **canlı** |
| B3 | *"tek satıra iner mi? [DOĞRULANMADI]"* | `KANIT/A7/02-COZUM-OLCUM.txt` **varyant A**: `maxLines:null + ellipsis` ⇒ `didExceedMaxLines = TRUE`, **1,0 satır** | Repo bunu **zaten ölçmüştü**. `BORCLAR.md` iddiası **DOĞRU**; mekanizma **genişlik** kaynaklı, v1'in *"`Center` gevşek yükseklik"* gerekçesi **yanlıştı** |
| B4 | kapsam = yer tutucu sayfa (2 yer) | `lib/` taraması: aynı sınıf **7 yerde**; 5'i **gerçek ekranda**, 2'si K42-d adım 3'te **silinecek** yer tutucuda | Bütçe atılacak işe gidiyordu ⇒ kapsam **beş gerçek ekrana** çevrildi |
| B5 | kriter 8 `EXIT 0` aldı | `spec-kapi-kapsama.py` kuralları yalnız `## 5.` **tablo** hücrelerinden okur; v1 ayakları madde imi yazmıştı ⇒ araç onları **görmedi** | **sahte yeşildi**; sınır §8/`S6`'da **beyan edildi** |

---

## 1. AMAÇ VE ÖLÇÜLMÜŞ GEREKÇE

`lib/sunum` altında **beş** `Text` `overflow: TextOverflow.ellipsis` taşır ama **`maxLines` taşımaz**.
Ölçülmüş mekanizma (B3): bu kombinasyon metni **fiilen tek satıra indirir** ve fazlasını **sessizce** atar —
istisna yok, log yok, kapı yok. Kayıp **görseldir** (ekran okuyucu tam metni alır), ama **gerçek ekranlardadır**:

| kod | dosya:satır | metin | bağlam |
|---|---|---|---|
| `Y1` | `sunum/gorev_satiri.dart:135` | `gorev.baslik` — **kullanıcı verisi, sınırsız uzunluk** | liste satırı (`Row`) |
| `Y2` | `sunum/bos_durum.dart:15` | `Metinler.bosDurum` | tam ekran, `MTipo.baslikL` (**en büyük tipografi**) |
| `Y3` | `sunum/hata_durumu.dart:47` | `Metinler.birSeylerTersGitti` | tam ekran `Column` |
| `Y4` | `sunum/hata_durumu.dart:56` | `Metinler.yenidenDene` | **`TextButton` etiketi** — okunamazsa kullanıcı eylemi kaybeder |
| `Y5` | `sunum/yukleme_durumu.dart:43` | `Metinler.yukleniyor` | tam ekran `Column` |

---

## 2. KAPSAM

**DÂHİL:** yalnız `Y1`–`Y5`'in `Text` çağrıları + yeni kapı `G16`.
**HARİÇ — adıyla, sessizce değil:** `cakisma_rozeti.dart:77` ve `:82` (`_CakismaCozumSayfasi`). Gerekçe:
sayfa kodun kendi yorumuyla **yer tutucudur** ve **K42-d adım 3** onu değiştirecektir; oraya harcanan emek
atılır. 🔴 Bu iki yer `BORCLAR.md`'ye **adıyla** yazılır (kapanış maddesi, §7/11).
**Ayrıca HARİÇ:** `DESIGN.md` (**K46**, tek bayt yazılmaz) · mevcut kapılar `G13`/`G14`/`G15` /
`a11y_statik_tasma_test.dart` (**değiştirilmez**; K34-f) · `Metinler` sabitleri (metin değişmez).

---

## 3. ORTAM

🟢 Cihaz ya da canlı sunucu kanıtı **İSTENMEZ** ⇒ K80'in ortam-kaldırma maddesi **UYGULANMAZ**, bilinçli
olarak yazılmadı. Tüm ölçüm `flutter test` (widget) + `flutter analyze`. `flutter` bu makinede `.bat`'tir
⇒ `C:\src\flutter\bin\flutter.bat` (K86). Kapı `@TestOn('vm')`'dir (web ayağı `DURUM.md` §7 gereği
**[DOĞRULANMADI]**). 🟢 **Navigator YOK:** beş bileşen de doğrudan pompalanır ⇒ v1'i vuran
*"itilen rota `MediaQuery`'yi görmez"* tuzağı bu tasarımda **yapısal olarak yoktur**.

---

## 4. ÜRÜN DEĞİŞİKLİĞİ — TASARIM KİLİDİ (Onur, oturum 42)

**TEK MEKANİZMA: `overflow: TextOverflow.ellipsis` KALIR (a11y statik kapısı bunu zorunlu kılar) ve
yanına AÇIK bir `maxLines` gelir.** Kaydırma (`SingleChildScrollView`) bu dilimde **EKLENMEZ** — gerekçe:
`Center`'ı kaydırıcı içine almak dikey ortalamayı sessizce düşürür (`rendering/shifted_box.dart:480-490`,
sonsuz `maxHeight` ⇒ shrink-wrap) ve bu, ölçülmemiş **görünür** bir ürün değişikliğidir. Kaydırma
gerekirse `A4` onu **ölçerek** ortaya çıkarır (§7/2).

🔴 **`maxLines` SAYILARI SPEC'TE UYDURULMAZ — BUILDER ÖLÇER.** Her yer için değer, ızgaranın **en kötü**
noktasında (`320dp × 2.0×`) metnin **gerektirdiği satır sayısıdır**; builder bunu `TextPainter` ile ölçer,
`00-OLCUM.txt`'ye yazar ve **ölçtüğü sayıyı** koda yazar. **Tavan `6`**; ölçüm 6'yı aşarsa **DUR** ve
Cowork'e bildir (o zaman doğru cevap kaydırmadır, bu dilim değil).

| kod | değişiklik | not |
|---|---|---|
| `Y1` | `maxLines: 1` — **sabit, ölçülmez** | Liste satırında tek satır **DOĞRU** davranıştır; kayıp **kabul edilir** ve `Semantics(label: gorev.baslik)` tam metni taşır (`gorev_satiri.dart:125`). Bugünkü **fiilî** davranış zaten budur ⇒ **düzen değişmez** ⇒ `G13`/`G14`/`G15` risk almaz. Değişiklik: örtük olan **açık** olur |
| `Y2` | `maxLines: <ölçülen>` | `MTipo.baslikL` ⇒ en çok satır isteyen yer |
| `Y3` | `maxLines: <ölçülen>` | |
| `Y4` | `maxLines: <ölçülen>` | `TextButton` etiketi |
| `Y5` | `maxLines: <ölçülen>` | |

🔴 **Sabitler tek yerde:** ölçülen değerler `lib/sunum` içinde **adlandırılmış sabitler** olarak yazılır
(ör. `const int kBosDurumMaxSatir = ...`), sayı gövdeye gömülmez — K30 (*"sayı bir kez yazılır"*).
🔴 **Token kuralı:** `MBosluk` / `MTipo` / `MRenk` kullanımına **dokunulmaz**; ham literal girmez (`D0`).

---

## 5. KAPILAR

### G16 — `lib/sunum` METİN KAYBI KAPISI

**Dosya:** `src/client/test/g16_metin_kaybi_kapisi_test.dart` · `@TestOn('vm')`
**Izgara:** ölçek `1.0 / 1.5 / 2.0` × genişlik `320 / 360 / 411` dp — **dokuz nokta**, beş yerin **her biri** için.
**Kurulum:** her bileşen ayrı ayrı `MaterialApp(home: MediaQuery(data: ...textScaler..., child: Align(
alignment: Alignment.topLeft, child: SizedBox(width: g, height: h, child: <bileşen>))))` ile pompalanır.
🔴 **POZİTİF KONTROL — hüküm vermeden ÖNCE:** ölçülen `RenderParagraph`'ın `constraints.maxWidth`'i
beklenen değere (genişlik − yatay padding) ve etkin `textScaler`'ın ızgara ölçeğine **eşit** olmalıdır;
değilse test **hata verir**. Gerekçe: v1'in harness'ı ızgarayı hedefe hiç ulaştırmıyordu (denetim bulgusu).

| ayak | kapsam | ne ölçer | hüküm |
|---|---|---|---|
| `A1` | **yalnız `Y2`–`Y5`** (dokuz nokta) | `RenderParagraph.didExceedMaxLines` | `false` olmalı — **manşet ayak** |
| `A2` | `Y1`–`Y5` | Her `Text`'in `maxLines != null` **ve** `overflow == TextOverflow.ellipsis` | ikisi birden — beyan ayağı, `a11y_statik_tasma` ile **uyumlu**; `Y1`'in TEK ölçüsü budur |
| `A3` | `Y1`–`Y5` | `tester.takeException()` | `null` (`RenderFlex` taşması yakalanır) |
| `A4` | `Y2`–`Y5` | `rp.size.height >= rp.getMinIntrinsicHeight(rp.constraints.maxWidth)` | çizilen kutu metnin **istediği** yüksekliği kısaltmamalı ⇒ dikey **sessiz kırpma** yakalanır |

🔴 **`A1` `Y1`'İ KAPSAMAZ — ölçülmüş gerekçe (denetim, oturum 42).** `Y1` `maxLines: 1` alır ve
`MTipo.govdeM`(16) ile `320dp × 2.0×`'te bir satıra **~8 karakter** sığar ⇒ gerçekçi her görev başlığında
`didExceedMaxLines = **true**` olur. `A1`'i `Y1`'e uygulamak, `S1`'in *"`Y1`'de kayıp KABUL EDİLİR"*
beyanıyla **doğrudan çelişirdi** ve kapı kalıcı kırmızı kalırdı. Kaçış olarak kısa örnek başlık yazmak da
**YASAK**: `g13_rozet_tasma_kapisi_test.dart:51-53` bunu adıyla *"kısa başlık kapıyı KÖRLEŞTİRİR"* diye
reddediyor. `Y1` bu yüzden `A2` ile ölçülür ve `S1`'e bağlanır.

🔴 **`A4`'ÜN ÖLÇÜSÜ DÜZELTİLDİ — ilk yazım TOTOLOJİYDİ (denetim, oturum 42).** `size.height <= maxHeight`
**her zaman** doğrudur: `rendering/paragraph.dart:946` `size = constraints.constrain(textSize)` ile yükseklik
kısıta **kenetlenir** ⇒ ayak asla ısıramazdı. Gerçek kayıp, çizilen kutunun metnin **istediği** yükseklikten
**küçük** kalmasıdır (`:948`); yukarıdaki ölçü bunu **açık API** ile alır.

**Bulucular adıyla yazılır** (belirsizlik yok): `find.text(Metinler.bosDurum)` · `find.text(Metinler.birSeylerTersGitti)`
· `find.text(Metinler.yenidenDene)` · `find.text(Metinler.yukleniyor)` · `Y1` için örnek görev başlığı.

---

## 6. MUTANTLAR

Hepsi **widget/statik** ⇒ K53/3 gereği **tavansız**. Her biri `KANIT/A8/02-MUTANT/` altına kırmızı **ve**
geri alma sonrası yeşil çıktısıyla yazılır; her çıktı **hangi ayakların** kırmızı olduğunu **ayak ayak** listeler.

| # | mutasyon | ısırması BEKLENEN | tür |
|---|---|---|---|
| **M88** | `Y1`'den `maxLines` silinir | `G16/A2` | widget |
| **M89** | `Y2`'den `maxLines` silinir | `G16/A1` + `G16/A2` | widget |
| **M90** | `Y3`'ten `maxLines` silinir | `G16/A1` + `G16/A2` | widget |
| **M91** | `Y4`'ten `maxLines` silinir | `G16/A1` + `G16/A2` | widget |
| **M92** | `Y5`'ten `maxLines` silinir | `G16/A1` + `G16/A2` | widget |
| **M93** | `Y2`'nin `maxLines`'ı **1** yapılır | `G16/A1` | widget |
| **M94** | `Y3`'ten `overflow: ellipsis` silinir | **`a11y_statik_tasma_test.dart`** (v1'i vuran kapı — ısırdığı KANITLANIR) | statik |
| **M95** | `Y2`'de `EdgeInsets.all(MBosluk.l)` → ham `EdgeInsets.all(24.0)` | **`design-token-kapisi.py`** | statik |
| **M96** | Izgara `2.0` ölçeğinden arındırılır (yalnız `1.0` kalır); hedef = **ÖLÇEĞE DUYARLI YER** (`00-OLCUM.txt`'de `1.0×`'te **1 satır**, `2.0×`'te **>1 satır** çıkan yer) ve onun `maxLines`'ı `1` yapılır | `G16/A1` — bu mutant dar ızgarada **ARTIK ISIRMAMALI** | widget |
| **M97** | Pozitif kontrol devre dışı bırakılır ve `MediaQuery` bileşenin **üstüne** konmaz (v1'in kusuru taklit edilir) | **kapının kendisi**: aynı ölçeğe duyarlı yerin mutantı **susmalı** ⇒ harness'ın ızgarayı gerçekten taşıdığı kanıtlanır | widget |

🔴 **`M96`/`M97` "KAPI-KAPISI"dır, tersten okunur:** beklenen sonuç *"kapı sustu"*tur; kanıtı **iki
dosyadır** (dar kurulumda yeşil, geniş kurulumda kırmızı). Susmuyorsa hüküm ızgaradan/harness'tan gelmiyor
demektir ve kapı **dekordur**.
🔴 **HEDEF SPEC'TE ADLA SABİTLENMEZ, ÖLÇÜMDEN SEÇİLİR — ölçülmüş gerekçe (denetim, oturum 42).** İlk yazım
hedefi `Y2`'ye (`M93`) bağlamıştı; ama `Metinler.bosDurum` (34 krk) `MTipo.baslikL`(20) ile `320dp`'de
**`1.0×`'te bile 3 satır** ister ⇒ `M93` dar ızgarada **da** ısırır ⇒ *"kapı sustu"* kanıtı **üretilemezdi**
(v1'in `M94` kusurunun birebir tekrarı). Bu yüzden hedef, kriter 2'nin ölçtüğü satır tablosundan
**mekanik olarak** seçilir. 🔴 **Hiçbir yer ölçeğe duyarlı değilse `M96`/`M97` KOŞULAMAZ:** builder bunu
`02-MUTANT/` altında **açıkça** yazar ve ızgaranın hüküm üretmediğini beyan eder — sessizce atlamaz.
🔴 **Mutant sayısı 10'dur (≥ 8).** Bu bilinçlidir: `iddia-kapisi.py`'nin `LISTE_ESIGI = 8` **envanter reddi**
ancak 8+ mutantta ısırır; v1 **7** mutantla eşiğin bir altında kalıyordu ve `06-SPEC-KAPSAMA.txt` tek başına
tüm mutantları *"kanıtlı"* gösterebiliyordu (**dairesel kanıt**, denetim bulgusu).

## 6b. MUTANT BORCU

**YOK — ve bu bölümün ARACA GÖRE boş olması bir SINIRIN sonucudur, temizliğin değil.**
`spec-kapi-kapsama.py` borcu yalnız **envanterindeki bir KURAL** için kabul eder; envanteri ise
`### G<n>` başlıkları ile `## 5.` tablosunun `D<n>`/`A11Y-<n>` hücrelerinden doğar ⇒ **ayaklar
(`A1`–`A4`) araca görünmez** ve onlar adına borç yazmak `[S6] GEREKSIZ BORC` ile **reddedilir**
(ölçüldü, oturum 42). Bu yüzden ayak düzeyindeki tek borç **§8/`S7`'de** beyan edilmiştir; gizlenmedi,
**yeri değiştirildi** ve nedeni yazıldı.

---

## 7. KABUL KRİTERLERİ (sırayla, atlanmaz)

1. 🔴 **ÖNCE ÖLÇ — `G16` DÜZELTMEDEN ÖNCE KIRMIZI YANMALI.** Kapı yazılır, **mevcut** kod üzerinde koşulur,
   çıktı `KANIT/A8/00-ONCE-KIRMIZI.txt`. **DUR ŞARTI YALNIZ `A1`'E BAĞLIDIR:** `A1` dokuz noktanın hiçbirinde
   ısırmazsa **DUR** ve Cowork'e bildir. *(`A2` düzeltilmemiş kodda tanım gereği kırmızıdır; onu frene
   saymak freni öldürür — denetim bulgusu.)*
2. **`maxLines` DEĞERLERİ ÖLÇÜLÜR** ve `KANIT/A8/00-OLCUM.txt`'ye **ızgaranın DOKUZ noktası için satır
   tablosu** olarak yazılır (bu tablo aynı zamanda `M96`/`M97`'nin hedefini seçer). Değer, `320dp × 2.0×`
   noktasındaki satır sayısıdır. **Tavan 8**; aşan olursa **DUR**. 🔴 **Tavan 6 DEĞİL, 8 — ölçülmüş gerekçe
   (denetim, oturum 42):** `Y2` (`bosDurum`, 34 krk × `baslikL` 20) `320dp × 2.0×`'te **6 satır** ister;
   tavanı 6 yapmak DUR şartını **yazı-turaya** çevirirdi. 8, ölçülen en kötü noktanın **üstünde** ve hâlâ
   *"bu artık kaydırma işidir"* diyebilecek kadar dar.
   `A4` bir yerde kırmızı kalıyorsa **DUR** — kaydırma gerekiyor demektir, o ayrı dilimdir.
3. §4'teki ürün değişikliği uygulanır (yalnız beş `Text` + adlandırılmış sabitler).
4. `G16` **yeşil**: `KANIT/A8/01-SONRA-YESIL.txt`.
5. `M88`–`M97` **hepsi beklendiği gibi** davranır (`M96`/`M97` **susar**); `KANIT/A8/02-MUTANT/`.
6. 🔴 **REGRESYON — PAZARLIKSIZ:** `a11y_statik_tasma_test` · `a11y_kapisi_test` · `sunum_bilesenleri_test` ·
   `g13`/`g14`/`g15` **yeşil kalır**. Biri kırılırsa **DUR**: `Y1` düzen değiştirmemeli (§4 gerekçesi).
   🔴 **EN RİSKLİ NOKTA ADIYLA:** `a11y_kapisi_test.dart:312-318` vitrini `textScale 2.0` ile pompalayıp
   `takeException()` `null` bekler. `Y2` bu değişiklikle **1 satırdan ~6 satıra** çıkar (`baslikL` satır
   yüksekliği ≈ 28 × 2,0 = 56 px ⇒ ~56 px yerine ~336 px dikey talep) ⇒ bir `RenderFlex` taşması **mümkündür**
   ve bu **[DOĞRULANMADI]**'dır: kâğıtta değil, **bu kriterde** ölçülür. Kırılırsa `Y2`'nin `maxLines`'ı
   düşürülmez — **DUR** ve Cowork'e bildir (doğru cevap kaydırmadır, o ayrı dilim).
7. `flutter.bat analyze --fatal-infos` ⇒ **0**.
8. `flutter test` tamamı yeşil; toplam **ölçülür**, beyan edilmez (A-7 sonrası taban **266**) ⇒ `03-TEST.txt`.
9. `python araclar\design-token-kapisi.py .` ⇒ **EXIT 0**.
10. `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-A8-metin-kaybi-gercek-ekranlar.md` ⇒ **EXIT 0**
    (dizin **verilmez**, K81). Çıktı `KANIT/A8` **DIŞINA** yazılır: `_SILINECEKLER\06-SPEC-KAPSAMA.txt`.
11. 🔴 `python araclar\iddia-kapisi.py GOREV_CLAUDE_CODE\GOREV-A8-metin-kaybi-gercek-ekranlar.md --kanit KANIT\A8`
    ⇒ **EXIT 0** *ve* çıktıda **`KANITLI MUTANT (10)`** görülür. *(v1 bu aracı **dizinle** çağırıyordu ⇒ ölçüldü: **EXIT 2**.)*
12. Değişen dosyalar `git --no-optional-locks status --porcelain` ile ölçülür; **`git add -A` YASAK** (K55),
    yol belirtilir. **PUSH ONUR'DA.**
13. `BORCLAR.md`'ye **kapanış maddesi**: `cakisma_rozeti.dart:77,82` bu dilimin **beyanlı HARİCİ**;
    K42-d adım 3'te kapanır.

---

## 8. BEYAN EDİLMİŞ SINIRLAR

- **S1 — `Y1`'de kayıp KABUL EDİLİR** (liste satırı tek satır kalır); `Semantics` tam metni taşır.
- **S2 — `flutter_test` fontu cihaz fontundan FARKLI ölçer** (`G13`/`S3` ile aynı sınır). Bu dilim **cihaz
  kanıtı istemez** ⇒ gerçek görünüm **[DOĞRULANMADI]**.
- **S3 — Izgara bir ÖRNEKLEMDİR** (`320/360/411` × `1.0/1.5/2.0`); ara genişlikler ve `>2.0` ölçek ölçülmedi.
- **S4 — Web ayağı [DOĞRULANMADI]** (`--platform chrome` bu ortamda sonuç üretmiyor, `DURUM.md` §7).
- **S5 — Kaydırma bu dilimde YOK.** Metin `maxLines` tavanını aşacak kadar uzarsa kayıp geri gelir;
  `A4` bunu **ölçer** ve o an ayrı dilim açılır.
- **S6 — Kriter 10 AYAKLARA KÖRDÜR [ölçüldü, oturum 42].** `spec-kapi-kapsama.py` yalnız `### G<n>`
  başlıklarını ve `## 5.` tablosunun `D<n>`/`A11Y-<n>` hücrelerini okur; `A1`–`A4` ona **görünmez**.
  Bu yüzden `EXIT 0` *"her ayak kapsandı"* demek **DEĞİLDİR** — ayak kapsaması §6 tablosuyla **elle** kurulur.
- **S7 — `A3`'ÜN BAĞIMSIZ MUTANTI YOK (ayak düzeyi borç; §6b'ye YAZILAMADI, gerekçesi orada).**
  `A3` hüküm vermez, `RenderFlex` taşmasının **beyanıdır**. `RenderParagraph` görsel taşmada istisna
  **ATMAZ** (`rendering/paragraph.dart:957-964`, `clip` dalı) ⇒ `A3`'ü ısırtacak mutasyon `Row`/`Column`
  yeniden tasarımı ister ve bu dilimin kapsamı dışındadır. **Aynı kaybı `A4` istisnasız ölçer**, bu yüzden
  boşluk kapıyı körleştirmez. Borç **adlandırıldı**, gizlenmedi.
- **S8 — `Y2`–`Y5`'İN DİKEY BÜYÜMESİ [DOĞRULANMADI] ve bu BİLİNÇLİDİR.** `maxLines` eklemek metnin
  kapladığı dikey alanı **artırır** (`Y2` için ~56 px → ~336 px, `320dp × 2.0×`). Bunun mevcut düzenleri
  taşırıp taşırmadığı **kâğıtta ölçülemez** — kriter 6 onu **koşan kodla** ölçer. K53/1 doktrini tam da
  budur: kâğıt turu bu soruyu cevaplayamaz, build cevaplar. Risk **gizlenmedi**, kriterde **adıyla** duruyor.
- **S9 — İKİ DENETİM TURU KOŞTU, ÜÇÜNCÜ YOK (K53/1).** Tur 1: **5 bloker** (mimariyi değiştirdi ⇒ tur 2
  meşru). Tur 2: **3 bloker** (hepsi bu sürümde kapatıldı) + 2 major. Eğilim projenin kendi ölçümüyle
  uyumlu (13→4→0); **üçüncü tur AÇILMAZ**, kalan belirsizlik `S8` olarak **build'e devredildi**.

---

## 9. KANIT DİZİNİ

`KANIT/A8/` → `00-OLCUM.txt` · `00-ONCE-KIRMIZI.txt` · `01-SONRA-YESIL.txt` · `02-MUTANT/` (M88–M97) ·
`03-TEST.txt` · `04-ANALYZE.txt` · `05-DESIGN-TOKEN.txt` · `06-REGRESYON.txt` · `07-IDDIA.txt` ·
`08-GIT-STATUS.txt` · `09-HUKUM.md` (**builder'ın kendi hükmü; Cowork doğrulamadan KABUL ETMEZ — K26**).
🔴 `06-SPEC-KAPSAMA.txt` **bu dizine konmaz** (dairesel kanıt — kriter 10).

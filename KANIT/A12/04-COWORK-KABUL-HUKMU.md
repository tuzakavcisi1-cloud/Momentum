# `GOREV-A12` — COWORK BAĞIMSIZ KABUL DENETİMİ (3 Ağu 2026, oturum 51)

> **K26: üreten ≠ denetleyen.** Aşağıdaki her satır **Cowork'ün kendi koşumudur**; builder'ın
> beyanı okundu ama **hiçbiri kanıt yerine sayılmadı**. Ölçüm anındaki kimlikler:
> `araclar/spec-kapi-kapsama.py` **17.100 b / `DE87E43D`** ·
> `GOREV-A11-ag-donus-itmesi.md` **35.255 b / `9BB716DF`** ·
> `GOREV-A12-kural-envanteri.md` **15.219 b / `70A6720A`** · `BORCLAR.md` **23.995 b / `E542E442`**.

## KRİTERLER

| # | kriter | Cowork'ün ölçümü | hüküm |
|---|---|---|---|
| **0** | patlama yarıçapı (daraltılmış hüküm) | Bağımsız taban **öncesi** `00-COWORK-TABAN-ONCESI.txt` (`AF42E7E7`) ↔ **sonrası** `03-COWORK-TABAN-SONRASI.txt` (`D26FA3F7`): 23 spec, **TOPLAM BULGU 10 → 10**. 21 spec'in hükmü **birebir aynı**; değişen tek şey `A11` `KURAL (0)→(6)` ve `A12` `KURAL (0)→(3)`, ikisi de **EXIT 0**. Envantere yeni giren kural sınıfı **dışında fark = 0** | ✅ |
| **1** | `--altin-kume` EXIT 0, vaka ≥ 21 | **21/21 GEÇTİ**, EXIT 0 (yeni vakalar 14–21 `A12/G25`/`a`–`h`) | ✅ |
| **2** | `M156`–`M161` ısırır, bayt-özdeş geri alınır | **6/6 ISIRDI** (`_cowork_mutant.py`, ORTAM.md reçetesi: ikili yedek → bayt yaması → koşum → yedekten geri yaz → sha). Her mutantta araç **`DE87E43D` OZDEŞ** geri geldi. `M160` ayrıca **gerçek depoda** ölçüldü: bulgu **10 → 265**. TEMİZ-ÖNCE EXIT 0 · TEMİZ-SONRA EXIT 0 | ✅ |
| **3a** | §6b kayıtlarından **önce** EXIT 1 + tam 6/3 `[S2]` | Kopya üzerinde ölçüldü (`_cowork_krit3a.py`): `A11` **EXIT 1, tam 6** `[S2]` · `A12` **EXIT 1, tam 3** `[S2]`. 🔴 Orijinal dosyalara **DOKUNULMADI** — sha8 önce/sonra `9BB716DF`/`70A6720A` **özdeş** | ✅ |
| **3b** | §6b kayıtlarından **sonra** EXIT 0, `KURAL (0)` yazmaz | `A11` **EXIT 0**, `[S2]` **yok**, `KURAL (6)` · `A12` **EXIT 0**, `[S2]` **yok**, `KURAL (3)` | ✅ |
| **4** | `sayi-tazeligi.py` TEMİZ | **TEMİZ / EXIT 0** (`DURUM.md` araç tablosu `13/13 → 21/21` tazelendi) | ✅ |
| **5** | `tek-kopya-kapisi.py` YEŞİL | **YEŞİL / EXIT 0** — 11 dosyanın hepsi tutarlı | ✅ |

## ONUR'UN ÜÇ ŞARTI (K123)

| şart | Cowork'ün ölçümü | hüküm |
|---|---|---|
| **1 — kayıtlar dürüst** | 9 kaydın **9'u da** `MUTANTSIZ DEGILDIR:` ile başlıyor, ısıran mutantı **adıyla ve kapı-ayağıyla** veriyor, eşlemenin neden dolaylı olduğunu yazıyor. **Hiçbiri "mutantı yok" demiyor.** Fazlası da var: `D-A11-6` için **"ÇİFT DOLAYLI"** deyip aracın §9/2 sınırına atıf yapılmış, `D-A12-2` için alt-desenin **kendi mutantı olmadığı** ayrıca beyan edilmiş | ✅ |
| **2 — üç bayat şey aynı turda** | (a) `D-A12-3` **daraltıldı** + errata ile eski metnin yanlışlandığı yazıldı · (b) kriter 3 **3a/3b** olarak iki aşamalı yazıldı, gerekçesi *"kör kapı olmadığının kanıtı"* · (c) *"sekiz"* → **10**, on spec **adıyla** sayıldı, `[SAYI YANLIŞ — errata]* işaretiyle eski cümle korunarak (additive) | ✅ |
| **3 — asıl kusur kapatılmadı** | `git diff` ile ölçüldü: `denetle()` içindeki **`S2` üretimi değişmemiş**; değişen yalnız envanterin **kaynağı** (`uc_baslik_kurallari` eklendi, `kod_araligi_ac` deseni genişledi). Kalem **`BORCLAR.md` `B-O51-1`** olarak yazıldı, dokuz eşleme örneğiyle | ✅ |

## 🔴 BUILDER, COWORK'ÜN EŞLEME ÖNERİSİNİ İKİ NOKTADA DÜZELTTİ — VE HAKLIYDI

Cowork K123'te dokuz kural için mutant eşlemesi önermişti. Builder ikisini reddetti ve **spec'in
kendi metnini kanıt gösterdi**; Cowork bunu **yeniden ölçtü ve builder'ı doğruladı**:

- **`M150` → `D-A11-3` değil `D-A11-5`.** `D-A11-5`'in gövdesi harfiyen şunu diyor:
  *"O sembolde bile: `turCalistir` izinli; `cekmeTuruCalistir`, `SenkronAgi` ve **`_yuvarlakDongusu`**
  yasak kalır (denetim `B5`)"*. `M150` tam olarak o yasak kümesinden `_yuvarlakDongusu`'nu çıkarır
  ⇒ ısırdığı karar `D-A11-5`'tir. **Cowork yanılmıştı.**
- **`M161` → `D-A12-2` değil `D-A12-1`.** `M161` §5 ilk-sütun kaynağını kaldırır; `D-A12-1`'in metni
  *"Bugünkü kaynak (§5 ilk sütun) **korunur**"* der ⇒ mutant o kararın **korunan yarısını** ölçer,
  `D-A12-2`'nin ad desenini değil. **Cowork yanılmıştı.**
- Ayrıca builder `D-A11-5`'e **`M147`**'yi ekledi (Cowork'ün listesinde yoktu): `(dosya, sınıf)`
  çifti kararının **en doğrudan** testi budur.

**Bu, K26'nın çift yönlü işlediğinin kanıtıdır:** denetçi de denetlenir. Cowork'ün kâğıt üzerinde
kurduğu eşleme, builder'ın belge metnine dayalı itirazıyla düzeldi.

## AÇIK KALANLAR (kabulü engellemez, **beyan edilir**)

1. 🔴 **`B-O51-1` — `S2` dolaylı kapı-ayak→kural eşlemesini görmüyor.** Bilerek kapatılmadı (Şart 3).
   Bedeli **ölçülmüş ve yazılıdır**: bundan sonraki **her** spec aynı sınıfı yeniden üretecek ve her
   seferinde elle §6b borcu yazmayı gerektirecek. Kapanış yolu `BORCLAR.md`'de tarif edilmiş.
2. 🔴 **`kriter-içi-çelişki` sınıfının mekanik kapısı YOK.** İki dilimde üst üste ısırdı
   (`A11` kriter 7↔8 · `A12` kriter 3) ve ikisi de **ancak kabul koşumunda** görüldü. Bu sınıfı ölçen
   bir kapı bugün mevcut değil.
3. 🔴 **`A12` ürün kodu değildir** ⇒ `R8` sayacını **düşürmez**. Bir sonraki oturum da araç/belge işi
   olursa sert durak yanar (K53/4).
4. 🟡 **`BORCLAR.md` `T2` SARI:** 23.995 / 24.576 b, pay yalnız **581 b** (eşik 1.228). Kapı diyor:
   *"Bir sonraki checkpoint tavanı AŞAR."* Kabul checkpoint'i yazılmadan **önce** budanmalı ya da
   tavan Onur tarafından yeniden ayarlanmalı (K40 — kapı tavanı kendi değiştirmez).
5. Aracın **kendi beyan ettiği sınır** yürürlükte: *"mutantın GERÇEKTEN ısırdığını ölçmez, yalnız
   kapsamayı ölçer."* Cowork bunu `M156`–`M161` koşumuyla **bu dilim için** ayrıca kapattı, ama
   genel sınır duruyor.

## HÜKÜM

**`GOREV-A12` KABUL EDİLEBİLİR.** Yedi kriterin yedisi + üç şartın üçü de **ölçülerek** geçti;
hiçbiri beyana dayanmıyor. Kabul kararı **Onur'undur** (K40/K26).

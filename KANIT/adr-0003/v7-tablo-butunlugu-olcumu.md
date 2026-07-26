# ADR 0003 — TABLO HÜCRE BÜTÜNLÜĞÜ ÖLÇÜMÜ [oturum 25, 26 Tem 2026 — K36]

**Neden bu dosya var:** `araclar/adr-kapi-taramasi.py` tablo hücre bütünlüğünü **HİÇ taramıyor**
(`K1`..`K7`'nin hiçbiri bu eksende değil). Buna karşılık **kapı-5 (M31)** ve **kapı-6 (M56)**
bu sınıftan bulgu üretti — yani eksen gerçek, ölçüm aracı kör.

Bu oturum (v7'yi yazan el) **araca DOKUNMADI** (K34-f: 2. onarım AYRI ELE aittir).
Onun yerine ölçümü **ayrı bir tarayıcıyla** yaptı ve hem betiği hem **ham çıktıyı** buraya bıraktı.
**Aracın 2. onarımını yapacak el, bu mantığı araca yeni bir kontrol kodu olarak eklemek
ve altın kümeye MUTASYON TESTİYLE kanıtlamakla yükümlüdür (kör kapı yok).**

---

## 1. TARAYICI (birebir koşulan betik)

```python
import re
f = "<adr dosyasi>.md"
L = open(f, encoding="utf-8").read().split("\n")

def cells(s):
    # kacisli \| bir hucre ayiraci DEGILDIR -> maskele
    t = re.sub(r'\\\|', '\x00', s).strip()
    if t.startswith('|'): t = t[1:]
    if t.endswith('|'):   t = t[:-1]
    return len(t.split('|'))

i = 0
while i < len(L):
    # tablo = `|` ile baslayan satir + hemen altinda ayirici satiri
    if L[i].lstrip().startswith('|') and i+1 < len(L) \
       and re.match(r'^\s*\|[\s:\-\|]+\|\s*$', L[i+1]):
        hdr = cells(L[i]); sep = cells(L[i+1]); j = i+2
        if hdr != sep:
            print(f"[KUSUR] satir {i+1}: baslik {hdr} hucre, ayirici {sep}")
        while j < len(L) and L[j].lstrip().startswith('|'):
            c = cells(L[j])
            if c != hdr:
                print(f"[HUCRE SAPMASI] satir {j+1}: {c} hucre (baslik {hdr})")
            j += 1
        i = j
    else:
        i += 1
```

**Kök neden ayrımı için ek sonda** (her sapmalı satırda son `|`'den sonraki metin okunur):

```python
s = L[n-1]; i = s.rfind('|'); print(repr(s[i+1:]))
```

---

## 2. HAM ÇIKTI — v6 (KANONİK, `sha256 6f6be71a…38cb08`)

```
[HUCRE SAPMASI] v6 satir 47: 5 hucre (baslik 4)
[HUCRE SAPMASI] v6 satir 342: 4 hucre (baslik 3)
[HUCRE SAPMASI] v6 satir 908: 7 hucre (baslik 5)
[HUCRE SAPMASI] v6 satir 1055: 4 hucre (baslik 3)
v6 TABLO: 23 · TOPLAM SAPMA: 4
```

## 3. HAM ÇIKTI — v7 çalışma dosyası (aynı koşum)

```
TABLO SAYISI: 23
  [HUCRE SAPMASI] satir 47: 5 hucre (baslik 4)
  [HUCRE SAPMASI] satir 398: 4 hucre (baslik 3)
  [HUCRE SAPMASI] satir 1010: 7 hucre (baslik 5)
  [HUCRE SAPMASI] satir 1157: 4 hucre (baslik 3)

TOPLAM KUSUR: 4
BASLIKSIZ/ORPHAN `|` SATIRI: 0
```

⇒ **Aynı dört kalem** (numaralar v7'nin eklemeleri yüzünden kaymış).
**v7 YENİ bir hücre sapması ÜRETMEDİ.**

## 4. KÖK NEDEN SONDASI — HAM ÇIKTI (v7)

```
--- satir 47 (uzunluk 316) ---
  son '|' SONRASI: '  <!-- [KS-LITERAL: §0.4 geri çekilen iddia kaydı — tarihsel metin, sayı değişemez] -->'
--- satir 398 (uzunluk 189) ---
  son '|' SONRASI: "  <!-- [KS-LITERAL: v1'in KALDIRILMIŞ mekanizmasının tarihsel tarifi] -->"
--- satir 1010 (uzunluk 893) ---
  son '|' SONRASI: ''
--- satir 1157 (uzunluk 509) ---
  son '|' SONRASI: '  <!-- [KS-LITERAL: REDDEDİLEN alternatifin sayısı — politikanın değil] -->'
```

---

## 5. HÜKÜM

**İKİ FARKLI SINIF VAR ve kapı-6 bunları ayırmamıştı:**

| satır (v6) | son `\|` sonrası | kök neden | render'da kayıp | sınıf |
|---|---|---|---|---|
| **908** (M56) | **boş** | satırın **İÇİNDE kaçışsız `\|`** (`grep "blocklist\|pwned\|sızdırılmış"`) | **VAR** — `[KS-31]` atfı, HIBP'nin adlandırılmış reddi ve satırın **ÇIPASI** ekranda kaybolur | **GERÇEK KUSUR** (kapı-6 majör #10) |
| 47 | HTML yorumu | yorum **son `\|`'den SONRA** ⇒ fazla hücre | **YOK** — atılan hücre yalnız bir HTML yorumu taşıyor, o zaten render'da görünmez; araç da yorumu kaynaktan okur | MİNÖR / kozmetik |
| 342 | HTML yorumu | aynı | **YOK** | MİNÖR / kozmetik |
| 1055 | HTML yorumu | aynı | **YOK** | MİNÖR / kozmetik |

### 🔴 KAPI-6'NIN BİR CÜMLESİ YANLIŞLANDI

Kapı-6 majör #10 birebir: *"**Belgenin tamamındaki tek hücre sapması budur.**"*
**ÖLÇÜLDÜ: DÖRT TANEDİR.**

**Ama kapı-6'nın ESAS HÜKMÜ DOĞRUDUR:** bilgi kaybı üreten **tek** sapma gerçekten **908**'dir.
⇒ **Sayı yanlış, önem doğru.** *(Bu, kapı-7'nin kapı-6 raporuna yapması gereken denetimin
erken ödenmiş bir parçasıdır — ve kapı-6'nın kendi uyarısını doğrular: "kapı-6 de bir üretimdir".)*

### v7'NİN BORCU

Üç kozmetik sapma da düzeltilecek (**HTML yorumu son `|`'den ÖNCEYE alınacak**) — gerekçe:
tarayıcının taban çizgisi **sıfır** olmalı ki gelecekte **gerçek** bir sapma gürültüye karışmasın.
*(Bugün "4 sapma var ama 3'ü zararsız" demek, bir sonraki turda 5. sapmanın sessizce
kabullenilmesine açık kapı bırakır.)*

---

## 6. BU OTURUMUN KENDİ ÜRETTİĞİ KUSUR [dürüstlük — gizlenmiyor]

K35'in alıntı-hijyeni not bloğu ilk yazıldığında **§1'in tablosunun ORTASINA** düştü
(`M-C` ile `B4` satırları arasına) ve **`B4` satırını tablodan kopardı** — yani
**tam olarak kapatmakta olduğu kusur sınıfı, onu kapatan turun kendi elinden.**
Aynı koşumda ölçüldü, düzeltildi ve **belgeye de yazıldı**.

**K33'ün dördüncü turda adlandırdığı örüntünün BEŞİNCİ kanıtı:**
*bir kusur sınıfını kapatan tur, o sınıfın en olası üreticisidir.*

⇒ **v7 kapanışında kendi YENİ satırları eski bulgu sınıflarına karşı taranacaktır.**

---

*Bu dosya bir ÖLÇÜM kaydıdır, bir kapı değildir. Kapı-7 hem ölçümü hem hükmü denetlemelidir.*

---

## 7. BU DOSYANIN KENDİSİ DE AYNI KUSURU TAŞIDI [ölçüldü, düzeltildi — gizlenmiyor]

Bu dosya yazıldıktan **hemen sonra kendi tarayıcısından geçirildi.** Ham çıktı:

```
[KUSUR] satir 99: baslik 6, ayirici 5
[HUCRE SAPMASI] satir 101: 5 hucre (baslik 6)
[HUCRE SAPMASI] satir 102: 5 hucre (baslik 6)
[HUCRE SAPMASI] satir 103: 5 hucre (baslik 6)
[HUCRE SAPMASI] satir 104: 5 hucre (baslik 6)
KANIT DOSYASI — TABLO: 1 · SAPMA: 5
  -> satir 99: backtick icinde KACISSIZ '|' var:
     "| satır (v6) | son `|` sonrası | kök neden | render'da kayıp | sınıf |"
```

**Kök neden:** §5'in başlık satırında `` son `|` sonrası `` yazılmıştı. **GFM'de bir kod aralığı
(`` ` ``) içindeki `|` bile hücre ayıracı sayılır** — kaçış (`\|`) zorunludur. ⇒ Başlık **6** hücre,
ayırıcı **5** oldu ve dört gövde satırının dördü de saptı. **Düzeltildi:** `` son `\|` sonrası ``.

**Bu, üçüncü kez aynı turda oluyor** (§6'daki tablo-ortası not bloğu · bu başlık) ve
**doktrinin işe yaradığının ölçülmüş kanıtıdır:** kusuru bulan şey akıl yürütme değil,
**mekanik olarak KOŞULAN bir tarayıcıdır** — ve tarayıcı **kendi belgesine de** uygulandığı için yakaladı.

> **ARACIN 2. ONARIMINI YAPACAK ELE PAZARLIKSIZ NOT:** bu kontrol araca eklenirken
> **altın kümeye üç ayrı mutasyon vakası** girmelidir, çünkü kök nedenler farklıdır ve
> biri diğerini yakalamaz:
> 1. satır **İÇİNDE** kaçışsız `\|` (⇒ **bilgi kaybı**, M56 sınıfı),
> 2. son `\|`'den **SONRA** metin/yorum (⇒ fazla hücre, kayıp yok),
> 3. **kod aralığı (`` ` ``) içinde** kaçışsız `\|` (⇒ bu dosyanın kendi kusuru; 1 ve 2'den ayrı yol).
>
> **Üçü de KIRMIZI vermeden kontrol altın kümeden geçmiş sayılmaz (kör kapı yok).**

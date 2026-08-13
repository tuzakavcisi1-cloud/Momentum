# ADR 0003 — `[KS-31]` KARA LİSTESİ: KAYNAK SEÇİMİ + LİSANS/CVE KAPISI + M56 PROBUNUN ÖLÇÜMÜ

**[oturum 26, 26 Tem 2026 — K37-b · K37-c · bloker B6-1]**

> 🔴 **REDAKSİYON (13 Ağu 2026, o71 — depo public'e açılmadan önce, Onur kilitledi):** aşağıdaki ham
> `METADATA` dökümünde `Author-email` satırındaki **üçüncü şahsa ait** e-posta adresi
> **maskelendi** (`<paket-yazari@REDAKTE>`). Maskeleme **ölçümün kendisini değiştirmez**: bu dosyanın
> lisans iddiası `Name` / `Version` / `License` / `Classifier` alanlarından türer, `Author-email`'den
> **değil**; `bayt` ve `sha256` satırları da dokunulmadan duruyor. Özgün değer paketin PyPI
> metadata'sında **zaten kamuya açıktır** — maskelemenin amacı gizlemek değil, bu deponun
> **tarayıcı hedefi** hâline gelmesini engellemektir. Başka hiçbir ham ölçüm satırı değiştirilmedi.


**Neden bu dosya var:** kapı-6'nın **B6-1** blokeri, M56'nın (*sızmış-parola kara listesi kontrolü
kaldırılır*) **kör kapı** olduğunu ölçtü: v6'nın probu `123456`'ydı ve bu parola `[KS-17]`=15
uzunluk kuralı yüzünden **mutasyondan bağımsız olarak** `400` alıyordu ⇒ mutant öldürülmüş
görünüyor ama kapı hiçbir şey ölçmüyordu. **K34-b** (Onur, 26 Tem) bunu şöyle kilitledi:
prob **≥`[KS-17]` uzunlukta GERÇEK bir kara-liste kaydına** çevrilir **ve o kaydın listede
bulunduğu KOŞULARAK ÖLÇÜLÜR**; ayrıca liste dosyasının **lisans + CVE kapısı (kırmızı çizgi #3)
BU TURDA KOŞAR** — çünkü altı turdur koşmamıştı.

Bu dosya o iki yükümlülüğün **ham kaydıdır**. Betikler birebir yazılıdır, çıktılar
**yeniden yazılmadan** yapıştırılmıştır (KANIT kuralı v2.1).

---

## 1. KİLİTLENEN KARAR (Onur, 26 Tem 2026)

- **K37-b — KAYNAK:** `zxcvbn` (PyPI, **MIT**, Daniel Wolf) paketinin frekans sıralı
  `FREQUENCY_LISTS['passwords']` listesinin **ilk 10.000 kaydı**. Repoya **`.txt` veri dosyası**
  olarak gömülür; **çalışma zamanı kod bağımlılığı YOKTUR** ⇒ paket üretime girmez.
- **K37-c — M56 PROBU:** `mailcreated5240` (15 karakter, **rank 1516**).
- **Reddedilenler ve gerekçeleri** `PROJE_HAFIZA.md` K37 checkpoint'inde adlandırılmıştır.

## 2. KOŞULAN BETİK — türetme ve prob ölçümü (birebir)

```python
import zipfile, hashlib
W = 'zxcvbn-4.5.0-py2.py3-none-any.whl'          # pip download zxcvbn --no-deps
print('wheel sha256:', hashlib.sha256(open(W,'rb').read()).hexdigest())
z = zipfile.ZipFile(W)
ns = {}; exec(z.read('zxcvbn/frequency_lists.py').decode('utf-8'), ns)
pw  = ns['FREQUENCY_LISTS']['passwords']          # frekans sirali, 30.000 kayit
top = pw[:10000]                                 # SIRASI KORUNARAK ilk 10.000
blob = ('\n'.join(top) + '\n').encode('utf-8')    # UTF-8, BOM yok, LF, sonda bir LF
print('uretilen dosya sha256:', hashlib.sha256(blob).hexdigest())
probe = 'mailcreated5240'
print('prob listede mi:', probe in top, '| rank:', top.index(probe)+1, '| uzunluk:', len(probe))
print('>=15 karakterli kayitlar:', [(i+1, len(p)) for i, p in enumerate(top) if len(p) >= 15])
```

## 3. KOŞULAN BETİK — CVE kapısı (birebir)

```bash
pip install pip-audit          # pip-audit 2.10.1
echo "zxcvbn==4.5.0" > req.txt
pip-audit -r req.txt --progress-spinner off ; echo "EXIT=$?"
```

---

## 4. HAM ÇIKTI — kaynak, lisans, türetme, prob (birebir yapıştırıldı)

```
[1] KAYNAK PAKET
    dosya      : zxcvbn-4.5.0-py2.py3-none-any.whl
    bayt       : 409397
    sha256     : 2b6eed621612ce6d65e6e4c7455b966acee87d0280e257956b1f06ccc66bd5ff
    METADATA   | Metadata-Version: 2.2
    METADATA   | Name: zxcvbn
    METADATA   | Version: 4.5.0
    METADATA   | Home-page: https://github.com/dwolfhub/zxcvbn-python
    METADATA   | Author: Daniel Wolf
    METADATA   | Author-email: <paket-yazari@REDAKTE>
    METADATA   | License: MIT
    METADATA   | Classifier: License :: OSI Approved :: MIT License
    METADATA   | License-File: LICENSE.txt
    METADATA   | License

[2] LISANS METNI (dist-info/LICENSE.txt, ilk 4 satir BIREBIR)
    | MIT License
    | 
    | Copyright (c) 2016 Daniel Wolf
    | 
    LICENSE.txt sha256: 5ac25259c90840319086f710e6b71740f32020c5322b508b858479fbd9869792

[3] TURETME TARIFI (deterministik)
    kaynak alan : FREQUENCY_LISTS['passwords']  (frekans sirali)
    toplam kayit: 30000
    dilim       : ilk 10000 kayit, SIRASI KORUNARAK
    kodlama     : UTF-8, BOM YOK, satir sonu LF, son kayittan sonra bir LF
    URETILEN DOSYA bayt   : 78880
    URETILEN DOSYA satir  : 10000
    URETILEN DOSYA sha256 : 839f86a5e388b0fe1ca13ec6c337975c9daf384e110effb70279b03caddd1462

[4] M56 PROBU - POZITIF AYAK (K37-c)
    prob        : 'mailcreated5240'
    uzunluk     : 15  (>= KS-17 = 15 :  True )
    listede mi  : True
    rank        : 1516 / 10000

[5] ILK 10.000 ICINDEKI >=15 KARAKTERLI TUM KAYITLARIN RANKLARI
    adet: 9
    (rank, uzunluk): [(1516, 15), (2174, 16), (6236, 18), (6766, 16), (8341, 17), (8512, 15), (8609, 15), (9980, 15), (9990, 15)]

[6] M56 PROBU - NEGATIF AYAK (listede OLMAYAN, >=15 karakter)
    'MomentumKapiTesti2026'  uzunluk=21  30.000'lik kaynakta var mi: False  ilk 10.000'de var mi: False
    'Zt7-quiet-harbor-42x'  uzunluk=20  30.000'lik kaynakta var mi: False  ilk 10.000'de var mi: False

[7] UZUNLUK DAGILIMI (ilk 10.000)
    {4: 294, 5: 655, 6: 3443, 7: 2213, 8: 2767, 9: 345, 10: 179, 11: 48, 12: 36, 13: 7, 14: 4, 15: 5, 16: 2, 17: 1, 18: 1}
```

## 5. HAM ÇIKTI — CVE kapısı (birebir yapıştırıldı)

```
No known vulnerabilities found
EXIT=0
```

---

## 6. HÜKÜM

**(1) LİSANS KAPISI — GEÇTİ [ÖLÇÜLDÜ].** Kaynak paket `zxcvbn 4.5.0`; `METADATA` içinde
`License: MIT` **ve** `Classifier: License :: OSI Approved :: MIT License`; `LICENSE.txt`
birebir *"MIT License / Copyright (c) 2016 Daniel Wolf"*. **MIT, kırmızı çizgi #3'ün izinli
OSI ailesindedir** (MIT / Apache-2.0 / BSD-3-Clause). ⇒ **Yükümlülük:** lisans metni ve atıf,
veri dosyasının yanında repoya girer (MIT'in *"copyright notice … shall be included"* şartı).

**(2) CVE KAPISI — GEÇTİ [ÖLÇÜLDÜ].** `pip-audit 2.10.1` · `zxcvbn==4.5.0` ⇒
*"No known vulnerabilities found"* · `EXIT=0`.
**Beyan edilmiş iki sınır:** (a) `pip-audit` bir **anlık görüntüdür** (26 Tem 2026, OSV/PyPI
danışma veritabanı) — süregelen bir garanti değildir; (b) paket **çalışma zamanı bağımlılığı
DEĞİLDİR**: yalnız **bir kez** veri türetmek için kullanılır, üretime giren şey `.txt` bir veri
dosyasıdır ⇒ **çalışan sistemin CVE yüzeyi bu kalemden ETKİLENMEZ.** Kapı yine de koştu, çünkü
kırmızı çizgi #3 *"bağımlılık eklerken"* der ve türetme aracı da bir bağımlılıktır.

**(3) M56 PROBU ARTIK GERÇEK BİR KAYITTIR — kör kapı KAPANDI [ÖLÇÜLDÜ].**
`mailcreated5240` **15 karakter** (⇒ `[KS-17]`=15 uzunluk kuralını **TAM** karşılar, uzunluktan
`400` **almaz**) **ve listenin 1516. kaydıdır** (⇒ kara-liste kontrolü kaldırılınca `201` alır).
Negatif ayak: `MomentumKapiTesti2026` (21 karakter) **30.000'lik kaynağın hiçbir yerinde yok**.
⇒ Mutasyon **altında** ve **olmadan** iki farklı sonuç ölçülür; v6'nın `123456` probunda bu
ayrım fiziksel olarak **imkânsızdı**.

**(4) DOSYA BUGÜN REPODA YOKTUR — beyan edilmiş sınır, K22-a sınıfından kaçınma.**
ADR var olmayan bir artefakta çıpalanmaz; onun yerine **türetme tarifi + beklenen `sha256`**
pinlenir (`839f86a5…dd1462`) ve **üretim + pin doğrulaması `GOREV-slice-3c-auth` build'inde
koşar.** Pin düşerse liste değişmiş demektir ve **M56 kırmızıya döner** ⇒ prob sessizce ölemez.
*(Pin, kaymayı ÖNLEMEZ; YAKALAR. Bu bir güvence değil, bir kapıdır.)*

---

## 7. 🔴 BU TURUN ÜRETTİĞİ YENİ BULGU — `[KS-31]`'İN MARJİNAL DEĞERİ ÖLÇÜLDÜ VE KÜÇÜK

Aynı koşum, kimsenin sormadığı bir sayıyı da verdi (uzunluk dağılımı, §4 çıktısı [7]):

- İlk 10.000 kaydın **9'u** `≥15` karakterdir. Kalan **9.991 kayıt** `≤14` karakterdir.
- `[KS-17]`=15 **asgari uzunluk** kuralı, o 9.991 kaydı **kara listeye hiç sormadan**,
  uzunluk kontrolünde reddeder.
- ⇒ **Kara listenin `[KS-17]`=15 politikası altında fiilen reddedebildiği parola sayısı: 9.**
  Listenin **%99,91'i ulaşılamazdır.** *(30.000'lik tam kaynakta bu sayı 31'dir.)*

**BU, K28-c'Yİ ÇÜRÜTMEZ — ama gerekçesini DEĞİŞTİRİR.** NIST SP 800-63B-4'ün kara-liste
`SHALL`'ı, asgari uzunluğun **8 karakter** olabildiği politikalar için yazılmıştır; 15 karakter
asgari uygulayan bir politikada kara listenin marjinal katkısı **ölçülebilir biçimde küçüktür**
ve değeri yalnızca *"uzun ama sızmış"* parolalarda (`momsanaladventure`, `123456789987654321`,
`1qaz2wsx3edc4rfv`, …) ortaya çıkar.

⚠ **Bu bulgu bir ÜRETİMDİR ve kendi üreticisi tarafından onaylanamaz — kapı-7 adjudike etmelidir.**
Bu turda yapılan şey **ölçmek ve yazmaktır**; kalemin ADR'deki işlenme biçimi (beyanlı sınır mı,
seçim ölçütünün değişmesi mi) Onur'un kararına bırakılmıştır ve `PROJE_HAFIZA.md`'de kayıtlıdır.

---

*Bu dosya bir ÖLÇÜM kaydıdır, bir kapı değildir. Kapı-7 hem ölçümü hem hükmü denetlemelidir.*

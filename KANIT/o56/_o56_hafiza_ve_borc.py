# -*- coding: utf-8 -*-
"""Oturum 56 -- K135 checkpoint'ini PROJE_HAFIZA.md'ye EKLER ve BORCLAR.md'den
KAPANMIS uc kalemi ARSIVE TASIR (K73/K83 doktrini: kapanan borc listede degil
arsivde yasar). ORTAM.md: os.replace WinError 5 verebilir => UC ADIMLI YEDEKLI
TAKAS. K60: once encode, sonra .tmp, en son takas."""
import hashlib, io, os, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
BORC = os.path.join(KOK, "BORCLAR.md")
HAFIZA = os.path.join(KOK, "PROJE_HAFIZA.md")

# (anahtar satir baslangici, kac satir) -- ANCHOR DOGRULANIR, korukorune kesilmez
KESILECEK = [
    ("- 🟢 **KAPANDI — `spec-kapi-kapsama.py`'nin KURAL YARISI ARTIK ÇALIŞIYOR", 4),
    ("- 🟢 **`A13` §9/5 KAPANDI**", 3),
    ("- 🟢 **`A13` §9/10 KAPANDI**", 1),
]
REFERANS = ("- 🟢 **KAPANMIŞ ÜÇ KALEM ARŞİVE TAŞINDI [oturum 56, `K135`]:** `spec-kapi-kapsama.py` "
            "kural yarısı (`K124`) · `A13` §9/5 · `A13` §9/10. Tam metinleri `PROJE_HAFIZA.md` "
            "`K135`'te; burada **yer kaplamaları** tavanı borç KAPANMADIĞI hâlde daraltıyordu.")


def atomik_yaz(yol, metin):
    ham = metin.encode("utf-8")
    tmp, yedek = yol + ".tmp", yol + ".yedek"
    with open(tmp, "wb") as f:
        f.write(ham)
    if os.path.exists(yedek):
        os.remove(yedek)
    os.rename(yol, yedek)
    try:
        os.rename(tmp, yol)
    except Exception:
        os.rename(yedek, yol)
        raise
    yeni = open(yol, "rb").read()
    if hashlib.sha256(yeni).digest() != hashlib.sha256(ham).digest():
        os.remove(yol)
        os.rename(yedek, yol)
        raise SystemExit("[KIRMIZI] SHA TUTMADI -- yedek geri alindi.")
    os.remove(yedek)
    return len(ham)


borc = io.open(BORC, encoding="utf-8").read()
borc_once = len(borc.encode("utf-8"))
satirlar = borc.split("\n")
arsiv = []
for anahtar, adet in KESILECEK:
    idx = [i for i, s in enumerate(satirlar) if s is not None and s.startswith(anahtar)]
    if len(idx) != 1:
        raise SystemExit("[KIRMIZI] ANCHOR TEK DEGIL (%d): %s" % (len(idx), anahtar[:60]))
    i = idx[0]
    arsiv.append("\n".join(satirlar[i:i + adet]))
    satirlar[i:i + adet] = [None] * adet
satirlar = [s for s in satirlar if s is not None]

# referans satirini, kesilen ILK blogun yerine degil, listenin SONUNA degil,
# 'OTURUM 53' basliginin hemen ONUNE koymak yerine: en sondaki bos olmayan
# satirdan sonra ekle -- yer degil VARLIK onemli, ve arama kolay olsun.
satirlar.append("")
satirlar.append(REFERANS)
yeni_borc = "\n".join(satirlar)
# 🔴 SIRA PAZARLIKSIZ: ONCE arsive YAZ, SONRA listeden KES. Ters sirada bir
# hata metni tamamen yok ederdi (K60'in kardesi: yarim kalan is veri kaybidir).

K135 = """

## K135 — `ss2-kapisi.py`'NİN BLOK YORUM KÖR KAPISI ÖLÇÜLDÜ ve ONARILDI (Onur kilitledi, 4 Ağu 2026, oturum 56)

**Nasıl doğdu.** Oturum 55 iki MINOR'u kapatmadan devretti; ikincisi *"`ss2-kapisi.py` `G33/c`'de
yorum-atlama ÖLÇÜLMEMİŞ (`G31/a`'da `M171b`/`M171c` var, `G33/c`'de yok)"* diyordu. Cowork bunu
kapatmak için önce **ölçtü** (`KANIT/o56/_g33c_yorum_olcumu.py` → `14-g33c-yorum-olcumu.txt`):

| vaka | beklenen | ölçülen | hüküm |
|---|---|---|---|
| A `distinct: true` satırı `//` ile yoruma çevrilir | `G33c` | `G33c` | 🟢 |
| B kod bozulmaz, `//` yorumunda `distinct`'siz `.count(` | sus | sus | 🟢 |
| C `/* ... */` **blok** yorumunda `distinct`'siz `.count(` | sus | **`G33c`** | 🔴 yanlış-pozitif |
| D gerçek kod `=> 4`, doğru değer **blok yorumda** | `G31a` | **sustu** | 🔴 **KÖR KAPI** |

**Ölçülmüş ders.** MINOR'un kendisi **davranışsal olarak temizdi** (A ve B geçti) — eksik olan
**davranış değil PİN**di. Ama pini koymak için yazılan ölçüm, MINOR'un **adını koymadığı** iki
kusuru açığa çıkardı. `_yorumsuz_satirlar` yalnız `//` kesiyordu; `/* */` hiç kesilmiyordu ⇒ araç
yorumdaki `schemaVersion => 5`'i **kod sanıp yeşil dönüyordu**. `M171b` tam bu kusuru yakalamak
için yazılmıştı ve **blok yolundan kaçıyordu**. 🔴 **Bir kapının bir yolu ölçülüyorsa, o kapının
DİĞER yolu ölçülmüş sayılmaz.**

**Karar (Onur, dört şık sunuldu):** ONAR + PİNLE. Beyan edip borçlandırmak reddedildi: `K53/3`
sınıflamasında **kör kapı borçlanamaz** — oturum 55'in kendi emsali (üç kör kapı bloker sayıldı).

**Onarım.** `_blok_yorumsuz()`: metnin tamamında durum makinesi; tırnak literallerine saygılı,
`//` yorumunun **içine bakmaz** (oradaki `/*` blok açmaz), blok yorumu **boşluğa çevirir ve satır
sayısını korur** (`g33c_distinct`'in satır numarası hesabı buna dayanır), kapanmayan blok dosya
sonuna kadar yorum sayılır. Altın küme **10 → 14**: 11–12 MINOR'un pini, 13–14 blok yolu.

**Kanıt (üreten ≠ denetleyen, K26/K34-f: aracı Claude Code yazdı, onaran/pinleyen el Cowork).**
`M-o56-1` (`KANIT/o56/_mutant_o56.py` → `17-mutant-o56-onarim-yuku.txt`): onarım devre dışı
bırakılınca **yalnız 13 ve 14 düştü** (12/14, EXIT 1), geri alma **bayt-özdeş** (`AC744C65`).
Yani onarım **eşdeğer mutant değil, yük taşıyor**. `git restore` **kullanılmadı** (ORTAM.md:
`core.autocrlf` onu bayt-özdeşlik için kör kılar) — ikili yedek + bayt yaması + sha.

**Yan ölçüm — ENVANTER BAYATTI.** `DURUM.md` §6 *"27 dosya / 21 çalıştırılabilir / tablo 21 satır"*
diyordu; ölçüm **29 dosya / 23 çalıştırılabilir** verdi. `ss2-kapisi.py` (oturum 55) ve
`ci-kapisi.py` (oturum 53) tabloya **hiç girmemişti** ⇒ **iki kapı envantersiz koşuyordu**.
Tablo ve envanter cümlesi düzeltildi; `ci-kapisi.py`'nin altın kümesi **13/13** ölçüldü.

**Yan ölçüm — TAZELİK KAPISI.** Oturum 55'in yazdığı `DURUM.md:78` iki *"altın küme N/M"* iddiasını
**araç adı olmadan** taşıyordu ⇒ `sayi-tazeligi.py` iki `[SARI] T5 BAGLANAMADI` verdi. Satır
bölündü ve `10/10` iddiası `ss2-kapisi.py` adına **mekanik olarak bağlandı**; kapı artık o sayıyı
**aracı koşarak** doğruluyor ve `14/14` ile eşleşti. Hüküm **TEMİZ**.

🔴 **Cowork'ün bu oturumdaki kendi ölçüm kusuru:** `sayi-tazeligi.py` ilk koşumda `findstr`'a boru
ile bağlandı ⇒ `!ERRORLEVEL!` **findstr'ın** kodunu ölçtü ve **sahte `EXIT=0`** verdi; borusuz
ölçümde gerçek kod **1** çıktı. `%ERRORLEVEL%` mayınının (oturum 33) **boru hattındaki kardeşi**.

**Kalan beyan edilmiş sınır.** `ss2-kapisi.py` bir Dart ayrıştırıcısı **değildir**: üç tırnaklı
(`'''`/`\\"\\"\\"`) literaller ve ham/kaçışlı dizeler tam ayrıştırılmaz.

### K135-EK — KAPANMIŞ ÜÇ BORÇ KALEMİ (BORCLAR.md'den buraya taşındı)

`BORCLAR.md` tavanı `T2` SARI verdi (pay 857 b) ve `K117`/`K126`'nın dersi *"budama ancak bir borç
KAPANDIĞINDA işe yarar"*dı. Ölçüm: **kapanmış üç kalem** listede yer kaplıyordu. Tam metinleri:

"""


hafiza = io.open(HAFIZA, encoding="utf-8").read()
hafiza_once = len(hafiza.encode("utf-8"))
ek = K135 + "\n\n".join(arsiv) + "\n"
hafiza_sonra = atomik_yaz(HAFIZA, hafiza + ek)
print("PROJE_HAFIZA.md : %d b -> %d b  (fark %+d)" % (hafiza_once, hafiza_sonra, hafiza_sonra - hafiza_once))
print("ARSIVLENEN BLOK : %d" % len(arsiv))

# arsiv GUVENDE => simdi listeden kes
borc_sonra = atomik_yaz(BORC, yeni_borc)
print("BORCLAR.md      : %d b -> %d b  (fark %+d)" % (borc_once, borc_sonra, borc_sonra - borc_once))

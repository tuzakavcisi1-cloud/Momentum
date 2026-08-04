# -*- coding: utf-8 -*-
"""Oturum 56 -- DURUM.md §5 BUDAMASI + B-SS2-5 borcu.
SIRA PAZARLIKSIZ: (1) arsive yaz (2) DURUM.md'yi buda (3) BORCLAR.md'ye borcu ekle.
Ucu de UC ADIMLI YEDEKLI TAKAS ile (ORTAM.md: os.replace WinError 5)."""
import hashlib, io, os, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DURUM = os.path.join(KOK, "DURUM.md")
BORC = os.path.join(KOK, "BORCLAR.md")
HAFIZA = os.path.join(KOK, "PROJE_HAFIZA.md")

ANCHORLAR = ["- **K77 · K78 · K79 · K81", "- **K76 · K75 · K74 · K71**", "- **K116 · K120 —"]

YENI_SATIR = (
    "- 🔒 **K71–K81 · K116–K120 — slice-3e · `R9`/`R10` · `A11` KABUL EDİLDİ; anlatım oturum 56'da "
    "arşive taşındı (`K135-EK2`).** Kurallar prozada değil **kapıda** koşuyor (K73). 🔴 **BAŞKA "
    "HİÇBİR CANLI BELGEDE İZİ OLMAYAN ALTI BEYAN BURADA KALIR** (ölçüldü: "
    "`KANIT/o56/25-beyan-izi.txt`): ① `CursorHint` **yoksayılır** (`D6`) ② `Y3`'ün mutantı **YOK** "
    "③ `G12` kriter 8 **UYGULANMAZ** ④ `D2` kural 3'ün `K != 'yerel'` istisnası ⑤ `R9` öncesi inmiş "
    "satırlar **`'yerel'` KALIR** (migration yasak) ⑥ `GOREV-slice-3d-cekme.md`'deki `D0` metni "
    "**bilerek bayat** (K70; kanonik metin `GOREV-A11` §3). 🟢 Kalan **yedi** beyan "
    "`BORCLAR.md`'de yaşıyor; buraya **kopyalanmaz** (`kanonik-kopya`)."
)

B_SS2_5 = (
    "\n- 🟡 **`B-SS2-5` — `M172`'NİN *\"BEKLENEN\"* METNİ GERÇEĞİ TARİF ETMİYOR [oturum 56'da ölçüldü, "
    "Onur borçlandırdı].** Kilitli spec (`K133`, `420E9F91`) satır 382 *\"`G32/a` KIRMIZI — kaybeden "
    "değer kazananla bayt-özdeş olur\"* diyor; **ölçülen gerçek**: `G32/a`·`G32/e`·`G32/e2`·`G32/g`·"
    "`G32/h` **beşi birden** düşüyor, çünkü şart 4 hep eşitlik verip çakışma kaydını **tamamen "
    "bastırıyor** (`KANIT/SS2/T7/23-mutant-kaydi.md`). 🔴 Spec kendi geleneğinde `M183` ve `M187` "
    "için kollateralı **açıkça yazıyor**, `M172`'de yazmamış ⇒ sınıf **beyansız-sınır**. 🟢 Çekirdek "
    "sözleşme **ayakta**: spec satır 372 *\"her mutant hedeflediği ayağı adıyla düşürür\"* diyor ve "
    "`M172` `G32/a`'yı **adıyla** düşürdü — bu yüzden kilit **açılmadı**. Kapanışı: spec bir sonraki "
    "meşru sebeple açıldığında satır 382'ye kollateral yazılır."
)

K135_EK2 = """

### K135-EK2 — `DURUM.md` §5'İN ÜÇ "KABUL EDİLDİ" SATIRI ARŞİVE TAŞINDI (oturum 56)

**Neden.** `belge-tavan-kapisi.py` `DURUM.md` için `T2` SARI verdi (pay **1.279 b**, eşik 1.638) ⇒
`SS2` kabul hükmü yazıldığı an **KIRMIZI** olacaktı. Ölçüm (`KANIT/o56/24-durum-bolum-olcumu.txt`):
§5 **8.571 b** ile en ağır bölüm; içindeki üç satır (**625 + 478 + 699 = 1.802 b**) `K73` gereği
**zaten çekilmiş** kilitlerin *anlatımıydı* — kural bugün prozada değil **kapıda** koşuyor.

🔴 **Taşımadan ÖNCE ölçüldü:** bu üç satırın **13 yaşayan beyanından 6'sının başka hiçbir canlı
belgede izi YOKTU** (`KANIT/o56/_beyan_izi.py` → `25-beyan-izi.txt`). Körü körüne taşımak o altısını
**gizlerdi** — `§4`'ün *"gizlenmiş sınır kabul edilmez"* maddesinin ihlali. Bu yüzden altısı
`DURUM.md` §5'te **tek satırda korundu**, kalan yedisi `BORCLAR.md`'de zaten yaşadığı için
**kopyalanmadı** (`kanonik-kopya`). Ders: **budama bir taşıma değil, ÖNCE bir ölçümdür.**

**Arşivlenen üç satır (tam metin):**

"""


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
    if hashlib.sha256(open(yol, "rb").read()).digest() != hashlib.sha256(ham).digest():
        os.remove(yol)
        os.rename(yedek, yol)
        raise SystemExit("[KIRMIZI] SHA TUTMADI -- yedek geri alindi.")
    os.remove(yedek)
    return len(ham)


durum = io.open(DURUM, encoding="utf-8").read()
durum_once = len(durum.encode("utf-8"))
satirlar = durum.split("\n")
kesilen = []
yer = None
for a in ANCHORLAR:
    idx = [i for i, s in enumerate(satirlar) if s is not None and s.startswith(a)]
    if len(idx) != 1:
        raise SystemExit("[KIRMIZI] ANCHOR TEK DEGIL (%d): %s" % (len(idx), a))
    i = idx[0]
    yer = i if yer is None else min(yer, i)
    kesilen.append(satirlar[i])
    satirlar[i] = None
satirlar[yer] = YENI_SATIR
satirlar = [s for s in satirlar if s is not None]
yeni_durum = "\n".join(satirlar)

hafiza = io.open(HAFIZA, encoding="utf-8").read()
h_once = len(hafiza.encode("utf-8"))
h_sonra = atomik_yaz(HAFIZA, hafiza + K135_EK2 + "\n\n".join(kesilen) + "\n")
print("PROJE_HAFIZA.md : %d b -> %d b (%+d)" % (h_once, h_sonra, h_sonra - h_once))

d_sonra = atomik_yaz(DURUM, yeni_durum)
print("DURUM.md        : %d b -> %d b (%+d)  pay %d b" % (durum_once, d_sonra, d_sonra - durum_once,
                                                          32768 - d_sonra))

borc = io.open(BORC, encoding="utf-8").read()
b_once = len(borc.encode("utf-8"))
b_sonra = atomik_yaz(BORC, borc + B_SS2_5 + "\n")
print("BORCLAR.md      : %d b -> %d b (%+d)  pay %d b" % (b_once, b_sonra, b_sonra - b_once,
                                                          32768 - b_sonra))
print("ARSIVLENEN SATIR: %d" % len(kesilen))

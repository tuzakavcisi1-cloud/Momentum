# -*- coding: utf-8 -*-
"""kapi-ad-teklik-kapisi.py 1.0.0 -- K108'in mekanik kapisi.

K108 (Onur kilitledi, 2 Agu 2026): KAPI KIMLIGI SPEC-YERELDIR.
Bir kapiya atif DAIMA kapsam onekiyle yapilir  ->  A10/G18, A9c/G18, slice-3d/G5.

Neden olculdu: A9b/G17 = 'iddia-kapisi.py 1.2.0 altin kume' iken
A10/G17 = 'release derlemesi INTERNET iznini tasir'; A10/G18 = 'cleartext yalniz
debug' iken A9c/G18 = 'iddia-kapisi.py 1.3.0 D8'. Iki farkli kapi, ayni ad.
Ayrica G1-G8 zaten dilim-yereldi (G1 = 3b'de MCP, 3c'de dev-kimlik, 3d'de
yalniz-cekme), yani 'kuresel dizi' varsayimi hic dogru olmamisti.

AYAKLAR
  N1 [KIRMIZI] Canli belgede KAPSAM ONEKSIZ 'G<n>' atfi var VE o kimlik BELIRSIZ
               (birden fazla spec'te ilan edilmis ve hicbirinde (GENISLETME)
               etiketi yok)  =>  atif BELIRSIZ.  Aralik yazimi ('G17-G21',
               '**`G1`-`G16`**') acilir, her kimlik ayri olculur.
               🔴 Etiketli paylasimda N1 SUSAR: A8/G16 ile A9/G16 (GENISLETME)
               AYNI kapidir; ilk surumde bu ayrim yoktu ve kapi yanlis-pozitif
               verdi -- altin kume vakasi 15 o kor noktanin regresyonudur.
  N2 [KIRMIZI] Ayni spec icinde ayni 'G<n>' iki kez BASLIK olarak ilan edilmis.
               Spec-yerel kimlik kendi icinde TEKIL olmak zorundadir.
  N3 [BILGI]   Bir kimlik >1 spec'te ilan edilmis ve hicbirinde (GENISLETME)
               etiketi yok  =>  o kimlige atif ZORUNLU olarak oneklidir.
               Bu N1'in SEBEBIDIR, kusur degildir (K108 boyle bir paylasimi
               MESRU sayar); listelenir ki N1 bulgusu gerekcesiyle okunsun.

CIKIS: 0 TEMIZ · 2 KIRMIZI · 3 KULLANIM/ORTAM · 4 OLCULEMEDI
Bu betik hicbir dosyaya YAZMAZ (K60 yazim kurali uygulanmaz); altin kume
yalniz gecici dizinde calisir.
"""
import re
import sys
import tempfile
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

SURUM = "1.0.0"
SPEC_DIZINI = "GOREV_CLAUDE_CODE"

# Canli belgeler: K108 burada zorlanir. DURUM.md ZORUNLUDUR -- yoksa olculemez.
HEDEF_BELGELER = ["DURUM.md", "CLAUDE.md", "BORCLAR.md", "KAPILAR.md", "DESIGN.md"]
ZORUNLU_BELGE = "DURUM.md"

# KAPSAM DISI ve GEREKCESI (susturma degil, olculmus sinir):
#   PROJE_HAFIZA.md : APPEND-ONLY arsiv (K58) -- gecmis kayit DUZELTILEMEZ.
#                     Kapsama alinirsa kapi kalici KIRMIZI yanar ve
#                     susturulamaz; yani hukmu tasimaz hale gelir.
#   KANIT/**        : donmus kanit, yazildigi andaki metni tasir.
#   docs/ADR/**     : ADR 0003 DONDURULDU (K41), tek bayt yazilmaz.

BASLIK = re.compile(r"^#{2,4}\s*(?:KAPI\s*)?(G\d+)\b")
ATIF = re.compile(r"G(\d+)")
ARALIK = re.compile(r"[\s`*_]*[-–—][\s`*_]*G(\d+)\b")
ONEK_SOL = re.compile(r"[A-Za-z0-9_.\-]")
SOZCUK = re.compile(r"[A-Za-z0-9_]")
# Yol parcasi ayirt etme [oturum 47'de olculdu]: 'KANIT/slice-3c/02-G2/' ve
# 'GOREV-slice-3e-G12.md' birer DIZIN/DOSYA adidir, kapi atfi DEGILDIR.
# Ayrim: eslesmeden ONCE ayni belirtecte '/' ya da '\' varsa YOL'dur; ama
# 'A10/G18' onektir ve o zaten onekli sayilir. 'G18/b' ise gercek AYAK atfidir
# (oncesinde ayirac yok) ve N1 kapsamindadir.
AYIRAC = set(" \t`*|,;()[]{}\"'<>")
YOL_UZANTI = re.compile(r"\.(md|txt|py|dart|json|jsonl|cmd|ps1|yaml|yml|lock|xml|cs|kt)$", re.I)


def belirtec_al(satir, i):
    """i konumunu iceren belirteci ve eslesmenin belirtec icindeki konumunu verir."""
    b = i
    while b > 0 and satir[b - 1] not in AYIRAC:
        b -= 1
    s = i
    while s < len(satir) and satir[s] not in AYIRAC:
        s += 1
    return satir[b:s], i - b

_TR = {"ı": "i", "İ": "I", "ş": "s", "Ş": "S",
       "ğ": "g", "Ğ": "G", "ü": "u", "Ü": "U",
       "ö": "o", "Ö": "O", "ç": "c", "Ç": "C"}


def sadelestir(s):
    """Turkce diyakritikleri duserek ASCII karsilastirmaya hazirlar."""
    return "".join(_TR.get(ch, ch) for ch in s)


def genisletme_mi(baslik):
    return "GENISLETME" in sadelestir(baslik).upper()


# ----------------------------------------------------------------------------
# SAF CEKIRDEK -- dosya sistemi bilmez, altin kume bunlari dogrudan olcer
# ----------------------------------------------------------------------------
def ilanlari_ayikla(metin):
    """Bir spec metninden BASLIK olarak ilan edilen kapi kimliklerini dondurur.
    kimlik -> [baslik satiri, ...]   (ayni kimlik birden fazlaysa N2 adayidir)"""
    ilan = {}
    for satir in metin.splitlines():
        m = BASLIK.match(satir)
        if m:
            ilan.setdefault(m.group(1), []).append(satir.strip())
    return ilan


def atiflari_ayikla(metin):
    """Belge metnindeki kapi atiflarini dondurur.
    [(kimlik, satir_no, onekli, satir_metni), ...] -- aralik yazimi ACILIR."""
    sonuc = []
    for no, satir in enumerate(metin.splitlines(), 1):
        for m in ATIF.finditer(satir):
            i = m.start()
            if i >= 1 and SOZCUK.match(satir[i - 1]):
                continue  # 'XG18' bir kimlik degildir
            onekli = bool(i >= 2 and satir[i - 1] == "/"
                          and ONEK_SOL.match(satir[i - 2]))
            tok, konum = belirtec_al(satir, i)
            if not onekli and ("/" in tok[:konum] or "\\" in tok[:konum]):
                continue  # yol parcasi: 'KANIT/slice-3c/02-G2/'
            if YOL_UZANTI.search(tok):
                continue  # dosya adi: 'GOREV-slice-3e-G12.md'
            bas = int(m.group(1))
            uc = bas
            am = ARALIK.match(satir[m.end():])
            if am:
                son = int(am.group(1))
                if bas < son <= bas + 64:
                    uc = son
            for n in range(bas, uc + 1):
                sonuc.append(("G%d" % n, no, onekli, satir.strip()))
    return sonuc


def denetle(kok):
    """Gercek agaci olcer. (bulgular, hukum, cikis) dondurur.
    bulgular: [(kod, siddet, mesaj), ...]"""
    kok = Path(kok)
    bulgular = []
    spec_dizin = kok / SPEC_DIZINI
    if not spec_dizin.is_dir():
        bulgular.append(("B1", "OLCULEMEDI",
                         "%s dizini YOK -- ilan kaynagi okunamadi. "
                         "Bu 'TEMIZ' DEGILDIR." % SPEC_DIZINI))
        return bulgular, "OLCULEMEDI", 4

    ilan = {}          # kimlik -> [(spec_adi, baslik), ...]
    for p in sorted(spec_dizin.glob("*.md")):
        yerel = ilanlari_ayikla(p.read_text(encoding="utf-8", errors="replace"))
        for k, basliklar in yerel.items():
            for b in basliklar:
                ilan.setdefault(k, []).append((p.name, b))
            if len(basliklar) > 1:
                bulgular.append(("N2", "KIRMIZI",
                                 "%s: '%s' AYNI spec icinde %d kez BASLIK olarak "
                                 "ilan edilmis -- spec-yerel kimlik kendi icinde "
                                 "TEKIL olmak zorunda." % (p.name, k, len(basliklar))))

    # BELIRSIZ = birden fazla spec'te ilan edilmis VE hicbirinde (GENISLETME)
    # etiketi YOK. Etiket varsa iki ilan AYNI kapiyi genisletiyor demektir ve
    # ciplak atif belirsiz DEGILDIR -- N1 o kimlik icin susar.
    belirsiz = {}      # kimlik -> [spec adlari]
    for k, kayitlar in ilan.items():
        adlar = sorted({ad for ad, _ in kayitlar})
        if len(adlar) > 1 and not any(genisletme_mi(b) for _, b in kayitlar):
            belirsiz[k] = adlar
            bulgular.append(("N3", "BILGI",
                             "'%s' %d spec'te ilan edilmis ve hicbirinde "
                             "(GENISLETME) etiketi yok (%s) => bu kimlige atif "
                             "ZORUNLU olarak oneklidir." % (k, len(adlar), ", ".join(adlar))))

    if not (kok / ZORUNLU_BELGE).exists():
        bulgular.append(("B0", "OLCULEMEDI",
                         "%s YOK -- canli belge tarafi olculemedi. "
                         "Bu 'TEMIZ' DEGILDIR." % ZORUNLU_BELGE))
        return bulgular, "OLCULEMEDI", 4

    gorulen = set()
    for ad in HEDEF_BELGELER:
        p = kok / ad
        if not p.exists():
            bulgular.append(("B0", "BILGI",
                             "%s bulunamadi -- bu belge olculmedi." % ad))
            continue
        for kimlik, no, onekli, satir in atiflari_ayikla(
                p.read_text(encoding="utf-8", errors="replace")):
            if onekli or kimlik not in belirsiz:
                continue
            anahtar = (ad, no, kimlik)
            if anahtar in gorulen:
                continue
            gorulen.add(anahtar)
            bulgular.append(("N1", "KIRMIZI",
                             "%s:%d '%s' KAPSAM ONEKSIZ gecti; bu kimlik %d spec'te "
                             "ilan edilmis (%s) => atif BELIRSIZ. Dogrusu: <spec>/%s. "
                             "[satir: %s]" % (ad, no, kimlik, len(belirsiz[kimlik]),
                                              ", ".join(belirsiz[kimlik]), kimlik,
                                              satir[:90])))

    kirmizi = [b for b in bulgular if b[1] == "KIRMIZI"]
    olculemedi = [b for b in bulgular if b[1] == "OLCULEMEDI"]
    if kirmizi:
        return bulgular, "KIRMIZI", 2
    if olculemedi:
        return bulgular, "OLCULEMEDI", 4
    return bulgular, "YESIL", 0


# ----------------------------------------------------------------------------
# ALTIN KUME -- kapinin KENDI kaniti: temizde susmali, kirlide isirmali
# ----------------------------------------------------------------------------
def _kur(kok, specler, belgeler):
    if specler is not None:
        (kok / SPEC_DIZINI).mkdir(parents=True, exist_ok=True)
        for ad, ic in specler.items():
            (kok / SPEC_DIZINI / ad).write_text(ic, encoding="utf-8")
    for ad, ic in belgeler.items():
        (kok / ad).write_text(ic, encoding="utf-8")


IKI_SPEC = {"S-a.md": "### G18 — cleartext yalniz debug\n",
            "S-b.md": "### G18 — D8 kapisi\n"}


def _vakalar():
    return [
        ("TEMIZ PROJE -- yanlis-pozitif kontrolu",
         {"S-a.md": "### G9 — tek kapi\n"}, {"DURUM.md": "kapi S-a/G9 yesil\n"},
         [], ["N1", "N2", "N3"], "YESIL"),
        ("N1 -- iki spec ayni kimlik + CIPLAK atif ISIRMALI",
         IKI_SPEC, {"DURUM.md": "G18 yesil\n"}, ["N1"], [], "KIRMIZI"),
        ("N1 YANLIS-POZITIF -- atif ONEKLI ise SUSMALI",
         IKI_SPEC, {"DURUM.md": "S-a/G18 yesil\n"}, [], ["N1"], "YESIL"),
        ("N1 -- kimlik TEK spec'te ilan edilmisse ciplak atif MESRU",
         {"S-a.md": "### G9 — x\n"}, {"DURUM.md": "G9 yesil\n"}, [], ["N1"], "YESIL"),
        ("N1 -- ARALIK yazimi ACILMALI ('G17-G21')",
         IKI_SPEC, {"DURUM.md": "Kapilar G17-G21 kosuyor\n"}, ["N1"], [], "KIRMIZI"),
        ("N1 ARALIK YANLIS-POZITIF -- aralik icindekiler tek ilanliysa SUSMALI",
         {"S-a.md": "### G1 — a\n### G2 — b\n### G3 — c\n"},
         {"DURUM.md": "Kapilar G1-G3 kosuyor\n"}, [], ["N1"], "YESIL"),
        ("N1 -- backtick+kalin+en-dash aralik bicimi de ACILMALI",
         IKI_SPEC, {"DURUM.md": "Kapilar **`G17`–`G21`** kosuyor\n"}, ["N1"], [], "KIRMIZI"),
        ("N2 -- ayni spec icinde ayni kimlik IKI KEZ baslik ISIRMALI",
         {"S-a.md": "### G5 — birinci\n### G5 — ikinci\n"},
         {"DURUM.md": "bos\n"}, ["N2"], [], "KIRMIZI"),
        ("N2 YANLIS-POZITIF -- govdede cok gecen ayak adlari SUSMALI",
         {"S-a.md": "### G5 — tek baslik\n\n| `G5/a` | x |\n| `G5/b` | y |\nG5 metinde tekrar gecer\n"},
         {"DURUM.md": "S-a/G5\n"}, [], ["N2"], "YESIL"),
        ("N3 -- etiketsiz paylasim BILDIRILMELI (kusur degil, N1'in SEBEBI)",
         IKI_SPEC, {"DURUM.md": "S-a/G18\n"}, ["N3"], [], "YESIL"),
        ("N3 YANLIS-POZITIF -- (GENISLETME) etiketi varsa SUSMALI",
         {"S-a.md": "### G16 — metin kaybi kapisi\n",
          "S-b.md": "### G16 — (GENİŞLETME) metin kaybi izgarasi\n"},
         {"DURUM.md": "S-a/G16\n"}, [], ["N3"], "YESIL"),
        ("KAPSAM DISI -- PROJE_HAFIZA.md'deki ciplak atif SUSMALI (append-only)",
         IKI_SPEC, {"DURUM.md": "S-a/G18\n",
                    "PROJE_HAFIZA.md": "G18 yesil diye yazilmis ESKI kayit\n"},
         [], ["N1"], "YESIL"),
        ("N1 KOR NOKTASI [oturum 47'de olculdu] -- (GENISLETME) etiketli "
         "paylasimda CIPLAK atif MESRUDUR, N1 SUSMALI",
         {"S-a.md": "### G16 — metin kaybi kapisi\n",
          "S-b.md": "### G16 — (GENİŞLETME) metin kaybi izgarasi\n"},
         {"DURUM.md": "G16 yesil\n"}, [], ["N1", "N3"], "YESIL"),
        ("YOL PARCASI YANLIS-POZITIFI [oturum 47'de olculdu] -- "
         "'KANIT/slice-3c/02-G18/' bir DIZIN adidir, kapi atfi DEGIL => N1 SUSMALI",
         IKI_SPEC, {"DURUM.md": "kanit `KANIT/slice-3c/02-G18/` altinda\n"},
         [], ["N1"], "YESIL"),
        ("YOL PARCASI SUSTURMA KONTROLU -- 'G18/b' bir AYAK atfidir => N1 ISIRMALI",
         IKI_SPEC, {"DURUM.md": "ayak `G18/b` yesil\n"}, ["N1"], [], "KIRMIZI"),
        ("DOSYA ADI YANLIS-POZITIFI -- 'GOREV-slice-3e-G18.md' => N1 SUSMALI",
         IKI_SPEC, {"DURUM.md": "spec `GOREV-slice-3e-G18.md` kilitli\n"},
         [], ["N1"], "YESIL"),
        ("ZORUNLU BELGE YOK -- 'OLCULEMEDI' demeli, TEMIZ DEMEMELI",
         {"S-a.md": "### G9 — x\n"}, {}, ["B0"], ["N1"], "OLCULEMEDI"),
        ("SPEC DIZINI YOK -- 'OLCULEMEDI' demeli, TEMIZ DEMEMELI",
         None, {"DURUM.md": "G18 yesil\n"}, ["B1"], ["N1"], "OLCULEMEDI"),
    ]


def altin_kume():
    print("=" * 78)
    print("ALTIN KUME -- KAPI AD TEKLIK KAPISININ KENDI KANITI (kor kapi yok)")
    print("=" * 78)
    vakalar = _vakalar()
    gecen = 0
    for i, (ad, specler, belgeler, bek_var, bek_yok, bek_hukum) in enumerate(vakalar, 1):
        with tempfile.TemporaryDirectory() as gecici:
            kok = Path(gecici)
            _kur(kok, specler, belgeler)
            bulgular, hukum, _ = denetle(kok)
        kodlar = {b[0] for b in bulgular}
        hata = []
        for k in bek_var:
            if k not in kodlar:
                hata.append("%s BEKLENIYORDU, yok" % k)
        for k in bek_yok:
            if k in kodlar:
                hata.append("%s OLMAMALIYDI, var" % k)
        if bek_hukum and hukum != bek_hukum:
            hata.append("hukum %s beklendi, %s olculdu" % (bek_hukum, hukum))
        if hata:
            print("[KALDI] %d) %s" % (i, ad))
            print("        %s   | olculen kodlar: %s | hukum: %s"
                  % ("; ".join(hata), sorted(kodlar) or "-", hukum))
        else:
            gecen += 1
            print("[GECTI] %d) %s" % (i, ad))
    print("-" * 78)
    print("%d/%d vaka gecti." % (gecen, len(vakalar)))
    if gecen == len(vakalar):
        print("HUKUM: ARAC KULLANILABILIR -- temizde susuyor, kirlide isiriyor.")
        print("=" * 78)
        return 0
    print("HUKUM: ARAC KULLANILAMAZ -- once kapinin kendisi onarilir.")
    print("=" * 78)
    return 2


def main(argv):
    if len(argv) == 2 and argv[1] == "--altin-kume":
        return altin_kume()
    if len(argv) != 2 or argv[1].startswith("--"):
        print("KULLANIM: python araclar\\kapi-ad-teklik-kapisi.py <kok>")
        print("          python araclar\\kapi-ad-teklik-kapisi.py --altin-kume")
        return 3
    kok = Path(argv[1])
    if not kok.is_dir():
        print("ORTAM HATASI: dizin degil -> %s" % kok)
        return 3
    bulgular, hukum, cikis = denetle(kok)
    print("=" * 78)
    print("KAPI AD TEKLIK KAPISI %s -- K108: kapi kimligi SPEC-YERELDIR" % SURUM)
    print("=" * 78)
    sira = {"KIRMIZI": 0, "OLCULEMEDI": 1, "BILGI": 2}
    for kod, siddet, mesaj in sorted(bulgular, key=lambda b: (sira.get(b[1], 9), b[0])):
        print("  [%s] %s: %s" % (siddet, kod, mesaj))
    if not bulgular:
        print("  bulgu yok -- her kapi atfi ya TEK ilanli ya da KAPSAM ONEKLI.")
    print("-" * 78)
    print("BEYAN EDILMIS SINIR:")
    print("  1) Bu kapi MUTANT (M<n>) kimliklerinin tekligini OLCMEZ: mutant adi")
    print("     spec'lerde hem ILAN hem ATIF olarak geciyor (or. A9c, A9b'nin")
    print("     M119'unu onariyor) ve arac ikisini ayirt edemez. Bu bir BORCTUR.")
    print("  2) Kapsam disi: PROJE_HAFIZA.md (append-only), KANIT/**, docs/ADR/**.")
    print("     Gerekce koddadir; susturma degil, DUZELTILEMEZ metin oldugu icin.")
    print("  3) Bir kimligin IKI spec'te AYNI seyi mi olctugunu OLCMEZ; yalniz")
    print("     (GENISLETME) etiketinin varligina bakar.")
    print("=" * 78)
    print("HUKUM: %s" % hukum)
    if hukum == "OLCULEMEDI":
        print("  >> OLCULEMEDI YESIL DEGILDIR.")
    print("=" * 78)
    return cikis


if __name__ == "__main__":
    sys.exit(main(sys.argv))

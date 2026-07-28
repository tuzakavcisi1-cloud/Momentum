#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""iddia-kapisi.py 1.0.0 -- BELGENIN KENDI IDDIASINI DISKLE KARSILASTIRIR

NEDEN VAR (iki sinif, IKISI DE IKI KEZ isirdi, ikisinin de kapisi YOKTU):

(1) SAYI <-> LISTE TUTARSIZLIGI. slice-3c spec v1 dort yerde "on alti mutant /
    M1-M16" diyordu ama tabloda 17 satir vardi (bagimsiz denetci buldu). Kacak
    olculebilir bir seydi: kabul kriteri "M1-M16'nin hepsi uygulandi" diyordu,
    dolayisiyla HARFIYEN uyan bir teslim M5b'yi atlayabilir ve yine de "tum
    kriterler saglandi" diyebilirdi. v2 yazilirken AYNI KUSUR TEKRAR URETILDI
    ("otuz iki" <-> 36 satir) ve yalniz sansla, kapi kosulmadan once yakalandi.

(2) KANITSIZ MUTANT BEYANI. KANIT/slice-3c/09-MUTANT/00-OZET.md 36 mutantin
    hepsini "uygulandi, KIRMIZI olculdu, geri alindi" diye beyan etti; ham
    terminal ciktisi yalniz 8'i icin dosyaya yazilmisti. Beyan DURUSTTU (kaynak
    acikca yazilmisti) ama SART KARSILANMADI: spec "her biri icin kanit" diyordu.
    Ders: kosum aninda dosyaya yazilmayan ham cikti SONRADAN URETILEMEZ.

Mevcut araclar bu iki sinifa KORDUR ve bu OLCULDU:
  * spec-kapi-kapsama.py mutantlari SAYAR ama belgenin KENDI sayi iddiasiyla
    karsilastirmaz -- 17 satirlik bir tabloyu "16 mutant" diyen metinle uyumlu
    sanar (kapsama sorusu farklidir).
  * sayi-tazeligi.py yalniz "altin kume N/M" IMZALI satirlara bakar; "otuz alti
    mutant" cumlesi o imzayi tasimaz.

BU KAPI NE OLCER (ve ne OLCMEZ):
  OLCER  -- belgenin kendi cumlesindeki mutant sayisi ile TABLOSUNDAKI satir
            sayisi; beyan edilen her mutantin KANIT dizininde bir ham cikti
            dosyasina sahip olup olmadigini.
  OLCMEZ -- mutantin GERCEKTEN isirdigini (bu kosan kod ister; spec-kapi-kapsama
            da ayni sinirini beyan eder). Ham ciktinin ICERIGININ dogru oldugunu
            da olcmez; VARLIGINI olcer. Bir dosyanin var olmasi, o mutantin
            kosuldugunu KANITLAMAZ -- yalnizca kanitin URETILDIGINI gosterir.

TURKCE SAYI: kusur tam da YAZIYLA yazilan sayilarda dogdu ("on alti", "otuz iki"),
bu yuzden 0-99 arasi Turkce sayi sozcukleri COZULUR. Rakamla yazilanlar da.

KODLAR: I0 bicim ? I1 sayi<->liste ? I2 kanitsiz mutant ? I3 hayalet kanit
        ? I4 gerekcesiz muafiyet ? I5 olu muafiyet.

Muafiyet: araclar/iddia-muafiyet.json -- GEREKCESIZ OLAMAZ (I4) ve artik hicbir
sapmayi ortmuyorsa OLU'dur ve SOYLENIR (I5). Olu tuzak bu projede adi konmus bir
kusur sinifidir.

KULLANIM:
  python araclar/iddia-kapisi.py <belge.md> [--kanit <dizin>]
  python araclar/iddia-kapisi.py --altin-kume

CIKIS: 0 temiz/sari ? 1 KIRMIZI ? 2 kullanim hatasi.
"""
import json
import os
import re
import sys

SURUM = "1.1.0"
LISTE_ESIGI = 8  # bu kadar farkli mutant kimligi tasiyan dosya ENVANTERDIR, kanit degil

# --------------------------------------------------------------- Turkce sayi
_BIRLER = {
    "sifir": 0, "bir": 1, "iki": 2, "uc": 3, "dort": 4, "bes": 5,
    "alti": 6, "yedi": 7, "sekiz": 8, "dokuz": 9,
}
_ONLAR = {
    "on": 10, "yirmi": 20, "otuz": 30, "kirk": 40, "elli": 50,
    "altmis": 60, "yetmis": 70, "seksen": 80, "doksan": 90,
}


def _sadelestir(s):
    """Turkce harfleri ASCII'ye indirger -- belge kaynagi karisik olabilir."""
    esle = {
        "ç": "c", "Ç": "c", "ğ": "g", "Ğ": "g",
        "ı": "i", "İ": "i", "ö": "o", "Ö": "o",
        "ş": "s", "Ş": "s", "ü": "u", "Ü": "u",
        "â": "a", "î": "i", "û": "u",
    }
    return "".join(esle.get(ch, ch) for ch in s).lower()


def turkce_sayi(sozcukler):
    """['otuz','alti'] -> 36 ? ['on','alti'] -> 16 ? ['yedi'] -> 7 ? yoksa None.

    YALNIZ 0-99. Yuz/bin BILEREK desteklenmez: bu kapi mutant sayilarini olcer
    ve uc haneli bir mutant listesi bu projede kusurun kendisi olurdu.
    """
    if not sozcukler:
        return None
    s = [_sadelestir(x) for x in sozcukler]
    if len(s) == 1:
        if s[0] in _ONLAR:
            return _ONLAR[s[0]]
        if s[0] in _BIRLER:
            return _BIRLER[s[0]]
        return None
    if len(s) == 2 and s[0] in _ONLAR and s[1] in _BIRLER and _BIRLER[s[1]] != 0:
        return _ONLAR[s[0]] + _BIRLER[s[1]]
    return None


# ------------------------------------------------------------- iddia cikarma
# "otuz alti mutant" / "36 mutant" / "M1-M36" / "M1–M36" (kisa+uzun tire)
_YAZI = re.compile(
    r"\b((?:on|yirmi|otuz|kirk|elli|altmis|yetmis|seksen|doksan)"
    r"(?:\s+(?:bir|iki|uc|dort|bes|alti|yedi|sekiz|dokuz))?"
    r"|bir|iki|uc|dort|bes|alti|yedi|sekiz|dokuz)\s+mutant\b")
_RAKAM = re.compile(r"\b(\d{1,3})\s+mutant\b")
# TERS SIRA -- "MUTANTLAR -- otuz alti" / "MUTANTLAR: 36". Bu deseni ALTIN KUME
# EKLETTI: ilk surum yalniz "N mutant" siralamasini taniyordu ve slice-3c'nin
# GERCEK kacagi ("## 6. MUTANTLAR -- otuz alti;") tam da ters siradaydi -- yani
# kapi, yazildigi ilk halde kendi var olus sebebini KACIRIYORDU.
_YAZI_TERS = re.compile(
    r"\bmutant\w*\b\s*(?:[-–—:]+|\()\s*"
    r"((?:on|yirmi|otuz|kirk|elli|altmis|yetmis|seksen|doksan)"
    r"(?:\s+(?:bir|iki|uc|dort|bes|alti|yedi|sekiz|dokuz))?"
    r"|bir|iki|uc|dort|bes|alti|yedi|sekiz|dokuz)\b")
_RAKAM_TERS = re.compile(r"\bmutant\w*\b\s*(?:[-–—:]+|\()\s*(\d{1,3})\b")
_ARALIK = re.compile(r"`?M(\d{1,3})`?\s*[-–—]+\s*`?M(\d{1,3})`?")

# §6 tablosundaki mutant satirlari: | **M12** | ... ya da | M12 | ...
_SATIR = re.compile(r"^\s*\|\s*\*{0,2}(M\d{1,3}[a-z]?)\*{0,2}\s*\|")


def tablodaki_mutantlar(metin):
    """Tablo satirlarindan mutant kimliklerini SIRAYLA cikarir (tekrarsiz)."""
    bulunan, gorulen = [], set()
    for satir in _sadelestir_koruyarak(metin).split("\n"):
        m = _SATIR.match(satir)
        if m and m.group(1) not in gorulen:
            gorulen.add(m.group(1))
            bulunan.append(m.group(1))
    return bulunan


def _sadelestir_koruyarak(metin):
    """Satir yapisini bozmadan yalniz Turkce harfleri indirger."""
    return "".join(
        {"ç": "c", "Ç": "C", "ğ": "g", "Ğ": "G", "ı": "i", "İ": "I",
         "ö": "o", "Ö": "O", "ş": "s", "Ş": "S", "ü": "u", "Ü": "U"}.get(ch, ch)
        for ch in metin)


def iddialar(metin):
    """Belgedeki mutant SAYISI iddialarini toplar: [(tur, deger, ham)]."""
    duz = _sadelestir_koruyarak(metin)
    cikti = []
    for m in _YAZI.finditer(duz.lower()):
        d = turkce_sayi(m.group(1).split())
        if d is not None:
            cikti.append(("yazi", d, m.group(0).strip()))
    for m in _RAKAM.finditer(duz):
        cikti.append(("rakam", int(m.group(1)), m.group(0).strip()))
    for m in _YAZI_TERS.finditer(duz.lower()):
        d = turkce_sayi(m.group(1).split())
        if d is not None:
            cikti.append(("yazi-ters", d, m.group(0).strip()))
    for m in _RAKAM_TERS.finditer(duz):
        cikti.append(("rakam-ters", int(m.group(1)), m.group(0).strip()))
    # ARALIK YALNIZ BUTUNLUK BAGLAMINDA TOPLAM IDDIASIDIR. Gercek depoda olculdu:
    # 09-MUTANT/00-OZET.md "M1-M2 (G1), M34-M36 (G6) taze kosuldu" diyor -- bunlar
    # KAPSAM ifadeleridir, toplam degil. Ilk surum ucunu de toplam sanip UC YANLIS-
    # POZITIF uretti. Kural: aralik, ayni SATIRDA butunluk sozcugu tasiyorsa sayilir.
    _BUTUNLUK = ("tek tek", "hepsi", "tamami", "butun", "toplam", "kriter",
                 "uygulandi", "her biri")
    for satir in duz.split("\n"):
        alt = satir.lower()
        if not any(s in alt for s in _BUTUNLUK):
            continue
        for m in _ARALIK.finditer(satir):
            bas, son = int(m.group(1)), int(m.group(2))
            if son >= bas:
                cikti.append(("aralik", son - bas + 1, m.group(0).strip()))
    return cikti


def kanit_mutantlari(kanit_dizini):
    """KANIT dizininde ham cikti dosyasi BULUNAN mutantlarin kumesi.

    Bir mutant KANITLI sayilir ancak ve ancak: dosya ADINDA ya da bir dosyanin
    ICINDE `Mnn` kimligi geciyorsa. Ozet/tablo dosyalari (00-OZET.md) HARIC
    tutulur -- ozet, kendi iddiasinin kaniti olamaz (dairesel kanit).
    """
    if not kanit_dizini or not os.path.isdir(kanit_dizini):
        return None
    kanitli = set()
    envanterler = []
    desen = re.compile(r"\bM(\d{1,3}[a-z]?)\b")
    for kok, _dizinler, dosyalar in os.walk(kanit_dizini):
        for ad in dosyalar:
            # DAIRESEL KANIT YASAGI -- OZET ve HUKUM belgeleri kanit SAYILMAZ.
            # Gercek depoda olculdu: ilk surum yalniz "00-ozet"i eliyordu, HUKUM.md
            # icindeki M1-M36 listesi 36 mutantin HEPSINI "kanitli" gosterdi ve kapi
            # slice-3c'nin BILINEN eksigini (28 mutantin ham ciktisi yok) KACIRDI.
            _ad = _sadelestir(ad)
            if (_ad.startswith("00-ozet") or _ad.startswith("ozet")
                    or _ad.startswith("hukum") or _ad.startswith("00-hukum")):
                continue
            yol = os.path.join(kok, ad)
            for m in desen.finditer(ad):
                kanitli.add("M" + m.group(1))
            try:
                with open(yol, encoding="utf-8", errors="replace") as f:
                    govde = f.read(400000)
            except OSError:
                continue
            icerdigi = {"M" + m.group(1) for m in desen.finditer(govde)}
            # ENVANTER REDDI. Gercek depoda olculdu: 07-G7-regresyon/07-spec-kapi-
            # kapsama.txt, spec-kapi-kapsama.py'nin "MUTANT(36): M1, M2, ... M36"
            # satirini tasiyor. Bu, mutantlarin KOSULDUGUNUN degil, SPECTE YAZILI
            # OLDUGUNUN ciktisidir -- ikinci bir dairesel kanit yolu. Tek bir mutant
            # kosumunun ham ciktisi dogasi geregi BIR (bazen iki) mutant anar; ESIK
            # kadar farkli kimlik tasiyan dosya bir ENVANTERDIR ve kanit SAYILMAZ.
            # Esik K40 geregi uydurulmadi: altin kumede 13. ve 14. vaka ile pinlendi.
            if len(icerdigi) >= LISTE_ESIGI:
                envanterler.append((os.path.relpath(yol, kanit_dizini), len(icerdigi)))
                continue
            kanitli |= icerdigi
    return kanitli, envanterler


def muafiyet_yukle(kok):
    """araclar/iddia-muafiyet.json -- gerekcesiz muafiyet KABUL EDILMEZ (I4)."""
    yol = os.path.join(kok, "araclar", "iddia-muafiyet.json")
    if not os.path.isfile(yol):
        return [], []
    try:
        with open(yol, encoding="utf-8") as f:
            kayitlar = json.load(f)
    except Exception as ex:  # noqa: BLE001 -- bozuk muafiyet KIRMIZI'dir
        return [], [("KIRMIZI", "I4", "iddia-muafiyet.json BOZUK: %r" % (ex,))]
    kabul, hata = [], []
    for k in kayitlar if isinstance(kayitlar, list) else []:
        gerekce = (k.get("gerekce") or "").strip()
        borc = (k.get("borc") or "").strip()
        if len(gerekce) < 20 or not borc:
            hata.append(("KIRMIZI", "I4",
                         "GEREKCESIZ MUAFIYET: %r -- `borc` ve en az 20 karakter "
                         "`gerekce` ZORUNLUDUR." % (k.get("mutant") or k.get("kod"),)))
            continue
        kabul.append(k)
    return kabul, hata


# --------------------------------------------------------------- saf cekirdek
def denetle(metin, kanitli=None, muafiyetler=None):
    """SAF FONKSIYON -- diske DOKUNMAZ. Doner: [(SEVIYE, KOD, mesaj)].

    `kanitli` None ise kanit ayagi CALISTIRILMAZ (olculmedi != temiz): I2/I3
    hukmu verilmez ve bu ozette SOYLENIR.
    """
    muafiyetler = muafiyetler or []
    muaf_mutant = {(m.get("mutant") or "").strip() for m in muafiyetler}
    bulgular = []

    tablo = tablodaki_mutantlar(metin)
    if not tablo:
        bulgular.append(("KIRMIZI", "I0",
                         "MUTANT TABLOSU YOK ya da hicbir satir `| Mnn |` bicimine "
                         "uymuyor -- bu kapi olcemez."))
        return bulgular, tablo, set()

    # --- I1: belgenin KENDI sayi iddiasi <-> tablo satir sayisi ---------------
    for tur, deger, ham in iddialar(metin):
        if deger != len(tablo):
            bulgular.append(("KIRMIZI", "I1",
                             "SAYI<->LISTE TUTARSIZLIGI: belge %r diyor (%s), tabloda "
                             "%d mutant satiri var. Kabul kriteri bu sayiya atif "
                             "yaparsa, FAZLA olan mutant SESSIZCE atlanabilir."
                             % (ham, tur, len(tablo))))

    # --- I2/I3: beyan <-> ham kanit ------------------------------------------
    kullanilan_muafiyet = set()
    if kanitli is None:
        return bulgular, tablo, set()

    for mid in tablo:
        if mid in kanitli:
            continue
        if mid in muaf_mutant:
            kullanilan_muafiyet.add(mid)
            k = next(m for m in muafiyetler if (m.get("mutant") or "").strip() == mid)
            bulgular.append(("BILGI", "I2",
                             "MUAFIYET UYGULANDI [borc %s] -- %s: %s. Muafiyet SESSIZ "
                             "DEGILDIR; borc kapaninca bu satir da kapanir."
                             % (k.get("borc"), mid, k.get("gerekce"))))
            continue
        bulgular.append(("KIRMIZI", "I2",
                         "KANITSIZ MUTANT: %s tabloda BEYAN EDILMIS ama KANIT dizininde "
                         "ham cikti dosyasi YOK. Kosum aninda yazilmayan cikti sonradan "
                         "URETILEMEZ." % mid))

    for mid in sorted(kanitli - set(tablo)):
        bulgular.append(("SARI", "I3",
                         "HAYALET KANIT: %s icin kanit dosyasi var ama mutant tablosunda "
                         "boyle bir satir YOK -- ya tablo eksik ya kanit bayat." % mid))

    for m in muafiyetler:
        mid = (m.get("mutant") or "").strip()
        if mid and mid not in kullanilan_muafiyet:
            bulgular.append(("SARI", "I5",
                             "OLU MUAFIYET: %s icin muafiyet duruyor ama artik hicbir "
                             "sapmayi ortmuyor -- SILINMELIDIR." % mid))

    return bulgular, tablo, kullanilan_muafiyet


def _yaz(s):
    try:
        print(s)
    except UnicodeEncodeError:
        print(s.encode("ascii", "replace").decode("ascii"))


# ---------------------------------------------------------------- altin kume
_TEMIZ = """## 6. MUTANTLAR -- uc; KAPALI liste

| # | mutant | kapi / kural | beklenen |
|---|---|---|---|
| **M1** | bir sey boz | G1 / D0 | kirmizi |
| **M2** | baska sey boz | G1 / D0 | kirmizi |
| **M3** | ucuncu sey boz | G2 / D1 | kirmizi |
"""


def _vaka(ad, metin, beklenen, kanitli=None, muafiyetler=None, olmamali=()):
    bulgular, _t, _m = denetle(metin, kanitli=kanitli, muafiyetler=muafiyetler)
    kodlar = sorted({k for _s, k, _m2 in bulgular})
    ok = all(b in kodlar for b in beklenen) and not any(o in kodlar for o in olmamali)
    _yaz(("[GECTI] " if ok else "[KALDI] ") + ad)
    _yaz("    beklenen: %s - olmamali: %s - olculen: %s"
         % (sorted(beklenen), sorted(olmamali), kodlar))
    if not ok:
        for s, k, m in bulgular:
            _yaz("      %s %s: %s" % (s, k, m))
    return ok


def altin_kume():
    _yaz("=" * 78)
    _yaz("ALTIN KUME -- IDDIA KAPISININ KENDI KANITI (kor kapi yok)")
    _yaz("=" * 78)
    s = []

    s.append(_vaka("1) TEMIZ: 'uc' <-> 3 satir, kanit tam -- SUSMALI",
                   _TEMIZ, [], kanitli={"M1", "M2", "M3"}, olmamali=("I1", "I2", "I3")))

    s.append(_vaka("2) YAZIYLA SAYI YANLIS ('iki' <-> 3 satir) -- I1 ISIRMALI",
                   _TEMIZ.replace("-- uc;", "-- iki;"), ["I1"], kanitli={"M1", "M2", "M3"}))

    s.append(_vaka("3) RAKAMLA SAYI YANLIS ('16 mutant' <-> 3) -- I1 ISIRMALI",
                   _TEMIZ + "\nToplam 16 mutant uygulandi.\n", ["I1"],
                   kanitli={"M1", "M2", "M3"}))

    s.append(_vaka("4) ARALIK YANLIS (M1-M16 <-> 3 satir) -- I1 ISIRMALI",
                   _TEMIZ + "\nKriter: `M1`-`M16` tek tek uygulandi.\n", ["I1"],
                   kanitli={"M1", "M2", "M3"}))

    s.append(_vaka("5) GERCEK slice-3c KACAGI: 'on alti' <-> 17 satir -- I1 ISIRMALI",
                   _TEMIZ.replace("-- uc;", "-- on alti;")
                   + "| **M3b** | dorduncu | G2 / D1 | kirmizi |\n", ["I1"],
                   kanitli={"M1", "M2", "M3", "M3b"}))

    s.append(_vaka("6) KANITSIZ MUTANT -- I2 ISIRMALI",
                   _TEMIZ, ["I2"], kanitli={"M1", "M2"}))

    s.append(_vaka("7) HAYALET KANIT -- I3 ISIRMALI",
                   _TEMIZ, ["I3"], kanitli={"M1", "M2", "M3", "M9"}))

    s.append(_vaka("8) KANIT OLCULMEDI (None) -- I2/I3 HUKMU VERILMEZ",
                   _TEMIZ, [], kanitli=None, olmamali=("I2", "I3")))

    s.append(_vaka("9) TABLO YOK -- I0 ISIRMALI",
                   "## 6. MUTANTLAR\nbos govde\n", ["I0"], kanitli=set()))

    s.append(_vaka("10) GEREKCELI MUAFIYET -- I2 KIRMIZI SUSAR, BILGI BASILIR",
                   _TEMIZ, [], kanitli={"M1", "M2"},
                   muafiyetler=[{"mutant": "M3", "borc": "BD-9",
                                 "gerekce": "cihaz gerektiren mutant, sonraki dilimde kosulacak"}],
                   olmamali=()))

    s.append(_vaka("11) OLU MUAFIYET -- I5 ISIRMALI",
                   _TEMIZ, ["I5"], kanitli={"M1", "M2", "M3"},
                   muafiyetler=[{"mutant": "M3", "borc": "BD-9",
                                 "gerekce": "artik gecerli degil, kanit uretildi ama kayit duruyor"}]))

    s.append(_vaka("12) COKLU IDDIA: biri dogru biri yanlis -- I1 YINE ISIRMALI",
                   _TEMIZ + "\nToplam 3 mutant.\nKriter: `M1`-`M9` uygulandi.\n",
                   ["I1"], kanitli={"M1", "M2", "M3"}))

    kaldi = s.count(False)
    _yaz("=" * 78)
    _yaz("ALTIN KUME: %s (%d/%d)" % ("GECTI" if kaldi == 0 else "KALDI",
                                     len(s) - kaldi, len(s)))
    _yaz("HUKUM: %s" % ("ARAC KULLANILABILIR -- temizde susuyor, kirlide isiriyor."
                        if kaldi == 0 else "ARAC KULLANILAMAZ"))
    _yaz("=" * 78)
    return 0 if kaldi == 0 else 1


# ---------------------------------------------------------------------- main
def main(argv):
    if "--altin-kume" in argv:
        return altin_kume()
    if not argv:
        _yaz(__doc__)
        return 2

    belge = argv[0]
    kanit = None
    if "--kanit" in argv:
        i = argv.index("--kanit")
        if i + 1 >= len(argv):
            _yaz("KULLANIM HATASI: --kanit bir dizin bekler.")
            return 2
        kanit = argv[i + 1]

    if not os.path.isfile(belge):
        _yaz("DOSYA YOK: %s" % belge)
        return 2

    kok = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    muafiyetler, muaf_hata = muafiyet_yukle(kok)

    with open(belge, encoding="utf-8") as f:
        metin = f.read()

    _k = kanit_mutantlari(kanit)
    kanitli, envanterler = (None, []) if _k is None else _k
    bulgular, tablo, _kul = denetle(metin, kanitli=kanitli, muafiyetler=muafiyetler)
    bulgular = muaf_hata + bulgular

    _yaz("=" * 78)
    _yaz("IDDIA KAPISI %s -- %s" % (SURUM, belge))
    _yaz("=" * 78)
    _yaz("TABLODAKI MUTANT (%d): %s"
         % (len(tablo), ", ".join(tablo) if tablo else "-"))
    if kanitli is None:
        _yaz("KANIT DIZINI: verilmedi -- I2/I3 OLCULMEDI.")
        _yaz("  OLCULMEDI demek, TEMIZ demek DEGILDIR.")
    else:
        _yaz("KANITLI MUTANT (%d): %s"
             % (len(kanitli), ", ".join(sorted(kanitli)) if kanitli else "-"))
        for yol, adet in envanterler:
            _yaz("  [ENVANTER REDDI] %s -- %d farkli mutant kimligi tasiyor "
                 "(esik %d); bu bir LISTE ciktisidir, tekil kosum kaniti DEGILDIR."
                 % (yol, adet, LISTE_ESIGI))
    _yaz("-" * 78)

    if not bulgular:
        _yaz("BULGU YOK: belgenin kendi sayi iddiasi tablosuyla tutuyor" +
             ("" if kanitli is None else " ve beyan edilen her mutantin ham kaniti var") + ".")
    for seviye, kod, mesaj in bulgular:
        _yaz("[%s] %s: %s" % (seviye, kod, mesaj))

    _yaz("-" * 78)
    _yaz("BEYAN EDILMIS SINIR: bu kapi mutantin GERCEKTEN ISIRDIGINI olcmez ve ham")
    _yaz("ciktinin ICERIGINI dogrulamaz -- kanitin VARLIGINI olcer. Bir dosyanin var")
    _yaz("olmasi o mutantin kosuldugunu kanitlamaz; kanitin URETILDIGINI gosterir.")
    _yaz("=" * 78)

    kirmizi = any(s == "KIRMIZI" for s, _k, _m in bulgular)
    _yaz("HUKUM: %s" % ("KIRMIZI" if kirmizi else "TEMIZ"))
    return 1 if kirmizi else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

# -*- coding: utf-8 -*-
"""spec-kapi-kapsama.py -- bir GOREV spec'inde MUTANTSIZ KAPI/KURAL arar.

NEDEN VAR (K51, radar R1): "kor-kapi" ve "esdeger-mutant" siniflari
GOREV-slice-3b-spec artefaktinda IKI TUR UST USTE dogdu ve iki turda da
INSAN buldu. Radar R1'in hukmu: "3. tur YASAK: once bu sinifi olcen mekanik
kontrol yazilir." Bu betik o kontroldur.

NE OLCER (ve NE OLCMEZ):
  OLCER  : her kapinin ve her ADLANDIRILMIS KURALIN en az bir mutanti var mi;
           mutant tablosunda envanterde OLMAYAN bir kapi/kurala atif var mi.
  OLCMEZ : mutantin gercekten ISIRIP isirmadigini. Esdeger-mutant tespiti
           calisan kod ister; bu betik onu YAPMAZ ve bunu BEYAN EDER.
           [BEYAN EDILMIS SINIR -- gizlenmis degil]

Cikis: 0 temiz · 1 bulgu · 3 bicim/ortam hatasi
Kodlar: S0 bicim · S1 mutantsiz KAPI · S2 mutantsiz KURAL · S3 hayalet atif
"""
import re
import sys

TIRE = dict.fromkeys([0x2010, 0x2011, 0x2012, 0x2013], ord("-"))


def _yaz(s):
    sys.stdout.write(s.encode("ascii", "replace").decode("ascii") + "\n")


def normalize(m):
    """Turkce metindeki bagli-tire (U+2011) tuzagini ASCII tireye cevirir."""
    return m.translate(TIRE)


def bolum(metin, baslik_re):
    """'## N. ...' basligiyla baslayan bolumun govdesini dondurur."""
    satirlar = metin.split("\n")
    bas = None
    for i, s in enumerate(satirlar):
        if re.match(baslik_re, s):
            bas = i + 1
            break
    if bas is None:
        return None
    son = len(satirlar)
    for j in range(bas, len(satirlar)):
        if re.match(r"^## ", satirlar[j]):
            son = j
            break
    return "\n".join(satirlar[bas:son])


def kod_araligi_ac(hucre):
    """'D0`-`D4' gibi araliklari D0,D1,D2,D3,D4'e acar.

    D-A12-2: ad deseni genisler -- D<rakam+> (cok haneli, D10 dahil),
    A11Y-<rakam+> ve D-<harf/rakam>+-<rakam+> (spec-yerel, or. D-A11-2).
    """
    bulunan = set()
    for a, b in re.findall(r"D(\d+)\s*[`\s]*-[`\s]*\s*D(\d+)", hucre):
        for k in range(int(a), int(b) + 1):
            bulunan.add("D%d" % k)
    for ad in re.findall(r"\bD-[A-Za-z0-9]+-\d+\b", hucre):
        bulunan.add(ad)
    for k in re.findall(r"\bD(\d+)\b", hucre):
        bulunan.add("D" + k)
    for k in re.findall(r"\bA11Y-(\d+)\b", hucre):
        bulunan.add("A11Y-" + k)
    return bulunan


def uc_baslik_kurallari(uc_govde):
    """D-A12-1: SS3'teki '### <KURAL-ADI> -- <baslik>' karar basliklarindan
    kural adlarini cikarir. Bicim KURAL-ADI'ni basliktan ayirir: yalniz
    '###' sonrasindaki ILK belirtec taranir, geri kalan serbest metin
    (baslik gerekcesi) TARANMAZ -- aksi halde baslik govdesinde gecen
    baska bir kod (or. '... D0 DARALTILDI') sahte kural olarak sizardi.
    '### G25 -- ...' gibi bir KAPI basligi ilk belirteci 'G25' oldugundan
    kendiliginden kural SAYILMAZ (D-A12-2: G<n> kural degildir)."""
    kurallar = set()
    if uc_govde is None:
        return kurallar
    for s in uc_govde.split("\n"):
        m = re.match(r"^###\s+(\S+)", s)
        if not m:
            continue
        kurallar |= kod_araligi_ac(m.group(1))
    return kurallar


def envanter(kapilar_govde):
    """§5'ten KAPI ve KURAL envanterini cikarir (bugunku kaynak -- korunur)."""
    kapilar = []
    for s in kapilar_govde.split("\n"):
        m = re.match(r"^###\s+(G\d+)\s", s)
        if m and m.group(1) not in kapilar:
            kapilar.append(m.group(1))
    kurallar = set()
    for s in kapilar_govde.split("\n"):
        if not s.lstrip().startswith("|"):
            continue
        hucreler = [h.strip() for h in s.strip().strip("|").split("|")]
        if not hucreler:
            continue
        kurallar |= kod_araligi_ac(hucreler[0])
        # G5 tablosunun ilk sutunundaki adlandirilmis kurallar
        ad = re.sub(r"[`*]", "", hucreler[0]).strip().lower()
        if ad in ("kontrast", "metin"):
            kurallar.add(ad)
    return kapilar, sorted(kurallar)


def mutantlar(mutant_govde):
    """§6 tablosundan {mutant_no: {atif kumesi}} cikarir."""
    sonuc = {}
    for s in mutant_govde.split("\n"):
        if not s.lstrip().startswith("|"):
            continue
        hucreler = [h.strip() for h in s.strip().strip("|").split("|")]
        if len(hucreler) < 3:
            continue
        no = re.sub(r"[`*]", "", hucreler[0]).strip()
        if not re.match(r"^M\d+[a-z]?$", no):
            continue
        hedef = hucreler[2]
        atif = set(re.findall(r"\bG\d+\b", hedef)) | kod_araligi_ac(hedef)
        ad = re.sub(r"[`*]", "", hedef).lower()
        if "kontrast" in ad:
            atif.add("kontrast")
        if "metin" in ad:
            atif.add("metin")
        sonuc[no] = atif
    return sonuc


def borclar(metin):
    """'## 6b. MUTANT BORCU' bolumunden BEYAN EDILMIS kural borclarini okur.

    Bicim (satir basi): '- KURAL: <ad> | GEREKCE: <en az 20 karakter>'
    Gerekcesiz borc KABUL EDILMEZ (S4) -- beyan, gerekce demektir.
    KAPI borclanamaz; yalniz KURAL borclanabilir (S5).
    """
    govde = bolum(metin, r"^##\s*6b\.")
    if govde is None:
        return {}, []
    kabul, hata = {}, []
    for s in govde.split("\n"):
        m = re.match(r"^\s*-\s*KURAL:\s*([^|]+)\|\s*GEREKCE:\s*(.*)$", s)
        if not m:
            continue
        ad = re.sub(r"[`*]", "", m.group(1)).strip()
        gerekce = m.group(2).strip()
        if re.match(r"^G\d+$", ad):
            hata.append(("S5", "KAPI BORCLANAMAZ: " + ad + " -- yalniz KURAL borclanabilir"))
        elif len(gerekce) < 20:
            hata.append(("S4", "GEREKCESIZ BORC: " + ad + " -- gerekce en az 20 karakter olmali"))
        else:
            kabul[ad] = gerekce
    return kabul, hata


def denetle(metin):
    """(bulgular, ozet) dondurur. bulgular: [(kod, mesaj)]"""
    metin = normalize(metin)
    uc = bolum(metin, r"^##\s*3\.")
    g5 = bolum(metin, r"^##\s*5\.")
    g6 = bolum(metin, r"^##\s*6\.")
    if g5 is None or g6 is None:
        return [("S0", "BICIM: '## 5.' veya '## 6.' bolumu bulunamadi")], None
    kapilar, kurallar_5 = envanter(g5)
    # D-A12-1: SS3 karar basliklari SS5 tablosunun UZERINE eklenir, yerini almaz.
    kurallar = sorted(set(kurallar_5) | uc_baslik_kurallari(uc))
    muts = mutantlar(g6)
    if not kapilar:
        return [("S0", "BICIM: §5'te hic '### G<n>' kapi basligi yok")], None
    if not muts:
        return [("S0", "BICIM: §6'da hic mutant satiri ayristirilamadi")], None

    kapsanan = set()
    for a in muts.values():
        kapsanan |= a

    borc, borc_hatasi = borclar(metin)
    bulgular = list(borc_hatasi)
    # KAPI borclanamaz: her kapinin mutanti PAZARLIKSIZ.
    for k in kapilar:
        if k not in kapsanan:
            bulgular.append(("S1", "MUTANTSIZ KAPI: " + k + " -- hicbir mutant bu kapiyi hedeflemiyor"))
    for r in kurallar:
        if r in kapsanan:
            continue
        if r in borc:
            continue  # BEYAN EDILMIS BORC -- ozet bolumunde SAYILIR, gizlenmez
        bulgular.append(("S2", "MUTANTSIZ KURAL: " + r + " -- mutanti da yok, BEYAN EDILMIS BORCU da yok"))
    for r in sorted(borc):
        if r in kapsanan:
            bulgular.append(("S6", "GEREKSIZ BORC: " + r + " -- mutanti VAR, borc beyani yaniltici"))
        elif r not in kurallar:
            bulgular.append(("S6", "GEREKSIZ BORC: " + r + " -- envanterde boyle bir kural yok"))
    envanter_kumesi = set(kapilar) | set(kurallar)
    for no in sorted(muts, key=lambda x: (len(x), x)):
        for a in sorted(muts[no]):
            if a not in envanter_kumesi:
                bulgular.append(("S3", "HAYALET ATIF: " + no + " -> " + a + " (envanterde yok)"))
    ozet = (kapilar, kurallar, muts, borc)
    return bulgular, ozet


_TEMIZ = """## 5. KAPILAR
### G1 - ilk kapi
| kod | ne |
| D0 | bir sey |
### G2 - ikinci kapi
| kural | olcum |
| A11Y-1 | bir sey |
| kontrast | bir sey |
## 6. MUTANTLAR
| # | mutant | kapi / kural | beklenen |
|---|---|---|---|
| **M1** | bir sey boz | G1 / D0 | kirmizi |
| **M2** | baska sey boz | G2 / A11Y-1 | kirmizi |
| **M3** | rengi boz | G2 / kontrast | kirmizi |
## 7. son
"""

_ARALIK = """## 5. KAPILAR
### G1 - kapi
| kod | ne |
| `D0`-`D2` | mevcut kodlar |
## 6. MUTANTLAR
| # | mutant | kapi / kural | beklenen |
| **M1** | boz | G1 / D0 | k |
| **M2** | boz | G1 / D1 | k |
| **M3** | boz | G1 / D2 | k |
## 7. son
"""


def _vaka(ad, metin, beklenen_kodlar):
    bulgular, _ = denetle(metin)
    olculen = sorted(set(k for k, _ in bulgular))
    ok = olculen == sorted(set(beklenen_kodlar))
    _yaz(("[GECTI] " if ok else "[KALDI] ") + ad)
    _yaz("    beklenen: " + str(sorted(set(beklenen_kodlar))) + " · olculen: " + str(olculen))
    if not ok:
        for k, m in bulgular:
            _yaz("      " + k + ": " + m)
    return ok


def altin_kume():
    _yaz("=" * 74)
    _yaz("ALTIN KUME -- ARACIN KENDI KANITI (kor kapi yok)")
    _yaz("=" * 74)
    sonuc = []
    sonuc.append(_vaka("1) TEMIZ SPEC -- yanlis-pozitif kontrolu", _TEMIZ, []))
    sonuc.append(_vaka("2) MUTANTSIZ KAPI -- S1 isirmali",
                       _TEMIZ.replace("| **M2** | baska sey boz | G2 / A11Y-1 | kirmizi |\n", "")
                             .replace("| **M3** | rengi boz | G2 / kontrast | kirmizi |\n", ""),
                       ["S1", "S2", "S2"]))
    sonuc.append(_vaka("3) MUTANTSIZ KURAL -- S2 isirmali",
                       _TEMIZ.replace("| **M3** | rengi boz | G2 / kontrast | kirmizi |\n", ""),
                       ["S2"]))
    sonuc.append(_vaka("4) HAYALET ATIF -- S3 isirmali",
                       _TEMIZ.replace("G2 / kontrast", "G9 / kontrast"),
                       ["S3"]))
    sonuc.append(_vaka("5) BOLUM YOK -- S0 isirmali",
                       _TEMIZ.replace("## 6. MUTANTLAR", "## 6x YOK"), ["S0"]))
    sonuc.append(_vaka("6) TEK MUTANT IKI KURALI KAPATIR -- susmali",
                       _TEMIZ.replace("| **M3** | rengi boz | G2 / kontrast | kirmizi |",
                                      "| **M3** | rengi boz | G2 / A11Y-1 / kontrast | kirmizi |"),
                       []))
    sonuc.append(_vaka("7) KOD ARALIGI (D0-D2) acilmali -- susmali", _ARALIK, []))
    sonuc.append(_vaka("8) BAGLI TIRE (U+2011) tuzagi -- susmali",
                       _TEMIZ.replace("| A11Y-1 | bir sey |", "| A11Y‑1 | bir sey |"), []))
    sonuc.append(_vaka("9) MUTANT TABLOSU BOS -- S0 isirmali",
                       _TEMIZ.split("## 6.")[0] + "## 6. MUTANTLAR\nbos\n## 7. son\n", ["S0"]))
    # --- K53: BEYAN EDILMIS MUTANT BORCU mekanizmasi ---
    _KONTRASTSIZ = _TEMIZ.replace("| **M3** | rengi boz | G2 / kontrast | kirmizi |\n", "")
    _BORC = "## 6b. MUTANT BORCU\n- KURAL: kontrast | GEREKCE: ilk dilim tavani 8 mutant, kontrast risk sirasinda disarida kaldi\n"
    sonuc.append(_vaka("10) BEYAN EDILMIS+GEREKCELI borc -- SUSMALI",
                       _KONTRASTSIZ.replace("## 7. son", _BORC + "## 7. son"), []))
    sonuc.append(_vaka("11) GEREKCESIZ borc -- S4 isirmali (beyan = gerekce demektir)",
                       _KONTRASTSIZ.replace(
                           "## 7. son",
                           "## 6b. MUTANT BORCU\n- KURAL: kontrast | GEREKCE: sonra\n## 7. son"),
                       ["S2", "S4"]))
    sonuc.append(_vaka("12) KAPI borclanmaya calisilirsa -- S1+S5 isirmali",
                       _TEMIZ.replace("| **M2** | baska sey boz | G2 / A11Y-1 | kirmizi |\n", "")
                             .replace("| **M3** | rengi boz | G2 / kontrast | kirmizi |\n", "")
                             .replace("## 7. son",
                                      "## 6b. MUTANT BORCU\n- KURAL: G2 | GEREKCE: bu kapiyi simdilik erteliyoruz cunku pahali\n## 7. son"),
                       ["S1", "S2", "S5"]))
    sonuc.append(_vaka("13) MUTANTI OLAN kural icin borc beyani -- S6 isirmali",
                       _TEMIZ.replace("## 7. son",
                                      "## 6b. MUTANT BORCU\n- KURAL: kontrast | GEREKCE: gereksiz beyan, mutanti zaten var ve kosuyor\n## 7. son"),
                       ["S6"]))
    # --- A12/G25: SS3 karar basliklari + genisletilmis ad deseni (D-A12-1/D-A12-2) ---
    _UC_D_A11_2 = """## 3. KARARLAR
### D-A11-2 -- YENIDEN DENEME SOZLESMESI
govde metni burada
## 5. KAPILAR
### G1 - kapi
| kod | ne |
| D0 | bir sey |
## 6. MUTANTLAR
| # | mutant | kapi / kural | beklenen |
| **M1** | boz | G1 / D0 | kirmizi |
## 7. son
"""
    sonuc.append(_vaka("14) A12/G25/a: SS3 basligi -- D-A11-2 envanterde gorunur (S2 isirmali)",
                       _UC_D_A11_2, ["S2"]))
    _UC_D0_D4 = """## 5. KAPILAR
### G1 - kapi
| kod | ne |
| `D0`-`D4` | mevcut kodlar |
## 6. MUTANTLAR
| # | mutant | kapi / kural | beklenen |
| **M1** | boz | G1 / D0 | k |
| **M2** | boz | G1 / D1 | k |
| **M3** | boz | G1 / D2 | k |
| **M4** | boz | G1 / D3 | k |
| **M5** | boz | G1 / D4 | k |
## 7. son
"""
    sonuc.append(_vaka("15) A12/G25/b: D0-D4 araligi bes kurala acilir -- susmali (regresyon)",
                       _UC_D0_D4, []))
    _UC_D10 = """## 5. KAPILAR
### G1 - kapi
| kod | ne |
| D10 | on birinci kod |
## 6. MUTANTLAR
| # | mutant | kapi / kural | beklenen |
| **M1** | boz | G1 | kirmizi |
## 7. son
"""
    sonuc.append(_vaka("16) A12/G25/c: D10 envanterde gorunur (S2 isirmali)", _UC_D10, ["S2"]))
    _UC_G25_BASLIK = """## 3. KARARLAR
### G25 -- KAPI BASLIGI ORNEGI (kural degil)
govde metni
## 5. KAPILAR
### G1 - kapi
| kod | ne |
| D0 | bir sey |
## 6. MUTANTLAR
| # | mutant | kapi / kural | beklenen |
| **M1** | boz | G1 / D0 | kirmizi |
## 7. son
"""
    sonuc.append(_vaka("17) A12/G25/d: SS3'te G<n> basligi kural SAYILMAZ -- susmali",
                       _UC_G25_BASLIK, []))
    _UC_SPEC_YEREL_5 = """## 5. KAPILAR
### G1 - kapi
| kod | ne |
| D-A11-2 | spec-yerel karar adi |
## 6. MUTANTLAR
| # | mutant | kapi / kural | beklenen |
| **M1** | boz | G1 | kirmizi |
## 7. son
"""
    sonuc.append(_vaka("18) A12/G25/e: SS5'te spec-yerel ad (D-A11-2) mutantsiz -- S2 isirmali",
                       _UC_SPEC_YEREL_5, ["S2"]))
    sonuc.append(_vaka("19) A12/G25/f: SS3 kaynakli kurala gerekceli borc -- SUSMALI",
                       _UC_D_A11_2.replace(
                           "## 7. son",
                           "## 6b. MUTANT BORCU\n- KURAL: D-A11-2 | GEREKCE: bu dilimde kasitli olarak mutantsiz birakildi test amacli\n## 7. son"),
                       []))
    _UC_HAYALET_BORC = """## 3. KARARLAR
### D-A11-2 -- YENIDEN DENEME SOZLESMESI
govde metni
## 5. KAPILAR
### G1 - kapi
| kod | ne |
| D0 | bir sey |
## 6. MUTANTLAR
| # | mutant | kapi / kural | beklenen |
| **M1** | boz | G1 / D0 | kirmizi |
| **M2** | boz | G1 / D-A11-2 | kirmizi |
## 6b. MUTANT BORCU
- KURAL: D-A11-99 | GEREKCE: envanterde hic olmayan bir ada kasitli hayalet borc denemesi
## 7. son
"""
    sonuc.append(_vaka("20) A12/G25/g: envanterde olmayan ada borc -- S6 isirmali (hayalet borc)",
                       _UC_HAYALET_BORC, ["S6"]))
    _UC_HAYALET_ATIF_YENI = """## 5. KAPILAR
### G1 - kapi
| kod | ne |
| D0 | bir sey |
## 6. MUTANTLAR
| # | mutant | kapi / kural | beklenen |
| **M1** | boz | G1 / D0 | kirmizi |
| **M2** | boz | G1 / D-A11-99 | kirmizi |
## 7. son
"""
    sonuc.append(_vaka("21) A12/G25/h: yeni-desenli hayalet atif -- S3 isirmali (bozulmadi)",
                       _UC_HAYALET_ATIF_YENI, ["S3"]))
    _yaz("=" * 74)
    gecti = sum(1 for x in sonuc if x)
    _yaz("HUKUM: %d/%d GECTI -- %s" % (gecti, len(sonuc),
         "ARAC KULLANILABILIR" if gecti == len(sonuc) else "ARAC KULLANILAMAZ"))
    _yaz("=" * 74)
    return 0 if gecti == len(sonuc) else 1


def main(argv):
    if argv and argv[0] == "--altin-kume":
        return altin_kume()
    if not argv:
        _yaz("KULLANIM: python araclar\\spec-kapi-kapsama.py [--altin-kume] <spec.md>")
        return 3
    try:
        metin = open(argv[0], "rb").read().decode("utf-8")
    except Exception as e:
        _yaz("ORTAM HATASI: " + str(e))
        return 3
    bulgular, ozet = denetle(metin)
    _yaz("=" * 74)
    _yaz("SPEC KAPI KAPSAMA -- " + argv[0])
    _yaz("=" * 74)
    if ozet:
        kapilar, kurallar, muts, borc = ozet
        _yaz("KAPI  (%d): %s" % (len(kapilar), ", ".join(kapilar)))
        _yaz("KURAL (%d): %s" % (len(kurallar), ", ".join(kurallar)))
        _yaz("MUTANT(%d): %s" % (len(muts), ", ".join(sorted(muts, key=lambda x: (len(x), x)))))
        if borc:
            _yaz("BEYAN EDILMIS MUTANT BORCU (%d) -- gizlenmiyor, SAYILIYOR:" % len(borc))
            for r in sorted(borc):
                _yaz("   * " + r + " -- " + borc[r])
        _yaz("-" * 74)
    for k, m in bulgular:
        _yaz("[" + k + "] " + m)
    if not bulgular:
        _yaz("BULGU YOK: her KAPI'nin mutanti var; mutantsiz her KURAL icin")
        _yaz("BEYAN EDILMIS ve GEREKCELI bir borc kaydi var.")
    _yaz("-" * 74)
    _yaz("BEYAN EDILMIS SINIR: bu betik mutantin GERCEKTEN ISIRDIGINI olcmez;")
    _yaz("esdeger-mutant tespiti calisan kod ister. Yalnizca KAPSAMA olculur.")
    _yaz("=" * 74)
    if any(k == "S0" for k, _ in bulgular):
        return 3
    return 1 if bulgular else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

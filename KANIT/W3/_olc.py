# -*- coding: utf-8 -*-
"""W3 SPEC OLCUM BETIGI -- K44-a (once arac, sonra belge) / K150-b onarimi.

_v2_olc.py'nin kusuru: mutant HEDEFLERINI **tum belgeden** grepliyordu
(`re.findall(r"G4[3-7]/[a-h]", txt)`). Sonuc: yalnizca s9'da ("NE OLCULEMEDI")
gecen `G46/e` **mutant hedefi sanildi** ve kor ayak YANLIS-NEGATIF oldu.
Bu, v1'i dusuren B4 kusurunun (kapi kendi spec'ini olcer) olcum aracinin
icinde yeniden dogmus haliydi.

Onarim: hedefler YALNIZ s6 mutant tablosunun UCUNCU SUTUNUNDAN okunur
(K126 sutun sirasi: no | tip | hedef | ...). Kaynak: _denetci_kapsama.py.

Kullanim:
    python KANIT/W3/_olc.py <spec-yolu>
    python KANIT/W3/_olc.py --altin-kume
"""
import hashlib, io, os, re, sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")   # ORTAM.md: cp1254
except Exception:
    pass

AYAK_D = r"(?m)^- \*\*([a-h])\)\*\*"
KAPI_D = r"(?m)^### (G4[3-7]) "
HEDEF_D = r"G4[3-7]/[a-h]"
# spec-kapi-kapsama.py:145'in kanonik s6b deseni -- v2 DORT alanli yazdi ve
# kanonik arac EXIT 1 verdi (K150-c). Bu betik ayni deseni olcer ki sapma
# belge yazilmadan ONCE gorulsun.
KANONIK_6B = re.compile(r"^\s*-\s*KURAL:\s*([^|]+)\|\s*GEREKCE:\s*(.*)$")


def ayrıstır(txt):
    ayak = []
    for m in re.finditer(KAPI_D, txt):
        g = m.group(1)
        son = txt.find("\n### ", m.end())
        blok = txt[m.end(): son if son > 0 else len(txt)]
        for a in re.findall(AYAK_D, blok):
            ayak.append(g + "/" + a)

    hedef = {}
    for ln in txt.split("\n"):
        if not ln.lstrip().startswith("|"):
            continue
        h = [c.strip() for c in ln.strip().strip("|").split("|")]
        if len(h) < 3:
            continue
        no = re.sub(r"[`*]", "", h[0]).strip()
        if not re.match(r"^(M\d+|MW\d+)$", no):
            continue
        hedef[no] = set(re.findall(HEDEF_D, h[2]))     # <-- YALNIZ 3. SUTUN

    kapsanan = set()
    for v in hedef.values():
        kapsanan |= v
    kor = [a for a in ayak if a not in kapsanan]

    b6 = ""
    if "## 6b." in txt and "## 7." in txt:
        b6 = txt.split("## 6b.")[1].split("## 7.")[0]
    b6_ayak = set(re.findall(HEDEF_D, b6))
    kor2 = [a for a in kor if a not in b6_ayak]

    # KOR NOKTA (o61'de kendi kendini isirdi): once yalniz "- ...KURAL..." satirlari
    # sayiliyordu; v2'nin 6b'si TABLO oldugu icin sayim 0 cikti ve betik "borc YOK"
    # ile "borc VAR ama BICIMI YANLIS"i AYIRT EDEMEDI. Simdi bicimden BAGIMSIZ sayar.
    b6_satir = [l for l in b6.split("\n")
                if ("KURAL" in l.upper() or re.search(r"B-W3-\d+", l))
                and l.strip() and not l.strip().startswith("#")]
    b6_kanonik = [l for l in b6_satir if KANONIK_6B.match(l)]
    return dict(ayak=ayak, hedef=hedef, kapsanan=kapsanan, kor=kor,
                b6_ayak=b6_ayak, kor2=kor2,
                b6_satir=len(b6_satir), b6_kanonik=len(b6_kanonik))


def olc(yol):
    ham = open(yol, "rb").read()
    txt = ham.decode("utf-8")
    r = ayrıstır(txt)
    print("=" * 74)
    print("W3 SPEC OLCUMU -- %s" % yol)
    print("=" * 74)
    print("KIMLIK  : %d b  sha8=%s  BOM=%s  CRLF=%d  U+FFFD=%d" % (
        len(ham), hashlib.sha256(ham).hexdigest()[:8].upper(),
        "VAR" if ham[:3] == b"\xef\xbb\xbf" else "yok",
        ham.count(b"\r\n"), txt.count("\ufffd")))   # KACIS ile: literal U+FFFD
        # yazmak betigin KENDI kimligini KIRLI yapar (o61'de dosya-kimlik.py
        # tam bunu soyledi) -- olcen el, olctugu kusuru TASIMAMALIDIR.
    print("          (OLCULDU -- kopyalanmadi; K151-b: kopyalanan kimlik bayatlar)")
    print("TANIMLI AYAK               = %d" % len(r["ayak"]))
    print("TABLODAKI MUTANT           = %d (kusurlu %d, susmali %d)" % (
        len(r["hedef"]),
        len([k for k in r["hedef"] if not k.startswith("MW")]),
        len([k for k in r["hedef"] if k.startswith("MW")])))
    print("HEDEF SUTUNUNDA GECEN AYAK = %d" % len(r["kapsanan"]))
    print("MUTANT HEDEFI OLMAYAN (%d) : %s" % (
        len(r["kor"]), ", ".join(r["kor"]) if r["kor"] else "(yok)"))
    print("6b'DE ADIYLA GECEN AYAK    : %s" % (", ".join(sorted(r["b6_ayak"])) or "(yok)"))
    print("6b SATIRI                  = %d, KANONIK BICIMDE = %d %s" % (
        r["b6_satir"], r["b6_kanonik"],
        "" if r["b6_satir"] == r["b6_kanonik"]
        else "<-- SAPMA: spec-kapi-kapsama.py bu satirlari GORMEZ (K150-c)"))
    print()
    print(">>> NE MUTANTI NE 6b BORCU OLAN AYAK (%d): %s" % (
        len(r["kor2"]), ", ".join(r["kor2"]) if r["kor2"] else "(yok)"))
    return 0 if (not r["kor2"] and r["b6_satir"] == r["b6_kanonik"]) else 1


# --------------------------------------------------------------------------
def altin_kume():
    print("=" * 74)
    print("ALTIN KUME -- betik once KENDINI kanitlar (kor kapi yok)")
    print("=" * 74)
    gecti = kaldi = 0

    def kp(ad, txt, bekle_kor2, bekle_kanonik=None):
        nonlocal gecti, kaldi
        r = ayrıstır(txt)
        ok = sorted(r["kor2"]) == sorted(bekle_kor2)
        if bekle_kanonik is not None:
            ok = ok and (r["b6_kanonik"] == bekle_kanonik)
        print("\n[%s] %s" % ("GECTI" if ok else "KALDI", ad))
        print("    beklenen kor2=%s%s · olculen kor2=%s (6b kanonik=%d)" % (
            bekle_kor2, "" if bekle_kanonik is None else (" 6b=%d" % bekle_kanonik),
            sorted(r["kor2"]), r["b6_kanonik"]))
        if ok:
            gecti += 1
        else:
            kaldi += 1

    GOVDE = ("### G46 — ornek kapi\n"
             "- **d)** bir ayak\n"
             "- **e)** baska bir ayak\n\n"
             "| no | tip | hedef | yama |\n|---|---|---|---|\n"
             "| `M001` | statik | `G46/d` | bir sey |\n")

    # 1) K150-b'NIN TA KENDISI: G46/e yalniz GOVDE METNINDE (s9) geciyor;
    #    hedef sutununda YOK => KOR ayak olarak GORULMELI.
    kp("1) ayak yalniz GOVDEDE geciyor (s9) -- hedef sutununda YOK => KOR",
       GOVDE + "\n## 9. NE OLCULEMEDI\n- `G46/e` olculemedi.\n", ["G46/e"])

    # 2) hedef sutununda gecen ayak KOR SAYILMAZ
    kp("2) ayak HEDEF SUTUNUNDA -- kor sayilmamali",
       GOVDE.replace("| `G46/d` |", "| `G46/d`, `G46/e` |"), [])

    # 3) 6b'de adiyla gecen kor ayak, kor2'den DUSER (beyan edilmis borc)
    kp("3) kor ayak 6b'de BEYAN EDILMIS -- kor2'den dusmeli, bicim KANONIK",
       GOVDE + "\n## 6b. MUTANT BORCU\n- KURAL: `G46/e` olculmez | GEREKCE: tarayici ister\n"
               "\n## 7. KABUL\n", [], bekle_kanonik=1)

    # 4) 6b DORT ALANLI yazilirsa kanonik arac GORMEZ (K150-c)
    kp("4) 6b DORT ALANLI -- kanonik bicim sayisi 0 olmali (K150-c)",
       GOVDE + "\n## 6b. MUTANT BORCU\n- B-W3-9 | KURAL: `G46/e` | NEDEN: tarayici | KAPATMA: T9\n"
               "\n## 7. KABUL\n", [], bekle_kanonik=0)

    # 5) "borc YOK" ile "borc VAR ama BICIMI YANLIS" AYRILMALI -- yoksa betik
    #    v2'nin TABLO bicimli 6b'sine "0 satir" der ve sessizce yanlis rapor verir.
    r5 = ayrıstır(GOVDE + "\n## 6b. MUTANT BORCU\n"
                  "| id | KURAL | NEDEN | KAPATMA |\n|---|---|---|---|\n"
                  "| B-W3-9 | `G46/e` olculmez | tarayici ister | T9 |\n\n## 7. KABUL\n")
    ok5 = (r5["b6_satir"] > 0 and r5["b6_kanonik"] == 0)
    print("\n[%s] 5) 6b TABLO bicimli -- borc GORULMELI ama KANONIK SAYILMAMALI"
          % ("GECTI" if ok5 else "KALDI"))
    print("    beklenen: satir>0 ve kanonik=0 · olculen: satir=%d kanonik=%d"
          % (r5["b6_satir"], r5["b6_kanonik"]))
    if ok5:
        gecti += 1
    else:
        kaldi += 1

    print("\n" + "=" * 74)
    print("HUKUM: %d/%d GECTI -- %s" % (gecti, gecti + kaldi,
          "BETIK KULLANILABILIR" if kaldi == 0 else "BETIK KULLANILAMAZ"))
    print("=" * 74)
    return 0 if kaldi == 0 else 1


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "--altin-kume":
        return altin_kume()
    yol = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
        "GOREV_CLAUDE_CODE", "GOREV-W3-capraz-koken-izolasyonu.md")
    return olc(yol)


if __name__ == "__main__":
    sys.exit(main())

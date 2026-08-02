# -*- coding: utf-8 -*-
"""COWORK BAGIMSIZ TABAN OLCUMU -- GOREV-A12 kabul kriteri 0.

ONARIM ONCESI referans: spec-kapi-kapsama.py'nin BUGUNKU hukmu, GOREV_CLAUDE_CODE
altindaki HER .md icin. Builder onarimdan SONRA ayni olcumu tekrarlar; fark > 0 ise
A12 kriter 0 geregi DURULUR ve Onur'a sorulur.

BU BETIK URUN KODU DEGILDIR (K55) -- olcum aracidir.
Yazim K60: once encode, sonra .tmp, en son takas.
"""
import hashlib
import os
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BU = os.path.dirname(os.path.abspath(__file__))
KOK = os.path.abspath(os.path.join(BU, "..", ".."))
ARAC = os.path.join(KOK, "araclar", "spec-kapi-kapsama.py")
SPECDIZIN = os.path.join(KOK, "GOREV_CLAUDE_CODE")
HEDEF = os.path.join(BU, "00-COWORK-TABAN-ONCESI.txt")


def kos(spec_yolu):
    s = subprocess.run(
        [sys.executable, ARAC, spec_yolu],
        capture_output=True, text=True, encoding="utf-8", errors="replace", cwd=KOK,
    )
    return s.returncode, (s.stdout or "") + (s.stderr or "")


def ayikla(cikti):
    kapi = kural = mutant = "[SATIR YOK]"
    bulgular = []
    for satir in cikti.splitlines():
        d = satir.strip()
        if d.startswith("KAPI"):
            kapi = d
        elif d.startswith("KURAL"):
            kural = d
        elif d.startswith("MUTANT"):
            mutant = d
        elif d.startswith("[S"):
            bulgular.append(d)
    return kapi, kural, mutant, bulgular


def main():
    adlar = sorted(a for a in os.listdir(SPECDIZIN) if a.lower().endswith(".md"))
    satirlar = ["COWORK BAGIMSIZ TABAN OLCUMU -- spec-kapi-kapsama.py, ONARIM ONCESI",
                "spec sayisi: %d" % len(adlar), "=" * 78]
    toplam_bulgu = 0
    for ad in adlar:
        rc, cikti = kos(os.path.join(SPECDIZIN, ad))
        kapi, kural, mutant, bulgular = ayikla(cikti)
        toplam_bulgu += len(bulgular)
        satirlar.append("%-52s EXIT=%d" % (ad, rc))
        satirlar.append("    " + kapi)
        satirlar.append("    " + kural)
        satirlar.append("    " + mutant)
        for b in bulgular:
            satirlar.append("    >> " + b)
    satirlar.append("=" * 78)
    satirlar.append("TOPLAM BULGU: %d" % toplam_bulgu)
    metin = "\n".join(satirlar) + "\n"
    ham = metin.encode("utf-8")
    tmp = HEDEF + ".tmp"
    with open(tmp, "wb") as f:
        f.write(ham)
    if os.path.exists(HEDEF):
        yedek = HEDEF + ".yedek"
        os.rename(HEDEF, yedek)
        os.rename(tmp, HEDEF)
        os.remove(yedek)
    else:
        os.rename(tmp, HEDEF)
    sha = hashlib.sha256(open(HEDEF, "rb").read()).hexdigest()[:8].upper()
    print(metin)
    print("YAZILDI: %s  (%d b, sha8 %s)" % (HEDEF, len(ham), sha))


main()

# -*- coding: utf-8 -*-
"""COWORK BAGIMSIZ KRITER 3a OLCUMU -- GOREV-A12.

Kriter 3a: SS6b borc kayitlari YAZILMADAN ONCE A11 EXIT=1 + TAM 6 adet [S2],
A12 EXIT=1 + TAM 3 adet [S2] olmali (envanterin gercekten doldugunun kaniti).

ORIJINAL SPEC DOSYALARINA DOKUNULMAZ: kopya uzerinde olculur ve orijinalin
sha256'si once/sonra karsilastirilarak dokunulmadigi KANITLANIR.
"""
import hashlib
import os
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BU = os.path.dirname(os.path.abspath(__file__))
KOK = os.path.abspath(os.path.join(BU, "..", ".."))
ARAC = os.path.join(KOK, "araclar", "spec-kapi-kapsama.py")
SPECDIZIN = os.path.join(KOK, "GOREV_CLAUDE_CODE")
GECICI = os.path.join(BU, "_krit3a")
os.makedirs(GECICI, exist_ok=True)

HEDEFLER = [("GOREV-A11-ag-donus-itmesi.md", 6), ("GOREV-A12-kural-envanteri.md", 3)]


def sha(yol):
    with open(yol, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()[:8].upper()


def kos(yol):
    s = subprocess.run([sys.executable, ARAC, yol], capture_output=True, text=True,
                       encoding="utf-8", errors="replace", cwd=KOK)
    return s.returncode, (s.stdout or "") + (s.stderr or "")


for ad, beklenen in HEDEFLER:
    yol = os.path.join(SPECDIZIN, ad)
    once_sha = sha(yol)
    with open(yol, "rb") as f:
        govde = f.read().decode("utf-8")

    # 3b: BUGUNKU hal (borc kayitlari YERINDE)
    rc_b, cikti_b = kos(yol)
    s2_b = [x.strip() for x in cikti_b.splitlines() if x.strip().startswith("[S2]")]
    kural0_b = "KURAL (0)" in cikti_b

    # 3a: borc kayitlari KALDIRILMIS kopya
    satirlar = govde.split("\n")
    kalan = [s for s in satirlar if not re.match(r"^\s*-\s*KURAL:\s", s)]
    kaldirilan = len(satirlar) - len(kalan)
    kopya = os.path.join(GECICI, ad)
    with open(kopya, "wb") as f:
        f.write("\n".join(kalan).encode("utf-8"))
    rc_a, cikti_a = kos(kopya)
    s2_a = [x.strip() for x in cikti_a.splitlines() if x.strip().startswith("[S2]")]

    sonra_sha = sha(yol)
    print("=" * 78)
    print("%s  (orijinal sha8 %s -> %s  %s)"
          % (ad, once_sha, sonra_sha, "DOKUNULMADI" if once_sha == sonra_sha else "SAPTI!"))
    print("  3a (borc kayitlari KALDIRILMIS kopya, %d satir cikarildi):" % kaldirilan)
    print("     EXIT=%d  |  [S2] sayisi=%d  (beklenen %d)  %s"
          % (rc_a, len(s2_a), beklenen,
             "GECTI" if (rc_a == 1 and len(s2_a) == beklenen) else "KALDI"))
    for x in s2_a:
        print("        " + x)
    print("  3b (bugunku hal, borc kayitlari YERINDE):")
    print("     EXIT=%d  |  [S2] sayisi=%d  |  'KURAL (0)' yaziyor mu: %s  %s"
          % (rc_b, len(s2_b), "EVET" if kural0_b else "HAYIR",
             "GECTI" if (rc_b == 0 and not s2_b and not kural0_b) else "KALDI"))
print("=" * 78)

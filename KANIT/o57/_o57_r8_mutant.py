# -*- coding: utf-8 -*-
"""R8 MUTANTI -- 'oturum 57 de 0 urun koduyla kapanirsa R8 yanar' iddiasini
KANITLAR. Gercek defter DEGISTIRILMEZ: kopya bir dizinde kosulur.
KOR KAPI YOK: once R8'in SUSTUGU (kontrol), sonra ISIRDIGI olculur.
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"
DEFTER = os.path.join(KOK, "PROJE_RADAR.jsonl")


def kos(dizin, etiket):
    p = subprocess.run([sys.executable, os.path.join(KOK, "araclar", "radar.py"), dizin],
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    r8 = [s.strip() for s in (p.stdout or "").splitlines() if "R8" in s]
    print("[%s] cikis=%d · R8 satiri=%d" % (etiket, p.returncode, len(r8)))
    for s in r8:
        print("      %s" % s)
    return len(r8)


gecici = tempfile.mkdtemp(prefix="r8mutant_")
try:
    hedef = os.path.join(gecici, "PROJE_RADAR.jsonl")
    shutil.copy2(DEFTER, hedef)
    n_kontrol = kos(gecici, "KONTROL: defter oldugu gibi")

    sahte = {"tarih": "2026-08-04", "oturum": 57, "urun_kodu_satiri": 0,
             "artefakt": "DURUM.md", "tur": 25, "asama": "MUTANT -- gercek degil",
             "bulgu": {"bloker": 0, "major": 0, "minor": 0}, "siniflar": [],
             "bayt": 30329, "kapatilan": 1, "uretilen": 0, "not": "MUTANT"}
    with open(hedef, "ab") as f:
        f.write((json.dumps(sahte, ensure_ascii=True) + "\n").encode("utf-8"))
    n_mutant = kos(gecici, "MUTANT: oturum 57 de 0 urun kodu")

    print("-" * 70)
    if n_kontrol == 0 and n_mutant > 0:
        print("HUKUM: R8 ISIRDI. Iddia KANITLANDI -- oturum 57 sifir urun koduyla")
        print("       kapanirsa SERT DURAK yanar (K53/4).")
    elif n_kontrol > 0:
        print("HUKUM: KONTROL KIRLI -- R8 zaten yaniyordu, mutant bir sey kanitlamaz.")
    else:
        print("HUKUM: R8 ISIRMADI. Iddiam YANLIS -- R8 penceresi bekledigim gibi degil.")
    print("gercek defter DOKUNULMADI: %d bayt" % os.path.getsize(DEFTER))
finally:
    shutil.rmtree(gecici, ignore_errors=True)

# -*- coding: utf-8 -*-
"""A13 KABUL - COWORK'UN KENDI KOSUMU, 1. parti (K26: builder'in beyanina guvenilmez).
Kriter 1 ve 3-4'un statik ayaklari + builder'in OZET iddiasi."""
import subprocess, sys, os
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"

def kos(baslik, arg, kes=2200):
    p = subprocess.run([sys.executable] + arg, cwd=KOK, capture_output=True,
                       text=True, encoding="utf-8", errors="replace")
    print("=" * 72)
    print("### %s   EXIT=%d" % (baslik, p.returncode))
    o = (p.stdout or "").strip()
    print(o[-kes:] if len(o) > kes else o)
    e = (p.stderr or "").strip()
    if e:
        print("[stderr] " + e[-700:])
    return p.returncode

kos("ci-kapisi --help", [r"araclar\ci-kapisi.py", "--help"], 900)
kos("KRITER 1: ci-kapisi --altin-kume (COWORK KOSUYOR)", [r"araclar\ci-kapisi.py", "--altin-kume"], 2600)
kos("KRITER 3-4: ci-kapisi . (gercek depo)", [r"araclar\ci-kapisi.py", "."], 2600)

print("=" * 72)
print("### BUILDER'IN OZET IDDIASI (KANIT/A13/08-OZET.md) -- OKUNUYOR, ONAYLANMIYOR")
with open(os.path.join(KOK, "KANIT", "A13", "08-OZET.md"), encoding="utf-8", errors="replace") as f:
    print(f.read())
print("=" * 72)
print("### ci.yml TAM ICERIK (COWORK KENDI OKUYOR)")
with open(os.path.join(KOK, ".github", "workflows", "ci.yml"), encoding="utf-8", errors="replace") as f:
    print(f.read())

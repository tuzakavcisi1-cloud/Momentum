# -*- coding: utf-8 -*-
"""Oturum 52 acilis adim 5-6: oturum-sagligi + radar (altin kume + kosum)."""
import subprocess, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"
KOSUMLAR = [
    ("adim5a oturum-sagligi --altin-kume", [r"araclar\oturum-sagligi.py", "--altin-kume"], 700),
    ("adim5b oturum-sagligi .", [r"araclar\oturum-sagligi.py", "."], 2200),
    ("adim6a radar --altin-kume", [r"araclar\radar.py", "--altin-kume"], 700),
    ("adim6b radar .", [r"araclar\radar.py", "."], 3000),
]
for ad, arg, kes in KOSUMLAR:
    p = subprocess.run([sys.executable] + arg, cwd=KOK, capture_output=True,
                       text=True, encoding="utf-8", errors="replace")
    print("=" * 72)
    print("### %s   EXIT=%d" % (ad, p.returncode))
    out = (p.stdout or "").strip()
    print(out[-kes:] if len(out) > kes else out)
    err = (p.stderr or "").strip()
    if err:
        print("--- STDERR ---")
        print(err[-1000:])
print("=" * 72)
print("KOSUM BITTI")

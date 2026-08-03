# -*- coding: utf-8 -*-
"""Oturum 52 acilis protokolu adim 2-4b: kapilari kos, EXIT kodlarini olc."""
import subprocess, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"
KAPILAR = [
    ("adim2  tek-kopya-kapisi", [r"araclar\tek-kopya-kapisi.py", "."]),
    ("adim3  belge-tavan-kapisi", [r"araclar\belge-tavan-kapisi.py", "."]),
    ("adim4  sayi-tazeligi", [r"araclar\sayi-tazeligi.py", "."]),
    ("adim4b kapi-ad-teklik-kapisi", [r"araclar\kapi-ad-teklik-kapisi.py", "."]),
]
for ad, arg in KAPILAR:
    p = subprocess.run([sys.executable] + arg, cwd=KOK, capture_output=True,
                       text=True, encoding="utf-8", errors="replace")
    print("=" * 72)
    print("### %s   EXIT=%d" % (ad, p.returncode))
    out = (p.stdout or "").strip()
    print(out[-2600:] if len(out) > 2600 else out)
    err = (p.stderr or "").strip()
    if err:
        print("--- STDERR ---")
        print(err[-1200:])
print("=" * 72)
print("KOSUM BITTI")

# -*- coding: utf-8 -*-
"""A13 spec'ini ARACLA olc: kapi-kapsama (YOL ile, K81) + ad-teklik + kimlik."""
import subprocess, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"
SPEC = r"GOREV_CLAUDE_CODE\GOREV-A13-ios-iskeleti-ci.md"

KOSUMLAR = [
    ("spec-kapi-kapsama (ALTIN KUME)", [r"araclar\spec-kapi-kapsama.py", "--altin-kume"], 900),
    ("spec-kapi-kapsama (A13 SPEC, yol ile)", [r"araclar\spec-kapi-kapsama.py", SPEC], 3000),
    ("kapi-ad-teklik-kapisi (tum depo)", [r"araclar\kapi-ad-teklik-kapisi.py", "."], 2200),
    ("dosya-kimlik (A13 spec)", [r"araclar\dosya-kimlik.py", SPEC], 900),
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

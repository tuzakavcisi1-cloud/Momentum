# -*- coding: utf-8 -*-
import os
import subprocess
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

KOK = r"C:\dev\Momentum"
p = subprocess.run([sys.executable, os.path.join(KOK, "araclar", "belge-tavan-kapisi.py"), "."],
                   cwd=KOK, capture_output=True, text=True, encoding="utf-8", errors="replace")
for s in (p.stdout or "").split("\n"):
    d = s.strip()
    if d.startswith(("DURUM.md", "ORTAM.md", "BORCLAR.md", "CLAUDE.md", "DESIGN.md", "KAPILAR.md",
                     "HUKUM", "[SARI]", "[KIRMIZI]", "bulgu")):
        print(d[:160])
print("EXIT=%d" % p.returncode)

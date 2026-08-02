# -*- coding: utf-8 -*-
import os
import subprocess
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

KOK = r"C:\dev\Momentum"
p = subprocess.run([sys.executable, os.path.join(KOK, "araclar", "sayi-tazeligi.py"), "."],
                   cwd=KOK, capture_output=True, text=True, encoding="utf-8", errors="replace")
c = (p.stdout or "") + (p.stderr or "")
for s in c.split("\n"):
    d = s.strip()
    if d.startswith(("[KIRMIZI]", "[SARI]", "[BULGU]", "HUKUM", "[T")) or "BAYAT" in d.upper():
        print(d[:400])
print("EXIT=%d" % p.returncode)

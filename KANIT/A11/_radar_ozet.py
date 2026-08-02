# -*- coding: utf-8 -*-
import os
import subprocess
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

KOK = r"C:\dev\Momentum"
p = subprocess.run([sys.executable, os.path.join(KOK, "araclar", "radar.py"), "."],
                   cwd=KOK, capture_output=True, text=True, encoding="utf-8", errors="replace")
cikti = (p.stdout or "") + (p.stderr or "")
yakala = False
for s in cikti.split("\n"):
    d = s.strip()
    if "[PROJE GENELI" in d:
        yakala = True
    if yakala and d:
        print(d[:170])
print("EXIT=%d" % p.returncode)

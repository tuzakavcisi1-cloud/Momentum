# -*- coding: utf-8 -*-
import io
import os
import subprocess
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

KOK = r"C:\dev\Momentum"
YY = os.path.join(KOK, "araclar", "yoklama-yasagi-kapisi.py")

p = subprocess.run([sys.executable, YY, "--altin-kume"], cwd=KOK,
                   capture_output=True, text=True, encoding="utf-8", errors="replace")
c = (p.stdout or "") + (p.stderr or "")
vaka = [s.strip() for s in c.split("\n") if "vaka" in s.lower() or "HUKUM" in s]
print("== yoklama-yasagi --altin-kume  EXIT=%d" % p.returncode)
for s in vaka[-4:]:
    print("   " + s[:150])

p2 = subprocess.run([sys.executable, YY, "."], cwd=KOK,
                    capture_output=True, text=True, encoding="utf-8", errors="replace")
c2 = (p2.stdout or "") + (p2.stderr or "")
print("== yoklama-yasagi PROJE         EXIT=%d" % p2.returncode)
for s in [x.strip() for x in c2.split("\n") if "HUKUM" in x][-2:]:
    print("   " + s[:150])

with io.open(os.path.join(KOK, "KANIT", "A11", "03-MUTANT-M141.txt"),
             "r", encoding="utf-8", errors="replace") as f:
    bas = [s.strip() for s in f.read().split("\n")[:4]]
print("== KANIT/A11/03-MUTANT-M141.txt ilk 4 satir:")
for s in bas:
    print("   " + s[:150])

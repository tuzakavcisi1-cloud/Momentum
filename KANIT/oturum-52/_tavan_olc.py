# -*- coding: utf-8 -*-
"""Budama SONRASI belge tavani: yalniz hukum + T satirlari."""
import subprocess, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
p = subprocess.run([sys.executable, r"araclar\belge-tavan-kapisi.py", "."],
                   cwd=r"C:\dev\Momentum", capture_output=True, text=True,
                   encoding="utf-8", errors="replace")
print("EXIT=%d" % p.returncode)
for s in (p.stdout or "").splitlines():
    t = s.rstrip()
    if ("[SARI]" in t or "[KIRMIZI]" in t or t.startswith("HUKUM")
            or "DURUM.md " in t or "BORCLAR.md " in t):
        print("  " + t[:230])

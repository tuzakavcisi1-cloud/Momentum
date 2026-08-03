# -*- coding: utf-8 -*-
"""R8 (urun kodu durgunlugu) DURUMUNU OLC -- beyan degil, radar ciktisindan."""
import subprocess, sys, re
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"

p = subprocess.run([sys.executable, r"araclar\radar.py", "."], cwd=KOK,
                   capture_output=True, text=True, encoding="utf-8", errors="replace")
tam = p.stdout or ""
with open(r"C:\dev\Momentum\KANIT\oturum-52\radar-tam-cikti.txt", "w",
          encoding="utf-8", errors="replace") as f:
    f.write(tam)
print("radar EXIT=%d, cikti %d karakter (tam metin radar-tam-cikti.txt'ye yazildi)" %
      (p.returncode, len(tam)))
print("=" * 72)
print("R / R8 SATIRLARI:")
for s in tam.splitlines():
    if re.search(r"\bR\d\b|urun_kodu|URUN KODU|R8", s):
        print("  " + s.rstrip())
print("=" * 72)
print("SON 60 SATIR (hukum bolgesi):")
for s in tam.splitlines()[-60:]:
    print("  " + s.rstrip())

# -*- coding: utf-8 -*-
"""Defter yazildiktan SONRA R8'in (iki oturum ust uste 0 urun kodu) yanip
yanmadigini olcer. findstr KULLANILMAZ -- ORTAM.md: findstr ayni dosyada bir
dizgeyi bulup digerini KACIRABILIYOR."""
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"

p = subprocess.run([sys.executable, r"araclar\radar.py", "."],
                   cwd=KOK, capture_output=True, text=True,
                   encoding="utf-8", errors="replace")
cikti = (p.stdout or "") + (p.returncode and "" or "")
satirlar = cikti.splitlines()

print("radar cikis kodu : %d  (0=YESIL 1=SARI 2=KIRMIZI)" % p.returncode)
print("toplam cikti satiri: %d" % len(satirlar))
print("--- 'R8' GECEN HER SATIR ---")
bulundu = 0
for i, s in enumerate(satirlar):
    if "R8" in s:
        bulundu += 1
        print("  %s" % s.strip())
if bulundu == 0:
    print("  (R8 HIC GECMIYOR)")
print("--- HUKUM SATIRLARI ---")
for s in satirlar:
    if s.startswith("HUKUM") or "DEVRE KESICI" in s:
        print("  %s" % s.strip())
print("--- POZITIF KONTROL (arac gercekten ariyor mu?) ---")
print("  'R1' gecen satir sayisi : %d" % sum(1 for s in satirlar if "R1" in s))
print("  'KIRMIZI' gecen satir   : %d" % sum(1 for s in satirlar if "KIRMIZI" in s))
if p.stderr.strip():
    print("--- STDERR ---")
    print(p.stderr.strip()[:2000])

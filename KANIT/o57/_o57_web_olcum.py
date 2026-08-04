# -*- coding: utf-8 -*-
"""(9) WEB BORCU -- ILK OLCUM, spec DEGIL.
Soru: web hedefi BUGUN hala deriliyor mu? build/web/main.dart.js 29.07.2026
21:14 tarihli, yani slice-3d/3e + A11/A12/A13 + SS2 girmeden ONCEKI halden.
ORTAM.md: flutter bu makinede .bat'tir ve DC kabugunda PROGRAMFILES(X86)
enjekte edilmezse cokuyor.
"""
import os
import subprocess
import sys
import time

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
ISTEMCI = r"C:\dev\Momentum\src\client"
FLUTTER = r"C:\src\flutter\bin\flutter.bat"
HEDEF = os.path.join(ISTEMCI, "build", "web", "main.dart.js")


def durum(etiket):
    if os.path.exists(HEDEF):
        st = os.stat(HEDEF)
        print("[%s] main.dart.js  %d bayt  mtime %s"
              % (etiket, st.st_size,
                 time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(st.st_mtime))))
        return st.st_mtime, st.st_size
    print("[%s] main.dart.js YOK" % etiket)
    return None, None


onceki = durum("ONCE")
env = os.environ.copy()
env["PROGRAMFILES(X86)"] = r"C:\Program Files (x86)"
print("PROGRAMFILES(X86) enjekte edildi (ORTAM.md kalkani).")
print("KOSUYOR: flutter build web  (tavan 900 s)")

t0 = time.time()
try:
    p = subprocess.run([FLUTTER, "build", "web"], cwd=ISTEMCI, env=env,
                       capture_output=True, text=True, encoding="utf-8",
                       errors="replace", timeout=900)
    kod, cikti, hata = p.returncode, p.stdout or "", p.stderr or ""
except subprocess.TimeoutExpired:
    kod, cikti, hata = -1, "", "TAVAN ASILDI (900 s) -- build BITMEDI"
sure = time.time() - t0

print("sure: %.1f s · cikis kodu: %s" % (sure, kod))
print("--- STDOUT (son 40 satir) ---")
for s in cikti.splitlines()[-40:]:
    print("  " + s)
if hata.strip():
    print("--- STDERR (son 40 satir) ---")
    for s in hata.splitlines()[-40:]:
        print("  " + s)
sonraki = durum("SONRA")
degisti = (onceki != sonraki)
print("-" * 70)
print("ARTEFAKT DEGISTI Mi : %s" % ("EVET" if degisti else "HAYIR"))
print("HUKUM: %s" % ("WEB DERLENIYOR" if (kod == 0 and degisti) else
                     "WEB DERLENMIYOR ya da ARTEFAKT TAZELENMEDI -- ayrinti yukarida"))

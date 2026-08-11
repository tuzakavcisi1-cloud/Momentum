# -*- coding: utf-8 -*-
"""IS-EMRI-o70: emulator boot_completed=1 olana kadar YOKLAR (sabit sleep
DEGIL). Aralik 3sn, tavan 40 deneme (~120sn), is emrinin kendi degerleri."""
import subprocess
import sys
import time

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ADB = r"C:\Users\gulci\AppData\Local\Android\Sdk\platform-tools\adb.exe"
ARALIK_SN = 3
TAVAN_DENEME = 40


def cihazlar():
    r = subprocess.run([ADB, "devices"], capture_output=True, text=True,
                        encoding="utf-8", errors="replace")
    satirlar = [s for s in r.stdout.splitlines()[1:] if s.strip() and "\tdevice" in s]
    return [s.split("\t")[0] for s in satirlar]


baslangic = time.time()
for deneme in range(1, TAVAN_DENEME + 1):
    seriler = cihazlar()
    print("[deneme %d, %.1fsn] adb devices -> %r" % (deneme, time.time() - baslangic, seriler))
    if seriler:
        seri = seriler[0]
        r = subprocess.run([ADB, "-s", seri, "shell", "getprop", "sys.boot_completed"],
                            capture_output=True, text=True, encoding="utf-8", errors="replace")
        ham = r.stdout
        kirpilmis = ham.strip()
        print("  getprop sys.boot_completed HAM=%r KIRPILMIS=%r (\\r var mi: %s)" % (
            ham, kirpilmis, "\\r" in ham))
        if kirpilmis == "1":
            print("BOOT_COMPLETED -- seri=%s, %.1f sn'de" % (seri, time.time() - baslangic))
            sys.exit(0)
    time.sleep(ARALIK_SN)

print("TAVAN ASILDI -- boot_completed OLMADI")
sys.exit(3)

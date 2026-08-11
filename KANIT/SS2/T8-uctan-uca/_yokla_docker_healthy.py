# -*- coding: utf-8 -*-
"""IS-EMRI-o70 / ERRATUM 10: momentum-postgres 'healthy' olana kadar YOKLAR
(sabit sleep DEGIL). Aralik 2sn, tavan 30 deneme (~60sn). Kanit yazar."""
import subprocess
import sys
import time

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ARALIK_SN = 2
TAVAN_DENEME = 30


def durum_oku():
    r = subprocess.run(
        ["docker", "inspect", "--format", "{{.State.Health.Status}}", "momentum-postgres"],
        capture_output=True, text=True, encoding="utf-8", errors="replace",
    )
    return r.returncode, r.stdout.strip(), r.stderr.strip()


baslangic = time.time()
sonuc_satirlari = []
for deneme in range(1, TAVAN_DENEME + 1):
    kod, out, err = durum_oku()
    satir = "[deneme %d, %.1fsn] exit=%s stdout=%r stderr=%r" % (
        deneme, time.time() - baslangic, kod, out, err)
    print(satir)
    sonuc_satirlari.append(satir)
    if out == "healthy":
        print("HEALTHY -- %.1f sn'de" % (time.time() - baslangic))
        sys.exit(0)
    time.sleep(ARALIK_SN)

print("TAVAN ASILDI -- healthy OLMADI")
sys.exit(3)

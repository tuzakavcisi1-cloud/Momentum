# -*- coding: utf-8 -*-
"""COWORK'UN KENDI KOSUMU (K26 -- ureten degil DENETLEYEN kosar).
Code'un kriter1/2/3 dosyalarini OKUMAZ; zinciri BASTAN kosar.
Sira ORTAM.md'ye gore: once portlar OLCULUR (verify.ps1 calisan backend varken
MSB3026 ile duser), sonra verify -> analyze -> test.
"""
import os
import re
import subprocess
import sys
import time

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"
ISTEMCI = os.path.join(KOK, "src", "client")
FLUTTER = r"C:\src\flutter\bin\flutter.bat"
env = os.environ.copy()
env["PROGRAMFILES(X86)"] = r"C:\Program Files (x86)"


def kos(ad, cmd, cwd, tavan, kabuk=False):
    t0 = time.time()
    try:
        p = subprocess.run(cmd, cwd=cwd, env=env, capture_output=True, text=True,
                           encoding="utf-8", errors="replace", timeout=tavan, shell=kabuk)
        return ad, p.returncode, (p.stdout or "") + (p.stderr or ""), time.time() - t0
    except subprocess.TimeoutExpired:
        return ad, -1, "TAVAN ASILDI (%d s)" % tavan, time.time() - t0


# --- 1) PORTLAR (findstr YOK -- ORTAM.md) ---
p = subprocess.run(["netstat", "-ano"], capture_output=True, text=True,
                   encoding="utf-8", errors="replace")
dinleyen = {}
for s in (p.stdout or "").splitlines():
    if "LISTENING" not in s:
        continue
    m = re.search(r":(\d+)\s", s)
    if m and m.group(1) in ("5298", "5000"):
        dinleyen.setdefault(m.group(1), []).append(s.strip())
print("=" * 74)
for port in ("5298", "5000"):
    v = dinleyen.get(port, [])
    print("PORT %s : %s" % (port, ("LISTENING (%d satir)" % len(v)) if v else "BOS"))
    for s in v[:2]:
        print("    " + s)
print("POZITIF KONTROL: netstat toplam LISTENING satiri = %d"
      % sum(1 for s in (p.stdout or "").splitlines() if "LISTENING" in s))
print("=" * 74)
if dinleyen.get("5298"):
    print("[DUR] :5298 DINLIYOR -- ORTAM.md: verify.ps1 calisan Momentum.Api varken")
    print("      EXIT 1 + MSB3026 verir ve bu URUN kusuru DEGILDIR. Once kapatilmali.")
    sys.exit(3)

sonuclar = []
sonuclar.append(kos("kriter1 verify.ps1",
                    ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass",
                     "-File", os.path.join(KOK, "araclar", "verify.ps1")], KOK, 1800))
sonuclar.append(kos("kriter2 flutter analyze",
                    [FLUTTER, "analyze", "--fatal-infos"], ISTEMCI, 1200))
sonuclar.append(kos("kriter3 flutter test", [FLUTTER, "test"], ISTEMCI, 2400))

print("=" * 74)
for ad, kod, cikti, sure in sonuclar:
    print("--- %s  ·  cikis=%s  ·  %.1f s ---" % (ad, kod, sure))
    ilgi = [s for s in cikti.splitlines()
            if re.search(r"(All tests passed|No issues found|issues? found|Failed|error|Error|"
                         r"HATA|BASARILI|EXIT|Passed!|Build succeeded|uyari|warning|"
                         r"\d+ tests? passed|test.*passed)", s)]
    for s in ilgi[-14:]:
        print("    " + s.strip()[:150])
    if not ilgi:
        for s in cikti.splitlines()[-8:]:
            print("    " + s.strip()[:150])
print("=" * 74)
print("HUKUM: " + " · ".join("%s=%s" % (a.split()[0], k) for a, k, _, _ in sonuclar))

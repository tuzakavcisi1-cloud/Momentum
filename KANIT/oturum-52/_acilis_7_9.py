# -*- coding: utf-8 -*-
"""Oturum 52 acilis adim 7 (git) + adim 9 (ortam) -- BEYAN YOK, OLCUM VAR."""
import subprocess, sys, os
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"
ADB = r"C:\Users\gulci\AppData\Local\Android\Sdk\platform-tools\adb.exe"

def kos(baslik, cmd, cwd=KOK):
    print("-" * 72)
    print("### " + baslik)
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True,
                           encoding="utf-8", errors="replace", timeout=180)
    except Exception as e:
        print("HATA: %r" % (e,))
        return None
    print("EXIT=%d" % p.returncode)
    o = (p.stdout or "").strip()
    e = (p.stderr or "").strip()
    print(o if o else "(stdout bos)")
    if e:
        print("[stderr] " + e[-800:])
    return p

print("=" * 72)
print("ADIM 7 -- GIT (fetch ATLANMAZ; --no-optional-locks zorunlu)")
print("=" * 72)
kos("git fetch origin", ["git", "--no-optional-locks", "fetch", "origin"])
kos("git log --oneline -1", ["git", "--no-optional-locks", "log", "--oneline", "-1"])
kos("git rev-list --left-right --count origin/main...HEAD  (SOL=geri SAG=ileri)",
    ["git", "--no-optional-locks", "rev-list", "--left-right", "--count", "origin/main...HEAD"])
kos("git status --porcelain", ["git", "--no-optional-locks", "status", "--porcelain"])
kilit = os.path.join(KOK, ".git", "index.lock")
print("-" * 72)
print("### .git/index.lock var mi? -> %s" % os.path.exists(kilit))

print("=" * 72)
print("ADIM 9 -- ORTAM (K80: beyan yok, olcum var)")
print("=" * 72)
kos("docker ps -a --filter name=momentum-postgres",
    ["docker", "ps", "-a", "--filter", "name=momentum-postgres",
     "--format", "{{.Names}} | {{.Status}} | {{.Ports}}"])
p = kos("netstat -ano (ham) -- :5298 satirlari Python ile suzuluyor",
        ["netstat", "-ano"])
print("--- :5298 SUZGEC ---")
if p and p.stdout:
    satirlar = [s.rstrip() for s in p.stdout.splitlines() if ":5298" in s]
    print("\n".join(satirlar) if satirlar else "(:5298 ile eslesen SATIR YOK -> backend DINLEMIYOR)")
else:
    print("netstat olculemedi")
print("-" * 72)
print("### adb (TAM YOL) -- PATH'te yok, K86 dersi")
print("adb.exe var mi: %s" % os.path.exists(ADB))
kos("adb devices", [ADB, "devices"], cwd=None)
print("=" * 72)
print("KOSUM BITTI")

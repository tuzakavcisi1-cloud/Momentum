# -*- coding: utf-8 -*-
# Oturum 55 KABUL KOSUMU (K26: Cowork'un KENDI kosumu, builder'in beyani degil).
# ORTAM.md: flutter .bat'tir; PROGRAMFILES(X86) enjekte edilmezse DC kabugu coker.
import os, subprocess, sys, io
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

FLUTTER = r"C:\src\flutter\bin\flutter.bat"
CWD     = r"C:\dev\Momentum\src\client"
KANIT   = r"C:\dev\Momentum\KANIT\SS2"

env = dict(os.environ)
env["PROGRAMFILES(X86)"] = r"C:\Program Files (x86)"   # ORTAM.md kalkani

if not os.path.exists(FLUTTER):
    print("HATA: flutter.bat YOK:", FLUTTER); sys.exit(9)

def kos(ad, argv, dosya, timeout):
    print("\n" + "=" * 70)
    print("KOSUM:", ad, "->", " ".join(argv))
    try:
        p = subprocess.run(argv, cwd=CWD, env=env, capture_output=True,
                           text=True, encoding="utf-8", errors="replace", timeout=timeout)
        cikti = (p.stdout or "") + ("\n--- STDERR ---\n" + p.stderr if p.stderr else "")
        rc = p.returncode
    except subprocess.TimeoutExpired as e:
        cikti = "TIMEOUT %ss\n" % timeout + str(e.stdout or "")
        rc = -1
    with io.open(os.path.join(KANIT, dosya), "w", encoding="utf-8", newline="\n") as f:
        f.write(cikti)
    satir = [s for s in cikti.splitlines() if s.strip()]
    print("EXIT =", rc, "| toplam satir:", len(satir), "| ham cikti:", dosya)
    print("--- SON 25 SATIR ---")
    for s in satir[-25:]:
        print("   ", s[:160])
    return rc, cikti

rc1, c1 = kos("KRITER 1 - analyze", [FLUTTER, "analyze"], "T7-analyze.txt", 900)
rc2, c2 = kos("KRITER 2/3 - test",  [FLUTTER, "test"],    "T7-test.txt",    2400)

print("\n" + "=" * 70)
print("OZET (Cowork'un KENDI olcumu):")
print("  KRITER 1 flutter analyze : EXIT", rc1)
print("  KRITER 2 flutter test    : EXIT", rc2)
print("=" * 70)

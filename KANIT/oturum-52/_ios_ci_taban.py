# -*- coding: utf-8 -*-
"""Oturum 52: (7) iOS iskelesi + CI icin BAGIMSIZ TABAN OLCUMU. Beyan yok."""
import os, sys, json
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"

def var(p):
    t = os.path.join(KOK, p)
    if os.path.isdir(t):
        n = len(os.listdir(t))
        return "DIZIN VAR (%d girdi)" % n
    if os.path.isfile(t):
        return "DOSYA VAR (%d b)" % os.path.getsize(t)
    return "YOK"

print("=" * 72)
print("A) CI / IS AKISI")
for p in [".github", ".github/workflows", "azure-pipelines.yml", ".gitlab-ci.yml",
          "Makefile", "araclar/verify.ps1"]:
    print("  %-34s %s" % (p, var(p)))
wf = os.path.join(KOK, ".github", "workflows")
if os.path.isdir(wf):
    for f in sorted(os.listdir(wf)):
        print("     - %s (%d b)" % (f, os.path.getsize(os.path.join(wf, f))))

print("=" * 72)
print("B) FLUTTER ISTEMCI PLATFORM KLASORLERI")
for p in ["src/client", "src/client/ios", "src/client/android", "src/client/web",
          "src/client/windows", "src/client/macos", "src/client/linux",
          "src/client/pubspec.yaml", "src/client/pubspec.lock"]:
    print("  %-34s %s" % (p, var(p)))

print("=" * 72)
print("C) src/ AGACI (1. seviye)")
for kok, dizinler, dosyalar in os.walk(os.path.join(KOK, "src")):
    d = os.path.relpath(kok, KOK).replace("\\", "/")
    if d.count("/") <= 2:
        print("  %s/  [%d dizin, %d dosya]" % (d, len(dizinler), len(dosyalar)))
    dizinler[:] = [x for x in dizinler if x not in
                   (".dart_tool", "build", "bin", "obj", "node_modules", ".git")]

print("=" * 72)
print("D) pubspec.yaml -- platform ile ilgili satirlar")
pp = os.path.join(KOK, "src", "client", "pubspec.yaml")
if os.path.isfile(pp):
    with open(pp, "r", encoding="utf-8", errors="replace") as f:
        for i, s in enumerate(f, 1):
            k = s.lower()
            if any(t in k for t in ("sdk:", "version:", "environment", "flutter:",
                                    "platforms", "ios", "macos")):
                print("  %4d: %s" % (i, s.rstrip()))
print("=" * 72)
print("E) GOREV_CLAUDE_CODE spec envanteri")
g = os.path.join(KOK, "GOREV_CLAUDE_CODE")
if os.path.isdir(g):
    ler = sorted(os.listdir(g))
    print("  %d dosya" % len(ler))
    for f in ler:
        print("   - %s (%d b)" % (f, os.path.getsize(os.path.join(g, f))))
print("=" * 72)
print("BITTI")

# -*- coding: utf-8 -*-
"""A13 - COWORK'UN BAGIMSIZ RISK OLCUMU: CI ilk kosumda patlar mi?
Uretilmis dosyalar (.g.dart / .drift.dart) REPODA mi, yoksa .gitignore'da mi?"""
import os, subprocess, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"

def git(*a):
    return subprocess.run(["git", "--no-optional-locks"] + list(a), cwd=KOK,
                          capture_output=True, text=True, encoding="utf-8", errors="replace")

print("=" * 72)
print("A) DISKTE uretilmis dosyalar (lib altinda .g.dart / .drift.dart)")
diskte = []
for kok, dz, ds in os.walk(os.path.join(KOK, "src", "client", "lib")):
    for f in ds:
        if f.endswith((".g.dart", ".drift.dart", ".freezed.dart")):
            diskte.append(os.path.relpath(os.path.join(kok, f), KOK).replace("\\", "/"))
print("  diskte %d dosya" % len(diskte))
for y in diskte[:20]:
    print("    " + y)

print("=" * 72)
print("B) BUNLAR GIT'TE IZLENIYOR MU? (izlenmiyorsa CI'da analyze/test PATLAR)")
izlenen = git("ls-files", "src/client/lib").stdout.splitlines()
izlenen_set = set(s.strip() for s in izlenen if s.strip())
eksik = [y for y in diskte if y not in izlenen_set]
print("  git ls-files toplam: %d" % len(izlenen_set))
print("  URETILMIS ama IZLENMEYEN: %d" % len(eksik))
for y in eksik[:20]:
    print("    [IZLENMIYOR] " + y)
if not eksik and diskte:
    print("  >> HEPSI IZLENIYOR: CI'da uretilmis dosya eksigi RISKI YOK.")
elif not diskte:
    print("  >> Diskte uretilmis dosya YOK -- ya build_runner kosmamis ya da desen farkli.")

print("=" * 72)
print("C) .gitignore'da uretilmis dosya deseni var mi? (varlik POZITIF kontrolu ile)")
with open(os.path.join(KOK, ".gitignore"), encoding="utf-8", errors="replace") as f:
    gi = f.read()
for d in ["*.g.dart", "*.drift.dart", ".dart_tool", "build/", "*.freezed.dart"]:
    print("  %-18s -> %s" % (d, "VAR" if d in gi else "yok"))
print("  [POZITIF KONTROL] '.dart_tool' bulundu mu: %s" % (".dart_tool" in gi))

print("=" * 72)
print("D) ci.yml'de 'flutter pub get' adimi VAR MI?")
with open(os.path.join(KOK, ".github", "workflows", "ci.yml"), encoding="utf-8", errors="replace") as f:
    yml = f.read()
print("  'pub get' gecti mi: %s  (Flutter aracligi package_config yoksa KENDI kosar --" % ("pub get" in yml))
print("   bu yuzden EKSIKLIGI tek basina bulgu DEGILDIR, ama build_runner ciktisi eksikse PATLAR)")

print("=" * 72)
print("E) MUTANT DALLARI gercekten var mi? (builder beyani DEGIL, git olcumu)")
p = git("branch", "--list", "mutant/*")
print(p.stdout.strip() or "(mutant dali YOK)")
for dal in ["mutant/A13-M167", "mutant/A13-M168", "mutant/A13-M169"]:
    d = git("diff", "--stat", "main.." + dal)
    print("--- %s ---" % dal)
    print((d.stdout or "").strip()[:400] or "(fark yok / dal yok)")

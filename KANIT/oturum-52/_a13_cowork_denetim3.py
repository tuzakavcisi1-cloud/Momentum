# -*- coding: utf-8 -*-
"""KRITER 2 ve 3/d -- COWORK'UN KENDI OLCUMU (builder beyanina guvenilmez)."""
import os, subprocess, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"
ISTEMCI = os.path.join(KOK, "src", "client")
FLUTTER = r"C:\src\flutter\bin\flutter.bat"
ONCESI = "c676eb15f1f3bde8bb1eaae2ff477741ffa958fd"

print("=" * 72)
print("KRITER 3/d -- COWORK KOSUYOR: git diff --stat <oncesi>..HEAD -- lib test pubspec")
p = subprocess.run(["git", "--no-optional-locks", "diff", "--stat", ONCESI + "..HEAD", "--",
                    "src/client/lib", "src/client/test", "src/client/pubspec.yaml"],
                   cwd=KOK, capture_output=True, text=True, encoding="utf-8", errors="replace")
o = (p.stdout or "").strip()
print("EXIT=%d" % p.returncode)
print("CIKTI: %s" % (repr(o) if o else "(BOS) -> G30/d GECTI"))
print("  >> HUKUM: %s" % ("GECTI (cikti bos)" if not o else "KALDI (cikti dolu)"))

print("=" * 72)
print("KRITER 3/d EK -- dilim oncesi sha gercekten HEAD'in atasi mi?")
q = subprocess.run(["git", "--no-optional-locks", "merge-base", "--is-ancestor", ONCESI, "HEAD"],
                   cwd=KOK, capture_output=True, text=True)
print("  merge-base --is-ancestor EXIT=%d (0 = evet, atasi)" % q.returncode)

print("=" * 72)
print("KRITER 2 -- COWORK KOSUYOR: flutter analyze --fatal-infos (yerelde)")
env = dict(os.environ)
env.setdefault("PROGRAMFILES(X86)", r"C:\Program Files (x86)")
try:
    r = subprocess.run([FLUTTER, "analyze", "--fatal-infos"], cwd=ISTEMCI, env=env,
                       capture_output=True, text=True, encoding="utf-8",
                       errors="replace", timeout=900)
    print("EXIT=%d" % r.returncode)
    son = (r.stdout or "").strip().splitlines()[-12:]
    print("\n".join(son))
    e = (r.stderr or "").strip()
    if e:
        print("[stderr] " + e[-500:])
except Exception as ex:
    print("OLCULEMEDI: %r" % (ex,))

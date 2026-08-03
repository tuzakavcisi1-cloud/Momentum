# -*- coding: utf-8 -*-
"""KRITER 5 -- COWORK'UN KENDI MUTANT KOSUMU (K26: builder'in OZET'ine guvenilmez).
ORTAM.md receti: ikili yedek -> BAYT yamasi -> kapi -> yedekten wb geri yaz -> sha256 olc.
git restore YASAK (core.autocrlf)."""
import hashlib, os, re, subprocess, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"
CIYML = os.path.join(KOK, ".github", "workflows", "ci.yml")
PBX = os.path.join(KOK, "src", "client", "ios", "Runner.xcodeproj", "project.pbxproj")

def sha(y):
    with open(y, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()[:8].upper()

def kapi():
    p = subprocess.run([sys.executable, r"araclar\ci-kapisi.py", "."], cwd=KOK,
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    kodlar = sorted(set(re.findall(r"G3?0?[89]?[abc]|G28[ab]|G29a|G30[abc]", p.stdout or "")))
    return p.returncode, kodlar, (p.stdout or "").strip().splitlines()

# ios/Pods/ hangi .gitignore'da?
GI = None
for aday in [os.path.join(KOK, ".gitignore"),
             os.path.join(KOK, "src", "client", ".gitignore"),
             os.path.join(KOK, "src", "client", "ios", ".gitignore")]:
    if os.path.isfile(aday):
        with open(aday, "rb") as f:
            if b"ios/Pods/" in f.read():
                GI = aday
                break
print("ios/Pods/ tasiyan .gitignore: %s" % (GI or "BULUNAMADI"))

MUTANTLAR = [
    ("M162", CIYML, b"flutter analyze --fatal-infos", b"flutter analyze", True),
    ("M163", CIYML, b"flutter-version: 3.44.6", b"flutter-version: 3.43.0", True),
    ("M163b", CIYML, b"flutter-version: 3.44.6\n", b"flutter-version: 3.44.6\n          channel: stable\n", False),
    ("M164", CIYML, b"flutter build ios --no-codesign", b"flutter build ios", True),
    ("M165", PBX, b"com.momentum.client", b"com.example.client", True),
    ("M166", GI, b"ios/Pods/", b"", True),
]

print("=" * 72)
temiz_kod, temiz_kodlar, _ = kapi()
print("TEMIZ-ONCE: EXIT=%d kodlar=%s" % (temiz_kod, temiz_kodlar))
sonuc = []
for ad, yol, eski, yeni, isirmali in MUTANTLAR:
    if not yol or not os.path.isfile(yol):
        print("%-6s ATLANDI (dosya yok)" % ad)
        continue
    with open(yol, "rb") as f:
        ham = f.read()
    s0 = hashlib.sha256(ham).hexdigest()[:8].upper()
    n = ham.count(eski)
    if n == 0:
        print("%-6s DURDU: desen bulunamadi (%r)" % (ad, eski[:40]))
        continue
    # M165 tek gecisi degistir; digerleri ilk gecis yeter
    yamali = ham.replace(eski, yeni, 1)
    with open(yol, "wb") as f:
        f.write(yamali)
    try:
        kod, kodlar, _ = kapi()
    finally:
        with open(yol, "wb") as f:
            f.write(ham)
    s1 = hashlib.sha256(open(yol, "rb").read()).hexdigest()[:8].upper()
    isirdi = (kod != 0)
    ok = (isirdi == isirmali) and (s0 == s1)
    sonuc.append((ad, ok))
    print("%-6s desen x%d | EXIT=%d kodlar=%s | beklenen=%s | sha %s->%s | %s"
          % (ad, n, kod, kodlar, "ISIR" if isirmali else "SUS", s0, s1,
             "GECTI" if ok else "KALDI"))

kod2, kodlar2, _ = kapi()
print("TEMIZ-SONRA: EXIT=%d kodlar=%s" % (kod2, kodlar2))
print("=" * 72)
gecen = sum(1 for _, o in sonuc if o)
print("COWORK HUKMU: %d/%d GECTI (temiz once %d, temiz sonra %d)"
      % (gecen, len(sonuc), temiz_kod, kod2))

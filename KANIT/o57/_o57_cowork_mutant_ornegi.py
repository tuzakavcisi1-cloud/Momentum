# -*- coding: utf-8 -*-
"""COWORK'UN BAGIMSIZ MUTANT ORNEKLEMESI (K26).
Code 14 statik mutantin ISIRDIGINI BEYAN etti. Beyan kanit degildir.
Cowork GERCEK REPODA bir mutanti kendi eliyle kosar: M192 -- izinli
basliklardan Content-Type cikarilir. Bu mutant SECILDI cunku denetimin
BLOKER-1'i tam olarak buydu: v1'de dort kapi da YESIL kalirken Chrome
istegi bloklaniyordu.

ORTAM.md: git restore YASAK (core.autocrlf bayt-ozdesligi kor kilar).
Yol: ikili yedek -> bayt duzeyinde yama -> kapi -> yedekten wb geri yaz -> sha256.
"""
import hashlib
import os
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"
HEDEF = os.path.join(KOK, "src", "backend", "Momentum.Api", "Program.cs")


def sha(y):
    return hashlib.sha256(open(y, "rb").read()).hexdigest()


def kapi():
    p = subprocess.run([sys.executable, os.path.join(KOK, "araclar", "cors-kapisi.py"), "."],
                       cwd=KOK, capture_output=True, text=True,
                       encoding="utf-8", errors="replace")
    return p.returncode, (p.stdout or "").strip().splitlines()


taban = sha(HEDEF)
yedek = open(HEDEF, "rb").read()
print("taban sha256 : %s" % taban[:24])
print("bayt         : %d" % len(yedek))

kod, satirlar = kapi()
print("-" * 70)
print("[KONTROL] mutantsiz kapi -> cikis=%d" % kod)
for s in satirlar:
    if "BULGU" in s or "KIRMIZI" in s:
        print("    " + s)
if kod != 0:
    print("[DUR] KONTROL KIRLI -- kapi zaten kirmizi, mutant bir sey kanitlamaz")
    sys.exit(2)

# --- MUTANT M192: izinli basliklardan Content-Type cikarilir ---
DESENLER = [b'"Content-Type", "X-Momentum-Dev-User"', b'"Content-Type","X-Momentum-Dev-User"']
bulundu = None
for d in DESENLER:
    if yedek.count(d) == 1:
        bulundu = d
        break
if bulundu is None:
    print("[KIRMIZI] izinli baslik deseni TEK ESLESME ile bulunamadi.")
    for d in DESENLER:
        print("    %r -> %d" % (d, yedek.count(d)))
    print("Program.cs'te WithHeaders satiri:")
    for s in yedek.decode("utf-8", "replace").splitlines():
        if "Header" in s or "Content-Type" in s:
            print("    " + s.strip())
    sys.exit(2)

mutant = yedek.replace(bulundu, b'"X-Momentum-Dev-User"', 1)
with open(HEDEF, "wb") as f:
    f.write(mutant)
    f.flush()
    os.fsync(f.fileno())
print("-" * 70)
print("[MUTANT M192] Content-Type izinli basliklardan CIKARILDI (%d -> %d bayt)"
      % (len(yedek), len(mutant)))
mkod, msatirlar = kapi()
print("[MUTANT] kapi -> cikis=%d" % mkod)
for s in msatirlar:
    if "G35" in s or "KIRMIZI" in s or "BULGU" in s:
        print("    " + s)

with open(HEDEF, "wb") as f:
    f.write(yedek)
    f.flush()
    os.fsync(f.fileno())
geri = sha(HEDEF)
print("-" * 70)
print("geri alma sha256 : %s  => %s"
      % (geri[:24], "BAYT-OZDES" if geri == taban else "SAPMA VAR (KIRMIZI)"))
gkod, _ = kapi()
print("geri alma sonrasi kapi -> cikis=%d" % gkod)
print("=" * 70)
if kod == 0 and mkod != 0 and geri == taban and gkod == 0:
    print("HUKUM: M192 GERCEK REPODA ISIRDI. Code'un beyani BU ORNEKTE DOGRULANDI.")
    print("BEYAN EDILMIS SINIR: 14 statik mutantin BIRI olculdu, kalan 13'u")
    print("Code'un kaydindan OKUNDU -- bu bir ORNEKLEMDIR, tam kosum DEGILDIR.")
else:
    print("HUKUM: KIRMIZI -- kontrol=%d mutant=%d geri=%s kapi=%d"
          % (kod, mkod, geri == taban, gkod))

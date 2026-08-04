# -*- coding: utf-8 -*-
"""§6 'hedef' sutununa KURAL adlarini ekler.

Gerekce OLCULDU: spec-kapi-kapsama.py'nin uc_baslik_kurallari() fonksiyonu
'### <ad>' basliklarindan kural cikariyor ve kod_araligi_ac() deseni
r'\\bD-[A-Za-z0-9]+-\\d+\\b' => 'D-W1-1'..'D-W1-9' KURAL sayilacak.
Kural ancak bir mutantin HEDEF (ucuncu) sutununda gecerse ortulu sayilir.
K60: atomik yazim -- once .tmp, sha dogrula, sonra takas (os.replace bu
makinede WinError 5 verebilir => uc adimli yedekli takas).
"""
import hashlib
import io
import os
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
YOL = r"C:\dev\Momentum\GOREV_CLAUDE_CODE\GOREV-W1-web-yuruyen-iskelet.md"

DEGISIM = [
    ("| M189b | statik | `W1/G35/a` |",
     "| M189b | statik | `W1/G35/a` \u00b7 `D-W1-2` |"),
    ("| M190 | statik | `W1/G35/b` |",
     "| M190 | statik | `W1/G35/b` \u00b7 `D-W1-2` |"),
    ("| M190b | statik | `W1/G35/b` |",
     "| M190b | statik | `W1/G35/b` \u00b7 `D-W1-2` |"),
    ("| M191 | statik | `W1/G35/c` |",
     "| M191 | statik | `W1/G35/c` \u00b7 `D-W1-1` |"),
    ("| M191b | statik | `W1/G35/c` |",
     "| M191b | statik | `W1/G35/c` \u00b7 `D-W1-1` |"),
    ("| M192 | statik | `W1/G35/d` |",
     "| M192 | statik | `W1/G35/d` \u00b7 `D-W1-8` |"),
    ("| M192b | statik | `W1/G35/d` |",
     "| M192b | statik | `W1/G35/d` \u00b7 `D-W1-8` |"),
    ("| M194 | statik | `W1/G38/c` |",
     "| M194 | statik | `W1/G38/c` \u00b7 `D-W1-5` |"),
    ("| M195 | ko\u015fan sunucu | `W1/G36/a` \u00b7 `W1/G36/c` |",
     "| M195 | ko\u015fan sunucu | `W1/G36/a` \u00b7 `W1/G36/c` \u00b7 `D-W1-3` |"),
    ("| M196 | ko\u015fan sunucu | `W1/G36/b` |",
     "| M196 | ko\u015fan sunucu | `W1/G36/b` \u00b7 `D-W1-1` |"),
    ("| M197 | ko\u015fan uygulama | `W1/G38/a` |",
     "| M197 | ko\u015fan uygulama | `W1/G38/a` \u00b7 `D-W1-4` \u00b7 `D-W1-9` |"),
    ("| M199 | ko\u015fan uygulama | `W1/G37/a` \u00b7 `W1/G37/b` \u00b7 `W1/G37/c` |",
     "| M199 | ko\u015fan uygulama | `W1/G37/a` \u00b7 `W1/G37/b` \u00b7 `W1/G37/c` \u00b7 `D-W1-6` |"),
]

metin = io.open(YOL, encoding="utf-8", newline="").read()
onceki = len(metin.encode("utf-8"))
eksik = []
for eski, yeni in DEGISIM:
    n = metin.count(eski)
    if n != 1:
        eksik.append((eski[:40], n))
        continue
    metin = metin.replace(eski, yeni, 1)

if eksik:
    print("[KIRMIZI] tek-esleme saglanamayan desen(ler):")
    for e, n in eksik:
        print("   %-45s eslesme=%d" % (e, n))
    print("HICBIR YAZIM YAPILMADI.")
    sys.exit(2)

ham = metin.encode("utf-8")
tmp = YOL + ".tmp"
with open(tmp, "wb") as f:
    f.write(ham)
    f.flush()
    os.fsync(f.fileno())
if hashlib.sha256(open(tmp, "rb").read()).hexdigest() != hashlib.sha256(ham).hexdigest():
    print("[KIRMIZI] .tmp sha tutmadi -- takas YAPILMADI")
    sys.exit(2)
yedek = YOL + ".yedek"
os.rename(YOL, yedek)
try:
    os.rename(tmp, YOL)
except Exception:
    os.rename(yedek, YOL)
    raise
os.remove(yedek)
print("YAZILDI (atomik, uc adimli yedekli takas -- K60)")
print("  degisim sayisi : %d / %d" % (len(DEGISIM), len(DEGISIM)))
print("  bayt           : %d -> %d" % (onceki, os.path.getsize(YOL)))

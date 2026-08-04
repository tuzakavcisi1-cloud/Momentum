# -*- coding: utf-8 -*-
"""Oturum 56 -- BORCLAR.md envanteri: borç kimliklerini ve BAYT ağırlıklarını
ÖLÇER (okumadan karar vermek için). Hiçbir şey yazmaz."""
import io, os, re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
yol = os.path.join(KOK, "BORCLAR.md")
ham = io.open(yol, encoding="utf-8").read()
satirlar = ham.split("\n")
print("BORCLAR.md = %d b, %d satir" % (len(ham.encode("utf-8")), len(satirlar)))
print("=" * 78)

KIMLIK = re.compile(r"`?(B[-A-Z0-9]*-[A-Za-z0-9]+(?:-\d+)?|BD-\d+)`?")
KAPANIS = ("KAPANDI", "KAPATILDI", "ÇÖZÜLDÜ", "COZULDU", "ÖLDÜ", "kapandı")

bas = None
bloklar = []
for i, s in enumerate(satirlar):
    if s.startswith(("- ", "* ", "### ", "## ", "#### ")) or re.match(r"^\*\*`?B", s):
        if bas is not None:
            bloklar.append((bas, i))
        bas = i
if bas is not None:
    bloklar.append((bas, len(satirlar)))

for a, b in bloklar:
    govde = "\n".join(satirlar[a:b])
    bayt = len(govde.encode("utf-8"))
    if bayt < 60:
        continue
    basligi = satirlar[a].strip()[:150]
    kapali = any(k in govde for k in KAPANIS)
    print("%5d b | satir %3d-%3d | %s | %s" % (bayt, a + 1, b, "KAPANIS-IZI" if kapali else "acik      ", basligi))
print("=" * 78)
print("BLOK SAYISI (>=60 b) = %d" % sum(1 for a, b in bloklar if len("\n".join(satirlar[a:b]).encode("utf-8")) >= 60))

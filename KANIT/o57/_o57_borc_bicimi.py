# -*- coding: utf-8 -*-
"""spec-kapi-kapsama.py BORC satirini HANGI bicimde okuyor? TAHMIN ETME, OKU."""
import io
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
YOL = r"C:\dev\Momentum\araclar\spec-kapi-kapsama.py"
L = io.open(YOL, encoding="utf-8").read().splitlines()
anahtar = ("GEREKCE", "borc", "BORC", "Borc", "6b", "re.compile", "KURAL")
for i, s in enumerate(L, 1):
    if any(a in s for a in anahtar):
        print("%4d| %s" % (i, s))

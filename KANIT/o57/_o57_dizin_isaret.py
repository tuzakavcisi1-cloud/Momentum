# -*- coding: utf-8 -*-
"""DIZIN:SON isareti 5 kez geciyor -- HANGISI gercek dizin sonu? TAHMIN ETME, OLC."""
import io
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
YOL = r"C:\dev\Momentum\PROJE_HAFIZA.md"
L = io.open(YOL, encoding="utf-8", newline="").read().split("\n")
for i, s in enumerate(L, 1):
    if "DIZIN:SON" in s or "DIZIN:BAS" in s:
        satir_basi = "SATIR-BASI" if s.startswith("<!--") else "govde-ici"
        print("%6d| [%s] %s" % (i, satir_basi, s[:120]))
print("---- ilk 3 checkpoint basligi (## K...) ----")
n = 0
for i, s in enumerate(L, 1):
    if s.startswith("## K"):
        print("%6d| %s" % (i, s[:90]))
        n += 1
        if n >= 3:
            break

# -*- coding: utf-8 -*-
"""Oturum 56'nin checkpointleri DIZIN:SON'un ALTINA mi yazildi? (o56 kaydinda
[OLCULMEDI] demistim -- simdi OLCUYORUM.)"""
import io
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
YOL = r"C:\dev\Momentum\PROJE_HAFIZA.md"
L = io.open(YOL, encoding="utf-8", newline="").read().split("\n")
print("toplam satir: %d" % len(L))
for i, s in enumerate(L, 1):
    if s.startswith("## K13"):
        print("%6d| %s" % (i, s[:100]))

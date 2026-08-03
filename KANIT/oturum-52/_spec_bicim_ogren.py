# -*- coding: utf-8 -*-
"""A13 spec'ini yazmadan ONCE: aracin kabul ettigi bicimi OLC (varsayma)."""
import re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

print("=" * 72)
print("A) GOREV-A12 BASLIK ISKELETI (en guncel kabul edilmis bicim)")
print("=" * 72)
with open(r"C:\dev\Momentum\GOREV_CLAUDE_CODE\GOREV-A12-kural-envanteri.md",
          encoding="utf-8", errors="replace") as f:
    for i, s in enumerate(f, 1):
        if s.startswith("#") or re.match(r"^\s*\|\s*(M\d+|G\d+)", s):
            print("%4d | %s" % (i, s.rstrip()[:150]))

print("=" * 72)
print("B) spec-kapi-kapsama.py -- AYRISTIRMA DESENLERI (regex/baslik satirlari)")
print("=" * 72)
with open(r"C:\dev\Momentum\araclar\spec-kapi-kapsama.py",
          encoding="utf-8", errors="replace") as f:
    for i, s in enumerate(f, 1):
        t = s.rstrip()
        if re.search(r"re\.(compile|match|search|findall)|## ?\d|BASLIK|startswith\(|BORC|S\d\]", t):
            print("%4d | %s" % (i, t[:160]))

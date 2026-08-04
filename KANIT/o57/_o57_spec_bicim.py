# -*- coding: utf-8 -*-
"""K81/K126 bicimini ORNEKTEN ogren: spec-kapi-kapsama.py'nin kabul ettigi
tek bicim SS2 spec'inde YASIYOR. Tahmin etme, OKU."""
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
YOL = r"C:\dev\Momentum\GOREV_CLAUDE_CODE\GOREV-SS2-cakisma-cozumu.md"

with open(YOL, "r", encoding="utf-8") as f:
    satirlar = f.read().splitlines()

print("=== TUM '## ' BASLIKLARI ===")
for i, s in enumerate(satirlar, 1):
    if s.startswith("## "):
        print("  %4d| %s" % (i, s))
print("=== TUM '### G' BASLIKLARI ===")
for i, s in enumerate(satirlar, 1):
    if s.startswith("### G"):
        print("  %4d| %s" % (i, s))

bas = None
for i, s in enumerate(satirlar):
    if s.startswith("## 6. MUTANT"):
        bas = i
        break
print("=== '## 6. MUTANTLAR' + sonraki 18 satir ===")
if bas is not None:
    for i in range(bas, min(bas + 18, len(satirlar))):
        print("  %4d| %s" % (i + 1, satirlar[i]))
else:
    print("  BULUNAMADI")

bas5 = None
for i, s in enumerate(satirlar):
    if s.startswith("## 5. KAPILAR"):
        bas5 = i
        break
print("=== '## 5. KAPILAR' + sonraki 22 satir ===")
if bas5 is not None:
    for i in range(bas5, min(bas5 + 22, len(satirlar))):
        print("  %4d| %s" % (i + 1, satirlar[i]))
else:
    print("  BULUNAMADI")

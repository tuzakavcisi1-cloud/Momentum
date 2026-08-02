# -*- coding: utf-8 -*-
"""Builder 'spec 5'teki metinle BIREBIR ekledim' dedi. OLC, guvenme.
Spec'teki ```dart blogunu cikarir, test dosyasinda ARAR ve fark varsa GOSTERIR."""
import difflib
import io
import re
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

SPEC = r"C:\dev\Momentum\GOREV_CLAUDE_CODE\GOREV-A11-ag-donus-itmesi.md"
TEST = r"C:\dev\Momentum\src\client\test\ag_donus_itmesi_test.dart"


def oku(p):
    with io.open(p, "r", encoding="utf-8", errors="replace") as f:
        return f.read().replace("\r\n", "\n")


spec = oku(SPEC)
test = oku(TEST)

bloklar = re.findall(r"```dart\n(.*?)```", spec, re.S)
print("spec'te dart blogu sayisi: %d" % len(bloklar))
if not bloklar:
    print("HUKUM: OLCULEMEDI -- spec'te dart blogu YOK")
    raise SystemExit(3)

hedef = None
for b in bloklar:
    if "G22/c2" in b:
        hedef = b
        break
if hedef is None:
    print("HUKUM: OLCULEMEDI -- 'G22/c2' iceren dart blogu YOK")
    raise SystemExit(3)

hedef_satirlar = [s.rstrip() for s in hedef.split("\n") if s.strip()]
print("spec c2 blogu: %d anlamli satir" % len(hedef_satirlar))

# 1) TAM BLOK dogrudan geciyor mu?
if hedef.strip() in test:
    print("HUKUM: BIREBIR -- spec blogu test dosyasinda AYNEN var.")
    raise SystemExit(0)

# 2) Degilse: testteki c2 testini bul ve FARKI goster.
m = re.search(r"( *test\(\s*\n?[^\n]*G22/c2.*?\n  \);)", test, re.S)
if not m:
    print("HUKUM: KUSUR -- test dosyasinda 'G22/c2' testi BULUNAMADI.")
    raise SystemExit(1)

testteki = [s.rstrip() for s in m.group(1).split("\n") if s.strip()]
fark = list(difflib.unified_diff(hedef_satirlar, testteki,
                                 fromfile="spec-5", tofile="test-dosyasi", lineterm=""))
if not fark:
    print("HUKUM: BIREBIR (yalniz bosluk/girinti farki).")
    raise SystemExit(0)
print("HUKUM: SAPMA VAR -- %d fark satiri:" % len(fark))
for s in fark[:60]:
    print("  " + s[:170])
raise SystemExit(1)

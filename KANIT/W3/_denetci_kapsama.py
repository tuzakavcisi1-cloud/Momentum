# -*- coding: utf-8 -*-
"""Bagimsiz denetci olcumu: ayak <-> mutant HEDEF SUTUNU kapsamasi.
_v2_olc.py'den farki: hedefleri TUM BELGEDEN degil, yalniz s6 mutant
tablosunun UCUNCU SUTUNUNDAN (K126: hedef) okur."""
import io, re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

P = r"C:\dev\Momentum\GOREV_CLAUDE_CODE\GOREV-W3-capraz-koken-izolasyonu.md"
txt = io.open(P, encoding="utf-8").read()

# 1) ayak envanteri (s5)
ayak = []
for m in re.finditer(r"(?m)^### (G4[3-7]) ", txt):
    g = m.group(1)
    son = txt.find("\n### ", m.end())
    blok = txt[m.end(): son if son > 0 else len(txt)]
    for a in re.findall(r"(?m)^- \*\*([a-h])\)\*\*", blok):
        ayak.append(g + "/" + a)

# 2) mutant tablosu: 1. sutun = no, 3. sutun = hedef
hed = {}
for ln in txt.split("\n"):
    if not ln.lstrip().startswith("|"):
        continue
    h = [c.strip() for c in ln.strip().strip("|").split("|")]
    if len(h) < 3:
        continue
    no = re.sub(r"[`*]", "", h[0]).strip()
    if not re.match(r"^(M\d+|MW\d+)$", no):
        continue
    hed[no] = set(re.findall(r"G4[3-7]/[a-h]", h[2]))

kaps = set()
for v in hed.values():
    kaps |= v
kor = [a for a in ayak if a not in kaps]

print("TANIMLI AYAK        = %d" % len(ayak))
print("TABLODAKI MUTANT    = %d (kusurlu %d, susmali %d)" % (
    len(hed),
    len([k for k in hed if not k.startswith("MW")]),
    len([k for k in hed if k.startswith("MW")])))
print("HEDEF SUTUNUNDA GECEN AYAK = %d" % len(kaps))
print("MUTANT HEDEFI OLMAYAN AYAK (%d): %s" % (len(kor), ", ".join(kor) if kor else "(yok)"))

# 3) s6b'de adiyla gecen ayak/kural
b = txt.split("## 6b.")[1].split("## 7.")[0]
b_ayak = set(re.findall(r"G4[3-7]/[a-h]", b))
print("6b'DE ADIYLA GECEN AYAK: %s" % ", ".join(sorted(b_ayak)))
kor2 = [a for a in kor if a not in b_ayak]
print()
print(">>> NE MUTANTI NE BORCU OLAN AYAK (%d): %s" % (
    len(kor2), ", ".join(kor2) if kor2 else "(yok)"))

# 4) her mutantin hedefi
print()
print("--- MUTANT -> HEDEF ---")
for k in hed:
    print("  %-6s %s" % (k, ", ".join(sorted(hed[k])) if hed[k] else "(ayak hedefi YOK)"))

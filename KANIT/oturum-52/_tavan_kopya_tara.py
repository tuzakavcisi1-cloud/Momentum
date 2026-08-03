# -*- coding: utf-8 -*-
"""BORCLAR.md tavanini BEYAN EDEN HER KOPYAYI bul (kanonik-kopya bu projede 6 kez isirdi)."""
import os, re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"
DESENLER = [r"24576", r"24\s*KB", r"16\s*->\s*24", r"16 → 24"]
ATLA = {".git", "KANIT", "arsiv", "build", ".dart_tool", "node_modules", "_SILINECEKLER"}

for kok, dizinler, dosyalar in os.walk(KOK):
    dizinler[:] = [d for d in dizinler if d not in ATLA]
    for ad in dosyalar:
        if not ad.endswith((".md", ".py", ".json", ".ps1")):
            continue
        yol = os.path.join(kok, ad)
        try:
            with open(yol, "r", encoding="utf-8", errors="replace") as f:
                satirlar = f.readlines()
        except Exception:
            continue
        rel = os.path.relpath(yol, KOK)
        for i, s in enumerate(satirlar, 1):
            for d in DESENLER:
                if re.search(d, s):
                    isaret = " <== APPEND-ONLY" if rel == "PROJE_HAFIZA.md" else ""
                    print("%-42s :%-5d %s%s" % (rel, i, s.strip()[:150], isaret))
                    break
print("-" * 72)
print("TARAMA BITTI (KANIT/ ve arsiv/ kapsam disi)")

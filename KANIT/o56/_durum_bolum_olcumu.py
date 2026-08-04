# -*- coding: utf-8 -*-
"""Oturum 56 -- DURUM.md'nin BOLUM BAZLI bayt agirligini olcer (budama karari
tahminle degil olcumle verilsin)."""
import io, os, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
ham = io.open(os.path.join(KOK, "DURUM.md"), encoding="utf-8").read()
satirlar = ham.split("\n")
bas = [i for i, s in enumerate(satirlar) if s.startswith("## ")]
bas.append(len(satirlar))
print("DURUM.md = %d b / 32768 b  (pay %d b)" % (len(ham.encode("utf-8")),
                                                 32768 - len(ham.encode("utf-8"))))
print("=" * 74)
for a, b in zip(bas[:-1], bas[1:]):
    govde = "\n".join(satirlar[a:b])
    print("%6d b | satir %3d-%3d | %s" % (len(govde.encode("utf-8")), a + 1, b, satirlar[a][:60]))
print("=" * 74)
# §5 icindeki tek tek kilit maddeleri
i5 = [i for i, s in enumerate(satirlar) if s.startswith("## 5.")]
if i5:
    son = [b for a, b in zip(bas[:-1], bas[1:]) if a == i5[0]][0]
    print("§5 MADDE BAZLI:")
    madde = [i for i in range(i5[0], son) if satirlar[i].startswith("- ")]
    madde.append(son)
    for a, b in zip(madde[:-1], madde[1:]):
        govde = "\n".join(satirlar[a:b])
        print("  %5d b | satir %3d-%3d | %s" % (len(govde.encode("utf-8")), a + 1, b,
                                                satirlar[a][2:100]))

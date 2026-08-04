# -*- coding: utf-8 -*-
"""W1 denetim -- 3. tur: sarkan atif avi (BORCLAR/K-numaralari/dosya yollari)."""
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"


def bolum(b):
    print("=" * 74)
    print(b)
    print("=" * 74)


def oku(rel):
    p = os.path.join(KOK, rel.replace("/", os.sep))
    if not os.path.exists(p):
        return None
    return io.open(p, encoding="utf-8", errors="replace").read()


bolum("1) BORCLAR.md -- B-W1-1 / B-W1-2 var mi? (spec bunlara atif yapiyor)")
b = oku("BORCLAR.md")
print("  BORCLAR.md boyut: %s" % (len(b) if b else "YOK"))
for kod in ["B-W1-1", "B-W1-2", "B-O52-1"]:
    satirlar = [(i + 1, l.strip()) for i, l in enumerate((b or "").splitlines()) if kod in l]
    print("  %-10s gecis: %d" % (kod, len(satirlar)))
    for i, l in satirlar[:3]:
        print("        :%-5d %s" % (i, l[:150]))

bolum("2) PROJE_HAFIZA.md -- spec'in atif yaptigi K numaralari GERCEKTEN VAR MI")
h = oku("PROJE_HAFIZA.md")
print("  PROJE_HAFIZA.md boyut: %d" % len(h or ""))
for k in ["K135", "K133", "K126", "K127", "K112", "K108", "K95", "K86", "K81", "K80",
          "K79", "K77", "K73", "K61", "K58", "K56", "K55", "K53", "K44-a", "K41", "K26",
          "M171c", "M172", "R8"]:
    n = len(re.findall(r"\b" + re.escape(k) + r"\b", h or ""))
    print("  %-8s x%d %s" % (k, n, "" if n else "  <<< HIC GECMIYOR"))

bolum("3) spec'in adiyla andigi DOSYA YOLLARI diskte var mi")
spec = oku("GOREV_CLAUDE_CODE/GOREV-W1-web-yuruyen-iskelet.md")
yollar = set(re.findall(r"`([A-Za-z0-9_\-./\\]+\.(?:py|ps1|dart|cs|json|md|js|wasm|cmd))`", spec))
for y in sorted(yollar):
    for aday in (y, "araclar/" + y, "src/client/" + y):
        p = os.path.join(KOK, aday.replace("/", os.sep))
        if os.path.exists(p):
            print("  VAR   %-56s (-> %s)" % (y, aday))
            break
    else:
        print("  YOK?  %-56s" % y)

bolum("4) DURUM.md -- SIRADAKI IS / son durum (ilk 60 satir + W1 gecen satirlar)")
d = oku("DURUM.md")
print("  DURUM.md boyut: %d b" % len(d or ""))
for i, l in enumerate((d or "").splitlines(), 1):
    if re.search(r"\bW1\b|oturum 57|SS2|KOSULAMAZ|KOŞULAMAZ", l):
        print("  :%-4d %s" % (i, l.strip()[:190]))

bolum("5) GOREV_CLAUDE_CODE dizini")
gd = os.path.join(KOK, "GOREV_CLAUDE_CODE")
for a in sorted(os.listdir(gd)):
    st = os.stat(os.path.join(gd, a))
    print("  %-52s %8d b" % (a, st.st_size))

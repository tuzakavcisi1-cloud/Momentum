# -*- coding: utf-8 -*-
"""Oturum 52 IKINCI commit -- K127 + A13 duzeltmesi. K55: yol vererek, dizin YOK, -A YOK."""
import os, subprocess, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"

def git(*a, goster=True):
    p = subprocess.run(["git", "--no-optional-locks"] + list(a), cwd=KOK,
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    if goster:
        print("$ git %s -> EXIT %d" % (" ".join(a[:3]), p.returncode))
        if p.stdout.strip():
            print(p.stdout.strip()[:1800])
        if p.stderr.strip():
            print("[stderr] " + p.stderr.strip()[:600])
    return p

YOLLAR = [
    "GOREV_CLAUDE_CODE/GOREV-A13-ios-iskeleti-ci.md",
    "PROJE_HAFIZA.md", "PROJE_RADAR.jsonl", "DURUM.md", "CLAUDE.md", "BORCLAR.md",
    "KANIT/A12/_checkpoint-metni.md",
    "KANIT/A13/00-DENETIM-kilit-oncesi.md",
]
d = os.path.join(KOK, "KANIT", "oturum-52")
for ad in sorted(os.listdir(d)):
    if os.path.isfile(os.path.join(d, ad)):
        YOLLAR.append("KANIT/oturum-52/" + ad)

for y in YOLLAR:
    p = git("add", "--", y, goster=False)
    if p.returncode != 0:
        print("ADD ATLANDI: %s -> %s" % (y, (p.stderr or "").strip()[:110]))
print("add bitti (%d yol denendi)." % len(YOLLAR))
print("=" * 72)
git("commit", "-m",
    "oturum-52-K127-kilit-oncesi-bagimsiz-denetim-ZORUNLU-A13-3-bloker-6-major-duzeltildi")
print("=" * 72)
git("log", "--oneline", "-1")
git("status", "--porcelain")
print("index.lock var mi -> %s" % os.path.exists(os.path.join(KOK, ".git", "index.lock")))
git("rev-list", "--left-right", "--count", "origin/main...HEAD")

# -*- coding: utf-8 -*-
"""Oturum 52 commit -- K55: YOL VEREREK add, dizin YOK, -A YOK.
ORTAM.md: commit mesajinda CIFT TIRNAK yok; her git cagrisinda --no-optional-locks."""
import os, subprocess, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"

def git(*a, goster=True):
    p = subprocess.run(["git", "--no-optional-locks"] + list(a), cwd=KOK,
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    if goster:
        print("$ git %s  -> EXIT %d" % (" ".join(a[:3]), p.returncode))
        if p.stdout.strip():
            print(p.stdout.strip()[:2000])
        if p.stderr.strip():
            print("[stderr] " + p.stderr.strip()[:800])
    return p

YOLLAR = [
    "GOREV_CLAUDE_CODE/GOREV-A13-ios-iskeleti-ci.md",
    "PROJE_HAFIZA.md", "PROJE_RADAR.jsonl", "DURUM.md", "CLAUDE.md", "BORCLAR.md",
    "araclar/belge-tavan-kapisi.py",
    "KANIT/A12/_checkpoint-metni.md", "KANIT/A12/_checkpoint-metni-K124.md",
]
# KANIT/oturum-52 icindeki dosyalar TEK TEK (K55: dizin vermek de kor alimdir)
d = os.path.join(KOK, "KANIT", "oturum-52")
for ad in sorted(os.listdir(d)):
    if os.path.isfile(os.path.join(d, ad)):
        YOLLAR.append("KANIT/oturum-52/" + ad)

print("=" * 72)
print("EKLENECEK %d YOL (dizin YOK, -A YOK):" % len(YOLLAR))
for y in YOLLAR:
    print("   " + y)
print("=" * 72)
for y in YOLLAR:
    p = git("add", "--", y, goster=False)
    if p.returncode != 0:
        print("ADD BASARISIZ: %s -> %s" % (y, (p.stderr or "").strip()[:200]))
print("add bitti.")
print("=" * 72)
git("commit", "-m",
    "oturum-52-K125-K126-A13-KILITLENDI-BORCLAR-tavani-32KB-vaka13-mutantla-olculdu")
print("=" * 72)
git("log", "--oneline", "-1")
git("status", "--porcelain")
print("=" * 72)
kilit = os.path.join(KOK, ".git", "index.lock")
print("index.lock var mi -> %s  (PAZARLIKSIZ KOSUL, K26 errata)" % os.path.exists(kilit))
git("rev-list", "--left-right", "--count", "origin/main...HEAD")

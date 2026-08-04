# -*- coding: utf-8 -*-
"""W1 denetim -- 5. tur: taban tablosunun 92-dosya iddiasi, devUserId gorunurlugu,
ss2-kapisi.py yorum-atlama yetenegi (cors-kapisi.py ile ortusme)."""
import io
import os
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"


def bolum(b):
    print("=" * 74)
    print(b)
    print("=" * 74)


bolum("1) _o57_cors.py YENIDEN KOSULDU (taban tablosu satiri: '92 backend dosyasi')")
r = subprocess.run([sys.executable, os.path.join(KOK, r"KANIT\o57\_o57_cors.py")],
                   capture_output=True, text=True, encoding="utf-8", errors="replace",
                   timeout=180, cwd=KOK)
cikti = (r.stdout or "")
for s in cikti.splitlines():
    if s.startswith("taranan") or "YOK" in s or "BULUNDU" in s or "POZITIF" in s or "gecen dosya" in s:
        print("  " + s)
print("  EXIT=%s" % r.returncode)

bolum("2) devUserId / clientId istemci konsolunda basiliyor mu? (G38/b icin gerekli)")
LIB = os.path.join(KOK, "src", "client", "lib")
bulundu = 0
for kok, d, f in os.walk(LIB):
    for a in f:
        if not a.endswith(".dart"):
            continue
        p = os.path.join(kok, a)
        m = io.open(p, encoding="utf-8", errors="replace").read()
        for i, l in enumerate(m.splitlines(), 1):
            if re.search(r"print\(", l) and not l.strip().startswith("//"):
                print("  %-46s :%-4d %s" % (os.path.relpath(p, LIB), i, l.strip()[:110]))
                bulundu += 1
print("  toplam print( satiri: %d" % bulundu)

bolum("3) ss2-kapisi.py -- zaten yorum atliyor mu? (cors-kapisi.py ile ortusme)")
ss2 = io.open(os.path.join(KOK, r"araclar\ss2-kapisi.py"), encoding="utf-8",
              errors="replace").read()
print("  boyut: %d b" % len(ss2))
for i, l in enumerate(ss2.splitlines(), 1):
    if re.search(r"yorum|/\*|//|def .*(yorum|temizle|strip)", l, re.I) and i < 140:
        print("  :%-4d %s" % (i, l.strip()[:130]))

bolum("4) spec: --dart-define DEV_USER_ID gecisi var mi?")
spec = io.open(os.path.join(KOK, r"GOREV_CLAUDE_CODE\GOREV-W1-web-yuruyen-iskelet.md"),
               encoding="utf-8", errors="replace").read()
for anahtar in ["DEV_USER_ID", "dart-define", "devUserId", "owner_id", "X-Momentum-Dev-User",
                "Content-Type", "content-type", "web-port"]:
    n = spec.count(anahtar)
    print("  %-24s x%d" % (anahtar, n))

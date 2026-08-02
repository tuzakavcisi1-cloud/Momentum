# -*- coding: utf-8 -*-
"""Backend AYAKTA MI -- beyan degil OLCUM. Port yeterli DEGIL (Program.cs:22-25:
baglanti dizesi yoksa host DB'siz acilir ve port yine dinler)."""
import json
import subprocess
import sys
import urllib.error
import urllib.request

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass


def istek(yol, veri=None, basliklar=None):
    r = urllib.request.Request("http://localhost:5298" + yol, data=veri,
                               headers=basliklar or {}, method="POST" if veri is not None else "GET")
    try:
        with urllib.request.urlopen(r, timeout=8) as y:
            return y.status, (y.read()[:120].decode("utf-8", "replace"))
    except urllib.error.HTTPError as e:
        return e.code, (e.read()[:120].decode("utf-8", "replace"))
    except Exception as e:
        return None, str(e)[:120]


p = subprocess.run(["netstat", "-ano"], capture_output=True, text=True,
                   encoding="utf-8", errors="replace")
dinleyen = [s.strip() for s in (p.stdout or "").split("\n") if ":5298" in s and "LISTENING" in s]
print("== netstat :5298 LISTENING satiri: %d" % len(dinleyen))
for s in dinleyen:
    print("   " + s)

for yol in ("/health/live", "/health/ready"):
    kod, govde = istek(yol)
    print("== GET %-14s -> %s   %s" % (yol, kod, govde[:60]))

govde = json.dumps({"clientId": "9f1c5a20-0000-7000-8000-000000000001", "clientHlc": None,
                    "sinceCursor": None, "ops": []}).encode("utf-8")
kod1, g1 = istek("/v1/sync", govde, {"Content-Type": "application/json"})
print("== POST /v1/sync  BASLIKSIZ  -> %s   (K61: 401 BEKLENIR)  %s" % (kod1, g1[:60]))
kod2, g2 = istek("/v1/sync", govde, {"Content-Type": "application/json",
                                     "X-Momentum-Dev-User": "11111111-1111-1111-1111-111111111111"})
print("== POST /v1/sync  DEV BASLIK -> %s   (200 BEKLENIR)       %s" % (kod2, g2[:60]))

print("\nHUKUM: %s" % (
    "BACKEND HAZIR (DB dahil)" if (kod1 == 401 and kod2 == 200) else
    "EKSIK -- yukaridaki kodlara bak (503 ya da 500 => baglanti dizesi/DB)"))

# -*- coding: utf-8 -*-
"""Kriter 7 IZOLASYONU: T1+4s'de kuyrugu bosaltan tetikleyici KIM?
A11 retry mi, yoksa slice-3e SignalR sinyali mi? Mevcut kanitlarda iz ara."""
import io
import os
import re
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

D = r"C:\dev\Momentum\KANIT\cevrimdisi-senkron"
DESEN = re.compile(r"signalr|sinyal|hub|websocket|negotiate|baglan|connect|/v1/sync",
                   re.IGNORECASE)

for ad in sorted(os.listdir(D)):
    yol = os.path.join(D, ad)
    if not os.path.isfile(yol) or os.path.getsize(yol) > 8 * 1024 * 1024:
        continue
    if not ad.lower().endswith((".txt", ".log", ".json")):
        continue
    try:
        with io.open(yol, "r", encoding="utf-8", errors="replace") as f:
            satirlar = f.read().split("\n")
    except Exception as e:
        print("[ATLANDI] %s (%s)" % (ad, e))
        continue
    vurus = [(i + 1, s.strip()) for i, s in enumerate(satirlar) if DESEN.search(s)]
    print("=== %s : %d satir, %d vurus" % (ad, len(satirlar), len(vurus)))
    for n, s in vurus[-12:]:
        print("    %5d: %s" % (n, s[:220]))

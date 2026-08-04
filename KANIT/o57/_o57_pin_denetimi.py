# -*- coding: utf-8 -*-
"""BAGIMSIZ DENETIM: drift_worker.js TOFU pini 2.34.0 -> 2.34.3 degistirildi.
Spec bunu YETKILENDIRMEDI. Uc soru, ucu de OLCULUR:
  1) diskteki dosyanin sha'si pinle TUTUYOR mu? (pin elle mi yazildi?)
  2) pubspec.lock'taki drift paket surumu 2.34.3 mu? (surum secimi TAHMIN mi?)
  3) sqlite3.wasm pini DEGISTI mi? (kapsam nereye kadar genisledi?)
"""
import hashlib
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"
PIN = os.path.join(KOK, "araclar", "web-varlik.sha256")
WORKER = os.path.join(KOK, "src", "client", "web", "drift_worker.js")
WASM = os.path.join(KOK, "src", "client", "web", "sqlite3.wasm")
LOCK = os.path.join(KOK, "src", "client", "pubspec.lock")

print("=" * 74)
pinler = {}
for s in io.open(PIN, encoding="utf-8").read().splitlines():
    if s.startswith("#") or not s.strip():
        continue
    p = s.split()
    pinler[p[0]] = {"sha": p[1], "tag": p[-1].split("=")[-1]}
    print("PIN  %-18s %s  tag=%s" % (p[0], p[1][:16] + "...", p[-1].split("=")[-1]))

print("-" * 74)
for ad, yol in (("drift_worker.js", WORKER), ("sqlite3.wasm", WASM)):
    if not os.path.exists(yol):
        print("[KIRMIZI] %s DISKTE YOK" % ad)
        continue
    h = hashlib.sha256(open(yol, "rb").read()).hexdigest()
    beklenen = pinler.get(ad, {}).get("sha", "")
    durum = "TUTUYOR" if h == beklenen else "TUTMUYOR"
    print("DISK %-18s %s  %d bayt  => %s"
          % (ad, h[:16] + "...", os.path.getsize(yol), durum))
    if h != beklenen:
        print("     [KIRMIZI] pin %s / disk %s" % (beklenen[:16], h[:16]))

print("-" * 74)
metin = io.open(LOCK, encoding="utf-8").read()
m = re.search(r"\n  drift:\n(?:.*\n)*?    version: \"([^\"]+)\"", metin)
paket = m.group(1) if m else None
print("pubspec.lock drift paket surumu : %s" % paket)
print("web-varlik.sha256 drift_worker tag: %s" % pinler.get("drift_worker.js", {}).get("tag"))
if paket and pinler.get("drift_worker.js"):
    t = pinler["drift_worker.js"]["tag"].replace("drift-", "")
    print("ESLESME: %s" % ("EVET -- worker paket surumuyle AYNI" if t == paket
                          else "HAYIR -- worker %s, paket %s (BU BIR BULGUDUR)" % (t, paket)))
print("=" * 74)
print("BEYAN EDILMIS SINIR: bu betik pinin DOGRU olup olmadigini degil,")
print("KENDI ICINDE TUTARLI olup olmadigini olcer. Yukaridaki url'nin gercekten")
print("o dosyayi verdigini OLCMEZ (ag ister, web-varlik-indir.py'nin isidir).")

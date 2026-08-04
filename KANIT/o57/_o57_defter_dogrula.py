# -*- coding: utf-8 -*-
"""Defter dogrulayici -- ONCEKI dogrulayicinin YANLIS-POZITIFI onarildi.
Kusur: dosyanin ilk 6 satiri '#' ile baslayan BASLIK bloguydu; ilk surum
onlari JSON sanip 6 sahte KIRMIZI verdi. Olcum aracinin kendi kusuru.
"""
import json
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
YOL = r"C:\dev\Momentum\PROJE_RADAR.jsonl"

with open(YOL, "r", encoding="utf-8") as f:
    satirlar = f.read().splitlines()

veri, yorum, bozuk = 0, 0, 0
for i, s in enumerate(satirlar, 1):
    d = s.strip()
    if not d:
        continue
    if d.startswith("#"):
        yorum += 1
        continue
    try:
        json.loads(d)
        veri += 1
    except Exception as e:
        bozuk += 1
        print("  [KIRMIZI] satir %d: %s" % (i, e))

print("toplam satir : %d" % len(satirlar))
print("yorum satiri : %d" % yorum)
print("JSON kaydi   : %d" % veri)
print("bozuk        : %d" % bozuk)

print("--- SON 6 KAYIT (oturum 57'nin geriye donuk yazdiklari) ---")
for s in [x for x in satirlar if x.strip() and not x.strip().startswith("#")][-6:]:
    k = json.loads(s)
    print("  %-52s tur %-3s oturum %s  urun_kodu=%s  kapatilan=%s uretilen=%s"
          % (k["artefakt"], k["tur"], k["oturum"],
             k.get("urun_kodu_satiri"), k["kapatilan"], k["uretilen"]))
print("HUKUM: %s" % ("TEMIZ" if bozuk == 0 else "KIRMIZI"))
sys.exit(0 if bozuk == 0 else 2)

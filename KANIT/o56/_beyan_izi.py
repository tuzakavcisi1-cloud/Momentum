# -*- coding: utf-8 -*-
"""Oturum 56 -- §5'ten TASINACAK uc satirin YASAYAN BEYANLARI baska bir CANLI
belgede (BORCLAR.md) ZATEN var mi? Tasimadan ONCE olculur; yoksa tasima
beyani GIZLER. Pozitif kontrol: her hedef dosya okundu mu sayilir."""
import io, os, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

BEYANLAR = [
    ("K77-81/1  Y1 sembol bazli + govde kurali", ["Y1", "gövde kural", "kapsayan"]),
    ("K77-81/2  CursorHint yoksayilir (D6)", ["CursorHint"]),
    ("K77-81/3  web'de sinyal kIsWeb ile KAPALI", ["kIsWeb", "web ayağı", "platform chrome"]),
    ("K77-81/4  Y3'un mutanti YOK", ["Y3"]),
    ("K77-81/5  G12 kriter 8 UYGULANMAZ", ["G12 kriter 8", "G12/T5", "kriter 8 **UYGULANMAZ**"]),
    ("K71-76/1  D2 kural 3 istisnasi (K != 'yerel')", ["D2 kural", "Yalnızca bu cihazda", "'yerel'"]),
    ("K71-76/2  R9 oncesi satirlar 'yerel' KALIR", ["R9 öncesi", "migration yasak"]),
    ("K71-76/3  K46 ACIK / DESIGN.md v2 / BD-1..7", ["BD‑1", "BD-1", "K46"]),
    ("K116-120/1 GOREV-slice-3d D0 metni bilerek BAYAT", ["D0", "bilerek bayat", "K70"]),
    ("K116-120/2 main.dart:149 kapisi YOK (B-O50-1)", ["main.dart:149", "B-O50-1"]),
    ("K116-120/3 durdur() uretimde cagrilmiyor", ["durdur()"]),
    ("K116-120/4 408/429 kapsam disi", ["408", "429"]),
    ("K116-120/5 fiziksel cihaz OLCULMEDI", ["fiziksel cihaz", "NAT"]),
]

HEDEFLER = ["BORCLAR.md", "KAPILAR.md"]
metinler = {}
for h in HEDEFLER:
    y = os.path.join(KOK, h)
    metinler[h] = io.open(y, encoding="utf-8").read() if os.path.isfile(y) else None
    print("[POZITIF KONTROL] %s okundu mu: %s (%d b)" % (
        h, metinler[h] is not None, len((metinler[h] or "").encode("utf-8"))))
print("=" * 78)
eksik = 0
for ad, desenler in BEYANLAR:
    bulundu = []
    for h, m in metinler.items():
        if m and any(d in m for d in desenler):
            bulundu.append(h)
    if not bulundu:
        eksik += 1
    print("%-45s | %s" % (ad, ", ".join(bulundu) if bulundu else "🔴 HICBIRINDE YOK"))
print("=" * 78)
print("BASKA CANLI BELGEDE IZI OLMAYAN BEYAN SAYISI = %d" % eksik)

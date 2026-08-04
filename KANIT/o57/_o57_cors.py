# -*- coding: utf-8 -*-
"""WEB'IN GERCEK BLOKERI: tarayici cagrisi CAPRAZ KAYNAKTIR.
Tarayici http://localhost:<port> ustunde kosar, API http://localhost:5298'de
=> FARKLI PORT = FARKLI ORIGIN. Ustelik istek 'X-Momentum-Dev-User' ozel
basligi tasiyor => tarayici ONCE preflight OPTIONS atar. Backend'de CORS
politikasi yoksa web istemci ASLA senkron olamaz -- ve bu, DERLEME
basarisiyla GORUNMEZ.
findstr KULLANILMAZ (ORTAM.md). Pozitif kontrol dahildir.
"""
import os
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum\src\backend"

DESENLER = ["AddCors", "UseCors", "WithOrigins", "AllowAnyOrigin",
            "AllowAnyHeader", "CorsPolicy", "MapHub", "X-Momentum-Dev-User"]

dosyalar = []
for kok, dizinler, adlar in os.walk(KOK):
    dizinler[:] = [d for d in dizinler if d not in ("bin", "obj")]
    for a in adlar:
        if a.endswith((".cs", ".json")):
            dosyalar.append(os.path.join(kok, a))
print("taranan backend dosyasi: %d" % len(dosyalar))

icerik = {}
for y in dosyalar:
    try:
        with open(y, "r", encoding="utf-8", errors="replace") as f:
            icerik[y] = f.read()
    except Exception as e:
        print("  [OKUNAMADI] %s: %s" % (y, e))

print("=" * 74)
for d in DESENLER:
    vurus = [(os.path.relpath(y, KOK), m.count(d)) for y, m in icerik.items() if d in m]
    if vurus:
        print("%-24s BULUNDU:" % d)
        for r, n in sorted(vurus):
            print("      %-56s x%d" % (r, n))
    else:
        print("%-24s YOK" % d)
print("=" * 74)
print("POZITIF KONTROL -- tarayici gercekten okuyor mu?")
for d in ["builder.Services", "app.Map", "using"]:
    n = sum(1 for m in icerik.values() if d in m)
    print("  '%s' gecen dosya: %d / %d" % (d, n, len(icerik)))
print("=" * 74)
prog = [y for y in icerik if os.path.basename(y) == "Program.cs"]
for y in prog:
    print("--- %s (ilk 45 satir) ---" % os.path.relpath(y, KOK))
    for i, s in enumerate(icerik[y].splitlines()[:45], 1):
        print("  %3d| %s" % (i, s))

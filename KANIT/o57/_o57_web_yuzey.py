# -*- coding: utf-8 -*-
"""WEB CALISMA-ZAMANI YUZEYI -- 'derleniyor' ile 'calisiyor' ayni sey degil.
findstr KULLANILMAZ (ORTAM.md: ayni dosyada bir dizgeyi bulup digerini
kacirabiliyor). Python ile taranir; her desen icin POZITIF KONTROL de yazilir.
"""
import os
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
LIB = r"C:\dev\Momentum\src\client\lib"

DESENLER = [
    "kIsWeb", "WasmDatabase", "driftDatabase", "NativeDatabase",
    "connectOnWeb", "sqlite3.wasm", "drift_worker", "LazyDatabase",
    "DatabaseConnection", "dart:io", "path_provider", "SignalR", "signalr",
    "http://", "10.0.2.2", "localhost", "IndexedDb", "indexeddb",
]

dosyalar = []
for kok, _, adlar in os.walk(LIB):
    for a in adlar:
        if a.endswith(".dart"):
            dosyalar.append(os.path.join(kok, a))
dosyalar.sort()
print("taranan .dart dosyasi: %d" % len(dosyalar))
print("=" * 74)

icerik = {}
for y in dosyalar:
    with open(y, "r", encoding="utf-8", errors="replace") as f:
        icerik[y] = f.read()

for d in DESENLER:
    vurus = []
    for y, m in icerik.items():
        n = m.count(d)
        if n:
            vurus.append((os.path.relpath(y, LIB), n))
    if vurus:
        print("%-20s %d dosya:" % (d, len(vurus)))
        for r, n in sorted(vurus):
            print("    %-52s x%d" % (r, n))
    else:
        print("%-20s YOK" % d)

print("=" * 74)
print("POZITIF KONTROL (tarayici gercekten okuyor mu?): 'import' gecen dosya = %d / %d"
      % (sum(1 for m in icerik.values() if "import" in m), len(dosyalar)))
print("=" * 74)
AYAR = os.path.join(LIB, "veri", "ayarlari_hazirla.dart")
if os.path.exists(AYAR):
    print("--- lib/veri/ayarlari_hazirla.dart TAM METIN ---")
    print(icerik[AYAR])
else:
    print("lib/veri/ayarlari_hazirla.dart YOK")

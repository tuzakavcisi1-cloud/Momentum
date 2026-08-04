# -*- coding: utf-8 -*-
# Oturum 56 -- tarayici (ORTAM.md: findstr yerine .py; stdout cp1254 kalkani)
import io, os, sys, re
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

KOK = sys.argv[1]
DESENLER = sys.argv[2].split("||")

# POZITIF KONTROL (ORTAM.md findstr dersi): tarayicinin gercekten okudugunu kanitla
kontrol = 0
bulgu = 0
for dizin, _, dosyalar in os.walk(KOK):
    if ".dart_tool" in dizin or "build" in dizin.split(os.sep):
        continue
    for ad in dosyalar:
        if not ad.endswith((".dart", ".yaml", ".gradle", ".kts", ".xml", ".json", ".properties",
                            ".md", ".txt", ".py", ".ps1", ".cmd", ".bat", ".log")):
            continue
        yol = os.path.join(dizin, ad)
        try:
            metin = io.open(yol, encoding="utf-8", errors="replace").read()
        except Exception as e:
            print("[OKUNAMADI]", yol, e)
            continue
        kontrol += 1
        for i, satir in enumerate(metin.splitlines(), start=1):
            for d in DESENLER:
                if re.search(d, satir):
                    bulgu += 1
                    print("%s:%d: %s" % (yol.replace(KOK, "").lstrip("\\/"), i, satir.strip()[:200]))
print("---")
print("TARANAN_DOSYA=%d  BULGU=%d" % (kontrol, bulgu))
if kontrol == 0:
    print("[KIRMIZI] POZITIF KONTROL DUSTU: hic dosya okunmadi -- bu 'bulgu yok' DEGILDIR.")

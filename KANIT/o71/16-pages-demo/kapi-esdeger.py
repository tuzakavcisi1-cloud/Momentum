# -*- coding: utf-8 -*-
"""o71 PAGES DEMOSU SS3.1 -- .github/workflows/pages.yml'deki bash+grep kapisinin
YEREL SEMANTIK ESDEGERI (KANIT/o71/16-pages-demo/ altinda -- araclar/'a KONULMADI,
K175(2) + K34-f).

BEYAN (ilk satir, kanit dosyasinin da ilk satiri olacak sekilde asagida tekrar
yazilir): Yerel olcum grep'i degil semantik esdegeri bir Python taramasini
olctu. CI'daki grep ayagi yerelde OLCULEMEDI; tek kaniti ilk CI kosumunun
logudur.

KULLANIM:
    python kapi-esdeger.py <build/web yolu> <base-href, orn /Momentum/>
"""
import os
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

DISLANAN_DOSYALAR = {"flutter.js", "flutter_bootstrap.js"}
CDN_DIZGESI = b"gstatic.com/flutter-canvaskit"
USE_LOCAL_CANVASKIT = b'"useLocalCanvasKit":true'


def dizin_var_mi(build_web):
    return os.path.isdir(build_web)


def pozitif_kontrol(build_web):
    """grep -rlI -e 'flutter' build/web esdegeri -- en az bir DOSYA icinde
    'flutter' dizgesi (metin modunda okunabilen dosyalarda -- -I ikilileri
    ATLAR) geciyor mu? Kor kapi yasagi: bu FALSE donerse tarama korlesmis
    demektir, AYAK 1/2/3'un sonucuna guvenilmez."""
    for kok, _dizinler, dosyalar in os.walk(build_web):
        for ad in dosyalar:
            yol = os.path.join(kok, ad)
            try:
                with open(yol, "r", encoding="utf-8", errors="strict") as f:
                    icerik = f.read()
            except (UnicodeDecodeError, OSError):
                continue  # -I ile ayni: ikili/okunamayan dosya atlanir
            if "flutter" in icerik:
                return True
    return False


def ayak1_varlik(build_web):
    """useLocalCanvasKit:true flutter_bootstrap.js'e indi mi?"""
    yol = os.path.join(build_web, "flutter_bootstrap.js")
    if not os.path.isfile(yol):
        return False, "flutter_bootstrap.js YOK"
    with open(yol, "rb") as f:
        ham = f.read()
    return (USE_LOCAL_CANVASKIT in ham), None


def ayak2_yokluk(build_web):
    """gstatic.com/flutter-canvaskit dizgesi, flutter.js/flutter_bootstrap.js
    HARIC hicbir dosyada (ikili dahil, -a esdegeri) GECMEMELI."""
    eslesen_dosyalar = []
    for kok, _dizinler, dosyalar in os.walk(build_web):
        for ad in dosyalar:
            if ad in DISLANAN_DOSYALAR:
                continue
            yol = os.path.join(kok, ad)
            try:
                with open(yol, "rb") as f:
                    ham = f.read()
            except OSError:
                continue
            if CDN_DIZGESI in ham:
                eslesen_dosyalar.append(yol)
    return (len(eslesen_dosyalar) == 0), eslesen_dosyalar


def ayak3_varlik(build_web, base_href):
    yol = os.path.join(build_web, "index.html")
    if not os.path.isfile(yol):
        return False, "index.html YOK"
    with open(yol, "r", encoding="utf-8", errors="replace") as f:
        icerik = f.read()
    beklenen = '<base href="%s">' % base_href
    return (beklenen in icerik), beklenen


def main():
    if len(sys.argv) < 3:
        print("KULLANIM: python kapi-esdeger.py <build/web yolu> <base-href>")
        return 2
    build_web = sys.argv[1]
    base_href = sys.argv[2]

    hepsi_gecti = True

    if not dizin_var_mi(build_web):
        print("KIRMIZI: build/web YOK (%s)" % build_web)
        return 1
    print("YESIL: build/web VAR")

    if not pozitif_kontrol(build_web):
        print("KIRMIZI: pozitif kontrol dustu -- tarama kor")
        return 1
    print("YESIL: pozitif kontrol -- en az bir dosyada 'flutter' dizgesi goruldu")

    ayak1, ayak1_detay = ayak1_varlik(build_web)
    if ayak1:
        print("YESIL: AYAK 1 -- useLocalCanvasKit:true VAR")
    else:
        print("KIRMIZI: AYAK 1 -- useLocalCanvasKit yok (%s)" % ayak1_detay)
        hepsi_gecti = False

    ayak2, ayak2_detay = ayak2_yokluk(build_web)
    if ayak2:
        print("YESIL: AYAK 2 -- CDN dizgesi izi yok (flutter.js/flutter_bootstrap.js haric)")
    else:
        print("KIRMIZI: AYAK 2 -- CDN dizgesi izi VAR: %s" % ayak2_detay)
        hepsi_gecti = False

    ayak3, ayak3_detay = ayak3_varlik(build_web, base_href)
    if ayak3:
        print("YESIL: AYAK 3 -- base href ciktiya inmis (%s)" % ayak3_detay)
    else:
        print("KIRMIZI: AYAK 3 -- base href yok (beklenen: %s)" % ayak3_detay)
        hepsi_gecti = False

    if hepsi_gecti:
        print("YESIL: useLocalCanvasKit=true - CDN URL izi yok - base href %s" % base_href)
        return 0
    return 1


if __name__ == "__main__":
    sys.exit(main())

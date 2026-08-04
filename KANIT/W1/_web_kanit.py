# -*- coding: utf-8 -*-
"""KANIT/W1/_web_kanit.py -- GOREV-W1 G37+G38 olcumu icin `flutter run -d chrome`
STDOUT LOGUNU YOKLAR (sabit sleep YOK, K86/uiautomator dersi), MOMENTUM-G6-KANIT
satirini BIREBIR yakalar.

NEDEN LOG DOSYASI (bir DevTools Protocol istemcisi degil): Flutter'in debug-mode
VM-service koprusu, Dart `print()` cagrilarini HEM tarayici konsoluna HEM
`flutter run`in kendi STDOUT'una ayni anda basar -- bu ikinci yol, ayri bir
tarayici-otomasyon baglantisi gerektirmeden GERCEK canli olcum saglar.

Kullanim: python _web_kanit.py <log_dosyasi> [beklenen_tekrar=1]
Cikis: 0 (beklenen sayida satir bulundu) * 1 (tavanda bulunamadi)
"""
import sys
import time

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

MARKER = "MOMENTUM-G6-KANIT"
TAVAN_SANIYE = 90
ARALIK_SANIYE = 2


def yokla(log_yolu, beklenen_tekrar=1):
    baslangic = time.time()
    while time.time() - baslangic < TAVAN_SANIYE:
        try:
            with open(log_yolu, "r", encoding="utf-8", errors="replace") as f:
                icerik = f.read()
        except FileNotFoundError:
            icerik = ""
        satirlar = [s for s in icerik.split("\n") if MARKER in s]
        if len(satirlar) >= beklenen_tekrar:
            return satirlar
        time.sleep(ARALIK_SANIYE)
    return None


def main(argv):
    if len(argv) < 1:
        print("KULLANIM: _web_kanit.py <log_dosyasi> [beklenen_tekrar]")
        return 2
    log_yolu = argv[0]
    beklenen_tekrar = int(argv[1]) if len(argv) > 1 else 1
    satirlar = yokla(log_yolu, beklenen_tekrar)
    if satirlar is None:
        print("KIRMIZI: %d saniyede '%s' iceren >= %d satir GORUNMEDI (log: %s)" %
              (TAVAN_SANIYE, MARKER, beklenen_tekrar, log_yolu))
        return 1
    print("HAZIR: %d satir bulundu (>= %d beklenen)" % (len(satirlar), beklenen_tekrar))
    for i, s in enumerate(satirlar, 1):
        print("  [%d] %s" % (i, s.strip()))
        if "missingFeatures=" in s:
            eksik = s.split("missingFeatures=", 1)[1].strip()
            if eksik and eksik not in ("[]", "{}", "()"):
                print("  *** DIKKAT: missingFeatures BOS DEGIL -- %s (G37/c: bu ACIKCA yazilmalidir)" % eksik)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

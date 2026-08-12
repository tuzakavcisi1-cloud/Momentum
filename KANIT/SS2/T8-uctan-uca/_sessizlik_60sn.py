# -*- coding: utf-8 -*-
"""ADIM 4 -- B cevrimdisiyken 60 saniyelik sessizlik olcumu (backend log buyumez)."""
import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from yardimcilar import mesaj, kanit_yaz  # noqa: E402

BURASI = os.path.dirname(os.path.abspath(__file__))
LOG_YOLU = os.path.join(BURASI, "09-backend-log.txt")


def main():
    gunluk = [mesaj("ADIM 4 -- 60 saniyelik sessizlik olcumu basliyor (B cevrimdisi, kuyrukta 1 op)")]
    with open(LOG_YOLU, "rb") as f:
        once = f.read()
    gunluk.append(mesaj("  60sn ONCESI log boyutu: %d bayt" % len(once)))
    time.sleep(60)
    with open(LOG_YOLU, "rb") as f:
        sonra = f.read()
    gunluk.append(mesaj("  60sn SONRASI log boyutu: %d bayt (fark=%d)" % (len(sonra), len(sonra) - len(once))))
    yeni_satirlar = sonra[len(once):].decode("utf-8", "replace")
    gunluk.append(mesaj("  yeni satirlar:\n" + (yeni_satirlar if yeni_satirlar.strip() else "(YOK -- tam sessizlik)")))
    kanit_yaz(os.path.join(BURASI, "05-adim4-60sn-sessizlik.txt"), gunluk)
    print("\n".join(gunluk))


if __name__ == "__main__":
    main()

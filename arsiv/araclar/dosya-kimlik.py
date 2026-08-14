# -*- coding: utf-8 -*-
"""dosya-kimlik.py -- dosya kimligini OLCER (beyan degil).

Her oturum PROJE_HAFIZA.md'ye "bayt + sha256 ilk 8" yaziyor. Bu betik onu
tek komutla uretir ve ayrica iki sessiz kusuru yakalar:
  * U+FFFD (bozuk kodlama; Turkce karakter kaybi)
  * CRLF (satir sonu kirlenmesi)

NEDEN BETIK: Cowork->Desktop Commander koprusunde PowerShell'e giden
komutlarda "$" degiskenleri SILINIYOR ve ic ice tirnaklar bozuluyor
(oturum 29'da olculdu). Tek satirlik python -c cagrilari bu yuzden
guvenilmez; kimlik olcumu dosyaya alindi.

Kullanim:  python araclar\\dosya-kimlik.py <yol> [yol...]
Cikis: 0 = hepsi temiz · 1 = en az bir dosyada FFFD/CRLF · 3 = dosya yok
"""
import hashlib
import os
import sys


def main(yollar):
    if not yollar:
        print("KULLANIM: python araclar\\dosya-kimlik.py <yol> [yol...]")
        return 3
    kirli = False
    eksik = False
    print("%-46s %10s %9s %6s %6s" % ("DOSYA", "BAYT", "SHA8", "FFFD", "CRLF"))
    print("-" * 82)
    for y in yollar:
        if not os.path.isfile(y):
            print("%-46s %10s" % (y, "YOK"))
            eksik = True
            continue
        b = open(y, "rb").read()
        sha8 = hashlib.sha256(b).hexdigest()[:8].upper()
        crlf = b.count(b"\r\n")
        try:
            # U+FFFD LITERAL OLARAK YAZILMAZ: yazilirsa betigin KENDISI kirli
            # olcumlenir (oturum 29'da olculdu, yanlis-pozitif). chr() ile uret.
            fffd = b.decode("utf-8").count(chr(0xFFFD))
        except UnicodeDecodeError:
            fffd = -1  # -1 = dosya hic UTF-8 degil
        if fffd != 0 or crlf != 0:
            kirli = True
        print("%-46s %10d %9s %6d %6d" % (os.path.basename(y), len(b), sha8, fffd, crlf))
    print("-" * 82)
    if eksik:
        print("HUKUM: EN AZ BIR DOSYA YOK")
        return 3
    print("HUKUM: " + ("KIRLI (FFFD veya CRLF var)" if kirli else "TEMIZ"))
    return 1 if kirli else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

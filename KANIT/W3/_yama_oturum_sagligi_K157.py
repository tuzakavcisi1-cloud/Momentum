#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""K157 yamasi -- oturum-sagligi.py D1 kimlik ayagini KIMLIKLER.md'yi de okuyacak sekilde onarir.

OLCULMUS KUSUR (oturum 62 acilisi): K151 (6 Agu 2026) DURUM.md 9. bolumunu KIMLIKLER.md'ye tasidi.
oturum-sagligi.py YALNIZ DURUM.md'ye bakiyordu => her kosumda
  [OLCULEMEDI] D1: DURUM.md kimlik tablosu: kimlik girisi AYRISTIRILAMADI
diyordu. Yani K151'den beri D1'in kimlik ayagi KORDU ve bunu kimse olcmedi.

YAMA ATOMIKTIR (K60 + ORTAM.md: os.replace bu makinede WinError 5 verebilir):
  .tmp yaz -> hedef .yedek'e rename -> .tmp hedefe rename -> sha dogrula -> .yedek sil
"""
import hashlib
import io
import os
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

YOL = os.path.join("araclar", "oturum-sagligi.py")

ESKI_GOVDE = '''def d1_durum_tablosu(kok, bulgular):
    yol = os.path.join(kok, "DURUM.md")
    if not os.path.isfile(yol):
        bulgular.append(("OLCULEMEDI", "D1", "DURUM.md YOK ⇒ kimlik tablosu OLCULEMEDI."))
        return
    girisler = []
    for no, satir in enumerate(oku(yol).splitlines(), 1):
        m = TABLO_SATIRI.match(satir)
        if not m:
            continue
        hucreler = [h.strip() for h in m.group(1).split("|")]
        if len(hucreler) < 3:
            continue
        ad_m = re.search(r"`([^`]+)`", hucreler[0])
        bayt_m = re.search(r"(\\d[\\d.,]*)", hucreler[1])
        sha_m = re.search(r"([0-9A-Fa-f]{8})", hucreler[2])
        if not (ad_m and bayt_m and sha_m):
            continue
        if not re.search(r"\\.[A-Za-z0-9]+$", ad_m.group(1).strip()):
            continue
        girisler.append((ad_m.group(1).strip(), sayiya(bayt_m.group(1)),
                         sha_m.group(1), no))
    kimlik_karsilastir(kok, "DURUM.md kimlik tablosu", girisler, bulgular)'''

YENI_GOVDE = '''# K151 (6 Agu 2026) DURUM.md 9. bolumunu KIMLIKLER.md'ye TASIDI. Kapsam bu yuzden bir
# LISTEDIR, tek dosya adi DEGIL -- hangi belge tabloyu tasiyorsa oradan okunur.
KIMLIK_TABLOSU_BELGELERI = ("KIMLIKLER.md", "DURUM.md")


def _kimlik_tablosu_girisleri(yol):
    girisler = []
    for no, satir in enumerate(oku(yol).splitlines(), 1):
        m = TABLO_SATIRI.match(satir)
        if not m:
            continue
        hucreler = [h.strip() for h in m.group(1).split("|")]
        if len(hucreler) < 3:
            continue
        ad_m = re.search(r"`([^`]+)`", hucreler[0])
        bayt_m = re.search(r"(\\d[\\d.,]*)", hucreler[1])
        sha_m = re.search(r"([0-9A-Fa-f]{8})", hucreler[2])
        if not (ad_m and bayt_m and sha_m):
            continue
        if not re.search(r"\\.[A-Za-z0-9]+$", ad_m.group(1).strip()):
            continue
        girisler.append((ad_m.group(1).strip(), sayiya(bayt_m.group(1)),
                         sha_m.group(1), no))
    return girisler


def d1_durum_tablosu(kok, bulgular):
    """K157 (oturum 62): kimlik tablosu ARTIK DURUM.md'de degil KIMLIKLER.md'de.

    Bu fonksiyon K151'den oturum 62'ye kadar yalniz DURUM.md'ye bakti ve her kosumda
    'AYRISTIRILAMADI => OLCULEMEDI' dedi: bir siniri TASIYAN el, o siniri OKUYAN araci
    tasimadigi icin D1'in kimlik ayagi KOR kaldi. Kapsam artik bir listedir; TABLOYU
    TASIYAN HER BELGE olculur ve OLCULEMEDI yalnizca HICBIRINDE giris yoksa yazilir --
    aksi halde tablosuz kalan DURUM.md kalici bir yanlis-pozitif uretirdi."""
    bulunan, olculdu = [], False
    for ad in KIMLIK_TABLOSU_BELGELERI:
        yol = os.path.join(kok, ad)
        if not os.path.isfile(yol):
            continue
        bulunan.append(ad)
        girisler = _kimlik_tablosu_girisleri(yol)
        if girisler:
            olculdu = True
            kimlik_karsilastir(kok, "%s kimlik tablosu" % ad, girisler, bulgular)
    if olculdu:
        return
    if not bulunan:
        bulgular.append(("OLCULEMEDI", "D1",
                         "kimlik tablosu belgesi YOK (%s aranmisti) \\u21d2 OLCULEMEDI."
                         % ", ".join(KIMLIK_TABLOSU_BELGELERI)))
        return
    bulgular.append(("OLCULEMEDI", "D1",
                     "%s: kimlik girisi AYRISTIRILAMADI \\u21d2 OLCULEMEDI "
                     "(bu 'TEMIZ' DEGILDIR)." % " + ".join(bulunan)))'''

ESKI_YARDIMCI = '''def _isirdi(bulgular, kod, seviye="KIRMIZI"):
    return any(b[0] == seviye for b in _kodlar(bulgular, kod))'''

YENI_YARDIMCI = ESKI_YARDIMCI + '''


def _ayristirilamadi(bulgular):
    """K157: 'AYRISTIRILAMADI' yanlis-pozitifini vaka duzeyinde olcer."""
    return any(b[1] == "D1" and "AYRISTIRILAMADI" in b[2] for b in bulgular)'''

ESKI_VAKA17 = '''    vaka("17) D1 BAYT TUTUYOR ama SHA BAYAT -- ISIRMALI (ayni boyutta degisim)",
         _isirdi(b, "D1"))'''

YENI_VAKA17 = ESKI_VAKA17 + '''

    # --- K157 (oturum 62): kapsam bir LISTEDIR. K151 tabloyu KIMLIKLER.md'ye tasiyinca
    #     bu ayak KORLESTI; asagidaki dort vaka o korlugu PINLER.
    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ, "veri.txt": hedef,
                    "KIMLIKLER.md": tablo_taze})
    b, _ = tara(kok)
    vaka("17b) TABLO YALNIZ KIMLIKLER.md'de -- OLCULMELI ve SUSMALI",
         (not _isirdi(b, "D1")) and (not _ayristirilamadi(b)))

    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ, "veri.txt": hedef,
                    "KIMLIKLER.md": tablo_bayat})
    b, _ = tara(kok)
    vaka("17c) KIMLIKLER.md'de BAYAT KIMLIK -- ISIRMALI", _isirdi(b, "D1"))

    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ, "veri.txt": hedef,
                    "KIMLIKLER.md": tablo_taze,
                    "DURUM.md": "tablosuz canli durum\\n"})
    b, _ = tara(kok)
    vaka("17d) KIMLIKLER.md TAZE + DURUM.md TABLOSUZ -- "
         "DURUM.md 'AYRISTIRILAMADI' DEMEMELI (K151'in urettigi yanlis-pozitif)",
         (not _isirdi(b, "D1")) and (not _ayristirilamadi(b)))

    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ, "veri.txt": hedef,
                    "DURUM.md": "tablosuz\\n", "KIMLIKLER.md": "tablosuz\\n"})
    b, _ = tara(kok)
    vaka("17e) HICBIR BELGEDE TABLO YOK -- 'OLCULEMEDI' demeli, TEMIZ DEMEMELI",
         _ayristirilamadi(b))'''


def main():
    if not os.path.isfile(YOL):
        print("ORTAM HATASI: %s yok (kokten kos)" % YOL)
        return 3
    with io.open(YOL, "rb") as f:
        eski = f.read()
    s = eski.decode("utf-8")

    for ad, a, y in (("d1_durum_tablosu", ESKI_GOVDE, YENI_GOVDE),
                     ("_isirdi yardimcisi", ESKI_YARDIMCI, YENI_YARDIMCI),
                     ("vaka 17", ESKI_VAKA17, YENI_VAKA17)):
        n = s.count(a)
        if n != 1:
            print("DUR: '%s' capasi %d kez bulundu (1 olmali). YAMA UYGULANMADI." % (ad, n))
            return 1
        s = s.replace(a, y, 1)

    yeni = s.encode("utf-8")
    tmp, yedek = YOL + ".tmp", YOL + ".yedek"
    with io.open(tmp, "wb") as f:
        f.write(yeni)
    os.rename(YOL, yedek)                 # K60 / ORTAM.md: uc adimli yedekli takas
    try:
        os.rename(tmp, YOL)
    except Exception:
        os.rename(yedek, YOL)
        raise
    with io.open(YOL, "rb") as f:
        diskteki = f.read()
    if hashlib.sha256(diskteki).hexdigest() != hashlib.sha256(yeni).hexdigest():
        os.remove(YOL)
        os.rename(yedek, YOL)
        print("DUR: sha dogrulamasi TUTMADI, geri alindi.")
        return 1
    os.remove(yedek)
    print("YAMA UYGULANDI. %d b -> %d b · CRLF=%d"
          % (len(eski), len(yeni), diskteki.count(b"\r\n")))
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SAYI TAZELIGI KAPISI — belgelerdeki "altin kume N/M" iddialarini ARACI KOSARAK dogrular.
=======================================================================================
Neden var (OLCULMUS kok neden, K57 / oturum 30):
  `GOREV-slice-3b-istemci-iskeleti.md` DORT bagimsiz denetim turundan gecmisti ve
  "spec-kapi-kapsama.py --altin-kume (9/9)" diyordu. Arac FIILEN 13 vaka tasiyordu.
  Dort turun hicbiri bunu bulmadi; bir regex taramasi + bir arac kosumu dakikalar
  icinde buldu. Ayni sinif (`kanonik-kopya`) DESIGN.md BD-6'da ve DURUM.md 6'da da
  tekrarladi => UC KEZ => R1'in mekaniklestirme esiginin USTUNDE.

Ilke: SAYI EZBERDEN YAZILMAZ, CIKTIDAN OKUNUR.

Kullanim:
    python araclar/sayi-tazeligi.py --altin-kume          # arac ONCE kendini kanitlar
    python araclar/sayi-tazeligi.py <kok> [dosya ...]     # gercek kosum
Cikis kodu: 0 = TEMIZ · 1 = BULGU · 3 = KULLANIM/OLCUM HATASI

BEYAN EDILMIS SINIRLAR (gizlenmez, ciktiya BASILIR):
  * Yalniz ALTIN KUME SAYISI olculur. Paket SURUM tazeligi OLCULMEZ -- o aga cikar
    ve `pub-surum-olc.py`'nin isidir (onun kendi bosluğu spec Z10b'de yazilidir).
  * Bu kapi bir vakanin DOGRU olup olmadigini olcmez; yalnizca KAC VAKA oldugunu olcer.
  * Cift tirnak icindeki bir sayi ALINTIDIR, iddia degildir => hukum verilmez ama
    `T4` ile GORUNUR kalir. "Olculmedi" demek "temiz" demek DEGILDIR.
  * Arac kosulamazsa TEMIZ denmez, `T3` denir.
"""
import argparse
import json
import os
import re
import subprocess
import sys
import tempfile

SURUM = "1.1.0"
# 1.1.0 [OLCULMUS GENISLETME]: 1.0.0 ilk gercek kosumunda BIR bayat sayi buldu ama
# UC KOR NOKTASI olculdu: (a) DURUM.md 6 ARAC TABLOSU -- satirda "altin kume" yazmiyor,
# yazan sey TABLO BASLIGI; (b) DESIGN.md:235 "altin kume 10/10" -- satirda ARAC ADI yok,
# yani bilinen bayat sayi (BD-6) kapinin ONUNDEN gecip gidiyordu; (c) K46 yuzunden
# DUZELTILEMEYEN bir belge icin muafiyet yolu yoktu. Ucu de kapatildi.

# Bir satirin "altin kume iddiasi" sayilmasi icin GEREKEN isaretler
IMZA = ("altin kume", "altinkume", "--altin-kume", "golden set")
SAYI = re.compile(r"(\d{1,3})\s*/\s*(\d{1,3})")
ARAC = re.compile(r"([A-Za-z0-9_\-]+\.py)")
# Araclarin altin kume ciktisindaki vaka satirlari (UC ARACTA DA OLCULDU: radar.py,
# spec-kapi-kapsama.py, design-token-kapisi.py hepsi bu bicimi basiyor)
VAKA = re.compile(r"^\s*\[(GECTI|KALDI)\]")


def _sadelestir(s):
    """Turkce harfleri ASCII'ye indirger (kucuk harf). Regex Turkce morfolojisi TASIMAZ;
    burada yalnizca ANAHTAR KELIME esleme icin kullanilir, dilbilgisi iddiasi yoktur."""
    d = {"ı": "i", "İ": "i", "ş": "s", "Ş": "s", "ğ": "g", "Ğ": "g",
         "ü": "u", "Ü": "u", "ö": "o", "Ö": "o", "ç": "c", "Ç": "c"}
    return "".join(d.get(k, k) for k in s).lower()


def _tirnak_araliklari(satir):
    """Cift tirnak (\" ve tipografik) ciftlerinin [bas, son) araliklarini dondurur."""
    araliklar, acik = [], None
    for i, k in enumerate(satir):
        if k in '"“”':
            if acik is None:
                acik = i
            else:
                araliklar.append((acik, i + 1))
                acik = None
    return araliklar


def _alintida_mi(konum, araliklar):
    return any(a <= konum < b for a, b in araliklar)


def olc_vaka_sayisi(arac_yolu, zaman_asimi=300):
    """Araci --altin-kume ile KOSAR ve [GECTI]/[KALDI] satirlarini SAYAR.
    Doner: (sayi, gecen, hata_metni). sayi None ise OLCULEMEDI."""
    try:
        p = subprocess.run([sys.executable, arac_yolu, "--altin-kume"],
                           capture_output=True, text=True, encoding="utf-8",
                           errors="replace", timeout=zaman_asimi)
    except Exception as ex:
        return None, None, "kosulamadi: %r" % (ex,)
    satirlar = (p.stdout or "").splitlines()
    vakalar = [s for s in satirlar if VAKA.match(s)]
    if not vakalar:
        return None, None, ("altin kume ciktisi AYRISTIRILAMADI "
                            "([GECTI]/[KALDI] satiri yok, EXIT=%d)" % p.returncode)
    gecen = sum(1 for s in vakalar if "[GECTI]" in s)
    return len(vakalar), gecen, None


def muafiyet_yukle(kok):
    """araclar/tazelik-muafiyet.json -- K46 gibi DUZELTILEMEYEN belgeler icin.
    Muafiyet SESSIZ DEGILDIR: uygulanan her muafiyet T6 ile BASILIR.
    Gerekcesiz ya da borc kimliksiz muafiyet KIRMIZI'dir (T7) -- beyan, gerekce demektir.
    Bicim: [{"dosya": "DESIGN.md", "satir": 235, "borc": "BD-6", "gerekce": "..."}]"""
    p = os.path.join(kok, "araclar", "tazelik-muafiyet.json")
    if not os.path.isfile(p):
        return [], []
    try:
        d = json.load(open(p, encoding="utf-8"))
    except Exception as ex:
        return [], [("KIRMIZI", "T7", "tazelik-muafiyet.json BOZUK: %r" % (ex,))]
    hata = []
    for k in d:
        if not k.get("gerekce") or not k.get("borc"):
            hata.append(("KIRMIZI", "T7",
                         "GEREKCESIZ MUAFIYET: %s:%s -- muafiyet kaydinda `borc` ve "
                         "`gerekce` ZORUNLUDUR. Beyan etmek, GEREKCE vermek demektir."
                         % (k.get("dosya", "?"), k.get("satir", "?"))))
    return d, hata


def _muaf(muafiyetler, dosya, no, satir):
    """`desen` (satir icinde gecen dizge) TERCIH EDILIR -- satir numarasi belge
    degistikce KAYAR ve muafiyet sessizce YANLIS SATIRA oturur."""
    for k in muafiyetler:
        if k.get("dosya") != dosya:
            continue
        if k.get("desen") and k["desen"] in satir:
            return k
        if k.get("desen") is None and int(k.get("satir", -1)) == no:
            return k
    return None


def denetle(kok, dosyalar, onbellek=None):
    """Doner: bulgular listesi [(SEVIYE, KOD, mesaj)]"""
    muafiyetler, b = muafiyet_yukle(kok)
    onbellek = {} if onbellek is None else onbellek
    for dosya in dosyalar:
        tam = dosya if os.path.isabs(dosya) else os.path.join(kok, dosya)
        if not os.path.isfile(tam):
            b.append(("KIRMIZI", "T0", "%s: DOSYA YOK -- denetlenemedi." % dosya))
            continue
        try:
            metin = open(tam, encoding="utf-8").read()
        except Exception as ex:
            b.append(("KIRMIZI", "T0", "%s: OKUNAMADI: %r" % (dosya, ex)))
            continue
        tablo_imzali = False
        for no, satir in enumerate(metin.split("\n"), 1):
            sade = _sadelestir(satir)
            satir_imzali = any(i in sade for i in IMZA)
            tablo_satiri = satir.strip().startswith("|")
            # MARKDOWN TABLO TAKIBI: basligi "altin kume" iceren bir tablonun HER SATIRI
            # iddia sayilir. (Olculmus kor nokta: DURUM.md 6 arac tablosunda imza
            # SATIRDA degil TABLO BASLIGINDA duruyor; 1.0.0 tabloyu hic gormedi.)
            if tablo_satiri:
                if satir_imzali:
                    tablo_imzali = True
            else:
                tablo_imzali = False
            if not (satir_imzali or (tablo_imzali and tablo_satiri)):
                continue
            if not SAYI.search(satir):
                continue
            muafiyet = _muaf(muafiyetler, dosya, no, satir)
            if muafiyet:
                b.append(("BILGI", "T6",
                          "%s:%d: MUAFIYET UYGULANDI [borc %s] -- %s (kaynak: "
                          "araclar/tazelik-muafiyet.json). Muafiyet SESSIZ DEGILDIR; "
                          "borc kapaninca bu satir da kapanir."
                          % (dosya, no, muafiyet.get("borc"), muafiyet.get("gerekce"))))
                continue
            araclar = [(m.start(), m.group(1)) for m in ARAC.finditer(satir)]
            tirnaklar = _tirnak_araliklari(satir)
            if not araclar:
                # ARAC ADI YOK => iddia MEKANIK OLARAK BAGLANAMIYOR.
                # (Olculmus kor nokta: DESIGN.md'nin BILINEN bayat "10/10"u tam
                #  boyle kacip gidiyordu -- satirda arac adi yoktu.)
                for m in SAYI.finditer(satir):
                    if _alintida_mi(m.start(), tirnaklar):
                        continue
                    b.append(("SARI", "T5",
                              "%s:%d: BAGLANAMADI -- satir altin kume sayisi (%s/%s) "
                              "iddia ediyor ama SATIRDA ARAC ADI YOK => hangi araci "
                              "kosacagi mekanik olarak belirlenemiyor. Arac adini yaz "
                              "ya da gerekceli muafiyet kaydi ac. OLCULMEDI, TEMIZ DEGIL."
                              % (dosya, no, m.group(1), m.group(2))))
                continue
            for m in SAYI.finditer(satir):
                iddia_gecen, iddia_toplam = int(m.group(1)), int(m.group(2))
                # en yakin arac adi (once solda arar, yoksa sagda)
                sol = [a for a in araclar if a[0] < m.start()]
                ad = (sol[-1][1] if sol else araclar[0][1])
                if _alintida_mi(m.start(), tirnaklar):
                    b.append(("BILGI", "T4",
                              "%s:%d: \"%d/%d\" ALINTI icinde (%s) => hukum VERILMEDI. "
                              "OLCULMEDI, TEMIZ DEGIL." % (dosya, no, iddia_gecen,
                                                           iddia_toplam, ad)))
                    continue
                arac_yolu = os.path.join(kok, "araclar", ad)
                if not os.path.isfile(arac_yolu):
                    alt = os.path.join(kok, ad)
                    arac_yolu = alt if os.path.isfile(alt) else None
                if arac_yolu is None:
                    b.append(("KIRMIZI", "T2",
                              "%s:%d: HAYALET ARAC -- belge `%s` diyor, o dosya YOK. "
                              "Iddia edilen sayi (%d/%d) DOGRULANAMAZ."
                              % (dosya, no, ad, iddia_gecen, iddia_toplam)))
                    continue
                if arac_yolu not in onbellek:
                    onbellek[arac_yolu] = olc_vaka_sayisi(arac_yolu)
                gercek, gecen, hata = onbellek[arac_yolu]
                if gercek is None:
                    b.append(("SARI", "T3",
                              "%s:%d: OLCULEMEDI -- `%s` %s. Bu satirin %d/%d iddiasi "
                              "DOGRULANMADI. Olculmedi demek TEMIZ demek DEGILDIR."
                              % (dosya, no, ad, hata, iddia_gecen, iddia_toplam)))
                    continue
                if iddia_toplam != gercek:
                    b.append(("KIRMIZI", "T1",
                              "%s:%d: BAYAT SAYI -- belge `%s` icin %d/%d diyor, arac "
                              "FIILEN %d vaka tasiyor (kosuldu, %d gecti). "
                              "Sayi ezberden yazilmis; ciktidan okunmali."
                              % (dosya, no, ad, iddia_gecen, iddia_toplam,
                                 gercek, gecen)))
                elif iddia_gecen != gecen:
                    b.append(("SARI", "T1b",
                              "%s:%d: TOPLAM dogru (%d) ama GECEN sayisi uyusmuyor -- "
                              "belge %d diyor, arac %d gecti (`%s`)."
                              % (dosya, no, gercek, iddia_gecen, gecen, ad)))
    return b


def rapor(bulgular, hedefler):
    print("=" * 78)
    print("SAYI TAZELIGI KAPISI v%s -- 'altin kume N/M' iddialari" % SURUM)
    print("hedef: " + ", ".join(hedefler))
    print("=" * 78)
    if not bulgular:
        print("BULGU YOK: her altin kume iddiasi ARACIN GERCEK VAKA SAYISIYLA eslesti.")
    for sev, kod, msg in bulgular:
        print("[%s] %s: %s" % (sev, kod, msg))
    print("-" * 78)
    print("BEYAN EDILMIS SINIR: bu kapi yalniz ALTIN KUME SAYISINI olcer. Paket SURUM")
    print("tazeligini OLCMEZ (ag ister; `pub-surum-olc.py`'nin isidir ve onun kendi")
    print("bosluğu spec Z10b'de yazilidir). Bir vakanin DOGRU olup olmadigini da olcmez.")
    print("=" * 78)
    if any(s == "KIRMIZI" for s, _, _ in bulgular):
        print("HUKUM: BAYAT SAYI VAR -- belge duzeltilmeden kilitlenemez.")
        return 1
    if any(s == "SARI" for s, _, _ in bulgular):
        print("HUKUM: OLCULEMEYEN IDDIA VAR -- 'temiz' DENMEZ.")
        return 1
    print("HUKUM: TEMIZ")
    return 0


# ------------------------------------------------------------------ ALTIN KUME
def _yaz(yol, icerik):
    with open(yol, "w", encoding="utf-8", newline="\n") as f:
        f.write(icerik)


def altin_kume():
    print("=" * 78)
    print("ALTIN KUME -- ARACIN KENDI KANITI (kor kapi yok)")
    print("=" * 78)
    gecti = kaldi = 0
    with tempfile.TemporaryDirectory() as kok:
        ar = os.path.join(kok, "araclar")
        os.makedirs(ar)
        # 5 vakali saglam vekil arac
        _yaz(os.path.join(ar, "vekil5.py"),
             "print('basli')\n"
             "for i in range(5):\n"
             "    print('[GECTI] %d) vaka' % (i + 1))\n"
             "print('HUKUM: ARAC KULLANILABILIR')\n")
        # 5 vaka, 1'i KALDI
        _yaz(os.path.join(ar, "vekil5k.py"),
             "for i in range(4):\n"
             "    print('[GECTI] %d) vaka' % (i + 1))\n"
             "print('[KALDI] 5) vaka')\n")
        # coken arac
        _yaz(os.path.join(ar, "coker.py"),
             "import sys\nsys.stderr.write('patladi\\n')\nsys.exit(1)\n")
        # altin kumesi OLMAYAN arac (hicbir vaka satiri basmaz)
        _yaz(os.path.join(ar, "sessiz.py"), "print('ben altin kume tasimiyorum')\n")

        def kontrol(ad, icerik, beklenen, olmamasi=(), dosya_adi="B.md"):
            nonlocal gecti, kaldi
            if icerik is not None:
                _yaz(os.path.join(kok, dosya_adi), icerik)
            kodlar = sorted({k for _, k, _ in denetle(kok, [dosya_adi])})
            ok = (all(k in kodlar for k in beklenen)
                  and not any(k in kodlar for k in olmamasi))
            print("\n[%s] %s" % ("GECTI" if ok else "KALDI", ad))
            print("    beklenen: %s · olmamali: %s · olculen: %s"
                  % (list(beklenen), list(olmamasi), kodlar))
            if ok:
                gecti += 1
            else:
                kaldi += 1

        kontrol("1) TEMIZ -- dogru sayi, hicbir sey isirmamali",
                "`python araclar/vekil5.py --altin-kume` (**5/5**, EXIT 0)\n",
                (), ("T0", "T1", "T1b", "T2", "T3", "T4"))
        kontrol("2) BAYAT SAYI -- T1 ISIRMALI",
                "`python araclar/vekil5.py --altin-kume` (**9/9**)\n", ("T1",))
        kontrol("3) HAYALET ARAC -- T2 ISIRMALI",
                "altin kume: `yok-boyle-bir-arac.py --altin-kume` (**4/4**)\n",
                ("T2",), ("T1",))
        kontrol("4) ARAC COKUYOR -- T3 ISIRMALI, 'temiz' DEMEMELI",
                "altin kume `araclar/coker.py --altin-kume` (**3/3**)\n",
                ("T3",), ("T1",))
        kontrol("5) ALTIN KUMESI OLMAYAN ARAC -- T3 ISIRMALI",
                "altin kume `araclar/sessiz.py --altin-kume` (**7/7**)\n",
                ("T3",), ("T1",))
        kontrol("6) ALINTI ICINDEKI SAYI -- T1 SUSMALI, T4 GORUNMELI",
                "`vekil5.py --altin-kume` (**5/5**) -- eski \"9/9\" rakami bayatti\n",
                ("T4",), ("T1",))
        kontrol("7) ARACLA ILGISIZ N/M -- YANLIS-POZITIF OLMAMALI",
                "A11Y guideline testi VM'de 3/3 gecti; kapi 3/3 der, 4/4 DEMEZ.\n",
                (), ("T1", "T2", "T3", "T4"))
        kontrol("8) TOPLAM dogru ama GECEN yanlis -- T1b ISIRMALI",
                "altin kume `araclar/vekil5k.py --altin-kume` (**5/5**)\n",
                ("T1b",), ("T1",))
        kontrol("9) DOSYA YOK -- T0 ISIRMALI",
                None, ("T0",), (), dosya_adi="YOK.md")
        kontrol("10) IMZASIZ SATIR -- kapi karismamali (kapsam disi)",
                "`python araclar/vekil5.py .` cikti 9/9 seklindeydi\n",
                (), ("T1", "T2", "T3", "T4"))
        # --- 1.1.0'da OLCULEN kor noktalarin vakalari
        kontrol("11) TABLO MODU -- imza TABLO BASLIGINDA, bayat satir ISIRMALI",
                "| arac | ne yapar | altin kume |\n"
                "|---|---|---|\n"
                "| `vekil5.py` | bir sey yapar | **9/9** |\n",
                ("T1",))
        kontrol("12) TABLO MODU YANLIS-POZITIF -- dogru sayida SUSMALI",
                "| arac | ne yapar | altin kume |\n"
                "|---|---|---|\n"
                "| `vekil5.py` | bir sey yapar | **5/5** |\n",
                (), ("T1", "T5"))
        kontrol("13) ARAC ADI YOK -- T5 ISIRMALI (bilinen kacak yolu)",
                "**26 Tem olcumu:** altin kume **10/10 GECTI** -- arac adi yazilmamis\n",
                ("T5",), ("T1",))
        _yaz(os.path.join(ar, "tazelik-muafiyet.json"),
             '[{"dosya": "B.md", "desen": "10/10 GECTI", "borc": "BD-X",\n'
             '  "gerekce": "belge dondurulmus (K46 benzeri), duzeltilemez"}]\n')
        kontrol("14) GEREKCELI MUAFIYET -- T6 BASMALI, T5 SUSMALI",
                "**26 Tem olcumu:** altin kume **10/10 GECTI** -- arac adi yazilmamis\n",
                ("T6",), ("T5", "T7"))
        _yaz(os.path.join(ar, "tazelik-muafiyet.json"),
             '[{"dosya": "B.md", "desen": "10/10 GECTI"}]\n')
        kontrol("15) GEREKCESIZ MUAFIYET -- T7 ISIRMALI (beyan = gerekce demektir)",
                "**26 Tem olcumu:** altin kume **10/10 GECTI** -- arac adi yazilmamis\n",
                ("T7",))
        os.remove(os.path.join(ar, "tazelik-muafiyet.json"))
        kontrol("16) MUAFIYET DOSYASI YOKKEN -- kapi normal calismali",
                "`python araclar/vekil5.py --altin-kume` (**5/5**)\n",
                (), ("T6", "T7", "T1"))

    print("\n" + "=" * 78)
    print("HUKUM: %d/%d GECTI -- %s" % (gecti, gecti + kaldi,
          "ARAC KULLANILABILIR" if kaldi == 0 else "ARAC KULLANILAMAZ"))
    print("=" * 78)
    return 0 if kaldi == 0 else 1


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    ap = argparse.ArgumentParser(description="Sayi tazeligi kapisi")
    ap.add_argument("kok", nargs="?", help="proje kok dizini")
    ap.add_argument("dosyalar", nargs="*", help="denetlenecek belgeler (kok'e gore)")
    ap.add_argument("--altin-kume", action="store_true")
    a = ap.parse_args()
    if a.altin_kume:
        return altin_kume()
    if not a.kok:
        ap.print_help()
        return 3
    hedefler = a.dosyalar or ["DURUM.md", "DESIGN.md", "CLAUDE.md"]
    return rapor(denetle(a.kok, hedefler), hedefler)


if __name__ == "__main__":
    sys.exit(main())

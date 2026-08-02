#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BELGE TAVAN KAPISI — canli belgelerin BAYT TAVANINI mekanik olarak zorlar.
==========================================================================
Neden var (OLCULMUS, K58 -> oturum 34 -> oturum 35):
  K58 `DURUM.md` icin 32 KB tavan koydu ve ayni cumlede kendi zayifligini BEYAN etti:
  "tavani su an HICBIR KAPI ZORLAMIYOR -- ilk isirista belge-tavan-kapisi.py yazilir."
  Tavan o gunden beri UC oturumda toplam ON UC KEZ asildi (34: yedi kez, 35: alti kez)
  ve her seferinde el ile budandi. Beyan edilmis zayif kontrol, kontrol DEGILDIR.

NE OLCER: tavan + PAY. Sadece "asti mi" demez; paya gore SARI/KIRMIZI ayrimi yapar,
  cunku bu projede kusur "tavani astim" degil "tavana 38 bayt kala checkpoint yazamiyorum"
  bicimide dogdu -- yani DAR PAY, asimin kendisi kadar zararlidir.

NE OLCMEZ (BEYAN EDILMIS SINIR, ciktiya BASILIR):
  * Icerigin GEREKLI olup olmadigini olcmez. "Budanmali" demez, "tavan asildi" der.
  * Hangi bolumun sisirdigini SOYLER (--bolum) ama neyin silinecegine KARAR VERMEZ.
  * Tavani KENDI DEGISTIRMEZ. Esik degisikligi K40 geregi Onur'dan gelir.

Kullanim:
    python araclar/belge-tavan-kapisi.py --altin-kume    # arac ONCE kendini kanitlar
    python araclar/belge-tavan-kapisi.py <kok> [--bolum]
Cikis: 0 = YESIL/SARI · 1 = KIRMIZI (tavan asildi) · 3 = kullanim hatasi
"""
import argparse
import io
import os
import re
import sys

SURUM = "1.0.0"

# (yol, tavan_bayt, gerekce) -- tavan degisikligi K40 geregi ONUR'dan gelir.
VARSAYILAN_KAPSAM = [
    ("DURUM.md", 32768, "K58 -- R4 freni + dikkat; 12 KB'den yukseltildi"),
    ("CLAUDE.md", 32768, "acilista TAM okunur; DURUM.md ile ayni gerekce"),
    ("DESIGN.md", 32768, "K46 ile donduruldu; tavan yine de olculur"),
    ("BORCLAR.md", 24576, "K83 -- DURUM.md 8'den ayrildi, acilista OKUNMAZ. Tavan "
     "DURUM.md'nin YARISI idi (16384) ve bu bilincliydi: listenin buyumesi borcun "
     "kapanmadigi sinyalidir. OTURUM 49'DA 24576'YA YUKSELTILDI (Onur) -- OLCULMUS "
     "GEREKCE: (1) oturum 48 budamayi OLCTU, 2 kalem kapandi 2 yeni dogdu, net +258 b "
     "=> budama bu dosyada ISE YARAMIYOR; (2) dosyada bolum basligi ('## ') YOK ve "
     "yalniz 4 satir kapanma isareti tasiyor => arsivlenecek olu kutle de YOK; "
     "(3) pay 212 b'ye dustugu icin kapi artik borcun KAPANMASINA degil "
     "KAYDEDILMESINE baski yapiyordu -- oturum 49 dort YENI olculmus borc uretti ve "
     "hicbiri yazilamadi. Gorunur borcu gorunmez yapan bir esik, uzun listeden KOTUDUR. "
     "BEYAN EDILMIS BEDEL: bu bir GEVSETMEDIR; karsiliginda K40'in 'esik degistiren "
     "altin kumeye vaka ekler' sarti bu turda MEKANIKLESTI (vaka 10)."),
    ("KAPILAR.md", 16384, "K89 -- kapi-tetik tablosu; DURUM.md 2'den ayrildi (Onur, sik B), "
     "acilista OKUNMAZ. Tavan ORTAM.md ile ayni (16 KB; BORCLAR.md oturum 49'da 24 KB'ye cikti, bu tablo CIKMADI): bu tablo buyurse kapi sayisi "
     "degil ANLATIM buyumus demektir. OLU BEYAN KAPANDI [oturum 49] -- eskiden burada su yaziyordu: bu eklemeyi altin kume "
     "KANITLAMAZ (kume VARSAYILAN_KAPSAM'a dokunmuyor, kayitli borc); kapsamin "
     "isirdigi oturum 42'de dosya yokken T0 ile el ile olculmustu. VAKA 10 ARTIK KAPSAM TABLOSUNDAKI HER TAVANI PINLIYOR => K89'dan beri tasinan o borc KAPANDI"),
    ("ORTAM.md", 16384, "Oturum 49 -- DURUM.md 7'den ayrildi (Onur kilitledi). BORCLAR/KAPILAR'dan "
     "FARKI: bu dosya ACILISTA OKUNUR (DURUM.md 2 adim 1), cunku basvuru degil OPERASYONEL bir "
     "mayin listesidir. Tavan KAPILAR.md ile ayni (16 KB) -- BORCLAR.md ile DEGIL, o oturum 49'da 24 KB oldu -- ve bu bilinclidir: bu liste buyurse mayin "
     "sayisi degil ANLATIM buyumus demektir -- mekaniklesen madde SILINIR (K73). Kapsam eklemesi "
     "kor kalmasin diye T1 mutantiyla olculdu (M138): 17000 b'lik ORTAM.md ile kapi KIRMIZI verdi"),
]
# Pay esigi: tavanin %5'inden az pay kaldiysa SARI. Olculmus gerekce: oturum 34'te
# pay 38 bayta dustu ve bir SONRAKI her ekleme tavani asti -- yani dar pay,
# asimin ta kendisinin habercisidir.
PAY_ORANI = 0.05


def olc(kok, kapsam):
    """SAF OLCUM -- yorum yok, yalniz bayt."""
    olcumler = []
    for yol, tavan, gerekce in kapsam:
        tam = os.path.join(kok, yol)
        var = os.path.isfile(tam)
        olcumler.append({
            "yol": yol,
            "tavan": tavan,
            "gerekce": gerekce,
            "var_mi": var,
            "bayt": os.path.getsize(tam) if var else 0,
        })
    return olcumler


def denetle(olcumler, pay_orani=PAY_ORANI):
    """SAF FONKSIYON -- diske DOKUNMAZ. Kapinin kendini kanitlayabilmesi bu ayrimdir."""
    bulgular = []
    for m in olcumler:
        yol, tavan, bayt = m["yol"], m["tavan"], m["bayt"]
        if not m.get("var_mi", True):
            bulgular.append(("SARI", "T0", yol, "DOSYA YOK -- kapsamda ama diskte degil."))
            continue
        pay = tavan - bayt
        if pay < 0:
            bulgular.append(("KIRMIZI", "T1", yol,
                             "TAVAN ASILDI: %d b / %d b (asim %d b). Tavan bir HEDEF degil "
                             "SINIRDIR; asan el budar ya da Onur'dan yeni esik alir (K40)."
                             % (bayt, tavan, -pay)))
        elif pay < tavan * pay_orani:
            bulgular.append(("SARI", "T2", yol,
                             "PAY DAR: %d b / %d b -- yalniz %d b kaldi (esik %d b). Bir sonraki "
                             "checkpoint tavani ASAR. Simdi budanmazsa yazim ani KIRMIZI olur."
                             % (bayt, tavan, pay, int(tavan * pay_orani))))
    if any(s == "KIRMIZI" for s, _, _, _ in bulgular):
        return bulgular, "KIRMIZI"
    if bulgular:
        return bulgular, "SARI"
    return bulgular, "YESIL"


def bolum_dagilimi(kok, yol):
    """Hangi bolum sisiriyor -- SOYLER, karar VERMEZ."""
    tam = os.path.join(kok, yol)
    if not os.path.isfile(tam):
        return []
    m = io.open(tam, encoding="utf-8").read()
    bas = [(x.start(), x.group(0).strip()) for x in re.finditer(r"^## .*$", m, re.M)]
    toplam = len(m.encode("utf-8")) or 1
    sonuc = []
    for i, (p, ad) in enumerate(bas):
        son = bas[i + 1][0] if i + 1 < len(bas) else len(m)
        n = len(m[p:son].encode("utf-8"))
        sonuc.append((n, 100.0 * n / toplam, ad[:58]))
    return sorted(sonuc, reverse=True)


def _o(**kw):
    t = {"yol": "X.md", "tavan": 1000, "gerekce": "test", "var_mi": True, "bayt": 500}
    t.update(kw)
    return t


def altin_kume():
    print("=" * 78)
    print("ALTIN KUME -- ARACIN KENDI KANITI (kor kapi yok)")
    print("=" * 78)
    gecti = kaldi = 0

    def kp(ad, olcumler, bekle_var=(), bekle_yok=(), bekle_hukum=None):
        nonlocal gecti, kaldi
        b, h = denetle(olcumler)
        kodlar = {k for _, k, _, _ in b}
        ok = all(x in kodlar for x in bekle_var) and not any(x in kodlar for x in bekle_yok)
        if bekle_hukum:
            ok = ok and h == bekle_hukum
        print("\n[%s] %s" % ("GECTI" if ok else "KALDI", ad))
        print("    beklenen kod: %s · olmamali: %s · olculen: %s · hukum: %s"
              % (list(bekle_var), list(bekle_yok), sorted(kodlar), h))
        gecti, kaldi = (gecti + 1, kaldi) if ok else (gecti, kaldi + 1)

    kp("1) TAVANIN COK ALTINDA -- yanlis-pozitif kontrolu, SUSMALI",
       [_o(bayt=500)], (), ("T1", "T2"), bekle_hukum="YESIL")
    kp("2) TAVAN ASILDI -- T1 isirmali",
       [_o(bayt=1200)], ("T1",), (), bekle_hukum="KIRMIZI")
    kp("3) TAM TAVANDA -- asim YOK ama pay 0 => T2 (T1 DEGIL)",
       [_o(bayt=1000)], ("T2",), ("T1",), bekle_hukum="SARI")
    kp("4) PAY DAR (%2) -- T2 isirmali",
       [_o(bayt=980)], ("T2",), ("T1",), bekle_hukum="SARI")
    kp("5) PAY ESIGININ TAM USTUNDE (%6) -- SUSMALI (esik uydurulmadiginin kaniti)",
       [_o(bayt=940)], (), ("T1", "T2"), bekle_hukum="YESIL")
    kp("6) BIR BAYT ASIM -- T1 isirmali (sinir davranisi)",
       [_o(bayt=1001)], ("T1",), (), bekle_hukum="KIRMIZI")
    kp("7) DOSYA YOK -- T0, ama KIRMIZI DEGIL (olcemedigini kirmizi sayma)",
       [_o(var_mi=False, bayt=0)], ("T0",), ("T1",), bekle_hukum="SARI")
    kp("8) IKI DOSYA, BIRI ASMIS -- hukum KIRMIZI, digeri sessiz",
       [_o(yol="A.md", bayt=100), _o(yol="B.md", bayt=1500)], ("T1",), (),
       bekle_hukum="KIRMIZI")
    kp("9) SIFIR BAYT -- pay tavana esit, SUSMALI (bu kapinin isi DEGIL; S1 tek-kopya'nin)",
       [_o(bayt=0)], (), ("T1", "T2"), bekle_hukum="YESIL")

    # --- 10) K40 MEKANIKLESTI [oturum 49] ------------------------------------
    # K40: "Esik degistiren, ALTIN KUMEYE YENI VAKA EKLEMEK ZORUNDADIR -- esigi
    # gevsetip altin kumeyi guncellememek olcum aracini kasten korlestirmektir."
    # Bu vaka o sarti PROZADAN KAPIYA tasir: kapsam tablosundaki HER tavan burada
    # PINLIDIR. Bir esigi degistiren el bu satiri da degistirmek ZORUNDADIR, yoksa
    # aracin kendi altin kumesi KIRMIZI verir ve degisiklik sessizce gecemez.
    # AYRICA: K89'dan beri yazili olan "altin kume VARSAYILAN_KAPSAM'a dokunmuyor,
    # kayitli borc" beyani BU VAKAYLA KAPANIR.
    BEKLENEN_KAPSAM = {
        "DURUM.md": 32768,
        "CLAUDE.md": 32768,
        "DESIGN.md": 32768,
        "BORCLAR.md": 24576,   # oturum 49'da 16384'ten yukseltildi (Onur)
        "KAPILAR.md": 16384,
        "ORTAM.md": 16384,     # oturum 49'da dogdu
    }
    olculen = {y: tv for y, tv, _ in VARSAYILAN_KAPSAM}
    ok10 = (olculen == BEKLENEN_KAPSAM)
    print("\n[%s] 10) KAPSAM TAVANLARI PINLI -- K40'in mekanik hali" % ("GECTI" if ok10 else "KALDI"))
    print("    beklenen: %s" % sorted(BEKLENEN_KAPSAM.items()))
    print("    olculen : %s" % sorted(olculen.items()))
    if not ok10:
        eksik = set(BEKLENEN_KAPSAM.items()) - set(olculen.items())
        fazla = set(olculen.items()) - set(BEKLENEN_KAPSAM.items())
        print("    SAPMA -> beklenip bulunmayan: %s | bulunup beklenmeyen: %s"
              % (sorted(eksik), sorted(fazla)))
        print("    K40: esigi degistiren el BU VAKAYI da guncellemek ZORUNDADIR.")
    gecti, kaldi = (gecti + 1, kaldi) if ok10 else (gecti, kaldi + 1)

    # --- 11) YENI TAVANIN SINIR DAVRANISI (gercek kapsam degeriyle) -----------
    _borclar_tavan = olculen.get("BORCLAR.md", 0)
    kp("11) BORCLAR.md YENI TAVANINDA bir bayt asim -- T1 isirmali",
       [_o(yol="BORCLAR.md", tavan=_borclar_tavan, bayt=_borclar_tavan + 1)],
       ("T1",), (), bekle_hukum="KIRMIZI")
    kp("12) BORCLAR.md yeni tavanin cok altinda (eski tavanin ustunde) -- SUSMALI",
       [_o(yol="BORCLAR.md", tavan=_borclar_tavan, bayt=17000)],
       (), ("T1", "T2"), bekle_hukum="YESIL")

    print("\n" + "=" * 78)
    print("HUKUM: %d/%d GECTI -- %s" % (gecti, gecti + kaldi,
          "KAPI KULLANILABILIR" if kaldi == 0 else "KAPI KULLANILAMAZ"))
    print("=" * 78)
    return 0 if kaldi == 0 else 1


def main():
    for akis in (sys.stdout, sys.stderr):
        try:
            akis.reconfigure(encoding="utf-8", errors="replace")
        except Exception:
            pass
    ap = argparse.ArgumentParser(description="Canli belge bayt tavani kapisi")
    ap.add_argument("kok", nargs="?")
    ap.add_argument("--altin-kume", action="store_true")
    ap.add_argument("--bolum", action="store_true", help="hangi bolum sisiriyor")
    a = ap.parse_args()
    if a.altin_kume:
        return altin_kume()
    if not a.kok:
        ap.print_help()
        return 3

    olcumler = olc(a.kok, VARSAYILAN_KAPSAM)
    bulgular, hukum = denetle(olcumler)

    print("=" * 78)
    print("BELGE TAVAN KAPISI %s -- canli belge bayt tavani" % SURUM)
    print("=" * 78)
    for m in olcumler:
        if not m["var_mi"]:
            print("  %-12s  [DOSYA YOK]" % m["yol"])
            continue
        pay = m["tavan"] - m["bayt"]
        print("  %-12s %7d b / %d b   pay %+6d b   (%s)"
              % (m["yol"], m["bayt"], m["tavan"], pay, m["gerekce"]))
    print("-" * 78)
    if bulgular:
        for sev, kod, yol, mesaj in bulgular:
            print("  [%s] %s %s: %s" % (sev, kod, yol, mesaj))
    else:
        print("  bulgu yok -- her canli belge tavaninin altinda ve payi genis.")

    if a.bolum:
        for m in olcumler:
            if not m["var_mi"]:
                continue
            d = bolum_dagilimi(a.kok, m["yol"])
            if not d:
                continue
            print("-" * 78)
            print("  %s -- BOLUM DAGILIMI (SOYLER, karar VERMEZ):" % m["yol"])
            for n, oran, ad in d[:6]:
                print("      %6d b  %5.1f%%  %s" % (n, oran, ad))

    print("-" * 78)
    print("  BEYAN EDILMIS SINIR: bu kapi icerigin GEREKLI olup olmadigini olcmez ve")
    print("  neyin silinecegine KARAR VERMEZ. Tavani da KENDI DEGISTIRMEZ -- esik")
    print("  degisikligi K40 geregi ONUR'dan gelir.")
    print("=" * 78)
    print("HUKUM: %s" % hukum)
    print("=" * 78)
    return 1 if hukum == "KIRMIZI" else 0


if __name__ == "__main__":
    sys.exit(main())

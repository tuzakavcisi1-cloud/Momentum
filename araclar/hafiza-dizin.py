#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
HAFIZA DIZINI — 520 KB'lik append-only arsivi GEZILEBILIR kilar.
=================================================================
Neden var (OLCULMUS, K58 / oturum 31):
  PROJE_HAFIZA.md 520.376 bayt (~149k token), 54 checkpoint ve oturum basina ~10 KB
  buyuyor. Erisim yolu "bir kararin gerekcesini merak edersen ac" idi -- bu boyutta
  FIILEN IMKANSIZ. Dizin, hicbir seyi silmeden arsivi navigasyona acar.

APPEND-ONLY IHLALI DEGILDIR: dizin bir KAYIT degil, kayitlardan TURETILMIS veridir.
Her kosumda SIFIRDAN yeniden uretilir; elle duzenlenmez (duzenlenirse bir sonraki
kosum ezer -- ve bu KASITLIDIR: elle tutulan dizin BAYATLAR, turetilen bayatlamaz).

Kullanim:
    python araclar/hafiza-dizin.py --altin-kume     # arac ONCE kendini kanitlar
    python araclar/hafiza-dizin.py <kok> [--dosya PROJE_HAFIZA.md] [--kuru]
Cikis: 0 = yazildi/degisiklik yok · 1 = dogrulama basarisiz · 3 = kullanim hatasi

BEYAN EDILMIS SINIRLAR (ciktiya BASILIR):
  * Dizin yalnizca BASLIK satirlarini indeksler; govdedeki kararlari ARAMAZ.
    Tam metin aramasi bu aracin isi DEGILDIR (grep/ripgrep yeterlidir).
  * Satir numaralari dizin yazildiktan SONRAKI hale gore verilir (kendi boyunu hesaba
    katar); dosyaya elle satir eklenirse BAYATLAR -- yeniden kosulmalidir.
"""
import argparse
import io
import os
import re
import sys

SURUM = "1.0.0"
BAS = "<!-- DIZIN:BAS -- MEKANIK URETIM, ELLE DUZENLEME: python araclar/hafiza-dizin.py . -->"
SON = "<!-- DIZIN:SON -->"
# "## ⏭ CHECKPOINT (26 Tem 2026 — oturum 29: **K56 — ...**)" gibi basliklar
BASLIK = re.compile(r"^##\s+(?:\W\s*)?(CHECKPOINT|CHECKPOINT-EK|DEVIR|DEVİR)\b(.*)$", re.I)
OTURUM = re.compile(r"oturum\s*(\d+)", re.I)
KILIT = re.compile(r"\bK(\d{1,3})(?:-[a-z])?\b")


def _temizle(s):
    """Baslik kuyrugundan okunabilir bir konu cikarir."""
    s = s.strip()
    s = re.sub(r"^\(|\)$", "", s.strip())
    s = s.replace("**", "").replace("`", "")
    s = re.sub(r"\s+", " ", s)
    return s.strip(" :-—·")


def _temiz_govde(satirlar):
    """Mevcut dizin blogunu SOKER ve capadan sonraki bos satirlari TEK'e indirger.
    Bu normalizasyon FIKIRLILIK (idempotence) icin sarttir: altin kume vaka 5, bu
    normalizasyon olmadan aracin her kosumda dosyaya IKI BOS SATIR eklediğini --
    yani 520 KB'lik arsivi her koşumda sisirdiğini -- OLCEREK yakaladi."""
    govde, icinde = [], False
    for s in satirlar:
        if s.startswith(BAS[:18]):
            icinde = True
            continue
        if icinde:
            if s.strip() == SON:
                icinde = False
            continue
        govde.append(s)
    capa = None
    for i, s in enumerate(govde):
        if "BU DOSYA ARTIK OTURUM" in s:
            capa = i
            break
    if capa is None:
        return govde, None
    j = capa + 1
    while j < len(govde) and govde[j].strip() == "":
        j += 1
    return govde[:capa + 1] + [""] + govde[j:], capa


def dizin_uret(satirlar):
    """(dizin_satirlari, kayit_sayisi) dondurur. Satir no'lari NIHAI dosyaya goredir."""
    govde, capa_ = _temiz_govde(satirlar)
    # 2. gecis: basliklari bul (govde uzerinde, gecici numaralarla)
    ham = []
    for i, s in enumerate(govde):
        m = BASLIK.match(s)
        if not m:
            continue
        kuyruk = _temizle(m.group(2))
        o = OTURUM.search(kuyruk)
        kilitler = sorted({"K" + k for k in KILIT.findall(kuyruk)},
                          key=lambda x: int(x[1:]), reverse=True)
        ham.append({"gecici": i, "tur": m.group(1).upper(),
                    "oturum": o.group(1) if o else "-",
                    "kilit": " ".join(kilitler[:3]) or "-",
                    "konu": kuyruk})
    # 3. gecis: dizin blogunun KENDI boyunu hesaba kat (satir no'lari kaymasin)
    basliklar = [BAS,
                 "### DIZIN — %d kayit (mekanik uretim, surum %s)" % (len(ham), SURUM),
                 "",
                 "| satir | tur | oturum | kilit | konu |",
                 "|---|---|---|---|---|"]
    kuyruklar = ["",
                 "> Bu blok `python araclar/hafiza-dizin.py .` ile URETILIR; elle duzenleme"
                 " bir sonraki kosumda EZILIR. Yeni checkpoint bu satirin ALTINA eklenir.",
                 SON, ""]
    kayma = len(basliklar) + len(ham) + len(kuyruklar)
    # capa YOKSA dizin en basa girer (vaka 7)
    ekleme_yeri = (capa_ + 2) if capa_ is not None else 0
    satirlar_dizin = list(basliklar)
    for k in ham:
        gercek = k["gecici"] + 1 + (kayma if k["gecici"] >= ekleme_yeri else 0)
        satirlar_dizin.append("| %d | %s | %s | %s | %s |"
                              % (gercek, k["tur"], k["oturum"], k["kilit"],
                                 k["konu"][:110]))
    satirlar_dizin += kuyruklar
    yeni = govde[:ekleme_yeri] + satirlar_dizin + govde[ekleme_yeri:]
    return yeni, len(ham)


def dogrula(yeni, beklenen):
    """Uretilen dosyayi KENDI uzerinde dogrular: her dizin satiri gercek bir baslik
    satirini gostermeli. Kor kapi yok -- arac kendi ciktisini olcer."""
    hatalar = []
    icinde, sayac = False, 0
    for s in yeni:
        if s.startswith(BAS[:18]):
            icinde = True
            continue
        if icinde and s.strip() == SON:
            icinde = False
            continue
        if not icinde or not s.startswith("| ") or s.startswith("|---") \
                or s.startswith("| satir"):
            continue
        try:
            no = int(s.split("|")[1].strip())
        except ValueError:
            continue
        sayac += 1
        if no < 1 or no > len(yeni):
            hatalar.append("satir no %d dosya disinda" % no)
        elif not BASLIK.match(yeni[no - 1]):
            hatalar.append("satir %d bir CHECKPOINT basligi DEGIL: %r"
                           % (no, yeni[no - 1][:70]))
    if sayac != beklenen:
        hatalar.append("dizinde %d satir var, %d baslik bekleniyordu" % (sayac, beklenen))
    return hatalar


def altin_kume():
    print("=" * 78)
    print("ALTIN KUME -- ARACIN KENDI KANITI (kor kapi yok)")
    print("=" * 78)
    gecti = kaldi = 0

    def kontrol(ad, satirlar, bekle_kayit, bekle_hata=0):
        nonlocal gecti, kaldi
        yeni, n = dizin_uret(satirlar)
        h = dogrula(yeni, n)
        ok = (n == bekle_kayit and len(h) == bekle_hata)
        print("\n[%s] %s" % ("GECTI" if ok else "KALDI", ad))
        print("    kayit: %d (beklenen %d) · dogrulama hatasi: %d (beklenen %d)"
              % (n, bekle_kayit, len(h), bekle_hata))
        if h:
            print("    hatalar: %s" % h[:3])
        gecti, kaldi = (gecti + 1, kaldi) if ok else (gecti, kaldi + 1)
        return yeni

    capa = "> BU DOSYA ARTIK OTURUM ACILISINDA OKUNMAZ"
    kontrol("1) BOS ARSIV -- dizin bos, cokme yok", ["# Baslik", capa], 0)
    a = ["# Baslik", capa, "", "## CHECKPOINT (26 Tem 2026 - oturum 29: K56 tasima)", "govde"]
    kontrol("2) TEK KAYIT -- satir no GERCEK basligi gostermeli", a, 1)
    b = ["# Baslik", capa, "",
         "## ⏭ CHECKPOINT (26 Tem - oturum 30: **K57 kilit**)", "x", "y",
         "## ⏭ CHECKPOINT-EK (27 Tem - oturum 31: **K58 tavan**)", "z"]
    ikinci = kontrol("3) IKI KAYIT + EK -- ikisi de dogru satiri gostermeli", b, 2)
    kontrol("4) FIKIRLI (idempotent) -- ikinci kosum ayni sonucu vermeli", ikinci, 2)
    ucuncu = dizin_uret(ikinci)[0]
    ok = (ucuncu == ikinci)
    print("\n[%s] 5) UCUNCU KOSUM da AYNI olmali (dizin kendini SISIRMEZ)"
          % ("GECTI" if ok else "KALDI"))
    print("    ikinci kosum ile ucuncu kosum ayni mi: %s" % ok)
    gecti, kaldi = (gecti + 1, kaldi) if ok else (gecti, kaldi + 1)
    c = ["# Baslik", capa, "", "## CHECKPOINT (oturum 7: K12, K9 iki kilit)", "g"]
    kontrol("6) KILIT NUMARALARI cikarilmali (K12, K9)", c, 1)
    d = ["# Baslik", "## CHECKPOINT (oturum 1: capa YOK)", "g"]
    kontrol("7) CAPA SATIRI YOKSA -- cokme yok, dizin yine dogru", d, 1)

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
    ap = argparse.ArgumentParser(description="Hafiza arsivi dizini")
    ap.add_argument("kok", nargs="?")
    ap.add_argument("--dosya", default="PROJE_HAFIZA.md")
    ap.add_argument("--altin-kume", action="store_true")
    ap.add_argument("--kuru", action="store_true", help="yazma, yalniz raporla")
    a = ap.parse_args()
    if a.altin_kume:
        return altin_kume()
    if not a.kok:
        ap.print_help()
        return 3
    yol = os.path.join(a.kok, a.dosya)
    if not os.path.isfile(yol):
        print("[DUR] dosya yok: %s" % yol)
        return 3
    eski = io.open(yol, encoding="utf-8").read()
    yeni, n = dizin_uret(eski.split("\n"))
    hatalar = dogrula(yeni, n)
    print("=" * 78)
    print("HAFIZA DIZINI v%s — %s" % (SURUM, yol))
    print("  indekslenen checkpoint: %d · dosya: %d bayt" % (n, len(eski.encode("utf-8"))))
    if hatalar:
        print("  DOGRULAMA BASARISIZ (dosya YAZILMADI):")
        for h in hatalar[:10]:
            print("    - " + h)
        print("=" * 78)
        return 1
    metin = "\n".join(yeni)
    if metin == eski:
        print("  DEGISIKLIK YOK -- dizin zaten guncel.")
    elif a.kuru:
        print("  [KURU KOSUM] dizin guncellenecekti, yazilmadi.")
    else:
        io.open(yol, "w", encoding="utf-8", newline="\n").write(metin)
        print("  DIZIN YAZILDI -- yeni boyut: %d bayt" % os.path.getsize(yol))
    print("  BEYAN EDILMIS SINIR: yalniz BASLIKLAR indekslenir; govde metni ARANMAZ")
    print("  (tam metin icin grep/ripgrep). Satir no'lari dosyaya ELLE satir eklenirse")
    print("  bayatlar -- araci yeniden kos.")
    print("=" * 78)
    return 0


if __name__ == "__main__":
    sys.exit(main())

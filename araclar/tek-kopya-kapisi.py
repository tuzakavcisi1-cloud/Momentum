#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""tek-kopya-kapisi.py 1.0.0 -- TEK KOPYA DOSYA REGRESYON KAPISI (K60)

NEDEN VAR (ucuz bir kural degil, olculmus bir hasar):
Oturum 31'de Cowork'un kendi betigi io.open(yol,"w") ile PROJE_HAFIZA.md'yi ONCE
BOSALTTI, sonra encode hatasi aldi: 542.475 baytlik arsiv 0 BAYTA dustu. Kurtaran
sey bir kural degil, SANSTI (dosya 30 dk once commit'lenmisti). O gun konulan K60
kurali "atomik yaz" diyordu -- ama KURAL, KOSULMASI GEREKMEYEN bir seydir; unutan
el icin yoktur. Bu kapi kuralin UYGULANIP UYGULANMADIGINI degil, DOSYANIN HALINI
olcer: hangi el, hangi yontem, hangi betik oldugu UMURUNDA DEGILDIR.

BEYAN EDILEN SINIR -- BU KAPI HASARI ONLEMEZ, SESSIZ KALMASINI IMKANSIZ KILAR.
Yazim aninda araya girmez; acilis protokolunde ve yazim sonrasi kosar. Asil olduren
sey hasar degil, FARK EDILMEYEN hasardir; bu kapi tam olarak onu hedefler.

SINIFLAR (davranis sinifa gore DEGISIR, tek esik yoktur):
  append_only : tanim geregi KUCULMEZ  -> tek bayt kucukse KIRMIZI
  kilitli     : bir kilidin sozlesmesi -> HEAD'deki sha'dan sapma KIRMIZI
  canli       : mesru budama olabilir  -> 0 bayt veya esikten (%10) fazla kucukme KIRMIZI

KODLAR: S0 dosya yok · S1 sifir bayt · S2 kuculme · S3 bozuk UTF-8 · S4 yarim
kalmis .tmp · S5 HEAD'de yok (ag yok) · S6 kilit sapmasi · S7 gerekcesiz muafiyet
· S8 muafiyet uygulandi · S9 olu muafiyet.

Muafiyet `araclar/tek-kopya-muafiyet.json`'dadir ve GEREKCESIZ OLAMAZ (S7). Bir
muafiyet artik hicbir sapmayi ortmuyorsa OLUDUR ve soylenir (S9) -- olu tuzak,
bu projede adi konmus bir kusur sinifidir.

CIKIS: 0 temiz/sari · 1 KIRMIZI · 2 kullanim hatasi.
"""
import hashlib
import io
import json
import os
import subprocess
import sys

SURUM = "1.1.0"
ESIK = 0.10  # canli sinifta mesru sayilan azami kuculme

VARSAYILAN_KAPSAM = [
    ("PROJE_HAFIZA.md", "append_only"),
    ("PROJE_RADAR.jsonl", "append_only"),
    ("DURUM.md", "canli"),
    ("CLAUDE.md", "canli"),
    ("DESIGN.md", "kilitli"),
    ("GOREV_CLAUDE_CODE/GOREV-slice-3b-istemci-iskeleti.md", "kilitli"),
    ("GOREV_CLAUDE_CODE/GOREV-slice-3c-senkron.md", "kilitli"),  # K64 -- v2 onaylandi
    ("araclar/radar.py", "kilitli"),
    ("araclar/adr-kapi-taramasi.py", "kilitli"),
]


# --------------------------------------------------------------- saf cekirdek
def denetle(olcumler, esik=ESIK, muafiyetler=None):
    """SAF FONKSIYON -- diske ve git'e DOKUNMAZ, sadece olcum sozluklerini yorumlar.
    Kapinin kendini kanitlayabilmesi (altin kume) bu ayrimin ta kendisidir.

    olcum: {yol, sinif, var_mi, bayt, sha8, head_var_mi, head_bayt, head_sha8,
            utf8_gecerli, tmp_var}
    doner: (bulgular, hukum)  bulgu = (seviye, kod, yol, mesaj)
    """
    muafiyetler = muafiyetler or []
    bulgular = []
    kullanilan = set()

    for m in olcumler:
        yol = m.get("yol", "?")
        sinif = m.get("sinif", "canli")
        muaf = None
        for i, x in enumerate(muafiyetler):
            if x.get("yol") == yol:
                muaf = (i, x)
                break
        if muaf and not (str(muaf[1].get("gerekce", "")).strip()
                         and str(muaf[1].get("borc", "")).strip()):
            bulgular.append(("KIRMIZI", "S7", yol,
                             "MUAFIYET GEREKCESIZ: her muafiyet borc + gerekce tasimak "
                             "ZORUNDADIR. Gerekcesiz muafiyet, kapiyi kor etmenin kibar adidir."))
            muaf = None

        if not m.get("var_mi", True):
            bulgular.append(("KIRMIZI", "S0", yol,
                             "IZLENEN DOSYA DISKTE YOK. Silinmis ya da tasinmis olabilir; "
                             "ikisi de sessiz gecilemez."))
            continue

        if not m.get("utf8_gecerli", True):
            bulgular.append(("KIRMIZI", "S3", yol,
                             "BOZUK UTF-8: dosya gecerli metin degil. Yarim kalmis bir "
                             "yazimin en tipik izi budur."))

        if m.get("tmp_var"):
            bulgular.append(("SARI", "S4", yol,
                             "YARIM KALMIS .tmp ARTIGI: atomik yazim tamamlanmamis. "
                             "Dosyanin kendisi saglam olsa bile bir betik yolda olmus."))

        bayt = int(m.get("bayt") or 0)
        if bayt == 0:
            bulgular.append(("KIRMIZI", "S1", yol,
                             "DOSYA SIFIR BAYT. K60'in tam olarak onlemek icin var oldugu hal."))
            continue

        if not m.get("head_var_mi", False):
            bulgular.append(("SARI", "S5", yol,
                             "HEAD'DE YOK: bu dosya henuz commit'lenmemis, yani ARKASINDA AG "
                             "YOK. Kaybolursa geri getirilemez -- commit et."))
            continue

        # SATIR SONU NORMALIZASYONU (S10) -- mutant M2 ile olculdu:
        # core.autocrlf acikken calisma kopyasi ile HEAD blob'u AYNI icerikte bile
        # farkli bayttadir. Ham bayt karsilastirmasi bu ortamda KOR KAPIDIR.
        if m.get("satirsonu_farki"):
            bulgular.append(("BILGI", "S10", yol,
                             "SATIR SONU FARKI: ham bayt %d, HEAD blob %d -- icerik LF'e "
                             "normalize edilince ayni. Karsilastirma NORMALIZE edilmis deger "
                             "uzerinden yapildi; ham bayt bu ortamda olcu DEGILDIR."
                             % (int(m.get("bayt") or 0), int(m.get("head_bayt") or 0))))
        bayt = int(m.get("bayt_n") or m.get("bayt") or 0)
        hb = int(m.get("head_bayt_n") or m.get("head_bayt") or 0)
        sha_c = m.get("sha8_n") or m.get("sha8")
        head_sha_c = m.get("head_sha8_n") or m.get("head_sha8")
        sapma_var = False
        if sinif == "kilitli":
            if sha_c != head_sha_c:
                sapma_var = True
                if muaf:
                    kullanilan.add(muaf[0])
                    bulgular.append(("BILGI", "S8", yol,
                                     "MUAFIYET UYGULANDI [%s]: %s"
                                     % (muaf[1].get("borc"), muaf[1].get("gerekce"))))
                else:
                    bulgular.append(("KIRMIZI", "S6", yol,
                                     "KILIT SAPMASI: calisma agacindaki sha (%s) HEAD'deki "
                                     "sha'dan (%s) FARKLI [LF-normalize karsilastirma]. Bu dosya "
                                     "bir sozlesmedir; degistiyse ya kilit bilerek yenilendi "
                                     "(K numarasiyla ILAN EDILMELI) ya da kimse fark etmeden bozuldu."
                                     % (sha_c, head_sha_c)))
        else:
            kucukme = (hb - bayt) / float(hb) if hb else 0.0
            kirmizi_mi = (kucukme > 0) if sinif == "append_only" else (kucukme > esik)
            if kirmizi_mi:
                sapma_var = True
                if muaf:
                    kullanilan.add(muaf[0])
                    bulgular.append(("BILGI", "S8", yol,
                                     "MUAFIYET UYGULANDI [%s]: %s"
                                     % (muaf[1].get("borc"), muaf[1].get("gerekce"))))
                else:
                    bulgular.append(("KIRMIZI", "S2", yol,
                                     "KUCULME: %d -> %d bayt (%%%.1f). Sinif '%s' icin bu "
                                     "kabul edilemez%s."
                                     % (hb, bayt, kucukme * 100, sinif,
                                        " (append-only dosya KUCULMEZ)" if sinif == "append_only"
                                        else " (esik %%%d)" % int(esik * 100))))
        if muaf and not sapma_var:
            kullanilan.add(muaf[0])
            bulgular.append(("SARI", "S9", yol,
                             "OLU MUAFIYET [%s]: bu muafiyet artik HICBIR sapmayi ortmuyor. "
                             "Olu tuzak, bu projede adi konmus bir kusur sinifidir -- SIL."
                             % muaf[1].get("borc")))

    for i, x in enumerate(muafiyetler):
        if i not in kullanilan and str(x.get("gerekce", "")).strip():
            if not any(m.get("yol") == x.get("yol") for m in olcumler):
                bulgular.append(("SARI", "S9", x.get("yol", "?"),
                                 "OLU MUAFIYET [%s]: muafiyetin isaret ettigi dosya kapsamda "
                                 "bile degil." % x.get("borc")))

    seviyeler = {s for s, _, _, _ in bulgular}
    hukum = "KIRMIZI" if "KIRMIZI" in seviyeler else ("SARI" if "SARI" in seviyeler else "YESIL")
    return bulgular, hukum


# --------------------------------------------------------------- gercek olcum
def _lf(ham):
    """CRLF/CR -> LF. Kapinin git'in satir sonu cevrimine KOR OLMAMASI icin sart."""
    return ham.replace(b"\r\n", b"\n").replace(b"\r", b"\n")


def _git(kok, *arg):
    p = subprocess.run(["git", "--no-optional-locks"] + list(arg), cwd=kok,
                       capture_output=True)
    return p.returncode, p.stdout


def olc(kok, kapsam):
    """Diskten + git'ten GERCEK olcum toplar. Yorum YAPMAZ; yorumu denetle() yapar."""
    olcumler = []
    for yol, sinif in kapsam:
        tam = os.path.join(kok, yol.replace("/", os.sep))
        m = {"yol": yol, "sinif": sinif, "var_mi": os.path.isfile(tam),
             "bayt": 0, "sha8": None, "head_var_mi": False, "head_bayt": 0,
             "head_sha8": None, "utf8_gecerli": True,
             "tmp_var": os.path.exists(tam + ".tmp")}
        if m["var_mi"]:
            ham = io.open(tam, "rb").read()
            m["bayt"] = len(ham)
            m["sha8"] = hashlib.sha256(ham).hexdigest()[:8].upper()
            n = _lf(ham)
            m["bayt_n"] = len(n)
            m["sha8_n"] = hashlib.sha256(n).hexdigest()[:8].upper()
            try:
                ham.decode("utf-8")
            except UnicodeDecodeError:
                m["utf8_gecerli"] = False
        rc, out = _git(kok, "cat-file", "-s", "HEAD:" + yol)
        if rc == 0:
            m["head_var_mi"] = True
            m["head_bayt"] = int(out.decode("ascii", "replace").strip() or 0)
            rc2, ham2 = _git(kok, "show", "HEAD:" + yol)
            if rc2 == 0:
                m["head_sha8"] = hashlib.sha256(ham2).hexdigest()[:8].upper()
                n2 = _lf(ham2)
                m["head_bayt_n"] = len(n2)
                m["head_sha8_n"] = hashlib.sha256(n2).hexdigest()[:8].upper()
                m["satirsonu_farki"] = (m["sha8"] != m["head_sha8"]
                                        and m.get("sha8_n") == m["head_sha8_n"])
        olcumler.append(m)
    return olcumler


def muafiyet_oku(kok):
    y = os.path.join(kok, "araclar", "tek-kopya-muafiyet.json")
    if not os.path.isfile(y):
        return []
    try:
        v = json.loads(io.open(y, encoding="utf-8").read())
        return v.get("muafiyetler", v) if isinstance(v, dict) else v
    except Exception as e:
        print("[UYARI] muafiyet dosyasi okunamadi: %s" % e)
        return []


def yaz(bulgular, hukum, olcumler):
    print("=" * 78)
    print("TEK KOPYA KAPISI %s -- dosya REGRESYON olcumu (K60)" % SURUM)
    print("=" * 78)
    for m in olcumler:
        d = "%-8s %-52s %8d b" % (m["sinif"], m["yol"], m["bayt"])
        if m["head_var_mi"]:
            fark = m["bayt"] - m["head_bayt"]
            d += "  (HEAD %d, %+d)" % (m["head_bayt"], fark)
        else:
            d += "  (HEAD: YOK)"
        print("  " + d)
    print("-" * 78)
    if not bulgular:
        print("  bulgu yok -- her tek kopya dosya HEAD'deki haliyle tutarli.")
    for s, k, y, msg in bulgular:
        print("  [%s] %s %s" % (s, k, y))
        print("      " + msg)
    print("=" * 78)
    print("HUKUM: %s" % hukum)
    if hukum == "KIRMIZI":
        print("DEVRE KESICI: once dosyayi kurtar (git restore <yol>), SONRA is yap.")
        print("Bu kapi hasari ONLEMEZ; sessiz kalmasini imkansiz kilar. Beyan edilmistir.")
    print("=" * 78)


# ------------------------------------------------------------- altin kume
def _o(**kw):
    t = {"yol": "X.md", "sinif": "canli", "var_mi": True, "bayt": 1000,
         "sha8": "AAAAAAAA", "head_var_mi": True, "head_bayt": 1000,
         "head_sha8": "AAAAAAAA", "utf8_gecerli": True, "tmp_var": False}
    t.update(kw)
    return t


def altin_kume():
    """Arac ONCE KENDINI kanitlar: temizde susar, kirlide isirir, KOR KAPI YOK."""
    print("=" * 78)
    print("ALTIN KUME -- TEK KOPYA KAPISININ KENDI KANITI")
    print("=" * 78)
    gecti = True

    def kp(ad, olcumler, bekle_var, bekle_yok, muaf=None, bekle_hukum=None):
        nonlocal gecti
        b, h = denetle(olcumler, muafiyetler=muaf)
        kodlar = {k for _, k, _, _ in b}
        ok = all(x in kodlar for x in bekle_var) and not any(x in kodlar for x in bekle_yok)
        if bekle_hukum:
            ok = ok and h == bekle_hukum
        gecti = gecti and ok
        print("[%s] %s" % ("GECTI" if ok else "KALDI", ad))
        if not ok:
            print("      beklenen var=%s yok=%s hukum=%s | gorulen kodlar=%s hukum=%s"
                  % (bekle_var, bekle_yok, bekle_hukum, sorted(kodlar), h))

    kp("1) TEMIZ: boyut HEAD ile ayni -- SUSMALI",
       [_o()], (), ("S0", "S1", "S2", "S3", "S4", "S5", "S6"), bekle_hukum="YESIL")
    kp("2) APPEND-ONLY 1 BAYT KUCULDU -- KIRMIZI (bu dosyalar kuculmez)",
       [_o(sinif="append_only", bayt=999)], ("S2",), (), bekle_hukum="KIRMIZI")
    kp("3) APPEND-ONLY BUYUDU -- normaldir, SUSMALI",
       [_o(sinif="append_only", bayt=1500)], (), ("S2",), bekle_hukum="YESIL")
    kp("4) SIFIR BAYT -- KIRMIZI (oturum 31'de gercekten olan hal)",
       [_o(bayt=0)], ("S1",), (), bekle_hukum="KIRMIZI")
    kp("5) CANLI SINIF %5 KUCULDU -- mesru budama, SUSMALI",
       [_o(bayt=950)], (), ("S2",), bekle_hukum="YESIL")
    kp("6) CANLI SINIF %15 KUCULDU -- KIRMIZI",
       [_o(bayt=850)], ("S2",), (), bekle_hukum="KIRMIZI")
    kp("7) BOZUK UTF-8 -- KIRMIZI (yarim yazimin tipik izi)",
       [_o(utf8_gecerli=False)], ("S3",), (), bekle_hukum="KIRMIZI")
    kp("8) YARIM KALMIS .tmp -- SARI, dosya saglam olsa bile",
       [_o(tmp_var=True)], ("S4",), ("S2",), bekle_hukum="SARI")
    kp("9) DOSYA DISKTE YOK -- KIRMIZI",
       [_o(var_mi=False)], ("S0",), (), bekle_hukum="KIRMIZI")
    kp("10) HEAD'DE YOK -- SARI (ag yok) ve KUCULME HUKMU VERILMEZ",
       [_o(head_var_mi=False, head_bayt=0, bayt=10)], ("S5",), ("S2", "S6"),
       bekle_hukum="SARI")
    kp("11) KILITLI, sha AYNI -- SUSMALI",
       [_o(sinif="kilitli")], (), ("S6",), bekle_hukum="YESIL")
    kp("12) KILITLI, sha FARKLI -- KIRMIZI (boyut ayni olsa bile)",
       [_o(sinif="kilitli", sha8="BBBBBBBB")], ("S6",), (), bekle_hukum="KIRMIZI")
    kp("13) KILITLI sapma + GEREKCELI muafiyet -- S8 BILGI, S6 YOK",
       [_o(sinif="kilitli", sha8="BBBBBBBB")], ("S8",), ("S6",),
       muaf=[{"yol": "X.md", "borc": "BD-9", "gerekce": "kilit K61 ile yenilendi"}],
       bekle_hukum="YESIL")
    kp("14) GEREKCESIZ MUAFIYET -- KIRMIZI ve muafiyet UYGULANMAZ",
       [_o(sinif="kilitli", sha8="BBBBBBBB")], ("S7", "S6"), (),
       muaf=[{"yol": "X.md", "borc": "BD-9"}], bekle_hukum="KIRMIZI")
    kp("15) OLU MUAFIYET (sapma yok ama muafiyet duruyor) -- SARI",
       [_o(sinif="kilitli")], ("S9",), ("S6",),
       muaf=[{"yol": "X.md", "borc": "BD-9", "gerekce": "artik gecersiz"}],
       bekle_hukum="SARI")
    kp("16) MUAFIYET KAPSAM DISI BIR DOSYAYI GOSTERIYOR -- SARI",
       [_o()], ("S9",), (),
       muaf=[{"yol": "YOK.md", "borc": "BD-9", "gerekce": "hayali dosya"}],
       bekle_hukum="SARI")

    kp("17) SATIR SONU FARKI, icerik AYNI -- S10 BILGI, S2/S6 YOK "
       "(mutant M2 ile olculdu)",
       [_o(sinif="append_only", bayt=2800, head_bayt=2400, bayt_n=2400, head_bayt_n=2400,
           sha8="CCCCCCCC", head_sha8="AAAAAAAA", sha8_n="AAAAAAAA", head_sha8_n="AAAAAAAA",
           satirsonu_farki=True)],
       ("S10",), ("S2", "S6"), bekle_hukum="YESIL")
    kp("18) SATIR SONU FARKI + GERCEK KUCULME -- S2 YINE ISIRMALI",
       [_o(sinif="append_only", bayt=2798, head_bayt=2400, bayt_n=2399, head_bayt_n=2400,
           sha8="CCCCCCCC", head_sha8="AAAAAAAA", sha8_n="DDDDDDDD", head_sha8_n="AAAAAAAA",
           satirsonu_farki=True)],
       ("S2",), (), bekle_hukum="KIRMIZI")
    kp("19) KILITLI dosyada satir sonu farki -- kilit BOZULMUS SAYILMAZ",
       [_o(sinif="kilitli", bayt=2800, head_bayt=2400, bayt_n=2400, head_bayt_n=2400,
           sha8="CCCCCCCC", head_sha8="AAAAAAAA", sha8_n="AAAAAAAA", head_sha8_n="AAAAAAAA",
           satirsonu_farki=True)],
       ("S10",), ("S6",), bekle_hukum="YESIL")

    print("=" * 78)
    print("ALTIN KUME: %s" % ("GECTI (19/19)" if gecti else "BASARISIZ"))
    print("=" * 78)
    return 0 if gecti else 1


def main(argv):
    if "--altin-kume" in argv:
        return altin_kume()
    kok = os.path.abspath(argv[1]) if len(argv) > 1 else "."
    if not os.path.isdir(os.path.join(kok, ".git")):
        print("[HATA] git deposu degil: %s" % kok)
        return 2
    olcumler = olc(kok, VARSAYILAN_KAPSAM)
    bulgular, hukum = denetle(olcumler, muafiyetler=muafiyet_oku(kok))
    yaz(bulgular, hukum, olcumler)
    return 1 if hukum == "KIRMIZI" else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

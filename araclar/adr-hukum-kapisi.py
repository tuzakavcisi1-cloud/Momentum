# -*- coding: utf-8 -*-
"""GOREV-ADR0004-KAPISI (K170'in mekanik kapısı) — `adr-hukum-kapisi.py` v1.

Beş kapı (G52-G56, 22 ayak) bir HEDEF BELGE üzerinde koşar ve o belgenin
tekrar eden üç kusur sınıfını (olcemedigini-sanmak / vaka-degil-sinif /
kanonik-kopya) + iki ek ayağı (kor-kapi kısmi + sınıf-adı sözlüğü) MEKANİK
olarak ölçer. `K26`: bu kapıyı YAZAN el (Claude Code) hükmü VERMEZ — altın
küme + 27 mutant + 5 negatif kontrolün KOŞUMU ve HÜKMÜ Cowork'ündür.

KULLANIM:
  python araclar/adr-hukum-kapisi.py <belge.md> [--kok .]
  python araclar/adr-hukum-kapisi.py --altin-kume

D-K170-2: kapı BELGE alır, DİZİN almaz — dizin verilirse [S0] BİÇİM, EXIT 4.

ÇIKIŞ KODU SÖZLEŞMESİ (bu betiğin kendi tasarımı, spec §5/§7'nin izin verdiği
alanda): 0=YEŞİL · 1=SARI · 2=KIRMIZI · 3=ORTAM HATASI · 4=[S0] BİÇİM.
Birden fazla sınıf oluşursa EN YÜKSEK kod döner (4>3>2>1>0).
"""
import difflib
import functools
import http.server
import io
import json
import os
import re
import socket
import sys
import threading
import time
from datetime import datetime
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

KOK_VARSAYILAN = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

EXIT_YESIL = 0
EXIT_SARI = 1
EXIT_KIRMIZI = 2
EXIT_ORTAM_HATASI = 3
EXIT_BICIM = 4
ETIKETLER = {
    EXIT_YESIL: "YESIL",
    EXIT_SARI: "SARI",
    EXIT_KIRMIZI: "KIRMIZI",
    EXIT_ORTAM_HATASI: "ORTAM HATASI",
    EXIT_BICIM: "[S0] BICIM",
}

# ============================ D-K170-9: TURKCE NORMALIZASYON =====================
# 🔴 KANONIK RECETE (spec D-K170-9, DORT yol OLCULDU, NFKD YANLIS cikti):
#    s.replace('İ','i').replace('I','ı').lower() -- NFKD KULLANILMAZ.


def normalize_tr(s):
    return s.replace("İ", "i").replace("I", "ı").lower()


# ============================ ORTAK YARDIMCILAR ==================================


def oku_metin(yol):
    with io.open(yol, "r", encoding="utf-8", errors="replace") as f:
        return f.read()


def _bicim_yolu_dosya_mi(yol):
    return os.path.isfile(yol)


def _dosya_coz(ad, kok):
    """`ad` (dosya adi, yol parcasi tasiyabilir) repoda TEK bir dosyaya mi
    cozuluyor? (path, coklu_mu) doner. path=None ise HIC bulunamadi."""
    ad_norm = ad.replace("\\", "/")
    taban_ad = os.path.basename(ad_norm)
    bulunanlar = []
    for dizin_kok, dizinler, dosyalar in os.walk(kok):
        dizinler[:] = [
            d for d in dizinler
            if d not in (".git", "node_modules", "build", ".dart_tool", "bin", "obj", "__pycache__")
        ]
        for dosya in dosyalar:
            if dosya == taban_ad:
                tam = os.path.join(dizin_kok, dosya)
                goreli = os.path.relpath(tam, kok).replace(os.sep, "/")
                # Eger `ad` bir yol parcasi tasiyorsa (ör. "src/x/Program.cs"),
                # cozulen yolun SONU o parcayla eslesmeli.
                if "/" in ad_norm and not goreli.endswith(ad_norm):
                    continue
                bulunanlar.append(tam)
    bulunanlar = sorted(set(bulunanlar))
    if not bulunanlar:
        return None, False
    if len(bulunanlar) > 1:
        return bulunanlar, True
    return bulunanlar[0], False


def _http_dene(url, yontem="GET", zaman_asimi=3):
    """(durum_kodu, hata) doner. durum_kodu None ise baglanti KURULAMADI."""
    try:
        req = Request(url, method=yontem)
        with urlopen(req, timeout=zaman_asimi) as resp:
            return resp.status, None
    except HTTPError as e:
        return e.code, None
    except URLError as e:
        return None, str(e.reason)
    except Exception as e:
        return None, str(e)


# ============================ G52 — OLCEMEDIGINI-SANMAK AYAGI ====================

TETIK_AILESI_G52 = re.compile(
    r"ölç(ül)?[eü]?med|çözüleme|koşulmad|yapılmad|\[doğrulanmadı\]"
)
URL_DESENI = re.compile(r"https?://[^\s\)\]\"'>]+")
YERTUTUCU_DESENI = re.compile(r"<engineRevision>", re.IGNORECASE)
# 🔴 GENEL TUTULDU (yalniz "gstatic.com" DEGIL): production'da gercek
# flutter_bootstrap.js "https://www.gstatic.com/flutter-canvaskit" tasir ve
# bu desen onu YAKALAR; test/altin-kume ise "dis aga cikilmaz" sarti geregi
# YEREL sunucuyu ("http://127.0.0.1:<port>/flutter-canvaskit") ayni desenle
# temsil eder -- ayni KOD YOLU, farkli host.
GSTATIC_HOST_DESENI = re.compile(r"https?://[^\s\"']+/flutter-canvaskit")
ENGINE_REVISION_DESENI = re.compile(r'engineRevision"\s*:\s*"([0-9a-fA-F]+)"')
REPO_YOL_DESENI = re.compile(r"[\w./\\-]+\.(?:py|cs|json|md|js|dart|ps1)\b")
TIRNAKLI_DESEN = re.compile(r"['\"]([^'\"]{1,120})['\"]")


def _g52_pozitif_kontrol(fixture_kok):
    """d) ayrı fixture'da bilinen bir tetik bulunmalı; bulunamazsa ORTAM HATASI."""
    yol = os.path.join(fixture_kok, "pozitif-kontrol.md")
    if not os.path.isfile(yol):
        return "pozitif-kontrol.md bulunamadi (G52/d)"
    metin = oku_metin(yol)
    satirlar = metin.splitlines()
    bulundu = any(TETIK_AILESI_G52.search(normalize_tr(s)) for s in satirlar)
    if not bulundu:
        return "pozitif-kontrol.md'de BILINEN tetik bulunamadi (G52/d)"
    return None


def _g52_hedef_ayikla(satir, kok):
    """Bir tetik satirindan hedef cikarir. Doner:
    ('a', url, yontem) | ('a2-cozuldu', url, 'GET') | ('a2-ortam-hatasi', mesaj) |
    ('b', dosya_yolu, desen) | ('c', None, None)"""
    if YERTUTUCU_DESENI.search(satir):
        fb_yol = os.path.join(kok, "src", "backend", "Momentum.Api", "wwwroot", "flutter_bootstrap.js")
        if not os.path.isfile(fb_yol):
            # BLOKER-1 (Cowork hukmu, o67): bu dal DAIMA 3'lu demet doner --
            # tetiklenmis bir satirda <engineRevision> VARKEN wwwroot/flutter_bootstrap.js
            # YOKSA (git-izsiz build ciktisi, .gitignore:31) bu NORMAL durumdur;
            # cagiran (g52) sinif="a2-ortam-hatasi" oldugunda ucuncu ogeyi OKUMAZ,
            # ama ucuncu oge EKSIK olunca `sinif, a, b = ...` ValueError ile COKUYORDU.
            return ("a2-ortam-hatasi", "flutter_bootstrap.js bulunamadi (git-izsiz build ciktisi, G52/a2)", None)
        fb_icerik = oku_metin(fb_yol)
        rev_m = ENGINE_REVISION_DESENI.search(fb_icerik)
        host_m = GSTATIC_HOST_DESENI.search(fb_icerik)
        if not rev_m or not host_m:
            return ("c", None, None)
        revision = rev_m.group(1)
        host = host_m.group(0)  # ör. ".../flutter-canvaskit" (gercek gstatic YA DA yerel test sunucusu)
        tamamlanan = YERTUTUCU_DESENI.sub(revision, satir)
        # satirin kendi yolundan revision SONRASI kismi al (ör. "/x.wasm")
        kalan_m = re.search(re.escape(revision) + r"(/[\w./-]+)", tamamlanan)
        kalan = kalan_m.group(1) if kalan_m else ""
        tam_url = host.rstrip("/") + "/" + revision + kalan
        return ("a2-cozuldu", tam_url, "GET")

    url_m = URL_DESENI.search(satir)
    if url_m:
        return ("a", url_m.group(0), "HEAD")

    yol_m = REPO_YOL_DESENI.search(satir)
    tirnak_m = TIRNAKLI_DESEN.search(satir)
    if yol_m and tirnak_m:
        return ("b", yol_m.group(0), tirnak_m.group(1))

    return ("c", None, None)


def g52(belge_metin, kok, fixture_kok=None):
    bulgular = []
    ortam_hatalari = []

    fixture_kok = fixture_kok or kok
    poz_hata = _g52_pozitif_kontrol(fixture_kok)
    if poz_hata:
        ortam_hatalari.append(poz_hata)

    satirlar = belge_metin.splitlines()
    for i, ham_satir in enumerate(satirlar, start=1):
        norm = normalize_tr(ham_satir)
        if not TETIK_AILESI_G52.search(norm):
            continue
        sinif, a, b = _g52_hedef_ayikla(ham_satir, kok)
        if sinif == "a2-ortam-hatasi":
            ortam_hatalari.append("satir %d: %s" % (i, a))
        elif sinif in ("a", "a2-cozuldu"):
            url, yontem = a, b
            durum, hata = _http_dene(url, yontem=yontem)
            if durum is None:
                ortam_hatalari.append("satir %d: '%s' baglanti KURULAMADI: %s" % (i, url, hata))
            elif 200 <= durum < 400:
                ayak = "G52/a" if sinif == "a" else "G52/a2"
                bulgular.append(
                    (ayak, "KIRMIZI", "olcemedigini-sanmak",
                     "satir %d: '%s' ULASILABILIR (durum=%s) ama belge 'olculemedi' diyor" % (i, url, durum))
                )
            # 4xx/5xx (404 dahil): D-K170-3 -- "404 bir OLCUMDUR", bulgu URETMEZ.
        elif sinif == "b":
            dosya_ad, desen = a, b
            coz, coklu = _dosya_coz(dosya_ad, kok)
            if coz is None:
                bulgular.append(
                    ("G52/b", "SARI", "hedef-cikarilamadi",
                     "satir %d: '%s' repoda bulunamadi" % (i, dosya_ad))
                )
                continue
            hedef_yol = coz[0] if coklu else coz
            hedef_icerik = oku_metin(hedef_yol)
            if desen in hedef_icerik:
                bulgular.append(
                    ("G52/b", "KIRMIZI", "olcemedigini-sanmak",
                     "satir %d: '%s' deseni '%s' icinde BULUNDU ama belge 'olculemedi' diyor" % (i, desen, dosya_ad))
                )
        else:
            bulgular.append(
                ("G52/c", "SARI", "hedef-cikarilamadi",
                 "satir %d: tetik var ama URL/yol cikarilamadi" % i)
            )

    return bulgular, ortam_hatalari


# ============================ G53 — VAKA-DEGIL-SINIF AYAGI =======================

CONFIG_OKUMA_DESENLERI = [
    re.compile(r"Configuration\[\s*([^\]]+?)\s*\]"),
    re.compile(r"GetValue\s*<[^>]+>\s*\(\s*([^,)]+)"),
    re.compile(r"(?<!Try)GetValue\s*\(\s*([^,)]+)"),
    re.compile(r"GetSection\s*\(\s*([^)]+)\s*\)"),
]
CONST_STRING_DESENI = re.compile(r'const\s+string\s+(\w+)\s*=\s*"([^"]*)"\s*;')
DOSYA_ADI_DESENI = re.compile(r"\b[\w-]+\.(?:cs|json)\b")


def _belgenin_andigi_dosyalar(belge_metin, kok):
    adaylar = sorted(set(DOSYA_ADI_DESENI.findall(belge_metin)))
    sonuc = {}
    for ad in adaylar:
        coz, coklu = _dosya_coz(ad, kok)
        sonuc[ad] = (coz, coklu)
    return sonuc


def _json_yapraklari(veri, on_ek=""):
    yapraklar = []
    if isinstance(veri, dict):
        for k, v in veri.items():
            yol = "%s:%s" % (on_ek, k) if on_ek else k
            if isinstance(v, dict):
                yapraklar.extend(_json_yapraklari(v, yol))
            else:
                yapraklar.append(yol)
    return yapraklar


def _sabit_coz(sembol_ifadesi, dosyalar_icerik):
    """`X.Y` bicimindeki bir sembolu `const string Y = "...";` icin arar.
    dosyalar_icerik: {dosya_adi: icerik}. Doner: (deger, belirsiz_mi, bulundu_mu)."""
    m = re.match(r"^\s*[\w]+\.(\w+)\s*$", sembol_ifadesi)
    if not m:
        return None, False, False
    uye_adi = m.group(1)
    bulunanlar = []
    for dosya_ad, icerik in dosyalar_icerik.items():
        for cm in CONST_STRING_DESENI.finditer(icerik):
            if cm.group(1) == uye_adi:
                bulunanlar.append((dosya_ad, cm.group(2)))
    if not bulunanlar:
        return None, False, False
    degerler = set(v for _d, v in bulunanlar)
    if len(bulunanlar) > 1 and len(degerler) > 1:
        return None, True, True
    return bulunanlar[0][1], False, True


def g53(belge_metin, kok):
    bulgular = []
    ortam_hatalari = []
    andigi = _belgenin_andigi_dosyalar(belge_metin, kok)

    dosyalar_icerik = {}
    for ad, (coz, coklu) in andigi.items():
        if coz is None:
            if ad.endswith(".cs") or ad.endswith(".json"):
                bulgular.append(
                    ("G53/e", "KIRMIZI", "var-olmayan-artefakta-hukum",
                     "belge '%s'yi anıyor ama dosya diskte YOK" % ad)
                )
            continue
        yol = coz[0] if coklu else coz
        try:
            dosyalar_icerik[ad] = oku_metin(yol)
        except Exception as ex:
            ortam_hatalari.append("'%s' okunamadi: %r" % (ad, ex))

    # a / a2: JSON yaprak anahtarlari
    okunan_anahtarlar = set()  # b/c'den once dolduruluyor asagida, once toplanir
    for ad, icerik in list(dosyalar_icerik.items()):
        if not ad.endswith(".json"):
            continue
        try:
            veri = json.loads(icerik)
        except Exception:
            continue
        for yaprak in _json_yapraklari(veri):
            if yaprak not in normalize_tr(belge_metin) and yaprak.lower() not in normalize_tr(belge_metin):
                if yaprak not in belge_metin:
                    bulgular.append(
                        ("G53/a", "SARI", "vaka-degil-sinif",
                         "'%s' dosyasinin yaprak anahtari '%s' belgede ANILMIYOR" % (ad, yaprak))
                    )

    # b + c: .cs dosyalarindaki config-okuma cagrilari
    for ad, icerik in dosyalar_icerik.items():
        if not ad.endswith(".cs"):
            continue
        for desen in CONFIG_OKUMA_DESENLERI:
            for m in desen.finditer(icerik):
                arg = m.group(1).strip()
                # NK1: TryGetValue negatif filtre -- desen zaten (?<!Try) ile disliyor.
                anahtar = None
                if arg.startswith('"') and arg.endswith('"'):
                    anahtar = arg.strip('"')
                elif re.match(r"^[\w]+\.[\w]+$", arg):
                    deger, belirsiz, bulundu = _sabit_coz(arg, dosyalar_icerik)
                    if belirsiz:
                        bulgular.append(
                            ("G53/c", "SARI", "cozulemeyen-ad",
                             "'%s' sembolu icin BIRDEN COK farkli const string bulundu (sabit-belirsiz)" % arg)
                        )
                        continue
                    if not bulundu:
                        bulgular.append(
                            ("G53/c", "SARI", "cozulemeyen-ad",
                             "'%s' sembolu icin const string COZULEMEDI" % arg)
                        )
                        continue
                    anahtar = deger
                else:
                    continue
                if anahtar is None:
                    continue
                okunan_anahtarlar.add(anahtar)
                if anahtar not in belge_metin:
                    bulgular.append(
                        ("G53/a2", "KIRMIZI", "vaka-degil-sinif",
                         "'%s' dosyasi '%s' anahtarini FIILEN OKUYOR ama belgede GECMIYOR" % (ad, anahtar))
                    )

    # d: kosulsuz-anlatilan cagri urunde if(...) icinde mi (N=3 pencere, kok-tabanli tetik)
    TETIK_D = re.compile(
        r"(zorunlu.{0,400}sıra|sıra.{0,400}zorunlu|her ortamda|her yanıtta|→)"
    )
    satirlar = belge_metin.splitlines()
    bildirilenler = set()
    for i in range(len(satirlar)):
        pencere = "\n".join(satirlar[i:i + 3])
        if not TETIK_D.search(normalize_tr(pencere)):
            continue
        # 🔴 TEK cagri DEGIL, penceredeki TUM cagri adaylari kontrol edilir --
        # ilk yazimda yalniz ILK eslesme aliniyordu ve pencerede birden fazla
        # `X()` varsa (ör. "UseRouting() -> UseCors()") ikincisi HIC gorulmuyordu.
        for cagri_m in re.finditer(r"\b([A-Z]\w+)\(\)", pencere):
            cagri_adi = cagri_m.group(1)
            for ad, icerik in dosyalar_icerik.items():
                if not ad.endswith(".cs"):
                    continue
                cagri_satirlari = icerik.splitlines()
                for j, satir in enumerate(cagri_satirlari):
                    if cagri_adi + "(" not in satir:
                        continue
                    # geriye dogru 5 satira kadar acik bir if( var mi VE aradaki
                    # '}' o if'i henuz KAPATMAMIS mi?
                    kosullu = False
                    for k in range(max(0, j - 5), j):
                        if re.search(r"\bif\s*\(", cagri_satirlari[k]):
                            araya_kapanis_var = any(
                                "}" in cagri_satirlari[m2] for m2 in range(k + 1, j)
                            )
                            if not araya_kapanis_var:
                                kosullu = True
                                break
                    if kosullu and (cagri_adi, ad, j) not in bildirilenler:
                        bildirilenler.add((cagri_adi, ad, j))
                        bulgular.append(
                            ("G53/d", "KIRMIZI", "vaka-degil-sinif",
                             "belge '%s()' cagrisini KOSULSUZ anlatiyor ama '%s' icinde if(...) icinde" % (cagri_adi, ad))
                        )

    return bulgular, ortam_hatalari


# ============================ G54 — KANONIK-KOPYA AYAGI ==========================

ALINTI_DESENLERI = [
    re.compile(r'\*"([^"]{12,})"\*'),
    re.compile(r"«([^»]{12,})»"),
    re.compile(r"^>\s+(.{12,})$", re.MULTILINE),
]
# BLOKER-2 (Cowork hukmu, o67): eski desen satir numarasini YALNIZ backtick'in
# ICINDE kabul ediyordu (`` `yol:satir` ``). ADR 0004'un KULLANDIGI bicim ise
# backtick'i YALNIZ dosya adinin cevresine kapatir, satir numarasi backtick'in
# DISINDA kalir (`` `yol`:satir ``) -- o bicim eski desenle SESSIZ (hic
# eslesmiyordu, satir_no=None). Dosya adindan hemen SONRA -- ama :satir'dan
# ONCE -- ikinci bir opsiyonel backtick eklenir; boylece HEM ic-backtick'li
# HEM dis-backtick'li HEM ciplak bicim ayni desenle cozulur.
ATIF_DESENI = re.compile(r"`?([\w./\\-]+\.(?:cs|py|md|js|json))`?(?::(\d+)(?:-(\d+))?)?`?")

KILIT_KAYNAGI = {
    # D-K170-9 icin K21 emsali: DURUM.md'nin CANLI K21 satiri KANONIK kaynaktir.
    # Fixture/altin-kume ayri bir "kanonik" DURUM.md kopyasi kullanir.
}


def _kilit_satiri_bul(durum_metin, kilit_id):
    for satir in durum_metin.splitlines():
        if re.search(r"\*\*%s\*\*" % re.escape(kilit_id), satir) and satir.strip().startswith("-"):
            return satir.strip()
    return None


def g54(belge_metin, kok, durum_kaynagi_yolu=None):
    bulgular = []
    ortam_hatalari = []
    satirlar = belge_metin.splitlines()

    for i, satir in enumerate(satirlar):
        for atif_m in ATIF_DESENI.finditer(satir):
            dosya_ad = atif_m.group(1)
            satir_no = atif_m.group(2)
            if satir_no is None:
                continue
            coz, coklu = _dosya_coz(dosya_ad, kok)
            if coz is None:
                continue
            if coklu:
                bulgular.append(
                    ("G54/b", "SARI", "yol-belirsiz",
                     "belge satır %d: cıplak '%s' REPODA BIRDEN COK dosyaya cozuluyor" % (i + 1, dosya_ad))
                )
                continue
            hedef_satirlar = oku_metin(coz).splitlines()
            satir_no_int = int(satir_no)
            if satir_no_int > len(hedef_satirlar) or satir_no_int < 1:
                bulgular.append(
                    ("G54/c", "KIRMIZI", "sarkan-atif",
                     "belge satır %d: '%s:%s' dosyada YOK (dosya %d satır)" % (i + 1, dosya_ad, satir_no, len(hedef_satirlar)))
                )
                continue

            pencere_baslangic = satir_no_int - 1
            pencere = "\n".join(hedef_satirlar[pencere_baslangic:pencere_baslangic + 5])
            pencere_norm = re.sub(r"\s+", " ", pencere)

            alinti_bulundu = None
            for desen in ALINTI_DESENLERI:
                for am in desen.finditer("\n".join(satirlar[max(0, i - 1):i + 2])):
                    alinti_bulundu = am.group(1)
                    break
                if alinti_bulundu:
                    break
            if alinti_bulundu:
                alinti_norm = re.sub(r"\s+", " ", alinti_bulundu).strip()
                if alinti_norm not in pencere_norm:
                    bulgular.append(
                        ("G54/a", "KIRMIZI", "kanonik-kopya",
                         "belge satır %d: alıntı '%s' kaynakta ('%s' 5 satır penceresinde) BULUNAMADI" % (i + 1, alinti_norm[:60], dosya_ad))
                    )

    if durum_kaynagi_yolu and os.path.isfile(durum_kaynagi_yolu):
        durum_metin = oku_metin(durum_kaynagi_yolu)
        for kilit_m in re.finditer(r"\*\*K(\d+)\*\*", belge_metin):
            kilit_id = "K" + kilit_m.group(1)
            kanonik = _kilit_satiri_bul(durum_metin, kilit_id)
            if not kanonik:
                continue
            cevre = belge_metin[kilit_m.start():kilit_m.start() + 400]
            alinti_bulundu = None
            for desen in ALINTI_DESENLERI:
                am = desen.search(cevre)
                if am:
                    alinti_bulundu = am.group(1)
                    break
            if alinti_bulundu:
                a_norm = re.sub(r"\s+", " ", alinti_bulundu).strip()
                k_norm = re.sub(r"\s+", " ", kanonik).strip()
                if a_norm not in k_norm:
                    bulgular.append(
                        ("G54/d", "SARI", "kanonik-kopya",
                         "belgede '%s' icin alintilanan metin KANONIK kaynaktan FARKLI" % kilit_id)
                    )

    return bulgular, ortam_hatalari


# ============================ G55 — KOR-KAPI AYAGI (KISMI) =======================

DURUM_IDDIASI_DESENI = re.compile(r"🟢|koşuyor|yeşil|geçti|exit 0")
YOKLUK_BEYANI_DESENI = re.compile(r"implementasyonu[ıu]?\s+yok|yoktur|yok\b")
ARAC_ADI_DESENI = re.compile(r"\b([\w-]+\.py)\b")
KAPI_KIMLIGI_DESENI = re.compile(r"\b([\w]+)/G(\d+)\b")


def _g55_pozitif_kontrol(fixture_kok):
    yol = os.path.join(fixture_kok, "pozitif-kontrol-kapilar.md")
    if not os.path.isfile(yol):
        return "pozitif-kontrol-kapilar.md bulunamadi (G55/d)"
    metin = oku_metin(yol)
    if not ARAC_ADI_DESENI.search(metin):
        return "pozitif-kontrol-kapilar.md'de BILINEN arac adi bulunamadi (G55/d)"
    return None


def g55(belge_metin, kok, kapilar_yolu=None, durum_yolu=None, fixture_kok=None):
    bulgular = []
    ortam_hatalari = []

    fixture_kok = fixture_kok or kok
    poz_hata = _g55_pozitif_kontrol(fixture_kok)
    if poz_hata:
        ortam_hatalari.append(poz_hata)

    kapilar_yolu = kapilar_yolu or os.path.join(kok, "KAPILAR.md")
    durum_yolu = durum_yolu or os.path.join(kok, "DURUM.md")
    kapilar_metin = oku_metin(kapilar_yolu) if os.path.isfile(kapilar_yolu) else ""
    durum_metin = oku_metin(durum_yolu) if os.path.isfile(durum_yolu) else ""

    def _bulgu_ekle(i, arac_adi, kaynak_not=""):
        stem = arac_adi[:-3] if arac_adi.endswith(".py") else arac_adi
        if stem not in kapilar_metin:
            bulgular.append(
                ("G55/a", "KIRMIZI", "kor-kapi",
                 "belge satır %d: '%s'%s icin DURUM IDDIASI var ama KAPILAR.md'de YOK" % (i + 1, arac_adi, kaynak_not))
            )
        if stem not in durum_metin:
            bulgular.append(
                ("G55/b", "KIRMIZI", "kor-kapi",
                 "belge satır %d: '%s'%s icin DURUM IDDIASI var ama DURUM.md §6'da YOK" % (i + 1, arac_adi, kaynak_not))
            )

    def _kimligin_araci(spec_ad):
        """`<spec>/G<n>` bir DURUM IDDIASI tasidiginda, o kapiyi UYGULAYAN
        araci spec'in KENDI '## 5. KAPILAR' bolumunden COZMEYE calisir
        (dogrudan .py adi YERINE kapi kimligi anilmis olabilir -- V6)."""
        for kok_dizin, _dizinler, dosyalar in os.walk(os.path.join(kok, "GOREV_CLAUDE_CODE")):
            for dosya in dosyalar:
                if dosya.startswith("GOREV-%s-" % spec_ad) or dosya == "GOREV-%s.md" % spec_ad:
                    spec_metin = oku_metin(os.path.join(kok_dizin, dosya))
                    m5 = re.search(r"## 5\. KAPILAR(.*?)(?:\n## |\Z)", spec_metin, re.DOTALL)
                    if m5:
                        py_m = re.search(r"[\w-]+\.py", m5.group(1))
                        if py_m:
                            return py_m.group(0)
        return None

    satirlar = belge_metin.splitlines()
    for i, satir in enumerate(satirlar):
        norm = normalize_tr(satir)
        if not DURUM_IDDIASI_DESENI.search(norm):
            continue
        if YOKLUK_BEYANI_DESENI.search(norm):
            # NK3: yoklugun DOGRU beyani -- KUTUP -- iddia SAYILMAZ.
            continue
        dogrudan_arac_var = False
        for arac_m in ARAC_ADI_DESENI.finditer(satir):
            dogrudan_arac_var = True
            _bulgu_ekle(i, arac_m.group(1))
        if not dogrudan_arac_var:
            # Dogrudan .py adi YOK -- belki DURUM IDDIASI bir KAPI KIMLIGINE
            # (<spec>/G<n>) bagli (V6'nin GERCEK ADR'deki bicimi budur).
            for kimlik_m in KAPI_KIMLIGI_DESENI.finditer(satir):
                spec_ad = kimlik_m.group(1)
                arac_adi = _kimligin_araci(spec_ad)
                if arac_adi:
                    _bulgu_ekle(i, arac_adi, kaynak_not=" (kimlik %s/G%s uzerinden cozuldu)" % (spec_ad, kimlik_m.group(2)))

    for kimlik_m in KAPI_KIMLIGI_DESENI.finditer(belge_metin):
        spec_ad, kapi_no = kimlik_m.group(1), kimlik_m.group(2)
        kimlik_tam = "%s/G%s" % (spec_ad, kapi_no)
        aday_yollari = []
        for kok_dizin, _dizinler, dosyalar in os.walk(os.path.join(kok, "GOREV_CLAUDE_CODE")):
            for dosya in dosyalar:
                if dosya.startswith("GOREV-%s-" % spec_ad) or dosya == "GOREV-%s.md" % spec_ad:
                    aday_yollari.append(os.path.join(kok_dizin, dosya))
        if not aday_yollari:
            bulgular.append(
                ("G55/c", "SARI", "spec-cozulemedi",
                 "'%s' icin GOREV-%s-*.md COZULEMEDI" % (kimlik_tam, spec_ad))
            )
            continue
        spec_metin = oku_metin(aday_yollari[0])
        m6 = re.search(r"## 6\. MUTANTLAR(.*?)(?:\n## |\Z)", spec_metin, re.DOTALL)
        gorulen = False
        if m6:
            for satir in m6.group(1).splitlines():
                hucreler = [h.strip() for h in satir.strip().strip("|").split("|")]
                if len(hucreler) >= 3 and kimlik_tam in hucreler[2]:
                    gorulen = True
                    break
        if not gorulen:
            bulgular.append(
                ("G55/c", "KIRMIZI", "kor-kapi",
                 "'%s' anilmis ama %s'nin ## 6. MUTANTLAR hedef sutununda YOK" % (kimlik_tam, os.path.basename(aday_yollari[0])))
            )

    return bulgular, ortam_hatalari


# ============================ G56 — SINIF ADI SOZLUGU ============================


def _defter_son_kayit(defter_yolu):
    son = None
    with io.open(defter_yolu, encoding="utf-8") as f:
        for satir in f:
            satir = satir.strip()
            if not satir or satir.startswith("#"):
                continue
            try:
                son = json.loads(satir)
            except Exception:
                continue
    return son


def g56(sozluk_yolu, defter_yolu):
    bulgular = []
    ortam_hatalari = []

    if not os.path.isfile(sozluk_yolu):
        return bulgular, ["sinif-sozlugu.json bulunamadi: %s" % sozluk_yolu]
    if not os.path.isfile(defter_yolu):
        return bulgular, ["defter bulunamadi: %s" % defter_yolu]

    with io.open(sozluk_yolu, encoding="utf-8") as f:
        sozluk = json.load(f)
    girdiler = sozluk.get("girdiler", [])
    adlar = {g["ad"] for g in girdiler}

    son_kayit = _defter_son_kayit(defter_yolu)
    if son_kayit is None:
        return bulgular, ["defterde gecerli kayit yok: %s" % defter_yolu]

    for sinif in son_kayit.get("siniflar", []) or []:
        if sinif not in adlar:
            en_yakin = difflib.get_close_matches(sinif, list(adlar), n=1, cutoff=0.0)
            oneri = en_yakin[0] if en_yakin else "(yok)"
            bulgular.append(
                ("G56/a", "KIRMIZI", "olcum-araci-boslugu",
                 "son kayittaki '%s' sozlukte YOK -- en yakin oneri: '%s'" % (sinif, oneri))
            )

    for i in range(len(girdiler)):
        for j in range(i + 1, len(girdiler)):
            a, b = girdiler[i]["ad"], girdiler[j]["ad"]
            r = difflib.SequenceMatcher(None, a, b).ratio()
            if r < 0.82:
                continue
            gerekceli_mi = (
                (isinstance(girdiler[i].get("ayri_tutuldu"), dict) and b in girdiler[i]["ayri_tutuldu"])
                or (isinstance(girdiler[j].get("ayri_tutuldu"), dict) and a in girdiler[j]["ayri_tutuldu"])
            )
            if not gerekceli_mi:
                bulgular.append(
                    ("G56/b", "KIRMIZI", "cozulemeyen-ad",
                     "'%s' <-> '%s' benzerlik %.3f (>=0.82) ama ayri_tutuldu GEREKCESI YOK" % (a, b, r))
                )

    for g in girdiler:
        if not g.get("tanim", "").strip():
            bulgular.append(
                ("G56/c", "SARI", "olculmemis-etiket",
                 "'%s' icin tanim ALANI BOS" % g["ad"])
            )

    return bulgular, ortam_hatalari


# ============================ DENETLE / ANA AKIS =================================


def denetle(belge_yolu, kok, sozluk_yolu=None, defter_yolu=None,
            kapilar_yolu=None, durum_yolu=None, fixture_kok=None, durum_kaynagi_yolu=None):
    belge_metin = oku_metin(belge_yolu)
    tum_bulgular = []
    tum_ortam_hatalari = []

    for fn, kwargs in (
        (g52, dict(belge_metin=belge_metin, kok=kok, fixture_kok=fixture_kok)),
        (g53, dict(belge_metin=belge_metin, kok=kok)),
        (g54, dict(belge_metin=belge_metin, kok=kok, durum_kaynagi_yolu=durum_kaynagi_yolu or durum_yolu)),
        (g55, dict(belge_metin=belge_metin, kok=kok, kapilar_yolu=kapilar_yolu, durum_yolu=durum_yolu, fixture_kok=fixture_kok)),
    ):
        b, h = fn(**kwargs)
        tum_bulgular += b
        tum_ortam_hatalari += h

    b, h = g56(
        sozluk_yolu or os.path.join(kok, "araclar", "sinif-sozlugu.json"),
        defter_yolu or os.path.join(kok, "PROJE_RADAR.jsonl"),
    )
    tum_bulgular += b
    tum_ortam_hatalari += h

    return tum_bulgular, tum_ortam_hatalari


def cikis_kodu_hesapla(bulgular, ortam_hatalari, bicim_hatasi=False):
    if bicim_hatasi:
        return EXIT_BICIM
    if ortam_hatalari:
        return EXIT_ORTAM_HATASI
    if any(e == "KIRMIZI" for _a, e, _s, _m in bulgular):
        return EXIT_KIRMIZI
    if any(e == "SARI" for _a, e, _s, _m in bulgular):
        return EXIT_SARI
    return EXIT_YESIL


def rapor_yazdir(bulgular, ortam_hatalari):
    print("=" * 78)
    print("ADR-HUKUM-KAPISI -- G52-G56")
    print("=" * 78)
    if not bulgular and not ortam_hatalari:
        print("bulgu yok.")
    for ayak, etiket, sinif, mesaj in bulgular:
        print("  [%s] %s (%s): %s" % (etiket, ayak, sinif, mesaj))
    for hata in ortam_hatalari:
        print("  [ORTAM HATASI] %s" % hata)
    # D-K170-5 / kabul kriteri 6: beyan satiri HER kosumda basilir.
    print("-" * 78)
    print(
        "BEYAN (D-K170-5): bu arac YALNIZ hedef belge + defterin SON kaydini "
        "olcer; PROJE_RADAR.jsonl'un GECMIS kayitlari denetlenmez (append-only, "
        "kural gelecegi baglar, gecmisi onarmaz)."
    )
    print("-" * 78)


# ============================ --ALTIN-KUME ========================================

FIXTURE_KOK = os.path.join(KOK_VARSAYILAN, "araclar", "fixture", "adr-hukum")


def _bos_port_bul():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(("127.0.0.1", 0))
        return s.getsockname()[1]


def _yerel_sunucu_baslat(dizin):
    port = _bos_port_bul()
    with open(os.path.join(dizin, "_hazir"), "w", encoding="utf-8") as f:
        f.write("hazir\n")
    handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=dizin)
    httpd = http.server.ThreadingHTTPServer(("127.0.0.1", port), handler)
    thread = threading.Thread(target=httpd.serve_forever, daemon=True)
    thread.start()
    baslangic = time.time()
    hazir = False
    while time.time() - baslangic < 10:
        try:
            with urlopen("http://127.0.0.1:%d/_hazir" % port, timeout=1) as r:
                if r.status == 200:
                    hazir = True
                    break
        except Exception:
            pass
        time.sleep(0.2)
    if not hazir:
        httpd.shutdown()
        raise RuntimeError("yerel sunucu 10s icinde hazir olmadi -- ORTAM HATASI")
    return httpd, port


def _yerel_sunucu_durdur(httpd, port):
    httpd.shutdown()
    httpd.server_close()
    baslangic = time.time()
    while time.time() - baslangic < 5:
        try:
            with socket.create_connection(("127.0.0.1", port), timeout=0.5):
                time.sleep(0.2)
                continue
        except Exception:
            return True
    return False


def altin_kume_kos():
    import tempfile

    vakalar = []

    def vaka(no, aciklama, fn):
        try:
            ok, detay = fn()
        except Exception as ex:
            ok, detay = False, "ISTISNA: %r" % ex
        vakalar.append((no, aciklama, ok, detay))
        ek = "" if ok else (" -- %r" % (detay,))
        print("[%s] %s) %s%s" % ("GECTI" if ok else "DUSTU", no, aciklama, ek))

    # ---- G52 ----
    def g52_temiz():
        with tempfile.TemporaryDirectory() as td:
            belge = os.path.join(td, "b.md")
            with open(belge, "w", encoding="utf-8") as f:
                f.write("Bu belgede hicbir olculemedi/olcemedi iddiasi YOK.\n")
            b, h = g52(oku_metin(belge), KOK_VARSAYILAN, fixture_kok=FIXTURE_KOK)
            return (not b and not h), (b, h)

    def g52_a_kirli_ve_ortam_hatasi():
        with tempfile.TemporaryDirectory() as td:
            httpd, port = _yerel_sunucu_baslat(td)
            try:
                with open(os.path.join(td, "x.wasm"), "wb") as f:
                    f.write(b"\x00wasm")
                belge = os.path.join(td, "b.md")
                url = "http://127.0.0.1:%d/x.wasm" % port
                with open(belge, "w", encoding="utf-8") as f:
                    f.write("CORP ÖLÇÜLEMEDİ (%s)\n" % url)  # M265
                b, h = g52(oku_metin(belge), KOK_VARSAYILAN, fixture_kok=FIXTURE_KOK)
                kirmizi_var = any(a == "G52/a" and e == "KIRMIZI" for a, e, _s, _m in b)
            finally:
                _yerel_sunucu_durdur(httpd, port)
            # sunucu KAPALIYKEN AYNI url -> ORTAM HATASI (M266)
            b2, h2 = g52(oku_metin(belge), KOK_VARSAYILAN, fixture_kok=FIXTURE_KOK)
            ortam_hatali = len(h2) > 0
            return (kirmizi_var and ortam_hatali), (b, h, b2, h2)

    def g52_a_turkce_normalize():
        with tempfile.TemporaryDirectory() as td:
            httpd, port = _yerel_sunucu_baslat(td)
            try:
                with open(os.path.join(td, "x.wasm"), "wb") as f:
                    f.write(b"\x00wasm")
                url = "http://127.0.0.1:%d/x.wasm" % port
                belge = os.path.join(td, "b.md")
                with open(belge, "w", encoding="utf-8") as f:
                    f.write("Satir1: ÖLÇÜLMEDİ (%s)\nSatir2: ÖLÇÜLEMEDİ (%s)\n" % (url, url))  # M267
                b, h = g52(oku_metin(belge), KOK_VARSAYILAN, fixture_kok=FIXTURE_KOK)
                iki_vaka = sum(1 for a, e, _s, _m in b if a == "G52/a" and e == "KIRMIZI") == 2
            finally:
                _yerel_sunucu_durdur(httpd, port)
            return iki_vaka, b

    def g52_a2_kirli():
        with tempfile.TemporaryDirectory() as td:
            httpd, port = _yerel_sunucu_baslat(td)
            try:
                ck_dizin = os.path.join(td, "flutter-canvaskit", "83675ed27633283e7fc296c8bca22e841224c096")
                os.makedirs(ck_dizin, exist_ok=True)
                with open(os.path.join(ck_dizin, "x.wasm"), "wb") as f:
                    f.write(b"\x00wasm")
                fb = ('_flutter.buildConfig={engineRevision":"83675ed27633283e7fc296c8bca22e841224c096",'
                      'canvasKitBaseUrl:i.canvasKitBaseUrl?i.canvasKitBaseUrl:"http://127.0.0.1:%d/flutter-canvaskit"};' % port)
                wwwroot_sahte = os.path.join(td, "_wwwroot")
                os.makedirs(wwwroot_sahte, exist_ok=True)
                with open(os.path.join(wwwroot_sahte, "flutter_bootstrap.js"), "w", encoding="utf-8") as f:
                    f.write(fb)
                sahte_kok = os.path.join(td, "_kok")
                os.makedirs(os.path.join(sahte_kok, "src", "backend", "Momentum.Api"), exist_ok=True)
                os.rename(wwwroot_sahte, os.path.join(sahte_kok, "src", "backend", "Momentum.Api", "wwwroot"))
                belge = os.path.join(td, "b.md")
                with open(belge, "w", encoding="utf-8") as f:
                    f.write("canvaskit/<engineRevision>/x.wasm ÖLÇÜLMEDİ\n")  # M268
                b, h = g52(oku_metin(belge), sahte_kok, fixture_kok=FIXTURE_KOK)
                return any(a == "G52/a2" and e == "KIRMIZI" for a, e, _s, _m in b), (b, h)
            finally:
                _yerel_sunucu_durdur(httpd, port)

    def g52_a2_bootstrap_yok_ortam_hatasi():
        # BLOKER-1 (Cowork hukmu, o67): tetiklenmis bir satirda <engineRevision>
        # VARKEN wwwroot/flutter_bootstrap.js YOKSA (git-izsiz build ciktisi,
        # .gitignore:31 -- temiz klon/CI/hic `flutter build web` kosmamis makine
        # icin NORMAL durum) arac COKMEMELI, ORTAM HATASI vermelidir.
        with tempfile.TemporaryDirectory() as td:
            sahte_kok = os.path.join(td, "_kok")
            os.makedirs(os.path.join(sahte_kok, "src", "backend", "Momentum.Api"), exist_ok=True)
            # flutter_bootstrap.js BILEREK YOK.
            belge = os.path.join(td, "b.md")
            with open(belge, "w", encoding="utf-8") as f:
                f.write("canvaskit/<engineRevision>/x.wasm ÖLÇÜLMEDİ\n")
            b, h = g52(oku_metin(belge), sahte_kok, fixture_kok=FIXTURE_KOK)
            ortam_hatali = any("flutter_bootstrap.js" in x for x in h)
            return ortam_hatali, (b, h)

    def g52_b_kirli():
        belge_metin = "araclar/radar.py icindeki 'mekanik' deseni ÖLÇÜLEMEDİ.\n"  # M269
        b, h = g52(belge_metin, KOK_VARSAYILAN, fixture_kok=FIXTURE_KOK)
        return any(a == "G52/b" and e == "KIRMIZI" for a, e, _s, _m in b), (b, h)

    def g52_c_sari():
        belge_metin = "Bu iddia hicbir sekilde ÖLÇÜLEMEDİ, ayrintisi yazilmadi.\n"  # M270
        b, h = g52(belge_metin, KOK_VARSAYILAN, fixture_kok=FIXTURE_KOK)
        return any(a == "G52/c" and e == "SARI" for a, e, _s, _m in b), (b, h)

    def g52_d_ortam_hatasi():
        with tempfile.TemporaryDirectory() as td:
            b, h = g52("temiz belge\n", KOK_VARSAYILAN, fixture_kok=td)
            return len(h) > 0, h

    vaka(1, "G52 temiz belge -> bulgu yok", g52_temiz)
    vaka(2, "G52/a: canli URL (M265 acik + M266 kapali) -> KIRMIZI + ORTAM HATASI", g52_a_kirli_ve_ortam_hatasi)
    vaka(3, "G52/a: Turkce buyuk/kucuk I normalizasyonu iki yazim (M267) -> 2 KIRMIZI", g52_a_turkce_normalize)
    vaka(4, "G52/a2: <engineRevision> yertutucu doldurma (M268) -> KIRMIZI", g52_a2_kirli)
    vaka("4b", "G52/a2: BLOKER-1 -- bootstrap YOK, tetiklenmis <engineRevision> -> ORTAM HATASI (COKMEZ)", g52_a2_bootstrap_yok_ortam_hatasi)
    vaka(5, "G52/b: repo-ici yol + tirnakli desen bulunur (M269) -> KIRMIZI", g52_b_kirli)
    vaka(6, "G52/c: hedef cikarilamaz (M270) -> SARI hedef-cikarilamadi", g52_c_sari)
    vaka(7, "G52/d: pozitif kontrol fixture'i yok (M271 benzeri) -> ORTAM HATASI", g52_d_ortam_hatasi)

    # ---- G53 ----
    def _g53_fixture_kur(td, appsettings_ekstra=None, cs_ekstra=None, usecors_kosullu=False,
                          sabit_coz=True, sabit_coklu=False, dosya_yok=False):
        appsettings = {"Logging": {"LogLevel": {"Default": "Information"}}, "AllowedHosts": "*"}
        if appsettings_ekstra:
            appsettings.update(appsettings_ekstra)
        with open(os.path.join(td, "appsettings.json"), "w", encoding="utf-8") as f:
            json.dump(appsettings, f)

        if sabit_coz:
            const_satir = 'public const string EtkinAnahtari = "Izolasyon:Etkin";\n' if not sabit_coklu else (
                'public const string EtkinAnahtari = "Izolasyon:Etkin";\n'
            )
        else:
            const_satir = ""
        cagri_satiri = "app.UseCors();\n"
        if usecors_kosullu:
            cagri_satiri = "if (env.IsDevelopment())\n{\n    app.UseCors();\n}\n"
        cs_govde = (
            "public class Program {\n"
            "  %s\n"
            "  void M() {\n"
            "    var x = Configuration[\"Logging:LogLevel:Default\"];\n"
            "    %s\n"
            "    %s\n"
            "  }\n"
            "}\n" % (const_satir, cagri_satiri, cs_ekstra or "")
        )
        with open(os.path.join(td, "Program.cs"), "w", encoding="utf-8") as f:
            f.write(cs_govde)
        if sabit_coklu:
            with open(os.path.join(td, "Ikinci.cs"), "w", encoding="utf-8") as f:
                f.write('public class Ikinci { public const string EtkinAnahtari = "Baska:Deger"; }\n')

    def g53_temiz():
        with tempfile.TemporaryDirectory() as td:
            _g53_fixture_kur(td)
            belge = (
                "Program.cs, `Logging:LogLevel:Default` anahtarini okur. "
                "`app.UseCors()` her ortamda kosulsuz cagrilir.\n"
            )
            b, h = g53(belge, td)
            kirmizi = [x for x in b if x[1] == "KIRMIZI"]
            return not kirmizi, (b, h)

    def g53_a_sari():
        with tempfile.TemporaryDirectory() as td:
            _g53_fixture_kur(td, appsettings_ekstra={"Yeni": {"Anahtar": "deger"}})  # M272
            belge = (
                "Program.cs, `Logging:LogLevel:Default` anahtarini okur. "
                "appsettings.json bu degerleri tasir.\n"
            )
            b, h = g53(belge, td)
            return any(a == "G53/a" and e == "SARI" for a, e, _s, _m in b), (b, h)

    def g53_a2_kirli():
        with tempfile.TemporaryDirectory() as td:
            _g53_fixture_kur(td, cs_ekstra='var y = Configuration["Yeni:Anahtar"];')  # M273
            belge = "Program.cs, `Logging:LogLevel:Default` anahtarini okur.\n"
            b, h = g53(belge, td)
            return any(a == "G53/a2" and e == "KIRMIZI" for a, e, _s, _m in b), (b, h)

    def g53_b_kirli():
        with tempfile.TemporaryDirectory() as td:
            _g53_fixture_kur(td, cs_ekstra='var y = Configuration.GetValue("Yeni:Anahtar", true);')  # M274
            belge = "Program.cs, `Logging:LogLevel:Default` anahtarini okur.\n"
            b, h = g53(belge, td)
            return any(a == "G53/a2" and e == "KIRMIZI" for a, e, _s, _m in b), (b, h)

    def nk1_trygetvalue_negatif_filtre():
        with tempfile.TemporaryDirectory() as td:
            # NK1: TryGetValue(...) bir CONFIG-OKUMA cagrisi SAYILMAZ (negatif filtre).
            _g53_fixture_kur(td, cs_ekstra='builder.TryGetValue("Yeni:Anahtar", out _);')
            belge = "Program.cs, `Logging:LogLevel:Default` anahtarini okur.\n"
            b, h = g53(belge, td)
            return not any("Yeni:Anahtar" in m for _a, _e, _s, m in b), (b, h)

    def g53_c_kirli_v2():
        with tempfile.TemporaryDirectory() as td:
            _g53_fixture_kur(td, cs_ekstra="var y = Configuration.GetValue(Program.EtkinAnahtari, true);")  # M275
            belge = "Program.cs, `Logging:LogLevel:Default` anahtarini okur.\n"
            b, h = g53(belge, td)
            return any(a == "G53/a2" and e == "KIRMIZI" and "Izolasyon:Etkin" in m for a, e, _s, m in b), (b, h)

    def g53_c_sari_cozulemedi():
        with tempfile.TemporaryDirectory() as td:
            _g53_fixture_kur(td, sabit_coz=False, cs_ekstra="var y = Configuration.GetValue(Program.EtkinAnahtari, true);")  # M276
            belge = "Program.cs, `Logging:LogLevel:Default` anahtarini okur.\n"
            b, h = g53(belge, td)
            return any(a == "G53/c" and e == "SARI" and "COZULEMEDI" in m for a, e, _s, m in b), (b, h)

    def g53_c_sari_belirsiz():
        with tempfile.TemporaryDirectory() as td:
            _g53_fixture_kur(td, sabit_coklu=True, cs_ekstra="var y = Configuration.GetValue(Program.EtkinAnahtari, true);")  # M277
            belge = (
                "Program.cs, `Logging:LogLevel:Default` anahtarini okur. "
                "Ikinci.cs de ilgili bir siniftir.\n"
            )
            b, h = g53(belge, td)
            return any(a == "G53/c" and e == "SARI" and "belirsiz" in m for a, e, _s, m in b), (b, h)

    def g53_d_kirli_v3():
        with tempfile.TemporaryDirectory() as td:
            _g53_fixture_kur(td, usecors_kosullu=True)  # M278
            belge = (
                "Sira ZORUNLUDUR: izolasyon her ortamda uygulanir →\n"
                "`app.UseCors()` her yanitta kosulsuz cagrilir (Program.cs).\n"
            )
            b, h = g53(belge, td)
            return any(a == "G53/d" and e == "KIRMIZI" for a, e, _s, _m in b), (b, h)

    def g53_e_kirli():
        with tempfile.TemporaryDirectory() as td:
            _g53_fixture_kur(td)
            os.remove(os.path.join(td, "Program.cs"))  # M279 benzeri: dosya yok
            belge = "Program.cs, `Logging:LogLevel:Default` anahtarini okur.\n"
            b, h = g53(belge, td)
            return any(a == "G53/e" and e == "KIRMIZI" for a, e, _s, _m in b), (b, h)

    vaka(8, "G53 temiz (anahtar anilmis, cagri kosulsuz) -> bulgu yok", g53_temiz)
    vaka(9, "G53/a: JSON yaprak anahtari anilmamis (M272) -> SARI anahtar-anilmadi", g53_a_sari)
    vaka(10, "G53/a2: kod OKUDUGU anahtar belgede yok (M273) -> KIRMIZI", g53_a2_kirli)
    vaka(11, "G53/b: generic'siz GetValue (M274) -> KIRMIZI", g53_b_kirli)
    vaka("11n", "NK1: TryGetValue(...) config-okuma SAYILMAZ -> SUSMALI", nk1_trygetvalue_negatif_filtre)
    vaka(12, "G53/c: sabit cozumleme ile V2 (M275) -> KIRMIZI", g53_c_kirli_v2)
    vaka(13, "G53/c: sabit cozulemedi (M276) -> SARI", g53_c_sari_cozulemedi)
    vaka(14, "G53/c: sabit belirsiz -- iki dosyada ayni ad (M277) -> SARI", g53_c_sari_belirsiz)
    vaka(15, "G53/d: kosulsuz anlatilan cagri if() icinde -- V3 (M278) -> KIRMIZI", g53_d_kirli_v3)
    vaka(16, "G53/e: belgenin andigi dosya diskte yok (M279 benzeri) -> KIRMIZI", g53_e_kirli)

    # ---- G54 ----
    def g54_temiz():
        with tempfile.TemporaryDirectory() as td:
            with open(os.path.join(td, "kaynak.cs"), "w", encoding="utf-8") as f:
                f.write("// satir 1\n// izolasyon VERIR ama alt kaynak farklidir\n// satir 3\n")
            belge = 'kaynak.cs:2 satirinda *"izolasyon VERIR ama alt kaynak farklidir"* yaziyor.\n'
            b, h = g54(belge, td)
            return not any(e == "KIRMIZI" for _a, e, _s, _m in b), (b, h)

    def g54_a_kirli():
        with tempfile.TemporaryDirectory() as td:
            with open(os.path.join(td, "kaynak.cs"), "w", encoding="utf-8") as f:
                f.write("// satir 1\n// izolasyon VERIR\n// satir 3\n")
            belge = 'kaynak.cs:2 satirinda *"izolasyon vermez ama alt kaynak"* yaziyor.\n'  # M280
            b, h = g54(belge, td)
            return any(a == "G54/a" and e == "KIRMIZI" for a, e, _s, _m in b), (b, h)

    def g54_a_disbacktick_kirli():
        # BLOKER-2 (Cowork hukmu, o67): ADR 0004'un KULLANDIGI bicim -- backtick
        # YALNIZ dosya adini kapsar, satir numarasi backtick DISINDA (`` `yol`:satir ``).
        # Eski desen bu bicimde satir_no'yu HIC cikaramiyordu (SESSIZ, EXIT 0).
        with tempfile.TemporaryDirectory() as td:
            with open(os.path.join(td, "kaynak.cs"), "w", encoding="utf-8") as f:
                f.write("// satir 1\n// izolasyon VERIR\n// satir 3\n")
            belge = '`kaynak.cs`:2 satirinda *"izolasyon vermez ama alt kaynak"* yaziyor.\n'
            b, h = g54(belge, td)
            return any(a == "G54/a" and e == "KIRMIZI" for a, e, _s, _m in b), (b, h)

    def nk4_nk5_backtick_alinti_degil():
        with tempfile.TemporaryDirectory() as td:
            with open(os.path.join(td, "kaynak.cs"), "w", encoding="utf-8") as f:
                f.write("// satir 1\napp.OnStarting(x);\n// satir 3\n")
            # NK4/NK5: tek-backtick'li tanimlayici (`OnStarting`) ALINTI DEGILDIR;
            # kaynakta GORUNMEYEN bir metin olsa bile G54/a TETIKLENMEMELI.
            belge = "kaynak.cs:2 satirinda `OnStarting` `TamamenFarkliBirIsim` cagirir.\n"
            b, h = g54(belge, td)
            return not any(a == "G54/a" for a, _e, _s, _m in b), (b, h)

    def g54_b_sari():
        with tempfile.TemporaryDirectory() as td:
            os.makedirs(os.path.join(td, "d1"))
            os.makedirs(os.path.join(td, "d2"))
            open(os.path.join(td, "d1", "Program.cs"), "w").close()
            open(os.path.join(td, "d2", "Program.cs"), "w").close()
            belge = "Program.cs:10 satirinda bir sey var.\n"  # M281
            b, h = g54(belge, td)
            return any(a == "G54/b" and e == "SARI" for a, e, _s, _m in b), (b, h)

    def g54_c_kirli():
        with tempfile.TemporaryDirectory() as td:
            with open(os.path.join(td, "x.cs"), "w", encoding="utf-8") as f:
                f.write("\n".join("satir %d" % i for i in range(1, 21)) + "\n")
            belge = "x.cs:9999 satirinda bir sey var.\n"  # M282
            b, h = g54(belge, td)
            return any(a == "G54/c" and e == "KIRMIZI" for a, e, _s, _m in b), (b, h)

    def g54_d_sari():
        with tempfile.TemporaryDirectory() as td:
            durum = os.path.join(td, "DURUM.md")
            with open(durum, "w", encoding="utf-8") as f:
                f.write("- **K21** — Oturum sagligi olculur; esikler MUTLAKTIR (yuzde YOK).\n")
            belge = '**K21** kilidi *"Oturum sagligi HISSEDILIR; esikler GORECELIDIR"* der.\n'  # M283 (degistirilerek)
            b, h = g54(belge, td, durum_kaynagi_yolu=durum)
            return any(a == "G54/d" and e == "SARI" for a, e, _s, _m in b), (b, h)

    def nk2_bosluk_farki_kacmaz():
        with tempfile.TemporaryDirectory() as td:
            with open(os.path.join(td, "kaynak.cs"), "w", encoding="utf-8") as f:
                f.write("// satir 1\n// izolasyon VERIR\n// satir 3\n// satir 4\n")
            # NK2: alinti YALNIZ BOSLUK farkiyla ve atif satirindan 2 satir asagida
            belge = 'kaynak.cs:2 satirinda bir sey var.\n\n*"izolasyon    VERIR"*\n'
            b, h = g54(belge, td)
            return not any(a == "G54/a" and e == "KIRMIZI" for a, e, _s, _m in b), (b, h)

    vaka(17, "G54 temiz (alinti kaynakla ayni) -> bulgu yok", g54_temiz)
    vaka(18, "G54/a: ters-alinti (M280) -> KIRMIZI", g54_a_kirli)
    vaka("18b", "G54/a: BLOKER-2 -- `yol`:satir bicimi (dis-backtick) + ters-alinti -> KIRMIZI", g54_a_disbacktick_kirli)
    vaka("18n", "NK4/NK5: tek-backtick tanimlayici ALINTI DEGIL -> SUSMALI", nk4_nk5_backtick_alinti_degil)
    vaka(19, "G54/b: ciplak dosya adi -- iki eslesme (M281) -> SARI yol-belirsiz", g54_b_sari)
    vaka(20, "G54/c: sarkan atif -- satir yok (M282) -> KIRMIZI", g54_c_kirli)
    vaka(21, "G54/d: K21 kilit metni degistirilerek kopyalanmis (M283) -> SARI kanonik-kopya", g54_d_sari)
    vaka(22, "NK2: yalniz bosluk farki + pencere ici konum -> SUSMALI", nk2_bosluk_farki_kacmaz)

    # ---- G55 ----
    def g55_temiz():
        with tempfile.TemporaryDirectory() as td:
            kapilar = os.path.join(td, "KAPILAR.md")
            durum = os.path.join(td, "DURUM.md")
            with open(kapilar, "w", encoding="utf-8") as f:
                f.write("| `yayin-kapisi.py` | ... | ... | ... |\n")
            with open(durum, "w", encoding="utf-8") as f:
                f.write("| `yayin-kapisi.py` | ... | 18/18 |\n")
            belge = "`yayin-kapisi.py` 🟢 kosuyor.\n"
            b, h = g55(belge, KOK_VARSAYILAN, kapilar_yolu=kapilar, durum_yolu=durum, fixture_kok=FIXTURE_KOK)
            return not any(e == "KIRMIZI" for _a, e, _s, _m in b), (b, h)

    def g55_a_kirli_v6():
        with tempfile.TemporaryDirectory() as td:
            kapilar = os.path.join(td, "KAPILAR.md")
            durum = os.path.join(td, "DURUM.md")
            with open(kapilar, "w", encoding="utf-8") as f:
                f.write("| `baska-arac.py` | ... |\n")  # M284: yayin-kapisi.py YOK
            with open(durum, "w", encoding="utf-8") as f:
                f.write("| `baska-arac.py` | ... |\n")
            belge = "`yayin-kapisi.py` 🟢 kosuyor.\n"
            b, h = g55(belge, KOK_VARSAYILAN, kapilar_yolu=kapilar, durum_yolu=durum, fixture_kok=FIXTURE_KOK)
            return any(a == "G55/a" and e == "KIRMIZI" for a, e, _s, _m in b), (b, h)

    def g55_b_kirli():
        with tempfile.TemporaryDirectory() as td:
            kapilar = os.path.join(td, "KAPILAR.md")
            durum = os.path.join(td, "DURUM.md")
            with open(kapilar, "w", encoding="utf-8") as f:
                f.write("| `yayin-kapisi.py` | ... |\n")
            with open(durum, "w", encoding="utf-8") as f:
                f.write("| `baska-arac.py` | ... |\n")  # M285: DURUM'da YOK
            belge = "`yayin-kapisi.py` 🟢 kosuyor.\n"
            b, h = g55(belge, KOK_VARSAYILAN, kapilar_yolu=kapilar, durum_yolu=durum, fixture_kok=FIXTURE_KOK)
            return any(a == "G55/b" and e == "KIRMIZI" for a, e, _s, _m in b), (b, h)

    def g55_c_kirli():
        with tempfile.TemporaryDirectory() as td:
            gcc = os.path.join(td, "GOREV_CLAUDE_CODE")
            os.makedirs(gcc, exist_ok=True)
            with open(os.path.join(gcc, "GOREV-SAHTE-ornek.md"), "w", encoding="utf-8") as f:
                f.write("## 6. MUTANTLAR\n| id | mutasyon | hedef | beklenen |\n|--|--|--|--|\n| M1 | x | SAHTE/G1 | KIRMIZI |\n")
            belge = "`SAHTE/G99` kimligi anilir.\n"  # M286: G99 tabloda yok
            b, h = g55(belge, td, kapilar_yolu=os.path.join(td, "yok.md"), durum_yolu=os.path.join(td, "yok2.md"), fixture_kok=FIXTURE_KOK)
            return any(a == "G55/c" and e == "KIRMIZI" for a, e, _s, _m in b), (b, h)

    def g55_c_sari_cozulemedi():
        with tempfile.TemporaryDirectory() as td:
            belge = "`YokSpec/G5` kimligi anilir.\n"
            b, h = g55(belge, td, kapilar_yolu=os.path.join(td, "yok.md"), durum_yolu=os.path.join(td, "yok2.md"), fixture_kok=FIXTURE_KOK)
            return any(a == "G55/c" and e == "SARI" for a, e, _s, _m in b), (b, h)

    def g55_d_ortam_hatasi():
        with tempfile.TemporaryDirectory() as td:
            b, h = g55("belge\n", td, fixture_kok=td)  # M287: pozitif kontrol fixture'i yok
            return len(h) > 0, h

    def nk3_yokluk_kutup():
        belge = "W3/G43-G47 implementasyonu YOKTUR.\n"
        b, h = g55(belge, KOK_VARSAYILAN, kapilar_yolu=os.path.join(KOK_VARSAYILAN, "yok.md"),
                   durum_yolu=os.path.join(KOK_VARSAYILAN, "yok2.md"), fixture_kok=FIXTURE_KOK)
        return not any(a in ("G55/a", "G55/b") for a, _e, _s, _m in b), (b, h)

    vaka(23, "G55 temiz (arac hem KAPILAR hem DURUM'da var) -> bulgu yok", g55_temiz)
    vaka(24, "G55/a: durum iddiasi var, KAPILAR.md'de yok -- V6 (M284) -> KIRMIZI", g55_a_kirli_v6)
    vaka(25, "G55/b: arac KAPILAR'da var DURUM'da yok (M285) -> KIRMIZI", g55_b_kirli)
    vaka(26, "G55/c: kapi kimligi spec hedef sutununda yok (M286) -> KIRMIZI", g55_c_kirli)
    vaka(27, "G55/c: spec cozulemedi -> SARI spec-cozulemedi", g55_c_sari_cozulemedi)
    vaka(28, "G55/d: pozitif kontrol fixture'i yok (M287) -> ORTAM HATASI", g55_d_ortam_hatasi)
    vaka(29, "NK3: yoklugun DOGRU beyani -- KUTUP -> SUSMALI", nk3_yokluk_kutup)

    # ---- G56 ----
    def _g56_fixture_kur(td, sozluk_ek=None, defter_ek_sinif=None):
        sozluk = {"girdiler": [
            {"ad": "kor-kapi", "tanim": "test"},
            {"ad": "olcemedigini-sanmak", "tanim": "test"},
        ]}
        if sozluk_ek:
            sozluk["girdiler"].append(sozluk_ek)
        sozluk_yolu = os.path.join(td, "sozluk.json")
        with open(sozluk_yolu, "w", encoding="utf-8") as f:
            json.dump(sozluk, f)
        defter_yolu = os.path.join(td, "defter.jsonl")
        siniflar = defter_ek_sinif if defter_ek_sinif is not None else ["kor-kapi"]
        with open(defter_yolu, "w", encoding="utf-8") as f:
            f.write(json.dumps({"tarih": "2026-01-01", "oturum": 1, "siniflar": siniflar}) + "\n")
        return sozluk_yolu, defter_yolu

    def g56_temiz():
        with tempfile.TemporaryDirectory() as td:
            sozluk_yolu, defter_yolu = _g56_fixture_kur(td)
            b, h = g56(sozluk_yolu, defter_yolu)
            return not b and not h, (b, h)

    def g56_a_kirli():
        with tempfile.TemporaryDirectory() as td:
            sozluk_yolu, defter_yolu = _g56_fixture_kur(td, defter_ek_sinif=["olculemedi-sanmak"])  # M288
            b, h = g56(sozluk_yolu, defter_yolu)
            return any(a == "G56/a" and e == "KIRMIZI" for a, e, _s, _m in b), (b, h)

    def g56_b_kirli():
        with tempfile.TemporaryDirectory() as td:
            sozluk_yolu, defter_yolu = _g56_fixture_kur(td, sozluk_ek={"ad": "kor-kapilar", "tanim": "x"})  # M289
            b, h = g56(sozluk_yolu, defter_yolu)
            return any(a == "G56/b" and e == "KIRMIZI" for a, e, _s, _m in b), (b, h)

    def g56_c_sari():
        with tempfile.TemporaryDirectory() as td:
            sozluk_yolu, defter_yolu = _g56_fixture_kur(td, sozluk_ek={"ad": "yeni-sinif-adi", "tanim": ""})  # M290
            b, h = g56(sozluk_yolu, defter_yolu)
            return any(a == "G56/c" and e == "SARI" for a, e, _s, _m in b), (b, h)

    vaka(30, "G56 temiz (son kayit sozlukte, cift yok, tanim dolu) -> bulgu yok", g56_temiz)
    vaka(31, "G56/a: son kayittaki sinif sozlukte yok (M288) -> KIRMIZI + oneri", g56_a_kirli)
    vaka(32, "G56/b: >=0.82 cift, ayri_tutuldu YOK (M289) -> KIRMIZI", g56_b_kirli)
    vaka(33, "G56/c: bos tanim alani (M290) -> SARI", g56_c_sari)

    # ---- D-K170-2: dizin argumani -> [S0] BICIM ----
    def d2_dizin_argumani():
        return not _bicim_yolu_dosya_mi(KOK_VARSAYILAN), "dizin bir 'dosya' SAYILMAMALI (D-K170-2 M291)"

    vaka(34, "D-K170-2: dizin argumani dosya SAYILMAZ (M291 -- [S0] BICIM temeli)", d2_dizin_argumani)

    # ---- kriter 11: OZ-TEST (K108) ----
    def oz_test_kirmizi():
        with tempfile.TemporaryDirectory() as td:
            kapilar = os.path.join(td, "KAPILAR.md")
            durum = os.path.join(td, "DURUM.md")
            with open(kapilar, "w", encoding="utf-8") as f:
                f.write("| `baska-arac.py` | ... | ... | ... |\n")  # adr-hukum-kapisi.py satiri SILINDI
            with open(durum, "w", encoding="utf-8") as f:
                f.write("| `adr-hukum-kapisi.py` | ... | 36/36 |\n")
            belge = (
                "`adr-hukum-kapisi.py` 🟢 koşuyor. Kimlikleri `ADR0004K/G52`–`ADR0004K/G56`"
                " öneklidir (K108).\n"
            )
            b, h = g55(belge, KOK_VARSAYILAN, kapilar_yolu=kapilar, durum_yolu=durum, fixture_kok=FIXTURE_KOK)
            return any(a == "G55/a" and e == "KIRMIZI" and "adr-hukum-kapisi.py" in m for a, e, _s, m in b), (b, h)

    vaka(35, "OZ-TEST (kriter 11, K108): fixture KAPILAR.md'den arac satiri silinince KIRMIZI", oz_test_kirmizi)

    print("-" * 78)
    gecen = sum(1 for _n, _a, ok, _d in vakalar if ok)
    toplam = len(vakalar)
    print("ALTIN KUME: %d/%d GECTI" % (gecen, toplam))
    return 0 if gecen == toplam else 1


# ============================ MAIN ================================================


def main():
    argv = sys.argv[1:]
    if "--altin-kume" in argv:
        return altin_kume_kos()

    kok = KOK_VARSAYILAN
    belge_yolu = None
    i = 0
    while i < len(argv):
        if argv[i] == "--kok" and i + 1 < len(argv):
            kok = os.path.abspath(argv[i + 1])
            i += 2
            continue
        if not argv[i].startswith("--"):
            belge_yolu = argv[i]
        i += 1

    if belge_yolu is None:
        print("KULLANIM: python araclar/adr-hukum-kapisi.py <belge.md> [--kok .]")
        return EXIT_BICIM

    # D-K170-2: DIZIN alinmaz -- [S0] BICIM.
    if os.path.isdir(belge_yolu):
        print("[S0] BICIM: bu arac BELGE alir, DIZIN almaz -- verilen: %s" % belge_yolu)
        return EXIT_BICIM
    if not os.path.isfile(belge_yolu):
        print("[S0] BICIM: belge bulunamadi: %s" % belge_yolu)
        return EXIT_BICIM

    bulgular, ortam_hatalari = denetle(belge_yolu, kok, fixture_kok=FIXTURE_KOK)
    rapor_yazdir(bulgular, ortam_hatalari)
    kod = cikis_kodu_hesapla(bulgular, ortam_hatalari)
    print("HUKUM: %s (EXIT %d)" % (ETIKETLER[kod], kod))
    return kod


if __name__ == "__main__":
    sys.exit(main())

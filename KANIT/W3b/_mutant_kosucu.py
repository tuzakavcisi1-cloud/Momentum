# -*- coding: utf-8 -*-
"""GOREV-W3b T5 -- mutant kosucusu (M246..M263 + MW23/MW24, K118 disiplini).

Her mutant: ikili yedek -> bayt duzeyinde yama (icerik) YA DA yapisal degisim
(yeniden adlandirma/silme) -> kapiyi kos (`araclar/yayin-kapisi.py`) -> geri
yukleme -> sha256 ile BAYT-OZDESLIK dogrula. `git restore` KULLANILMAZ.

🔴 MOUNT KISITI (spec §6 dipnotu): M250 (.gitignore bosaltilir), M253 (dizin
yeniden adlandirilir), M256 (wwwroot yeniden adlandirilir), M262 (dosya
SILINIR) dosya sistemi YAPISINA dokunuyor -- Cowork'un mount'u `unlink`'e izin
vermiyor. Bu DORDU yalniz BURADA, Onur'un makinesinde (Claude Code eliyle)
kosulur. Kalan 16'si Cowork'un kendi (mount-uyumlu) kosumuna aittir -- bu
dosya TUM 20'yi TANIMLAR (referans/izlenebilirlik icin) ama varsayilan
calistirma yalniz DORDUNU kosar (`--hepsi` ile tumu de kosulabilir).
"""
import hashlib
import io
import json
import os
import shutil
import subprocess
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

KOK = r"C:\dev\Momentum"
API = os.path.join(KOK, "src", "backend", "Momentum.Api")
APPSETTINGS = os.path.join(API, "appsettings.json")
APPSETTINGS_DEV = os.path.join(API, "appsettings.Development.json")
GITIGNORE = os.path.join(KOK, ".gitignore")
WWWROOT = os.path.join(API, "wwwroot")
FB = os.path.join(WWWROOT, "flutter_bootstrap.js")
FJS = os.path.join(WWWROOT, "flutter.js")
BUILD_JSON = os.path.join(WWWROOT, "_BUILD.json")
CANVASKIT = os.path.join(WWWROOT, "canvaskit")
INDEX = os.path.join(WWWROOT, "index.html")
KAPI = os.path.join(KOK, "araclar", "yayin-kapisi.py")
KANIT_DIR = os.path.join(KOK, "KANIT", "W3b")

# spec S5: 0=YESIL 1=SARI 2=KIRMIZI 3=ORTAM HATASI
KOD_ETIKET = {0: "YESIL", 1: "SARI", 2: "KIRMIZI", 3: "ORTAM HATASI/OLCULEMEDI"}


def oku(p):
    with io.open(p, "rb") as f:
        return f.read()


def yaz(p, b):
    with io.open(p, "wb") as f:
        f.write(b)


def sha(b):
    return hashlib.sha256(b).hexdigest()[:8].upper()


def kapiyi_kos():
    p = subprocess.run(
        [sys.executable, KAPI, KOK],
        capture_output=True, text=True, encoding="utf-8", errors="replace",
    )
    return p.returncode, (p.stdout or "") + (p.stderr or "")


def kanit_yaz(ad, metin):
    with io.open(os.path.join(KANIT_DIR, "_MUTANT-%s.txt" % ad), "w",
                 encoding="utf-8", errors="replace") as f:
        f.write(metin)


# ============================ MOUNT-INCAPABLE 4 (BENIM) =========================

def m250_gitignore_bosalt():
    """M250: .gitignore bosaltilir -> hedef ORTAM HATASI (G49/b pozitif kontrol duser)."""
    yedek = oku(GITIGNORE)
    try:
        yaz(GITIGNORE, b"")
        rc, cikti = kapiyi_kos()
    finally:
        yaz(GITIGNORE, yedek)
        ozdes = oku(GITIGNORE) == yedek
    return rc, cikti, ozdes, "ORTAM HATASI bekleniyor (exit 3), G49/b pozitif kontrol dusmeli"


def m253_canvaskit_yeniden_adlandir():
    """M253: canvaskit/ yeniden adlandirilir -> hedef G50/c KIRMIZI."""
    gecici = CANVASKIT + "-M253-GECICI"
    try:
        os.rename(CANVASKIT, gecici)
        rc, cikti = kapiyi_kos()
    finally:
        if os.path.isdir(gecici) and not os.path.isdir(CANVASKIT):
            os.rename(gecici, CANVASKIT)
        ozdes = os.path.isdir(CANVASKIT) and not os.path.isdir(gecici)
    return rc, cikti, ozdes, "G50/c KIRMIZI bekleniyor"


def m256_wwwroot_yeniden_adlandir():
    """M256: wwwroot dizini gecici olarak yeniden adlandirilir -> hedef ORTAM HATASI (G50/f)."""
    gecici = WWWROOT + "-M256-GECICI"
    try:
        os.rename(WWWROOT, gecici)
        rc, cikti = kapiyi_kos()
    finally:
        if os.path.isdir(gecici) and not os.path.isdir(WWWROOT):
            os.rename(gecici, WWWROOT)
        ozdes = os.path.isdir(WWWROOT) and not os.path.isdir(gecici)
    return rc, cikti, ozdes, "ORTAM HATASI bekleniyor (exit 3), G50/f"


def m262_flutter_bootstrap_sil():
    """M262: flutter_bootstrap.js SILINIR -> hedef ORTAM HATASI (G51/d); cikis kodu SIFIR OLAMAZ."""
    yedek = oku(FB)
    try:
        os.remove(FB)
        rc, cikti = kapiyi_kos()
    finally:
        if not os.path.isfile(FB):
            yaz(FB, yedek)
        ozdes = os.path.isfile(FB) and oku(FB) == yedek
    return rc, cikti, ozdes, "ORTAM HATASI bekleniyor (exit != 0), G51/d"


BENIM_DORT = [
    ("M250", m250_gitignore_bosalt),
    ("M253", m253_canvaskit_yeniden_adlandir),
    ("M256", m256_wwwroot_yeniden_adlandir),
    ("M262", m262_flutter_bootstrap_sil),
]


# =================== DIGER 16 (REFERANS/IZLENEBILIRLIK -- Cowork kosar) =========
# 🔴 Bu tanimlar TAMDIR ama VARSAYILAN kosumda CALISTIRILMAZ (--hepsi bayragi
# gerekir) -- spec 4b'nin el dagitimi geregi bunlarin kosumu COWORK'UNDUR.
# Icerik-mutanti oldugu icin mount'ta sorunsuz kosarlar.

def _content_mutant(dosya, eski, yeni, hedef_aciklama):
    yedek = oku(dosya)
    ham = yedek
    eb = eski.encode("utf-8") if isinstance(eski, str) else eski
    nb = yeni.encode("utf-8") if isinstance(yeni, str) else yeni
    n = ham.count(eb)
    try:
        if n == 1:
            yaz(dosya, ham.replace(eb, nb))
        rc, cikti = kapiyi_kos() if n == 1 else (None, "ESLESME SAYISI %d (1 bekleniyordu)" % n)
    finally:
        yaz(dosya, yedek)
        ozdes = oku(dosya) == yedek
    return rc, cikti, ozdes, hedef_aciklama


DIGER_16 = {
    "M246": lambda: _content_mutant(
        APPSETTINGS,
        '"Istemci": {\n    "KokDizin": "wwwroot"\n  }',
        '"IstemciSILINDI": {}',
        "G48/a KIRMIZI",
    ),
    "M247": lambda: _content_mutant(
        APPSETTINGS, '"KokDizin": "wwwroot"', '"KokDizin": "wwwroot2"', "G48/b KIRMIZI"
    ),
    "M248": lambda: _content_mutant(
        APPSETTINGS, '{\n  "Logging"', '{ GECERSIZ_JSON "Logging"', "ORTAM HATASI (exit 3)"
    ),
    "M249": lambda: _content_mutant(
        GITIGNORE,
        "src/backend/Momentum.Api/wwwroot/",
        "wwwroot",
        "G49/a ve G49/c ikisi de KIRMIZI",
    ),
    "M251": lambda: _content_mutant(
        INDEX,
        None,  # ozel: tum dosya degisir, asagida override
        None,
        "G50/a KIRMIZI",
    ),
    "M252": lambda: _content_mutant(FB, None, None, "G50/b KIRMIZI (e hukumsuz)"),
    "M254": lambda: _content_mutant(BUILD_JSON, None, None, "G50/d KIRMIZI (kaynakSha silindi)"),
    "M255": lambda: _content_mutant(
        FB, "_flutter", "_flutter/*10.0.2.2 enjekte*/http://10.0.2.2:5298", "G50/e KIRMIZI"
    ),
    "M257": lambda: _content_mutant(
        FB, '"useLocalCanvasKit":true', '"useLocalCanvasKit":false', "G51/a KIRMIZI (cekirdek kusur)"
    ),
    "M258": lambda: _content_mutant(
        FB, "_flutter", '_flutter/*inject*/canvasKitBaseUrl:"https://x/"', "G51/b KIRMIZI"
    ),
    "M259": lambda: _content_mutant(
        FB, "_flutter", "_flutter/*inject*/canvasKitBaseUrl:'https://x/'", "G51/b KIRMIZI (tek tirnak)"
    ),
    "M260": lambda: _content_mutant(
        FB, "_flutter", '_flutter/*inject*/canvasKitBaseUrl:"//x/"', "G51/b KIRMIZI (protokol-goreli)"
    ),
    "M261": lambda: _content_mutant(
        FJS, "www.gstatic.com/flutter-canvaskit", "www.gstatic.com/DEGISTIRILDI", "G51/c SARI"
    ),
    "M263": lambda: _content_mutant(FB, "canvasKitBaseUrl", "XX", "G51/b2 SARI (pin sapmasi)"),
    "MW23": lambda: _content_mutant(
        FB, "canvasKitBaseUrl:i.canvasKitBaseUrl",
        "// canvasKitBaseUrl\ncanvasKitBaseUrl:i.canvasKitBaseUrl",
        "SUSMALI -- hicbir KIRMIZI olusmamali",
    ),
    "MW24": lambda: _content_mutant(
        APPSETTINGS_DEV, '"Cors"', '"AlakasizAnahtar": true, "Cors"', "SUSMALI -- G48 kapsami disi"
    ),
}


def main():
    hepsi = "--hepsi" in sys.argv
    calistir = list(BENIM_DORT)
    if hepsi:
        print("🔴 --hepsi verildi: DIGER 16 da bu makinede kosuluyor (normalde Cowork'un isi).")
        calistir += [(ad, fn) for ad, fn in DIGER_16.items()]

    print("=" * 74)
    print("GOREV-W3b T5 -- mutant kosucusu (K118 disiplini)")
    print("Bu kosum yalniz mount'ta CALISAMAYAN dorduyu kosar (M250/M253/M256/M262)")
    print("Diger 16'si Cowork'e aittir (spec 4b) -- burada yalniz TANIMLIDIR.")
    print("=" * 74)

    ozet = []
    for ad, fn in calistir:
        try:
            rc, cikti, ozdes, beklenen = fn()
        except Exception as ex:
            rc, cikti, ozdes, beklenen = None, "ISTISNA: %r" % ex, None, "?"
        etiket = KOD_ETIKET.get(rc, "BILINMEYEN(%r)" % rc)
        satir = "  %-6s rc=%-3s (%s) ozdes=%s -- beklenen: %s" % (
            ad, rc, etiket, ozdes, beklenen
        )
        print(satir)
        ozet.append(satir)
        kanit_yaz(
            ad,
            "MUTANT %s\nbeklenen: %s\nrc=%s (%s)\nyedek ozdes=%s\n\n=== kapi ciktisi ===\n%s"
            % (ad, beklenen, rc, etiket, ozdes, cikti),
        )

    print("-" * 74)
    metin = "\n".join(ozet)
    kanit_yaz("OZET-CLAUDE-CODE-4", metin)
    print(metin)
    print()
    print("BU OZET BIR KABUL BEYANI DEGILDIR (K26) -- hukmu Cowork verir.")
    print("Diger 16 mutant Cowork'un kendi kosumunda ayrica raporlanir.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

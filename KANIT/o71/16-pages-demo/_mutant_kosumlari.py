# -*- coding: utf-8 -*-
"""o71 PAGES DEMOSU SS3.2 -- alti kosum (pozitif + M-P1..M-P5). HAM CIKTI
uretir, HUKUM VERMEZ (K26), DESEN ONARMAZ (K34-f). KANIT/o71/16-pages-demo/
altinda -- araclar/'a KONULMADI.
"""
import io
import os
import subprocess
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

FLUTTER = r"C:\src\flutter\bin\flutter.bat"
KOK = r"C:\dev\Momentum"
ISTEMCI = os.path.join(KOK, "src", "client")
BUILD_WEB = os.path.join(ISTEMCI, "build", "web")
GATE = os.path.join(KOK, "KANIT", "o71", "16-pages-demo", "kapi-esdeger.py")
BASE_HREF = "/Momentum/"
KANIT_YOLU = os.path.join(KOK, "KANIT", "o71", "16-pages-demo", "01-mutant-kosumlari.txt")


def calistir(argv, cwd=None, zaman_asimi=240):
    try:
        r = subprocess.run(argv, cwd=cwd, capture_output=True, text=True,
                            encoding="utf-8", errors="replace", timeout=zaman_asimi)
        return r.returncode, (r.stdout or "") + (r.stderr or "")
    except subprocess.TimeoutExpired as e:
        return -1, "TIMEOUT: %r" % e


def gate_kos():
    return calistir([sys.executable, GATE, BUILD_WEB, BASE_HREF])


kayitlar = []


def kayit(ad, komut_str, kod, cikti):
    kayitlar.append((ad, komut_str, kod, cikti))
    print("=== %s === exit=%s" % (ad, kod))


# 1) POZITIF KOSUM -- SS3.0'daki bayrakli build uzerinde
kod, cikti = gate_kos()
kayit("POZITIF", "python kapi-esdeger.py \"%s\" %s" % (BUILD_WEB, BASE_HREF), kod, cikti)

# 2) M-P3 -- build/web'i GECICI yeniden adlandir
yedek1 = BUILD_WEB + "_MP3_yedek"
os.rename(BUILD_WEB, yedek1)
kod, cikti = gate_kos()
kayit("M-P3", "[build/web -> build/web_MP3_yedek yeniden adlandirildi] python kapi-esdeger.py \"%s\" %s" % (BUILD_WEB, BASE_HREF), kod, cikti)
os.rename(yedek1, BUILD_WEB)  # GERI AL

# 3) M-P4 -- BOS build/web dizini
yedek2 = BUILD_WEB + "_MP4_yedek"
os.rename(BUILD_WEB, yedek2)
os.makedirs(BUILD_WEB)
kod, cikti = gate_kos()
kayit("M-P4", "[build/web -> BOS dizin] python kapi-esdeger.py \"%s\" %s" % (BUILD_WEB, BASE_HREF), kod, cikti)
os.rmdir(BUILD_WEB)
os.rename(yedek2, BUILD_WEB)  # GERI AL

# 4) M-P5 -- NUL bayti TASIYAN bir dosyaya CDN dizgesini enjekte et
enjekte_yol = os.path.join(BUILD_WEB, "_MP5_enjekte.bin")
with open(enjekte_yol, "wb") as f:
    f.write(b"\x00\x00" + b"gstatic.com/flutter-canvaskit" + b"\x00\x00")
kod, cikti = gate_kos()
kayit("M-P5", "[build/web/_MP5_enjekte.bin -- NUL baytli, CDN dizgesi enjekte edildi] python kapi-esdeger.py \"%s\" %s" % (BUILD_WEB, BASE_HREF), kod, cikti)
os.remove(enjekte_yol)  # GERI AL

# 5) M-P1 -- --no-web-resources-cdn OLMADAN build, sonra gate
komut1 = [FLUTTER, "build", "web", "--release", "--no-wasm-dry-run", "--base-href", BASE_HREF]
kod_b1, cikti_b1 = calistir(komut1, cwd=ISTEMCI)
kod_g1, cikti_g1 = gate_kos()
birlesik1 = "BUILD exit=%s:\n%s\n\nGATE exit=%s:\n%s" % (kod_b1, cikti_b1, kod_g1, cikti_g1)
kayit("M-P1", " ".join(komut1) + "  ---sonra---  python kapi-esdeger.py \"%s\" %s" % (BUILD_WEB, BASE_HREF), kod_g1, birlesik1)

# 6) M-P2 -- --base-href OLMADAN build, sonra gate
komut2 = [FLUTTER, "build", "web", "--release", "--no-web-resources-cdn", "--no-wasm-dry-run"]
kod_b2, cikti_b2 = calistir(komut2, cwd=ISTEMCI)
kod_g2, cikti_g2 = gate_kos()
birlesik2 = "BUILD exit=%s:\n%s\n\nGATE exit=%s:\n%s" % (kod_b2, cikti_b2, kod_g2, cikti_g2)
kayit("M-P2", " ".join(komut2) + "  ---sonra---  python kapi-esdeger.py \"%s\" %s" % (BUILD_WEB, BASE_HREF), kod_g2, birlesik2)

# 7) SON -- temiz bayrakli build YENIDEN kosulur (restore)
komut3 = [FLUTTER, "build", "web", "--release", "--no-web-resources-cdn", "--no-wasm-dry-run", "--base-href", BASE_HREF]
kod_b3, cikti_b3 = calistir(komut3, cwd=ISTEMCI)
kod_g3, cikti_g3 = gate_kos()
birlesik3 = "BUILD exit=%s:\n%s\n\nGATE exit=%s:\n%s" % (kod_b3, cikti_b3, kod_g3, cikti_g3)
kayit("TEMIZ-SON-RESTORE", " ".join(komut3) + "  ---sonra---  python kapi-esdeger.py \"%s\" %s" % (BUILD_WEB, BASE_HREF), kod_g3, birlesik3)


# ============================ KANIT YAZ (HAM, YORUMSUZ) ============================
satirlar = [
    "Yerel olcum grep'i degil semantik esdegeri bir Python taramasini olctu.",
    "CI'daki grep ayagi yerelde OLCULEMEDI; tek kaniti ilk CI kosumunun logudur.",
    "",
    "HUKUM YOK -- ham cikti (K26/K34-f). Alti kosum: POZITIF, M-P3, M-P4, M-P5, M-P1, M-P2.",
    "(TEMIZ-SON-RESTORE yedinci kayittir -- mutant DEGIL, geri alma dogrulamasidir.)",
    "",
]
for ad, komut_str, kod, cikti in kayitlar:
    satirlar.append("=" * 78)
    satirlar.append("KOSUM: %s" % ad)
    satirlar.append("KOMUT: %s" % komut_str)
    satirlar.append("CIKIS KODU: %s" % kod)
    satirlar.append("STDOUT+STDERR:")
    satirlar.append(cikti.replace("\r\n", "\n").replace("\r", "\n"))
    satirlar.append("")

with io.open(KANIT_YOLU, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(satirlar))

print("\nYAZILDI:", KANIT_YOLU)

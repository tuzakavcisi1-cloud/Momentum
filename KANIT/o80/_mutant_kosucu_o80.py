# -*- coding: utf-8 -*-
"""IS-EMRI-o80 -- bos senkron rozeti mutantlari. Referans koşucu:
KANIT/A11/_mutant_kosucu.py (ORTAM.md: git restore YASAK, core.autocrlf
bayt-ozdesligi kor kilar). Ikili yedek -> BAYT duzeyinde yama -> kapiyi kos
-> yedekten geri yaz -> sha256 ile ozdeslik olc.
"""
import hashlib
import io
import os
import subprocess
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

KOK = r"C:\dev\Momentum"
ISTEMCI = os.path.join(KOK, "src", "client")
FLUTTER = r"C:\src\flutter\bin\flutter.bat"
KANIT = os.path.join(KOK, "KANIT", "o80")

GS = os.path.join(ISTEMCI, "lib", "sunum", "gorev_satiri.dart")
TEST_KOMUT = [FLUTTER, "test", "test/gorev_satiri_rozet_genislik_test.dart"]

ORTAM = dict(os.environ)
ORTAM["PROGRAMFILES(X86)"] = r"C:\Program Files (x86)"


def oku(p):
    with io.open(p, "rb") as f:
        return f.read()


def yaz(p, b):
    with io.open(p, "wb") as f:
        f.write(b)


def sha(b):
    return hashlib.sha256(b).hexdigest()[:8].upper()


def nl(ham, s):
    return s.replace("\n", "\r\n") if b"\r\n" in ham else s


def kos():
    p = subprocess.run(TEST_KOMUT, cwd=ISTEMCI, capture_output=True, text=True,
                        encoding="utf-8", errors="replace", env=ORTAM, timeout=180)
    return p.returncode, ((p.stdout or "") + (p.stderr or ""))


ESKI_TANIM = "    final rozetCiziyor = SenkronRozeti.metinIcin(senkronDurumu) != null;\n"
ESKI_TERNARY = (
    "      rozetCiziyor\n"
    "          ? Flexible(child: SenkronRozeti(durum: senkronDurumu))\n"
    "          : SenkronRozeti(durum: senkronDurumu),\n"
)

# ============================ MUTANT TANIMLARI ================================
M = []

M.append(("M-o80-1", "kosul kaldirilir (rozet HER durumda Flexible ile eklenir) -> eski kusur geri gelir",
    ESKI_TERNARY,
    "      Flexible(child: SenkronRozeti(durum: senkronDurumu)),\n"))

M.append(("M-o80-2", "kosul ters cevrilir (dallar takas edilir -- yalniz BOSKEN Flexible)",
    ESKI_TERNARY,
    "      rozetCiziyor\n"
    "          ? SenkronRozeti(durum: senkronDurumu)\n"
    "          : Flexible(child: SenkronRozeti(durum: senkronDurumu)),\n"))

M.append(("M-o80-3", "kosul senkronize yerine baska bir duruma baglanir (yerel)",
    ESKI_TANIM,
    "    final rozetCiziyor = senkronDurumu != SenkronDurumTuru.yerel;\n"))


# ================================ KOSUM =======================================

def kanit_yaz(ad, metin):
    with io.open(os.path.join(KANIT, "03-MUTANT-%s.txt" % ad), "w",
                 encoding="utf-8", errors="replace", newline="\n") as f:
        f.write(metin.replace("\r\n", "\n").replace("\r", "\n"))


def son_satirlar(cikti, n=25):
    s = [x for x in cikti.replace("\r", "").split("\n") if x.strip()]
    return "\n".join(s[-n:])


def main():
    os.makedirs(KANIT, exist_ok=True)
    baslangic = oku(GS)
    ozet = []
    ozet.append("IS-EMRI-o80 -- M-o80-1/2/3 mutant kosumu (Claude Code)")
    ozet.append("  TABAN sha8=%s %7d b  gorev_satiri.dart" % (sha(baslangic), len(baslangic)))

    # --- 0) TEMIZ TABAN: yeni test dosyasi EXIT 0 olmali ---
    rc, cikti = kos()
    ozet.append("  TEMIZ-ONCE EXIT=%d" % rc)
    kanit_yaz("00-TEMIZ-ONCE", "EXIT=%d\n\n%s" % (rc, cikti))
    if rc != 0:
        ozet.append("  [DUR] temiz taban KIRMIZI -- mutant kosumu BASLAMADI.")
        print("\n".join(ozet))
        return 3

    # --- 1) MUTANTLAR ---
    gecen = 0
    for ad, aciklama, eski, yeni in M:
        yedek = oku(GS)
        eb = nl(yedek, eski).encode("utf-8")
        nb = nl(yedek, yeni).encode("utf-8")
        n = yedek.count(eb)
        hata = None
        rc_m, cikti_m = None, ""
        if n != 1:
            hata = "ESLESME SAYISI %d (1 BEKLENIR)" % n
        else:
            yaz(GS, yedek.replace(eb, nb))
            rc_m, cikti_m = kos()

        # --- GERI ALMA + BAYT-OZDESLIK ---
        yaz(GS, yedek)
        simdi = oku(GS)
        ozdes = simdi == yedek
        if not ozdes:
            hata = (hata or "") + " GERI-ALMA-BOZUK"

        if hata:
            hukum = "ORTAM HATASI: %s" % hata
            ok = False
        else:
            ok = rc_m != 0
            hukum = "KIRMIZI (beklenen)" if ok else "HAYATTA KALDI (KUSUR)"
        if ok:
            gecen += 1

        satir = "  %-9s %-58s eslesme=%s ozdes=%s exit=%s -> %s" % (
            ad, aciklama, n, ozdes, rc_m, hukum)
        ozet.append(satir)
        print(satir)
        sys.stdout.flush()

        govde = ["MUTANT %s -- %s" % (ad, aciklama), "dosya: %s" % GS,
                 "eslesme sayisi: %d" % n, "geri alma bayt-ozdes: %s (sha8=%s)" % (ozdes, sha(simdi)),
                 "HUKUM: %s" % hukum, "", "=== test EXIT=%r ===" % rc_m, son_satirlar(cikti_m, 30)]
        kanit_yaz(ad, "\n".join(govde))

    # --- 2) TEMIZ KOSUM TEKRAR ---
    simdi = oku(GS)
    ozet.append("  SON sha8=%s %7d b  gorev_satiri.dart  ozdes=%s" % (sha(simdi), len(simdi), simdi == baslangic))
    rc, cikti = kos()
    ozet.append("  TEMIZ-SONRA EXIT=%d" % rc)
    kanit_yaz("99-TEMIZ-SONRA", "EXIT=%d\n\n%s" % (rc, cikti))

    ozet.append("  ISIRAN MUTANT: %d/%d" % (gecen, len(M)))
    metin = "\n".join(ozet)
    kanit_yaz("OZET", metin)
    print("\n" + metin)
    return 0 if gecen == len(M) else 1


if __name__ == "__main__":
    sys.exit(main())

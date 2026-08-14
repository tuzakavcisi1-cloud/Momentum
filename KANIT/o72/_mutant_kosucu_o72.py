# -*- coding: utf-8 -*-
"""IS-EMRI-o72 -- SIL EYLEMI mutantlari (M-o72-1/2/3). Referans koşucu:
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
KANIT = os.path.join(KOK, "KANIT", "o72")

GS = os.path.join(ISTEMCI, "lib", "sunum", "gorev_satiri.dart")

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


def kos(cmd, cwd):
    p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True,
                        encoding="utf-8", errors="replace", env=ORTAM, timeout=180)
    return p.returncode, ((p.stdout or "") + (p.stderr or ""))


T2 = ("T2", [FLUTTER, "test", "test/gorev_satiri_silme_test.dart", "--plain-name", "T2"], ISTEMCI)
T3 = ("T3", [FLUTTER, "test", "test/gorev_satiri_silme_test.dart", "--plain-name", "T3"], ISTEMCI)
T4 = ("T4", [FLUTTER, "test", "test/g14_dikey_donus_kapisi_test.dart", "--plain-name", "onSil"], ISTEMCI)

# ============================ MUTANT TANIMLARI ================================
M = []

M.append(("M-o72-1", "tooltip satirini sil -> T2 isirmali", GS,
    "      tooltip: Metinler.gorevSil,\n",
    "",
    [T2]))

M.append(("M-o72-2", "D4 onSil terimini sabitlerden cikar -> T4 isirmali", GS,
    "        (onBaslikDuzenlendi != null ? MOlcu.dokunmaHedefi + MBosluk.xs : 0) +\n"
    "        // IS-EMRI-o72 D4: silme ikonu da `_rozetler()`e eklenir -- BURAYA\n"
    "        // eklenmezse OLCULEN duzen (bu formul) ile CIZILEN duzen sessizce\n"
    "        // ayrisir (M77b sinifi, ayni gerekce onBaslikDuzenlendi icin\n"
    "        // yukarida yazildigi gibi).\n"
    "        (onSil != null ? MOlcu.dokunmaHedefi + MBosluk.xs : 0);\n",
    "        (onBaslikDuzenlendi != null ? MOlcu.dokunmaHedefi + MBosluk.xs : 0);\n",
    [T4]))

M.append(("M-o72-3", "iptal yolunu pop(true) yap -> T3 isirmali", GS,
    "            onPressed: () => Navigator.of(dialogBaglami).pop(),\n",
    "            onPressed: () => Navigator.of(dialogBaglami).pop(true),\n",
    [T3]))


# ================================ KOSUM =======================================

def kanit_yaz(ad, metin):
    with io.open(os.path.join(KANIT, "03-MUTANT-%s.txt" % ad), "w",
                 encoding="utf-8", errors="replace", newline="\n") as f:
        f.write(metin.replace("\r\n", "\n").replace("\r", "\n"))


def son_satirlar(cikti, n=20):
    s = [x for x in cikti.replace("\r", "").split("\n") if x.strip()]
    return "\n".join(s[-n:])


def main():
    os.makedirs(KANIT, exist_ok=True)
    baslangic = oku(GS)
    ozet = []
    ozet.append("IS-EMRI-o72 -- M-o72-1/2/3 mutant kosumu (Claude Code)")
    ozet.append("  TABAN sha8=%s %7d b  gorev_satiri.dart" % (sha(baslangic), len(baslangic)))

    # --- 0) TEMIZ TABAN: T2/T3/T4 uc de EXIT 0 olmali ---
    for e, cmd, cwd in (T2, T3, T4):
        rc, cikti = kos(cmd, cwd)
        ozet.append("  TEMIZ-ONCE %-4s EXIT=%d" % (e, rc))
        kanit_yaz("00-TEMIZ-ONCE-" + e, "EXIT=%d\n\n%s" % (rc, cikti))
        if rc != 0:
            ozet.append("  [DUR] temiz taban KIRMIZI (%s) -- mutant kosumu BASLAMADI." % e)
            print("\n".join(ozet))
            return 3

    # --- 1) MUTANTLAR ---
    gecen = 0
    for ad, kapi, yol, eski, yeni, komutlar in M:
        yedek = oku(yol)
        eb = nl(yedek, eski).encode("utf-8")
        nb = nl(yedek, yeni).encode("utf-8")
        n = yedek.count(eb)
        hata = None
        cikislar = []
        if n != 1:
            hata = "ESLESME SAYISI %d (1 BEKLENIR)" % n
        else:
            yaz(yol, yedek.replace(eb, nb))
            for e, cmd, cwd in komutlar:
                rc, cikti = kos(cmd, cwd)
                cikislar.append((e, rc, cikti))

        # --- GERI ALMA + BAYT-OZDESLIK ---
        yaz(yol, yedek)
        simdi = oku(yol)
        ozdes = simdi == yedek
        if not ozdes:
            hata = (hata or "") + " GERI-ALMA-BOZUK"

        if hata:
            hukum = "ORTAM HATASI: %s" % hata
            ok = False
        else:
            ok = all(rc != 0 for _e, rc, _c in cikislar) and len(cikislar) > 0
            hukum = "KIRMIZI (beklenen)" if ok else "HAYATTA KALDI (KUSUR)"
        if ok:
            gecen += 1

        satir = "  %-9s %-45s eslesme=%s ozdes=%s %s -> %s" % (
            ad, kapi, n, ozdes,
            " ".join("%s=%s" % (e, rc) for e, rc, _c in cikislar) or "-", hukum)
        ozet.append(satir)
        print(satir)
        sys.stdout.flush()

        govde = ["MUTANT %s -- %s" % (ad, kapi), "dosya: %s" % yol,
                 "eslesme sayisi: %d" % n, "geri alma bayt-ozdes: %s (sha8=%s)" % (ozdes, sha(simdi)),
                 "HUKUM: %s" % hukum, ""]
        for e, rc, c in cikislar:
            govde.append("=== %s EXIT=%d ===" % (e, rc))
            govde.append(son_satirlar(c, 30))
            govde.append("")
        kanit_yaz(ad, "\n".join(govde))

    # --- 2) TEMIZ KOSUM TEKRAR ---
    simdi = oku(GS)
    ozet.append("  SON sha8=%s %7d b  gorev_satiri.dart  ozdes=%s" % (sha(simdi), len(simdi), simdi == baslangic))
    for e, cmd, cwd in (T2, T3, T4):
        rc, cikti = kos(cmd, cwd)
        ozet.append("  TEMIZ-SONRA %-4s EXIT=%d" % (e, rc))
        kanit_yaz("99-TEMIZ-SONRA-" + e, "EXIT=%d\n\n%s" % (rc, cikti))

    ozet.append("  ISIRAN MUTANT: %d/%d" % (gecen, len(M)))
    metin = "\n".join(ozet)
    kanit_yaz("OZET", metin)
    print("\n" + metin)
    return 0 if gecen == len(M) else 1


if __name__ == "__main__":
    sys.exit(main())

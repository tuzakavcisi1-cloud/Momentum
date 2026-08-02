# -*- coding: utf-8 -*-
"""A11 KABUL adim 5 -- M139..M155 mutant kosucusu (Cowork'un KENDI kosumu, K26).

Her mutant: ikili yedek -> yama uygula -> kapiyi kos -> yedekten GERI YAZ ->
sha256 ile BAYT-OZDESLIK dogrula. `git restore` KULLANILMAZ (ORTAM.md:
core.autocrlf aktif, restore bayt-ozdes DEGIL).
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
KANIT = os.path.join(KOK, "KANIT", "A11")
YY_YOL = os.path.join(KOK, "araclar", "yoklama-yasagi-kapisi.py")

SD = os.path.join(ISTEMCI, "lib", "veri", "senkron_dongusu.dart")
IY = os.path.join(ISTEMCI, "lib", "veri", "itme_yeniden_deneme.dart")
YY = YY_YOL

ORTAM = dict(os.environ)
ORTAM["PROGRAMFILES(X86)"] = r"C:\Program Files (x86)"

DART = ("DART", ["cmd", "/c", FLUTTER, "test", "test/ag_donus_itmesi_test.dart"], ISTEMCI)
ALTIN = ("ALTIN", [sys.executable, YY_YOL, "--altin-kume"], KOK)
PROJE = ("PROJE", [sys.executable, YY_YOL, "."], KOK)


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
                       encoding="utf-8", errors="replace", env=ORTAM)
    return p.returncode, ((p.stdout or "") + (p.stderr or ""))


# ============================ MUTANT TANIMLARI ================================
# (ad, kapi, [(dosya, eski, yeni)], [komut])

M = []

M.append(("M139", "A11/G22/a", [(SD,
    "            _itmeYenidenDeneme.planla();\n",
    "            // MUTANT M139: planlama KALDIRILDI\n")], [DART]))

M.append(("M140", "A11/G22/b", [(IY,
    "    Duration(seconds: 2),\n    Duration(seconds: 5),\n"
    "    Duration(seconds: 15),\n    Duration(seconds: 30),\n"
    "    Duration(seconds: 60),\n",
    "    Duration(seconds: 2),\n    Duration(seconds: 2),\n"
    "    Duration(seconds: 2),\n    Duration(seconds: 2),\n"
    "    Duration(seconds: 2),\n")], [DART]))

M.append(("M141", "A11/G22/c2", [(IY,
    "  void sifirla() {\n    _zamanlayici?.cancel();\n"
    "    _zamanlayici = null;\n    _indeks = 0;\n  }\n",
    "  void sifirla() {\n    _indeks = 0; // MUTANT M141: iptal YOK\n  }\n")], [DART]))

M.append(("M142", "A11/G22/m", [(SD,
    "          if (kuyrugaBak) {\n"
    "            // GOREV-A11 D-A11-2/3: basarili itme -- retry cizelgesi SIFIRLANIR.\n"
    "            _itmeYenidenDeneme.sifirla();\n          }\n",
    "          if (kuyrugaBak) {\n            // MUTANT M142: sifirla() KALDIRILDI\n          }\n")], [DART]))

M.append(("M143", "A11/G22/e", [(IY,
    "  void planla() {\n    _zamanlayici?.cancel();\n",
    "  void planla() {\n    // MUTANT M143: teklik kontrolu KALDIRILDI\n")], [DART]))

M.append(("M144", "A11/G22/f", [(SD,
    "    } else {\n      await _db.transaction(() async {\n",
    "    } else {\n      if (itmeBaglamindaMi && gonderilenler.isNotEmpty) {\n"
    "        _itmeYenidenDeneme.planla(); // MUTANT M144: 400 de yeniden denenir\n      }\n"
    "      await _db.transaction(() async {\n")], [DART]))

M.append(("M145", "A11/G22/h + A11/G23/f", [
    (IY, "  final Future<void> Function() _turCalistir;\n",
         "  final Future<void> Function() _cekmeTuruCalistir; // MUTANT M145\n"),
    (IY, "    : _turCalistir = turCalistir,\n", "    : _cekmeTuruCalistir = turCalistir,\n"),
    (IY, "      unawaited(_turCalistir());\n", "      unawaited(_cekmeTuruCalistir());\n"),
    (SD, "        return turCalistir();\n", "        return cekmeTuruCalistir(); // MUTANT M145\n"),
], [DART, PROJE]))

M.append(("M146", "A11/G23/a,b", [(YY,
    "        for idx in future_delayed_cagrilari_bul(temiz_metin):\n"
    "            sembol = _kapsayan_bildirim(temiz_metin, idx)\n"
    "            govde = kapsayan_fonksiyon_govdesi_bul(temiz_metin, idx)\n"
    "            _govde_kuralini_uygula(bulgular, yol, temel, sembol, govde, \"Future.delayed\")\n",
    "        # MUTANT M146: Future.delayed ayagi CIKARILDI\n")], [ALTIN]))

M.append(("M147", "A11/G23/h", [(YY,
    "            if (temel, sembol) not in BEYAZ_LISTE_SEMBOL:\n",
    "            if temel not in set(p[0] for p in BEYAZ_LISTE_SEMBOL):  # MUTANT M147\n")], [ALTIN]))

M.append(("M148", "A11/G22/i", [(IY,
    "  void durdur() {\n    _zamanlayici?.cancel();\n    _zamanlayici = null;\n  }\n",
    "  void durdur() {\n    // MUTANT M148: iptal YOK\n  }\n")], [DART]))

M.append(("M149", "A11/G23/c,d", [(YY,
    "kapsayan_fonksiyon_govdesi_bul(temiz_metin, idx)",
    "temiz_metin[idx:temiz_metin.find(\")\", idx) + 1]")], [ALTIN]))

M.append(("M150", "A11/G23/g", [(YY,
    "    \"cekmeTuruCalistir\", \"turCalistir\", \"SenkronAgi\", \"_yuvarlakDongusu\",\n",
    "    \"cekmeTuruCalistir\", \"turCalistir\", \"SenkronAgi\",  # MUTANT M150\n")], [ALTIN]))

M.append(("M151", "A11/G24/c", [(YY,
    "    (\"itme_yeniden_deneme.dart\", \"ItmeYenidenDeneme\"),   # [D-A11-5/K116] itme geri cekilmeli retry\n}",
    "    (\"itme_yeniden_deneme.dart\", \"ItmeYenidenDeneme\"),   # [D-A11-5/K116] itme geri cekilmeli retry\n"
    "    (\"senkron_dongusu.dart\", \"SenkronDongusu\"),          # MUTANT M151\n}")], [ALTIN]))

M.append(("M152", "A11/G22/j", [(SD,
    "            basariRozeti: 'cevrimdisi',\n            sayaciArtir: false,\n          );\n",
    "            basariRozeti: 'cevrimdisi',\n            sayaciArtir: true, // MUTANT M152\n          );\n")], [DART]))

M.append(("M153", "A11/G22/k", [(SD,
    "        sayaciArtir: true,\n", "        sayaciArtir: false, // MUTANT M153\n")], [DART]))

M.append(("M154", "A11/G22/l", [(SD,
    "    if (!yenidenDenemeIcindenGeldi) {\n      _itmeYenidenDeneme.sifirla();\n    }\n",
    "    if (!yenidenDenemeIcindenGeldi) {\n      // MUTANT M154: sifirlama KALDIRILDI\n    }\n")], [DART]))

M.append(("M155", "A11/G23/i,j", [(YY,
    "            _govde_kuralini_uygula(bulgular, yol, temel, sembol, govde, \"Future.delayed\")\n",
    "            bulgular.append((\"Y1\", yol, \"MUTANT M155: her Future.delayed isirilir\"))\n")], [ALTIN]))


# ================================ KOSUM =======================================

def kanit_yaz(ad, metin):
    with io.open(os.path.join(KANIT, "03-MUTANT-%s.txt" % ad), "w",
                 encoding="utf-8", errors="replace") as f:
        f.write(metin)


def son_satirlar(cikti, n=14):
    s = [x for x in cikti.replace("\r", "").split("\n") if x.strip()]
    return "\n".join(s[-n:])


def main():
    baslangic = {p: oku(p) for p in (SD, IY, YY)}
    ozet = []
    ozet.append("A11 KABUL adim 5 -- M139..M155 mutant kosumu (Cowork, K26)")
    for p, b in baslangic.items():
        ozet.append("  TABAN sha8=%s %7d b  %s" % (sha(b), len(b), os.path.basename(p)))

    # --- 0) TEMIZ TABAN: uc kapi da EXIT 0 olmali ---
    for e, cmd, cwd in (DART, ALTIN, PROJE):
        rc, cikti = kos(cmd, cwd)
        ozet.append("  TEMIZ-ONCE %-6s EXIT=%d" % (e, rc))
        kanit_yaz("00-TEMIZ-ONCE-" + e, "EXIT=%d\n\n%s" % (rc, cikti))
        if rc != 0:
            ozet.append("  [DUR] temiz taban KIRMIZI -- mutant kosumu BASLAMADI.")
            print("\n".join(ozet))
            return 3

    # --- 1) MUTANTLAR ---
    gecen = 0
    for ad, kapi, duzenlemeler, komutlar in M:
        yedek = {}
        for yol, _e, _y in duzenlemeler:
            yedek.setdefault(yol, oku(yol))
        gecici = dict(yedek)
        hata = None
        eslesmeler = []
        for yol, eski, yeni in duzenlemeler:
            ham = gecici[yol]
            eb = nl(ham, eski).encode("utf-8")
            nb = nl(ham, yeni).encode("utf-8")
            n = ham.count(eb)
            eslesmeler.append("%s:%d" % (os.path.basename(yol), n))
            if n == 0:
                hata = "ESLESME YOK -- %s" % os.path.basename(yol)
                break
            gecici[yol] = ham.replace(eb, nb)

        cikislar = []
        if hata is None:
            for yol, b in gecici.items():
                yaz(yol, b)
            for e, cmd, cwd in komutlar:
                rc, cikti = kos(cmd, cwd)
                cikislar.append((e, rc, cikti))

        # --- GERI ALMA + BAYT-OZDESLIK ---
        geri = []
        for yol, b in yedek.items():
            yaz(yol, b)
            simdi = oku(yol)
            ozdes = (simdi == b)
            geri.append("%s sha8=%s ozdes=%s" % (os.path.basename(yol), sha(simdi), ozdes))
            if not ozdes:
                hata = (hata or "") + " GERI-ALMA-BOZUK:%s" % yol

        if hata:
            hukum = "ORTAM HATASI: %s" % hata
            ok = False
        else:
            ok = all(rc != 0 for _e, rc, _c in cikislar) and len(cikislar) > 0
            hukum = "KIRMIZI (beklenen)" if ok else "HAYATTA KALDI (KUSUR)"
        if ok:
            gecen += 1

        satir = "  %-5s %-22s eslesme[%s] %s -> %s" % (
            ad, kapi, ",".join(eslesmeler),
            " ".join("%s=%s" % (e, rc) for e, rc, _c in cikislar) or "-", hukum)
        ozet.append(satir)
        print(satir)
        sys.stdout.flush()

        govde = ["MUTANT %s -- kapi %s" % (ad, kapi), "eslesme: %s" % ",".join(eslesmeler),
                 "geri alma: %s" % " | ".join(geri), "HUKUM: %s" % hukum, ""]
        for e, rc, c in cikislar:
            govde.append("=== %s EXIT=%d ===" % (e, rc))
            govde.append(son_satirlar(c, 30))
            govde.append("")
        kanit_yaz(ad, "\n".join(govde))

    # --- 2) TEMIZ KOSUM TEKRAR ---
    for p, b in baslangic.items():
        simdi = oku(p)
        ozet.append("  SON   sha8=%s %7d b  %s  ozdes=%s"
                    % (sha(simdi), len(simdi), os.path.basename(p), simdi == b))
    for e, cmd, cwd in (DART, ALTIN, PROJE):
        rc, cikti = kos(cmd, cwd)
        ozet.append("  TEMIZ-SONRA %-6s EXIT=%d" % (e, rc))
        kanit_yaz("99-TEMIZ-SONRA-" + e, "EXIT=%d\n\n%s" % (rc, cikti))

    ozet.append("  ISIRAN MUTANT: %d/%d" % (gecen, len(M)))
    metin = "\n".join(ozet)
    kanit_yaz("OZET", metin)
    print("\n" + metin)
    return 0 if gecen == len(M) else 1


if __name__ == "__main__":
    sys.exit(main())

# -*- coding: utf-8 -*-
"""COWORK BAGIMSIZ MUTANT KOSUMU -- GOREV-A12 kriter 2 (M156-M161).

ORTAM.md recetesi (oturum 50'de 17 mutantta kostu):
  ikili yedek -> BAYT yamasi -> kapiyi kos -> YEDEKTEN geri yaz -> sha256 ile ozdeslik OLC.
git restore YASAK: core.autocrlf onu bayt-ozdeslik icin KOR kilar.

Her mutant altin kumeyi KIRMIZI yapmali (EXIT != 0). M160 ayrica GERCEK DEPO
farkiyla olculur (A12/G26/a: 23 spec'in bulgu kumesi degismemeli).
"""
import hashlib
import os
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BU = os.path.dirname(os.path.abspath(__file__))
KOK = os.path.abspath(os.path.join(BU, "..", ".."))
ARAC = os.path.join(KOK, "araclar", "spec-kapi-kapsama.py")
SPECDIZIN = os.path.join(KOK, "GOREV_CLAUDE_CODE")

MUTANTLAR = [
    ("M156", "A12/G25/a", "SS3 baslik kaynagini kaldir",
     r"    kurallar = sorted(set(kurallar_5) | uc_baslik_kurallari(uc))",
     r"    kurallar = sorted(set(kurallar_5))"),
    ("M157", "A12/G25/c", "deseni tek haneye geri al",
     r'    for k in re.findall(r"\bD(\d+)\b", hucre):',
     r'    for k in re.findall(r"\bD(\d)\b", hucre):'),
    ("M158", "A12/G25/d", "G<n>'i de kural say",
     r"        kurallar |= kod_araligi_ac(m.group(1))",
     r'        kurallar |= kod_araligi_ac(m.group(1)) | set(re.findall(r"\bG\d+\b", m.group(1)))'),
    ("M159", "A12/G25/g", "hayalet-borc (S6) kontrolunu kaldir",
     r"        elif r not in kurallar:",
     r"        elif False:"),
    ("M160", "A12/G26/a", "deseni \\w+ kadar gevset",
     r'    for ad in re.findall(r"\bD-[A-Za-z0-9]+-\d+\b", hucre):',
     r'    for ad in re.findall(r"\b\w+\b", hucre):'),
    ("M161", "A12/G25/b", "SS5 ilk-sutun kaynagini kaldir",
     r"    kapilar, kurallar_5 = envanter(g5)",
     r"    kapilar, kurallar_5 = envanter(g5)\n    kurallar_5 = set()"),
]


def kos_altin():
    s = subprocess.run([sys.executable, ARAC, "--altin-kume"], capture_output=True,
                       text=True, encoding="utf-8", errors="replace", cwd=KOK)
    return s.returncode, (s.stdout or "") + (s.stderr or "")


def depo_bulgu():
    toplam = 0
    for ad in sorted(os.listdir(SPECDIZIN)):
        if not ad.lower().endswith(".md"):
            continue
        s = subprocess.run([sys.executable, ARAC, os.path.join(SPECDIZIN, ad)],
                           capture_output=True, text=True, encoding="utf-8",
                           errors="replace", cwd=KOK)
        toplam += sum(1 for x in (s.stdout or "").splitlines() if x.strip().startswith("[S"))
    return toplam


def main():
    with open(ARAC, "rb") as f:
        ORIJINAL = f.read()
    orj_sha = hashlib.sha256(ORIJINAL).hexdigest()[:8].upper()
    print("ARAC: %d b / sha8 %s" % (len(ORIJINAL), orj_sha))

    rc0, _ = kos_altin()
    temiz_depo = depo_bulgu()
    print("TEMIZ-ONCE: altin kume EXIT=%d  |  depo toplam bulgu=%d" % (rc0, temiz_depo))
    print("-" * 78)

    satirlar = []
    isiran = 0
    for ad, kapi, aciklama, eski, yeni in MUTANTLAR:
        govde = ORIJINAL.decode("utf-8")
        yeni_gercek = yeni.replace("\\n", "\n")
        sayi = govde.count(eski)
        if sayi != 1:
            satirlar.append("%-5s %-12s DURDU: desen %d kez gecti (1 bekleniyordu) -- %s"
                            % (ad, kapi, sayi, aciklama))
            continue
        yamali = govde.replace(eski, yeni_gercek, 1).encode("utf-8")
        try:
            with open(ARAC, "wb") as f:
                f.write(yamali)
            rc, cikti = kos_altin()
            depo = depo_bulgu() if ad == "M160" else None
        finally:
            with open(ARAC, "wb") as f:
                f.write(ORIJINAL)
        with open(ARAC, "rb") as f:
            geri_sha = hashlib.sha256(f.read()).hexdigest()[:8].upper()
        ozdes = "OZDES" if geri_sha == orj_sha else "SAPMA(%s)" % geri_sha
        dusen = [x.strip() for x in cikti.splitlines() if x.strip().startswith("[DUSTU]")]
        if ad == "M160":
            isirdi = (rc != 0) or (depo != temiz_depo)
            ek = " | depo bulgu=%d (temiz %d)" % (depo, temiz_depo)
        else:
            isirdi = rc != 0
            ek = ""
        if isirdi:
            isiran += 1
        satirlar.append("%-5s %-12s %-10s EXIT=%d%s  geri=%s  [%s]"
                        % (ad, kapi, "ISIRDI" if isirdi else "HAYATTA", rc, ek, ozdes, aciklama))
        for d in dusen[:4]:
            satirlar.append("        %s" % d)

    rc1, _ = kos_altin()
    son_depo = depo_bulgu()
    with open(ARAC, "rb") as f:
        son_sha = hashlib.sha256(f.read()).hexdigest()[:8].upper()
    print("\n".join(satirlar))
    print("-" * 78)
    print("TEMIZ-SONRA: altin kume EXIT=%d  |  depo toplam bulgu=%d  |  arac sha8 %s (%s)"
          % (rc1, son_depo, son_sha, "OZDES" if son_sha == orj_sha else "SAPMA"))
    print("HUKUM: %d/%d ISIRDI" % (isiran, len(MUTANTLAR)))


main()

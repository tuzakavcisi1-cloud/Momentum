"""COWORK'UN BAGIMSIZ MUTANT ORNEKLEMESI -- W2 / M215 (K26).

Bu betigi COWORK yazdi; Claude Code'un _mutant_kosucu.py'sini KULLANMAZ.
Amac: kabul kriteri 4'un en yuk tasiyan mutantini (M215 -- dikisin argumanlari
sabit dizgeye cevrilir) GERCEK REPODA kendi elimizle kosmak.

ORTAM.md: git restore YASAK (core.autocrlf bayt-ozdesligi kor eder) =>
ikili yedek -> bayt duzeyinde yama -> yedekten wb geri yaz -> sha256 olc.
try/finally: cokse bile geri alinir.
"""
import hashlib
import os
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KOK = os.path.dirname(KOK)  # KANIT/W2 -> KANIT -> proje koku
HEDEF = os.path.join(KOK, "src", "client", "lib", "veri", "veritabani.dart")
ISTEMCI = os.path.join(KOK, "src", "client")
FLUTTER = r"C:\src\flutter\bin\flutter.bat"
TEST_DOSYASI = "test/w2_dikis_kapisi_test.dart"

ESKI = (b"            uygulamaAdi: sonuc.chosenImplementation.name,\n"
        b"            depolamaApi: sonuc.chosenImplementation.storageApi?.name,\n")
YENI = (b"            uygulamaAdi: 'opfsShared',\n"
        b"            depolamaApi: 'opfs',\n")


def sha(b):
    return hashlib.sha256(b).hexdigest()[:8].upper()


def kos():
    ortam = dict(os.environ)
    ortam["PROGRAMFILES(X86)"] = r"C:\Program Files (x86)"
    p = subprocess.run([FLUTTER, "test", TEST_DOSYASI, "--reporter", "expanded"],
                       cwd=ISTEMCI, capture_output=True, text=True,
                       encoding="utf-8", errors="replace", env=ortam)
    cikti = (p.stdout or "") + (p.returncode and (p.stderr or "") or "")
    kirmizi = sorted(set(re.findall(r"G4\d/[a-g]", "\n".join(
        [s for s in cikti.splitlines() if s.strip().startswith("\u001b") or "[E]" in s or "Some tests failed" in s or ": G4" in s and "-" in s]))))
    # daha guvenli: hata bloklarindaki ayak kimliklerini topla
    hata_ayaklari = sorted(set(re.findall(r"(G4\d/[a-g])[^\n]*\n[^\n]*(?:Expected|Actual|failed)", cikti)))
    return p.returncode, cikti, kirmizi, hata_ayaklari


def main():
    with open(HEDEF, "rb") as f:
        taban = f.read()
    print("HEDEF          : %s" % os.path.relpath(HEDEF, KOK))
    print("taban sha8     : %s  (%d b)" % (sha(taban), len(taban)))
    if ESKI not in taban:
        print("HATA: yama deseni BULUNAMADI -- olcum YAPILAMADI (OLCULEMEDI).")
        return 3
    if taban.count(ESKI) != 1:
        print("HATA: desen %d kez gecti, TEK olmali." % taban.count(ESKI))
        return 3

    print("\n[KONTROL] mutantsiz kosum (taban):")
    rc0, c0, _, _ = kos()
    print("  cikis=%s  %s" % (rc0, "TUM TESTLER GECTI" if rc0 == 0 else "BASARISIZ"))

    mutant = taban.replace(ESKI, YENI)
    try:
        with open(HEDEF, "wb") as f:
            f.write(mutant)
        print("\n[M215] argumanlar SABIT DIZGEYE cevrildi (%d -> %d b)" % (len(taban), len(mutant)))
        rc1, c1, _, _ = kos()
        print("  cikis=%s" % rc1)
        for s in c1.splitlines():
            if "[E]" in s or "Some tests failed" in s or "All tests passed" in s:
                print("  | %s" % s.strip()[:160])
    finally:
        with open(HEDEF, "wb") as f:
            f.write(taban)
        with open(HEDEF, "rb") as f:
            simdi = f.read()
        print("\ngeri alma sha8 : %s  ozdes=%s" % (sha(simdi), simdi == taban))

    print("\n[KONTROL] geri alma sonrasi kosum:")
    rc2, _, _, _ = kos()
    print("  cikis=%s" % rc2)
    print("\nHUKUM: taban=%s  mutant=%s  geri=%s" % (rc0, rc1, rc2))
    return 0


if __name__ == "__main__":
    sys.exit(main())

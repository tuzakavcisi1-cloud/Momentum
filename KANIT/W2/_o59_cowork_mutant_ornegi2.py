"""COWORK'UN IKINCI BAGIMSIZ MUTANT ORNEKLEMESI -- W2 / M200 (K26).

Amac: Claude Code'un "M200 ASIRI-YAKALAMA (yapisal), KOR KAPI DEGIL" iddiasini
URETICIDEN BAGIMSIZ olarak yeniden olcmek. Iddia: D-W2-2'nin (4) dali TEK bir
`return` satiridir ve G39/b + G39/e + G39/g ayaklarinin UCU DE ayni yoldan gecer.

ORTAM.md: git restore YASAK. Ikili yedek -> bayt yamasi -> yedekten geri -> sha.
"""
import hashlib
import os
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

KOK = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HEDEF = os.path.join(KOK, "src", "client", "lib", "veri", "depolama_durumu.dart")
ISTEMCI = os.path.join(KOK, "src", "client")
FLUTTER = r"C:\src\flutter\bin\flutter.bat"
TEST_DOSYASI = "test/w2_depolama_esleme_test.dart"

ESKI = b"  return DepolamaSinifi.geriDusus; // \xe2\x91\xa3"
YENI = b"  return DepolamaSinifi.kaliciOpfs; // \xe2\x91\xa3"


def sha(b):
    return hashlib.sha256(b).hexdigest()[:8].upper()


def kos():
    ortam = dict(os.environ)
    ortam["PROGRAMFILES(X86)"] = r"C:\Program Files (x86)"
    p = subprocess.run([FLUTTER, "test", TEST_DOSYASI, "--reporter", "expanded"],
                       cwd=ISTEMCI, capture_output=True, text=True,
                       encoding="utf-8", errors="replace", env=ortam)
    c = (p.stdout or "") + (p.stderr or "")
    ayaklar = sorted(set(re.findall(r"G\d\d/[a-g]", "\n".join(
        s for s in c.splitlines() if "[E]" in s))))
    return p.returncode, c, ayaklar


def main():
    with open(HEDEF, "rb") as f:
        taban = f.read()
    print("HEDEF       : %s" % os.path.relpath(HEDEF, KOK))
    print("taban sha8  : %s  (%d b)" % (sha(taban), len(taban)))
    if taban.count(ESKI) != 1:
        print("HATA: desen %d kez gecti, TEK olmali -> OLCULEMEDI." % taban.count(ESKI))
        return 3

    rc0, _, _ = kos()
    print("[KONTROL] mutantsiz : cikis=%s" % rc0)

    try:
        with open(HEDEF, "wb") as f:
            f.write(taban.replace(ESKI, YENI))
        print("[M200] (4) aksi-hal dali geriDusus -> kaliciOpfs")
        rc1, c1, ayaklar = kos()
        print("  cikis=%s" % rc1)
        print("  KIRMIZI AYAKLAR (olculen): %s" % (", ".join(ayaklar) or "(yok)"))
        for s in c1.splitlines():
            if "[E]" in s:
                print("  | %s" % s.strip()[:150])
    finally:
        with open(HEDEF, "wb") as f:
            f.write(taban)
        with open(HEDEF, "rb") as f:
            simdi = f.read()
        print("geri alma   : sha8=%s ozdes=%s" % (sha(simdi), simdi == taban))

    rc2, _, _ = kos()
    print("[KONTROL] geri sonrasi: cikis=%s" % rc2)
    return 0


if __name__ == "__main__":
    sys.exit(main())

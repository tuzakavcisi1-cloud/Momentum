# -*- coding: utf-8 -*-
"""Oturum 56 -- M-o56-1: oturum 56 ONARIMININ YUK TASIDIGINI kanitlar.
Onarimi (blok yorum kesme) DEVRE DISI birakir; vaka 13 ve 14 DUSMELIDIR.
ORTAM.md: `git restore` YASAK (core.autocrlf) => ikili yedek + bayt yamasi + sha."""
import hashlib, os, subprocess, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
HEDEF = os.path.join(KOK, "araclar", "ss2-kapisi.py")
ESKI = b"for satir in _blok_yorumsuz(metin).split"
YENI = b"for satir in metin.split"


def sha(b):
    return hashlib.sha256(b).hexdigest()[:8].upper()


ham = open(HEDEF, "rb").read()
sha_once = sha(ham)
print("HEDEF   : araclar/ss2-kapisi.py  %d b  sha8=%s" % (len(ham), sha_once))
if ham.count(ESKI) != 1:
    print("[KIRMIZI] YAMA NOKTASI TEK DEGIL (%d) -- mutant KOSULMADI." % ham.count(ESKI))
    sys.exit(2)

try:
    open(HEDEF, "wb").write(ham.replace(ESKI, YENI))
    p = subprocess.run([sys.executable, HEDEF, "--altin-kume"],
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    dusen = [s.strip() for s in p.stdout.splitlines() if s.startswith("[KALDI]")]
    hukum = [s.strip() for s in p.stdout.splitlines() if s.startswith("HUKUM")]
    print("MUTANT  : _blok_yorumsuz() devre disi (onarim geri alindi)")
    print("EXIT    : %d  (0 ise ONARIM YUK TASIMIYOR = ESDEGER MUTANT)" % p.returncode)
    for s in dusen:
        print("  " + s)
    for s in hukum:
        print("  " + s)
finally:
    open(HEDEF, "wb").write(ham)

geri = open(HEDEF, "rb").read()
sha_sonra = sha(geri)
print("GERI AL : %d b  sha8=%s  ==> %s" % (len(geri), sha_sonra,
      "BAYT-OZDES" if sha_sonra == sha_once else "SAPMA VAR (KIRMIZI)"))

isirdi = (p.returncode != 0
          and any("13)" in s for s in dusen)
          and any("14)" in s for s in dusen))
print("HUKUM   : %s" % ("ISIRDI -- onarim yuk tasiyor (13 ve 14 dustu)"
                        if isirdi else "ISIRMADI -- ONARIM SAHTE, KIRMIZI"))
sys.exit(0 if (isirdi and sha_sonra == sha_once) else 1)

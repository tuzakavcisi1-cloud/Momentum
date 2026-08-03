# -*- coding: utf-8 -*-
"""Tavan degisikligi SONRASI: altin kume + gercek kosum + MUTANT (geri cekme testi).
K40 sarti: esigi degistiren el altin kumeye vaka ekler VE o vakanin ISIRDIGINI kanitlar."""
import hashlib, shutil, subprocess, sys, os
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"
ARAC = os.path.join(KOK, "araclar", "belge-tavan-kapisi.py")

def sha8(y):
    with open(y, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()[:8].upper()

def kos(arg, baslik, kes=1400):
    p = subprocess.run([sys.executable, ARAC] + arg, cwd=KOK, capture_output=True,
                       text=True, encoding="utf-8", errors="replace")
    print("=" * 72)
    print("### %s   EXIT=%d" % (baslik, p.returncode))
    o = (p.stdout or "").strip()
    print(o[-kes:] if len(o) > kes else o)
    return p.returncode

print("ARAC sha8 (baslangic): %s" % sha8(ARAC))
kos(["--altin-kume"], "ALTIN KUME (13 vaka bekleniyor)", 1100)
kos(["."], "GERCEK KOSUM", 1600)

# --- MUTANT: tavan SESSIZCE geri cekilirse altin kume ISIRMALI mi? -----------
print("=" * 72)
print("### MUTANT M-T13: tavan 32768 -> 24576 (sessiz geri cekme)")
yedek = ARAC + ".ikili-yedek"
with open(ARAC, "rb") as f:
    ham = f.read()
with open(yedek, "wb") as f:
    f.write(ham)
try:
    # SADECE VARSAYILAN_KAPSAM'daki degeri geri cek; BEKLENEN_KAPSAM'a DOKUNMA.
    hedef = b'("BORCLAR.md", 32768, "K83'
    yeni = b'("BORCLAR.md", 24576, "K83'
    if ham.count(hedef) != 1:
        print("DURDU: desen %d kez gecti, 1 bekleniyordu." % ham.count(hedef))
        raise SystemExit(4)
    with open(ARAC, "wb") as f:
        f.write(ham.replace(hedef, yeni))
    kod = kos(["--altin-kume"], "MUTANT ALTINDA ALTIN KUME (ISIRMALI)", 900)
    print(">>> MUTANT HUKMU: %s" % ("ISIRDI (dogru)" if kod != 0 else "ISIRMADI -- KOR VAKA!"))
finally:
    with open(ARAC, "wb") as f:
        f.write(ham)
    os.remove(yedek)
print("ARAC sha8 (geri yazim sonrasi): %s" % sha8(ARAC))

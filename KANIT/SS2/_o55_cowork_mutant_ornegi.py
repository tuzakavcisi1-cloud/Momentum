# -*- coding: utf-8 -*-
# COWORK'UN BAGIMSIZ MUTANT ORNEKLEMESI (K26 -- builder'in beyanina guvenilmez).
# ORTAM.md: git restore YASAK (core.autocrlf). Ikili yedek -> bayt yamasi -> geri yaz -> sha256.
import os, sys, subprocess, hashlib, io
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

FLUTTER = r"C:\src\flutter\bin\flutter.bat"
CWD     = r"C:\dev\Momentum\src\client"
HEDEF   = os.path.join(CWD, "lib", "veri", "gorev_deposu.dart")
TEST    = "test/g33_rozet_uc_kanal_test.dart"
env = dict(os.environ); env["PROGRAMFILES(X86)"] = r"C:\Program Files (x86)"

def sha(p):
    with open(p, "rb") as f: return hashlib.sha256(f.read()).hexdigest()

def test_kos(etiket):
    p = subprocess.run([FLUTTER, "test", TEST], cwd=CWD, env=env, capture_output=True,
                       text=True, encoding="utf-8", errors="replace", timeout=900)
    son = [s for s in (p.stdout or "").splitlines() if s.strip()]
    print("   [%s] EXIT=%d | son satir: %s" % (etiket, p.returncode, son[-1][:120] if son else "(bos)"))
    return p.returncode, (p.stdout or "")

with open(HEDEF, "rb") as f: TABAN = f.read()          # ikili yedek
taban_sha = hashlib.sha256(TABAN).hexdigest()
print("TABAN gorev_deposu.dart:", len(TABAN), "bayt · sha256", taban_sha[:16])

# --- 0) MUTANTSIZ TABAN: test GECMELI (yanlis-pozitif kontrolu)
print("\n0) MUTANTSIZ TABAN -- test GECMELI")
rc0, _ = test_kos("taban")

# --- 1) M176b MUTANTI: distinct: true -> distinct: false (ilk eslesme)
DESEN = b"distinct: true"
adet = TABAN.count(DESEN)
print("\n1) M176b -- 'distinct: true' eslesme sayisi:", adet)
if adet == 0:
    print("   HATA: desen YOK -- distinct korumasi kaynakta bulunamadi."); sys.exit(2)
mutant = TABAN.replace(DESEN, b"distinct: false", 1)     # YALNIZ ILKI
with open(HEDEF, "wb") as f: f.write(mutant)
print("   mutant yazildi:", len(mutant), "bayt · sha256", hashlib.sha256(mutant).hexdigest()[:16])
rc1, cikti1 = test_kos("M176b")

# --- 2) GERI YAZ (wb) ve sha256 ile OZDESLIGI OLC
with open(HEDEF, "wb") as f: f.write(TABAN)
geri_sha = sha(HEDEF)
print("\n2) GERI YAZIM · sha256", geri_sha[:16], "==" if geri_sha == taban_sha else "!= FARKLI", "taban")

# --- 3) GERI ALINDIKTAN SONRA test YINE GECMELI
print("\n3) GERI ALIM SONRASI -- test YINE GECMELI")
rc3, _ = test_kos("geri-alim")

print("\n" + "=" * 66)
print("COWORK'UN BAGIMSIZ HUKMU (M176b ornegi):")
print("  taban test       :", "GECTI" if rc0 == 0 else "DUSTU (EXIT %d)" % rc0)
print("  mutant test      :", "DUSTU = ISIRDI" if rc1 != 0 else "GECTI = ISIRMADI (ESDEGER MUTANT!)")
print("  bayt-ozdes geri  :", "EVET" if geri_sha == taban_sha else "HAYIR")
print("  geri alim testi  :", "GECTI" if rc3 == 0 else "DUSTU (EXIT %d)" % rc3)
karar = (rc0 == 0 and rc1 != 0 and geri_sha == taban_sha and rc3 == 0)
print("  HUKUM            :", "M176b GERCEKTEN ISIRIYOR" if karar else "DOGRULANAMADI")
print("=" * 66)
with io.open(os.path.join(r"C:\dev\Momentum\KANIT\SS2", "T7-COWORK-bagimsiz-mutant-ornegi.txt"),
             "w", encoding="utf-8", newline="\n") as f:
    f.write("COWORK BAGIMSIZ ORNEKLEME -- M176b\ntaban sha256 %s\ngeri sha256  %s\n"
            "taban EXIT %d | mutant EXIT %d | geri-alim EXIT %d\nHUKUM: %s\n\n--- MUTANT KOSUMU HAM ---\n%s"
            % (taban_sha, geri_sha, rc0, rc1, rc3,
               "ISIRDI" if karar else "DOGRULANAMADI", cikti1))
sys.exit(0 if karar else 3)

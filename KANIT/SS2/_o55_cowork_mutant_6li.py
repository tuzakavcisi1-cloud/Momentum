# -*- coding: utf-8 -*-
# COWORK: 6 'distinct: true' esleşmesinin HER BIRI ayri mutant. Hangisi G33/d'yi dusuruyor?
# Amac: G33/c'nin "HER count() distinct tasir" kuralinin KAC sutununun fiilen KORUNDUGUNU olcmek.
import os, sys, subprocess, hashlib, io, re
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

FLUTTER = r"C:\src\flutter\bin\flutter.bat"
CWD     = r"C:\dev\Momentum\src\client"
HEDEF   = os.path.join(CWD, "lib", "veri", "gorev_deposu.dart")
TESTLER = ["test/g33_rozet_uc_kanal_test.dart"]
env = dict(os.environ); env["PROGRAMFILES(X86)"] = r"C:\Program Files (x86)"

with open(HEDEF, "rb") as f: TABAN = f.read()
taban_sha = hashlib.sha256(TABAN).hexdigest()
metin = TABAN.decode("utf-8")
satirlar = metin.split("\n")

# esleşmelerin satir no'su + o satirin hangi sutuna ait oldugunu bulmak icin geriye dogru bak
yerler = []
for i, s in enumerate(satirlar):
    if "distinct: true" in s:
        baglam = ""
        for j in range(i, max(-1, i - 6), -1):
            m = re.search(r"(\w+Sutunu|\w+Sayisi|final\s+(\w+))", satirlar[j])
            if m: baglam = m.group(0); break
        yerler.append((i + 1, baglam, satirlar[i].strip()[:60]))

print("TABAN:", len(TABAN), "bayt · sha256", taban_sha[:16])
print("'distinct: true' bulunan satirlar:")
for no, bg, ic in yerler:
    print("   satir %-5d  baglam=%-22s  %s" % (no, bg, ic))

def test_kos():
    rc = 0; sonsat = ""
    for t in TESTLER:
        p = subprocess.run([FLUTTER, "test", t], cwd=CWD, env=env, capture_output=True,
                           text=True, encoding="utf-8", errors="replace", timeout=900)
        ss = [x for x in (p.stdout or "").splitlines() if x.strip()]
        if ss: sonsat = ss[-1][:100]
        if p.returncode != 0: rc = p.returncode
    return rc, sonsat

DESEN = b"distinct: true"
sonuc = []
print("\n" + "=" * 70)
for k in range(len(yerler)):
    # k'inci esleşmeyi degistir
    parcalar = TABAN.split(DESEN)
    mutant = DESEN.join(parcalar[:k+1]) + b"distinct: false" + DESEN.join([b""] + parcalar[k+1:])[0:0] + DESEN.join(parcalar[k+1:])
    # yukaridaki ifade karisik; net yol:
    idx = -1
    p = 0
    for _ in range(k + 1):
        idx = TABAN.find(DESEN, p); p = idx + 1
    mutant = TABAN[:idx] + b"distinct: false" + TABAN[idx + len(DESEN):]
    with open(HEDEF, "wb") as f: f.write(mutant)
    rc, sonsat = test_kos()
    isirdi = (rc != 0)
    sonuc.append((yerler[k][0], yerler[k][1], isirdi, sonsat))
    print("  #%d satir %-5d %-22s => %s | %s"
          % (k + 1, yerler[k][0], yerler[k][1], "ISIRDI" if isirdi else "ISIRMADI (KOR)", sonsat))
    with open(HEDEF, "wb") as f: f.write(TABAN)   # geri yaz
    if hashlib.sha256(open(HEDEF, "rb").read()).hexdigest() != taban_sha:
        print("   HATA: geri yazim bayt-ozdes DEGIL -- DURDURULDU."); sys.exit(4)

isiran = sum(1 for _, _, i, _ in sonuc if i)
print("=" * 70)
print("SONUC: %d/%d 'distinct: true' korunuyor (mutant isiriyor)." % (isiran, len(sonuc)))
print("       %d tanesi KOR -- silinse hicbir test dusmez." % (len(sonuc) - isiran))
print("TABAN sha256 son kontrol:", hashlib.sha256(open(HEDEF, "rb").read()).hexdigest()[:16],
      "==" if hashlib.sha256(open(HEDEF, "rb").read()).hexdigest() == taban_sha else "!=", "taban")

with io.open(os.path.join(r"C:\dev\Momentum\KANIT\SS2", "T7-COWORK-distinct-6li-olcum.txt"),
             "w", encoding="utf-8", newline="\n") as f:
    f.write("COWORK BAGIMSIZ OLCUM -- G33/c 'her count() distinct tasir' kuralinin KAC ayagi korunuyor?\n")
    f.write("taban sha256 %s\n\n" % taban_sha)
    for no, bg, i, ss in sonuc:
        f.write("satir %-5d %-22s %s | %s\n" % (no, bg, "ISIRDI" if i else "ISIRMADI(KOR)", ss))
    f.write("\nSONUC: %d/%d korunuyor, %d KOR.\n" % (isiran, len(sonuc), len(sonuc) - isiran))

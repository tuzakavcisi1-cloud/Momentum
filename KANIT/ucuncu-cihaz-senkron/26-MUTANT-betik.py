import os, sys, subprocess, re, time
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
C = r"C:\dev\Momentum\src\client"
FLUTTER = r"C:\src\flutter\bin\flutter.bat"
HEDEF = os.path.join(C, "lib", "sunum", "gorev_listesi_ekrani.dart")
TEST = r"test\yerel_yazma_itme_tetikleyicisi_test.dart"
ort = dict(os.environ); ort["PROGRAMFILES(X86)"] = r"C:\Program Files (x86)"
ASIL = open(HEDEF, "rb").read()

def kos(ad):
    t0 = time.time()
    p = subprocess.run([FLUTTER, "test", TEST], cwd=C, env=ort, capture_output=True,
                       text=True, encoding="utf-8", errors="replace", timeout=1200)
    c = (p.stdout or "") + (p.stderr or "")
    dusen = sorted(set(re.findall(r"K112/([abcd])", "\n".join(
        [s for s in c.splitlines() if "[E]" in s or "Expected:" in s or "FAILED" in s or
         ": K112/" in s and "+" not in s.split(":")[0]]))))
    hata = [s for s in c.splitlines() if re.search(r"^\s*\d+:\d+ \+\d+ -\d+", s)]
    print("[" + ad + "] EXIT=" + str(p.returncode) + " · " + str(round(time.time()-t0, 1)) + "s")
    son = [s for s in c.splitlines() if s.strip()][-3:]
    for s in son:
        print("     " + s.strip()[:170])
    for s in c.splitlines():
        if "K112/" in s and ("-1" in s or "-2" in s or "[E]" in s):
            print("     DUSEN >> " + s.strip()[:150])
    return p.returncode

def yaz(b):
    open(HEDEF + ".tmp", "wb").write(b)
    os.rename(HEDEF, HEDEF + ".yedek"); os.rename(HEDEF + ".tmp", HEDEF)
    os.remove(HEDEF + ".yedek")

print("### 0) TEMIZ KOSUM -- 4/4 gecmeli")
temiz = kos("temiz")

print()
print("### M136 -- tetikleyici cagrisi KALDIRILIR (kapi a ve b ISIRMALI)")
m = ASIL.decode("utf-8").replace(
    "    final tetik = widget.onYerelYazma;\n    if (tetik != null) await tetik();",
    "    // M136 MUTANT: tetikleyici cagrisi kaldirildi.")
if "M136 MUTANT" not in m:
    print("   [HATA] mutant deseni uygulanamadi"); yaz(ASIL); sys.exit(1)
yaz(m.encode("utf-8"))
m136 = kos("M136")
yaz(ASIL)

print()
print("### M137 -- SIRA TERS CEVRILIR: once itme, sonra yazma (kapi b ISIRMALI)")
m = ASIL.decode("utf-8").replace(
    "    await yazma();\n    final tetik = widget.onYerelYazma;\n    if (tetik != null) await tetik();",
    "    // M137 MUTANT: sira ters.\n    final tetik = widget.onYerelYazma;\n"
    "    if (tetik != null) await tetik();\n    await yazma();")
if "M137 MUTANT" not in m:
    print("   [HATA] mutant deseni uygulanamadi"); yaz(ASIL); sys.exit(1)
yaz(m.encode("utf-8"))
m137 = kos("M137")
yaz(ASIL)

print()
print("### 3) GERI ALINDI -- dosya bayt-ozdes mi: " +
      str(open(HEDEF, "rb").read() == ASIL))
son = kos("temiz-tekrar")
print()
print("[HUKUM] temiz=" + str(temiz) + " · M136=" + str(m136) + " · M137=" + str(m137) +
      " · temiz-tekrar=" + str(son))
print("[BEKLENEN] temiz 0 · M136 !=0 · M137 !=0 · temiz-tekrar 0")
print("[SONUC] " + ("KAPI ISIRIYOR" if (temiz == 0 and m136 != 0 and m137 != 0 and son == 0)
                    else "KAPI KOR YA DA OLCUM BOZUK -- INCELE"))

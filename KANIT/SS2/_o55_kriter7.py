# -*- coding: utf-8 -*-
# KRITER 7: docker ayaga kaldirilir (Onur'un ACIK izniyle, K80), verify.ps1 kosar.
import subprocess, time, sys, io, os
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"

print("1) PORT 5298 KONTROLU (verify calisan Api varken kosulmaz -- ORTAM.md)")
p = subprocess.run("netstat -ano | findstr :5298", shell=True, capture_output=True, text=True)
print("   cikti:", repr((p.stdout or "").strip()[:120]) or "(bos)")
if (p.stdout or "").strip():
    print("   DURDURULDU: :5298 DOLU. verify.ps1 kosulamaz."); sys.exit(2)
print("   :5298 BOS -- devam.")

print("\n2) docker start momentum-postgres")
p = subprocess.run(["docker", "start", "momentum-postgres"], capture_output=True, text=True)
print("   EXIT", p.returncode, "|", (p.stdout or p.stderr or "").strip()[:120])

print("\n3) HEALTHY YOKLAMASI (tavanli: 60 x 2s) -- sabit bekleme YOK")
durum = "?"
for i in range(60):
    q = subprocess.run(["docker", "inspect", "-f", "{{.State.Health.Status}}", "momentum-postgres"],
                       capture_output=True, text=True)
    durum = (q.stdout or "").strip()
    if i % 5 == 0 or durum == "healthy":
        print("   yoklama %2d: %s" % (i, durum))
    if durum == "healthy":
        break
    time.sleep(2)
if durum != "healthy":
    print("   DURDURULDU: healthy olmadi (son durum: %s)" % durum); sys.exit(3)

print("\n4) verify.ps1 KOSUYOR")
p = subprocess.run(["powershell", "-ExecutionPolicy", "Bypass", "-File", r"araclar\verify.ps1"],
                   cwd=KOK, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=1800)
cikti = (p.stdout or "") + ("\n--- STDERR ---\n" + p.stderr if p.stderr else "")
with io.open(os.path.join(KOK, "KANIT", "SS2", "T8-verify-ps1.txt"), "w", encoding="utf-8", newline="\n") as f:
    f.write(cikti)
satir = [s for s in cikti.splitlines() if s.strip()]
print("   EXIT =", p.returncode, "| toplam satir:", len(satir), "| ham: KANIT/SS2/T8-verify-ps1.txt")
print("   --- SON 18 SATIR ---")
for s in satir[-18:]:
    print("      ", s[:150])
print("\n" + "=" * 60)
print("KRITER 7 HUKMU:", "GECTI (EXIT 0)" if p.returncode == 0 else "DUSTU (EXIT %d)" % p.returncode)
print("=" * 60)

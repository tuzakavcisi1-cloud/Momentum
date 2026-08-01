import io, subprocess, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

KOK = r"C:\dev\Momentum"


def kos(*a):
    p = subprocess.run(["git", "--no-optional-locks"] + list(a), cwd=KOK,
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    return p.stdout


izlenmeyen = [s for s in kos("status", "--porcelain").split("\n") if s.strip()]
print("STATUS SATIRI (once):", len(izlenmeyen))

# 22-23 desenlerinin FIILEN gizledigi dosyalar (yalniz bu iki kural)
gizli = [s for s in kos("status", "--porcelain", "--ignored=matching").split("\n") if s.strip()]
print("STATUS+IGNORED SATIRI:", len(gizli))

aday = []
for s in gizli:
    if not s.startswith("!!"):
        continue
    yol = s[3:].strip().strip('"')
    aday.append(yol)

# hangi kural yakaliyor?
sayac = {}
ornek = {}
for yol in aday:
    ci = kos("check-ignore", "-v", yol).strip()
    if not ci:
        continue
    kural = ci.split("\t")[0]
    sayac[kural] = sayac.get(kural, 0) + 1
    ornek.setdefault(kural, yol)

print()
print("YOK SAYILAN YOLLARI HANGI KURAL YAKALIYOR:")
for k in sorted(sayac, key=lambda x: -sayac[x]):
    print(f"  {sayac[k]:4d}  {k}   ornek: {ornek[k]}")
print()
print("KRITIK: yalniz .gitignore:22 veya :23 tarafindan yakalanan yollar SILINCE GORUNUR OLUR.")

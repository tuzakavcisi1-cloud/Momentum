# -*- coding: utf-8 -*-
"""W1 denetim -- 2. tur: ortam + ASP.NET CORS safelist + web/index.html."""
import glob
import io
import os
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def bolum(b):
    print("=" * 74)
    print(b)
    print("=" * 74)


def kos(cmd, timeout=90):
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, shell=True,
                           timeout=timeout, encoding="utf-8", errors="replace")
        return r.returncode, (r.stdout or "") + (r.stderr or "")
    except Exception as e:
        return None, "OLCULEMEDI: %s" % e


bolum("1) docker ps -- momentum-postgres")
k, o = kos('docker ps -a --filter name=momentum --format "{{.Names}} | {{.Status}} | {{.Ports}}"')
print("EXIT=%s\n%s" % (k, o.strip() or "(bos)"))

bolum("2) netstat :5298 / :5000")
k, o = kos("netstat -ano")
for s in o.splitlines():
    if ":5298" in s or ":5000 " in s:
        print("  " + s.strip())

bolum("3) ASP.NET Core CORS -- SimpleRequestHeaders safelist (DLL string taramasi)")
adaylar = glob.glob(r"C:\Program Files\dotnet\shared\Microsoft.AspNetCore.App\*\Microsoft.AspNetCore.Cors.dll")
print("  bulunan DLL: %d" % len(adaylar))
for d in sorted(adaylar)[-2:]:
    ham = open(d, "rb").read()
    # .NET metadata string heap'i UTF-8; user strings UTF-16LE.
    def var8(s):
        return s.encode("utf-8") in ham
    def var16(s):
        return s.encode("utf-16-le") in ham
    print("  --- %s (%d b)" % (d, len(ham)))
    for s in ["Origin", "Accept-Language", "Content-Language", "Content-Type",
              "Access-Control-Request-Headers", "Access-Control-Allow-Headers",
              "SimpleRequestHeaders", "AllowAnyHeader",
              "application/x-www-form-urlencoded", "multipart/form-data", "text/plain",
              "The request header '{0}' is not allowed"]:
        print("      utf8=%-5s utf16=%-5s  %s" % (var8(s), var16(s), s))

bolum("4) src/client/web/index.html (tam)")
print(io.open(r"C:\dev\Momentum\src\client\web\index.html", encoding="utf-8",
              errors="replace").read())

bolum("5) appsettings.json (tam)")
print(io.open(r"C:\dev\Momentum\src\backend\Momentum.Api\appsettings.json",
              encoding="utf-8", errors="replace").read())

bolum("6) sunucu tarafi tablo adlari (Infrastructure icindeki SQL/DDL)")
kok = r"C:\dev\Momentum\src\backend"
desen = re.compile(r"(?:FROM|INTO|UPDATE|TABLE(?: IF NOT EXISTS)?)\s+([a-zA-Z_.\"]+)", re.I)
bulunan = {}
for r_, d_, f_ in os.walk(kok):
    d_[:] = [x for x in d_ if x not in ("bin", "obj")]
    for a in f_:
        if not a.endswith((".cs", ".sql")):
            continue
        p = os.path.join(r_, a)
        m = io.open(p, encoding="utf-8", errors="replace").read()
        for t in desen.findall(m):
            bulunan.setdefault(t.strip('"'), set()).add(os.path.relpath(p, kok))
for t in sorted(bulunan):
    print("  %-28s %s" % (t, sorted(bulunan[t])[:2]))

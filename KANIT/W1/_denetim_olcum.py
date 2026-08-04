# -*- coding: utf-8 -*-
"""W1 spec BAGIMSIZ DENETIM -- kosulabilirlik olcumleri (denetci eli)."""
import datetime
import io
import os
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

KOK = r"C:\dev\Momentum"
LIB = os.path.join(KOK, "src", "client", "lib")


def bolum(baslik):
    print("=" * 74)
    print(baslik)
    print("=" * 74)


bolum("1) kIsWeb -- lib/ genelinde HER gecis (dosya:satir)")
n = 0
for r, d, f in os.walk(LIB):
    for a in f:
        if not a.endswith(".dart"):
            continue
        p = os.path.join(r, a)
        metin = io.open(p, encoding="utf-8", errors="replace").read()
        for i, l in enumerate(metin.splitlines(), 1):
            if "kIsWeb" in l:
                n += 1
                print("  %-46s :%-4d %s" % (os.path.relpath(p, LIB), i, l.strip()))
print("  TOPLAM: %d" % n)

bolum("2) web varliklari + build ciktisi + atif edilen betikler")
for rel in ["src/client/web/sqlite3.wasm", "src/client/web/drift_worker.js",
            "src/client/web/index.html",
            "src/client/build/web/main.dart.js",
            "src/backend/Momentum.Api/appsettings.json",
            "src/backend/Momentum.Api/appsettings.Development.json",
            "araclar/cors-kapisi.py",
            "KANIT/A11/_backend_dogrula.py",
            "KANIT/A11/_mutant_kosucu.py",
            "KANIT/W1/_preflight.py"]:
    p = os.path.join(KOK, rel.replace("/", os.sep))
    if os.path.exists(p):
        st = os.stat(p)
        print("  VAR   %-52s %10d b  %s" % (
            rel, st.st_size,
            datetime.datetime.fromtimestamp(st.st_mtime).strftime("%Y-%m-%d %H:%M:%S")))
    else:
        print("  YOK   %s" % rel)

bolum("3) Program.cs -- CORS/pozitif kontrol dizgeleri")
prog = io.open(os.path.join(KOK, r"src\backend\Momentum.Api\Program.cs"),
               encoding="utf-8", errors="replace").read()
for d in ["AddCors", "UseCors", "WithOrigins", "AllowAnyOrigin", "AllowAnyHeader",
          "builder.Services.AddMediator", "UseRouting", "MapHub", "IsDevelopment"]:
    print("  %-32s x%d" % (d, prog.count(d)))

bolum("4) .gitignore -- appsettings / secret satirlari")
gi = io.open(os.path.join(KOK, ".gitignore"), encoding="utf-8", errors="replace").read()
for i, l in enumerate(gi.splitlines(), 1):
    if "appsettings" in l.lower() or "secret" in l.lower():
        print("  :%-4d %s" % (i, l))

bolum("5) veritabani.dart -- MOMENTUM-G6-KANIT / DriftWebOptions satirlari")
vt = io.open(os.path.join(KOK, r"src\client\lib\veri\veritabani.dart"),
             encoding="utf-8", errors="replace").read()
for i, l in enumerate(vt.splitlines(), 1):
    if "MOMENTUM-G6-KANIT" in l or "DriftWebOptions" in l or "onResult" in l:
        print("  :%-4d %s" % (i, l))

bolum("6) flutter surumu")
FL = r"C:\src\flutter\bin\flutter.bat"
print("  flutter.bat VAR mi: %s" % os.path.exists(FL))
try:
    r = subprocess.run([FL, "--version"], capture_output=True, text=True, timeout=300,
                       encoding="utf-8", errors="replace")
    print("  --version EXIT=%s" % r.returncode)
    print((r.stdout or "").strip()[:900])
    if (r.stderr or "").strip():
        print("  STDERR: " + r.stderr.strip()[:400])
except Exception as e:
    print("  OLCULEMEDI: %s" % e)

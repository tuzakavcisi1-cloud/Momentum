# -*- coding: utf-8 -*-
"""Backend'i YENIDEN BASLATMA komutu UYDURULMAZ, OLCULUR."""
import io
import json
import subprocess
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

print("== appsettings.json ConnectionStrings ==")
try:
    with io.open(r"C:\dev\Momentum\src\backend\Momentum.Api\appsettings.json",
                 "r", encoding="utf-8-sig", errors="replace") as f:
        js = json.load(f)
    print(json.dumps(js.get("ConnectionStrings", "YOK"), ensure_ascii=False, indent=2))
except Exception as e:
    print("OKUNAMADI: %s" % e)

print("\n== docker inspect momentum-postgres -> POSTGRES_* ==")
p = subprocess.run(["docker", "inspect", "momentum-postgres"],
                   capture_output=True, text=True, encoding="utf-8", errors="replace")
try:
    env = json.loads(p.stdout)[0]["Config"]["Env"]
    for e in env:
        if e.startswith("POSTGRES"):
            print("  " + e)
except Exception as e:
    print("OKUNAMADI: %s" % e)

print("\n== Momentum.Api.csproj var mi ==")
import os
yol = r"C:\dev\Momentum\src\backend\Momentum.Api\Momentum.Api.csproj"
print("  %s -> %s" % (yol, "VAR" if os.path.exists(yol) else "YOK"))

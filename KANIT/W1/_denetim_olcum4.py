# -*- coding: utf-8 -*-
"""W1 denetim -- 4. tur: sunucu DB semasi (G38/a) + chrome cihazi (G37)."""
import os
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def bolum(b):
    print("=" * 74)
    print(b)
    print("=" * 74)


def psql(sql, timeout=60):
    cmd = ["docker", "exec", "momentum-postgres", "psql", "-U", "momentum",
           "-d", "momentum", "-c", sql]
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout,
                           encoding="utf-8", errors="replace")
        return r.returncode, (r.stdout or "") + (r.stderr or "")
    except Exception as e:
        return None, "OLCULEMEDI: %s" % e


bolum("1) tasks tablosu semasi -- G38/a'nin 'psql ile satir sayilir' ayagi")
for sql in ["\\d tasks",
            "select count(*) as toplam from tasks;",
            "select distinct owner_id from tasks limit 10;"]:
    k, o = psql(sql)
    print("--- %s  (EXIT=%s)" % (sql, k))
    print(o.strip()[:2000])
    print()

bolum("2) flutter devices (chrome var mi?)")
env = os.environ.copy()
env["PROGRAMFILES(X86)"] = r"C:\Program Files (x86)"
try:
    r = subprocess.run([r"C:\src\flutter\bin\flutter.bat", "devices"],
                       cwd=r"C:\dev\Momentum\src\client", env=env,
                       capture_output=True, text=True, timeout=600,
                       encoding="utf-8", errors="replace")
    print("EXIT=%s" % r.returncode)
    print((r.stdout or "").strip()[:2500])
    if (r.stderr or "").strip():
        print("STDERR: " + r.stderr.strip()[:800])
except Exception as e:
    print("OLCULEMEDI: %s" % e)

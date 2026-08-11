# -*- coding: utf-8 -*-
"""o71 IS-EMRI SS4 -- ortami SEN kaldir (K80 + GOREV-W3 SS4c). Cowork kaldirmaz,
yalniz olcer; bu betik Claude Code'un kendi kosumudur.

KULLANIM:
    python _ortam_o71.py baslat   -- (1) docker start+healthy yokla (2) backend
                                      ayri surecte (3) /health/live+ready+v1/sync yokla
    python _ortam_o71.py kapat    -- backend'i PID ile kapatir, netstat :5298 BOS
                                      donene kadar yoklar
"""
import io
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

KOK = r"C:\dev\Momentum"
KANIT = os.path.join(KOK, "KANIT", "o71")
PID_DOSYASI = os.path.join(KANIT, "_backend.pid")
DEV_USER = "11111111-1111-1111-1111-111111111111"


def damga():
    return time.strftime("%H:%M:%S")


def mesaj(s):
    satir = "[%s] %s" % (damga(), s)
    print(satir)
    return satir


def kanit_yaz(ad, satirlar):
    with io.open(os.path.join(KANIT, ad), "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(satirlar) + "\n")


def calistir(argv, zaman_asimi=15):
    try:
        r = subprocess.run(argv, capture_output=True, text=True, timeout=zaman_asimi)
        return r.returncode, r.stdout, r.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "TIMEOUT"


def yokla(aciklama, olc_fn, aralik_sn, tavan_deneme, gecme_fn):
    gunluk = [mesaj("YOKLAMA basladi: %s (aralik=%ss, tavan=%d deneme)" % (aciklama, aralik_sn, tavan_deneme))]
    t0 = time.time()
    for i in range(1, tavan_deneme + 1):
        sonuc = olc_fn()
        gecen = time.time() - t0
        gunluk.append(mesaj("  [deneme %d/%d, %.1fsn] %r" % (i, tavan_deneme, gecen, sonuc)))
        if gecme_fn(sonuc):
            gunluk.append(mesaj("YOKLAMA GECTI: %s (%.1f sn'de)" % (aciklama, gecen)))
            return 0, sonuc, gunluk
        time.sleep(aralik_sn)
    gunluk.append(mesaj("YOKLAMA TAVANA CARPTI: %s -- DUR" % aciklama))
    return 3, None, gunluk


def _docker_healthy_mi():
    kod, out, err = calistir(["docker", "inspect", "--format", "{{.State.Health.Status}}", "momentum-postgres"])
    return out.strip() if kod == 0 else None


def docker_baslat():
    gunluk = [mesaj("① docker start momentum-postgres")]
    kod, out, err = calistir(["docker", "start", "momentum-postgres"])
    gunluk.append(mesaj("  exit=%d out=%r err=%r" % (kod, out.strip(), err.strip())))
    yokla_kod, sonuc, yokla_gunluk = yokla(
        "momentum-postgres healthy", _docker_healthy_mi,
        aralik_sn=2, tavan_deneme=30, gecme_fn=lambda s: s == "healthy")
    gunluk += yokla_gunluk
    kanit_yaz("01-docker.txt", gunluk)
    return 0 if yokla_kod == 0 else 3


def _bind_durumu():
    kod, out, err = calistir(["cmd", "/c", "netstat -ano | findstr :5298"])
    listening = [s for s in out.splitlines() if "LISTENING" in s]
    if any("0.0.0.0:5298" in s for s in listening):
        return "0.0.0.0"
    if any("127.0.0.1:5298" in s for s in listening):
        return "127.0.0.1"
    return None


def backend_baslat():
    gunluk = [mesaj("② backend baslatiliyor -- AYRI surecte, Python subprocess.Popen(env=)")]
    conn = "Host=localhost;Port=5432;Database=momentum;Username=momentum;Password=momentum_dev"
    env = dict(os.environ)
    env["ASPNETCORE_ENVIRONMENT"] = "Development"
    env["ASPNETCORE_URLS"] = "http://0.0.0.0:5298"
    env["ConnectionStrings__Momentum"] = conn
    log_yolu = os.path.join(KANIT, "09-backend-log.txt")
    log_dosyasi = open(log_yolu, "wb")
    api_dizini = os.path.join(KOK, "src", "backend", "Momentum.Api")
    p = subprocess.Popen(
        ["dotnet", "run", "--no-launch-profile"],
        cwd=api_dizini, env=env, stdout=log_dosyasi, stderr=subprocess.STDOUT,
        creationflags=subprocess.CREATE_NEW_PROCESS_GROUP,
    )
    with open(PID_DOSYASI, "w", encoding="utf-8") as f:
        f.write(str(p.pid))
    gunluk.append(mesaj("  baslatildi -- PID=%d, log=%s" % (p.pid, log_yolu)))
    kanit_yaz("02-backend-baslatma.txt", gunluk)
    return p.pid


def _dogrula():
    sonuclar = {}
    try:
        with urllib.request.urlopen("http://localhost:5298/health/live", timeout=5) as r:
            sonuclar["health_live"] = r.status
    except Exception as e:
        sonuclar["health_live"] = "HATA:%r" % e
    try:
        with urllib.request.urlopen("http://localhost:5298/health/ready", timeout=5) as r:
            sonuclar["health_ready"] = r.status
    except Exception as e:
        sonuclar["health_ready"] = "HATA:%r" % e

    govde = b'{"clientId":"9f1c5a20-0000-7000-8000-000000000071","clientHlc":null,"sinceCursor":null,"ops":[]}'
    req = urllib.request.Request("http://localhost:5298/v1/sync", data=govde, method="POST")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=5) as r:
            sonuclar["sync_baslikSIZ"] = r.status
    except urllib.error.HTTPError as e:
        sonuclar["sync_baslikSIZ"] = e.code
    except Exception as e:
        sonuclar["sync_baslikSIZ"] = "HATA:%r" % e

    req2 = urllib.request.Request("http://localhost:5298/v1/sync", data=govde, method="POST")
    req2.add_header("Content-Type", "application/json")
    req2.add_header("X-Momentum-Dev-User", DEV_USER)
    try:
        with urllib.request.urlopen(req2, timeout=5) as r:
            sonuclar["sync_devbaslikLI"] = r.status
    except urllib.error.HTTPError as e:
        sonuclar["sync_devbaslikLI"] = e.code
    except Exception as e:
        sonuclar["sync_devbaslikLI"] = "HATA:%r" % e
    return sonuclar


def backend_hazir_mi_yokla():
    gunluk = [mesaj("③ hazirlik -- PORTLA DEGIL, /health/live+ready+POST /v1/sync ile")]
    yk1, bind_sonuc, yg1 = yokla("port :5298 dinlemeye basladi (0.0.0.0)", _bind_durumu,
                                  aralik_sn=2, tavan_deneme=30, gecme_fn=lambda s: s is not None)
    gunluk += yg1
    if yk1 != 0 or bind_sonuc != "0.0.0.0":
        gunluk.append(mesaj("  KIRMIZI: 0.0.0.0:5298 dinlemiyor (bind=%r)" % bind_sonuc))
        kanit_yaz("03-backend-hazir.txt", gunluk)
        return 3

    yk2, sonuc, yg2 = yokla(
        "health/live=200 + health/ready=200 + sync 401/200", _dogrula,
        aralik_sn=2, tavan_deneme=30,
        gecme_fn=lambda s: s.get("health_live") == 200 and s.get("health_ready") == 200
        and s.get("sync_baslikSIZ") == 401 and s.get("sync_devbaslikLI") == 200)
    gunluk += yg2
    kanit_yaz("03-backend-hazir.txt", gunluk)
    return 0 if yk2 == 0 else 3


def kapat():
    gunluk = [mesaj("§4 adim ④ -- backend KAPATILIYOR")]
    if os.path.isfile(PID_DOSYASI):
        with open(PID_DOSYASI, "r", encoding="utf-8") as f:
            pid = int(f.read().strip())
        gunluk.append(mesaj("  kayitli PID=%d -- taskkill /PID /T /F" % pid))
        kod, out, err = calistir(["taskkill", "/PID", str(pid), "/T", "/F"])
        gunluk.append(mesaj("  taskkill -> exit=%d out=%r err=%r" % (kod, out.strip(), err.strip())))
    else:
        gunluk.append(mesaj("  _backend.pid YOK"))

    def listening_yok_mu():
        kod, out, err = calistir(["cmd", "/c", "netstat -ano | findstr :5298"])
        satirlar = [s for s in out.splitlines() if "LISTENING" in s]
        return (out, satirlar)

    yk, sonuc, yg = yokla("netstat :5298 -- LISTENING satiri YOK", listening_yok_mu,
                           aralik_sn=2, tavan_deneme=20, gecme_fn=lambda t: len(t[1]) == 0)
    gunluk += yg
    kanit_yaz("04-kapatma.txt", gunluk)
    return 0 if yk == 0 else 3


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("KULLANIM: python _ortam_o71.py {baslat|kapat}")
        sys.exit(2)
    komut = sys.argv[1]
    if komut == "baslat":
        kod1 = docker_baslat()
        if kod1 != 0:
            sys.exit(kod1)
        backend_baslat()
        sys.exit(backend_hazir_mi_yokla())
    elif komut == "kapat":
        sys.exit(kapat())
    else:
        print("BILINMEYEN KOMUT")
        sys.exit(2)

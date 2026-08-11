# -*- coding: utf-8 -*-
"""IS-EMRI-o70 -- SS2 kriter 8: ORTAM KURMA (GOREV-SS2 kriter 8 sirasi ①②③;
KANIT/SS2/08 §2 + KANIT/SS2/09 item 9/12/13'un duzelttigi bicimde).

KULLANIM:
    python ortam_kur.py docker      -- ① Postgres baslat + healthy yokla
    python ortam_kur.py backend     -- ② backend AYRI surecte baslat (env
                                        Python subprocess.Popen(env=...) ile
                                        verilir -- PowerShell backtick/`$`
                                        kacislarindan TAMAMEN BAGIMSIZ) +
                                        ③ /health/live+ready+v1/sync yokla
    python ortam_kur.py emulator <avd-id>  -- flutter emulators --launch +
                                        boot_completed yokla
    python ortam_kur.py sokme       -- backend'i PID ile kapat + netstat
                                        :5298 bos oldugunu yokla
    python ortam_kur.py istemci <hedef> <etiket> [ek bayraklar...]
                                        -- flutter run -d <hedef> AYRI surecte
                                        (BU AGACTAN, taze kurulum) + "Flutter
                                        run key commands" yokla. Ikisi de
                                        AYNI DEV_USER_ID ile baslar (KANIT/
                                        SS2/11 §4 sart1: taban URL BAGIMSIZ
                                        cozulur -- chrome icin ek bayrak
                                        olarak --web-port=5000 ve
                                        --dart-define=SENKRON_SUNUCU_URL=
                                        http://localhost:5298 verilir)

Hicbiri --altin-kume TASIMAZ: bu modul saf ORKESTRASYONDUR (I/O), on_kosullar.py
gibi ayrilabilir saf mantik tasimiyor -- kendini kanitlama YOKLAMA
FONKSIYONLARININ KENDISI (yokla() zaten yardimcilar.py'de TEK YERDEN sinanir).
"""
import json
import os
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from yardimcilar import ADB, FLUTTER, adb, adb_shell, calistir, kanit_yaz, mesaj, yokla  # noqa: E402

KOK = r"C:\dev\Momentum"
BURASI = os.path.dirname(os.path.abspath(__file__))
PID_DOSYASI = os.path.join(BURASI, "_backend.pid")


def _docker_healthy_mi():
    kod, out, err = calistir(["docker", "inspect", "--format", "{{.State.Health.Status}}", "momentum-postgres"])
    return out.strip() if kod == 0 else None


def docker_baslat():
    gunluk = [mesaj("① docker start momentum-postgres")]
    kod, out, err = calistir(["docker", "start", "momentum-postgres"])
    gunluk.append(mesaj("  exit=%d out=%r err=%r" % (kod, out.strip(), err.strip())))
    kod2, out2, err2 = calistir(["docker", "ps", "-a", "--filter", "name=momentum-postgres"])
    gunluk.append(mesaj("  docker ps -a:\n" + out2))

    yokla_kod, sonuc, yokla_gunluk = yokla(
        "momentum-postgres healthy", _docker_healthy_mi,
        aralik_sn=2, tavan_deneme=30, gecme_fn=lambda s: s == "healthy")
    gunluk += yokla_gunluk
    kanit_yaz(os.path.join(BURASI, "01-ortam-docker.txt"), gunluk)
    if yokla_kod != 0:
        print("DUR -- momentum-postgres healthy OLMADI (yedek ayak: pg_isready dene)")
        kod3, out3, err3 = calistir(["docker", "exec", "momentum-postgres", "pg_isready", "-U", "momentum"])
        print("  pg_isready -> exit=%d %s" % (kod3, out3.strip() or err3.strip()))
        return 3
    print("HAZIR -- momentum-postgres healthy")
    return 0


def backend_baslat():
    gunluk = [mesaj("② backend baslatiliyor -- AYRI surecte, env Python subprocess.Popen(env=) ile")]
    conn = "Host=localhost;Port=5432;Database=momentum;Username=momentum;Password=momentum_dev"
    gunluk.append(mesaj("  baglanti dizesi (docker inspect ile TEYIT EDILDI): %s" % conn))
    env = dict(os.environ)
    env["ASPNETCORE_ENVIRONMENT"] = "Development"
    env["ASPNETCORE_URLS"] = "http://0.0.0.0:5298"
    env["ConnectionStrings__Momentum"] = conn

    log_yolu = os.path.join(BURASI, "09-backend-log.txt")
    log_dosyasi = open(log_yolu, "wb")  # ikili -- UTF-8 kacislari icin coz*me* yapilmaz, ham byte akisi
    api_dizini = os.path.join(KOK, "src", "backend", "Momentum.Api")
    gunluk.append(mesaj("  cwd=%s" % api_dizini))
    p = subprocess.Popen(
        ["dotnet", "run", "--no-launch-profile"],
        cwd=api_dizini, env=env, stdout=log_dosyasi, stderr=subprocess.STDOUT,
        creationflags=subprocess.CREATE_NEW_PROCESS_GROUP,
    )
    with open(PID_DOSYASI, "w", encoding="utf-8") as f:
        f.write(str(p.pid))
    gunluk.append(mesaj("  baslatildi -- PID=%d, log=%s, pid dosyasi=%s" % (p.pid, log_yolu, PID_DOSYASI)))
    kanit_yaz(os.path.join(BURASI, "02-backend-baslatma.txt"), gunluk)
    return p.pid


def _bind_adresi_olc():
    kod, out, err = calistir(["cmd", "/c", "netstat -ano | findstr :5298"], zaman_asimi=15)
    return out


def backend_hazir_mi_yokla():
    gunluk = [mesaj("③ backend hazir olma yoklamasi -- PORTLA DEGIL, /health/live+ready+v1/sync ile")]

    # AŞAMA 1: bind adresi ORTAYA CIKANA kadar YOKLANIR (dotnet run derleme +
    # baslatma icin birkac saniye ister -- ILK OLCUMDE gormemek BASARISIZLIK
    # DEGIL, henuz baslamamis olmaktir; bu yuzden TEK CEKIMLIK degil YOKLAMALI).
    #
    # 🔴 BULUNUP DUZELTILEN UCUNCU CANLI HATA (bu turda): substring arama
    # LISTENING/ESTABLISHED ayrimi YAPMIYORDU -- bir istemci (tuzak_api34,
    # onceki turdan hala acik) 10.0.2.2:5298'e baglaninca netstat'ta
    # "127.0.0.1:5298 ... ESTABLISHED" satiri olusuyor; substring testi bunu
    # "127.0.0.1'e bagli, DUR" sanip GERCEKTEN 0.0.0.0'da LISTENING olan
    # backend'i SAHTE KIRMIZI ile durduruyordu (canli olcumde yakalandi:
    # 09-backend-log.txt "Now listening on: http://0.0.0.0:5298" derken
    # netstat ayni anda 0.0.0.0 LISTENING + uc ayri 127.0.0.1 ESTABLISHED
    # satiri gosteriyordu). Duzeltme: sokme()'nin listening_yok_mu() ile
    # AYNI disiplin -- yalniz LISTENING satirlari sayilir.
    def bind_durumu():
        out = _bind_adresi_olc()
        listening = [s for s in out.splitlines() if "LISTENING" in s]
        if any("0.0.0.0:5298" in s for s in listening):
            return "0.0.0.0"
        if any("127.0.0.1:5298" in s for s in listening):
            return "127.0.0.1"
        return None  # henuz dinlemiyor -- yokla devam eder

    yokla_kod1, bind_sonuc, yokla_gunluk1 = yokla(
        "port :5298 dinlemeye basladi (0.0.0.0 BEKLENIR)", bind_durumu,
        aralik_sn=2, tavan_deneme=30, gecme_fn=lambda s: s is not None)
    gunluk += yokla_gunluk1
    if yokla_kod1 != 0:
        gunluk.append(mesaj("  KIRMIZI: :5298 HIC dinlemeye baslamadi (dotnet run cokmus olabilir -- 09-backend-log.txt'e bak)"))
        kanit_yaz(os.path.join(BURASI, "03-ortam-backend-hazir.txt"), gunluk)
        return 3
    if bind_sonuc == "127.0.0.1":
        gunluk.append(mesaj("  KIRMIZI: 127.0.0.1:5298 (0.0.0.0 BEKLENIYORDU) -- emulator ULASAMAZ, DUR"))
        kanit_yaz(os.path.join(BURASI, "03-ortam-backend-hazir.txt"), gunluk)
        return 3
    gunluk.append(mesaj("  0.0.0.0:5298 dinliyor -- devam"))
    kod_poz, out_poz, err_poz = calistir(["cmd", "/c", "netstat -ano | findstr :5432"], zaman_asimi=15)
    gunluk.append(mesaj("  pozitif kontrol (baska bilinen port :5432 LISTENING mi):\n" + out_poz))

    # AŞAMA 2: portun dinlemesi DB'ye baglandigini KANITLAMAZ (ORTAM.md 41) --
    # _backend_dogrula.py ile /health/ready + /v1/sync YOKLANIR.
    def dogrula_kos():
        kod, out, err = calistir(
            ["python", os.path.join(KOK, "KANIT", "A11", "_backend_dogrula.py")], zaman_asimi=15)
        return out

    yokla_kod2, sonuc, yokla_gunluk2 = yokla(
        "backend hazir (_backend_dogrula.py -> HUKUM: BACKEND HAZIR)",
        dogrula_kos, aralik_sn=2, tavan_deneme=30,
        gecme_fn=lambda out: "HUKUM: BACKEND HAZIR" in (out or ""))
    gunluk += yokla_gunluk2
    kanit_yaz(os.path.join(BURASI, "03-ortam-backend-hazir.txt"), gunluk)
    return 0 if yokla_kod2 == 0 else 3


def emulator_baslat(avd_id):
    gunluk = [mesaj("emulator baslatiliyor: %s" % avd_id)]
    kod, out, err = calistir([FLUTTER, "emulators", "--launch", avd_id], zaman_asimi=30)
    gunluk.append(mesaj("  flutter emulators --launch %s -> exit=%d" % (avd_id, kod)))

    def seri_ve_boot():
        kod, out, err = adb(None, "devices")
        seriler = [s.split("\t")[0] for s in out.splitlines()[1:] if "\tdevice" in s]
        if not seriler:
            return None
        for seri in seriler:
            k2, o2, e2 = adb_shell(seri, ["getprop", "sys.boot_completed"])
            if o2.strip() == "1":
                k3, o3, e3 = adb_shell(seri, ["getprop", "ro.boot.qemu.avd_name"])
                return (seri, o3.strip())
        return None

    yokla_kod, sonuc, yokla_gunluk = yokla(
        "emulator boot_completed=1", seri_ve_boot, aralik_sn=3, tavan_deneme=40)
    gunluk += yokla_gunluk
    kanit_yaz(os.path.join(BURASI, "01-ortam-emulator-%s.txt" % avd_id), gunluk)
    if yokla_kod != 0:
        return 3, None
    print("HAZIR -- seri=%s, avd_name=%s" % sonuc)
    return 0, sonuc


DEV_USER_ID = "11111111-1111-1111-1111-111111111111"


def istemci_baslat(hedef, etiket, ek_bayraklar=None):
    """flutter run -d <hedef> AYRI surecte baslatir (GOREV-SS2 08 §2④ satir 111:
    'Uygulama BU TURDA, BU AGACTAN kurulur' -- stale APK olcumu YASAK).
    hedef 'chrome' ya da bir cihaz serisi (orn emulator-5554) olabilir.
    Her iki cihaz da AYNI DEV_USER_ID ile baslatilir (adim 0 madde 5: UserId
    AYNI, clientId FARKLI -- clientId cihaz kurulumunda kendiliginden ayrisir)."""
    gunluk = [mesaj("istemci baslatiliyor: hedef=%s etiket=%s" % (hedef, etiket))]
    bayraklar = ["-d", hedef, "--dart-define=DEV_USER_ID=%s" % DEV_USER_ID]
    if ek_bayraklar:
        bayraklar += ek_bayraklar
    gunluk.append(mesaj("  komut: %s run %s" % (FLUTTER, " ".join(bayraklar))))
    log_yolu = os.path.join(BURASI, "05-istemci-%s-log.txt" % etiket)
    log_dosyasi = open(log_yolu, "wb")
    istemci_dizini = os.path.join(KOK, "src", "client")
    p = subprocess.Popen(
        [FLUTTER, "run"] + bayraklar,
        cwd=istemci_dizini, stdin=subprocess.DEVNULL,
        stdout=log_dosyasi, stderr=subprocess.STDOUT,
        creationflags=subprocess.CREATE_NEW_PROCESS_GROUP,
    )
    pid_dosyasi = os.path.join(BURASI, "_istemci_%s.pid" % etiket)
    with open(pid_dosyasi, "w", encoding="utf-8") as f:
        f.write(str(p.pid))
    gunluk.append(mesaj("  baslatildi -- PID=%d, log=%s, pid dosyasi=%s" % (p.pid, log_yolu, pid_dosyasi)))

    def hazir_mi():
        if not os.path.isfile(log_yolu):
            return None
        with open(log_yolu, "rb") as f:
            icerik = f.read().decode("utf-8", "replace")
        if "Flutter run key commands" in icerik:
            return True
        if "Exception" in icerik or "FAILURE" in icerik:
            return "HATA -- log'a bak: " + log_yolu
        return None

    # 🔴 OLCULDU (bu turda, canli, cihaz B): SOGUK Gradle assembleDebug 210 sn
    # surdu -- ilk tavan (3sn*60=180sn) BUNU KACIRIYORDU (yanlis DUR verirdi).
    # aralik=5sn/tavan=90 -> 450 sn ust sinir, olculen degerin ~2 kati.
    yokla_kod, sonuc, yokla_gunluk = yokla(
        "istemci %s hazir (Flutter run key commands satiri)" % etiket, hazir_mi,
        aralik_sn=5, tavan_deneme=90, gecme_fn=lambda s: s is True)
    gunluk += yokla_gunluk
    kanit_yaz(os.path.join(BURASI, "01-istemci-%s-baslatma.txt" % etiket), gunluk)
    if yokla_kod != 0:
        print("DUR -- istemci %s hazir olmadi, %s dosyasina bak" % (etiket, log_yolu))
        return 3, p.pid
    print("HAZIR -- istemci %s (PID=%d)" % (etiket, p.pid))
    return 0, p.pid


def sokme():
    gunluk = [mesaj("§6 SOKME basliyor")]
    if os.path.isfile(PID_DOSYASI):
        with open(PID_DOSYASI, "r", encoding="utf-8") as f:
            pid = int(f.read().strip())
        gunluk.append(mesaj("  kayitli backend PID=%d -- Stop-Process deneniyor" % pid))
        kod, out, err = calistir(["taskkill", "/PID", str(pid), "/T", "/F"], zaman_asimi=15)
        gunluk.append(mesaj("  taskkill /PID %d /T /F -> exit=%d out=%r err=%r" % (pid, kod, out.strip(), err.strip())))
    else:
        gunluk.append(mesaj("  _backend.pid YOK -- backend bu surucuyle baslatilmamis olabilir"))

    # 🔴 OLCULDU (bu turda, canli): sureç oldurulduktan SONRA bile netstat
    # ESKI baglantilarin TIME_WAIT/SYN_SENT kalintisini dakikalarca gosterir
    # -- bu NORMAL TCP davranisidir ve YENI bir dinleyicinin BAGLANMASINI
    # ENGELLEMEZ. "BOS" olcutu "hic satir yok" DEGIL, "LISTENING satiri yok"
    # olmalidir -- verify.ps1'in MSB3026 riski dosya kilidiyle ilgilidir
    # (surec halen yasiyorsa), portun TIME_WAIT'iyle DEGIL.
    def listening_yok_mu():
        out = _bind_adresi_olc()
        listening_satirlari = [s for s in out.splitlines() if "LISTENING" in s]
        return (out, listening_satirlari)

    yokla_kod, sonuc, yokla_gunluk = yokla(
        "netstat :5298 -- LISTENING satiri YOK (TIME_WAIT kalintisi KABUL)",
        listening_yok_mu, aralik_sn=2, tavan_deneme=15,
        gecme_fn=lambda t: len(t[1]) == 0)
    gunluk += yokla_gunluk
    kanit_yaz(os.path.join(BURASI, "08-sokme.txt"), gunluk)
    return 0 if yokla_kod == 0 else 3


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("KULLANIM: python ortam_kur.py {docker|backend|emulator <avd>|sokme}")
        sys.exit(2)
    komut = sys.argv[1]
    if komut == "docker":
        sys.exit(docker_baslat())
    elif komut == "backend":
        backend_baslat()
        sys.exit(backend_hazir_mi_yokla())
    elif komut == "emulator":
        kod, sonuc = emulator_baslat(sys.argv[2])
        sys.exit(kod)
    elif komut == "sokme":
        sys.exit(sokme())
    elif komut == "istemci":
        hedef = sys.argv[2]
        etiket = sys.argv[3]
        ek = sys.argv[4:] if len(sys.argv) > 4 else None
        kod, pid = istemci_baslat(hedef, etiket, ek)
        sys.exit(kod)
    else:
        print("BILINMEYEN KOMUT: %s" % komut)
        sys.exit(2)

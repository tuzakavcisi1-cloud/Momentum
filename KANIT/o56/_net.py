# -*- coding: utf-8 -*-
"""Oturum 56 -- cihaz agini KAPAT/AC ve GERCEKTEN kapandigini/acildigini OLC.
A11 dersi (KANIT/cevrimdisi-senkron/A11-KABUL-7-OZET.md): `airplane_mode_on`
bir BAYRAKTIR, olcum degildir; gercek dogrulama `toybox nc` probuyla yapilir.
Kullanim: python _net.py <seri> <kapat|ac|olc> [hedef_ip]"""
import subprocess, sys, time
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
ADB = r"C:\Users\gulci\AppData\Local\Android\Sdk\platform-tools\adb.exe"


def adb(seri, *args, timeout=40):
    # 🔴 stdin=DEVNULL ZORUNLU: basarili bir `nc` baglantisi stdin'i bekler ve
    # subprocess'i 40 s ASAR (oturum 56'da olculdu -- probun kendi kusuruydu).
    p = subprocess.run([ADB, "-s", seri] + list(args), capture_output=True,
                       stdin=subprocess.DEVNULL,
                       text=True, encoding="utf-8", errors="replace", timeout=timeout)
    return p.returncode, ((p.stdout or "") + (p.stderr or "")).strip()


def prob(seri, ip, port="5298", tekrar=3):
    """toybox nc probu. Doner: True = ULASILIYOR, False = ULASILAMIYOR."""
    sonuc = []
    for _ in range(tekrar):
        kod, cikti = adb(seri, "shell", "toybox", "nc", "-w", "2", ip, port)
        sonuc.append((kod, cikti[:80]))
        time.sleep(0.5)
    ulasiliyor = any(k == 0 for k, _ in sonuc)
    print("  PROB %s -> %s:%s  ham=%s  ==> %s" % (
        seri, ip, port, sonuc, "ULASILIYOR" if ulasiliyor else "ULASILAMIYOR"))
    return ulasiliyor


if __name__ == "__main__":
    seri, mod = sys.argv[1], sys.argv[2]
    ip = sys.argv[3] if len(sys.argv) > 3 else "10.0.2.2"
    if mod == "kapat":
        for k in (("svc", "wifi", "disable"), ("svc", "data", "disable")):
            print("  %s -> %s" % (" ".join(k), adb(seri, "shell", *k)))
        time.sleep(3)
        u = prob(seri, ip)
        print("HUKUM: %s" % ("KIRMIZI -- HALA ULASILIYOR, cevrimdisi DEGIL" if u
                            else "YESIL -- CEVRIMDISI (olculdu, bayrakla degil)"))
        sys.exit(1 if u else 0)
    if mod == "ac":
        for k in (("svc", "wifi", "enable"), ("svc", "data", "enable")):
            print("  %s -> %s" % (" ".join(k), adb(seri, "shell", *k)))
        for i in range(20):
            time.sleep(3)
            if prob(seri, ip):
                print("HUKUM: YESIL -- CEVRIMICI (%d. yoklamada, ~%d s)" % (i + 1, (i + 1) * 3))
                sys.exit(0)
        print("HUKUM: KIRMIZI -- 60 s'de baglanti geri gelmedi")
        sys.exit(1)
    if mod == "olc":
        sys.exit(0 if prob(seri, ip) else 1)

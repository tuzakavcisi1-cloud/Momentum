# -*- coding: utf-8 -*-
"""IS-EMRI-o70 -- SS2 kriter 8 uctan uca surucusunun ORTAK yardimcilari.

🔴 K175(2) YASAGI bu dosya icin gecerli DEGIL -- yasak yalniz GOREV_CLAUDE_CODE/,
docs/ADR/, araclar/ icindir; taban 32*6*41 KORUNUR (bu dosya KANIT/SS2/T8-uctan-uca/
altindadir).

Bu modul, KANIT/SS2/09-DENETIM-TUR2...md'nin "Ayrica (major sinifi)" bolumunun ve
KANIT/SS2/10-OLCUM-ERRATUM...md'nin ONERDIGI onlemlerin YAZILI hali:
  - $FLUTTER / $ADB HER cagrida TAM YOLLA (ORTAM.md/DURUM.md).
  - Kanit UTF-8+LF, ikili modda yazilir (Out-File BOM+CRLF uretiyor -- item 3).
  - adb shell ciktisi \r icerebilir (item 4) -- HER cagriyi saran fonksiyon kirpiyor
    (bu makinede Python subprocess.run([...]) ile \r GORULMEDI -- olculdu, KANIT/SS2/
    T8-uctan-uca/01-*.md -- ama savunmaci kirpma UCRETSIZ, kaldiriliyor).
  - HER mesaj HH:mm:ss damgasi tasir (el sikisma protokolu).
  - Sabit sleep YOK -- yokla() fonksiyonu ARALIK+TAVAN ile poll eder.
"""
import subprocess
import sys
import time
from datetime import datetime

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.stderr.reconfigure(encoding="utf-8", errors="replace")

FLUTTER = r"C:\src\flutter\bin\flutter.bat"
ADB = r"C:\Users\gulci\AppData\Local\Android\Sdk\platform-tools\adb.exe"
DOCKER = "docker"  # PATH'te var, olculdu (oturum 69: "Docker version 29.6.2")


def damga():
    """HH:mm:ss -- CIHAZDAN (ORTAM.md: tarih ortam beyanindan OKUNMAZ)."""
    return datetime.now().strftime("%H:%M:%S")


def mesaj(s):
    """El sikisma protokolu icin damgali satir -- STDOUT'a VE cagiranin
    biriktirdigi kanit metnine ayni bicimde yazilir."""
    satir = "[%s] %s" % (damga(), s)
    print(satir)
    return satir


def kanit_yaz(yol, satirlar):
    """UTF-8, LF, BOM'SUZ -- ikili modda yazar (item 3: PowerShell 5.1'in
    Out-File/Tee-Object'i BOM+CRLF/UTF-16LE uretiyor, bu YASAKTIR)."""
    metin = "\n".join(satirlar) + "\n"
    with open(yol, "wb") as f:
        f.write(metin.encode("utf-8"))


def calistir(argv, girdi=None, zaman_asimi=30):
    """subprocess.run sarmalayici -- LISTE argumanla cagirir (MSYS/Git Bash
    yol bozma sorunundan BAGIMSIZ -- olculdu, 01-*.md'de kanitli). \r
    savunmaci olarak kirpilir."""
    r = subprocess.run(
        argv, input=girdi, capture_output=True, text=True,
        encoding="utf-8", errors="replace", timeout=zaman_asimi,
    )
    return r.returncode, (r.stdout or "").replace("\r", ""), (r.stderr or "").replace("\r", "")


def adb(seri, *args, zaman_asimi=15):
    """`adb -s <seri> <args...>` -- TAM YOL, LISTE argumanla."""
    argv = [ADB]
    if seri:
        argv += ["-s", seri]
    argv += list(args)
    return calistir(argv, zaman_asimi=zaman_asimi)


def adb_shell(seri, komut_listesi, zaman_asimi=15):
    """`adb -s <seri> shell <komut...>` -- komut TEK bir dize olarak DEGIL,
    LISTE olarak verilir (adb shell kendi icinde birlestirir); boylece ne
    Python ne MSYS bir kabuk ayristirmasi yapmaz."""
    return adb(seri, "shell", *komut_listesi, zaman_asimi=zaman_asimi)


def yokla(aciklama, olc_fn, aralik_sn, tavan_deneme, gecme_fn=None):
    """Sabit sleep DEGIL -- ARALIK saniyede bir `olc_fn()` cagirir, sonucu
    `gecme_fn` (varsayilan: dogruluk degeri) ile sinar. TAVAN asilirsa
    (kod, None) doner (kod=3, ORTAM HATASI sinifi). Her deneme kanita basilir."""
    if gecme_fn is None:
        gecme_fn = bool
    baslangic = time.time()
    gunluk = [mesaj("YOKLAMA basladi: %s (aralik=%ds, tavan=%d deneme)" % (
        aciklama, aralik_sn, tavan_deneme))]
    for deneme in range(1, tavan_deneme + 1):
        sonuc = olc_fn()
        gecen = time.time() - baslangic
        gunluk.append(mesaj("  [deneme %d/%d, %.1fsn] %r" % (
            deneme, tavan_deneme, gecen, sonuc)))
        if gecme_fn(sonuc):
            gunluk.append(mesaj("YOKLAMA GECTI: %s (%.1f sn'de)" % (aciklama, gecen)))
            return 0, sonuc, gunluk
        if deneme < tavan_deneme:
            time.sleep(aralik_sn)
    gunluk.append(mesaj("YOKLAMA TAVANA CARPTI: %s -- DUR" % aciklama))
    return 3, None, gunluk


class DurHatasi(Exception):
    """Is emrinin PAZARLIKSIZ kurali: 'herhangi biri saglanmazsa DURULUR,
    ham cikti yazilir, ONUR'A DONULUR. Sessizce ikinci bir yola gecilmez.'
    Bu istisna o kuralin KOD karsiligidir -- yakalanmaz, surucuyu durdurur."""
    def __init__(self, gerekce, kanit_satirlari=None):
        super().__init__(gerekce)
        self.gerekce = gerekce
        self.kanit_satirlari = kanit_satirlari or []

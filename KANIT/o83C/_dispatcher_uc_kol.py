# -*- coding: utf-8 -*-
"""IS-EMRI-o83-C s1 -- Dispatcher AYIRT EDICI OLCUM: 3 kol x 5 kosum, YALNIZ
Cursor_correctness_is_unaffected_by_concurrent_dispatch_single_owner.

ONCE OLCER SONRA DUZELTIR (s0): bu betik URUN KODUNA DOKUNMAZ, testin
IDDIASINI DEGISTIRMEZ -- yalniz TestSupport.cs'teki havuz ayarlarini
(A/B/C) gecici olarak degistirip GERI YAZAR (bayt-duzeyi, sha256 ile
ozdeslik dogrulanir -- KANIT/A11/_mutant_kosucu.py deseni, git restore
KULLANILMAZ).
"""
import hashlib
import io
import os
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

KOK = r"C:\dev\Momentum"
KANIT = os.path.join(KOK, "KANIT", "o83C")
TRX_DIZIN = os.path.join(KANIT, "trx")
TS = os.path.join(KOK, "tests", "Momentum.Persistence.Tests", "TestSupport.cs")
TESTLER_CSPROJ = os.path.join(KOK, "tests", "Momentum.Persistence.Tests", "Momentum.Persistence.Tests.csproj")
FILTRE = "FullyQualifiedName~Cursor_correctness_is_unaffected_by_concurrent_dispatch_single_owner"
TEST_ADI = "Cursor_correctness_is_unaffected_by_concurrent_dispatch_single_owner"

TRX_NS = "{http://microsoft.com/schemas/VisualStudio/TeamTest/2010}"


def oku(p):
    with io.open(p, "rb") as f:
        return f.read()


def yaz(p, b):
    with io.open(p, "wb") as f:
        f.write(b)


def sha(b):
    return hashlib.sha256(b).hexdigest()[:12].upper()


def dotnet_test_trx(etiket, kosum_no):
    trx_adi = "%s-%d.trx" % (etiket, kosum_no)
    trx_yolu = os.path.join(TRX_DIZIN, trx_adi)
    if os.path.isfile(trx_yolu):
        os.remove(trx_yolu)
    cmd = [
        "dotnet", "test", TESTLER_CSPROJ,
        "--filter", FILTRE,
        "--logger", "trx;LogFileName=%s" % trx_adi,
        "--results-directory", TRX_DIZIN,
    ]
    ortam = dict(os.environ)
    ortam["MOMENTUM_KANIT_DIZIN"] = KANIT
    p = subprocess.run(cmd, cwd=KOK, capture_output=True, text=True,
                        encoding="utf-8", errors="replace", timeout=120, env=ortam)
    konsol = (p.stdout or "") + (p.stderr or "")
    sonuc = "BILINMIYOR"
    if os.path.isfile(trx_yolu):
        agac = ET.parse(trx_yolu)
        for eleman in agac.getroot().iter(TRX_NS + "UnitTestResult"):
            ad_test = eleman.get("testName", "")
            if ad_test.rsplit(".", 1)[-1] == TEST_ADI:
                sonuc = eleman.get("outcome", "BILINMIYOR")
    return p.returncode, sonuc, konsol


def kanit_yaz(ad, metin):
    temiz = metin.replace("\r\n", "\n").replace("\r", "\n")
    with io.open(os.path.join(KANIT, "_ham-%s.txt" % ad), "w",
                 encoding="utf-8", errors="replace", newline="\n") as f:
        f.write(temiz)


# ============================ KOL TANIMLARI ================================
# Bugunku (B) govde -- betik bunu OKUYARAK dogrular, elle YAZMAZ (B zaten
# dosyanin dinlenme durumudur).
B_PARCASI = (
    "        var connectionString = new NpgsqlConnectionStringBuilder(fixture.Container.GetConnectionString())\n"
    "        {\n"
    "            Database = databaseName,\n"
    "            MaxPoolSize = 4, // sirali kosumda fazlasi gerekmiyor\n"
    "            ConnectionIdleLifetime = 1, // saniye -- bosta baglanti budanir\n"
    "            ConnectionPruningInterval = 1,\n"
    "        }.ConnectionString;\n"
)

# Kol A: kelepce YOK (o83-B ONCESI govde).
A_PARCASI = (
    "        var connectionString = new NpgsqlConnectionStringBuilder(fixture.Container.GetConnectionString())\n"
    "        {\n"
    "            Database = databaseName,\n"
    "        }.ConnectionString;\n"
)

# Kol C: kelepce var, MaxPoolSize=50.
C_PARCASI = (
    "        var connectionString = new NpgsqlConnectionStringBuilder(fixture.Container.GetConnectionString())\n"
    "        {\n"
    "            Database = databaseName,\n"
    "            MaxPoolSize = 50, // o83-C H2 olcumu -- gecici\n"
    "            ConnectionIdleLifetime = 1, // saniye -- bosta baglanti budanir\n"
    "            ConnectionPruningInterval = 1,\n"
    "        }.ConnectionString;\n"
)


def kol_kos(etiket, govde_parcasi, taban, orijinal):
    """govde_parcasi=None ise dosyaya DOKUNULMAZ (Kol B, bugunku durum).
    Degilse B_PARCASI -> govde_parcasi bayt-duzeyinde degistirilir, 5 kosum
    yapilir, sonra taban'a (orijinal bayt) GERI YAZILIR -- HATA/ISTISNA
    OLSA BILE (try/finally): tek bir kosumun cokmesi dosyayi YAMALI
    BIRAKMAZ."""
    sonuclar = []
    if govde_parcasi is not None:
        eb = B_PARCASI.encode("utf-8")
        nb = govde_parcasi.encode("utf-8")
        n = taban.count(eb)
        if n != 1:
            return None, "ESLESME SAYISI %d (1 BEKLENIR)" % n
        yaz(TS, taban.replace(eb, nb))

    try:
        for i in range(1, 6):
            rc, sonuc, konsol = dotnet_test_trx(etiket, i)
            sonuclar.append(sonuc)
            kanit_yaz("%s-%d" % (etiket, i), "KOL %s KOSUM %d\nEXIT=%d SONUC=%s\n\n%s" % (etiket, i, rc, sonuc, konsol[-3000:]))
            print("  kol %s kosum %d -> %s" % (etiket, i, sonuc))
            sys.stdout.flush()
    finally:
        if govde_parcasi is not None:
            yaz(TS, taban)  # GERI YAZ (orijinal bayt, tam olarak) -- ISTISNA OLSA BILE
            simdi = oku(TS)
            ozdes = simdi == taban
            if not ozdes:
                sonuclar.append("GERI-ALMA-BOZUK")
            print("  [geri yazildi] ozdes(tabanla)=%s" % ozdes)
            sys.stdout.flush()

    return sonuclar, None


KOLLAR = {
    "A": ("kelepce YOK", A_PARCASI),
    "B": ("MaxPoolSize=4, bugunku", None),
    "C": ("MaxPoolSize=50", C_PARCASI),
}


def tek_kol_kos(harf):
    os.makedirs(TRX_DIZIN, exist_ok=True)
    taban = oku(TS)
    aciklama, parca = KOLLAR[harf]

    if B_PARCASI.encode("utf-8") not in taban:
        print("[DUR] B_PARCASI dosyada BULUNAMADI -- olcum BASLAMADI (govde beklenenden farkli).")
        return 3

    print("Kol %s (%s) basliyor..." % (harf, aciklama))
    sonuc, hata = kol_kos(harf, parca, taban, taban)
    if hata:
        print("[DUR] Kol %s: %s" % (harf, hata))
        return 3
    gecen = sonuc.count("Passed")
    satir = "KOL %s (%s) : %s -> %d/5 GECTI" % (harf, aciklama, sonuc, gecen)
    print(satir)

    son = oku(TS)
    ozdes = son == taban
    print("Kosum sonrasi dosya sha8=%s ozdes(tabanla)=%s" % (sha(son), ozdes))

    with io.open(os.path.join(KANIT, "_sonuc-kol-%s.txt" % harf), "w", encoding="utf-8", newline="\n") as f:
        f.write(satir + "\n")
        f.write("ham liste: %r\n" % sonuc)
        f.write("dosya ozdes(kosum sonrasi=taban): %s\n" % ozdes)

    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2 or sys.argv[1] not in KOLLAR:
        print("kullanim: python _dispatcher_uc_kol.py [A|B|C]")
        sys.exit(2)
    sys.exit(tek_kol_kos(sys.argv[1]))

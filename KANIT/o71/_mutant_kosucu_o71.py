# -*- coding: utf-8 -*-
"""o71 IS-EMRI SS3 -- M231/M231b mutant kosucusu (Claude Code'un KENDI kosumu).

Ikili yedek -> yama BAYT DUZEYINDE uygula -> tests/Momentum.Api.Tests/
CorpBasligiTestleri kosulur (TRX ile TEK TEK test adi + sonuc okunur, sadece
toplam sayi degil) -> yedekten GERI YAZ -> sha256 ile BAYT-OZDESLIK dogrula.
`git restore` KULLANILMAZ (ORTAM.md: core.autocrlf/eol=lf aktif, restore
bayt-ozdes DEGIL).
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
KANIT = os.path.join(KOK, "KANIT", "o71")
TRX_DIZIN = os.path.join(KANIT, "trx")
TESTLER_CSPROJ = os.path.join(KOK, "tests", "Momentum.Api.Tests", "Momentum.Api.Tests.csproj")

IS = os.path.join(KOK, "src", "backend", "Momentum.Api", "Web", "IstemciServisi.cs")
IB = os.path.join(KOK, "src", "backend", "Momentum.Api", "Web", "IzolasyonBasliklari.cs")

TRX_ISIM_NS = "{http://microsoft.com/schemas/VisualStudio/TeamTest/2010}"


def oku(p):
    with io.open(p, "rb") as f:
        return f.read()


def yaz(p, b):
    with io.open(p, "wb") as f:
        f.write(b)


def sha(b):
    return hashlib.sha256(b).hexdigest()[:8].upper()


def dotnet_test_trx(ad):
    trx_adi = "%s.trx" % ad
    trx_yolu = os.path.join(TRX_DIZIN, trx_adi)
    if os.path.isfile(trx_yolu):
        os.remove(trx_yolu)
    cmd = [
        "dotnet", "test", TESTLER_CSPROJ,
        "--filter", "FullyQualifiedName~CorpBasligiTestleri",
        "--logger", "trx;LogFileName=%s" % trx_adi,
        "--results-directory", TRX_DIZIN,
    ]
    p = subprocess.run(cmd, cwd=KOK, capture_output=True, text=True,
                        encoding="utf-8", errors="replace", timeout=180)
    konsol = (p.stdout or "") + (p.stderr or "")
    sonuclar = {}
    if os.path.isfile(trx_yolu):
        agac = ET.parse(trx_yolu)
        for eleman in agac.getroot().iter(TRX_ISIM_NS + "UnitTestResult"):
            ad_test = eleman.get("testName", "")
            # testName "Momentum.Api.Tests.CorpBasligiTestleri.Yontem" bicimindedir -- son parcayi al
            kisa_ad = ad_test.rsplit(".", 1)[-1]
            sonuclar[kisa_ad] = eleman.get("outcome", "")
    return p.returncode, sonuclar, konsol, trx_yolu


def kanit_yaz(ad, metin):
    # newline="\n" + \r\n normalizasyonu: metin subprocess'ten YAKALANAN konsol
    # ciktisi (dogal CRLF) icerir; ikili yazim olmadan text-modun kendi
    # cevirisine guvenmek CRLF sizdirir (K60/dosya-kimlik dersi).
    temiz = metin.replace("\r\n", "\n").replace("\r", "\n")
    with io.open(os.path.join(KANIT, "03-MUTANT-%s.txt" % ad), "w",
                 encoding="utf-8", errors="replace", newline="\n") as f:
        f.write(temiz)


TUM_TESTLER = [
    "Statik_dosya_CORP_same_origin_tasir",
    "Health_live_CORP_tasimaz",
    "Sync_ucnoktasi_CORP_tasimaz",
    "Statik_yanitta_COOP_ve_COEP_degismez",
    "Health_yanitinda_COOP_ve_COEP_degismez",
    "Sync_yanitinda_COOP_ve_COEP_degismez",
]

# ============================ MUTANT TANIMLARI ================================
# (ad, kapi, dosya, eski, yeni, beklenen_basarisiz_kume)

M231_ESKI = (
    "            ServeUnknownFileTypes = true,\n"
    "            DefaultContentType = \"application/octet-stream\",\n"
    "            // D-W3-4 (GOREV-W3 SS3, kilitli karar, o71): CORP YALNIZ statik yanitlara -- bu\n"
    "            // secenekler hem UseStaticFiles hem MapFallbackToFile'da kullanildigi icin SPA\n"
    "            // geri-dusus belgesi de statiktir ve CORP alir; bu BILINCLIDIR. /v1/**, /health/**,\n"
    "            // /hubs/**, /scalar/** bu secenekleri hic gormez, CORP yazilmaz.\n"
    "            OnPrepareResponse = baglam =>\n"
    "                baglam.Context.Response.Headers[IzolasyonBasliklari.CorpAdi] = IzolasyonBasliklari.CorpDegeri,\n"
    "        };\n"
)
M231_YENI = (
    "            ServeUnknownFileTypes = true,\n"
    "            DefaultContentType = \"application/octet-stream\",\n"
    "            // MUTANT M231: OnPrepareResponse SATIRI SILINDI -- CORP artik HICBIR YERDE yazilmiyor\n"
    "        };\n"
)

M231b_ESKI = (
    "        return app.Use(async (context, next) =>\n"
    "        {\n"
    "            context.Response.OnStarting(static state =>\n"
    "            {\n"
    "                var yanit = ((HttpContext)state).Response;\n"
    "                yanit.Headers[CoopAdi] = CoopDegeri;\n"
    "                yanit.Headers[CoepAdi] = CoepDegeri;\n"
    "                return Task.CompletedTask;\n"
    "            }, context);\n"
)
M231b_YENI = (
    "        return app.Use(async (context, next) =>\n"
    "        {\n"
    "            context.Response.OnStarting(static state =>\n"
    "            {\n"
    "                var yanit = ((HttpContext)state).Response;\n"
    "                yanit.Headers[CoopAdi] = CoopDegeri;\n"
    "                yanit.Headers[CoepAdi] = CoepDegeri;\n"
    "                yanit.Headers[CorpAdi] = CorpDegeri; // MUTANT M231b: CORP GLOBAL hale getirildi\n"
    "                return Task.CompletedTask;\n"
    "            }, context);\n"
)

MUTANTLAR = [
    ("M231", "o71/G-CORP-a", IS, M231_ESKI, M231_YENI,
     {"Statik_dosya_CORP_same_origin_tasir"}),
    ("M231b", "o71/G-CORP-b,c", IB, M231b_ESKI, M231b_YENI,
     {"Health_live_CORP_tasimaz", "Sync_ucnoktasi_CORP_tasimaz"}),
]


def main():
    os.makedirs(TRX_DIZIN, exist_ok=True)
    baslangic = {p: oku(p) for p in (IS, IB)}
    ozet = []
    ozet.append("o71 IS-EMRI SS3 -- M231/M231b mutant kosumu (Claude Code)")
    for p, b in baslangic.items():
        ozet.append("  TABAN sha8=%s %6d b  %s" % (sha(b), len(b), os.path.basename(p)))

    # --- 0) TEMIZ TABAN: 6 testin 6'si da GECMELI ---
    rc0, sonuc0, konsol0, trx0 = dotnet_test_trx("00-TEMIZ-ONCE")
    kanit_yaz("00-TEMIZ-ONCE", "EXIT=%d\nTRX=%s\nSONUCLAR=%r\n\n%s" % (rc0, trx0, sonuc0, konsol0))
    beklenmeyen = [t for t in TUM_TESTLER if sonuc0.get(t) != "Passed"]
    ozet.append("  TEMIZ-ONCE EXIT=%d sonuclar=%r" % (rc0, sonuc0))
    if beklenmeyen:
        ozet.append("  [DUR] temiz taban KIRMIZI (%s) -- mutant kosumu BASLAMADI." % beklenmeyen)
        print("\n".join(ozet))
        return 3

    # --- 1) MUTANTLAR ---
    gecen = 0
    for ad, kapi, yol, eski, yeni, beklenen_basarisiz in MUTANTLAR:
        ham = baslangic[yol]
        eb = eski.encode("utf-8")
        nb = yeni.encode("utf-8")
        n = ham.count(eb)
        hata = None
        if n != 1:
            hata = "ESLESME SAYISI %d (1 BEKLENIR) -- %s" % (n, os.path.basename(yol))
        else:
            yaz(yol, ham.replace(eb, nb))

        rc, sonuc, konsol, trx = (None, {}, "", None)
        if hata is None:
            rc, sonuc, konsol, trx = dotnet_test_trx(ad)

        # --- GERI ALMA + BAYT-OZDESLIK ---
        yaz(yol, ham)
        simdi = oku(yol)
        ozdes = simdi == ham
        if not ozdes:
            hata = (hata or "") + " GERI-ALMA-BOZUK:%s" % yol

        if hata:
            hukum = "ORTAM HATASI: %s" % hata
            ok = False
        else:
            basarisiz_olanlar = {t for t in TUM_TESTLER if sonuc.get(t) != "Passed"}
            ok = basarisiz_olanlar == beklenen_basarisiz
            hukum = ("ISIRDI (beklenen kume birebir: %s)" % sorted(beklenen_basarisiz)
                      if ok else
                      "KUSUR -- beklenen=%s gercek=%s" % (sorted(beklenen_basarisiz), sorted(basarisiz_olanlar)))
        if ok:
            gecen += 1

        satir = "  %-6s %-16s eslesme=%s ozdes=%s -> %s" % (ad, kapi, n, ozdes, hukum)
        ozet.append(satir)
        print(satir)
        sys.stdout.flush()

        govde = [
            "MUTANT %s -- kapi %s" % (ad, kapi),
            "dosya: %s" % yol,
            "eslesme sayisi: %d" % n,
            "geri alma bayt-ozdes: %s (sha8=%s)" % (ozdes, sha(simdi)),
            "beklenen basarisiz kume: %s" % sorted(beklenen_basarisiz),
            "gercek TRX sonuclari: %r" % sonuc,
            "HUKUM: %s" % hukum,
            "",
            "=== dotnet test EXIT=%r ===" % rc,
            konsol[-4000:] if konsol else "(kosulmadi -- eslesme hatasi)",
        ]
        kanit_yaz(ad, "\n".join(govde))

    # --- 2) TEMIZ KOSUM TEKRAR ---
    for p, b in baslangic.items():
        simdi = oku(p)
        ozet.append("  SON sha8=%s %6d b  %s  ozdes=%s"
                    % (sha(simdi), len(simdi), os.path.basename(p), simdi == b))
    rc9, sonuc9, konsol9, trx9 = dotnet_test_trx("99-TEMIZ-SONRA")
    kanit_yaz("99-TEMIZ-SONRA", "EXIT=%d\nTRX=%s\nSONUCLAR=%r\n\n%s" % (rc9, trx9, sonuc9, konsol9))
    ozet.append("  TEMIZ-SONRA EXIT=%d sonuclar=%r" % (rc9, sonuc9))
    temiz_sonra_tamam = all(sonuc9.get(t) == "Passed" for t in TUM_TESTLER)

    ozet.append("  ISIRAN MUTANT: %d/%d" % (gecen, len(MUTANTLAR)))
    metin = "\n".join(ozet)
    kanit_yaz("OZET", metin)
    print("\n" + metin)
    return 0 if (gecen == len(MUTANTLAR) and temiz_sonra_tamam) else 1


if __name__ == "__main__":
    sys.exit(main())

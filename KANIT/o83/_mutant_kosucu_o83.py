# -*- coding: utf-8 -*-
"""IS-EMRI-o83 -- F5 KILIDI mutantlari (Claude Code).

Referans kosucu: KANIT/o71/_mutant_kosucu_o71.py (TRX ile TEK TEK test adi+sonuc
okunur, sadece toplam sayi degil). Ikili yedek -> yama BAYT DUZEYINDE uygula ->
tests/Momentum.Persistence.Tests (gercek Postgres, Testcontainers) kosulur ->
yedekten GERI YAZ -> sha256 ile BAYT-OZDESLIK dogrula. `git restore` KULLANILMAZ
(core.autocrlf/eol=lf aktif, restore bayt-ozdes DEGIL).
"""
import hashlib
import io
import os
import subprocess
import sys
import xml.etree.ElementTree as ET

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

KOK = r"C:\dev\Momentum"
KANIT = os.path.join(KOK, "KANIT", "o83")
TRX_DIZIN = os.path.join(KANIT, "trx")
TESTLER_CSPROJ = os.path.join(KOK, "tests", "Momentum.Persistence.Tests", "Momentum.Persistence.Tests.csproj")

SCH = os.path.join(KOK, "src", "backend", "Momentum.Application", "Features", "Sync", "SyncCommandHandler.cs")
WM = os.path.join(KOK, "src", "backend", "Momentum.Application", "Features", "Sync", "WireMapping.cs")

TRX_ISIM_NS = "{http://microsoft.com/schemas/VisualStudio/TeamTest/2010}"

FILTRE = ("FullyQualifiedName~D9OwnerIdVisibilityTests"
          "|FullyQualifiedName~ScopeAndDriftAnchorTests")

TUM_TESTLER = [
    "D9_baslik_X_govde_actorId_Y_ise_satir_Xin_cekmesinde_gorunur_Yninkinde_gorunmez",
    "D9_outbox_owner_id_VE_actor_id_ikisi_de_artik_dogrulanan_aktorden_yazilir",
    "F5_pull_payloadindaki_WireOp_ActorId_de_authenticated_aktorden_gelir_govdeden_DEGIL",
    "D9_F5_outbox_owner_VE_actor_ikisi_de_authenticated_actorden_gelir_not_wire_actor",
]


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
        "--filter", FILTRE,
        "--logger", "trx;LogFileName=%s" % trx_adi,
        "--results-directory", TRX_DIZIN,
    ]
    # D9_outbox_owner_id_VE_actor_id_...(GOREV-slice-3d 8.2 deseni) MOMENTUM_KANIT_DIZIN'i sessizce
    # atlamiyor, ortam yoksa firlatiyor -- alt surece ACIKCA gecirilir (subprocess ortami miras ALMAZ).
    ortam = dict(os.environ)
    ortam["MOMENTUM_KANIT_DIZIN"] = KANIT
    p = subprocess.run(cmd, cwd=KOK, capture_output=True, text=True,
                        encoding="utf-8", errors="replace", timeout=180, env=ortam)
    konsol = (p.stdout or "") + (p.stderr or "")
    sonuclar = {}
    if os.path.isfile(trx_yolu):
        agac = ET.parse(trx_yolu)
        for eleman in agac.getroot().iter(TRX_ISIM_NS + "UnitTestResult"):
            ad_test = eleman.get("testName", "")
            kisa_ad = ad_test.rsplit(".", 1)[-1]
            sonuclar[kisa_ad] = eleman.get("outcome", "")
    return p.returncode, sonuclar, konsol, trx_yolu


def kanit_yaz(ad, metin):
    temiz = metin.replace("\r\n", "\n").replace("\r", "\n")
    with io.open(os.path.join(KANIT, "04-MUTANT-%s.txt" % ad), "w",
                 encoding="utf-8", errors="replace", newline="\n") as f:
        f.write(temiz)


# ============================ MUTANT TANIMLARI ================================

M_F5_1_ESKI = (
    "            // IS-EMRI-o83 F5 KILIDI: govdenin actorId iddiasi ARTIK YOK SAYILIR (D9'un onceki\n"
    "            // \"actor_id govdeden gelmeye devam eder\" beyanini SUPERSEDE eder -- yukaridaki yorum).\n"
    "            ActorId: authenticatedActorId,\n"
)
M_F5_1_YENI = (
    "            // MUTANT M-o83-F5-1: govdenin actorId iddiasi GERI GETIRILDI (D9'un ESKI davranisi).\n"
    "            ActorId: op.ActorId,\n"
)

M_F5_2_ESKI = (
    "        var clamped = op with\n"
    "        {\n"
    "            ActorId = authenticatedActorId,\n"
    "            OpHlc = Clamp(op.OpHlc),\n"
)
M_F5_2_YENI = (
    "        var clamped = op with\n"
    "        {\n"
    "            // MUTANT M-o83-F5-2: ActorId override SATIRI SILINDI -- payload govdenin actorId'sini yankilar.\n"
    "            OpHlc = Clamp(op.OpHlc),\n"
)

MUTANTLAR = [
    ("M-o83-F5-1", "F5/outbox-actor_id", SCH, M_F5_1_ESKI, M_F5_1_YENI,
     {"D9_outbox_owner_id_VE_actor_id_ikisi_de_artik_dogrulanan_aktorden_yazilir",
      "D9_F5_outbox_owner_VE_actor_ikisi_de_authenticated_actorden_gelir_not_wire_actor"}),
    ("M-o83-F5-2", "F5/pull-payload-actorId", WM, M_F5_2_ESKI, M_F5_2_YENI,
     {"F5_pull_payloadindaki_WireOp_ActorId_de_authenticated_aktorden_gelir_govdeden_DEGIL"}),
]


def main():
    os.makedirs(TRX_DIZIN, exist_ok=True)
    baslangic = {p: oku(p) for p in (SCH, WM)}
    ozet = []
    ozet.append("IS-EMRI-o83 -- F5 KILIDI M-o83-F5-1/2 mutant kosumu (Claude Code)")
    for p, b in baslangic.items():
        ozet.append("  TABAN sha8=%s %6d b  %s" % (sha(b), len(b), os.path.basename(p)))

    # --- 0) TEMIZ TABAN: 4 testin 4'u de GECMELI ---
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

        satir = "  %-11s %-24s eslesme=%s ozdes=%s -> %s" % (ad, kapi, n, ozdes, hukum)
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

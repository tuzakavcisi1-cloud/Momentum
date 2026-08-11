# -*- coding: utf-8 -*-
"""IS-EMRI-o70 -- SS2 kriter 8: ON KOSUL OLCUMLERI (Ö1-Ö7 + psql, KANIT/SS2/10
ERRATUM'una gore DUZELTILMIS -- eski Ö8/madde6/7/15 DUSTU, yerine psql geldi).

KULLANIM:
    python on_kosullar.py            -- GERCEK ortami olcer, 00-onkosul.txt yazar
    python on_kosullar.py --altin-kume  -- SENTETIK veriyle DUR/GECTI dallarinin
                                            IKISININ DE fiilen isirdigini kanitlar
                                            (is emri: "kendini kanitlasin, kor kapi yok")

Her check_* fonksiyonu SAF MANTIKTIR (girdi -> (gecti_mi, mesaj)) -- gercek
olcumden AYRILMISTIR ki sentetik girdiyle sinanabilsin (bu projenin
araclar/*.py --altin-kume gelenegiyle AYNI desen).
"""
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from yardimcilar import ADB, FLUTTER, calistir, damga, kanit_yaz, mesaj  # noqa: E402

KOK = r"C:\dev\Momentum"


# ============================ SAF MANTIK (sentetik sinanabilir) =================


def check_agac_temiz(porcelain_ciktisi):
    """Ö1: 'git status --porcelain -- src' BOS olmali."""
    if porcelain_ciktisi.strip() == "":
        return True, "src altinda agac TEMIZ"
    return False, "src altinda KIRLI satirlar var:\n" + porcelain_ciktisi


def check_taban_uiicin_ui(rev_parse_kod, merge_base_kod):
    """Ö2: 2710db0 (K174 baslik duzenleme UI) HEAD'in atasi mi."""
    if rev_parse_kod != 0:
        return False, "2710db0 GECERLI BIR COMMIT DEGIL (rev-parse --verify basarisiz, kod=%d)" % rev_parse_kod
    if merge_base_kod == 0:
        return True, "2710db0 HEAD'in atasi (merge-base --is-ancestor exit 0)"
    return False, "2710db0 HEAD'in atasi DEGIL (merge-base --is-ancestor exit=%d)" % merge_base_kod


def check_araclar_var(flutter_var, adb_var, dogrula_var):
    """Ö3: $FLUTTER, $ADB, _backend_dogrula.py UCUNUN de var olmasi."""
    eksik = [ad for ad, v in (
        ("$FLUTTER", flutter_var), ("$ADB", adb_var),
        ("_backend_dogrula.py", dogrula_var)) if not v]
    if eksik:
        return False, "EKSIK: " + ", ".join(eksik)
    return True, "ucu de VAR"


def check_iki_avd(avd_listesi):
    """Ö4: en az IKI ayri AVD."""
    if len(avd_listesi) >= 2:
        return True, "%d AVD: %s" % (len(avd_listesi), avd_listesi)
    return False, "yalniz %d AVD bulundu: %s -- S6 Android icin EN AZ IKI ister" % (
        len(avd_listesi), avd_listesi)


def check_healthcheck_var(config_healthcheck_json):
    """Ö5 (DUZELTILDI, KANIT/SS2/10 item 18): .Config.Healthcheck'e bakilir,
    .State.Health'e DEGIL -- ikincisi konteyner DURMUSKEN null doner ve
    healthcheck VARKEN 'yok' hukmu verilirdi."""
    if config_healthcheck_json and config_healthcheck_json.strip() not in ("", "null", "<no value>"):
        return True, "Config.Healthcheck TANIMLI: %s" % config_healthcheck_json[:120]
    return False, ("Config.Healthcheck YOK/null -- yedek ayak: "
                    "'docker exec momentum-postgres pg_isready -U momentum'")


def check_psql_sema(dt_ciktisi, gerekli_tablolar=("processed_operations", "sync_client_clock")):
    """YENI (KANIT/SS2/10 erratum madde 7 yerine): psql \\dt ciktisinda
    gerekli iki tablo GORUNUYOR mu."""
    eksik = [t for t in gerekli_tablolar if t not in dt_ciktisi]
    if eksik:
        return False, "SEMADA EKSIK tablo(lar): " + ", ".join(eksik)
    return True, "sema iki gerekli tabloyu da tasiyor: %s" % list(gerekli_tablolar)


def check_taban_url(main_dart_metni):
    """Ö7: SENKRON_SUNUCU_URL derleme-zamani ezmesi VAR MI -- varsa iki
    emulator icin AYRI deger GEREKMEZ (10.0.2.2 her emulator icin KENDI
    hostuna cozer), urun kodu degisikligi GEREKMEZ."""
    if "String.fromEnvironment(\n  'SENKRON_SUNUCU_URL'" in main_dart_metni or \
       "String.fromEnvironment('SENKRON_SUNUCU_URL'" in main_dart_metni or \
       ("SENKRON_SUNUCU_URL" in main_dart_metni and "String.fromEnvironment" in main_dart_metni):
        return True, ("SENKRON_SUNUCU_URL derleme-zamani ezmesi VAR (varsayilan "
                       "10.0.2.2:5298 -- her emulator KENDI hostuna cozer, degisiklik GEREKMEZ)")
    return False, ("SENKRON_SUNUCU_URL ezmesi YOK -- taban URL SABIT olabilir; "
                    "iki istemci icin degistirilmesi gerekiyorsa URUN KODU degisikligi -- DUR")


def check_dev_user_id_ezmesi(main_dart_metni, ayarlari_hazirla_metni):
    """EK OLCUM (kriter 4 icin degerli): DEV_USER_ID derleme-zamani ezmesi
    VAR MI -- varsa iki cihazi AYNI kullaniciya AYARLAMAK icin urun kodu
    degil, TEK BIR paylasilan derleme (--dart-define=DEV_USER_ID=<guid>)
    yeterlidir (GOREV-A10 Y3)."""
    var_mi = ("DEV_USER_ID" in main_dart_metni and
              "String.fromEnvironment('DEV_USER_ID')" in main_dart_metni and
              "GUID olmalı" in ayarlari_hazirla_metni)
    if var_mi:
        return True, "DEV_USER_ID derleme-zamani ezmesi VAR (GOREV-A10 Y3) -- TEK build iki cihaza yeter"
    return False, "DEV_USER_ID ezmesi bulunamadi -- iki cihazi ayni kullaniciya baglamak icin ALTERNATIF gerekir"


# ============================ GERCEK OLCUM (I/O) =================================


def _olc_gercek():
    bulgular = []  # (ad, gecti_mi, mesaj)
    kanit = [mesaj("IS-EMRI-o70 ON KOSUL OLCUMU basliyor (KANIT/SS2/10 erratum'una gore)")]

    # Ö1
    kod, out, err = calistir(["git", "--no-optional-locks", "status", "--porcelain", "--", "src"], zaman_asimi=20)
    gecti, msg = check_agac_temiz(out)
    bulgular.append(("O1-agac-temiz", gecti, msg))
    kanit.append(mesaj("O1: git status --porcelain -- src -> exit=%d, %s" % (kod, msg)))

    # Ö2
    kod_rp, out_rp, err_rp = calistir(["git", "--no-optional-locks", "rev-parse", "--verify", "2710db0^{commit}"])
    kod_mb, out_mb, err_mb = calistir(["git", "--no-optional-locks", "merge-base", "--is-ancestor", "2710db0", "HEAD"])
    gecti, msg = check_taban_uiicin_ui(kod_rp, kod_mb)
    bulgular.append(("O2-taban-UI-K174", gecti, msg))
    kanit.append(mesaj("O2: rev-parse exit=%d (%s) * merge-base exit=%d -> %s" % (
        kod_rp, out_rp.strip() or err_rp.strip(), kod_mb, msg)))

    # Ö3
    dogrula_yol = os.path.join(KOK, "KANIT", "A11", "_backend_dogrula.py")
    gecti, msg = check_araclar_var(
        os.path.isfile(FLUTTER), os.path.isfile(ADB), os.path.isfile(dogrula_yol))
    bulgular.append(("O3-araclar-var", gecti, msg))
    kanit.append(mesaj("O3: %s" % msg))

    # Ö4
    kod, out, err = calistir([FLUTTER, "emulators"], zaman_asimi=30)
    avdler = []
    for satir in out.splitlines():
        if "•" in satir and "available emulator" not in satir and not satir.strip().startswith("Id"):
            parca = satir.split("•")
            if parca:
                ad = parca[0].strip()
                if ad:
                    avdler.append(ad)
    gecti, msg = check_iki_avd(avdler)
    bulgular.append(("O4-iki-AVD", gecti, msg))
    kanit.append(mesaj("O4: flutter emulators -> %s" % msg))

    # Ö5 (duzeltilmis)
    kod, out, err = calistir(["docker", "inspect", "momentum-postgres", "--format", "{{json .Config.Healthcheck}}"])
    gecti, msg = check_healthcheck_var(out if kod == 0 else "")
    bulgular.append(("O5-healthcheck-var", gecti, msg))
    kanit.append(mesaj("O5: docker inspect .Config.Healthcheck -> exit=%d, %s" % (kod, msg)))

    # Ö6 (bilgi, engellemez)
    launch_yol = os.path.join(KOK, "src", "backend", "Momentum.Api", "Properties", "launchSettings.json")
    var = os.path.isfile(launch_yol)
    kanit.append(mesaj("O6 (bilgi): launchSettings.json %s" % ("VAR" if var else "YOK -- --no-launch-profile yine de kullanilir")))

    # Ö7
    main_dart_yol = os.path.join(KOK, "src", "client", "lib", "main.dart")
    with open(main_dart_yol, "r", encoding="utf-8", errors="replace") as f:
        main_dart_metni = f.read()
    gecti, msg = check_taban_url(main_dart_metni)
    bulgular.append(("O7-taban-URL", gecti, msg))
    kanit.append(mesaj("O7: %s" % msg))

    # EK: DEV_USER_ID
    ayarlari_hazirla_yol = os.path.join(KOK, "src", "client", "lib", "veri", "ayarlari_hazirla.dart")
    with open(ayarlari_hazirla_yol, "r", encoding="utf-8", errors="replace") as f:
        ayarlari_hazirla_metni = f.read()
    gecti, msg = check_dev_user_id_ezmesi(main_dart_metni, ayarlari_hazirla_metni)
    bulgular.append(("EK-DEV_USER_ID", gecti, msg))
    kanit.append(mesaj("EK: %s" % msg))

    # psql sema (YENI, madde 7 yerine -- konteyner ayakta olmali, cagiran sorumlu)
    kod, out, err = calistir(["docker", "exec", "-i", "momentum-postgres", "psql", "-U", "momentum", "-d", "momentum", "-c", "\\dt"])
    gecti, msg = check_psql_sema(out if kod == 0 else "")
    bulgular.append(("PSQL-sema", gecti, msg))
    kanit.append(mesaj("PSQL: docker exec ... psql -c \\dt -> exit=%d, %s" % (kod, msg)))

    return bulgular, kanit


def main():
    bulgular, kanit = _olc_gercek()
    kanit.append(mesaj("=" * 70))
    basarisiz = [b for b in bulgular if not b[1]]
    for ad, gecti, msg in bulgular:
        kanit.append(mesaj("[%s] %s: %s" % ("GECTI" if gecti else "DUR", ad, msg)))
    kanit_yaz(os.path.join(os.path.dirname(os.path.abspath(__file__)), "00-onkosul.txt"), kanit)
    if basarisiz:
        print("\nDUR -- %d on kosul SAGLANMADI: %s" % (
            len(basarisiz), [b[0] for b in basarisiz]))
        return 3
    print("\nTUM ON KOSULLAR GECTI")
    return 0


# ============================ ALTIN KUME (sentetik, kendini kanitlama) ===========


def altin_kume():
    print("=" * 74)
    print("ALTIN KUME -- on_kosullar.py KENDI KANITI (her DUR/GECTI dali ISIRIYOR mu)")
    print("=" * 74)
    vakalar = []

    def vaka(ad, gecti_beklenen, fn):
        gecti, msg = fn()
        ok = gecti == gecti_beklenen
        print("[%s] %s -- beklenen=%s olculen=%s (%s)" % (
            "GECTI" if ok else "DUSTU", ad, gecti_beklenen, gecti, msg))
        vakalar.append(ok)

    vaka("O1 TEMIZ agac -> GECER", True, lambda: check_agac_temiz(""))
    vaka("O1 KIRLI agac -> DUR", False, lambda: check_agac_temiz(" M src/foo.cs\n"))
    vaka("O2 gecerli commit + ata -> GECER", True, lambda: check_taban_uiicin_ui(0, 0))
    vaka("O2 gecersiz commit (rev-parse basarisiz) -> DUR", False, lambda: check_taban_uiicin_ui(128, 0))
    vaka("O2 gecerli commit ama ata DEGIL -> DUR", False, lambda: check_taban_uiicin_ui(0, 1))
    vaka("O3 ucu de var -> GECER", True, lambda: check_araclar_var(True, True, True))
    vaka("O3 FLUTTER eksik -> DUR", False, lambda: check_araclar_var(False, True, True))
    vaka("O3 ADB eksik -> DUR", False, lambda: check_araclar_var(True, False, True))
    vaka("O3 dogrula.py eksik -> DUR", False, lambda: check_araclar_var(True, True, False))
    vaka("O4 iki AVD -> GECER", True, lambda: check_iki_avd(["avdA", "avdB"]))
    vaka("O4 uc AVD -> GECER", True, lambda: check_iki_avd(["a", "b", "c"]))
    vaka("O4 TEK AVD -> DUR (BU MAKINEDE FIILEN OLCULEN DURUM)", False, lambda: check_iki_avd(["tuzak_api34"]))
    vaka("O4 SIFIR AVD -> DUR", False, lambda: check_iki_avd([]))
    vaka("O5 healthcheck tanimli -> GECER", True, lambda: check_healthcheck_var('{"Test":["CMD-SHELL","pg_isready"]}'))
    vaka("O5 healthcheck null (konteyner durdurulmus OLABILIR) -> DUR", False, lambda: check_healthcheck_var("null"))
    vaka("O5 healthcheck bos -> DUR", False, lambda: check_healthcheck_var(""))
    vaka("PSQL iki tablo da var -> GECER", True, lambda: check_psql_sema("processed_operations\nsync_client_clock\n"))
    vaka("PSQL bir tablo eksik -> DUR", False, lambda: check_psql_sema("processed_operations\n"))
    vaka("PSQL ikisi de eksik -> DUR", False, lambda: check_psql_sema("baska_tablo\n"))
    vaka("O7 SENKRON_SUNUCU_URL var -> GECER", True, lambda: check_taban_url(
        "const String _senkronSunucuUrl = String.fromEnvironment(\n  'SENKRON_SUNUCU_URL',\n"))
    vaka("O7 ezme YOK (sabit taban URL) -> DUR", False, lambda: check_taban_url("const String x = 'http://sabit';"))
    vaka("EK DEV_USER_ID var -> GECER", True, lambda: check_dev_user_id_ezmesi(
        "String.fromEnvironment('DEV_USER_ID')", "GUID olmalı -- backend"))
    vaka("EK DEV_USER_ID yok -> DUR", False, lambda: check_dev_user_id_ezmesi("", ""))

    print("=" * 74)
    gecen = sum(1 for v in vakalar if v)
    print("HUKUM: %d/%d GECTI" % (gecen, len(vakalar)))
    print("=" * 74)
    return 0 if gecen == len(vakalar) else 1


if __name__ == "__main__":
    if "--altin-kume" in sys.argv:
        sys.exit(altin_kume())
    sys.exit(main())

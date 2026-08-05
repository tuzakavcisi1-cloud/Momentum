# -*- coding: utf-8 -*-
"""GOREV-W2 kabul kriteri 4/11 -- M200..M216 + MW20 mutant kosucusu.

Referans: KANIT\\A11\\_mutant_kosucu.py (ikili yedek -> yama -> kos -> yedekten
GERI YAZ -> sha256 BAYT-OZDESLIK). `git restore` KULLANILMAZ (core.autocrlf
bayt-ozdesligi kor eder).

BU DOSYA K11/K26 KAPSAMINDADIR: bunu YAZAN el (Claude Code, oturum 59) bu
kosumun HUKMUNU vermez -- ayri, bagimsiz bir el (Cowork ya da bu runner'i
yazmamis baska bir ajan) calistirip OKUR ve nihai kabul/red kararini verir.
Bu betik yalniz MEKANIK olcumu yapar: her mutant icin
  (a) flutter test --reporter json ile testleri kosar,
  (b) KIRMIZI (basarisiz, gizli-olmayan) test adlarindan `G<n>/<harf>`
      desenine uyan AYAK KIMLIKLERINI cikarir,
  (c) bu kumeyi mutantin `hedef` sutunundaki ayak kumesiyle TAM ESITLIK
      (alt kume DEGIL) ile karsilastirir,
  (d) dosyalari BAYT-OZDES geri yazar ve sha256 ile dogrular.

MW20 (hicbir dosyaya dokunulmaz) tum test takimini kosar ve SIFIR kirmizi
bekler -- KALDI vermezse koşucu bozuktur, TUM KOSUM GECERSIZDIR (spec kriter 4).
"""
import hashlib
import io
import json
import os
import re
import subprocess
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

KOK = r"C:\dev\Momentum"
ISTEMCI = os.path.join(KOK, "src", "client")
FLUTTER = r"C:\src\flutter\bin\flutter.bat"
KANIT = os.path.join(KOK, "KANIT", "W2")

DD = os.path.join(ISTEMCI, "lib", "veri", "depolama_durumu.dart")
DS = os.path.join(ISTEMCI, "lib", "sunum", "depolama_seridi.dart")
VT = os.path.join(ISTEMCI, "lib", "veri", "veritabani.dart")
MN = os.path.join(ISTEMCI, "lib", "main.dart")

DOSYALAR = [DD, DS, VT, MN]

# G39/G41/G42'nin uc dosyasi -- 17 mutantin TUMU bu uc dosyanin testleriyle
# olculur (hedef sutununda hicbir mutant W2-disi bir kapiyi hedeflemiyor;
# bu KISITLI KOSUM spec'in TAM EŞİTLİK gerekliligini bozmaz, yalniz
# yuruturmeyi hizlandirir -- referans runner da AYNI deseni kullanir:
# _mutant_kosucu.py [A11] her mutant icin TEK bir hedef test dosyasi kosar).
W2_TEST_DOSYALARI = [
    "test/w2_depolama_esleme_test.dart",
    "test/w2_depolama_seridi_test.dart",
    "test/w2_dikis_kapisi_test.dart",
]

ORTAM = dict(os.environ)
ORTAM["PROGRAMFILES(X86)"] = r"C:\Program Files (x86)"

AYAK_DESENI = re.compile(r"G\d+/[a-z]")


def oku(p):
    with io.open(p, "rb") as f:
        return f.read()


def yaz(p, b):
    with io.open(p, "wb") as f:
        f.write(b)


def sha(b):
    return hashlib.sha256(b).hexdigest()[:8].upper()


def nl(ham, s):
    return s.replace("\n", "\r\n") if b"\r\n" in ham else s


def kanit_yaz(ad, metin):
    with io.open(os.path.join(KANIT, "_KOSUM-%s.txt" % ad), "w",
                 encoding="utf-8", errors="replace") as f:
        f.write(metin)


def flutter_test_json(dosyalar, cwd, timeout=240):
    """`flutter test --reporter json [dosyalar]` kosar; (rc, kirmizi_ayaklar,
    kirmizi_test_adlari, ham_json_satirlari, hata) doner.

    `hata` None DEGILSE (ORTAM/PARSE sorunu -- ör. surec hic JSON uretmeden
    coktu), kirmizi_ayaklar kumesi BOS sayilir ve cagiran taraf bunu
    "hedefle ESLESMEDI" olarak degerlendirir (sessizce YESIL SAYILMAZ).
    """
    cmd = [FLUTTER, "test", "--reporter", "json"] + list(dosyalar)
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True,
                            encoding="utf-8", errors="replace", env=ORTAM,
                            timeout=timeout)
    except subprocess.TimeoutExpired as e:
        return None, set(), [], "", "ZAMAN ASIMI (%ss): %s" % (timeout, e)

    ham = (p.stdout or "") + "\n--STDERR--\n" + (p.stderr or "")
    tests = {}
    sonuclar = {}
    try:
        for satir in (p.stdout or "").splitlines():
            satir = satir.strip()
            if not satir:
                continue
            try:
                e = json.loads(satir)
            except ValueError:
                continue  # JSON-olmayan satirlar (nadiren) sessizce atlanir
            t = e.get("type")
            if t == "testStart":
                tests[e["test"]["id"]] = e["test"]
            elif t == "testDone":
                sonuclar[e["testID"]] = e
    except Exception as ex:
        return p.returncode, set(), [], ham, "JSON AYRISTIRMA HATASI: %r" % ex

    kirmizi_adlar = []
    for tid, test in tests.items():
        sonuc = sonuclar.get(tid)
        if sonuc is None:
            continue  # tamamlanmadi (ör. surec erken coktu)
        if sonuc.get("hidden"):
            continue  # (loading .. ) / (setUpAll) / (tearDownAll) sozde-testleri
        if sonuc.get("result") != "success" or sonuc.get("skipped"):
            kirmizi_adlar.append(test.get("name", ""))

    ayaklar = set()
    for ad in kirmizi_adlar:
        ayaklar.update(AYAK_DESENI.findall(ad))

    hata = None
    if not tests:
        hata = "ORTAM HATASI: hic test olayi ayristirilamadi (surec cokmus olabilir)"
    return p.returncode, ayaklar, kirmizi_adlar, ham, hata


# ============================ MUTANT TANIMLARI ================================
# (ad, hedef_ayak_kumesi, [(dosya, eski, yeni)])

M = []

M.append(("M200", {"G39/b"}, [(DD,
    "  return DepolamaSinifi.geriDusus; // ④ aksi halde (bilinmeyen ad dahil)\n",
    "  return DepolamaSinifi.kaliciOpfs; // MUTANT M200\n")]))

M.append(("M201", {"G39/c"}, [(DD,
    "    return DepolamaSinifi.geriDusus; // ③\n",
    "    return DepolamaSinifi.kaliciDegil; // MUTANT M201\n")]))

M.append(("M202", {"G39/d"}, [(DD,
    "    return DepolamaSinifi.kaliciDegil; // ①\n",
    "    return DepolamaSinifi.geriDusus; // MUTANT M202\n")]))

M.append(("M213", {"G39/e"}, [(DD,
    "  if (kaliciOpfsAdlari.contains(uygulamaAdi) && depolamaApi == 'opfs') {\n",
    "  if (kaliciOpfsAdlari.contains(uygulamaAdi)) {"
    " // MUTANT M213: api kosulu KALDIRILDI\n")]))

M.append(("M203", {"G40/a"}, [(DS,
    "  bool _seritGerekliMi(DepolamaSinifi sinif) =>\n"
    "      sinif == DepolamaSinifi.geriDusus || sinif == DepolamaSinifi.kaliciDegil;\n",
    "  bool _seritGerekliMi(DepolamaSinifi sinif) =>\n"
    "      sinif == DepolamaSinifi.geriDusus || sinif == DepolamaSinifi.kaliciDegil ||"
    " sinif == DepolamaSinifi.kaliciOpfs; // MUTANT M203\n")]))

M.append(("M204", {"G40/a", "G40/b"}, [(DS,
    "  bool _seritGerekliMi(DepolamaSinifi sinif) =>\n"
    "      sinif == DepolamaSinifi.geriDusus || sinif == DepolamaSinifi.kaliciDegil;\n",
    "  bool _seritGerekliMi(DepolamaSinifi sinif) =>\n"
    "      sinif == DepolamaSinifi.kaliciDegil; // MUTANT M204: geriDusus KALDIRILDI\n")]))

M.append(("M206", {"G40/b"}, [(DS,
    "            Icon(Icons.storage, size: MOlcu.ikon, color: renk),\n"
    "            SizedBox(width: MBosluk.xs),\n",
    "            // MUTANT M206: Icon KALDIRILDI\n"
    "            SizedBox(width: MBosluk.xs),\n")]))

M.append(("M205", {"G40/e"}, [(DS,
    "    final renk = MRenk.cevrimdisi(context);\n",
    "    final renk = MRenk.uyari(context); // MUTANT M205\n")]))

M.append(("M208", {"G40/d"}, [(DS,
    "                  maxLines: 2,\n",
    "                  maxLines: 5, // MUTANT M208\n")]))

M.append(("M207", {"G40/c"}, [(DD,
    "    : sinif = DepolamaSinifi.olculmedi,\n",
    "    : sinif = DepolamaSinifi.geriDusus, // MUTANT M207\n")]))

M.append(("M214", {"G40/f"}, [(DS,
    "    if (!oncekiGerekliMi && _seritGerekliMi(yeniSinif)) {\n"
    "      SemanticsService.sendAnnouncement(\n"
    "        View.of(context),\n"
    "        Metinler.duyuruDepolamaGeriDususu,\n"
    "        TextDirection.ltr,\n"
    "      );\n"
    "    }\n",
    "    if (!oncekiGerekliMi && _seritGerekliMi(yeniSinif)) {\n"
    "      // MUTANT M214: sendAnnouncement KALDIRILDI\n"
    "    }\n")]))

M.append(("M209", {"G39/a", "G41/a"}, [(DD,
    "const Set<String> kaliciOpfsAdlari = {'opfsShared', 'opfsLocks'};\n",
    "const Set<String> kaliciOpfsAdlari ="
    " {'opfsShared', 'kilitliDosyaSistemi'}; // MUTANT M209\n")]))

M.append(("M210", {"G42/a"}, [(VT,
    "        if (bildirim != null) {\n"
    "          depolamaBildirimiYaz(\n"
    "            bildirim,\n"
    "            uygulamaAdi: sonuc.chosenImplementation.name,\n"
    "            depolamaApi: sonuc.chosenImplementation.storageApi?.name,\n"
    "          );\n"
    "        }\n",
    "        // MUTANT M210: depolamaBildirimiYaz cagrisi KALDIRILDI\n")]))

M.append(("M216", {"G42/a"}, [(VT,
    "        if (bildirim != null) {\n"
    "          depolamaBildirimiYaz(\n"
    "            bildirim,\n"
    "            uygulamaAdi: sonuc.chosenImplementation.name,\n"
    "            depolamaApi: sonuc.chosenImplementation.storageApi?.name,\n"
    "          );\n"
    "        }\n",
    "        /* MUTANT M216: depolamaBildirimiYaz cagrisi YORUMA ALINDI\n"
    "        if (bildirim != null) {\n"
    "          depolamaBildirimiYaz(\n"
    "            bildirim,\n"
    "            uygulamaAdi: sonuc.chosenImplementation.name,\n"
    "            depolamaApi: sonuc.chosenImplementation.storageApi?.name,\n"
    "          );\n"
    "        }\n"
    "        */\n")]))

M.append(("M215", {"G42/a"}, [(VT,
    "            uygulamaAdi: sonuc.chosenImplementation.name,\n"
    "            depolamaApi: sonuc.chosenImplementation.storageApi?.name,\n",
    "            uygulamaAdi: 'opfsShared', // MUTANT M215\n"
    "            depolamaApi: 'opfs', // MUTANT M215\n")]))

M.append(("M211", {"G42/b"}, [(VT,
    "        // ignore: avoid_print\n"
    "        print(\n"
    "          'MOMENTUM-G6-KANIT chosenImplementation=${sonuc.chosenImplementation} '\n"
    "          'missingFeatures=${sonuc.missingFeatures}',\n"
    "        );\n",
    "        // MUTANT M211: MOMENTUM-G6-KANIT print satiri KALDIRILDI\n")]))

M.append(("M212", {"G42/c"}, [(MN,
    "              depolama: depolama,\n",
    "              depolama: null, // MUTANT M212\n")]))


# ================================ KOSUM =======================================

def son_satirlar(cikti, n=40):
    s = [x for x in cikti.replace("\r", "").split("\n") if x.strip()]
    return "\n".join(s[-n:])


def temiz_taban_kontrolu(etiket):
    rc, ayaklar, adlar, ham, hata = flutter_test_json([], ISTEMCI, timeout=300)
    satir = "  %s: EXIT=%s kirmizi=%d hata=%s" % (
        etiket, rc, len(adlar), hata or "-")
    kanit_yaz(etiket, "EXIT=%s\nHATA=%s\nKIRMIZI ADLAR:\n%s\n\n%s" % (
        rc, hata, "\n".join(adlar), son_satirlar(ham, 60)))
    return satir, (rc == 0 and not hata and not adlar)


def main():
    baslangic = {p: oku(p) for p in DOSYALAR}
    ozet = []
    ozet.append("GOREV-W2 kabul kriteri 4/11 -- M200..M216 + MW20 mutant kosumu")
    ozet.append("(Bu betigi YAZAN el HUKUM VERMEZ -- K11/K26. Ham veri asagida.)")
    for p, b in baslangic.items():
        ozet.append("  TABAN sha8=%s %7d b  %s" % (sha(b), len(b), os.path.basename(p)))

    # --- 0) TEMIZ TABAN: TUM TAKIM EXIT 0 VE SIFIR KIRMIZI OLMALI ---
    satir, ok = temiz_taban_kontrolu("00-TEMIZ-ONCE")
    ozet.append(satir)
    print(satir)
    if not ok:
        ozet.append("  [DUR] temiz taban KIRMIZI -- mutant kosumu BASLAMADI.")
        metin = "\n".join(ozet)
        kanit_yaz("OZET", metin)
        print(metin)
        return 3

    # --- 1) MUTANTLAR (W2_TEST_DOSYALARI ile HIZLI kosum) ---
    sonuc_tablosu = []
    for ad, hedef, duzenlemeler in M:
        yedek = {}
        for yol, _e, _y in duzenlemeler:
            yedek.setdefault(yol, oku(yol))
        gecici = dict(yedek)
        hata_yama = None
        eslesmeler = []
        for yol, eski, yeni in duzenlemeler:
            ham = gecici[yol]
            eb = nl(ham, eski).encode("utf-8")
            nb = nl(ham, yeni).encode("utf-8")
            n = ham.count(eb)
            eslesmeler.append("%s:%d" % (os.path.basename(yol), n))
            if n != 1:
                hata_yama = "ESLESME SAYISI %d (1 BEKLENIYORDU) -- %s" % (n, os.path.basename(yol))
                break
            gecici[yol] = ham.replace(eb, nb)

        rc = None
        gozlenen_ayaklar = set()
        kirmizi_adlar = []
        ham_cikti = ""
        hata_kosum = None
        try:
            if hata_yama is None:
                for yol, b in gecici.items():
                    yaz(yol, b)
                rc, gozlenen_ayaklar, kirmizi_adlar, ham_cikti, hata_kosum = (
                    flutter_test_json(W2_TEST_DOSYALARI, ISTEMCI))
        finally:
            # --- GERI ALMA + BAYT-OZDESLIK (try/finally: cokse bile calisir) ---
            geri = []
            hata_geri = None
            for yol, b in yedek.items():
                yaz(yol, b)
                simdi = oku(yol)
                ozdes = (simdi == b)
                geri.append("%s sha8=%s ozdes=%s" % (os.path.basename(yol), sha(simdi), ozdes))
                if not ozdes:
                    hata_geri = (hata_geri or "") + " GERI-ALMA-BOZUK:%s" % yol

        hata = hata_yama or hata_kosum or hata_geri
        if hata:
            esitlik = False
            hukum = "OLCULEMEDI (ORTAM HATASI): %s" % hata
        else:
            esitlik = (gozlenen_ayaklar == hedef)
            hukum = "ESLESTI (beklenen)" if esitlik else "ESLESMEDI (hedef=%s gozlenen=%s)" % (
                sorted(hedef), sorted(gozlenen_ayaklar))

        sonuc_tablosu.append((ad, sorted(hedef), sorted(gozlenen_ayaklar), esitlik, hata))

        satir = "  %-6s hedef=%-20s gozlenen=%-20s eslesme[%s] rc=%s -> %s" % (
            ad, sorted(hedef), sorted(gozlenen_ayaklar), ",".join(eslesmeler), rc, hukum)
        ozet.append(satir)
        print(satir)
        sys.stdout.flush()

        govde = [
            "MUTANT %s -- hedef ayak kumesi: %s" % (ad, sorted(hedef)),
            "eslesme (yama): %s" % ",".join(eslesmeler),
            "gozlenen KIRMIZI ayak kumesi: %s" % sorted(gozlenen_ayaklar),
            "TAM ESITLIK: %s" % esitlik,
            "geri alma: %s" % " | ".join(geri),
            "HUKUM: %s" % hukum,
            "",
            "KIRMIZI TEST ADLARI:",
        ] + kirmizi_adlar + ["", "=== flutter test --reporter json (son 60 satir) ==="] + [
            son_satirlar(ham_cikti, 60)
        ]
        kanit_yaz(ad, "\n".join(govde))

    # --- 2) MW20 NEGATIF KONTROL: HICBIR DOSYAYA DOKUNULMAZ, TAM TAKIM ---
    rc, ayaklar, adlar, ham, hata = flutter_test_json([], ISTEMCI, timeout=300)
    mw20_kaldi = (rc == 0 and not hata and not adlar)
    hukum_mw20 = "KALDI (beklenen)" if mw20_kaldi else "ISIRDI (KOSUCU BOZUK -- KOSUM GECERSIZ)"
    satir = "  MW20   hicbir dosyaya DOKUNULMADI, TAM TAKIM -> kirmizi=%d rc=%s -> %s" % (
        len(adlar), rc, hukum_mw20)
    ozet.append(satir)
    print(satir)
    kanit_yaz("MW20", "HUKUM: %s\nEXIT=%s\nHATA=%s\nKIRMIZI ADLAR:\n%s\n\n%s" % (
        hukum_mw20, rc, hata, "\n".join(adlar), son_satirlar(ham, 60)))

    # --- 3) TEMIZ TABAN TEKRAR (revert sonrasi butunluk) ---
    for p, b in baslangic.items():
        simdi = oku(p)
        ozet.append("  SON   sha8=%s %7d b  %s  ozdes=%s"
                    % (sha(simdi), len(simdi), os.path.basename(p), simdi == b))
    satir, ok_sonra = temiz_taban_kontrolu("99-TEMIZ-SONRA")
    ozet.append(satir)
    print(satir)

    # --- OZET TABLO ---
    esitlik_sayisi = sum(1 for r in sonuc_tablosu if r[3])
    ozet.append("")
    ozet.append("ESLESEN MUTANT (TAM ESITLIK): %d/%d" % (esitlik_sayisi, len(M)))
    ozet.append("MW20 NEGATIF KONTROL: %s" % hukum_mw20)
    ozet.append("TEMIZ-ONCE: %s | TEMIZ-SONRA: %s" % (ok, ok_sonra))
    ozet.append("")
    ozet.append("BU OZET BIR KABUL BEYANI DEGILDIR (K11/K26) -- bu betigi YAZAN")
    ozet.append("el bu ciktiyi kendi kabul hukmune donusturmez; bagimsiz bir el")
    ozet.append("(runner'i yazmamis) bu KANIT dosyalarini okuyup nihai hukmu verir.")

    metin = "\n".join(ozet)
    kanit_yaz("OZET", metin)
    print("\n" + metin)

    basarili = (esitlik_sayisi == len(M)) and mw20_kaldi and ok and ok_sonra
    return 0 if basarili else 1


if __name__ == "__main__":
    sys.exit(main())

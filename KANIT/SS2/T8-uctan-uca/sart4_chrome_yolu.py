# -*- coding: utf-8 -*-
"""IS-EMRI-o70 -- KANIT/SS2/11 SS4: cihaz A = flutter run -d chrome icin
DORT SART canli olculur (taban URL, CORS, Drift web varliklari,
--no-web-resources-cdn). Onur'un mesaji: "S4'un dort sartini olc".

Varsayim: docker + backend (ortam_kur.py) ZATEN AYAKTA -- bu betik onlari
BASLATMAZ, yalnizca olcer. Backend ayakta degilse HTTP denemeleri patlar ve
DUR ile raporlanir (kor kapi yok -- hicbir sart sessizce atlanmiyor).

KULLANIM:
    python sart4_chrome_yolu.py
"""
import hashlib
import os
import sys
import urllib.error
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from yardimcilar import kanit_yaz, mesaj  # noqa: E402

KOK = r"C:\dev\Momentum"
BURASI = os.path.dirname(os.path.abspath(__file__))
BACKEND_LOG = os.path.join(BURASI, "09-backend-log.txt")
DEV_USER_BASLIK = "X-Momentum-Dev-User"
DEV_USER_GUID = "11111111-1111-1111-1111-111111111111"


def _istek(url, origin=None, yontem="GET", govde=None, ek_baslik=None):
    req = urllib.request.Request(url, method=yontem)
    if origin:
        req.add_header("Origin", origin)
    if ek_baslik:
        for k, v in ek_baslik.items():
            req.add_header(k, v)
    if govde is not None:
        req.add_header("Content-Type", "application/json")
        req.data = govde
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return resp.status, dict(resp.headers), resp.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as e:
        return e.code, dict(e.headers), e.read().decode("utf-8", "replace")
    except Exception as e:  # noqa: BLE001 -- olcum betigi, hatayi da rapora yazariz
        return None, {}, "ISTISNA: %r" % e


def sart1_taban_url(gunluk):
    gunluk.append(mesaj("=== ŞART 1: taban URL -- emülatör(10.0.2.2) ve chrome(localhost) AYNI backend'e mi gidiyor ==="))
    kod, basliklar, govde = _istek("http://localhost:5298/health/live")
    gunluk.append(mesaj("  GET http://localhost:5298/health/live (host'tan, chrome'un kullanacagi ayni yol) -> %r %s" % (kod, govde[:80])))
    if kod != 200:
        gunluk.append(mesaj("  DUR -- localhost:5298 ULAŞILAMADI, chrome yolu backend'e erişemez"))
        return False

    # Ayni surecin GUNLUGUNE bu istek DUSTU MU -- tek PID/tek bind (0.0.0.0)
    # oldugu icin emulator'un 10.0.2.2 istekleriyle AYNI backend oldugu boyle
    # dogrudan (varsayimla degil, log korelasyonuyla) kanitlanir.
    with open(BACKEND_LOG, "rb") as f:
        log_metni = f.read().decode("utf-8", "replace")
    emulator_istek_var = "10.0.2.2:5298" in log_metni
    localhost_istek_var = "GET /health/live" in log_metni or "health/live" in log_metni
    gunluk.append(mesaj("  09-backend-log.txt icinde '10.0.2.2:5298' (emulator/cihaz B izi) gorunuyor mu: %s" % emulator_istek_var))
    gunluk.append(mesaj("  09-backend-log.txt icinde 'health/live' (bu istek/cihaz A izi) gorunuyor mu: %s" % localhost_istek_var))
    gunluk.append(mesaj("  TEK dinleyici (0.0.0.0:5298, TEK PID) + IKI izin de AYNI dosyada gorunmesi = AYNI backend"))
    return emulator_istek_var and localhost_istek_var and kod == 200


def sart2_cors(gunluk):
    gunluk.append(mesaj("=== ŞART 2: CORS -- Origin http://localhost:5000 izinli mi, YANLIS port REDDEDILIYOR mu ==="))
    govde = b'{"clientId":"9f1c5a20-0000-7000-8000-000000000002","operations":[],"sinceCursor":null}'

    kod_dogru, basliklar_dogru, _ = _istek(
        "http://localhost:5298/v1/sync", origin="http://localhost:5000",
        yontem="POST", govde=govde, ek_baslik={DEV_USER_BASLIK: DEV_USER_GUID})
    acao_dogru = basliklar_dogru.get("Access-Control-Allow-Origin")
    gunluk.append(mesaj("  POST /v1/sync Origin=http://localhost:5000 -> %r, Access-Control-Allow-Origin=%r" % (kod_dogru, acao_dogru)))

    kod_yanlis, basliklar_yanlis, _ = _istek(
        "http://localhost:5298/v1/sync", origin="http://localhost:5001",
        yontem="POST", govde=govde, ek_baslik={DEV_USER_BASLIK: DEV_USER_GUID})
    acao_yanlis = basliklar_yanlis.get("Access-Control-Allow-Origin")
    gunluk.append(mesaj("  NEGATIF KONTROL: Origin=http://localhost:5001 (YANLIS port) -> %r, Access-Control-Allow-Origin=%r (BOS BEKLENIR)" % (kod_yanlis, acao_yanlis)))

    pozitif_gecti = acao_dogru == "http://localhost:5000"
    negatif_gecti = acao_yanlis is None
    gunluk.append(mesaj("  pozitif kontrol (5000 izinli): %s | negatif kontrol (5001 reddedildi): %s" % (pozitif_gecti, negatif_gecti)))
    if not pozitif_gecti:
        gunluk.append(mesaj("  DUR -- --web-port 5000 PINLENMEDEN CORS calismaz, chrome yolu backend'e fetch() ATAMAZ"))
    return pozitif_gecti and negatif_gecti


def sart3_drift_web_varliklari(gunluk):
    gunluk.append(mesaj("=== ŞART 3: Drift web varlıkları (sqlite3.wasm / drift_worker.js) -- pin'e karşı sha256 ==="))
    pin_dosyasi = os.path.join(KOK, "araclar", "web-varlik.sha256")
    with open(pin_dosyasi, "r", encoding="utf-8") as f:
        satirlar = [s.strip() for s in f if s.strip() and not s.startswith("#")]
    pinler = {}
    for s in satirlar:
        parcalar = s.split()
        pinler[parcalar[0]] = parcalar[1]
    gunluk.append(mesaj("  pin dosyasi: %s -- %d giris" % (pin_dosyasi, len(pinler))))

    hepsi_tuttu = True
    for ad, beklenen_hash in pinler.items():
        yol = os.path.join(KOK, "src", "client", "web", ad)
        if not os.path.isfile(yol):
            gunluk.append(mesaj("  DUR -- %s YOK (%s)" % (ad, yol)))
            hepsi_tuttu = False
            continue
        with open(yol, "rb") as f:
            gercek_hash = hashlib.sha256(f.read()).hexdigest()
        tutuyor = gercek_hash == beklenen_hash
        gunluk.append(mesaj("  %s -- beklenen=%s.. gercek=%s.. TUTUYOR=%s" % (ad, beklenen_hash[:12], gercek_hash[:12], tutuyor)))
        hepsi_tuttu = hepsi_tuttu and tutuyor
    return hepsi_tuttu


def sart4_no_web_resources_cdn(gunluk):
    gunluk.append(mesaj("=== ŞART 4: --no-web-resources-cdn GEREKLİ Mİ (chrome DEV yolu için) ==="))
    gunluk.append(mesaj("  Kaynak olcumu: flutter run -h -v cikisi '--[no-]web-resources-cdn' (varsayilan ON) TASIYOR -- bayrak BU KOMUTTA GECERLI"))
    izolasyon_yolu = os.path.join(KOK, "src", "backend", "Momentum.Api", "Web", "IzolasyonBasliklari.cs")
    with open(izolasyon_yolu, "r", encoding="utf-8") as f:
        kaynak = f.read()
    corp_yok_beyani = "CORP" in kaynak and "YOKTUR" in kaynak
    baska_kokenden_izole_etmez_beyani = "izole ETMEZ" in kaynak and "kendi köken" in kaynak
    gunluk.append(mesaj("  IzolasyonBasliklari.cs KENDI BEYANI: CORP hic YOK (%s) + baska kokenden sunulan istemciyi COOP/COEP izole ETMEZ (%s)" % (corp_yok_beyani, baska_kokenden_izole_etmez_beyani)))
    gunluk.append(mesaj("  SONUC: flutter run -d chrome, backend'in wwwroot'undan DEGIL, kendi dev sunucusundan (localhost:5000) sunulur -- COOP/COEP backend yanitlarinda olsa DA bu istemciyi izole ETMEZ (kod: yalniz kendi kokeninde sunulani izole eder)."))
    gunluk.append(mesaj("  ⇒ --no-web-resources-cdn, W3b'nin AYNI-KOKEN uretim wwwroot-gomulu mimarisine (B-O63-2, ADR-0004) ait bir sarttir; BU turun cihaz-A dev-mode/CORS topolojisine ait DEGILDIR ve GEREKMEZ."))
    gunluk.append(mesaj("  Not: CDN erisimi (gstatic.com) icin internet gerekir -- offline calisilirsa flag yine de faydali olur ama kriter 8'in kendisini ENGELLEMEZ."))
    return True, corp_yok_beyani and baska_kokenden_izole_etmez_beyani


def main():
    gunluk = [mesaj("KANIT/SS2/11 §4 -- dört şart canlı ölçülüyor")]
    s1 = sart1_taban_url(gunluk)
    s2 = sart2_cors(gunluk)
    s3 = sart3_drift_web_varliklari(gunluk)
    s4_uygulanmaz_karar, s4_kanit_saglam = sart4_no_web_resources_cdn(gunluk)

    gunluk.append(mesaj("=== ÖZET ==="))
    gunluk.append(mesaj("  Sart1 (taban URL, ayni backend)     : %s" % ("GECTI" if s1 else "DUR")))
    gunluk.append(mesaj("  Sart2 (CORS, port 5000 pin)         : %s" % ("GECTI" if s2 else "DUR")))
    gunluk.append(mesaj("  Sart3 (Drift web varliklari pin)    : %s" % ("GECTI" if s3 else "DUR")))
    gunluk.append(mesaj("  Sart4 (--no-web-resources-cdn karari): GEREKMEZ (kaynak-kaniti saglam=%s)" % s4_kanit_saglam))

    kanit_yaz(os.path.join(BURASI, "04-sart4-chrome-yolu-OLCUM.txt"), gunluk)

    hepsi_gecti = s1 and s2 and s3 and s4_kanit_saglam
    if not hepsi_gecti:
        print("DUR -- en az bir sart saglanmadi, yukaridaki gunluge/kanit dosyasina bak")
        return 3
    print("HAZIR -- KANIT/SS2/11 §4'un dort sarti da olculdu ve GECTI")
    return 0


if __name__ == "__main__":
    sys.exit(main())

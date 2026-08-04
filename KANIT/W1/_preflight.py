# -*- coding: utf-8 -*-
"""KANIT/W1/_preflight.py -- GOREV-W1 G36'nin UC AYAGINI CANLI backend'e karsi
olcer (T3). Backend AYAKTA olmalidir: ASPNETCORE_ENVIRONMENT=Development,
Cors:AllowedOrigins=["http://localhost:5000"] (appsettings.Development.json).
Ham istek/yanit basliklari KANIT/W1/G36-preflight-ham.txt'e yazilir -- "kostu,
gecti" cumlesi kanit degildir (K26); Cowork bu dosyayi KENDISI acar.

D-W1-9: SABIT_GUID, web'in --dart-define=DEV_USER_ID ile AYNI olmak zorundadir.
"""
import json
import sys
import urllib.error
import urllib.request

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

TABAN = "http://localhost:5298"
SABIT_GUID = "11111111-1111-1111-1111-111111111111"  # D-W1-9 -- web ile AYNI


def istek(yol, method, basliklar=None, govde=None):
    r = urllib.request.Request(TABAN + yol, data=govde, headers=basliklar or {}, method=method)
    try:
        with urllib.request.urlopen(r, timeout=8) as y:
            return y.status, list(y.getheaders()), y.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as e:
        return e.code, list(e.headers.items()), e.read().decode("utf-8", "replace")
    except Exception as e:
        return None, [], str(e)


def basi_bul(basliklar, ad):
    ad_l = ad.lower()
    for k, v in basliklar:
        if k.lower() == ad_l:
            return v
    return None


def yaz_ham(dosya, baslik, kod, basliklar, govde):
    with open(dosya, "a", encoding="utf-8") as f:
        f.write("=== " + baslik + " ===\n")
        f.write("HTTP %s\n" % kod)
        for k, v in basliklar:
            f.write("%s: %s\n" % (k, v))
        f.write("\nGOVDE (ilk 500 bayt): " + (govde[:500] if govde else "(bos)") + "\n\n")


def main():
    cikti = "KANIT/W1/G36-preflight-ham.txt"
    open(cikti, "w", encoding="utf-8").close()  # temizle -- her kosum baastan yazar
    sonuclar = {}

    # --- G36/a (pozitif): dogru origin + iki basligin ikisi de istenir ----------
    kod, basliklar, govde = istek("/v1/sync", "OPTIONS", {
        "Origin": "http://localhost:5000",
        "Access-Control-Request-Method": "POST",
        "Access-Control-Request-Headers": "content-type, x-momentum-dev-user",
    })
    yaz_ham(cikti, "G36/a: OPTIONS /v1/sync (Origin: http://localhost:5000)", kod, basliklar, govde)
    aco = basi_bul(basliklar, "Access-Control-Allow-Origin")
    ach = (basi_bul(basliklar, "Access-Control-Allow-Headers") or "").lower()
    g36a_ok = (kod in (200, 204) and aco == "http://localhost:5000"
               and "content-type" in ach and "x-momentum-dev-user" in ach)
    sonuclar["G36/a"] = g36a_ok
    print("G36/a: HTTP=%s ACAO=%r ACAH=%r -> %s" %
          (kod, aco, basi_bul(basliklar, "Access-Control-Allow-Headers"), "GECTI" if g36a_ok else "KALDI"))

    # --- G36/b (negatif): evil.local -- politikanin GERCEKTEN DARALTTIGINI kanitlar ---
    kod, basliklar, govde = istek("/v1/sync", "OPTIONS", {
        "Origin": "http://evil.local",
        "Access-Control-Request-Method": "POST",
        "Access-Control-Request-Headers": "content-type, x-momentum-dev-user",
    })
    yaz_ham(cikti, "G36/b: OPTIONS /v1/sync (Origin: http://evil.local)", kod, basliklar, govde)
    aco_evil = basi_bul(basliklar, "Access-Control-Allow-Origin")
    g36b_ok = aco_evil is None
    sonuclar["G36/b"] = g36b_ok
    print("G36/b: HTTP=%s ACAO=%r -> %s (DONMEMELI)" % (kod, aco_evil, "GECTI" if g36b_ok else "KALDI"))

    # --- G36/c: gercek POST, gecerli GUID clientId (ORTAM.md: dize gonderirsen 500 doner, PROBUN kusuru olur) ---
    govde_json = json.dumps({
        "clientId": SABIT_GUID, "clientHlc": None, "sinceCursor": None, "ops": [],
    }).encode("utf-8")
    kod, basliklar, govde_resp = istek("/v1/sync", "POST", {
        "Origin": "http://localhost:5000",
        "Content-Type": "application/json",
        "X-Momentum-Dev-User": SABIT_GUID,
    }, govde_json)
    yaz_ham(cikti, "G36/c: POST /v1/sync (Origin: http://localhost:5000)", kod, basliklar, govde_resp)
    aco_post = basi_bul(basliklar, "Access-Control-Allow-Origin")
    g36c_ok = (kod == 200 and aco_post == "http://localhost:5000")
    sonuclar["G36/c"] = g36c_ok
    print("G36/c: HTTP=%s ACAO=%r -> %s" % (kod, aco_post, "GECTI" if g36c_ok else "KALDI"))

    dusenler = {k: v for k, v in sonuclar.items() if not v}
    print("\nHUKUM: %s" % ("HEPSI GECTI" if not dusenler else "BAZI AYAKLAR DUSTU: " + str(dusenler)))
    print("Ham cikti: " + cikti)
    return 0 if not dusenler else 1


if __name__ == "__main__":
    sys.exit(main())

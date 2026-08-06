#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""izolasyon-olc.py -- W3 capraz-koken izolasyon OLCUM araci.

NE OLCER
  Bir kokenin (origin) tarayici baglamini CAPRAZ-KOKEN IZOLE hale getirip getirmedigini olcer.
  Iki ayak, ikisi de ayri bir seyi kanitlar:

    H (HTTP ayagi, YALNIZ STDLIB)  -- yanit basliklarini olcer:
         Cross-Origin-Opener-Policy   == same-origin
         Cross-Origin-Embedder-Policy == require-corp   (credentialless KABUL EDILMEZ; beyan asagida)
    T (TARAYICI ayagi, playwright)  -- gercek bir sayfada `self.crossOriginIsolated` ve
         `typeof SharedArrayBuffer` degerini olcer.

NEDEN IKI AYAK
  OLCULDU (oturum 60 denetimi, headless Chrome 151.0.7922.75):
    --enable-features=SharedArrayBuffer        -> crossOriginIsolated=false, SharedArrayBuffer=function
    --enable-blink-features=SharedArrayBuffer  -> crossOriginIsolated=false, SharedArrayBuffer=function
  Yani BAYRAK yalnizca YAPICIYI geri getirir, IZOLASYON VERMEZ. `typeof SharedArrayBuffer`e bakan bir
  kapi bu yuzden KORDUR. Isolation yalniz BASLIKTAN turer -> H ayagi mekanizmayi, T ayagi sonucu olcer.

BEYAN EDILMIS SINIRLAR
  1) T ayagi playwright ISTER. Onur'un makinesinde playwright YOK (oturum 60'ta olculdu: chrome
     PATH'te yok, playwright yok, selenium yok) => orada T ayagi [OLCULEMEDI] der. OLCULEMEDI
     TEMIZ DEGILDIR. H ayagi her yerde kosar (yalniz stdlib).
  2) Bu arac CORP (Cross-Origin-Resource-Policy) OLCMEZ. CORP kapsami olculmemis bir karardir.
  3) Bu arac `credentialless` COEP degerini KABUL ETMEZ. Gerekce: izolasyon verir ama alt kaynak
     davranisi require-corp'tan FARKLIDIR; ikisini ayni saymak beyansiz bir tercih olurdu.
  4) Bu arac SUNUCU KALDIRMAZ (K80). Adresi verilen kokeni olcer, o kadar.
"""
from __future__ import annotations

import argparse
import http.server
import json
import socket
import sys
import threading
import urllib.error
import urllib.request

try:                                     # ORTAM.md: bu makinede stdout cp1254
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:                        # pragma: no cover
    pass

SURUM = "1.0.0"

COOP_ADI = "Cross-Origin-Opener-Policy"
COEP_ADI = "Cross-Origin-Embedder-Policy"
COOP_BEKLENEN = "same-origin"
COEP_BEKLENEN = "require-corp"

CIKIS_YESIL = 0
CIKIS_BULGU = 1
CIKIS_ORTAM = 3

PROB_SAYFA = (
    b"<!doctype html><meta charset=utf-8><title>izolasyon-probu</title>"
    b"<body><pre id=s>olculuyor</pre><script>"
    b"document.getElementById('s').textContent="
    b"JSON.stringify([self.crossOriginIsolated, typeof SharedArrayBuffer]);"
    b"</script>"
)


# ---------------------------------------------------------------- H ayagi (stdlib)
def http_olc(url: str, zaman_asimi: float = 10.0) -> dict:
    """Yanit basliklarini olcer. Aga cikar; ORTAM HATASI'ni BULGU ile karistirmaz."""
    istek = urllib.request.Request(url, method="GET")
    try:
        with urllib.request.urlopen(istek, timeout=zaman_asimi) as y:
            durum, basliklar = y.status, dict(y.headers)
    except urllib.error.HTTPError as e:          # 4xx/5xx de OLCUMDUR: basliklar okunur
        durum, basliklar = e.code, dict(e.headers or {})
    except Exception as e:
        return {"ortam_hatasi": f"{type(e).__name__}: {e}", "url": url}

    def b(ad: str):                               # baslik ADI buyuk/kucuk harf duyarsizdir
        for k, v in basliklar.items():
            if k.lower() == ad.lower():
                return v.strip()
        return None

    coop, coep = b(COOP_ADI), b(COEP_ADI)
    bulgular = []
    if coop is None:
        bulgular.append(f"H1: {COOP_ADI} YOK")
    elif coop != COOP_BEKLENEN:                   # DEGER birebir karsilastirilir
        bulgular.append(f"H1: {COOP_ADI} = '{coop}', beklenen '{COOP_BEKLENEN}'")
    if coep is None:
        bulgular.append(f"H2: {COEP_ADI} YOK")
    elif coep != COEP_BEKLENEN:
        bulgular.append(f"H2: {COEP_ADI} = '{coep}', beklenen '{COEP_BEKLENEN}'"
                        + (" -- 'credentialless' BILEREK kabul edilmiyor (sinir 3)"
                           if coep == "credentialless" else ""))
    return {"url": url, "http": durum, "coop": coop, "coep": coep, "bulgular": bulgular}


# ---------------------------------------------------------------- T ayagi (playwright)
def tarayici_olc(url: str) -> dict:
    try:
        from playwright.sync_api import sync_playwright
    except Exception as e:
        return {"olculemedi": f"playwright yok ({type(e).__name__}) -- T ayagi OLCULEMEDI"}
    try:
        with sync_playwright() as p:
            tarayici = p.chromium.launch()
            try:
                sayfa = tarayici.new_page()
                sayfa.goto(url, wait_until="load")
                izole, sab = sayfa.evaluate(
                    "() => [self.crossOriginIsolated, typeof SharedArrayBuffer]")
            finally:
                tarayici.close()
    except Exception as e:
        return {"olculemedi": f"tarayici kosturulamadi: {type(e).__name__}: {e}"}
    bulgular = []
    if izole is not True:
        bulgular.append(f"T1: self.crossOriginIsolated = {izole!r} (True bekleniyordu)")
    if sab != "function":
        bulgular.append(f"T2: typeof SharedArrayBuffer = '{sab}' ('function' bekleniyordu)")
    return {"crossOriginIsolated": izole, "SharedArrayBuffer": sab, "bulgular": bulgular}


# ---------------------------------------------------------------- rapor
def olc(url: str, tarayici: bool = True) -> tuple[int, dict]:
    h = http_olc(url)
    sonuc = {"surum": SURUM, "url": url, "http_ayagi": h}
    if "ortam_hatasi" in h:
        return CIKIS_ORTAM, sonuc
    sonuc["tarayici_ayagi"] = tarayici_olc(url) if tarayici else {"olculemedi": "--http-only verildi"}
    t = sonuc["tarayici_ayagi"]
    bulgu = list(h["bulgular"]) + list(t.get("bulgular") or [])
    sonuc["bulgular"] = bulgu
    sonuc["tarayici_olculemedi"] = "olculemedi" in t
    return (CIKIS_BULGU if bulgu else CIKIS_YESIL), sonuc


def yaz(kod: int, s: dict) -> None:
    print("=" * 78)
    print(f"IZOLASYON OLCUMU {SURUM} -- {s['url']}")
    print("=" * 78)
    h = s["http_ayagi"]
    if "ortam_hatasi" in h:
        print(f"  [ORTAM HATASI] {h['ortam_hatasi']}")
        print("  >> Bu bir BULGU DEGILDIR: adres olculemedi. 'temiz' DENMEZ.")
        print("=" * 78)
        print("HUKUM: OLCULEMEDI")
        return
    print(f"  [OLCUM] H: HTTP {h['http']} · {COOP_ADI}: {h['coop']!r} · {COEP_ADI}: {h['coep']!r}")
    t = s.get("tarayici_ayagi") or {}
    if "olculemedi" in t:
        print(f"  [OLCULEMEDI] T: {t['olculemedi']}")
        print("               >> OLCULEMEDI YESIL DEGILDIR.")
    else:
        print(f"  [OLCUM] T: crossOriginIsolated={t['crossOriginIsolated']!r} · "
              f"typeof SharedArrayBuffer='{t['SharedArrayBuffer']}'")
    for b in s["bulgular"]:
        print(f"  [KIRMIZI] {b}")
    print("-" * 78)
    if s["bulgular"]:
        print("HUKUM: IZOLE DEGIL")
    elif s.get("tarayici_olculemedi"):
        print("HUKUM: H AYAGI YESIL, T AYAGI OLCULEMEDI -- TAM YESIL DEGIL")
    else:
        print("HUKUM: CAPRAZ-KOKEN IZOLE (iki ayak da olculdu)")
    print("=" * 78)


# ---------------------------------------------------------------- altin kume
class _Sunucu(http.server.BaseHTTPRequestHandler):
    basliklar: dict = {}

    def do_GET(self):                                    # noqa: N802
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        for k, v in self.basliklar.items():
            self.send_header(k, v)
        self.send_header("Content-Length", str(len(PROB_SAYFA)))
        self.end_headers()
        self.wfile.write(PROB_SAYFA)

    def log_message(self, *a):                           # sessiz
        return


def _sunucu_ac(basliklar: dict):
    tip = type("_S", (_Sunucu,), {"basliklar": basliklar})
    s = http.server.ThreadingHTTPServer(("127.0.0.1", 0), tip)
    threading.Thread(target=s.serve_forever, daemon=True).start()
    return s, f"http://127.0.0.1:{s.server_address[1]}/"


def altin_kume() -> int:
    try:
        import playwright.sync_api  # noqa: F401
        tarayici_var = True
    except Exception:
        tarayici_var = False

    TAM = {COOP_ADI: COOP_BEKLENEN, COEP_ADI: COEP_BEKLENEN}
    vakalar = [
        ("1) TAM baslik seti -- H SUSMALI", TAM, {"h": 0}),
        ("2) HIC baslik yok -- H ISIRMALI (iki ayak)", {}, {"h": 2}),
        ("3) YALNIZ COOP -- H ISIRMALI (COEP eksik)", {COOP_ADI: COOP_BEKLENEN}, {"h": 1}),
        ("4) YALNIZ COEP -- H ISIRMALI (COOP eksik)", {COEP_ADI: COEP_BEKLENEN}, {"h": 1}),
        ("5) COEP=unsafe-none -- H ISIRMALI (deger birebir)",
         {COOP_ADI: COOP_BEKLENEN, COEP_ADI: "unsafe-none"}, {"h": 1}),
        ("6) COEP=credentialless -- H ISIRMALI (sinir 3: BILEREK)",
         {COOP_ADI: COOP_BEKLENEN, COEP_ADI: "credentialless"}, {"h": 1}),
        ("7) COOP=same-origin-allow-popups -- H ISIRMALI",
         {COOP_ADI: "same-origin-allow-popups", COEP_ADI: COEP_BEKLENEN}, {"h": 1}),
        ("8) baslik ADI kucuk harfle -- H SUSMALI (ad duyarsiz, deger degil)",
         {COOP_ADI.lower(): COOP_BEKLENEN, COEP_ADI.lower(): COEP_BEKLENEN}, {"h": 0}),
    ]

    gecen = toplam = 0
    t_kanitlanmadi = False
    for ad, basliklar, beklenen in vakalar:
        toplam += 1
        s, url = _sunucu_ac(basliklar)
        try:
            h = http_olc(url)
            olculen = len(h.get("bulgular") or [])
        finally:
            s.shutdown()
        ok = olculen == beklenen["h"]
        gecen += ok
        print(f"[{'GECTI' if ok else 'DUSTU'}] {ad}  (H bulgu: beklenen {beklenen['h']}, olculen {olculen})")

    # --- T ayagi: yalniz playwright varsa OLCULUR; yoksa vaka OLCULEMEDI der, GECTI DEMEZ
    for ad, basliklar, bekle_izole in [
        ("9) TAM baslik + TARAYICI -- crossOriginIsolated TRUE olmali", TAM, True),
        ("10) baslik YOK + TARAYICI -- crossOriginIsolated FALSE olmali", {}, False),
    ]:
        if not tarayici_var:
            t_kanitlanmadi = True
            print(f"[KAPSAM DISI] {ad}  -- playwright YOK, vaka KOSULAMADI. "
                  f"Bu vaka N/M'ye SAYILMAZ; T ayagi KANITLANMAMIS sayilir.")
            continue
        toplam += 1
        s, url = _sunucu_ac(basliklar)
        try:
            t = tarayici_olc(url)
        finally:
            s.shutdown()
        ok = ("olculemedi" not in t) and (t.get("crossOriginIsolated") is bekle_izole)
        gecen += ok
        print(f"[{'GECTI' if ok else 'DUSTU'}] {ad}  (olculen: {t.get('crossOriginIsolated', t)})")

    # --- ORTAM HATASI bulgu ile karistirilmamali
    toplam += 1
    with socket.socket() as sk:                      # kapali bir port bul
        sk.bind(("127.0.0.1", 0))
        kapali = sk.getsockname()[1]
    h = http_olc(f"http://127.0.0.1:{kapali}/", zaman_asimi=2.0)
    ok = "ortam_hatasi" in h
    gecen += ok
    print(f"[{'GECTI' if ok else 'DUSTU'}] 11) ULASILAMAYAN adres -- ORTAM HATASI demeli, "
          f"'izole degil' DEMEMELI  (olculen: {'ORTAM HATASI' if ok else h})")

    print("-" * 78)
    print(f"{gecen}/{toplam} vaka gecti.")
    if t_kanitlanmadi:
        print("BEYAN: T ayaginin IKI vakasi KOSULAMADI (playwright yok) ve N/M'ye SAYILMADI.")
        print("       Bu ortamda arac YALNIZ H ayagi icin kendini kanitlamistir; T ayagi")
        print("       kosum aninda zaten [OLCULEMEDI] der -- ve OLCULEMEDI YESIL DEGILDIR.")
    if gecen == toplam:
        print("HUKUM: ARAC KULLANILABILIR -- temizde susuyor, kirlide isiriyor.")
        print("=" * 78)
        return 0
    print("HUKUM: ARAC KULLANILAMAZ -- once kendini kanitlasin.")
    print("=" * 78)
    return CIKIS_BULGU


def main() -> int:
    ap = argparse.ArgumentParser(description="W3 capraz-koken izolasyon olcumu")
    ap.add_argument("url", nargs="?", help="olculecek adres, or. http://127.0.0.1:5298/health/live")
    ap.add_argument("--altin-kume", action="store_true", help="aracin kendi kanitini kos")
    ap.add_argument("--http-only", action="store_true", help="yalniz H ayagi (tarayici kosulmaz)")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()

    if a.altin_kume:
        return altin_kume()
    if not a.url:
        ap.print_help()
        return CIKIS_ORTAM
    kod, s = olc(a.url, tarayici=not a.http_only)
    if a.json:
        print(json.dumps(s, ensure_ascii=False, indent=1))
    else:
        yaz(kod, s)
    return kod


if __name__ == "__main__":
    sys.exit(main())

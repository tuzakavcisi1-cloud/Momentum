#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""O2 OLCUMU -- drift, belge CAPRAZ-KOKEN IZOLE olunca OPFS'e geciyor mu?

W3'un MERKEZI URUN SORUSU budur ve iki denetim turu KAGITTA cevaplayamadi:
  denetim B1 -> "drift_flutter 0.3.1 moveExistingIndexedDbToOpfs bayragini GECIREMIYOR ve
  veritabani.dart driftDatabase() kullaniyor => izolasyon kusursuz saglansa bile drift
  sharedIndexedDb'de KALIR, urun davranisi DEGISMEZ."
Burada GERCEK build, GERCEK tarayicida, IKI kosulda kosturulur ve W2'nin gorunur dikisi
(MOMENTUM-G6-KANIT chosenImplementation=...) konsoldan OKUNUR.

KOSUL A: sunucu COOP/COEP GONDERMEZ  -> crossOriginIsolated = false
KOSUL B: sunucu COOP/COEP GONDERIR   -> crossOriginIsolated = true
Fark VARSA izolasyon urun davranisini degistiriyordur; YOKSA denetimin B1'i DOGRUDUR.
"""
import http.server, json, mimetypes, os, re, sys, threading
from playwright.sync_api import sync_playwright

KOK = "/home/claude/o62/src/client/build/web"
PORT = 5211
ANAHTAR = re.compile(r"MOMENTUM-G6-KANIT[^\n]*")


def sunucu_yap(izole: bool):
    class H(http.server.SimpleHTTPRequestHandler):
        def __init__(self, *a, **k):
            super().__init__(*a, directory=KOK, **k)

        def end_headers(self):
            if izole:
                self.send_header("Cross-Origin-Opener-Policy", "same-origin")
                self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
            self.send_header("Cross-Origin-Resource-Policy", "same-origin")
            super().end_headers()

        def log_message(self, *a):
            return
    return H


def kos(izole: bool, bekleme_ms: int = 25000) -> dict:
    s = http.server.ThreadingHTTPServer(("127.0.0.1", PORT), sunucu_yap(izole))
    threading.Thread(target=s.serve_forever, daemon=True).start()
    konsol, basarisiz = [], []
    try:
        with sync_playwright() as p:
            # ORTAM: konteynerde locale YOK -> intl acilista RangeError atiyor ve uygulama
            # drift init'e HIC gelmiyordu. Bu bir URUN kusuru DEGIL, olcum ortaminin kusuru.
            b = p.chromium.launch(args=["--lang=en-US"])
            try:
                ctx = b.new_context(locale="en-US", timezone_id="Europe/Istanbul")
                pg = ctx.new_page()
                pg.on("console", lambda m: konsol.append(m.text))
                pg.on("pageerror", lambda e: konsol.append(f"PAGEERROR: {e}"))
                pg.on("requestfailed", lambda r: basarisiz.append(f"{r.url} :: {r.failure}"))
                pg.goto(f"http://127.0.0.1:{PORT}/", wait_until="load")
                izolasyon = pg.evaluate("() => [self.crossOriginIsolated, typeof SharedArrayBuffer]")
                # drift init'i BEKLE -- sabit sleep degil, ANAHTAR gorunene kadar yokla (tavanli)
                gecen = 0
                while gecen < bekleme_ms:
                    if any(ANAHTAR.search(c) for c in konsol):
                        break
                    pg.wait_for_timeout(500)
                    gecen += 500
                kanit = [ANAHTAR.search(c).group(0) for c in konsol if ANAHTAR.search(c)]
                ctx.close()
            finally:
                b.close()
    finally:
        s.shutdown()
        s.server_close()      # shutdown() dinleyen soketi KAPATMAZ -> ikinci kosum 'Address already in use'
    return {"izole_beklendi": izole, "crossOriginIsolated": izolasyon[0],
            "typeof_SharedArrayBuffer": izolasyon[1],
            "G6_KANIT": kanit, "basarisiz_istekler": basarisiz[:10],
            "konsol_ilk10": konsol[:10]}


def main():
    if not os.path.isdir(KOK):
        print("ORTAM HATASI: build/web yok"); return 3
    sonuc = {"A_izolasyonsuz": kos(False), "B_izole": kos(True)}
    a, b = sonuc["A_izolasyonsuz"], sonuc["B_izole"]
    sonuc["HUKUM"] = (
        "OLCULEMEDI: G6 kaniti hicbir kosulda gorunmedi"
        if not a["G6_KANIT"] and not b["G6_KANIT"] else
        "IZOLASYON URUN DAVRANISINI DEGISTIRDI" if a["G6_KANIT"] != b["G6_KANIT"] else
        "IZOLASYON URUN DAVRANISINI DEGISTIRMEDI -- denetimin B1'i DOGRU")
    print(json.dumps(sonuc, ensure_ascii=False, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())

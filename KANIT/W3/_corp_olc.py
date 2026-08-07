#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""require-corp FIILEN IS YAPIYOR MU? -- capraz-koken alt kaynak bloklanmasi olcumu.

KANIT/W3/00-ISKELET-OLCUMU-o62.md 6/5: "require-corp altinda CORP gondermeyen bir alt kaynagin
BLOKLANDIGI olculmedi; olculen yalnizca BELGENIN izole oldugudur." Burada o bosluk kapatilir.

Kurgu: belge 127.0.0.1:5111'de (COOP+COEP => izole). Alt kaynak 127.0.0.1:5112'de (AYRI KOKEN).
Ucu de olculur: CORP yok · CORP: same-origin · CORP: cross-origin.
"""
import http.server, json, threading, sys
from playwright.sync_api import sync_playwright

BELGE_PORT, KAYNAK_PORT = 5111, 5112
KAYNAK = f"http://127.0.0.1:{KAYNAK_PORT}"

# 1x1 saydam GIF -- <img> ile no-cors modda yuklenir; COEP'in klasik hedefi budur
GIF = bytes.fromhex("47494638396101000100800000ffffff00000021f90401000000002c000000000100010000020144003b")

SAYFA = ("""<!doctype html><meta charset=utf-8><title>corp-probu</title><body><pre id=s>...</pre>
<script>
const dene = (yol) => new Promise((coz) => {
  const im = new Image();
  const zaman = setTimeout(() => coz('ZAMAN ASIMI'), 4000);
  im.onload  = () => { clearTimeout(zaman); coz('YUKLENDI'); };
  im.onerror = () => { clearTimeout(zaman); coz('BLOKLANDI/HATA'); };
  im.src = '%s' + yol + '?t=' + Math.random();
});
window.SONUC = (async () => ({
  izole: self.crossOriginIsolated,
  corp_yok:          await dene('/yok.gif'),
  corp_same_origin:  await dene('/same.gif'),
  corp_cross_origin: await dene('/cross.gif'),
}))();
</script>""" % KAYNAK).encode("utf-8")


def _yap(basliklar, govde, tur):
    class H(http.server.BaseHTTPRequestHandler):
        def do_GET(self):                                  # noqa: N802
            self.send_response(200)
            self.send_header("Content-Type", tur)
            for k, v in basliklar(self.path).items():
                self.send_header(k, v)
            self.send_header("Content-Length", str(len(govde)))
            self.end_headers()
            self.wfile.write(govde)

        def log_message(self, *a):
            return
    return H


def belge_basliklari(_):
    return {"Cross-Origin-Opener-Policy": "same-origin",
            "Cross-Origin-Embedder-Policy": "require-corp"}


def kaynak_basliklari(yol):
    if yol.startswith("/same.gif"):
        return {"Cross-Origin-Resource-Policy": "same-origin"}
    if yol.startswith("/cross.gif"):
        return {"Cross-Origin-Resource-Policy": "cross-origin"}
    return {}                                              # /yok.gif -- CORP YOK


def main():
    s1 = http.server.ThreadingHTTPServer(("127.0.0.1", BELGE_PORT),
                                         _yap(belge_basliklari, SAYFA, "text/html; charset=utf-8"))
    s2 = http.server.ThreadingHTTPServer(("127.0.0.1", KAYNAK_PORT),
                                         _yap(kaynak_basliklari, GIF, "image/gif"))
    for s in (s1, s2):
        threading.Thread(target=s.serve_forever, daemon=True).start()
    konsol = []
    with sync_playwright() as p:
        b = p.chromium.launch()
        try:
            pg = b.new_page()
            pg.on("console", lambda m: konsol.append(f"{m.type}: {m.text}"))
            pg.goto(f"http://127.0.0.1:{BELGE_PORT}/", wait_until="load")
            sonuc = pg.evaluate("() => window.SONUC")
        finally:
            b.close()
    for s in (s1, s2):
        s.shutdown()

    beklenen = {"corp_yok": "BLOKLANDI/HATA", "corp_same_origin": "BLOKLANDI/HATA",
                "corp_cross_origin": "YUKLENDI"}
    gecti = all(sonuc.get(k) == v for k, v in beklenen.items()) and sonuc.get("izole") is True
    print(json.dumps({"olculen": sonuc, "beklenen": beklenen,
                      "HUKUM": "require-corp FIILEN IS YAPIYOR" if gecti
                               else "BEKLENENDEN SAPMA -- incele",
                      "konsol": konsol[:6]}, ensure_ascii=False, indent=1))
    return 0 if gecti else 1


if __name__ == "__main__":
    sys.exit(main())

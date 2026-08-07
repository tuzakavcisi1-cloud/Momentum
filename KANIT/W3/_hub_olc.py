#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""F/5 olcumu: IZOLE bir belgeden /hubs/sync'e SignalR negotiate + WebSocket yukseltmesi.

Denetim raporu F/5 (ve B-1'in fonksiyonel yarisi): yeni COOP/COEP ara katmaninin SignalR'a ne
yaptigi OLCULMEMISTI. Burada olculur -- iddia edilmez.

Kurgu: probe sayfasi AYRI bir kokende (127.0.0.1:5111) ve COOP/COEP ile servis edilir => belge
IZOLEDIR. Oradan API'ye (127.0.0.1:5298) capraz-koken negotiate (fetch, cors) ve WebSocket denenir.
"""
import http.server, json, threading, sys
from playwright.sync_api import sync_playwright

PROBE_PORT = 5111
API = "http://127.0.0.1:5298"
DEV_KULLANICI = "11111111-1111-1111-1111-111111111111"

SAYFA = ("""<!doctype html><meta charset=utf-8><title>hub-probu</title><body><pre id=s>...</pre>
<script>
window.SONUC = (async () => {
  const r = {izole: self.crossOriginIsolated};
  try {
    const n = await fetch('%s/hubs/sync/negotiate?negotiateVersion=1', {
      method: 'POST', headers: {'X-Momentum-Dev-User': '%s'}});
    r.negotiate_status = n.status;
    r.negotiate_govde = n.ok ? await n.json() : null;
  } catch (e) { r.negotiate_hata = String(e); }

  // (a) BASLIKSIZ WebSocket -- tarayici WS el sikismasina baslik EKLEYEMEZ
  const wsDene = (url) => new Promise((coz) => {
    let ws;
    const bitir = (d) => { try { ws && ws.close(); } catch (_) {} coz(d); };
    try { ws = new WebSocket(url); } catch (e) { return coz({sonuc: 'YAPICI HATASI', hata: String(e)}); }
    const zaman = setTimeout(() => bitir({sonuc: 'ZAMAN ASIMI'}), 4000);
    ws.onopen  = () => { clearTimeout(zaman); bitir({sonuc: 'ACILDI'}); };
    ws.onerror = () => { clearTimeout(zaman); bitir({sonuc: 'HATA (onerror)'}); };
    ws.onclose = (e) => { clearTimeout(zaman); coz({sonuc: 'KAPANDI', kod: e.code, sebep: e.reason}); };
  });

  const id = r.negotiate_govde && r.negotiate_govde.connectionToken;
  r.ws_tokenli = id ? await wsDene('%s/hubs/sync?id=' + encodeURIComponent(id)) : {sonuc: 'TOKEN YOK'};
  r.ws_tokensiz = await wsDene('%s/hubs/sync');
  document.getElementById('s').textContent = JSON.stringify(r);
  return r;
})();
</script>""" % (API, DEV_KULLANICI, API.replace("http", "ws"), API.replace("http", "ws"))).encode("utf-8")


class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):                                     # noqa: N802
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Content-Length", str(len(SAYFA)))
        self.end_headers()
        self.wfile.write(SAYFA)

    def log_message(self, *a):
        return


def main():
    s = http.server.ThreadingHTTPServer(("127.0.0.1", PROBE_PORT), H)
    threading.Thread(target=s.serve_forever, daemon=True).start()
    konsol, basarisiz = [], []
    with sync_playwright() as p:
        b = p.chromium.launch()
        try:
            pg = b.new_page()
            pg.on("console", lambda m: konsol.append(f"{m.type}: {m.text}"))
            pg.on("requestfailed", lambda r: basarisiz.append(f"{r.url} :: {r.failure}"))
            pg.goto(f"http://127.0.0.1:{PROBE_PORT}/", wait_until="load")
            sonuc = pg.evaluate("() => window.SONUC")
        finally:
            b.close()
    s.shutdown()
    print(json.dumps({"probe_kokeni": f"http://127.0.0.1:{PROBE_PORT}", "olculen": sonuc,
                      "basarisiz_istekler": basarisiz, "konsol": konsol[:10]},
                     ensure_ascii=False, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())

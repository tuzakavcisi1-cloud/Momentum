#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""VERI GOCU OLCUMU -- izolasyon acilinca mevcut sharedIndexedDb verisine NE OLUYOR?

Denetim B-11: "drift/lib/src/web/wasm_setup/indexeddb_to_opfs.dart:71-77 ->
  await existingVfs.close(); await IndexedDbFileSystem.deleteDatabase(databaseName);
 v2 'kopyalanir' diyor -- EKSIK BEYAN. Kopyalama ATOMIK DEGIL; sekme yarida kapanirsa OPFS'te
 KISMI bir veritabani kalir ve _selectExistingDatabase bir sonraki acilista OPFS'i mevcut sayip
 oradan devam eder => IndexedDB'deki saglam kopya OKSUZ kalir."

KURGU (urun yolu, ayni kaynak, ayni tarayici profili):
  KOSUM 1  basliksiz  -> drift sharedIndexedDb secer, deposunu OLUSTURUR
  KOSUM 2  COOP/COEP  -> drift opfsLocks secer; IndexedDB deposuna ve OPFS'e NE OLDU?
  KOSUM 3  basliksiz  -> izolasyon GERI ALINIRSA veri hangi tarafta kaldi? (geri donus yolu)

KRITIK: tarayici profili KALICIDIR (launch_persistent_context) ve koken AYNIDIR (ayni port),
yoksa depo paylasilmaz ve olcum SESSIZCE anlamsiz olur.
"""
import http.server, json, os, re, shutil, sys, threading
from playwright.sync_api import sync_playwright

KOK = "/home/claude/o62/src/client/build/web"
PROFIL = "/tmp/o62-goc-profil"
PORT = 5211
ANAHTAR = re.compile(r"MOMENTUM-G6-KANIT[^\n]*")

DEPO_SORGUSU = """
async () => {
  const r = {indexedDB: [], opfs: [], opfs_hata: null};
  try {
    for (const d of await indexedDB.databases()) r.indexedDB.push({ad: d.name, surum: d.version});
  } catch (e) { r.indexedDB = ['HATA: ' + e]; }
  try {
    const kok = await navigator.storage.getDirectory();
    for await (const [ad, tut] of kok.entries()) {
      let bayt = null;
      if (tut.kind === 'file') { try { bayt = (await tut.getFile()).size; } catch (_) {} }
      r.opfs.push({ad, tur: tut.kind, bayt});
    }
  } catch (e) { r.opfs_hata = String(e); }
  return r;
}
"""


def sunucu_yap(izole: bool):
    class H(http.server.SimpleHTTPRequestHandler):
        def __init__(self, *a, **k):
            super().__init__(*a, directory=KOK, **k)

        def end_headers(self):
            if izole:
                self.send_header("Cross-Origin-Opener-Policy", "same-origin")
                self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
            self.send_header("Cross-Origin-Resource-Policy", "same-origin")
            # KALICI PROFIL + HTTP ONBELLEGI = KOR OLCUM: kosum 1'de onbellege giren index.html
            # kosum 2'de BASLIKSIZ haliyle geri servis edildi ve izolasyon HIC uygulanmadi.
            # Olculdu (bu betigin ilk kosumu): kosum 2 crossOriginIsolated=False verdi.
            self.send_header("Cache-Control", "no-store, no-cache, must-revalidate")
            super().end_headers()

        def log_message(self, *a):
            return
    return H


def kos(etiket: str, izole: bool, bekleme_ms: int = 25000) -> dict:
    s = http.server.ThreadingHTTPServer(("127.0.0.1", PORT), sunucu_yap(izole))
    threading.Thread(target=s.serve_forever, daemon=True).start()
    konsol = []
    try:
        with sync_playwright() as p:
            ctx = p.chromium.launch_persistent_context(
                PROFIL, args=["--lang=en-US"], locale="en-US", timezone_id="Europe/Istanbul")
            try:
                pg = ctx.new_page()
                pg.on("console", lambda m: konsol.append(m.text))
                pg.on("pageerror", lambda e: konsol.append(f"PAGEERROR: {e}"))
                pg.goto(f"http://127.0.0.1:{PORT}/", wait_until="load")
                izolasyon = pg.evaluate("() => self.crossOriginIsolated")
                gecen = 0
                while gecen < bekleme_ms:
                    if any(ANAHTAR.search(c) for c in konsol):
                        break
                    pg.wait_for_timeout(500)
                    gecen += 500
                pg.wait_for_timeout(4000)          # drift'in gocu bitirmesine PAY birak
                depo = pg.evaluate(DEPO_SORGUSU)
                kanit = [ANAHTAR.search(c).group(0) for c in konsol if ANAHTAR.search(c)]
            finally:
                ctx.close()
    finally:
        s.shutdown()
        s.server_close()
    if izolasyon is not izole:
        return {"etiket": etiket, "izole_beklendi": izole, "crossOriginIsolated": izolasyon,
                "KOR": ("OLCUM KOR: beklenen izolasyon %r, olculen %r. Depo sonuclari "
                        "ANLAMSIZDIR." % (izole, izolasyon)),
                "G6_KANIT": kanit, "depo": depo, "goc_izi": []}
    return {"etiket": etiket, "izole_beklendi": izole, "crossOriginIsolated": izolasyon,
            "G6_KANIT": kanit, "depo": depo,
            "goc_izi": [c for c in konsol if "opfs" in c.lower() or "migrat" in c.lower()][:5]}


def main():
    if not os.path.isdir(KOK):
        print("ORTAM HATASI: build/web yok"); return 3
    shutil.rmtree(PROFIL, ignore_errors=True)      # TEMIZ profille basla, yoksa olcum bayatlar
    os.makedirs(PROFIL, exist_ok=True)
    sonuc = [kos("1-basliksiz (depo OLUSSUN)", False),
             kos("2-IZOLE (goc burada olmali)", True),
             kos("3-basliksiz (geri donus)", False)]
    kor = [r for r in sonuc if "KOR" in r]
    print(json.dumps(sonuc, ensure_ascii=False, indent=1))
    if kor:
        print("DUR: %d kosum KORDU -- hukum VERILMEZ." % len(kor))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

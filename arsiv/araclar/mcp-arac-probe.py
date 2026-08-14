# -*- coding: utf-8 -*-
"""mcp-arac-probe.py -- bir MCP sunucusunun GERCEK arac listesini olcer.

NEDEN VAR (K43'un dersi): `--help` ciktisindaki OZELLIK listesi ARAC listesi
DEGILDIR. Oturum 28'de Cowork tam bu tuzaga dustu ve kendi iddiasini
yanlislamak zorunda kaldi. Bu betik sunucuyu stdio uzerinden JSON-RPC ile
konusturur ve `tools/list` cevabini OLCER.

Cikti SAF ASCII'dir (cp1254 kalkani: PYTHONUTF8 ayari olmadan da cokmez).

Kullanim:
  python araclar\\mcp-arac-probe.py <sunucu-komutu> [arg...]
  python araclar\\mcp-arac-probe.py --sema <arac-adi> -- <sunucu-komutu> [arg...]

Cikis kodlari: 0 = olculdu · 2 = sunucu cevap vermedi · 3 = ortam hatasi
"""
import json
import subprocess
import sys
import time

TIMEOUT_S = 60


def _yaz(s):
    sys.stdout.write(s.encode("ascii", "replace").decode("ascii") + "\n")
    sys.stdout.flush()


def _gonder(p, obj):
    p.stdin.write(json.dumps(obj) + "\n")
    p.stdin.flush()


def _oku_id(p, beklenen_id):
    """Belirtilen id'li cevabi bekler; bildirimleri/loglari atlar."""
    son = time.time() + TIMEOUT_S
    while time.time() < son:
        satir = p.stdout.readline()
        if not satir:
            return None
        satir = satir.strip()
        if not satir:
            continue
        try:
            m = json.loads(satir)
        except ValueError:
            continue
        if m.get("id") == beklenen_id:
            return m
    return None


def main(argv):
    sema_arac = None
    if argv and argv[0] == "--sema":
        sema_arac = argv[1]
        argv = argv[2:]
    # KUSUR/DUZELTME (olculdu, oturum 29): bu satir once YALNIZ --sema dalinin
    # icindeydi; --sema'siz cagrida bastaki "--" ayiklanmiyor ve Popen onu komut
    # saniyordu ([WinError 2]). Ayiklama artik KOSULSUZ.
    while argv and argv[0] == "--":
        argv = argv[1:]
    if not argv:
        _yaz("KULLANIM: python mcp-arac-probe.py [--sema <arac>] -- <komut> [arg...]")
        return 3
    try:
        p = subprocess.Popen(
            argv, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL, text=True, encoding="utf-8",
            errors="replace", bufsize=1,
        )
    except OSError as e:
        _yaz("ORTAM HATASI: sunucu baslatilamadi: " + str(e))
        return 3

    _gonder(p, {"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {
        "protocolVersion": "2024-11-05", "capabilities": {},
        "clientInfo": {"name": "momentum-probe", "version": "1"}}})
    init = _oku_id(p, 1)
    if init is None:
        _yaz("HUKUM: SUNUCU CEVAP VERMEDI (initialize)")
        p.kill()
        return 2

    si = (init.get("result") or {}).get("serverInfo") or {}
    _yaz("=" * 74)
    _yaz("SUNUCU: " + str(si.get("name")) + " " + str(si.get("version")))
    _yaz("PROTOKOL: " + str((init.get("result") or {}).get("protocolVersion")))
    _yaz("=" * 74)

    _gonder(p, {"jsonrpc": "2.0", "method": "notifications/initialized"})
    _gonder(p, {"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}})
    cev = _oku_id(p, 2)
    if cev is None:
        _yaz("HUKUM: SUNUCU CEVAP VERMEDI (tools/list)")
        p.kill()
        return 2

    araclar = (cev.get("result") or {}).get("tools") or []
    _yaz("OLCULEN ARAC SAYISI: " + str(len(araclar)))
    _yaz("-" * 74)
    for t in sorted(araclar, key=lambda x: x.get("name", "")):
        sema = t.get("inputSchema") or {}
        alanlar = sorted((sema.get("properties") or {}).keys())
        zorunlu = sorted(sema.get("required") or [])
        _yaz("* " + t.get("name", "?"))
        _yaz("    parametreler: " + (", ".join(alanlar) if alanlar else "(yok)"))
        _yaz("    zorunlu     : " + (", ".join(zorunlu) if zorunlu else "(yok)"))

    if sema_arac:
        _yaz("=" * 74)
        _yaz("TAM SEMA: " + sema_arac)
        _yaz("=" * 74)
        bulundu = False
        for t in araclar:
            if t.get("name") == sema_arac:
                bulundu = True
                _yaz("ACIKLAMA:")
                _yaz(str(t.get("description", "")))
                _yaz("SEMA:")
                _yaz(json.dumps(t.get("inputSchema") or {}, indent=2,
                                ensure_ascii=True, sort_keys=True))
        if not bulundu:
            _yaz("BULUNAMADI: " + sema_arac + " bu sunucuda YOK.")

    p.kill()
    _yaz("=" * 74)
    _yaz("HUKUM: OLCULDU. Bu liste `--help` ciktisi DEGIL, `tools/list` cevabidir.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

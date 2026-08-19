# -*- coding: utf-8 -*-
"""URUN DONGUSUNUN BIREBIR TAKLIDI (SyncPuller.PullIncrementalAsync).
ORDER BY urunun yazdigi sekilde (golgelenmis, ::text), WHERE urunun yazdigi sekilde (xid8 sayisal),
next = sayfanin SON satiri, hasMore = (satir sayisi == PageSize).
"""
import subprocess, sys
sys.stdout.reconfigure(encoding="utf-8")

def q(sql):
    p = subprocess.run(["psql","-h","/tmp","-p","55432","-U","postgres","-d","postgres","-A","-t","-F","|","-c",sql],
                       capture_output=True, text=True)
    if p.returncode != 0:
        raise SystemExit("PSQL HATA: " + p.stderr)
    return [l for l in p.stdout.strip().split("\n") if l]

def kur(bas, adet):
    q("DROP TABLE IF EXISTS outbox_messages")
    q("CREATE TABLE outbox_messages (commit_xid xid8 NOT NULL, server_seq bigint NOT NULL, payload text NOT NULL)")
    q("INSERT INTO outbox_messages (commit_xid, server_seq, payload) "
      "SELECT (%d + i)::text::xid8, (1+i)::bigint, 'v'||i FROM generate_series(0,%d) AS g(i)" % (bas, adet-1))

def cek(sql_order, sayfa, bas_xid=0, bas_seq=0):
    """Urun dongusu. sql_order: ORDER BY ifadesi."""
    xid, seq = bas_xid, bas_seq
    gorulen, tur = [], 0
    while True:
        tur += 1
        if tur > 20: return gorulen, tur, "DONGU-TAVANI"
        rows = q("SELECT commit_xid::text, server_seq, payload FROM outbox_messages o "
                 "WHERE (commit_xid, server_seq) > ('%d'::xid8, %d) "
                 "ORDER BY %s LIMIT %d" % (xid, seq, sql_order, sayfa))
        for r in rows:
            a,b,c = r.split("|"); gorulen.append(c)
        if rows:
            a,b,c = rows[-1].split("|"); xid, seq = int(a), int(b)
        if len(rows) != sayfa:
            return gorulen, tur, "BITTI"

def rapor(baslik, bas, adet, sayfa):
    kur(bas, adet)
    beklenen = ["v%d" % i for i in range(adet)]
    print("\n=== %s  (xid %d..%d, %d satir, PageSize=%d) ===" % (baslik, bas, bas+adet-1, adet, sayfa))
    for etiket, order in (("URUN  (ORDER BY commit_xid, server_seq)", "commit_xid, server_seq"),
                          ("DUZELTME (ORDER BY o.commit_xid, o.server_seq)", "o.commit_xid, o.server_seq")):
        gorulen, tur, son = cek(order, sayfa)
        kayip = [v for v in beklenen if v not in gorulen]
        tekrar = len(gorulen) - len(set(gorulen))
        sirali = (gorulen == beklenen)
        print("  %-46s tur=%-2d teslim=%-4d KAYIP=%-4d tekrar=%-3d sira_dogru=%s"
              % (etiket, tur, len(gorulen), len(kayip), tekrar, sirali))
        if kayip:
            k = kayip if len(kayip) <= 6 else kayip[:3] + ["..."] + kayip[-2:]
            print("      KAYIP ORNEK: %s" % ", ".join(k))

rapor("SENARYO 1 - kucuk sayfa", 988, 25, 5)
rapor("SENARYO 2 - URUNUN GERCEK PageSize'i", 900, 600, 500)
rapor("SENARYO 3 - tek sayfa (sinir asilmiyor, sayfalama yok)", 988, 25, 500)

# -*- coding: utf-8 -*-
"""o83-F Test 2 penceresi: X=752 (Claude Code'un olctugu ufuk) altinda kusur ISIRIYOR mu?
Iki aday pencere karsilastirilir. Urun dongusu birebir (ORDER BY golgeli, WHERE sayisal,
next = sayfanin son satiri, devam = satir sayisi == PageSize=500)."""
import subprocess, sys
sys.stdout.reconfigure(encoding="utf-8")

def q(sql):
    p = subprocess.run(["psql","-h","/tmp","-p","55432","-U","postgres","-d","postgres","-A","-t","-F","|","-c",sql],
                       capture_output=True, text=True)
    if p.returncode != 0: raise SystemExit("PSQL HATA: " + p.stderr)
    return [l for l in p.stdout.strip().split("\n") if l]

def kur(xidler):
    q("DROP TABLE IF EXISTS outbox_messages")
    q("CREATE TABLE outbox_messages (commit_xid xid8 NOT NULL, server_seq bigint GENERATED ALWAYS AS IDENTITY, payload text NOT NULL)")
    degerler = ",".join("('%d'::xid8,'v%d')" % (x, i) for i, x in enumerate(xidler))
    q("INSERT INTO outbox_messages (commit_xid, payload) VALUES " + degerler)

def cek(order, sayfa=500):
    xid, seq, gorulen, tur = 0, 0, [], 0
    while True:
        tur += 1
        if tur > 20: return gorulen, tur
        rows = q("SELECT commit_xid::text, server_seq, payload FROM outbox_messages o "
                 "WHERE (commit_xid, server_seq) > ('%d'::xid8, %d) ORDER BY %s LIMIT %d"
                 % (xid, seq, order, sayfa))
        for r in rows: gorulen.append(r.split("|")[2])
        if rows:
            a,b,_ = rows[-1].split("|"); xid, seq = int(a), int(b)
        if len(rows) != sayfa: return gorulen, tur

def dene(ad, xidler, X):
    kur(xidler)
    beklenen = ["v%d" % i for i in range(len(xidler))]
    print("\n=== %s ===" % ad)
    print("  xid araligi: %d..%d (%d satir) · en buyuk xid %d < X=%d mi: %s"
          % (min(xidler), max(xidler), len(xidler), max(xidler), X, "EVET" if max(xidler) < X else "HAYIR"))
    for etiket, order in (("URUN   (ORDER BY commit_xid, server_seq)", "commit_xid, server_seq"),
                          ("DUZELT (ORDER BY o.commit_xid, o.server_seq)", "o.commit_xid, o.server_seq")):
        g, tur = cek(order)
        kayip = [v for v in beklenen if v not in g]
        print("  %-45s tur=%d teslim=%-4d KAYIP=%-4d sira_dogru=%s"
              % (etiket, tur, len(g), len(kayip), g == beklenen))

X = 752   # Claude Code'un cihazda olctugu ufuk
# ADAY: B=100 · alt grup 90..99 (hepsi '9' ile baslar) · ust grup 100..599 (tam 500 satir = PageSize)
dene("ADAY PENCERE  B=100 · xid 90..599 · 510 satir", list(range(90, 600)), X)
# KARSILASTIRMA: emrin ilk kurali B=1000 isterdi -> X=752 altinda IMKANSIZ
print("\n=== EMRIN ILK KURALI (oncesi=100, sonrasi=499, B=10^k) ===")
print("  B=1000 gerekiyordu -> B+499=1499 < X=752 SAGLANMIYOR -> pencere YOK (Claude Code hakli)")

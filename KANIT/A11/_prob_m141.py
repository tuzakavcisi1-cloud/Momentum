# -*- coding: utf-8 -*-
"""M141 ESDEGERLIK YANLASLAMASI (Cowork, oturum 50).

Iddia: A11/G22/c ayagi M141'i OLCMEZ cunku o senaryoda retry timer'i KENDISI
atesleyip callback icinde `_zamanlayici = null` yapiyor -- `sifirla()`'nin
iptal ayagi hic is yapmiyor. Yanlaslama: timer HENUZ ATESLEMEDEN disaridan
gelen BASARILI bir tur kurgulanir. Orijinal kodda YESIL, M141'de KIRMIZI
olmali. Ikisi de olculur; degilse iddia CURUR.
"""
import hashlib
import io
import os
import subprocess
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

KOK = r"C:\dev\Momentum"
ISTEMCI = os.path.join(KOK, "src", "client")
FLUTTER = r"C:\src\flutter\bin\flutter.bat"
KANIT = os.path.join(KOK, "KANIT", "A11")
TEST = os.path.join(ISTEMCI, "test", "ag_donus_itmesi_test.dart")
IY = os.path.join(ISTEMCI, "lib", "veri", "itme_yeniden_deneme.dart")

ORTAM = dict(os.environ)
ORTAM["PROGRAMFILES(X86)"] = r"C:\Program Files (x86)"

PROB_ESKI = "\n  );\n}"
PROB_YENI = """
  );

  test(
    'PROB-M141: bekleyen retry timer + DISARIDAN basarili tur -- sifirla() IPTAL ETMELI',
    () async {
      final k = await kurulumYap();
      await k.depo.ekle('prob m141');

      fakeAsync((async) {
        var cagriSayisi = 0;
        final agi = SahteSenkronAgi(
          davranis: (govde, cagriNo) async {
            cagriSayisi++;
            if (cagriSayisi == 1) return SenkronAgHatasi(Exception('tasima hatasi'));
            return _basariliYanit(govde);
          },
        );
        final dongu = donguOlustur(k, agi, rastgele: Random(3));

        unawaited(dongu.turCalistir());
        async.elapse(Duration.zero);
        expect(cagriSayisi, 1);
        expect(async.pendingTimers, isNotEmpty, reason: 'retry planlanmis olmali');

        unawaited(dongu.turCalistir());
        async.elapse(Duration.zero);
        expect(cagriSayisi, 2, reason: 'disaridan gelen tur kosmus olmali');
        expect(
          async.pendingTimers,
          isEmpty,
          reason: 'sifirla() bekleyen retry timer ini IPTAL ETMELIYDI',
        );
      });

      await k.db.close();
    },
  );
}"""

M141_ESKI = ("  void sifirla() {\n    _zamanlayici?.cancel();\n"
             "    _zamanlayici = null;\n    _indeks = 0;\n  }\n")
M141_YENI = "  void sifirla() {\n    _indeks = 0; // MUTANT M141\n  }\n"


def oku(p):
    with io.open(p, "rb") as f:
        return f.read()


def yaz(p, b):
    with io.open(p, "wb") as f:
        f.write(b)


def sha(b):
    return hashlib.sha256(b).hexdigest()[:8].upper()


def nl(ham, s):
    return s.replace("\n", "\r\n") if b"\r\n" in ham else s


def yama(yol, eski, yeni, son=False):
    ham = oku(yol)
    eb = nl(ham, eski).encode("utf-8")
    nb = nl(ham, yeni).encode("utf-8")
    n = ham.count(eb)
    if n == 0 or (n != 1 and not son):
        raise SystemExit("ESLESME %d (1 bekleniyordu): %s" % (n, os.path.basename(yol)))
    if son:
        i = ham.rfind(eb)
        yaz(yol, ham[:i] + nb + ham[i + len(eb):])
    else:
        yaz(yol, ham.replace(eb, nb))


def kos():
    p = subprocess.run(["cmd", "/c", FLUTTER, "test", "test/ag_donus_itmesi_test.dart"],
                       cwd=ISTEMCI, capture_output=True, text=True,
                       encoding="utf-8", errors="replace", env=ORTAM)
    return p.returncode, (p.stdout or "") + (p.stderr or "")


def main():
    test_yedek = oku(TEST)
    iy_yedek = oku(IY)
    satirlar = ["M141 ESDEGERLIK YANLASLAMASI",
                "  TABAN test sha8=%s (%d b) | itme_yeniden_deneme sha8=%s (%d b)"
                % (sha(test_yedek), len(test_yedek), sha(iy_yedek), len(iy_yedek))]
    ciktilar = []
    try:
        # P1: yalniz prob ayagi -- ORIJINAL kodda YESIL olmali.
        yama(TEST, PROB_ESKI, PROB_YENI, son=True)
        rc1, c1 = kos()
        satirlar.append("  P1 prob ayagi + ORIJINAL kod  EXIT=%d  (beklenen 0)" % rc1)
        ciktilar.append(("P1", rc1, c1))

        # P2: prob ayagi + M141 -- KIRMIZI olmali.
        yama(IY, M141_ESKI, M141_YENI)
        rc2, c2 = kos()
        satirlar.append("  P2 prob ayagi + M141          EXIT=%d  (beklenen !=0)" % rc2)
        ciktilar.append(("P2", rc2, c2))
    finally:
        yaz(TEST, test_yedek)
        yaz(IY, iy_yedek)
        satirlar.append("  GERI ALMA test ozdes=%s | itme_yeniden_deneme ozdes=%s"
                        % (oku(TEST) == test_yedek, oku(IY) == iy_yedek))

    hukum = ("M141 ESDEGER DEGIL -- A11/G22/c KOR AYAK"
             if (ciktilar and ciktilar[0][1] == 0 and len(ciktilar) > 1 and ciktilar[1][1] != 0)
             else "IDDIA CURUDU ya da OLCULEMEDI")
    satirlar.append("  HUKUM: %s" % hukum)
    metin = "\n".join(satirlar)
    with io.open(os.path.join(KANIT, "03-MUTANT-M141-YANLASLAMA.txt"), "w",
                 encoding="utf-8", errors="replace") as f:
        f.write(metin + "\n\n")
        for ad, rc, c in ciktilar:
            f.write("=== %s EXIT=%d ===\n" % (ad, rc))
            f.write("\n".join([x for x in c.replace("\r", "").split("\n") if x.strip()][-25:]))
            f.write("\n\n")
    print(metin)
    return 0


if __name__ == "__main__":
    sys.exit(main())

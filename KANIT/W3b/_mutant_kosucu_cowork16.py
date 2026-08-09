"""GOREV-W3b T5 -- COWORK'un 16 ICERIK MUTANTI kosucusu (K118 + K34-f).

NEDEN AYRI DOSYA: _mutant_kosucu.py'yi Claude Code yazdi ve 16 icerik mutantinin
9'u OLU cikti (o66'da Cowork olctu). K34-f geregi ONARAN EL YAZAN ELDEN AYRIDIR ⇒
uretici artefakti OLDUGU GIBI birakildi, onarim buraya yazildi.

UC ONARIM (hepsi olculmus sebeple):
  1. KOK argv[1]'den ya da CWD'den gelir -- SABIT WINDOWS YOLU YOK (B-O64-2 sinifi,
     ureticinin kopyasinda ikinci kez tekrarlanmisti: mount'ta FileNotFoundError).
  2. Uc mutant (M251/M252/M254) ureticide eski=None,yeni=None ile TANIMSIZDI ve
     ham.count(None) TypeError veriyordu ⇒ uc yeni KIP: whole/empty/json_del.
  3. Cok-eslesmede ureticinin n==1 korumasi yamayi HIC UYGULAMIYORDU (capa
     gercek flutter_bootstrap.js'te 12 / 2 / 0 kez geciyor) ⇒ kip basina acik
     semantik (first/append) + eslesme sayisi KANITA yazilir.

🔴 UREITICIDE OLMAYAN KRITIK AYAK: yama UYGULANDI MI diye SHA ile olculur.
   sha(yamali) == sha(yedek) ise mutant OLUDUR ve kapi ciktisi HUKUMSUZ sayilir --
   sessizce yesil donmez. "Yamanin fiilen uygulandigi olculmeden kosum gecersizdir" (K118).
"""
import hashlib, io, json, os, subprocess, sys, time

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

KOK = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")
API = os.path.join(KOK, "src", "backend", "Momentum.Api")
APPSETTINGS = os.path.join(API, "appsettings.json")
APPSETTINGS_DEV = os.path.join(API, "appsettings.Development.json")
GITIGNORE = os.path.join(KOK, ".gitignore")
WWWROOT = os.path.join(API, "wwwroot")
FB = os.path.join(WWWROOT, "flutter_bootstrap.js")
FJS = os.path.join(WWWROOT, "flutter.js")
BUILD_JSON = os.path.join(WWWROOT, "_BUILD.json")
INDEX = os.path.join(WWWROOT, "index.html")
KAPI = os.path.join(KOK, "araclar", "yayin-kapisi.py")
KANIT_DIR = os.path.join(KOK, "KANIT", "W3b")
KOD = {0: "YESIL", 1: "SARI", 2: "KIRMIZI", 3: "ORTAM HATASI/OLCULEMEDI"}


def oku(p):
    with io.open(p, "rb") as f:
        return f.read()


def yaz(p, b):
    with io.open(p, "wb") as f:
        f.write(b)


def sha(b):
    return hashlib.sha256(b).hexdigest()[:8].upper()


def kapiyi_kos():
    p = subprocess.run([sys.executable, KAPI, KOK], capture_output=True,
                       text=True, encoding="utf-8", errors="replace")
    return p.returncode, (p.stdout or "") + (p.stderr or "")


def yamala(ham, kip, eski, yeni):
    """(yeni_bayt, olcum_notu) dondurur. Kip semantigi ACIKTIR, tahmin degil."""
    if kip == "whole":
        return yeni, "TUM DOSYA degistirildi (%d b -> %d b)" % (len(ham), len(yeni))
    if kip == "empty":
        return b"", "dosya BOSALTILDI (%d b -> 0 b)" % len(ham)
    if kip == "append":
        return ham + yeni, "dosya SONUNA %d b eklendi" % len(yeni)
    if kip == "json_del":
        d = json.loads(ham.decode("utf-8"))
        vardi = eski in d
        d.pop(eski, None)
        return (json.dumps(d, indent=2).encode("utf-8"),
                "JSON anahtari '%s' silindi (anahtar vardi=%s)" % (eski, vardi))
    n = ham.count(eski)
    if kip == "first":
        return ham.replace(eski, yeni, 1), "capa %d kez geciyor, YALNIZ ILKI degistirildi" % n
    if kip == "all":
        return ham.replace(eski, yeni), "capa %d kez geciyor, HEPSI degistirildi" % n
    raise ValueError("bilinmeyen kip: %s" % kip)


def kos(ad, dosya, kip, eski, yeni, beklenen, kirmizi_yasak=False):
    yedek = oku(dosya)
    y_sha = sha(yedek)
    rc = cikti = None
    olu = False
    try:
        yamali, not_ = yamala(yedek, kip, eski, yeni)
        if sha(yamali) == y_sha:
            olu = True
            not_ += "  🔴 OLU MUTANT: yama dosyayi DEGISTIRMEDI"
            rc, cikti = None, "OLU MUTANT -- kapi KOSULMADI (hukumsuz)"
        else:
            yaz(dosya, yamali)
            uygulandi = sha(oku(dosya)) == sha(yamali)
            not_ += "  yama diske indi=%s (%s -> %s)" % (uygulandi, y_sha, sha(yamali))
            rc, cikti = kapiyi_kos()
    except Exception as ex:
        not_ = "ISTISNA: %r" % ex
        olu = True
    finally:
        yaz(dosya, yedek)
        ozdes = sha(oku(dosya)) == y_sha
    return {"ad": ad, "rc": rc, "olu": olu, "ozdes": ozdes, "not": not_,
            "beklenen": beklenen, "kirmizi_yasak": kirmizi_yasak, "cikti": cikti}


YER_TUTUCU = b"<!doctype html><html><head><title>yer tutucu</title></head><body>bos</body></html>"

M = [
    ("M246", APPSETTINGS, "first", b'"Istemci": {\n    "KokDizin": "wwwroot"\n  }', b'"IstemciSILINDI": {}', "G48/a KIRMIZI", False),
    ("M247", APPSETTINGS, "first", b'"KokDizin": "wwwroot"', b'"KokDizin": "wwwroot2"', "G48/b KIRMIZI", False),
    ("M248", APPSETTINGS, "first", b'{\n  "Logging"', b'{ GECERSIZ_JSON "Logging"', "ORTAM HATASI (3)", False),
    ("M249", GITIGNORE, "first", b"src/backend/Momentum.Api/wwwroot/", b"wwwroot", "G49/a+c KIRMIZI", False),
    ("M251", INDEX, "whole", None, YER_TUTUCU, "G50/a KIRMIZI (yer tutucu, bootstrap referansi YOK)", False),
    ("M252", FB, "empty", None, None, "G50/b KIRMIZI (+ G50/e hukumsuz)", False),
    ("M254", BUILD_JSON, "json_del", "kaynakSha", None, "G50/d KIRMIZI", False),
    ("M255", FB, "append", None, b"\n/*M255 enjekte*/var s='http://10.0.2.2:5298';\n", "G50/e KIRMIZI", False),
    ("M257", FB, "first", b'"useLocalCanvasKit":true', b'"useLocalCanvasKit":false', "G51/a KIRMIZI (cekirdek kusur)", False),
    ("M258", FB, "append", None, b'\n/*M258*/canvasKitBaseUrl:"https://x/";\n', "G51/b KIRMIZI (cift tirnak)", False),
    ("M259", FB, "append", None, b"\n/*M259*/canvasKitBaseUrl:'https://x/';\n", "G51/b KIRMIZI (tek tirnak)", False),
    ("M260", FB, "append", None, b'\n/*M260*/canvasKitBaseUrl:"//x/";\n', "G51/b KIRMIZI (protokol-goreli)", False),
    ("M261", FJS, "first", b"www.gstatic.com/flutter-canvaskit", b"www.gstatic.com/DEGISTIRILDI", "G51/c SARI", False),
    ("M263", FB, "first", b"canvasKitBaseUrl", b"XX", "G51/b2 SARI (taban sayi 2->1)", False),
    ("MW23", FB, "append", None, b"\n// canvasKitBaseUrl\n", "SUSMALI: KIRMIZI OLMAMALI (rc != 2)", True),
    ("MW24", APPSETTINGS_DEV, "first", b'"Cors"', b'"AlakasizAnahtar": true, "Cors"', "SUSMALI: rc != 2", True),
]


def main():
    print("=" * 78)
    print("GOREV-W3b T5 -- 16 ICERIK MUTANTI (COWORK kosumu, K26/K34-f)")
    print("KOK =", KOK)
    print("=" * 78)
    ozet, olu, hatali = [], [], []
    for ad, dosya, kip, eski, yeni, bek, ky in M:
        t0 = time.time()
        r = kos(ad, dosya, kip, eski, yeni, bek, ky)
        et = KOD.get(r["rc"], "OLU/BILINMEYEN")
        s = "  %-6s rc=%-4s %-24s ozdes=%-5s %.1fs | %s\n          beklenen: %s\n          olcum   : %s" % (
            ad, r["rc"], et, r["ozdes"], time.time() - t0,
            "OLU" if r["olu"] else "kostu", r["beklenen"], r["not"])
        print(s, flush=True)
        ozet.append(s)
        if r["olu"]:
            olu.append(ad)
        if not r["ozdes"]:
            hatali.append(ad)
        with io.open(os.path.join(KANIT_DIR, "_MUTANT-%s.txt" % ad), "w",
                     encoding="utf-8", errors="replace") as f:
            f.write("MUTANT %s -- COWORK KOSUMU (K26: ureten != denetleyen)\nbeklenen: %s\nrc=%s (%s)\nolu=%s\nyedek ozdes=%s\nolcum: %s\n\n=== kapi ciktisi ===\n%s"
                    % (ad, r["beklenen"], r["rc"], et, r["olu"], r["ozdes"], r["not"], r["cikti"]))
    print("-" * 78)
    print("OLU MUTANT:", olu or "YOK")
    print("GERI YUKLEME BOZUK:", hatali or "YOK (hepsi bayt-ozdes)")
    with io.open(os.path.join(KANIT_DIR, "_MUTANT-OZET-COWORK-16.txt"), "w",
                 encoding="utf-8", errors="replace") as f:
        f.write("GOREV-W3b -- 16 ICERIK MUTANTI, COWORK KOSUMU\nKOK=%s\n\n%s\n\nOLU: %s\nGERI YUKLEME BOZUK: %s\n\nBU BIR KABUL BEYANI DEGILDIR -- hukum ayri yazilir.\n"
                % (KOK, "\n".join(ozet), olu or "YOK", hatali or "YOK"))
    return 0


if __name__ == "__main__":
    sys.exit(main())

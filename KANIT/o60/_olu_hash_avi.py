# -*- coding: utf-8 -*-
"""Depoda ESKI (cozumlenmeyen) commit hash atfi ariyor.
Once KENDINI kanitlar (altin kume), sonra tarar.
"""
import os, re, subprocess, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

KOK = r"C:\dev\Momentum"
# Kucuk harfli 7-40 hex = commit hash adayi.
# BUYUK harfli 8 hex = bu projede DOSYA sha256 kimligi (DURUM.md 9) -> ADAY DEGIL.
ADAY = re.compile(r"(?<![0-9A-Za-z])([0-9a-f]{7,40})(?![0-9A-Za-z])")
SADECE_RAKAM = re.compile(r"^[0-9]+$")

# 🔴 KAPSAM DARALTILDI (ilk surum 884 sahte-pozitif uretti).
# Notun istedigi yer: "kendi hafiza/karar gunlugu dosyalarin".
# KANIT/** HAM ARAC CIKTISIDIR (Flutter engineContentHash, pub hash'leri...) --
# oradaki 40-hex dizgeler commit ATFI DEGILDIR; taranmaz.
KANONIK_DOSYA = [
    "DURUM.md", "CLAUDE.md", "PROJE_HAFIZA.md", "BORCLAR.md",
    "ORTAM.md", "KAPILAR.md", "DESIGN.md", "PROJE_RADAR.jsonl", "README.md",
]
KANONIK_DIZIN = ["GOREV_CLAUDE_CODE", "docs"]
TARANAN_UZANTI = {".md", ".jsonl"}


def cozumlenir_mi(h, onbellek={}):
    """CANLI = HEAD'den ULASILABILIR.

    🔴 'git cat-file -t' YETMEZ: 6 Agu 2026 rebase'inden sonra eski commit'ler
    yerel .git'te DANGLING nesne olarak KALDI (gc almadi) ve cat-file onlara
    'commit' der. Ama temiz bir klonda YOKLAR. cat-file ile olcen bir kapi bu
    makinede YESIL, meslektasin klonunda KIRMIZI verir = TEKRARLANAMAZ KAPI.
    Dogru yordam: merge-base --is-ancestor (ulasilabilirlik).
    """
    if h in onbellek:
        return onbellek[h]
    var = subprocess.run(["git", "cat-file", "-t", h],
                         cwd=KOK, capture_output=True, text=True)
    if var.returncode != 0 or var.stdout.strip() not in ("commit", "tag"):
        onbellek[h] = False
        return False
    ula = subprocess.run(["git", "merge-base", "--is-ancestor", h, "HEAD"],
                         cwd=KOK, capture_output=True, text=True)
    ok = (ula.returncode == 0)
    onbellek[h] = ok
    return ok


print("=" * 70)
print("ALTIN KUME (arac kendini kanitlar)")
print("=" * 70)
gercek = subprocess.run(["git", "rev-parse", "HEAD"], cwd=KOK,
                        capture_output=True, text=True).stdout.strip()
vakalar = [
    ("A1 gercek HEAD tam",  gercek,     True),
    ("A2 gercek HEAD kisa", gercek[:7], True),
    # A3 KRITIK: nesne VAR (dangling) ama HEAD'den ULASILAMAZ -> OLU sayilmali.
    # Bu vaka aracin ilk surumunu DUSURDU (cat-file 'commit' diyordu).
    ("A3 dangling (rebase oncesi)", "a474463", False),
    ("A4 hic olmayan hash", "deadbee",  False),
    ("A5 tamamen sifir",    "0000000",  False),
]
gecti = 0
for ad, h, bek in vakalar:
    goz = cozumlenir_mi(h)
    ok = (goz == bek)
    gecti += ok
    print("  [%s] %-22s %-42s beklenen=%s gozlenen=%s" %
          ("GECTI" if ok else "DUSTU", ad, h, bek, goz))
if gecti != len(vakalar):
    print("\n[ORTAM HATASI] Altin kume DUSTU -> tarama HUKMU GECERSIZ.")
    sys.exit(3)
print("  -> %d/%d GECTI. Arac isirir." % (gecti, len(vakalar)))

print("\n" + "=" * 70)
print("TARAMA")
print("=" * 70)
hedefler = []
for ad in KANONIK_DOSYA:
    y = os.path.join(KOK, ad)
    if os.path.isfile(y):
        hedefler.append(y)
for dz in KANONIK_DIZIN:
    for kok, _, dosyalar in os.walk(os.path.join(KOK, dz)):
        for ad in dosyalar:
            if os.path.splitext(ad)[1].lower() in TARANAN_UZANTI:
                hedefler.append(os.path.join(kok, ad))

olu, canli, dosya_sayisi = {}, {}, 0
if True:
    for yol in hedefler:
        try:
            metin = open(yol, encoding="utf-8", errors="replace").read()
        except Exception:
            continue
        dosya_sayisi += 1
        for i, satir in enumerate(metin.split("\n"), 1):
            for m in ADAY.finditer(satir):
                h = m.group(1)
                if SADECE_RAKAM.match(h):
                    continue
                baglam = satir.strip()
                if len(baglam) > 150:
                    s = max(0, m.start() - 60)
                    baglam = "..." + satir[s:m.end() + 60].strip() + "..."
                kayit = (os.path.relpath(yol, KOK), i, baglam)
                (canli if cozumlenir_mi(h) else olu).setdefault(h, []).append(kayit)

print("  taranan dosya = %d" % dosya_sayisi)
print("  COZUMLENEN (canli) farkli hash = %d" % len(canli))
print("  COZUMLENMEYEN (olu) farkli hash = %d" % len(olu))

if canli:
    print("\n--- CANLI (dokunma) ---")
    for h in sorted(canli):
        print("  %s  (%d atif)" % (h, len(canli[h])))

if olu:
    print("\n--- OLU ATIFLAR (DUZELTILECEK) ---")
    for h in sorted(olu, key=lambda x: -len(olu[x])):
        print("\n  [%s]  %d atif" % (h, len(olu[h])))
        for yol, sat, bag in olu[h]:
            print("      %s:%d" % (yol, sat))
            print("        %s" % bag)
else:
    print("\n  -> OLU ATIF YOK.")

print("\n" + "=" * 70)
print("BEYAN EDILMIS SINIRLAR:")
print(" 1. YALNIZ kucuk-harfli 7-40 hex taranir; BUYUK harfli 8-hex (DURUM.md 9")
print("    dosya kimligi) ADAY DEGILDIR.")
print(" 2. KAPSAM = kanonik hafiza/karar belgeleri + GOREV_CLAUDE_CODE + docs.")
print("    KANIT/** TARANMADI (ham arac ciktisi; engineContentHash gibi 40-hex")
print("    dizgeler commit atfi DEGIL). Orada olu bir commit atfi varsa GORULMEDI.")
print(" 3. Proza atif ('oturum 59'un commit'i') GORULMEZ -- olculmedi.")
print(" 4. 7 haneden KISA atiflar (or. 'a47446') taranmaz -- git de cozmez.")
print("=" * 70)
print("HUKUM: %s" % ("KIRMIZI (olu atif var)" if olu else "YESIL"))
sys.exit(1 if olu else 0)

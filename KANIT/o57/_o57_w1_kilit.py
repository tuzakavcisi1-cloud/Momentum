# -*- coding: utf-8 -*-
"""GOREV-W1 v2 KILIT SATIRI (Onur kilitledi, 4 Agu 2026, oturum 57).

ORTAM.md ISIRDI (ilk kosum): kilit emojisi iki ayri \\u kacisi olarak yazildi,
BIRLESMEDI, yalniz vekil karakter oldu ve encode('utf-8') patladi
(UnicodeEncodeError: surrogates not allowed). K60 ise TUTTU -- encode YAZIMDAN
ONCE oldugu icin dosyaya tek bayt yazilmadi, spec 32801 b / 606F04F5 kaldi.
Cozum: emoji chr() ile kurulur, kacis yazilmaz.
"""
import hashlib
import io
import os
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
YOL = r"C:\dev\Momentum\GOREV_CLAUDE_CODE\GOREV-W1-web-yuruyen-iskelet.md"
KILIT = chr(0x1F512)

ESKI_BASLIK = "> **v1 kimliği `DFA8FF77` (19.941 b) GEÇERSİZDİR.**"
YENI_BASLIK = (
    ESKI_BASLIK + "\n"
    ">\n"
    "> " + KILIT + " **K137 — ONUR KİLİTLEDİ (4 Ağu 2026, oturum 57).** Kilit satırından\n"
    "> **ÖNCEKİ** kimlik `606F04F5` (32.801 b) **GEÇERSİZDİR**; kanonik kimlik `DURUM.md` §9'dadır.\n"
    "> Değişen her bayt kilidi bozar. Denetim çıktı yolları `## 0`'dadır (`K127` şartı ÖDENDİ)."
)

ESKI_9 = "Bu spec **HENÜZ KİLİTLİ DEĞİLDİR** — kilidi **Onur** verir. `K127` şartı **ÖDENDİ**: kilitten önce"
YENI_9 = "Bu spec **KİLİTLİDİR** (`K137`, Onur, 4 Ağu 2026). `K127` şartı **ÖDENDİ**: kilitten önce"

metin = io.open(YOL, encoding="utf-8", newline="").read()
onceki = len(metin.encode("utf-8"))

for eski in (ESKI_BASLIK, ESKI_9):
    if metin.count(eski) != 1:
        print("[KIRMIZI] tek esleme yok (%d): %s" % (metin.count(eski), eski[:50]))
        print("HICBIR YAZIM YAPILMADI.")
        sys.exit(2)

metin = metin.replace(ESKI_BASLIK, YENI_BASLIK, 1).replace(ESKI_9, YENI_9, 1)

ham = metin.encode("utf-8")
tmp = YOL + ".tmp"
with open(tmp, "wb") as f:
    f.write(ham)
    f.flush()
    os.fsync(f.fileno())
if hashlib.sha256(open(tmp, "rb").read()).hexdigest() != hashlib.sha256(ham).hexdigest():
    print("[KIRMIZI] .tmp sha tutmadi -- takas YAPILMADI")
    sys.exit(2)
yedek = YOL + ".yedek"
os.rename(YOL, yedek)
try:
    os.rename(tmp, YOL)
except Exception:
    os.rename(yedek, YOL)
    raise
os.remove(yedek)
print("KILIT SATIRI YAZILDI (atomik, uc adimli yedekli takas)")
print("  bayt: %d -> %d" % (onceki, os.path.getsize(YOL)))

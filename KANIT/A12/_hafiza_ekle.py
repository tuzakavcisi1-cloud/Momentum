# -*- coding: utf-8 -*-
"""PROJE_HAFIZA.md'ye checkpoint EKLER -- dizin blogunun BITISININ ALTINA.

K60: once encode (hata dosyaya DOKUNMADAN patlar), sonra .tmp, en son
UC ADIMLI YEDEKLI TAKAS (ORTAM.md: os.replace bu makinede WinError 5 verebilir).
Append-only guvencesi: yeni dosya ESKISINDEN KUCUK/ESIT ise DURUR.

OLCULDU (oturum 51): '<!-- DIZIN:SON -->' dizgesi dosyada 4 KEZ geciyor -- eski
checkpoint'ler kurali ALINTILAMIS. Bu yuzden 'teklik' sarti YANLIS bir sart;
dogru sart ILK gecisin gercekten dizin blogunun sonu OLDUGUNU kanitlamaktir:
  (1) '<!-- DIZIN:BAS' ondan ONCE gecmeli,
  (2) konum dosyanin ilk %10'unda olmali.
Metin ayri dosyadan okunur; bu betik icerik TASIMAZ.
"""
import hashlib
import os
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BU = os.path.dirname(os.path.abspath(__file__))
KOK = os.path.abspath(os.path.join(BU, "..", ".."))
HEDEF = os.path.join(KOK, "PROJE_HAFIZA.md")
METIN = os.path.join(BU, "_checkpoint-metni.md")
ISARET = "<!-- DIZIN:SON -->"

with open(HEDEF, "rb") as f:
    ham_hedef = f.read()
eski_sha = hashlib.sha256(ham_hedef).hexdigest()[:8].upper()
with open(METIN, "r", encoding="utf-8") as f:
    metin = f.read()

govde = ham_hedef.decode("utf-8")
ilk = govde.find(ISARET)
bas = govde.find("<!-- DIZIN:BAS")
if ilk < 0:
    print("DURDU: isaret hic gecmiyor.")
    raise SystemExit(2)
if not (0 <= bas < ilk):
    print("DURDU: 'DIZIN:BAS' ilk isaretten ONCE gecmiyor (bas=%d, ilk=%d)." % (bas, ilk))
    raise SystemExit(2)
if ilk > len(govde) * 0.10:
    print("DURDU: ilk isaret dosyanin ilk yuzde 10'unda degil (%d / %d)." % (ilk, len(govde)))
    raise SystemExit(2)
print("ISARET: ilk gecis %d. karakter (toplam %d) -- dizin blogu dogrulandi." % (ilk, len(govde)))

i = ilk + len(ISARET)
ham_yeni = (govde[:i] + "\n\n" + metin.strip() + "\n" + govde[i:]).encode("utf-8")
if len(ham_yeni) <= len(ham_hedef):
    print("DURDU: append-only ihlali -- dosya buyumedi.")
    raise SystemExit(3)

tmp = HEDEF + ".tmp"
yedek = HEDEF + ".yedek"
with open(tmp, "wb") as f:
    f.write(ham_yeni)
os.rename(HEDEF, yedek)
try:
    os.rename(tmp, HEDEF)
except Exception:
    os.rename(yedek, HEDEF)
    raise
with open(HEDEF, "rb") as f:
    yeni_sha = hashlib.sha256(f.read()).hexdigest()[:8].upper()
os.remove(yedek)
print("ESKI: %d b / %s" % (len(ham_hedef), eski_sha))
print("YENI: %d b / %s  (+%d b)" % (len(ham_yeni), yeni_sha, len(ham_yeni) - len(ham_hedef)))

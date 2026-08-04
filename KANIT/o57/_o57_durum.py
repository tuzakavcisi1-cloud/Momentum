# -*- coding: utf-8 -*-
"""DURUM.md: K137 kilidi (§4 tazeleme + §5 kilit satiri + §9 kimlik).
K60 atomik yazim. Emoji chr() ile (ORTAM.md). Tavan 32768 b -- pay 2439 b idi.
"""
import hashlib
import io
import os
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
YOL = r"C:\dev\Momentum\DURUM.md"
K = chr(0x1F512)
R = chr(0x1F534)
Y = chr(0x1F7E2)

ESKI4 = (R + " **ÖLÇÜLDÜ: ⑨ web\n"
         "borcunun HAZIR SPEC'İ YOK** — 25 spec'in **hiçbiri web değil** ⇒ o yol bir **spec turu** ister.\n"
         "→ **kriter 8 + `SS2` kabulü** → ⑨ web + **backend CI** (`D-A13-4`) + release → ⑩ `ADR 0004` + vitrin.")

YENI4 = (Y + " **⑨ WEB — `GOREV-W1` v2 KİLİTLİ (`K137`, oturum 57).** Web borcu **spec turu olarak\n"
         "DEĞİL**, `K53/5` gereği **yürüyen iskelet** olarak kuruldu; gerekçe `R8` **mutantıyla** ölçüldü.\n"
         "Ölçülen taban: `flutter build web` **EXIT 0** · Drift web **tam bağlı** · " + R + " **backend'de CORS\n"
         "YOK** (92 dosya). İş **Claude Code'da** (`T1`–`T7`); kabul kriterleri spec `## 7`'de.\n"
         "→ **backend CI** (`D-A13-4`) + release → ⑩ `ADR 0004` + vitrin.")

ESKI5 = "- **K44-a** — **Önce araç, sonra belge.**"
YENI5 = (
    "- " + K + " **K137 — `GOREV-W1` v2 KİLİTLENDİ (Onur, 4 Ağu 2026, oturum 57).** Kimlik **§9'da**.\n"
    "  `K127` şartı **ÖDENDİ**: iki bağımsız denetçi kilitten **ÖNCE** koştu, **6 bloker** buldu, altısı da\n"
    "  kapandı; çıktı yolları spec `## 0`'dadır. " + R + " **Yaşayan sınır: 18 mutantın ISIRDIĞI ÖLÇÜLMEDİ**\n"
    "  — `cors-kapisi.py` ve `_preflight.py` henüz **yok**; `spec-kapi-kapsama.py` kendi beyanıyla\n"
    "  *\"ısırmayı değil kapsamayı\"* ölçer. Gerekçe: hafıza `K137`.\n"
    + ESKI5)

ESKI9_SON = "Kapıları **`SS2/G31`–`SS2/G34`** (K108). " + R + " **Beyanlı-kilit sepetinde** — `tek-kopya-kapisi.py` kapsamına **eklenmedi** (sepet `BORCLAR.md`'de) |"
YENI9 = (ESKI9_SON + "\n"
         "| `GOREV-W1-web-yuruyen-iskelet.md` | **33.077** | **`5CF3F921`** | " + K + " **K137 kilidi "
         "(Onur kilitledi 4 Ağu 2026, oturum 57)** — kilit satırı **ÖNCESİ** `606F04F5` (32.801 b) ve "
         "**v1** `DFA8FF77` (19.941 b) **GEÇERSİZDİR**. U+FFFD 0 · CRLF 0. Kapıları **`W1/G35`–`W1/G38`**, "
         "mutantları `M189`–`M199` (K108). " + R + " **Beyanlı-kilit sepetinde** — `tek-kopya-kapisi.py` "
         "kapsamına **eklenmedi** |")

metin = io.open(YOL, encoding="utf-8", newline="").read()
onceki = len(metin.encode("utf-8"))
for eski in (ESKI4, ESKI5, ESKI9_SON):
    if metin.count(eski) != 1:
        print("[KIRMIZI] tek esleme yok (%d): %r" % (metin.count(eski), eski[:60]))
        print("HICBIR YAZIM YAPILMADI.")
        sys.exit(2)
metin = metin.replace(ESKI4, YENI4, 1).replace(ESKI5, YENI5, 1).replace(ESKI9_SON, YENI9, 1)

ham = metin.encode("utf-8")
if len(ham) > 32768:
    print("[KIRMIZI] TAVAN ASILIR: %d > 32768 -- YAZILMADI" % len(ham))
    sys.exit(2)
tmp = YOL + ".tmp"
with open(tmp, "wb") as f:
    f.write(ham)
    f.flush()
    os.fsync(f.fileno())
if hashlib.sha256(open(tmp, "rb").read()).hexdigest() != hashlib.sha256(ham).hexdigest():
    print("[KIRMIZI] .tmp sha tutmadi")
    sys.exit(2)
yedek = YOL + ".yedek"
os.rename(YOL, yedek)
try:
    os.rename(tmp, YOL)
except Exception:
    os.rename(yedek, YOL)
    raise
os.remove(yedek)
print("DURUM.md yazildi (atomik): %d -> %d bayt (pay %d)"
      % (onceki, os.path.getsize(YOL), 32768 - os.path.getsize(YOL)))

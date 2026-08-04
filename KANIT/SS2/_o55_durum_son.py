# -*- coding: utf-8 -*-
import sys, os, hashlib
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
YOL = r"C:\dev\Momentum\DURUM.md"
Y = []
Y.append(("SS2 satiri",
"""🟢 **⑧ `SS2` v3 KİLİTLENDİ (`K133`, oturum 55 · Onur kilitledi).** Tur 2'nin **beş blokeri de
kapatıldı**; **13 major borçlandı** (`S11`–`S14` + `B-SS2-4`). Üçüncü denetim turu `K53/1` gereği
**açılmadı**, gerekçe kanıtta yazılı (K127'nin *"yoksa açıkça yazar"* şıkkı). Dört mekanik kapı
YEŞİL. Hüküm **`KANIT/SS2/03-v3-KILIT.md`**. 🔴 **İş Claude Code'da: `T0` → `T1`.**""",
"""🟢 **⑧ `SS2` v3 KİLİTLENDİ (`K133`) ve `T0`–`T8` UYGULANDI (`K134`, oturum 55).** Beş bloker
kapandı, 13 major borçlandı (`S11`–`S14` + `B-SS2-4`); üçüncü denetim turu `K53/1` gereği
**açılmadı**. Claude Code `b900bae` ile **+5831/−69** yazdı. 🔴 **KABUL VERİLMEDİ:** Cowork'ün kendi
koşumuyla **kriter 1·2·3·5·6·7·9 geçti** (`analyze` 0 · `test` **522/522** · `verify.ps1` EXIT 0,
backend **120/120**, CVE 0 · altın küme **10/10**), **kriter 8 (uçtan uca) ÖLÇÜLMEDİ**.
Hükümler: `KANIT/SS2/03-v3-KILIT.md` + hafıza K134."""))
Y.append(("R8 satiri",
"""🔴 **`R8` AÇIK — oturum 55'te ÖLÇÜLDÜ ve ISIRDI** (53 ve 54 = **0** ürün kodu). Sönmesi
`SS2/T1`'in **ilk satırına** bağlıdır; `T0` araçtır, **saymaz**. 🔴 **ÖLÇÜLDÜ (oturum 55): ⑨ web
borcunun HAZIR SPEC'İ YOK** — `GOREV_CLAUDE_CODE/` altındaki 25 spec'in **hiçbiri web değil** ⇒ o
yol önce bir **spec turu** ister ve `R8` onu yasaklar; devir notunun *"kural açısından en temiz"*
beyanı böylece **çürüdü**. → ⑨ web + **backend CI** (`D-A13-4`) + release → ⑩ `ADR 0004` + vitrin.""",
"""🟢 **`R8` SÖNDÜ (oturum 55'te ÖLÇÜLDÜ):** `urun_kodu_satiri = 1773`, `radar.py . --olc-urun-kodu`
ile **git'ten türetildi**; radar artık *"ürün kodu durgunluğu"* bildirmiyor. 🔴 **ÖLÇÜLDÜ: ⑨ web
borcunun HAZIR SPEC'İ YOK** — 25 spec'in **hiçbiri web değil** ⇒ o yol bir **spec turu** ister.
→ **kriter 8 + `SS2` kabulü** → ⑨ web + **backend CI** (`D-A13-4`) + release → ⑩ `ADR 0004` + vitrin."""))
with open(YOL, "rb") as f: ham = f.read()
m = ham.decode("utf-8"); hata = 0
for ad, e, y in Y:
    if m.count(e) != 1: print("  [HATA]", ad, m.count(e)); hata += 1
    else: m = m.replace(e, y, 1); print("  [OK]  ", ad)
if hata: sys.exit(2)
yeni = m.encode("utf-8")
if b"\r\n" in yeni: print("CRLF"); sys.exit(3)
tmp, yd = YOL + ".tmp", YOL + ".yedek"
with open(tmp, "wb") as f: f.write(yeni)
if os.path.exists(yd): os.remove(yd)
os.rename(YOL, yd)
try: os.rename(tmp, YOL)
except Exception as ex:
    os.rename(yd, YOL); print("takas:", ex); sys.exit(4)
son = open(YOL, "rb").read()
if son != yeni:
    os.remove(YOL); os.rename(yd, YOL); print("sha"); sys.exit(5)
os.remove(yd)
print("DURUM.md: %d -> %d (%+d) · sha8 %s · pay %d b"
      % (len(ham), len(son), len(son)-len(ham), hashlib.sha256(son).hexdigest()[:8].upper(), 32768-len(son)))

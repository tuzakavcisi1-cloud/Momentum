# -*- coding: utf-8 -*-
"""Oturum 56 -- DEVIR-oturum-56.md'nin OLCUMLE YANLISLANMIS satirlarini tazeler.
Yalniz 'push' satiri degil: ayni turda bayatlayan HER satir duzeltilir (bayat-beyan
sinifi tek satirla sinirli degildir). Anchor'lar DOGRULANIR; tutmayan varsa DURUR."""
import hashlib, io, os, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
YOL = os.path.join(KOK, "KANIT", "o56", "DEVIR-oturum-56.md")

YAMALAR = [
    # (eski, yeni)
    ("**PROJE:** `C:\\dev\\Momentum` · main = **`1203833`** · 🔴 **PUSH ONUR'DA (7 commit ileri)**",
     "**PROJE:** `C:\\dev\\Momentum` · 🔴 **HEAD ve PUSH DURUMU BU BELGEYE YAZILMAZ — açılışta "
     "ÖLÇÜLÜR** (`K82-b`, `DURUM.md` §2 adım 7). Aşağıdaki satır bir **anlık ölçüm kaydıdır**, "
     "canlı durum değildir: oturum 56 kapanışında `SS2` kabulü `1203833`, devir notu `a051760`, "
     "ardından **push edildi** ve `fetch` sonrası **0 geri / 0 ileri** ölçüldü."),
    ("**Çalışma ağacı:** 5 bilinen `verify.ps1` artefaktı + 🔴 **iki APK (353 MB, untracked, "
     "`.gitignore` KAPSAMINDA DEĞİL)** · `index.lock` YOK",
     "**Çalışma ağacı:** yalnız 5 bilinen `verify.ps1` artefaktı · `index.lock` YOK. 🟢 İki APK "
     "(**353 MB**) oturum sonunda **`C:\\dev\\_momentum_apk\\`'ya TAŞINDI** — `.gitignore`'a "
     "**dokunulmadı** (bu projede `*.log` deseni 7 verify kaydını sessizce yutmuştu, `K111`)."),
    ("**Kapanış sağlığı:** **454.209 / 550k** 🟢",
     "**Kapanış sağlığı:** **465.688 / 550k** 🟢 (SARI eşiğine 84.312)"),
    ("""1. **PUSH** (7 commit) — Onur'da.
2. **`.gitignore` kararı:** `KANIT/o56/apk-*.apk` **353 MB**, untracked ama **ignore EDİLMİYOR**. Bir `git add -A` depoyu şişirir. 🔴 `*.log` satırı bu projede 7 verify kaydını **sessizce yutmuştu** (K111 borcu) ⇒ geniş desen YAZILMAMALI; dar desen + **kapı** gerekir.
3. **Ortam kapatma (K80 — Onur'un izniyle):** backend PID **10404**, emülatör `emulator-5554`, telefon `fba69c15`. Kapatma **ölçülür** (`netstat :5298` boş).
4. ⑨ **web borcu**""",
     """1. 🟢 **PUSH YAPILDI** (ölçüldü: `0 geri / 0 ileri`) · 🟢 **APK'lar repo dışına taşındı** ·
   🟢 **Ortam kapatıldı ve ÖLÇÜLDÜ**: `netstat :5298`'de **LISTENING satırı YOK**, `adb devices`'ta
   **emülatör YOK**, boş RAM **624 MiB → 1,54 GiB**. Docker **açık** bırakıldı (healthy).
2. ⑨ **web borcu**"""),
]


def atomik_yaz(yol, metin):
    ham = metin.encode("utf-8")
    tmp, yedek = yol + ".tmp", yol + ".yedek"
    with open(tmp, "wb") as f:
        f.write(ham)
    if os.path.exists(yedek):
        os.remove(yedek)
    os.rename(yol, yedek)
    try:
        os.rename(tmp, yol)
    except Exception:
        os.rename(yedek, yol)
        raise
    if hashlib.sha256(open(yol, "rb").read()).digest() != hashlib.sha256(ham).digest():
        os.remove(yol)
        os.rename(yedek, yol)
        raise SystemExit("[KIRMIZI] SHA TUTMADI -- yedek geri alindi.")
    os.remove(yedek)
    return len(ham)


metin = io.open(YOL, encoding="utf-8").read()
once = len(metin.encode("utf-8"))
for i, (eski, yeni) in enumerate(YAMALAR, 1):
    n = metin.count(eski)
    if n != 1:
        raise SystemExit("[KIRMIZI] YAMA %d ANCHOR TEK DEGIL (%d) -- HICBIR SEY YAZILMADI." % (i, n))
    metin = metin.replace(eski, yeni)
    print("  yama %d: TUTTU" % i)
sonra = atomik_yaz(YOL, metin)
print("DEVIR-oturum-56.md : %d b -> %d b (%+d)" % (once, sonra, sonra - once))

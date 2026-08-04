# -*- coding: utf-8 -*-
"""Oturum 56 -- B-SS2-5 kaydi BORCLAR.md'de 915 b yer kapladi ve pay 416 b'ye
dustu. Gerekce HAFIZAYA (K135-EK3), listede KISA kayit kalir. Once arsiv, sonra
kisaltma (K60 kardesi: yarim kalan is veri kaybidir)."""
import hashlib, io, os, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
BORC = os.path.join(KOK, "BORCLAR.md")
HAFIZA = os.path.join(KOK, "PROJE_HAFIZA.md")
ANCHOR = "- 🟡 **`B-SS2-5` — `M172`'NİN"

KISA = ("- 🟡 **`B-SS2-5` — `M172`'nin *beklenen* metni gerçeği tarif etmiyor [oturum 56'da ölçüldü, "
        "Onur borçlandırdı].** Kilitli spec (`K133`) satır 382 yalnız `G32/a` bekler; ölçülen gerçek "
        "**beş ayak** (`G32/a`·`e`·`e2`·`g`·`h`) — şart 4 çakışma kaydını **tamamen bastırıyor**. "
        "Sınıf **beyansız-sınır**; kilit **açılmadı** (çekirdek sözleşme ayakta: `M172` `G32/a`'yı "
        "**adıyla** düşürdü). Gerekçe + kapanış şartı: hafıza `K135-EK3`.")


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


borc = io.open(BORC, encoding="utf-8").read()
b_once = len(borc.encode("utf-8"))
satirlar = borc.split("\n")
idx = [i for i, s in enumerate(satirlar) if s.startswith(ANCHOR)]
if len(idx) != 1:
    raise SystemExit("[KIRMIZI] ANCHOR TEK DEGIL (%d)" % len(idx))
uzun = satirlar[idx[0]]
satirlar[idx[0]] = KISA

EK3 = ("\n\n### K135-EK3 — `B-SS2-5`'İN TAM GEREKÇESİ (oturum 56; `BORCLAR.md` tavanı yüzünden "
       "listede KISA tutuldu)\n\n**Onur'un kararı:** *borçlandır + beyan et* (spec AÇILMADI). "
       "Sunulan üç şıktan ikincisi (`K130` emsaliyle spec'i açıp yeniden kilitlemek) ölçülerek "
       "reddedildi: `M172` spec'in **çekirdek sözleşmesini** (satır 372: *her mutant hedeflediği "
       "ayağı adıyla düşürür*) **ihlal etmiyor** — `G32/a`'yı adıyla düşürdü. Kusur, kollateralin "
       "**beyan edilmemesi**; spec aynı tabloda `M183` ve `M187` için kollateralı yazıyor.\n\n"
       "**Listede duran kısa kayıt:**\n\n" + KISA + "\n\n**Kısaltılmadan önceki tam metin:**\n\n"
       + uzun + "\n")

hafiza = io.open(HAFIZA, encoding="utf-8").read()
h_once = len(hafiza.encode("utf-8"))
h_sonra = atomik_yaz(HAFIZA, hafiza + EK3)
print("PROJE_HAFIZA.md : %d b -> %d b (%+d)" % (h_once, h_sonra, h_sonra - h_once))
b_sonra = atomik_yaz(BORC, "\n".join(satirlar))
print("BORCLAR.md      : %d b -> %d b (%+d)  pay %d b" % (b_once, b_sonra, b_sonra - b_once,
                                                          32768 - b_sonra))

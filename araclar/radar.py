#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PROJE RADARI — kisir dongu / azalan verim dedektoru
====================================================
Bir projenin AYNI artefakt uzerinde donup donmedigini OLCER; hissetmez.

Girdi : <proje-kok>/PROJE_RADAR.jsonl   (append-only; satir basina bir JSON kaydi)
Cikti : Turkce teshis raporu + HUKUM (YESIL / SARI / KIRMIZI)
Cikis kodu: 0 = YESIL · 1 = SARI · 2 = KIRMIZI  (kapi olarak kullanilabilir)

KOR KAPI YOK: --altin-kume ile arac ONCE KENDINI kanitlar.
Kullanim:
    python radar.py <proje-kok> [--json] [--artefakt <ad>]
    python radar.py --altin-kume
"""
import json
import os
import sys
import argparse

SURUM = "0.2.0"

# ---------------------------------------------------------------- esikler
E = {
    "tur_esigi": 3,               # bu turdan sonra egim aranir
    "egim_orani": 0.80,           # son iki turun ortalamasi, onceki ikinin %80'inin ustundeyse "dusmuyor"
    "uretim_orani": 0.50,         # uretilen >= kapatilan * bu  => churn
    "r3_asgari_ornek": 4,         # [0.2.0] kapatilan bunun ALTINDAysa R3 HUKUM VERMEZ
    "odak_oturum": 3,             # gorunen cikti %0 iken tek artefakta bu kadar oturum = KIRMIZI
    "kalan_kusur_esigi": 5,       # capture-recapture tahmini bunun ustundeyse "kilitleme"
    "bayt_buyume_orani": 0.05,    # tur basina %5+ buyume = SARI sinyali
    "urun_kodu_durgunluk": 2,     # [0.2.0] ust uste bu kadar oturum 0 urun kodu = KIRMIZI (R8)
}

# Proje kokunde radar.config.json varsa esikler ORADAN gelir (her proje kendi ritmine
# gore kalibre eder). Ornek:
#   {"esikler": {"odak_oturum": 5, "urun_kodu_durgunluk": 3},
#    "urun_kodu_yollari": ["src/", "app/"],
#    "urun_kodu_haric": ["scripts/", "tools/", "docs/", "*.md"]}
VARSAYILAN_URUN_YOLLARI = ["src/", "lib/", "app/"]
VARSAYILAN_URUN_HARIC = ["test/", "tests/", "docs/", "scripts/", "tools/", "araclar/"]


def _config_yukle(kok):
    """radar.config.json varsa esikleri EZER ve ayarlari dondurur. Yoksa varsayilan."""
    cfg = {"urun_kodu_yollari": VARSAYILAN_URUN_YOLLARI,
           "urun_kodu_haric": VARSAYILAN_URUN_HARIC,
           "_kaynak": "varsayilan (radar.config.json yok)"}
    p = os.path.join(kok or ".", "radar.config.json")
    if not os.path.exists(p):
        return cfg
    try:
        d = json.load(open(p, encoding="utf-8"))
    except Exception as ex:
        raise SystemExit(f"[DUR] radar.config.json bozuk: {ex}")
    for k, v in (d.get("esikler") or {}).items():
        if k not in E:
            raise SystemExit(f"[DUR] radar.config.json'da BILINMEYEN esik: {k}")
        E[k] = v
    cfg.update({k: v for k, v in d.items() if k != "esikler"})
    cfg["_kaynak"] = p
    return cfg


def _oku(kok):
    p = os.path.join(kok, "PROJE_RADAR.jsonl")
    if not os.path.exists(p):
        return None, p
    kayitlar = []
    for i, satir in enumerate(open(p, encoding="utf-8"), 1):
        satir = satir.strip()
        if not satir or satir.startswith("#"):
            continue
        try:
            kayitlar.append(json.loads(satir))
        except json.JSONDecodeError as ex:
            raise SystemExit(f"[DUR] PROJE_RADAR.jsonl satir {i} bozuk JSON: {ex}")
    return kayitlar, p


def _artefaktlar(kayitlar):
    d = {}
    for k in kayitlar:
        d.setdefault(k.get("artefakt", "(adsiz)"), []).append(k)
    for a in d:
        d[a].sort(key=lambda k: (k.get("tur", 0), k.get("tarih", "")))
    return d


def _bloker(k):
    return int((k.get("bulgu") or {}).get("bloker", 0) or 0)


def _egim_dusmuyor(turlar):
    """Son iki turun bloker ortalamasi, onceki iki turun %80'inin ustundeyse egim DUSMUYOR."""
    b = [_bloker(k) for k in turlar]
    if len(b) < 4:
        return None
    son, once = sum(b[-2:]) / 2.0, sum(b[-4:-2]) / 2.0
    if once == 0:
        return False
    return son >= once * E["egim_orani"], son, once


def _capture_recapture(k):
    """Petersen-Lincoln: N ~ n1*n2/ortak. Iki BAGIMSIZ denetciden bulgu sayilari gerekir."""
    cr = k.get("capture_recapture")
    if not cr:
        return None
    n1, n2, ortak = cr.get("n1"), cr.get("n2"), cr.get("ortak")
    if not (n1 and n2) or not ortak:
        return None
    tahmin = (n1 * n2) / float(ortak)
    bulunan = n1 + n2 - ortak
    return {"n1": n1, "n2": n2, "ortak": ortak,
            "tahmin_toplam": round(tahmin, 1),
            "bulunan": bulunan,
            "kalan": round(max(0.0, tahmin - bulunan), 1)}


def teshis(kayitlar):
    """Her artefakt icin metrikleri hesaplar ve bulgu listesi uretir."""
    sonuc = []
    for ad, turlar in _artefaktlar(kayitlar).items():
        son = turlar[-1]
        bulgular = []          # (seviye, kod, mesaj)
        tur_sayisi = son.get("tur", len(turlar))
        oturum = len({k.get("oturum") for k in turlar if k.get("oturum") is not None})

        # --- 1. TEKRAR EDEN KUSUR SINIFI (en guclu sinyal)
        sayac = {}
        for k in turlar:
            for s in (k.get("siniflar") or []):
                sayac[s] = sayac.get(s, 0) + 1
        mekanik = set()
        for k in turlar:
            for s in (k.get("mekanik_kontrol_siniflari") or []):
                mekanik.add(s)
        tekrar = {s: n for s, n in sayac.items() if n >= 2}
        kapisiz = sorted(s for s in tekrar if s not in mekanik)
        if kapisiz:
            bulgular.append(("KIRMIZI", "R1",
                             "TEKRAR EDEN KUSUR SINIFI, MEKANIK KAPISI YOK: "
                             + " · ".join(f"{s} ({tekrar[s]} tur)" for s in kapisiz)
                             + " ⇒ 3. tur YASAK: once bu sinifi olcen mekanik kontrol yazilir."))
        kapili = sorted(s for s in tekrar if s in mekanik)
        if kapili:
            bulgular.append(("BILGI", "R1b",
                             "Tekrar eden ama MEKANIKLESMIS sinif(lar): " + " · ".join(kapili)
                             + " ⇒ bu sinif icin tur eklemek mesrudur."))

        # --- 2. BULGU EGIMI DUSMUYOR
        eg = _egim_dusmuyor(turlar)
        if tur_sayisi >= E["tur_esigi"] and isinstance(eg, tuple) and eg[0]:
            bulgular.append(("KIRMIZI", "R2",
                             f"BULGU EGIMI DUSMUYOR: son iki tur ort. {eg[1]:.1f} bloker, "
                             f"onceki iki tur ort. {eg[2]:.1f} ⇒ doygunluk YOK, tur eklemek yakinsamiyor."))

        # --- 3. CHURN: uretilen >= kapatilanin yarisi
        kap = int(son.get("kapatilan", 0) or 0)
        ure = int(son.get("uretilen", 0) or 0)
        if kap and ure >= kap * E["uretim_orani"]:
            if kap < E["r3_asgari_ornek"]:
                # [0.2.0] ORNEKLEM YETERSIZ: hukum VERILMEZ, ama SUSULMAZ da.
                bulgular.append(("BILGI", "R3-ORNEKLEM",
                                 f"CHURN OLCULEMEDI: son turda kapatilan={kap} "
                                 f"(asgari ornek {E['r3_asgari_ornek']}). uretilen={ure}. "
                                 "Bu orneklemde R3 hukum VERMEZ -- kusurunu olcup ayni turda "
                                 "kapatan DURUST bir el aksi halde cezalandirilirdi. "
                                 "OLCULMEDI demek, TEMIZ demek DEGILDIR."))
            else:
                bulgular.append(("KIRMIZI", "R3",
                                 f"YAZIM KENDI KUSURUNU URETIYOR: son turda {kap} kalem kapandi, "
                                 f"{ure} yeni kusur dogdu (esik: kapatilanin %{int(E['uretim_orani']*100)}'i)."))

        # --- 4. TESLIM DENGESI
        gc = son.get("gorunen_cikti_yuzde")
        if gc is not None and int(gc) == 0 and oturum >= E["odak_oturum"]:
            bulgular.append(("KIRMIZI", "R5",
                             f"TESLIM DENGESI BOZUK: bu artefakta {oturum} oturum harcandi ve projenin "
                             f"GORUNEN CIKTISI hala %0."))

        # --- 5. ARTEFAKT BUYUMESI
        b0 = int(turlar[0].get("bayt", 0) or 0)
        b1 = int(son.get("bayt", 0) or 0)
        if b0 and b1 > b0 and tur_sayisi > 1:
            oran = (b1 - b0) / float(b0) / max(1, tur_sayisi - 1)
            if oran >= E["bayt_buyume_orani"]:
                bulgular.append(("SARI", "R4",
                                 f"ARTEFAKT BUYUYOR: {b0} → {b1} bayt, tur basina ~%{oran*100:.1f} "
                                 "⇒ capraz-atif yuzeyi buyuyor, yeni kusur sinifi dogurur."))

        # --- 6. KOSULAMAYAN SPEC
        if son.get("downstream_kod_var") is False and tur_sayisi > 2:
            bulgular.append(("KIRMIZI", "R2b",
                             f"KOSULAMAYAN SPEC: bu artefakt {tur_sayisi} turdur denetleniyor ama "
                             "iddialarini kosacak KOD YOK ⇒ kagitta 2 turdan fazla test tasarimi "
                             "denetimi YASAK; kalan iddialar KODA devredilir."))

        # --- 7. BUTCE
        bt = son.get("butce") or {}
        if bt.get("oturum") and oturum > int(bt["oturum"]):
            bulgular.append(("KIRMIZI", "R6",
                             f"BUTCE ASILDI: planlanan {bt['oturum']} oturum, harcanan {oturum}."))

        # --- 8. SONLANMA OLCUTU SAYI-TABANLI MI
        if son.get("sonlanma_olcutu") in ("sayi", "bloker=0"):
            bulgular.append(("SARI", "R3b",
                             "SONLANMA OLCUTU SAYI-TABANLI ('bloker=0'). Yazim bloker urettigi surece "
                             "matematiksel olarak sonlanmaz ⇒ SINIF-tabanli olcute cevir."))

        # --- 9. CAPTURE-RECAPTURE
        cr = _capture_recapture(son)
        if cr and cr["kalan"] >= E["kalan_kusur_esigi"]:
            bulgular.append(("SARI", "CR",
                             f"KALAN KUSUR TAHMINI (Petersen-Lincoln): n1={cr['n1']} · n2={cr['n2']} · "
                             f"ortak={cr['ortak']} ⇒ toplam ~{cr['tahmin_toplam']}, bulunan {cr['bulunan']}, "
                             f"KALAN ~{cr['kalan']} ⇒ kilitlemeden once bu tahmini dusur "
                             "(bagimsizlik ihlal edilirse tahmin DUSUK cikar)."))

        seviye = "KIRMIZI" if any(b[0] == "KIRMIZI" for b in bulgular) else (
                 "SARI" if any(b[0] == "SARI" for b in bulgular) else "YESIL")
        sonuc.append({
            "artefakt": ad, "tur": tur_sayisi, "oturum": oturum,
            "bloker_egrisi": [_bloker(k) for k in turlar],
            "bayt": b1, "kapatilan": kap, "uretilen": ure,
            "tekrar_eden_kapisiz": kapisiz, "capture_recapture": cr,
            "seviye": seviye, "bulgular": bulgular,
        })
    return sonuc


ZORUNLU_ALANLAR = ("tarih", "oturum", "artefakt", "tur", "bulgu", "kapatilan", "uretilen")


def defter_denetle(kayitlar, kok):
    """[0.2.0] DEFTER DURUSTLUK KAPISI -- radarin EN ZAYIF halkasini kapatir.

    Radar GERCEGI degil DEFTERI olcer. Defter dolduran el kendi karnesini yaziyorsa,
    "iyi gidiyoruz" demek bedavadir. Bu kapi, defterin KENDI ICINDE ve DISARIDAKI
    gercekle CELISIP celismedigini arar. "Durust ol" demez; celiskiyi GOSTERIR.

    D1 bayt beyani diskteki gercekle uyusmuyor · D2 tur tekrari/atlamasi ·
    D3 zorunlu alan eksik · D4 beyan/olcum celiskisi · D5 hic kusur uretmemis defter
    """
    b = []
    if not kayitlar:
        return b
    for i, k in enumerate(kayitlar, 1):
        eksik = [a for a in ZORUNLU_ALANLAR if k.get(a) is None]
        if eksik:
            b.append(("SARI", "D3", f"kayit {i} ({k.get('artefakt','?')} tur {k.get('tur','?')}): "
                                    f"zorunlu alan EKSIK: {', '.join(eksik)}"))
        yol = k.get("artefakt") or ""
        beyan = k.get("bayt")
        if beyan and kok and ("/" in yol or "\\" in yol or "." in yol):
            tam = os.path.join(kok, yol.replace("/", os.sep))
            if os.path.isfile(tam):
                gercek = os.path.getsize(tam)
                # yalniz SON kayit icin anlamli: onceki turlarin bayti dogal olarak eskidir
                if k is kayitlar[-1] or all(x.get("artefakt") != yol for x in kayitlar[kayitlar.index(k) + 1:]):
                    if beyan != gercek:
                        b.append(("SARI", "D1",
                                  f"{yol}: defter {beyan} bayt diyor, DISKTE {gercek} bayt. "
                                  "Beyan bayatlamis ya da olculmeden yazilmis."))
    for ad in sorted({k.get("artefakt") for k in kayitlar if k.get("artefakt")}):
        turlar = [int(k.get("tur", 0) or 0) for k in kayitlar if k.get("artefakt") == ad]
        yinelenen = sorted({t for t in turlar if turlar.count(t) > 1})
        if yinelenen:
            b.append(("SARI", "D2", f"{ad}: ayni tur numarasi birden cok kayitta: {yinelenen} "
                                    "(duzeltme kaydiysa `asama` alanina 'olcum-duzeltme' yaz)."))
        bek = list(range(1, max(turlar) + 1)) if turlar else []
        eksik_tur = [t for t in bek if t not in turlar]
        if eksik_tur:
            b.append(("SARI", "D2", f"{ad}: tur ATLAMIS, eksik tur(lar): {eksik_tur}."))
    gc = [int(k.get("gorunen_cikti_yuzde") or 0) for k in kayitlar
          if k.get("gorunen_cikti_yuzde") is not None]
    uk = [int(k.get("urun_kodu_satiri") or 0) for k in kayitlar
          if k.get("urun_kodu_satiri") is not None]
    if gc and max(gc) > 0 and uk and max(uk) == 0:
        b.append(("KIRMIZI", "D4",
                  f"BEYAN/OLCUM CELISKISI: defter gorunen ciktiyi %{max(gc)} diyor ama OLCULEN "
                  "urun kodu her oturumda 0. Ikisinden biri yanlis; radar hangisi oldugunu "
                  "SOYLEYEMEZ -- duzeltmek defteri tutan elin isidir."))
    ureti = [int(k.get("uretilen") or 0) for k in kayitlar if k.get("uretilen") is not None]
    if len(ureti) >= 5 and max(ureti) == 0:
        b.append(("SARI", "D5",
                  f"BU DEFTER {len(ureti)} TURDUR HIC KUSUR URETMEDIGINI IDDIA EDIYOR. "
                  "`uretilen` bu defterin EN DEGERLI ve EN COK ATLANAN alanidir. Surekli 0 ise "
                  "ya olculmuyor ya yazilmiyor; her iki halde de R3 KORDUR."))
    return b


def proje_teshis(kayitlar):
    """[0.2.0] ARTEFAKTTAN BAGIMSIZ, PROJE GENELI kural.

    R8 -- URUN KODU DURGUNLUGU: son N OTURUMun hepsinde `urun_kodu_satiri` 0 ise KIRMIZI.
    Alan hic yoksa hukum VERILMEZ (OLCULMEDI; TEMIZ DEGIL).

    TANIM (kritik): `urun_kodu_satiri` = o oturum penceresinde projeye giren URUN kodu,
    HANGI EL yazarsa yazsin (insan, ajan, build aracı). ARAC/betik/belge SAYILMAZ.
    Yanlis tanim ("benim yazdigim kod") baska bir el insa ederken YANLIS-POZITIF verir.
    """
    bulgular = []
    oturumlar = {}
    for k in kayitlar:
        o = k.get("oturum")
        if o is None:
            continue
        v = k.get("urun_kodu_satiri")
        if v is None:
            continue
        oturumlar[o] = max(int(oturumlar.get(o, 0)), int(v))
    if not oturumlar:
        bulgular.append(("BILGI", "R8-OLCULMEDI",
                         "URUN KODU DURGUNLUGU OLCULEMEDI: hicbir kayitta `urun_kodu_satiri` "
                         "alani yok. Otomatik olcum: radar.py --olc-urun-kodu <kok> <git-ref>. "
                         "OLCULMEDI, TEMIZ DEGIL."))
        return bulgular
    son = sorted(oturumlar)[-E["urun_kodu_durgunluk"]:]
    if len(son) >= E["urun_kodu_durgunluk"] and all(oturumlar[o] == 0 for o in son):
        bulgular.append(("KIRMIZI", "R8",
                         f"URUN KODU DURGUNLUGU: son {len(son)} oturumda (oturum {son}) "
                         "tek satir URUN kodu projeye girmedi. SERT DURAK: bir sonraki oturum "
                         "URUN KODU ile baslar; yeni belge/ADR/spec/arac turu ACILMAZ. "
                         "Kalite disiplini, degerlendiricinin acacagi seyin var olmamasini telafi etmez."))
    return bulgular


def olc_urun_kodu(kok, ref, cfg):
    """[0.2.0] `urun_kodu_satiri`ni GIT'TEN turetir -- kendi karnesini kimse dolduramasin.

    git diff --numstat <ref>..HEAD  ile eklenen satirlar sayilir; yalniz urun yollari
    icindekiler, haric listesindekiler DUSULEREK.
    """
    import subprocess
    try:
        cikti = subprocess.run(
            ["git", "--no-optional-locks", "-C", kok, "diff", "--numstat", f"{ref}..HEAD"],
            capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=120)
    except Exception as ex:
        print(f"[DUR] git kosulamadi: {ex}")
        return 3
    if cikti.returncode != 0:
        print(f"[DUR] git hata verdi: {(cikti.stderr or '').strip()}")
        return 3
    yollar = cfg.get("urun_kodu_yollari") or VARSAYILAN_URUN_YOLLARI
    haric = cfg.get("urun_kodu_haric") or []
    toplam, sayilan, atlanan = 0, [], []
    for satir in cikti.stdout.splitlines():
        parca = satir.split("\t")
        if len(parca) != 3 or parca[0] == "-":
            continue
        eklenen, yol = int(parca[0]), parca[2].replace("\\", "/")
        if not any(yol.startswith(y.replace("\\", "/")) for y in yollar):
            continue
        if any(h.replace("\\", "/").strip("*") in yol for h in haric):
            atlanan.append(yol)
            continue
        toplam += eklenen
        sayilan.append((yol, eklenen))
    print("=" * 78)
    print(f"URUN KODU OLCUMU (git) — {ref}..HEAD")
    print(f"kok: {kok} · ayar kaynagi: {cfg.get('_kaynak')}")
    print(f"urun yollari: {yollar}")
    print(f"haric: {haric}")
    print("-" * 78)
    for yol, n in sorted(sayilan, key=lambda x: -x[1])[:20]:
        print(f"  +{n:<7} {yol}")
    if atlanan:
        print(f"  ({len(atlanan)} dosya HARIC listesi geregi sayilmadi)")
    print("-" * 78)
    print(f"urun_kodu_satiri = {toplam}")
    print("Bu sayiyi deftere OLDUGU GIBI yaz. Elle degistirirsen R8 korlesir.")
    print("=" * 78)
    return 0


def rapor(sonuc, kaynak, proje_bulgulari=()):
    K = {"KIRMIZI": "KIRMIZI", "SARI": "SARI", "YESIL": "YESIL"}
    print("=" * 78)
    print(f"PROJE RADARI v{SURUM} — kisir dongu teshisi")
    print(f"kaynak: {kaynak}")
    print("=" * 78)
    en_kotu = "YESIL"
    for s in sorted(sonuc, key=lambda x: {"KIRMIZI": 0, "SARI": 1, "YESIL": 2}[x["seviye"]]):
        print(f"\n[{K[s['seviye']]}] {s['artefakt']}")
        print(f"   tur {s['tur']} · oturum {s['oturum']} · bloker egrisi {s['bloker_egrisi']} "
              f"· bayt {s['bayt']} · son tur kapatilan {s['kapatilan']} / uretilen {s['uretilen']}")
        if not s["bulgular"]:
            print("   ✅ bulgu yok — ilerleme olculuyor.")
        for sev, kod, msg in s["bulgular"]:
            print(f"   [{sev}] {kod}: {msg}")
        if {"KIRMIZI": 0, "SARI": 1, "YESIL": 2}[s["seviye"]] < {"KIRMIZI": 0, "SARI": 1, "YESIL": 2}[en_kotu]:
            en_kotu = s["seviye"]
    if proje_bulgulari:
        print("\n[PROJE GENELI / DEFTER]")
        for sev, kod, msg in proje_bulgulari:
            print(f"   [{sev}] {kod}: {msg}")
            if sev == "KIRMIZI":
                en_kotu = "KIRMIZI"
            elif sev == "SARI" and en_kotu == "YESIL":
                en_kotu = "SARI"

    print("\n" + "=" * 78)
    print(f"HUKUM: {K[en_kotu]}")
    if en_kotu == "KIRMIZI":
        print("DEVRE KESICI: yeni tur YASAK. Kullaniciya dort sik sunulur.")
        print("[0.2.0 — SIKLAR ESIT AGIRLIKTA DEGILDIR; ISPAT YUKU TERSINE CEVRILDI]")
        print("  VARSAYILAN >> (1) DEVRET — kosulamayan iddialari KODA/BUILD'e tasi.")
        print("       Olculmus gerekce: kagitta dogrulanan bir kapi, dogrulandigini")
        print("       KANITLAYAMAZ; kagit turlarinin marjinal getirisi hizla duser.")
        print("  (2) MEKANIKLESTIR — tekrar eden sinifi olcen kontrolu yaz, sonra tur.")
        print("       >> SECEN EL YAZILI GEREKCE VERMEK ZORUNDADIR: 'bu sinif, kosan")
        print("       kod OLMADAN olculebilir' -- olculemiyorsa bu sik GECERSIZDIR.")
        print("  (3) DARALT — kilit olcutunu sinif-tabanli yap, kalani beyan+devir.")
        print("  (4) DURDUR — artefakti kilitle/park et, gorunen cikti isine gec.")
    elif en_kotu == "SARI":
        print("UYARI: eldeki maddeyi bitir, checkpoint yaz, YENI buyuk is acma.")
    print("=" * 78)
    return {"KIRMIZI": 2, "SARI": 1, "YESIL": 0}[en_kotu]


# ------------------------------------------------------------- altin kume
def _kayit(**kw):
    t = {"tarih": "2026-01-01", "oturum": kw.pop("oturum", 1), "artefakt": "A", "tur": 1,
         "bulgu": {"bloker": 0}, "siniflar": [], "bayt": 1000,
         "kapatilan": 0, "uretilen": 0, "gorunen_cikti_yuzde": 50,
         "downstream_kod_var": True}
    t.update(kw)
    return t


def altin_kume():
    """Arac once KENDINI kanitlar: temizde susar, kirlide isirir."""
    print("=" * 78)
    print("ALTIN KUME — RADARIN KENDI KANITI (kor kapi yok)")
    print("=" * 78)
    gecti = True

    def kontrol(ad, kayitlar, beklenen_seviye, beklenen_kodlar=()):
        nonlocal gecti
        s = teshis(kayitlar)
        sev = "KIRMIZI" if any(x["seviye"] == "KIRMIZI" for x in s) else (
              "SARI" if any(x["seviye"] == "SARI" for x in s) else "YESIL")
        kodlar = {k for x in s for _, k, _ in x["bulgular"]}
        ok = (sev == beklenen_seviye) and all(k in kodlar for k in beklenen_kodlar)
        print(f"\n[{'GECTI' if ok else 'BASARISIZ'}] {ad}")
        print(f"    beklenen: {beklenen_seviye} {list(beklenen_kodlar)} · olculen: {sev} {sorted(kodlar)}")
        if not ok:
            gecti = False

    # 1) TEMIZ: iki tur, bulgu dusuyor, churn yok, gorunen cikti var
    kontrol("1) TEMIZ PROJE — yanlis-pozitif kontrolu",
            [_kayit(tur=1, oturum=1, bulgu={"bloker": 10}, kapatilan=10, uretilen=0),
             _kayit(tur=2, oturum=2, bulgu={"bloker": 2}, kapatilan=8, uretilen=1)],
            "YESIL")

    # 2) KISIR DONGU: 4 tur, egim duz, tekrar eden kapisiz sinif, churn, gorunen cikti %0
    kisir = [_kayit(tur=i, oturum=i, bulgu={"bloker": 10 + (i % 2)},
                    siniflar=["beyansiz-sinir", "kor-kapi"], bayt=1000 + 200 * i,
                    kapatilan=10, uretilen=6, gorunen_cikti_yuzde=0,
                    downstream_kod_var=False) for i in range(1, 5)]
    kontrol("2) KISIR DONGU — dort kural birden isirmali",
            kisir, "KIRMIZI", ("R1", "R2", "R3", "R5"))

    # 3) MEKANIKLESMIS TEKRAR: ayni sinif tekrarliyor AMA kapisi var => R1 TETIKLENMEZ
    mek = [_kayit(tur=i, oturum=i, bulgu={"bloker": 6 - 2 * i},
                  siniflar=["kanonik-kopya"], mekanik_kontrol_siniflari=["kanonik-kopya"],
                  kapatilan=6, uretilen=0) for i in range(1, 3)]
    s3 = teshis(mek)
    kodlar3 = {k for x in s3 for _, k, _ in x["bulgular"]}
    ok3 = "R1" not in kodlar3
    print(f"\n[{'GECTI' if ok3 else 'BASARISIZ'}] 3) MEKANIKLESMIS TEKRAR — R1 TETIKLENMEMELI")
    print(f"    olculen kodlar: {sorted(kodlar3)}")
    gecti = gecti and ok3

    # 4) CAPTURE-RECAPTURE: n1=12 n2=9 ortak=4 => toplam 27, bulunan 17, kalan 10 => SARI/CR
    kontrol("4) KALAN KUSUR TAHMINI — CR isirmali",
            [_kayit(tur=1, oturum=1, bulgu={"bloker": 12}, kapatilan=12, uretilen=0,
                    capture_recapture={"n1": 12, "n2": 9, "ortak": 4})],
            "SARI", ("CR",))

    # 5) SAYI-TABANLI SONLANMA OLCUTU => SARI/R3b
    kontrol("5) SAYI-TABANLI SONLANMA OLCUTU — R3b isirmali",
            [_kayit(tur=1, oturum=1, sonlanma_olcutu="bloker=0", kapatilan=3, uretilen=0)],
            "SARI", ("R3b",))

    # 6) BUTCE ASIMI => KIRMIZI/R6
    kontrol("6) BUTCE ASIMI — R6 isirmali",
            [_kayit(tur=i, oturum=i, butce={"oturum": 2}, kapatilan=5, uretilen=0) for i in range(1, 5)],
            "KIRMIZI", ("R6",))

    # ---- [0.2.0] R3 ASGARI ORNEKLEM (K40: esik degistiren altin kumeye VAKA EKLER)
    kontrol("7) R3 ASGARI ORNEKLEM — kapatilan=1'de R3 TETIKLENMEMELI",
            [_kayit(tur=1, oturum=1, kapatilan=1, uretilen=1)],
            "YESIL", ("R3-ORNEKLEM",))
    kontrol("8) R3 ESIK USTUNDE — hala ISIRMALI (susturma kontrolu)",
            [_kayit(tur=1, oturum=1, kapatilan=4, uretilen=2)],
            "KIRMIZI", ("R3",))

    def kp(ad, kayitlar, bekle, olmamasi=(), kok=None, fn=None):
        nonlocal gecti
        b = (fn or proje_teshis)(kayitlar) if fn is not defter_denetle else defter_denetle(kayitlar, kok)
        kodlar = {k for _, k, _ in b}
        ok = all(k in kodlar for k in bekle) and not any(k in kodlar for k in olmamasi)
        print(f"\n[{'GECTI' if ok else 'BASARISIZ'}] {ad}")
        print(f"    beklenen: {list(bekle)} · olmamali: {list(olmamasi)} · olculen: {sorted(kodlar)}")
        if not ok:
            gecti = False

    # ---- [0.2.0] R8 URUN KODU DURGUNLUGU
    kp("9) R8 — iki oturum 0 urun kodu ISIRMALI",
       [_kayit(tur=1, oturum=1, urun_kodu_satiri=0), _kayit(tur=2, oturum=2, urun_kodu_satiri=0)],
       ("R8",))
    kp("10) R8 YANLIS-POZITIF — son oturumda kod yazildiysa SUSMALI",
       [_kayit(tur=1, oturum=1, urun_kodu_satiri=0), _kayit(tur=2, oturum=2, urun_kodu_satiri=120)],
       (), ("R8",))
    kp("11) R8 OLCULMEDI — alan yoksa hukum VERMEZ ama SUSMAZ",
       [_kayit(tur=1, oturum=1), _kayit(tur=2, oturum=2)], ("R8-OLCULMEDI",), ("R8",))

    # ---- [0.2.0] DEFTER DURUSTLUK KAPISI
    kp("12) DEFTER TEMIZ — yanlis-pozitif kontrolu",
       [_kayit(tur=1, oturum=1, artefakt="A", kapatilan=3, uretilen=1),
        _kayit(tur=2, oturum=2, artefakt="A", kapatilan=3, uretilen=1)],
       (), ("D1", "D2", "D3", "D4", "D5"), fn=defter_denetle)
    kp("13) D2 — TUR ATLAMASI isirmali",
       [_kayit(tur=1, oturum=1, artefakt="A"), _kayit(tur=3, oturum=2, artefakt="A")],
       ("D2",), (), fn=defter_denetle)
    kp("14) D3 — ZORUNLU ALAN EKSIK isirmali",
       [{"artefakt": "A", "tur": 1, "oturum": 1, "tarih": "2026-01-01"}],
       ("D3",), (), fn=defter_denetle)
    kp("15) D4 — BEYAN/OLCUM CELISKISI isirmali (gorunen cikti >0 ama olculen kod 0)",
       [_kayit(tur=1, oturum=1, gorunen_cikti_yuzde=60, urun_kodu_satiri=0),
        _kayit(tur=2, oturum=2, gorunen_cikti_yuzde=60, urun_kodu_satiri=0)],
       ("D4",), (), fn=defter_denetle)
    # D1 GERCEK DOSYA ISTER: gecici bir kok kurulur (deterministik, ag yok)
    import tempfile
    with tempfile.TemporaryDirectory() as td:
        os.makedirs(os.path.join(td, "docs"), exist_ok=True)
        hedef = os.path.join(td, "docs", "karar.md")
        open(hedef, "w", encoding="utf-8").write("x" * 500)
        kp("16) D1 — BAYT BEYANI DISKLE UYUSMUYORSA isirmali",
           [_kayit(tur=1, oturum=1, artefakt="docs/karar.md", bayt=999999)],
           ("D1",), (), kok=td, fn=defter_denetle)
        kp("17) D1 YANLIS-POZITIF — bayt DOGRUysa susmali",
           [_kayit(tur=1, oturum=1, artefakt="docs/karar.md", bayt=500)],
           (), ("D1",), kok=td, fn=defter_denetle)

    kp("18) D5 — 'hic kusur uretmedim' diyen defter isirmali",
       [_kayit(tur=i, oturum=i, artefakt="A", kapatilan=5, uretilen=0) for i in range(1, 6)],
       ("D5",), (), fn=defter_denetle)

    print("\n" + "=" * 78)
    print("HUKUM: " + ("RADAR KULLANILABILIR — temizde susuyor, kirlide isiriyor."
                       if gecti else "RADAR KULLANILAMAZ — altin kume BASARISIZ."))
    print("=" * 78)
    return 0 if gecti else 2


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    ap = argparse.ArgumentParser(description="Proje Radari — kisir dongu dedektoru")
    ap.add_argument("kok", nargs="?", help="proje kok dizini (PROJE_RADAR.jsonl burada aranir)")
    ap.add_argument("--altin-kume", action="store_true", help="aracin kendi kanitini kos")
    ap.add_argument("--olc-urun-kodu", metavar="GIT_REF",
                    help="urun_kodu_satiri'ni GIT'TEN turet (elle yazma): --olc-urun-kodu <ref>")
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--artefakt", help="yalniz bu artefakti raporla")
    a = ap.parse_args()

    if a.altin_kume:
        return altin_kume()
    if not a.kok:
        ap.print_help()
        return 2

    cfg = _config_yukle(a.kok)
    if a.olc_urun_kodu:
        return olc_urun_kodu(a.kok, a.olc_urun_kodu, cfg)

    kayitlar, yol = _oku(a.kok)
    if kayitlar is None:
        print(f"DEFTER YOK: {yol}")
        print("⇒ Bu proje HENUZ OLCULMUYOR. Radar defteri kurulmadan hukum verilemez.")
        print("   Kurulum: bos bir PROJE_RADAR.jsonl olustur ve her checkpoint'te bir satir ekle.")
        return 1
    if not kayitlar:
        print(f"DEFTER BOS: {yol} ⇒ ilk checkpoint satiri yazilmali.")
        return 1

    s = teshis(kayitlar)
    if a.artefakt:
        s = [x for x in s if x["artefakt"] == a.artefakt]
    if a.json:
        print(json.dumps({"surum": SURUM, "kaynak": yol, "sonuc": s}, ensure_ascii=False, indent=2,
                         default=str))
        return {"KIRMIZI": 2, "SARI": 1, "YESIL": 0}[
            "KIRMIZI" if any(x["seviye"] == "KIRMIZI" for x in s) else
            ("SARI" if any(x["seviye"] == "SARI" for x in s) else "YESIL")]
    return rapor(s, yol, list(defter_denetle(kayitlar, a.kok)) + list(proje_teshis(kayitlar)))


if __name__ == "__main__":
    sys.exit(main())

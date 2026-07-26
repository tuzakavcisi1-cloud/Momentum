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

SURUM = "0.1.0"

# ---------------------------------------------------------------- esikler
E = {
    "tur_esigi": 3,               # bu turdan sonra egim aranir
    "egim_orani": 0.80,           # son iki turun ortalamasi, onceki ikinin %80'inin ustundeyse "dusmuyor"
    "uretim_orani": 0.50,         # uretilen >= kapatilan * bu  => churn
    "odak_oturum": 3,             # gorunen cikti %0 iken tek artefakta bu kadar oturum = KIRMIZI
    "kalan_kusur_esigi": 5,       # capture-recapture tahmini bunun ustundeyse "kilitleme"
    "bayt_buyume_orani": 0.05,    # tur basina %5+ buyume = SARI sinyali
}


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


def rapor(sonuc, kaynak):
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
    print("\n" + "=" * 78)
    print(f"HUKUM: {K[en_kotu]}")
    if en_kotu == "KIRMIZI":
        print("DEVRE KESICI: yeni tur YASAK. Onur'a dort sik olculerek sunulur:")
        print("  (1) DARALT  — kilit olcutunu sinif-tabanli yap, kalani beyan+devir")
        print("  (2) DEVRET  — kosulamayan iddialari koda/build'e tasi")
        print("  (3) MEKANIKLESTIR — tekrar eden sinifi olcen kontrolu yaz, sonra tur")
        print("  (4) DURDUR  — artefakti oldugu gibi kilitle/park et, gorunen cikti isine gec")
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
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--artefakt", help="yalniz bu artefakti raporla")
    a = ap.parse_args()

    if a.altin_kume:
        return altin_kume()
    if not a.kok:
        ap.print_help()
        return 2

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
    return rapor(s, yol)


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""izolasyon-olc.py -- W3 capraz-koken izolasyon OLCUM araci.

NE OLCER
  Bir kokenin (origin) tarayici baglamini CAPRAZ-KOKEN IZOLE hale getirip getirmedigini olcer.
  Iki ayak, ikisi de ayri bir seyi kanitlar:

    H (HTTP ayagi, YALNIZ STDLIB)  -- yanit basliklarini olcer:
         Cross-Origin-Opener-Policy   == same-origin
         Cross-Origin-Embedder-Policy == require-corp   (credentialless KABUL EDILMEZ; beyan asagida)
    T (TARAYICI ayagi, playwright)  -- gercek bir sayfada `self.crossOriginIsolated` ve
         `typeof SharedArrayBuffer` degerini olcer.

  1.1.0 (oturum 63, K159) -- UC AYAK DAHA. Ilk ikisi URL olcer; bunlar DIZIN/KAYNAK olcer:

    B (BUILD ayagi)  -- Flutter web build ciktisinin CanvasKit'i AYNI KOKENDEN mi cektigini olcer.
    S (SERVIS ayagi) -- istemci kokunde bir API onekiyle AYNI ADI tasiyan dosya/dizin var mi
                        (varsa `UseStaticFiles` o uc noktayi GOLGELER).
    F (TAZELIK ayagi)-- kaynakta bulunan kok yollar `SpaDisiOnEkler` listesinde kapsanmis mi.

  NEDEN B AYAGI VAR (o63'te OLCULDU)
    `flutter build web` VARSAYILAN olarak CanvasKit'i https://www.gstatic.com/flutter-canvaskit
    adresinden ceker. `COEP: require-corp` altinda CORP tasimayan capraz-koken bir alt kaynak
    OLUR (o63'te pozitif+negatif kontrolle olculdu: CORP'suz betik BLOKLANDI, CORP'lu YUKLENDI).
    => `--no-web-resources-cdn` bir TERCIH DEGIL, KAPI SARTIDIR.

  🔴 B AYAGININ YANLIS-POZITIF TUZAGI (olculdu, bilerek kacinildi)
    `gstatic.com/flutter-canvaskit` dizgesi YEREL build'in bootstrap'inda DA gecer -- cunku o
    dizge bir UCLU ISLECIN OLU DALINDADIR:
        canvasKitBaseUrl ? canvasKitBaseUrl
                         : (engineRevision && !useLocalCanvasKit ? <gstatic> : "canvaskit")
    Dolayisiyla "gstatic geciyorsa ISIR" diyen bir ayak HER build'i kirmizi yakardi. Dogru olcu
    IKI KOSULDUR: `useLocalCanvasKit":true` VAR **ve** `canvasKitBaseUrl` capraz-kokene AYARLI DEGIL.

  🔴 ONEK LISTESI BU ARACA YAZILMAZ
    S ve F ayaklarinin onek listesi `Web/IstemciServisi.cs`'teki `SpaDisiOnEkler` dizisinden
    AYRISTIRILIR. Sabit liste yazmak `kanonik-kopya` olurdu (bu projede alti kez isirdi):
    urun kodu degisince kapi sessizce bayatlardi.

NEDEN IKI AYAK
  OLCULDU (oturum 60 denetimi, headless Chrome 151.0.7922.75):
    --enable-features=SharedArrayBuffer        -> crossOriginIsolated=false, SharedArrayBuffer=function
    --enable-blink-features=SharedArrayBuffer  -> crossOriginIsolated=false, SharedArrayBuffer=function
  Yani BAYRAK yalnizca YAPICIYI geri getirir, IZOLASYON VERMEZ. `typeof SharedArrayBuffer`e bakan bir
  kapi bu yuzden KORDUR. Isolation yalniz BASLIKTAN turer -> H ayagi mekanizmayi, T ayagi sonucu olcer.

BEYAN EDILMIS SINIRLAR
  1) T ayagi playwright ISTER. Onur'un makinesinde playwright YOK (oturum 60'ta olculdu: chrome
     PATH'te yok, playwright yok, selenium yok) => orada T ayagi [OLCULEMEDI] der. OLCULEMEDI
     TEMIZ DEGILDIR. H ayagi her yerde kosar (yalniz stdlib).
  2) Bu arac CORP (Cross-Origin-Resource-Policy) OLCMEZ. CORP kapsami olculmemis bir karardir.
  3) Bu arac `credentialless` COEP degerini KABUL ETMEZ. Gerekce: izolasyon verir ama alt kaynak
     davranisi require-corp'tan FARKLIDIR; ikisini ayni saymak beyansiz bir tercih olurdu.
  4) Bu arac SUNUCU KALDIRMAZ (K80). Adresi verilen kokeni olcer, o kadar.
  5) [1.1.0] B/S/F ayaklari YALNIZ `--istemci-kok` (ve F icin `--kaynak-kok`) verilirse kosar.
     Verilmezse ayak [OLCULEMEDI] der ve hukum "TAM YESIL DEGIL" olur -- T ayaginin deseni.
     OLCULEMEDI TEMIZ DEGILDIR.
  6) [1.1.0] S ayagi ad karsilastirmasini BUYUK/KUCUK HARF DUYARSIZ yapar: kanonik kok Windows'ta
     yasiyor ve NTFS duyarsizdir -- `V1` adli bir dizin orada `/v1`'i golgeler, Linux'ta golgelemez.
     Duyarsiz karsilastirma iki ortamin KATI olanini uygular (yanlis-pozitif riski BEYAN EDILMISTIR).
  7) [1.1.0] F ayagi kutuphane-eslemeli yollari GOREMEZ: `MapScalarApiReference()` ve `MapOpenApi()`
     kaynakta HICBIR yol literali tasimaz. Bu yuzden F yalnizca TEK YONLU isirir (kaynakta VAR,
     listede YOK); ters yon (listede var, kaynakta yok) BILGI'dir, KIRMIZI DEGIL.
"""
from __future__ import annotations

import argparse
import http.server
import json
import os
import re
import socket
import sys
import threading
import urllib.error
import urllib.request

try:                                     # ORTAM.md: bu makinede stdout cp1254
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:                        # pragma: no cover
    pass

SURUM = "1.1.0"

COOP_ADI = "Cross-Origin-Opener-Policy"
COEP_ADI = "Cross-Origin-Embedder-Policy"
COOP_BEKLENEN = "same-origin"
COEP_BEKLENEN = "require-corp"

CIKIS_YESIL = 0
CIKIS_BULGU = 1
CIKIS_ORTAM = 3

PROB_SAYFA = (
    b"<!doctype html><meta charset=utf-8><title>izolasyon-probu</title>"
    b"<body><pre id=s>olculuyor</pre><script>"
    b"document.getElementById('s').textContent="
    b"JSON.stringify([self.crossOriginIsolated, typeof SharedArrayBuffer]);"
    b"</script>"
)


# ---------------------------------------------------------------- H ayagi (stdlib)
def http_olc(url: str, zaman_asimi: float = 10.0) -> dict:
    """Yanit basliklarini olcer. Aga cikar; ORTAM HATASI'ni BULGU ile karistirmaz."""
    istek = urllib.request.Request(url, method="GET")
    try:
        with urllib.request.urlopen(istek, timeout=zaman_asimi) as y:
            durum, basliklar = y.status, dict(y.headers)
    except urllib.error.HTTPError as e:          # 4xx/5xx de OLCUMDUR: basliklar okunur
        durum, basliklar = e.code, dict(e.headers or {})
    except Exception as e:
        return {"ortam_hatasi": f"{type(e).__name__}: {e}", "url": url}

    def b(ad: str):                               # baslik ADI buyuk/kucuk harf duyarsizdir
        for k, v in basliklar.items():
            if k.lower() == ad.lower():
                return v.strip()
        return None

    coop, coep = b(COOP_ADI), b(COEP_ADI)
    bulgular = []
    if coop is None:
        bulgular.append(f"H1: {COOP_ADI} YOK")
    elif coop != COOP_BEKLENEN:                   # DEGER birebir karsilastirilir
        bulgular.append(f"H1: {COOP_ADI} = '{coop}', beklenen '{COOP_BEKLENEN}'")
    if coep is None:
        bulgular.append(f"H2: {COEP_ADI} YOK")
    elif coep != COEP_BEKLENEN:
        bulgular.append(f"H2: {COEP_ADI} = '{coep}', beklenen '{COEP_BEKLENEN}'"
                        + (" -- 'credentialless' BILEREK kabul edilmiyor (sinir 3)"
                           if coep == "credentialless" else ""))
    return {"url": url, "http": durum, "coop": coop, "coep": coep, "bulgular": bulgular}


# ---------------------------------------------------------------- T ayagi (playwright)
def tarayici_olc(url: str) -> dict:
    try:
        from playwright.sync_api import sync_playwright
    except Exception as e:
        return {"olculemedi": f"playwright yok ({type(e).__name__}) -- T ayagi OLCULEMEDI"}
    try:
        with sync_playwright() as p:
            tarayici = p.chromium.launch()
            try:
                sayfa = tarayici.new_page()
                sayfa.goto(url, wait_until="load")
                izole, sab = sayfa.evaluate(
                    "() => [self.crossOriginIsolated, typeof SharedArrayBuffer]")
            finally:
                tarayici.close()
    except Exception as e:
        return {"olculemedi": f"tarayici kosturulamadi: {type(e).__name__}: {e}"}
    bulgular = []
    if izole is not True:
        bulgular.append(f"T1: self.crossOriginIsolated = {izole!r} (True bekleniyordu)")
    if sab != "function":
        bulgular.append(f"T2: typeof SharedArrayBuffer = '{sab}' ('function' bekleniyordu)")
    return {"crossOriginIsolated": izole, "SharedArrayBuffer": sab, "bulgular": bulgular}


# ================================================================ 1.1.0 -- B / S / F ayaklari
# `//` ve `/* */` ATILIR ama DIZE LITERALLERININ ICI KORUNUR. Duz bir `//` siyirici
# `"https://..."` iceren satiri yarim keserdi; cors-kapisi.py bu sinifi zaten ogrendi.
def yorumlari_at(metin: str) -> str:
    cikti, i, n = [], 0, len(metin)
    while i < n:
        c = metin[i]
        if c == '"' and metin[i - 1: i] == "@":                 # @"...": kacis YOK, "" = tirnak
            cikti.append(" "); i += 1
            while i < n:
                if metin[i] == '"':
                    if metin[i + 1: i + 2] == '"':
                        i += 2; continue
                    i += 1; break
                i += 1
            continue
        if c == '"':
            cikti.append(" "); i += 1                            # dize GOVDESI korunur
            govde = []
            while i < n:
                if metin[i] == "\\":
                    govde.append(metin[i:i + 2]); i += 2; continue
                if metin[i] == '"':
                    i += 1; break
                govde.append(metin[i]); i += 1
            cikti.append('"' + "".join(govde) + '"')
            continue
        if c == "/" and metin[i + 1: i + 2] == "/":
            while i < n and metin[i] != "\n":
                i += 1
            continue
        if c == "/" and metin[i + 1: i + 2] == "*":
            son = metin.find("*/", i + 2)
            i = n if son == -1 else son + 2
            continue
        cikti.append(c); i += 1
    return "".join(cikti)


def spa_disi_onekler(cs_yolu: str) -> tuple[list[str] | None, str]:
    """`IstemciServisi.cs`'ten SpaDisiOnEkler dizisini AYRISTIRIR. (liste|None, aciklama)"""
    if not os.path.isfile(cs_yolu):
        return None, f"kaynak YOK: {cs_yolu}"
    try:
        ham = open(cs_yolu, "rb").read().decode("utf-8")
    except Exception as e:
        return None, f"okunamadi: {type(e).__name__}: {e}"
    temiz = yorumlari_at(ham)
    yer = temiz.find("SpaDisiOnEkler")
    if yer == -1:
        return None, "SpaDisiOnEkler bildirimi BULUNAMADI (yorum disi kodda yok)"
    esit = temiz.find("=", yer)
    if esit == -1:
        return None, "SpaDisiOnEkler gecti ama ATAMA yok (atif olabilir)"
    acik = None
    for j in range(esit, min(esit + 80, len(temiz))):
        if temiz[j] in "[{":
            acik = j
            break
    if acik is None:
        return None, "SpaDisiOnEkler atamasinda dizi acilisi ([ veya {) bulunamadi"
    kapali = "]" if temiz[acik] == "[" else "}"
    son = temiz.find(kapali, acik)
    if son == -1:
        return None, "dizi kapanisi bulunamadi"
    onekler = re.findall(r'"([^"]*)"', temiz[acik:son])
    if not onekler:
        return None, "dizi BOS -- bos liste bir OLCUM DEGILDIR"
    return [o.strip() for o in onekler], f"{len(onekler)} onek ayristirildi"


# ---------------------------------------------------------------- B ayagi (build ciktisi)
def build_olc(istemci_kok: str) -> dict:
    yol = os.path.join(istemci_kok, "flutter_bootstrap.js")
    if not os.path.isdir(istemci_kok):
        return {"ortam_hatasi": f"istemci kok dizini YOK: {istemci_kok}"}
    if not os.path.isfile(yol):
        return {"bulgular": ["B0: flutter_bootstrap.js YOK -- bu dizin bir Flutter web build "
                             "ciktisi degil; izolasyon iddiasi OLCULEMEZ"]}
    try:
        js = open(yol, "rb").read().decode("utf-8", errors="replace")
    except Exception as e:
        return {"ortam_hatasi": f"bootstrap okunamadi: {type(e).__name__}: {e}"}

    bulgular = []
    yerel = re.search(r'"useLocalCanvasKit"\s*:\s*true', js) is not None
    if not yerel:
        bulgular.append('B1: build yapilandirmasinda "useLocalCanvasKit":true YOK '
                        "=> CanvasKit gstatic'ten cekilir ve require-corp altinda BLOKLANIR. "
                        "`flutter build web --no-web-resources-cdn` ile derle.")
    # canvasKitBaseUrl UCLU ISLECTE `useLocalCanvasKit`ten ONCE okunur => bayrak yetmez.
    capraz = re.findall(r'canvasKitBaseUrl\s*[:=]\s*"(https?://[^"]+)"', js)
    for adres in capraz:
        bulgular.append(f"B2: canvasKitBaseUrl CAPRAZ-KOKENE ayarli ({adres}) -- bu deger "
                        "useLocalCanvasKit'i EZER (uclu islecte ilk okunan odur).")
    return {"useLocalCanvasKit": yerel, "canvasKitBaseUrl": capraz or None, "bulgular": bulgular}


# ---------------------------------------------------------------- S ayagi (golgeleme)
def servis_olc(istemci_kok: str, onekler: list[str]) -> dict:
    if not os.path.isdir(istemci_kok):
        return {"ortam_hatasi": f"istemci kok dizini YOK: {istemci_kok}"}
    try:
        girdiler = os.listdir(istemci_kok)
    except Exception as e:
        return {"ortam_hatasi": f"dizin okunamadi: {type(e).__name__}: {e}"}
    # sinir 6: NTFS duyarsizdir => KATI olan uygulanir
    kucuk = {g.lower(): g for g in girdiler}
    bulgular = []
    for onek in onekler:
        ad = onek.lstrip("/").split("/")[0]
        if not ad:
            continue
        varsa = kucuk.get(ad.lower())
        if varsa is not None:
            bulgular.append(f"S1: istemci kokunde '{varsa}' var ve '{onek}' onekiyle AYNI AD "
                            f"=> UseStaticFiles o uc noktayi GOLGELER (statik dosya uc noktadan "
                            f"ONCE kosar).")
    return {"olculen_onek": len(onekler), "girdi": len(girdiler), "bulgular": bulgular}


# ---------------------------------------------------------------- F ayagi (liste tazeligi)
# 🔴 BEYAN EDILMIS SINIR (sinir 7 + olculmus gerekce, o63):
#    YALNIZ MUTLAK kok ureten cagrilar okunur: MapGroup / MapHealthChecks / MapHub.
#    `MapGet`/`MapPost` OKUNMAZ, cunku bu depoda gruba GORELIDIRLER ("/tasks", "/sync") ve
#    arac grup yuvalanmasini cozemez -- okusaydi '/tasks kapsanmiyor' diye YANLIS-POZITIF verirdi.
#    Bu, "regex dilbilgisini tasimaz" dersinin bu aractaki halidir; olculdu, uydurulmadi.
MUTLAK_KOK_DESENI = re.compile(
    r'\b(?:MapGroup|MapHealthChecks|MapHub)\s*(?:<[^>]*>)?\s*\(\s*"(/[^"]*)"')


def _kok_oneki(sablon: str) -> str:
    """'/v{version:apiVersion}' -> '/v' · '/health/live' -> '/health'"""
    ilk = sablon.lstrip("/").split("/")[0]
    kesik = ilk.split("{")[0]
    return "/" + kesik


def tazelik_olc(kaynak_koku: str, onekler: list[str]) -> dict:
    if not os.path.isdir(kaynak_koku):
        return {"ortam_hatasi": f"kaynak kok dizini YOK: {kaynak_koku}"}
    bulunan: dict[str, list[str]] = {}
    for dizin, _, dosyalar in os.walk(kaynak_koku):
        if any(p in dizin.replace("\\", "/").split("/") for p in ("bin", "obj")):
            continue
        for d in dosyalar:
            if not d.endswith(".cs"):
                continue
            tam = os.path.join(dizin, d)
            try:
                temiz = yorumlari_at(open(tam, "rb").read().decode("utf-8", errors="replace"))
            except Exception:
                continue
            for sablon in MUTLAK_KOK_DESENI.findall(temiz):
                bulunan.setdefault(_kok_oneki(sablon), []).append(sablon)
    if not bulunan:
        return {"bulgular": ["F0: kaynakta HICBIR mutlak kok bulunamadi -- kapsam yanlis "
                             "ya da desen bayat. BOS OLCUM 'temiz' DEGILDIR."]}
    bulgular, bilgi = [], []
    kucuk_onek = [o.lower() for o in onekler]
    for kok, sablonlar in sorted(bulunan.items()):
        if not any(kok.lower().startswith(o) or o.startswith(kok.lower()) for o in kucuk_onek):
            bulgular.append(f"F1: kaynakta '{kok}' koku eslenmis ({sablonlar[0]}) ama "
                            f"SpaDisiOnEkler onu KAPSAMIYOR => o yol SPA kabuguna duser.")
    for onek in onekler:
        if not any(k.lower().startswith(onek.lower()) or onek.lower().startswith(k.lower())
                   for k in bulunan):
            bilgi.append(f"F2: '{onek}' oneki kaynakta MUTLAK literalle bulunamadi -- "
                         f"kutuphane eslemeli olabilir (MapOpenApi/MapScalarApiReference yol "
                         f"literali TASIMAZ) ya da OLU onek. Bu KIRMIZI DEGILDIR (sinir 7).")
    return {"bulunan_kok": sorted(bulunan), "bulgular": bulgular, "bilgi": bilgi}


# ---------------------------------------------------------------- rapor
def _cs_bul(kaynak_koku: str | None) -> str | None:
    if not kaynak_koku or not os.path.isdir(kaynak_koku):
        return None
    for dizin, _, dosyalar in os.walk(kaynak_koku):
        if "IstemciServisi.cs" in dosyalar:
            return os.path.join(dizin, "IstemciServisi.cs")
    return None


def dosya_ayaklari(istemci_kok: str | None, kaynak_kok: str | None) -> dict:
    """B/S/F. Girdi verilmeyen ayak [OLCULEMEDI] der -- ve OLCULEMEDI TEMIZ DEGILDIR."""
    d: dict = {}
    d["build_ayagi"] = (build_olc(istemci_kok) if istemci_kok
                        else {"olculemedi": "--istemci-kok verilmedi"})

    cs = _cs_bul(kaynak_kok)
    onekler, aciklama = (spa_disi_onekler(cs) if cs else (None, "--kaynak-kok verilmedi"))
    d["onekler"] = onekler
    d["onek_aciklamasi"] = aciklama
    d["onek_kaynagi"] = cs

    if onekler is None:
        gerekce = f"onek listesi ayristirilamadi ({aciklama})"
        d["servis_ayagi"] = {"olculemedi": gerekce}
        d["tazelik_ayagi"] = {"olculemedi": gerekce}
        return d
    d["servis_ayagi"] = (servis_olc(istemci_kok, onekler) if istemci_kok
                         else {"olculemedi": "--istemci-kok verilmedi"})
    d["tazelik_ayagi"] = tazelik_olc(kaynak_kok, onekler)
    return d


def olc(url: str | None, tarayici: bool = True,
        istemci_kok: str | None = None, kaynak_kok: str | None = None) -> tuple[int, dict]:
    sonuc: dict = {"surum": SURUM, "url": url}
    bulgu: list[str] = []
    ortam: list[str] = []

    if url:
        h = http_olc(url)
        sonuc["http_ayagi"] = h
        if "ortam_hatasi" in h:
            return CIKIS_ORTAM, sonuc
        sonuc["tarayici_ayagi"] = (tarayici_olc(url) if tarayici
                                   else {"olculemedi": "--http-only verildi"})
        t = sonuc["tarayici_ayagi"]
        bulgu += list(h["bulgular"]) + list(t.get("bulgular") or [])
        sonuc["tarayici_olculemedi"] = "olculemedi" in t
    else:
        sonuc["http_ayagi"] = {"olculemedi": "url verilmedi"}
        sonuc["tarayici_ayagi"] = {"olculemedi": "url verilmedi"}
        sonuc["tarayici_olculemedi"] = True

    d = dosya_ayaklari(istemci_kok, kaynak_kok)
    sonuc.update(d)
    for ad in ("build_ayagi", "servis_ayagi", "tazelik_ayagi"):
        a = sonuc[ad]
        if "ortam_hatasi" in a:
            ortam.append(f"{ad}: {a['ortam_hatasi']}")
        bulgu += list(a.get("bulgular") or [])

    sonuc["bulgular"] = bulgu
    sonuc["ortam_hatalari"] = ortam
    sonuc["olculemeyen"] = [ad for ad in ("http_ayagi", "tarayici_ayagi", "build_ayagi",
                                          "servis_ayagi", "tazelik_ayagi")
                            if "olculemedi" in sonuc.get(ad, {})]
    if ortam:
        return CIKIS_ORTAM, sonuc
    return (CIKIS_BULGU if bulgu else CIKIS_YESIL), sonuc


def yaz(kod: int, s: dict) -> None:
    print("=" * 78)
    print(f"IZOLASYON OLCUMU {SURUM} -- {s.get('url') or '(url yok -- yalniz dosya ayaklari)'}")
    print("=" * 78)
    h = s["http_ayagi"]
    if "ortam_hatasi" in h:
        print(f"  [ORTAM HATASI] {h['ortam_hatasi']}")
        print("  >> Bu bir BULGU DEGILDIR: adres olculemedi. 'temiz' DENMEZ.")
        print("=" * 78)
        print("HUKUM: OLCULEMEDI")
        return
    if "olculemedi" in h:
        print(f"  [OLCULEMEDI] H: {h['olculemedi']}")
    else:
        print(f"  [OLCUM] H: HTTP {h['http']} · {COOP_ADI}: {h['coop']!r} · "
              f"{COEP_ADI}: {h['coep']!r}")
    t = s.get("tarayici_ayagi") or {}
    if "olculemedi" in t:
        print(f"  [OLCULEMEDI] T: {t['olculemedi']}")
        print("               >> OLCULEMEDI YESIL DEGILDIR.")
    else:
        print(f"  [OLCUM] T: crossOriginIsolated={t['crossOriginIsolated']!r} · "
              f"typeof SharedArrayBuffer='{t['SharedArrayBuffer']}'")

    b_ = s.get("build_ayagi") or {}
    if "olculemedi" in b_:
        print(f"  [OLCULEMEDI] B: {b_['olculemedi']}")
    elif "ortam_hatasi" in b_:
        print(f"  [ORTAM HATASI] B: {b_['ortam_hatasi']}")
    else:
        print(f"  [OLCUM] B: useLocalCanvasKit={b_.get('useLocalCanvasKit')!r} · "
              f"canvasKitBaseUrl={b_.get('canvasKitBaseUrl')!r}")
    if s.get("onekler") is not None:
        print(f"  [OLCUM] onek listesi: {s['onekler']}  ({s['onek_aciklamasi']})")
        print(f"          kaynak: {s.get('onek_kaynagi')}  -- ARACA YAZILMADI, AYRISTIRILDI")
    else:
        print(f"  [OLCULEMEDI] onek listesi: {s.get('onek_aciklamasi')}")
    for ad, harf in (("servis_ayagi", "S"), ("tazelik_ayagi", "F")):
        a = s.get(ad) or {}
        if "olculemedi" in a:
            print(f"  [OLCULEMEDI] {harf}: {a['olculemedi']}")
        elif "ortam_hatasi" in a:
            print(f"  [ORTAM HATASI] {harf}: {a['ortam_hatasi']}")
        elif harf == "S":
            print(f"  [OLCUM] S: {a.get('olculen_onek')} onek x {a.get('girdi')} kok girdisi tarandi")
        else:
            print(f"  [OLCUM] F: kaynakta bulunan MUTLAK kokler: {a.get('bulunan_kok')}")
            for i in a.get("bilgi") or []:
                print(f"  [BILGI] {i}")

    for b in s["bulgular"]:
        print(f"  [KIRMIZI] {b}")
    print("-" * 78)
    if s.get("ortam_hatalari"):
        for o in s["ortam_hatalari"]:
            print(f"  [ORTAM HATASI] {o}")
        print("HUKUM: OLCULEMEDI")
    elif s["bulgular"]:
        print("HUKUM: IZOLE DEGIL")
    elif s.get("olculemeyen"):
        print(f"HUKUM: OLCULEN AYAKLAR YESIL -- ama {', '.join(s['olculemeyen'])} OLCULEMEDI "
              f"=> TAM YESIL DEGIL")
    else:
        print("HUKUM: CAPRAZ-KOKEN IZOLE (BES AYAK DA OLCULDU)")
    print("=" * 78)


# ---------------------------------------------------------------- altin kume
class _Sunucu(http.server.BaseHTTPRequestHandler):
    basliklar: dict = {}

    def do_GET(self):                                    # noqa: N802
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        for k, v in self.basliklar.items():
            self.send_header(k, v)
        self.send_header("Content-Length", str(len(PROB_SAYFA)))
        self.end_headers()
        self.wfile.write(PROB_SAYFA)

    def log_message(self, *a):                           # sessiz
        return


def _sunucu_ac(basliklar: dict):
    tip = type("_S", (_Sunucu,), {"basliklar": basliklar})
    s = http.server.ThreadingHTTPServer(("127.0.0.1", 0), tip)
    threading.Thread(target=s.serve_forever, daemon=True).start()
    return s, f"http://127.0.0.1:{s.server_address[1]}/"


def _yaz(yol: str, icerik: str) -> None:
    os.makedirs(os.path.dirname(yol), exist_ok=True)
    with open(yol, "wb") as f:
        f.write(icerik.encode("utf-8"))


_CS_KALIBI = '''namespace Momentum.Api.Web;
public static class IstemciServisi
{{
    public const string KokDizinAnahtari = "Istemci:KokDizin";
    // SAHTE BILDIRIM -- SpaDisiOnEkler = ["/SAHTE"];  yorum icinde, ALDANMAMALI
    /* blok yorumda da: SpaDisiOnEkler = ["/BLOK"]; */
    public static readonly string[] SpaDisiOnEkler = [{onekler}];
    // dize icinde // gecen bir satir: yorum siyiricinin testi
    public const string Belge = "https://ornek.test/yol";
}}
'''

_BOOTSTRAP_YEREL = ('(()=>{var w={"useLocalCanvasKit":true,"engineRevision":"abc"};'
                    'function E(i,e){return i.canvasKitBaseUrl?i.canvasKitBaseUrl:'
                    '(e.engineRevision&&!e.useLocalCanvasKit?'
                    'I("https://www.gstatic.com/flutter-canvaskit",e.engineRevision):"canvaskit")}})();')
_BOOTSTRAP_CDN = _BOOTSTRAP_YEREL.replace('"useLocalCanvasKit":true,', "")
_BOOTSTRAP_EZEN = _BOOTSTRAP_YEREL.replace(
    '"engineRevision":"abc"', '"engineRevision":"abc",canvasKitBaseUrl:"https://cdn.ornek/ck"')


def _dosya_vakalari() -> tuple[int, int]:
    """B / S / F ve AYRISTIRICI vakalari. Hepsi gecici dizinde, AG ISTEMEZ."""
    import shutil
    import tempfile

    gecen = toplam = 0

    def bildir(ad: str, ok: bool, olculen) -> None:
        nonlocal gecen, toplam
        toplam += 1
        gecen += bool(ok)
        print(f"[{'GECTI' if ok else 'DUSTU'}] {ad}  (olculen: {olculen})")

    kok = tempfile.mkdtemp(prefix="izolasyon-altin-")
    try:
        # ---------------- B ayagi
        b1 = os.path.join(kok, "b-yerel")
        _yaz(os.path.join(b1, "flutter_bootstrap.js"), _BOOTSTRAP_YEREL)
        r = build_olc(b1)
        bildir("12) B: useLocalCanvasKit=true VE gstatic dizgesi de geciyor -- SUSMALI "
               "(gstatic OLU DALDADIR; 'gstatic gecerse isir' diyen kapi HER build'i kirar)",
               len(r["bulgular"]) == 0, r["bulgular"])

        b2 = os.path.join(kok, "b-cdn")
        _yaz(os.path.join(b2, "flutter_bootstrap.js"), _BOOTSTRAP_CDN)
        r = build_olc(b2)
        bildir("13) B: useLocalCanvasKit YOK (varsayilan build) -- ISIRMALI",
               any(x.startswith("B1") for x in r["bulgular"]), r["bulgular"])

        b3 = os.path.join(kok, "b-ezen")
        _yaz(os.path.join(b3, "flutter_bootstrap.js"), _BOOTSTRAP_EZEN)
        r = build_olc(b3)
        bildir("14) B: bayrak VAR ama canvasKitBaseUrl capraz-kokene ayarli -- ISIRMALI "
               "(uclu islecte baseUrl ONCE okunur, bayragi EZER)",
               any(x.startswith("B2") for x in r["bulgular"]), r["bulgular"])

        b4 = os.path.join(kok, "b-bos")
        os.makedirs(b4, exist_ok=True)
        r = build_olc(b4)
        bildir("15) B: flutter_bootstrap.js YOK -- ISIRMALI (build ciktisi degil)",
               any(x.startswith("B0") for x in r["bulgular"]), r["bulgular"])

        # ---------------- AYRISTIRICI
        cs_dizin = os.path.join(kok, "kaynak", "Web")
        cs = os.path.join(cs_dizin, "IstemciServisi.cs")
        _yaz(cs, _CS_KALIBI.format(onekler='"/v1", "/health", "/hubs", "/scalar", "/openapi"'))
        onekler, aciklama = spa_disi_onekler(cs)
        bildir("16) AYRISTIRICI: yorumdaki SAHTE bildirime ALDANMAMALI, GERCEK listeyi okumali",
               onekler == ["/v1", "/health", "/hubs", "/scalar", "/openapi"], onekler)

        onekler_yok, aciklama_yok = spa_disi_onekler(os.path.join(kok, "yok.cs"))
        bildir("17) AYRISTIRICI: dosya YOK -- None demeli (OLCULEMEDI), BOS LISTE dondurmemeli",
               onekler_yok is None, f"{onekler_yok!r} / {aciklama_yok}")

        temiz = yorumlari_at('var a = "https://ornek.test/yol"; // gercek yorum\nvar b = 1;')
        bildir("18) YORUM SIYIRICI: dize icindeki // KESMEMELI, gercek yorumu ATMALI",
               ("https://ornek.test/yol" in temiz) and ("gercek yorum" not in temiz)
               and ("var b = 1;" in temiz), repr(temiz[:70]))

        # ---------------- S ayagi
        s1 = os.path.join(kok, "s-temiz")
        _yaz(os.path.join(s1, "index.html"), "<html>")
        _yaz(os.path.join(s1, "main.dart.js"), "//")
        r = servis_olc(s1, onekler)
        bildir("19) S: temiz istemci koku -- SUSMALI", len(r["bulgular"]) == 0, r["bulgular"])

        s2 = os.path.join(kok, "s-golge")
        _yaz(os.path.join(s2, "index.html"), "<html>")
        _yaz(os.path.join(s2, "health"), "golge")
        r = servis_olc(s2, onekler)
        bildir("20) S: kokte 'health' ADINDA dosya -- ISIRMALI (/health golgelenir)",
               any(x.startswith("S1") for x in r["bulgular"]), r["bulgular"])

        s3 = os.path.join(kok, "s-buyuk")
        _yaz(os.path.join(s3, "index.html"), "<html>")
        os.makedirs(os.path.join(s3, "V1"), exist_ok=True)
        r = servis_olc(s3, onekler)
        bildir("21) S: kokte BUYUK HARFLI 'V1' dizini -- ISIRMALI (NTFS duyarsiz, sinir 6)",
               any(x.startswith("S1") for x in r["bulgular"]), r["bulgular"])

        # ---------------- F ayagi
        f_kok = os.path.join(kok, "kaynak")
        _yaz(os.path.join(f_kok, "Endpoints", "Uc.cs"),
             'class U { static void M(object app){ app.MapGroup("/v{version:apiVersion}");'
             ' app.MapHealthChecks("/health/live"); app.MapHub<H>("/hubs/sync");'
             ' g.MapGet("/tasks"); g.MapPost("/sync"); } }')
        r = tazelik_olc(f_kok, onekler)
        bildir("22) F: gruba GORELI MapGet('/tasks') ve MapPost('/sync') -- ISIRMAMALI "
               "(mutlak sanilirsa YANLIS-POZITIF; sinir 7)",
               not any(x.startswith("F1") for x in r["bulgular"]), r["bulgular"])

        _yaz(os.path.join(f_kok, "Endpoints", "Yeni.cs"),
             'class Y { static void M(object app){ app.MapHealthChecks("/metrics/canli"); } }')
        r = tazelik_olc(f_kok, onekler)
        bildir("23) F: kaynaga YENI '/metrics' koku girdi, listede YOK -- ISIRMALI",
               any(x.startswith("F1") and "/metrics" in x for x in r["bulgular"]), r["bulgular"])
        os.remove(os.path.join(f_kok, "Endpoints", "Yeni.cs"))

        r = tazelik_olc(f_kok, onekler)
        bildir("24) F: listede olup kaynakta MUTLAK literali olmayan onek ('/scalar','/openapi') "
               "-- KIRMIZI DEGIL, BILGI olmali (kutuphane eslemeli; sinir 7)",
               (not r["bulgular"]) and any("/scalar" in i for i in r.get("bilgi") or []),
               {"kirmizi": r["bulgular"], "bilgi": len(r.get("bilgi") or [])})

        f_bos = os.path.join(kok, "f-bos")
        _yaz(os.path.join(f_bos, "Bos.cs"), "class B { }")
        r = tazelik_olc(f_bos, onekler)
        bildir("25) F: kaynakta HIC mutlak kok yok -- ISIRMALI (BOS OLCUM 'temiz' DEGILDIR)",
               any(x.startswith("F0") for x in r["bulgular"]), r["bulgular"])
    finally:
        shutil.rmtree(kok, ignore_errors=True)
    return gecen, toplam


def altin_kume() -> int:
    try:
        import playwright.sync_api  # noqa: F401
        tarayici_var = True
    except Exception:
        tarayici_var = False

    TAM = {COOP_ADI: COOP_BEKLENEN, COEP_ADI: COEP_BEKLENEN}
    vakalar = [
        ("1) TAM baslik seti -- H SUSMALI", TAM, {"h": 0}),
        ("2) HIC baslik yok -- H ISIRMALI (iki ayak)", {}, {"h": 2}),
        ("3) YALNIZ COOP -- H ISIRMALI (COEP eksik)", {COOP_ADI: COOP_BEKLENEN}, {"h": 1}),
        ("4) YALNIZ COEP -- H ISIRMALI (COOP eksik)", {COEP_ADI: COEP_BEKLENEN}, {"h": 1}),
        ("5) COEP=unsafe-none -- H ISIRMALI (deger birebir)",
         {COOP_ADI: COOP_BEKLENEN, COEP_ADI: "unsafe-none"}, {"h": 1}),
        ("6) COEP=credentialless -- H ISIRMALI (sinir 3: BILEREK)",
         {COOP_ADI: COOP_BEKLENEN, COEP_ADI: "credentialless"}, {"h": 1}),
        ("7) COOP=same-origin-allow-popups -- H ISIRMALI",
         {COOP_ADI: "same-origin-allow-popups", COEP_ADI: COEP_BEKLENEN}, {"h": 1}),
        ("8) baslik ADI kucuk harfle -- H SUSMALI (ad duyarsiz, deger degil)",
         {COOP_ADI.lower(): COOP_BEKLENEN, COEP_ADI.lower(): COEP_BEKLENEN}, {"h": 0}),
    ]

    gecen = toplam = 0
    t_kanitlanmadi = False
    for ad, basliklar, beklenen in vakalar:
        toplam += 1
        s, url = _sunucu_ac(basliklar)
        try:
            h = http_olc(url)
            olculen = len(h.get("bulgular") or [])
        finally:
            s.shutdown()
        ok = olculen == beklenen["h"]
        gecen += ok
        print(f"[{'GECTI' if ok else 'DUSTU'}] {ad}  (H bulgu: beklenen {beklenen['h']}, olculen {olculen})")

    # --- T ayagi: yalniz playwright varsa OLCULUR; yoksa vaka OLCULEMEDI der, GECTI DEMEZ
    for ad, basliklar, bekle_izole in [
        ("9) TAM baslik + TARAYICI -- crossOriginIsolated TRUE olmali", TAM, True),
        ("10) baslik YOK + TARAYICI -- crossOriginIsolated FALSE olmali", {}, False),
    ]:
        if not tarayici_var:
            t_kanitlanmadi = True
            print(f"[KAPSAM DISI] {ad}  -- playwright YOK, vaka KOSULAMADI. "
                  f"Bu vaka N/M'ye SAYILMAZ; T ayagi KANITLANMAMIS sayilir.")
            continue
        toplam += 1
        s, url = _sunucu_ac(basliklar)
        try:
            t = tarayici_olc(url)
        finally:
            s.shutdown()
        ok = ("olculemedi" not in t) and (t.get("crossOriginIsolated") is bekle_izole)
        gecen += ok
        print(f"[{'GECTI' if ok else 'DUSTU'}] {ad}  (olculen: {t.get('crossOriginIsolated', t)})")

    # --- 1.1.0: B / S / F ve AYRISTIRICI vakalari (dosya sistemi, ag ISTEMEZ)
    g2, t2 = _dosya_vakalari()
    gecen += g2
    toplam += t2

    # --- ORTAM HATASI bulgu ile karistirilmamali
    toplam += 1
    with socket.socket() as sk:                      # kapali bir port bul
        sk.bind(("127.0.0.1", 0))
        kapali = sk.getsockname()[1]
    h = http_olc(f"http://127.0.0.1:{kapali}/", zaman_asimi=2.0)
    ok = "ortam_hatasi" in h
    gecen += ok
    print(f"[{'GECTI' if ok else 'DUSTU'}] 11) ULASILAMAYAN adres -- ORTAM HATASI demeli, "
          f"'izole degil' DEMEMELI  (olculen: {'ORTAM HATASI' if ok else h})")

    print("-" * 78)
    print(f"{gecen}/{toplam} vaka gecti.")
    if t_kanitlanmadi:
        print("BEYAN: T ayaginin IKI vakasi KOSULAMADI (playwright yok) ve N/M'ye SAYILMADI.")
        print("       Bu ortamda arac YALNIZ H ayagi icin kendini kanitlamistir; T ayagi")
        print("       kosum aninda zaten [OLCULEMEDI] der -- ve OLCULEMEDI YESIL DEGILDIR.")
    if gecen == toplam:
        print("HUKUM: ARAC KULLANILABILIR -- temizde susuyor, kirlide isiriyor.")
        print("=" * 78)
        return 0
    print("HUKUM: ARAC KULLANILAMAZ -- once kendini kanitlasin.")
    print("=" * 78)
    return CIKIS_BULGU


def main() -> int:
    ap = argparse.ArgumentParser(description="W3 capraz-koken izolasyon olcumu")
    ap.add_argument("url", nargs="?", help="olculecek adres, or. http://127.0.0.1:5298/health/live")
    ap.add_argument("--altin-kume", action="store_true", help="aracin kendi kanitini kos")
    ap.add_argument("--http-only", action="store_true", help="yalniz H ayagi (tarayici kosulmaz)")
    ap.add_argument("--istemci-kok", help="Flutter web build ciktisi (B ve S ayaklari)")
    ap.add_argument("--kaynak-kok", help="Momentum.Api kaynak dizini (onek listesi + F ayagi)")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()

    if a.altin_kume:
        return altin_kume()
    if not a.url and not a.istemci_kok and not a.kaynak_kok:
        ap.print_help()
        return CIKIS_ORTAM
    kod, s = olc(a.url, tarayici=not a.http_only,
                 istemci_kok=a.istemci_kok, kaynak_kok=a.kaynak_kok)
    if a.json:
        print(json.dumps(s, ensure_ascii=False, indent=1))
    else:
        yaz(kod, s)
    return kod


if __name__ == "__main__":
    sys.exit(main())

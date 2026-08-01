#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""iddia-kapisi.py 1.2.0 -- BELGENIN KENDI IDDIASINI DISKLE KARSILASTIRIR

NEDEN VAR (iki sinif, IKISI DE IKI KEZ isirdi, ikisinin de kapisi YOKTU):

(1) SAYI <-> LISTE TUTARSIZLIGI. slice-3c spec v1 dort yerde "on alti mutant /
    M1-M16" diyordu ama tabloda 17 satir vardi (bagimsiz denetci buldu). Kacak
    olculebilir bir seydi: kabul kriteri "M1-M16'nin hepsi uygulandi" diyordu,
    dolayisiyla HARFIYEN uyan bir teslim M5b'yi atlayabilir ve yine de "tum
    kriterler saglandi" diyebilirdi. v2 yazilirken AYNI KUSUR TEKRAR URETILDI
    ("otuz iki" <-> 36 satir) ve yalniz sansla, kapi kosulmadan once yakalandi.

(2) KANITSIZ MUTANT BEYANI. KANIT/slice-3c/09-MUTANT/00-OZET.md 36 mutantin
    hepsini "uygulandi, KIRMIZI olculdu, geri alindi" diye beyan etti; ham
    terminal ciktisi yalniz 8'i icin dosyaya yazilmisti. Beyan DURUSTTU (kaynak
    acikca yazilmisti) ama SART KARSILANMADI: spec "her biri icin kanit" diyordu.
    Ders: kosum aninda dosyaya yazilmayan ham cikti SONRADAN URETILEMEZ.

Mevcut araclar bu iki sinifa KORDUR ve bu OLCULDU:
  * spec-kapi-kapsama.py mutantlari SAYAR ama belgenin KENDI sayi iddiasiyla
    karsilastirmaz -- 17 satirlik bir tabloyu "16 mutant" diyen metinle uyumlu
    sanar (kapsama sorusu farklidir).
  * sayi-tazeligi.py yalniz "altin kume N/M" IMZALI satirlara bakar; "otuz alti
    mutant" cumlesi o imzayi tasimaz.

BU KAPI NE OLCER (ve ne OLCMEZ):
  OLCER  -- belgenin kendi cumlesindeki mutant sayisi ile TABLOSUNDAKI satir
            sayisi; beyan edilen her mutantin KANIT dizininde bir ham cikti
            dosyasina sahip olup olmadigini.
  OLCMEZ -- mutantin GERCEKTEN isirdigini (bu kosan kod ister; spec-kapi-kapsama
            da ayni sinirini beyan eder). Ham ciktinin ICERIGININ dogru oldugunu
            da olcmez; VARLIGINI olcer. Bir dosyanin var olmasi, o mutantin
            kosuldugunu KANITLAMAZ -- yalnizca kanitin URETILDIGINI gosterir.

TURKCE SAYI: kusur tam da YAZIYLA yazilan sayilarda dogdu ("on alti", "otuz iki"),
bu yuzden 0-99 arasi Turkce sayi sozcukleri COZULUR. Rakamla yazilanlar da.

KODLAR: I0 bicim ? I1 sayi<->liste ? I2 kanitsiz mutant ? I3 hayalet kanit
        ? I4 gerekcesiz muafiyet ? I5 olu muafiyet.

Muafiyet: araclar/iddia-muafiyet.json -- GEREKCESIZ OLAMAZ (I4) ve artik hicbir
sapmayi ortmuyorsa OLU'dur ve SOYLENIR (I5). Olu tuzak bu projede adi konmus bir
kusur sinifidir.

KULLANIM:
  python araclar/iddia-kapisi.py <belge.md> [--kanit <dizin>]
  python araclar/iddia-kapisi.py --altin-kume

CIKIS: 0 temiz/sari ? 1 KIRMIZI ? 2 kullanim hatasi.
"""
import hashlib
import json
import os
import re
import sys
import tempfile

SURUM = "1.2.0"
LISTE_ESIGI = 8  # bu kadar farkli mutant kimligi tasiyan dosya ENVANTERDIR, kanit degil
# [D5] Esik K40 geregi UYDURULMADI: D1'den sonra kimlik SAYISI dosya ADINDAN
# okunur (icerikten degil) ve altin kumede IKI YONLU pinlenir --
# LISTE_ESIGI_PIN_VAKALARI'nda ADLANDIRILAN vaka numaralariyla:
# vaka 16 esik DEGERINI (8) reddeder, vaka 17 esigin BIR ALTINI (7) kabul eder.
# Eski yorum on ucuncu ve on dorduncu vaka numaralarina atif yapiyordu --
# altin_kume()'de o numaralarda vaka YOKTU (mevcut kume 12 vakaydi) ve gerekce
# icerik-taramali eski yola atif yapiyordu; D1'den sonra o yol hic kosmuyor --
# KOR BIR ATIFTI. Sabit + bu yorum ile atif artik MEKANIK: `LISTE_ESIGI_PIN_VAKALARI`
# degisirse burasi da degismek ZORUNDADIR, aksi halde `findstr` ile yapilan
# kriter 11 yakalar. (Bu yorumun kendisi eski YANLIS atfi rakamla TEKRAR ETMEZ --
# kapinin kendi I1 ayagi boyle bir tekrari sayi iddiasi sanabilirdi, S7.)
LISTE_ESIGI_PIN_VAKALARI = (16, 17)

# --------------------------------------------------------------- Turkce sayi
_BIRLER = {
    "sifir": 0, "bir": 1, "iki": 2, "uc": 3, "dort": 4, "bes": 5,
    "alti": 6, "yedi": 7, "sekiz": 8, "dokuz": 9,
}
_ONLAR = {
    "on": 10, "yirmi": 20, "otuz": 30, "kirk": 40, "elli": 50,
    "altmis": 60, "yetmis": 70, "seksen": 80, "doksan": 90,
}


def _sadelestir(s):
    """Turkce harfleri ASCII'ye indirger -- belge kaynagi karisik olabilir."""
    esle = {
        "ç": "c", "Ç": "c", "ğ": "g", "Ğ": "g",
        "ı": "i", "İ": "i", "ö": "o", "Ö": "o",
        "ş": "s", "Ş": "s", "ü": "u", "Ü": "u",
        "â": "a", "î": "i", "û": "u",
    }
    return "".join(esle.get(ch, ch) for ch in s).lower()


def turkce_sayi(sozcukler):
    """['otuz','alti'] -> 36 ? ['on','alti'] -> 16 ? ['yedi'] -> 7 ? yoksa None.

    YALNIZ 0-99. Yuz/bin BILEREK desteklenmez: bu kapi mutant sayilarini olcer
    ve uc haneli bir mutant listesi bu projede kusurun kendisi olurdu.
    """
    if not sozcukler:
        return None
    s = [_sadelestir(x) for x in sozcukler]
    if len(s) == 1:
        if s[0] in _ONLAR:
            return _ONLAR[s[0]]
        if s[0] in _BIRLER:
            return _BIRLER[s[0]]
        return None
    if len(s) == 2 and s[0] in _ONLAR and s[1] in _BIRLER and _BIRLER[s[1]] != 0:
        return _ONLAR[s[0]] + _BIRLER[s[1]]
    return None


# ------------------------------------------------------------- iddia cikarma
# "otuz alti mutant" / "36 mutant" / "M1-M36" / "M1–M36" (kisa+uzun tire)
_YAZI = re.compile(
    r"\b((?:on|yirmi|otuz|kirk|elli|altmis|yetmis|seksen|doksan)"
    r"(?:\s+(?:bir|iki|uc|dort|bes|alti|yedi|sekiz|dokuz))?"
    r"|bir|iki|uc|dort|bes|alti|yedi|sekiz|dokuz)\s+mutant\b")
_RAKAM = re.compile(r"\b(\d{1,3})\s+mutant\b")
# TERS SIRA -- "MUTANTLAR -- otuz alti" / "MUTANTLAR: 36". Bu deseni ALTIN KUME
# EKLETTI: ilk surum yalniz "N mutant" siralamasini taniyordu ve slice-3c'nin
# GERCEK kacagi ("## 6. MUTANTLAR -- otuz alti;") tam da ters siradaydi -- yani
# kapi, yazildigi ilk halde kendi var olus sebebini KACIRIYORDU.
_YAZI_TERS = re.compile(
    r"\bmutant\w*\b\s*(?:[-–—:]+|\()\s*"
    r"((?:on|yirmi|otuz|kirk|elli|altmis|yetmis|seksen|doksan)"
    r"(?:\s+(?:bir|iki|uc|dort|bes|alti|yedi|sekiz|dokuz))?"
    r"|bir|iki|uc|dort|bes|alti|yedi|sekiz|dokuz)\b")
_RAKAM_TERS = re.compile(r"\bmutant\w*\b\s*(?:[-–—:]+|\()\s*(\d{1,3})\b")
_ARALIK = re.compile(r"`?M(\d{1,3})`?\s*[-–—]+\s*`?M(\d{1,3})`?")

# §6 tablosundaki mutant satirlari: | **M12** | ... ya da | M12 | ...
_SATIR = re.compile(r"^\s*\|\s*\*{0,2}(M\d{1,3}[a-z]?)\*{0,2}\s*\|")


def tablodaki_mutantlar(metin):
    """Tablo satirlarindan mutant kimliklerini SIRAYLA cikarir (tekrarsiz)."""
    bulunan, gorulen = [], set()
    for satir in _sadelestir_koruyarak(metin).split("\n"):
        m = _SATIR.match(satir)
        if m and m.group(1) not in gorulen:
            gorulen.add(m.group(1))
            bulunan.append(m.group(1))
    return bulunan


def _sadelestir_koruyarak(metin):
    """Satir yapisini bozmadan yalniz Turkce harfleri indirger."""
    return "".join(
        {"ç": "c", "Ç": "C", "ğ": "g", "Ğ": "G", "ı": "i", "İ": "I",
         "ö": "o", "Ö": "O", "ş": "s", "Ş": "S", "ü": "u", "Ü": "U"}.get(ch, ch)
        for ch in metin)


def iddialar(metin):
    """Belgedeki mutant SAYISI iddialarini toplar: [(tur, deger, ham, satir_no)].

    `satir_no` [D4]: `metin.count("\\n", 0, m.start()) + 1` ile turetilir --
    tarama TUM METIN uzerinde kalir, yalniz konum EKLENIR (satir satir
    taramaya GECILMEZ; `_YAZI_TERS` satir sinirini asabilir, bu yetenek
    KORUNUR).
    """
    duz = _sadelestir_koruyarak(metin)
    cikti = []
    for m in _YAZI.finditer(duz.lower()):
        d = turkce_sayi(m.group(1).split())
        if d is not None:
            cikti.append(("yazi", d, m.group(0).strip(), duz.count("\n", 0, m.start()) + 1))
    for m in _RAKAM.finditer(duz):
        cikti.append(("rakam", int(m.group(1)), m.group(0).strip(),
                      duz.count("\n", 0, m.start()) + 1))
    for m in _YAZI_TERS.finditer(duz.lower()):
        d = turkce_sayi(m.group(1).split())
        if d is not None:
            cikti.append(("yazi-ters", d, m.group(0).strip(),
                          duz.count("\n", 0, m.start()) + 1))
    for m in _RAKAM_TERS.finditer(duz):
        cikti.append(("rakam-ters", int(m.group(1)), m.group(0).strip(),
                      duz.count("\n", 0, m.start()) + 1))
    # ARALIK YALNIZ BUTUNLUK BAGLAMINDA TOPLAM IDDIASIDIR. Gercek depoda olculdu:
    # 09-MUTANT/00-OZET.md "M1-M2 (G1), M34-M36 (G6) taze kosuldu" diyor -- bunlar
    # KAPSAM ifadeleridir, toplam degil. Ilk surum ucunu de toplam sanip UC YANLIS-
    # POZITIF uretti. Kural: aralik, ayni SATIRDA butunluk sozcugu tasiyorsa sayilir.
    _BUTUNLUK = ("tek tek", "hepsi", "tamami", "butun", "toplam", "kriter",
                 "uygulandi", "her biri")
    for satir_no, satir in enumerate(duz.split("\n"), 1):
        alt = satir.lower()
        if not any(s in alt for s in _BUTUNLUK):
            continue
        for m in _ARALIK.finditer(satir):
            bas, son = int(m.group(1)), int(m.group(2))
            if son >= bas:
                cikti.append(("aralik", son - bas + 1, m.group(0).strip(), satir_no))
    return cikti


_MNN = re.compile(r"(?i)(?<![0-9A-Za-z])M(\d{1,3}[a-z]?)(?![0-9A-Za-z])")
# [D1] sertlestirilmis desen: eski `\bM(\d{1,3}[a-z]?)\b` `_tmp_diff_M26.txt` ve
# `M12_kirmizi.txt` gibi adlari KACIRIYORDU (`_` bir `\w` karakteridir, `\b`
# saglanmaz) ve `2026-M4.txt` gibi bir tarih onekini YANLISLIKLA `M4` saniyordu.


def kanit_topla(adlar):
    """SAF FONKSIYON -- diske DOKUNMAZ [D0]. `adlar`: dosya adi/yolu dizisi.

    Bir mutant KANITLI sayilir ancak ve ancak: dosya ADINDA `Mnn` kimligi
    geciyorsa -- ICERIK ARTIK OKUNMAZ (bu fonksiyonun imzasinda hic yok).
    Kimlik eslemesi yalniz TEMEL ada (`os.path.basename`) uygulanir; bir
    dizin adindaki kimlik gorunmez [S9]. Ozet/hukum belgeleri (D2) ve
    LISTE_ESIGI'yi asan cok-kimlikli adlar (D3) ELENIR.

    Doner: (kanitli, envanterler, elenen).
      kanitli     -- kanit TASIYAN mutant kimlikleri (set)
      envanterler -- [(ad, kimlik_sayisi), ...] -- ENVANTER REDDEDILEN adlar
      elenen      -- dairesel-kanit filtresine takilan adlar
    """
    kanitli = set()
    envanterler = []
    elenen = []
    for ad in adlar or []:
        temel = os.path.basename(ad)
        # DAIRESEL KANIT YASAGI [D2] -- OZET ve HUKUM belgeleri kanit SAYILMAZ.
        # Sadelestirilmis ad "ozet" ya da "hukum" dizgesini ICERIYORSA elenir --
        # startswith DEGIL: on ek numarasi (`09-`, `T8-`, `TASIMA-00-`) bir
        # KACIS YOLU degildir. Gercek depoda olculdu: `_ad.startswith(...)`
        # yuzunden `09-HUKUM.md`, `T8-OZET.md`, `T9-ILERLEME-OZETI.md`,
        # `TASIMA-00-OZET.md` filtreden KACIYORDU. Kimlik HAM addan (`temel`),
        # eleme SADELESTIRILMIS addan (`_temel`) okunur -- ayrim NETTIR.
        _temel = _sadelestir(temel)
        if "ozet" in _temel or "hukum" in _temel:
            elenen.append(ad)
            continue
        kimlikler = {"M" + m.group(1) for m in _MNN.finditer(temel)}
        if not kimlikler:
            continue
        # ENVANTER REDDI [D3]: bir dosya ADI LISTE_ESIGI kadar (ya da fazla)
        # farkli kimlik tasiyorsa o ad bir ENVANTERDIR, tekil kosum kaniti DEGIL.
        if len(kimlikler) >= LISTE_ESIGI:
            envanterler.append((ad, len(kimlikler)))
            continue
        kanitli |= kimlikler
    return kanitli, envanterler, elenen


def kanit_mutantlari(kanit_dizini):
    """INCE DISK SARMALAYICISI [D0] -- os.walk yapar, adlari toplar, SAF
    `kanit_topla()`'yi cagirir. Kendisi hicbir kural OLCMEZ."""
    if not kanit_dizini or not os.path.isdir(kanit_dizini):
        return None
    adlar = []
    for kok, _dizinler, dosyalar in os.walk(kanit_dizini):
        for ad in dosyalar:
            adlar.append(os.path.relpath(os.path.join(kok, ad), kanit_dizini))
    kanitli, envanterler, _elenen = kanit_topla(adlar)
    return kanitli, envanterler


def muafiyet_yukle(kok):
    """araclar/iddia-muafiyet.json -- [D0] YALNIZ YUKLER, JSON HATASINI BILDIRIR.

    Alan dogrulamasi (gerekce/borc/tavan/sha/oluluk) ARTIK burada YAPILMAZ --
    saf cekirdege (`denetle()`) tasindi; bu fonksiyon disk erisimi GEREKTIREN
    tek adimdir ve yalnizca o adimi yapar.
    """
    yol = os.path.join(kok, "araclar", "iddia-muafiyet.json")
    if not os.path.isfile(yol):
        return [], []
    try:
        with open(yol, encoding="utf-8") as f:
            kayitlar = json.load(f)
    except Exception as ex:  # noqa: BLE001 -- bozuk muafiyet KIRMIZI'dir
        return [], [("KIRMIZI", "I4", "iddia-muafiyet.json BOZUK: %r" % (ex,))]
    return (kayitlar if isinstance(kayitlar, list) else []), []


def _muafiyet_kodu(m):
    """kod alani yoksa I2 varsayilir -- eski bicim [D4] boyle korunur."""
    return (m.get("kod") or "I2").strip() or "I2"


def _muafiyet_gecerli_mi(m):
    """GENEL alan dogrulamasi: `borc` bos olamaz, `gerekce` >= 20 karakter."""
    gerekce = (m.get("gerekce") or "").strip()
    borc = (m.get("borc") or "").strip()
    return len(gerekce) >= 20 and bool(borc)


def _yol_norm(y):
    """[D4] iki taraf da depo kokune gore goreli varsayilip `/` ile karsilastirilir
    -- JSON `/` ile yazilir, kriterler `\\` ile cagirir; duz karsilastirma Windows'ta
    hicbir zaman tutmaz."""
    return os.path.normpath(y or "").replace("\\", "/")


def _satir_sha(metin, satir_no):
    """[D4] satir_sha = HAM DOSYA SATIRINDAN -- sadelestirilmis/kucuk harfli
    satir KULLANILMAZ."""
    satir = metin.split("\n")[satir_no - 1].strip()
    return hashlib.sha256(satir.encode("utf-8")).hexdigest()[:16]


def _ham_sha(ham):
    """[D4] ham_sha = iddialar()'in DONDURDUGU `ham` alanindan (sadelestirilmis
    +yazi turlerinde .lower() sonrasi hal); baska normalizasyon UYGULANMAZ."""
    return hashlib.sha256(ham.strip().encode("utf-8")).hexdigest()[:16]


# --------------------------------------------------------------- saf cekirdek
def denetle(metin, kanitli=None, muafiyetler=None, belge_yolu=None):
    """SAF FONKSIYON -- diske DOKUNMAZ [D0]. Doner: [(SEVIYE, KOD, mesaj)].

    `kanitli` None ise kanit ayagi CALISTIRILMAZ (olculmedi != temiz): I2/I3
    hukmu verilmez ve bu ozette SOYLENIR. `belge_yolu` -- I1 muafiyetinin
    `dosya` alaniyla eslesecek deger [D4].
    """
    muafiyetler = muafiyetler or []
    bulgular = []

    # --- I4: muafiyet kayitlarinin GENEL gecerliligi -- [D0] burada, cekirdekte.
    # Bugun I4 yalniz muafiyet_yukle() icinde uretiliyordu (denetle() icinde SIFIR
    # kez); bu artik denetlenen belgeden BAGIMSIZ, HER kosumda calisir.
    for m in muafiyetler:
        if not _muafiyet_gecerli_mi(m):
            bulgular.append(("KIRMIZI", "I4",
                             "GEREKCESIZ MUAFIYET: %r -- `borc` ve en az 20 karakter "
                             "`gerekce` ZORUNLUDUR."
                             % (m.get("mutant") or m.get("dosya") or m.get("kod"),)))

    # --- I4 (devam) [D4]: I1 TAVANI -- `dosya`'ya gore gruplanmis TUM I1
    # kayitlari uzerinde en cok 3. Sayim denetlenen belgeden BAGIMSIZDIR --
    # aksi halde baska bir belgeye yazilan yedi muafiyet HIC GORUNMEZDI.
    _i1_dosya_sayaci = {}
    for m in muafiyetler:
        if _muafiyet_kodu(m) == "I2" or not _muafiyet_gecerli_mi(m):
            continue
        d = _yol_norm(m.get("dosya"))
        _i1_dosya_sayaci[d] = _i1_dosya_sayaci.get(d, 0) + 1
    for _dosya, _adet in sorted(_i1_dosya_sayaci.items()):
        if _adet > 3:
            bulgular.append(("KIRMIZI", "I4",
                             "MUAFIYET TAVANI ASILDI: %s icin %d adet I1 kaydi var "
                             "(tavan 3, TUM dosyalar uzerinde sayilir)."
                             % (_dosya, _adet)))

    muaf_mutant = {(m.get("mutant") or "").strip()
                   for m in muafiyetler
                   if _muafiyet_kodu(m) == "I2" and _muafiyet_gecerli_mi(m)}
    # [D4] I1 KAPSAMI: yalniz DENETLENEN belgeye ait, GECERLI I1 kayitlari.
    i1_kapsam = [m for m in muafiyetler
                 if _muafiyet_kodu(m) == "I1" and _muafiyet_gecerli_mi(m)
                 and belge_yolu is not None
                 and _yol_norm(m.get("dosya")) == _yol_norm(belge_yolu)]

    tablo = tablodaki_mutantlar(metin)
    if not tablo:
        bulgular.append(("KIRMIZI", "I0",
                         "MUTANT TABLOSU YOK ya da hicbir satir `| Mnn |` bicimine "
                         "uymuyor -- bu kapi olcemez."))
        return bulgular, tablo, set()

    # --- I1: belgenin KENDI sayi iddiasi <-> tablo satir sayisi [D4: sha-keyli
    # muafiyet]. I5 (I1 icin) burada, kanitli-is-None ERKEN DONUSUNDEN ONCE
    # degerlendirilir -- bugunku I5 dongusu o erken donusun ARDINDA idi ve
    # --kanit verilmeden kosan her denetimde olu muafiyet GORUNMUYORDU.
    _kullanilan_i1 = set()
    for tur, deger, ham, satir_no in iddialar(metin):
        if deger == len(tablo):
            continue
        satir_sha = _satir_sha(metin, satir_no)
        ham_sha = _ham_sha(ham)
        eslesen = next((k for k in i1_kapsam
                        if k.get("satir_sha") == satir_sha
                        and k.get("ham_sha") == ham_sha), None)
        if eslesen is not None:
            _kullanilan_i1.add(id(eslesen))
            bulgular.append(("BILGI", "I1",
                             "MUAFIYET UYGULANDI [borc %s] -- satir %d %r (%s): %s. "
                             "Muafiyet SESSIZ DEGILDIR; borc kapaninca bu satir da "
                             "kapanir." % (eslesen.get("borc"), satir_no, ham, tur,
                                           eslesen.get("gerekce"))))
            continue
        bulgular.append(("KIRMIZI", "I1",
                         "SAYI<->LISTE TUTARSIZLIGI: belge %r diyor (%s), tabloda "
                         "%d mutant satiri var. Kabul kriteri bu sayiya atif "
                         "yaparsa, FAZLA olan mutant SESSIZCE atlanabilir."
                         % (ham, tur, len(tablo))))
    for k in i1_kapsam:
        if id(k) not in _kullanilan_i1:
            bulgular.append(("SARI", "I5",
                             "OLU MUAFIYET: I1 kaydi (dosya=%s, satir_sha=%s) icin "
                             "muafiyet duruyor ama artik hicbir sapmayi ortmuyor -- "
                             "SILINMELIDIR." % (k.get("dosya"), k.get("satir_sha"))))

    # --- I2/I3: beyan <-> ham kanit ------------------------------------------
    kullanilan_muafiyet = set()
    if kanitli is None:
        return bulgular, tablo, set()

    for mid in tablo:
        if mid in kanitli:
            continue
        if mid in muaf_mutant:
            kullanilan_muafiyet.add(mid)
            k = next(m for m in muafiyetler
                     if _muafiyet_kodu(m) == "I2" and _muafiyet_gecerli_mi(m)
                     and (m.get("mutant") or "").strip() == mid)
            bulgular.append(("BILGI", "I2",
                             "MUAFIYET UYGULANDI [borc %s] -- %s: %s. Muafiyet SESSIZ "
                             "DEGILDIR; borc kapaninca bu satir da kapanir."
                             % (k.get("borc"), mid, k.get("gerekce"))))
            continue
        bulgular.append(("KIRMIZI", "I2",
                         "KANITSIZ MUTANT: %s tabloda BEYAN EDILMIS ama KANIT dizininde "
                         "ham cikti dosyasi YOK. Kosum aninda yazilmayan cikti sonradan "
                         "URETILEMEZ." % mid))

    for mid in sorted(kanitli - set(tablo)):
        bulgular.append(("SARI", "I3",
                         "HAYALET KANIT: %s icin kanit dosyasi var ama mutant tablosunda "
                         "boyle bir satir YOK -- ya tablo eksik ya kanit bayat." % mid))

    for m in muafiyetler:
        if _muafiyet_kodu(m) != "I2" or not _muafiyet_gecerli_mi(m):
            continue
        mid = (m.get("mutant") or "").strip()
        if mid and mid not in kullanilan_muafiyet:
            bulgular.append(("SARI", "I5",
                             "OLU MUAFIYET: %s icin muafiyet duruyor ama artik hicbir "
                             "sapmayi ortmuyor -- SILINMELIDIR." % mid))

    return bulgular, tablo, kullanilan_muafiyet


def _yaz(s):
    try:
        print(s)
    except UnicodeEncodeError:
        print(s.encode("ascii", "replace").decode("ascii"))


# ---------------------------------------------------------------- altin kume
_TEMIZ = """## 6. MUTANTLAR -- uc; KAPALI liste

| # | mutant | kapi / kural | beklenen |
|---|---|---|---|
| **M1** | bir sey boz | G1 / D0 | kirmizi |
| **M2** | baska sey boz | G1 / D0 | kirmizi |
| **M3** | ucuncu sey boz | G2 / D1 | kirmizi |
"""


def _vaka(ad, metin, beklenen, kanitli=None, muafiyetler=None, olmamali=(), belge_yolu=None):
    """[D7] `beklenen`/`olmamali`: (SEVIYE, KOD) CIFTLERI -- yalniz KOD DEGIL.

    Boyle olmasi ZORUNLUDUR: eskiden yalniz KOD karsilastirilirdi ve
    `beklenen=[], olmamali=()` yazilan bir vaka `all([]) and not any(())`
    yuzunden DAIMA GECERDI -- denetci muafiyet mekanizmasini SILSE bile.
    """
    bulgular, _t, _m = denetle(metin, kanitli=kanitli, muafiyetler=muafiyetler,
                                belge_yolu=belge_yolu)
    olculen = sorted({(s, k) for s, k, _m2 in bulgular})
    beklenen, olmamali = set(beklenen), set(olmamali)
    ok = beklenen.issubset(set(olculen)) and not (olmamali & set(olculen))
    _yaz(("[GECTI] " if ok else "[KALDI] ") + ad)
    _yaz("    beklenen: %s - olmamali: %s - olculen: %s"
         % (sorted(beklenen), sorted(olmamali), olculen))
    if not ok:
        for s, k, m in bulgular:
            _yaz("      %s %s: %s" % (s, k, m))
    return ok


def _vaka_kanit(ad, adlar, beklenen_kanitli, beklenen_envanter=(), beklenen_elenen=()):
    """`kanit_topla()`'yi DOGRUDAN sinar -- D1/D2/D3 disk OLMADAN olculur."""
    kanitli, envanterler, elenen = kanit_topla(adlar)
    ok = (kanitli == set(beklenen_kanitli)
          and sorted(envanterler) == sorted(beklenen_envanter)
          and sorted(elenen) == sorted(beklenen_elenen))
    _yaz(("[GECTI] " if ok else "[KALDI] ") + ad)
    _yaz("    beklenen kanitli: %s - envanter: %s - elenen: %s"
         % (sorted(beklenen_kanitli), sorted(beklenen_envanter), sorted(beklenen_elenen)))
    if not ok:
        _yaz("    olculen  kanitli: %s - envanter: %s - elenen: %s"
             % (sorted(kanitli), sorted(envanterler), sorted(elenen)))
    return ok


def _i1_aday(metin):
    """Yardimci (yalniz altin kume icin) -- metindeki TEK I1 UYUSMAZLIK adayinin
    (satir_no, ham) ciftini bulur. sha'lari SPEC'TEN KOPYALAMAMAK icin altin kume
    kendi vaka metnini kendi ARACIN sha fonksiyonlariyla olcer."""
    tablo_n = len(tablodaki_mutantlar(metin))
    for _tur, deger, ham, satir_no in iddialar(metin):
        if deger != tablo_n:
            return satir_no, ham
    raise AssertionError("altin kume vakasi: I1 adayi bulunamadi")


def altin_kume():
    _yaz("=" * 78)
    _yaz("ALTIN KUME -- IDDIA KAPISININ KENDI KANITI (kor kapi yok)")
    _yaz("LISTE_ESIGI=%d -- LISTE_ESIGI_PIN_VAKALARI=%s [D5]"
         % (LISTE_ESIGI, LISTE_ESIGI_PIN_VAKALARI))
    _yaz("=" * 78)
    s = []

    s.append(_vaka("1) TEMIZ: 'uc' <-> 3 satir, kanit tam -- SUSMALI",
                   _TEMIZ, [], kanitli={"M1", "M2", "M3"},
                   olmamali=[("KIRMIZI", "I1"), ("KIRMIZI", "I2"), ("SARI", "I3")]))

    s.append(_vaka("2) YAZIYLA SAYI YANLIS ('iki' <-> 3 satir) -- I1 ISIRMALI",
                   _TEMIZ.replace("-- uc;", "-- iki;"), [("KIRMIZI", "I1")],
                   kanitli={"M1", "M2", "M3"}))

    s.append(_vaka("3) RAKAMLA SAYI YANLIS ('16 mutant' <-> 3) -- I1 ISIRMALI",
                   _TEMIZ + "\nToplam 16 mutant uygulandi.\n", [("KIRMIZI", "I1")],
                   kanitli={"M1", "M2", "M3"}))

    s.append(_vaka("4) ARALIK YANLIS (M1-M16 <-> 3 satir) -- I1 ISIRMALI",
                   _TEMIZ + "\nKriter: `M1`-`M16` tek tek uygulandi.\n", [("KIRMIZI", "I1")],
                   kanitli={"M1", "M2", "M3"}))

    s.append(_vaka("5) GERCEK slice-3c KACAGI: 'on alti' <-> 17 satir -- I1 ISIRMALI",
                   _TEMIZ.replace("-- uc;", "-- on alti;")
                   + "| **M3b** | dorduncu | G2 / D1 | kirmizi |\n", [("KIRMIZI", "I1")],
                   kanitli={"M1", "M2", "M3", "M3b"}))

    s.append(_vaka("6) KANITSIZ MUTANT -- I2 ISIRMALI",
                   _TEMIZ, [("KIRMIZI", "I2")], kanitli={"M1", "M2"}))

    s.append(_vaka("7) HAYALET KANIT -- I3 ISIRMALI",
                   _TEMIZ, [("SARI", "I3")], kanitli={"M1", "M2", "M3", "M9"}))

    s.append(_vaka("8) KANIT OLCULMEDI (None) -- I2/I3 HUKMU VERILMEZ",
                   _TEMIZ, [], kanitli=None,
                   olmamali=[("KIRMIZI", "I2"), ("BILGI", "I2"), ("SARI", "I3")]))

    s.append(_vaka("9) TABLO YOK -- I0 ISIRMALI",
                   "## 6. MUTANTLAR\nbos govde\n", [("KIRMIZI", "I0")], kanitli=set()))

    s.append(_vaka("10) GEREKCELI MUAFIYET -- I2 KIRMIZI SUSAR, BILGI BASILIR [D7 ONARIMI]",
                   _TEMIZ, [("BILGI", "I2")], kanitli={"M1", "M2"},
                   muafiyetler=[{"mutant": "M3", "borc": "BD-9",
                                 "gerekce": "cihaz gerektiren mutant, sonraki dilimde kosulacak"}]))

    s.append(_vaka("11) OLU MUAFIYET -- I5 ISIRMALI",
                   _TEMIZ, [("SARI", "I5")], kanitli={"M1", "M2", "M3"},
                   muafiyetler=[{"mutant": "M3", "borc": "BD-9",
                                 "gerekce": "artik gecerli degil, kanit uretildi ama kayit duruyor"}]))

    s.append(_vaka("12) COKLU IDDIA: biri dogru biri yanlis -- I1 YINE ISIRMALI",
                   _TEMIZ + "\nToplam 3 mutant.\nKriter: `M1`-`M9` uygulandi.\n",
                   [("KIRMIZI", "I1")], kanitli={"M1", "M2", "M3"}))

    # --- D1/D2/D3: kanit_topla() SAF FONKSIYONUNUN dogrudan sinanmasi --------
    # vaka 13 GERCEK bir dosya kullanir (icerigi "M10" GECIYOR) -- M109 mutanti
    # (icerik yeniden TARANSA) yalniz boyle yakalanabilir; hayali bir ad
    # icin open() sessizce basarisiz olur ve mutant hic ISIRMAZ.
    with tempfile.TemporaryDirectory() as _td13:
        _p13 = os.path.join(_td13, "M100.txt")
        with open(_p13, "w", encoding="utf-8") as _f13:
            _f13.write("log ozeti: mutant M10 burada basarisiz oldu\n")
        s.append(_vaka_kanit(
            "13) ad M100.txt (gercek dosya, icerigi 'M10' GECIYOR) -- HAYALET M10 "
            "dogmaz (D1: icerik ARTIK TARANMAZ, kimlik HAM adin TAMAMINA "
            "sertlestirilmis desenle uygulanir)",
            [_p13], {"M100"}))

    s.append(_vaka_kanit(
        "14) kanit adi 09-HUKUM.md -- on ek NUMARALI (D2: startswith degil, "
        "sadelestirilmis adin ICINDE arar) -- ELENIR",
        ["09-HUKUM.md"], set(), (), ["09-HUKUM.md"]))

    s.append(_vaka_kanit(
        "15) kanit adi T8-OZET.md -- on ek HARFLI (D2) -- ELENIR",
        ["T8-OZET.md"], set(), (), ["T8-OZET.md"]))

    s.append(_vaka_kanit(
        "16) dosya ADI 8 farkli kimlik tasiyor (D3, esik) -- ENVANTER REDDI",
        ["M1-M2-M3-M4-M5-M6-M7-M8-liste.txt"], set(),
        [("M1-M2-M3-M4-M5-M6-M7-M8-liste.txt", 8)]))

    s.append(_vaka_kanit(
        "17) dosya ADI 7 farkli kimlik tasiyor (D3, esigin alti) -- KABUL EDILIR "
        "(LISTE_ESIGI=8 ALTTAN pinlendi)",
        ["M1-M2-M3-M4-M5-M6-M7-liste.txt"],
        {"M1", "M2", "M3", "M4", "M5", "M6", "M7"}))

    # --- D4: I1 (sayi<->liste) icin sha-keyli, dosya-kapsamli muafiyet -------
    _D4_METIN = _TEMIZ + "\nToplam 5 mutant uygulandi.\n"
    _d4_satir, _d4_ham = _i1_aday(_D4_METIN)
    _d4_sha = _satir_sha(_D4_METIN, _d4_satir)
    _d4_hamsha = _ham_sha(_d4_ham)
    _GEREKCE20 = "altin kume test muafiyeti - en az yirmi karakter uzunlukta"

    _muaf18 = [{"kod": "I1", "dosya": "VAKA-D4.md", "satir_sha": _d4_sha,
                "ham_sha": _d4_hamsha, "borc": "BD-D4T", "gerekce": _GEREKCE20}]
    s.append(_vaka("18) I1 muafiyeti: uc alan da tutuyor (D4) -- BILGI I1 VAR, KIRMIZI I1 YOK",
                   _D4_METIN, [("BILGI", "I1")], kanitli={"M1", "M2", "M3"},
                   muafiyetler=_muaf18, olmamali=[("KIRMIZI", "I1")],
                   belge_yolu="VAKA-D4.md"))

    _muaf19 = [dict(_muaf18[0], satir_sha="0" * 16)]
    s.append(_vaka("19) I1 muafiyeti: satir_sha TUTMUYOR (D4) -- muafiyet OLUR, KIRMIZI I1",
                   _D4_METIN, [("KIRMIZI", "I1")], kanitli={"M1", "M2", "M3"},
                   muafiyetler=_muaf19, belge_yolu="VAKA-D4.md"))

    _muaf20 = [{"kod": "I1", "dosya": "VAKA20.md", "satir_sha": "sha%d" % i,
                "ham_sha": "ham%d" % i, "borc": "BD-X", "gerekce": _GEREKCE20}
               for i in range(4)]
    s.append(_vaka("20) I1 muafiyet TAVANI asildi: bir belgede 4 kayit (D4) -- KIRMIZI I4",
                   _TEMIZ, [("KIRMIZI", "I4")], kanitli={"M1", "M2", "M3"},
                   muafiyetler=_muaf20, belge_yolu="baska-belge.md"))

    # 20b AYRICA (BILGI,I1)/(KIRMIZI,I1) ayni-kod cift-seviye desenini tasir --
    # D7'nin sinadigi TAM SINIF budur: seviyesiz karsilastirma bu ciftte
    # cakisir (I1 hem "olmali" hem "olmamali" sanilir), tavan bunun UZERINE
    # eklenmis IKINCI, bagimsiz bir olcumdur.
    _muaf20b = [dict(_muaf18[0], dosya="VAKA20B.md")] + [
        {"kod": "I1", "dosya": "VAKA20B.md", "satir_sha": "fill%dsha" % i,
         "ham_sha": "fill%dham" % i, "borc": "BD-X", "gerekce": _GEREKCE20}
        for i in range(2)]
    s.append(_vaka("20b) I1 muafiyet tavaninda: bir belgede 3 kayit (D4) -- I4 YOK "
                   "(tavan ustten pinlendi); esas kayit yine ESLESIR",
                   _D4_METIN, [("BILGI", "I1")], kanitli={"M1", "M2", "M3"},
                   muafiyetler=_muaf20b,
                   olmamali=[("KIRMIZI", "I1"), ("KIRMIZI", "I4")],
                   belge_yolu="VAKA20B.md"))

    _muaf21 = [{"kod": "I1", "dosya": "VAKA21.md", "satir_sha": "x", "ham_sha": "y",
                "borc": "BD-X", "gerekce": "kisa"}]
    s.append(_vaka("21) I1 muafiyeti: gerekce 20 karakterden kisa (D4) -- KIRMIZI I4",
                   _TEMIZ, [("KIRMIZI", "I4")], kanitli={"M1", "M2", "M3"},
                   muafiyetler=_muaf21, belge_yolu="VAKA21.md"))

    _muaf22 = [{"kod": "I1", "dosya": "VAKA22.md", "satir_sha": "aaaa", "ham_sha": "bbbb",
                "borc": "BD-X", "gerekce": _GEREKCE20}]
    s.append(_vaka("22) I1 muafiyeti hicbir iddiayi ortmuyor, AYNI belge (D4) -- SARI I5",
                   _TEMIZ, [("SARI", "I5")], kanitli={"M1", "M2", "M3"},
                   muafiyetler=_muaf22, belge_yolu="VAKA22.md"))

    s.append(_vaka("22b) I1 muafiyeti BASKA belgeye ait, bu belge denetleniyor (D4) -- "
                   "I5 YOK (kapsam pinlendi)",
                   _TEMIZ, [], kanitli={"M1", "M2", "M3"},
                   muafiyetler=_muaf22, olmamali=[("SARI", "I5")],
                   belge_yolu="FARKLI-BELGE.md"))

    _muaf23 = [dict(_muaf18[0], dosya="VAKA23.md", ham_sha="yanlis-ham-sha")]
    s.append(_vaka("23) I1 muafiyeti: ham_sha TUTMUYOR, satir_sha tutuyor (D4) -- "
                   "muafiyet OLUR, KIRMIZI I1",
                   _D4_METIN, [("KIRMIZI", "I1")], kanitli={"M1", "M2", "M3"},
                   muafiyetler=_muaf23, belge_yolu="VAKA23.md"))

    # Ikinci kayit (Z) BASKA bir belgeye ait, sha'lari da ILGISIZ -- dogru
    # davraniste kapsam disi kalip HICBIR IZ birakmamali (ne eslesme ne I5).
    # Kapsam kontrolu TAMAMEN kaldirilirsa (M121) Z de "kapsamda" sayilir,
    # eslesmez (sha'lari ilgisiz) ve OLU MUAFIYET (I5) olarak ISIRIR --
    # normalizasyon TEK BASINA kaldirilirsa (M118) Z zaten kapsam disidir,
    # ama Record X de RAW karsilastirmada kapsam disina duser.
    _muaf24 = [dict(_muaf18[0], dosya="GOREV_CLAUDE_CODE/VAKA24.md"),
               {"kod": "I1", "dosya": "TAMAMEN-BASKA-BELGE.md",
                "satir_sha": "zzzzzzzzzzzzzzzz", "ham_sha": "wwwwwwwwwwwwwwww",
                "borc": "BD-X", "gerekce": _GEREKCE20}]
    s.append(_vaka("24) muafiyetteki yol `/`, denetlenen yol `\\` (D4) -- ESLESIR, "
                   "muafiyet UYGULANIR; BASKA belgeye ait ikinci kayit kapsam DISI "
                   "kalir (I5 dogmaz)",
                   _D4_METIN, [("BILGI", "I1")], kanitli={"M1", "M2", "M3"},
                   muafiyetler=_muaf24,
                   olmamali=[("SARI", "I5")],
                   belge_yolu="GOREV_CLAUDE_CODE\\VAKA24.md"))

    kaldi = s.count(False)
    _yaz("=" * 78)
    _yaz("ALTIN KUME: %s (%d/%d)" % ("GECTI" if kaldi == 0 else "KALDI",
                                     len(s) - kaldi, len(s)))
    _yaz("HUKUM: %s" % ("ARAC KULLANILABILIR -- temizde susuyor, kirlide isiriyor."
                        if kaldi == 0 else "ARAC KULLANILAMAZ"))
    _yaz("=" * 78)
    return 0 if kaldi == 0 else 1


# ---------------------------------------------------------------------- main
def main(argv):
    if "--altin-kume" in argv:
        return altin_kume()
    if not argv:
        _yaz(__doc__)
        return 2

    belge = argv[0]
    kanit = None
    if "--kanit" in argv:
        i = argv.index("--kanit")
        if i + 1 >= len(argv):
            _yaz("KULLANIM HATASI: --kanit bir dizin bekler.")
            return 2
        kanit = argv[i + 1]

    if not os.path.isfile(belge):
        _yaz("DOSYA YOK: %s" % belge)
        return 2

    kok = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    muafiyetler, muaf_hata = muafiyet_yukle(kok)

    with open(belge, encoding="utf-8") as f:
        metin = f.read()

    _k = kanit_mutantlari(kanit)
    kanitli, envanterler = (None, []) if _k is None else _k
    bulgular, tablo, _kul = denetle(metin, kanitli=kanitli, muafiyetler=muafiyetler,
                                     belge_yolu=belge)
    bulgular = muaf_hata + bulgular

    _yaz("=" * 78)
    _yaz("IDDIA KAPISI %s -- %s" % (SURUM, belge))
    _yaz("=" * 78)
    _yaz("TABLODAKI MUTANT (%d): %s"
         % (len(tablo), ", ".join(tablo) if tablo else "-"))
    if kanitli is None:
        _yaz("KANIT DIZINI: verilmedi -- I2/I3 OLCULMEDI.")
        _yaz("  OLCULMEDI demek, TEMIZ demek DEGILDIR.")
    else:
        _yaz("KANITLI MUTANT (%d): %s"
             % (len(kanitli), ", ".join(sorted(kanitli)) if kanitli else "-"))
        for yol, adet in envanterler:
            _yaz("  [ENVANTER REDDI] %s -- %d farkli mutant kimligi tasiyor "
                 "(esik %d); bu bir LISTE ciktisidir, tekil kosum kaniti DEGILDIR."
                 % (yol, adet, LISTE_ESIGI))
    _yaz("-" * 78)

    if not bulgular:
        _yaz("BULGU YOK: belgenin kendi sayi iddiasi tablosuyla tutuyor" +
             ("" if kanitli is None else " ve beyan edilen her mutantin ham kaniti var") + ".")
    for seviye, kod, mesaj in bulgular:
        _yaz("[%s] %s: %s" % (seviye, kod, mesaj))

    _yaz("-" * 78)
    _yaz("BEYAN EDILMIS SINIR: bu kapi mutantin GERCEKTEN ISIRDIGINI olcmez ve ham")
    _yaz("ciktinin ICERIGINI dogrulamaz -- kanitin VARLIGINI olcer. Bir dosyanin var")
    _yaz("olmasi o mutantin kosuldugunu kanitlamaz; kanitin URETILDIGINI gosterir.")
    _yaz("=" * 78)

    kirmizi = any(s == "KIRMIZI" for s, _k, _m in bulgular)
    _yaz("HUKUM: %s" % ("KIRMIZI" if kirmizi else "TEMIZ"))
    return 1 if kirmizi else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

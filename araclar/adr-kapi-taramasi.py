#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
adr-kapi-taramasi.py — ADR kapı/tamlık ölçüm aracı (Momentum, K18-d / K19-c)

NE YAPAR
--------
Bir ADR belgesindeki her `**Kx-…**` KARARI çıkarır ve o kararın
  (a) §3 mutant tablosunda bir çıpası var mı,
  (b) yoksa §3.1'de "mutantsız" diye AÇIKÇA beyan edilmiş mi
sorusunu MEKANİK olarak yanıtlar. İkisi de yoksa: KAPI HATASI.

Ayrıca ALTI yardımcı ölçüm koşar:
  K2  sarkan atıf     — tabloda/§3.1'de atıf var ama karar başlığı yok (emekli etiket)
  K3  tablo bütünlüğü — başlık satırı olmayan markdown tablosu (GFM'de render olmaz)
  K4  kanonik sayı    — kanonik tablodaki bir sayı gövdede KOPYALANMIŞ mı (atıf yerine).
                        Bilinçli literaller `[KS-LITERAL: gerekçe]` ile işaretlenir (birebir
                        alıntı · ölçüm kaydı · geri çekilmiş iddia). Sessiz muafiyet yoktur.
  K5  mutant numarası — kayıp/çift numara
  K6  çıpa bütünlüğü  — §3 tablosunun ÇIPA SÜTUNU var mı; bir karar hem kapılı hem
                        §3.1'de kapısız-beyanlı mı (çelişki); §3.1'de "kapısız kalan"
                        tablosu var mı
  K7  metin bütünlüğü — görünmez/sıfır-genişlikli karakter (regex'i böler, okuyucuya görünmez)

ONARIM KAYDI [oturum 22, K26-a — kapı-5'in B5-1…B5-4 bulguları]
---------------------------------------------------------------
Bu araç kapı-5'te DÖRT kör noktasıyla yakalandı; dördü de burada onarıldı ve her biri
altın kümede ONARIMDAN ÖNCE KIRMIZI / SONRA YEŞİL olduğu koşularak kanıtlandı:
  B5-1  değerinde rakam olmayan kanonik satır (`Environment.ProcessorCount`) sözlüğe hiç
        girmiyor, dolayısıyla "kapsam dışı" raporuna da giremiyordu = SESSİZ DARALTMA.
        ⇒ artık TÜM satırlar sözlüğe girer; ayrıca `kanonik_satir == taranan + atlanan`
        MUHAFIZI eklendi (tutmazsa araç kendini K4 bulgusuyla ihbar eder).
  B5-2  `("[KS-" not in s)` koşulu, `[KS-n]` atfı geçen HER satırı K4'ten muaf tutuyordu
        ⇒ "aynı satırda hem atıf hem ham sayı" yapısal olarak görülemiyordu. Muafiyet
        yalnız `[KS-LITERAL:` ile sınırlandı; `[KS-n]` jetonları taramadan ÖNCE MASKELENİR.
  B5-3  `K1` çıpa sütununu ayrıştırmıyor, §3'ün TÜM METNİNDE alt dize arıyordu ⇒ giriş
        paragrafında/devir cümlesinde adı geçen karar "kapılı" sayılıyordu.
        ⇒ artık YALNIZ çıpa sütunu sayılır; çıpa sütunu OLMAYAN tablo K6 ile ihbar edilir.
  B5-4  `K4` mutant tablosunu ve §3.1'i hiç taramıyordu, oysa §1-K kuralı o iki bölgeyi
        AÇIKÇA bağlar ⇒ artık taranır; ayrıca `[KS-n]±1` SINIR DEĞER literalleri raporlanır.
ARACIN BEYAN EDİLMİŞ SINIRLARI (kapı-6 bunları ELLE denetlemelidir):
  · Araç KARAR-ID düzeyindedir: bir kararın kapılı-olmayan ÖZELLİKLERİNİ göremez.
  · Araç etiketin VARLIĞINI ölçer; mutantın o kararı GERÇEKTEN ısırdığını ölçemez.
  · `K5`'in rezerv affı SATIR bazlıdır: "rezerv" kelimesi geçen bir satırdaki her `M<n>`
    affedilir. Jeton bazına indirilmedi — bilinçli, çünkü aralık ilanı ("M54–M59") satır
    bazlı okunuyor. ELLE kontrol edilmelidir.
  · `[KS-LITERAL: …]` muafiyetinin GEREKÇESİ mekanik olarak doğrulanmaz (gerekçe metni
    okunmaz). Muafiyet KORUNUR ama artık ADIYLA raporlanır ⇒ ELLE doğrulanmalıdır.
  · Çıpa sütunundaki jeton, o mutantın kararı GERÇEKTEN test ettiğini kanıtlamaz; alakasız
    bağlamda yazılmış bir karar adı da "kapılı" saydırır (farklı-model saldırısı koşarak
    kanıtladı). Bu, aracın en büyük tek sınırıdır ve ELLE denetlenmelidir.
  · Aracı onaran oturum onu DENETLEYEMEZ (K26): kapı-6 aracın kendisini de denetler.

FARKLI MODEL SALDIRISI [oturum 22, K26-a 3. şart — Sonnet]
----------------------------------------------------------
Onarımdan sonra araca farklı bir modelle SALDIRILDI ("bu aracı kandır"). Yedi açık bulundu,
beşi onarıldı ve altın kümeye regresyon kontrolü olarak eklendi (S-1/S-2/S-5/S-6/S-7);
ikisi (çıpa bağlamı · rezerv satır affı) ADLANDIRILMIŞ SINIR olarak yukarıda durur.

DOKTRİN (turkce-kapilar / CLAUDE.md "KÖR KAPI YOK")
---------------------------------------------------
Bu araç bir KAPIDIR, dolayısıyla ÖNCE KENDİNİ KANITLAR. `--altin-kume` kipi
  · bilerek kapısız-ve-beyansız bırakılmış bir kararı BULMAK ZORUNDADIR (yanlış-negatif kontrolü)
  · temiz belgede SIFIR bulgu vermek ZORUNDADIR (yanlış-pozitif kontrolü)
Bu ikisinden biri tutmazsa araç `KULLANILAMAZ` der ve çıkış kodu 2 olur.
Aracın yeşili TEK BAŞINA kanıt değildir: aracı v5'i yazan oturum yazdı (K19-c),
bu yüzden kapı-5 ARACIN KENDİSİNİ de denetlemek zorundadır.

KULLANIM
--------
  python3 adr-kapi-taramasi.py <adr.md> [--kanonik-bolum "KANONİK SAYILAR"] [--json]
  python3 adr-kapi-taramasi.py --altin-kume            # aracın kendi kanıtı

ÇIKIŞ KODU: 0 = bulgu yok · 1 = bulgu var · 2 = araç kendini kanıtlayamadı/kullanım hatası
            3 = DOSYA OKUNAMADI (geçerli UTF-8 değil) — tarama HİÇ yapılmadı, 'bulgu yok' DEĞİLDİR

ORTAM: Python 3.8+. Bağımlılık YOK (stdlib). Windows/PowerShell'de de, bağlı Linux
VM'de de, bulut konteynerinde de aynı çıktıyı verir. `araclar/verify.ps1` derleme
zincirinindir; bu araç BELGE zincirinindir, o zincire dokunmaz.
"""

import argparse
import io
import json
import os
import re
import sys
import tempfile
import unicodedata

KARAR = re.compile(r"^\*\*(K\d+-[A-Z]\d+[a-z]?)\b")          # satır başında karar başlığı
JETON = re.compile(r"K\d+-[A-Z]\d+[a-z]?(?:\(\d+[a-z]?\))?")  # her yerde geçen atıf jetonu
ALT = re.compile(r"^(K\d+-[A-Z]\d+[a-z]?)(\(\d+[a-z]?\))$")


def _oku(yol):
    # SALDIRI-6 (farklı model, oturum 22): geçersiz UTF-8 baytı aracı çıplak traceback ile
    # çökertiyor ve çıkış kodu TESADÜFEN 1 oluyor ⇒ CI bunu "bulgu var" sanabilir.
    # Ayrı ve belirgin çıkış kodu (3) verilir.
    try:
        with io.open(yol, encoding="utf-8") as f:
            return f.read()
    except UnicodeDecodeError as e:
        print("DOSYA OKUNAMADI (geçerli UTF-8 değil): %s — %s" % (yol, e))
        print("⚠ TARAMA HİÇ YAPILMADI. Bu 'bulgu yok' DEĞİLDİR.")
        sys.exit(3)


# Görünmez / biçim karakterleri: metni okuyucuya aynı gösterip regex'i bölerler.
GORUNMEZ = "​‌‍⁠﻿­᠎"
_TR_KUCUK = {ord("I"): "ı", ord("İ"): "i"}


def _kucult(s):
    """Türkçe-duyarlı küçültme.

    SALDIRI-5 (farklı model): `"ÇIPA".lower()` Python'da `çipa` (noktalı i) verir, `çıpa`
    ile EŞLEŞMEZ ⇒ başlığı büyük yazan TEMİZ bir belge sahte K1/K6 seli üretiyordu.
    """
    return s.translate(_TR_KUCUK).lower()


def _normalize(metin):
    """NFKC + görünmez karakter temizliği. Kaç tane temizlendiğini de döndürür.

    SALDIRI-2 (farklı model): `1<U+200B>5 dk` okuyucuya `15 dk` görünür ama `\\d[\\d.,]*`
    deseni diziyi bölünmüş görür ⇒ kanonik sayı kopyası SESSİZCE kaçar.
    """
    n = sum(metin.count(c) for c in GORUNMEZ)
    for c in GORUNMEZ:
        metin = metin.replace(c, "")
    metin = metin.replace(" ", " ")
    return unicodedata.normalize("NFKC", metin), n


def _bolum_araligi(satirlar, bas_desen, bit_desen):
    """bas_desen ile eşleşen satırdan bit_desen ile eşleşen ilk satıra kadar (yarı açık)."""
    bas = bit = None
    for i, s in enumerate(satirlar):
        if bas is None and re.search(bas_desen, s):
            bas = i
            continue
        if bas is not None and re.search(bit_desen, s):
            bit = i
            break
    if bas is None:
        return None
    return (bas, bit if bit is not None else len(satirlar))


def _kok(jeton):
    m = ALT.match(jeton)
    return m.group(1) if m else jeton


def _tablolar(satirlar, bas, bit):
    """[bas, bit) aralığındaki GFM tablolarını döndürür: (baslik_satir_no, baslik_hucreleri, [(satir_no, hucreler)])

    Bir tablo ancak BAŞLIK + AYRAÇ satırıyla başlarsa tablodur (K3 zaten başlıksızları ihbar eder).
    """
    tablolar = []
    i = bas
    while i < bit:
        s = satirlar[i]
        if s.startswith("|") and i + 1 < bit and re.match(r"^\|[\s:|-]+\|\s*$", satirlar[i + 1]):
            basliklar = [_kucult(re.sub(r"[*`]", "", h).strip()) for h in s.split("|")]
            basliklar = [h for h in basliklar if h != ""]
            govde = []
            j = i + 2
            while j < bit and satirlar[j].startswith("|"):
                govde.append((j + 1, [h.strip() for h in satirlar[j].split("|")]))
                j += 1
            tablolar.append((i + 1, basliklar, govde))
            i = j
            continue
        i += 1
    return tablolar


def _son_dolu(hucreler):
    dolu = [h for h in hucreler if h.strip()]
    return dolu[-1] if dolu else ""


def _ks_maskele(s):
    """`[KS-30]` / `KS-30` atıflarını taramadan ÖNCE maskeler.

    B5-2: aksi hâlde `[KS-30]` atfının içindeki `30` sayısı kendi kopyası sanılır
    (yanlış-pozitif) ya da satır tümüyle muaf tutulur (yanlış-negatif, eski kusur).
    """
    return re.sub(r"\[?KS-\d+\]?", " ", s)


def tara(metin, kanonik_baslik=None):
    metin, _gorunmez = _normalize(metin)
    satirlar = metin.split("\n")
    bulgular = []
    if _gorunmez:
        bulgular.append(("K7", 0, "GÖRÜNMEZ KARAKTER: belgede %d adet sıfır-genişlikli/biçim karakteri bulundu ve "
                                  "taramadan önce temizlendi — okuyucuya görünmez, regex'i böler; kaynağı ELLE bulunmalı."
                         % _gorunmez))

    # --- bölümler -------------------------------------------------------
    mutant = _bolum_araligi(satirlar, r"^##\s*3\.\s", r"^###\s*3\.1")
    beyan = _bolum_araligi(satirlar, r"^###\s*3\.1", r"^###\s*3\.2|^##\s*4\.")
    if mutant is None:
        bulgular.append(("K0", 0, "§3 (mutant tablosu) bölümü BULUNAMADI — araç bu belgede koşamaz."))
        return bulgular, {}
    if beyan is None:
        bulgular.append(("K0", 0, "§3.1 (mutantsız beyanı) bölümü BULUNAMADI — tamlık iddiası ölçülemez."))
        beyan = (mutant[1], mutant[1])

    mutant_metin = "\n".join(satirlar[mutant[0]:mutant[1]])
    beyan_metin = "\n".join(satirlar[beyan[0]:beyan[1]])
    govde_disi = set(range(mutant[0], mutant[1])) | set(range(beyan[0], beyan[1]))

    # --- K1: karar ↔ kapı/beyan eşlemesi --------------------------------
    kararlar = {}          # id -> satır no (1-tabanlı)
    for i, s in enumerate(satirlar):
        m = KARAR.match(s)
        if m and m.group(1) not in kararlar:
            kararlar[m.group(1)] = i + 1

    # atıfla var olduğu görülen alt maddeler de birer karardır (K3-C6(5) gibi)
    alt_maddeler = {}
    for jt in JETON.findall(metin):
        if ALT.match(jt) and _kok(jt) in kararlar:
            alt_maddeler.setdefault(jt, kararlar[_kok(jt)])

    # B5-3: KAPILILIK YALNIZ ÇIPA SÜTUNUNDAN ÇÖZÜLÜR — §3'ün düz metninde/giriş
    # paragrafında/devir cümlesinde adı geçen bir karar KAPILI SAYILMAZ.
    kapili = set()
    capasiz_tablo = []
    for bas_no, basliklar, govde in _tablolar(satirlar, mutant[0], mutant[1]):
        if basliklar and "çıpa" in basliklar[-1]:
            for _sn, hucreler in govde:
                kapili |= set(JETON.findall(_son_dolu(hucreler)))
        else:
            capasiz_tablo.append((bas_no, basliklar[-1] if basliklar else "(başlıksız)", len(govde)))

    for bas_no, son_ad, n in capasiz_tablo:
        bulgular.append(("K6", bas_no,
                         "ÇIPA SÜTUNU YOK: satır %d'deki §3 tablosunun son sütunu '%s' ⇒ bu tablonun %d satırındaki "
                         "karar atıfları KAPI SAYILMAZ (kapılılık yalnız çıpa sütunundan çözülür)." % (bas_no, son_ad, n)))

    # BEYAN YALNIZ "kapısız kalan" TABLOSUNDAN ÇÖZÜLÜR.
    # (Kapı-5 D9 bulgusu: §3.1'de İKİ tablo var — `çıkarılan muafiyet | neden düştü | kapısı`
    #  tablosundaki kalemler ARTIK KAPILIDIR, kapısızlık BEYANI DEĞİLDİR. İkisini birlikte
    #  saymak hem sahte "beyanlı" üretir hem sahte ÇELİŞKİ ihbarı doğurur.)
    beyanli = set()
    beyan_tablo_bulundu = False
    for _bn, _bh, _bg in _tablolar(satirlar, beyan[0], beyan[1]):
        if _bh and "kapısız" in _bh[0]:
            beyan_tablo_bulundu = True
            for _sn, hucreler in _bg:
                dolu = [h for h in hucreler if h.strip()]
                if dolu:
                    beyanli |= set(JETON.findall(dolu[0]))
    if not beyan_tablo_bulundu and beyan[1] > beyan[0]:
        bulgular.append(("K6", beyan[0] + 1,
                         "§3.1'DE 'kapısız kalan' TABLOSU BULUNAMADI ⇒ kapısızlık beyanı ölçülemiyor; "
                         "K1 bu belgede yalnız çıpa sütununa dayanır (tamlık iddiası ZAYIFTIR)."))
    # bir alt madde kapılıysa kökü de kapılı sayılır; kökü kapılıysa alt maddesi SAYILMAZ
    kapili |= {_kok(j) for j in list(kapili)}
    beyanli |= {_kok(j) for j in list(beyanli)}

    for kid, satir in sorted(kararlar.items()):
        if kid not in kapili and kid not in beyanli:
            bulgular.append(("K1", satir, "KAPISIZ-VE-BEYANSIZ KARAR: %s — ne §3'ün ÇIPA SÜTUNUNDA ne §3.1'de geçiyor." % kid))
    for jt, satir in sorted(alt_maddeler.items()):
        if jt not in kapili and jt not in beyanli:
            bulgular.append(("K1", satir, "KAPISIZ-VE-BEYANSIZ ALT MADDE: %s — atıfla var olduğu görülüyor, kapısı/beyanı yok." % jt))

    # --- K6: aynı karar hem kapılı hem §3.1'de beyanlı ⇒ ÇELİŞKİ ------------
    # (Araç bunu ÇÖZMEZ, İHBAR EDER: ya kapı gerçek değildir ya beyan bayattır.)
    for kid in sorted(k for k in kararlar if k in kapili and k in beyanli):
        bulgular.append(("K6", kararlar[kid],
                         "ÇELİŞKİ: %s hem §3'ün çıpa sütununda (kapılı) hem §3.1'de (kapısız beyanlı) geçiyor — "
                         "ikisi aynı anda doğru olamaz; ya kapı süs ya beyan bayat." % kid))

    # --- K2: sarkan atıf (emekli etiket) --------------------------------
    for jt in sorted(set(JETON.findall(mutant_metin)) | set(JETON.findall(beyan_metin))):
        if _kok(jt) not in kararlar:
            bulgular.append(("K2", 0, "SARKAN ATIF: %s — §3/§3.1'de atıf var ama karar başlığı yok (emekli/yanlış etiket)." % jt))

    # --- K3: başlıksız markdown tablosu ---------------------------------
    onceki_bos = True
    for i, s in enumerate(satirlar):
        if s.startswith("|") and onceki_bos:
            ayrac = satirlar[i + 1] if i + 1 < len(satirlar) else ""
            if not re.match(r"^\|[\s:|-]+\|\s*$", ayrac):
                bulgular.append(("K3", i + 1, "BAŞLIKSIZ TABLO: satır %d bir tablo satırıyla başlıyor ama ayraç satırı yok ⇒ GFM'de RENDER OLMAZ." % (i + 1)))
        onceki_bos = (s.strip() == "")

    # --- K4: kanonik sayının gövdede kopyalanması ------------------------
    kanonik = {}
    _satir_sayaci = [0]
    _bos = [0]
    _atlanan = []
    _kopya = {}    # (satır, "sayı birim") -> {KS id}   GÜÇLÜ eşleşme (sayı+birim ya da birimsiz kalem)
    _zayif = {}    # "KS (sayı)" -> [satır]             ZAYIF eşleşme (çıplak sayı, birim uyuşmadı)
    _sinir = {}    # (satır, "sayı±1") -> {KS id}       SINIR DEĞER literali
    _literal = {}  # KS id -> [satır]                   `[KS-LITERAL:]` ile muaf tutulan kopya
    if kanonik_baslik:
        # BİTİŞ: yalnız AYNI seviyedeki bir sonraki `## ` başlığı. `### ` alt bölümler bölüme DÂHİLDİR.
        # (v5 yazımında bulundu: `### 1-K.1` bitiş sanılırsa tablo satırları HİÇ okunmaz ve araç
        #  sessizce 0 kanonik sayı görür = KÖR KAPI. Altın kümede bu vaka artık kontrol ediliyor.)
        kt = _bolum_araligi(satirlar, r"^#{1,3}\s.*" + re.escape(kanonik_baslik), r"^##\s")
        # BAŞLANGIÇ bir BAŞLIK satırı olmalı: gövdede başlığın ADI geçiyor diye oradan başlanırsa
        # bölüm boş okunur (v5 yazımında fiilen oldu: §0'daki bir cümle "KANONİK SAYILAR" içeriyordu).
        if kt is None:
            bulgular.append(("K4", 0, "KANONİK BÖLÜM YOK: '%s' başlığı bulunamadı ⇒ sayı tekrarı ölçülemedi." % kanonik_baslik))
        else:
            # SÜTUNLAR BAŞLIKTAN ÇÖZÜLÜR, İNDİSTEN VARSAYILMAZ.
            # (v5 yazımında fiilen oldu: kanonik tablo `| id | ad | değer | …` idi, araç
            #  "değer"i 2. sütun sanıp "ad" sütununu okudu ve her satırdan yanlış sayı
            #  çıkardı = SESSİZ KÖR KAPI. Altın kümede bu vaka artık kontrol ediliyor.)
            anahtar_i = deger_i = None
            for i in range(kt[0], kt[1]):
                if not satirlar[i].startswith("|"):
                    continue
                bas = [_kucult(re.sub(r"[*`]", "", h).strip()) for h in satirlar[i].split("|")]
                if "değer" in bas:
                    deger_i = bas.index("değer")
                    anahtar_i = bas.index("id") if "id" in bas else (bas.index("ad") if "ad" in bas else 1)
                    continue
                if deger_i is None or re.match(r"^[\s:|-]+$", satirlar[i]):
                    continue
                hucreler = [h.strip() for h in satirlar[i].split("|")]
                if len(hucreler) <= max(anahtar_i, deger_i):
                    continue
                anahtar = re.sub(r"[*`]", "", hucreler[anahtar_i]).strip()
                deger = re.sub(r"[*`]", "", hucreler[deger_i]).strip()
                # SALDIRI-7 (farklı model): `ad` hücresi BOŞ bırakılan satır eskiden ne sayılıyor
                # ne sözlüğe giriyordu ⇒ muhafız SİMETRİK olarak kör kalıyordu. Artık HER gövde
                # satırı sayılır; anahtarsız satır kapsam-dışı olarak ADIYLA raporlanır.
                _satir_sayaci[0] += 1
                if not anahtar:
                    _bos[0] += 1
                    _atlanan.append(("(satır %d)" % (i + 1), "ad/id hücresi BOŞ — kalem adlandırılmamış"))
                    continue
                # B5-1: DEĞERİNDE RAKAM OLMAYAN SATIR DA SÖZLÜĞE GİRER.
                # (Eski sürüm `re.search(r"\d", deger)` ile eliyordu ⇒ satır ne taranıyor
                #  ne "kapsam dışı" diye bildiriliyordu = SESSİZ DARALTMA. Kapı-5 B5-1.)
                if anahtar and deger:
                    kanonik[anahtar] = deger
            if deger_i is None:
                bulgular.append(("K4", kt[0] + 1, "KANONİK TABLONUN BAŞLIK SATIRINDA 'değer' SÜTUNU YOK ⇒ K4 KÖRDÜR."))
            if not kanonik:
                bulgular.append(("K4", kt[0] + 1, "KANONİK BÖLÜM BOŞ OKUNDU: '%s' başlığı bulundu ama tek bir sayı satırı bile çıkarılamadı ⇒ K4 kontrolü KÖRDÜR (tablo biçimi mi değişti?)." % kanonik_baslik))
            for anahtar, deger in kanonik.items():
                # TÜRETİLMİŞ değer (başka bir KS'ye atıf) taranmaz: "KS-2 ile aynı", "2 × KS-14" …
                if "KS-" in deger:
                    _atlanan.append((anahtar, "türetilmiş değer (başka KS'ye atıf)"))
                    continue
                # Sayı, bir ETİKETİN parçası olmamalı: `K18-b`, `KS-2`, `M49`, `SHA-256` …
                sayi = re.search(r"(?<![A-Za-z0-9-])\d[\d.,]*", deger)
                if not sayi:
                    _atlanan.append((anahtar, "sayısal literal yok"))
                    continue
                if len(sayi.group(0).replace(".", "").replace(",", "")) < 2:
                    # tek haneli sayılar metinde güvenilir biçimde ayırt edilemez (yanlış-pozitif seli)
                    _atlanan.append((anahtar, "tek haneli literal — metinde ayırt edilemez"))
                    continue
                # Gövdede de sayı bir ETİKETİN/atıfın parçası olmamalı: `K15-a`, `bloker #15`,
                # `M11`, `RFC 5321`, `v1.5` … Aksi hâlde araç yanlış-pozitif seli üretir.
                ham = sayi.group(0)
                # BİRİM ÇÖZÜMLEMESİ: "15 dk" → sayı 15, birim "dk". Birim varsa gövdedeki
                # eşleşme GÜÇLÜ (sayı+birim), yoksa ZAYIF (çıplak sayı) sayılır. İkisi de
                # RAPORLANIR — zayıf olan gruplanıp "ELLE DOĞRULA" etiketiyle verilir.
                # Gerekçe [ölçüldü]: `10` gibi çıplak sayılar belgede 9 farklı bağlamda geçiyor
                # (ör. satır 921 "47 karar + 10 alt madde") ⇒ tiersiz raporlama YANLIŞ-POZİTİF SELİ üretir
                # ve gerçek bulguyu gömer. Sessiz eleme YOK: zayıf sınıf ayrı başlıkta sayılır.
                bm = re.match(r"\s*" + re.escape(ham) + r"\s*(dk|dakika|sn|saniye|saat|gün|ms|bayt|byte|karakter|istek|deneme|bit|KiB|MiB)\b",
                              deger[sayi.start():], re.IGNORECASE)
                birim = bm.group(1) if bm else None
                desen = re.compile(r"(?<![\w.,#-])" + re.escape(ham) + r"(?![\w.,-])")
                guclu_desen = (re.compile(r"(?<![\w.,#-])" + re.escape(ham) + r"(?![\w.,-])[\s`*_]{0,4}" + re.escape(birim) + r"\b",
                                          re.IGNORECASE) if birim else None)
                # B5-4 ek: `[KS-n]±1` SINIR DEĞER literalleri (M23'ün "31.", M29'un "61 sn")
                # kanonik değer değişince ÖLÜ TUZAĞA döner. Ayrı mesajla raporlanır.
                sinir = []
                try:
                    _t = int(ham.replace(".", "").replace(",", ""))
                    if _t >= 10:
                        sinir = [(_t + 1, "+1"), (_t - 1, "-1")]
                except ValueError:
                    pass
                sinir_desen = [(re.compile(r"(?<![\w.,#-])" + str(v) + r"(?![\w.,-])"), et) for v, et in sinir]
                bulundu = 0
                for i, s in enumerate(satirlar):
                    if i >= kt[0] and i < kt[1]:
                        continue
                    # B5-4: mutant tablosu ve §3.1 ARTIK TARANIR — §1-K kuralı birebir
                    # "Gövde metni, MUTANT TABLOSU ve §3.1 … sayıyı KOPYALAMAZ" diyor.
                    # B5-2: `[KS-n]` atıfları maskelenir; muafiyet YALNIZ `[KS-LITERAL:`tir.
                    if ("KANONİK" in s) or ("§1-K" in s):
                        continue
                    if "[KS-LITERAL:" in s:
                        # SALDIRI-1 (farklı model): muafiyetin GEREKÇESİ hiç okunmuyordu ⇒ sessiz kaçış.
                        # Muafiyet KORUNUR (belge kuralı) ama artık ADIYLA raporlanır.
                        if desen.search(_ks_maskele(s)):
                            _literal.setdefault(anahtar, []).append(i + 1)
                        continue
                    sm = _ks_maskele(s)
                    if desen.search(sm):
                        if guclu_desen is not None and guclu_desen.search(sm):
                            _kopya.setdefault((i + 1, ham + " " + birim), set()).add(anahtar)
                        elif guclu_desen is None:
                            _kopya.setdefault((i + 1, ham), set()).add(anahtar)
                        else:
                            _zayif.setdefault(anahtar + " (" + ham + ")", []).append(i + 1)
                        bulundu += 1
                    else:
                        for sd, et in sinir_desen:
                            if i >= mutant[0] and i < beyan[1] and sd.search(sm):
                                _sinir.setdefault((i + 1, ham + et), set()).add(anahtar)
                                break

        # --- K4 bulgularının GRUPLANMIŞ raporu (aynı sayıyı paylaşan KS'ler tek satırda) ---
        for (satir, etiket), idler in sorted(_kopya.items()):
            bulgular.append(("K4", satir, "KANONİK SAYI KOPYALANMIŞ: %s (%s) gövdede yeniden yazılmış — atıf bekleniyordu."
                             % (" / ".join(sorted(idler)), etiket)))
        for (satir, etiket), idler in sorted(_sinir.items()):
            bulgular.append(("K4", satir, "SINIR DEĞER LİTERALİ: %s (%s) kill sinyaline yazılmış — kanonik değer "
                                          "değişirse bu mutant ÖLÜ TUZAĞA döner; atıf±1 biçiminde yazılmalı."
                             % (" / ".join(sorted(idler)), etiket)))
        if _literal:
            bulgular.append(("K4", 0, "K4 `[KS-LITERAL:]` MUAFİYETİYLE GEÇEN KOPYALAR [gerekçe MEKANİK OLARAK DOĞRULANMAZ — ELLE DOĞRULA]: " +
                             " · ".join("%s → satır %s" % (a, ",".join(str(x) for x in v)) for a, v in sorted(_literal.items()))))
        if _zayif:
            bulgular.append(("K4", 0, "K4 ZAYIF EŞLEŞMELER [çıplak sayı — birim uyuşmadı; SESSİZ ELEME YOK, ELLE DOĞRULA]: " +
                             " · ".join("%s → satır %s" % (a, ",".join(str(x) for x in v[:6]) + ("…" if len(v) > 6 else ""))
                                        for a, v in sorted(_zayif.items()))))

        # B5-1 MUHAFIZI: sayılan satır ile sınıflandırılan satır eşit DEĞİLSE araç kendini ihbar eder.
        if kanonik_baslik and _satir_sayaci[0] != len(kanonik) + _bos[0]:
            bulgular.append(("K4", 0,
                             "⚠ ARAÇ KENDİNİ İHBAR EDİYOR — SESSİZ DÜŞÜŞ: kanonik tabloda %d satır sayıldı ama %d'i "
                             "sınıflandırıldı; %d satır ne tarandı ne kapsam-dışı bildirildi. K4 BU BELGEDE KÖRDÜR."
                             % (_satir_sayaci[0], len(kanonik), _satir_sayaci[0] - len(kanonik))))

        if _atlanan:
            bulgular.append(("K4", 0, "K4 KAPSAM DIŞI BIRAKTIKLARI [sessiz daraltma yok — ELLE kontrol edilmeli]: " +
                         " · ".join("%s (%s)" % (a, n) for a, n in _atlanan)))

    # --- K5: mutant numara bütünlüğü ------------------------------------
    numaralar = sorted({int(n) for n in re.findall(r"\*\*M(\d+)[a-c]?\*\*", mutant_metin)})
    # belgede AÇIKÇA rezerv/VOID ilan edilmiş numaralar boşluk sayılmaz
    ilan_edilen = set()
    for s in satirlar:
        if re.search(r"rezerv|VOID|ayrılmış", s, re.IGNORECASE):
            ilan_edilen |= {int(n) for n in re.findall(r"\bM(\d+)\b", s)}
    if numaralar:
        eksik = [n for n in range(1, max(numaralar) + 1) if n not in numaralar and n not in ilan_edilen]
        if eksik:
            bulgular.append(("K5", 0, "MUTANT NUMARA BOŞLUĞU: %s — belgede rezerv/VOID diye AÇIKÇA yazılı DEĞİL." % ", ".join("M%d" % n for n in eksik)))

    ozet = {
        "karar": len(kararlar),
        "alt_madde": len(alt_maddeler),
        "kapili": len([k for k in kararlar if k in kapili]),
        "beyanli": len([k for k in kararlar if k in beyanli and k not in kapili]),
        "kanonik_satir": _satir_sayaci[0],
        "kanonik_taranan": _satir_sayaci[0] - len(_atlanan),
        "kanonik_atlanan": len(_atlanan),
        "kanonik_sayi": len(kanonik),   # DÜRÜSTLÜK: her kanonik SATIR sözlüğe girer; taranamayanlar
                                        # `kanonik_atlanan` altında GEREKÇESİYLE raporlanır (B5-1).
        "capasiz_tablo": len(capasiz_tablo),
        "mutant": len(numaralar),
    }
    return bulgular, ozet


# ---------------------------------------------------------------------------
# ALTIN KÜME — aracın kendi kanıtı (yanlış-negatif VE yanlış-pozitif kontrolü)
# ---------------------------------------------------------------------------

TEMIZ = """# ADR 9999 — altın küme (TEMİZ kontrol)

## 1-K. KANONİK SAYILAR

| ad | değer | sahibi |
|---|---|---|
| erişim token ömrü | 15 dk | K9-C1 |

## 2. Karar

**K9-A1 — Kapılı karar.** Gövde, ömür için §1-K'ya atıf yapar, sayıyı kopyalamaz.

**K9-B1 — Beyanlı karar.** Bilinçli olarak mutantsızdır.

**K9-C1 — Ömür kararı.** Değer §1-K'dadır.

## 3. Isıran kapılar

| # | mutasyon | kill sinyali | seviye | çıpa |
|---|---|---|---|---|
| **M1** | A kaldırılır | *"…"* FAIL | TS | K9-A1 |
| **M2** | Ömür sabitlenir | *"…"* FAIL | TS | K9-C1 |

### 3.1 — MUTANTSIZ OLDUĞU AÇIKÇA YAZILANLAR

| kapısız kalan | neden |
|---|---|
| **K9-B1** | Çerçevenin kendi doğrulaması; bilinçli. |

## 4. Gerekçe
Bitti.
"""

# Aynı belge, DÖRT kusur bilerek yerleştirilmiş:
#  (1) K9-D1 kararı eklendi — ne kapılı ne beyanlı   -> K1 bulmalı
#  (2) §3.1'de emekli K9-Z9 etiketine atıf           -> K2 bulmalı
#  (3) §3.1 tablosunun başlık/ayraç satırı silindi   -> K3 bulmalı
#  (4) "15 dk" gövdeye kopyalandı                    -> K4 bulmalı
KIRLI = """# ADR 9999 — altın küme (KİRLİ kontrol)

## 1-K. KANONİK SAYILAR

| ad | değer | sahibi |
|---|---|---|
| erişim token ömrü | 15 dk | K9-C1 |

## 2. Karar

**K9-A1 — Kapılı karar.** Gövde atıf yapar.

**K9-B1 — Beyanlı karar.** Bilinçli olarak mutantsızdır.

**K9-C1 — Ömür kararı.** Erişim token'ı 15 dk yaşar ve bu satır sayıyı KOPYALIYOR.

**K9-D1 — Kapısız ve beyansız karar.** Bu kalem hiçbir yerde ölçülmüyor.

## 3. Isıran kapılar

| # | mutasyon | kill sinyali | seviye | çıpa |
|---|---|---|---|---|
| **M1** | A kaldırılır | *"…"* FAIL | TS | K9-A1 |
| **M2** | Ömür sabitlenir | *"…"* FAIL | TS | K9-C1 |

### 3.1 — MUTANTSIZ OLDUĞU AÇIKÇA YAZILANLAR

| **K9-B1** | Çerçevenin kendi doğrulaması; bilinçli. |
| **K9-Z9** | Emekli etikete canlı atıf. |

## 4. Gerekçe
Bitti.
"""


ID_SUTUNLU = TEMIZ.replace(
    "| ad | değer | sahibi |\n|---|---|---|\n| erişim token ömrü | 15 dk | K9-C1 |",
    "| id | ad | değer | sahibi |\n|---|---|---|---|\n| KS-1 | erişim token ömrü | 15 dk | K9-C1 |")
ID_SUTUNLU_KIRLI = ID_SUTUNLU.replace(
    "**K9-C1 — Ömür kararı.** Değer §1-K'dadır.",
    "**K9-C1 — Ömür kararı.** Erişim token'ı 15 dk yaşar ve bu satır sayıyı KOPYALIYOR.")

ADI_GOVDEDE = TEMIZ.replace(
    "# ADR 9999 — altın küme (TEMİZ kontrol)",
    "# ADR 9999 — altın küme (TEMİZ kontrol)\n\n- Not: bu belgede **KANONİK SAYILAR** tablosu vardır.")

ALT_BOLUMLU = TEMIZ.replace(
    "## 1-K. KANONİK SAYILAR\n\n| ad |",
    "## 1-K. KANONİK SAYILAR\n\n### 1-K.1 — alt bölüm\n\n| ad |")

# --- KAPI-5'İN BULDUĞU DÖRT KÖR NOKTA İÇİN ALTIN KÜME VAKALARI (B5-1…B5-4) ---

# B5-1: değerinde HİÇ RAKAM olmayan kanonik satır. Eski araç bunu sözlüğe hiç almıyor,
#       dolayısıyla "kapsam dışı" raporuna da yazmıyordu = SESSİZ DARALTMA.
RAKAMSIZ_DEGER = ID_SUTUNLU.replace(
    "| KS-1 | erişim token ömrü | 15 dk | K9-C1 |",
    "| KS-1 | erişim token ömrü | 15 dk | K9-C1 |\n| KS-2 | eşzamanlılık izni | `Environment.ProcessorCount` | K9-C1 |")

# B5-2: AYNI SATIRDA hem `[KS-n]` atfı hem ham sayı. Eski araç `[KS-` gören her satırı
#       toptan muaf tuttuğu için bu ihlali YAPISAL OLARAK göremiyordu.
ATIF_VE_KOPYA = ID_SUTUNLU.replace(
    "**K9-C1 — Ömür kararı.** Değer §1-K'dadır.",
    "**K9-C1 — Ömür kararı.** Değer `[KS-1]`'dedir; ama bu satır 15 dk diye sayıyı da yazıyor.")

# B5-3: §3'ün DÜZ METNİNDE anılan, çıpa sütununda OLMAYAN karar. Eski araç bunu kapılı sayıyordu.
DUZ_METINDE_ANMA = TEMIZ.replace(
    "**K9-C1 — Ömür kararı.** Değer §1-K'dadır.",
    "**K9-C1 — Ömür kararı.** Değer §1-K'dadır.\n\n**K9-D1 — Düz metinde anılan karar.** Kapısı yoktur.").replace(
    "## 3. Isıran kapılar\n",
    "## 3. Isıran kapılar\n\nNot: **K9-D1** bu turda ele alınmadı, ADR 9998'e devredildi.\n")

# B5-3 (ikinci ayak): ÇIPA SÜTUNU OLMAYAN §3 tablosu — karar atıfları `seviye` hücresine sıkışmış.
CAPASIZ_TABLO = TEMIZ.replace(
    "### 3.1 — MUTANTSIZ",
    "| # | mutasyon | kill sinyali | seviye |\n|---|---|---|---|\n"
    "| **M3** | X kaldırılır | *\"…\"* FAIL | DART · K9-B1 |\n\n### 3.1 — MUTANTSIZ")

# D9: §3.1'in "çıkarılan muafiyet" tablosu KAPISIZLIK BEYANI DEĞİLDİR (o kalemler artık KAPILIDIR).
#     Eski araç §3.1'in TÜM metnini beyan sayıyordu ⇒ sahte "beyanlı" + sahte ÇELİŞKİ üretiyordu.
MUAFIYET_TABLOSU = TEMIZ.replace(
    "| kapısız kalan | neden |\n|---|---|\n| **K9-B1** | Çerçevenin kendi doğrulaması; bilinçli. |",
    "| çıkarılan muafiyet | neden düştü | kapısı |\n|---|---|---|\n| **K9-B1** | Artık kapılıdır. | **M9** |")

# B5-4: KANONİK SAYI MUTANT TABLOSUNA GÖMÜLÜ. Eski araç §3'ü ve §3.1'i hiç taramıyordu.
MUTANTA_GOMULU = TEMIZ.replace(
    '| **M2** | Ömür sabitlenir | *"…"* FAIL | TS | K9-C1 |',
    '| **M2** | Ömür sabitlenir | *"token 15 dk sonra 401 alır"* FAIL | TS | K9-C1 |')



# --- FARKLI MODEL SALDIRISININ (Sonnet, oturum 22) AÇTIĞI BEŞ VAKA ---
ZWSP_KACIS = TEMIZ.replace(
    "**K9-C1 — Ömür kararı.** Değer §1-K'dadır.",
    "**K9-C1 — Ömür kararı.** Erişim token'ı 1\u200b5 dk yaşar (görünmez karakterle bölünmüş kopya).")

BOS_ANAHTAR = ID_SUTUNLU.replace(
    "| KS-1 | erişim token ömrü | 15 dk | K9-C1 |",
    "| KS-1 | erişim token ömrü | 15 dk | K9-C1 |\n|  | adsız kalem | 42 gün | K9-C1 |")

BUYUK_BASLIK = TEMIZ.replace(
    "| # | mutasyon | kill sinyali | seviye | çıpa |",
    "| # | MUTASYON | KILL SİNYALİ | SEVİYE | ÇIPA |")

LITERAL_MUAF = TEMIZ.replace(
    "**K9-C1 — Ömür kararı.** Değer §1-K'dadır.",
    "**K9-C1 — Ömür kararı.** Erişim token'ı 15 dk yaşar.  <!-- [KS-LITERAL: gerekçe] -->")


def altin_kume():
    print("=" * 78)
    print("ALTIN KÜME — ARACIN KENDİ KANITI (kör kapı yok: araç önce kendini kanıtlar)")
    print("=" * 78)
    gecti = True

    # --- yanlış-POZİTİF kontrolü: temiz belge SIFIR bulgu vermeli
    b, o = tara(TEMIZ, kanonik_baslik="KANONİK SAYILAR")
    print("\n[1] TEMİZ KONTROL (yanlış-pozitif) — beklenen: 0 bulgu")
    print("    özet: %s" % o)
    if b:
        gecti = False
        print("    ❌ BAŞARISIZ — araç temiz belgede %d bulgu üretti:" % len(b))
        for k, s, m in b:
            print("       [%s] satır %s: %s" % (k, s, m))
    else:
        print("    ✅ GEÇTİ — temiz belgede bulgu yok (araç her şeye kırmızı demiyor).")

    # --- yanlış-NEGATİF kontrolü: dört kusurun DÖRDÜ de bulunmalı
    b, o = tara(KIRLI, kanonik_baslik="KANONİK SAYILAR")
    kodlar = {k for k, _, _ in b}
    print("\n[2] KİRLİ KONTROL (yanlış-negatif) — bilerek 4 kusur yerleştirildi")
    print("    özet: %s" % o)
    for k, s, m in b:
        print("       [%s] satır %s: %s" % (k, s, m))
    beklenen = {
        "K1": "kapısız-ve-beyansız karar (K9-D1)",
        "K2": "emekli etikete sarkan atıf (K9-Z9)",
        "K3": "başlık satırı olmayan tablo (§3.1)",
        "K4": "kanonik sayının gövdeye kopyalanması (15 dk)",
    }
    for kod, ad in sorted(beklenen.items()):
        if kod in kodlar:
            print("    ✅ %s bulundu — %s" % (kod, ad))
        else:
            gecti = False
            print("    ❌ %s BULUNAMADI — %s  ⇒ ARAÇ KÖRDÜR" % (kod, ad))

    # --- K1'in DOĞRU kalemi bulduğu (yanlış kalem değil)
    # NOT [onarım, oturum 22]: KİRLİ fikstürde §3.1 tablosunun BAŞLIK satırı bilerek silinmiştir
    # (kusur 3). Beyan artık YALNIZ "kapısız kalan" tablosundan okunduğu için, başlıksız tablo
    # ⇒ beyan OKUNAMAZ ⇒ K9-B1'in de K1 vermesi DOĞRU davranıştır. Ama araç bunu SESSİZCE
    # yapamaz: fazladan K1 ancak SEBEBİ de (K6) raporlanıyorsa kabul edilir.
    k1 = [m for k, _, m in b if k == "K1"]
    sebep = any(k == "K6" and "kapısız" in m and "BULUNAMADI" in m for k, _, m in b)
    fazla = [m for m in k1 if "K9-D1" not in m]
    if any("K9-D1" in m for m in k1) and (not fazla or sebep):
        print("    ✅ K1 isabetli — K9-D1 bulundu%s" % (
            "; fazladan K1 var ve SEBEBİ (§3.1 tablosu okunamıyor) K6 ile raporlanmış." if fazla else ", yanlış alarm yok."))
    else:
        gecti = False
        print("    ❌ K1 isabetsiz — K9-D1=%s, fazla=%s, sebep raporlandı=%s" % (
            any("K9-D1" in m for m in k1), fazla, sebep))

    # --- KÖR-KAPI kontrolü: kanonik tablo `###` alt bölümün ALTINDAYSA da okunmalı
    b3, o3 = tara(ALT_BOLUMLU, kanonik_baslik="KANONİK SAYILAR")
    print("\n[3] ALT BÖLÜMLÜ KANONİK TABLO (kör-kapı kontrolü) — beklenen: sayı OKUNUR, 0 bulgu")
    print("    özet: %s" % o3)
    if o3.get("kanonik_sayi", 0) >= 1 and not b3:
        print("    ✅ GEÇTİ — `###` alt bölüm K4'ü körleştirmiyor.")
    else:
        gecti = False
        print("    ❌ BAŞARISIZ — K4 alt bölümlü tabloyu okuyamadı ⇒ SESSİZ KÖR KAPI. bulgular: %s" % b3)

    # --- KÖR-KAPI kontrolü 2: başlığın ADI gövdede geçiyorsa bölüm yine de doğru bulunmalı
    b4, o4 = tara(ADI_GOVDEDE, kanonik_baslik="KANONİK SAYILAR")
    print("\n[4] BAŞLIK ADI GÖVDEDE DE GEÇİYOR (kör-kapı kontrolü) — beklenen: sayı OKUNUR, 0 bulgu")
    print("    özet: %s" % o4)
    if o4.get("kanonik_sayi", 0) >= 1 and not b4:
        print("    ✅ GEÇTİ — bölüm başlangıcı BAŞLIK satırına çıpalı, gövdedeki anmaya değil.")
    else:
        gecti = False
        print("    ❌ BAŞARISIZ — gövdedeki anma bölümü kaydırdı ⇒ SESSİZ KÖR KAPI. bulgular: %s" % b4)

    # --- KÖR-KAPI kontrolü 3: sütun düzeni `| id | ad | değer |` olduğunda da doğru okunmalı
    b5, o5 = tara(ID_SUTUNLU, kanonik_baslik="KANONİK SAYILAR")
    b6, o6 = tara(ID_SUTUNLU_KIRLI, kanonik_baslik="KANONİK SAYILAR")
    print("\n[5] `id` SÜTUNLU KANONİK TABLO (kör-kapı kontrolü)")
    print("    temiz özet: %s · kirli özet: %s" % (o5, o6))
    if o5.get("kanonik_sayi", 0) == 1 and not b5 and any(k == "K4" for k, _, _ in b6):
        print("    ✅ GEÇTİ — sütunlar BAŞLIKTAN çözülüyor; temizde 0 bulgu, kirlide K4 ısırıyor.")
    else:
        gecti = False
        print("    ❌ BAŞARISIZ — sütun düzeni K4'ü körleştiriyor. temiz=%s kirli=%s" % (b5, b6))

    # ===== KAPI-5'İN BULDUĞU DÖRT KÖR NOKTA (B5-1…B5-4) — REGRESYON KONTROLLERİ =====

    # --- [6] B5-1: rakamsız kanonik değer sessizce düşmemeli
    b6a, o6a = tara(RAKAMSIZ_DEGER, kanonik_baslik="KANONİK SAYILAR")
    kapsam = [m for k, _, m in b6a if "KAPSAM DIŞI" in m]
    muhafiz = [m for k, _, m in b6a if "SESSİZ DÜŞÜŞ" in m]
    print("\n[6] RAKAMSIZ KANONİK DEĞER (B5-1) — beklenen: satır SAYILIR ve KAPSAM DIŞI diye BİLDİRİLİR")
    print("    özet: %s" % o6a)
    tamlik = (o6a.get("kanonik_satir") == o6a.get("kanonik_taranan", 0) + o6a.get("kanonik_atlanan", 0))
    if tamlik and kapsam and "KS-2" in kapsam[0] and not muhafiz:
        print("    ✅ GEÇTİ — satır sayısı = taranan + atlanan; KS-2 kapsam-dışı raporunda görünüyor.")
    else:
        gecti = False
        print("    ❌ BAŞARISIZ — SESSİZ DARALTMA. tamlık=%s kapsam=%s muhafız=%s" % (tamlik, kapsam, muhafiz))

    # --- [7] B5-2: aynı satırda hem `[KS-n]` atfı hem ham sayı yakalanmalı
    b7, o7 = tara(ATIF_VE_KOPYA, kanonik_baslik="KANONİK SAYILAR")
    print("\n[7] AYNI SATIRDA HEM ATIF HEM KOPYA (B5-2) — beklenen: K4 ısırır")
    if any(k == "K4" and "KOPYALANMIŞ" in m for k, _, m in b7):
        print("    ✅ GEÇTİ — `[KS-n]` atfı satırı K4'ten muaf tutmuyor (jeton maskeleniyor).")
    else:
        gecti = False
        print("    ❌ BAŞARISIZ — `[KS-` içeren satır hâlâ toptan muaf ⇒ KÖR. bulgular: %s" % b7)

    # --- [8] B5-3: §3 düz metninde anılan karar KAPILI SAYILMAMALI
    b8, o8 = tara(DUZ_METINDE_ANMA, kanonik_baslik="KANONİK SAYILAR")
    print("\n[8] §3 DÜZ METNİNDE ANILAN KAPISIZ KARAR (B5-3) — beklenen: K1 ısırır (K9-D1)")
    if any(k == "K1" and "K9-D1" in m for k, _, m in b8):
        print("    ✅ GEÇTİ — kapılılık YALNIZ çıpa sütunundan çözülüyor, düz metinden değil.")
    else:
        gecti = False
        print("    ❌ BAŞARISIZ — düz metindeki anma kapı sayılıyor ⇒ 'kapılı' sayımı ölçüm değil. bulgular: %s" % b8)

    # --- [9] B5-3 ikinci ayak: çıpa sütunu olmayan §3 tablosu İHBAR EDİLMELİ
    b9, o9 = tara(CAPASIZ_TABLO, kanonik_baslik="KANONİK SAYILAR")
    print("\n[9] ÇIPA SÜTUNU OLMAYAN §3 TABLOSU (B5-3) — beklenen: K6 ısırır")
    if any(k == "K6" and "ÇIPA SÜTUNU YOK" in m for k, _, m in b9) and o9.get("capasiz_tablo", 0) == 1:
        print("    ✅ GEÇTİ — çıpa sütunu olmayan tablonun atıfları kapı sayılmıyor ve ihbar ediliyor.")
    else:
        gecti = False
        print("    ❌ BAŞARISIZ — `seviye` hücresine sıkışmış atıf kapı sanılıyor. bulgular: %s özet: %s" % (b9, o9))

    # --- [10] B5-4: mutant tablosuna gömülü kanonik kopya yakalanmalı
    b10, o10 = tara(MUTANTA_GOMULU, kanonik_baslik="KANONİK SAYILAR")
    print("\n[10] MUTANT TABLOSUNA GÖMÜLÜ KANONİK KOPYA (B5-4) — beklenen: K4 ısırır")
    if any(k == "K4" and "KOPYALANMIŞ" in m for k, _, m in b10):
        print("    ✅ GEÇTİ — §1-K'nın bağladığı iki bölge (§3 ve §3.1) artık taranıyor.")
    else:
        gecti = False
        print("    ❌ BAŞARISIZ — mutant tablosu K4'ten muaf ⇒ B-1 sınıfı kusur görünmez. bulgular: %s" % b10)

    # --- [12] §3.1'in "çıkarılan muafiyet" tablosu BEYAN SAYILMAMALI (kapı-5 D9)
    b12, o12 = tara(MUAFIYET_TABLOSU, kanonik_baslik="KANONİK SAYILAR")
    print("\n[12] ÇIKARILAN-MUAFİYET TABLOSU BEYAN DEĞİLDİR (D9) — beklenen: K1 ısırır (K9-B1)")
    print("    özet: %s" % o12)
    if any(k == "K1" and "K9-B1" in m for k, _, m in b12) and o12.get("beyanli") == 0:
        print("    ✅ GEÇTİ — 'artık kapılıdır' kalemi kapısızlık beyanı sayılmıyor.")
    else:
        gecti = False
        print("    ❌ BAŞARISIZ — muafiyet tablosu beyan sayılıyor ⇒ sahte 'beyanlı' + sahte ÇELİŞKİ. bulgular: %s" % b12)

    # --- [11] RAPORLAYICI SESSİZ DARALTMA YAPMAMALI ---------------------------
    # (Onarım sırasında fiilen yaşandı: `K6` üretiliyordu ama sabit kod listesi yüzünden
    #  yazdırılmıyordu. Bu kontrol, ÜRETİLEN her bulgu kodunun RAPORA girdiğini ölçer.)
    import io as _io
    import contextlib as _ctx
    _b11, _o11 = tara(CAPASIZ_TABLO, kanonik_baslik="KANONİK SAYILAR")
    _kodlar = {k for k, _, _ in _b11}
    _tampon = _io.StringIO()
    with _ctx.redirect_stdout(_tampon):
        for kod in sorted({k for k, _, _ in _b11}):
            grup = [(s, m) for k, s, m in _b11 if k == kod]
            if grup:
                print("### %s — %d bulgu" % (kod, len(grup)))
    _basilan = {k for k in _kodlar if ("### %s " % k) in _tampon.getvalue()}
    print("\n[11] RAPORLAYICI TAMLIĞI — beklenen: üretilen HER bulgu kodu rapora girer")
    print("    üretilen kodlar: %s · basılan: %s" % (sorted(_kodlar), sorted(_basilan)))
    if _kodlar and _kodlar == _basilan:
        print("    ✅ GEÇTİ — rapor kodları sabit listeden değil, üretilen bulgulardan türetiliyor.")
    else:
        gecti = False
        print("    ❌ BAŞARISIZ — üretilen bulgu koda rağmen basılmıyor ⇒ RAPORLAYICIDA SESSİZ DARALTMA.")


    # ===== FARKLI MODEL SALDIRISI (Sonnet) — BEŞ YENİ REGRESYON KONTROLÜ =====

    b13, o13 = tara(ZWSP_KACIS, kanonik_baslik="KANONİK SAYILAR")
    print("\n[13] GÖRÜNMEZ KARAKTERLE BÖLÜNMÜŞ SAYI (Sonnet SALDIRI-2) — beklenen: K4 ısırır + K7 ihbar")
    if any(k == "K4" and "KOPYALANMIŞ" in m for k, _, m in b13) and any(k == "K7" for k, _, m in b13):
        print("    ✅ GEÇTİ — NFKC + görünmez karakter temizliği kaçışı kapatıyor ve kaynağı ihbar ediyor.")
    else:
        gecti = False
        print("    ❌ BAŞARISIZ — ZWSP ile bölünmüş kopya sessizce kaçıyor. bulgular: %s" % b13)

    b14, o14 = tara(BOS_ANAHTAR, kanonik_baslik="KANONİK SAYILAR")
    print("\n[14] ANAHTARI BOŞ KANONİK SATIR (Sonnet SALDIRI-7) — beklenen: sayılır ve kapsam-dışı bildirilir")
    print("    özet: %s" % o14)
    tam = (o14.get("kanonik_satir") == o14.get("kanonik_taranan", 0) + o14.get("kanonik_atlanan", 0))
    if tam and any("hücresi BOŞ" in m for _, _, m in b14):
        print("    ✅ GEÇTİ — anahtarsız satır artık SAYILIYOR ve adıyla raporlanıyor (muhafız simetrik körlükten kurtuldu).")
    else:
        gecti = False
        print("    ❌ BAŞARISIZ — anahtarsız satır hem sayaçtan hem sözlükten düşüyor ⇒ muhafız KÖR. bulgular: %s" % b14)

    b15, o15 = tara(BUYUK_BASLIK, kanonik_baslik="KANONİK SAYILAR")
    print("\n[15] BÜYÜK HARFLİ TÜRKÇE BAŞLIK 'ÇIPA' (Sonnet SALDIRI-5) — beklenen: 0 bulgu")
    if not b15 and o15.get("capasiz_tablo", 0) == 0:
        print("    ✅ GEÇTİ — Türkçe-duyarlı küçültme ('I'→'ı') sahte K1/K6 selini önlüyor.")
    else:
        gecti = False
        print("    ❌ BAŞARISIZ — 'ÇIPA'.lower() = 'çipa' ⇒ temiz belgede YANLIŞ-POZİTİF. bulgular: %s" % b15)

    b16, o16 = tara(LITERAL_MUAF, kanonik_baslik="KANONİK SAYILAR")
    print("\n[16] `[KS-LITERAL:]` MUAFİYETİ (Sonnet SALDIRI-1) — beklenen: muafiyet KORUNUR ama RAPORLANIR")
    if any("KS-LITERAL" in m and "ELLE DOĞRULA" in m for _, _, m in b16) and not any("KOPYALANMIŞ" in m for _, _, m in b16):
        print("    ✅ GEÇTİ — gerekçe mekanik doğrulanamıyor ama muafiyet artık SESSİZ DEĞİL.")
    else:
        gecti = False
        print("    ❌ BAŞARISIZ — `[KS-LITERAL:]` hâlâ sessiz kaçış. bulgular: %s" % b16)

    print("\n" + "=" * 78)
    if gecti:
        print("HÜKÜM: ✅ ARAÇ KULLANILABİLİR — yanlış-pozitif, yanlış-negatif ve YEDİ kör-kapı")
        print("        kontrolünü geçti (üçü v5 yazımından, DÖRDÜ kapı-5'in B5-1…B5-4 bulgularından).")
        print("UYARI:  Aracı v5'i yazan oturum yazdı, ONARAN oturum ise kapı-5'i koşan oturumdur (K26-a).")
        print("        Aracın yeşili TEK BAŞINA kanıt DEĞİLDİR; KAPI-6 ARACIN KENDİSİNİ de denetlemelidir.")
    else:
        print("HÜKÜM: ❌ ARAÇ KULLANILAMAZ — kendini kanıtlayamadı. Bulgularına GÜVENİLMEZ.")
    print("=" * 78)
    return 0 if gecti else 2


def main():
    ap = argparse.ArgumentParser(description="ADR kapı/tamlık ölçüm aracı")
    ap.add_argument("adr", nargs="?", help="ADR markdown dosyası")
    ap.add_argument("--kanonik-bolum", default="KANONİK SAYILAR", help="kanonik sayı tablosunun başlığı")
    ap.add_argument("--altin-kume", action="store_true", help="aracın kendi kanıtını koş")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()

    if a.altin_kume:
        return altin_kume()
    if not a.adr:
        ap.print_help()
        return 2
    if not os.path.exists(a.adr):
        print("DOSYA YOK: %s" % a.adr)
        return 2

    bulgular, ozet = tara(_oku(a.adr), kanonik_baslik=a.kanonik_bolum)
    if a.json:
        print(json.dumps({"ozet": ozet, "bulgular": [{"kod": k, "satir": s, "mesaj": m} for k, s, m in bulgular]},
                         ensure_ascii=False, indent=2))
    else:
        print("DOSYA: %s" % a.adr)
        print("ÖZET : %s" % ozet)
        print("-" * 78)
        if not bulgular:
            print("✅ BULGU YOK — her karar ya kapılı ya §3.1'de beyanlı; tablo/sayı/numara kontrolleri temiz.")
        else:
            # KODLAR SABİT LİSTEDEN DEĞİL, ÜRETİLEN BULGULARDAN TÜRETİLİR.
            # (Onarım sırasında fiilen yaşandı: `K6` eklendi ama sabit liste güncellenmedi ⇒
            #  bulgular üretiliyor ama YAZDIRILMIYORDU = raporlayıcıda SESSİZ DARALTMA.)
            for kod in sorted({k for k, _, _ in bulgular}):
                grup = [(s, m) for k, s, m in bulgular if k == kod]
                if grup:
                    print("\n### %s — %d bulgu" % (kod, len(grup)))
                    for s, m in grup:
                        print("  satır %-5s %s" % (s, m))
            print("\nTOPLAM: %d bulgu" % len(bulgular))
    return 1 if bulgular else 0


if __name__ == "__main__":
    sys.exit(main())

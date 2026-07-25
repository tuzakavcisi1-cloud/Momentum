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

Ayrıca dört yardımcı ölçüm koşar:
  K2  sarkan atıf     — tabloda/§3.1'de atıf var ama karar başlığı yok (emekli etiket)
  K3  tablo bütünlüğü — başlık satırı olmayan markdown tablosu (GFM'de render olmaz)
  K4  kanonik sayı    — kanonik tablodaki bir sayı gövdede KOPYALANMIŞ mı (atıf yerine).
                        Bilinçli literaller `[KS-LITERAL: gerekçe]` ile işaretlenir (birebir
                        alıntı · ölçüm kaydı · geri çekilmiş iddia). Sessiz muafiyet yoktur.
  K5  mutant numarası — kayıp/çift numara

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

KARAR = re.compile(r"^\*\*(K\d+-[A-Z]\d+[a-z]?)\b")          # satır başında karar başlığı
JETON = re.compile(r"K\d+-[A-Z]\d+[a-z]?(?:\(\d+[a-z]?\))?")  # her yerde geçen atıf jetonu
ALT = re.compile(r"^(K\d+-[A-Z]\d+[a-z]?)(\(\d+[a-z]?\))$")


def _oku(yol):
    with io.open(yol, encoding="utf-8") as f:
        return f.read()


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


def tara(metin, kanonik_baslik=None):
    satirlar = metin.split("\n")
    bulgular = []

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

    kapili = set(JETON.findall(mutant_metin))
    beyanli = set(JETON.findall(beyan_metin))
    # bir alt madde kapılıysa kökü de kapılı sayılır; kökü kapılıysa alt maddesi SAYILMAZ
    kapili |= {_kok(j) for j in list(kapili)}
    beyanli |= {_kok(j) for j in list(beyanli)}

    for kid, satir in sorted(kararlar.items()):
        if kid not in kapili and kid not in beyanli:
            bulgular.append(("K1", satir, "KAPISIZ-VE-BEYANSIZ KARAR: %s — ne §3 mutant tablosunda ne §3.1'de geçiyor." % kid))
    for jt, satir in sorted(alt_maddeler.items()):
        if jt not in kapili and jt not in beyanli:
            bulgular.append(("K1", satir, "KAPISIZ-VE-BEYANSIZ ALT MADDE: %s — atıfla var olduğu görülüyor, kapısı/beyanı yok." % jt))

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
    _atlanan = []
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
                bas = [re.sub(r"[*`]", "", h).strip().lower() for h in satirlar[i].split("|")]
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
                if anahtar:
                    _satir_sayaci[0] += 1
                if anahtar and deger and re.search(r"\d", deger):
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
                desen = re.compile(r"(?<![\w.,#-])" + re.escape(sayi.group(0)) + r"(?![\w.,-])")
                bulundu = 0
                for i, s in enumerate(satirlar):
                    if i >= kt[0] and i < kt[1]:
                        continue
                    if i in govde_disi:          # mutant tablosu ve §3.1 sayı taşıyabilir (kill sinyali)
                        continue
                    # `[KS-LITERAL: …]` işaretli satır BİLİNÇLİ literaldir (birebir alıntı, ölçüm
                    # kaydı, geri çekilmiş iddia). Gerekçesi satırda yazılıdır; sessiz muafiyet YOK.
                    if desen.search(s) and ("KANONİK" not in s) and ("§1-K" not in s) \
                            and ("[KS-" not in s) and ("[KS-LITERAL:" not in s):
                        bulgular.append(("K4", i + 1, "KANONİK SAYI KOPYALANMIŞ: '%s' (%s) gövdede yeniden yazılmış — atıf bekleniyordu." % (anahtar, sayi.group(0))))
                        bulundu += 1
                        if bulundu >= 8:
                            bulgular.append(("K4", 0, "… '%s' için 8'den fazla kopya var; listelenmedi." % anahtar))
                            break

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
        "kanonik_taranan": len(kanonik) - len(_atlanan),
        "kanonik_atlanan": len(_atlanan),
        "kanonik_sayi": len(kanonik),   # DÜRÜSTLÜK: yalnız SAYISAL LİTERAL taşıyan satırlar taranır;
                                        # "KS-2 ile aynı" / TimeSpan.Zero gibi satırlar K4 kapsamı DIŞINDADIR.
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
    k1 = [m for k, _, m in b if k == "K1"]
    if len(k1) == 1 and "K9-D1" in k1[0]:
        print("    ✅ K1 tam isabetli — yalnız K9-D1, yanlış alarm yok.")
    else:
        gecti = False
        print("    ❌ K1 isabetsiz — beklenen yalnız K9-D1, gelen: %s" % k1)

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

    print("\n" + "=" * 78)
    if gecti:
        print("HÜKÜM: ✅ ARAÇ KULLANILABİLİR — hem yanlış-pozitif hem yanlış-negatif kontrolünü geçti.")
        print("UYARI:  Aracı, v5'i yazan oturum yazdı (K19-c). Aracın yeşili TEK BAŞINA kanıt")
        print("        DEĞİLDİR; kapı-5 ARACIN KENDİSİNİ de denetlemek zorundadır.")
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
            for kod in ("K0", "K1", "K2", "K3", "K4", "K5"):
                grup = [(s, m) for k, s, m in bulgular if k == kod]
                if grup:
                    print("\n### %s — %d bulgu" % (kod, len(grup)))
                    for s, m in grup:
                        print("  satır %-5s %s" % (s, m))
            print("\nTOPLAM: %d bulgu" % len(bulgular))
    return 1 if bulgular else 0


if __name__ == "__main__":
    sys.exit(main())

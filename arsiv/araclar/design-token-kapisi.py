#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
design-token-kapisi.py  --  Momentum DESIGN.md <-> Flutter kodu MEKANIK KAPISI

NEDEN VAR (K42-b + K44-a):
  "Tam tasarim sistemi" karari, kod uretmeyen bir belgenin buyumesi riskini dogurur
  (radar R2b/R4). Bu arac o riski YAPISAL olarak kapatir: DESIGN.md'nin MUST kalemleri
  kodda FIILEN kullanilmak ZORUNDADIR ve kodda tokensiz ham tasarim literali OLAMAZ.
  Belge boylece prozadan cikar, KOSULABILIR olur.

TASARIM DERSLERI (bu projede olculmus, tekrar edilmiyor):
  1) Makine-okunur veri PROZA TABLOSUNA yazilmaz (K38-b). Tokenlar DESIGN.md icindeki
     tek bir ```tokens fenced blogunda yasar; cevresindeki metin insan icindir.
  2) Cikti SAF ASCII'dir. ADR araci Windows cp1254 stdout'unda emoji yuzunden cokuyordu
     ve EXIT=1 veriyordu (yanlislikla "bulgu var" diye okunabiliyordu). Burada emoji YOK.
  3) Arac ONCE kendini kanitlar: --altin-kume, temizde SUSAR, mutasyonda ISIRIR.
     Altin kume gecmeden normal tarama HUKUM VERMEZ (kor kapi yok).

KONTROLLER:
  D1  MUST token kodda hic kullanilmamis, YA DA yalniz lib/design/ icinde
      kullaniliyor (adiyla MUAF olanlar haric)      -> KUSUR  [K57: sikilastirildi]
  D2  Kodda ham tasarim literali (token kacagi)     -> KUSUR
  D3  MUST token'in Dart sembolu token dosyasinda tanimli degil -> KUSUR
  D4  Muafiyet isareti gerekcesiz                   -> KUSUR
  D5  tokens.dart/tema.dart DISINDA Theme.of( ile renk/tipografi erisimi -> KUSUR  [K57]
  D6  lib/ altinda package:flutter/cupertino.dart importu -> KUSUR  [K57]

MUAFIYET:
  D2/D4: Ayni satirda ya da BIR ONCEKI satirda:  // [DESIGN-LITERAL: gerekce]
         Gerekcesiz "// [DESIGN-LITERAL]" KABUL EDILMEZ (D4).
  D1:    renk.yuzey.ikincil, renk.metin, hareket.hizli, olcu.odak.kalinlik --
         DESIGN.md'nin sekiz bilesenine atanmamis (BD-7), ADIYLA muaf.
  D5:    tokens.dart ve tema.dart (lib/design/) -- muafiyet YAPISALDIR, isaretle degil.

CIKIS KODLARI:
  0 = temiz | 1 = kusur var | 2 = kullanim/girdi hatasi | 3 = bozuk kodlama (UTF-8 degil)

KULLANIM:
  python araclar/design-token-kapisi.py --altin-kume
  python araclar/design-token-kapisi.py <proje-kok>
       [--design DESIGN.md] [--kod src/client] [--token-dosyasi lib/design/tokens.dart]
"""

import argparse
import os
import re
import sys
import tempfile
import shutil

SURUM = "0.2.0"

# --- cp1254 kalkani: cikti daima UTF-8, icerik daima ASCII ---------------------
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

VARSAYILAN_DESIGN = "DESIGN.md"
VARSAYILAN_KOD = os.path.join("src", "client")
VARSAYILAN_TOKEN_DOSYASI = os.path.join("lib", "design", "tokens.dart")

BLOK_BAS = re.compile(r"^\s*```tokens\s*$")
BLOK_SON = re.compile(r"^\s*```\s*$")
SEVIYE = re.compile(r"^\s*#\s*seviye\s*:\s*(MUST|NICE)\s*$", re.I)
YORUM = re.compile(r"^\s*#")
TOKEN_SATIRI = re.compile(
    r"^\s*(?P<ad>[A-Za-z0-9_.\-]+)\s*=\s*(?P<deger>[^->]+?)\s*->\s*(?P<sembol>[A-Za-z0-9_.]+)\s*$"
)

MUAFIYET = re.compile(r"//\s*\[DESIGN-LITERAL(?P<gerekce>:[^\]]*)?\]")

# D2 -- ham tasarim literalleri. Her biri (ad, desen).
HAM_LITERAL = [
    ("renk-hex", re.compile(r"Color\s*\(\s*0x[0-9a-fA-F]{6,8}\s*\)")),
    ("renk-fromARGB", re.compile(r"Color\.fromARGB\s*\(")),
    ("fontSize", re.compile(r"fontSize\s*:\s*\d")),
    ("EdgeInsets", re.compile(r"EdgeInsets\.\w+\s*\(\s*[\d.]")),
    ("BorderRadius", re.compile(r"BorderRadius\.circular\s*\(\s*[\d.]")),
    ("SizedBox", re.compile(r"SizedBox\s*\(\s*(width|height)\s*:\s*[\d.]")),
    ("Duration", re.compile(r"Duration\s*\(\s*milliseconds\s*:\s*\d")),
]

# --- K57/T8: D1 sikilastirmasi + D5 + D6 (GOREV-slice-3b SS5 G4) ------------

# DESIGN.md'nin sekiz gorsel bilesenine ATANMAMIS dort MUST token (BD-7);
# mesru yerleri tema.dart'tir ve "lib/design/ disinda kullanim" sartindan
# ADIYLA muaftir. Bu liste spec'te KAPALIDIR -- yeni ad eklemek spec degisikligi
# ister (K57 kilidi).
MUAF_D1_ADLARI = {"renk.yuzey.ikincil", "renk.metin", "hareket.hizli", "olcu.odak.kalinlik"}

# D5/D6: tokens.dart ile AYNI dizinde (lib/design/) yasayan tema.dart, tokens.dart
# ile birlikte Theme.of( erisiminden muaftir (D5 imza sozlesmesi, T3).
TEMA_DOSYASI_ADI = "tema.dart"
D5_DESEN = re.compile(r"Theme\.of\s*\(")
D6_DESEN = re.compile(r"""import\s+['"]package:flutter/cupertino\.dart['"]""")


# ============================== OKUMA ========================================

def _oku(yol):
    """UTF-8 zorunlu. Bozuk kodlama BULGU DEGIL, ORTAM HATASIDIR -> exit 3."""
    with open(yol, "rb") as f:
        ham = f.read()
    try:
        return ham.decode("utf-8")
    except UnicodeDecodeError as e:
        print("HATA: %s UTF-8 degil (%s). Bu bir BULGU DEGIL, kodlama hatasidir." % (yol, e))
        sys.exit(3)


def tokenlari_ayikla(design_yolu):
    """DESIGN.md icindeki TEK ```tokens blogunu ayristirir.

    Donen: (tokenlar, hatalar)
      tokenlar: [{ad, deger, sembol, seviye, satir}]
    Prozadaki hicbir sey okunmaz -- K38-b'nin dersi.
    """
    hatalar = []
    if not os.path.exists(design_yolu):
        return [], hatalar
    satirlar = _oku(design_yolu).split("\n")
    icinde = False
    blok_sayisi = 0
    seviye = None
    tokenlar = []
    for i, s in enumerate(satirlar, 1):
        if not icinde and BLOK_BAS.match(s):
            icinde = True
            blok_sayisi += 1
            seviye = None
            continue
        if icinde and BLOK_SON.match(s):
            icinde = False
            continue
        if not icinde:
            continue
        if not s.strip():
            continue
        m = SEVIYE.match(s)
        if m:
            seviye = m.group(1).upper()
            continue
        if YORUM.match(s):
            continue
        t = TOKEN_SATIRI.match(s)
        if not t:
            hatalar.append((design_yolu, i, "BICIM", "tokens blogunda ayristirilamayan satir: %r" % s.strip()))
            continue
        if seviye is None:
            hatalar.append((design_yolu, i, "SEVIYESIZ",
                            "token '%s' bir '# seviye: MUST|NICE' basligindan ONCE geliyor" % t.group("ad")))
            continue
        tokenlar.append({
            "ad": t.group("ad"),
            "deger": t.group("deger").strip(),
            "sembol": t.group("sembol"),
            "seviye": seviye,
            "satir": i,
        })
    if blok_sayisi > 1:
        hatalar.append((design_yolu, 0, "COKLU-BLOK",
                        "%d adet ```tokens blogu var; TEK kaynak olmali" % blok_sayisi))
    return tokenlar, hatalar


def dart_dosyalari(kok):
    if not os.path.isdir(kok):
        return []
    bulunan = []
    for dp, dn, fn in os.walk(kok):
        dn[:] = [d for d in dn if d not in (".dart_tool", "build", ".git", "ios", "macos", "windows", "linux")]
        for f in fn:
            if f.endswith(".dart") and not f.endswith(".g.dart") and not f.endswith(".freezed.dart"):
                bulunan.append(os.path.join(dp, f))
    return sorted(bulunan)


def yorum_disi(satir):
    """Satirin kod kismini dondurur; // sonrasi ATILIR.
    Blok yorumu (/* */) tek satirlik halde temizlenir. Bu bir tam ayristirici DEGILDIR
    ve bu SINIR bilerek beyan edilmistir (cok satirli /* */ icindeki literal kacabilir).
    """
    s = re.sub(r"/\*.*?\*/", "", satir)
    k = s.find("//")
    return s if k < 0 else s[:k]


# ============================== KONTROLLER ===================================

def tara(kok, design_yolu, kod_kok, token_dosyasi):
    """Butun kontrolleri kosar. Donen: (bulgular, ozet)
    bulgu = (kod, dosya, satir, mesaj)
    """
    bulgular = []
    tokenlar, bicim_hatalari = tokenlari_ayikla(design_yolu)
    for dosya, satir, kod, mesaj in bicim_hatalari:
        bulgular.append(("D0", os.path.relpath(dosya, kok), satir, mesaj))

    dosyalar = dart_dosyalari(kod_kok)

    # --- BOS GIRDI: token yok VE kod yok -> SUS (K44-a'nin altin kume vakasi) ---
    if not tokenlar and not dosyalar:
        return bulgular, {
            "token": 0, "must": 0, "nice": 0, "dart_dosya": 0,
            "durum": "BOS-GIRDI",
        }

    # --- BELGE VAR, KOD YOK -> D1/D3 ERTELENIR (kusur DEGIL, olculemez) ---
    # Gerekce: kod dogmadan once D1/D3'u kusur saymak, her MUST token icin bir
    # YANLIS-POZITIF taban cizgisi uretir; surekli kirmizi yanan kapi gormezden
    # gelinir (ADR aracinin ogrenilmis dersi). D0 (bicim) YINE ISIRIR -- erteleme
    # kapiyi KORLESTIRMEZ ve bu altin kumede mutantla kanitlanir.
    if tokenlar and not dosyalar:
        must_s = len([t for t in tokenlar if t["seviye"] == "MUST"])
        nice_s = len(tokenlar) - must_s
        return bulgular, {
            "token": len(tokenlar), "must": must_s, "nice": nice_s,
            "dart_dosya": 0, "durum": "BELGE-VAR-KOD-YOK", "ertelenen": must_s,
        }

    # token dosyasinin govdesi (D3 icin) -- kullanim taramasindan HARIC tutulur
    token_dosyasi_tam = os.path.join(kod_kok, token_dosyasi) if not os.path.isabs(token_dosyasi) else token_dosyasi
    token_govdesi = _oku(token_dosyasi_tam) if os.path.exists(token_dosyasi_tam) else ""

    # tema.dart, token dosyasiyla AYNI dizinde yasar (lib/design/) -- D5 ikisini
    # birlikte muaf tutar. lib_dizin, D5/D6'nin "lib/ altinda" sinirini olcer.
    ic_tasarim_dizin = os.path.abspath(os.path.dirname(token_dosyasi_tam))
    tema_dosyasi_tam = os.path.join(ic_tasarim_dizin, TEMA_DOSYASI_ADI)
    lib_dizin = os.path.abspath(os.path.join(kod_kok, "lib"))

    def _ic_tasarimda_mi(yol):
        return os.path.abspath(os.path.dirname(yol)) == ic_tasarim_dizin

    def _lib_altinda_mi(yol):
        ap = os.path.abspath(yol)
        return ap == lib_dizin or ap.startswith(lib_dizin + os.sep)

    # kullanim govdesi = token dosyasi HARIC butun dart kodu, yorumlar atilmis.
    # kullanim govdesi (DIS) = lib/design/'in TAMAMI HARIC -- D1 sikilastirmasi
    # (yalniz lib/design/ icinde kullanim D1'i doyurmaz) BUNUNLA olculur.
    kullanim_parcalari, kullanim_parcalari_dis = [], []
    for d in dosyalar:
        if os.path.abspath(d) == os.path.abspath(token_dosyasi_tam):
            continue
        govde = [yorum_disi(s) for s in _oku(d).split("\n")]
        kullanim_parcalari.extend(govde)
        if not _ic_tasarimda_mi(d):
            kullanim_parcalari_dis.extend(govde)
    kullanim_govdesi = "\n".join(kullanim_parcalari)
    kullanim_govdesi_dis = "\n".join(kullanim_parcalari_dis)

    must = [t for t in tokenlar if t["seviye"] == "MUST"]
    nice = [t for t in tokenlar if t["seviye"] == "NICE"]

    # --- D1: MUST token kodda hic kullanilmamis / yalniz lib/design/ icinde ---
    for t in must:
        if t["ad"] in MUAF_D1_ADLARI:
            continue  # TAM MUAFIYET: DESIGN.md'nin BD-7 kusuru, hicbir bilesene
                       # atanmamis (mesru yeri tema.dart'tir; kullanim ZORUNLU degil)
        son = t["sembol"].split(".")[-1]
        desen = re.compile(r"\b" + re.escape(t["sembol"]) + r"\b") \
            if "." in t["sembol"] else re.compile(r"\b" + re.escape(son) + r"\b")
        herhangi = bool(desen.search(kullanim_govdesi))
        disinda = bool(desen.search(kullanim_govdesi_dis))
        if not herhangi:
            bulgular.append(("D1", os.path.relpath(design_yolu, kok), t["satir"],
                             "MUST token '%s' (%s) Flutter kodunda HIC KULLANILMIYOR"
                             % (t["ad"], t["sembol"])))
        elif not disinda:
            bulgular.append(("D1", os.path.relpath(design_yolu, kok), t["satir"],
                             "MUST token '%s' (%s) YALNIZ lib/design/ icinde kullaniliyor -- "
                             "D1 sikilastirmasi: en az bir kullanim DISARIDA olmali (MUAF degil)"
                             % (t["ad"], t["sembol"])))

    # --- D3: MUST token'in Dart sembolu token dosyasinda tanimli degil ---
    if must:
        if not os.path.exists(token_dosyasi_tam):
            bulgular.append(("D3", os.path.relpath(design_yolu, kok), 0,
                             "token dosyasi YOK: %s (MUST token sayisi %d)"
                             % (token_dosyasi, len(must))))
        else:
            for t in must:
                son = t["sembol"].split(".")[-1]
                if not re.search(r"\b" + re.escape(son) + r"\b", token_govdesi):
                    bulgular.append(("D3", os.path.relpath(design_yolu, kok), t["satir"],
                                     "MUST token '%s' icin '%s' sembolu %s icinde TANIMLI DEGIL"
                                     % (t["ad"], t["sembol"], token_dosyasi)))

    # --- D2 + D4 + D5 + D6: kod taramasi ---
    for d in dosyalar:
        token_dosyasi_mi = os.path.abspath(d) == os.path.abspath(token_dosyasi_tam)
        tema_dosyasi_mi = os.path.abspath(d) == os.path.abspath(tema_dosyasi_tam)
        satirlar = _oku(d).split("\n")
        for i, ham in enumerate(satirlar, 1):
            kod = yorum_disi(ham)

            # D6: lib/ altinda cupertino.dart importu -- yapisal kural, muafiyet YOK.
            if _lib_altinda_mi(d) and D6_DESEN.search(kod):
                bulgular.append(("D6", os.path.relpath(d, kok), i,
                                 "lib/ altinda cupertino.dart importu yasak: %r" % kod.strip()))

            if token_dosyasi_mi:
                continue  # token TANIMI ham deger tasimak ZORUNDA, D2/D4/D5'ten muaf

            # D5: tokens.dart ve tema.dart DISINDA Theme.of( ile erisim.
            if _lib_altinda_mi(d) and not tema_dosyasi_mi and D5_DESEN.search(kod):
                bulgular.append(("D5", os.path.relpath(d, kok), i,
                                 "tokens.dart/tema.dart DISINDA Theme.of( kullanimi: %r"
                                 % kod.strip()))

            m = MUAFIYET.search(ham)
            if m:
                g = (m.group("gerekce") or "").lstrip(":").strip()
                if not g:
                    bulgular.append(("D4", os.path.relpath(d, kok), i,
                                     "gerekcesiz muafiyet: [DESIGN-LITERAL] gerekce ZORUNLU"))
            if not kod.strip():
                continue
            onceki = satirlar[i - 2] if i >= 2 else ""
            muaf = bool(MUAFIYET.search(ham)) or bool(MUAFIYET.search(onceki))
            for ad, desen in HAM_LITERAL:
                mm = desen.search(kod)
                if mm and not muaf:
                    bulgular.append(("D2", os.path.relpath(d, kok), i,
                                     "ham tasarim literali (%s): %r -- token'a cevrilmeli ya da "
                                     "[DESIGN-LITERAL: gerekce] ile muaf tutulmali"
                                     % (ad, mm.group(0))))
                    break

    ozet = {
        "token": len(tokenlar), "must": len(must), "nice": len(nice),
        "dart_dosya": len(dosyalar), "durum": "TARANDI",
    }
    return bulgular, ozet


# ============================== ALTIN KUME ===================================
# Arac ONCE kendini kanitlar: temizde SUSAR, mutasyonda ISIRIR. Kor kapi yok.

def _proje_kur(kok, design_metni, tokens_dart, main_dart, tema_dart=None):
    os.makedirs(os.path.join(kok, "src", "client", "lib", "design"), exist_ok=True)
    if design_metni is not None:
        with open(os.path.join(kok, "DESIGN.md"), "w", encoding="utf-8", newline="\n") as f:
            f.write(design_metni)
    if tokens_dart is not None:
        with open(os.path.join(kok, "src", "client", "lib", "design", "tokens.dart"),
                  "w", encoding="utf-8", newline="\n") as f:
            f.write(tokens_dart)
    if main_dart is not None:
        with open(os.path.join(kok, "src", "client", "lib", "main.dart"),
                  "w", encoding="utf-8", newline="\n") as f:
            f.write(main_dart)
    if tema_dart is not None:
        with open(os.path.join(kok, "src", "client", "lib", "design", "tema.dart"),
                  "w", encoding="utf-8", newline="\n") as f:
            f.write(tema_dart)


DESIGN_TEMIZ = """# DESIGN.md (altin kume ornegi)

Insan icin proza burada durur; arac BU METNI OKUMAZ.

```tokens
# seviye: MUST
renk.yuzey   = #FFFFFF  -> MRenk.yuzey
bosluk.m     = 16       -> MBosluk.m
# seviye: NICE
hareket.giris = 240ms   -> MHareket.giris
```
"""

TOKENS_TEMIZ = """class MRenk { static const yuzey = Color(0xFFFFFFFF); }
class MBosluk { static const m = 16.0; }
class MHareket { static const giris = Duration(milliseconds: 240); }
"""

MAIN_TEMIZ = """import 'design/tokens.dart';
Widget yap() => Container(color: MRenk.yuzey, padding: EdgeInsets.all(MBosluk.m));
"""

# D1 sikilastirmasi + D5 vakalari icin: MUST tokenlarin YALNIZ lib/design/
# icinde (tema.dart) kullanildigi durumu simule eden govde -- main.dart YOK.
TEMA_KULLANIM_ICERDE = """import 'tokens.dart';
final a = MRenk.yuzey;
final b = MBosluk.m;
"""

# MUAF token (renk.metin) icin izole tek-token fixture'i.
DESIGN_MUAF = """# DESIGN.md (D1 muafiyet ornegi)

```tokens
# seviye: MUST
renk.metin = #000000  -> MRenk.metin
```
"""

TOKENS_MUAF = "class MRenk { static const metin = Color(0xFF000000); }\n"

TEMA_MUAF = "import 'tokens.dart';\nfinal x = MRenk.metin;\n"

# D5 muafiyet vakasi: tema.dart'in KENDISI Theme.of( cagirir -- ISIRMAMALI.
TEMA_THEME_OF_MUAF = """import 'package:flutter/material.dart';
import 'tokens.dart';
Color renkAl(BuildContext context) => Theme.of(context).colorScheme.primary;
"""


def altin_kume():
    vakalar = []

    def vaka(ad, beklenen_kodlar, design, tokens, main, tema=None):
        gecici = tempfile.mkdtemp(prefix="dtk_")
        try:
            _proje_kur(gecici, design, tokens, main, tema_dart=tema)
            bulgular, ozet = tara(
                gecici,
                os.path.join(gecici, VARSAYILAN_DESIGN),
                os.path.join(gecici, "src", "client"),
                VARSAYILAN_TOKEN_DOSYASI,
            )
            olculen = sorted(set(b[0] for b in bulgular))
            gecti = olculen == sorted(set(beklenen_kodlar))
            vakalar.append((gecti, ad, sorted(set(beklenen_kodlar)), olculen, bulgular))
        finally:
            shutil.rmtree(gecici, ignore_errors=True)

    # 1) BOS GIRDI -- SUSMALI (K44-a'nin adlandirdigi vaka)
    vaka("BOS GIRDI (DESIGN.md yok, dart yok) -- SUSMALI", [], None, None, None)

    # 2) TEMIZ PROJE -- SUSMALI (yanlis-pozitif kontrolu)
    vaka("TEMIZ PROJE -- SUSMALI", [], DESIGN_TEMIZ, TOKENS_TEMIZ, MAIN_TEMIZ)

    # 3) KULLANILMAYAN MUST -- D1 ISIRMALI
    vaka("KULLANILMAYAN MUST -- D1", ["D1"], DESIGN_TEMIZ, TOKENS_TEMIZ,
         "import 'design/tokens.dart';\nWidget yap() => Container(color: MRenk.yuzey);\n")

    # 4) HAM RENK LITERALI -- D2 ISIRMALI
    vaka("HAM RENK LITERALI kodda -- D2", ["D2"], DESIGN_TEMIZ, TOKENS_TEMIZ,
         MAIN_TEMIZ + "Widget kacak() => Container(color: Color(0xFF112233));\n")

    # 5) NICE KULLANILMAMIS -- SUSMALI (NICE zorunlu degildir)
    vaka("NICE token kullanilmamis -- SUSMALI", [], DESIGN_TEMIZ, TOKENS_TEMIZ, MAIN_TEMIZ)

    # 6) MUST SEMBOLU TOKEN DOSYASINDA YOK -- D3 ISIRMALI
    vaka("MUST sembolu tokens.dart'ta tanimsiz -- D3", ["D3"], DESIGN_TEMIZ,
         "class MRenk { static const yuzey = Color(0xFFFFFFFF); }\n"
         "class MHareket { static const giris = Duration(milliseconds: 240); }\n",
         MAIN_TEMIZ)

    # 7) YORUM ICINDEKI LITERAL -- SUSMALI (yanlis-pozitif kontrolu)
    vaka("YORUM icindeki ham literal -- SUSMALI", [], DESIGN_TEMIZ, TOKENS_TEMIZ,
         MAIN_TEMIZ + "// eski deger Color(0xFF112233) idi\n")

    # 8) GEREKCESIZ MUAFIYET -- D4 ISIRMALI
    vaka("GEREKCESIZ muafiyet -- D4", ["D4"], DESIGN_TEMIZ, TOKENS_TEMIZ,
         MAIN_TEMIZ + "Widget x() => Container(color: Color(0xFF112233)); // [DESIGN-LITERAL]\n")

    # 9) GEREKCELI MUAFIYET -- SUSMALI
    vaka("GEREKCELI muafiyet -- SUSMALI", [], DESIGN_TEMIZ, TOKENS_TEMIZ,
         MAIN_TEMIZ +
         "// [DESIGN-LITERAL: marka disi 3. taraf rozeti, sabit renk sozlesmesi]\n"
         "Widget x() => Container(color: Color(0xFF112233));\n")

    # 10) BOZUK BLOK -- D0 ISIRMALI (bicim hatasi sessizce yutulmamali)
    vaka("BOZUK tokens satiri -- D0", ["D0"],
         DESIGN_TEMIZ.replace("bosluk.m     = 16       -> MBosluk.m",
                              "bosluk.m 16 MBosluk.m"),
         TOKENS_TEMIZ, MAIN_TEMIZ)

    # 11) BELGE VAR, KOD YOK -- D1/D3 ERTELENIR, SUSMALI
    #     (kod dogmadan MUST kullanimini kusur saymak yanlis-pozitif taban cizgisi uretir)
    vaka("BELGE VAR ama 0 dart -- D1/D3 ERTELENIR, SUSMALI", [],
         DESIGN_TEMIZ, None, None)

    # 12) MUTANT: erteleme kapiyi KORLESTIRMEMELI -- kod yokken bile D0 ISIRMALI
    #     Bu vaka olmadan 11) numarali erteleme bir KOR KAPI olurdu.
    vaka("BELGE VAR, 0 dart, ama tokens blogu BOZUK -- D0 YINE ISIRMALI", ["D0"],
         DESIGN_TEMIZ.replace("bosluk.m     = 16       -> MBosluk.m",
                              "bosluk.m 16 MBosluk.m"),
         None, None)

    # --- K57/T8: D1 sikilastirmasi + D5 + D6 (G4 -- 12 mevcut + yeni vakalar) ---

    # 13) MUST token YALNIZ lib/design/ (tema.dart) icinde kullaniliyor,
    #     MUAF degil -- D1 sikilastirmasi ISIRMALI.
    vaka("MUST token YALNIZ tema.dart icinde (MUAF DEGIL) -- D1 sikilastirmasi", ["D1"],
         DESIGN_TEMIZ, TOKENS_TEMIZ, None, tema=TEMA_KULLANIM_ICERDE)

    # 14) MUAF token (renk.metin) YALNIZ lib/design/ icinde kullaniliyor -- SUSMALI.
    vaka("MUAF token (renk.metin) YALNIZ tema.dart icinde -- SUSMALI", [],
         DESIGN_MUAF, TOKENS_MUAF, None, tema=TEMA_MUAF)

    # 14b) MUAF token HIC KULLANILMIYOR (gercek renk.yuzey.ikincil/hareket.hizli
    #      durumu) -- TAM MUAFIYET, SUSMALI. main/tema YOK.
    vaka("MUAF token HIC KULLANILMIYOR -- TAM MUAFIYET, SUSMALI", [],
         DESIGN_MUAF, TOKENS_MUAF, "final _bilinmez = 1;\n")

    # 15) Theme.of( DISINDA (main.dart) kullanim -- D5 ISIRMALI.
    vaka("Theme.of( main.dart'ta (tokens/tema DISINDA) -- D5", ["D5"],
         DESIGN_TEMIZ, TOKENS_TEMIZ,
         MAIN_TEMIZ + "Widget kacak2(BuildContext context) => "
                      "Container(color: Theme.of(context).colorScheme.primary);\n")

    # 16) Theme.of( tema.dart'IN KENDISINDE -- MUAF, SUSMALI.
    vaka("Theme.of( tema.dart'ta -- MUAF, SUSMALI", [],
         DESIGN_TEMIZ, TOKENS_TEMIZ, MAIN_TEMIZ, tema=TEMA_THEME_OF_MUAF)

    # 17) lib/ altinda cupertino.dart importu -- D6 ISIRMALI.
    vaka("cupertino.dart importu (lib/ altinda) -- D6", ["D6"],
         DESIGN_TEMIZ, TOKENS_TEMIZ,
         MAIN_TEMIZ + "import 'package:flutter/cupertino.dart';\n")

    cizgi = "=" * 78
    print(cizgi)
    print("ALTIN KUME -- DESIGN TOKEN KAPISININ KENDI KANITI (kor kapi yok)")
    print(cizgi)
    hepsi = True
    for gecti, ad, beklenen, olculen, bulgular in vakalar:
        print("\n[%s] %s" % ("GECTI" if gecti else "KALDI", ad))
        print("    beklenen: %s | olculen: %s" % (beklenen or "[]", olculen or "[]"))
        if not gecti:
            hepsi = False
            for b in bulgular:
                print("        %s %s:%s %s" % b)
    print("\n" + cizgi)
    if hepsi:
        print("HUKUM: ARAC KULLANILABILIR -- temizde susuyor, kirlide isiriyor.")
        print(cizgi)
        return 0
    print("HUKUM: ARAC KULLANILAMAZ -- altin kume KALDI. Normal tarama HUKUM VERMEZ.")
    print(cizgi)
    return 1


# ============================== RAPOR / CLI ==================================

ACIKLAMA = {
    "D0": "DESIGN.md tokens blogu bicim hatasi",
    "D1": "MUST token kullanilmiyor / yalniz lib/design/ icinde (MUAF degil)",
    "D2": "kodda ham tasarim literali (token kacagi)",
    "D3": "MUST token'in Dart sembolu token dosyasinda tanimsiz",
    "D4": "gerekcesiz muafiyet",
    "D5": "tokens.dart/tema.dart DISINDA Theme.of( erisimi",
    "D6": "lib/ altinda cupertino.dart importu",
}


def rapor(bulgular, ozet, kok, design_yolu, kod_kok):
    cizgi = "=" * 78
    print(cizgi)
    print("DESIGN TOKEN KAPISI v%s -- DESIGN.md <-> Flutter kodu" % SURUM)
    print("kok    : %s" % kok)
    print("belge  : %s" % design_yolu)
    print("kod    : %s" % kod_kok)
    print(cizgi)

    if ozet.get("durum") == "BOS-GIRDI":
        print("\nBOS GIRDI: DESIGN.md yok/token yok VE hic .dart dosyasi yok.")
        print("Arac SUSUYOR -- bu bir TEMIZ hukum DEGIL, olculecek bir sey OLMADIGININ beyanidir.")
        print("\n" + cizgi)
        print("HUKUM: OLCULECEK SEY YOK (exit 0)")
        print(cizgi)
        return 0

    if ozet.get("durum") == "BELGE-VAR-KOD-YOK":
        print("\nOZET: token %d (MUST %d / NICE %d) | dart dosyasi 0"
              % (ozet["token"], ozet["must"], ozet["nice"]))
        print("\nBELGE VAR, KOD YOK.")
        print("  D1 (MUST kullanimi) ve D3 (sembol tanimi) ERTELENDI: %d MUST token"
              % ozet.get("ertelenen", 0))
        print("  D2/D4 kod ister, kosulmadi. D0 (bicim) KOSULDU ve %s."
              % ("BULGU VERDI" if bulgular else "temiz"))
        print("\n  Bu bir TEMIZ hukum DEGILDIR. Belgenin MUST vaadi HENUZ OLCULMEMISTIR;")
        print("  ilk .dart dosyasi dogdugu anda bu kapi GERCEK hukum verecektir.")
        if bulgular:
            print("\nBULGULAR (%d):" % len(bulgular))
            for kod, dosya, satir, mesaj in bulgular:
                yer = "%s:%s" % (dosya, satir) if satir else dosya
                print("  [%s] %s\n        %s" % (kod, yer, mesaj))
            print("\n" + cizgi)
            print("HUKUM: KUSURLU (bicim) -- %d bulgu. (exit 1)" % len(bulgular))
            print(cizgi)
            return 1
        print("\n" + cizgi)
        print("HUKUM: BEKLEMEDE -- belge bicimi temiz, MUST vaadi KOD DOGUNCA olculecek. (exit 0)")
        print(cizgi)
        return 0

    print("\nOZET: token %d (MUST %d / NICE %d) | dart dosyasi %d"
          % (ozet["token"], ozet["must"], ozet["nice"], ozet["dart_dosya"]))

    if not bulgular:
        print("\n" + cizgi)
        print("HUKUM: TEMIZ -- her MUST token kodda kullaniliyor, ham literal yok. (exit 0)")
        print(cizgi)
        return 0

    sayac = {}
    for kod, dosya, satir, mesaj in bulgular:
        sayac[kod] = sayac.get(kod, 0) + 1
    print("\nBULGULAR (%d):" % len(bulgular))
    for kod in sorted(sayac):
        print("  %s x%-3d  %s" % (kod, sayac[kod], ACIKLAMA.get(kod, "")))
    print("")
    for kod, dosya, satir, mesaj in bulgular:
        yer = "%s:%s" % (dosya, satir) if satir else dosya
        print("  [%s] %s" % (kod, yer))
        print("        %s" % mesaj)
    print("\n" + cizgi)
    print("HUKUM: KUSURLU -- %d bulgu. (exit 1)" % len(bulgular))
    print(cizgi)
    return 1


def main(argv):
    ap = argparse.ArgumentParser(
        description="Momentum DESIGN.md <-> Flutter kodu mekanik kapisi")
    ap.add_argument("kok", nargs="?", help="proje kok dizini")
    ap.add_argument("--altin-kume", action="store_true",
                    help="araci kendi altin kumesinde kanitla (cikis 0 olmali)")
    ap.add_argument("--design", default=VARSAYILAN_DESIGN)
    ap.add_argument("--kod", default=VARSAYILAN_KOD)
    ap.add_argument("--token-dosyasi", default=VARSAYILAN_TOKEN_DOSYASI)
    a = ap.parse_args(argv)

    if a.altin_kume:
        return altin_kume()

    if not a.kok:
        ap.print_usage()
        print("HATA: proje kok dizini gerekli (ya da --altin-kume).")
        return 2
    if not os.path.isdir(a.kok):
        print("HATA: dizin yok: %s" % a.kok)
        return 2

    kok = os.path.abspath(a.kok)
    design_yolu = a.design if os.path.isabs(a.design) else os.path.join(kok, a.design)
    kod_kok = a.kod if os.path.isabs(a.kod) else os.path.join(kok, a.kod)

    bulgular, ozet = tara(kok, design_yolu, kod_kok, a.token_dosyasi)
    return rapor(bulgular, ozet, kok, design_yolu, kod_kok)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

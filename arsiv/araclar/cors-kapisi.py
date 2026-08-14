# -*- coding: utf-8 -*-
"""cors-kapisi.py -- GOREV-W1 icin STATIK ayak denetimi.

NEDEN VAR (GOREV-W1, T2, K44-a: once arac sonra belge): `W1/G35/a-d`, `W1/G37/d`
ve `W1/G38/c` KOSAN KOD OLMADAN olculebilir statik desenlerdir; bu arac onlari
push/build beklemeden dogrular.

🔴 **IKI DILLIDIR:** `.cs` (backend `Program.cs`) VE `.dart` (`veritabani.dart`,
`signalr_json_sinyal.dart`) tarar -- ayni dosyada degil, UC AYRI dosyada.

🔴 **YORUM ATLAMA MANTIGI `ss2-kapisi.py`'DEN ALINDI, YENIDEN YAZILMADI**
(K44-a/T2 sarti): `_blok_yorumsuz` ve `_yorumsuz_satirlar` fonksiyonlari
`ss2-kapisi.py`'nin K135'te onarilan BLOK (`/* ... */`) + SATIR (`//`) yolunu
BIREBIR tasir -- kopyalanan kod, degistirilmeyen kod. Genellenen tek sey blok
CIKARMA yardimcilaridir (`_tum_bloklari_bul` -- AYNI `{`/`}` derinlik sayacini
COKLU eslesmeye genisletir, cunku W1/D-W1-2 isareti dosyada IKI KEZ gecer;
`_parantez_blogu_bul` -- ayni derinlik sayacini `(`/`)` icin, ss2-kapisi.py'nin
`g33c_distinct` icindeki INLINE dongunun disariya cikarilmis hali).

NE OLCER:
  G35/a : `AddCors(` VE `UseCors(` ikisi de kod satirinda (yorumsuz, DOSYA GENELI).
  G35/b : ikisi de `// W1/D-W1-2` isaretli blok(lar)IN ICINDE (BLOK-ARALIKLI).
  G35/c : `AllowAnyOrigin` VE `SetIsOriginAllowed` kod satirinda HIC gecmez.
  G35/d : izinli basliklarda `Content-Type` VE `X-Momentum-Dev-User` ADIYLA.
  G37/d : `veritabani.dart`taki `driftDatabase(` cagrisinin PARANTEZ ARALIGINDA
          `MOMENTUM-G6-KANIT` oneki (yorumsuz).
  G38/c : `signalr_json_sinyal.dart`ta `if (kIsWeb) {` SATIRI durur -- ciplak
          `kIsWeb` dizgesi ARANMAZ (`:5`teki import satirinda da gecer, MAJOR-1).

🔴 **POZITIF KONTROL (PAZARLIKSIZ):** `Program.cs`ta `builder.Services.AddMediator`
bulunamazsa arac YESIL DEMEZ, `ORTAM HATASI` doner (G35/G8 hedefi: bu makinede
bir tarayici ayni dosyada bir dizgeyi bulup digerini kacirdi -- ORTAM.md).

Cikis: 0 temiz * 1 bulgu * 3 bicim/ortam hatasi (dosya yok VEYA pozitif kontrol dustu)
Kodlar: G35a * G35b * G35c * G35d * G37d * G38c
"""
import re
import sys


def _yaz(s):
    sys.stdout.write(s.encode("ascii", "replace").decode("ascii") + "\n")


# =====================================================================================
# ss2-kapisi.py'DEN ALINDI, DEGISTIRILMEDI (K44-a) -- blok (/* */) + satir (//) yorum
# atlama. K135: blok yolu onarilmadan once bu KOR KAPIYDI (KANIT/o56/14-...).
# =====================================================================================
def _blok_yorumsuz(metin):
    """Blok yorumlari (/* ... */) BOSLUGA cevirir. SATIR SAYISINI ve satir ici
    KONUMLARI korur. Tirnak literallerine saygilidir ve '//' satir yorumunun
    ICINE BAKMAZ. Kapanmayan bir blok dosya sonuna kadar yorum sayilir."""
    ci = list(metin)
    n = len(metin)
    i = 0
    tek = cift = False
    while i < n:
        ch = metin[i]
        if tek or cift:
            if ch == "\\":
                i += 2
                continue
            if ch == "'" and tek:
                tek = False
            elif ch == '"' and cift:
                cift = False
            elif ch == "\n":
                tek = cift = False
            i += 1
            continue
        if ch == "'":
            tek = True
        elif ch == '"':
            cift = True
        elif ch == "/" and i + 1 < n and metin[i + 1] == "/":
            while i < n and metin[i] != "\n":
                i += 1
            continue
        elif ch == "/" and i + 1 < n and metin[i + 1] == "*":
            j = metin.find("*/", i + 2)
            son = (j + 2) if j != -1 else n
            for k in range(i, son):
                if ci[k] != "\n":
                    ci[k] = " "
            i = son
            continue
        i += 1
    return "".join(ci)


def _yorumsuz_satirlar(metin):
    """Once BLOK yorumlari (bkz. _blok_yorumsuz), sonra her satirin ilk tirnaksiz
    '//' isaretinden SONRASINI yorum sayip atar."""
    sonuc = []
    for satir in _blok_yorumsuz(metin).split("\n"):
        tek = cift = False
        kesim = len(satir)
        i = 0
        while i < len(satir):
            ch = satir[i]
            if ch == "'" and not cift:
                tek = not tek
            elif ch == '"' and not tek:
                cift = not cift
            elif ch == "/" and not tek and not cift and i + 1 < len(satir) and satir[i + 1] == "/":
                kesim = i
                break
            i += 1
        sonuc.append(satir[:kesim])
    return sonuc


def _temiz(metin):
    """Kisayol: hem blok hem satir yorumlari atilmis TEK PARCA metin."""
    return "\n".join(_yorumsuz_satirlar(metin))


# =====================================================================================
# BLOK CIKARMA -- ss2-kapisi.py'nin _blok_ayikla / g33c_distinct'teki INLINE derinlik
# sayaclarinin GENELLENMIS hali (K126 dersi: recete SATIR BAZLI DEGIL, ARALIK bazli).
# =====================================================================================
def _tum_bloklari_bul(taban_metin, acilis_deseni):
    """`acilis_deseni`nin TUM eslesmelerini bulur (ss2-kapisi.py'nin _blok_ayikla'si
    TEK eslesme alirdi -- W1/D-W1-2 isareti dosyada IKI KEZ gecer, AddCors ve UseCors
    AYRI bloklardadir). Her eslesme icin acan '{' ile eslesen kapanisa kadarki
    ARALIGI dondurur. `taban_metin` blok-yorumlari BOSLUKLANMIS ama '//' yorumlari
    DOKUNULMAMIS olmalidir -- isaretin kendisi bir '//' yorumudur, tam temizlenmis
    metinde bulunamaz."""
    bloklar = []
    for m in re.finditer(acilis_deseni, taban_metin, re.S):
        baslangic = m.end()
        derinlik = 1
        i = baslangic
        while i < len(taban_metin) and derinlik > 0:
            if taban_metin[i] == "{":
                derinlik += 1
            elif taban_metin[i] == "}":
                derinlik -= 1
            i += 1
        if derinlik == 0:
            bloklar.append(taban_metin[baslangic:i - 1])
    return bloklar


def _parantez_blogu_bul(temiz_metin, acilis_deseni):
    """acilis_deseni'nin ILK eslesmesinden baslayip o parantezle eslesen kapanisa
    kadarki ARALIGI dondurur (ss2-kapisi.py'nin g33c_distinct'teki .count(...)
    dongusunun disariya cikarilmis hali). Eslesme yoksa None."""
    m = re.search(acilis_deseni, temiz_metin)
    if m is None:
        return None
    baslangic = m.end()
    derinlik = 1
    i = baslangic
    while i < len(temiz_metin) and derinlik > 0:
        if temiz_metin[i] == "(":
            derinlik += 1
        elif temiz_metin[i] == ")":
            derinlik -= 1
        i += 1
    if derinlik != 0:
        return None
    return temiz_metin[baslangic:i - 1]


# =====================================================================================
# AYAKLAR
# =====================================================================================
_ISARET_DESENI = r"//\s*W1/D-W1-2.*?\{"


def pozitif_kontrol(program_cs_metin):
    """PAZARLIKSIZ: Program.cs:38'de OLDUGU BILINEN bir dizge (builder.Services.
    AddMediator) bulunamazsa arac YESIL DEMEZ -- ORTAM.md'nin findstr dersi
    (ayni dosyada bir dizgeyi bulup digerini kacirma) burada mekaniklestirildi."""
    return "builder.Services.AddMediator" in _temiz(program_cs_metin)


def g35a_ikisi_de_var(program_cs_metin):
    """W1/G35/a: `AddCors(` VE `UseCors(` ikisi de DOSYA GENELINDE (yorumsuz)."""
    kod = _temiz(program_cs_metin)
    eksikler = []
    if "AddCors(" not in kod:
        eksikler.append("AddCors(")
    if "UseCors(" not in kod:
        eksikler.append("UseCors(")
    return eksikler


def g35b_blok_isaretli(program_cs_metin):
    """W1/G35/b: ikisi de `// W1/D-W1-2` isaretli blok(lar)IN METIN ARALIGINDA.
    Isaret arama BLOK-YORUMSUZ ama SATIR-YORUMLU tabanda yapilir (isaretin
    kendisi bir '//' yorumudur); her bulunan blogun ICERIGI ayrica TAM
    temizlenir (M193/M193c: yorumdaki bir kalinti SAYILMAZ)."""
    taban = _blok_yorumsuz(program_cs_metin)
    bloklar_ham = _tum_bloklari_bul(taban, _ISARET_DESENI)
    if not bloklar_ham:
        return ["// W1/D-W1-2 isaretli hicbir blok bulunamadi"]
    birlesim = "\n".join(_temiz(b) for b in bloklar_ham)
    eksikler = []
    if "AddCors(" not in birlesim:
        eksikler.append("AddCors( // W1/D-W1-2 bloklarinin DISINDA (ya da hic yok)")
    if "UseCors(" not in birlesim:
        eksikler.append("UseCors( // W1/D-W1-2 bloklarinin DISINDA (ya da hic yok)")
    return eksikler


def g35c_acik_desen_yok(program_cs_metin):
    """W1/G35/c: `AllowAnyOrigin` VE `SetIsOriginAllowed` kod satirinda HIC gecmez
    (yokluk olcen ayak -- yorumsuz metinde arar, M191b'nin yanlis-pozitifini
    engellemek icin)."""
    kod = _temiz(program_cs_metin)
    bulunanlar = []
    if "AllowAnyOrigin" in kod:
        bulunanlar.append("AllowAnyOrigin")
    if "SetIsOriginAllowed" in kod:
        bulunanlar.append("SetIsOriginAllowed")
    return bulunanlar


def g35d_basliklar(program_cs_metin):
    """W1/G35/d: izinli basliklar arasinda `Content-Type` VE `X-Momentum-Dev-User`
    ADIYLA gecer -- AllowAnyHeader() TEK BASINA yetmez (bu ayak onu aramaz)."""
    kod = _temiz(program_cs_metin)
    eksikler = []
    if "Content-Type" not in kod:
        eksikler.append("Content-Type")
    if "X-Momentum-Dev-User" not in kod:
        eksikler.append("X-Momentum-Dev-User")
    return eksikler


def g37d_g6_kaniti(veritabani_metin):
    """W1/G37/d: `driftDatabase(` cagrisinin PARANTEZ ARALIGINDA `MOMENTUM-G6-KANIT`
    oneki (yorumsuz) -- bu ayak G37'nin TUMUNUN dayandigi kanit zincirini korur."""
    kod = _temiz(veritabani_metin)
    blok = _parantez_blogu_bul(kod, r"driftDatabase\(")
    if blok is None:
        return False, "driftDatabase( cagrisi bulunamadi"
    if "MOMENTUM-G6-KANIT" not in blok:
        return False, "MOMENTUM-G6-KANIT oneki driftDatabase( cagrisinda bulunamadi"
    return True, ""


def g38c_kisweb_kapali(signalr_metin):
    """W1/G38/c: `if (kIsWeb) {` SATIRI durur -- ciplak `kIsWeb` dizgesi ARANMAZ
    (`:5`teki `import ... show kIsWeb;` satirinda da gecer, MAJOR-1)."""
    kod = _temiz(signalr_metin)
    if re.search(r"if\s*\(\s*kIsWeb\s*\)\s*\{", kod) is None:
        return False, "if (kIsWeb) { satiri bulunamadi (dal silinmis olabilir)"
    return True, ""


def denetle(program_cs_metin, veritabani_metin, signalr_metin):
    """(ortam_hatasi_mi, bulgular) dondurur. ortam_hatasi_mi True ise bulgular
    bos liste ve arac cagirani 'ORTAM HATASI' yazmalidir (YESIL DEMEZ)."""
    if not pozitif_kontrol(program_cs_metin):
        return True, []

    bulgular = []
    for eksik in g35a_ikisi_de_var(program_cs_metin):
        bulgular.append(("G35a", "W1/G35/a: " + eksik + " kod satirinda yok"))
    for eksik in g35b_blok_isaretli(program_cs_metin):
        bulgular.append(("G35b", "W1/G35/b: " + eksik))
    for bulunan in g35c_acik_desen_yok(program_cs_metin):
        bulgular.append(("G35c", "W1/G35/c: " + bulunan + " kod satirinda GECIYOR (yasak)"))
    for eksik in g35d_basliklar(program_cs_metin):
        bulgular.append(("G35d", "W1/G35/d: izinli basliklarda '" + eksik + "' adiyla yok"))
    ok, mesaj = g37d_g6_kaniti(veritabani_metin)
    if not ok:
        bulgular.append(("G37d", "W1/G37/d: " + mesaj))
    ok, mesaj = g38c_kisweb_kapali(signalr_metin)
    if not ok:
        bulgular.append(("G38c", "W1/G38/c: " + mesaj))
    return False, bulgular


# =====================================================================================
# ALTIN KUME (K44-a: once arac, sonra belge)
# =====================================================================================
_PROGRAM_CS_TEMIZ = """
using Microsoft.AspNetCore.Builder;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddMediator();

builder.Services.AddHttpContextAccessor();
if (builder.Environment.IsDevelopment())
{
    builder.Services.AddScoped<ICurrentUser, DevCurrentUser>();
}
else
{
    builder.Services.AddScoped<ICurrentUser, NullCurrentUser>();
}

var corsAllowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [];
if (builder.Environment.IsDevelopment() && corsAllowedOrigins.Length > 0) // W1/D-W1-2
{
    builder.Services.AddCors(options => options.AddDefaultPolicy(policy => policy
        .WithOrigins(corsAllowedOrigins)
        .WithHeaders("Content-Type", "X-Momentum-Dev-User")
        .WithMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")));
}

var app = builder.Build();

if (builder.Environment.IsDevelopment() && corsAllowedOrigins.Length > 0) // W1/D-W1-2
{
    app.UseCors();
}

app.UseExceptionHandler();

app.Run();
"""

_VERITABANI_DART_TEMIZ = """
QueryExecutor _uretimBaglantisi() {
  return driftDatabase(
    name: 'momentum',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
      onResult: (sonuc) {
        print(
          'MOMENTUM-G6-KANIT chosenImplementation=${sonuc.chosenImplementation} '
          'missingFeatures=${sonuc.missingFeatures}',
        );
      },
    ),
  );
}
"""

_SIGNALR_DART_TEMIZ = """
import 'package:flutter/foundation.dart' show kIsWeb;

class SignalrJsonSinyal {
  Future<void> baslat() async {
    if (kIsWeb) {
      gunlukYaz('web: gercek zamanli sinyal KAPALI -- elle yenileme tek yol');
      return;
    }
  }
}
"""


def _vaka(ad, program_cs_metin, veritabani_metin, signalr_metin, beklenen):
    """beklenen: "ORTAM" sentinel'i (pozitif kontrol dusmesi beklenir) VEYA
    bulgu kodlarinin listesi (bos liste = SUSMALI/TEMIZ)."""
    ortam_hatasi, bulgular = denetle(program_cs_metin, veritabani_metin, signalr_metin)
    if beklenen == "ORTAM":
        ok = ortam_hatasi
        olculen = "ORTAM" if ortam_hatasi else sorted(set(k for k, _ in bulgular))
    else:
        olculen = sorted(set(k for k, _ in bulgular))
        ok = (not ortam_hatasi) and olculen == sorted(set(beklenen))
    _yaz(("[GECTI] " if ok else "[KALDI] ") + ad)
    _yaz("    beklenen: " + str(beklenen) + " -- olculen: " + str(olculen))
    if not ok:
        for k, m in bulgular:
            _yaz("      " + k + ": " + m)
    return ok


def altin_kume():
    _yaz("=" * 78)
    _yaz("ALTIN KUME -- cors-kapisi.py KENDI KANITI (kor kapi yok, K44-a)")
    _yaz("=" * 78)
    sonuc = []

    sonuc.append(_vaka("1) TEMIZ -- taban vaka, hicbir bulgu beklenmez",
                        _PROGRAM_CS_TEMIZ, _VERITABANI_DART_TEMIZ, _SIGNALR_DART_TEMIZ, []))

    sonuc.append(_vaka("2) POZITIF KONTROL: AddMediator silinirse ORTAM HATASI (YESIL DENMEZ)",
                        _PROGRAM_CS_TEMIZ.replace("builder.Services.AddMediator();\n", ""),
                        _VERITABANI_DART_TEMIZ, _SIGNALR_DART_TEMIZ, "ORTAM"))

    # --- G35/a: M189, M189b ------------------------------------------------------
    sonuc.append(_vaka("3) M189: app.UseCors(); satiri silinir -- G35a KIRMIZI",
                        _PROGRAM_CS_TEMIZ.replace("    app.UseCors();\n", ""),
                        _VERITABANI_DART_TEMIZ, _SIGNALR_DART_TEMIZ, ["G35a", "G35b"]))

    sonuc.append(_vaka("4) M189b: builder.Services.AddCors(...) silinir (UseCors kalir) -- G35a KIRMIZI",
                        _PROGRAM_CS_TEMIZ.replace(
                            "    builder.Services.AddCors(options => options.AddDefaultPolicy(policy => policy\n"
                            "        .WithOrigins(corsAllowedOrigins)\n"
                            "        .WithHeaders(\"Content-Type\", \"X-Momentum-Dev-User\")\n"
                            "        .WithMethods(\"GET\", \"POST\", \"PUT\", \"DELETE\", \"OPTIONS\")));\n",
                            ""),
                        _VERITABANI_DART_TEMIZ, _SIGNALR_DART_TEMIZ, ["G35a", "G35b", "G35d"]))

    # --- G35/b: M190, M190b (dosya geneli SUSAR, blok-araligi ISIRIR) -----------
    sonuc.append(_vaka("5) M190: UseCors, W1/D-W1-2 blogunun DISINA tasinir (dosyada hala VAR) -- G35a SESSIZ, G35b KIRMIZI",
                        _PROGRAM_CS_TEMIZ.replace(
                            "\nif (builder.Environment.IsDevelopment() && corsAllowedOrigins.Length > 0) // W1/D-W1-2\n{\n    app.UseCors();\n}\n",
                            "\napp.UseCors();\n"),
                        _VERITABANI_DART_TEMIZ, _SIGNALR_DART_TEMIZ, ["G35b"]))

    sonuc.append(_vaka("6) M190b: AddCors, W1/D-W1-2 blogunun DISINA tasinir (uretimde de kaydedilir) -- G35a SESSIZ, G35b KIRMIZI",
                        _PROGRAM_CS_TEMIZ.replace(
                            "if (builder.Environment.IsDevelopment() && corsAllowedOrigins.Length > 0) // W1/D-W1-2\n"
                            "{\n"
                            "    builder.Services.AddCors(options => options.AddDefaultPolicy(policy => policy\n"
                            "        .WithOrigins(corsAllowedOrigins)\n"
                            "        .WithHeaders(\"Content-Type\", \"X-Momentum-Dev-User\")\n"
                            "        .WithMethods(\"GET\", \"POST\", \"PUT\", \"DELETE\", \"OPTIONS\")));\n"
                            "}\n",
                            "builder.Services.AddCors(options => options.AddDefaultPolicy(policy => policy\n"
                            "    .WithOrigins(corsAllowedOrigins)\n"
                            "    .WithHeaders(\"Content-Type\", \"X-Momentum-Dev-User\")\n"
                            "    .WithMethods(\"GET\", \"POST\", \"PUT\", \"DELETE\", \"OPTIONS\")));\n"),
                        _VERITABANI_DART_TEMIZ, _SIGNALR_DART_TEMIZ, ["G35b"]))

    # --- G35/c: M191, M191b ------------------------------------------------------
    sonuc.append(_vaka("7) M191: WithOrigins(...) -> AllowAnyOrigin() -- G35c KIRMIZI",
                        _PROGRAM_CS_TEMIZ.replace(".WithOrigins(corsAllowedOrigins)", ".AllowAnyOrigin()"),
                        _VERITABANI_DART_TEMIZ, _SIGNALR_DART_TEMIZ, ["G35c"]))

    sonuc.append(_vaka("8) M191b: kod bozulmaz, AllowAnyOrigin dizgesi YALNIZ yorumda -- SUSMALI (yanlis-pozitif)",
                        _PROGRAM_CS_TEMIZ.replace(
                            "var app = builder.Build();",
                            "// eskiden AllowAnyOrigin() kullaniliyordu, artik yasak (D-W1-1)\nvar app = builder.Build();"),
                        _VERITABANI_DART_TEMIZ, _SIGNALR_DART_TEMIZ, []))

    # --- G35/d: M192, M192b -------------------------------------------------------
    sonuc.append(_vaka("9) M192: izinli basliklardan Content-Type cikarilir -- G35d KIRMIZI",
                        _PROGRAM_CS_TEMIZ.replace('.WithHeaders("Content-Type", "X-Momentum-Dev-User")',
                                                    '.WithHeaders("X-Momentum-Dev-User")'),
                        _VERITABANI_DART_TEMIZ, _SIGNALR_DART_TEMIZ, ["G35d"]))

    sonuc.append(_vaka("10) M192b: izinli basliklardan X-Momentum-Dev-User cikarilir -- G35d KIRMIZI",
                        _PROGRAM_CS_TEMIZ.replace('.WithHeaders("Content-Type", "X-Momentum-Dev-User")',
                                                    '.WithHeaders("Content-Type")'),
                        _VERITABANI_DART_TEMIZ, _SIGNALR_DART_TEMIZ, ["G35d"]))

    # --- G35/a yorum-atlama yolu: M193, M193b, M193c ------------------------------
    sonuc.append(_vaka("11) M193: gercek app.UseCors() silinir, dogru satir YALNIZ // yorumunda -- KIRMIZI (// yolu)",
                        _PROGRAM_CS_TEMIZ.replace("    app.UseCors();\n", "    // app.UseCors();\n"),
                        _VERITABANI_DART_TEMIZ, _SIGNALR_DART_TEMIZ, ["G35a", "G35b"]))

    sonuc.append(_vaka("12) M193b: kod bozulmaz, FAZLADAN // yorum eklenir -- SUSMALI (yanlis-pozitif)",
                        _PROGRAM_CS_TEMIZ.replace(
                            "    app.UseCors();\n",
                            "    app.UseCors();\n    // app.UseCors(); // hatirlatma yorumu\n"),
                        _VERITABANI_DART_TEMIZ, _SIGNALR_DART_TEMIZ, []))

    sonuc.append(_vaka("13) M193c: gercek app.UseCors() silinir, dogru satir YALNIZ /* */ blok yorumunda -- KIRMIZI (blok yolu, K135)",
                        _PROGRAM_CS_TEMIZ.replace("    app.UseCors();\n", "    /* app.UseCors(); */\n"),
                        _VERITABANI_DART_TEMIZ, _SIGNALR_DART_TEMIZ, ["G35a", "G35b"]))

    # --- G38/c: M194 ---------------------------------------------------------------
    sonuc.append(_vaka("14) M194: if (kIsWeb) { dali silinir, import show kIsWeb; birakilir -- G38c KIRMIZI (ciplak dizge kacirir, MAJOR-1)",
                        _PROGRAM_CS_TEMIZ, _VERITABANI_DART_TEMIZ,
                        _SIGNALR_DART_TEMIZ.replace(
                            "    if (kIsWeb) {\n"
                            "      gunlukYaz('web: gercek zamanli sinyal KAPALI -- elle yenileme tek yol');\n"
                            "      return;\n"
                            "    }\n",
                            ""),
                        ["G38c"]))

    # --- G37/d: M198, M198b ----------------------------------------------------------
    sonuc.append(_vaka("15) M198: MOMENTUM-G6-KANIT oneki degistirilir (kod derlenir) -- G37d KIRMIZI",
                        _PROGRAM_CS_TEMIZ, _VERITABANI_DART_TEMIZ.replace("MOMENTUM-G6-KANIT", "MOMENTUM-DEGISTIRILDI"),
                        _SIGNALR_DART_TEMIZ, ["G37d"]))

    sonuc.append(_vaka("16) M198b: gercek print silinir, onek YALNIZ /* */ blok yorumunda -- G37d KIRMIZI",
                        _PROGRAM_CS_TEMIZ, _VERITABANI_DART_TEMIZ.replace(
                            "      onResult: (sonuc) {\n"
                            "        print(\n"
                            "          'MOMENTUM-G6-KANIT chosenImplementation=${sonuc.chosenImplementation} '\n"
                            "          'missingFeatures=${sonuc.missingFeatures}',\n"
                            "        );\n"
                            "      },\n",
                            "      onResult: (sonuc) {\n"
                            "        /* print('MOMENTUM-G6-KANIT chosenImplementation=' + sonuc.chosenImplementation); */\n"
                            "      },\n"),
                        _SIGNALR_DART_TEMIZ, ["G37d"]))

    # --- robustluk: driftDatabase( hic yoksa -- bicim/varlik kontrolu -------------
    sonuc.append(_vaka("17) driftDatabase( cagrisi HIC yoksa -- G37d KIRMIZI (varlik kontrolu)",
                        _PROGRAM_CS_TEMIZ, "// veritabani.dart burada degil", _SIGNALR_DART_TEMIZ, ["G37d"]))

    # --- robustluk: isaret HIC yoksa (D-W1-2 tamamen silinir) ----------------------
    sonuc.append(_vaka("18) // W1/D-W1-2 isareti HER IKI yerden de silinir (IsDevelopment kosullari kalir) -- G35b KIRMIZI",
                        _PROGRAM_CS_TEMIZ.replace(" // W1/D-W1-2", ""),
                        _VERITABANI_DART_TEMIZ, _SIGNALR_DART_TEMIZ, ["G35b"]))

    _yaz("=" * 78)
    gecti = sum(1 for x in sonuc if x)
    _yaz("HUKUM: %d/%d GECTI -- %s" % (gecti, len(sonuc),
         "ARAC KULLANILABILIR" if gecti == len(sonuc) else "ARAC KULLANILAMAZ"))
    _yaz("=" * 78)
    return 0 if gecti == len(sonuc) else 1


def main(argv):
    if argv and argv[0] == "--altin-kume":
        return altin_kume()
    kok = argv[0] if argv else "."
    program_cs_yol = kok.rstrip("\\/") + "/src/backend/Momentum.Api/Program.cs"
    veritabani_yol = kok.rstrip("\\/") + "/src/client/lib/veri/veritabani.dart"
    signalr_yol = kok.rstrip("\\/") + "/src/client/lib/ag/signalr_json_sinyal.dart"
    try:
        program_cs_metin = open(program_cs_yol, "rb").read().decode("utf-8")
        veritabani_metin = open(veritabani_yol, "rb").read().decode("utf-8")
        signalr_metin = open(signalr_yol, "rb").read().decode("utf-8")
    except Exception as e:
        _yaz("ORTAM HATASI: " + str(e))
        return 3

    ortam_hatasi, bulgular = denetle(program_cs_metin, veritabani_metin, signalr_metin)
    _yaz("=" * 78)
    _yaz("CORS KAPISI -- " + kok)
    _yaz("=" * 78)
    if ortam_hatasi:
        _yaz("ORTAM HATASI: Program.cs'te 'builder.Services.AddMediator' bulunamadi --")
        _yaz("  pozitif kontrol dustu, arac YESIL DEMEZ (ORTAM.md: findstr dersi).")
        _yaz("=" * 78)
        return 3
    for k, m in bulgular:
        _yaz("[" + k + "] " + m)
    if not bulgular:
        _yaz("BULGU YOK: G35/a-d * G37/d * G38/c hepsi gecti.")
    _yaz("-" * 78)
    _yaz("BEYAN EDILMIS SINIR: duz metin taranir, C#/Dart ayristirilmaz.")
    _yaz("G31/c tarzi birim/widget/kosan testleri BURADA OLCULMEZ.")
    _yaz("=" * 78)
    return 1 if bulgular else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

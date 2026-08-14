# -*- coding: utf-8 -*-
"""ci-kapisi.py -- GOREV-A13 icin CI dosyasi + iOS iskeleti STATIK denetimi.

NEDEN VAR (GOREV-A13, K44-a: once arac sonra belge): `ci.yml`, `project.pbxproj`
ve `.gitignore` icinde D-A13-2/3/5/6 kararlarinin gercekten yazili oldugunu
KOSAN CI OLMADAN olcer -- boylece push'tan ONCE (henuz push YOK, K80/PUSH ONURUNDUR)
statik mutantlar (M162-M166) sha256 ozdesligiyle sinanabilir.

NE OLCER (ve NE OLCMEZ):
  OLCER  : A13/G28/a,b (istemci isi) * A13/G29/a (ios isi) * A13/G30/a,b,c
           (pbxproj bundle id + deployment target + .gitignore artefakt yollari)
           * A13/G31/a-h (IS-EMRI-o69, backend CI isi -- D-A13-4 kapanisi:
           backend isi+runner * verify.ps1 cagrisi+shell * services YOK *
           is-duzeyi defaults ezmesi * kuresel defaults'ta shell YOK *
           istemci/ios'ta if: YOK * ASPNETCORE_ENVIRONMENT YOK * akis-stili
           (flow-style) YAML YASAK -- bagimsiz denetimde bulunan kor kapi
           kapatildi, oturum 69).
  OLCMEZ : A13/G27, A13/G28/c-d, A13/G29/b-d -- bunlar KOSAN CI logundan `gh` ile
           olculur (push sonrasi, Cowork/Onur isi). A13/G30/d (git diff --stat)
           de BURADA DEGIL -- kriter 3 onu ayri bir CIKTI-BOS olcumu olarak ister
           ("iki farkli olcu tek kosulda toplanmaz").

🔴 **DUZ METIN TARAR, YAML/PLIST AYRISTIRICISI DEGIL** [BEYAN EDILMIS SINIR --
gizlenmis degil]. `ci.yml` icin: her satirin ilk tirnaksiz `#`'dan SONRAKI kismi
YORUM sayilir ve ATILIR (yorum-satirindaki bayrak GORUNMEZ -- kriter 1'in
PAZARLIKSIZ istedigi vaka budur). `project.pbxproj` icin: gercek bir plist
ayristirici degil, ama `PBXNativeTarget "Runner"` build-configuration-list
baglantisini ID uzerinden takip eder ki `RunnerTests`'in kendi bundle id'si
Runner'inkiyle KARISMASIN.

Cikis: 0 temiz * 1 bulgu * 3 bicim/ortam hatasi
Kodlar: G28a * G28b * G29a * G30a * G30b * G30c * G31a * G31b * G31c * G31d *
        G31e * G31f * G31g * G31h * S0 (bicim/ortam)
"""
import re
import sys


def _yaz(s):
    sys.stdout.write(s.encode("ascii", "replace").decode("ascii") + "\n")


def _yorumsuz_satirlar(metin):
    """Her satirin ilk tirnaksiz '#' isaretinden SONRASINI yorum sayip atar.

    Duz metin taramasi -- gercek bir YAML/shell ayristiricisi degildir (BEYAN
    EDILMIS SINIR). Tirnak icindeki '#' de kabaca korunur (basit sayac), tam
    shell/YAML dogrulugu iddia edilmez.
    """
    sonuc = []
    for satir in metin.split("\n"):
        tek = cift = False
        kesim = len(satir)
        for i, ch in enumerate(satir):
            if ch == "'" and not cift:
                tek = not tek
            elif ch == '"' and not tek:
                cift = not cift
            elif ch == "#" and not tek and not cift:
                kesim = i
                break
        sonuc.append(satir[:kesim])
    return sonuc


def g28a_analiz_bayragi(ci_metin):
    """A13/G28/a: 'flutter analyze' + '--fatal-infos' AYNI (yorumsuz) satirda mi."""
    for satir in _yorumsuz_satirlar(ci_metin):
        if "flutter analyze" in satir and "--fatal-infos" in satir:
            return True
    return False


def g28b_flutter_surumu(ci_metin):
    """A13/G28/b: 'flutter-version:' degeri TAM OLARAK '3.44.6' mi.

    'channel:' anahtarina HIC bakilmaz [oturum 52'de duzeltildi] -- olculen
    sey PININ VARLIGIDIR, 'stable' kelimesinin yoklugu degil.
    """
    for satir in _yorumsuz_satirlar(ci_metin):
        m = re.search(r"flutter-version:\s*[\"']?([0-9A-Za-z.]+)[\"']?", satir)
        if m:
            return m.group(1) == "3.44.6"
    return False


def g29a_no_codesign(ci_metin):
    """A13/G29/a: 'flutter build ios' + '--no-codesign' AYNI (yorumsuz) satirda mi."""
    for satir in _yorumsuz_satirlar(ci_metin):
        if "flutter build ios" in satir and "--no-codesign" in satir:
            return True
    return False


def _runner_yapilandirma_idleri(pbxproj_metin):
    """'PBXNativeTarget "Runner"' icin build-configuration-list baglantisini
    takip edip (ad, id) ciftlerini dondurur -- 'RunnerTests' ile KARISMAZ."""
    m = re.search(
        r'/\*\s*Build configuration list for PBXNativeTarget "Runner"\s*\*/'
        r'\s*=\s*\{.*?buildConfigurations\s*=\s*\((.*?)\);',
        pbxproj_metin, re.S)
    if not m:
        return []
    return re.findall(r"([0-9A-Fa-f]{24})\s*/\*\s*(\w+)\s*\*/", m.group(1))


def _yapilandirma_ayarlari(pbxproj_metin, cfg_id, cfg_ad):
    """Verilen (id, ad) ciftinin KENDI 'XCBuildConfiguration' tanim blogunu
    bulur (referans degil, TANIM -- '= {' ile ayirt edilir) ve buildSettings
    govdesini dondurur."""
    desen = (re.escape(cfg_id) + r"\s*/\*\s*" + re.escape(cfg_ad) +
              r"\s*\*/\s*=\s*\{.*?buildSettings\s*=\s*\{(.*?)\};.*?\};")
    blok = re.search(desen, pbxproj_metin, re.S)
    return blok.group(1) if blok else ""


def g30a_bundle_id(pbxproj_metin):
    """A13/G30/a: Runner'in UC yapilandirmasinda PRODUCT_BUNDLE_IDENTIFIER
    hepsi 'com.momentum.client'; hicbirinde 'com.example' GECMEMELI.
    'RunnerTests' hedefi OLCULMEZ [beyan edilmis sinir, SS9/9]."""
    idler = _runner_yapilandirma_idleri(pbxproj_metin)
    if len(idler) < 3:
        return False, "Runner hedefinin uc yapilandirmasi bulunamadi (id=%d)" % len(idler)
    for cfg_id, cfg_ad in idler:
        govde = _yapilandirma_ayarlari(pbxproj_metin, cfg_id, cfg_ad)
        if "com.example" in govde:
            return False, "%s yapilandirmasinda 'com.example' geciyor" % cfg_ad
        m = re.search(r"PRODUCT_BUNDLE_IDENTIFIER\s*=\s*([^;]+);", govde)
        if not m or m.group(1).strip() != "com.momentum.client":
            deger = m.group(1).strip() if m else "(YOK)"
            return False, "%s yapilandirmasinda PRODUCT_BUNDLE_IDENTIFIER=%s (com.momentum.client bekleniyordu)" % (cfg_ad, deger)
    return True, ""


def g30b_deployment_target(pbxproj_metin):
    """A13/G30/b: IPHONEOS_DEPLOYMENT_TARGET'in TUM gecisleri '13.0' mi.
    Runner'a mi PBXProject'e mi ait oldugu ayirt edilmez -- D-A13-2'nin
    kendisi TEK bir tutarli deger ister; dosyada baska bir deger kalmasi
    (eski sablon artigi) kusurdur."""
    degerler = re.findall(r"IPHONEOS_DEPLOYMENT_TARGET\s*=\s*([^;]+);", pbxproj_metin)
    if not degerler:
        return False, "IPHONEOS_DEPLOYMENT_TARGET hicbir yerde yok"
    for d in degerler:
        if d.strip() != "13.0":
            return False, "IPHONEOS_DEPLOYMENT_TARGET=%s bulundu (13.0 bekleniyordu)" % d.strip()
    return True, ""


def g30c_gitignore(gitignore_metin):
    """A13/G30/c: ios/Pods/, ios/.symlinks/, ios/Flutter/Flutter.framework
    UCU DE VARLIK POZITIF kontroluyle .gitignore'da bulunmali (ORTAM.md
    findstr dersi: yoklugu 'olcemedim' saymak yerine varligi ARA)."""
    zorunlu = ["ios/Pods/", "ios/.symlinks/", "ios/Flutter/Flutter.framework"]
    eksik = [y for y in zorunlu if y not in gitignore_metin]
    if eksik:
        return False, "gitignore'da eksik: " + ", ".join(eksik)
    return True, ""


# ============================ IS-EMRI-o69 -- A13/G31/a-g (backend CI) =========
# 🔴 GENISLETME (D-A13-4 kapanisi, oturum 69): backend isini tarayan yedi yeni
# ayak. AYNI beyan edilmis sinir gecerlidir -- duz metin/girinti tabanli tarama,
# gercek bir YAML ayristirici DEGIL. Blok cikarma yontemi: bir anahtarin
# GIRINTI SEVIYESINI bulur, AYNI ya da DAHA SIG girintili bir sonraki satira
# kadar govdeyi toplar (basit, deterministik, YAML'in KENDI blok kuralinin
# yaklasik bir taklidi).


def _blok_ayikla(metin, anahtar, girinti=0):
    """`anahtar` (ör. 'defaults' ya da 'istemci') GIRINTI seviyesinde bir
    anahtar SATIRI olarak baslar (girinti=0 ⇒ 'defaults:', girinti=2 ⇒
    '  istemci:') ve AYNI ya da DAHA SIG girintili bir sonraki DOLU satira
    kadar govdeyi dondurur. Bulunamazsa None doner."""
    satirlar = metin.split("\n")
    on = " " * girinti
    bas = None
    for i, s in enumerate(satirlar):
        if s == on + anahtar + ":" or s.startswith(on + anahtar + ": "):
            bas = i
            break
    if bas is None:
        return None
    govde = [satirlar[bas]]
    for s in satirlar[bas + 1:]:
        if s.strip() == "":
            govde.append(s)
            continue
        mevcut = len(s) - len(s.lstrip(" "))
        if mevcut <= girinti:
            break
        govde.append(s)
    return "\n".join(govde)


def _is_bloklarini_ayikla(ci_metin):
    """`jobs:` altindaki HER isin (2 girinti) govdesini {ad: govde} olarak
    dondurur. Yorumlar ONCE atilir (_yorumsuz_satirlar) -- ayni desen G28/G29/
    G30'un kullandigi desendir."""
    metin = "\n".join(_yorumsuz_satirlar(ci_metin))
    jobs_govde = _blok_ayikla(metin, "jobs", girinti=0)
    if jobs_govde is None:
        return {}
    isler = {}
    satirlar = jobs_govde.split("\n")[1:]  # 'jobs:' satirini atla
    i = 0
    while i < len(satirlar):
        s = satirlar[i]
        m = re.match(r"^  ([\w-]+):\s*$", s)
        if not m:
            i += 1
            continue
        ad = m.group(1)
        govde = [s]
        j = i + 1
        while j < len(satirlar):
            s2 = satirlar[j]
            if s2.strip() == "":
                govde.append(s2)
                j += 1
                continue
            girinti2 = len(s2) - len(s2.lstrip(" "))
            if girinti2 <= 2:
                break
            govde.append(s2)
            j += 1
        isler[ad] = "\n".join(govde)
        i = j
    return isler


def g31a_backend_isi(ci_metin):
    """A13/G31/a: `backend` isi VAR ve `runs-on: ubuntu-latest`."""
    isler = _is_bloklarini_ayikla(ci_metin)
    govde = isler.get("backend")
    if govde is None:
        return False, "'backend' isi YOK"
    if not re.search(r"runs-on:\s*ubuntu-latest", govde):
        return False, "'backend' isi var ama runs-on: ubuntu-latest degil"
    return True, ""


def g31b_verify_cagrisi(ci_metin):
    """A13/G31/b: `./araclar/verify.ps1` cagrilan ADIMIN AYNI adiminda
    `shell: pwsh` de var mi (adimlar '- ' ile ayrilir, G28/G29'un 'ayni
    satirda' kuralinin adim-genisletilmis hali)."""
    isler = _is_bloklarini_ayikla(ci_metin)
    govde = isler.get("backend")
    if govde is None:
        return False, "'backend' isi YOK -- verify.ps1 cagrisi olculemedi"
    adimlar = re.split(r"\n(?=\s*-\s)", govde)
    for adim in adimlar:
        if "verify.ps1" in adim:
            if re.search(r"shell:\s*pwsh", adim):
                return True, ""
            return False, "verify.ps1 cagrisi var ama AYNI adimda 'shell: pwsh' yok"
    return False, "'backend' isinde './araclar/verify.ps1' cagrisi YOK"


def g31c_services_yok(ci_metin):
    """A13/G31/c: `services:` blogu HIC YOK (tasarim karari: testler kendi
    Testcontainers konteynerini acar)."""
    metin = "\n".join(_yorumsuz_satirlar(ci_metin))
    if re.search(r"(?m)^\s*services:\s*$", metin):
        return False, "'services:' blogu VAR (Testcontainers tasarimi ihlal edildi)"
    return True, ""


def g31d_is_duzeyi_defaults(ci_metin):
    """A13/G31/d: `backend` isi KENDI `defaults: / run: / working-directory:`
    ezmesini tasir (kuresel `defaults:` src/client'i ezer)."""
    isler = _is_bloklarini_ayikla(ci_metin)
    govde = isler.get("backend")
    if govde is None:
        return False, "'backend' isi YOK -- is-duzeyi defaults olculemedi"
    is_defaults = _blok_ayikla(govde, "defaults", girinti=4)
    if is_defaults is None:
        return False, "'backend' isinde is-duzeyi 'defaults:' YOK"
    if "working-directory:" not in is_defaults:
        return False, "'backend' isinde 'defaults:' var ama 'working-directory:' yok"
    return True, ""


def g31e_global_defaults_shell_yok(ci_metin):
    """A13/G31/e: KURESEL `defaults: / run:` altinda `shell:` YOK (tur 2'nin
    karsi ornegi: `shell: pwsh` kuresel bloga eklenirse istemci/ios'un TUM
    adimlarinin kabugu SESSIZCE degisir)."""
    metin = "\n".join(_yorumsuz_satirlar(ci_metin))
    govde = _blok_ayikla(metin, "defaults", girinti=0)
    if govde is None:
        return True, ""  # kuresel defaults hic yoksa shell de yoktur -- SUSAR
    if re.search(r"(?m)^\s*shell:\s*", govde):
        return False, "KURESEL 'defaults:' altinda 'shell:' VAR (istemci/ios'u sessizce etkiler)"
    return True, ""


def g31f_istemci_ios_if_yok(ci_metin):
    """A13/G31/f: `istemci` VE `ios` islerinin GOVDESINDE `if:` YOK (tur 2'nin
    ikinci karsi ornegi: `if: false` ile bir is sessizce devre disi kalabilir,
    'yalniz ekleme' testi bunu goremez)."""
    isler = _is_bloklarini_ayikla(ci_metin)
    for ad in ("istemci", "ios"):
        govde = isler.get(ad)
        if govde is None:
            continue
        if re.search(r"(?m)^\s*if:\s*", govde):
            return False, "'%s' isinin govdesinde 'if:' VAR (sessizce devre disi birakilabilir)" % ad
    return True, ""


def g31g_aspnetcore_environment_yok(ci_metin):
    """A13/G31/g: `ASPNETCORE_ENVIRONMENT` ci.yml'de HIC GECMEZ -- verify.ps1
    API'yi ayaga kaldirmaz, testler ortami kendileri `UseEnvironment` ile
    pinler; disaridan set etmek PINLEMEYEN bir testin davranisini sessizce
    degistirir (is emri §3b)."""
    if "ASPNETCORE_ENVIRONMENT" in ci_metin:
        return False, "'ASPNETCORE_ENVIRONMENT' ci.yml'de GECIYOR"
    return True, ""


def g31h_akis_stili_yasak(ci_metin):
    """A13/G31/h: ci.yml AKIS-STILI (flow-style, '{...}') YAML eslemesi
    TASIMAZ -- yalniz BOS akis-stili ('workflow_dispatch: {}') istisna.

    🔴 OLCULDU (bagimsiz denetimde bulundu, oturum 69): `_blok_ayikla`/
    `_is_bloklarini_ayikla` yalniz BLOK-STILI (girintili) YAML anahtarlarini
    tanir -- duz metin taramasinin BEYAN EDILMIS SINIRIDIR (gercek bir YAML
    ayristirici degildir). Ama `defaults: {run: {shell: pwsh}}` ya da
    `ios: {runs-on: macos-latest, if: false, ...}` gibi AKIS-STILI (JSON
    benzeri) yazim GERCEKTEN GECERLI YAML'dir ve GitHub Actions onu AYNI
    sekilde calistirir -- G31/c, G31/e, G31/f'nin BLOK-STILI regex'leri bunu
    GORMEZ ⇒ tur-2'nin 'Y2' saldirisi (kuresel shell/if: false ile is
    sessizce degistirilir) AKIS-STILIYLE YENIDEN acilabilirdi. Bu ayak o
    SINIFI TEK NOKTADAN kapatir: akis-stili HIC KULLANILAMAZ (bos harici).
    """
    metin = "\n".join(_yorumsuz_satirlar(ci_metin))
    for m in re.finditer(r":\s*\{([^}]*)\}", metin):
        if m.group(1).strip() == "":
            continue  # bos akis-stili (workflow_dispatch: {}) -- ISTISNA
        return False, "akis-stili (flow-style) YAML eslemesi bulundu: '%s' (yalniz block-stil taranir, gizli anahtar tasiyabilir)" % m.group(0)[:80].replace("\n", " ")
    return True, ""


def denetle(ci_metin, pbxproj_metin, gitignore_metin):
    """(bulgular) dondurur. bulgular: [(kod, mesaj)]"""
    bulgular = []
    if not g28a_analiz_bayragi(ci_metin):
        bulgular.append(("G28a", "A13/G28/a: 'flutter analyze' + '--fatal-infos' ayni satirda degil (silinmis ya da yalniz yorumda)"))
    if not g28b_flutter_surumu(ci_metin):
        bulgular.append(("G28b", "A13/G28/b: 'flutter-version:' 3.44.6 degil ya da hic yok"))
    if not g29a_no_codesign(ci_metin):
        bulgular.append(("G29a", "A13/G29/a: 'flutter build ios' + '--no-codesign' ayni satirda degil"))
    ok, mesaj = g30a_bundle_id(pbxproj_metin)
    if not ok:
        bulgular.append(("G30a", "A13/G30/a: " + mesaj))
    ok, mesaj = g30b_deployment_target(pbxproj_metin)
    if not ok:
        bulgular.append(("G30b", "A13/G30/b: " + mesaj))
    ok, mesaj = g30c_gitignore(gitignore_metin)
    if not ok:
        bulgular.append(("G30c", "A13/G30/c: " + mesaj))
    for kod, fn in (
        ("G31a", g31a_backend_isi),
        ("G31b", g31b_verify_cagrisi),
        ("G31c", g31c_services_yok),
        ("G31d", g31d_is_duzeyi_defaults),
        ("G31e", g31e_global_defaults_shell_yok),
        ("G31f", g31f_istemci_ios_if_yok),
        ("G31g", g31g_aspnetcore_environment_yok),
        ("G31h", g31h_akis_stili_yasak),
    ):
        ok, mesaj = fn(ci_metin)
        if not ok:
            bulgular.append((kod, "A13/G31/%s: %s" % (kod[-1], mesaj)))
    return bulgular


_CI_TEMIZ = """name: ci
on:
  workflow_dispatch: {}
  push:
    branches: [main]
defaults:
  run:
    working-directory: src/client
jobs:
  istemci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.44.6
      - run: flutter analyze --fatal-infos
      - run: flutter test
  ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.44.6
      - run: flutter build ios --no-codesign
  backend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: .
    steps:
      - uses: actions/checkout@v4
      - run: pwsh --version
        shell: pwsh
      - run: docker info
        shell: pwsh
      - uses: actions/setup-dotnet@v4
        with:
          global-json-file: global.json
      - run: ./araclar/verify.ps1
        shell: pwsh
"""
# 🔴 OLCULDU (is emri v3 Y5 -- oturum 69): eski fikstur KURESEL 'defaults:'
# TASIMIYORDU ama gercek ci.yml TASIYORDU (adim-duzeyi working-directory
# yerine). Fikstur burada gercege HIZALANDI -- yoksa yeni G31/d,e ayaklari
# KOR DOGARDI (vaka 1 'TEMIZ' zaten KIRMIZI verirdi).

_PBXPROJ_TEMIZ = """// !$*UTF8*$!
{
	archiveVersion = 1;
	objects = {

/* Begin XCBuildConfiguration section */
		97C147031CF9000F007C117D /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				IPHONEOS_DEPLOYMENT_TARGET = 13.0;
			};
			name = Debug;
		};
		97C147041CF9000F007C117D /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				IPHONEOS_DEPLOYMENT_TARGET = 13.0;
			};
			name = Release;
		};
		249021D3217E4FDB00AE95B9 /* Profile */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				IPHONEOS_DEPLOYMENT_TARGET = 13.0;
			};
			name = Profile;
		};
		97C147061CF9000F007C117D /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				IPHONEOS_DEPLOYMENT_TARGET = 13.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.momentum.client;
			};
			name = Debug;
		};
		97C147071CF9000F007C117D /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				IPHONEOS_DEPLOYMENT_TARGET = 13.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.momentum.client;
			};
			name = Release;
		};
		249021D4217E4FDB00AE95B9 /* Profile */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				IPHONEOS_DEPLOYMENT_TARGET = 13.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.momentum.client;
			};
			name = Profile;
		};
		331C8081294A63A400263BE5 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				IPHONEOS_DEPLOYMENT_TARGET = 13.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.momentum.client.RunnerTests;
			};
			name = Debug;
		};
		331C8082294A63A400263BE5 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				IPHONEOS_DEPLOYMENT_TARGET = 13.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.momentum.client.RunnerTests;
			};
			name = Release;
		};
		331C8083294A63A400263BE5 /* Profile */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				IPHONEOS_DEPLOYMENT_TARGET = 13.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.momentum.client.RunnerTests;
			};
			name = Profile;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		97C146E91CF9000F007C117D /* Build configuration list for PBXProject "Runner" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				97C147031CF9000F007C117D /* Debug */,
				97C147041CF9000F007C117D /* Release */,
				249021D3217E4FDB00AE95B9 /* Profile */,
			);
		};
		97C147051CF9000F007C117D /* Build configuration list for PBXNativeTarget "Runner" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				97C147061CF9000F007C117D /* Debug */,
				97C147071CF9000F007C117D /* Release */,
				249021D4217E4FDB00AE95B9 /* Profile */,
			);
		};
		331C8080294A63A400263BE5 /* Build configuration list for PBXNativeTarget "RunnerTests" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				331C8081294A63A400263BE5 /* Debug */,
				331C8082294A63A400263BE5 /* Release */,
				331C8083294A63A400263BE5 /* Profile */,
			);
		};
/* End XCConfigurationList section */
	};
}
"""

_GITIGNORE_TEMIZ = """.dart_tool/
build/
ios/Pods/
ios/.symlinks/
ios/Flutter/Flutter.framework
"""


def _vaka(ad, ci_metin, pbxproj_metin, gitignore_metin, beklenen_kodlar):
    bulgular = denetle(ci_metin, pbxproj_metin, gitignore_metin)
    olculen = sorted(set(k for k, _ in bulgular))
    ok = olculen == sorted(set(beklenen_kodlar))
    _yaz(("[GECTI] " if ok else "[KALDI] ") + ad)
    _yaz("    beklenen: " + str(sorted(set(beklenen_kodlar))) + " -- olculen: " + str(olculen))
    if not ok:
        for k, m in bulgular:
            _yaz("      " + k + ": " + m)
    return ok


def altin_kume():
    _yaz("=" * 74)
    _yaz("ALTIN KUME -- ci-kapisi.py KENDI KANITI (kor kapi yok)")
    _yaz("=" * 74)
    sonuc = []
    sonuc.append(_vaka("1) TEMIZ -- yanlis-pozitif kontrolu",
                       _CI_TEMIZ, _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, []))
    sonuc.append(_vaka("2) G28/a: --fatal-infos SILINMIS -- KIRMIZI",
                       _CI_TEMIZ.replace(" --fatal-infos", ""),
                       _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, ["G28a"]))
    sonuc.append(_vaka("3) G28/a YORUM SATIRI vakasi -- bayrak YALNIZ '#' satirinda -- KIRMIZI (kriter-1 PAZARLIKSIZ)",
                       _CI_TEMIZ.replace(
                           "      - run: flutter analyze --fatal-infos\n",
                           "      # - run: flutter analyze --fatal-infos\n      - run: flutter analyze\n"),
                       _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, ["G28a"]))
    sonuc.append(_vaka("4) G28/b: flutter-version 3.43.0 -- KIRMIZI",
                       _CI_TEMIZ.replace("3.44.6", "3.43.0"),
                       _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, ["G28b"]))
    sonuc.append(_vaka("5) G28/b: flutter-version anahtari HIC YOK -- KIRMIZI",
                       _CI_TEMIZ.replace("          flutter-version: 3.44.6\n", ""),
                       _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, ["G28b"]))
    sonuc.append(_vaka("6) G28/b YANLIS-POZITIF: channel: stable EKLENDI, flutter-version KORUNDU -- SUSMALI (M163b)",
                       _CI_TEMIZ.replace(
                           "          flutter-version: 3.44.6\n",
                           "          flutter-version: 3.44.6\n          channel: stable\n"),
                       _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, []))
    sonuc.append(_vaka("7) G29/a: --no-codesign SILINMIS -- KIRMIZI",
                       _CI_TEMIZ.replace(" --no-codesign", ""),
                       _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, ["G29a"]))
    sonuc.append(_vaka("8) G30/a: bir yapilandirmada com.example.client -- KIRMIZI",
                       _CI_TEMIZ, _PBXPROJ_TEMIZ.replace(
                           "PRODUCT_BUNDLE_IDENTIFIER = com.momentum.client;\n\t\t\t};\n\t\t\tname = Release;",
                           "PRODUCT_BUNDLE_IDENTIFIER = com.example.client;\n\t\t\t};\n\t\t\tname = Release;", 1),
                       _GITIGNORE_TEMIZ, ["G30a"]))
    sonuc.append(_vaka("9) G30/a: RunnerTests'in kendi bundle id'si Runner'i ISIRMAZ -- susmali (SS9/9)",
                       _CI_TEMIZ, _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, []))
    sonuc.append(_vaka("10) G30/b: bir yapilandirmada IPHONEOS_DEPLOYMENT_TARGET eski deger (12.0) kalmis -- KIRMIZI",
                       _CI_TEMIZ, _PBXPROJ_TEMIZ.replace(
                           "IPHONEOS_DEPLOYMENT_TARGET = 13.0;\n\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.momentum.client;\n\t\t\t};\n\t\t\tname = Debug;",
                           "IPHONEOS_DEPLOYMENT_TARGET = 12.0;\n\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.momentum.client;\n\t\t\t};\n\t\t\tname = Debug;", 1),
                       _GITIGNORE_TEMIZ, ["G30b"]))
    sonuc.append(_vaka("11) G30/c: gitignore'dan ios/Pods/ satiri silinmis -- KIRMIZI",
                       _CI_TEMIZ, _PBXPROJ_TEMIZ,
                       _GITIGNORE_TEMIZ.replace("ios/Pods/\n", ""), ["G30c"]))
    sonuc.append(_vaka("12) G30/c: uc yoldan biri bile eksikse KIRMIZI (Flutter.framework eksik)",
                       _CI_TEMIZ, _PBXPROJ_TEMIZ,
                       _GITIGNORE_TEMIZ.replace("ios/Flutter/Flutter.framework\n", ""), ["G30c"]))
    sonuc.append(_vaka("13) BIRDEN FAZLA ayak birlikte kirmizi -- karisik gecmez",
                       _CI_TEMIZ.replace(" --fatal-infos", ""),
                       _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ.replace("ios/Pods/\n", ""),
                       ["G28a", "G30c"]))
    # ---- IS-EMRI-o69: A13/G31/a-g (backend CI) ----
    sonuc.append(_vaka("14) G31/a: backend isi runs-on macos-latest'e degistirilmis -- KIRMIZI",
                       _CI_TEMIZ.replace(
                           "  backend:\n    runs-on: ubuntu-latest\n",
                           "  backend:\n    runs-on: macos-latest\n"),
                       _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, ["G31a"]))
    sonuc.append(_vaka("15) G31/b: verify.ps1 adiminda shell: pwsh silinmis -- KIRMIZI",
                       _CI_TEMIZ.replace(
                           "      - run: ./araclar/verify.ps1\n        shell: pwsh\n",
                           "      - run: ./araclar/verify.ps1\n"),
                       _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, ["G31b"]))
    sonuc.append(_vaka("16) G31/c: backend isine services: eklenmis -- KIRMIZI",
                       _CI_TEMIZ.replace(
                           "  backend:\n    runs-on: ubuntu-latest\n",
                           "  backend:\n    runs-on: ubuntu-latest\n    services:\n      postgres:\n        image: postgres:17-alpine\n"),
                       _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, ["G31c"]))
    sonuc.append(_vaka("17) G31/d: backend isinin is-duzeyi defaults'u silinmis -- KIRMIZI",
                       _CI_TEMIZ.replace(
                           "    defaults:\n      run:\n        working-directory: .\n", ""),
                       _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, ["G31d"]))
    sonuc.append(_vaka("18) G31/e: kuresel defaults'a shell: bash eklenmis -- KIRMIZI (tur 2 karsi ornegi)",
                       _CI_TEMIZ.replace(
                           "defaults:\n  run:\n    working-directory: src/client\n",
                           "defaults:\n  run:\n    working-directory: src/client\n    shell: bash\n"),
                       _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, ["G31e"]))
    sonuc.append(_vaka("19) G31/f: ios isine if: false eklenmis -- KIRMIZI (tur 2 karsi ornegi)",
                       _CI_TEMIZ.replace(
                           "  ios:\n    runs-on: macos-latest\n",
                           "  ios:\n    runs-on: macos-latest\n    if: false\n"),
                       _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, ["G31f"]))
    sonuc.append(_vaka("20) G31/g: ASPNETCORE_ENVIRONMENT verify.ps1 adimina eklenmis -- KIRMIZI",
                       _CI_TEMIZ.replace(
                           "      - run: ./araclar/verify.ps1\n        shell: pwsh\n",
                           "      - run: ./araclar/verify.ps1\n        shell: pwsh\n        env:\n          ASPNETCORE_ENVIRONMENT: Development\n"),
                       _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, ["G31g"]))
    sonuc.append(_vaka("22) G31/h: kuresel defaults AKIS-STILINE (flow-style) cevrilmis -- KIRMIZI",
                       _CI_TEMIZ.replace(
                           "defaults:\n  run:\n    working-directory: src/client\n",
                           "defaults: {run: {working-directory: src/client}}\n"),
                       _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, ["G31h"]))
    sonuc.append(_vaka("21) G31/c + G31/g BIRLIKTE kirmizi -- karisik gecmez (K40)",
                       _CI_TEMIZ.replace(
                           "  backend:\n    runs-on: ubuntu-latest\n",
                           "  backend:\n    runs-on: ubuntu-latest\n    services:\n      postgres:\n        image: postgres:17-alpine\n"
                       ).replace(
                           "      - run: ./araclar/verify.ps1\n        shell: pwsh\n",
                           "      - run: ./araclar/verify.ps1\n        shell: pwsh\n        env:\n          ASPNETCORE_ENVIRONMENT: Development\n"),
                       _PBXPROJ_TEMIZ, _GITIGNORE_TEMIZ, ["G31c", "G31g"]))
    _yaz("=" * 74)
    gecti = sum(1 for x in sonuc if x)
    _yaz("HUKUM: %d/%d GECTI -- %s" % (gecti, len(sonuc),
         "ARAC KULLANILABILIR" if gecti == len(sonuc) else "ARAC KULLANILAMAZ"))
    _yaz("=" * 74)
    return 0 if gecti == len(sonuc) else 1


def main(argv):
    if argv and argv[0] == "--altin-kume":
        return altin_kume()
    kok = argv[0] if argv else "."
    ci_yol = kok.rstrip("\\/") + "/.github/workflows/ci.yml"
    pbxproj_yol = kok.rstrip("\\/") + "/src/client/ios/Runner.xcodeproj/project.pbxproj"
    gitignore_yol = kok.rstrip("\\/") + "/.gitignore"
    try:
        ci_metin = open(ci_yol, "rb").read().decode("utf-8")
        pbxproj_metin = open(pbxproj_yol, "rb").read().decode("utf-8")
        gitignore_metin = open(gitignore_yol, "rb").read().decode("utf-8")
    except Exception as e:
        _yaz("ORTAM HATASI: " + str(e))
        return 3
    bulgular = denetle(ci_metin, pbxproj_metin, gitignore_metin)
    _yaz("=" * 74)
    _yaz("CI KAPISI -- " + kok)
    _yaz("=" * 74)
    for k, m in bulgular:
        _yaz("[" + k + "] " + m)
    if not bulgular:
        _yaz("BULGU YOK: G28/a,b * G29/a * G30/a,b,c * G31/a-h hepsi gecti.")
    _yaz("-" * 74)
    _yaz("BEYAN EDILMIS SINIR: duz metin taranir, YAML/plist ayristirilmaz.")
    _yaz("A13/G27, G28/c-d, G29/b-d, G30/d BURADA OLCULMEZ (kosan CI / git diff isi).")
    _yaz("=" * 74)
    return 1 if bulgular else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

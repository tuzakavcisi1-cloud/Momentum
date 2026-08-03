# -*- coding: utf-8 -*-
"""ci-kapisi.py -- GOREV-A13 icin CI dosyasi + iOS iskeleti STATIK denetimi.

NEDEN VAR (GOREV-A13, K44-a: once arac sonra belge): `ci.yml`, `project.pbxproj`
ve `.gitignore` icinde D-A13-2/3/5/6 kararlarinin gercekten yazili oldugunu
KOSAN CI OLMADAN olcer -- boylece push'tan ONCE (henuz push YOK, K80/PUSH ONURUNDUR)
statik mutantlar (M162-M166) sha256 ozdesligiyle sinanabilir.

NE OLCER (ve NE OLCMEZ):
  OLCER  : A13/G28/a,b (istemci isi) * A13/G29/a (ios isi) * A13/G30/a,b,c
           (pbxproj bundle id + deployment target + .gitignore artefakt yollari).
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
Kodlar: G28a * G28b * G29a * G30a * G30b * G30c * S0 (bicim/ortam)
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
    return bulgular


_CI_TEMIZ = """name: ci
on:
  workflow_dispatch: {}
  push:
    branches: [main]
jobs:
  istemci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.44.6
      - run: flutter analyze --fatal-infos
        working-directory: src/client
      - run: flutter test
        working-directory: src/client
  ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.44.6
      - run: flutter build ios --no-codesign
        working-directory: src/client
"""

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
        _yaz("BULGU YOK: G28/a,b * G29/a * G30/a,b,c hepsi gecti.")
    _yaz("-" * 74)
    _yaz("BEYAN EDILMIS SINIR: duz metin taranir, YAML/plist ayristirilmaz.")
    _yaz("A13/G27, G28/c-d, G29/b-d, G30/d BURADA OLCULMEZ (kosan CI / git diff isi).")
    _yaz("=" * 74)
    return 1 if bulgular else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

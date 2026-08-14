# -*- coding: utf-8 -*-
"""ss2-kapisi.py -- GOREV-SS2 icin STATIK ayak denetimi.

NEDEN VAR (GOREV-SS2, T0, K44-a: once arac sonra belge): `SS2/G31/a,b` ve
`SS2/G33/c` KOSAN KOD OLMADAN olculebilir statik desenlerdir; bu arac onlari
push/build beklemeden, T1-T4'un urun kodu yazilmadan ONCE dogrular (mutant
M162-tarzi kalitede: koşan uygulama istemez, tavansizdir).

NE OLCER (ve NE OLCMEZ):
  OLCER  : SS2/G31/a (schemaVersion=>5 + CakismaKayitlari tablo listesinde) *
           SS2/G31/b (from<5 migration blogu YALNIZ createTable cagirir) *
           SS2/G33/c (gorevlerGorunur() sorgusundaki HER count() distinct:true tasir).
  OLCMEZ : G31/c (drift_dev fikstur migration testi, birim testiyle olculur) *
           G32, G34 (birim/widget testi) * G33/a,b,d (birim testi) --
           BEYAN EDILMIS SINIR, gizlenmemis.

🔴 **DUZ METIN TARAR, DART AYRISTIRICISI DEGIL** [BEYAN EDILMIS SINIR]. Her
satirin ilk tirnaksiz `//`'den SONRASI yorum sayilir ve ATILIR -- yorum
satirindaki bir desen GORUNMEZ (M171c yanlis-pozitif kontrolu tam bunu ister).
🔴 **BLOK YORUM (`/* ... */`) DA ATILIR [oturum 56'da ONARILDI -- ONCESINDE KOR
KAPIYDI].** Olculmus gerekce (`KANIT/o56/14-g33c-yorum-olcumu.txt`): gercek kod
`schemaVersion => 4` iken dogru deger YALNIZ blok yorumda birakilinca arac
YANLIS SUSUYORDU (vaka D), ve blok yorumdaki `distinct`'siz bir `.count(`
YANLIS-POZITIF veriyordu (vaka C). `//` ayagi (M171b/M171c) blok yolunu
GORMUYORDU. Onarim `_blok_yorumsuz()`'tadir; altin kume vaka 11-14 ile pinli.
KALAN BEYAN EDILMIS SINIR: uc tirnakli (`'''`/`\"\"\"`) Dart literalleri ve
ham/kacisli dizeler TAM ayristirilmaz; bu bir Dart ayristiricisi degildir.
Blok aramalari (`G31/b`, `G33/c`) SATIR BAZLI DEGILDIR -- acan parantezden/
suslu parantezden kapanana kadar olan ARALIK taranir (K126 dersi: recete
satir bazli olursa cok-satirli cagrilarda ya kacirir ya da MESRU baska bir
bloktaki ayni deseni yanlislikla yakalar).

Cikis: 0 temiz * 1 bulgu * 3 bicim/ortam hatasi
Kodlar: G31a * G31b * G33c * S0 (bicim/ortam)
"""
import re
import sys


def _yaz(s):
    sys.stdout.write(s.encode("ascii", "replace").decode("ascii") + "\n")


def _blok_yorumsuz(metin):
    """Blok yorumlari (/* ... */) BOSLUGA cevirir. SATIR SAYISINI ve satir ici
    KONUMLARI korur -- g33c_distinct'in satir numarasi hesabi buna dayanir, bu
    yuzden silme degil BOSLUKLA DOLDURMA yapilir. Tirnak literallerine saygilidir
    ve '//' satir yorumunun ICINE BAKMAZ (oradaki '/*' bir blok ACMAZ); onlari
    _yorumsuz_satirlar'in per-satir gecisi zaten temizler. Kapanmayan bir blok
    dosya sonuna kadar yorum sayilir (Dart derleyicisi de oyle yapar)."""
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


def _blok_ayikla(kod, acilis_deseni):
    """`acilis_deseni` ile eslesen ilk yerden baslayip, o noktadaki acik
    suslu parantezle eslesen kapanisa kadar olan ARALIGI dondurur (basit
    derinlik sayaci). Eslesme yoksa None."""
    m = re.search(acilis_deseni, kod)
    if m is None:
        return None
    baslangic = m.end()
    derinlik = 1
    i = baslangic
    while i < len(kod) and derinlik > 0:
        if kod[i] == "{":
            derinlik += 1
        elif kod[i] == "}":
            derinlik -= 1
        i += 1
    if derinlik != 0:
        return None
    return kod[baslangic:i - 1]


def g31a_schema_ve_tablo(veritabani_metin):
    """SS2/G31/a: 'schemaVersion => 5' VE '@DriftDatabase(tables:[...])'
    listesinde 'CakismaKayitlari' -- ikisi BİRDEN aranir (AND)."""
    kod = "\n".join(_yorumsuz_satirlar(veritabani_metin))
    schema5 = re.search(r"\bschemaVersion\s*=>\s*5\b", kod) is not None
    tabloda_var = re.search(
        r"@DriftDatabase\(\s*tables:\s*\[[^\]]*\bCakismaKayitlari\b[^\]]*\]", kod, re.S
    ) is not None
    return schema5 and tabloda_var


def g31b_migration_blok(veritabani_metin):
    """SS2/G31/b: 'from < 5' bloğunun METIN ARALIGINDA 'alterTable(' ve
    'gorevler' GECMEMELI; blok YALNIZ 'createTable(' cagirmali. Blok-aralikli
    arama ZORUNLUDUR -- dosya geneli 'from < 2'deki MESRU alterTable'i
    yanlislikla yakalamamak icin (yanlis-pozitif kontrolu)."""
    kod = "\n".join(_yorumsuz_satirlar(veritabani_metin))
    blok = _blok_ayikla(kod, r"if\s*\(\s*from\s*<\s*5\s*\)\s*\{")
    if blok is None:
        return False, "if (from < 5) { ... } blogu bulunamadi"
    if "alterTable(" in blok:
        return False, "from<5 blogunda alterTable( geciyor"
    if "gorevler" in blok:
        return False, "from<5 blogunda 'gorevler' geciyor"
    if "createTable(" not in blok:
        return False, "from<5 blogunda createTable( yok"
    return True, ""


def g33c_distinct(gorev_deposu_metin):
    """SS2/G33/c: 'gorevlerGorunur()' sorgusundaki HER '.count(' cagrisi
    'distinct: true' tasir. Recete SATIR BAZLI DEGILDIR -- '.count('un acan
    parantezinden kapanan parantezine kadarki ARALIK taranir (argumanlar
    cok satirda olabilir, K126 dersi)."""
    kod = "\n".join(_yorumsuz_satirlar(gorev_deposu_metin))
    eksik_satirlar = []
    toplam = 0
    for m in re.finditer(r"\.count\(", kod):
        toplam += 1
        baslangic = m.end()
        derinlik = 1
        i = baslangic
        while i < len(kod) and derinlik > 0:
            if kod[i] == "(":
                derinlik += 1
            elif kod[i] == ")":
                derinlik -= 1
            i += 1
        arg = kod[baslangic:i - 1]
        if re.search(r"distinct\s*:\s*true", arg) is None:
            satir_no = kod.count("\n", 0, m.start()) + 1
            eksik_satirlar.append(satir_no)
    if toplam == 0:
        return False, "hic '.count(' cagrisi bulunamadi"
    if eksik_satirlar:
        return False, "distinct:true eksik -- satir(lar): " + ", ".join(str(s) for s in eksik_satirlar)
    return True, ""


def denetle(veritabani_metin, gorev_deposu_metin):
    """(bulgular) dondurur. bulgular: [(kod, mesaj)]"""
    bulgular = []
    if not g31a_schema_ve_tablo(veritabani_metin):
        bulgular.append(("G31a", "SS2/G31/a: schemaVersion=>5 VE CakismaKayitlari tablo listesinde -- ikisi birden saglanmiyor"))
    ok, mesaj = g31b_migration_blok(veritabani_metin)
    if not ok:
        bulgular.append(("G31b", "SS2/G31/b: " + mesaj))
    ok, mesaj = g33c_distinct(gorev_deposu_metin)
    if not ok:
        bulgular.append(("G33c", "SS2/G33/c: " + mesaj))
    return bulgular


_VERITABANI_TEMIZ = """
@DriftDatabase(tables: [Gorevler, SenkronKuyrugu, Ayarlar, UzakAlanDurumu, CakismaKayitlari])
class Veritabani extends _$Veritabani {
  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(senkronKuyrugu);
        await m.alterTable(TableMigration(gorevler));
      }
      if (from < 3) {
        await m.createTable(ayarlar);
      }
      if (from < 4) {
        await m.createTable(uzakAlanDurumu);
      }
      if (from < 5) {
        await m.createTable(cakismaKayitlari);
      }
    },
  );
}
"""

_GOREV_DEPOSU_TEMIZ = """
    final ucustaSutunu = kuyruk.opId.count(
      filter: kuyruk.durum.equals('gonderildi'),
      distinct: true,
    );
    final bekleyenSutunu = kuyruk.opId.count(
      filter: kuyruk.durum.equals('bekliyor'),
      distinct: true,
    );
    final zehirliSutunu = kuyruk.opId.count(
      filter: kuyruk.durum.equals('zehirli'),
      distinct: true,
    );
"""


def _vaka(ad, veritabani_metin, gorev_deposu_metin, beklenen_kodlar):
    bulgular = denetle(veritabani_metin, gorev_deposu_metin)
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
    _yaz("ALTIN KUME -- ss2-kapisi.py KENDI KANITI (kor kapi yok)")
    _yaz("=" * 74)
    sonuc = []
    sonuc.append(_vaka("1) TEMIZ -- yanlis-pozitif kontrolu",
                       _VERITABANI_TEMIZ, _GOREV_DEPOSU_TEMIZ, []))
    sonuc.append(_vaka("2) M171: schemaVersion => 5 -> => 4 -- KIRMIZI",
                       _VERITABANI_TEMIZ.replace("schemaVersion => 5;", "schemaVersion => 4;"),
                       _GOREV_DEPOSU_TEMIZ, ["G31a"]))
    sonuc.append(_vaka("3) M171b: gercek kod => 4, dogru deger YALNIZ yorumda -- KIRMIZI",
                       _VERITABANI_TEMIZ.replace(
                           "schemaVersion => 5;",
                           "schemaVersion => 4; // schemaVersion => 5"),
                       _GOREV_DEPOSU_TEMIZ, ["G31a"]))
    sonuc.append(_vaka("4) M171c: kod bozulmaz, fazladan YORUM satiri eklenir -- SUSMALI (yanlis-pozitif)",
                       _VERITABANI_TEMIZ.replace(
                           "int get schemaVersion => 5;",
                           "int get schemaVersion => 5;\n  // schemaVersion => 4 (eski deger, yorumda)"),
                       _GOREV_DEPOSU_TEMIZ, []))
    sonuc.append(_vaka("5) CakismaKayitlari tablo listesinden cikarilirsa -- KIRMIZI",
                       _VERITABANI_TEMIZ.replace(", CakismaKayitlari]", "]"),
                       _GOREV_DEPOSU_TEMIZ, ["G31a"]))
    sonuc.append(_vaka("6) M181: from<5 blogunda alterTable(TableMigration(gorevler)) eklenir -- KIRMIZI",
                       _VERITABANI_TEMIZ.replace(
                           "      if (from < 5) {\n        await m.createTable(cakismaKayitlari);\n      }",
                           "      if (from < 5) {\n        await m.createTable(cakismaKayitlari);\n        await m.alterTable(TableMigration(gorevler));\n      }"),
                       _GOREV_DEPOSU_TEMIZ, ["G31b"]))
    sonuc.append(_vaka("7) from<2'deki MESRU alterTable -- yanlis-pozitif ISTEMEZ (TEMIZ zaten tasiyor, susmali)",
                       _VERITABANI_TEMIZ, _GOREV_DEPOSU_TEMIZ, []))
    sonuc.append(_vaka("8) M176: distinct:true bir count()'tan silinir -- KIRMIZI",
                       _VERITABANI_TEMIZ,
                       _GOREV_DEPOSU_TEMIZ.replace(
                           "      filter: kuyruk.durum.equals('bekliyor'),\n      distinct: true,\n",
                           "      filter: kuyruk.durum.equals('bekliyor'),\n"),
                       ["G33c"]))
    sonuc.append(_vaka("9) count() argumanlari SONRAKI satirda (K126 cok-satir deseni) -- susmali",
                       _VERITABANI_TEMIZ,
                       "final x = kuyruk.opId.count(\n  filter: kuyruk.durum.equals('bekliyor'),\n  distinct: true,\n);",
                       []))
    sonuc.append(_vaka("10) hic count() cagrisi yoksa -- KIRMIZI (bicim/varlik kontrolu)",
                       _VERITABANI_TEMIZ, "// gorevlerGorunur burada degil", ["G33c"]))
    # 11-14: YORUM-ATLAMA ayaginin G33/c ve BLOK yolu [oturum 56, Cowork; K34-f:
    # araci Claude Code yazdi, onaran/pinleyen el AYRI]. 11-12 oturum 55'in
    # kapatilmamis MINOR'uydu (davranis zaten dogruydu, PIN yoktu); 13-14 ise
    # OLCULEREK dogdu ve 14 bir KOR KAPIYDI (KANIT/o56/14-g33c-yorum-olcumu.txt).
    sonuc.append(_vaka("11) M176c: distinct:true satiri '//' ile YORUMA cevrilir -- KIRMIZI",
                       _VERITABANI_TEMIZ,
                       _GOREV_DEPOSU_TEMIZ.replace(
                           "      filter: kuyruk.durum.equals('bekliyor'),\n      distinct: true,\n",
                           "      filter: kuyruk.durum.equals('bekliyor'),\n      // distinct: true,\n"),
                       ["G33c"]))
    sonuc.append(_vaka("12) M176d: kod bozulmaz, YORUMDA distinct'siz .count( -- SUSMALI (yanlis-pozitif)",
                       _VERITABANI_TEMIZ,
                       _GOREV_DEPOSU_TEMIZ
                       + "\n    // final eski = kuyruk.opId.count(filter: kuyruk.durum.equals('x'));\n",
                       []))
    sonuc.append(_vaka("13) BLOK yorum /* ... */ icinde distinct'siz .count( -- SUSMALI [o56 onarimi]",
                       _VERITABANI_TEMIZ,
                       _GOREV_DEPOSU_TEMIZ
                       + "\n    /* final eski = kuyruk.opId.count(filter: kuyruk.durum.equals('x')); */\n",
                       []))
    sonuc.append(_vaka("14) BLOK yorumda schemaVersion => 5, GERCEK kod => 4 -- KIRMIZI [o56: KOR KAPIYDI]",
                       _VERITABANI_TEMIZ.replace(
                           "int get schemaVersion => 5;",
                           "int get schemaVersion => 4;\n  /* int get schemaVersion => 5; */"),
                       _GOREV_DEPOSU_TEMIZ, ["G31a"]))
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
    veritabani_yol = kok.rstrip("\\/") + "/src/client/lib/veri/veritabani.dart"
    gorev_deposu_yol = kok.rstrip("\\/") + "/src/client/lib/veri/gorev_deposu.dart"
    try:
        veritabani_metin = open(veritabani_yol, "rb").read().decode("utf-8")
        gorev_deposu_metin = open(gorev_deposu_yol, "rb").read().decode("utf-8")
    except Exception as e:
        _yaz("ORTAM HATASI: " + str(e))
        return 3
    bulgular = denetle(veritabani_metin, gorev_deposu_metin)
    _yaz("=" * 74)
    _yaz("SS2 KAPISI -- " + kok)
    _yaz("=" * 74)
    for k, m in bulgular:
        _yaz("[" + k + "] " + m)
    if not bulgular:
        _yaz("BULGU YOK: G31/a,b * G33/c hepsi gecti.")
    _yaz("-" * 74)
    _yaz("BEYAN EDILMIS SINIR: duz metin taranir, Dart ayristirilmaz.")
    _yaz("G31/c, G32, G33/a,b,d, G34 BURADA OLCULMEZ (birim/widget testi isi).")
    _yaz("=" * 74)
    return 1 if bulgular else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

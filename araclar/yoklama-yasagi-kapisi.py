#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
yoklama-yasagi-kapisi.py -- Momentum GOREV-slice-3e-G12 T5: yoklama yasagi
(K68) + sinyal protokolu kurallarinin (K77/6, K77/3) STATIK kapisi.

NEDEN VAR (G12 K79/3):
  "Periyodik yoklama YASAK" (K68) uc dilimdir PROZADA yasiyordu, mekanik
  kapisi YOKTU. Bu arac dort ayagi (Y1-Y4) MEKANIK olarak olcer:

    Y1 -- src/client/lib altinda HER `Timer(`/`Timer.periodic(` cagrisi
          YALNIZ beyaz listedeki dosyada (signalr_json_sinyal.dart)
          olabilir. Ayrica HANGI dosyada olursa olsun, govdesinde
          `cekmeTuruCalistir`/`turCalistir`/`SenkronAgi` gecen bir
          zamanlayici KIRMIZI'dir (K68'in ta kendisi -- periyodik cekme).
    Y2 -- signalr_json_sinyal.dart'ta `arguments`/`cursorHint` dizgeleri
          YALNIZ yorum satirinda gecebilir (K77/6 -- CursorHint yoksayilir).
    Y3 -- signalr_json_sinyal.dart icinde `/v1/sync` dizgesi -- KOD
          satirinda -- hic gecemez (keepalive'in kendisi yoklamaya
          DONUSEMEZ). BEYAN EDILMIS SINIR: bu ayagin mutanti YOK (GOREV
          §3, Y3 borcu).
    Y4 -- `X-Momentum-Dev-User` basligi HEM negotiate isteginde HEM WS
          acilisinda gonderilmeli (K77/3'un dayanagi -- biri duserse
          sessiz 401).

YORUM SOYMA -- design-token-kapisi.py'nin yorum_disi()'siyle AYNI YONTEM
  (bu projede olculmus referans): tek satirlik `/* */` + `//` sonrasi
  atilir. BEYAN EDILMIS SINIR (M2b'nin tersi, o projede olculdu): cok
  satirli `/* */` icindeki literal KACABILIR -- bu dosyada boyle bir blok
  yorum kullanilmadigi icin pratikte zarasizdir, ama yontem AYNEN tasindi.
  Y2/Y3 bu yuzden yorum-disi (comment-stripped) metin uzerinde calisir --
  Y2'nin GOREV metni bunu ACIKCA ister; Y3'un metni SESSIZDIR ama ayni
  yontem uygulanir (gerekce: ayagin adi "KEEPALIVE YOKLAMAYA DONUSEMEZ" --
  davranissal bir kisitlamadir, `/v1/sync`i ACIKLAYICI biçimde ANMAYAN bir
  yorum satirini kusur SAYMAK yanlis-pozitif uretir; nitekim bu dosyanin
  KENDI T2/6 yorumu "`/v1/sync`e DOKUNMAZ" der -- kod DEGIL, yorumdur).

CIKIS KODLARI: 0 temiz | 1 bulgu var | 2 kullanim hatasi | 3 ortam/bicim hatasi
KULLANIM:
  python araclar\\yoklama-yasagi-kapisi.py --altin-kume
  python araclar\\yoklama-yasagi-kapisi.py <kok-dizin>  (ornek: .)
  python araclar\\yoklama-yasagi-kapisi.py <kok-dizin> --kanit <dosya>
"""

import argparse
import os
import re
import sys

SURUM = "0.1.0"

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

BEYAZ_LISTE_DOSYA = "signalr_json_sinyal.dart"   # Y2/Y3/Y4 hala DOSYA bazli

# K81 [Onur, 29 Tem 2026 -- K79/3 DARALTILDI]: Y1 artik DOSYA degil SEMBOL bazli.
# Gerekce olculdu: senkron_rozeti.dart:170 `_DonenOkState` icinde donen-ok
# ANIMASYON zamanlayicisi var -- ag yok, senkron cagrisi yok, K68 ile ilgisiz.
# Dosya butununu affetmek KOR NOKTA acardi (ayni dosyaya sonradan eklenecek
# senkron ceken bir Timer gorunmez olurdu); bu yuzden (dosya, KAPSAYAN BILDIRIM)
# cifti beyaz listelenir ve GOVDE kurali beyaz listedekiler DAHIL herkese uygulanir.
BEYAZ_LISTE_SEMBOL = {
    ("signalr_json_sinyal.dart", "SignalrJsonSinyal"),   # keepalive + geri cekilme
    ("senkron_rozeti.dart", "_DonenOkState"),            # donen ok animasyonu (sunum)
}
YASAKLI_GOVDE_TANIMLAYICILAR = ("cekmeTuruCalistir", "turCalistir", "SenkronAgi")
DEV_BASLIK_LITERAL = "X-Momentum-Dev-User"
LIB_ALT_YOLU = os.path.join("src", "client", "lib")


# ============================== YORUM SOYMA ===================================

def yorum_disi(satir):
    """Satirin kod kismini dondurur; `//` sonrasi ATILIR.

    design-token-kapisi.py'deki `yorum_disi()` ile AYNI yontem (bu projede
    olculmus referans). Tam bir ayristirici DEGILDIR -- cok satirli `/* */`
    icindeki literal KACABILIR, bu BEYAN EDILMIS bir sinirdir.
    """
    s = re.sub(r"/\*.*?\*/", "", satir)
    k = s.find("//")
    return s if k < 0 else s[:k]


def yorum_disi_metin(icerik):
    return "\n".join(yorum_disi(s) for s in icerik.split("\n"))


# ============================== DOSYA OKUMA ===================================

def dart_dosyalarini_oku(kok):
    """{goreli_yol: icerik} -- yalniz `<kok>/src/client/lib` altindaki `.dart` dosyalari."""
    lib_kok = os.path.join(kok, LIB_ALT_YOLU)
    sonuc = {}
    if not os.path.isdir(lib_kok):
        return sonuc
    for dirpath, _, dosyalar in os.walk(lib_kok):
        for ad in dosyalar:
            if not ad.endswith(".dart"):
                continue
            tam = os.path.join(dirpath, ad)
            with open(tam, "rb") as f:
                icerik = f.read().decode("utf-8", errors="replace")
            goreli = os.path.relpath(tam, kok).replace("\\", "/")
            sonuc[goreli] = icerik
    return sonuc


# ============================== PARANTEZ/SUSLU ESLESTIRME ======================

def _esleseni_bul(metin, ac_idx, ac_char, kapa_char):
    """metin[ac_idx] == ac_char varsayilir; eslesen kapanisin INDEKSINI dondurur (yoksa None)."""
    derinlik = 0
    i = ac_idx
    n = len(metin)
    while i < n:
        c = metin[i]
        if c == ac_char:
            derinlik += 1
        elif c == kapa_char:
            derinlik -= 1
            if derinlik == 0:
                return i
        i += 1
    return None


def timer_cagrilari_bul(metin):
    """[(baslangic_idx, tam_cagri_metni)] -- her `Timer(`/`Timer.periodic(` icin."""
    sonuc = []
    for m in re.finditer(r"\bTimer(?:\.periodic)?\s*\(", metin):
        ac_idx = m.end() - 1
        kapa_idx = _esleseni_bul(metin, ac_idx, "(", ")")
        govde = metin[m.start():kapa_idx + 1] if kapa_idx is not None else metin[m.start():]
        sonuc.append((m.start(), govde))
    return sonuc


def fonksiyon_govdesi_bul(metin, imza_regex):
    """Imzayla eslesen ilk GERCEK TANIMIN govdesini dondurur (yoksa None).

    `imza_regex` bir CAGRI SATIRIYLA da eslesebilir (orn. `_websocketAc(x)`
    hem tanimda hem cagrida gecer) -- bu yuzden TEK ilk eslesmeyle
    YETINILMEZ: eslesmeden hemen sonra (yalniz bosluk atlanarak) bir `{`
    GELMIYORSA bu bir cagri/ifade satiridir, atlanir ve bir SONRAKI eslesme
    denenir.
    """
    for m in re.finditer(imza_regex, metin):
        i = m.end()
        while i < len(metin) and metin[i] in " \t\r\n":
            i += 1
        if metin[i:i + 5] == "async" and (i + 5 >= len(metin) or not metin[i + 5].isalnum()):
            i += 5
            while i < len(metin) and metin[i] in " \t\r\n":
                i += 1
        if i < len(metin) and metin[i] == "{":
            kapa_idx = _esleseni_bul(metin, i, "{", "}")
            if kapa_idx is not None:
                return metin[i:kapa_idx + 1]
    return None


def _kapsayan_bildirim(metin, idx):
    """[K81] `idx` konumundan ONCE gelen EN YAKIN class/mixin/enum adini dondurur.

    Beyan edilmis sinir: sozdizimi agaci degil, metin taramasidir. Ic ice sinif
    tanimlarinda EN YAKIN olani secer; hicbir bildirim yoksa "(dosya koku)" doner.
    """
    en_yakin = None
    for m in re.finditer(r"\b(?:class|mixin|enum)\s+(\w+)", metin):
        if m.start() < idx:
            en_yakin = m.group(1)
        else:
            break
    return en_yakin or "(dosya koku)"


# ============================== AYAKLAR =======================================

def _y1(dosyalar):
    """K68 + K81: Timer/Timer.periodic SEMBOL beyaz listesi + yasakli govde taramasi.

    K81 PAZARLIKSIZ: govde kurali beyaz listedekiler DAHIL HER zamanlayiciya
    uygulanir. Eski surumde beyaz liste disindaki dosya `continue` ile atlaniyordu;
    olculdu (M71): senkron ceken bir Timer yalniz "beyaz liste disi" diye
    raporlaniyor, "YOKLAMA SUPHESI" bacagi gercek depoda HIC kosmuyordu.
    """
    bulgular = []
    izin = ", ".join("%s::%s" % p for p in sorted(BEYAZ_LISTE_SEMBOL))
    for yol, icerik in sorted(dosyalar.items()):
        temiz_metin = yorum_disi_metin(icerik)
        cagrilar = timer_cagrilari_bul(temiz_metin)
        if not cagrilar:
            continue
        temel = os.path.basename(yol)
        for idx, govde in cagrilar:
            sembol = _kapsayan_bildirim(temiz_metin, idx)
            if (temel, sembol) not in BEYAZ_LISTE_SEMBOL:
                bulgular.append(("Y1", yol,
                                 "BEYAZ LISTE DISI: %s::%s -- izinli: %s"
                                 % (temel, sembol, izin)))
            for yasakli in YASAKLI_GOVDE_TANIMLAYICILAR:
                if yasakli in govde:
                    bulgular.append(("Y1", yol,
                                     "YOKLAMA SUPHESI: %s::%s -- Timer govdesinde '%s' geciyor"
                                     % (temel, sembol, yasakli)))
    return bulgular


def _y2(dosyalar):
    """K77/6: `arguments`/`cursorHint` yalniz yorum satirinda gecebilir."""
    bulgular = []
    for yol, icerik in sorted(dosyalar.items()):
        if os.path.basename(yol) != BEYAZ_LISTE_DOSYA:
            continue
        for i, satir in enumerate(icerik.split("\n"), start=1):
            kod = yorum_disi(satir)
            if "arguments" in kod:
                bulgular.append(("Y2", yol, "satir %d: 'arguments' KOD satirinda gecti" % i))
            if "cursorHint" in kod:
                bulgular.append(("Y2", yol, "satir %d: 'cursorHint' KOD satirinda gecti" % i))
    return bulgular


def _y3(dosyalar):
    """Keepalive yoklamaya donusemez: `/v1/sync` KOD satirinda hic gecemez."""
    bulgular = []
    for yol, icerik in sorted(dosyalar.items()):
        if os.path.basename(yol) != BEYAZ_LISTE_DOSYA:
            continue
        for i, satir in enumerate(icerik.split("\n"), start=1):
            kod = yorum_disi(satir)
            if "/v1/sync" in kod:
                bulgular.append(("Y3", yol, "satir %d: '/v1/sync' KOD satirinda gecti" % i))
    return bulgular


def _y4(dosyalar):
    """X-Momentum-Dev-User HEM negotiate'te HEM WS acilisinda gonderilmeli."""
    bulgular = []
    for yol, icerik in sorted(dosyalar.items()):
        if os.path.basename(yol) != BEYAZ_LISTE_DOSYA:
            continue

        sabit_m = re.search(r"(\w+)\s*=\s*'%s'" % re.escape(DEV_BASLIK_LITERAL), icerik)
        tanimlayici = sabit_m.group(1) if sabit_m else ("'%s'" % DEV_BASLIK_LITERAL)

        # (a) negotiate istegi -- govdesi basligi DOGRUDAN tasimali.
        negotiate_govde = fonksiyon_govdesi_bul(icerik, r"_negotiate\s*\([^)]*\)")
        if negotiate_govde is None:
            bulgular.append(("Y4", yol, "negotiate fonksiyonu BULUNAMADI (_negotiate)"))
        elif tanimlayici not in negotiate_govde:
            bulgular.append(("Y4", yol,
                              "negotiate istegi '%s' basligini ICERMIYOR" % DEV_BASLIK_LITERAL))

        # (b1) WS icin baslik NEREDE HESAPLANIYOR -- _websocketAc govdesi ayni tanimliyi kullanmali.
        ws_govde = fonksiyon_govdesi_bul(icerik, r"_websocketAc\s*\([^)]*\)\s*")
        if ws_govde is None:
            bulgular.append(("Y4", yol, "WS acma fonksiyonu BULUNAMADI (_websocketAc)"))
        elif tanimlayici not in ws_govde:
            bulgular.append(("Y4", yol,
                              "WS acilisi icin baslik HESAPLANMIYOR (_websocketAc icinde '%s' yok)"
                              % DEV_BASLIK_LITERAL))

        # (b2) HESAPLANAN baslik GERCEKTEN baglanti cagrisina ULASIYOR MU -- gercek
        # `IOWebSocketChannel.connect(...)` cagrisinin KENDI parantez araliginda bir
        # `headers:` argumani OLMALI (M73 tam bunu siler; araci-fonksiyon adina
        # BAGIMLI OLMADAN dogrudan production API cagrisini hedefler).
        connect_m = re.search(r"IOWebSocketChannel\.connect\s*\(", icerik)
        if connect_m is None:
            bulgular.append(("Y4", yol, "WS baglanti cagrisi BULUNAMADI (IOWebSocketChannel.connect)"))
        else:
            ac_idx = connect_m.end() - 1
            kapa_idx = _esleseni_bul(icerik, ac_idx, "(", ")")
            govde = icerik[connect_m.start():kapa_idx + 1] if kapa_idx is not None else icerik[connect_m.start():]
            if "headers" not in govde:
                bulgular.append(("Y4", yol, "WS baglanti cagrisi 'headers:' argumani TASIMIYOR"))
    return bulgular


def tara(dosyalar):
    """Tum ayaklari kosar. Doner: [(kod, dosya, mesaj)]."""
    bulgular = []
    bulgular.extend(_y1(dosyalar))
    bulgular.extend(_y2(dosyalar))
    bulgular.extend(_y3(dosyalar))
    bulgular.extend(_y4(dosyalar))
    return bulgular


# ============================== ALTIN KUME ===================================
# AGA CIKMAZ, DISK OKUMAZ (fixture) -- en az 9 vaka, GOREV T5 gerekcesiyle birebir.

_TEMIZ_SINYAL = """import 'dart:async';

class SignalrJsonSinyal {
  static const String _devKullaniciBasligi = 'X-Momentum-Dev-User';
  Timer? _keepaliveZamanlayicisi;
  Timer? _yenidenBaglanmaZamanlayicisi;

  void _keepaliveBaslat() {
    _keepaliveZamanlayicisi = Timer.periodic(Duration(seconds: 15), (_) {
      kanal.sink.add('{"type":6}');
    });
  }

  void _yenidenBaglanmayiPlanla() {
    _yenidenBaglanmaZamanlayicisi = Timer(gecikme, () {
      unawaited(_baglanmayiDene());
    });
  }

  Future<String> _negotiate() async {
    final yanit = await _http.post(url, headers: {_devKullaniciBasligi: actorId});
    return yanit.body;
  }

  WebSocketChannel _websocketAc(String connectionToken) {
    final basliklar = {_devKullaniciBasligi: actorId};
    return (_kanalAcici ?? _varsayilanKanalAc)(url, basliklar);
  }

  static WebSocketChannel _varsayilanKanalAc(Uri url, Map<String, String> basliklar) =>
      IOWebSocketChannel.connect(url, headers: basliklar);

  // K77/6 PAZARLIKSIZ: `arguments` icerigi okunmaz, sinyal yalniz uyandirma
  // zilidir; `cursorHint` de ayni gerekceyle yoksayilir.
  // T2/6: bu bir PROTOKOL keepalive'idir, YOKLAMA DEGILDIR -- `/v1/sync`e DOKUNMAZ.
  bool _tekMesajiIsle(String parca) {
    return false;
  }
}
"""

_TEMIZ_DIGER = """class Baska {
  void yap() {
    print('yoklama yok, zamanlayici da yok');
  }
}
"""


def _fixture(sinyal=None, diger=None, rozet=None):
    d = {"src/client/lib/ag/signalr_json_sinyal.dart": sinyal or _TEMIZ_SINYAL}
    if diger is not None:
        d["src/client/lib/veri/gorev_deposu.dart"] = diger
    if rozet is not None:
        d["src/client/lib/sunum/senkron_rozeti.dart"] = rozet
    return d


def _vaka(sonuclar, ad, dosyalar, beklenen_kodlar, icermeli=None):
    """[K81] `icermeli`: bulgu METINLERINDEN birinde gecmesi ZORUNLU alt dizge.

    Gerekce olculdu: `_vaka` yalniz KODLARI (Y1/Y2/...) karsilastiriyordu; iki
    farkli Y1 bacagi (beyaz liste vs yasakli govde) ayirt EDILEMIYORDU, dolayisiyla
    "govde bacagi kosuyor mu?" sorusunu altin kume SORAMIYORDU.
    """
    bulgular = tara(dosyalar)
    olculen = sorted(set(k for k, _, _ in bulgular))
    gecti = olculen == sorted(set(beklenen_kodlar))
    if icermeli is not None:
        gecti = gecti and any(icermeli in mesaj for _, _, mesaj in bulgular)
    sonuclar.append((gecti, ad, sorted(set(beklenen_kodlar)), olculen, bulgular))


def altin_kume():
    sonuclar = []

    _vaka(sonuclar, "1) TEMIZ (iki dosya) -- SUSMALI", _fixture(diger=_TEMIZ_DIGER), [])

    _vaka(
        sonuclar, "2) Y1 BEYAZ LISTE DISI -- baska dosyada Timer -- ISIRMALI",
        _fixture(diger=_TEMIZ_DIGER.replace(
            "void yap() {",
            "void yap() {\n    Timer.periodic(Duration(seconds: 5), (_) {});",
        )),
        ["Y1"],
    )

    _vaka(
        sonuclar, "3) Y1 YASAKLI GOVDE -- beyaz listedeki dosyada bile cekmeTuruCalistir -- ISIRMALI",
        _fixture(sinyal=_TEMIZ_SINYAL.replace(
            'kanal.sink.add(\'{"type":6}\');',
            'kanal.sink.add(\'{"type":6}\'); cekmeTuruCalistir();',
        )),
        ["Y1"],
    )

    _vaka(
        sonuclar, "4) Y1 YASAKLI GOVDE -- SenkronAgi gecen bir zamanlayici -- ISIRMALI",
        _fixture(sinyal=_TEMIZ_SINYAL.replace(
            "unawaited(_baglanmayiDene());",
            "unawaited(_baglanmayiDene()); SenkronAgi x = SenkronAgi();",
        )),
        ["Y1"],
    )

    _vaka(
        sonuclar, "5) Y2 -- 'arguments' KOD satirinda -- ISIRMALI",
        _fixture(sinyal=_TEMIZ_SINYAL.replace(
            "return false;", "return mesaj['arguments'] != null;",
        )),
        ["Y2"],
    )

    _vaka(
        sonuclar, "6) Y2 -- 'cursorHint' KOD satirinda -- ISIRMALI",
        _fixture(sinyal=_TEMIZ_SINYAL.replace(
            "return false;", "final x = govde['cursorHint'];",
        )),
        ["Y2"],
    )

    _vaka(
        sonuclar, "7) Y3 -- '/v1/sync' KOD satirinda -- ISIRMALI",
        _fixture(sinyal=_TEMIZ_SINYAL.replace(
            "return false;", "print('/v1/sync');",
        )),
        ["Y3"],
    )

    _vaka(
        sonuclar, "8) Y3 -- '/v1/sync' YALNIZ yorumda -- SUSMALI (yanlis-pozitif kontrolu)",
        _fixture(sinyal=_TEMIZ_SINYAL + "\n// bu satir /v1/sync'ten SOZ EDER ama koda DEGIL\n"),
        [],
    )

    _vaka(
        sonuclar, "9) Y4 -- negotiate basligi eksik -- ISIRMALI",
        _fixture(sinyal=_TEMIZ_SINYAL.replace(
            "headers: {_devKullaniciBasligi: actorId}", "headers: {}",
        )),
        ["Y4"],
    )

    _vaka(
        sonuclar, "10) Y4 -- WS govdesinde baslik HESAPLANMIYOR -- ISIRMALI",
        _fixture(sinyal=_TEMIZ_SINYAL.replace(
            "final basliklar = {_devKullaniciBasligi: actorId};", "final basliklar = <String, String>{};",
        )),
        ["Y4"],
    )

    _vaka(
        sonuclar, "11) Y4 -- IOWebSocketChannel.connect 'headers:' TASIMIYOR (M73 senaryosu) -- ISIRMALI",
        _fixture(sinyal=_TEMIZ_SINYAL.replace(
            "IOWebSocketChannel.connect(url, headers: basliklar)", "IOWebSocketChannel.connect(url)",
        )),
        ["Y4"],
    )

    _vaka(
        sonuclar, "12) Timer( YALNIZ yorumda gecen baska dosya -- SUSMALI (yanlis-pozitif kontrolu)",
        _fixture(diger=_TEMIZ_DIGER + "\n// eskiden burada bir Timer(...) vardi, kaldirildi\n"),
        [],
    )


    # ---- K81 ile eklenen uc vaka (sembol bazli beyaz liste) ----
    _vaka(
        sonuclar,
        "13) K81 -- beyaz listedeki SEMBOL (senkron_rozeti::_DonenOkState) -- SUSMALI",
        _fixture(diger=_TEMIZ_DIGER, rozet="import 'dart:async';\nclass _DonenOkState {\n  void baslat() {\n    Timer.periodic(Duration(seconds: 1), (_) {});\n  }\n}\n"),
        [],
    )

    _vaka(
        sonuclar,
        "14) K81 -- AYNI dosyada BASKA sembolde Timer -- ISIRMALI (dosya butunu affedilmez)",
        _fixture(diger=_TEMIZ_DIGER, rozet="import 'dart:async';\nclass _BaskaWidgetState {\n  void baslat() {\n    Timer.periodic(Duration(seconds: 1), (_) {});\n  }\n}\n"),
        ["Y1"],
        icermeli="BEYAZ LISTE DISI",
    )

    _vaka(
        sonuclar,
        "15) K81 -- beyaz listedeki sembolde BILE senkron ceken govde -- GOVDE BACAGI ISIRMALI",
        _fixture(diger=_TEMIZ_DIGER, rozet="import 'dart:async';\nclass _DonenOkState {\n  void baslat() {\n    Timer.periodic(Duration(seconds: 1), (_) { dongu.cekmeTuruCalistir(); });\n  }\n}\n"),
        ["Y1"],
        icermeli="YOKLAMA SUPHESI",
    )

    cizgi = "=" * 78
    print(cizgi)
    print("ALTIN KUME -- YOKLAMA YASAGI KAPISININ KENDI KANITI (aga cikmaz, kor kapi yok)")
    print(cizgi)
    hepsi = True
    for gecti, ad, beklenen, olculen, bulgular in sonuclar:
        print("\n[%s] %s" % ("GECTI" if gecti else "KALDI", ad))
        print("    beklenen: %s | olculen: %s" % (beklenen or "[]", olculen or "[]"))
        if not gecti:
            hepsi = False
            for kod, dosya, mesaj in bulgular:
                print("        [%s] %s -- %s" % (kod, dosya, mesaj))
    print("\n" + cizgi)
    print("%d/%d vaka GECTI" % (sum(1 for s in sonuclar if s[0]), len(sonuclar)))
    if hepsi:
        print("HUKUM: ARAC KULLANILABILIR -- temizde susuyor, kirlide isiriyor.")
        print(cizgi)
        return 0
    print("HUKUM: ARAC KULLANILAMAZ -- altin kume KALDI. Gercek tarama HUKUM VERMEZ.")
    print(cizgi)
    return 1


# ============================== RAPOR / CLI ==================================

def rapor(bulgular, dosyalar, kok):
    cizgi = "=" * 78
    print(cizgi)
    print("YOKLAMA YASAGI KAPISI (G12/T5) v%s" % SURUM)
    print("kok dizin    : %s" % kok)
    print("taranan lib  : %s (%d .dart dosyasi)" % (os.path.join(kok, LIB_ALT_YOLU), len(dosyalar)))
    print(cizgi)

    if bulgular:
        print("\nBULGU (%d):" % len(bulgular))
        for kod, dosya, mesaj in bulgular:
            print("  [%s] %s -- %s" % (kod, dosya, mesaj))
    else:
        print("\nBULGU YOK: Y1-Y4 hepsi TEMIZ.")

    print("\n" + cizgi)
    print("BEYAN EDILMIS SINIRLAR:")
    print(" - Y3'un mutanti YOK (GOREV §3) -- yapay enjeksiyon degil, acikca borclu.")
    print(" - Yorum soyma tek-satirlik `/* */` + `//` sonrasi icindir; cok satirli")
    print("   `/* */` icindeki literal KACABILIR (design-token-kapisi.py'de olculmus sinir).")
    print(" - Y3, GOREV metninde SESSIZ kalinan bir noktada YORUM-DISI metin uzerinde")
    print("   calisir (Y2 ile AYNI yontem) -- gerekce dosyanin basinda yazili.")
    print(cizgi)

    return 1 if bulgular else 0


def main(argv):
    ap = argparse.ArgumentParser(description="Momentum yoklama yasagi + sinyal protokolu kapisi (G12/T5)")
    ap.add_argument("kok", nargs="?", help="proje kok dizini (orn. .)")
    ap.add_argument("--altin-kume", action="store_true",
                     help="araci kendi altin kumesinde kanitla (cikis 0 olmali)")
    ap.add_argument("--kanit", default=None, help="ozet KANIT dosyasi yolu")
    a = ap.parse_args(argv)

    if a.altin_kume:
        return altin_kume()

    if not a.kok:
        ap.print_usage()
        print("HATA: kok dizin gerekli (ya da --altin-kume).")
        return 2
    if not os.path.isdir(a.kok):
        print("HATA: dizin yok: %s" % a.kok)
        return 2

    dosyalar = dart_dosyalarini_oku(a.kok)
    if not dosyalar:
        print("ORTAM HATASI: %s altinda .dart dosyasi bulunamadi" % os.path.join(a.kok, LIB_ALT_YOLU))
        return 3

    bulgular = tara(dosyalar)
    kod = rapor(bulgular, dosyalar, a.kok)

    if a.kanit:
        os.makedirs(os.path.dirname(a.kanit) or ".", exist_ok=True)
        with open(a.kanit, "w", encoding="utf-8", newline="\n") as f:
            f.write("kok dizin: %s\n" % a.kok)
            f.write("taranan dosya sayisi: %d\n" % len(dosyalar))
            f.write("bulgu: %s\n" % bulgular)

    return kod


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

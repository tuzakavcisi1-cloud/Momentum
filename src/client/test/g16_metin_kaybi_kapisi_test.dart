@TestOn('vm')
library;

// GOREV-A8 (v2) [K90/spec] -- G16 lib/sunum METIN KAYBI KAPISI.
//
// NEDEN VAR: `lib/sunum` altinda bes yerde (Y1-Y5) `Text` `overflow:
// TextOverflow.ellipsis` tasiyor ama `maxLines` TASIMIYORDU (v1'in oldugu
// yer, spec SS0). Olculmus mekanizma (B3, KANIT/A7/02-COZUM-OLCUM.txt
// varyant A): bu kombinasyon metni FIILEN tek satira indirir ve fazlasini
// SESSIZCE atar. Bu kapi o kombinasyonun DUZELTILDIGINI dogrudan olcer.
//
// TEK MEKANIZMA (spec SS4): `ellipsis` KALIR (a11y_statik_tasma_test bunu
// zorunlu kilar) + yanina ACIK bir `maxLines` gelir. Kaydirma bu dilimde
// YOK (S5) -- `A4` onu ISTERSE ortaya cikarir, ayri dilim acilir.
//
// IZGARA: olcek 1.0/1.5/2.0 x genislik 320/360/411 dp -- dokuz nokta.
//
// GOREV-A9 [K93/spec SS5/G16] -- GENISLETME: Y6 (AppBar basligi) + Y7 (govde,
// CakismaCozumSayfasi) eklendi. Uc liste: `_hepsi`=7 (A2) · `_a3Kapsami`=6
// (A3, Y6 HARIC) · `_olcumKapsami`=5 (A1/A4, Y1+Y6 HARIC). `A0` kod ici
// kapsam korumasi bu ucunun UYELIGINI (uzunluk DEGIL) dogrular.
//
// POZITIF KONTROL (huk mvermeden ONCE): v1'in harness'i izgarayi hedefe
// hic ulastirmiyordu (denetim bulgusu). Burada iki sey ONCE dogrulanir:
//  (a) etkin textScaler izgara olcegine ESIT (butun Y1-Y5 icin),
//  (b) RenderParagraph.constraints.maxWidth beklenen degere ESIT -- YALNIZ
//      Y2-Y5 icin: bunlarin genislik formulu DUZ bir Padding cikarmasidir.
//      Y1 (GorevSatiri baslik) BEYAN EDILMIS SINIR: genisligi Row/Expanded
//      ile rozetle PAYLASILAN bir deger olup "genislik - yatay padding"
//      bicimine UYMAZ (G14'un kendi `_dikeyMi` formulune bakiniz); bu
//      kapi Y1 icin yalniz OLCEK yarisini dogrular, GENISLIK yarisini
//      DEGIL -- Y1'in TEK hukmu zaten A2'dir (asagida).
//  Y4 (TextButton etiketi) icin beklenen genislik butonun KENDI ic yatay
//      dolgusunu da CIKARIR; bu dolgu olculdu (probe, oturum 42, GOREV-A8):
//      320/360/411 dp'nin ucunde de AYNI -- yalniz OLCEGE gore degisir
//      (Material'in `ButtonStyleButton` govdesi textScale arttikca ic
//      dolguyu azaltir): 1.0x -> 24, 1.5x -> 20, 2.0x -> 16 (toplam yatay).
//
// dart:io yok -- @TestOn('vm') PAZARLIKSIZ DEGIL burada (kaynak taramasi
// yapmiyoruz) ama G13/G14 ile AYNI ailede kaldigi icin ayni etiket
// korunuyor; dosyanin hicbir yerinde dart:io kullanilmiyor, yalniz aile
// tutarliligi icin.

import 'package:client/design/metinler.dart';
import 'package:client/design/tokens.dart';
import 'package:client/sunum/bos_durum.dart';
import 'package:client/sunum/cakisma_rozeti.dart';
import 'package:client/sunum/gorev_satiri.dart';
import 'package:client/sunum/hata_durumu.dart';
import 'package:client/sunum/senkron_rozeti.dart';
import 'package:client/sunum/yukleme_durumu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const List<double> _olcekler = <double>[1.0, 1.5, 2.0];
const List<double> _genislikler = <double>[320.0, 360.0, 411.0];

// Y4 -- olculmus (probe, oturum 42): TextButton'in TOPLAM yatay ic dolgusu,
// olcege gore. 320/360/411dp'nin UCUNDE de AYNI (yalniz olcege bagli) --
// KANIT/A8/00-OLCUM.txt bu olcumu tasimaz (o dosya SATIR sayisini olcer);
// bu deger ayri bir prob kosumuyla dogrulandi.
double _y4ButonYatayDolgu(double olcek) {
  if (olcek == 1.0) return 24.0;
  if (olcek == 1.5) return 20.0;
  if (olcek == 2.0) return 16.0;
  throw ArgumentError('izgaranin disinda olcek: $olcek');
}

/// GOREV-SS2 [T5]: `Y6`/`Y7` icin minimal sahte depo -- `CakismaCozumSayfasi`
/// artik `entityId`+`depo` alir (M184). `a11y_kapisi_test.dart`'in `_SabitDepo`
/// deseninin aynisi, dosyaya OZGU (Dart gorunurlugu dosya-bazlidir).
class _SahteDepoY6Y7 implements GorevDeposu {
  final List<CakismaKaydi> _kayitlar;
  const _SahteDepoY6Y7(this._kayitlar);

  @override
  Stream<List<GorevGorunum>> gorevlerGorunur() => const Stream.empty();
  @override
  Future<void> ekle(String baslik) async {}
  @override
  Future<void> duzenle(String id, String yeniBaslik) async {}

  // ODEV.md §4(a): arayuze eklenen yeni yazma yolu. Bu sahte depo onu
  // KULLANMAZ -- govde bilerek bostur (mevcut `duzenle` stub'inin aynisi).
  @override
  Future<void> ayrintilariGuncelle(
    String id, {
    Yazim<String>? baslik,
    Yazim<int?>? oncelik,
    Yazim<DateTime?>? sonTarih,
    Set<String>? etiketEklenen,
    Set<String>? etiketSilinen,
  }) async {}
  @override
  Future<void> tamamlaGeriAl(String id, {required bool tamamlandi}) async {}
  @override
  Future<void> sil(String id) async {}
  @override
  Stream<List<CakismaKaydi>> cakismaKayitlariniIzle(String entityId) => Stream.value(_kayitlar);
  @override
  Future<void> cakismaCoz(String entityId, CakismaSecimi secim) async {}
}

// GOREV-SS2 [T5]: Y7'nin govde olcumu icin UZUN bir cakisma degeri --
// eski Y1 fixture'iyla (uzun baslik) AYNI gerekce: kisa bir dize kapiyi
// KORLESTIRIR.
const _y7Kayit = CakismaKaydi(
  alan: 'fields:title',
  kaybedenDeger: 'Sozlesmeyi gozden gecir ve imzala ve sonra raporu tamamla',
  kazananDeger: 'Baska bir cihazdan gelen uzun baslik metni burada devam eder',
);

Gorev _y1Gorev() => Gorev(
  id: 'g16-y1',
  // Uzun baslik BILINCLI (g13_rozet_tasma_kapisi_test.dart:51-53 ile ayni
  // gerekce): kisa bir baslik yazmak kapiyi KORLESTIRIR.
  baslik: 'Sozlesmeyi gozden gecir ve imzala ve sonra raporu tamamla',
  tamamlandi: false,
  olusturuldu: DateTime.utc(2026, 7, 30, 12),
  guncellendi: DateTime.utc(2026, 7, 30, 12),
  senkronDurumu: 'yerel',
  silindi: false,
);

/// Bes yerin ORTAK modeli: nasil pompalanir, Text'i nasil bulunur, pozitif
/// kontrolun genislik yarisi (varsa) nasil hesaplanir.
class _Bilesen {
  final String kod;
  final String aciklama;
  final Widget Function() olustur;
  final Finder Function() bul;
  final double Function(double genislik, double olcek)? beklenenGenislik;

  const _Bilesen({
    required this.kod,
    required this.aciklama,
    required this.olustur,
    required this.bul,
    this.beklenenGenislik,
  });
}

final _y1 = _Bilesen(
  kod: 'Y1',
  aciklama: 'gorev_satiri.dart:135 (baslik)',
  olustur: () => GorevSatiri(
    gorev: _y1Gorev(),
    onTamamlaDegisti: (_) {},
    senkronDurumu: SenkronDurumTuru.yerel,
  ),
  bul: () => find.text(_y1Gorev().baslik),
  // BEYAN EDILMIS SINIR (yukarida): Y1 genislik formulu Row/Expanded
  // paylasimina bagli, "genislik - yatay padding" degil -- kontrol edilmez.
);

final _y2 = _Bilesen(
  kod: 'Y2',
  aciklama: 'bos_durum.dart:15 (Metinler.bosDurum)',
  olustur: () => const BosDurum(),
  bul: () => find.text(Metinler.bosDurum),
  beklenenGenislik: (g, s) => g - 2 * MBosluk.l,
);

final _y3 = _Bilesen(
  kod: 'Y3',
  aciklama: 'hata_durumu.dart:47 (Metinler.birSeylerTersGitti)',
  olustur: () => HataDurumu(onYenidenDene: () {}),
  bul: () => find.text(Metinler.birSeylerTersGitti),
  beklenenGenislik: (g, s) => g - 2 * MBosluk.m,
);

final _y4 = _Bilesen(
  kod: 'Y4',
  aciklama: 'hata_durumu.dart:56 (Metinler.yenidenDene, TextButton etiketi)',
  olustur: () => HataDurumu(onYenidenDene: () {}),
  bul: () => find.text(Metinler.yenidenDene),
  beklenenGenislik: (g, s) => g - 2 * MBosluk.m - _y4ButonYatayDolgu(s),
);

final _y5 = _Bilesen(
  kod: 'Y5',
  aciklama: 'yukleme_durumu.dart:43 (Metinler.yukleniyor)',
  olustur: () => const YuklenmeDurumu(),
  bul: () => find.text(Metinler.yukleniyor),
  beklenenGenislik: (g, s) => g,
);

// GOREV-A9 [K93/spec SS5/G16]: `_y6` -- AppBar basligi. YALNIZ A2'ye girer:
// A1/A4'e giremez (olcek kelepcesi, _kMaxTitleTextScaleFactor=1.34 -- spec
// SS0/2, SS8/S1), A3'e de girmez (spec SS8/S4: A3 `bul()` KULLANMAZ, yalniz
// `olustur()`'u pompalayip `takeException()`'a bakar -- `_y6` ile `_y7` AYNI
// sayfayi urettigi icin A3'te BIREBIR AYNI testi uretirdi; sayi dekoratif
// test tasimaz).
final _y6 = _Bilesen(
  kod: 'Y6',
  aciklama: 'cakisma_rozeti.dart (AppBar basligi, Metinler.duyuruCakismaVar)',
  olustur: () => const CakismaCozumSayfasi(entityId: 'y6', depo: _SahteDepoY6Y7([])),
  bul: () => find.text(Metinler.duyuruCakismaVar),
  // BEYAN EDILMIS SINIR: genislik formulu YOK -- yalniz OLCEK yarisi (A2)
  // kontrol edilir (yukaridaki gerekce).
);

// GOREV-SS2 [T5 -- ONCEKI Y7 GECERSIZ, YENIDEN OLCULDU]: govde artik TEK
// merkezi Text DEGIL, YAN YANA iki deger blogu (Ö11 sonrasi olcum). Yapi:
// Scaffold.body -> StreamBuilder -> ListView(padding: all(MBosluk.m)) ->
// Row(2x Expanded, aralarinda SizedBox(width: MBosluk.m)) -> Column -> Text.
// Genislik formulu: (g - 2*MBosluk.m [liste dolgusu] - MBosluk.m [Row araligi]) / 2.
// A1+A4'e girer (_olcumKapsami).
final _y7 = _Bilesen(
  kod: 'Y7',
  aciklama: 'cakisma_rozeti.dart (govde, deger blogu -- kaybedenDeger)',
  olustur: () => const CakismaCozumSayfasi(entityId: 'y7', depo: _SahteDepoY6Y7([_y7Kayit])),
  bul: () => find.text(_y7Kayit.kaybedenDeger),
  beklenenGenislik: (g, s) => (g - 3 * MBosluk.m) / 2,
);

final _hepsi = <_Bilesen>[_y1, _y2, _y3, _y4, _y5, _y6, _y7]; // A2 -- 7
final _a3Kapsami = <_Bilesen>[_y1, _y2, _y3, _y4, _y5, _y7]; // A3 -- 6, Y6 HARIC (SS4)
final _olcumKapsami = <_Bilesen>[_y2, _y3, _y4, _y5, _y7]; // A1/A4 -- 5, Y1+Y6 HARIC (SS1)

// GOREV-A9 [K93]: PUBLIC (alt cizgisiz) -- `_a9_probe_test.dart` bu
// sarmalayiciyi DOGRUDAN kullanmak ZORUNDA (spec kriter 2: "kendi kurulumunu
// yazmak YASAKTIR"); Dart gorunurlugu dosya-bazlidir, private bir top-level
// fonksiyon baska bir test dosyasindan import EDILEMEZ.
Widget sarmalayici({
  required double genislik,
  required double olcek,
  required Widget bilesen,
}) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        final taban = MediaQuery.of(context);
        return MediaQuery(
          data: taban.copyWith(textScaler: TextScaler.linear(olcek)),
          // Scaffold: G13/G14'un (ayni GorevSatiri'yi pompalayan, halihazirda
          // yesil/altin) KENDI kurulumuyla AYNI -- Checkbox bir `Material`
          // atasi ister; onsuz Row/Column RenderFlex tasmasi (olculdu, ilk
          // kosum: cikbox Material olmadan intrinsic genisligini yanlis
          // hesapliyor, 100000px). Y2-Y5 icin de gercek uretimde (Gorev
          // ListesiEkrani/DurumVitrini) HER ZAMAN bir Scaffold var -- bu
          // yuzden hepsi icin AYNI, DAHA SADIK kurulum.
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              // GENISLIK TIGHT, YUKSEKLIK GEVSEK (maxHeight budget): duz
              // `SizedBox(height: h)` HER IKI ekseni de TIGHT yapar --
              // GorevSatiri'nin (Y1) KOKU `Container` (Center DEGIL) tight
              // yuksekligi OLDUGU GIBI alt Column'a iletir ve mainAxisSize.min
              // ile CATISIR. Y2-Y5 `Center` kokludur (Center HER ZAMAN
              // gevsetir) ve bu farki GIZLERDI -- bu yuzden butun bes yer
              // icin AYNI gevsek desen.
              child: SizedBox(
                width: genislik,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 2000),
                  child: bilesen,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// Bilesen'i pompalar, POZITIF KONTROLU (huk mvermeden ONCE) uygular ve
/// olculen RenderParagraph'i doner.
Future<RenderParagraph> _pompalaVeDogrula(
  WidgetTester tester,
  _Bilesen b,
  double genislik,
  double olcek,
) async {
  await tester.pumpWidget(
    sarmalayici(genislik: genislik, olcek: olcek, bilesen: b.olustur()),
  );
  await tester.pump();

  final rp = tester.renderObject<RenderParagraph>(b.bul());

  expect(
    rp.textScaler,
    TextScaler.linear(olcek),
    reason:
        'POZITIF KONTROL ISIRDI (${b.kod}, ${genislik}dp x ${olcek}x): '
        'etkin textScaler izgara olcegine esit degil -- harness izgarayi '
        'hedefe ULASTIRMIYOR (v1 kusuru).',
  );
  if (b.beklenenGenislik != null) {
    final beklenen = b.beklenenGenislik!(genislik, olcek);
    expect(
      rp.constraints.maxWidth,
      moreOrLessEquals(beklenen, epsilon: 0.5),
      reason:
          'POZITIF KONTROL ISIRDI (${b.kod}, ${genislik}dp x ${olcek}x): '
          'constraints.maxWidth=${rp.constraints.maxWidth}, beklenen=$beklenen '
          '-- harness izgarayi hedefe ULASTIRMIYOR (v1 kusuru).',
    );
  }
  return rp;
}

void main() {
  group('G16/A0 -- kod ici kapsam korumasi (UYELIK, uzunluk DEGIL)', () {
    // GOREV-A9 [K93/spec SS5/G16]: uzunluk iddiasi bir TAKASI (ör.
    // _olcumKapsami'nda _y7 yerine _y1) YAKALAMAZ -- UYELIK dogrulanir.
    test('_hepsi / _a3Kapsami / _olcumKapsami kodlari TAM olarak beklenen', () {
      expect(
        _hepsi.map((b) => b.kod).toList(),
        <String>['Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7'],
        reason: '_hepsi (A2 kapsami) beklenen kod kumesinden SAPTI.',
      );
      expect(
        _a3Kapsami.map((b) => b.kod).toList(),
        <String>['Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y7'],
        reason:
            '_a3Kapsami beklenen kod kumesinden SAPTI -- Y6 burada OLMAMALI: '
            'A3 bul() KULLANMAZ (yalniz olustur()+takeException()), Y6 ile Y7 '
            'AYNI sayfayi urettigi icin A3\'te BIREBIR AYNI testi uretirdi.',
      );
      expect(
        _olcumKapsami.map((b) => b.kod).toList(),
        <String>['Y2', 'Y3', 'Y4', 'Y5', 'Y7'],
        reason:
            '_olcumKapsami beklenen kod kumesinden SAPTI -- Y1 burada '
            'OLMAMALI (liste satirinda kayip KABUL EDILIR, S1); Y6 burada '
            'OLMAMALI (AppBar olcek kelepcesi, izgara oraya ULASMAZ, S1).',
      );
    });
  });

  group(
    'G16/A1 -- yalniz Y2-Y5+Y7: RenderParagraph.didExceedMaxLines FALSE olmali',
    () {
    // SS1 (spec 5/6): Y1 burada YOK -- maxLines:1 alir ve 320dp x 2.0x'te
    // gercekci her baslikta didExceedMaxLines=true olur; S1'in "Y1'de kayip
    // KABUL EDILIR" beyaniyla dogrudan CATISIRDI. Y1 A2 ile olculur.
    // GOREV-A9 [K93]: Y6 da YOK -- AppBar olcek kelepcesi ($1.34$), izgaranin
    // 1.5x/2.0x ayaklari oraya ULASMAZ (spec SS4/Y6, SS8/S1). Y6 A2 ile olculur.
    for (final b in _olcumKapsami) {
      for (final olcek in _olcekler) {
        for (final genislik in _genislikler) {
          testWidgets('${b.kod}: ${genislik}dp x ${olcek}x -- kirpma YOK', (
            tester,
          ) async {
            final rp = await _pompalaVeDogrula(tester, b, genislik, olcek);
            expect(
              rp.didExceedMaxLines,
              isFalse,
              reason:
                  '${b.kod} (${b.aciklama}) KIRPILDI (${genislik}dp x ${olcek}x) -- '
                  'maxLines yetersiz.',
            );
          });
        }
      }
    }
  });

  group('G16/A2 -- Y1-Y7 (hepsi): her Text maxLines!=null VE overflow==ellipsis', () {
    // Y1'in TEK olcusu budur (SS1): liste satirinda maxLines:1 + ellipsis,
    // kayip a11y_statik_tasma_test ile UYUMLU sekilde KABUL EDILIR.
    // GOREV-A9 [K93]: Y6'nin da TEK olcusu budur (AppBar basligi, olcek
    // kelepceli -- A1/A3/A4'e giremez).
    for (final b in _hepsi) {
      for (final olcek in _olcekler) {
        for (final genislik in _genislikler) {
          testWidgets('${b.kod}: ${genislik}dp x ${olcek}x -- maxLines+ellipsis beyani', (
            tester,
          ) async {
            await tester.pumpWidget(
              sarmalayici(genislik: genislik, olcek: olcek, bilesen: b.olustur()),
            );
            await tester.pump();
            final widget = tester.widget<Text>(b.bul());
            expect(
              widget.maxLines,
              isNotNull,
              reason: '${b.kod} (${b.aciklama}) maxLines TASIMIYOR.',
            );
            expect(
              widget.overflow,
              TextOverflow.ellipsis,
              reason: '${b.kod} (${b.aciklama}) overflow:ellipsis TASIMIYOR.',
            );
          });
        }
      }
    }
  });

  group(
    'G16/A3 -- Y1-Y5+Y7 (Y6 HARIC): tester.takeException() null (RenderFlex tasmasi yakalanir)',
    () {
    // GOREV-A9 [K93/spec SS8/S4]: Y6 burada YOK -- A3 `bul()` KULLANMAZ,
    // yalniz `olustur()`'u pompalayip `takeException()`'a bakar; `_y6` ile
    // `_y7` AYNI sayfayi (CakismaCozumSayfasi) urettigi icin burada
    // BIREBIR AYNI testi uretirdi -- sayi dekoratif test tasimaz.
    for (final b in _a3Kapsami) {
      for (final olcek in _olcekler) {
        for (final genislik in _genislikler) {
          testWidgets('${b.kod}: ${genislik}dp x ${olcek}x -- istisna yok', (
            tester,
          ) async {
            await tester.pumpWidget(
              sarmalayici(genislik: genislik, olcek: olcek, bilesen: b.olustur()),
            );
            await tester.pump();
            expect(
              tester.takeException(),
              isNull,
              reason:
                  '${b.kod} (${b.aciklama}) ${genislik}dp x ${olcek}x noktasinda '
                  'beklenmeyen istisna (ör. RenderFlex tasmasi) firladi.',
            );
          });
        }
      }
    }
  });

  group(
    'G16/A4 -- yalniz Y2-Y5+Y7: cizilen kutu metnin ISTEDIGI yuksekligi KISALTMAMALI',
    () {
      // Olcu DUZELTILDI (denetim, oturum 42): size.height <= maxHeight HER
      // ZAMAN dogrudur (constraints.constrain), o yuzden hukum vermez.
      // Gercek kayip: size.height, metnin ISTEDIGI (minIntrinsic) yukseklikten
      // KUCUK kaliyor mu -- rp.getMinIntrinsicHeight(rp.constraints.maxWidth)
      // ile ACIK API'den olculur.
      for (final b in _olcumKapsami) {
        for (final olcek in _olcekler) {
          for (final genislik in _genislikler) {
            testWidgets(
              '${b.kod}: ${genislik}dp x ${olcek}x -- dikey sessiz kirpma yok',
              (tester) async {
                final rp = await _pompalaVeDogrula(tester, b, genislik, olcek);
                final gerekenYukseklik = rp.getMinIntrinsicHeight(
                  rp.constraints.maxWidth,
                );
                expect(
                  rp.size.height,
                  greaterThanOrEqualTo(gerekenYukseklik),
                  reason:
                      '${b.kod} (${b.aciklama}) ${genislik}dp x ${olcek}x -- '
                      'cizilen yukseklik ${rp.size.height}, istenen '
                      '$gerekenYukseklik -- DIKEY SESSIZ KIRPMA (S8).',
                );
              },
            );
          }
        }
      }
    },
  );
}

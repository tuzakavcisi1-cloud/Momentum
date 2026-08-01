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
// IZGARA: olcek 1.0/1.5/2.0 x genislik 320/360/411 dp -- dokuz nokta, bes
// yerin HER BIRI icin.
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

final _hepsi = <_Bilesen>[_y1, _y2, _y3, _y4, _y5];
final _olcumKapsami = <_Bilesen>[_y2, _y3, _y4, _y5]; // A1/A4 -- Y1 HARIC (SS1)

Widget _sarmalayici({
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
    _sarmalayici(genislik: genislik, olcek: olcek, bilesen: b.olustur()),
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
  group('G16/A1 -- yalniz Y2-Y5: RenderParagraph.didExceedMaxLines FALSE olmali', () {
    // SS1 (spec 5/6, denetim oturum 42): Y1 burada YOK -- maxLines:1 alir
    // ve 320dp x 2.0x'te gercekci her baslikta didExceedMaxLines=true olur;
    // S1'in "Y1'de kayip KABUL EDILIR" beyaniyla dogrudan CATISIRDI. Y1
    // A2 ile olculur.
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

  group('G16/A2 -- Y1-Y5: her Text maxLines!=null VE overflow==ellipsis', () {
    // Y1'in TEK olcusu budur (SS1): liste satirinda maxLines:1 + ellipsis,
    // kayip a11y_statik_tasma_test ile UYUMLU sekilde KABUL EDILIR.
    for (final b in _hepsi) {
      for (final olcek in _olcekler) {
        for (final genislik in _genislikler) {
          testWidgets('${b.kod}: ${genislik}dp x ${olcek}x -- maxLines+ellipsis beyani', (
            tester,
          ) async {
            await tester.pumpWidget(
              _sarmalayici(genislik: genislik, olcek: olcek, bilesen: b.olustur()),
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

  group('G16/A3 -- Y1-Y5: tester.takeException() null (RenderFlex tasmasi yakalanir)', () {
    for (final b in _hepsi) {
      for (final olcek in _olcekler) {
        for (final genislik in _genislikler) {
          testWidgets('${b.kod}: ${genislik}dp x ${olcek}x -- istisna yok', (
            tester,
          ) async {
            await tester.pumpWidget(
              _sarmalayici(genislik: genislik, olcek: olcek, bilesen: b.olustur()),
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
    'G16/A4 -- yalniz Y2-Y5: cizilen kutu metnin ISTEDIGI yuksekligi KISALTMAMALI',
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

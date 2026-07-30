@TestOn('vm')
library;

// GOREV-A7 [K85 / spec v4 §5] -- G13 KIRPMA KAPISI.
//
// 🔴 HUKMU VEREN TEK OLCU: `RenderParagraph.didExceedMaxLines`.
// `intrinsic`/`size`/`height` hata mesajinda TESHIS icin raporlanir ama
// HUKUM VERMEZ. Olculmus gerekce (KANIT/A7/02-COZUM-OLCUM.txt, varyant
// B/D/F): metin SARIYORKEN ve kirpma YOKKEN de `getMaxIntrinsicWidth`
// 1102,5 kalir ⇒ intrinsic-tabanli bir olcut her sarma cozumunu
// yanlis-pozitifle reddederdi. v3'un `G13_TOLERANS`i bu yuzden KALKTI.
//
// NEDEN BU KAPI VAR: mevcut A11Y-4 kapisi (a11y_kapisi_test.dart:274)
// `expect(tester.takeException(), isNull)`dir ve `TextOverflow.ellipsis`
// FlutterError ATMAZ ⇒ o kapi 1102,50 px isteyip 104,00 px alan bir metin
// icin bile SUSAR (olculdu: KANIT/A7/00-OLCUM-kor-kapi.txt, bagimsiz teyit
// KANIT/A7/01-DENETIM.md §3). G13 o kapinin YERINE gecmez, YANINA gelir --
// o kapi RenderFlex overflow'unu hala yakaliyor.
//
// BEYAN EDILMIS SINIRLAR (spec §8):
//  · S1: yalniz ROZET alt agaci olculur; baslik kirpilmasi KABUL EDILIR.
//  · S3: `flutter_test` FONTUYLA olculur, cihaz fontu FARKLI olcer --
//        gercek gorunum CM1/CM2 ile olculur, bu dosya onun yerine GECMEZ.
//  · S4: 320/360/411dp bir ORNEKLEMDIR; ara genislikler olculmedi.
//  · A3 dart:io kullanir ⇒ @TestOn('vm') PAZARLIKSIZ (web'de dart:io yok).
//    Web ayagi zaten [DOGRULANMADI] (DURUM.md §7: --platform chrome bu
//    ortamda SONUC URETMIYOR).

import 'dart:io';

import 'package:client/design/tokens.dart';
import 'package:client/sunum/gorev_satiri.dart';
import 'package:client/sunum/senkron_rozeti.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const List<double> _olcekler = <double>[1.0, 1.5, 2.0];
const List<double> _genislikler = <double>[320, 360, 411];
const List<SenkronDurumTuru> _durumlar = <SenkronDurumTuru>[
  SenkronDurumTuru.yerel,
  SenkronDurumTuru.kuyrukta,
  SenkronDurumTuru.cevrimdisi,
  SenkronDurumTuru.gonderilmemis,
];
const List<bool> _cakismalar = <bool>[false, true];

Gorev _ornekGorev() => Gorev(
  id: 'g13-ornek',
  // Uzun baslik BILINCLI: rozet ile baslik ayni satirda YARISIYOR; kisa bir
  // baslik yazmak rozete gercekte olmayan bir bolluk verir ve kapiyi
  // KORLESTIRIR (spec §1.4: Expanded/Flexible flex paylasimi).
  baslik: 'Sozlesmeyi gozden gecir ve imzala',
  tamamlandi: false,
  olusturuldu: DateTime.utc(2026, 7, 30, 12),
  guncellendi: DateTime.utc(2026, 7, 30, 12),
  senkronDurumu: 'yerel',
  silindi: false,
);

Widget _sarmalayici({
  required double genislik,
  required double olcek,
  required SenkronDurumTuru durum,
  required bool cakismaVarMi,
}) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        final taban = MediaQuery.of(context);
        return MediaQuery(
          // disableAnimations: true -- 'kuyrukta' varyantinin _DonenOk'u
          // gercek Timer.periodic baslatir ve testler arasi "Timer is still
          // pending" invaryant ihlali uretir (a11y_kapisi_test.dart'ta
          // olculmus ayni kusur).
          data: taban.copyWith(
            disableAnimations: true,
            textScaler: TextScaler.linear(olcek),
          ),
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: genislik,
                child: GorevSatiri(
                  gorev: _ornekGorev(),
                  onTamamlaDegisti: (_) {},
                  senkronDurumu: durum,
                  cakismaVarMi: cakismaVarMi,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

Finder _rozetMetni() => find.descendant(
  of: find.byType(SenkronRozeti),
  matching: find.byType(Text),
);

void main() {
  group('G13/A1 -- KIRPMA YOK: 72 kombinasyon (3 olcek x 3 genislik x 4 durum x 2 cakisma)', () {
    // 🔴 SAYI IDDIASI MEKANIK OLARAK DOGRULANIR -- v3 "96" yazmisti ve
    // 3*3*4*2 = 72'dir (KANIT/A7/01-DENETIM.md §2). Iddia ile liste
    // arasindaki sapma burada TESTLE olculur, ezberden yazilmaz.
    test('kombinasyon sayisi TAM 72', () {
      expect(
        _olcekler.length * _genislikler.length * _durumlar.length * _cakismalar.length,
        72,
      );
    });

    for (final olcek in _olcekler) {
      for (final genislik in _genislikler) {
        for (final durum in _durumlar) {
          for (final cakisma in _cakismalar) {
            testWidgets(
              'olcek=$olcek genislik=$genislik durum=${durum.name} cakisma=$cakisma',
              (tester) async {
                await tester.pumpWidget(
                  _sarmalayici(
                    genislik: genislik,
                    olcek: olcek,
                    durum: durum,
                    cakismaVarMi: cakisma,
                  ),
                );
                await tester.pump();

                final rp = tester.renderObject<RenderParagraph>(_rozetMetni());
                expect(
                  rp.didExceedMaxLines,
                  isFalse,
                  reason:
                      'rozet metni KIRPILDI '
                      '(olcek=$olcek genislik=$genislik durum=${durum.name} '
                      'cakisma=$cakisma) · TESHIS: '
                      'intrinsic=${rp.getMaxIntrinsicWidth(double.infinity)} '
                      'ayrilan=${rp.size.width} yukseklik=${rp.size.height} '
                      '· HUKUM YALNIZ didExceedMaxLines\'tan gelir',
                );
              },
            );
          }
        }
      }
    }
  });

  group('G13/A2 -- senkronize: olculecek Text YOK, kapi susar ama "olctum" DEMEZ', () {
    testWidgets('320dp + 2.0x + senkronize ⇒ rozet Text kumesi BOS', (tester) async {
      await tester.pumpWidget(
        _sarmalayici(
          genislik: 320,
          olcek: 2.0,
          durum: SenkronDurumTuru.senkronize,
          cakismaVarMi: false,
        ),
      );
      await tester.pump();

      // Gurultu azaltma (DESIGN.md §4): 'senkronize' rozet CIZMEZ.
      expect(find.byType(SenkronRozeti), findsOneWidget);
      final metinler = _rozetMetni().evaluate();
      // ACIK BEYAN: bu kume BOS'tur, dolayisiyla A1'in olcusu bu durumda
      // UYGULANAMAZ. "didExceedMaxLines false" DEMIYORUZ -- OLCMEDIK.
      expect(
        metinler,
        isEmpty,
        reason: 'senkronize durumunda gorunur rozet metni OLMAMALI '
            '(SizedBox.shrink) -- bulunursa A1 bu durumu da olcmelidir',
      );
      expect(SenkronRozeti.metinIcin(SenkronDurumTuru.senkronize), isNull);
      expect(SenkronRozeti.tamMetinIcin(SenkronDurumTuru.senkronize), isNull);
    });
  });

  group('G13/A3 -- STATIK: rozet Text\'i maxLines TASIR', () {
    // Olculmus gerekce (spec §1.3): `overflow: ellipsis`, `maxLines`
    // VERILMEDIGINDE metni FIILEN tek satira indiriyor (varyant A) --
    // yani ellipsis zorunlulugu, maxLines olmadan KIRPMA YASAGIYLA
    // CATISIR. Ucu birlikte tutarlidir.
    //
    // KAPSAM BEYANI: taranan dosya rozet metnini tasiyan TEK dosyadir
    // (lib/sunum/senkron_rozeti.dart). CakismaRozeti gorunur rozet metni
    // TASIMAZ -- yalniz Semantics(label:) (spec §8/S8) ⇒ G13 onu olcmez.
    test('lib/sunum/senkron_rozeti.dart icindeki her Text( cagrisi maxLines tasir', () {
      final dosya = File('lib/sunum/senkron_rozeti.dart');
      expect(dosya.existsSync(), isTrue, reason: 'taranacak dosya bulunamadi');

      final satirlar = dosya.readAsLinesSync();
      final textCagrisi = RegExp(r'\bText(\.rich)?\s*\(');
      final maxLinessizlar = <String>[];

      for (var i = 0; i < satirlar.length; i++) {
        if (satirlar[i].trimLeft().startsWith('//')) continue;
        if (!textCagrisi.hasMatch(satirlar[i])) continue;
        // Text(...) cagrisi cok satira yayilir -- kapanan parantezi bul.
        var derinlik = 0;
        var basladi = false;
        final govde = StringBuffer();
        for (var j = i; j < satirlar.length && j < i + 25; j++) {
          govde.writeln(satirlar[j]);
          for (final ch in satirlar[j].split('')) {
            if (ch == '(') {
              derinlik++;
              basladi = true;
            } else if (ch == ')') {
              derinlik--;
            }
          }
          if (basladi && derinlik <= 0) break;
        }
        if (!govde.toString().contains('maxLines')) {
          maxLinessizlar.add('${dosya.path}:${i + 1}: ${satirlar[i].trim()}');
        }
      }

      expect(
        maxLinessizlar,
        isEmpty,
        reason:
            'Asagidaki rozet Text() cagrilari maxLines TASIMIYOR -- '
            'overflow: ellipsis TEK BASINA metni tek satira indirir ve '
            'kirpar (olculdu, varyant A · spec §1.3):\n'
            '${maxLinessizlar.join('\n')}',
      );
    });

    test('MAX_SATIR degeri 1\'den BUYUK ve emniyet payi tasiyor', () {
      // M85 (MAX_SATIR=1) kaynak duzeyinde de gorulur olsun: olculdu, yeni
      // dizgeler 236 px'te 2.0x'te 2 SATIR ⇒ 1 yetmez.
      expect(SenkronRozeti.maxSatir, greaterThanOrEqualTo(2));
      expect(SenkronRozeti.maxSatir, 3);
      expect(MOlcu.ikon, 24);
    });
  });
}

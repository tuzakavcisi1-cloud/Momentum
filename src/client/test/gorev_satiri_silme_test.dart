@TestOn('vm')
library;

// IS-EMRI-o72 -- gorev silme UI'i.
//
// 🔴 BU DOSYA YENI BIR G<n>/D-<x> KAPISI ILAN ETMEZ (is emri §0) --
// `GorevDeposu.sil` ZATEN VAR (gorev_deposu.dart:81/388), eksik olan yalniz
// sunum katmani kablosuydu. Bu, kilitli o68 desenini (`onBaslikDuzenlendi`)
// AYNEN tekrarlayan urun kodu testidir --
// gorev_satiri_duzenleme_test.dart'in BIREBIR AYNI sablonu (is emri §2).
//
// dart:io kullanmaz ama @TestOn('vm') o68/g14 emsaliyle TUTARLILIK icin
// korunur (bu dosyadaki kriter 7 STATIK ayagi dart:io ister).

import 'dart:io';

import 'package:client/design/metinler.dart';
import 'package:client/sunum/gorev_satiri.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Gorev _sahteGorev() => Gorev(
  id: 'g72-ornek',
  baslik: 'Silinecek gorev',
  tamamlandi: false,
  olusturuldu: DateTime.utc(2026, 8, 14),
  guncellendi: DateTime.utc(2026, 8, 14),
  senkronDurumu: 'yerel',
  silindi: false,
);

Widget _sarmala(Widget cocuk) => MaterialApp(home: Scaffold(body: cocuk));

void main() {
  group('IS-EMRI-o72 -- GorevSatiri silme', () {
    testWidgets(
      'T1 -- onSil NULL iken silme ikonu HIC CIZILMEZ (geriye donuk uyum)',
      (tester) async {
        await tester.pumpWidget(
          _sarmala(
            GorevSatiri(gorev: _sahteGorev(), onTamamlaDegisti: (_) {}),
          ),
        );
        expect(find.byIcon(Icons.delete_outline), findsNothing);
      },
    );

    testWidgets(
      'T2 -- onSil verili: ikon var; labeledTapTargetGuideline VE androidTapTargetGuideline gecer',
      (tester) async {
        final tutamac = tester.ensureSemantics();
        await tester.pumpWidget(
          _sarmala(
            GorevSatiri(
              gorev: _sahteGorev(),
              onTamamlaDegisti: (_) {},
              onSil: () {},
            ),
          ),
        );
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
        // NOT: `meetsGuideline(labeledTapTargetGuideline)` bu projenin M7
        // icin kullandigi AYNI OLCUMDUR (gorev_satiri_duzenleme_test.dart
        // emsali) -- Flutter'in ic agac detayina bagli olmadan "etiket VAR
        // ve dokunma hedefiyle ESLESIYOR" sorusunu OTORITER sekilde yanitlar.
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        tutamac.dispose();
      },
    );

    testWidgets(
      'T3a -- ikona dokun -> diyalog acilir -> IPTAL -> onSil CAGRILMAZ',
      (tester) async {
        var cagrildi = false;
        await tester.pumpWidget(
          _sarmala(
            GorevSatiri(
              gorev: _sahteGorev(),
              onTamamlaDegisti: (_) {},
              onSil: () => cagrildi = true,
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text(Metinler.gorevSilOnay), findsOneWidget);

        await tester.tap(find.text(Metinler.iptalDugmesi));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(cagrildi, isFalse);
      },
    );

    testWidgets(
      'T3b -- ikona dokun -> diyalog acilir -> SIL -> onSil TAM BIR KEZ cagrilir',
      (tester) async {
        var cagriSayaci = 0;
        await tester.pumpWidget(
          _sarmala(
            GorevSatiri(
              gorev: _sahteGorev(),
              onTamamlaDegisti: (_) {},
              onSil: () => cagriSayaci++,
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        // NOT: `find.text(Metinler.gorevSil)` diyalog acikken BELIRSIZDIR --
        // hem diyalog basligi hem "Sil" eylem dugmesi AYNI dizgeyi tasir
        // (gorev_satiri_duzenleme_test.dart'in Text/EditableText belirsizligi
        // emsali). `find.widgetWithText(TextButton, Metinler.gorevSil)` ile
        // yalniz EYLEM DUGMESI hedeflenir.
        await tester.tap(
          find.widgetWithText(TextButton, Metinler.gorevSil),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(cagriSayaci, 1);
      },
    );

    // Kriter (is emri §1, T6 PAZARLIKSIZ): "satir hala onTap tasimiyor" --
    // gorev_satiri_duzenleme_test.dart'in AYNI STATIK yontemi (gerekce
    // orada yazili: bir widget testi bunu guvenilir sinayamaz, GestureDetector
    // agac sirasina/derinligine bagli olmadan STATIK tarama daha guvenilir).
    test(
      'kriter (STATIK): build() donen Container -- onTap/GestureDetector TASIMAZ',
      () {
        final kaynak = File(
          'lib/sunum/gorev_satiri.dart',
        ).readAsStringSync();
        final buildM = RegExp(
          r'Widget build\(BuildContext context\) \{.*?\n  \}\n',
          dotAll: true,
        ).firstMatch(kaynak);
        expect(
          buildM,
          isNotNull,
          reason: 'build() metodu BULUNAMADI -- kapi KORLESTI',
        );
        final govde = buildM!.group(0)!;
        expect(
          govde,
          isNot(contains('onTap:')),
          reason: 'build() govdesinde onTap bulundu -- T6 ihlali:\n$govde',
        );
        expect(
          govde,
          isNot(contains('GestureDetector(')),
          reason:
              'build() govdesinde GestureDetector bulundu -- T6 ihlali:\n$govde',
        );
      },
    );
  });
}

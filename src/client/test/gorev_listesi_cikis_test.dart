@TestOn('vm')
library;

// IS-EMRI-o83 s2.2/12: cikis dugmesi -- onYenile/onYerelYazma/depolama'nin
// AYNI "null ise sessizce kapanir" deseni (geriye donuk uyum).

import 'dart:async';

import 'package:client/design/metinler.dart';
import 'package:client/sunum/gorev_listesi_ekrani.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// DURUM.md sinir 18: yeni sahte depo `ekle`nin UC opsiyonel alanini kabul ETMEK ZORUNDADIR.
class _SahteDepo implements GorevDeposu {
  @override
  Stream<List<GorevGorunum>> gorevlerGorunur() => Stream.value(const []);

  @override
  Future<void> ekle(
    String baslik, {
    int? oncelik,
    DateTime? sonTarih,
    Set<String> etiketler = const {},
  }) async {}

  @override
  Future<void> duzenle(String id, String yeniBaslik) async {}

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
  Stream<List<CakismaKaydi>> cakismaKayitlariniIzle(String entityId) =>
      Stream.value(const []);

  @override
  Future<void> cakismaCoz(String entityId, CakismaSecimi secim) async {}
}

Widget _sarmala(Widget cocuk) => MaterialApp(home: cocuk);

void main() {
  group('IS-EMRI-o83 -- GorevListesiEkrani cikis dugmesi', () {
    testWidgets('onCikisYap NULL iken dugme HIC CIZILMEZ (geriye donuk uyum)', (
      tester,
    ) async {
      await tester.pumpWidget(_sarmala(GorevListesiEkrani(depo: _SahteDepo())));

      expect(find.byIcon(Icons.logout), findsNothing);
    });

    testWidgets('onCikisYap verili: dugme var, dokununca TAM BIR KEZ cagrilir', (
      tester,
    ) async {
      var cagriSayaci = 0;
      await tester.pumpWidget(
        _sarmala(
          GorevListesiEkrani(
            depo: _SahteDepo(),
            onCikisYap: () => cagriSayaci++,
          ),
        ),
      );

      expect(find.byIcon(Icons.logout), findsOneWidget);
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pump();

      expect(cagriSayaci, 1);
    });

    testWidgets(
      'a11y: onCikisYap+onYenile birlikte -- labeledTapTargetGuideline VE androidTapTargetGuideline gecer',
      (tester) async {
        final tutamac = tester.ensureSemantics();
        await tester.pumpWidget(
          _sarmala(
            GorevListesiEkrani(
              depo: _SahteDepo(),
              onYenile: () async {},
              onCikisYap: () {},
            ),
          ),
        );

        expect(find.text(Metinler.cikisYapDugmesi), findsNothing); // tooltip metni, GORUNUR metin degil
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        tutamac.dispose();
      },
    );
  });
}

@TestOn('vm')
library;

// IS-EMRI-o80 -- bos senkron rozeti satirin yarisini yutuyor.
//
// Kok neden (is emri): `Flexible(child: SenkronRozeti(...))` HER ZAMAN
// `_rozetler()`e eklenirdi; `senkronize` durumunda rozet HICBIR SEY CIZMEZ
// (SizedBox.shrink) ama Flex algoritmasi flex-payini YINE DE ayirir --
// `Expanded(child: _baslikVeMeta(...))` ile AYNI havuzu (flex:1) paylasip
// bos alanin YARISINI yutar. Kilit: rozet cizmiyorsa listeye HIC girmesin.
//
// 🔴 `find.text(...)` YETMEZ -- metin bulunur ama kirpilmis olur (is emri).
// Olcum GENISLIK uzerinden yapilir: `tester.getSize(find.text(...)).width`,
// cunku Expanded FlexFit.tight ile Text'e (meta satiri YOKKEN, bare Text
// case) TAM ALLOCATED GENISLIGI tight constraint olarak verir.
//
// dart:io kullanmaz ama @TestOn('vm') g14/o68/o72 emsaliyle TUTARLILIK icin
// korunur.

import 'package:client/sunum/gorev_satiri.dart';
import 'package:client/sunum/senkron_rozeti.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Gorev _sahteGorev({String baslik = 'Sut al ve firina ugra'}) => Gorev(
  id: 'g80-ornek',
  baslik: baslik,
  tamamlandi: false,
  olusturuldu: DateTime.utc(2026, 8, 17),
  guncellendi: DateTime.utc(2026, 8, 17),
  senkronDurumu: 'senkronize',
  silindi: false,
);

Widget _sarmala({required double genislik, required SenkronDurumTuru durum}) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: genislik,
          child: GorevSatiri(
            gorev: _sahteGorev(),
            onTamamlaDegisti: (_) {},
            senkronDurumu: durum,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('IS-EMRI-o80 -- bos senkron rozeti satirin yarisini yutmamali', () {
    // OLCULDU (bu is emrinde): 360dp genislikte -- onay kutusu 48 + iki
    // MBosluk.s (8+8) checkbox/rozetler arasi bosluk = 64 sabit, rozetler
    // listesi BOS (senkronize + cakisma/duzenle/sil YOK) ⇒ kalan 296 TAMAMI
    // baslige gitmeli (Expanded TEK flex cocuk, flex:1 alone).
    // ESKI (kusurlu) davranista: Flexible(SenkronRozeti) da listede olurdu,
    // toplam flex=2, 296 ikiye bolunur ⇒ baslik yalniz 148 alirdi.
    // Esik (250) ikisini net ayirir: ESKI=148 < 250 < YENI≈296.
    testWidgets(
      '360dp + senkronize ⇒ baslik CIZILEN genisligi > 250dp (bos rozet slotu yutmuyor)',
      (tester) async {
        await tester.pumpWidget(
          _sarmala(genislik: 360, durum: SenkronDurumTuru.senkronize),
        );
        await tester.pump();

        expect(
          SenkronRozeti.metinIcin(SenkronDurumTuru.senkronize),
          isNull,
          reason: 'on kosul: senkronize durumunda rozet metin URETMEMELI',
        );

        final genislik = tester.getSize(find.text(_sahteGorev().baslik)).width;
        expect(
          genislik,
          greaterThan(250),
          reason:
              'baslik CIZILEN genisligi $genislik -- 250in ALTINDAYSA bos '
              'SenkronRozeti hala flex-payini yutuyor demektir (eski kusur: '
              '360-48-16=296 alanin YARISI ~148). find.text(...) TEK BASINA '
              'bunu YAKALAMAZ (metin bulunur, kirpilmis olur) -- olcum '
              'GENISLIK uzerinden yapildi.',
        );
      },
    );

    // KABUL OLCUTU 2: rozet DOLU olan durumlarda davranis BIREBIR eskisi --
    // Flexible hala listede, kuculebilirlik korunur. Dar bir genislikte
    // (240dp) uzun bir rozet metniyle (gonderilmemis) baslik hala YATAY
    // kalir (rozet metni kisadir, _dikeyMi esigini gecmez) ve Flexible
    // SATIRDA VAR olmaya devam eder -- `find.byType(Flexible)` regresyonu.
    testWidgets(
      '360dp + gonderilmemis (DOLU rozet) ⇒ Flexible(SenkronRozeti) HALA listede',
      (tester) async {
        await tester.pumpWidget(
          _sarmala(genislik: 360, durum: SenkronDurumTuru.gonderilmemis),
        );
        await tester.pump();

        expect(
          find.ancestor(
            of: find.byType(SenkronRozeti),
            matching: find.byType(Flexible),
          ),
          findsOneWidget,
          reason:
              'DOLU rozet durumunda Flexible KORUNMALI (kabul olcutu 2) -- '
              'rozet metni uzunken kuculebilirlik kaybolmamali.',
        );
      },
    );

    // KABUL OLCUTU 3: `_dikeyMi()` karari degismez -- zaten `metinIcin ==
    // null` iken `false` donuyordu, bu turda DOKUNULMADI. Dar + buyuk
    // olcekte (320dp/2.0x) senkronize hala YATAY kalmali (g14/A7 emsali,
    // burada TEKRAR olculur cunku o80 TAM BU KOSULA dokunuyor olabilirdi).
    testWidgets(
      '320dp + senkronize ⇒ _dikeyMi degismedi, hala YATAY',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 320,
                  child: GorevSatiri(
                    gorev: _sahteGorev(),
                    onTamamlaDegisti: (_) {},
                    senkronDurumu: SenkronDurumTuru.senkronize,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final duzenColumn = find.descendant(
          of: find.byType(GorevSatiri),
          matching: find.byType(Column),
        );
        expect(
          duzenColumn,
          findsNothing,
          reason:
              '_dikeyMi() senkronize icin degismemeliydi -- Column bulunmasi '
              'kabul olcutu 3un ihlali olur.',
        );
      },
    );
  });
}

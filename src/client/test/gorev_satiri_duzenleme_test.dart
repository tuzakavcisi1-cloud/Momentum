@TestOn('vm')
library;

// IS-EMRI-o68 -- SS2 kriter 8: baslik duzenleme UI'i.
//
// 🔴 BU DOSYA YENI BIR G<n>/D-<x> KAPISI ILAN ETMEZ (is emri §0) -- kilitli
// `GOREV-SS2`nin bir parcasini urun yoluna baglayan URUN KODU testidir.
//
// Kabul kriteri 4/5 (is emri §5): "M7 ISIRIYOR" ve "yeni ikon etiketli"
// olcumu BU DOSYADA degil -- Semantics etiketi SABIT/gomulu oldugu icin
// "etiket silinince ne olur" bir DART PARAMETRESI DEGIL, GERCEK BIR KAYNAK
// MUTASYONUDUR (bu projenin M7/M75/M77 mutant yontemi -- ORTAM.md +
// KANIT/A11/_mutant_kosucu.py emsali). O olcum bagimsiz bir betikle
// AYRICA kosuldu ve ciktisi KANIT altindadir; bu dosya yalniz "etiket BUGUN
// yerinde mi + guideline BUGUN geciyor mu"yu dogrudan sinar (M7'nin
// kendisini degil, on kosulunu).
//
// dart:io kullanir (kriter 7'nin STATIK ayagi) ⇒ @TestOn('vm') PAZARLIKSIZ
// (g14_dikey_donus_kapisi_test.dart emsali).

import 'dart:io';

import 'package:client/design/metinler.dart';
import 'package:client/sunum/gorev_satiri.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Gorev _sahteGorev() => Gorev(
  id: 'g68-ornek',
  baslik: 'Eski baslik',
  tamamlandi: false,
  olusturuldu: DateTime.utc(2026, 8, 10),
  guncellendi: DateTime.utc(2026, 8, 10),
  senkronDurumu: 'yerel',
  silindi: false,
);

Widget _sarmala(Widget cocuk) => MaterialApp(home: Scaffold(body: cocuk));

void main() {
  group('IS-EMRI-o68 -- GorevSatiri baslik duzenleme', () {
    testWidgets(
      'onBaslikDuzenlendi NULL iken duzenleme ikonu HIC CIZILMEZ',
      (tester) async {
        await tester.pumpWidget(
          _sarmala(
            GorevSatiri(gorev: _sahteGorev(), onTamamlaDegisti: (_) {}),
          ),
        );
        expect(find.byIcon(Icons.edit_outlined), findsNothing);
      },
    );

    testWidgets(
      'ikon gorunur -> basilir -> diyalogda kaydet -> duzenle(id, yeniBaslik) cagrildi',
      (tester) async {
        String? cagrilanId;
        String? cagrilanBaslik;
        await tester.pumpWidget(
          _sarmala(
            GorevSatiri(
              gorev: _sahteGorev(),
              onTamamlaDegisti: (_) {},
              onBaslikDuzenlendi: (yeni) {
                cagrilanId = _sahteGorev().id;
                cagrilanBaslik = yeni;
              },
            ),
          ),
        );

        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        // NOT: find.text('Eski baslik') BURADA BELIRSIZDIR -- GorevSatiri'nin
        // KENDI baslik Text'i AYNI dizgeyi tasir, `find.text` hem `Text` hem
        // `EditableText`i eslestirdigi icin IKI widget bulunur (ilk kosumda
        // yakalandi). TextField'in controller'ini DOGRUDAN oku.
        final alan = tester.widget<TextField>(find.byType(TextField));
        expect(alan.controller!.text, 'Eski baslik');

        await tester.enterText(find.byType(TextField), 'Yeni baslik');
        await tester.tap(find.text(Metinler.kaydetDugmesi));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(cagrilanId, 'g68-ornek');
        expect(cagrilanBaslik, 'Yeni baslik');
      },
    );

    testWidgets(
      'diyalogda IPTAL -> duzenle CAGRILMAZ',
      (tester) async {
        var cagrildi = false;
        await tester.pumpWidget(
          _sarmala(
            GorevSatiri(
              gorev: _sahteGorev(),
              onTamamlaDegisti: (_) {},
              onBaslikDuzenlendi: (_) => cagrildi = true,
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();
        await tester.tap(find.text(Metinler.iptalDugmesi));
        await tester.pumpAndSettle();

        expect(cagrildi, isFalse);
      },
    );

    testWidgets(
      'diyalogda BOS baslik (kirpma sonrasi) -> duzenle CAGRILMAZ',
      (tester) async {
        var cagrildi = false;
        await tester.pumpWidget(
          _sarmala(
            GorevSatiri(
              gorev: _sahteGorev(),
              onTamamlaDegisti: (_) {},
              onBaslikDuzenlendi: (_) => cagrildi = true,
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '   ');
        await tester.tap(find.text(Metinler.kaydetDugmesi));
        await tester.pumpAndSettle();

        expect(cagrildi, isFalse);
        // OLCULDU (bagimsiz denetimde bulundu, sonra duzeltildi): bos
        // baslikta diyalog KAPANMAZ -- kapansaydi kullanicinin gozunde
        // IPTAL'den AYIRT EDILEMEZ olurdu (sessiz DUZENLEME kaybi).
        // `GorevEkleAlani._gonder()` ile AYNI desen: gecersizse alan/diyalog
        // ACIK kalir, kullanici duzeltebilir.
        expect(
          find.byType(AlertDialog),
          findsOneWidget,
          reason: 'bos baslikta diyalog ACIK KALMALI (IPTAL ile karistirilmaz)',
        );
      },
    );

    // Kriter 7 (is emri §5, T6 PAZARLIKSIZ): "satir hala onTap tasimiyor".
    // 🔴 BIR WIDGET TESTI BUNU GUVENILIR SINAYAMAZ: agacta CakismaRozeti VE
    // duzenleme IconButton'inin KENDI GestureDetector/InkResponse'lari zaten
    // VAR (istenen budur) -- "kokte GestureDetector YOK" iddiasi agac
    // sirasina/derinligine baglidir ve YANLIS-POZITIF/YANLIS-NEGATIF
    // uretmeden dogrudan olculemez. STATIK kaynak taramasi burada daha
    // GUVENILIR VE UCUZDUR (K53/3: statik mutant tavansiz) -- `build()`in
    // DONDURDUGU Container'in ACILIS-KAPANIS araligi (ilk `return Container(`
    // -- onunla AYNI GIRINTIDEKI kapanis `);`) `onTap:`/`GestureDetector(`
    // ICERMEMELI; bu ikisi yalniz `_onayKutusu`/`_rozetler`/`_duzenleIkonu`
    // GIBI AYRI METOTLARDA (govdenin DISINDA) yasamalidir.
    test(
      'kriter 7 (STATIK): build() donen Container -- onTap/GestureDetector TASIMAZ',
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

    testWidgets(
      'kriter: yeni ikon ETIKETLI (labeledTapTargetGuideline BUGUN gecer)',
      (tester) async {
        final tutamac = tester.ensureSemantics();
        await tester.pumpWidget(
          _sarmala(
            GorevSatiri(
              gorev: _sahteGorev(),
              onTamamlaDegisti: (_) {},
              onBaslikDuzenlendi: (_) {},
            ),
          ),
        );
        // NOT: `getSemantics(...)` ile TEK bir dugumun `.label`ini elle
        // okumak KIRILGANDIR -- `tooltip`in etiketi hangi dugume yazdigi
        // Flutter surumune gore degisebilir (ilk kosumda hem `find.byIcon`
        // hem `find.byType(IconButton)` BOS `.label` dondurdu, ikisi de
        // YANLIS dugumdu). `meetsGuideline(labeledTapTargetGuideline)` bu
        // projenin M7 icin kullandigi AYNI OLCUMDUR (GOREV-slice-3b:264) --
        // dogrudan onu kosmak, Flutter'in ic agac detayina bagli olmadan
        // "etiket VAR ve dokunma hedefiyle ESLESIYOR" sorusunu OTORITER
        // sekilde yanitlar.
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        tutamac.dispose();
      },
    );
  });
}

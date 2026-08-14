@TestOn('vm')
library;

// IS-EMRI-o68 -- duzenleme UI'i (ODEV.md §4(a) ile GENISLETILDI: kalem ikonu
// artik baslik + oncelik + son tarih'i TEK diyalogda duzenler).
//
// 🔴 BU DOSYA YENI BIR G<n>/D-<x> KAPISI ILAN ETMEZ -- kilitli davranisi
// URUN YOLUNA baglayan urun kodu testidir.
//
// Kabul kriteri 4/5 (is emri §5): "M7 ISIRIYOR" ve "yeni ikon etiketli"
// olcumu BU DOSYADA degil -- Semantics etiketi SABIT/gomulu oldugu icin
// "etiket silinince ne olur" bir DART PARAMETRESI DEGIL, GERCEK BIR KAYNAK
// MUTASYONUDUR (bu projenin M7/M75/M77 mutant yontemi). O olcum bagimsiz
// bir betikle AYRICA kosuldu ve ciktisi KANIT altindadir; bu dosya yalniz
// "etiket BUGUN yerinde mi + guideline BUGUN geciyor mu"yu sinar.
//
// dart:io kullanir (kriter 7'nin STATIK ayagi) ⇒ @TestOn('vm') PAZARLIKSIZ
// (g14_dikey_donus_kapisi_test.dart emsali).

import 'dart:io';

import 'package:client/design/metinler.dart';
import 'package:client/sunum/gorev_satiri.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Gorev _sahteGorev({int? oncelik, DateTime? sonTarih}) => Gorev(
  id: 'g68-ornek',
  baslik: 'Eski baslik',
  tamamlandi: false,
  olusturuldu: DateTime.utc(2026, 8, 10),
  guncellendi: DateTime.utc(2026, 8, 10),
  senkronDurumu: 'yerel',
  silindi: false,
  oncelik: oncelik,
  sonTarih: sonTarih,
);

Widget _sarmala(Widget cocuk) => MaterialApp(home: Scaffold(body: cocuk));

void main() {
  group('IS-EMRI-o68 + ODEV §4(a) -- GorevSatiri duzenleme diyalogu', () {
    testWidgets(
      'onAyrintilarDuzenlendi NULL iken duzenleme ikonu HIC CIZILMEZ',
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
      'ikon gorunur -> basilir -> diyalogda kaydet -> YALNIZ baslik Yazim`i dolu',
      (tester) async {
        GorevAyrintiDegisikligi? yakalanan;
        await tester.pumpWidget(
          _sarmala(
            GorevSatiri(
              gorev: _sahteGorev(),
              onTamamlaDegisti: (_) {},
              onAyrintilarDuzenlendi: (d) => yakalanan = d,
            ),
          ),
        );

        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        // NOT: find.text('Eski baslik') BURADA BELIRSIZDIR -- GorevSatiri'nin
        // KENDI baslik Text'i AYNI dizgeyi tasir, `find.text` hem `Text` hem
        // `EditableText`i eslestirdigi icin IKI widget bulunur (o68'in ilk
        // kosumunda yakalandi). TextField'in controller'ini DOGRUDAN oku.
        final alan = tester.widget<TextField>(find.byType(TextField));
        expect(alan.controller!.text, 'Eski baslik');

        await tester.enterText(find.byType(TextField), 'Yeni baslik');
        await tester.tap(find.text(Metinler.kaydetDugmesi));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(yakalanan, isNotNull);
        expect(yakalanan!.baslik!.deger, 'Yeni baslik');
        // 🔴 DEGISMEYEN ALAN TELE KONMAZ: `oncelik`/`sonTarih` `null`
        // kalmali. Aksi halde her kaydet, degismemis alanlari YENI bir HLC
        // ile yeniden damgalar ve arada gelen uzak bir yazimi LWW ile
        // sessizce EZER (bu dilimin en sinsi kusur sinifi).
        expect(yakalanan!.oncelik, isNull);
        expect(yakalanan!.sonTarih, isNull);
      },
    );

    testWidgets(
      'HICBIR SEY degismeden Kaydet -> geri cagirim CAGRILMAZ (bos op uretilmez)',
      (tester) async {
        var cagrildi = false;
        await tester.pumpWidget(
          _sarmala(
            GorevSatiri(
              gorev: _sahteGorev(),
              onTamamlaDegisti: (_) {},
              onAyrintilarDuzenlendi: (_) => cagrildi = true,
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();
        await tester.tap(find.text(Metinler.kaydetDugmesi));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing, reason: 'diyalog KAPANIR');
        expect(
          cagrildi,
          isFalse,
          reason:
              'D2: her op EN AZ BIR kanal tasimali -- hicbir alan degismediyse '
              'op URETILMEZ (sunucu bos op`u BUTUN olarak reddeder)',
        );
      },
    );

    testWidgets(
      'oncelik cipine basilir -> Kaydet -> YALNIZ oncelik Yazim`i dolu',
      (tester) async {
        GorevAyrintiDegisikligi? yakalanan;
        await tester.pumpWidget(
          _sarmala(
            GorevSatiri(
              gorev: _sahteGorev(),
              onTamamlaDegisti: (_) {},
              onAyrintilarDuzenlendi: (d) => yakalanan = d,
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();
        await tester.tap(find.text(Metinler.oncelikYuksek));
        await tester.pumpAndSettle();
        await tester.tap(find.text(Metinler.kaydetDugmesi));
        await tester.pumpAndSettle();

        expect(yakalanan, isNotNull);
        expect(yakalanan!.oncelik, isNotNull);
        expect(
          yakalanan!.oncelik!.deger,
          oncelikSayiya(Oncelik.yuksek),
          reason: 'sayi ESLEMESI enumdan TURETILIR, elle yazilmaz',
        );
        expect(yakalanan!.baslik, isNull);
        expect(yakalanan!.sonTarih, isNull);
      },
    );

    testWidgets(
      'ONCELIGI olan gorevde "Yok" cipine basilir -> Yazim(null) = TEMIZLE',
      (tester) async {
        GorevAyrintiDegisikligi? yakalanan;
        await tester.pumpWidget(
          _sarmala(
            GorevSatiri(
              gorev: _sahteGorev(oncelik: 1),
              onTamamlaDegisti: (_) {},
              onAyrintilarDuzenlendi: (d) => yakalanan = d,
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();
        await tester.tap(find.text(Metinler.oncelikYok));
        await tester.pumpAndSettle();
        await tester.tap(find.text(Metinler.kaydetDugmesi));
        await tester.pumpAndSettle();

        expect(yakalanan, isNotNull);
        // 🔴 `Yazim` VAR ama `deger` NULL: "temizle". Duz `null` olsaydi
        // "dokunma" demek olurdu ve temizleme SESSIZCE KAYBOLURDU.
        expect(yakalanan!.oncelik, isNotNull);
        expect(yakalanan!.oncelik!.deger, isNull);
      },
    );

    testWidgets(
      'SON TARIHI olan gorevde temizleme ikonu -> Kaydet -> Yazim(null)',
      (tester) async {
        GorevAyrintiDegisikligi? yakalanan;
        await tester.pumpWidget(
          _sarmala(
            GorevSatiri(
              gorev: _sahteGorev(sonTarih: DateTime.utc(2026, 8, 21)),
              onTamamlaDegisti: (_) {},
              onAyrintilarDuzenlendi: (d) => yakalanan = d,
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();
        expect(
          find.text(GorevSatiri.tarihEtiketi(DateTime.utc(2026, 8, 21))),
          findsWidgets,
          reason: 'diyalog acilirken MEVCUT tarih dugmede gorunmeli',
        );
        await tester.tap(find.byTooltip(Metinler.sonTarihiTemizle));
        await tester.pumpAndSettle();
        await tester.tap(find.text(Metinler.kaydetDugmesi));
        await tester.pumpAndSettle();

        expect(yakalanan, isNotNull);
        expect(yakalanan!.sonTarih, isNotNull);
        expect(yakalanan!.sonTarih!.deger, isNull);
      },
    );

    testWidgets(
      'diyalogda IPTAL -> geri cagirim CAGRILMAZ',
      (tester) async {
        var cagrildi = false;
        await tester.pumpWidget(
          _sarmala(
            GorevSatiri(
              gorev: _sahteGorev(),
              onTamamlaDegisti: (_) {},
              onAyrintilarDuzenlendi: (_) => cagrildi = true,
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
      'diyalogda BOS baslik (kirpma sonrasi) -> geri cagirim CAGRILMAZ',
      (tester) async {
        var cagrildi = false;
        await tester.pumpWidget(
          _sarmala(
            GorevSatiri(
              gorev: _sahteGorev(),
              onTamamlaDegisti: (_) {},
              onAyrintilarDuzenlendi: (_) => cagrildi = true,
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '   ');
        await tester.tap(find.text(Metinler.kaydetDugmesi));
        await tester.pumpAndSettle();

        expect(cagrildi, isFalse);
        // OLCULDU (o68'de bagimsiz denetimde bulundu, sonra duzeltildi): bos
        // baslikta diyalog KAPANMAZ -- kapansaydi kullanicinin gozunde
        // IPTAL'den AYIRT EDILEMEZ olurdu (sessiz DUZENLEME kaybi).
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
    // GUVENILIR VE UCUZDUR: `build()`in DONDURDUGU Container'in
    // ACILIS-KAPANIS araligi `onTap:`/`GestureDetector(` ICERMEMELI.
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
              onAyrintilarDuzenlendi: (_) {},
            ),
          ),
        );
        // NOT: `getSemantics(...)` ile TEK bir dugumun `.label`ini elle
        // okumak KIRILGANDIR -- `tooltip`in etiketi hangi dugume yazdigi
        // Flutter surumune gore degisebilir (o68'in ilk kosumunda hem
        // `find.byIcon` hem `find.byType(IconButton)` BOS `.label` dondurdu).
        // `meetsGuideline(labeledTapTargetGuideline)` bu projenin M7 icin
        // kullandigi AYNI OLCUMDUR.
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        tutamac.dispose();
      },
    );
  });
}

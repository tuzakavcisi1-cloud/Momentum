// GOREV-A7 [K85 / spec v4 §5] -- G15 BILESIK SATIR · A11Y-1 · A11Y-6 ·
// A11Y-7 · CIFT OKUMA.
//
// 🔴 A13 (CIFT OKUMA) v3'te KAPSAM DISIYDI ve v4'te KAPSAMA GIRDI. Sebep
// mekaniktir: kisa gorunur dizge karari, gorunur metin ile
// Semantics(label:)'i FARKLI dizgeler yapti ⇒ ExcludeSemantics olmadan
// ekran okuyucu "Cevrimdisisiniz. Degisiklikler kaydedildi. Cevrimdisi"
// diye IKI KEZ okur. Haric tutulan borc, bir sonraki kararin yan
// etkisinden KORUNMAZ (spec §2/3).
//
// Bu dosya dart:io ICERMEZ (web'de de kosabilir); statik ayaklar G13/A3 ve
// G14/A8'dedir.

import 'package:client/design/metinler.dart';
import 'package:client/design/tokens.dart';
import 'package:client/sunum/cakisma_rozeti.dart';
import 'package:client/sunum/gorev_satiri.dart';
import 'package:client/sunum/senkron_rozeti.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Gorev _ornekGorev() => Gorev(
  id: 'g15-ornek',
  baslik: 'Raporu gonder ve onaya sun',
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
  bool cakismaVarMi = false,
}) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        final taban = MediaQuery.of(context);
        return MediaQuery(
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

/// SystemChannels.accessibility'i mock'lar; GONDERILEN duyuru dizgelerini
/// yakalar (A11Y-7). a11y_kapisi_test.dart'taki ayni desen.
List<String> _duyurulariYakala(WidgetTester tester) {
  final yakalanan = <String>[];
  tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
    SystemChannels.accessibility,
    (dynamic mesaj) async {
      final harita = mesaj as Map;
      if (harita['type'] == 'announce') {
        final veri = harita['data'] as Map;
        yakalanan.add(veri['message'] as String);
      }
      return null;
    },
  );
  return yakalanan;
}

/// Bir semantics alt agacindaki BOS OLMAYAN tum etiketleri toplar.
/// A13'un olcusu budur: etiket SAYISI 1 olmali -- 2 olmasi "ekran okuyucu
/// ayni rozeti iki kez okuyor" demektir.
List<String> _etiketler(SemanticsNode kok) {
  final sonuc = <String>[];
  void gez(SemanticsNode dugum) {
    if (dugum.label.isNotEmpty) sonuc.add(dugum.label);
    dugum.visitChildren((cocuk) {
      gez(cocuk);
      return true;
    });
  }

  gez(kok);
  return sonuc;
}

void main() {
  group('G15/A9 -- BILESIK SATIR: iki rozet AYNI ANDA agacta', () {
    testWidgets('cakisma=true + gonderilmemis, 320dp, 2.0x', (tester) async {
      await tester.pumpWidget(
        _sarmalayici(
          genislik: 320,
          olcek: 2.0,
          durum: SenkronDurumTuru.gonderilmemis,
          cakismaVarMi: true,
        ),
      );
      await tester.pump();
      // GOREV-R10 D7: cakisma DIK KANALDIR -- taban rozeti BASTIRMAZ.
      expect(find.byType(CakismaRozeti), findsOneWidget);
      expect(find.byType(SenkronRozeti), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SenkronRozeti),
          matching: find.byType(Text),
        ),
        findsOneWidget,
        reason: 'dikey duzende taban rozetin metni dusurulmus (M79 sinifi)',
      );
    });
  });

  group('G15/A10 -- A11Y-1: dokunma hedefleri dikeyde de >= 48dp', () {
    testWidgets('Checkbox ve CakismaRozeti kendi 48dp\'lerini korur', (tester) async {
      final tutamac = tester.ensureSemantics();
      await tester.pumpWidget(
        _sarmalayici(
          genislik: 320,
          olcek: 2.0,
          durum: SenkronDurumTuru.gonderilmemis,
          cakismaVarMi: true,
        ),
      );
      await tester.pump();

      final onayKutusu = tester.getSize(find.byType(Checkbox));
      expect(
        onayKutusu.width,
        greaterThanOrEqualTo(MOlcu.dokunmaHedefi),
        reason: 'Checkbox genisligi kuculmus (M82)',
      );
      expect(onayKutusu.height, greaterThanOrEqualTo(MOlcu.dokunmaHedefi));

      final cakisma = tester.getSize(find.byType(CakismaRozeti));
      expect(cakisma.width, greaterThanOrEqualTo(MOlcu.dokunmaHedefi));
      expect(cakisma.height, greaterThanOrEqualTo(MOlcu.dokunmaHedefi));

      // Ayni olcum Flutter'in KENDI kilavuzuyla da bagimsizca kosar.
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      tutamac.dispose();
    });
  });

  group('G15/A11 -- A11Y-6: rozetin GORUNUR Text\'i KORUNUR', () {
    // Metni GIZLEYEREK tasmayi "cozmek" YASAKTIR (M78). Kirpma cozumu
    // gorunur metni KISALTIR, YOK ETMEZ.
    for (final durum in <SenkronDurumTuru>[
      SenkronDurumTuru.yerel,
      SenkronDurumTuru.kuyrukta,
      SenkronDurumTuru.cevrimdisi,
      SenkronDurumTuru.gonderilmemis,
    ]) {
      testWidgets('${durum.name}: gorunur Text VAR ve BOS DEGIL', (tester) async {
        await tester.pumpWidget(
          _sarmalayici(genislik: 320, olcek: 2.0, durum: durum),
        );
        await tester.pump();
        final metinFinder = find.descendant(
          of: find.byType(SenkronRozeti),
          matching: find.byType(Text),
        );
        expect(metinFinder, findsOneWidget);
        final metin = tester.widget<Text>(metinFinder).data;
        expect(metin, isNotNull);
        expect(metin, isNotEmpty);
        expect(
          metin,
          SenkronRozeti.metinIcin(durum),
          reason: 'cizilen metin metinIcin() ile ayrismis (M77b sinifi)',
        );
      });
    }
  });

  group('G15/A12 -- A11Y-7 REGRESYONU: durum gecisinde duyuru BIR KEZ', () {
    testWidgets('kuyrukta ⇒ cevrimdisi gecisinde tek duyuru', (tester) async {
      final yakalanan = _duyurulariYakala(tester);
      await tester.pumpWidget(
        _sarmalayici(
          genislik: 320,
          olcek: 2.0,
          durum: SenkronDurumTuru.kuyrukta,
        ),
      );
      await tester.pump();
      expect(
        yakalanan,
        isNot(contains(Metinler.duyuruCevrimdisi)),
        reason: 'gecis OLMADAN duyuru gitmis',
      );

      await tester.pumpWidget(
        _sarmalayici(
          genislik: 320,
          olcek: 2.0,
          durum: SenkronDurumTuru.cevrimdisi,
        ),
      );
      await tester.pump();

      expect(
        yakalanan.where((d) => d == Metinler.duyuruCevrimdisi).length,
        1,
        reason: 'G11 davranisi bozuldu -- duyuru ya kayboldu ya cift gitti. '
            'Yakalanan: $yakalanan',
      );

      // Ayni durumla yeniden pump: TEKRAR duyurmamali.
      await tester.pumpWidget(
        _sarmalayici(
          genislik: 320,
          olcek: 2.0,
          durum: SenkronDurumTuru.cevrimdisi,
        ),
      );
      await tester.pump();
      expect(
        yakalanan.where((d) => d == Metinler.duyuruCevrimdisi).length,
        1,
        reason: 'ayni durumda tekrar duyuru gitti',
      );
    });
  });

  group('G15/A13 -- CIFT OKUMA: semantics agacinda TEK etiket, TAM metin', () {
    // 🔴 Bu ayak M87'yi (ExcludeSemantics kaldirilir) isirtir.
    const beklenen = <SenkronDurumTuru, String>{
      SenkronDurumTuru.yerel: Metinler.yalnizcaBuCihazda,
      SenkronDurumTuru.kuyrukta: Metinler.gonderiliyor,
      SenkronDurumTuru.cevrimdisi: Metinler.cevrimdisiKaydedildi,
      SenkronDurumTuru.gonderilmemis: Metinler.gonderilmemisDegisiklik,
    };

    for (final girdi in beklenen.entries) {
      testWidgets('${girdi.key.name}: tek etiket = TAM metin', (tester) async {
        final tutamac = tester.ensureSemantics();
        await tester.pumpWidget(
          _sarmalayici(genislik: 320, olcek: 2.0, durum: girdi.key),
        );
        await tester.pump();

        final etiketler = _etiketler(
          tester.getSemantics(find.byType(SenkronRozeti)),
        );
        expect(
          etiketler,
          <String>[girdi.value],
          reason:
              'rozetin semantics alt agacinda TAM METIN BIR KEZ gecmeli. '
              'Iki etiket ⇒ ekran okuyucu rozeti IKI KEZ okur '
              '(ExcludeSemantics kaldirilmis · M87). Olculen: $etiketler',
        );

        // Kisa gorunur metin semantics agacinda BULUNMAMALI -- tam metinle
        // AYNI oldugu 'kuyrukta' durumu haric (orada tek dizge zaten TAM
        // metindir; ayri bir kisa karsilik YOKTUR, bu bilincli bir karardir).
        final kisa = SenkronRozeti.metinIcin(girdi.key);
        if (kisa != girdi.value) {
          expect(
            etiketler,
            isNot(contains(kisa)),
            reason: 'kisa gorunur metin ("$kisa") semantics agacina sizmis',
          );
        }
        tutamac.dispose();
      });
    }
  });
}

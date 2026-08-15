@TestOn('vm')
library;

// GOREV-W2 T10 -- G40 (serit kapisi). @TestOn('vm') ZORUNLU: G40/e
// meetsGuideline(textContrastGuideline) RenderObject.toImage cagirir --
// flutter_test'te bunun web karsiligi YOKTUR (a11y_kontrast_test.dart:4-7
// ile AYNI gerekce, Z16).
//
// 🔴 BEYAN EDILMIS TASARIM KARARI ("YOK" yuku): spec G40 basligi "YOK" =
// `find.byType(DepolamaSeridi)` hic bulunmaz der. T3 birebir metni ise
// "gerekmiyorsa SizedBox.shrink()" -- yani WIDGET'IN KENDISI agacta KALIR
// (yalniz govdesi kucculur); `find.byType` bunu HER ZAMAN bulur. Literal
// tanim yalniz `depolama == null` senaryosunda (G40/c'nin ikinci yarisi)
// birebir gecerlidir. Durum-tabanli YOK (kaliciOpfs/olculmedi) icin bu
// dosya GORUNUR GOVDE sifira dogrulanir (boyut + ikon/metin yoklugu) --
// aksi halde M203/M204 hicbir ayaktan KIRMIZI VERMEZDI (olculdu: `find.
// byType(DepolamaSeridi)` mutant ONCESI de SONRASI da AYNI sonucu dondurur,
// cunku widget HER IKI durumda da insa edilir). Bu sapma GIZLENMIYOR --
// Cowork'un bagimsiz denetimi icin burada ACIKCA yazili.

import 'package:client/design/metinler.dart';
import 'package:client/design/tema.dart';
import 'package:client/sunum/depolama_seridi.dart';
import 'package:client/sunum/gorev_listesi_ekrani.dart';
import 'package:client/veri/depolama_durumu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'destekler/duyuru_yakala.dart';

/// Serit icerigiyle ILGISIZ -- G40 yalniz seridi olcer, gorev listesini
/// degil (desen: a11y_kapisi_test.dart `_SabitDepo`, bos liste).
class _BosDepo implements GorevDeposu {
  @override
  Stream<List<GorevGorunum>> gorevlerGorunur() => Stream.value(const []);
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
  Stream<List<CakismaKaydi>> cakismaKayitlariniIzle(String entityId) =>
      Stream.value(const []);
  @override
  Future<void> cakismaCoz(String entityId, CakismaSecimi secim) async {}
}

Widget _ekranSarmalayici({
  required DepolamaBildirimi? depolama,
  Brightness parlaklik = Brightness.light,
  Size? boyut,
  double textScale = 1.0,
}) {
  return MaterialApp(
    theme: MomentumTema.olustur(parlaklik),
    home: Builder(
      builder: (context) {
        final taban = MediaQuery.of(context);
        final govde = GorevListesiEkrani(depo: _BosDepo(), depolama: depolama);
        return MediaQuery(
          data: taban.copyWith(size: boyut, textScaler: TextScaler.linear(textScale)),
          // GOREV-W2 T10 (G40/d, TESHIS EDILDI): MediaQuery.size YALNIZ
          // BILGI tasir -- test yuzeyinin GERCEK RenderBox genisligini
          // DEGISTIRMEZ (800x600 sabit kalirdi, olculdu). Gercek genislik
          // kisitlamasi icin g13_rozet_tasma_kapisi_test.dart:81-93 ile
          // AYNI desen: GorevListesiEkrani GERCEK KALIR (YALITILMIS
          // DEGIL, spec §5/G40 pini), yalniz disaridan bir SizedBox'la
          // kisitlanir.
          child: boyut == null
              ? govde
              : Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(width: boyut.width, height: boyut.height, child: govde),
                ),
        );
      },
    ),
  );
}

const List<Type> _yasakSarmalayicilar = [
  Opacity,
  Visibility,
  Offstage,
  Transform,
  ClipRect,
  ColorFiltered,
];

/// Bu dosyanin ustundeki "BEYAN EDILMIS TASARIM KARARI" notuna bakiniz.
void _seritYokDogrula(WidgetTester tester) {
  final serit = find.byType(DepolamaSeridi);
  final bulunanlar = serit.evaluate();
  if (bulunanlar.isEmpty) {
    // `depolama == null` -- G40'in LITERAL tanimi burada birebir gecerli.
    expect(bulunanlar, isEmpty);
    return;
  }
  expect(bulunanlar, hasLength(1), reason: 'serit birden fazla kez agacta');
  final boyut = tester.getSize(serit);
  expect(
    boyut,
    Size.zero,
    reason: 'serit "YOK" olmali ama sifir olmayan boyutta cizildi: $boyut',
  );
  expect(
    find.descendant(of: serit, matching: find.byType(Icon)).evaluate(),
    isEmpty,
    reason: 'serit "YOK" olmali ama ikon buldu',
  );
  expect(
    find.descendant(of: serit, matching: find.byType(Text)).evaluate(),
    isEmpty,
    reason: 'serit "YOK" olmali ama metin buldu',
  );
}

/// G40 basligi -- BES KOSUL PAZARLIKSIZ (spec §5/G40).
void _seritVarDogrula(WidgetTester tester, String metin) {
  final serit = find.byType(DepolamaSeridi);
  expect(serit, findsOneWidget, reason: 'serit "VAR" olmali ama agacta yok');
  expect(
    find.descendant(of: serit, matching: find.text(metin)),
    findsOneWidget,
    reason: 'serit metni bulunamadi: $metin',
  );
  expect(
    find.descendant(of: serit, matching: find.byIcon(Icons.storage)),
    findsOneWidget,
    reason: 'serit Icons.storage ikonunu tasimiyor',
  );
  final boyut = tester.getSize(serit);
  expect(boyut.height, greaterThan(0), reason: 'serit yuksekligi sifir');
  expect(boyut.width, greaterThan(0), reason: 'serit genisligi sifir');
  for (final tip in _yasakSarmalayicilar) {
    final bulunan = find.descendant(
      of: serit,
      matching: find.byWidgetPredicate((w) => w.runtimeType == tip),
    );
    expect(
      bulunan.evaluate(),
      isEmpty,
      reason: 'yasak sarmalayici bulundu (T3): $tip',
    );
  }
}

void main() {
  group('G40 -- serit kapisi (GorevListesiEkrani pump edilir, YALITILMIS DEGIL)', () {
    testWidgets(
      'G40/a — kaliciOpfs ⇒ YOK (pozitif kontrol: ayni testte geriDusus ⇒ VAR)',
      (tester) async {
        final bildirim = DepolamaBildirimi(
          const DepolamaDurumu(sinif: DepolamaSinifi.kaliciOpfs, uygulamaAdi: 'opfsShared'),
        );
        await tester.pumpWidget(_ekranSarmalayici(depolama: bildirim));
        await tester.pump();
        _seritYokDogrula(tester);

        bildirim.value = const DepolamaDurumu(
          sinif: DepolamaSinifi.geriDusus,
          uygulamaAdi: 'sharedIndexedDb',
        );
        await tester.pump();
        _seritVarDogrula(tester, Metinler.depolamaGeriDususu);
      },
    );

    testWidgets('G40/b — geriDusus ⇒ VAR, ikon + metin birlikte', (tester) async {
      final bildirim = DepolamaBildirimi(
        const DepolamaDurumu(sinif: DepolamaSinifi.geriDusus, uygulamaAdi: 'sharedIndexedDb'),
      );
      await tester.pumpWidget(_ekranSarmalayici(depolama: bildirim));
      await tester.pump();
      _seritVarDogrula(tester, Metinler.depolamaGeriDususu);
    });

    testWidgets('G40/c — olculmedi VE depolama == null ⇒ YOK', (tester) async {
      // Yari 1: depolama parametresinin kendisi null -- ValueListenableBuilder
      // hic kurulmaz (T4), literal "YOK" burada birebir gecerli.
      await tester.pumpWidget(_ekranSarmalayici(depolama: null));
      await tester.pump();
      _seritYokDogrula(tester);

      // Yari 2: depolama != null ama durum HALA `olculmedi` (native
      // varsayilan, D-W2-7) -- gorunur govde sifir olmali.
      final bildirim = DepolamaBildirimi(const DepolamaDurumu.olculmedi());
      await tester.pumpWidget(_ekranSarmalayici(depolama: bildirim));
      await tester.pump();
      _seritYokDogrula(tester);
    });

    testWidgets(
      'G40/d — textScaler 2.0x + genislik 320dp ⇒ serit metni en fazla 2 satir',
      (tester) async {
        // En uzun serit dizgesi secildi (D-A9 emsali: pozitif kontrol GERCEKTEN
        // sinamali) -- 'Veriler kaliciDegil' metni bu genislik+olcekte DOGAL
        // olarak 2 satirdan FAZLASINI gerektirir; asagidaki `didExceedMaxLines`
        // kontrolu bunu KENDI ICINDE kanitlar (aksi halde bu ayak M208'den
        // KACARDI -- arac kendini kanitlar doktrini, a11y_statik_tasma_test.dart
        // R4 ile AYNI desen).
        final bildirim = DepolamaBildirimi(
          const DepolamaDurumu(sinif: DepolamaSinifi.kaliciDegil, uygulamaAdi: 'inMemory'),
        );
        await tester.pumpWidget(
          _ekranSarmalayici(
            depolama: bildirim,
            boyut: const Size(320, 800),
            textScale: 2.0,
          ),
        );
        await tester.pump();

        final metinBulucu = find.descendant(
          of: find.byType(DepolamaSeridi),
          matching: find.text(Metinler.depolamaKaliciDegil),
        );
        expect(metinBulucu, findsOneWidget);
        final rp = tester.renderObject<RenderParagraph>(metinBulucu);
        // TABAN DOGRULAMASI (pozitif kontrol -- a11y_statik_tasma_test.dart
        // R4 ile AYNI doktrin): bu SDK surumunde RenderParagraph.
        // computeLineMetrics() PUBLIC DEGIL (yalniz TextPainter'da) --
        // bagimsiz bir TextPainter kurup maxLines'i KENDIM sabitlersem
        // gercek widget'in maxLines'ini hic OKUMAMIS, M208'i KACIRMIS
        // olurdum (vakayi taklit eder ama olcmez). Bunun yerine GERCEK
        // RenderParagraph'in ILISKILI ILE OKUNAN iki canli ozelligi
        // kullanilir: `didExceedMaxLines` (bu metin+genislik+olcek
        // GERCEKTEN >2 satir gerektiriyor mu -- pozitif kontrol) VE
        // `maxLines` (widget'a fiilen GECEN deger -- M208'in DOGRUDAN
        // hedefi; degeri OKUR, KENDI degerimle EZMEZ).
        expect(
          rp.didExceedMaxLines,
          isTrue,
          reason:
              'TABAN DOGRULAMASI: metin bu genislik+olcekte DOGAL olarak >2 '
              'satir gerektirmeli -- aksi halde bu ayak M208 (maxLines 2->5) '
              'mutantindan KACAR (vaka gercek degil)',
        );
        expect(
          rp.maxLines,
          lessThanOrEqualTo(2),
          reason:
              'serit metninin GERCEKTEN CIZILEN RenderParagraph.maxLines '
              'degeri 2den BUYUK (M208: kaynakta maxLines 2 -> 5)',
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'G40/e — koyu temada cizilmis serit textContrastGuideline gecer',
      (tester) async {
        final tutamac = tester.ensureSemantics();
        final bildirim = DepolamaBildirimi(
          const DepolamaDurumu(sinif: DepolamaSinifi.geriDusus, uygulamaAdi: 'sharedIndexedDb'),
        );
        await tester.pumpWidget(
          _ekranSarmalayici(depolama: bildirim, parlaklik: Brightness.dark),
        );
        await tester.pump();
        _seritVarDogrula(tester, Metinler.depolamaGeriDususu);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        tutamac.dispose();
      },
    );

    testWidgets(
      'G40/f — olculmedi -> geriDusus gecisinde TAM BIR KEZ sendAnnouncement, dizge BIREBIR',
      (tester) async {
        final bildirim = DepolamaBildirimi(const DepolamaDurumu.olculmedi());
        final yakalanan = duyurulariYakala(tester);
        await tester.pumpWidget(_ekranSarmalayici(depolama: bildirim));
        await tester.pump();
        expect(
          yakalanan,
          isNot(contains(Metinler.duyuruDepolamaGeriDususu)),
          reason: 'olculmedi durumunda mount aninda duyuru gonderilmemeli',
        );

        bildirim.value = const DepolamaDurumu(
          sinif: DepolamaSinifi.geriDusus,
          uygulamaAdi: 'sharedIndexedDb',
        );
        await tester.pump();

        final gecisSayisi = yakalanan
            .where((s) => s == Metinler.duyuruDepolamaGeriDususu)
            .length;
        expect(
          gecisSayisi,
          1,
          reason:
              'olculmedi->geriDusus gecisinde TAM BIR duyuru bekleniyordu, '
              '$gecisSayisi bulundu. Yakalanan: $yakalanan',
        );
      },
    );
  });
}

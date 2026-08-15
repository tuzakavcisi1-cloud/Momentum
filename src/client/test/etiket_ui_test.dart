@TestOn('vm')
library;

// ODEV.md §4(a) ETIKET DILIMI -- KABLO (UI) KAPISI.
//
// Neyi olcer: (1) suzme cip seridi yalniz ETIKET VARSA cizilir; (2) cipe
// dokununca liste FIILEN suzulur (ayni stream, yeniden abone OLUNMAZ);
// (3) satirda etiketler meta metninde gorunur; (4) diyalogdan eklenen
// etiket URUN YOLUNDAN depoya `etiketEklenen` olarak iner ve K112 dikisi
// (once YEREL YAZMA, sonra itme) KORUNUR.

import 'dart:async';

import 'package:client/design/metinler.dart';
import 'package:client/sunum/gorev_listesi_ekrani.dart';
import 'package:client/sunum/gorev_satiri.dart';
import 'package:client/sunum/senkron_rozeti.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _SahteDepo implements GorevDeposu {
  final List<String> cagrilar;
  final List<({Set<String> eklenen, Set<String> silinen})> etiketYazimlari = [];
  final _denetleyici = StreamController<List<GorevGorunum>>.broadcast();

  _SahteDepo(this.cagrilar);

  @override
  Stream<List<GorevGorunum>> gorevlerGorunur() => _denetleyici.stream;

  @override
  Future<void> ekle(
    String baslik, {
    int? oncelik,
    DateTime? sonTarih,
    Set<String> etiketler = const {},
  }) async => cagrilar.add('ekle:$baslik');

  @override
  Future<void> duzenle(String id, String yeniBaslik) async =>
      cagrilar.add('duzenle:$id');

  @override
  Future<void> ayrintilariGuncelle(
    String id, {
    Yazim<String>? baslik,
    Yazim<int?>? oncelik,
    Yazim<DateTime?>? sonTarih,
    Set<String>? etiketEklenen,
    Set<String>? etiketSilinen,
  }) async {
    cagrilar.add('ayrintilar:$id');
    etiketYazimlari.add((
      eklenen: etiketEklenen ?? const {},
      silinen: etiketSilinen ?? const {},
    ));
  }

  @override
  Future<void> tamamlaGeriAl(String id, {required bool tamamlandi}) async =>
      cagrilar.add('tamamla:$id');

  @override
  Future<void> sil(String id) async => cagrilar.add('sil:$id');

  @override
  Stream<List<CakismaKaydi>> cakismaKayitlariniIzle(String entityId) =>
      Stream.value(const []);

  @override
  Future<void> cakismaCoz(String entityId, CakismaSecimi secim) async =>
      cagrilar.add('cakismaCoz:$entityId');

  void yayinla(List<GorevGorunum> g) => _denetleyici.add(g);

  void kapat() => _denetleyici.close();
}

GorevGorunum _gorunum(String id, String baslik, List<String> etiketler) =>
    GorevGorunum(
      gorev: Gorev(
        id: id,
        baslik: baslik,
        tamamlandi: false,
        olusturuldu: DateTime.utc(2026, 8, 1),
        guncellendi: DateTime.utc(2026, 8, 1),
        senkronDurumu: 'senkronize',
        silindi: false,
        etiketler: etiketler,
      ),
      senkronDurumu: SenkronDurumTuru.senkronize,
      cakismaVarMi: false,
    );

void main() {
  testWidgets('etiketsiz projede suzme seridi HIC CIZILMEZ', (tester) async {
    final depo = _SahteDepo([]);
    addTearDown(depo.kapat);
    await tester.pumpWidget(MaterialApp(home: GorevListesiEkrani(depo: depo)));
    depo.yayinla([_gorunum('g1', 'Rapor', const [])]);
    await tester.pump();

    expect(find.text(Metinler.etiketTumu), findsNothing);
    expect(find.byType(ChoiceChip), findsNothing);
  });

  testWidgets('cipe dokunmak listeyi SUZER; ikinci dokunus suzmeyi kaldirir', (
    tester,
  ) async {
    final depo = _SahteDepo([]);
    addTearDown(depo.kapat);
    await tester.pumpWidget(MaterialApp(home: GorevListesiEkrani(depo: depo)));
    depo.yayinla([
      _gorunum('g1', 'Rapor', const ['iş']),
      _gorunum('g2', 'Market', const ['ev']),
    ]);
    await tester.pump();

    // Serit: Tümü + iki etiket (SIRALI).
    expect(find.text(Metinler.etiketTumu), findsOneWidget);
    expect(find.byKey(const ValueKey('etiket_cipi_iş')), findsOneWidget);
    expect(find.byKey(const ValueKey('etiket_cipi_ev')), findsOneWidget);
    expect(find.text('Rapor'), findsOneWidget);
    expect(find.text('Market'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('etiket_cipi_iş')));
    await tester.pump();
    expect(find.text('Rapor'), findsOneWidget);
    expect(find.text('Market'), findsNothing, reason: 'suzme FIILEN uygulanmali');

    await tester.tap(find.byKey(const ValueKey('etiket_cipi_iş')));
    await tester.pump();
    expect(find.text('Market'), findsOneWidget, reason: 'ikinci dokunus suzmeyi kaldirir');
  });

  testWidgets('secili etiket AKISTAN KAYBOLURSA suzme kendiliginden duser', (
    tester,
  ) async {
    final depo = _SahteDepo([]);
    addTearDown(depo.kapat);
    await tester.pumpWidget(MaterialApp(home: GorevListesiEkrani(depo: depo)));
    depo.yayinla([
      _gorunum('g1', 'Rapor', const ['iş']),
      _gorunum('g2', 'Market', const ['ev']),
    ]);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('etiket_cipi_iş')));
    await tester.pump();
    expect(find.text('Market'), findsNothing);

    // 'iş' etiketi uzaktan kaldirildi: liste BOS KALMAMALI.
    depo.yayinla([
      _gorunum('g1', 'Rapor', const []),
      _gorunum('g2', 'Market', const ['ev']),
    ]);
    await tester.pump();
    expect(find.text('Rapor'), findsOneWidget);
    expect(find.text('Market'), findsOneWidget);
  });

  testWidgets('satir meta metni etiketleri gosterir (# oneki, TEK satir)', (
    tester,
  ) async {
    final gorev = _gorunum('g1', 'Rapor', const ['acil', 'iş']).gorev;
    expect(GorevSatiri.metaMetni(gorev), '#acil #iş');

    final oncelikli = Gorev(
      id: 'g2',
      baslik: 'Rapor',
      tamamlandi: false,
      olusturuldu: DateTime.utc(2026, 8, 1),
      guncellendi: DateTime.utc(2026, 8, 1),
      senkronDurumu: 'yerel',
      silindi: false,
      oncelik: 1,
      sonTarih: DateTime.utc(2026, 8, 21),
      etiketler: const ['iş'],
    );
    expect(GorevSatiri.metaMetni(oncelikli), 'Yüksek · 21 Ağu 2026 · #iş');
  });

  testWidgets('diyalogdan etiket eklenir -> depoya `etiketEklenen` iner, ITME tetiklenir', (
    tester,
  ) async {
    final sira = <String>[];
    final depo = _SahteDepo(sira);
    addTearDown(depo.kapat);
    await tester.pumpWidget(
      MaterialApp(
        home: GorevListesiEkrani(
          depo: depo,
          onYerelYazma: () async => sira.add('itme'),
        ),
      ),
    );
    depo.yayinla([_gorunum('g1', 'Rapor', const ['ev'])]);
    await tester.pump();

    await tester.tap(find.byTooltip(Metinler.gorevDuzenle));
    await tester.pumpAndSettle();

    // Mevcut etiket cip olarak gorunur.
    expect(find.widgetWithText(InputChip, 'ev'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('etiket_alani')), '  iş  ');
    await tester.tap(find.byTooltip(Metinler.etiketEkle));
    await tester.pump();
    expect(find.widgetWithText(InputChip, 'iş'), findsOneWidget,
        reason: 'kirpilmis etiket cip olarak eklenmeli');

    // Mevcut 'ev' cipini SIL.
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(InputChip, 'ev'),
        matching: find.byTooltip(Metinler.etiketKaldir),
      ),
    );
    await tester.pump();

    await tester.tap(find.text(Metinler.kaydetDugmesi));
    await tester.pumpAndSettle();

    expect(depo.etiketYazimlari.length, 1);
    expect(depo.etiketYazimlari.single.eklenen, {'iş'});
    expect(depo.etiketYazimlari.single.silinen, {'ev'});
    expect(sira, ['ayrintilar:g1', 'itme'],
        reason: 'K112 dikisi: ONCE yerel yazma, SONRA itme');
  });

  testWidgets('gecersiz etiket (bos / azami uzunlugu asan) EKLENMEZ', (
    tester,
  ) async {
    final depo = _SahteDepo([]);
    addTearDown(depo.kapat);
    await tester.pumpWidget(MaterialApp(home: GorevListesiEkrani(depo: depo)));
    depo.yayinla([_gorunum('g1', 'Rapor', const [])]);
    await tester.pump();

    await tester.tap(find.byTooltip(Metinler.gorevDuzenle));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('etiket_alani')), '   ');
    await tester.tap(find.byTooltip(Metinler.etiketEkle));
    await tester.pump();
    expect(find.byType(InputChip), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('etiket_alani')),
      'x' * 33,
    );
    await tester.tap(find.byTooltip(Metinler.etiketEkle));
    await tester.pump();
    expect(find.byType(InputChip), findsNothing,
        reason: '32 karakter kelepcesi diyalogda UYGULANMALI');

    // HICBIR degisiklik yok -> Kaydet geri cagirimi TETIKLEMEZ (D2).
    await tester.tap(find.text(Metinler.kaydetDugmesi));
    await tester.pumpAndSettle();
    expect(depo.etiketYazimlari, isEmpty);
  });
}

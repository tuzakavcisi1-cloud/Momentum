@TestOn('vm')
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/design/metinler.dart';
import 'package:client/sunum/gorev_listesi_ekrani.dart';
import 'package:client/veri/gorev_deposu.dart';

/// K112 KAPISI (oturum 48) -- YEREL YAZMA ITMEYI TETIKLER.
///
/// Bu kapinin var olma sebebi KAGIT DEGIL, CIHAZDA OLCULMUS bir bosluktur:
/// gorev eklendikten sonra itme turu HIC kosmuyordu; kayit "Bu cihazda"
/// rozetiyle duruyor ve uygulama YENIDEN BASLATILANA kadar sunucuya
/// gitmiyordu (60 s bekleme + elle yenileme 40 s: gelmedi / yeniden
/// baslatma: 14,4 s ve 23,5 s'te geldi -- KANIT/ucuncu-cihaz-senkron).
///
/// 481 istemci testi bu boslugu GORMEDI; bu dosya o kor noktayi kapatir.
class _SahteDepo implements GorevDeposu {
  /// PAZARLIKSIZ: depo cagrilari ile itme tetikleyicisi AYNI listeye yazar --
  /// aksi halde "once yazma, sonra itme" iddiasi OLCULEMEZ, yalniz iki ayri
  /// sayac karsilastirilir (ilk yazimda bu kusuru fiilen urettim).
  final List<String> cagrilar;

  _SahteDepo(this.cagrilar);

  final _denetleyici = StreamController<List<GorevGorunum>>.broadcast();

  @override
  Stream<List<GorevGorunum>> gorevlerGorunur() => _denetleyici.stream;

  @override
  Future<void> ekle(
    String baslik, {
    int? oncelik,
    DateTime? sonTarih,
    Set<String> etiketler = const {},
    String? projeId,
  }) async => cagrilar.add('ekle:$baslik');

  @override
  Future<void> duzenle(String id, String yeniBaslik) async =>
      cagrilar.add('duzenle:$id');

  // ODEV.md §4(a): K112 dikisi (once YEREL YAZMA, sonra itme) YENI yazma
  // yolu icin de olculebilsin diye AYNI listeye yazar.
  @override
  Future<void> ayrintilariGuncelle(
    String id, {
    Yazim<String>? baslik,
    Yazim<int?>? oncelik,
    Yazim<DateTime?>? sonTarih,
    Yazim<String?>? projeId,
    Set<String>? etiketEklenen,
    Set<String>? etiketSilinen,
  }) async => cagrilar.add('ayrintilar:$id');

  @override
  Future<void> tamamlaGeriAl(String id, {required bool tamamlandi}) async =>
      cagrilar.add('tamamla:$id:$tamamlandi');

  @override
  Future<void> sil(String id) async => cagrilar.add('sil:$id');

  @override
  Stream<List<CakismaKaydi>> cakismaKayitlariniIzle(String entityId) =>
      Stream.value(const []);

  @override
  Future<void> cakismaCoz(String entityId, CakismaSecimi secim) async =>
      cagrilar.add('cakismaCoz:$entityId:$secim');

  @override
  Stream<List<Proje>> listelerGorunur() => Stream.value(const []);

  @override
  Future<void> listeEkle(String ad) async {}

  @override
  Future<void> listeDuzenle(String id, String yeniAd) async {}

  @override
  Future<void> listeSil(String id) async {}

  void yayinla(List<GorevGorunum> g) => _denetleyici.add(g);

  void kapat() => _denetleyici.close();
}

Future<void> _ekle(WidgetTester tester, String metin) async {
  await tester.enterText(find.byType(TextField), metin);
  await tester.tap(find.bySemanticsLabel(Metinler.ekleDugmesi));
  await tester.pump();
}

void main() {
  testWidgets('K112/a -- gorev ekleme ITME turunu tetikler', (tester) async {
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
    depo.yayinla(const []);
    await tester.pump();

    await _ekle(tester, 'K112 vaka a');

    expect(sira, [
      'ekle:K112 vaka a',
      'itme',
    ], reason: 'yerel yazma sonrasi itme KOSMALI');
  });

  testWidgets('K112/b -- SIRA: once YAZMA, sonra itme', (tester) async {
    // Ters sira sessiz bir kusurdur: itme once kosarsa kuyrugu HENUZ BOS
    // gorur ve hicbir sey gondermez. Bu ayak o mutanti oldurur.
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
    depo.yayinla(const []);
    await tester.pump();
    await _ekle(tester, 'sira');

    // TEK liste, GERCEK sira: yazma once, itme sonra.
    expect(sira, [
      'ekle:sira',
      'itme',
    ], reason: 'itme ONCE kosarsa kuyrugu BOS gorur -- M137 bu ayakta olur');
  });

  testWidgets('K112/c -- YANLIS-POZITIF: onYerelYazma null ise cokmez', (
    tester,
  ) async {
    final depo = _SahteDepo(<String>[]);
    addTearDown(depo.kapat);

    await tester.pumpWidget(MaterialApp(home: GorevListesiEkrani(depo: depo)));
    depo.yayinla(const []);
    await tester.pump();
    await _ekle(tester, 'tetikleyicisiz');

    expect(depo.cagrilar, ['ekle:tetikleyicisiz']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('K112/d -- BOS metin ne yazar ne tetikler', (tester) async {
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
    depo.yayinla(const []);
    await tester.pump();
    await _ekle(tester, '   ');

    expect(sira, isEmpty, reason: 'yazma yoksa itme de OLMAMALI');
  });
}

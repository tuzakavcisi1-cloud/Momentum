@TestOn('vm')
library;

// GOREV-SS2 G34 -- EKRAN VE COZUM EYLEMI KAPISI (widget testi). `a/b/c/g`
// burada olculur. `d/e/f` (cakismaCoz davranisi) T6/G32 kapsamindadir --
// bkz. T6-cakismacoz-testleri. `h` (tasma ayagi) MUTANTSIZ/BEYANLIDIR.

import 'package:client/design/metinler.dart';
import 'package:client/design/tema.dart';
import 'package:client/design/tokens.dart';
import 'package:client/sunum/cakisma_rozeti.dart';
import 'package:client/sunum/gorev_satiri.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _sarmala(Widget cocuk) => MaterialApp(theme: MomentumTema.olustur(Brightness.light), home: cocuk);

class _SahteDepo implements GorevDeposu {
  final List<CakismaKaydi> kayitlar;
  final List<String> cagrilar = [];
  _SahteDepo([this.kayitlar = const []]);

  @override
  Stream<List<GorevGorunum>> gorevlerGorunur() => const Stream.empty();
  @override
  Future<void> ekle(String baslik) async {}
  @override
  Future<void> duzenle(String id, String yeniBaslik) async {}
  @override
  Future<void> tamamlaGeriAl(String id, {required bool tamamlandi}) async {}
  @override
  Future<void> sil(String id) async {}
  @override
  Stream<List<CakismaKaydi>> cakismaKayitlariniIzle(String entityId) => Stream.value(kayitlar);
  @override
  Future<void> cakismaCoz(String entityId, CakismaSecimi secim) async {
    cagrilar.add('$entityId:$secim');
  }
}

Gorev _gorev() => Gorev(
  id: 'g34-e1',
  baslik: 'Test gorevi',
  tamamlandi: false,
  olusturuldu: DateTime.utc(2026, 1, 1),
  guncellendi: DateTime.utc(2026, 1, 1),
  senkronDurumu: 'cakisma',
  silindi: false,
);

void main() {
  testWidgets('G34/a: GorevSatiri -> CakismaRozeti entityId=gorev.id geçirir', (tester) async {
    final depo = _SahteDepo();
    await tester.pumpWidget(
      _sarmala(
        Scaffold(
          body: GorevSatiri(
            gorev: _gorev(),
            onTamamlaDegisti: (_) {},
            cakismaVarMi: true,
            depo: depo,
          ),
        ),
      ),
    );
    final rozet = tester.widget<CakismaRozeti>(find.byType(CakismaRozeti));
    expect(rozet.entityId, 'g34-e1');
    expect(rozet.depo, same(depo));
  });

  testWidgets('G34/b: cakisan alanin IKI degeri de ekranda, tasma yok', (tester) async {
    const kayit = CakismaKaydi(
      alan: 'fields:title',
      kaybedenDeger: 'Benim yerel basligim',
      kazananDeger: 'Onlarin uzak basligi',
    );
    await tester.pumpWidget(
      _sarmala(CakismaCozumSayfasi(entityId: 'g34-e1', depo: _SahteDepo([kayit]))),
    );
    await tester.pump();

    expect(find.text(kayit.kaybedenDeger), findsOneWidget);
    expect(find.text(kayit.kazananDeger), findsOneWidget);
    final rp1 = tester.renderObject<RenderParagraph>(find.text(kayit.kaybedenDeger));
    final rp2 = tester.renderObject<RenderParagraph>(find.text(kayit.kazananDeger));
    expect(rp1.didExceedMaxLines, isFalse);
    expect(rp2.didExceedMaxLines, isFalse);
  });

  testWidgets('G34/c: iki buton 48dp + Semantics(button:true) + AYRI etiketler', (tester) async {
    const kayit = CakismaKaydi(alan: 'fields:title', kaybedenDeger: 'A', kazananDeger: 'B');
    await tester.pumpWidget(
      _sarmala(CakismaCozumSayfasi(entityId: 'g34-e1', depo: _SahteDepo([kayit]))),
    );
    await tester.pump();

    final benimkiniTutButonu = find.widgetWithText(ElevatedButton, Metinler.cakismaBenimkiniTut);
    final onlarinkiniAlButonu = find.widgetWithText(ElevatedButton, Metinler.cakismaOnlarinkiniAl);
    expect(benimkiniTutButonu, findsOneWidget);
    expect(onlarinkiniAlButonu, findsOneWidget);
    expect(Metinler.cakismaBenimkiniTut == Metinler.cakismaOnlarinkiniAl, isFalse, reason: 'etiketler AYRI olmali');

    expect(tester.getSize(benimkiniTutButonu).height, MOlcu.dokunmaHedefi);
    expect(tester.getSize(onlarinkiniAlButonu).height, MOlcu.dokunmaHedefi);

    final semantics = tester.getSemantics(benimkiniTutButonu);
    expect(semantics.flagsCollection.isButton, isTrue);
  });

  testWidgets('G34/g: BOS DURUM -- 0 kayitla Metinler.cakismaKaydiYok gorunur, butonlar YOK', (tester) async {
    await tester.pumpWidget(
      _sarmala(CakismaCozumSayfasi(entityId: 'g34-e1', depo: _SahteDepo(const []))),
    );
    await tester.pump();

    expect(find.text(Metinler.cakismaKaydiYok), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });
}

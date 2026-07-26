import 'package:client/design/tema.dart';
import 'package:client/vitrin/durum_vitrini.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// T7 -- durum vitrininin 8 durumu `ByValueKey('vitrin_durum')` ile
/// bulunabilmeli (F5). main.dart'in gercek (--dart-define olmadan) yolu
/// path_provider/sqlite gerektiren gercek bir Veritabani baglantisi actigi
/// icin burada degil, entegrasyon dogrulamasinda kosulur.
void main() {
  const durumlar = [
    'vitrin_bos',
    'vitrin_yukleniyor',
    'vitrin_yerel',
    'vitrin_kuyrukta',
    'vitrin_senkronize',
    'vitrin_cevrimdisi',
    'vitrin_cakisma',
    'vitrin_hata',
  ];

  testWidgets('durum vitrininin 8 durumu da ByValueKey ile bulunur', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: MomentumTema.olustur(Brightness.light),
        home: const DurumVitrini(),
      ),
    );
    await tester.pump();

    for (final durum in durumlar) {
      expect(
        find.byKey(ValueKey(durum)),
        findsOneWidget,
        reason: '$durum anahtarli widget vitrinde bulunamadi',
      );
    }
  });
}

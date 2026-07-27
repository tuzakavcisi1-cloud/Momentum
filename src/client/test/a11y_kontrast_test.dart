@TestOn('vm')
library;

// G5 -- KONTRAST OLCUMU. @TestOn('vm') ZORUNLU (Z16): textContrastGuideline
// RenderObject.toImage cagirir ve flutter_test'te bunun kIsWeb korumasi
// YOKTUR; web'de "captureImage is not supported on the web" hatasi verir.
// Web durumu bu yuzden [DOGRULANMADI] -- gizlenmez, T0/00-ortam.txt'te yazili.

import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/veritabani.dart';
import 'package:client/sunum/gorev_listesi_ekrani.dart';
import 'package:client/vitrin/durum_vitrini.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('kontrast: durum vitrini textContrastGuideline (VM)', (tester) async {
    final tutamac = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(home: DurumVitrini()));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    tutamac.dispose();
  });

  testWidgets('kontrast: gercek ekran (yerel durum) textContrastGuideline (VM)', (tester) async {
    final db = Veritabani(NativeDatabase.memory());
    final sabitSaat = DateTime.utc(2026, 7, 27, 12);
    var idSayaci = 0;
    String idUret() => 'kontrast-test-${idSayaci++}';
    final ayarlarDeposu = AyarlarDeposu(db, idUret: idUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final depo = DriftGorevDeposu(
      db,
      saat: () => sabitSaat,
      idUret: idUret,
      hlc: HlcUretici(
        simdiMs: () => sabitSaat.millisecondsSinceEpoch,
        clientId: ayarlar.clientId,
      ),
      ayarlarDeposu: ayarlarDeposu,
      actorId: ayarlar.devUserId,
    );
    await depo.ekle('Kontrast testi');
    final tutamac = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(home: GorevListesiEkrani(depo: depo)));
    await tester.pump();
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    tutamac.dispose();
    await db.close();
  });
}

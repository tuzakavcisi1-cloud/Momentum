@TestOn('vm')
library;

// GOREV-R9 -- G10 ROZET KAPSAMI KAPISI (Dart birim + widget testi; koşan
// uygulama İSTEMEZ). K72 (P6/D4 DARALTMA): INSERT-from-pull 'senkronize'
// ile doğar (T1); UPDATE-of-local rozete DOKUNMAZ (kilit AYNEN durur).
// AYAK1/AYAK2/AYAK5 -- G10'un YALNIZ KENDİSİNE ait yeni kapsama (spec §6).
// AYAK3/AYAK4/AYAK6 -- mevcut kilidin (P6/P7) hâlâ sağlam olduğunu doğrular.

import 'dart:io';

import 'package:client/design/metinler.dart';
import 'package:client/senkron/uzak_degisiklik_uygulayici.dart';
import 'package:client/sunum/gorev_listesi_ekrani.dart';
import 'package:client/sunum/senkron_rozeti.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/veritabani.dart' hide Ayarlar;
import 'package:client/veri/wire_op.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory gecici;

  setUp(() {
    gecici = Directory.systemTemp.createTempSync('g10-rozet-kapsami-kapisi');
  });

  tearDown(() {
    try {
      gecici.deleteSync(recursive: true);
    } catch (_) {}
  });

  Veritabani dosyaDbAc() => Veritabani(NativeDatabase(File('${gecici.path}/m.sqlite')));

  Future<void> mevcutGorevYaz(Veritabani db, String id, {required String senkronDurumu}) async {
    await db
        .into(db.gorevler)
        .insert(
          GorevlerCompanion.insert(
            id: id,
            baslik: 'Eski baslik',
            olusturuldu: DateTime.utc(2025, 1, 1),
            guncellendi: DateTime.utc(2025, 1, 1),
            senkronDurumu: Value(senkronDurumu),
          ),
        );
  }

  Map<String, Object?> changesGirdisi({
    required String entityId,
    required String opId,
    required String clientId,
    required int wallMs,
    required String title,
  }) {
    final hlc = Hlc(wallMs: wallMs, counter: 0, clientId: clientId);
    final op = WireOp(
      operationId: opId,
      clientId: clientId,
      entityId: entityId,
      actorId: 'actor-1',
      entityType: 'Task',
      opHlc: hlc,
      fields: {'title': WireFieldWrite(value: title, hlc: hlc)},
    );
    return {'cursor': {'xid': 1, 'seq': 0}, 'payload': op.toJson()};
  }

  Map<String, Object?> snapshotGirdisi({
    required String entityId,
    required String winOpId,
    required int wallMs,
    required String title,
  }) => {
    'entityType': 'Task',
    'entityId': entityId,
    'scalars': [
      {
        'field': 'title',
        'value': title,
        'hlc': {'wallMs': wallMs, 'counter': 0, 'clientId': 'client-uzak'},
        'winOperationId': winOpId,
      },
    ],
    'sets': <Object?>[],
    'groups': <Object?>[],
  };

  // ================= AYAK1/AYAK2 -- G10'a ozgu: INSERT-from-pull =================

  test('AYAK1: changesUygula ile YENI entity dogar -- senkronDurumu == senkronize', () async {
    final db = dosyaDbAc();
    final uygulayici = UzakDegisiklikUygulayici(db);

    await uygulayici.changesUygula([
      changesGirdisi(entityId: 'e-ayak1', opId: 'op-ayak1', clientId: 'client-uzak', wallMs: 1000, title: 'AYAK1 yeni gorev'),
    ]);

    final yeni = await (db.select(db.gorevler)..where((t) => t.id.equals('e-ayak1'))).getSingle();
    expect(yeni.senkronDurumu, 'senkronize', reason: 'AYAK1: changesUygula INSERT-from-pull senkronize ile dogmali');
    await db.close();
  });

  test('AYAK2: snapshotUygula ile YENI entity dogar -- senkronDurumu == senkronize', () async {
    final db = dosyaDbAc();
    final uygulayici = UzakDegisiklikUygulayici(db);

    await uygulayici.snapshotUygula([
      snapshotGirdisi(entityId: 'e-ayak2', winOpId: 'op-ayak2', wallMs: 1000, title: 'AYAK2 yeni gorev'),
    ]);

    final yeni = await (db.select(db.gorevler)..where((t) => t.id.equals('e-ayak2'))).getSingle();
    expect(yeni.senkronDurumu, 'senkronize', reason: 'AYAK2: snapshotUygula INSERT-from-pull senkronize ile dogmali');
    await db.close();
  });

  // ================= AYAK3/AYAK4 -- P6/P7 kilidi UPDATE dalinda AYNEN durur =================

  test('AYAK3: MEVCUT cakisma satir uzak degisiklik alir -- rozet cakisma KALIR (P6 saglam)', () async {
    final db = dosyaDbAc();
    await mevcutGorevYaz(db, 'e-ayak3', senkronDurumu: 'cakisma');
    final uygulayici = UzakDegisiklikUygulayici(db);

    await uygulayici.changesUygula([
      changesGirdisi(entityId: 'e-ayak3', opId: 'op-ayak3', clientId: 'client-uzak', wallMs: 5000, title: 'AYAK3 uzak baslik'),
    ]);

    final gorev = await (db.select(db.gorevler)..where((t) => t.id.equals('e-ayak3'))).getSingle();
    expect(gorev.baslik, 'AYAK3 uzak baslik', reason: 'AYAK3: projeksiyon kazanmali (yoksa UPDATE dali hic kosmaz)');
    expect(gorev.senkronDurumu, 'cakisma', reason: 'AYAK3: P6 -- UPDATE dali rozete DOKUNMAZ');
    await db.close();
  });

  test('AYAK4: MEVCUT yerel satir (bekleyen yerel yazim) echo alir -- rozet yerel KALIR (P7 kardesi)', () async {
    final db = dosyaDbAc();
    await mevcutGorevYaz(db, 'e-ayak4', senkronDurumu: 'yerel');
    final uygulayici = UzakDegisiklikUygulayici(db);

    // Echo: sunucunun (kirpilmis) HLC'siyle geri gelen AYNI yazim -- D6/P7'nin
    // asli senaryosu; UPDATE dali yine de rozete DOKUNMAMALI.
    await uygulayici.changesUygula([
      changesGirdisi(entityId: 'e-ayak4', opId: 'op-ayak4', clientId: 'client-yerel', wallMs: 9999, title: 'AYAK4 kirpilmis deger'),
    ]);

    final gorev = await (db.select(db.gorevler)..where((t) => t.id.equals('e-ayak4'))).getSingle();
    expect(gorev.baslik, 'AYAK4 kirpilmis deger', reason: 'AYAK4: echo uygulanmali (D6)');
    expect(gorev.senkronDurumu, 'yerel', reason: 'AYAK4: P7 -- UPDATE dali rozete DOKUNMAZ');
    await db.close();
  });

  // ================= AYAK5/AYAK6 -- widget: rozet gorunurlugu =================

  Widget gercekEkranSarmalayici(GorevDeposu depo) => MaterialApp(home: GorevListesiEkrani(depo: depo));

  testWidgets('AYAK5: changesUygula ile UCTAN UCA dogan (INSERT-from-pull) satir listede -- Yalnizca bu cihazda metni YOK', (tester) async {
    // PAZARLIKSIZ: bu ayak AYAK1'in SENTETIK degil, GERCEK uretim yolundan
    // (changesUygula -> _projeksiyonYaz INSERT dali) dogan satirini render
    // eder -- M41/M43 T1'in INSERT'ine dokunduğunda bu ayak da DUSMELIDIR
    // (spec §6); sabit/elle Value('senkronize') yazan bir depo bunu OLCEMEZ.
    final db = dosyaDbAc();
    final uygulayici = UzakDegisiklikUygulayici(db);
    await uygulayici.changesUygula([
      changesGirdisi(entityId: 'g10-ayak5', opId: 'op-ayak5', clientId: 'client-uzak', wallMs: 1000, title: 'AYAK5 uctan uca gorev'),
    ]);

    // Yalniz OKUMA icin -- write yollari bu ayakta hic cagrilmaz, satir
    // yukarida GERCEK changesUygula yoluyla zaten yazildi.
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final hlc = HlcUretici(simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch, clientId: ayarlar.clientId);
    final okuyucuDepo = DriftGorevDeposu(db, saat: () => DateTime.now().toUtc(), idUret: uretimIdUret, hlc: hlc, ayarlarDeposu: ayarlarDeposu, actorId: ayarlar.devUserId);
    await tester.pumpWidget(gercekEkranSarmalayici(okuyucuDepo));
    await tester.pumpAndSettle();

    // GOREV-R10 spec §4: POZITIF iddia -- join yonu ters donerse (leftOuterJoin
    // yerine innerJoin) satirin TAMAMI listeden duser ve asagidaki findsNothing
    // yine de gecerdi (kor). Baslik metninin VAR oldugunu ayrica dogrulamak
    // bu mutant sinifini yakalar.
    expect(find.text('AYAK5 uctan uca gorev'), findsOneWidget);
    // GOREV-A7 [K85 / D-A7-1]: rozetin GORUNUR dizgesi kisaldi (bkz. AYAK6).
    // Bu ayak NEGATIF iddiadir: rozet HIC cizilmemeli -- bu yuzden hem kisa
    // hem tam dizge aranir; yalniz birini aramak, digerinin sizmasina
    // sessizce izin verirdi.
    expect(find.text(Metinler.rozetKisaYerel), findsNothing);
    expect(find.text(Metinler.yalnizcaBuCihazda), findsNothing);
    await db.close();
  });

  testWidgets('AYAK6: DriftGorevDeposu.ekle() ile uretilmis satir listede -- Yalnizca bu cihazda metni VAR', (tester) async {
    final db = dosyaDbAc();
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final hlc = HlcUretici(simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch, clientId: ayarlar.clientId);
    final depo = DriftGorevDeposu(db, saat: () => DateTime.now().toUtc(), idUret: uretimIdUret, hlc: hlc, ayarlarDeposu: ayarlarDeposu, actorId: ayarlar.devUserId);

    // PAZARLIKSIZ (spec §5): satir SENTETIK yazilmaz -- uretimdeki TEK 'yerel'
    // ureticisi olan gercek ekle() cagrilir (gorev_deposu.dart:91-115).
    await depo.ekle('AYAK6 gercek ekle() gorevi');

    await tester.pumpWidget(gercekEkranSarmalayici(depo));
    await tester.pumpAndSettle();

    // GOREV-A7 [K85 / D-A7-1]: gorunur dizge "Bu cihazda"ya kisaldi; tam
    // metin Semantics(label:)'da yasiyor (G15/A13 orada olcer).
    expect(find.text(Metinler.rozetKisaYerel), findsOneWidget);
    expect(
      SenkronRozeti.tamMetinIcin(SenkronDurumTuru.yerel),
      Metinler.yalnizcaBuCihazda,
    );
    await db.close();
  });
}

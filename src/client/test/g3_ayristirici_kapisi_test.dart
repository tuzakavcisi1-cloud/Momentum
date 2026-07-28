@TestOn('vm')
library;

// GOREV-slice-3d G3 -- IKI AYRISTIRICI + PROJEKSIYON KAPISI (Dart birim
// testi; ag YOK). Girdi: elle yazilmis sabit fixture JSON'lar.

import 'dart:convert';
import 'dart:io';

import 'package:client/senkron/uzak_degisiklik_uygulayici.dart';
import 'package:client/veri/veritabani.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory gecici;

  setUpAll(() {
    final kanitDizini = Directory('../../KANIT/slice-3d/03-G3-ayristirici');
    kanitDizini.createSync(recursive: true);
    File('test/destekler/fixture_changes.json').copySync('${kanitDizini.path}/fixture_changes.json');
    File('test/destekler/fixture_snapshot.json').copySync('${kanitDizini.path}/fixture_snapshot.json');
  });

  setUp(() {
    gecici = Directory.systemTemp.createTempSync('g3-ayristirici-kapisi');
  });

  tearDown(() {
    try {
      gecici.deleteSync(recursive: true);
    } catch (_) {}
  });

  Veritabani dosyaDbAc() => Veritabani(NativeDatabase(File('${gecici.path}/m.sqlite')));

  List<Map<String, Object?>> changesFixtureOku() =>
      (jsonDecode(File('test/destekler/fixture_changes.json').readAsStringSync()) as List)
          .cast<Map<String, Object?>>();
  List<Map<String, Object?>> snapshotFixtureOku() =>
      (jsonDecode(File('test/destekler/fixture_snapshot.json').readAsStringSync()) as List)
          .cast<Map<String, Object?>>();

  Future<void> mevcutGorevYaz(Veritabani db, String id, {String senkronDurumu = 'senkronize'}) async {
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

  test('D2: changes fixture -- fields.title + groups.completion okundu; projeksiyon guncellendi', () async {
    final db = dosyaDbAc();
    await mevcutGorevYaz(db, 'e-mevcut-1');
    final uygulayici = UzakDegisiklikUygulayici(db);

    await uygulayici.changesUygula(changesFixtureOku());

    final gorev = await (db.select(db.gorevler)..where((t) => t.id.equals('e-mevcut-1'))).getSingle();
    expect(gorev.baslik, 'Guncellenmis baslik');
    expect(gorev.tamamlandi, isTrue, reason: 'groups.completion status=done -> tamamlandi=true');
    await db.close();
  });

  test('D2: snapshot fixture -- scalars[]/groups[] okundu; winOperationId DOGRUDAN kullanildi', () async {
    final db = dosyaDbAc();
    final uygulayici = UzakDegisiklikUygulayici(db);

    await uygulayici.snapshotUygula(snapshotFixtureOku());

    final acik = await (db.select(db.gorevler)..where((t) => t.id.equals('e-snap-open'))).getSingle();
    expect(acik.baslik, 'Acik gorev');
    expect(acik.tamamlandi, isFalse);
    await db.close();
  });

  test('D2: "sets":null,"order":null tasiyan payload -- COKME YOK, kanal bos sayildi', () async {
    final db = dosyaDbAc();
    await mevcutGorevYaz(db, 'e-mevcut-1');
    final uygulayici = UzakDegisiklikUygulayici(db);

    // fixture_changes.json'daki TUM ophlar zaten sets:null/order:null tasir --
    // cokmeden tamamlanmasi bu ayagin kaniti.
    await expectLater(uygulayici.changesUygula(changesFixtureOku()), completes);
    await db.close();
  });

  test('D2: notes/priority tasiyan payload -- UzakAlanDurumunda satir VAR, Gorevler DEGISMEDI', () async {
    final db = dosyaDbAc();
    await mevcutGorevYaz(db, 'e-mevcut-1');
    final uygulayici = UzakDegisiklikUygulayici(db);

    await uygulayici.changesUygula(changesFixtureOku());

    final notesSatiri = await (db.select(db.uzakAlanDurumu)
          ..where((t) => t.entityId.equals('e-mevcut-1') & t.alan.equals('fields:notes')))
        .getSingleOrNull();
    expect(notesSatiri, isNotNull, reason: 'bilinmeyen alan UzakAlanDurumuna kaydedilmeli');

    final gorev = await (db.select(db.gorevler)..where((t) => t.id.equals('e-mevcut-1'))).getSingle();
    expect(gorev.baslik, 'Guncellenmis baslik', reason: 'notes Gorevlerde HICBIR sutuna yazilmamali');
    await db.close();
  });

  test('D2: "sets":[...] tasiyan snapshot -- yok sayildi, cokme yok, UzakAlanDurumuna YAZILMADI', () async {
    final db = dosyaDbAc();
    final uygulayici = UzakDegisiklikUygulayici(db);

    await expectLater(uygulayici.snapshotUygula(snapshotFixtureOku()), completes);

    final setSatirlari = await (db.select(db.uzakAlanDurumu)..where((t) => t.alan.like('sets:%'))).get();
    expect(setSatirlari, isEmpty, reason: 'sets kanali bilincli olarak yok sayilir (SINIR)');
    await db.close();
  });

  test('D4: completion.status == "open" -> tamamlandi == false', () async {
    final db = dosyaDbAc();
    final uygulayici = UzakDegisiklikUygulayici(db);
    await uygulayici.snapshotUygula(snapshotFixtureOku());
    final gorev = await (db.select(db.gorevler)..where((t) => t.id.equals('e-snap-open'))).getSingle();
    expect(gorev.tamamlandi, isFalse);
    await db.close();
  });

  test('D4: completion.status == "done" -> tamamlandi == true', () async {
    final db = dosyaDbAc();
    final uygulayici = UzakDegisiklikUygulayici(db);
    await uygulayici.snapshotUygula(snapshotFixtureOku());
    final gorev = await (db.select(db.gorevler)..where((t) => t.id.equals('e-snap-done'))).getSingle();
    expect(gorev.tamamlandi, isTrue);
    await db.close();
  });

  test('D4: isDeleted.value == "True" (buyuk T) -> silindi FALSE kalir (Ordinal, tam dize)', () async {
    final db = dosyaDbAc();
    final uygulayici = UzakDegisiklikUygulayici(db);
    await uygulayici.snapshotUygula(snapshotFixtureOku());
    final gorev = await (db.select(db.gorevler)..where((t) => t.id.equals('e-snap-done'))).getSingle();
    expect(gorev.silindi, isFalse, reason: '"True" != "true" ordinal -- silinmis SAYILMAZ');
    await db.close();
  });

  test('D4: uygulama sonrasi senkronDurumu DEGISMEDI (rozete dokunulmadi)', () async {
    final db = dosyaDbAc();
    await mevcutGorevYaz(db, 'e-mevcut-1', senkronDurumu: 'cakisma');
    final uygulayici = UzakDegisiklikUygulayici(db);

    await uygulayici.changesUygula(changesFixtureOku());

    final gorev = await (db.select(db.gorevler)..where((t) => t.id.equals('e-mevcut-1'))).getSingle();
    expect(gorev.senkronDurumu, 'cakisma', reason: 'uzak yazim rozete DOKUNMAMALI');
    await db.close();
  });

  test('D4: yerelde OLMAYAN entityId -- Gorevlere INSERT edildi; baslik telden, senkronDurumu==senkronize (R9/T1)', () async {
    final db = dosyaDbAc();
    final uygulayici = UzakDegisiklikUygulayici(db);

    await uygulayici.changesUygula(changesFixtureOku());

    final yeni = await (db.select(db.gorevler)..where((t) => t.id.equals('e-yeni-1'))).getSingle();
    expect(yeni.baslik, 'Yeni entity basligi');
    expect(yeni.senkronDurumu, 'senkronize', reason: 'K72/R9-T1: INSERT-from-pull senkronize ile dogar -- bekleyen yerel yazim yok, P6/P7 kapsami disi');
    await db.close();
  });

  test('D4: ayni fixture IKI KEZ, iki farkli sanal saatte uygulanir -- olusturuldu iki kosumda da AYNI', () async {
    final db1 = dosyaDbAc();
    final uygulayici1 = UzakDegisiklikUygulayici(db1);
    await uygulayici1.changesUygula(changesFixtureOku());
    final ilkKosum = await (db1.select(db1.gorevler)..where((t) => t.id.equals('e-yeni-1'))).getSingle();
    await db1.close();

    // [DESIGN-LITERAL: test zamanlama gecikmesi, tasarim tokeni degil]
    await Future<void>.delayed(const Duration(milliseconds: 50)); // gercek saat GERCEKTEN ilerler

    final gecici2 = Directory.systemTemp.createTempSync('g3-ikinci-kosum');
    final db2 = Veritabani(NativeDatabase(File('${gecici2.path}/m2.sqlite')));
    final uygulayici2 = UzakDegisiklikUygulayici(db2);
    await uygulayici2.changesUygula(changesFixtureOku());
    final ikinciKosum = await (db2.select(db2.gorevler)..where((t) => t.id.equals('e-yeni-1'))).getSingle();
    await db2.close();
    try {
      gecici2.deleteSync(recursive: true);
    } catch (_) {}

    expect(
      ikinciKosum.olusturuldu,
      ilkKosum.olusturuldu,
      reason: 'olusturuldu VERIDEN turetilir (en kucuk op-HLC wallMs), gercek saatten degil',
    );
  });

  test('D2: dolu bir UzakAlanDurumu + Gorevler ustune SNAPSHOT uygulanir -- tablolar TEMIZLENMEDI', () async {
    final db = dosyaDbAc();
    await mevcutGorevYaz(db, 'e-yerel-baska', senkronDurumu: 'kuyrukta');
    await db
        .into(db.uzakAlanDurumu)
        .insert(
          UzakAlanDurumuCompanion.insert(
            entityType: 'Task',
            entityId: 'e-yerel-baska',
            alan: 'fields:title',
            hlcWall: 999,
            hlcCounter: 0,
            hlcClientId: 'cccccccc00000000000000000000000',
            winOpId: 'dddddddd00000000000000000000000',
          ),
        );

    final uygulayici = UzakDegisiklikUygulayici(db);
    await uygulayici.snapshotUygula(snapshotFixtureOku());

    final halaVarMi = await (db.select(db.gorevler)..where((t) => t.id.equals('e-yerel-baska'))).getSingleOrNull();
    expect(halaVarMi, isNotNull, reason: 'snapshotta olmayan yerel satir SILINMEMELI (birlestirici)');
    final metaHalaVarMi = await (db.select(db.uzakAlanDurumu)..where((t) => t.entityId.equals('e-yerel-baska'))).getSingleOrNull();
    expect(metaHalaVarMi, isNotNull, reason: 'UzakAlanDurumu snapshot uygulamasinda TEMIZLENMEZ');

    // snapshottaki entity'ler de dogru uygulandi (D3 yolundan gectigini dolayli dogrular).
    final acik = await (db.select(db.gorevler)..where((t) => t.id.equals('e-snap-open'))).getSingleOrNull();
    expect(acik, isNotNull);
    await db.close();
  });
}

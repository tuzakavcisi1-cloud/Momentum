@TestOn('vm')
library;

// GOREV-slice-3d G2 -- SEMA / MIGRATION KAPISI (Drift, gercek dosya DB).
// PAZARLIKSIZ: NativeDatabase.memory() YASAK (slice-3c G3 gerekcesi: "kapat/
// yeniden ac" ayagi bellekte dogru kodla da yesil kalir, M14 ile dogru kod
// ayirt edilemez).

import 'dart:io';

import 'package:client/veri/veritabani.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v3.dart' as v3;
import 'generated_migrations/schema_v4.dart' as v4;

Future<String?> _createTableSql(GeneratedDatabase db, String tablo) async {
  final satirlar = await db
      .customSelect(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name=?",
        variables: [Variable.withString(tablo)],
      )
      .get();
  if (satirlar.isEmpty) return null;
  return satirlar.single.read<String>('sql');
}

void main() {
  late Directory gecici;

  setUp(() {
    gecici = Directory.systemTemp.createTempSync('g2-migration-kapisi');
  });

  tearDown(() {
    try {
      gecici.deleteSync(recursive: true);
    } catch (_) {}
  });

  Veritabani dosyaDbAc(String ad) =>
      Veritabani(NativeDatabase(File('${gecici.path}/$ad.sqlite')));

  test('D1: schemaVersion == 5 (GOREV-SS2 T1: 4->5 zorunlu guncelleme)', () async {
    final db = dosyaDbAc('m1');
    expect(db.schemaVersion, 5);
    await db.close();
  });

  test('D1: v3->v4 migration hatasiz -- uzak_alan_durumu tablosu var', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(3);
    final yeniDb = Veritabani(schema.newConnection());

    final sql = await _createTableSql(yeniDb, 'uzak_alan_durumu');
    expect(sql, isNotNull, reason: 'migration sonrasi uzak_alan_durumu tablosu var olmali');
    await yeniDb.close();
  });

  test('D1: v3teki uc Gorevler satiri migration sonrasi ucu de aynen durur', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(3);
    final eskiDb = v3.DatabaseAtV3(schema.newConnection());
    for (final id in ['g2-v3-1', 'g2-v3-2', 'g2-v3-3']) {
      await eskiDb.customStatement(
        "INSERT INTO gorevler (id, baslik, tamamlandi, olusturuldu, guncellendi, senkron_durumu, silindi) "
        "VALUES (?, ?, 0, ?, ?, 'yerel', 0)",
        [id, 'Gorev $id', DateTime.utc(2026, 1, 1).toIso8601String(), DateTime.utc(2026, 1, 1).toIso8601String()],
      );
    }
    await eskiDb.close();

    final yeniDb = Veritabani(schema.newConnection());
    final satirlar = await yeniDb.select(yeniDb.gorevler).get();
    expect(satirlar.map((s) => s.id).toSet(), {'g2-v3-1', 'g2-v3-2', 'g2-v3-3'});
    await yeniDb.close();
  });

  test('D1: Gorevler CREATE TABLE SQL metni v3 ve v4te bayt bayt AYNI', () async {
    final verifier = SchemaVerifier(GeneratedHelper());

    final v3Schema = await verifier.schemaAt(3);
    final v3Db = v3.DatabaseAtV3(v3Schema.newConnection());
    final v3Sql = await _createTableSql(v3Db, 'gorevler');
    await v3Db.close();

    final v4Schema = await verifier.schemaAt(3);
    final v4Db = Veritabani(v4Schema.newConnection()); // migration'i tetikler
    final v4Sql = await _createTableSql(v4Db, 'gorevler');
    await v4Db.close();

    expect(v3Sql, isNotNull);
    expect(v4Sql, v3Sql, reason: 'D1: Gorevlere DOKUNULMAZ, alterTable cagrilmaz');
  });

  test('D1: UzakAlanDurumu PK (entityType, entityId, alan) -- ikinci yazim UPSERT, kopya satir dogmaz', () async {
    final db = dosyaDbAc('m5');
    await db.into(db.uzakAlanDurumu).insertOnConflictUpdate(
          UzakAlanDurumuCompanion.insert(
            entityType: 'Task',
            entityId: 'e1',
            alan: 'fields:title',
            hlcWall: 1000,
            hlcCounter: 0,
            hlcClientId: 'c1',
            winOpId: 'op1',
          ),
        );
    await db.into(db.uzakAlanDurumu).insertOnConflictUpdate(
          UzakAlanDurumuCompanion.insert(
            entityType: 'Task',
            entityId: 'e1',
            alan: 'fields:title',
            hlcWall: 2000,
            hlcCounter: 0,
            hlcClientId: 'c1',
            winOpId: 'op2',
          ),
        );
    final satirlar = await db.select(db.uzakAlanDurumu).get();
    expect(satirlar, hasLength(1), reason: 'PK ihlali degil, upsert olmali');
    expect(satirlar.single.hlcWall, 2000);
    expect(satirlar.single.winOpId, 'op2');
    await db.close();
  });

  test('SS2 G31/c: v4->v5 migration hatasiz -- cakisma_kayitlari tablosu var', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(4);
    final yeniDb = Veritabani(schema.newConnection());

    final sql = await _createTableSql(yeniDb, 'cakisma_kayitlari');
    expect(sql, isNotNull, reason: 'migration sonrasi cakisma_kayitlari tablosu var olmali');
    await yeniDb.close();
  });

  test('SS2 G31/c: v4teki uc Gorevler satiri migration sonrasi ucu de aynen durur', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(4);
    final eskiDb = v4.DatabaseAtV4(schema.newConnection());
    for (final id in ['ss2-v4-1', 'ss2-v4-2', 'ss2-v4-3']) {
      await eskiDb.customStatement(
        "INSERT INTO gorevler (id, baslik, tamamlandi, olusturuldu, guncellendi, senkron_durumu, silindi) "
        "VALUES (?, ?, 0, ?, ?, 'yerel', 0)",
        [id, 'Gorev $id', DateTime.utc(2026, 1, 1).toIso8601String(), DateTime.utc(2026, 1, 1).toIso8601String()],
      );
    }
    await eskiDb.close();

    final yeniDb = Veritabani(schema.newConnection());
    final satirlar = await yeniDb.select(yeniDb.gorevler).get();
    expect(satirlar.map((s) => s.id).toSet(), {'ss2-v4-1', 'ss2-v4-2', 'ss2-v4-3'});
    await yeniDb.close();
  });

  test('SS2 G31/c: Gorevler CREATE TABLE SQL metni v4 ve v5te bayt bayt AYNI', () async {
    final verifier = SchemaVerifier(GeneratedHelper());

    final v4Schema = await verifier.schemaAt(4);
    final v4Db = v4.DatabaseAtV4(v4Schema.newConnection());
    final v4Sql = await _createTableSql(v4Db, 'gorevler');
    await v4Db.close();

    final v5Schema = await verifier.schemaAt(4);
    final v5Db = Veritabani(v5Schema.newConnection()); // migration'i tetikler
    final v5Sql = await _createTableSql(v5Db, 'gorevler');
    await v5Db.close();

    expect(v4Sql, isNotNull);
    expect(v5Sql, v4Sql, reason: 'D-SS2-1: Gorevlere DOKUNULMAZ, alterTable cagrilmaz');
  });

  test('D1: ayarlar.imlecSahibi sutunu var -- eski (migration\'dan gelen) satirda null', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(3);
    final eskiDb = v3.DatabaseAtV3(schema.newConnection());
    await eskiDb.customStatement(
      "INSERT INTO ayarlar (id, client_id, son_wall, son_counter, dev_user_id) VALUES (1, ?, 0, 0, ?)",
      ['client-v3', 'dev-v3'],
    );
    await eskiDb.close();

    final yeniDb = Veritabani(schema.newConnection());
    final ayarSatiri = await yeniDb.select(yeniDb.ayarlar).getSingle();
    expect(ayarSatiri.clientId, 'client-v3', reason: 'eski satir korunmali');
    expect(ayarSatiri.imlecSahibi, isNull, reason: 'migrationdan gelen eski satir sahipsiz (null) olmali');
    await yeniDb.close();
  });
}

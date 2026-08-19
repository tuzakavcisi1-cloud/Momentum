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
import 'generated_migrations/schema_v1.dart' as v1;
import 'generated_migrations/schema_v3.dart' as v3;
import 'generated_migrations/schema_v4.dart' as v4;
import 'generated_migrations/schema_v5.dart' as v5;
import 'generated_migrations/schema_v6.dart' as v6;
import 'generated_migrations/schema_v7.dart' as v7;

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

  test(
    'D1: schemaVersion == 8 (IS-EMRI-o85-A liste dilimi: 7->8 zorunlu guncelleme)',
    () async {
      final db = dosyaDbAc('m1');
      expect(db.schemaVersion, 8);
      await db.close();
    },
  );

  // ODEV.md §4(a) -- "oncelik + son tarih" dilimi. v4->v5'ten FARKLI olarak
  // bu migration `Gorevler`e DOKUNUR (iki nullable sutun), bu yuzden "SQL
  // metni bayt bayt AYNI" iddiasi burada GECERSIZDIR -- yerine ONUN AYNASI
  // yazilir: yeni sutunlar v6'da VAR, v5'te YOK.
  test(
    'ODEV §4(a): v5->v6 migration hatasiz -- gorevlerde oncelik + son_tarih sutunlari VAR',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(5);
      final yeniDb = Veritabani(schema.newConnection()); // migration'i tetikler

      final sql = await _createTableSql(yeniDb, 'gorevler');
      expect(sql, isNotNull);
      expect(
        sql,
        contains('oncelik'),
        reason: 'v6 gorevler tablosunda oncelik sutunu olmali',
      );
      expect(
        sql,
        contains('son_tarih'),
        reason: 'v6 gorevler tablosunda son_tarih sutunu olmali',
      );
      await yeniDb.close();
    },
  );

  // ODEV.md §4(a) ETIKET DILIMI -- v6->v7. v4->v5'in AYNI deseni: SALT-EKLEME
  // (yeni tablo), `Gorevler`e DOKUNULMAZ ⇒ "gorevler SQL metni BAYT BAYT AYNI"
  // iddiasi burada GECERLIDIR ve yazilir.
  test(
    'etiket dilimi: v6->v7 migration hatasiz -- gorev_etiketleri tablosu VAR',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(6);
      final yeniDb = Veritabani(schema.newConnection()); // migration'i tetikler

      final sql = await _createTableSql(yeniDb, 'gorev_etiketleri');
      expect(sql, isNotNull, reason: 'v7de gorev_etiketleri tablosu olmali');
      expect(sql, contains('add_tag'));
      expect(sql, contains('iptal_edildi'));
      await yeniDb.close();
    },
  );

  // POZITIF KONTROL: yukaridaki test bir sey OLCUYOR mu? v6'da tablo YOKSA
  // olcuyor; VARSA yukaridaki test bos bir iddiadir.
  test(
    'etiket dilimi: v6 semasinda gorev_etiketleri HENUZ YOK (pozitif kontrol)',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(6);
      final v6Db = v6.DatabaseAtV6(schema.newConnection());
      final v6Sql = await _createTableSql(v6Db, 'gorev_etiketleri');
      await v6Db.close();
      expect(v6Sql, isNull);
    },
  );

  // 🔴 SALT-EKLEME KANITI: v6->v7 `Gorevler`e DOKUNMADI. Bu iddia "bugune
  // kadar dokunulmadi" degil, "BU ADIM dokunmadi" olcer -- v6 semasindaki
  // gorevler SQL'i ile v7deki BIREBIR ayni olmali.
  test(
    'etiket dilimi: v6->v7 gorevler tablosunun SQL metni BAYT BAYT AYNI',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());

      final v6Schema = await verifier.schemaAt(6);
      final v6Db = v6.DatabaseAtV6(v6Schema.newConnection());
      final oncekiSql = await _createTableSql(v6Db, 'gorevler');
      await v6Db.close();

      // 🔴 [IS-EMRI-o85-A ile duzeltildi] `Veritabani(...)` GUNCEL semaya
      // (artik v8) kadar gocer -- "v6->v7 dokunmadi" iddiasini v7'YE DEGIL
      // BUGUNE karsi sinardi (v3->GUNCEL testlerinin ayni tuzagi). Migration
      // KOSTURMEDEN, v7'nin KENDI dondurulmus (onCreate) anlik goruntusu
      // dogrudan v6'nınkiyle karsilastirilir -- ikisi de BAGIMSIZ olusturulur.
      final v7Schema = await verifier.schemaAt(7);
      final v7Db = v7.DatabaseAtV7(v7Schema.newConnection());
      final sonrakiSql = await _createTableSql(v7Db, 'gorevler');
      await v7Db.close();

      expect(oncekiSql, isNotNull);
      expect(sonrakiSql, oncekiSql);
    },
  );

  // v1'den gelen kullanici: `gorevler` v1->v2'de YENIDEN YARATILIR, sonra
  // v6->v7 yeni tabloyu ekler. Zincirin TAMAMI kosulur (o74'te v1 yolu bir
  // kez COKMUSTU -- kagit denetimi bunu KACIRMISTI).
  test(
    'etiket dilimi: v1->v7 zinciri hatasiz -- gorev_etiketleri VAR, v1 satiri KORUNDU',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(1);
      final eskiDb = v1.DatabaseAtV1(schema.newConnection());
      await eskiDb.customStatement(
        "INSERT INTO gorevler (id, baslik, tamamlandi, olusturuldu, guncellendi, senkron_durumu, silindi) "
        "VALUES ('v1-etiket', 'Eski gorev', 0, ?, ?, 'yerel', 0)",
        [
          DateTime.utc(2026, 1, 1).toIso8601String(),
          DateTime.utc(2026, 1, 1).toIso8601String(),
        ],
      );
      await eskiDb.close();

      final yeniDb = Veritabani(schema.newConnection());
      final sql = await _createTableSql(yeniDb, 'gorev_etiketleri');
      final satirlar = await yeniDb.select(yeniDb.gorevler).get();
      await yeniDb.close();

      expect(
        sql,
        isNotNull,
        reason: 'v1 yolundan gelen kullanicida da tablo yaratilmali',
      );
      expect(satirlar.map((s) => s.id).toSet(), {'v1-etiket'});
    },
  );

  // POZITIF KONTROL: yukaridaki test bir sey OLCUYOR mu? v5'te bu iki sutun
  // YOKSA olcuyor; VARSA yukaridaki test bos bir iddiadir.
  test(
    'ODEV §4(a): v5 semasinda oncelik/son_tarih HENUZ YOK (pozitif kontrol)',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(5);
      final v5Db = v5.DatabaseAtV5(schema.newConnection());
      final v5Sql = await _createTableSql(v5Db, 'gorevler');
      await v5Db.close();

      expect(v5Sql, isNotNull);
      expect(v5Sql, isNot(contains('oncelik')));
      expect(v5Sql, isNot(contains('son_tarih')));
    },
  );

  test(
    'ODEV §4(a): v5teki uc Gorevler satiri migration sonrasi durur, yeni sutunlari NULL',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(5);
      final eskiDb = v5.DatabaseAtV5(schema.newConnection());
      for (final id in ['v6-1', 'v6-2', 'v6-3']) {
        await eskiDb.customStatement(
          "INSERT INTO gorevler (id, baslik, tamamlandi, olusturuldu, guncellendi, senkron_durumu, silindi) "
          "VALUES (?, ?, 0, ?, ?, 'yerel', 0)",
          [
            id,
            'Gorev $id',
            DateTime.utc(2026, 1, 1).toIso8601String(),
            DateTime.utc(2026, 1, 1).toIso8601String(),
          ],
        );
      }
      await eskiDb.close();

      final yeniDb = Veritabani(schema.newConnection());
      final satirlar = await yeniDb.select(yeniDb.gorevler).get();
      expect(satirlar.map((s) => s.id).toSet(), {'v6-1', 'v6-2', 'v6-3'});
      expect(
        satirlar.every((s) => s.oncelik == null),
        isTrue,
        reason: 'ALTER TABLE ADD COLUMN mevcut satirlara NULL yazmali',
      );
      expect(satirlar.every((s) => s.sonTarih == null), isTrue);
      await yeniDb.close();
    },
  );

  test(
    'D1: v3->v4 migration hatasiz -- uzak_alan_durumu tablosu var',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(3);
      final yeniDb = Veritabani(schema.newConnection());

      final sql = await _createTableSql(yeniDb, 'uzak_alan_durumu');
      expect(
        sql,
        isNotNull,
        reason: 'migration sonrasi uzak_alan_durumu tablosu var olmali',
      );
      await yeniDb.close();
    },
  );

  test(
    'D1: v3teki uc Gorevler satiri migration sonrasi ucu de aynen durur',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(3);
      final eskiDb = v3.DatabaseAtV3(schema.newConnection());
      for (final id in ['g2-v3-1', 'g2-v3-2', 'g2-v3-3']) {
        await eskiDb.customStatement(
          "INSERT INTO gorevler (id, baslik, tamamlandi, olusturuldu, guncellendi, senkron_durumu, silindi) "
          "VALUES (?, ?, 0, ?, ?, 'yerel', 0)",
          [
            id,
            'Gorev $id',
            DateTime.utc(2026, 1, 1).toIso8601String(),
            DateTime.utc(2026, 1, 1).toIso8601String(),
          ],
        );
      }
      await eskiDb.close();

      final yeniDb = Veritabani(schema.newConnection());
      final satirlar = await yeniDb.select(yeniDb.gorevler).get();
      expect(satirlar.map((s) => s.id).toSet(), {
        'g2-v3-1',
        'g2-v3-2',
        'g2-v3-3',
      });
      await yeniDb.close();
    },
  );

  test(
    'D1/ODEV §4(a): v3 -> GUNCEL -- gorevler YALNIZ uc nullable sutun kazanir',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());

      final v3Schema = await verifier.schemaAt(3);
      final v3Db = v3.DatabaseAtV3(v3Schema.newConnection());
      final v3Sql = await _createTableSql(v3Db, 'gorevler');
      await v3Db.close();

      final guncelSchema = await verifier.schemaAt(3);
      final guncelDb = Veritabani(
        guncelSchema.newConnection(),
      ); // migration'i tetikler
      final guncelSql = await _createTableSql(guncelDb, 'gorevler');
      await guncelDb.close();

      // 🔴 ODEV.md §4(a): bu testin ESKI iddiasi ("bayt bayt AYNI") ARTIK
      // YANLIStir -- ve testin ne olctugu bastan beri yanlis adlandirilmisti:
      // `Veritabani(...)` DAIMA EN GUNCEL semaya migrate eder, yani bu test
      // "o adim dokunmadi" degil "BUGUNE KADAR dokunulmadi" olcuyordu.
      // v5->v6 BILEREK dokunuyor, IS-EMRI-o85-A da (proje_id). Yerine AYNI
      // GUCTE bir iddia yazilir: gorevler tablosu YALNIZ UC nullable sutun
      // kazanir -- CHECK kisitlari, varsayilanlar, sutun sirasi ve PK AYNEN
      // durur. Tabloyu yeniden yaratip CHECK'i degistiren bir mutant burada
      // HALA olur.
      const ucYeniSutun =
          ', "oncelik" INTEGER NULL, "son_tarih" TEXT NULL, "proje_id" TEXT NULL';
      const pkCipasi = ', PRIMARY KEY(id))';

      expect(v3Sql, isNotNull);
      expect(
        v3Sql,
        isNot(contains('oncelik')),
        reason: 'pozitif kontrol: v3te YOK',
      );
      expect(
        v3Sql,
        contains(pkCipasi),
        reason: 'cipa yoksa asagidaki iddia BOSALIR',
      );
      expect(
        guncelSql,
        v3Sql!.replaceFirst(pkCipasi, ucYeniSutun + pkCipasi),
        reason:
            'v3ten bugune gorevler tablosu YALNIZ uc nullable sutun kazanmali; '
            'CHECK/varsayilan/sutun sirasi/PK DEGISMEMELI',
      );
    },
  );

  test(
    'D1: UzakAlanDurumu PK (entityType, entityId, alan) -- ikinci yazim UPSERT, kopya satir dogmaz',
    () async {
      final db = dosyaDbAc('m5');
      await db
          .into(db.uzakAlanDurumu)
          .insertOnConflictUpdate(
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
      await db
          .into(db.uzakAlanDurumu)
          .insertOnConflictUpdate(
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
    },
  );

  test(
    'SS2 G31/c: v4->v5 migration hatasiz -- cakisma_kayitlari tablosu var',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(4);
      final yeniDb = Veritabani(schema.newConnection());

      final sql = await _createTableSql(yeniDb, 'cakisma_kayitlari');
      expect(
        sql,
        isNotNull,
        reason: 'migration sonrasi cakisma_kayitlari tablosu var olmali',
      );
      await yeniDb.close();
    },
  );

  test(
    'SS2 G31/c: v4teki uc Gorevler satiri migration sonrasi ucu de aynen durur',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(4);
      final eskiDb = v4.DatabaseAtV4(schema.newConnection());
      for (final id in ['ss2-v4-1', 'ss2-v4-2', 'ss2-v4-3']) {
        await eskiDb.customStatement(
          "INSERT INTO gorevler (id, baslik, tamamlandi, olusturuldu, guncellendi, senkron_durumu, silindi) "
          "VALUES (?, ?, 0, ?, ?, 'yerel', 0)",
          [
            id,
            'Gorev $id',
            DateTime.utc(2026, 1, 1).toIso8601String(),
            DateTime.utc(2026, 1, 1).toIso8601String(),
          ],
        );
      }
      await eskiDb.close();

      final yeniDb = Veritabani(schema.newConnection());
      final satirlar = await yeniDb.select(yeniDb.gorevler).get();
      expect(satirlar.map((s) => s.id).toSet(), {
        'ss2-v4-1',
        'ss2-v4-2',
        'ss2-v4-3',
      });
      await yeniDb.close();
    },
  );

  test(
    'SS2 G31/c + ODEV §4(a): v4 -> GUNCEL -- gorevler YALNIZ uc nullable sutun kazanir',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());

      final v4Schema = await verifier.schemaAt(4);
      final v4Db = v4.DatabaseAtV4(v4Schema.newConnection());
      final v4Sql = await _createTableSql(v4Db, 'gorevler');
      await v4Db.close();

      final guncelSchema = await verifier.schemaAt(4);
      final guncelDb = Veritabani(
        guncelSchema.newConnection(),
      ); // migration'i tetikler
      final guncelSql = await _createTableSql(guncelDb, 'gorevler');
      await guncelDb.close();

      // 🔴 ODEV.md §4(a): bu testin ESKI iddiasi ("bayt bayt AYNI") ARTIK
      // YANLIStir -- ve testin ne olctugu bastan beri yanlis adlandirilmisti:
      // `Veritabani(...)` DAIMA EN GUNCEL semaya migrate eder, yani bu test
      // "o adim dokunmadi" degil "BUGUNE KADAR dokunulmadi" olcuyordu.
      // v5->v6 BILEREK dokunuyor, IS-EMRI-o85-A da (proje_id). Yerine AYNI
      // GUCTE bir iddia yazilir: gorevler tablosu YALNIZ UC nullable sutun
      // kazanir -- CHECK kisitlari, varsayilanlar, sutun sirasi ve PK AYNEN
      // durur. Tabloyu yeniden yaratip CHECK'i degistiren bir mutant burada
      // HALA olur.
      const ucYeniSutun =
          ', "oncelik" INTEGER NULL, "son_tarih" TEXT NULL, "proje_id" TEXT NULL';
      const pkCipasi = ', PRIMARY KEY(id))';

      expect(v4Sql, isNotNull);
      expect(
        v4Sql,
        isNot(contains('oncelik')),
        reason: 'pozitif kontrol: v4te YOK',
      );
      expect(
        v4Sql,
        contains(pkCipasi),
        reason: 'cipa yoksa asagidaki iddia BOSALIR',
      );
      expect(
        guncelSql,
        v4Sql!.replaceFirst(pkCipasi, ucYeniSutun + pkCipasi),
        reason:
            'D-SS2-1 + ODEV §4(a): v4ten bugune YALNIZ uc nullable sutun; '
            'CHECK/varsayilan/sutun sirasi/PK DEGISMEMELI',
      );
    },
  );

  // IS-EMRI-o85-A A4/A3 -- liste dilimi, v7->v8. v5->v6'nin BIREBIR deseni:
  // YENI tablo (`projeler`) + `Gorevler`e TEK NULLABLE sutun AYNI adimda.
  // POZITIF KONTROL: yukaridaki test bir sey OLCUYOR mu? v7'de tablo YOKSA
  // olcuyor; VARSA yukaridaki test bos bir iddiadir.
  test(
    'liste dilimi: v7 semasinda projeler HENUZ YOK (pozitif kontrol)',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(7);
      final v7Db = v7.DatabaseAtV7(schema.newConnection());
      final v7Sql = await _createTableSql(v7Db, 'projeler');
      await v7Db.close();
      expect(v7Sql, isNull);
    },
  );

  test(
    'liste dilimi: v7->v8 migration hatasiz -- projeler tablosu VAR',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(7);
      final yeniDb = Veritabani(schema.newConnection()); // migration'i tetikler

      final sql = await _createTableSql(yeniDb, 'projeler');
      expect(sql, isNotNull, reason: 'v8de projeler tablosu olmali');
      expect(sql, contains('ad'));
      expect(sql, contains('silindi'));
      expect(
        sql,
        isNot(contains('pos')),
        reason: 'K3: order/listPos kanali bu dilimde acilmaz',
      );
      expect(
        sql,
        isNot(contains('renk')),
        reason: 'ekrani yok -- olu sutun yazilmaz',
      );
      await yeniDb.close();
    },
  );

  test(
    'liste dilimi: v7->v8 -- gorevler YALNIZ proje_id sutunu kazanir',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());

      final v7Schema = await verifier.schemaAt(7);
      final v7Db = v7.DatabaseAtV7(v7Schema.newConnection());
      final v7Sql = await _createTableSql(v7Db, 'gorevler');
      await v7Db.close();

      final guncelSchema = await verifier.schemaAt(7);
      final guncelDb = Veritabani(
        guncelSchema.newConnection(),
      ); // migration'i tetikler
      final guncelSql = await _createTableSql(guncelDb, 'gorevler');
      await guncelDb.close();

      // AYNI GUCTE iddia (v3->GUNCEL/v4->GUNCEL desenlerinin aynisi): gorevler
      // tablosu YALNIZ bir nullable sutun kazanir -- CHECK kisitlari,
      // varsayilanlar, sutun sirasi ve PK AYNEN durur.
      const yeniSutun = ', "proje_id" TEXT NULL';
      const pkCipasi = ', PRIMARY KEY(id))';

      expect(v7Sql, isNotNull);
      expect(
        v7Sql,
        isNot(contains('proje_id')),
        reason: 'pozitif kontrol: v7de YOK',
      );
      expect(
        v7Sql,
        contains(pkCipasi),
        reason: 'cipa yoksa asagidaki iddia BOSALIR',
      );
      expect(
        guncelSql,
        v7Sql!.replaceFirst(pkCipasi, yeniSutun + pkCipasi),
        reason:
            'v7den bugune gorevler tablosu YALNIZ proje_id sutunu kazanmali; '
            'CHECK/varsayilan/sutun sirasi/PK DEGISMEMELI',
      );
    },
  );

  test(
    'liste dilimi: v7teki gorevler satirlari migration sonrasi korunur, proje_id NULL',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(7);
      final eskiDb = v7.DatabaseAtV7(schema.newConnection());
      for (final id in ['v8-1', 'v8-2', 'v8-3']) {
        await eskiDb.customStatement(
          "INSERT INTO gorevler (id, baslik, tamamlandi, olusturuldu, guncellendi, senkron_durumu, silindi) "
          "VALUES (?, ?, 0, ?, ?, 'yerel', 0)",
          [
            id,
            'Gorev $id',
            DateTime.utc(2026, 1, 1).toIso8601String(),
            DateTime.utc(2026, 1, 1).toIso8601String(),
          ],
        );
      }
      await eskiDb.close();

      final yeniDb = Veritabani(schema.newConnection());
      final satirlar = await yeniDb.select(yeniDb.gorevler).get();
      expect(satirlar.map((s) => s.id).toSet(), {'v8-1', 'v8-2', 'v8-3'});
      expect(
        satirlar.every((s) => s.projeId == null),
        isTrue,
        reason:
            'ALTER TABLE ADD COLUMN mevcut satirlara NULL yazmali (K4: NULL = Gelen Kutusu)',
      );
      await yeniDb.close();
    },
  );

  // v1'den gelen kullanici: `gorevler` v1->v2'de YENIDEN YARATILIR, sonra
  // v7->v8 hem yeni tabloyu ekler hem `Gorevler`e sutun ekler. Zincirin
  // TAMAMI kosulur (o74'te v1 yolu bir kez COKMUSTU -- kagit denetimi bunu
  // KACIRMISTI; ayni desen etiket diliminde de tekrarlanmisti).
  test(
    'liste dilimi: v1->v8 zinciri hatasiz -- projeler VAR, v1 satiri KORUNDU',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(1);
      final eskiDb = v1.DatabaseAtV1(schema.newConnection());
      await eskiDb.customStatement(
        "INSERT INTO gorevler (id, baslik, tamamlandi, olusturuldu, guncellendi, senkron_durumu, silindi) "
        "VALUES ('v1-liste', 'Eski gorev', 0, ?, ?, 'yerel', 0)",
        [
          DateTime.utc(2026, 1, 1).toIso8601String(),
          DateTime.utc(2026, 1, 1).toIso8601String(),
        ],
      );
      await eskiDb.close();

      final yeniDb = Veritabani(schema.newConnection());
      final sql = await _createTableSql(yeniDb, 'projeler');
      final satirlar = await yeniDb.select(yeniDb.gorevler).get();
      await yeniDb.close();

      expect(
        sql,
        isNotNull,
        reason: 'v1 yolundan gelen kullanicida da tablo yaratilmali',
      );
      expect(satirlar.map((s) => s.id).toSet(), {'v1-liste'});
      expect(satirlar.single.projeId, isNull);
    },
  );

  test(
    'D1: ayarlar.imlecSahibi sutunu var -- eski (migration\'dan gelen) satirda null',
    () async {
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
      expect(
        ayarSatiri.imlecSahibi,
        isNull,
        reason: 'migrationdan gelen eski satir sahipsiz (null) olmali',
      );
      await yeniDb.close();
    },
  );
}

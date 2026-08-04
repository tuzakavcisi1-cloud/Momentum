@TestOn('vm')
library;

// GOREV-SS2 G32 -- TESPIT KAPISI (Dart, gercek dosya DB; ag YOK). Alti ayak
// (a-e, e2, g, h) `select(cakismaKayitlari).get()` ile SAYI ve DEGER olarak
// olculur. `f` (INSERT dali) MUTANTSIZ ve BEYANLIDIR (bkz. spec SS2 SS6b).

import 'dart:io';

import 'package:client/senkron/alan_anahtari.dart';
import 'package:client/senkron/uzak_degisiklik_uygulayici.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/veritabani.dart';
import 'package:client/veri/wire_op.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory gecici;

  setUp(() {
    gecici = Directory.systemTemp.createTempSync('g32-cakisma-tespiti');
  });

  tearDown(() {
    try {
      gecici.deleteSync(recursive: true);
    } catch (_) {}
  });

  Veritabani dosyaDbAc() => Veritabani(NativeDatabase(File('${gecici.path}/m.sqlite')));

  Future<void> gorevYaz(Veritabani db, String id, {String baslik = 'Eski baslik', bool tamamlandi = false}) async {
    await db
        .into(db.gorevler)
        .insert(
          GorevlerCompanion.insert(
            id: id,
            baslik: baslik,
            tamamlandi: Value(tamamlandi),
            olusturuldu: DateTime.utc(2025, 1, 1),
            guncellendi: DateTime.utc(2025, 1, 1),
            senkronDurumu: const Value('senkronize'),
          ),
        );
  }

  Map<String, Object?> baslikDegisikligi({
    required String entityId,
    required String opId,
    required String clientId,
    required int wallMs,
    int counter = 0,
    required String title,
  }) {
    final hlc = Hlc(wallMs: wallMs, counter: counter, clientId: clientId);
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

  Map<String, Object?> tamamlanmaDegisikligi({
    required String entityId,
    required String opId,
    required String clientId,
    required int wallMs,
    int counter = 0,
    required bool tamamlandi,
  }) {
    final hlc = Hlc(wallMs: wallMs, counter: counter, clientId: clientId);
    final op = WireOp(
      operationId: opId,
      clientId: clientId,
      entityId: entityId,
      actorId: 'actor-1',
      entityType: 'Task',
      opHlc: hlc,
      groups: {
        'completion': WireGroupWrite(
          fields: {'status': tamamlandi ? 'done' : 'open', 'completedAt': null},
          hlc: hlc,
        ),
      },
    );
    return {'cursor': {'xid': 1, 'seq': 0}, 'payload': op.toJson()};
  }

  test('G32/a: dort sart saglanir -- 1 kayit, kaybeden=eski yerel, kazanan=uzak, kazananClientHex=uzagin client\'i', () async {
    final db = dosyaDbAc();
    await gorevYaz(db, 'e1', baslik: 'Eski Baslik');
    final uygulayici = UzakDegisiklikUygulayici(
      db,
      clientId: 'client-yerel',
      bekleyenYerelYazimVarMi: (entityId, alan) async => true,
    );

    await uygulayici.changesUygula([
      baslikDegisikligi(entityId: 'e1', opId: 'op1', clientId: 'client-uzak', wallMs: 1000, title: 'Yeni Uzak Baslik'),
    ]);

    final kayitlar = await db.select(db.cakismaKayitlari).get();
    expect(kayitlar, hasLength(1));
    expect(kayitlar.single.entityId, 'e1');
    expect(kayitlar.single.alan, 'fields:title');
    expect(kayitlar.single.kaybedenDeger, 'Eski Baslik');
    expect(kayitlar.single.kazananDeger, 'Yeni Uzak Baslik');
    expect(kayitlar.single.kazananClientHex, normHex('client-uzak'));
    await db.close();
  });

  test('G32/b: sart 2 -- kuyrukta bekleyen yerel yazim YOK -- 0 kayit', () async {
    final db = dosyaDbAc();
    await gorevYaz(db, 'e1', baslik: 'Eski Baslik');
    final uygulayici = UzakDegisiklikUygulayici(
      db,
      clientId: 'client-yerel',
      bekleyenYerelYazimVarMi: (entityId, alan) async => false,
    );

    await uygulayici.changesUygula([
      baslikDegisikligi(entityId: 'e1', opId: 'op1', clientId: 'client-uzak', wallMs: 1000, title: 'Yeni Uzak Baslik'),
    ]);

    expect(await db.select(db.cakismaKayitlari).get(), isEmpty);
    await db.close();
  });

  test('G32/c: sart 3 -- kazanan BIZIZ (echo) -- 0 kayit', () async {
    final db = dosyaDbAc();
    await gorevYaz(db, 'e1', baslik: 'Eski Baslik');
    final uygulayici = UzakDegisiklikUygulayici(
      db,
      clientId: 'client-yerel',
      bekleyenYerelYazimVarMi: (entityId, alan) async => true,
    );

    await uygulayici.changesUygula([
      baslikDegisikligi(entityId: 'e1', opId: 'op1', clientId: 'client-yerel', wallMs: 1000, title: 'Yeni Uzak Baslik'),
    ]);

    expect(await db.select(db.cakismaKayitlari).get(), isEmpty);
    await db.close();
  });

  test('G32/d: sart 4 -- kanonikDize degerleri AYNI -- 0 kayit', () async {
    final db = dosyaDbAc();
    await gorevYaz(db, 'e1', baslik: 'Ayni Baslik');
    final uygulayici = UzakDegisiklikUygulayici(
      db,
      clientId: 'client-yerel',
      bekleyenYerelYazimVarMi: (entityId, alan) async => true,
    );

    await uygulayici.changesUygula([
      baslikDegisikligi(entityId: 'e1', opId: 'op1', clientId: 'client-uzak', wallMs: 1000, title: 'Ayni Baslik'),
    ]);

    expect(await db.select(db.cakismaKayitlari).get(), isEmpty);
    await db.close();
  });

  test('G32/e: bayatlama -- kayit varken cakismasiz uzak yazim gelir -- 1 kayit KALIR, kazanan GUNCELLENIR, kaybeden DEGISMEZ', () async {
    final db = dosyaDbAc();
    await gorevYaz(db, 'e1', baslik: 'Eski Baslik');
    final uygulayici = UzakDegisiklikUygulayici(
      db,
      clientId: 'client-yerel',
      bekleyenYerelYazimVarMi: (entityId, alan) async => true,
    );
    await uygulayici.changesUygula([
      baslikDegisikligi(entityId: 'e1', opId: 'op1', clientId: 'client-uzak-1', wallMs: 1000, title: 'Birinci Uzak Baslik'),
    ]);

    // Ikinci tur: sart 2 bu kez YOK (bekleyenYerelYazimVarMi false) -- /e
    // sart 2/4 aramaksizin calismali.
    final uygulayici2 = UzakDegisiklikUygulayici(
      db,
      clientId: 'client-yerel',
      bekleyenYerelYazimVarMi: (entityId, alan) async => false,
    );
    await uygulayici2.changesUygula([
      baslikDegisikligi(entityId: 'e1', opId: 'op2', clientId: 'client-uzak-2', wallMs: 2000, title: 'Ikinci Uzak Baslik'),
    ]);

    final kayitlar = await db.select(db.cakismaKayitlari).get();
    expect(kayitlar, hasLength(1));
    expect(kayitlar.single.kaybedenDeger, 'Eski Baslik', reason: 'kaybeden DEGISMEMELI');
    expect(kayitlar.single.kazananDeger, 'Ikinci Uzak Baslik', reason: 'kazanan GUNCELLENMELI');
    expect(kayitlar.single.kazananClientHex, normHex('client-uzak-2'));
    await db.close();
  });

  test('G32/e2: bayatlamada sart 3 -- kayit varken KENDI ECHO\'muz gelir -- kazanan/kaybeden DEGISMEZ, kayit sayisi 1 kalir', () async {
    final db = dosyaDbAc();
    await gorevYaz(db, 'e1', baslik: 'Eski Baslik');
    final uygulayici = UzakDegisiklikUygulayici(
      db,
      clientId: 'client-yerel',
      bekleyenYerelYazimVarMi: (entityId, alan) async => true,
    );
    await uygulayici.changesUygula([
      baslikDegisikligi(entityId: 'e1', opId: 'op1', clientId: 'client-uzak-1', wallMs: 1000, title: 'Birinci Uzak Baslik'),
    ]);
    final oncesi = await db.select(db.cakismaKayitlari).getSingle();

    // Ikinci tur: KENDI echo'muz (per-alan hlc.clientId == cihazin clientId'si).
    final uygulayici2 = UzakDegisiklikUygulayici(
      db,
      clientId: 'client-yerel',
      bekleyenYerelYazimVarMi: (entityId, alan) async => true,
    );
    await uygulayici2.changesUygula([
      baslikDegisikligi(entityId: 'e1', opId: 'op2', clientId: 'client-yerel', wallMs: 2000, title: 'Kendi Echomuz'),
    ]);

    final kayitlar = await db.select(db.cakismaKayitlari).get();
    expect(kayitlar, hasLength(1));
    expect(kayitlar.single.kazananDeger, oncesi.kazananDeger, reason: 'kazanan DEGISMEMELI (echo)');
    expect(kayitlar.single.kaybedenDeger, oncesi.kaybedenDeger, reason: 'kaybeden DEGISMEMELI');
    expect(kayitlar.single.kazananClientHex, oncesi.kazananClientHex);
    await db.close();
  });

  test('G32/g: saat dikisi -- olusturuldu enjekte saatin sabit degerine BIREBIR esittir', () async {
    final db = dosyaDbAc();
    await gorevYaz(db, 'e1', baslik: 'Eski Baslik');
    final sabitSaat = DateTime.utc(2026, 1, 1, 12, 0, 0);
    final uygulayici = UzakDegisiklikUygulayici(
      db,
      clientId: 'client-yerel',
      bekleyenYerelYazimVarMi: (entityId, alan) async => true,
      saat: () => sabitSaat,
    );

    await uygulayici.changesUygula([
      baslikDegisikligi(entityId: 'e1', opId: 'op1', clientId: 'client-uzak', wallMs: 1000, title: 'Yeni Uzak Baslik'),
    ]);

    final kayit = await db.select(db.cakismaKayitlari).getSingle();
    expect(kayit.olusturuldu.toIso8601String(), sabitSaat.toIso8601String());
    await db.close();
  });

  test('G32/h: kanonik temsil -- groups:completion kaybeden/kazanan ikisi de kanonik alanda (tamamlandi/acik), HAM TEL DEGERI DEGIL', () async {
    final db = dosyaDbAc();
    await gorevYaz(db, 'e1', tamamlandi: false); // 'acik'
    final uygulayici = UzakDegisiklikUygulayici(
      db,
      clientId: 'client-yerel',
      bekleyenYerelYazimVarMi: (entityId, alan) async => true,
    );

    await uygulayici.changesUygula([
      tamamlanmaDegisikligi(entityId: 'e1', opId: 'op1', clientId: 'client-uzak', wallMs: 1000, tamamlandi: true), // 'done' telden gelir
    ]);

    final kayit = await db.select(db.cakismaKayitlari).getSingle();
    expect(kayit.alan, 'groups:completion');
    expect(kayit.kaybedenDeger, 'acik');
    expect(kayit.kazananDeger, 'tamamlandi');
    expect(['tamamlandi', 'acik'].contains(kayit.kaybedenDeger), isTrue);
    expect(['tamamlandi', 'acik'].contains(kayit.kazananDeger), isTrue);
    await db.close();
  });
}

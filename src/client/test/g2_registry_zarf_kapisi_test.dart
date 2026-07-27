@TestOn('vm')
library;

// GOREV-slice-3c G2 -- REGISTRY UYUM + ZARF KAPISI. dart:io ile KANIT'a
// ham WireOp JSON'u yazar (ag YOK, tamamen yerel).

import 'dart:convert';
import 'dart:io';

import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/veritabani.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Veritabani db;
  late DriftGorevDeposu depo;
  late String devUserId;
  late String clientId;

  setUp(() async {
    db = Veritabani(NativeDatabase.memory());
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    devUserId = ayarlar.devUserId;
    clientId = ayarlar.clientId;
    final hlc = HlcUretici(
      simdiMs: () => DateTime.utc(2026, 7, 27, 12).millisecondsSinceEpoch,
      clientId: clientId,
    );
    // M7 (.toUtc() dusurulmesi) YEREL (UTC OLMAYAN) bir saat olmadan
    // GOZLENEMEZ -- makine yereli UTC ise .toUtc() zaten no-op olur. Bu
    // makinede (SS1.3 kirmizi uyari: "Turkiye'de 3 saat kayma") yerel !=
    // UTC oldugu icin DateTime.now() ile GERCEK yerel-UTC farkini kullanir.
    final sabitYerelSaat = DateTime.now();
    depo = DriftGorevDeposu(
      db,
      saat: () => sabitYerelSaat,
      idUret: uretimIdUret,
      hlc: hlc,
      ayarlarDeposu: ayarlarDeposu,
      actorId: devUserId,
    );
  });

  tearDown(() async => db.close());

  Future<List<Map<String, Object?>>> dortOpUret() async {
    await depo.ekle('Sut al');
    final id = (await db.select(db.gorevler).get()).single.id;
    await depo.duzenle(id, 'Sut ve ekmek al');
    await depo.tamamlaGeriAl(id, tamamlandi: true);
    await depo.sil(id);

    final kuyruk = await (db.select(
      db.senkronKuyrugu,
    )..orderBy([(t) => OrderingTerm(expression: t.hlcCounter)])).get();
    expect(kuyruk, hasLength(4));

    final isimler = ['01-ekle', '02-duzenle', '03-tamamlaGeriAl', '04-sil'];
    final dizin = Directory('../../KANIT/slice-3c/02-G2');
    if (!dizin.existsSync()) dizin.createSync(recursive: true);

    final opler = <Map<String, Object?>>[];
    for (var i = 0; i < 4; i++) {
      File(
        '${dizin.path}/${isimler[i]}.json',
      ).writeAsStringSync(kuyruk[i].govdeJson);
      opler.add(jsonDecode(kuyruk[i].govdeJson) as Map<String, Object?>);
    }
    return opler;
  }

  test('D2: entityType tam "Task"', () async {
    final opler = await dortOpUret();
    for (final op in opler) {
      expect(op['entityType'], 'Task');
    }
  });

  test('D2: fields anahtarlari title/isDeleted, groups yalniz completion', () async {
    final opler = await dortOpUret();
    for (final op in opler) {
      final fields = (op['fields'] as Map?)?.keys ?? const <String>[];
      for (final k in fields) {
        expect(['title', 'isDeleted'], contains(k));
      }
      final groups = (op['groups'] as Map?)?.keys ?? const <String>[];
      for (final k in groups) {
        expect(k, 'completion');
      }
    }
  });

  test('D2: olusturuldu/guncellendi/senkronDurumu hicbir kanalda gecmez', () async {
    final opler = await dortOpUret();
    final yasakli = ['olusturuldu', 'guncellendi', 'senkronDurumu'];
    for (final op in opler) {
      final fields = (op['fields'] as Map?)?.keys ?? const <String>[];
      final groups = (op['groups'] as Map?)?.keys ?? const <String>[];
      for (final y in yasakli) {
        expect(fields, isNot(contains(y)));
        expect(groups, isNot(contains(y)));
      }
    }
  });

  test('D2: silindi==true => fields.isDeleted.value == "true" (tam dize)', () async {
    final opler = await dortOpUret();
    final silOp = opler[3]; // 04-sil
    final isDeleted = (silOp['fields'] as Map)['isDeleted'] as Map;
    expect(isDeleted['value'], 'true');
  });

  test('D2: completion fields hem status hem completedAt tasir', () async {
    final opler = await dortOpUret();
    final tamamlaOp = opler[2]; // 03-tamamlaGeriAl
    final completion = (tamamlaOp['groups'] as Map)['completion'] as Map;
    final fields = completion['fields'] as Map;
    expect(fields.containsKey('status'), isTrue);
    expect(fields.containsKey('completedAt'), isTrue);
  });

  test('D2: status degeri done/open tam dize', () async {
    final opler = await dortOpUret();
    final tamamlaOp = opler[2];
    final completion = (tamamlaOp['groups'] as Map)['completion'] as Map;
    final status = (completion['fields'] as Map)['status'];
    expect(['done', 'open'], contains(status));
  });

  test('D2: completedAt "...Z" ile biter ve DateTime.parse ile geri okunur', () async {
    final opler = await dortOpUret();
    final tamamlaOp = opler[2];
    final completion = (tamamlaOp['groups'] as Map)['completion'] as Map;
    final completedAt = (completion['fields'] as Map)['completedAt'] as String;
    expect(completedAt.endsWith('Z'), isTrue);
    expect(() => DateTime.parse(completedAt), returnsNormally);
  });

  test('D2: bos op uretilemez -- her opun en az bir kanali var', () async {
    final opler = await dortOpUret();
    for (final op in opler) {
      final fieldsBos = (op['fields'] as Map?)?.isEmpty ?? true;
      final groupsBos = (op['groups'] as Map?)?.isEmpty ?? true;
      expect(fieldsBos && groupsBos, isFalse);
    }
  });

  final guidDeseni = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );

  test('D7: dort zarf alani bos-olmayan gecerli GUID', () async {
    final opler = await dortOpUret();
    const bosGuid = '00000000-0000-0000-0000-000000000000';
    for (final op in opler) {
      for (final alan in ['operationId', 'clientId', 'entityId', 'actorId']) {
        final deger = op[alan] as String;
        expect(deger, isNotEmpty);
        expect(guidDeseni.hasMatch(deger), isTrue, reason: '$alan="$deger" GUID degil');
        expect(deger, isNot(bosGuid), reason: '$alan bos GUID (Guid.Empty) olamaz');
      }
    }
  });

  test('D7: actorId dev kullanici GUIDine esit ve clientIdden farkli', () async {
    final opler = await dortOpUret();
    for (final op in opler) {
      expect(op['actorId'], devUserId);
      expect(op['actorId'], isNot(equals(op['clientId'])));
    }
  });

  test('D7: HLC iskeleti -- opHlc + her fields/groups.hlc mevcut ve AYNI damga', () async {
    final opler = await dortOpUret();
    for (final op in opler) {
      final opHlc = op['opHlc'] as Map;
      expect(opHlc['wallMs'], isNotNull);
      expect(opHlc['counter'], isNotNull);
      expect(opHlc['clientId'], isNotNull);

      final fields = (op['fields'] as Map?) ?? const {};
      for (final v in fields.values) {
        expect((v as Map)['hlc'], opHlc);
      }
      final groups = (op['groups'] as Map?) ?? const {};
      for (final v in groups.values) {
        expect((v as Map)['hlc'], opHlc);
      }
    }
  });
}

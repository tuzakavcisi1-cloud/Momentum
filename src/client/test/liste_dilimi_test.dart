@TestOn('vm')
library;

// IS-EMRI-o85-A DILIM 2 "Liste" -- kapi testleri.
//
// Kapsam: B1 (liste yarat/yeniden adlandir/sil -- Task yazimlarinin
// BIREBIR AYNI deseni) * B2/B3 (gorev<->liste bagi, Gelen Kutusu'na tasima
// `Yazim(null)` ile GERCEK bir tel yazimidir) * C1/C2 (entityType dali --
// Project changesUygula/snapshotUygula'da AYRI havuza gider, Task
// DEGISMEDEN kalir) * C3 (projectId/name/isDeleted icin cakisma tespiti
// KAPSAM DISI -- kanonikDize cagrilmaz, cakismaKayitlari'na YAZILMAZ).
//
// `NativeDatabase.memory()` YASAGI (G2/G3 gerekcesi) BURADA GECERSIZDIR --
// bu dosya "kapat/yeniden ac" ayagi OLCMEZ, olctugu sey senkron mantigidir.
// Migration ayagi g2_migration_kapisi_test.dart'ta gercek DOSYA DB ile kosar.

import 'package:client/senkron/uzak_degisiklik_uygulayici.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/veritabani.dart';
import 'package:client/veri/wire_op.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sayaca bagli, DETERMINISTIK id uretici -- etiket_dilimi_test.dart'in
/// AYNI deseni (rastgele GUID iddiayi olcemez hale getirirdi).
class _SayacId {
  int _n = 0;
  String cagir() => 'id-${++_n}';
}

Veritabani _bellekDb() => Veritabani(NativeDatabase.memory());

Future<DriftGorevDeposu> _depoKur(Veritabani db, _SayacId id) async {
  const sabitSaat = 1786752000000; // 2026-08-14T12:00:00Z
  final ayarlarDeposu = AyarlarDeposu(db, idUret: id.cagir);
  final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
  return DriftGorevDeposu(
    db,
    saat: () => DateTime.fromMillisecondsSinceEpoch(sabitSaat, isUtc: true),
    idUret: id.cagir,
    hlc: HlcUretici(simdiMs: () => sabitSaat, clientId: ayarlar.clientId),
    ayarlarDeposu: ayarlarDeposu,
    actorId: ayarlar.devUserId,
  );
}

Future<List<SenkronKuyruguRow>> _kuyrukSatirlari(Veritabani db) => (db.select(
  db.senkronKuyrugu,
)..orderBy([(t) => OrderingTerm(expression: t.olusturuldu)])).get();

Map<String, Object?> _hlcJson({
  int wall = 1000,
  int counter = 0,
  String clientId = 'uzak',
}) => {'wallMs': wall, 'counter': counter, 'clientId': clientId};

/// `WireOp.toJson()` uzerinden gercek tel bicimini uretir -- g32/g5'in AYNI
/// deseni (elle JSON yazmak, sunucu sozlesmesinden SESSIZCE ayrisabilirdi).
Map<String, Object?> _degisiklik({
  required String entityType,
  required String entityId,
  required String alan,
  required String? deger,
  String opId = 'op-uzak',
  String clientId = 'uzak',
  int wallMs = 2000,
}) {
  final hlc = Hlc(wallMs: wallMs, counter: 0, clientId: clientId);
  final op = WireOp(
    operationId: opId,
    clientId: clientId,
    entityId: entityId,
    actorId: 'actor-uzak',
    entityType: entityType,
    opHlc: hlc,
    fields: {alan: WireFieldWrite(value: deger, hlc: hlc)},
  );
  return {
    'cursor': {'xid': 1, 'seq': 0},
    'payload': op.toJson(),
  };
}

Map<String, Object?> _snapshotProje({
  required String entityId,
  required String ad,
  String winOpId = 'op-s',
}) => {
  'entityType': 'Project',
  'entityId': entityId,
  'scalars': [
    {
      'field': 'name',
      'value': ad,
      'hlc': _hlcJson(wall: 2000),
      'winOperationId': winOpId,
    },
  ],
  'groups': const [],
};

void main() {
  group(
    'B1 -- liste yarat/yeniden adlandir/sil (Task yazimlarinin AYNI deseni)',
    () {
      late Veritabani db;
      late DriftGorevDeposu depo;

      setUp(() async {
        db = _bellekDb();
        depo = await _depoKur(db, _SayacId());
      });

      tearDown(() async => db.close());

      test(
        'listeEkle: Projeler satiri + TEK WireOp (entityType Project, fields:name), pos/color YOK',
        () async {
          await depo.listeEkle('İş');

          final satirlar = await db.select(db.projeler).get();
          expect(satirlar, hasLength(1));
          expect(satirlar.single.ad, 'İş');
          expect(satirlar.single.silindi, isFalse);

          final kuyruk = await _kuyrukSatirlari(db);
          expect(kuyruk, hasLength(1));
          expect(kuyruk.single.entityType, 'Project');
          expect(kuyruk.single.govdeJson, contains('"name"'));
          expect(kuyruk.single.govdeJson, isNot(contains('"pos"')));
          expect(kuyruk.single.govdeJson, isNot(contains('"color"')));
        },
      );

      test(
        'listeDuzenle: satir + kuyruk fields:name ile guncellenir',
        () async {
          await depo.listeEkle('Eski Ad');
          final id = (await db.select(db.projeler).get()).single.id;

          await depo.listeDuzenle(id, 'Yeni Ad');

          final satir = await (db.select(
            db.projeler,
          )..where((t) => t.id.equals(id))).getSingle();
          expect(satir.ad, 'Yeni Ad');
          final kuyruk = await _kuyrukSatirlari(db);
          expect(kuyruk.last.govdeJson, contains('Yeni Ad'));
        },
      );

      test('listeSil: silindi=true + kuyruk fields:isDeleted=true', () async {
        await depo.listeEkle('Silinecek');
        final id = (await db.select(db.projeler).get()).single.id;

        await depo.listeSil(id);

        final satir = await (db.select(
          db.projeler,
        )..where((t) => t.id.equals(id))).getSingle();
        expect(satir.silindi, isTrue);
        final kuyruk = await _kuyrukSatirlari(db);
        expect(kuyruk.last.govdeJson, contains('"isDeleted"'));
        expect(kuyruk.last.govdeJson, contains('"true"'));
      });
    },
  );

  group('B2/B3 -- gorev<->liste bagi (Gelen Kutusu = null)', () {
    late Veritabani db;
    late DriftGorevDeposu depo;

    setUp(() async {
      db = _bellekDb();
      depo = await _depoKur(db, _SayacId());
    });

    tearDown(() async => db.close());

    test(
      'B3: ekle(projeId: verildi) -- AKTIF listede dogar, TEK WireOp fields:projectId tasir',
      () async {
        await depo.ekle('Görev', projeId: 'proje-1');

        final satir = (await db.select(db.gorevler).get()).single;
        expect(satir.projeId, 'proje-1');
        final kuyruk = await _kuyrukSatirlari(db);
        expect(
          kuyruk,
          hasLength(1),
          reason: 'TEK WireOp -- ayri bir ayrintilariGuncelle cagrisi YOK',
        );
        expect(kuyruk.single.govdeJson, contains('"projectId"'));
      },
    );

    test(
      'B3: ekle(projeId verilmedi) -- Gelen Kutusunda dogar, projectId tele HIC KONMAZ',
      () async {
        await depo.ekle('Görev');

        final satir = (await db.select(db.gorevler).get()).single;
        expect(satir.projeId, isNull);
        final kuyruk = await _kuyrukSatirlari(db);
        expect(kuyruk.single.govdeJson, isNot(contains('projectId')));
      },
    );

    test(
      'B2: ayrintilariGuncelle(projeId: Yazim(x)) -- gorevi listeye tasir',
      () async {
        await depo.ekle('Görev');
        final id = (await db.select(db.gorevler).get()).single.id;

        await depo.ayrintilariGuncelle(id, projeId: const Yazim('proje-2'));

        final satir = await (db.select(
          db.gorevler,
        )..where((t) => t.id.equals(id))).getSingle();
        expect(satir.projeId, 'proje-2');
      },
    );

    test(
      'B2 KILIT: ayrintilariGuncelle(projeId: Yazim(null)) -- Gelen Kutusuna tasir, GERCEK bir tel yazimidir (bos op DEGIL)',
      () async {
        await depo.ekle('Görev', projeId: 'proje-1');
        final id = (await db.select(db.gorevler).get()).single.id;

        await depo.ayrintilariGuncelle(id, projeId: const Yazim(null));

        final satir = await (db.select(
          db.gorevler,
        )..where((t) => t.id.equals(id))).getSingle();
        expect(satir.projeId, isNull);
        final kuyruk = await _kuyrukSatirlari(db);
        // ekle() + bu cagri = 2 satir; SONUNCUSU projectId:null tasimali.
        expect(kuyruk.last.govdeJson, contains('"projectId":{"value":null'));
      },
    );

    test(
      'ayrintilariGuncelle(projeId verilmedi) -- projeId HIC DOKUNULMAZ, mevcut deger korunur',
      () async {
        await depo.ekle('Görev', projeId: 'proje-1');
        final id = (await db.select(db.gorevler).get()).single.id;

        await depo.ayrintilariGuncelle(id, baslik: const Yazim('Yeni baslik'));

        final satir = await (db.select(
          db.gorevler,
        )..where((t) => t.id.equals(id))).getSingle();
        expect(
          satir.projeId,
          'proje-1',
          reason: 'projeId parametresi verilmedi -- Value.absent()',
        );
      },
    );
  });

  group('C1/C2 -- entityType dali (Project AYRI havuza, Task DEGISMEDEN)', () {
    late Veritabani db;
    late UzakDegisiklikUygulayici uygulayici;

    setUp(() async {
      db = _bellekDb();
      uygulayici = UzakDegisiklikUygulayici(db, clientId: 'client-yerel');
    });

    tearDown(() async => db.close());

    test(
      'C1: changesUygula -- Project fields:name YENI Projeler satiri dogurur (Task tablosuna DUSMEZ)',
      () async {
        await uygulayici.changesUygula([
          _degiskilikProje(entityId: 'p1', alan: 'name', deger: 'İş'),
        ]);

        final projeler = await db.select(db.projeler).get();
        expect(projeler, hasLength(1));
        expect(projeler.single.ad, 'İş');
        expect(
          await db.select(db.gorevler).get(),
          isEmpty,
          reason: 'Project Task tablosuna SIZMAMALI',
        );
      },
    );

    test(
      'C1: changesUygula -- Project fields:isDeleted mevcut satiri siler',
      () async {
        await db
            .into(db.projeler)
            .insert(
              ProjelerCompanion.insert(
                id: 'p1',
                ad: 'İş',
                olusturuldu: DateTime.utc(2026, 8, 1),
              ),
            );
        await uygulayici.changesUygula([
          _degiskilikProje(entityId: 'p1', alan: 'isDeleted', deger: 'true'),
        ]);

        final satir = await (db.select(
          db.projeler,
        )..where((t) => t.id.equals('p1'))).getSingle();
        expect(satir.silindi, isTrue);
      },
    );

    test(
      'C1/C3: changesUygula -- Task fields:projectId gorevler.projeId\'ye baglanir, cakisma tespiti KAPSAM DISI',
      () async {
        await db
            .into(db.gorevler)
            .insert(
              GorevlerCompanion.insert(
                id: 'g1',
                baslik: 'Görev',
                olusturuldu: DateTime.utc(2026, 8, 1),
                guncellendi: DateTime.utc(2026, 8, 1),
              ),
            );
        await uygulayici.changesUygula([
          _degisiklikTask(entityId: 'g1', alan: 'projectId', deger: 'proje-1'),
        ]);

        final satir = await (db.select(
          db.gorevler,
        )..where((t) => t.id.equals('g1'))).getSingle();
        expect(satir.projeId, 'proje-1');
        expect(
          await db.select(db.cakismaKayitlari).get(),
          isEmpty,
          reason: 'C3: projectId cakisma tespiti KAPSAM DISI',
        );
      },
    );

    test(
      'C1: changesUygula -- Task fields:projectId value:null gorevi Gelen Kutusuna dusurur',
      () async {
        await db
            .into(db.gorevler)
            .insert(
              GorevlerCompanion.insert(
                id: 'g1',
                baslik: 'Görev',
                olusturuldu: DateTime.utc(2026, 8, 1),
                guncellendi: DateTime.utc(2026, 8, 1),
                projeId: const Value('proje-1'),
              ),
            );
        await uygulayici.changesUygula([
          _degisiklikTask(entityId: 'g1', alan: 'projectId', deger: null),
        ]);

        final satir = await (db.select(
          db.gorevler,
        )..where((t) => t.id.equals('g1'))).getSingle();
        expect(satir.projeId, isNull);
      },
    );

    test(
      'C2 KRITIK: snapshotUygula -- Project entity TEMIZ KURULUMDA projeler tablosuna yazilir',
      () async {
        await uygulayici.snapshotUygula([
          _snapshotProje(entityId: 'p1', ad: 'İş'),
        ]);

        final projeler = await db.select(db.projeler).get();
        expect(
          projeler,
          hasLength(1),
          reason: 'dal acilmazsa liste TEMIZ KURULUMDA GORUNMEZ (C2)',
        );
        expect(projeler.single.ad, 'İş');
      },
    );
  });
}

Map<String, Object?> _degiskilikProje({
  required String entityId,
  required String alan,
  required String? deger,
}) => _degisiklik(
  entityType: 'Project',
  entityId: entityId,
  alan: alan,
  deger: deger,
);

Map<String, Object?> _degisiklikTask({
  required String entityId,
  required String alan,
  required String? deger,
}) => _degisiklik(
  entityType: 'Task',
  entityId: entityId,
  alan: alan,
  deger: deger,
);

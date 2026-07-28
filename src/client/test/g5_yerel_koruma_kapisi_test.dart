@TestOn('vm')
library;

// GOREV-slice-3d G5 -- YEREL KORUMA / ROZET / ECHO KAPISI (Dart, gercek
// dosya DB; ag YOK -- degisiklikler dogrudan olusturulur). Bu dosyanin ILK
// ONBIR satiri T5 kapsamindadir (D5/D6/D4); son DORT satir T7 kapsamindadir
// (D0/D7, itme turu + atomik sayfa -- SenkronDongusu gerektirir).

import 'dart:convert';
import 'dart:io';

import 'package:client/ag/senkron_agi.dart';
import 'package:client/senkron/kuyruk_tabani.dart';
import 'package:client/senkron/uzak_degisiklik_uygulayici.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/senkron_dongusu.dart';
import 'package:client/veri/veritabani.dart';
import 'package:client/veri/wire_op.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'destekler/sahte_senkron_agi.dart';

/// T7: `changesUygula`/`snapshotUygula` cagrildiginda `cagriSirasi`ya bir
/// giriş ekleyen gozlemci -- D7/1'in "veri ONCE, imlec SONRA" sirasini
/// dogrudan gozlemlemek icin (mevcut/kalici sinama araci degil).
class _GozlemciUygulayici extends UzakDegisiklikUygulayici {
  _GozlemciUygulayici(
    super.db, {
    required this.cagriSirasi,
    required super.kuyrukTabaniSaglayici,
  });
  final List<String> cagriSirasi;

  @override
  Future<void> changesUygula(List<Map<String, Object?>> changes) async {
    cagriSirasi.add('changesUygula');
    await super.changesUygula(changes);
  }

  @override
  Future<void> snapshotUygula(List<Map<String, Object?>> snapshot) async {
    cagriSirasi.add('snapshotUygula');
    await super.snapshotUygula(snapshot);
  }
}

/// T7: `changesUygula` cagrisinin ORTASINDA firlayan sahte uygulayici --
/// D7/1'in "bir sayfa ATOMIKTIR" kuralini (yarim sayfa senaryosu) olcer.
class _FirlatanUygulayici extends UzakDegisiklikUygulayici {
  _FirlatanUygulayici(super.db, {required super.kuyrukTabaniSaglayici});

  @override
  Future<void> changesUygula(List<Map<String, Object?>> changes) async {
    throw StateError('kasitli hata -- yarim sayfa senaryosu');
  }
}

/// T7: `nextCursorKalicilastir` cagrildiginda `cagriSirasi`ya giriş ekleyen
/// gozlemci `AyarlarDeposu`.
class _GozlemciAyarlarDeposu extends AyarlarDeposu {
  _GozlemciAyarlarDeposu(super.db, {required super.idUret, required this.cagriSirasi});
  final List<String> cagriSirasi;

  @override
  Future<void> nextCursorKalicilastir(String? json, {required String devUserId}) async {
    cagriSirasi.add('nextCursorKalicilastir');
    await super.nextCursorKalicilastir(json, devUserId: devUserId);
  }
}

void main() {
  late Directory gecici;

  setUp(() {
    gecici = Directory.systemTemp.createTempSync('g5-yerel-koruma-kapisi');
  });

  tearDown(() {
    try {
      gecici.deleteSync(recursive: true);
    } catch (_) {}
  });

  Veritabani dosyaDbAc() => Veritabani(NativeDatabase(File('${gecici.path}/m.sqlite')));

  Future<void> gorevYaz(Veritabani db, String id, {String baslik = 'Eski baslik', String senkronDurumu = 'senkronize'}) async {
    await db
        .into(db.gorevler)
        .insert(
          GorevlerCompanion.insert(
            id: id,
            baslik: baslik,
            olusturuldu: DateTime.utc(2025, 1, 1),
            guncellendi: DateTime.utc(2025, 1, 1),
            senkronDurumu: Value(senkronDurumu),
          ),
        );
  }

  Future<void> kuyrukSatiriEkle(
    Veritabani db, {
    required String opId,
    required String entityId,
    required String govdeJson,
    String durum = 'bekliyor',
    int hlcWallMs = 0,
    int hlcCounter = 0,
  }) async {
    await db
        .into(db.senkronKuyrugu)
        .insert(
          SenkronKuyruguCompanion.insert(
            opId: opId,
            clientId: 'client-yerel',
            entityType: 'Task',
            entityId: entityId,
            govdeJson: govdeJson,
            hlcWallMs: hlcWallMs,
            hlcCounter: hlcCounter,
            durum: Value(durum),
            olusturuldu: DateTime.now().toUtc(),
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

  UzakDegisiklikUygulayici uygulayiciOlustur(Veritabani db) =>
      UzakDegisiklikUygulayici(db, kuyrukTabaniSaglayici: (entityId, alan) => kuyrukEnBuyuk(db, entityId, alan));

  test('D5: kuyrukta bekliyor op (HLC buyuk), uzak yazim (HLC kucuk) gelir -- projeksiyon yerel degeri KORUR', () async {
    final db = dosyaDbAc();
    await gorevYaz(db, 'e1', baslik: 'Yerel bekleyen baslik');
    final yerelOp = WireOp(
      operationId: 'localop1',
      clientId: 'client-yerel',
      entityId: 'e1',
      actorId: 'actor-1',
      entityType: 'Task',
      opHlc: const Hlc(wallMs: 5000, counter: 0, clientId: 'client-yerel'),
      fields: {'title': const WireFieldWrite(value: 'Yerel bekleyen baslik', hlc: Hlc(wallMs: 5000, counter: 0, clientId: 'client-yerel'))},
    );
    await kuyrukSatiriEkle(db, opId: 'localop1', entityId: 'e1', govdeJson: jsonEncode(yerelOp.toJson()), hlcWallMs: 5000);

    final uygulayici = uygulayiciOlustur(db);
    await uygulayici.changesUygula([
      baslikDegisikligi(entityId: 'e1', opId: 'uzakop1', clientId: 'client-uzak', wallMs: 1000, title: 'Uzaktan gelen baslik'),
    ]);

    final gorev = await (db.select(db.gorevler)..where((t) => t.id.equals('e1'))).getSingle();
    expect(gorev.baslik, 'Yerel bekleyen baslik');
    await db.close();
  });

  test('D5: ayni senaryo, kuyruk satiri "gonderildi" -- projeksiyon YINE yerel degeri korur', () async {
    final db = dosyaDbAc();
    await gorevYaz(db, 'e1', baslik: 'Ucustaki baslik');
    final yerelOp = WireOp(
      operationId: 'localop1',
      clientId: 'client-yerel',
      entityId: 'e1',
      actorId: 'actor-1',
      entityType: 'Task',
      opHlc: const Hlc(wallMs: 5000, counter: 0, clientId: 'client-yerel'),
      fields: {'title': const WireFieldWrite(value: 'Ucustaki baslik', hlc: Hlc(wallMs: 5000, counter: 0, clientId: 'client-yerel'))},
    );
    await kuyrukSatiriEkle(db, opId: 'localop1', entityId: 'e1', govdeJson: jsonEncode(yerelOp.toJson()), hlcWallMs: 5000, durum: 'gonderildi');

    final uygulayici = uygulayiciOlustur(db);
    await uygulayici.changesUygula([
      baslikDegisikligi(entityId: 'e1', opId: 'uzakop1', clientId: 'client-uzak', wallMs: 1000, title: 'Uzaktan gelen baslik'),
    ]);

    final gorev = await (db.select(db.gorevler)..where((t) => t.id.equals('e1'))).getSingle();
    expect(gorev.baslik, 'Ucustaki baslik', reason: 'gonderildi DISARIDA BIRAKILAMAZ');
    await db.close();
  });

  test('D5: kuyrukta op YOK -- uzak deger UYGULANIR', () async {
    final db = dosyaDbAc();
    await gorevYaz(db, 'e1', baslik: 'Eski baslik');
    final uygulayici = uygulayiciOlustur(db);
    await uygulayici.changesUygula([
      baslikDegisikligi(entityId: 'e1', opId: 'uzakop1', clientId: 'client-uzak', wallMs: 1000, title: 'Uzaktan gelen baslik'),
    ]);
    final gorev = await (db.select(db.gorevler)..where((t) => t.id.equals('e1'))).getSingle();
    expect(gorev.baslik, 'Uzaktan gelen baslik');
    await db.close();
  });

  test('D5: baslik icinde SAHTE hlc/wallMs metni tasiyan bir yazim -- desen YANILMAZ, DOGRU HLC okunur', () async {
    // baslik degeri kacis-duyarli desenin gerekliligini kanitlayan bir
    // adversaryel metin tasir: '"hlc":{"wallMs":9999999999999,...' -- kacis-
    // duyarli olmayan bir desen ([^"]*) burada yanilir ve SAHTE HLC'yi okur.
    const kotuNiyetliBaslik = 'a"hlc":{"wallMs":9999999999999,"counter":0,"clientId":"sahte"}';
    final hlc = const Hlc(wallMs: 1234, counter: 7, clientId: 'client-gercek');
    final op = WireOp(
      operationId: 'op-kacis',
      clientId: 'client-gercek',
      entityId: 'e1',
      actorId: 'actor-1',
      entityType: 'Task',
      opHlc: hlc,
      fields: {'title': WireFieldWrite(value: kotuNiyetliBaslik, hlc: hlc)},
    );
    final govdeJson = jsonEncode(op.toJson());
    // cipa VAR (govdede birden fazla '"hlc":' gecebilir -- desen yine de
    // ILK/DOGRU eslesmeyi -- alan adinin HEMEN ARDINDAKI value/hlc cipini --
    // bulmali).
    final sonuc = hamAlanHlcCikar(govdeJson, 'fields:title');
    expect(sonuc, isNotNull);
    expect(sonuc!.wallMs, 1234, reason: 'SAHTE 9999999999999 degil, GERCEK 1234 okunmali');
    expect(sonuc.counter, 7);
    expect(sonuc.clientId, 'client-gercek');
  });

  test('D6: changes\'te KENDI clientId\'li echo op\'u -- UYGULANIR; UzakAlanDurumu sunucunun (kirpilmis) HLC\'siyle yazilir', () async {
    final db = dosyaDbAc();
    await gorevYaz(db, 'e1', baslik: 'Yerel baslik');
    final uygulayici = uygulayiciOlustur(db);

    // Echo: gelen op'un clientId'si BU cihazinkiyle AYNI (client-yerel) --
    // D6: atlanmaz, normal yoldan uygulanir.
    await uygulayici.changesUygula([
      baslikDegisikligi(entityId: 'e1', opId: 'kendi-opim', clientId: 'client-yerel', wallMs: 9999, title: 'Sunucudaki kirpilmis deger'),
    ]);

    final gorev = await (db.select(db.gorevler)..where((t) => t.id.equals('e1'))).getSingle();
    expect(gorev.baslik, 'Sunucudaki kirpilmis deger', reason: 'echo ATILMAZ, uygulanir');
    await db.close();
  });

  test('D6: echo sonrasi UzakAlanDurumu.hlcWall -- govdedeki YEREL damga DEGIL, YANITTAKI damga', () async {
    final db = dosyaDbAc();
    await gorevYaz(db, 'e1');
    final uygulayici = uygulayiciOlustur(db);
    // Sunucunun KIRPILMIS damgasi (9999) -- istemcinin yerelde uretmis
    // olabilecegi HERHANGI bir damgadan BAGIMSIZ, yalniz gelen govdedeki
    // deger baz alinir (bu senaryoda tek kaynak zaten budur).
    await uygulayici.changesUygula([
      baslikDegisikligi(entityId: 'e1', opId: 'kendi-opim', clientId: 'client-yerel', wallMs: 9999, title: 'x'),
    ]);
    final meta = await (db.select(db.uzakAlanDurumu)
          ..where((t) => t.entityId.equals('e1') & t.alan.equals('fields:title')))
        .getSingle();
    expect(meta.hlcWall, 9999);
    await db.close();
  });

  test('D6: echo, AYNI ALAN icin kuyrukta "bekliyor" op VARKEN gelir -- UzakAlanDurumu YINE yazilir; Gorevler DEGISMEZ', () async {
    final db = dosyaDbAc();
    await gorevYaz(db, 'e1', baslik: 'Bekleyen yerel deger');
    final yerelOp = WireOp(
      operationId: 'bekleyen-op',
      clientId: 'client-yerel',
      entityId: 'e1',
      actorId: 'actor-1',
      entityType: 'Task',
      opHlc: const Hlc(wallMs: 5000, counter: 0, clientId: 'client-yerel'),
      fields: {'title': const WireFieldWrite(value: 'Bekleyen yerel deger', hlc: Hlc(wallMs: 5000, counter: 0, clientId: 'client-yerel'))},
    );
    await kuyrukSatiriEkle(db, opId: 'bekleyen-op', entityId: 'e1', govdeJson: jsonEncode(yerelOp.toJson()), hlcWallMs: 5000);

    final uygulayici = uygulayiciOlustur(db);
    // Echo, kuyruktaki ile AYNI opId+HLC'de geri geliyor (sunucu tarafindan
    // KIRPILMAMIS -- ayni deger, farkli "kaynak").
    await uygulayici.changesUygula([
      baslikDegisikligi(entityId: 'e1', opId: 'bekleyen-op', clientId: 'client-yerel', wallMs: 5000, title: 'Bekleyen yerel deger'),
    ]);

    final meta = await (db.select(db.uzakAlanDurumu)
          ..where((t) => t.entityId.equals('e1') & t.alan.equals('fields:title')))
        .getSingleOrNull();
    expect(meta, isNotNull, reason: 'meta karari kuyruga BAKMAZ -- yazilmali');
    final gorev = await (db.select(db.gorevler)..where((t) => t.id.equals('e1'))).getSingle();
    expect(gorev.baslik, 'Bekleyen yerel deger', reason: 'projeksiyon kuyruk tabaniyla korunur');
    await db.close();
  });

  test('D5: hamAlanHlcCikar -- govdede "title": cipasi VAR, desen BOZULMUS -- StateError firlatir', () {
    const bozukGovde = '{"operationId":"x","fields":{"title":{"BOZUK_SEKIL":true}}}';
    expect(() => hamAlanHlcCikar(bozukGovde, 'fields:title'), throwsA(isA<StateError>()));
  });

  test('D5: hamAlanHlcCikar -- govdede "notes": cipasi YOK -- sessiz null (MESRU), istisna YOK', () {
    final op = WireOp(
      operationId: 'op1',
      clientId: 'c1',
      entityId: 'e1',
      actorId: 'a1',
      entityType: 'Task',
      opHlc: const Hlc(wallMs: 1, counter: 0, clientId: 'c1'),
      fields: {'title': const WireFieldWrite(value: 'x', hlc: Hlc(wallMs: 1, counter: 0, clientId: 'c1'))},
    );
    final govde = jsonEncode(op.toJson());
    expect(() => hamAlanHlcCikar(govde, 'fields:notes'), returnsNormally);
    expect(hamAlanHlcCikar(govde, 'fields:notes'), isNull);
  });

  test('D4: uzak yazim uygulandiktan sonra senkronDurumu DEGISMEDI', () async {
    final db = dosyaDbAc();
    await gorevYaz(db, 'e1', senkronDurumu: 'cevrimdisi');
    final uygulayici = uygulayiciOlustur(db);
    await uygulayici.changesUygula([
      baslikDegisikligi(entityId: 'e1', opId: 'uzakop1', clientId: 'client-uzak', wallMs: 1000, title: 'Yeni'),
    ]);
    final gorev = await (db.select(db.gorevler)..where((t) => t.id.equals('e1'))).getSingle();
    expect(gorev.senkronDurumu, 'cevrimdisi');
    await db.close();
  });

  // ================= T7 (D0/D7): itme turu da uygular + atomik sayfa =================

  test('D0: itme turu (turCalistir()) yaniti changes tasir -- degisiklikler UYGULANIR (bugun: atiliyor)', () async {
    final db = dosyaDbAc();
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final hlc = HlcUretici(simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch, clientId: ayarlar.clientId);
    final depo = DriftGorevDeposu(db, saat: () => DateTime.now().toUtc(), idUret: uretimIdUret, hlc: hlc, ayarlarDeposu: ayarlarDeposu, actorId: ayarlar.devUserId);
    await depo.ekle('itilecek gorev');

    final agi = SahteSenkronAgi(
      davranis: (govde, cagriNo) async {
        final ops = (govde['ops'] as List).cast<Map<String, Object?>>();
        return SenkronBasarili(jsonEncode({
          'serverHlc': null,
          'nextCursor': {'xid': 1, 'seq': 0},
          'hasMore': false,
          'resyncRequired': false,
          'applied': [for (final op in ops) {'operationId': op['operationId'], 'code': 'Applied', 'effectiveOpHlc': op['opHlc']}],
          'changes': [
            {
              'cursor': {'xid': 1, 'seq': 0},
              'payload': {
                'operationId': 'baska-cihaz-op',
                'clientId': 'baska-clientId',
                'entityId': 'e-baska-cihaz',
                'actorId': 'baska-actor',
                'entityType': 'Task',
                'opHlc': {'wallMs': 500, 'counter': 0, 'clientId': 'baska-clientId'},
                'fields': {'title': {'value': 'Baska cihazdan gelen gorev', 'hlc': {'wallMs': 500, 'counter': 0, 'clientId': 'baska-clientId'}}},
              },
            },
          ],
          'snapshot': [],
        }));
      },
    );
    final dongu = SenkronDongusu(db: db, agi: agi, ayarlarDeposu: ayarlarDeposu, hlc: hlc, clientId: ayarlar.clientId, devUserId: ayarlar.devUserId);
    await dongu.turCalistir();

    final baskaCihazGorevi = await (db.select(db.gorevler)..where((t) => t.id.equals('e-baska-cihaz'))).getSingleOrNull();
    expect(baskaCihazGorevi, isNotNull, reason: 'itme turu changesi ATMAMALI, UYGULAMALI');
    expect(baskaCihazGorevi!.baslik, 'Baska cihazdan gelen gorev');
    await db.close();
  });

  test('D0: ilk itme turu (sinceCursor==null), yanit snapshot tasir -- snapshot UYGULANIR, hicbir entity kaybolmaz', () async {
    final db = dosyaDbAc();
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final hlc = HlcUretici(simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch, clientId: ayarlar.clientId);
    final depo = DriftGorevDeposu(db, saat: () => DateTime.now().toUtc(), idUret: uretimIdUret, hlc: hlc, ayarlarDeposu: ayarlarDeposu, actorId: ayarlar.devUserId);
    await depo.ekle('ilk itme');

    final agi = SahteSenkronAgi(
      davranis: (govde, cagriNo) async {
        expect(govde['sinceCursor'], isNull, reason: 'ilk tur -- sinceCursor null gitmeli');
        final ops = (govde['ops'] as List).cast<Map<String, Object?>>();
        return SenkronBasarili(jsonEncode({
          'serverHlc': null,
          'nextCursor': {'xid': 1, 'seq': 0},
          'hasMore': false,
          'resyncRequired': false,
          'applied': [for (final op in ops) {'operationId': op['operationId'], 'code': 'Applied', 'effectiveOpHlc': op['opHlc']}],
          'changes': [],
          'snapshot': [
            {
              'entityType': 'Task',
              'entityId': 'e-snapshot-entity',
              'scalars': [
                {'field': 'title', 'value': 'Snapshottan gelen gorev', 'hlc': {'wallMs': 900, 'counter': 0, 'clientId': 'snap-client'}, 'winOperationId': 'snap-op'},
              ],
              'sets': [],
              'groups': [],
            },
          ],
        }));
      },
    );
    final dongu = SenkronDongusu(db: db, agi: agi, ayarlarDeposu: ayarlarDeposu, hlc: hlc, clientId: ayarlar.clientId, devUserId: ayarlar.devUserId);
    await dongu.turCalistir();

    final pushedGorev = await (db.select(db.gorevler)..where((t) => t.baslik.equals('ilk itme'))).getSingleOrNull();
    expect(pushedGorev, isNotNull, reason: 'itilen gorev KAYBOLMAMALI');
    final snapshotGorevi = await (db.select(db.gorevler)..where((t) => t.id.equals('e-snapshot-entity'))).getSingleOrNull();
    expect(snapshotGorevi, isNotNull, reason: 'snapshot entity UYGULANMALI');
    await db.close();
  });

  test('D7: sayfa uygulamasi ile imlec yaziminin sirasi -- imlec EN SON yazildi', () async {
    final db = dosyaDbAc();
    final cagriSirasi = <String>[];
    final ayarlarDeposu = _GozlemciAyarlarDeposu(db, idUret: uretimIdUret, cagriSirasi: cagriSirasi);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final hlc = HlcUretici(simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch, clientId: ayarlar.clientId);
    final uygulayici = _GozlemciUygulayici(db, cagriSirasi: cagriSirasi, kuyrukTabaniSaglayici: (entityId, alan) => kuyrukEnBuyuk(db, entityId, alan));

    final agi = SahteSenkronAgi(
      davranis: (govde, cagriNo) async => SenkronBasarili(jsonEncode({
        'serverHlc': null,
        'nextCursor': {'xid': 1, 'seq': 0},
        'hasMore': false,
        'resyncRequired': false,
        'applied': [],
        'changes': [],
        'snapshot': [
          {
            'entityType': 'Task', 'entityId': 'e-sira-testi',
            'scalars': [{'field': 'title', 'value': 'Sira testi', 'hlc': {'wallMs': 1, 'counter': 0, 'clientId': 'c1'}, 'winOperationId': 'op1'}],
            'sets': [], 'groups': [],
          },
        ],
      })),
    );
    final dongu = SenkronDongusu(db: db, agi: agi, ayarlarDeposu: ayarlarDeposu, hlc: hlc, clientId: ayarlar.clientId, devUserId: ayarlar.devUserId, uygulayici: uygulayici);
    await dongu.cekmeTuruCalistir();

    expect(cagriSirasi, ['snapshotUygula', 'nextCursorKalicilastir'], reason: 'veri ONCE, imlec SONRA yazilmali');
    await db.close();
  });

  test('D7: uygulama ortasinda firlayan sahte uygulayici (yarim sayfa) -- TEK transaction geri sarildi', () async {
    final db = dosyaDbAc();
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final hlc = HlcUretici(simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch, clientId: ayarlar.clientId);
    final firlatanUygulayici = _FirlatanUygulayici(db, kuyrukTabaniSaglayici: (entityId, alan) => kuyrukEnBuyuk(db, entityId, alan));

    final agi = SahteSenkronAgi(
      davranis: (govde, cagriNo) async => SenkronBasarili(jsonEncode({
        'serverHlc': null,
        'nextCursor': {'xid': 999, 'seq': 0},
        'hasMore': false,
        'resyncRequired': false,
        'applied': [],
        'changes': [
          {
            'cursor': {'xid': 999, 'seq': 0},
            'payload': {
              'operationId': 'yarim-sayfa-op', 'clientId': 'c1', 'entityId': 'e-yarim-sayfa', 'actorId': 'a1', 'entityType': 'Task',
              'opHlc': {'wallMs': 1, 'counter': 0, 'clientId': 'c1'},
              'fields': {'title': {'value': 'Yarim sayfa gorevi', 'hlc': {'wallMs': 1, 'counter': 0, 'clientId': 'c1'}}},
            },
          },
        ],
        'snapshot': [],
      })),
    );
    final dongu = SenkronDongusu(db: db, agi: agi, ayarlarDeposu: ayarlarDeposu, hlc: hlc, clientId: ayarlar.clientId, devUserId: ayarlar.devUserId, uygulayici: firlatanUygulayici);

    await expectLater(dongu.cekmeTuruCalistir(), throwsA(isA<StateError>()));

    final ayarSatiri = await (db.select(db.ayarlar)..where((t) => t.id.equals(1))).getSingle();
    expect(ayarSatiri.nextCursorJson, isNull, reason: 'imlec ESKI (baslangic) degerinde kalmali -- ilerlememeli');
    final yarimSayfaGorevi = await (db.select(db.gorevler)..where((t) => t.id.equals('e-yarim-sayfa'))).getSingleOrNull();
    expect(yarimSayfaGorevi, isNull, reason: 'uygulanan satir OLMAMALI -- tum islem geri sarildi');
    await db.close();
  });
}

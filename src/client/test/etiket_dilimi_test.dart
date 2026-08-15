@TestOn('vm')
library;

// ODEV.md §4(a) ETIKET DILIMI -- kapi testleri.
//
// Kapsam: tel bicimi (sunucu sozlesmesinin AYNASI) * yerel birlestirme
// kurallari (adds/removes idempotent + degismeli) * snapshot uzlasmasi
// (tombstone TELE CIKMAZ ⇒ kuyruk korumasi) * D5 kor nokta (sets tasiyan
// govde `fields:title` cipasini YANLISLIKLA tetiklemez) * sorgu (etiketler
// TEK sorgudan, benzersiz + sirali).
//
// `NativeDatabase.memory()` YASAGI (G2/G3 gerekcesi) BURADA GECERSIZDIR:
// bu dosya "kapat/yeniden ac" ayagi OLCMEZ; olctugu sey birlestirme
// mantigidir. Migration/kalicilik ayaklari g2_migration_kapisi_test.dart'ta
// gercek DOSYA DB ile kosar.

import 'dart:convert';

import 'package:client/senkron/kuyruk_tabani.dart';
import 'package:client/senkron/uzak_degisiklik_uygulayici.dart';
import 'package:client/sunum/etiket_dogrulama.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/veritabani.dart';
import 'package:client/veri/wire_op.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sayaca bagli, DETERMINISTIK id uretici -- uretilen tag'ler testte
/// BEKLENEBILIR olmali (rastgele GUID iddiayi olcemez hale getirirdi).
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

Future<GorevRow> _gorevEkle(Veritabani db, String id) async {
  await db
      .into(db.gorevler)
      .insert(
        GorevlerCompanion.insert(
          id: id,
          baslik: 'Gorev $id',
          olusturuldu: DateTime.utc(2026, 8, 1),
          guncellendi: DateTime.utc(2026, 8, 1),
        ),
      );
  return (db.select(db.gorevler)..where((t) => t.id.equals(id))).getSingle();
}

Future<List<GorevEtiketiRow>> _etiketSatirlari(Veritabani db, String gorevId) =>
    (db.select(db.gorevEtiketleri)
          ..where((t) => t.gorevId.equals(gorevId))
          ..orderBy([(t) => OrderingTerm(expression: t.addTag)]))
        .get();

Map<String, Object?> _hlcJson({int wall = 1000, int counter = 0, String clientId = 'uzak'}) => {
  'wallMs': wall,
  'counter': counter,
  'clientId': clientId,
};

Map<String, Object?> _setsOpu(
  String entityId, {
  List<Map<String, Object?>> adds = const [],
  List<Map<String, Object?>> removes = const [],
}) => {
  'cursor': 'c',
  'payload': {
    'operationId': 'op-uzak',
    'clientId': 'uzak',
    'entityId': entityId,
    'actorId': 'u2',
    'entityType': 'Task',
    'opHlc': _hlcJson(),
    'sets': {
      'tags': {
        if (adds.isNotEmpty) 'adds': adds,
        if (removes.isNotEmpty) 'removes': removes,
      },
    },
  },
};

void main() {
  // ================= 1. DOGRULAMA =================

  group('etiketDogrula (TEK kaynak)', () {
    test('kirpar, bosu reddeder, azami uzunlugu asani reddeder', () {
      expect(etiketDogrula('  is  '), 'is');
      expect(etiketDogrula('   '), isNull);
      expect(etiketDogrula(''), isNull);
      expect(etiketDogrula('a' * kEtiketAzamiUzunluk), 'a' * kEtiketAzamiUzunluk);
      expect(etiketDogrula('a' * (kEtiketAzamiUzunluk + 1)), isNull);
      // Kirpma UZUNLUKTAN ONCE: 32 karakter + bosluklar GECERLI.
      expect(etiketDogrula('  ${'b' * kEtiketAzamiUzunluk}  '), 'b' * kEtiketAzamiUzunluk);
    });

    test('BUYUK/KUCUK HARF KATLANMAZ -- sunucu Ordinal karsilastirir (BILINEN SINIR)', () {
      expect(etiketDogrula('İş'), 'İş');
      expect(etiketDogrula('iş'), 'iş');
      expect(etiketDogrula('İş') == etiketDogrula('iş'), isFalse);
    });
  });

  // ================= 2. TEL BICIMI =================

  group('tel bicimi (sunucu sozlesmesinin aynasi)', () {
    test('WireSetDelta JSON: el/tag/hlc + observed -- BOS liste tele KONMAZ', () {
      final hlc = Hlc(wallMs: 7, counter: 1, clientId: 'c1');
      final op = WireOp(
        operationId: 'op1',
        clientId: 'c1',
        entityId: 'g1',
        actorId: 'u1',
        entityType: 'Task',
        opHlc: hlc,
        sets: {
          'tags': WireSetDelta(
            adds: [WireSetAdd(el: 'iş', tag: 't1', hlc: hlc)],
            removes: [
              WireSetRemove(el: 'ev', observed: ['t0', 't9'], hlc: hlc),
            ],
          ),
        },
      );
      final json = op.toJson();
      final sets = json['sets']! as Map<String, Object?>;
      final tags = sets['tags']! as Map<String, Object?>;
      expect((tags['adds']! as List).single, {
        'el': 'iş',
        'tag': 't1',
        'hlc': hlc.toJson(),
      });
      expect((tags['removes']! as List).single, {
        'el': 'ev',
        'observed': ['t0', 't9'],
        'hlc': hlc.toJson(),
      });

      // Yalniz add tasiyan delta 'removes' anahtarini HIC yazmaz (sunucuda
      // ikisi de nullable).
      final yalnizAdd = WireSetDelta(
        adds: [WireSetAdd(el: 'a', tag: 't', hlc: hlc)],
      ).toJson();
      expect(yalnizAdd.containsKey('removes'), isFalse);
      expect(const WireSetDelta().bosMu, isTrue);
    });

    test('sets tasimayan op `sets` anahtarini HIC yazmaz (D2 -- eski govdeler bozulmaz)', () {
      final hlc = Hlc(wallMs: 7, counter: 1, clientId: 'c1');
      final json = WireOp(
        operationId: 'op1',
        clientId: 'c1',
        entityId: 'g1',
        actorId: 'u1',
        entityType: 'Task',
        opHlc: hlc,
        fields: {'title': WireFieldWrite(value: 'x', hlc: hlc)},
      ).toJson();
      expect(json.containsKey('sets'), isFalse);
    });
  });

  // ================= 3. D5 KOR NOKTA =================

  test('D5: sets tasiyan govde `fields:title` cipasini TETIKLEMEZ (StateError firlamaz)', () {
    final hlc = Hlc(wallMs: 7, counter: 1, clientId: 'c1');
    // 🔴 SALDIRGAN ETIKET: metnin KENDISI `"title":{"value"` benzeri bir
    // dizge tasiyor. JSON kacisi (`\"`) cipayi bozdugu icin desen TAKILMAZ.
    final govde = jsonEncode(
      WireOp(
        operationId: 'op1',
        clientId: 'c1',
        entityId: 'g1',
        actorId: 'u1',
        entityType: 'Task',
        opHlc: hlc,
        sets: {
          'tags': WireSetDelta(
            adds: [
              WireSetAdd(el: 'iş', tag: 't1', hlc: hlc),
              WireSetAdd(el: '"title":{"value":"x"}', tag: 't2', hlc: hlc),
            ],
          ),
        },
      ).toJson(),
    );

    expect(hamAlanHlcCikar(govde, 'fields:title'), isNull);
    expect(hamAlanHlcCikar(govde, 'groups:completion'), isNull);
    // Pozitif kontrol: AYNI fonksiyon gercek bir title yaziminda OKUR.
    final titleGovde = jsonEncode(
      WireOp(
        operationId: 'op2',
        clientId: 'c1',
        entityId: 'g1',
        actorId: 'u1',
        entityType: 'Task',
        opHlc: hlc,
        fields: {'title': WireFieldWrite(value: 'x', hlc: hlc)},
        sets: {
          'tags': WireSetDelta(adds: [WireSetAdd(el: 'iş', tag: 't3', hlc: hlc)]),
        },
      ).toJson(),
    );
    expect(hamAlanHlcCikar(titleGovde, 'fields:title')?.wallMs, 7);
  });

  // ================= 4. YEREL YAZMA YOLU =================

  group('depo yazma yolu', () {
    late Veritabani db;
    late DriftGorevDeposu depo;
    late _SayacId id;

    setUp(() async {
      db = _bellekDb();
      id = _SayacId();
      depo = await _depoKur(db, id);
      await _gorevEkle(db, 'g1');
    });

    tearDown(() => db.close());

    test('ekleme: yerel satir + TEK op, tel `adds` ile AYNI tag', () async {
      await depo.ayrintilariGuncelle('g1', etiketEklenen: {'iş'});

      final satirlar = await _etiketSatirlari(db, 'g1');
      expect(satirlar.length, 1);
      expect(satirlar.single.etiket, 'iş');
      expect(satirlar.single.iptalEdildi, isFalse);

      final kuyruk = await db.select(db.senkronKuyrugu).get();
      expect(kuyruk.length, 1);
      final govde = jsonDecode(kuyruk.single.govdeJson) as Map<String, Object?>;
      final tags =
          (govde['sets']! as Map<String, Object?>)['tags']! as Map<String, Object?>;
      final add = (tags['adds']! as List).single as Map<String, Object?>;
      expect(add['el'], 'iş');
      expect(add['tag'], satirlar.single.addTag,
          reason: 'tele giden tag ile YEREL satirin tag`i AYNI olmali -- '
              'ayrilirsa uzaktan gelen remove yerel satiri iptal EDEMEZ');
      expect(add['hlc'], isA<Map<String, Object?>>());
      expect(govde['operationId'], isNotNull);
    });

    test('silme: `observed` DEPODA cozulur -- aktif TUM tag`ler iptal edilir', () async {
      // Iki AYRI istemciden gelmis gibi ayni etiket icin IKI aktif tag.
      await depo.ayrintilariGuncelle('g1', etiketEklenen: {'iş'});
      await db
          .into(db.gorevEtiketleri)
          .insert(
            GorevEtiketleriCompanion.insert(
              gorevId: 'g1',
              etiket: 'iş',
              addTag: 'uzak-tag',
            ),
          );

      await depo.ayrintilariGuncelle('g1', etiketSilinen: {'iş'});

      final satirlar = await _etiketSatirlari(db, 'g1');
      expect(satirlar.every((s) => s.iptalEdildi), isTrue,
          reason: 'aktif tag`lerin HEPSI iptal edilmeli (ADD-WINS aksi halde diriltir)');

      final sonGovde = (await db.select(db.senkronKuyrugu).get()).last.govdeJson;
      final tags = ((jsonDecode(sonGovde) as Map<String, Object?>)['sets']!
              as Map<String, Object?>)['tags']!
          as Map<String, Object?>;
      final remove = (tags['removes']! as List).single as Map<String, Object?>;
      expect(remove['el'], 'iş');
      expect(
        (remove['observed']! as List).toSet(),
        satirlar.map((s) => s.addTag).toSet(),
      );
    });

    test('AKTIF TAG YOKSA op URETILMEZ (D2: bos op yasagi)', () async {
      await depo.ayrintilariGuncelle('g1', etiketSilinen: {'olmayan'});
      expect(await db.select(db.senkronKuyrugu).get(), isEmpty);
      expect(await _etiketSatirlari(db, 'g1'), isEmpty);
    });

    test('baslik + oncelik + etiket TEK op, TEK transaction`da gider', () async {
      await depo.ayrintilariGuncelle(
        'g1',
        baslik: const Yazim('Yeni'),
        oncelik: const Yazim(1),
        etiketEklenen: {'iş'},
      );
      final kuyruk = await db.select(db.senkronKuyrugu).get();
      expect(kuyruk.length, 1, reason: 'iki kanal TEK op tasimali');
      final govde = jsonDecode(kuyruk.single.govdeJson) as Map<String, Object?>;
      expect((govde['fields']! as Map<String, Object?>).keys.toSet(), {'title', 'priority'});
      expect(govde.containsKey('sets'), isTrue);
    });

    test('sorgu: etiketler TEK sorgudan gelir -- BENZERSIZ ve SIRALI, iptalli GORUNMEZ', () async {
      await depo.ayrintilariGuncelle('g1', etiketEklenen: {'ev', 'iş'});
      await depo.ayrintilariGuncelle('g1', etiketEklenen: {'acil'});
      // Iptal edilen etiket listede GORUNMEZ.
      await depo.ayrintilariGuncelle('g1', etiketSilinen: {'ev'});

      final gorunum = await depo.gorevlerGorunur().first;
      expect(gorunum.single.gorev.etiketler, ['acil', 'iş']);
    });

    test('sorgu: etiket satiri olmayan gorev DUSMEZ (leftOuterJoin)', () async {
      final gorunum = await depo.gorevlerGorunur().first;
      expect(gorunum.length, 1);
      expect(gorunum.single.gorev.etiketler, isEmpty);
    });

    test('sorgu: ucuncu join rozet sayimlarini SISIRMEZ (distinct korumasi)', () async {
      // Ayni gorevde UC etiket + kuyrukta birden cok op ⇒ kartezyen carpim
      // buyur; `distinct: true` olmasaydi bekleyen sayisi sisip rozet
      // DEGISIRDI.
      await depo.ayrintilariGuncelle('g1', etiketEklenen: {'a', 'b', 'c'});
      var ucusta = -1, bekleyen = -1, zehirli = -1, cakisma = -1;
      final gorunum = await depo
          .gorevlerGorunur(
            hamSayimGozlemcisi: (u, b, z, c) {
              ucusta = u;
              bekleyen = b;
              zehirli = z;
              cakisma = c;
            },
          )
          .first;
      expect(gorunum.single.gorev.etiketler, ['a', 'b', 'c']);
      expect(bekleyen, 1, reason: 'TEK op var -- uc etiket satiri sayiyi SISIRMEMELI');
      expect(ucusta, 0);
      expect(zehirli, 0);
      expect(cakisma, 0);
    });

    test('etiket metninde AYIRAC benzeri karakterler: virgullu etiket BOZULMAZ', () async {
      await depo.ayrintilariGuncelle('g1', etiketEklenen: {'is, ev', 'okul'});
      final gorunum = await depo.gorevlerGorunur().first;
      expect(gorunum.single.gorev.etiketler, ['is, ev', 'okul'],
          reason: 'group_concat ayiraci VIRGUL OLSAYDI bu etiket ikiye bolunurdu');
    });
  });

  // ================= 5. UZAK YOL (delta) =================

  group('uzak delta birlestirme', () {
    late Veritabani db;
    late UzakDegisiklikUygulayici uygulayici;

    setUp(() async {
      db = _bellekDb();
      uygulayici = UzakDegisiklikUygulayici(db, clientId: 'c1');
      await _gorevEkle(db, 'g1');
    });

    tearDown(() => db.close());

    test('adds: insertOrIgnore -- IPTALLI tag`in add`i OLU DOGAR', () async {
      await uygulayici.changesUygula([
        _setsOpu('g1', adds: [
          {'el': 'iş', 'tag': 't1', 'hlc': _hlcJson()},
        ]),
      ]);
      await uygulayici.changesUygula([
        _setsOpu('g1', removes: [
          {'el': 'iş', 'observed': ['t1'], 'hlc': _hlcJson()},
        ]),
      ]);
      // AYNI add YENIDEN gelir (yeniden gonderim/kesisen sayfa).
      await uygulayici.changesUygula([
        _setsOpu('g1', adds: [
          {'el': 'iş', 'tag': 't1', 'hlc': _hlcJson()},
        ]),
      ]);

      final satirlar = await _etiketSatirlari(db, 'g1');
      expect(satirlar.single.iptalEdildi, isTrue,
          reason: 'tombstone KALICI -- sonra gelen add DIRILTEMEZ');
    });

    test('removes: HIC GORULMEMIS tag icin satir ACILIR (sunucunun Cancelled.Add`i)', () async {
      await uygulayici.changesUygula([
        _setsOpu('g1', removes: [
          {'el': 'iş', 'observed': ['gelmemis-tag'], 'hlc': _hlcJson()},
        ]),
      ]);
      final satirlar = await _etiketSatirlari(db, 'g1');
      expect(satirlar.single.addTag, 'gelmemis-tag');
      expect(satirlar.single.iptalEdildi, isTrue);

      // Ayni tag`in add`i SONRA gelirse: OLU DOGAR.
      await uygulayici.changesUygula([
        _setsOpu('g1', adds: [
          {'el': 'iş', 'tag': 'gelmemis-tag', 'hlc': _hlcJson()},
        ]),
      ]);
      expect((await _etiketSatirlari(db, 'g1')).single.iptalEdildi, isTrue);
    });

    test('SIRADAN BAGIMSIZ (degismeli): remove-once vs add-once AYNI sonucu verir', () async {
      final db2 = _bellekDb();
      final uygulayici2 = UzakDegisiklikUygulayici(db2, clientId: 'c1');
      await _gorevEkle(db2, 'g1');

      final add = _setsOpu('g1', adds: [
        {'el': 'iş', 'tag': 't1', 'hlc': _hlcJson()},
      ]);
      final remove = _setsOpu('g1', removes: [
        {'el': 'iş', 'observed': ['t1'], 'hlc': _hlcJson()},
      ]);

      await uygulayici.changesUygula([add, remove]);
      await uygulayici2.changesUygula([remove, add]);

      final a = await _etiketSatirlari(db, 'g1');
      final b = await _etiketSatirlari(db2, 'g1');
      expect(a.map((s) => (s.etiket, s.addTag, s.iptalEdildi)),
          b.map((s) => (s.etiket, s.addTag, s.iptalEdildi)));
      expect(a.single.iptalEdildi, isTrue);
      await db2.close();
    });

    test('IDEMPOTENT: ayni delta iki kez uygulanir -- sonuc DEGISMEZ', () async {
      final op = _setsOpu('g1', adds: [
        {'el': 'iş', 'tag': 't1', 'hlc': _hlcJson()},
      ]);
      await uygulayici.changesUygula([op]);
      await uygulayici.changesUygula([op]);
      expect((await _etiketSatirlari(db, 'g1')).length, 1);
    });

    test('sets kanali LWW meta`ya (UzakAlanDurumu) DOKUNMAZ', () async {
      await uygulayici.changesUygula([
        _setsOpu('g1', adds: [
          {'el': 'iş', 'tag': 't1', 'hlc': _hlcJson()},
        ]),
      ]);
      expect(await db.select(db.uzakAlanDurumu).get(), isEmpty,
          reason: 'OR-Set`te ALAN BASINA TEK KAZANAN kavrami YOKTUR');
    });
  });

  // ================= 6. SNAPSHOT UZLASMASI =================

  group('snapshot uzlasmasi', () {
    late Veritabani db;
    late UzakDegisiklikUygulayici uygulayici;

    setUp(() async {
      db = _bellekDb();
      uygulayici = UzakDegisiklikUygulayici(db, clientId: 'c1');
      await _gorevEkle(db, 'g1');
    });

    tearDown(() => db.close());

    Map<String, Object?> snapshotEntity({
      List<Map<String, Object?>>? sets,
      bool setsAnahtariVar = true,
    }) => {
      'entityType': 'Task',
      'entityId': 'g1',
      'scalars': [
        {
          'field': 'title',
          'value': 'Gorev g1',
          'hlc': _hlcJson(wall: 2000),
          'winOperationId': 'op-s',
        },
      ],
      'groups': const [],
      if (setsAnahtariVar) 'sets': sets ?? const [],
    };

    test('snapshottaki aktif tag EKLENIR', () async {
      await uygulayici.snapshotUygula([
        snapshotEntity(sets: [
          {
            'setName': 'tags',
            'elements': [
              {
                'element': 'iş',
                'activeTags': [
                  {'tag': 't1', 'hlc': _hlcJson()},
                ],
              },
            ],
          },
        ]),
      ]);
      final satirlar = await _etiketSatirlari(db, 'g1');
      expect(satirlar.single.etiket, 'iş');
      expect(satirlar.single.iptalEdildi, isFalse);
    });

    test('snapshotta OLMAYAN yerel tag: KUYRUKTAYSA korunur, DEGILSE iptal edilir', () async {
      // (a) kuyrukta op`u OLAN tag
      await db.into(db.gorevEtiketleri).insert(
            GorevEtiketleriCompanion.insert(
              gorevId: 'g1',
              etiket: 'kuyrukta',
              addTag: 'tag-kuyrukta',
            ),
          );
      await db.into(db.senkronKuyrugu).insert(
            SenkronKuyruguCompanion.insert(
              opId: 'op-yerel',
              clientId: 'c1',
              entityType: 'Task',
              entityId: 'g1',
              govdeJson: jsonEncode({
                'sets': {
                  'tags': {
                    'adds': [
                      {'el': 'kuyrukta', 'tag': 'tag-kuyrukta', 'hlc': _hlcJson()},
                    ],
                  },
                },
              }),
              hlcWallMs: 5,
              hlcCounter: 0,
              olusturuldu: DateTime.utc(2026, 8, 14),
            ),
          );
      // (b) kuyrukta op`u OLMAYAN tag (uzakta silinmis)
      await db.into(db.gorevEtiketleri).insert(
            GorevEtiketleriCompanion.insert(
              gorevId: 'g1',
              etiket: 'uzakta-silindi',
              addTag: 'tag-eski',
            ),
          );

      await uygulayici.snapshotUygula([snapshotEntity(sets: const [])]);

      final satirlar = await _etiketSatirlari(db, 'g1');
      final harita = {for (final s in satirlar) s.etiket: s.iptalEdildi};
      expect(harita['kuyrukta'], isFalse, reason: 'KUYRUK KORUMASI: op henuz gitmedi');
      expect(harita['uzakta-silindi'], isTrue, reason: 'uzakta iptal edilmis');
    });

    test('KUYRUKTAKI REMOVE korumaz -- `observed` bare-string`dir, desene TAKILMAZ', () async {
      await db.into(db.gorevEtiketleri).insert(
            GorevEtiketleriCompanion.insert(
              gorevId: 'g1',
              etiket: 'silinen',
              addTag: 'tag-silinen',
            ),
          );
      await db.into(db.senkronKuyrugu).insert(
            SenkronKuyruguCompanion.insert(
              opId: 'op-remove',
              clientId: 'c1',
              entityType: 'Task',
              entityId: 'g1',
              govdeJson: jsonEncode({
                'sets': {
                  'tags': {
                    'removes': [
                      {'el': 'silinen', 'observed': ['tag-silinen'], 'hlc': _hlcJson()},
                    ],
                  },
                },
              }),
              hlcWallMs: 5,
              hlcCounter: 0,
              olusturuldu: DateTime.utc(2026, 8, 14),
            ),
          );

      await uygulayici.snapshotUygula([snapshotEntity(sets: const [])]);
      expect((await _etiketSatirlari(db, 'g1')).single.iptalEdildi, isTrue);
    });

    test('`sets` ANAHTARI YOKSA uzlasma KOSMAZ (yerel etiket sessizce silinmez)', () async {
      await db.into(db.gorevEtiketleri).insert(
            GorevEtiketleriCompanion.insert(
              gorevId: 'g1',
              etiket: 'yerel',
              addTag: 'tag-yerel',
            ),
          );
      await uygulayici.snapshotUygula([snapshotEntity(setsAnahtariVar: false)]);
      expect((await _etiketSatirlari(db, 'g1')).single.iptalEdildi, isFalse);
    });

    test('YEREL TOMBSTONE korunur: snapshot tag`i AKTIF gosterse bile diriltilmez', () async {
      await db.into(db.gorevEtiketleri).insert(
            GorevEtiketleriCompanion.insert(
              gorevId: 'g1',
              etiket: 'iş',
              addTag: 't1',
              iptalEdildi: const Value(true),
            ),
          );
      await uygulayici.snapshotUygula([
        snapshotEntity(sets: [
          {
            'setName': 'tags',
            'elements': [
              {
                'element': 'iş',
                'activeTags': [
                  {'tag': 't1', 'hlc': _hlcJson()},
                ],
              },
            ],
          },
        ]),
      ]);
      expect((await _etiketSatirlari(db, 'g1')).single.iptalEdildi, isTrue);
    });
  });

  // ================= 7. DENETIM BULGULARI (o76, iki bagimsiz denetci) =======

  group('denetim bulgulari -- kapatildi', () {
    late Veritabani db;
    late DriftGorevDeposu depo;
    late UzakDegisiklikUygulayici uygulayici;
    late _SayacId id;

    setUp(() async {
      db = _bellekDb();
      id = _SayacId();
      depo = await _depoKur(db, id);
      uygulayici = UzakDegisiklikUygulayici(db, clientId: 'c1');
      await _gorevEkle(db, 'g1');
    });

    tearDown(() => db.close());

    // CIDDI-1: BANT-ICI AYIRAC. Uzaktan gelen, kontrol karakteri TASIYAN bir
    // eleman TEK etikettir ve SILINEBILIR olmali (hayalet etiket yasak).
    test('kontrol karakteri (U+001F) tasiyan uzak etiket BOLUNMEZ ve SILINEBILIR', () async {
      const bolucu = 'a\u001Fb';
      await uygulayici.changesUygula([
        _setsOpu('g1', adds: [
          {'el': bolucu, 'tag': 'uzak-1', 'hlc': _hlcJson()},
        ]),
      ]);

      final gorunum = await depo.gorevlerGorunur().first;
      expect(gorunum.single.gorev.etiketler, [bolucu],
          reason: 'bant-ici ayirac IKI HAYALET etiket dogurmamali');

      // Hayalet olsaydi bu silme HICBIR aktif satir bulamaz ve op URETMEZDI.
      await depo.ayrintilariGuncelle('g1', etiketSilinen: {bolucu});
      final sonra = await depo.gorevlerGorunur().first;
      expect(sonra.single.gorev.etiketler, isEmpty);
      final kuyruk = await db.select(db.senkronKuyrugu).get();
      expect(kuyruk.length, 1, reason: 'silme op`u URETILMELI');
    });

    test('cift tirnak / kose parantez / virgul tasiyan etiket BOZULMAZ (JSON kacisi)', () async {
      const zor = '"a", ["b"]';
      await depo.ayrintilariGuncelle('g1', etiketEklenen: {zor, 'sade'});
      final gorunum = await depo.gorevlerGorunur().first;
      expect(gorunum.single.gorev.etiketler, [zor, 'sade']..sort());
    });

    // Bulgu-3 (denetci B): BOS DIZE eleman projeksiyondan DUSER ama satir ve
    // tel DOKUNULMADAN durur.
    test('bos dize eleman projeksiyondan duser, DB satiri durur', () async {
      await uygulayici.changesUygula([
        _setsOpu('g1', adds: [
          {'el': '', 'tag': 'bos-1', 'hlc': _hlcJson()},
          {'el': 'iş', 'tag': 'dolu-1', 'hlc': _hlcJson()},
        ]),
      ]);
      final gorunum = await depo.gorevlerGorunur().first;
      expect(gorunum.single.gorev.etiketler, ['iş'],
          reason: 'bos cip cizilmez; komsu etiket de KAYBOLMAZ');
      expect((await _etiketSatirlari(db, 'g1')).length, 2,
          reason: 'DB satiri ve tel DOKUNULMADAN durur');
    });

    // CIDDI-2 (denetci A, M5): `gonderildi` durumundaki op DA korur.
    test('KUYRUK KORUMASI `gonderildi` durumunu DA kapsar (ucustaki op)', () async {
      await db.into(db.gorevEtiketleri).insert(
            GorevEtiketleriCompanion.insert(
              gorevId: 'g1',
              etiket: 'ucusta',
              addTag: 'tag-ucusta',
            ),
          );
      await db.into(db.senkronKuyrugu).insert(
            SenkronKuyruguCompanion.insert(
              opId: 'op-ucusta',
              clientId: 'c1',
              entityType: 'Task',
              entityId: 'g1',
              govdeJson: jsonEncode({
                'sets': {
                  'tags': {
                    'adds': [
                      {'el': 'ucusta', 'tag': 'tag-ucusta', 'hlc': _hlcJson()},
                    ],
                  },
                },
              }),
              hlcWallMs: 5,
              hlcCounter: 0,
              olusturuldu: DateTime.utc(2026, 8, 14),
              // 🔴 MUTANT KAPISI: filtre yalniz 'bekliyor' olsaydi bu satir
              // korumasiz kalir ve tombstone KALICI oldugu icin sunucudan
              // gelecek echo onu ASLA DIRILTEMEZDI (kalici veri kaybi).
              durum: const Value('gonderildi'),
            ),
          );

      await uygulayici.snapshotUygula([
        {
          'entityType': 'Task',
          'entityId': 'g1',
          'scalars': const [],
          'groups': const [],
          'sets': const [],
        },
      ]);
      expect((await _etiketSatirlari(db, 'g1')).single.iptalEdildi, isFalse);
    });

    // CIDDI-2 (denetci A, M10): kuyruk deseni YALNIZ `"tag"` anahtarini
    // okur -- `"el"` degerini tag SANMAZ.
    test('kuyruk deseni `el` degerini TAG SANMAZ (desen ozgullugu)', () async {
      // Yerelde aktif bir satir; addTag'i, kuyruktaki op'un ELEMAN METNIYLE
      // ayni. Desen `el`i de okusaydi bu satir YANLISLIKLA korunurdu.
      await db.into(db.gorevEtiketleri).insert(
            GorevEtiketleriCompanion.insert(
              gorevId: 'g1',
              etiket: 'kurban',
              addTag: 'TUZAK',
            ),
          );
      // Kuyruktaki op'un GERCEK tag'i: bu satir KORUNMALI (pozitif kontrol --
      // aksi halde test yalniz "her sey iptal edildi" der ve korumayi olcmez).
      await db.into(db.gorevEtiketleri).insert(
            GorevEtiketleriCompanion.insert(
              gorevId: 'g1',
              etiket: 'kurban',
              addTag: 'gercek-tag',
            ),
          );
      await db.into(db.senkronKuyrugu).insert(
            SenkronKuyruguCompanion.insert(
              opId: 'op-tuzak',
              clientId: 'c1',
              entityType: 'Task',
              entityId: 'g1',
              govdeJson: jsonEncode({
                'sets': {
                  'tags': {
                    'adds': [
                      {'el': 'TUZAK', 'tag': 'gercek-tag', 'hlc': _hlcJson()},
                    ],
                  },
                },
              }),
              hlcWallMs: 5,
              hlcCounter: 0,
              olusturuldu: DateTime.utc(2026, 8, 14),
            ),
          );

      await uygulayici.snapshotUygula([
        {
          'entityType': 'Task',
          'entityId': 'g1',
          'scalars': const [],
          'groups': const [],
          'sets': const [],
        },
      ]);
      final harita = {
        for (final s in await _etiketSatirlari(db, 'g1')) s.addTag: s.iptalEdildi,
      };
      expect(harita['TUZAK'], isTrue,
          reason: '`el` degeri tag sayilsaydi bu satir yanlislikla KORUNURDU');
      expect(harita['gercek-tag'], isFalse, reason: 'gercek tag KORUNMALI');
    });

    // KUCUK-1 (denetci A): uzlasma (ELEMAN, TAG) ciftine gore yapilir.
    test('uzlasma (eleman, tag) CIFTINE bakar -- ayni tag baska eleman altinda korumaz', () async {
      await db.into(db.gorevEtiketleri).insert(
            GorevEtiketleriCompanion.insert(
              gorevId: 'g1',
              etiket: 'A',
              addTag: 'ortak-tag',
            ),
          );
      await uygulayici.snapshotUygula([
        {
          'entityType': 'Task',
          'entityId': 'g1',
          'scalars': const [],
          'groups': const [],
          'sets': [
            {
              'setName': 'tags',
              'elements': [
                {
                  'element': 'B',
                  'activeTags': [
                    {'tag': 'ortak-tag', 'hlc': _hlcJson()},
                  ],
                },
              ],
            },
          ],
        },
      ]);
      final harita = {
        for (final s in await _etiketSatirlari(db, 'g1'))
          (s.etiket, s.addTag): s.iptalEdildi,
      };
      expect(harita[('A', 'ortak-tag')], isTrue,
          reason: 'uzakta A altinda AKTIF DEGIL ⇒ iptal edilmeli');
      expect(harita[('B', 'ortak-tag')], isFalse);
    });
  });
}

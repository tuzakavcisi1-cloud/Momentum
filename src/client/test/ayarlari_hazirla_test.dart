import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/ayarlari_hazirla.dart';
import 'package:client/veri/veritabani.dart' hide Ayarlar;
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// G19 -- `ayarlariHazirla` sozlesmesi. ORTAK FIKSTUR (pazarliksiz, spec
/// SS5): devUserId == imlecSahibi == GUID-A (ESIT), nextCursorJson DOLU,
/// uzak_alan_durumu/gorevler/senkron_kuyrugu her biri >= 2 satir. Cagridan
/// ONCE dort sayi okunup `print` ile KANITA yazilir.
const String _guidA = '11111111-1111-1111-1111-111111111111';
const String _guidB = '22222222-2222-2222-2222-222222222222';

class _CasusAyarlarDeposu extends AyarlarDeposu {
  int devUserIdDegistirCagriSayisi = 0;
  _CasusAyarlarDeposu(super.db, {required super.idUret});

  @override
  Future<void> devUserIdDegistir(String yeni) async {
    devUserIdDegistirCagriSayisi++;
    await super.devUserIdDegistir(yeni);
  }
}

void main() {
  late Veritabani db;

  Future<void> fiksturKur() async {
    await db.into(db.ayarlar).insert(
      AyarlarCompanion.insert(
        clientId: 'cihaz-1',
        devUserId: _guidA,
        imlecSahibi: const Value(_guidA),
        nextCursorJson: const Value('{"Xid":7,"Seq":3}'),
      ),
    );
    for (var i = 0; i < 2; i++) {
      await db.into(db.uzakAlanDurumu).insert(
        UzakAlanDurumuCompanion.insert(
          entityType: 'gorev',
          entityId: 'e$i',
          alan: 'fields:title',
          hlcWall: 1000 + i,
          hlcCounter: i,
          hlcClientId: 'cihaz-1',
          winOpId: 'op-$i',
        ),
      );
      await db.into(db.gorevler).insert(
        GorevlerCompanion.insert(
          id: 'g$i',
          baslik: 'gorev $i',
          olusturuldu: DateTime.utc(2026, 1, 1),
          guncellendi: DateTime.utc(2026, 1, 1),
        ),
      );
      await db.into(db.senkronKuyrugu).insert(
        SenkronKuyruguCompanion.insert(
          opId: 'op-$i',
          clientId: 'cihaz-1',
          entityType: 'gorev',
          entityId: 'g$i',
          govdeJson: '{}',
          hlcWallMs: 1000 + i,
          hlcCounter: i,
          olusturuldu: DateTime.utc(2026, 1, 1),
        ),
      );
    }
  }

  Future<void> onceDortSayiYaz() async {
    final ayarlar =
        await (db.select(db.ayarlar)..where((t) => t.id.equals(1))).getSingle();
    final uzak = await db.select(db.uzakAlanDurumu).get();
    final gorev = await db.select(db.gorevler).get();
    final kuyruk = await db.select(db.senkronKuyrugu).get();
    // ignore: avoid_print
    print('G19-KANIT ONCE: cursor=${ayarlar.nextCursorJson == null ? "bos" : "dolu"} '
        'uzak=${uzak.length} gorev=${gorev.length} kuyruk=${kuyruk.length}');
    expect(ayarlar.nextCursorJson, isNotNull);
    expect(uzak, hasLength(greaterThanOrEqualTo(2)));
    expect(gorev, hasLength(greaterThanOrEqualTo(2)));
    expect(kuyruk, hasLength(greaterThanOrEqualTo(2)));
  }

  setUp(() async {
    db = Veritabani(NativeDatabase.memory());
    await fiksturKur();
  });

  tearDown(() async {
    await db.close();
  });

  test('G19/a: farkli GUID ezmesi -- devUserId degisir, dort kayit sifirlanir', () async {
    await onceDortSayiYaz();
    final depo = AyarlarDeposu(db, idUret: () => throw StateError('idUret cagrilmamali'));

    final sonuc = await ayarlariHazirla(db, depo, ezme: _guidB);

    expect(sonuc.devUserId, _guidB);
    expect(sonuc.nextCursorJson, isNull);
    expect(await db.select(db.uzakAlanDurumu).get(), isEmpty);
    expect(await db.select(db.gorevler).get(), isEmpty);
    expect(await db.select(db.senkronKuyrugu).get(), isEmpty);
  });

  test('G19/b: bos ezme -- devUserId DEGISMEZ, cursor KORUNUR, tablolar DOLU kalir', () async {
    await onceDortSayiYaz();
    final depo = AyarlarDeposu(db, idUret: () => throw StateError('idUret cagrilmamali'));

    final sonuc = await ayarlariHazirla(db, depo, ezme: '');

    expect(sonuc.devUserId, _guidA);
    expect(sonuc.nextCursorJson, '{"Xid":7,"Seq":3}');
    expect(await db.select(db.uzakAlanDurumu).get(), hasLength(2));
    expect(await db.select(db.gorevler).get(), hasLength(2));
    expect(await db.select(db.senkronKuyrugu).get(), hasLength(2));
  });

  test('G19/c: ezme zaten esit -- devUserIdDegistir HIC cagrilmaz (casus sayar)', () async {
    await onceDortSayiYaz();
    final casus =
        _CasusAyarlarDeposu(db, idUret: () => throw StateError('idUret cagrilmamali'));

    final sonuc = await ayarlariHazirla(db, casus, ezme: _guidA);

    expect(casus.devUserIdDegistirCagriSayisi, 0);
    expect(sonuc.devUserId, _guidA);
    expect(sonuc.nextCursorJson, '{"Xid":7,"Seq":3}');
    expect(await db.select(db.uzakAlanDurumu).get(), hasLength(2));
    expect(await db.select(db.gorevler).get(), hasLength(2));
    expect(await db.select(db.senkronKuyrugu).get(), hasLength(2));
  });

  test('G19/d: GUID olmayan ezme -- ArgumentError firlar, HICBIR sey degismez', () async {
    await onceDortSayiYaz();
    final depo = AyarlarDeposu(db, idUret: () => throw StateError('idUret cagrilmamali'));

    await expectLater(
      () => ayarlariHazirla(db, depo, ezme: 'onur'),
      throwsArgumentError,
    );

    final ayarlar =
        await (db.select(db.ayarlar)..where((t) => t.id.equals(1))).getSingle();
    expect(ayarlar.devUserId, _guidA);
    expect(ayarlar.nextCursorJson, '{"Xid":7,"Seq":3}');
    expect(await db.select(db.uzakAlanDurumu).get(), hasLength(2));
    expect(await db.select(db.gorevler).get(), hasLength(2));
    expect(await db.select(db.senkronKuyrugu).get(), hasLength(2));
  });
}

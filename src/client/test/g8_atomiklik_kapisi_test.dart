@TestOn('vm')
library;

// GOREV-slice-3c G8 -- ATOMIKLIK + COKME KURTARMA KAPISI. Gercek dosya DB
// (D1'le ayni gerekce: NativeDatabase.memory() ile "kapat/yeniden ac"
// ayagi anlamsizlasir).

import 'dart:io';

import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/senkron_dongusu.dart';
import 'package:client/veri/veritabani.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'destekler/sahte_senkron_agi.dart';

void main() {
  late Directory gecici;

  setUp(() {
    gecici = Directory.systemTemp.createTempSync('g8-atomiklik-kapisi');
  });

  tearDown(() {
    try {
      gecici.deleteSync(recursive: true);
    } catch (_) {}
  });

  Veritabani dosyaDbAc() =>
      Veritabani(NativeDatabase(File('${gecici.path}/m.sqlite')));

  test('D8: kuyruk yazimi zorla firlatilir -- Gorevlerde de 0 satir (islem geri sarilir)', () async {
    final db = dosyaDbAc();
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final hlc = HlcUretici(
      simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch,
      clientId: ayarlar.clientId,
    );

    // Kuyruk INSERT'inin PK ihlaliyle FIRLAMASINI saglamak icin, uretilecek
    // operationId ile AYNI opId'de bir satir ONCEDEN eklenir.
    const catisanOpId = 'catisan-op-id';
    await db
        .into(db.senkronKuyrugu)
        .insert(
          SenkronKuyruguCompanion.insert(
            opId: catisanOpId,
            clientId: 'x',
            entityType: 'Task',
            entityId: 'x',
            govdeJson: '{}',
            hlcWallMs: 1,
            hlcCounter: 1,
            olusturuldu: DateTime.now().toUtc(),
          ),
        );

    var cagri = 0;
    String idUret() {
      cagri++;
      // 1. cagri: Gorevler.id (taze) -- 2. cagri: operationId (CATISAN).
      return cagri == 1 ? 'taze-entity-id' : catisanOpId;
    }

    final depo = DriftGorevDeposu(
      db,
      saat: () => DateTime.now().toUtc(),
      idUret: idUret,
      hlc: hlc,
      ayarlarDeposu: ayarlarDeposu,
      actorId: ayarlar.devUserId,
    );

    await expectLater(depo.ekle('atomiklik testi'), throwsA(anything));

    final gorevler = await db.select(db.gorevler).get();
    expect(gorevler, isEmpty, reason: 'islem GERI SARILMALI -- hayalet Gorevler satiri olmamali');
    final kuyruk = await db.select(db.senkronKuyrugu).get();
    expect(kuyruk, hasLength(1), reason: 'yalniz ONCEDEN eklenen catisan satir kalmali');
    await db.close();
  });

  test('D8: Gorevler yazimi zorla firlatilir -- kuyrukta da 0 satir (hayalet op yok)', () async {
    final db = dosyaDbAc();
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final hlc = HlcUretici(
      simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch,
      clientId: ayarlar.clientId,
    );

    const catisanId = 'catisan-gorev-id';
    await db
        .into(db.gorevler)
        .insert(
          GorevlerCompanion.insert(
            id: catisanId,
            baslik: 'onceden var',
            olusturuldu: DateTime.now().toUtc(),
            guncellendi: DateTime.now().toUtc(),
          ),
        );

    var cagri = 0;
    String idUret() {
      cagri++;
      // 1. cagri: Gorevler.id (CATISAN) -- 2. cagri hic YAPILMAMALI (Gorevler
      // insert'i ilk basamak; firlarsa operationId hic uretilmez).
      return cagri == 1 ? catisanId : 'kullanilmamali';
    }

    final depo = DriftGorevDeposu(
      db,
      saat: () => DateTime.now().toUtc(),
      idUret: idUret,
      hlc: hlc,
      ayarlarDeposu: ayarlarDeposu,
      actorId: ayarlar.devUserId,
    );

    await expectLater(depo.ekle('atomiklik testi 2'), throwsA(anything));

    final kuyruk = await db.select(db.senkronKuyrugu).get();
    expect(kuyruk, isEmpty, reason: 'hayalet op OLUSMAMALI (Gorevler basarisizken kuyruk yazilmamali)');
    final gorevler = await db.select(db.gorevler).get();
    expect(gorevler, hasLength(1), reason: 'yalniz ONCEDEN eklenen catisan gorev kalmali');
    await db.close();
  });

  test('D8: uc op gonderildi iken DB kapatilip acilir -- ucu de bekliyore doner, secilebilir', () async {
    var db = dosyaDbAc();
    for (var i = 0; i < 3; i++) {
      await db
          .into(db.senkronKuyrugu)
          .insert(
            SenkronKuyruguCompanion.insert(
              opId: 'op-$i',
              clientId: 'c1',
              entityType: 'Task',
              entityId: 'e$i',
              govdeJson: '{"operationId":"op-$i"}',
              hlcWallMs: 1000 + i,
              hlcCounter: 0,
              durum: const Value('gonderildi'),
              olusturuldu: DateTime.now().toUtc(),
            ),
          );
    }
    await db.close();

    db = dosyaDbAc();
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final hlc = HlcUretici(
      simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch,
      clientId: ayarlar.clientId,
    );
    final agi = SahteSenkronAgi();
    final dongu = SenkronDongusu(
      db: db,
      agi: agi,
      ayarlarDeposu: ayarlarDeposu,
      hlc: hlc,
      clientId: ayarlar.clientId,
    );

    await dongu.gonderildiKurtar();
    final kurtarilan = await db.select(db.senkronKuyrugu).get();
    expect(kurtarilan, hasLength(3));
    for (final s in kurtarilan) {
      expect(s.durum, 'bekliyor', reason: '${s.opId} kurtarilmali');
    }

    // Yeniden secilebilir oldugunu da GERCEKTEN dogrula (turCalistir).
    await dongu.turCalistir();
    expect(agi.alinanIstekler, hasLength(1));
    expect((agi.alinanIstekler.single['ops'] as List), hasLength(3));
    await db.close();
  });

  test('D8: secim yuklemi -- yalniz durum=bekliyor satirlar secilir', () async {
    // NOT: 'gonderildi' durumu BURADA test EDILMEZ -- turCalistir() HER
    // turun basinda gonderildiKurtar() cagirir (D8/2 PAZARLIKSIZ), yani
    // 'gonderildi' bir satir bu cagriyla ONCE 'bekliyor'e doner ve sonra
    // DOGRU sekilde secilir -- bu, YUKARIDAKI "uc op gonderildi" testinde
    // ayrica dogrulanir. Burada YALNIZ 'zehirli' disarida biraklidigi
    // (G5'te de dogrulandi, G8'in kendi tablosunda AYRI satir).
    final db = dosyaDbAc();
    await db
        .into(db.senkronKuyrugu)
        .insert(
          SenkronKuyruguCompanion.insert(
            opId: 'bekliyor-op',
            clientId: 'c1',
            entityType: 'Task',
            entityId: 'e-bekliyor',
            govdeJson: '{"operationId":"bekliyor-op"}',
            hlcWallMs: 1,
            hlcCounter: 0,
            olusturuldu: DateTime.now().toUtc(),
          ),
        );
    await db
        .into(db.senkronKuyrugu)
        .insert(
          SenkronKuyruguCompanion.insert(
            opId: 'zehirli-op',
            clientId: 'c1',
            entityType: 'Task',
            entityId: 'e-zehirli',
            govdeJson: '{"operationId":"zehirli-op"}',
            hlcWallMs: 3,
            hlcCounter: 0,
            durum: const Value('zehirli'),
            olusturuldu: DateTime.now().toUtc(),
          ),
        );

    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final hlc = HlcUretici(
      simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch,
      clientId: ayarlar.clientId,
    );
    final agi = SahteSenkronAgi();
    final dongu = SenkronDongusu(
      db: db,
      agi: agi,
      ayarlarDeposu: ayarlarDeposu,
      hlc: hlc,
      clientId: ayarlar.clientId,
    );

    await dongu.turCalistir();
    final govde = agi.alinanIstekler.single;
    final gonderilenOpIdler = (govde['ops'] as List)
        .map((op) => (op as Map)['operationId'])
        .toSet();
    expect(gonderilenOpIdler, {'bekliyor-op'});
    await db.close();
  });
}

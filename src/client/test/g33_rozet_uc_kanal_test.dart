@TestOn('vm')
library;

// GOREV-SS2 G33 -- ROZET UCUNCU KANAL KAPISI (Dart, gercek dosya DB; ag
// YOK). `a`/`b`/`d` ayaklari burada birim testiyle olculur. `c` (distinct:
// true deseni) `ss2-kapisi.py` ile STATIK olculur (bkz. ss2-kapisi.py).

import 'dart:io';

import 'package:client/senkron/uzak_degisiklik_uygulayici.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/veritabani.dart';
import 'package:client/veri/wire_op.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory gecici;
  late Veritabani db;
  late AyarlarDeposu ayarlarDeposu;
  late DriftGorevDeposu depo;

  setUp(() async {
    gecici = Directory.systemTemp.createTempSync('g33-rozet-uc-kanal');
    db = Veritabani(NativeDatabase(File('${gecici.path}/m.sqlite')));
    ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    depo = DriftGorevDeposu(
      db,
      saat: () => DateTime.now().toUtc(),
      idUret: uretimIdUret,
      hlc: HlcUretici(simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch, clientId: ayarlar.clientId),
      ayarlarDeposu: ayarlarDeposu,
      actorId: ayarlar.devUserId,
    );
  });

  tearDown(() async {
    await db.close();
    try {
      gecici.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<void> cakismaKaydiEkle(String entityId, String alan) async {
    await db.into(db.cakismaKayitlari).insert(
      CakismaKayitlariCompanion.insert(
        entityId: entityId,
        alan: alan,
        kaybedenDeger: 'eski',
        kazananDeger: 'yeni',
        kazananClientHex: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        olusturuldu: DateTime.utc(2026, 1, 1),
      ),
    );
  }

  test('G33/a: cakisma kaydi olan gorevde cakismaVarMi==true; kayit silinince false (gorevlerGorunur() akisi uzerinden)', () async {
    await depo.ekle('Gorev A');
    final id = (await depo.gorevlerGorunur().first).single.gorev.id;

    var gorunum = (await depo.gorevlerGorunur().first).single;
    expect(gorunum.cakismaVarMi, isFalse, reason: 'onkosul: henuz cakisma yok');

    await cakismaKaydiEkle(id, 'fields:title');
    gorunum = (await depo.gorevlerGorunur().first).single;
    expect(gorunum.cakismaVarMi, isTrue);

    await (db.delete(db.cakismaKayitlari)..where((t) => t.entityId.equals(id))).go();
    gorunum = (await depo.gorevlerGorunur().first).single;
    expect(gorunum.cakismaVarMi, isFalse);
  });

  test('G33/b: UPDATE dali senkronDurumu\'na YAZMAZ (D4 kilidi) -- cakisma kaydi yazildiktan sonra sutun ONCEKI degeriyle BIREBIR ayni', () async {
    await depo.ekle('Gorev B');
    final gorevOnceki = await (db.select(db.gorevler)).getSingle();
    final senkronDurumuOncesi = gorevOnceki.senkronDurumu;

    final uygulayici = UzakDegisiklikUygulayici(
      db,
      clientId: 'client-yerel',
      bekleyenYerelYazimVarMi: (entityId, alan) async => true,
    );
    final hlc = Hlc(wallMs: 9999, counter: 0, clientId: 'client-uzak');
    await uygulayici.changesUygula([
      {
        'cursor': {'xid': 1, 'seq': 0},
        'payload': WireOp(
          operationId: 'op-uzak-1',
          clientId: 'client-uzak',
          entityId: gorevOnceki.id,
          actorId: 'actor-1',
          entityType: 'Task',
          opHlc: hlc,
          fields: {'title': WireFieldWrite(value: 'Cakisan Uzak Baslik', hlc: hlc)},
        ).toJson(),
      },
    ]);

    expect(await db.select(db.cakismaKayitlari).get(), isNotEmpty, reason: 'onkosul: cakisma gercekten yazildi');
    final gorevSonrasi = await (db.select(db.gorevler)..where((t) => t.id.equals(gorevOnceki.id))).getSingle();
    expect(gorevSonrasi.senkronDurumu, senkronDurumuOncesi, reason: 'D4: rozete (senkronDurumu) ASLA dokunulmaz');
  });

  test('G33/d: cakisma kaydi DOLU iken (0->1->2) ucusta/bekleyen/zehirli sayilari SABIT kalir (distinct:true fan-out korumasi, M176b)', () async {
    await depo.ekle('Gorev D');
    final gorev = await (db.select(db.gorevler)).getSingle();
    final id = gorev.id;

    // Bir bekliyor + bir gonderildi + bir zehirli satiri -- ucusta=1,
    // bekleyen=1 (ekle() zaten 1 bekliyor op uretti, onu 'gonderildi'ye
    // cevirip ayrica 'bekliyor' ve 'zehirli' birer satir daha ekliyoruz).
    await (db.update(db.senkronKuyrugu)..where((t) => t.entityId.equals(id))).write(
      const SenkronKuyruguCompanion(durum: Value('gonderildi')),
    );
    Future<void> kuyrukSatiriEkle(String opId, String durum) => db.into(db.senkronKuyrugu).insert(
      SenkronKuyruguCompanion.insert(
        opId: opId,
        clientId: 'client-yerel',
        entityType: 'Task',
        entityId: id,
        govdeJson: '{}',
        hlcWallMs: 0,
        hlcCounter: 0,
        durum: Value(durum),
        olusturuldu: DateTime.utc(2026, 1, 1),
      ),
    );
    await kuyrukSatiriEkle('op-bekliyor', 'bekliyor');
    await kuyrukSatiriEkle('op-zehirli', 'zehirli');

    // 🔴 rozetDikisi() yalniz '>0' sinar (1 ile 2 arasinda fark GORMEZ) --
    // fan-out'un GERCEKTEN sisip sismedigini kanitlamak icin PRODUKSIYONUN
    // KENDI sorgusundaki HAM sayilar `hamSayimGozlemcisi` (test-görünür)
    // ile dogrudan okunur -- bagimsiz bir kopya sorgu YAZILMAZ (öyle bir kopya
    // M176b mutasyonunu hiç GÖRMEZ, kendi sabit distinct:true'sunu taşır).
    Future<(int, int, int, int)> hamSayimlariOlc() async {
      late (int, int, int, int) sonuc;
      await depo.gorevlerGorunur(
        hamSayimGozlemcisi: (ucusta, bekleyen, zehirli, cakismaKaydiSayisi) {
          sonuc = (ucusta, bekleyen, zehirli, cakismaKaydiSayisi);
        },
      ).first;
      return sonuc;
    }

    // 0 cakisma kaydi -- taban.
    final taban = await hamSayimlariOlc();
    expect(taban, (1, 1, 1, 0), reason: 'onkosul: bir gonderildi + bir bekliyor + bir zehirli satiri, sifir cakisma kaydi');

    // 1 cakisma kaydi.
    await cakismaKaydiEkle(id, 'fields:title');
    expect(await hamSayimlariOlc(), (1, 1, 1, 1), reason: 'distinct:true olmadan fan-out ucusta/bekleyen/zehirliyi SISIRIRDI (ornegin 1->2)');

    // 2 cakisma kaydi (AYNI entity, FARKLI alan) -- fan-out riski EN YUKSEK burada.
    await cakismaKaydiEkle(id, 'groups:completion');
    expect(await hamSayimlariOlc(), (1, 1, 1, 2), reason: 'iki cakisma kaydiyla bile ucusta/bekleyen/zehirli DEGISMEMELI (distinct:true, D5 sqlite ile olculdu)');

    final gorunumSonrasi = (await depo.gorevlerGorunur().first).single;
    expect(gorunumSonrasi.cakismaVarMi, isTrue);
  });
}

@TestOn('vm')
library;

// GOREV-SS2 T6 -- `GorevDeposu.cakismaCoz` DAVRANISI (G34/d,e,f) + S11
// OLCUMU (ic ice transaction savepoint'e duser mi). Gercek dosya DB.

import 'dart:io';

import 'package:client/senkron/alan_anahtari.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/veritabani.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory gecici;

  setUp(() {
    gecici = Directory.systemTemp.createTempSync('g34-cakismacoz');
  });

  tearDown(() {
    try {
      gecici.deleteSync(recursive: true);
    } catch (_) {}
  });

  Veritabani dosyaDbAc(String ad) => Veritabani(NativeDatabase(File('${gecici.path}/$ad.sqlite')));

  // 🔴 S11 OLCUMU -- SPEC'IN BEYAN ETTIGI SINIR: "drift'in ic ice transaction()
  // cagrisini savepoint'e indirgedigi bu depoda ÖLÇÜLMEMİŞTİR." Bu test AYNI
  // nesting DESENINI (disaridaki transaction icinde baska bir transaction())
  // izole olarak kurar ve DISARIDAKI hata sonrasi ICERIDEKI yazimin da GERI
  // ALINIP ALINMADIGINI dogrudan olcer -- cakismaCoz'un KENDI mantigina
  // BAGIMLI DEGILDIR, drift'in mekanizmasinin kendisini sinar.
  test('S11 OLCUMU: ic ice transaction() savepoint\'e duser -- disaridaki throw ICERIDEKI yazimi da geri alir', () async {
    final db = dosyaDbAc('s11');
    await db.into(db.gorevler).insert(
      GorevlerCompanion.insert(
        id: 'e1',
        baslik: 'Baslangic',
        olusturuldu: DateTime.utc(2026, 1, 1),
        guncellendi: DateTime.utc(2026, 1, 1),
      ),
    );

    var icTransactionTamamlandi = false;
    Object? yakalananHata;
    try {
      await db.transaction(() async {
        await db.transaction(() async {
          await (db.update(db.gorevler)..where((t) => t.id.equals('e1'))).write(
            const GorevlerCompanion(baslik: Value('Ic-ice-yazim')),
          );
        });
        icTransactionTamamlandi = true;
        throw StateError('kasitli disaridaki hata -- S11 olcumu');
      });
    } catch (e) {
      yakalananHata = e;
    }

    expect(icTransactionTamamlandi, isTrue, reason: 'onkosul: ic transaction hatasiz tamamlandi');
    expect(yakalananHata, isA<StateError>(), reason: 'onkosul: dis hata gercekten firladi');

    final sonra = await (db.select(db.gorevler)..where((t) => t.id.equals('e1'))).getSingle();
    expect(
      sonra.baslik,
      'Baslangic',
      reason:
          'S11 OLCUMU: eger ic transaction() BAGIMSIZ commit etmis olsaydi '
          'burada "Ic-ice-yazim" gorulurdu -- yani ic ice transaction '
          'SAVEPOINT\'e indirgenmiyor demektir ve cakismaCoz D-SS2-6\'nin '
          'atomiklik iddiasi GECERSIZ olurdu (builder DURMALIYDI). Baslik '
          '"Baslangic" olarak KALDIYSA savepoint indirgemesi DOGRULANMISTIR.',
    );
    await db.close();
  });

  Future<DriftGorevDeposu> depoKur(Veritabani db) async {
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    return DriftGorevDeposu(
      db,
      saat: () => DateTime.utc(2026, 1, 1),
      idUret: uretimIdUret,
      hlc: HlcUretici(simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch, clientId: ayarlar.clientId),
      ayarlarDeposu: ayarlarDeposu,
      actorId: ayarlar.devUserId,
    );
  }

  test('G34/d: benimkiniTut -- kuyruga 1 yeni op (HLC kazanandan buyuk) VE projeksiyon kaybedenDeger\'e doner', () async {
    final db = dosyaDbAc('d');
    final depo = await depoKur(db);
    await db.into(db.gorevler).insert(
      GorevlerCompanion.insert(
        id: 'e1',
        baslik: 'Uzagin yazdigi baslik',
        olusturuldu: DateTime.utc(2026, 1, 1),
        guncellendi: DateTime.utc(2026, 1, 1),
      ),
    );
    await db.into(db.cakismaKayitlari).insert(
      CakismaKayitlariCompanion.insert(
        entityId: 'e1',
        alan: 'fields:title',
        kaybedenDeger: 'Benim yerel basligim',
        kazananDeger: 'Uzagin yazdigi baslik',
        kazananClientHex: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        olusturuldu: DateTime.utc(2026, 1, 1),
      ),
    );
    final kuyrukOncesi = await db.select(db.senkronKuyrugu).get();
    expect(kuyrukOncesi, isEmpty, reason: 'onkosul');

    await depo.cakismaCoz('e1', CakismaSecimi.benimkiniTut);

    final kuyrukSonrasi = await db.select(db.senkronKuyrugu).get();
    expect(kuyrukSonrasi, hasLength(1), reason: 'kuyruga TAM 1 yeni op girmeli');
    final gorevSonrasi = await (db.select(db.gorevler)..where((t) => t.id.equals('e1'))).getSingle();
    expect(gorevSonrasi.baslik, 'Benim yerel basligim', reason: 'projeksiyon kaybedenDeger\'e DONMELI');

    // HLC kazanandan buyuk: yeni op'un HLC'si (govdeJson icinde) kazananin
    // clientHex'inden (kazananAnahtar) BUYUK olmali (AlanAnahtari.compareTo).
    final yeniOp = kuyrukSonrasi.single;
    final kazananAnahtar = AlanAnahtari.normalizeEdilmis(
      wall: 0,
      counter: 0,
      clientHex: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      opHex: '0',
    );
    final yeniAnahtar = AlanAnahtari(
      wall: yeniOp.hlcWallMs,
      counter: yeniOp.hlcCounter,
      clientId: yeniOp.clientId,
      opId: yeniOp.opId,
    );
    expect(yeniAnahtar.compareTo(kazananAnahtar) > 0, isTrue, reason: 'yeni opun HLCsi kazanandan BUYUK olmali (wall/counter enjekte saatten ileri)');

    final kayitlarSonrasi = await db.select(db.cakismaKayitlari).get();
    expect(kayitlarSonrasi, isEmpty, reason: 'cozum sonrasi kayitlar SILINMELI');
    await db.close();
  });

  test('G34/e: onlarinkiniAl -- kuyruga YENI OP GIRMEZ, projeksiyon DEGISMEZ, kayitlar silinir', () async {
    final db = dosyaDbAc('e');
    final depo = await depoKur(db);
    await db.into(db.gorevler).insert(
      GorevlerCompanion.insert(
        id: 'e1',
        baslik: 'Uzagin yazdigi baslik',
        olusturuldu: DateTime.utc(2026, 1, 1),
        guncellendi: DateTime.utc(2026, 1, 1),
      ),
    );
    await db.into(db.cakismaKayitlari).insert(
      CakismaKayitlariCompanion.insert(
        entityId: 'e1',
        alan: 'fields:title',
        kaybedenDeger: 'Benim yerel basligim',
        kazananDeger: 'Uzagin yazdigi baslik',
        kazananClientHex: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        olusturuldu: DateTime.utc(2026, 1, 1),
      ),
    );

    await depo.cakismaCoz('e1', CakismaSecimi.onlarinkiniAl);

    expect(await db.select(db.senkronKuyrugu).get(), isEmpty, reason: 'yeni op GIRMEMELI');
    final gorevSonrasi = await (db.select(db.gorevler)..where((t) => t.id.equals('e1'))).getSingle();
    expect(gorevSonrasi.baslik, 'Uzagin yazdigi baslik', reason: 'projeksiyon zaten uzagin degerini tasiyor -- DEGISMEMELI');
    expect(await db.select(db.cakismaKayitlari).get(), isEmpty, reason: 'kayitlar SILINMELI');
    await db.close();
  });

  test('G34/f: yazma ONCE, silme SONRA -- kayitlar SILINMEDEN ONCE okunur, sonuc bunu KANITLAR (M177)', () async {
    final db = dosyaDbAc('f');
    final depo = await depoKur(db);
    await db.into(db.gorevler).insert(
      GorevlerCompanion.insert(
        id: 'e1',
        baslik: 'Uzagin yazdigi baslik',
        olusturuldu: DateTime.utc(2026, 1, 1),
        guncellendi: DateTime.utc(2026, 1, 1),
      ),
    );
    await db.into(db.cakismaKayitlari).insert(
      CakismaKayitlariCompanion.insert(
        entityId: 'e1',
        alan: 'fields:title',
        kaybedenDeger: 'Benim yerel basligim',
        kazananDeger: 'Uzagin yazdigi baslik',
        kazananClientHex: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        olusturuldu: DateTime.utc(2026, 1, 1),
      ),
    );

    await depo.cakismaCoz('e1', CakismaSecimi.benimkiniTut);

    // 🔴 Bu ikisi BIRLIKTE sirayi kanitlar: yazma GERCEKTEN oldu (M177
    // sirayi ters cevirip silmeyi ONCE kosturursa `kayitlar` sorgusu BOS
    // doner ve asagidaki `baslik` KAYBEDEN degerine DONMEZ, "Uzagin yazdigi
    // baslik" olarak KALIR -- bu, testin KIRMIZI vermesidir).
    final gorevSonrasi = await (db.select(db.gorevler)..where((t) => t.id.equals('e1'))).getSingle();
    expect(gorevSonrasi.baslik, 'Benim yerel basligim', reason: 'yazma GERCEKLESMELI (silme ondan SONRA kosmali)');
    expect(await db.select(db.senkronKuyrugu).get(), hasLength(1), reason: 'yazma yeni bir op da URETMELI');
    expect(await db.select(db.cakismaKayitlari).get(), isEmpty, reason: 'silme de GERCEKLESMELI');
    await db.close();
  });
}

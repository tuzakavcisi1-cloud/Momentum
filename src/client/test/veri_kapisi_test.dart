import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/veritabani.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// G7 -- VERI KATMANI KAPISI. Sabit saat/idUret ile deterministik.
void main() {
  late Veritabani db;
  late DriftGorevDeposu depo;
  late DateTime sabitSaat;
  var idSayaci = 0;

  setUp(() {
    db = Veritabani(NativeDatabase.memory());
    sabitSaat = DateTime.utc(2026, 7, 26, 12);
    idSayaci = 0;
    depo = DriftGorevDeposu(
      db,
      saat: () => sabitSaat,
      idUret: () => 'test-id-${idSayaci++}',
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('bos durum dogru zamanda', () async {
    final ilk = await depo.gorevlerGorunur().first;
    expect(ilk, isEmpty);
  });

  test('bes islem uctan uca: ekle, duzenle, tamamla/geri al, sil, listele', () async {
    await depo.ekle('Sut al');
    var liste = await depo.gorevlerGorunur().first;
    expect(liste, hasLength(1));
    expect(liste.single.baslik, 'Sut al');
    expect(liste.single.tamamlandi, isFalse);

    final id = liste.single.id;

    await depo.duzenle(id, 'Sut ve ekmek al');
    liste = await depo.gorevlerGorunur().first;
    expect(liste.single.baslik, 'Sut ve ekmek al');

    await depo.tamamlaGeriAl(id, tamamlandi: true);
    liste = await depo.gorevlerGorunur().first;
    expect(liste.single.tamamlandi, isTrue);

    await depo.tamamlaGeriAl(id, tamamlandi: false);
    liste = await depo.gorevlerGorunur().first;
    expect(liste.single.tamamlandi, isFalse);

    await depo.sil(id);
    liste = await depo.gorevlerGorunur().first;
    expect(liste, isEmpty);
  });

  test('yumusak silme: silinen kayit gorunur listede yok, ham tabloda var', () async {
    await depo.ekle('Silinecek gorev');
    final once = await depo.gorevlerGorunur().first;
    final id = once.single.id;

    await depo.sil(id);

    final gorunur = await depo.gorevlerGorunur().first;
    expect(gorunur, isEmpty);

    final ham = await db.select(db.gorevler).get();
    expect(ham, hasLength(1));
    expect(ham.single.silindi, isTrue);
    expect(ham.single.id, id);
  });

  test('olusturuldu/guncellendi daima isUtc == true', () async {
    await depo.ekle('UTC kontrolu');
    final satir = (await db.select(db.gorevler).get()).single;
    expect(satir.olusturuldu.isUtc, isTrue);
    expect(satir.guncellendi.isUtc, isTrue);
  });

  test('guncellendi her yazimda ilerler, olusturuldu degismez', () async {
    await depo.ekle('Ilerleme kontrolu');
    final ilkSatir = (await db.select(db.gorevler).get()).single;
    final ilkOlusturuldu = ilkSatir.olusturuldu;
    final ilkGuncellendi = ilkSatir.guncellendi;

    sabitSaat = sabitSaat.add(const Duration(minutes: 5));
    await depo.duzenle(ilkSatir.id, 'Degisti');

    final ikinciSatir = (await db.select(db.gorevler).get()).single;
    expect(ikinciSatir.olusturuldu, ilkOlusturuldu);
    expect(ikinciSatir.guncellendi.isAfter(ilkGuncellendi), isTrue);
  });

  test('senkronDurumu yerel disi yazma DB kisitindan duser', () async {
    await depo.ekle('Kisit kontrolu');
    final satir = (await db.select(db.gorevler).get()).single;

    await expectLater(
      db.customStatement(
        'UPDATE gorevler SET senkron_durumu = ? WHERE id = ?',
        ['kuyrukta', satir.id],
      ),
      throwsA(isA<Exception>()),
    );
  });
}

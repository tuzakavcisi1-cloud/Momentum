// ELLE DUMAN TESTI (T5/T6, oturum 32) -- `flutter test tool/uctan_uca_duman_testi.dart`
// ile kosulur (`dart run` YETERSIZ: dart:ui zincirini -- Veritabani drift_flutter
// uzerinden yukler -- kuyrugu ancak flutter_test'in VM baglami acar). `flutter
// test` (bare) bu dosyayi TARAMAZ (yalniz test/ altini), bu yuzden G7'nin
// regresyon sayisina karismaz. AG BAGIMLIDIR: localhost:5298'de calisan
// GERCEK backend + gercek Postgres ister; o yokken kirmizi yanar (beklenen --
// burasi bir CI testi degil, elle kosulan bir kanit aracidir). T3
// (HlcUretici/ayarlar) + T4 (WireOp uretimi) + T5 (HttpSenkronAgi) + T6
// (SenkronDongusu -- tam tur) zincirini GERCEK backend'e karsi UCTAN UCA
// dogrular.
import 'package:client/ag/http_senkron_agi.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/senkron_dongusu.dart';
import 'package:client/veri/veritabani.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('T6 duman testi: tam senkron turu gorevi senkronize eder', () async {
    final db = Veritabani(NativeDatabase.memory());
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final hlc = HlcUretici(
      simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch,
      clientId: ayarlar.clientId,
    );
    final depo = DriftGorevDeposu(
      db,
      saat: () => DateTime.now().toUtc(),
      idUret: uretimIdUret,
      hlc: hlc,
      ayarlarDeposu: ayarlarDeposu,
      actorId: ayarlar.devUserId,
    );

    await depo.ekle('T6 duman testi gorevi 1');
    await depo.ekle('T6 duman testi gorevi 2');
    await depo.tamamlaGeriAl(
      (await db.select(db.gorevler).get()).first.id,
      tamamlandi: true,
    );

    final oncekiKuyrukUzunlugu = (await db.select(db.senkronKuyrugu).get()).length;
    expect(oncekiKuyrukUzunlugu, 3); // 2x ekle + 1x tamamlaGeriAl

    final agi = HttpSenkronAgi(
      senkronUcNoktasi: Uri.parse('http://127.0.0.1:5298/v1/sync'),
      actorId: ayarlar.devUserId,
    );
    final dongu = SenkronDongusu(
      db: db,
      agi: agi,
      ayarlarDeposu: ayarlarDeposu,
      hlc: hlc,
      clientId: ayarlar.clientId,
      baslangicCursorJson: ayarlar.nextCursorJson,
    );

    await dongu.turCalistir();

    final kuyrukSonrasi = await db.select(db.senkronKuyrugu).get();
    expect(kuyrukSonrasi, isEmpty, reason: 'basarili turdan sonra kuyruk bosalmali');

    final gorevlerSonrasi = await db.select(db.gorevler).get();
    for (final g in gorevlerSonrasi) {
      expect(
        g.senkronDurumu,
        'senkronize',
        reason: '${g.baslik} senkronize olmali, oldu: ${g.senkronDurumu}',
      );
    }

    // D3: sonWall/sonCounter senkron sonrasi kalicilastirilmis olmali.
    final ayarSonrasi = await (db.select(
      db.ayarlar,
    )..where((t) => t.id.equals(1))).getSingle();
    expect(ayarSonrasi.sonWall, greaterThan(0));

    await db.close();
  });
}

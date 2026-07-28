// GOREV-slice-3d T1 -- YURUYEN ISKELET (bu adim bitmeden baska kod yazilmaz).
// `flutter test tool/t1_yalniz_cekme_duman.dart` ile kosulur (uctan_uca_duman_testi.dart
// ile AYNI gerekce: dart:ui zincirini -- Veritabani drift_flutter uzerinden yukler --
// kuyrugu ancak flutter_test'in VM baglami acar). `flutter test` (bare) bu dosyayi
// TARAMAZ (yalniz test/ altini). AG BAGIMLIDIR: localhost:5298'de GERCEK backend +
// gercek Postgres ister.
//
// Drift'e HICBIR SEY YAZILMAZ -- yalniz devUserId'yi almak icin gecici bellek-ici
// bir Veritabani acilir; govde "ops":[] tasir, gercek API'ye gonderilir, ham yanit
// oldugu gibi basilir ve KANIT dosyasina yazilir.
//
// ignore_for_file: avoid_print -- KANIT ciktisi kasitli.
import 'dart:convert';
import 'dart:io';

import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/veritabani.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('T1: yalniz-cekme istegi gercek API\'ye gider, 200 doner, snapshot dolu', () async {
    final db = Veritabani(NativeDatabase.memory());
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();

    print('T1-DEVUSERID: ${ayarlar.devUserId}');
    print('T1-CLIENTID: ${ayarlar.clientId}');

    // Taze devUserId'nin gorecek hicbir seyi olmaz -- "snapshot DOLU" kabul
    // kriterini anlamli kilmak icin, ham (Drift'siz) TEK bir push ile bir
    // gorev tohumlanir. Bu, olculen yalniz-cekme istegiNIN DISINDA bir
    // kurulum adimidir; Drift'e YINE hicbir sey yazilmaz.
    final tohumOpId = uretimIdUret();
    final tohumEntityId = uretimIdUret();
    const tohumWallMs = 1700000000000;
    final tohumGovde =
        '{"clientId":${jsonEncode(ayarlar.clientId)},"clientHlc":null,"sinceCursor":null,'
        '"ops":[{"operationId":"$tohumOpId","clientId":${jsonEncode(ayarlar.clientId)},'
        '"entityId":"$tohumEntityId","actorId":${jsonEncode(ayarlar.devUserId)},'
        '"entityType":"Task","opHlc":{"wallMs":$tohumWallMs,"counter":0,"clientId":${jsonEncode(ayarlar.clientId)}},'
        '"fields":{"title":{"value":"T1 tohum gorevi","hlc":{"wallMs":$tohumWallMs,"counter":0,"clientId":${jsonEncode(ayarlar.clientId)}}}}}]}';
    final tohumYaniti = await http.post(
      Uri.parse('http://127.0.0.1:5298/v1/sync'),
      headers: {'Content-Type': 'application/json', 'X-Momentum-Dev-User': ayarlar.devUserId},
      body: tohumGovde,
    );
    print('T1-TOHUM-DURUM-KODU: ${tohumYaniti.statusCode}');
    print('T1-TOHUM-YANIT: ${tohumYaniti.body}');
    expect(tohumYaniti.statusCode, 200, reason: 'T1 kurulum: tohum push 200 donmeli');

    final govde = '{"clientId":${jsonEncode(ayarlar.clientId)},"clientHlc":null,'
        '"sinceCursor":null,"ops":[]}';

    final yanit = await http.post(
      Uri.parse('http://127.0.0.1:5298/v1/sync'),
      headers: {
        'Content-Type': 'application/json',
        'X-Momentum-Dev-User': ayarlar.devUserId,
      },
      body: govde,
    );

    print('T1-DURUM-KODU: ${yanit.statusCode}');
    print('T1-HAM-YANIT: ${yanit.body}');

    expect(yanit.statusCode, 200, reason: 'T1 kabul: 200 alinmali');

    final govdeMap = jsonDecode(yanit.body) as Map<String, Object?>;
    final changes = govdeMap['changes'] as List?;
    final snapshot = govdeMap['snapshot'] as List?;
    expect(changes, isEmpty, reason: 'T1 kabul: sinceCursor:null turunda changes BOS olmali');
    expect(snapshot, isNotEmpty, reason: 'T1 kabul: sinceCursor:null turunda snapshot DOLU olmali');
    print('T1-SNAPSHOT-UZUNLUK: ${snapshot?.length}');

    final kanitDizini = Directory('../../KANIT/slice-3d/01-G1-yalniz-cekme');
    kanitDizini.createSync(recursive: true);
    print('T1-KANIT-DIZINI-MUTLAK: ${kanitDizini.absolute.path}');
    final kanitDosyasi = File('${kanitDizini.path}/t1-iskelet.txt');
    kanitDosyasi.writeAsStringSync(
      'T1 -- yalniz-cekme yuruyen iskelet\n'
      'istek govdesi: $govde\n'
      'durum kodu: ${yanit.statusCode}\n'
      'ham yanit:\n${yanit.body}\n',
    );

    await db.close();
  });
}

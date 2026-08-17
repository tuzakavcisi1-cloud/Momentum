import 'package:client/ag/http_senkron_agi.dart';
import 'package:client/ag/senkron_agi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// IS-EMRI-o83 s2.2/10: 401'de sessiz yenileme. `erisimJetonuAl`/`jetonuYenile`
// opsiyoneldir (varsayilan null) -- K192 emsali: MEVCUT cagri yerleri/davranis
// (erisimJetonuAl/jetonuYenile hic verilmeden) BIREBIR AYNI kalmali.

void main() {
  final uc = Uri.parse('http://sunucu.test/v1/sync');

  test('erisimJetonuAl/jetonuYenile verilmezse Authorization eklenmez, 401 DEGISMEDEN doner (geriye donuk uyum)', () async {
    var cagriSayisi = 0;
    final istemci = MockClient((istek) async {
      cagriSayisi++;
      expect(istek.headers.containsKey('Authorization'), isFalse);
      return http.Response('', 401);
    });
    final agi = HttpSenkronAgi(senkronUcNoktasi: uc, actorId: 'a1', istemci: istemci);

    final sonuc = await agi.gonder('{}');

    expect(sonuc, isA<SenkronHttpHatasi>());
    expect((sonuc as SenkronHttpHatasi).durumKodu, 401);
    expect(cagriSayisi, 1, reason: 'jetonuYenile verilmediyse TEKRAR DENEME olmamali');
  });

  test('erisimJetonuAl doluysa istek Authorization: Bearer tasir', () async {
    String? gorulenBaslik;
    final istemci = MockClient((istek) async {
      gorulenBaslik = istek.headers['Authorization'];
      return http.Response('{"ok":true}', 200);
    });
    final agi = HttpSenkronAgi(
      senkronUcNoktasi: uc,
      actorId: 'a1',
      istemci: istemci,
      erisimJetonuAl: () async => 'jeton-123',
    );

    final sonuc = await agi.gonder('{}');

    expect(sonuc, isA<SenkronBasarili>());
    expect(gorulenBaslik, 'Bearer jeton-123');
  });

  test('401 -> jetonuYenile TRUE donerse istek TEKRARLANIR, ikinci deneme basarili doner', () async {
    var cagriSayisi = 0;
    final istemci = MockClient((istek) async {
      cagriSayisi++;
      if (cagriSayisi == 1) {
        return http.Response('', 401);
      }
      return http.Response('{"ikinci":true}', 200);
    });
    var yenilemeCagrildi = 0;
    final agi = HttpSenkronAgi(
      senkronUcNoktasi: uc,
      actorId: 'a1',
      istemci: istemci,
      jetonuYenile: () async {
        yenilemeCagrildi++;
        return true;
      },
    );

    final sonuc = await agi.gonder('{}');

    expect(cagriSayisi, 2, reason: 'TEK bir tekrar denemesi -- sonsuz dongu yok');
    expect(yenilemeCagrildi, 1);
    expect(sonuc, isA<SenkronBasarili>());
    expect((sonuc as SenkronBasarili).govdeJson, '{"ikinci":true}');
  });

  test('401 -> jetonuYenile FALSE donerse SenkronHttpHatasi(401) DEGISMEDEN doner (kuyruk korunur -- SenkronDongusu kendi 401 dalini hic degistirmez)', () async {
    var cagriSayisi = 0;
    final istemci = MockClient((istek) async {
      cagriSayisi++;
      return http.Response('', 401);
    });
    final agi = HttpSenkronAgi(
      senkronUcNoktasi: uc,
      actorId: 'a1',
      istemci: istemci,
      jetonuYenile: () async => false,
    );

    final sonuc = await agi.gonder('{}');

    expect(cagriSayisi, 1, reason: 'yenileme basarisizsa TEKRAR DENEME olmamali');
    expect(sonuc, isA<SenkronHttpHatasi>());
    expect((sonuc as SenkronHttpHatasi).durumKodu, 401);
  });

  test('401 DISI hata kodlarinda jetonuYenile HIC CAGRILMAZ', () async {
    var yenilemeCagrildi = 0;
    final istemci = MockClient((istek) async => http.Response('', 500));
    final agi = HttpSenkronAgi(
      senkronUcNoktasi: uc,
      actorId: 'a1',
      istemci: istemci,
      jetonuYenile: () async {
        yenilemeCagrildi++;
        return true;
      },
    );

    final sonuc = await agi.gonder('{}');

    expect(yenilemeCagrildi, 0);
    expect((sonuc as SenkronHttpHatasi).durumKodu, 500);
  });
}

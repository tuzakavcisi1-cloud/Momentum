import 'dart:async';

import 'package:http/http.dart' as http;

import 'senkron_agi.dart';

/// GOREV-slice-3c T5: `SenkronAgi`nin gercek HTTP uygulamasi. `X-Momentum-Dev-User`
/// basligi D0/D7'nin `actorId`sidir -- deger koda GOMULMEZ (D0 kirmizi cizgi),
/// yapicidan (ayarlar.devUserId, T3) enjekte edilir.
class HttpSenkronAgi implements SenkronAgi {
  static const String _devKullaniciBasligi = 'X-Momentum-Dev-User';

  final http.Client _istemci;
  final Uri senkronUcNoktasi;
  final String actorId;
  final Duration zamanAsimi;

  HttpSenkronAgi({
    required this.senkronUcNoktasi,
    required this.actorId,
    http.Client? istemci,
    this.zamanAsimi = const Duration(seconds: 20),
  }) : _istemci = istemci ?? http.Client();

  @override
  Future<SenkronSonucu> gonder(String govdeJson) async {
    try {
      final yanit = await _istemci
          .post(
            senkronUcNoktasi,
            headers: {
              'Content-Type': 'application/json',
              _devKullaniciBasligi: actorId,
            },
            body: govdeJson,
          )
          .timeout(zamanAsimi);

      if (yanit.statusCode == 200) {
        return SenkronBasarili(yanit.body);
      }
      return SenkronHttpHatasi(yanit.statusCode);
    } catch (hata) {
      // D9 "ag hatasi / zaman asimi" -- zaman asimi (TimeoutException) ve
      // baglanti hatalari (platforma gore ClientException/SocketException)
      // AYNI dalda islenir; siniflandirma yalniz HTTP durum kodu YOKLUGUNA
      // dayanir, istisna TIPINE degil (web/native platform farkina bagimli
      // olmamak icin).
      return SenkronAgHatasi(hata);
    }
  }
}

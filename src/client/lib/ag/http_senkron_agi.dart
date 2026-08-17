import 'dart:async';

import 'package:http/http.dart' as http;

import 'senkron_agi.dart';

/// GOREV-slice-3c T5: `SenkronAgi`nin gercek HTTP uygulamasi. `X-Momentum-Dev-User`
/// basligi D0/D7'nin `actorId`sidir -- deger koda GOMULMEZ (D0 kirmizi cizgi),
/// yapicidan (ayarlar.devUserId, T3) enjekte edilir.
///
/// IS-EMRI-o83 s2.2/10: [erisimJetonuAl]/[jetonuYenile] EKLENDI (ikisi de opsiyonel,
/// varsayilan `null` -- MEVCUT cagri yerleri/testler DEGISMEDEN gecer, K192 emsali).
/// Verildiginde: istek `Authorization: Bearer` tasir; 401 gelirse [jetonuYenile]
/// TEK KEZ denenir, basariliysa istek AYNEN TEKRARLANIR (sonsuz dongu yok).
/// Yenileme de duserse SenkronHttpHatasi(401) DEGISMEDEN doner -- SenkronDongusu'nun
/// kendi 401 dali (kuyruk 'bekliyor'a doner) HICBIR SEKILDE degismez, kuyruk boylece
/// KORUNUR (s2.2/11).
class HttpSenkronAgi implements SenkronAgi {
  static const String _devKullaniciBasligi = 'X-Momentum-Dev-User';

  final http.Client _istemci;
  final Uri senkronUcNoktasi;
  final String actorId;
  final Duration zamanAsimi;
  final Future<String?> Function()? erisimJetonuAl;
  final Future<bool> Function()? jetonuYenile;

  HttpSenkronAgi({
    required this.senkronUcNoktasi,
    required this.actorId,
    http.Client? istemci,
    this.zamanAsimi = const Duration(seconds: 20),
    this.erisimJetonuAl,
    this.jetonuYenile,
  }) : _istemci = istemci ?? http.Client();

  @override
  Future<SenkronSonucu> gonder(String govdeJson) async {
    final sonuc = await _tekIstekGonder(govdeJson);
    if (sonuc is SenkronHttpHatasi &&
        sonuc.durumKodu == 401 &&
        jetonuYenile != null) {
      final yenilendiMi = await jetonuYenile!();
      if (yenilendiMi) {
        return _tekIstekGonder(govdeJson);
      }
    }
    return sonuc;
  }

  Future<SenkronSonucu> _tekIstekGonder(String govdeJson) async {
    try {
      final basliklar = {
        'Content-Type': 'application/json',
        _devKullaniciBasligi: actorId,
      };
      final jeton = erisimJetonuAl == null ? null : await erisimJetonuAl!();
      if (jeton != null) {
        basliklar['Authorization'] = 'Bearer $jeton';
      }
      final yanit = await _istemci
          .post(senkronUcNoktasi, headers: basliklar, body: govdeJson)
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

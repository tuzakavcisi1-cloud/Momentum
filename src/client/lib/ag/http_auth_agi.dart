import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_agi.dart';

/// `AuthAgi`nin gercek HTTP uygulamasi (`http_senkron_agi.dart`nin AYNI deseni).
class HttpAuthAgi implements AuthAgi {
  final http.Client _istemci;
  final String sunucuTabanUrl;
  final Duration zamanAsimi;

  HttpAuthAgi({
    required this.sunucuTabanUrl,
    http.Client? istemci,
    this.zamanAsimi = const Duration(seconds: 20),
  }) : _istemci = istemci ?? http.Client();

  Future<AuthSonucu> _istekGonder(String yol, Map<String, String> govde) async {
    try {
      final yanit = await _istemci
          .post(
            Uri.parse('$sunucuTabanUrl$yol'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(govde),
          )
          .timeout(zamanAsimi);

      if (yanit.statusCode == 200 || yanit.statusCode == 201) {
        final gov = jsonDecode(yanit.body) as Map<String, dynamic>;
        return AuthBasarili(
          erisimJetonu: gov['accessToken'] as String,
          yenilemeJetonu: gov['refreshToken'] as String,
          kullaniciId: gov['userId'] as String,
        );
      }
      return AuthHttpHatasi(yanit.statusCode);
    } catch (hata) {
      return AuthAgHatasi(hata);
    }
  }

  @override
  Future<AuthSonucu> kayitOl(String eposta, String sifre) =>
      _istekGonder('/v1/auth/register', {'email': eposta, 'password': sifre});

  @override
  Future<AuthSonucu> girisYap(String eposta, String sifre) =>
      _istekGonder('/v1/auth/login', {'email': eposta, 'password': sifre});

  @override
  Future<AuthSonucu> yenile(String yenilemeJetonu) =>
      _istekGonder('/v1/auth/refresh', {'refreshToken': yenilemeJetonu});

  @override
  Future<void> cikisYap(String yenilemeJetonu) async {
    try {
      await _istemci
          .post(
            Uri.parse('$sunucuTabanUrl/v1/auth/logout'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': yenilemeJetonu}),
          )
          .timeout(zamanAsimi);
    } catch (_) {
      // en-iyi-caba -- yerel oturum cikisYap cagrilmadan ONCE zaten temizlenir (OturumYoneticisi).
    }
  }
}

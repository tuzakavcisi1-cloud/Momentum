import 'dart:async';

import 'package:flutter/foundation.dart';

import '../ag/auth_agi.dart';
import '../design/metinler.dart';
import 'kimlik_deposu.dart';

/// IS-EMRI-o83 s2.2 -- oturum durumunun TEK sahibi. `oturum` reaktiftir: kok widget
/// bunu dinler, `null` iken GirisEkrani, degilken uygulama gosterilir.
class OturumYoneticisi {
  final AuthAgi _agi;
  final KimlikDeposu _depo;
  final ValueNotifier<KimlikDurumu?> oturum = ValueNotifier(null);

  // Ayni anda birden fazla istek 401 alirsa (ornegin push+pull) TEK yenileme
  // denemesi yapilir -- paralel yenileme cagrilari refresh token'i BIRDEN
  // FAZLA rotate ETMEYE calisip birbirini gecersiz kilmasin diye.
  bool _yenilemeSurmekte = false;

  // `required this._agi` KULLANILMAZ: initializing-formal parametre ADINI
  // alan adiyla (private `_agi`/`_depo`) ES ZORUNLU kilar -- `agi:`/`depo:`
  // cagri-yeri okunurlugu (main.dart) BILEREK tercih edildi.
  OturumYoneticisi({required AuthAgi agi, required KimlikDeposu depo})
    : _agi = agi, // ignore: prefer_initializing_formals
      _depo = depo; // ignore: prefer_initializing_formals

  Future<void> baslat() async {
    oturum.value = await _depo.oku();
  }

  Future<String?> girisYap(String eposta, String sifre) async {
    return _sonucIsle(await _agi.girisYap(eposta, sifre));
  }

  Future<String?> kayitOl(String eposta, String sifre) async {
    return _sonucIsle(await _agi.kayitOl(eposta, sifre));
  }

  /// `null`: basarili. Degilse kullaniciya gosterilecek hata metni.
  Future<String?> _sonucIsle(AuthSonucu sonuc) async {
    switch (sonuc) {
      case AuthBasarili basarili:
        final yeni = KimlikDurumu(
          erisimJetonu: basarili.erisimJetonu,
          yenilemeJetonu: basarili.yenilemeJetonu,
          kullaniciId: basarili.kullaniciId,
        );
        await _depo.yaz(yeni);
        oturum.value = yeni;
        return null;
      case AuthHttpHatasi(durumKodu: 401):
        return Metinler.girisHatasiGecersizBilgi;
      case AuthHttpHatasi(durumKodu: 409):
        return Metinler.girisHatasiEpostaKullanimda;
      case AuthHttpHatasi(durumKodu: 400):
        return Metinler.girisHatasiKisaSifre;
      case AuthHttpHatasi():
        return Metinler.girisHatasiGenel;
      case AuthAgHatasi():
        return Metinler.girisHatasiAg;
    }
  }

  /// IS-EMRI-o83 s2.2/10: `HttpSenkronAgi` 401 aldiginda BUNU cagirir. Basariliysa
  /// TRUE (istek TEKRARLANMALI). Basarisizsa (s2.2/11) oturum DUSER (`oturum.value
  /// = null`) -- SenkronDongusu'nun kendi 401 dalinda HICBIR DEGISIKLIK YOK, kuyruk
  /// bu yuzden KORUNUR (o kod bu yontemi hic bilmez).
  Future<bool> yenile() async {
    if (_yenilemeSurmekte) {
      return false;
    }
    final mevcut = oturum.value;
    if (mevcut == null) {
      return false;
    }
    _yenilemeSurmekte = true;
    try {
      final sonuc = await _agi.yenile(mevcut.yenilemeJetonu);
      if (sonuc is AuthBasarili) {
        final yeni = KimlikDurumu(
          erisimJetonu: sonuc.erisimJetonu,
          yenilemeJetonu: sonuc.yenilemeJetonu,
          kullaniciId: sonuc.kullaniciId,
        );
        await _depo.yaz(yeni);
        oturum.value = yeni;
        return true;
      }
      await _depo.temizle();
      oturum.value = null;
      return false;
    } finally {
      _yenilemeSurmekte = false;
    }
  }

  Future<String?> gecerliErisimJetonuAl() async => oturum.value?.erisimJetonu;

  Future<void> cikisYap() async {
    final mevcut = oturum.value;
    await _depo.temizle();
    oturum.value = null;
    if (mevcut != null) {
      unawaited(_agi.cikisYap(mevcut.yenilemeJetonu));
    }
  }
}

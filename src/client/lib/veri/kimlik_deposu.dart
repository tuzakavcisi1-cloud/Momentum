import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// IS-EMRI-o83 s2.2/9-10: yerelde saklanan oturum. `kullaniciId`, `ayarlari_hazirla.dart`taki
/// `ezme` parametresine AYNEN gecer (s2.3, mevcut mekanizma yeniden kullanilir).
class KimlikDurumu {
  final String erisimJetonu;
  final String yenilemeJetonu;
  final String kullaniciId;

  const KimlikDurumu({
    required this.erisimJetonu,
    required this.yenilemeJetonu,
    required this.kullaniciId,
  });
}

abstract class KimlikDeposu {
  Future<KimlikDurumu?> oku();

  Future<void> yaz(KimlikDurumu durum);

  Future<void> temizle();
}

/// `flutter_secure_storage` sarmalayicisi (s2.2/9: Android'de EncryptedSharedPreferences).
/// YENI BAGIMLILIK -- lisans+CVE kapilari kosuldu, KANIT/o83/05-06.
class GuvenliKimlikDeposu implements KimlikDeposu {
  static const String _erisimAnahtari = 'momentum_erisim_jetonu';
  static const String _yenilemeAnahtari = 'momentum_yenileme_jetonu';
  static const String _kullaniciAnahtari = 'momentum_kullanici_id';

  final FlutterSecureStorage _depo;

  // OLCULDU (17 Agu 2026): is emri s2.2/9 "Android: EncryptedSharedPreferences"
  // diyor ama pub'dan cozulen 11.0.0'da `AndroidOptions.encryptedSharedPreferences`
  // parametresi YOK -- o surumun VARSAYILAN semasi ESKI EncryptedSharedPreferences
  // yaklasimini AES-GCM + RSA-KeyStore sarmalamasiyla degistirdi (paketin kendi
  // dokumantasyonu: "strong security ... No biometric authentication required").
  // Bu es-degeri (ya da ustu) bir guvenlik seviyesidir; `AndroidOptions()`
  // varsayilani BILEREK degistirilmez.
  GuvenliKimlikDeposu({FlutterSecureStorage? depo})
    : _depo =
          depo ?? const FlutterSecureStorage(aOptions: AndroidOptions());

  @override
  Future<KimlikDurumu?> oku() async {
    final erisim = await _depo.read(key: _erisimAnahtari);
    final yenileme = await _depo.read(key: _yenilemeAnahtari);
    final kullanici = await _depo.read(key: _kullaniciAnahtari);
    if (erisim == null || yenileme == null || kullanici == null) {
      return null;
    }
    return KimlikDurumu(
      erisimJetonu: erisim,
      yenilemeJetonu: yenileme,
      kullaniciId: kullanici,
    );
  }

  @override
  Future<void> yaz(KimlikDurumu durum) async {
    await _depo.write(key: _erisimAnahtari, value: durum.erisimJetonu);
    await _depo.write(key: _yenilemeAnahtari, value: durum.yenilemeJetonu);
    await _depo.write(key: _kullaniciAnahtari, value: durum.kullaniciId);
  }

  @override
  Future<void> temizle() async {
    await _depo.delete(key: _erisimAnahtari);
    await _depo.delete(key: _yenilemeAnahtari);
    await _depo.delete(key: _kullaniciAnahtari);
  }
}

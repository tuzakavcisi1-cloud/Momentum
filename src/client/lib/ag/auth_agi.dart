/// IS-EMRI-o83 s2.2/8: `/v1/auth/{register,login,refresh}` tasima katmani soyutlamasi --
/// `senkron_agi.dart`nin AYNI deseni (sonuc siniflandirmasi HTTP durum kodu YOKLUGUNA dayanir).
sealed class AuthSonucu {
  const AuthSonucu();
}

class AuthBasarili extends AuthSonucu {
  final String erisimJetonu;
  final String yenilemeJetonu;
  final String kullaniciId;

  const AuthBasarili({
    required this.erisimJetonu,
    required this.yenilemeJetonu,
    required this.kullaniciId,
  });
}

/// HTTP durum kodu 200/201 DISINDA (401 yanlis bilgi, 409 eposta kullanimda, 400 gecersiz govde, 5xx).
class AuthHttpHatasi extends AuthSonucu {
  final int durumKodu;

  const AuthHttpHatasi(this.durumKodu);
}

class AuthAgHatasi extends AuthSonucu {
  final Object neden;

  const AuthAgHatasi(this.neden);
}

abstract class AuthAgi {
  Future<AuthSonucu> kayitOl(String eposta, String sifre);

  Future<AuthSonucu> girisYap(String eposta, String sifre);

  Future<AuthSonucu> yenile(String yenilemeJetonu);

  /// En-iyi-caba (best-effort) -- cagiran taraf yerel oturumu HER HALUKARDA
  /// temizler, bu cagrinin basarisi/basarisizligi kullanici akisini etkilemez.
  Future<void> cikisYap(String yenilemeJetonu);
}

// ignore_for_file: prefer_initializing_formals -- `senkron_dongusu.dart:1`
// ile AYNI gerekce: alanlar bilerek PRIVATE (`_turCalistir`), yapici
// parametresi PUBLIC adlandirilmis (`turCalistir`); `this._turCalistir`
// parametre adini da private yapip disaridan adlandirilmis argumanla
// cagirmayi imkansizlastirirdi.

import 'dart:async';
import 'dart:math';

/// GOREV-A11 (K116) `D-A11-1`/`D-A11-2`/`D-A11-5`/`D-A11-6`: kuyrukta bekleyen
/// satır varken başarısız bir İTME turunu tavanlı geri çekilmeyle yeniden
/// dener. `D0` daraltmasının TEK istisnası budur -- ÇEKMEYE genişlemez ve
/// hiçbir koşulda `cekmeTuruCalistir()` çağırmaz.
///
/// `D-A11-5` PAZARLIKSIZ: bu sınıf `Y1` (yoklama-yasagi-kapisi.py) beyaz
/// listesine YALNIZ (`itme_yeniden_deneme.dart`, `ItmeYenidenDeneme`) çifti
/// olarak girer -- `SenkronDongusu` GİRMEZ (yoksa senkron çekirdeğinin
/// tamamı muaf olurdu). O sembolde bile `turCalistir` DIŞINDA hiçbir şey
/// (özellikle `cekmeTuruCalistir`/`SenkronAgi`/`_yuvarlakDongusu`) izinli
/// değildir.
///
/// `D-A11-6`: planlama kararı ÇAĞIRANDAN yapılmaz -- `SenkronDongusu` hata
/// sınıfını `_httpHatasiIsle` içinde bilir ve orada `planla()`/`sifirla()`
/// çağrılır; bu sınıf yalnız ZAMANLAMA mekanizmasıdır, hata sınıflandırması
/// yapmaz.
class ItmeYenidenDeneme {
  // D-A11-2/1: 2s -> 5s -> 15s -> 30s -> 60s, altıncıdan sonra 60s'de sabit.
  static const List<Duration> _cizelge = [
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(seconds: 60),
  ];

  final Future<void> Function() _turCalistir;
  final Random _rastgele;

  Timer? _zamanlayici;
  int _indeks = 0;

  /// [signalr_json_sinyal.dart:49,68-78] ile AYNI, kabul edilmiş desen:
  /// `Random` enjekte edilebilir -- test seed sabitleyip KESİN eşitlik
  /// ölçsün, pencere/tolerans değil. Üretimde her zaman `null` ⇒ gerçek
  /// `Random()`.
  ItmeYenidenDeneme({required Future<void> Function() turCalistir, Random? rastgele})
    : _turCalistir = turCalistir,
      _rastgele = rastgele ?? Random();

  /// D-A11-2/2 PAZARLIKSIZ: aynı anda EN FAZLA bir bekleyen zamanlayıcı --
  /// var olanı iptal edip YENİDEN kurar (bekleyen sayısı asla 2 olmaz).
  void planla() {
    _zamanlayici?.cancel();
    final indeks = min(_indeks, _cizelge.length - 1);
    final taban = _cizelge[indeks];
    _indeks++;
    final jitterCarpani = 1 + (_rastgele.nextDouble() * 0.4 - 0.2); // +-%20
    _zamanlayici = Timer(taban * jitterCarpani, () {
      _zamanlayici = null;
      unawaited(_turCalistir());
    });
  }

  /// D-A11-2/3: çizelge SIFIRLANIR -- başarılı itme VEYA yeni yerel yazma
  /// (taze kullanıcı niyeti) çağırır. Bekleyen zamanlayıcı varsa iptal
  /// edilir; bir sonraki `planla()` yeniden 2 s'den başlar.
  void sifirla() {
    _zamanlayici?.cancel();
    _zamanlayici = null;
    _indeks = 0;
  }

  /// D-A11-2/4 (DURMA) + G22/i: bekleyen zamanlayıcıyı iptal eder, çizelgeyi
  /// SIFIRLAMAZ (`sifirla()`'dan farkı budur -- uygulama kapanırken indeksin
  /// anlamı yoktur). [SINIR, GOREV §9/3] üretimde bunu çağıran bir yaşam
  /// döngüsü kancası YOK; bugün yalnız testte anlamlıdır.
  void durdur() {
    _zamanlayici?.cancel();
    _zamanlayici = null;
  }

  /// Test-görünür: bekleyen bir yeniden deneme var mı.
  bool get beklemedeMi => _zamanlayici != null;
}

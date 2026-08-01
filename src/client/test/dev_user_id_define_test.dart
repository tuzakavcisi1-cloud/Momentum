import 'package:client/main.dart' show devUserIdEzmesi;
import 'package:flutter_test/flutter_test.dart';

/// G20 -- `--dart-define=DEV_USER_ID` boru hattinin GERCEKTEN bagli oldugunu
/// olcer. Bu test KANONIK anahtari KENDI okur (urun kodundan BAGIMSIZ) ve
/// urunun `devUserIdEzmesi` sabitiyle karsilastirir. Anahtar adi urunde
/// yanlis yazilsaydi (`DEV_USERID`), `devUserIdEzmesi` HER ZAMAN bos kalirdi
/// ve bu test define VERILDIGINDE (G20/a) ayrisip KIRMIZI yanardi;
/// define VERILMEDEN (G20/b) ikisi de bos oldugu icin YESIL kalir.
void main() {
  test('DEV_USER_ID define, urunun devUserIdEzmesi sabitiyle AYNI degeri tasir', () {
    const String testinKendiOkudugu = String.fromEnvironment('DEV_USER_ID');
    // ignore: avoid_print
    print('G20-KANIT testinKendiOkudugu=$testinKendiOkudugu '
        'urunDevUserIdEzmesi=$devUserIdEzmesi');
    expect(devUserIdEzmesi, testinKendiOkudugu);
  });
}

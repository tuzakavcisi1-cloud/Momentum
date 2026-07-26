import 'package:flutter/material.dart';

/// DESIGN.md SS1 (donmus kimlik 534DFF68) ile birebir tutulan token katmani.
/// Ham deger YALNIZ bu dosyada tasinir -- D2 taramasindan muaf (DESIGN.md SS9).
/// Renk sembolleri Theme.of(context).brightness uzerinden acik/koyu cozer;
/// bu erisimden yalniz bu dosya ve tema.dart muaftir (D5, GOREV-slice-3b SS3 T3).

class MRenk {
  MRenk._();

  static Color _coz(BuildContext context, Color acik, Color koyu) {
    return Theme.of(context).brightness == Brightness.dark ? koyu : acik;
  }

  static Color yuzey(BuildContext context) =>
      _coz(context, const Color(0xFFFFFFFF), const Color(0xFF0F1319));

  static Color yuzeyIkincil(BuildContext context) =>
      _coz(context, const Color(0xFFF3F4F6), const Color(0xFF181D25));

  static Color metin(BuildContext context) =>
      _coz(context, const Color(0xFF14181F), const Color(0xFFE8EBF0));

  static Color metinIkincil(BuildContext context) =>
      _coz(context, const Color(0xFF525C6B), const Color(0xFFA2ADBC));

  static Color birincil(BuildContext context) =>
      _coz(context, const Color(0xFF1B4FC4), const Color(0xFF8FB4FF));

  static Color uzeriBirincil(BuildContext context) =>
      _coz(context, const Color(0xFFFFFFFF), const Color(0xFF0F1319));

  static Color tehlike(BuildContext context) =>
      _coz(context, const Color(0xFFA4231C), const Color(0xFFFF8F87));

  static Color cevrimdisi(BuildContext context) =>
      _coz(context, const Color(0xFF7A5200), const Color(0xFFF0C24B));

  static Color ayirici(BuildContext context) =>
      _coz(context, const Color(0xFFDDE1E7), const Color(0xFF2A313B));

  static Color kenarlikEtkilesim(BuildContext context) =>
      _coz(context, const Color(0xFF6E7783), const Color(0xFF8B94A2));

  // NICE -- DESIGN.md SS1.1 koyu tema tablosu bu ikisini icermiyor (olculmedi);
  // ilk dilimde kullanilmadiklari icin uydurulmus koyu deger yazilmaz.
  static Color basari(BuildContext context) => const Color(0xFF1B6B3A);

  static Color uyari(BuildContext context) => const Color(0xFF8A5A00);
}

class MTipo {
  MTipo._();

  static const TextStyle baslikL = TextStyle(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle govdeM = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle etiketS = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
  );

  // NICE
  static const TextStyle baslikXl = TextStyle(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
  );
}

class MBosluk {
  MBosluk._();

  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;

  // NICE
  static const double xl = 32;
}

class MRadius {
  MRadius._();

  static const double s = 8;
  static const double m = 12;

  // NICE
  static const double tam = 999;
}

class MHareket {
  MHareket._();

  static const Duration hizli = Duration(milliseconds: 120);
  static const Duration standart = Duration(milliseconds: 200);

  // NICE
  static const Duration yavas = Duration(milliseconds: 320);
}

class MOlcu {
  MOlcu._();

  static const double dokunmaHedefi = 48;
  static const double ikon = 24;
  static const double odakKalinlik = 2;

  // NICE
  static const double ikonBuyuk = 32;
}

class MYukselti {
  MYukselti._();

  // NICE
  static const double kart = 1;
}

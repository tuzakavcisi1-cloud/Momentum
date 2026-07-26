import 'package:flutter/material.dart';

import 'tokens.dart';

/// T6 -- MomentumTema: widget DEGIL, tek ThemeData kaynagi (acik/koyu).
/// D5 muafiyeti tokens.dart ile birlikte bu dosyayi da kapsar: ThemeData
/// insa edilirken henuz bir BuildContext yoktur, bu yuzden MRenk'in
/// Brightness-tabanli ("Icin" ekli) sürümleri kullanilir.
class MomentumTema {
  MomentumTema._();

  static ThemeData olustur(Brightness parlaklik) {
    final renkSemasi = ColorScheme(
      brightness: parlaklik,
      primary: MRenk.birincilIcin(parlaklik),
      onPrimary: MRenk.uzeriBirincilIcin(parlaklik),
      secondary: MRenk.birincilIcin(parlaklik),
      onSecondary: MRenk.uzeriBirincilIcin(parlaklik),
      error: MRenk.tehlikeIcin(parlaklik),
      onError: MRenk.uzeriBirincilIcin(parlaklik),
      surface: MRenk.yuzeyIcin(parlaklik),
      onSurface: MRenk.metinIcin(parlaklik),
    );

    final metinRengi = MRenk.metinIcin(parlaklik);
    final metinIkincilRengi = MRenk.metinIkincilIcin(parlaklik);

    return ThemeData(
      brightness: parlaklik,
      colorScheme: renkSemasi,
      scaffoldBackgroundColor: MRenk.yuzeyIcin(parlaklik),
      dividerColor: MRenk.ayiriciIcin(parlaklik),
      textTheme: TextTheme(
        titleLarge: MTipo.baslikL.copyWith(color: metinRengi),
        bodyMedium: MTipo.govdeM.copyWith(color: metinRengi),
        labelSmall: MTipo.etiketS.copyWith(color: metinIkincilRengi),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}

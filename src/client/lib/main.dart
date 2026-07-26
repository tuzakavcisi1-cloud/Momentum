import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'design/tema.dart';
import 'sunum/gorev_listesi_ekrani.dart';
import 'veri/gorev_deposu.dart';
import 'veri/veritabani.dart';
import 'vitrin/durum_vitrini.dart';

void main() {
  // F7: flutter_driver bayrak korumali -- agac sarsimi bunu surum
  // derlemesinde dusurmelidir (kriter 13'te olculur).
  if (const bool.fromEnvironment('ENABLE_FLUTTER_DRIVER')) {
    enableFlutterDriverExtension();
  }
  runApp(const MomentumUygulamasi());
}

class MomentumUygulamasi extends StatelessWidget {
  const MomentumUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MomentumTema.olustur(Brightness.light),
      darkTheme: MomentumTema.olustur(Brightness.dark),
      // F5: --dart-define=DURUM_VITRINI=true ile durum vitrini acilir.
      home: const bool.fromEnvironment('DURUM_VITRINI')
          ? const DurumVitrini()
          : GorevListesiEkrani(depo: _uretimDeposuOlustur()),
    );
  }
}

GorevDeposu _uretimDeposuOlustur() {
  return DriftGorevDeposu(
    Veritabani(),
    saat: () => DateTime.now().toUtc(),
    idUret: uretimIdUret,
  );
}

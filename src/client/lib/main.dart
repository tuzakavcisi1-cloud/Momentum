import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'ag/http_senkron_agi.dart';
import 'design/tema.dart';
import 'sunum/gorev_listesi_ekrani.dart';
import 'veri/ayarlar_deposu.dart';
import 'veri/gorev_deposu.dart';
import 'veri/hlc.dart';
import 'veri/senkron_dongusu.dart';
import 'veri/veritabani.dart';
import 'vitrin/durum_vitrini.dart';

/// Android emulator'dan host makinenin localhost'una ozel takma ad (real
/// cihaz/masaustu/web icin --dart-define=SENKRON_SUNUCU_URL ile ezilir).
/// K41: bu dilim gelistirme-ortami olcum iskelesidir (D0), gercek sunucu
/// kesfi/yapilandirmasi kapsam disidir.
const String _senkronSunucuUrl = String.fromEnvironment(
  'SENKRON_SUNUCU_URL',
  defaultValue: 'http://10.0.2.2:5298',
);

void main() async {
  // F7: flutter_driver bayrak korumali -- agac sarsimi bunu surum
  // derlemesinde dusurmelidir (kriter 13'te olculur).
  if (const bool.fromEnvironment('ENABLE_FLUTTER_DRIVER')) {
    enableFlutterDriverExtension();
  }
  // F5: durum vitrini gercek DB/ayarlar bootstrap'ina hic ihtiyac duymaz --
  // "olu tuzagi engeller" gerekcesi burada da korunur (bkz. durum_vitrini.dart).
  GorevDeposu? depo;
  if (!const bool.fromEnvironment('DURUM_VITRINI')) {
    final kurulum = await _uretimKurulumOlustur();
    depo = kurulum.depo;
    // D8/2 PAZARLIKSIZ: acilista `gonderildi` olan TUM satirlar `bekliyor`e
    // doner (bir onceki koşum ucusun ortasinda cokmus olabilir).
    await kurulum.dongu.gonderildiKurtar();
    // T6: zamanlayici tetikli senkron -- D4'un mutex'i cakisan tetikleri
    // (zamanlayici + baska bir tetik) zaten tek tura indirger.
    Timer.periodic(
      const Duration(seconds: 15),
      (_) => kurulum.dongu.turCalistir(),
    );
    unawaited(kurulum.dongu.turCalistir());
  }
  runApp(MomentumUygulamasi(depo: depo));
}

class MomentumUygulamasi extends StatelessWidget {
  final GorevDeposu? depo;

  const MomentumUygulamasi({super.key, required this.depo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MomentumTema.olustur(Brightness.light),
      darkTheme: MomentumTema.olustur(Brightness.dark),
      // F5: --dart-define=DURUM_VITRINI=true ile durum vitrini acilir.
      home: depo == null
          ? const DurumVitrini()
          : GorevListesiEkrani(depo: depo!),
    );
  }
}

class _UretimKurulumu {
  final GorevDeposu depo;
  final SenkronDongusu dongu;
  const _UretimKurulumu(this.depo, this.dongu);
}

/// GOREV-slice-3c T3/T4/T5/T6: ayarlar (clientId/devUserId) once yuklenir/
/// uretilir; HLC ureteci VE senkron dongusu ayni ornegi (`hlc`) PAYLASIR --
/// biri yeni op damgalar (T4), digeri sunucu yanitiyla birlestirir (D3).
Future<_UretimKurulumu> _uretimKurulumOlustur() async {
  final db = Veritabani();
  final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
  final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
  final hlc = HlcUretici(
    simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch,
    clientId: ayarlar.clientId,
    sonWall: ayarlar.sonWall,
    sonCounter: ayarlar.sonCounter,
  );

  final depo = DriftGorevDeposu(
    db,
    saat: () => DateTime.now().toUtc(),
    idUret: uretimIdUret,
    hlc: hlc,
    ayarlarDeposu: ayarlarDeposu,
    actorId: ayarlar.devUserId,
  );

  final dongu = SenkronDongusu(
    db: db,
    agi: HttpSenkronAgi(
      senkronUcNoktasi: Uri.parse('$_senkronSunucuUrl/v1/sync'),
      actorId: ayarlar.devUserId,
    ),
    ayarlarDeposu: ayarlarDeposu,
    hlc: hlc,
    clientId: ayarlar.clientId,
    baslangicCursorJson: ayarlar.nextCursorJson,
  );

  return _UretimKurulumu(depo, dongu);
}

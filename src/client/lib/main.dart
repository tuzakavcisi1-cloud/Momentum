import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'ag/gercek_zamanli_sinyal.dart';
import 'ag/http_senkron_agi.dart';
import 'ag/signalr_json_sinyal.dart';
import 'design/tema.dart';
import 'sunum/gorev_listesi_ekrani.dart';
import 'veri/ayarlar_deposu.dart';
import 'veri/ayarlari_hazirla.dart';
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

/// GOREV-A10 Y3: derleme-zamani `DEV_USER_ID` ezmesi -- iki cihazi ayni
/// kullanici yapmanin yolu (bugune kadar `devUserId` her kurulumda
/// rastgeleydi). Uygulamasi ayarlari_hazirla.dart'taki fonksiyona devredilir.
const String devUserIdEzmesi = String.fromEnvironment('DEV_USER_ID');

void main() async {
  // F7: flutter_driver bayrak korumali -- agac sarsimi bunu surum
  // derlemesinde dusurmelidir (kriter 13'te olculur).
  if (const bool.fromEnvironment('ENABLE_FLUTTER_DRIVER')) {
    enableFlutterDriverExtension();
  }
  // F5: durum vitrini gercek DB/ayarlar bootstrap'ina hic ihtiyac duymaz --
  // "olu tuzagi engeller" gerekcesi burada da korunur (bkz. durum_vitrini.dart).
  GorevDeposu? depo;
  SenkronDongusu? dongu;
  if (!const bool.fromEnvironment('DURUM_VITRINI')) {
    final kurulum = await _uretimKurulumOlustur();
    depo = kurulum.depo;
    dongu = kurulum.dongu;
    // D8/2 PAZARLIKSIZ: acilista `gonderildi` olan TUM satirlar `bekliyor`e
    // doner (bir onceki koşum ucusun ortasinda cokmus olabilir).
    await kurulum.dongu.gonderildiKurtar();
    // slice-3d D0: PERIYODIK YOKLAMA YASAK -- Timer.periodic ile cekmek
    // KALDIRILDI. Acilista once bekleyen (varsa) itilir, hemen ardindan
    // KAPALI LISTE'nin 1. tetikleyicisi (acilis cekme turu) koşulur; ikisi
    // AYNI tek-uçuş kilidini paylastigi icin cekme turu dogal olarak K3
    // bayragiyla ertelenip itme bitince BIR KEZ koşar.
    unawaited(kurulum.dongu.turCalistir());
    unawaited(kurulum.dongu.cekmeTuruCalistir());
  }
  runApp(MomentumUygulamasi(depo: depo, dongu: dongu));
}

class MomentumUygulamasi extends StatelessWidget {
  final GorevDeposu? depo;
  final SenkronDongusu? dongu;

  const MomentumUygulamasi({super.key, required this.depo, this.dongu});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MomentumTema.olustur(Brightness.light),
      darkTheme: MomentumTema.olustur(Brightness.dark),
      // F5: --dart-define=DURUM_VITRINI=true ile durum vitrini acilir.
      home: depo == null
          ? const DurumVitrini()
          : GorevListesiEkrani(depo: depo!, onYenile: dongu?.cekmeTuruCalistir),
    );
  }
}

class _UretimKurulumu {
  final GorevDeposu depo;
  final SenkronDongusu dongu;
  // GOREV-slice-3e-G12 T2: sinyal artik BURADA tutulur -- sahipsiz kalirsa
  // `durdur()`u cagiracak kimse olmaz (K79/0 ikinci bulgu).
  final GercekZamanliSinyal sinyal;
  const _UretimKurulumu(this.depo, this.dongu, this.sinyal);
}

/// GOREV-slice-3c T3/T4/T5/T6: ayarlar (clientId/devUserId) once yuklenir/
/// uretilir; HLC ureteci VE senkron dongusu ayni ornegi (`hlc`) PAYLASIR --
/// biri yeni op damgalar (T4), digeri sunucu yanitiyla birlestirir (D3).
Future<_UretimKurulumu> _uretimKurulumOlustur() async {
  final db = Veritabani();
  final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
  final ayarlar = await ayarlariHazirla(db, ayarlarDeposu, ezme: devUserIdEzmesi);
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
    devUserId: ayarlar.devUserId,
    baslangicCursorJson: ayarlar.nextCursorJson,
  );

  // GOREV-slice-3e T3: gercek zamanli sinyal -- K77/5 dogrudan esleme, EK
  // debounce/zamanlayici/kuyruk YOK. `_senkronSunucuUrl`den YENIDEN turetilir,
  // SENKRON_SUNUCU_URL icin IKINCI bir derleme-zamani ortam okumasi EKLENMEZ.
  final sinyal = SignalrJsonSinyal(
    sunucuTabanUrl: _senkronSunucuUrl,
    actorId: ayarlar.devUserId,
  );
  sinyal.olaylar.listen((_) => unawaited(dongu.cekmeTuruCalistir()));
  unawaited(sinyal.baslat());

  return _UretimKurulumu(depo, dongu, sinyal);
}

import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../veri/gorev_deposu.dart';
import 'bos_durum.dart';
import 'gorev_ekle_alani.dart';
import 'gorev_satiri.dart';
import 'hata_durumu.dart';
import 'senkron_rozeti.dart';
import 'yukleme_durumu.dart';

/// SS3.1 -- tek vitrin ekrani (gercek, akis-tabanli ekran; durum_vitrini.dart
/// ile KARISTIRILMAZ, o statik/deterministik bir gosterimdir).
///
/// F5 PAZARLIKSIZ: G5 bu ekranin uzerinde de kosar (bos * yerel * hata).
/// GOREV-slice-3c T6 ile birlikte gercek veri artik kuyrukta/senkronize/
/// cevrimdisi/cakisma da uretebilir (senkron dongusu); [rozetDikisi] (D5)
/// `Gorevler.senkronDurumu` dizesini `GorevSatiri`nin iki parametresine
/// cevirir.
///
/// GOREV-slice-3c D5: `senkronDurumu` -> `(SenkronDurumTuru, cakismaVarMi)`.
/// Taninmayan dize CHECK kisitinin anlamini yok eder (sessizce 'yerel'e
/// dusmek YASAK) -- bu yuzden FIRLATIR.
(SenkronDurumTuru, bool) rozetDikisi(String senkronDurumu) {
  switch (senkronDurumu) {
    case 'yerel':
      return (SenkronDurumTuru.yerel, false);
    case 'kuyrukta':
      return (SenkronDurumTuru.kuyrukta, false);
    case 'senkronize':
      return (SenkronDurumTuru.senkronize, false);
    case 'cevrimdisi':
      return (SenkronDurumTuru.cevrimdisi, false);
    case 'cakisma':
      return (SenkronDurumTuru.yerel, true);
    default:
      throw ArgumentError('Taninmayan senkronDurumu: $senkronDurumu');
  }
}
class GorevListesiEkrani extends StatefulWidget {
  final GorevDeposu depo;
  // slice-3d D0: KAPALI LISTE'deki dort tetikleyiciden biri -- "kullanici
  // elle yenilediginde bir cekme turu". `null` ise (mevcut testler/durum
  // vitrini) yenile dugmesi HIC gosterilmez -- geriye donuk uyumlu.
  final Future<void> Function()? onYenile;

  const GorevListesiEkrani({super.key, required this.depo, this.onYenile});

  @override
  State<GorevListesiEkrani> createState() => _GorevListesiEkraniState();
}

class _GorevListesiEkraniState extends State<GorevListesiEkrani> {
  late Stream<List<Gorev>> _akis;

  @override
  void initState() {
    super.initState();
    _akis = widget.depo.gorevlerGorunur();
  }

  void _yenidenDene() {
    setState(() {
      _akis = widget.depo.gorevlerGorunur();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MRenk.yuzey(context),
      appBar: widget.onYenile == null
          ? null
          : AppBar(
              backgroundColor: MRenk.yuzey(context),
              elevation: 0,
              actions: [
                IconButton(
                  key: const ValueKey('elle_yenile_dugmesi'),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Yenile',
                  onPressed: () => widget.onYenile!(),
                ),
              ],
            ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Gorev>>(
                stream: _akis,
                builder: (context, anlik) {
                  if (anlik.hasError) {
                    return HataDurumu(onYenidenDene: _yenidenDene);
                  }
                  if (!anlik.hasData) {
                    return const YuklenmeDurumu();
                  }
                  final gorevler = anlik.data!;
                  if (gorevler.isEmpty) {
                    return const BosDurum();
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: MBosluk.m),
                    itemCount: gorevler.length,
                    itemBuilder: (context, i) {
                      final gorev = gorevler[i];
                      final (senkronDurumu, cakismaVarMi) = rozetDikisi(
                        gorev.senkronDurumu,
                      );
                      return GorevSatiri(
                        key: ValueKey('gorev_satiri_${gorev.id}'),
                        gorev: gorev,
                        onTamamlaDegisti: (deger) => widget.depo
                            .tamamlaGeriAl(gorev.id, tamamlandi: deger),
                        senkronDurumu: senkronDurumu,
                        cakismaVarMi: cakismaVarMi,
                      );
                    },
                  );
                },
              ),
            ),
            GorevEkleAlani(onEkle: widget.depo.ekle),
          ],
        ),
      ),
    );
  }
}

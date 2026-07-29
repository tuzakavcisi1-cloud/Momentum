import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../veri/gorev_deposu.dart';
import 'bos_durum.dart';
import 'gorev_ekle_alani.dart';
import 'gorev_satiri.dart';
import 'hata_durumu.dart';
import 'yukleme_durumu.dart';

/// SS3.1 -- tek vitrin ekrani (gercek, akis-tabanli ekran; durum_vitrini.dart
/// ile KARISTIRILMAZ, o statik/deterministik bir gosterimdir).
///
/// F5 PAZARLIKSIZ: G5 bu ekranin uzerinde de kosar (bos * yerel * hata).
/// GOREV-R10 D5: rozet turetme (`rozetDikisi`) artik `veri/gorev_deposu.dart`
/// katmanindadir -- bu ekran `GorevGorunum.senkronDurumu`/`cakismaVarMi`yi
/// DOGRUDAN okur, kendisi turetme yapmaz (F4 dikisi: widget'lar tasima
/// katmani durumunu gormez).
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
  late Stream<List<GorevGorunum>> _akis;

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
              child: StreamBuilder<List<GorevGorunum>>(
                stream: _akis,
                builder: (context, anlik) {
                  if (anlik.hasError) {
                    return HataDurumu(onYenidenDene: _yenidenDene);
                  }
                  if (!anlik.hasData) {
                    return const YuklenmeDurumu();
                  }
                  final gorunumler = anlik.data!;
                  if (gorunumler.isEmpty) {
                    return const BosDurum();
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: MBosluk.m),
                    itemCount: gorunumler.length,
                    itemBuilder: (context, i) {
                      final gorunum = gorunumler[i];
                      return GorevSatiri(
                        key: ValueKey('gorev_satiri_${gorunum.gorev.id}'),
                        gorev: gorunum.gorev,
                        onTamamlaDegisti: (deger) => widget.depo
                            .tamamlaGeriAl(gorunum.gorev.id, tamamlandi: deger),
                        senkronDurumu: gorunum.senkronDurumu,
                        cakismaVarMi: gorunum.cakismaVarMi,
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

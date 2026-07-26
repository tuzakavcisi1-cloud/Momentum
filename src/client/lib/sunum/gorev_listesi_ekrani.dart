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
/// Bu dilimde gercek veri hicbir zaman kuyrukta/senkronize/cevrimdisi/cakisma
/// uretemez (T4'un CHECK kisiti yalniz 'yerel'), bu yuzden bu ekran yalniz
/// o uc alt durumu gosterir; digerleri vitrindedir.
class GorevListesiEkrani extends StatefulWidget {
  final GorevDeposu depo;

  const GorevListesiEkrani({super.key, required this.depo});

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
                      return GorevSatiri(
                        key: ValueKey('gorev_satiri_${gorev.id}'),
                        gorev: gorev,
                        onTamamlaDegisti: (deger) => widget.depo
                            .tamamlaGeriAl(gorev.id, tamamlandi: deger),
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

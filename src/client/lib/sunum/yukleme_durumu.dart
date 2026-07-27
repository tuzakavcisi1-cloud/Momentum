import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../design/metinler.dart';
import '../design/tokens.dart';

/// SS3.1 -- ilk yukleme. Gorunur oldugunda BIR KERELIK semantics duyurusu
/// yapar ("Gorevler yukleniyor", A11Y-7 / DESIGN.md SS4).
class YuklenmeDurumu extends StatefulWidget {
  const YuklenmeDurumu({super.key});

  @override
  State<YuklenmeDurumu> createState() => _YuklenmeDurumuState();
}

class _YuklenmeDurumuState extends State<YuklenmeDurumu> {
  bool _duyuruYapildi = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_duyuruYapildi) return;
    _duyuruYapildi = true;
    SemanticsService.sendAnnouncement(
      View.of(context),
      Metinler.duyuruGorevlerYukleniyor,
      TextDirection.ltr,
    );
  }

  @override
  Widget build(BuildContext context) {
    final azalt = MediaQuery.of(context).disableAnimations;
    return Center(
      child: AnimatedOpacity(
        opacity: 1,
        duration: azalt ? Duration.zero : MHareket.standart,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: MBosluk.m),
            Text(
              Metinler.yukleniyor,
              overflow: TextOverflow.ellipsis,
              style: MTipo.govdeM.copyWith(color: MRenk.metinIkincil(context)),
            ),
          ],
        ),
      ),
    );
  }
}

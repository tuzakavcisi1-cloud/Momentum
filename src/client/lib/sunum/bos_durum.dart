import 'package:flutter/material.dart';

import '../design/metinler.dart';
import '../design/tokens.dart';

/// SS3.1 -- hic gorev yok. Semantics duyurusu YOK (DESIGN.md SS4: "--").
class BosDurum extends StatelessWidget {
  const BosDurum({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(MBosluk.l),
        child: Text(
          Metinler.bosDurum,
          textAlign: TextAlign.center,
          style: MTipo.baslikL.copyWith(color: MRenk.metinIkincil(context)),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../design/metinler.dart';
import '../design/tokens.dart';

/// SS3.1 -- hic gorev yok. Semantics duyurusu YOK (DESIGN.md SS4: "--").
class BosDurum extends StatelessWidget {
  const BosDurum({super.key});

  /// GOREV-A8 [K90/spec SS4/Y2]: OLCULDU (KANIT/A8/00-OLCUM.txt), izgaranin
  /// en kotu noktasinda (320dp x 2.0x) -- ellipsis TEK BASINA metni fiilen
  /// tek satira indirdigi icin (B3) bu deger olmadan kayip SESSIZDI.
  static const int kBosDurumMaxSatir = 6;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(MBosluk.l),
        child: Text(
          Metinler.bosDurum,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: kBosDurumMaxSatir,
          style: MTipo.baslikL.copyWith(color: MRenk.metinIkincil(context)),
        ),
      ),
    );
  }
}

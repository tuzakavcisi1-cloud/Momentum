import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../veri/gorev_deposu.dart';
import 'cakisma_rozeti.dart';
import 'senkron_rozeti.dart';

/// SS3.1 -- gorev: onay kutusu + baslik + senkron rozeti.
///
/// PAZARLIKSIZ DOKUNMA SINIRI (T6): bu widget'in kendisi onTap TASIMAZ --
/// dokunulabilir tek alanlar Checkbox ve (varsa) CakismaRozeti'nin kendi
/// GestureDetector'idir. Gerekce: dokunulabilir alan satir olsaydi metin
/// semantics dugumune girer ve M7 isirmazdi.
class GorevSatiri extends StatelessWidget {
  final Gorev gorev;
  final ValueChanged<bool> onTamamlaDegisti;
  final SenkronDurumTuru senkronDurumu;
  final bool cakismaVarMi;

  const GorevSatiri({
    super.key,
    required this.gorev,
    required this.onTamamlaDegisti,
    this.senkronDurumu = SenkronDurumTuru.yerel,
    this.cakismaVarMi = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: MRenk.ayirici(context)),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: MBosluk.xs),
      child: Row(
        children: [
          Semantics(
            label: gorev.baslik,
            child: Checkbox(
              value: gorev.tamamlandi,
              onChanged: (deger) => onTamamlaDegisti(deger ?? false),
            ),
          ),
          SizedBox(width: MBosluk.s),
          Expanded(
            child: Text(
              gorev.baslik,
              style: MTipo.govdeM.copyWith(
                color: MRenk.metin(context),
                decoration: gorev.tamamlandi
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: MBosluk.s),
          if (cakismaVarMi)
            const CakismaRozeti()
          else
            Flexible(child: SenkronRozeti(durum: senkronDurumu)),
        ],
      ),
    );
  }
}

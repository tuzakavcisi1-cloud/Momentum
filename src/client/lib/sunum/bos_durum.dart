import 'package:flutter/material.dart';

import '../design/metinler.dart';
import '../design/tokens.dart';

/// SS3.1 -- hic gorev yok. Semantics duyurusu YOK (DESIGN.md SS4: "--").
///
/// ODEV.md §4(a) ARAMA DILIMI: ikinci varyant [BosDurum.eslesmeYok] --
/// gorevler VAR ama suzgecler hicbirini gecirmiyor. AYRI dizge ve AYRI eylem
/// tasir; `const BosDurum()` davranisi ZERRE DEGISMEDI (mevcut vitrin/a11y
/// testleri etkilenmez).
class BosDurum extends StatelessWidget {
  /// `null` = birinci varyant (hic gorev yok). Dolu ise ikinci varyant:
  /// aramayi VE cip secimini tek dokunusta sifirlar.
  final VoidCallback? onSuzgecleriTemizle;

  const BosDurum({super.key}) : onSuzgecleriTemizle = null;

  const BosDurum.eslesmeYok({
    super.key,
    required VoidCallback this.onSuzgecleriTemizle,
  });

  /// GOREV-A8 [K90/spec SS4/Y2]: OLCULDU (KANIT/A8/00-OLCUM.txt), izgaranin
  /// en kotu noktasinda (320dp x 2.0x) -- ellipsis TEK BASINA metni fiilen
  /// tek satira indirdigi icin (B3) bu deger olmadan kayip SESSIZDI.
  static const int kBosDurumMaxSatir = 6;

  Widget _metin(BuildContext context, String dize) => Text(
    dize,
    textAlign: TextAlign.center,
    overflow: TextOverflow.ellipsis,
    maxLines: kBosDurumMaxSatir,
    style: MTipo.baslikL.copyWith(color: MRenk.metinIkincil(context)),
  );

  @override
  Widget build(BuildContext context) {
    final temizle = onSuzgecleriTemizle;
    // 🔴 BIRINCI VARYANT: agac BIREBIR ESKISIDIR (Center > Padding > Text).
    // Ikinci varyant icin `Column` sarmalayip ikisini BIRLESTIRMEK, mevcut
    // A8 tasma olcumunu ve vitrin testlerini gorunmez bicimde kaydirirdi.
    if (temizle == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(MBosluk.l),
          child: _metin(context, Metinler.bosDurum),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: EdgeInsets.all(MBosluk.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _metin(context, Metinler.aramaEslesmeYok),
            SizedBox(height: MBosluk.m),
            // A11Y-3: METIN tasiyan buton (ikon-yalniz DEGIL).
            TextButton(
              key: const ValueKey('suzgecleri_temizle_dugmesi'),
              onPressed: temizle,
              // R1 (a11y_statik_tasma): buton etiketi de KORUNAKLI olmali --
              // 2.0x olcekte sessiz kirpma buton metninde de sessizdir.
              child: Text(
                Metinler.suzgecleriTemizle,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

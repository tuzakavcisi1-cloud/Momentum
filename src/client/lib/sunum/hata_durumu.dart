import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../design/metinler.dart';
import '../design/tokens.dart';

/// SS3.1 -- yerel DB / ag hatasi + yeniden dene. Gorunur oldugunda BIR
/// KERELIK semantics duyurusu yapar ("Hata", A11Y-7 / DESIGN.md SS4).
class HataDurumu extends StatefulWidget {
  final VoidCallback onYenidenDene;

  const HataDurumu({super.key, required this.onYenidenDene});

  @override
  State<HataDurumu> createState() => _HataDurumuState();
}

class _HataDurumuState extends State<HataDurumu> {
  /// GOREV-A8 [K90/spec SS4/Y3]: OLCULDU (KANIT/A8/00-OLCUM.txt), izgaranin
  /// en kotu noktasinda (320dp x 2.0x).
  static const int kHataDurumuMesajMaxSatir = 4;

  /// GOREV-A8 [K90/spec SS4/Y4]: OLCULDU (KANIT/A8/00-OLCUM.txt), izgaranin
  /// en kotu noktasinda (320dp x 2.0x) -- TextButton etiketi.
  static const int kYenidenDeneMaxSatir = 2;

  bool _duyuruYapildi = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_duyuruYapildi) return;
    _duyuruYapildi = true;
    SemanticsService.sendAnnouncement(
      View.of(context),
      Metinler.duyuruHata,
      TextDirection.ltr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(MBosluk.m),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: MOlcu.ikon,
              color: MRenk.tehlike(context),
            ),
            SizedBox(height: MBosluk.m),
            Text(
              Metinler.birSeylerTersGitti,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: kHataDurumuMesajMaxSatir,
              style: MTipo.govdeM.copyWith(color: MRenk.tehlike(context)),
            ),
            SizedBox(height: MBosluk.m),
            TextButton(
              onPressed: widget.onYenidenDene,
              child: Text(
                Metinler.yenidenDene,
                overflow: TextOverflow.ellipsis,
                maxLines: kYenidenDeneMaxSatir,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

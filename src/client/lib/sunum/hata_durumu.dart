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
              style: MTipo.govdeM.copyWith(color: MRenk.tehlike(context)),
            ),
            SizedBox(height: MBosluk.m),
            TextButton(
              onPressed: widget.onYenidenDene,
              child: Text(Metinler.yenidenDene, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

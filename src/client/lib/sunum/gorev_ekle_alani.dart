import 'package:flutter/material.dart';

import '../design/metinler.dart';
import '../design/tokens.dart';

/// SS3.1 -- alt sabit giris + ekle dugmesi.
///
/// A11Y-2 (G5): focusedBorder.borderSide.width == MOlcu.odakKalinlik ve
/// rengi == MRenk.birincil(context) -- bu ozellik DOGRUDAN bu widget'in
/// InputDecoration'inda tanimlanir (M15 mutanti bu satiri hedefler).
class GorevEkleAlani extends StatefulWidget {
  final ValueChanged<String> onEkle;

  const GorevEkleAlani({super.key, required this.onEkle});

  @override
  State<GorevEkleAlani> createState() => _GorevEkleAlaniState();
}

class _GorevEkleAlaniState extends State<GorevEkleAlani> {
  final _denetleyici = TextEditingController();

  void _gonder() {
    final metin = _denetleyici.text.trim();
    if (metin.isEmpty) return;
    widget.onEkle(metin);
    _denetleyici.clear();
  }

  @override
  void dispose() {
    _denetleyici.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MBosluk.m),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _denetleyici,
              onSubmitted: (_) => _gonder(),
              style: MTipo.govdeM.copyWith(color: MRenk.metin(context)),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MRadius.m),
                  borderSide: BorderSide(
                    color: MRenk.kenarlikEtkilesim(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MRadius.m),
                  borderSide: BorderSide(
                    width: MOlcu.odakKalinlik,
                    color: MRenk.birincil(context),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: MBosluk.s),
          SizedBox(
            width: MOlcu.dokunmaHedefi,
            height: MOlcu.dokunmaHedefi,
            child: Material(
              color: MRenk.birincil(context),
              borderRadius: BorderRadius.circular(MRadius.m),
              child: InkWell(
                borderRadius: BorderRadius.circular(MRadius.m),
                onTap: _gonder,
                child: Semantics(
                  button: true,
                  label: Metinler.ekleDugmesi,
                  child: Icon(Icons.add, color: MRenk.uzeriBirincil(context)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

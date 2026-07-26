import 'package:flutter/material.dart';

import '../design/metinler.dart';
import '../design/tokens.dart';

/// SS3.1 -- sunucu ile cakisma; dokununca cozum sayfasi (yer tutucu) acar.
///
/// PAZARLIKSIZ DOKUNMA SINIRI (T6): bu bilesen KENDI GestureDetector'ini
/// tasir ve gorunur metin dugumunun DISINDADIR; GorevSatiri'nin kendisi
/// onTap tasimaz. Gerekce: dokunulabilir alan satir olsaydi metin semantics
/// dugumune girer ve M7 (Semantics etiketi silme mutanti) isirmazdi.
class CakismaRozeti extends StatelessWidget {
  const CakismaRozeti({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _cozumSayfasiniAc(context),
      child: Semantics(
        label: Metinler.cakismaVar,
        button: true,
        child: Icon(
          Icons.error_outline,
          size: MOlcu.ikon,
          color: MRenk.tehlike(context),
        ),
      ),
    );
  }

  void _cozumSayfasiniAc(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _CakismaCozumSayfasi()),
    );
  }
}

/// Yer tutucu -- gercek cakisma cozumu K42-d adim 3'te gelir (SS2 YOK).
class _CakismaCozumSayfasi extends StatelessWidget {
  const _CakismaCozumSayfasi();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Metinler.duyuruCakismaVar)),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(MBosluk.m),
          child: Text(
            Metinler.cakismaVar,
            style: MTipo.govdeM.copyWith(color: MRenk.metin(context)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

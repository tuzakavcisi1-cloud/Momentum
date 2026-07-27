import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../design/metinler.dart';
import '../design/tokens.dart';

/// SS3.1 -- sunucu ile cakisma; dokununca cozum sayfasi (yer tutucu) acar.
/// Gorunur oldugunda BIR KERELIK semantics duyurusu yapar ("Cakisma var",
/// A11Y-7 / DESIGN.md SS4 -- durum matrisi "cakisma" satiri).
///
/// PAZARLIKSIZ DOKUNMA SINIRI (T6): bu bilesen KENDI GestureDetector'ini
/// tasir ve gorunur metin dugumunun DISINDADIR; GorevSatiri'nin kendisi
/// onTap tasimaz. Gerekce: dokunulabilir alan satir olsaydi metin semantics
/// dugumune girer ve M7 (Semantics etiketi silme mutanti) isirmazdi.
class CakismaRozeti extends StatefulWidget {
  const CakismaRozeti({super.key});

  @override
  State<CakismaRozeti> createState() => _CakismaRozetiState();
}

class _CakismaRozetiState extends State<CakismaRozeti> {
  bool _duyuruYapildi = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_duyuruYapildi) return;
    _duyuruYapildi = true;
    SemanticsService.sendAnnouncement(
      View.of(context),
      Metinler.duyuruCakismaVar,
      TextDirection.ltr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _cozumSayfasiniAc(context),
      child: Semantics(
        label: Metinler.cakismaVar,
        button: true,
        child: Container(
          width: MOlcu.dokunmaHedefi,
          height: MOlcu.dokunmaHedefi,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MRenk.tehlike(context).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(MRadius.s),
          ),
          child: Icon(
            Icons.error_outline,
            size: MOlcu.ikon,
            color: MRenk.tehlike(context),
          ),
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
      appBar: AppBar(
        title: const Text(Metinler.duyuruCakismaVar, overflow: TextOverflow.ellipsis),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(MBosluk.m),
          child: Text(
            Metinler.cakismaVar,
            style: MTipo.govdeM.copyWith(color: MRenk.metin(context)),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

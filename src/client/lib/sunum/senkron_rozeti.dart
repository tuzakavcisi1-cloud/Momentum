import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../design/metinler.dart';
import '../design/tokens.dart';

/// DESIGN.md SS4 durum matrisindeki rozet karsiliklari. 'senkronize' hicbir
/// zaman gercek veriden dogmaz (T4'un CHECK kisiti yalniz 'yerel'e izin
/// verir); bu deger yalniz vitrin/testler icindir.
enum SenkronDurumTuru { yerel, kuyrukta, senkronize, cevrimdisi }

/// SS3.1 -- 4 durum: yerel * kuyrukta * gonderildi(senkronize) * cevrimdisi.
/// senkronize/cevrimdisi durumlari, bu durumla ILK KEZ olusturulduklarinda
/// bir kerelik semantics duyurusu yapar (A11Y-7, DESIGN.md SS4).
class SenkronRozeti extends StatefulWidget {
  final SenkronDurumTuru durum;

  const SenkronRozeti({super.key, required this.durum});

  @override
  State<SenkronRozeti> createState() => _SenkronRozetiState();
}

class _SenkronRozetiState extends State<SenkronRozeti> {
  bool _duyuruYapildi = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_duyuruYapildi) return;
    final duyuru = switch (widget.durum) {
      SenkronDurumTuru.senkronize => Metinler.duyuruSenkronizeEdildi,
      SenkronDurumTuru.cevrimdisi => Metinler.duyuruCevrimdisi,
      _ => null,
    };
    if (duyuru != null) {
      _duyuruYapildi = true;
      SemanticsService.sendAnnouncement(
        View.of(context),
        duyuru,
        TextDirection.ltr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.durum) {
      case SenkronDurumTuru.yerel:
        return _rozet(
          context,
          ikon: Icons.schedule,
          renk: MRenk.metinIkincil(context),
          metin: Metinler.yalnizcaBuCihazda,
        );
      case SenkronDurumTuru.kuyrukta:
        return _rozet(
          context,
          ikon: null,
          renk: MRenk.metinIkincil(context),
          metin: Metinler.gonderiliyor,
          donenIkon: true,
        );
      case SenkronDurumTuru.senkronize:
        // Gurultu azaltma (DESIGN.md SS4): ikon YOK, gorunur rozet YOK --
        // yalniz bir kerelik semantics duyurusu (A11Y-7), bkz. gorev_satiri.
        return const SizedBox.shrink();
      case SenkronDurumTuru.cevrimdisi:
        return _rozet(
          context,
          ikon: Icons.cloud_off,
          renk: MRenk.cevrimdisi(context),
          metin: Metinler.cevrimdisiKaydedildi,
        );
    }
  }

  Widget _rozet(
    BuildContext context, {
    required IconData? ikon,
    required Color renk,
    required String metin,
    bool donenIkon = false,
  }) {
    return Semantics(
      label: metin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (donenIkon)
            _DonenOk(renk: renk)
          else
            Icon(ikon, size: MOlcu.ikon, color: renk),
          SizedBox(width: MBosluk.xs),
          Flexible(
            child: Text(
              metin,
              style: MTipo.etiketS.copyWith(color: renk),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// 'kuyrukta' durumunun donen yukari-ok ikonu. MediaQuery.disableAnimations
/// acikken sure SIFIRDIR (A11Y-5) -- AnimatedRotation.duration dogrudan
/// bundan turer, dolayisiyla widget agacindan olculebilir.
class _DonenOk extends StatefulWidget {
  final Color renk;

  const _DonenOk({required this.renk});

  @override
  State<_DonenOk> createState() => _DonenOkState();
}

class _DonenOkState extends State<_DonenOk> {
  double _tur = 0;
  Timer? _zamanlayici;
  bool _azaltilmisMi = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _azaltilmisMi = MediaQuery.of(context).disableAnimations;
    _zamanlayici?.cancel();
    if (!_azaltilmisMi) {
      _zamanlayici = Timer.periodic(MHareket.standart, (_) {
        if (mounted) setState(() => _tur += 1);
      });
    }
  }

  @override
  void dispose() {
    _zamanlayici?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: _tur,
      duration: _azaltilmisMi ? Duration.zero : MHareket.standart,
      child: Icon(Icons.arrow_upward, size: MOlcu.ikon, color: widget.renk),
    );
  }
}

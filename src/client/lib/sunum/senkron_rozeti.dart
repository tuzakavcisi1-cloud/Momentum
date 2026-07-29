import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../design/metinler.dart';
import '../design/tokens.dart';

/// DESIGN.md SS4 durum matrisindeki rozet karsiliklari. 'senkronize' GERCEK
/// veriden dogar -- itme turunda basarili sonuc sonrasi yazilir
/// (`senkron_dongusu.dart:274` cagirir, yazici govdesi `:364`) ve
/// R9/T1'den beri cekmeyle DOGAN (INSERT-from-pull) satirlar da 'senkronize'
/// ile baslar. CHECK kisiti bes degerin TUMUNE izin verir ('yerel',
/// 'kuyrukta', 'senkronize', 'cakisma', 'cevrimdisi'). Bu durumda rozetin
/// CIZILMEMESI bir veri sinirlamasi degil, GURULTU AZALTMADIR (DESIGN.md
/// SS4) -- kullaniciya yalniz DIKKAT gerektiren durumlar gosterilir.
///
/// GOREV-R10 [K75]: `gonderilmemis` -- satir sunucuda VAR ama son degisiklik
/// (senkron kuyrugunda bekleyen bir op) henuz gitmedi. `K` (ham DB kolonu)
/// bu durumu HICBIR ZAMAN tasimaz -- taban KUYRUKTAN turetilir (rozetDikisi,
/// D2 kural 3), enum degeri yalniz TURETILMIS taban icindir.
enum SenkronDurumTuru { yerel, kuyrukta, senkronize, cevrimdisi, gonderilmemis }

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
  // GOREV-R10 D9: eski kod duyuruyu SADECE didChangeDependencies'te
  // yapiyordu -- bu yalniz ILK mount'ta / inherited bagimlilik degisiminde
  // koşar, ebeveyn `durum` PARAMETRESINI degistirdiginde (ayni State,
  // didUpdateWidget) HIC koşmaz ⇒ durum gecislerinde duyuru sessizce
  // kaybolurdu. `_sonDuyurulanDurum` hem "ilk mount'ta bir kez" hem "onceki
  // durum != yeni durum" kuralini TEK bayrakla tasir.
  SenkronDurumTuru? _sonDuyurulanDurum;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sonDuyurulanDurum == null) {
      _duyuruGerekirseGonder(widget.durum);
    }
  }

  @override
  void didUpdateWidget(covariant SenkronRozeti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.durum != widget.durum) {
      _duyuruGerekirseGonder(widget.durum);
    }
  }

  void _duyuruGerekirseGonder(SenkronDurumTuru durum) {
    _sonDuyurulanDurum = durum;
    final duyuru = switch (durum) {
      SenkronDurumTuru.senkronize => Metinler.duyuruSenkronizeEdildi,
      SenkronDurumTuru.cevrimdisi => Metinler.duyuruCevrimdisi,
      SenkronDurumTuru.gonderilmemis => Metinler.duyuruGonderilmemisDegisiklik,
      _ => null,
    };
    if (duyuru != null) {
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
      case SenkronDurumTuru.gonderilmemis:
        return _rozet(
          context,
          ikon: Icons.edit_outlined,
          renk: MRenk.metinIkincil(context),
          metin: Metinler.gonderilmemisDegisiklik,
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

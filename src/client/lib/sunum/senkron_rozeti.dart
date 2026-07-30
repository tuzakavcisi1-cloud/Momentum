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

  /// GOREV-A7 D-A7-2: spec'in `MAX_SATIR`i. Dart adlandirmasi camelCase'dir
  /// (`constant_identifier_names`, `--fatal-infos` altinda SCREAMING_CASE
  /// analyzer info uretir) -- deger ve anlam spec ile birebir.
  ///
  /// OLCULMUS GEREKCE: yeni kisa dizgelerin hepsi 236 px'te 2.0x'te **2
  /// satir** (KANIT/A7/02-COZUM-OLCUM.txt); 3 bir EMNIYET PAYIDIR, cunku
  /// cihaz fontu test fontundan genis olcebilir (spec §8/S3). `ellipsis`
  /// KALIR: 3 satir da yetmezse kirpma GORUNUR olur ve G13 isirir.
  /// 🔴 maxLines'i KALDIRMAK `ellipsis`'i fiilen tek satira indirir
  /// (olculdu, varyant A) -- M84 bunu isirtir.
  static const int maxSatir = 3;

  /// GOREV-A7 D-A7-1: EKRANDA gorunen KISA metin. `null` ⇒ rozet cizilmez.
  /// `build` ve `GorevSatiri`nin dikey-donus hesabi AYNI bu fonksiyonu
  /// cagirir -- kopya esleme YASAK (M77b).
  static String? metinIcin(SenkronDurumTuru durum) => switch (durum) {
    SenkronDurumTuru.yerel => Metinler.rozetKisaYerel,
    SenkronDurumTuru.kuyrukta => Metinler.gonderiliyor,
    SenkronDurumTuru.senkronize => null,
    SenkronDurumTuru.cevrimdisi => Metinler.rozetKisaCevrimdisi,
    SenkronDurumTuru.gonderilmemis => Metinler.rozetKisaGonderilmedi,
  };

  /// GOREV-A7 D-A7-1: ekran okuyucunun okudugu TAM metin -- F6'nin kilitli
  /// dizgesidir, DEGISMEZ. Gorunur metin kisaldi, bilgi KAYBOLMADI.
  static String? tamMetinIcin(SenkronDurumTuru durum) => switch (durum) {
    SenkronDurumTuru.yerel => Metinler.yalnizcaBuCihazda,
    SenkronDurumTuru.kuyrukta => Metinler.gonderiliyor,
    SenkronDurumTuru.senkronize => null,
    SenkronDurumTuru.cevrimdisi => Metinler.cevrimdisiKaydedildi,
    SenkronDurumTuru.gonderilmemis => Metinler.gonderilmemisDegisiklik,
  };

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
        );
      case SenkronDurumTuru.kuyrukta:
        return _rozet(
          context,
          ikon: null,
          renk: MRenk.metinIkincil(context),
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
        );
      case SenkronDurumTuru.gonderilmemis:
        return _rozet(
          context,
          ikon: Icons.edit_outlined,
          renk: MRenk.metinIkincil(context),
        );
    }
  }

  /// GOREV-A7 D-A7-1. Dizgeler PARAMETRE OLARAK GELMEZ -- bu govde
  /// `SenkronRozeti.metinIcin`/`tamMetinIcin`i KENDISI cagirir. Gerekce
  /// M77b: cagiran tarafta ikinci bir esleme tablosu olsaydi, o tablo ile
  /// `GorevSatiri`nin dikey-donus hesabinin kullandigi tablo SESSIZCE
  /// ayrisabilirdi. Tek kaynak, iki tuketici.
  ///
  /// `!` guvenlidir: iki fonksiyon YALNIZ `senkronize` icin null doner ve o
  /// durum yukaridaki switch'te `SizedBox.shrink()` ile daha once donmustur.
  Widget _rozet(
    BuildContext context, {
    required IconData? ikon,
    required Color renk,
    bool donenIkon = false,
  }) {
    final kisaMetin = SenkronRozeti.metinIcin(widget.durum)!;
    final tamMetin = SenkronRozeti.tamMetinIcin(widget.durum)!;
    return Semantics(
      label: tamMetin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (donenIkon)
            _DonenOk(renk: renk)
          else
            Icon(ikon, size: MOlcu.ikon, color: renk),
          SizedBox(width: MBosluk.xs),
          Flexible(
            // GOREV-A7 §2/3: gorunur metin ile Semantics(label:) artik FARKLI
            // dizgeler tasiyor. ExcludeSemantics OLMADAN ekran okuyucu
            // "Cevrimdisisiniz. Degisiklikler kaydedildi. Cevrimdisi" diye
            // IKI KEZ okur -- M87 bunu isirtir (G15/A13).
            child: ExcludeSemantics(
              child: Text(
                kisaMetin,
                style: MTipo.etiketS.copyWith(color: renk),
                maxLines: SenkronRozeti.maxSatir,
                overflow: TextOverflow.ellipsis,
              ),
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

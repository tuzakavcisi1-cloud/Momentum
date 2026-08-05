import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../design/metinler.dart';
import '../design/tokens.dart';
import '../veri/depolama_durumu.dart';

/// GOREV-W2 T3 (D-W2-3): UI YALNIZ KUSURDA KONUSUR -- `kaliciOpfs` ve
/// `olculmedi` icin serit YOK, `geriDusus`/`kaliciDegil` icin VAR.
/// D-W2-4: renk `MRenk.cevrimdisi` YALNIZ METIN+IKONDADIR, DOLGU YOKTUR;
/// zemin sıradan `MRenk.yuzey`dir.
/// 🔴 YASAK sarmalayicilar (denetim BL-2/YB-4): `Opacity` · `Visibility` ·
/// `Offstage` · `Transform` · `ClipRect` · `ColorFiltered` · sabit
/// yukseklik/genislik -- hicbiri bu dosyada KULLANILMAZ.
class DepolamaSeridi extends StatefulWidget {
  final DepolamaDurumu durum;

  const DepolamaSeridi({super.key, required this.durum});

  @override
  State<DepolamaSeridi> createState() => _DepolamaSeridiState();
}

class _DepolamaSeridiState extends State<DepolamaSeridi> {
  // GOREV-W2 T3/A11Y-7 (desen senkron_rozeti.dart:76 -- `_sonDuyurulanDurum`):
  // "olculmedi -> geriDusus" gecisinde TAM BIR KEZ duyuru gonderilir.
  DepolamaSinifi? _sonBilinenSinif;

  bool _seritGerekliMi(DepolamaSinifi sinif) =>
      sinif == DepolamaSinifi.geriDusus || sinif == DepolamaSinifi.kaliciDegil;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _duyuruGerekirseGonder(widget.durum.sinif);
  }

  @override
  void didUpdateWidget(covariant DepolamaSeridi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.durum.sinif != widget.durum.sinif) {
      _duyuruGerekirseGonder(widget.durum.sinif);
    }
  }

  void _duyuruGerekirseGonder(DepolamaSinifi yeniSinif) {
    final oncekiGerekliMi =
        _sonBilinenSinif != null && _seritGerekliMi(_sonBilinenSinif!);
    _sonBilinenSinif = yeniSinif;
    if (!oncekiGerekliMi && _seritGerekliMi(yeniSinif)) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        Metinler.duyuruDepolamaGeriDususu,
        TextDirection.ltr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_seritGerekliMi(widget.durum.sinif)) {
      return const SizedBox.shrink();
    }
    final metin = widget.durum.sinif == DepolamaSinifi.kaliciDegil
        ? Metinler.depolamaKaliciDegil
        : Metinler.depolamaGeriDususu;
    final renk = MRenk.cevrimdisi(context);
    return Container(
      color: MRenk.yuzey(context),
      padding: EdgeInsets.symmetric(horizontal: MBosluk.m, vertical: MBosluk.s),
      child: Semantics(
        label: metin,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storage, size: MOlcu.ikon, color: renk),
            SizedBox(width: MBosluk.xs),
            Flexible(
              // Desen senkron_rozeti.dart:169-185: gorunur metin ile
              // Semantics(label:) AYNI dizgeyi tasir -- ExcludeSemantics
              // olmadan ekran okuyucu iki kez okur.
              child: ExcludeSemantics(
                child: Text(
                  metin,
                  style: MTipo.etiketS.copyWith(color: renk),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

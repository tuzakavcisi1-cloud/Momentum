import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../veri/gorev_deposu.dart';
import 'cakisma_rozeti.dart';
import 'senkron_rozeti.dart';

/// SS3.1 -- gorev: onay kutusu + baslik + senkron rozeti.
///
/// PAZARLIKSIZ DOKUNMA SINIRI (T6): bu widget'in kendisi onTap TASIMAZ --
/// dokunulabilir tek alanlar Checkbox ve (varsa) CakismaRozeti'nin kendi
/// GestureDetector'idir. Gerekce: dokunulabilir alan satir olsaydi metin
/// semantics dugumune girer ve M7 isirmazdi.
class GorevSatiri extends StatelessWidget {
  final Gorev gorev;
  final ValueChanged<bool> onTamamlaDegisti;
  final SenkronDurumTuru senkronDurumu;
  final bool cakismaVarMi;

  const GorevSatiri({
    super.key,
    required this.gorev,
    required this.onTamamlaDegisti,
    this.senkronDurumu = SenkronDurumTuru.yerel,
    this.cakismaVarMi = false,
  });

  /// GOREV-A7 D-A7-3: baslik icin ayrilan ASGARI genislik. 96dp'dir ve
  /// MEVCUT token'in KATI olarak yazilmistir -- K46 yeni token yasagi
  /// yururlukte (DESIGN.md'ye tek bayt yazilmaz). Spec §8/S7: bu bir
  /// TASARIM SECIMIDIR, olculmus esik degil.
  static const double baslikAsgari = MOlcu.dokunmaHedefi * 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: MRenk.ayirici(context)),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: MBosluk.xs),
      // GOREV-A7 D-A7-3: dar ekran + buyuk olcekte satir DIKEYE doner.
      // 🔴 AMACI KIRPMAYI ONLEMEK DEGILDIR (onu D-A7-1 kisa dizge +
      // D-A7-2 maxLines yapiyor) -- satir YUKSEKLIGINI dusurmektir: rozet
      // tam genislik alinca 2 satir yerine 1 satira sigar.
      child: LayoutBuilder(
        builder: (context, kisitlar) {
          return _dikeyMi(context, kisitlar.maxWidth)
              ? _dikeyDuzen(context)
              : _yatayDuzen(context);
        },
      ),
    );
  }

  /// D-A7-3 karar formulu. `metinIcin` DOGRUDAN cagrilir (M77b: ikinci bir
  /// esleme tablosu yazmak, olculen dizge ile CIZILEN dizgenin sessizce
  /// ayrismasina izin verirdi).
  bool _dikeyMi(BuildContext context, double maxGenislik) {
    if (!maxGenislik.isFinite) return false;
    final kisaMetin = SenkronRozeti.metinIcin(senkronDurumu);
    // 'senkronize' rozet CIZMEZ (SizedBox.shrink) ⇒ olculecek metin yok,
    // dikeye donmenin sebebi de yok (G14/A7).
    if (kisaMetin == null) return false;

    final boyaci = TextPainter(
      text: TextSpan(text: kisaMetin, style: MTipo.etiketS),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final rozetIstedigi =
        boyaci.maxIntrinsicWidth + MOlcu.ikon + MBosluk.xs;
    boyaci.dispose();

    final sabitler = MOlcu.dokunmaHedefi +
        MBosluk.s +
        MBosluk.s +
        (cakismaVarMi ? MOlcu.dokunmaHedefi + MBosluk.xs : 0);

    return sabitler + baslikAsgari + rozetIstedigi > maxGenislik;
  }

  Widget _yatayDuzen(BuildContext context) {
    return Row(
      children: [
        _onayKutusu(),
        SizedBox(width: MBosluk.s),
        Expanded(child: _baslik(context)),
        SizedBox(width: MBosluk.s),
        ..._rozetler(),
      ],
    );
  }

  /// Baslik ustte (onay kutusuyla ayni satirda), rozet satiri altta.
  /// Rozet satiri onay kutusunun genisligi kadar GIRINTILIDIR -- boylece
  /// rozete ayrilan gercek genislik `maxWidth - 48 - 8` olur ve D-A7-3'un
  /// formulundeki `sabitler` ile TUTARLI kalir.
  /// `Checkbox` ve `CakismaRozeti` kendi 48dp dokunma hedeflerini KORUR.
  Widget _dikeyDuzen(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _onayKutusu(),
            SizedBox(width: MBosluk.s),
            Expanded(child: _baslik(context)),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
            left: MOlcu.dokunmaHedefi + MBosluk.s,
          ),
          child: Row(children: _rozetler()),
        ),
      ],
    );
  }

  Widget _onayKutusu() {
    return Semantics(
      label: gorev.baslik,
      child: Checkbox(
        value: gorev.tamamlandi,
        onChanged: (deger) => onTamamlaDegisti(deger ?? false),
      ),
    );
  }

  /// GOREV-A8 [K90/spec SS4/Y1]: liste satirinda tek satir DOGRU davranistir
  /// -- sabit, OLCULMEZ (S1). Kayip KABUL EDILIR; `Semantics(label:
  /// gorev.baslik)` (satir 125) tam metni tasir. `ellipsis` TEK BASINA
  /// metni FIILEN tek satira indirdigi icin (B3, KANIT/A7) bugunku FIILI
  /// davranis zaten budur -- degisiklik ORTUK olani ACIK yapar, duzen
  /// DEGISMEZ (G13/G14/G15 risk almaz).
  static const int kGorevSatiriBaslikMaxSatir = 1;

  Widget _baslik(BuildContext context) {
    return Text(
      gorev.baslik,
      style: MTipo.govdeM.copyWith(
        color: MRenk.metin(context),
        decoration: gorev.tamamlandi
            ? TextDecoration.lineThrough
            : TextDecoration.none,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: kGorevSatiriBaslikMaxSatir,
    );
  }

  /// GOREV-R10 D7 PAZARLIKSIZ: cakisma bir DIK KANALDIR -- taban rozeti
  /// BASTIRMAZ. Eski if/else bir satirin AYNI ANDA hem cakismali hem
  /// bekleyen olabilecegi gercegini sessizce dusuruyordu (DESIGN.md v2 §4).
  /// Once cakisma ikonu, sonra taban.
  /// 🔴 TEK GOVDE: yatay ve dikey duzen AYNI listeyi kullanir; kopyalanmis
  /// olsaydi M79 (dikeyde CakismaRozeti dusurulur) sessizce mumkun olurdu.
  List<Widget> _rozetler() {
    return [
      if (cakismaVarMi) ...[
        const CakismaRozeti(),
        SizedBox(width: MBosluk.xs),
      ],
      Flexible(child: SenkronRozeti(durum: senkronDurumu)),
    ];
  }
}

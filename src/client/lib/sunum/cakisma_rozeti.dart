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
      MaterialPageRoute(builder: (_) => const CakismaCozumSayfasi()),
    );
  }
}

/// GOREV-A9 [K93]: yer tutucu -- gercek cakisma cozumu (SS2) AYRI bir
/// dilimdir; K42-d'nin dort adimi tamamlandi ve SS2'yi getirmedi -- sahibi
/// HENUZ YOK (spec SS1/S10, BORCLAR.md'ye Cowork tasir).
///
/// GOREV-A9 [K93]: public + `{super.key}` -- iki ZORUNLU gerekce: (1)
/// `g16_metin_kaybi_kapisi_test.dart` bu sinifi `package:` uzerinden PUBLIC
/// olarak kurmak zorunda (private sinif test edilemez); (2)
/// `use_key_in_widget_constructors` linti YALNIZ public siniflarda isirir --
/// alt cizgi kalsaydi `key` almayan kurucu `--fatal-infos` altinda KIRMIZI
/// verirdi.
class CakismaCozumSayfasi extends StatelessWidget {
  const CakismaCozumSayfasi({super.key});

  /// GOREV-A9 [K93/spec SS4/Y6]: 🔒 SABIT, OLCULMEZ. `AppBar` basligi
  /// `_kMaxTitleTextScaleFactor = 1.34`'e kelepceli oldugu icin izgaranin
  /// 1.5x/2.0x ayaklari oraya ULASMAZ; "en kucuk N" kurali uygulansa N=2
  /// cikar ve 2 satir 64 dp toolbar'da SESSIZCE kesilir (spec SS0/2, SS8/S1).
  static const int kCakismaBasligiMaxSatir = 1;

  /// GOREV-A9 [K93/spec SS4/Y7]: OLCULDU (KANIT/A9/00-OLCUM.txt, probe) --
  /// izgaranin DOKUZ noktasinin HEPSINDE didExceedMaxLines==false veren EN
  /// KUCUK N.
  static const int kCakismaGovdesiMaxSatir = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          Metinler.duyuruCakismaVar,
          overflow: TextOverflow.ellipsis,
          maxLines: kCakismaBasligiMaxSatir,
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(MBosluk.m),
          child: Text(
            Metinler.cakismaVar,
            style: MTipo.govdeM.copyWith(color: MRenk.metin(context)),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: kCakismaGovdesiMaxSatir,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../design/metinler.dart';
import '../design/tokens.dart';
import '../veri/gorev_deposu.dart';
import 'cakisma_rozeti.dart';
import 'gorev_baslik_dogrulama.dart';
import 'senkron_rozeti.dart';

/// SS3.1 -- gorev: onay kutusu + baslik + senkron rozeti.
///
/// PAZARLIKSIZ DOKUNMA SINIRI (T6): bu widget'in kendisi onTap TASIMAZ --
/// dokunulabilir alanlar Checkbox, (varsa) CakismaRozeti'nin kendi
/// GestureDetector'i ve (varsa) baslik duzenleme IconButton'idir; ucu de
/// KENDI dokunma hedefini tasir. Gerekce: dokunulabilir alan satir olsaydi
/// metin semantics dugumune girer ve M7 isirmazdi (IS-EMRI-o68: kilit
/// lafzi ucuncu alana genisledi, gerekce KORUNDU -- baslik metni hala
/// dokunulamaz).
class GorevSatiri extends StatelessWidget {
  final Gorev gorev;
  final ValueChanged<bool> onTamamlaDegisti;
  final SenkronDurumTuru senkronDurumu;
  final bool cakismaVarMi;
  // GOREV-SS2 D-SS2-8: `cakismaVarMi` iken `CakismaRozeti`'ye `entityId` +
  // `depo` geçirmek için gerekir. `cakismaVarMi == false` olan mevcut
  // çağrı yerleri (testler dâhil) bunu HİÇ bilmez -- `null` varsayılanı
  // güvenlidir çünkü o durumda `CakismaRozeti` zaten inşa edilmez.
  final GorevDeposu? depo;
  // IS-EMRI-o68 SS2 kriter 8: baslik duzenleme. `null` ise ikon HIC CIZILMEZ
  // -- mevcut cagri yerleri ve testler bunu hic bilmez (D-SS2-8'in `depo`
  // alanindaki emsalin AYNISI, ayni turda ayni desen tekrar kullanildi).
  final ValueChanged<String>? onBaslikDuzenlendi;

  const GorevSatiri({
    super.key,
    required this.gorev,
    required this.onTamamlaDegisti,
    this.senkronDurumu = SenkronDurumTuru.yerel,
    this.cakismaVarMi = false,
    this.depo,
    this.onBaslikDuzenlendi,
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

    // IS-EMRI-o68: baslik duzenleme ikonu `_rozetler()`in SONUNA eklenir
    // (asagida) -- kendi 48dp dokunma hedefini CAKISMA ikonuyla AYNI
    // desende rezerve eder. Buraya eklenmezse OLCULEN duzen (bu formul)
    // ile CIZILEN duzen sessizce ayrisir -- M77b'nin uyardigi kusurun
    // aynisi (IS-EMRI-o68 §1.5).
    final sabitler = MOlcu.dokunmaHedefi +
        MBosluk.s +
        MBosluk.s +
        (cakismaVarMi ? MOlcu.dokunmaHedefi + MBosluk.xs : 0) +
        (onBaslikDuzenlendi != null ? MOlcu.dokunmaHedefi + MBosluk.xs : 0);

    return sabitler + baslikAsgari + rozetIstedigi > maxGenislik;
  }

  Widget _yatayDuzen(BuildContext context) {
    return Row(
      children: [
        _onayKutusu(),
        SizedBox(width: MBosluk.s),
        Expanded(child: _baslik(context)),
        SizedBox(width: MBosluk.s),
        ..._rozetler(context),
      ],
    );
  }

  /// Baslik ustte (onay kutusuyla ayni satirda), rozet satiri altta.
  /// Rozet satiri onay kutusunun genisligi kadar GIRINTILIDIR (`maxWidth -
  /// 48 - 8`) -- bu satir SABIT kalir (checkbox genisligi degismedi), ama
  /// IS-EMRI-o68 ile bu girintili satirin ICERIGI degisti: `_rozetler()`
  /// artik (varsa) baslik duzenleme ikonunu da tasir, CAKISMA ikonuyla
  /// AYNI konumda. D-A7-3'un formulundeki `sabitler` bu ikisini de (cakisma
  /// + duzenleme) AYRI AYRI, kosullu terimlerle sayar -- girinti SABITI
  /// ile `sabitler` arasindaki iliski YAKLASIKTIR (girinti tek bosluk
  /// `MBosluk.s` sayar, `sabitler` yatay tek-satirda IKI sayar: baslikla
  /// arada ve rozetlerle arada), TAM ESITLIK DEGILDIR -- bu satir eski
  /// haliyle de boyleydi (56 ≠ 64), IS-EMRI-o68 bu ONCEDEN VAR OLAN
  /// yaklasikligi DEGISTIRMEDI.
  /// `Checkbox`, `CakismaRozeti` ve (varsa) duzenleme ikonu kendi 48dp
  /// dokunma hedeflerini KORUR.
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
          child: Row(children: _rozetler(context)),
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
  /// IS-EMRI-o68: (varsa) baslik duzenleme ikonu SONA eklenir -- durum
  /// rozetleri (cakisma/senkron) ONCE, eylem ikonu EN SON.
  List<Widget> _rozetler(BuildContext context) {
    return [
      if (cakismaVarMi) ...[
        CakismaRozeti(entityId: gorev.id, depo: depo),
        SizedBox(width: MBosluk.xs),
      ],
      Flexible(child: SenkronRozeti(durum: senkronDurumu)),
      if (onBaslikDuzenlendi != null) ...[
        SizedBox(width: MBosluk.xs),
        _duzenleIkonu(context),
      ],
    ];
  }

  /// IS-EMRI-o68 SS2 kriter 8: `onBaslikDuzenlendi` VARSA kendi 48dp dokunma
  /// hedefini tasiyan AYRI bir IconButton (Onur kilidi ①: satirin kendisi
  /// onTap TASIMAZ, T6 PAZARLIKSIZ).
  /// 🔴 `tooltip` ZORUNLUDUR -- bu, etiketi IconButton'in KENDI ic
  /// Semantics dugumune yazan yoldur. OLCULDU: disardan saran bir
  /// `Semantics(label:, button:true, child: IconButton(...))` BURADA
  /// ISE YARAMADI -- IconButton kendi `container:true` semantics dugumunu
  /// tasiyor, disaridaki sarmalayici AYRI bir dugume duser ve
  /// `labeledTapTargetGuideline` "tap eylemi olan dugumde etiket yok"
  /// diye FAIL eder (ilk kosumda gorulup duzeltildi -- CakismaRozeti'nin
  /// deseni GestureDetector+Semantics+Container'dir, IconButton'un KENDI
  /// ic semantics'i VARDIR, ikisi AYNI DESEN DEGILDIR).
  /// Etiketsiz birakilirsa `labeledTapTargetGuideline` KENDISI FAIL eder ve
  /// M7 (CakismaRozeti'nin etiketini silme mutanti) o zaman etiketsiz-
  /// ikondan AYIRT EDILEMEZ hale gelir, yani M7 OLUR (IS-EMRI-o68 §1.4).
  Widget _duzenleIkonu(BuildContext context) {
    final geriCagirim = onBaslikDuzenlendi!;
    return IconButton(
      icon: Icon(Icons.edit_outlined, size: MOlcu.ikon),
      tooltip: Metinler.baslikDuzenle,
      constraints: BoxConstraints.tightFor(
        width: MOlcu.dokunmaHedefi,
        height: MOlcu.dokunmaHedefi,
      ),
      padding: EdgeInsets.zero,
      onPressed: () => _baslikDuzenleDiyaloguAc(context, geriCagirim),
    );
  }

  /// IS-EMRI-o68 §3.2/§3.3: bir MODAL diyalog acar -- "yerinde" (satirin
  /// kendi govdesinde) `TextField` Onur tarafindan REDDEDILDI, bu ONDAN
  /// FARKLIDIR ve T6'yi ihlal etmez (satirin KENDISINE `onTap` eklenmez).
  /// Govde `_BaslikDuzenleDiyalogu`'a tasindi (asagida) -- OLCULDU: bu
  /// metodun ONCEKI govdesi `TextEditingController`i burada YARATIP
  /// `await showDialog(...)` SONRASI hemen `dispose()` ediyordu; iptal/
  /// kaydet'in Navigator.pop() COGRAFI FRAME'de kapanir ama diyalogun KAPANMA
  /// GECISI (route transition) bir sonraki frame'lerde surer -- controller
  /// o gecis SURERKEN hala TextField'a bagliyken dispose ediliyordu
  /// ("TextEditingController was used after being disposed", ilk kosumda
  /// yakalandi). Controller'i kendi State.dispose()'unda yok eden bir
  /// StatefulWidget bu yarisi ORTADAN KALDIRIR -- framework onu SADECE
  /// widget agactan GERCEKTEN kalktiginda cagirir.
  Future<void> _baslikDuzenleDiyaloguAc(
    BuildContext context,
    ValueChanged<String> onKaydet,
  ) async {
    final yeniBaslik = await showDialog<String>(
      context: context,
      builder: (_) => _BaslikDuzenleDiyalogu(baslangicBasligi: gorev.baslik),
    );
    if (yeniBaslik != null) onKaydet(yeniBaslik);
  }
}

/// IS-EMRI-o68: `GorevSatiri._baslikDuzenleDiyaloguAc`'in diyalog govdesi --
/// ayri bir StatefulWidget, cunku `TextEditingController`in yasam dongusu
/// State'e baglanmali (yukaridaki metodun dokumantasyonu OLCULMUS gerekceyi
/// tasir).
class _BaslikDuzenleDiyalogu extends StatefulWidget {
  final String baslangicBasligi;

  const _BaslikDuzenleDiyalogu({required this.baslangicBasligi});

  @override
  State<_BaslikDuzenleDiyalogu> createState() =>
      _BaslikDuzenleDiyaloguState();
}

class _BaslikDuzenleDiyaloguState extends State<_BaslikDuzenleDiyalogu> {
  late final TextEditingController _denetleyici;

  @override
  void initState() {
    super.initState();
    _denetleyici = TextEditingController(text: widget.baslangicBasligi);
  }

  @override
  void dispose() {
    _denetleyici.dispose();
    super.dispose();
  }

  // OLCULDU (bagimsiz denetimde bulundu): `Navigator.pop(gorevBasligiDogrula
  // (...))` KOSULSUZ cagrilirsa, bos baslikta `pop(null)` diyalogu YINE
  // KAPATIR -- kullanicinin gozunde IPTAL'den AYIRT EDILEMEZ olur (sessiz
  // veri kaybi degil ama sessiz DUZENLEME kaybi). `GorevEkleAlani._gonder()`
  // AYNI durumda hicbir sey yapmadan geri doner (alan ACIK kalir) -- burada
  // da AYNI desen: gecersizse diyalog ACIK KALIR, kullanici duzeltebilir.
  void _kaydet() {
    final gecerliBaslik = gorevBasligiDogrula(_denetleyici.text);
    if (gecerliBaslik == null) return;
    Navigator.of(context).pop(gecerliBaslik);
  }

  // A11Y-4 STATIK (a11y_statik_tasma_test.dart R1/R2): HER Text( cagrisi
  // `overflow: TextOverflow.ellipsis` + `maxLines` tasir -- maxLines TEK
  // BASINA yetmez (M16: Flutter varsayilani sessiz TextOverflow.clip'tir).
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        Metinler.baslikDuzenle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      content: TextField(
        controller: _denetleyici,
        autofocus: true,
        onSubmitted: (_) => _kaydet(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            Metinler.iptalDugmesi,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        TextButton(
          onPressed: _kaydet,
          child: Text(
            Metinler.kaydetDugmesi,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

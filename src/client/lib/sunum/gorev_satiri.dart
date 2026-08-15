import 'package:flutter/material.dart';

import '../design/metinler.dart';
import '../design/tokens.dart';
import '../veri/gorev_deposu.dart';
import 'cakisma_rozeti.dart';
import 'etiket_dogrulama.dart';
import 'gorev_baslik_dogrulama.dart';
import 'senkron_rozeti.dart';

/// SS3.1 -- gorev: onay kutusu + baslik + senkron rozeti.
///
/// PAZARLIKSIZ DOKUNMA SINIRI (T6): bu widget'in kendisi onTap TASIMAZ --
/// dokunulabilir alanlar Checkbox, (varsa) CakismaRozeti'nin kendi
/// GestureDetector'i ve (varsa) duzenleme/silme IconButton'idir; hepsi
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
  // ODEV.md §4(a) "oncelik + son tarih" dilimi: kalem ikonu artik BASLIK +
  // ONCELIK + SON TARIH'i TEK diyalogda duzenler (o68'in `onBaslikDuzenlendi`
  // parametresinin HALEFI -- ayni konum, ayni ikon, genisletilmis yuk).
  // 🔴 SATIRA YENI IKON EKLENMEZ: `_dikeyMi()`nin sabitler toplamindaki
  // kosullu terim SAYISI degismez, yalniz adi degisir -- M77b sinifi (olculen
  // duzen ile cizilen duzenin sessizce ayrismasi) bu dilimde DOGMAZ.
  // `null` ise ikon HIC CIZILMEZ (o68/o72 ile ayni desen).
  final ValueChanged<GorevAyrintiDegisikligi>? onAyrintilarDuzenlendi;
  // IS-EMRI-o72: gorev silme. `null` ise ikon HIC CIZILMEZ -- mevcut cagri
  // yerleri ve testler bunu hic bilmez.
  final VoidCallback? onSil;

  const GorevSatiri({
    super.key,
    required this.gorev,
    required this.onTamamlaDegisti,
    this.senkronDurumu = SenkronDurumTuru.yerel,
    this.cakismaVarMi = false,
    this.depo,
    this.onAyrintilarDuzenlendi,
    this.onSil,
  });

  /// GOREV-A7 D-A7-3: baslik icin ayrilan ASGARI genislik. 96dp'dir ve
  /// MEVCUT token'in KATI olarak yazilmistir -- K46 yeni token yasagi
  /// yururlukte (DESIGN.md'ye tek bayt yazilmaz). Spec §8/S7: bu bir
  /// TASARIM SECIMIDIR, olculmus esik degil.
  static const double baslikAsgari = MOlcu.dokunmaHedefi * 2;

  /// SAF (BuildContext/saat/DB YOK): satirin baslik ALTINDA gorunecek meta
  /// metni. Ikisi de yoksa `null` -- o zaman meta satiri HIC CIZILMEZ ve
  /// satir yuksekligi bugunku degerinde kalir (mevcut duzen testleri, G13/
  /// G14/G15, oncelik/son tarih tasimayan gorevlerle kosar ve ETKILENMEZ).
  /// Bicim: `Yuksek · 21 Ağu 2026` -- ayirici sabittir, ikisinden biri yoksa
  /// tek parca yazilir.
  static String? metaMetni(Gorev gorev) {
    final oncelik = oncelikSayidan(gorev.oncelik);
    final parcalar = <String>[
      if (oncelik != null) oncelikEtiketi(oncelik),
      if (gorev.sonTarih != null) tarihEtiketi(gorev.sonTarih!),
      // ODEV.md §4(a) etiket dilimi: etiketler AYNI meta satirinin SONUNA,
      // TEK parca olarak yazilir. IKINCI BIR SATIR/CIP SERIDI EKLENMEZ --
      // G13/G14/G15 duzen testleri satir yuksekligine duyarlidir ve etiket
      // tasiyan gorev, oncelik/son tarih tasiyan bir gorevle AYNI yuksekligi
      // korur. '#' oneki ODEV.md §4(a)'nin dogal dil bicimiyle (`#iş`) AYNI.
      if (gorev.etiketler.isNotEmpty)
        gorev.etiketler.map((e) => '#$e').join(' '),
    ];
    return parcalar.isEmpty ? null : parcalar.join(' · ');
  }

  /// SAF: takvim gunu etiketi. `sonTarih` PAZARLIKSIZ `DateTime.utc(y, m, d)`
  /// oldugu icin (veritabani.dart TAKVIM GUNU PINI) burada YEREL SAATE
  /// CEVIRME YAPILMAZ -- `.toLocal()` cagirmak UTC+3'te gunu bir gun geri
  /// kaydirirdi (00:00Z -> onceki gun 03:00 degil, 00:00 yerel -> 21:00Z
  /// yonunun tersi; her iki yon de gun kaymasi uretir).
  static String tarihEtiketi(DateTime gun) =>
      '${gun.day} ${Metinler.ayKisaltmalari[gun.month - 1]} ${gun.year}';

  /// SAF + TAKVIM GUNU PINI'nin TEK normalizasyon noktasi. `showDatePicker`
  /// YEREL bir `DateTime` dondurur; onu `.toUtc()` ile cevirmek UTC+3'te gunu
  /// BIR GUN GERI kaydirir. Bu yuzden saat bileseni ATILIR ve y/m/d DOGRUDAN
  /// UTC olarak yeniden kurulur.
  /// 🔴 AYRI BIR METOT OLMASININ SEBEBI OLCULEBILIRLIK (bagimsiz denetim, o74):
  /// `.utc`yi dusuren ya da `secilen.toUtc()` yazan mutantlar `.toLocal()`
  /// ICERMEDIGI icin STATIK taramadan GECER; burada `isUtc == true` ve
  /// `hour == 0` iddialari onlari ENV-BAGIMSIZ olarak (CI UTC koşsa bile)
  /// oldurur.
  static DateTime takvimGunu(DateTime secilen) =>
      DateTime.utc(secilen.year, secilen.month, secilen.day);

  /// SAF: enum -> gorunur etiket. Tek esleme (M77b: ikinci bir tablo yazmak
  /// olculen ile cizilen degerin ayrismasina izin verirdi).
  static String oncelikEtiketi(Oncelik oncelik) => switch (oncelik) {
    Oncelik.yuksek => Metinler.oncelikYuksek,
    Oncelik.orta => Metinler.oncelikOrta,
    Oncelik.dusuk => Metinler.oncelikDusuk,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: MRenk.ayirici(context))),
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
    final rozetIstedigi = boyaci.maxIntrinsicWidth + MOlcu.ikon + MBosluk.xs;
    boyaci.dispose();

    // IS-EMRI-o68: duzenleme ikonu `_rozetler()`in SONUNA eklenir (asagida)
    // -- kendi 48dp dokunma hedefini CAKISMA ikonuyla AYNI desende rezerve
    // eder. Buraya eklenmezse OLCULEN duzen (bu formul) ile CIZILEN duzen
    // sessizce ayrisir -- M77b'nin uyardigi kusurun aynisi.
    // 🔴 ODEV.md §4(a): oncelik/son tarih dilimi bu formule DOKUNMAZ --
    // meta satiri BASLIGIN ALTINDA (dikey eksende) yasar, yatay genislik
    // butcesinden tek piksel almaz; satira yeni IKON da eklenmemistir.
    final sabitler =
        MOlcu.dokunmaHedefi +
        MBosluk.s +
        MBosluk.s +
        (cakismaVarMi ? MOlcu.dokunmaHedefi + MBosluk.xs : 0) +
        (onAyrintilarDuzenlendi != null
            ? MOlcu.dokunmaHedefi + MBosluk.xs
            : 0) +
        // IS-EMRI-o72 D4: silme ikonu da `_rozetler()`e eklenir -- BURAYA
        // eklenmezse OLCULEN duzen (bu formul) ile CIZILEN duzen sessizce
        // ayrisir (M77b sinifi, ayni gerekce yukarida yazildigi gibi).
        (onSil != null ? MOlcu.dokunmaHedefi + MBosluk.xs : 0);

    return sabitler + baslikAsgari + rozetIstedigi > maxGenislik;
  }

  Widget _yatayDuzen(BuildContext context) {
    return Row(
      children: [
        _onayKutusu(),
        SizedBox(width: MBosluk.s),
        Expanded(child: _baslikVeMeta(context)),
        SizedBox(width: MBosluk.s),
        ..._rozetler(context),
      ],
    );
  }

  /// Baslik ustte (onay kutusuyla ayni satirda), rozet satiri altta.
  /// Rozet satiri onay kutusunun genisligi kadar GIRINTILIDIR (`maxWidth -
  /// 48 - 8`) -- bu satir SABIT kalir (checkbox genisligi degismedi), ama
  /// IS-EMRI-o68 ile bu girintili satirin ICERIGI degisti: `_rozetler()`
  /// artik (varsa) duzenleme ikonunu da tasir, CAKISMA ikonuyla AYNI
  /// konumda. D-A7-3'un formulundeki `sabitler` bu ikisini de (cakisma
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
            Expanded(child: _baslikVeMeta(context)),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: MOlcu.dokunmaHedefi + MBosluk.s),
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
  /// gorev.baslik)` tam metni tasir. `ellipsis` TEK BASINA metni FIILEN tek
  /// satira indirdigi icin (B3, KANIT/A7) bugunku FIILI davranis zaten budur.
  static const int kGorevSatiriBaslikMaxSatir = 1;

  /// ODEV.md §4(a): baslik + (varsa) meta satiri. Meta YOKSA agac BUGUNKU
  /// haliyle AYNI kalir (tek `Text`) -- bos bir `Column` sarmalayici bile
  /// eklenmez, boylece oncelik/son tarih tasimayan gorevlerin duzeni
  /// olculebilir bicimde DEGISMEZ.
  Widget _baslikVeMeta(BuildContext context) {
    final meta = metaMetni(gorev);
    if (meta == null) return _baslik(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _baslik(context),
        Text(
          meta,
          style: MTipo.etiketS.copyWith(color: _metaRengi(context)),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  /// Renk YALNIZ YARDIMCIDIR: anlami METIN tasir (WCAG 1.4.1 -- renk tek
  /// basina bilgi tasiyamaz). Ikisi de mevcut token'dir, yeni token
  /// URETILMEZ (K46 yasagi yururlukte).
  Color _metaRengi(BuildContext context) =>
      oncelikSayidan(gorev.oncelik) == Oncelik.yuksek
      ? MRenk.tehlike(context)
      : MRenk.metinIkincil(context);

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
  /// IS-EMRI-o68: (varsa) duzenleme ikonu SONA eklenir -- durum rozetleri
  /// (cakisma/senkron) ONCE, eylem ikonlari EN SON.
  List<Widget> _rozetler(BuildContext context) {
    return [
      if (cakismaVarMi) ...[
        CakismaRozeti(entityId: gorev.id, depo: depo),
        SizedBox(width: MBosluk.xs),
      ],
      Flexible(child: SenkronRozeti(durum: senkronDurumu)),
      if (onAyrintilarDuzenlendi != null) ...[
        SizedBox(width: MBosluk.xs),
        _duzenleIkonu(context),
      ],
      // IS-EMRI-o72: eylem ikonlari arasinda sira duzenle -> sil.
      if (onSil != null) ...[SizedBox(width: MBosluk.xs), _silIkonu(context)],
    ];
  }

  /// IS-EMRI-o68 SS2 kriter 8: `onAyrintilarDuzenlendi` VARSA kendi 48dp
  /// dokunma hedefini tasiyan AYRI bir IconButton (Onur kilidi ①: satirin
  /// kendisi onTap TASIMAZ, T6 PAZARLIKSIZ).
  /// 🔴 `tooltip` ZORUNLUDUR -- bu, etiketi IconButton'in KENDI ic
  /// Semantics dugumune yazan yoldur. OLCULDU: disardan saran bir
  /// `Semantics(label:, button:true, child: IconButton(...))` BURADA
  /// ISE YARAMADI -- IconButton kendi `container:true` semantics dugumunu
  /// tasiyor, disaridaki sarmalayici AYRI bir dugume duser ve
  /// `labeledTapTargetGuideline` "tap eylemi olan dugumde etiket yok"
  /// diye FAIL eder (ilk kosumda gorulup duzeltildi).
  /// Etiketsiz birakilirsa `labeledTapTargetGuideline` KENDISI FAIL eder ve
  /// M7 (CakismaRozeti'nin etiketini silme mutanti) o zaman etiketsiz-
  /// ikondan AYIRT EDILEMEZ hale gelir, yani M7 OLUR (IS-EMRI-o68 §1.4).
  Widget _duzenleIkonu(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit_outlined, size: MOlcu.ikon),
      tooltip: Metinler.gorevDuzenle,
      constraints: BoxConstraints.tightFor(
        width: MOlcu.dokunmaHedefi,
        height: MOlcu.dokunmaHedefi,
      ),
      padding: EdgeInsets.zero,
      onPressed: () => _duzenleDiyaloguAc(context),
    );
  }

  /// IS-EMRI-o68 §3.2/§3.3: bir MODAL diyalog acar -- "yerinde" (satirin
  /// kendi govdesinde) `TextField` Onur tarafindan REDDEDILDI, bu ONDAN
  /// FARKLIDIR ve T6'yi ihlal etmez (satirin KENDISINE `onTap` eklenmez).
  /// Govde `_GorevDuzenleDiyalogu`'a tasindi (asagida) -- OLCULDU: bu
  /// metodun ONCEKI govdesi `TextEditingController`i burada YARATIP
  /// `await showDialog(...)` SONRASI hemen `dispose()` ediyordu; iptal/
  /// kaydet'in Navigator.pop() COGRAFI FRAME'de kapanir ama diyalogun KAPANMA
  /// GECISI (route transition) bir sonraki frame'lerde surer -- controller
  /// o gecis SURERKEN hala TextField'a bagliyken dispose ediliyordu
  /// ("TextEditingController was used after being disposed", ilk kosumda
  /// yakalandi). Controller'i kendi State.dispose()'unda yok eden bir
  /// StatefulWidget bu yarisi ORTADAN KALDIRIR.
  /// ODEV.md §4(a): DONUS TIPI degisti -- `String` yerine hangi alanlarin
  /// DEGISTIGINI tasiyan `GorevAyrintiDegisikligi`. `bosMu` ise (kullanici
  /// hicbir seyi degistirmeden Kaydet'e bastiysa) geri cagirim CAGRILMAZ:
  /// bos bir op sunucu tarafinda BUTUN olarak reddedilirdi (D2).
  Future<void> _duzenleDiyaloguAc(BuildContext context) async {
    final degisiklik = await showDialog<GorevAyrintiDegisikligi>(
      context: context,
      builder: (_) => _GorevDuzenleDiyalogu(
        baslangicBasligi: gorev.baslik,
        baslangicOncelik: gorev.oncelik,
        baslangicSonTarih: gorev.sonTarih,
        baslangicEtiketleri: gorev.etiketler,
      ),
    );
    if (degisiklik == null || degisiklik.bosMu) return;
    onAyrintilarDuzenlendi!(degisiklik);
  }

  /// IS-EMRI-o72: `_duzenleIkonu` ile AYNI iskelet (D3). `tooltip`
  /// ZORUNLUDUR -- ayni gerekce yukarida `_duzenleIkonu`'nun belgesinde
  /// yazili: disardan saran bir Semantics(label:) burada da ISE YARAMAZ
  /// (IconButton kendi ic semantics dugumunu tasir, o68'de olculdu).
  Widget _silIkonu(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete_outline, size: MOlcu.ikon),
      tooltip: Metinler.gorevSil,
      constraints: BoxConstraints.tightFor(
        width: MOlcu.dokunmaHedefi,
        height: MOlcu.dokunmaHedefi,
      ),
      padding: EdgeInsets.zero,
      onPressed: () => _silOnayDiyaloguAc(context),
    );
  }

  /// IS-EMRI-o72 D5: onay diyaloğu -- `showDialog<bool>`, TextEditingController
  /// YOK ⇒ StatefulWidget'a gerek yok (o68'in dispose yarisi burada hic
  /// DOGMAZ, cunku govde hicbir controller tasimaz). pop(true) donerse
  /// onSil cagrilir; iptal / disari dokunma (pop(null)) ⇒ hicbir sey olmaz.
  Future<void> _silOnayDiyaloguAc(BuildContext context) async {
    final onaylandi = await showDialog<bool>(
      context: context,
      builder: (dialogBaglami) => AlertDialog(
        title: Text(
          Metinler.gorevSil,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        content: Text(
          Metinler.gorevSilOnay,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogBaglami).pop(),
            child: Text(
              Metinler.iptalDugmesi,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogBaglami).pop(true),
            child: Text(
              Metinler.gorevSil,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
    if (onaylandi == true) onSil!();
  }
}

/// ODEV.md §4(a): oncelik secim seritinin TEK kaynagi. `Oncelik.values`ten
/// TURETILIR -- elle yazilmis ikinci bir (sayi, etiket) tablosu, enum ile
/// sessizce ayrisabilirdi (bu projede olculmus M77b sinifi).
List<({int? deger, String etiket})> _oncelikSecenekleri() => [
  (deger: null, etiket: Metinler.oncelikYok),
  for (final o in Oncelik.values)
    (deger: oncelikSayiya(o), etiket: GorevSatiri.oncelikEtiketi(o)),
];

/// IS-EMRI-o68'in `_BaslikDuzenleDiyalogu`'sunun HALEFI: baslik + oncelik +
/// son tarih TEK diyalogda. `TextEditingController`in yasam dongusu hala
/// State'e baglidir (o68'de olculmus dispose yarisi).
class _GorevDuzenleDiyalogu extends StatefulWidget {
  final String baslangicBasligi;
  final int? baslangicOncelik;
  final DateTime? baslangicSonTarih;

  /// ODEV.md §4(a): diyalog KAPANDIGINDA fark alinir (eklenen/silinen) --
  /// ara durumlar tele KONMAZ (kullanici ekleyip geri silerse hicbir op
  /// dogmaz, `bosMu` bunu yakalar).
  final List<String> baslangicEtiketleri;

  const _GorevDuzenleDiyalogu({
    required this.baslangicBasligi,
    required this.baslangicOncelik,
    required this.baslangicSonTarih,
    required this.baslangicEtiketleri,
  });

  @override
  State<_GorevDuzenleDiyalogu> createState() => _GorevDuzenleDiyaloguState();
}

class _GorevDuzenleDiyaloguState extends State<_GorevDuzenleDiyalogu> {
  late final TextEditingController _denetleyici;
  late final TextEditingController _etiketDenetleyici;
  late int? _oncelik;
  late DateTime? _sonTarih;
  late List<String> _etiketler;

  @override
  void initState() {
    super.initState();
    _denetleyici = TextEditingController(text: widget.baslangicBasligi);
    // Ayri controller: baslik alanindan BAGIMSIZ yasar ve o68'de olculen
    // dispose yarisina karsi AYNI korumayi (State.dispose) tasir.
    _etiketDenetleyici = TextEditingController();
    _oncelik = widget.baslangicOncelik;
    _sonTarih = widget.baslangicSonTarih;
    // KOPYA: `widget.baslangicEtiketleri` (depo listesi) DEGISTIRILMEZ --
    // fark hesabi kapanista ONA karsi yapilir.
    _etiketler = List<String>.of(widget.baslangicEtiketleri);
  }

  @override
  void dispose() {
    _denetleyici.dispose();
    _etiketDenetleyici.dispose();
    super.dispose();
  }

  /// Dogrulama TEK KAYNAKTAN (`etiketDogrula`). Gecersizse alan
  /// TEMIZLENMEZ ve hicbir sey olmaz -- `_kaydet`in bos baslikta diyalogu
  /// ACIK BIRAKMASIYLA ayni desen (sessiz kayip YASAK).
  void _etiketEkle() {
    final gecerli = etiketDogrula(_etiketDenetleyici.text);
    if (gecerli == null) return;
    // AYNI METIN IKI KEZ EKLENMEZ: OR-Set'te eleman kimligi metnin
    // KENDISIDIR; ikinci bir add-tag'i acmak uyeligi degistirmez, yalniz
    // gereksiz tel trafigi ve ikinci bir tombstone dogururdu.
    if (_etiketler.contains(gecerli)) {
      _etiketDenetleyici.clear();
      return;
    }
    setState(() {
      _etiketler.add(gecerli);
      _etiketDenetleyici.clear();
    });
  }

  /// Normalizasyon `GorevSatiri.takvimGunu`dedir (TEK nokta, orada olculur).
  ///
  /// 🔴 KELEPCE PAZARLIKSIZ [OLCULDU -- bagimsiz denetim, o74]:
  /// `showDatePicker` `assert(!initialDate.isBefore(firstDate))` tasir ve
  /// `_sonTarih` araligin DISINDA olabilir -- (a) baska bir istemci herhangi
  /// bir `DateTimeOffset` yazabilir (sunucu kisitlamaz, biz de "bilinmeyen
  /// degeri EZME" diyoruz), (b) takvim yili donunce eski bir yerel gorev de
  /// aralik disina duser. Kelepcelenmezse tarih dugmesi HICBIR SEY YAPMAZ
  /// (debug'da yakalanmamis assert, release'de sessiz bozukluk).
  Future<void> _tarihSec() async {
    final bugun = DateTime.now();
    final ilk = DateTime(bugun.year - 1);
    final son = DateTime(bugun.year + 5);
    final mevcut = _sonTarih == null
        ? DateTime(bugun.year, bugun.month, bugun.day)
        : DateTime(_sonTarih!.year, _sonTarih!.month, _sonTarih!.day);
    final baslangic = mevcut.isBefore(ilk)
        ? ilk
        : (mevcut.isAfter(son) ? son : mevcut);
    final secilen = await showDatePicker(
      context: context,
      initialDate: baslangic,
      firstDate: ilk,
      lastDate: son,
    );
    if (secilen == null) return;
    if (!mounted) return;
    setState(() {
      _sonTarih = GorevSatiri.takvimGunu(secilen);
    });
  }

  // OLCULDU (o68'de bagimsiz denetimde bulundu): bos baslikta `pop(null)`
  // diyalogu YINE KAPATIR ve kullanicinin gozunde IPTAL'den AYIRT EDILEMEZ
  // olur (sessiz DUZENLEME kaybi). `GorevEkleAlani._gonder()` AYNI durumda
  // hicbir sey yapmadan geri doner -- burada da AYNI desen: gecersizse
  // diyalog ACIK KALIR.
  void _kaydet() {
    final gecerliBaslik = gorevBasligiDogrula(_denetleyici.text);
    if (gecerliBaslik == null) return;
    // 🔴 [OLCULDU -- bagimsiz denetim, o74] Karsilastirma AYNI NORMALIZASYONDAN
    // gecmis iki deger arasinda yapilir: `gecerliBaslik` KIRPILMIS, ham
    // `baslangicBasligi` kirpilmamis olabilir (uzaktan 'Rapor ' gelebilir).
    // Ham degerle karsilastirilsaydi, kullanici basliga HIC DOKUNMADAN yalniz
    // onceligi degistirse bile `title` yeni bir HLC ile yeniden damgalanir ve
    // arada gelen uzak bir baslik yazimini LWW ile EZERDI.
    final baslangicGecerli =
        gorevBasligiDogrula(widget.baslangicBasligi) ?? widget.baslangicBasligi;
    Navigator.of(context).pop(
      GorevAyrintiDegisikligi(
        // YALNIZ DEGISEN alan `Yazim` ile isaretlenir. `Yazim(null)`
        // "temizle" demektir, `null` "dokunma".
        baslik: gecerliBaslik == baslangicGecerli ? null : Yazim(gecerliBaslik),
        oncelik: _oncelik == widget.baslangicOncelik ? null : Yazim(_oncelik),
        sonTarih: _sonTarih == widget.baslangicSonTarih
            ? null
            : Yazim(_sonTarih),
        // ODEV.md §4(a): FARK. Ekleyip geri silen kullanici hicbir op
        // dogurmaz (iki kume de bos ⇒ `bosMu`).
        etiketEklenen: _etiketler
            .where((e) => !widget.baslangicEtiketleri.contains(e))
            .toSet(),
        etiketSilinen: widget.baslangicEtiketleri
            .where((e) => !_etiketler.contains(e))
            .toSet(),
      ),
    );
  }

  // A11Y-4 STATIK (a11y_statik_tasma_test.dart R1/R2): HER Text( cagrisi
  // `overflow: TextOverflow.ellipsis` + `maxLines` tasir -- maxLines TEK
  // BASINA yetmez (M16: Flutter varsayilani sessiz TextOverflow.clip'tir).
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        Metinler.gorevDuzenle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      // Buyuk metin olceginde (textScaler 2.0) diyalog govdesi tasabilir --
      // kaydirilabilir sarmalayici, A11Y-4'un "kirpma sessizdir" kuralinin
      // diyalog govdesindeki karsiligidir.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              // ODEV.md §4(a) etiket dilimi: diyalogda ARTIK IKI TextField
              // var (baslik + etiket) ⇒ `find.byType(TextField)` TEK BASINA
              // BELIRSIZ. Anahtar, testlerin DOGRU alani hedeflemesi icin
              // eklendi -- iddia gucu AYNI kalir, yalniz hedef netlesir.
              key: const ValueKey('baslik_alani'),
              controller: _denetleyici,
              autofocus: true,
              onSubmitted: (_) => _kaydet(),
            ),
            SizedBox(height: MBosluk.m),
            Text(
              Metinler.oncelikBasligi,
              style: MTipo.etiketS,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            SizedBox(height: MBosluk.xs),
            // ChoiceChip: secenekler EKRANDA GORUNUR durur (acilir liste
            // DEGIL). Gerekce OLCULMUSTUR: Flutter web'de otomasyon
            // tiklamasi overlay menulerde ek bir tuzak katmani dogurur
            // (hover -> tiklama sirasi), gorunur cipler o katmani hic
            // yaratmaz -- canli olcum turu bu yuzden daha kisa.
            Wrap(
              spacing: MBosluk.xs,
              children: [
                for (final secenek in _oncelikSecenekleri())
                  ChoiceChip(
                    label: Text(
                      secenek.etiket,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    selected: _oncelik == secenek.deger,
                    onSelected: (_) => setState(() => _oncelik = secenek.deger),
                  ),
              ],
            ),
            SizedBox(height: MBosluk.m),
            Text(
              Metinler.sonTarihBasligi,
              style: MTipo.etiketS,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            SizedBox(height: MBosluk.xs),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _tarihSec,
                    child: Text(
                      _sonTarih == null
                          ? Metinler.sonTarihSec
                          : GorevSatiri.tarihEtiketi(_sonTarih!),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                if (_sonTarih != null)
                  IconButton(
                    icon: Icon(Icons.close, size: MOlcu.ikon),
                    tooltip: Metinler.sonTarihiTemizle,
                    constraints: BoxConstraints.tightFor(
                      width: MOlcu.dokunmaHedefi,
                      height: MOlcu.dokunmaHedefi,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () => setState(() => _sonTarih = null),
                  ),
              ],
            ),
            // ODEV.md §4(a) etiket dilimi: ekleme alani + mevcut etiketler.
            SizedBox(height: MBosluk.m),
            Text(
              Metinler.etiketlerBasligi,
              style: MTipo.etiketS,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            SizedBox(height: MBosluk.xs),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const ValueKey('etiket_alani'),
                    controller: _etiketDenetleyici,
                    onSubmitted: (_) => _etiketEkle(),
                  ),
                ),
                // `tooltip` ZORUNLU: etiketi IconButton'in KENDI ic
                // Semantics dugumune yazan yol budur (o68'de olculdu --
                // disardan saran Semantics `labeledTapTargetGuideline`i
                // GECIRMEZ).
                IconButton(
                  icon: Icon(Icons.add, size: MOlcu.ikon),
                  tooltip: Metinler.etiketEkle,
                  constraints: BoxConstraints.tightFor(
                    width: MOlcu.dokunmaHedefi,
                    height: MOlcu.dokunmaHedefi,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: _etiketEkle,
                ),
              ],
            ),
            if (_etiketler.isNotEmpty) ...[
              SizedBox(height: MBosluk.xs),
              Wrap(
                spacing: MBosluk.xs,
                children: [
                  for (final etiket in _etiketler)
                    InputChip(
                      label: Text(
                        etiket,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      // Silme YALNIZ diyalog KAPANINCA tele konar (fark
                      // hesabi) -- burada yerel taslak listeden cikarilir.
                      onDeleted: () =>
                          setState(() => _etiketler.remove(etiket)),
                      deleteButtonTooltipMessage: Metinler.etiketKaldir,
                    ),
                ],
              ),
            ],
          ],
        ),
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

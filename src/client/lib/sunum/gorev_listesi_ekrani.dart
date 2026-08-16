import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../design/metinler.dart';
import '../design/tokens.dart';
import '../veri/depolama_durumu.dart';
import '../veri/gorev_deposu.dart';
import 'arama_eslestirme.dart';
import 'bos_durum.dart';
import 'depolama_seridi.dart';
import 'gorev_ekle_alani.dart';
import 'gorev_satiri.dart';
import 'hata_durumu.dart';
import 'yukleme_durumu.dart';

/// SS3.1 -- tek vitrin ekrani (gercek, akis-tabanli ekran; durum_vitrini.dart
/// ile KARISTIRILMAZ, o statik/deterministik bir gosterimdir).
///
/// F5 PAZARLIKSIZ: G5 bu ekranin uzerinde de kosar (bos * yerel * hata).
/// GOREV-R10 D5: rozet turetme (`rozetDikisi`) artik `veri/gorev_deposu.dart`
/// katmanindadir -- bu ekran `GorevGorunum.senkronDurumu`/`cakismaVarMi`yi
/// DOGRUDAN okur, kendisi turetme yapmaz (F4 dikisi: widget'lar tasima
/// katmani durumunu gormez).
class GorevListesiEkrani extends StatefulWidget {
  final GorevDeposu depo;
  // slice-3d D0: KAPALI LISTE'deki dort tetikleyiciden biri -- "kullanici
  // elle yenilediginde bir cekme turu". `null` ise (mevcut testler/durum
  // vitrini) yenile dugmesi HIC gosterilmez -- geriye donuk uyumlu.
  final Future<void> Function()? onYenile;

  // K112 (oturum 48 -- CIHAZDA OLCULDU): yerel yazma ITMEYI tetiklemiyordu.
  // Gorev ekleniyor, "Bu cihazda" rozetiyle duruyor ve uygulama YENIDEN
  // BASLATILANA kadar sunucuya gitmiyordu (olcum: 60 s + elle yenileme 40 s
  // bekledi, gelmedi; yeniden baslatinca 14,4 s ve 23,5 s'te geldi).
  // Bu geri cagri her YEREL YAZMA'dan SONRA bir itme turu ister.
  // slice-3d D0'i IHLAL ETMEZ: zamanlayici degil, OLAY tetiklidir --
  // periyodik yoklama yasagi yerinde durur.
  // `null` ise (mevcut testler / durum vitrini) hicbir sey tetiklenmez.
  final Future<void> Function()? onYerelYazma;

  // GOREV-W2 T4: `null` ise (mevcut testler/durum vitrini) SERIT HIC CIZILMEZ
  // -- geriye donuk uyumlu, DepolamaSeridi'ye hic ulasilmaz.
  final ValueListenable<DepolamaDurumu>? depolama;

  const GorevListesiEkrani({
    super.key,
    required this.depo,
    this.onYenile,
    this.onYerelYazma,
    this.depolama,
  });

  @override
  State<GorevListesiEkrani> createState() => _GorevListesiEkraniState();
}

class _GorevListesiEkraniState extends State<GorevListesiEkrani> {
  late Stream<List<GorevGorunum>> _akis;

  /// ODEV.md §4(a): TEK SECIM (Onur kilidi ④ -- coklu secimin AND/OR
  /// semantigi ve arama alani KAPSAM DISI). `null` = suzme yok.
  /// 🔴 SUZME DART TARAFINDA: AYNI stream kullanilir, yeniden ABONE
  /// OLUNMAZ -- yeni bir sorgu acmak ara karede bos liste (ve BosDurum
  /// yanip sonmesi) dogururdu.
  String? _secilenEtiket;

  /// ODEV.md §4(a) ARAMA (Onur kilidi -- 15 Agu): her tusta CANLI, debounce
  /// YOK; suzme AYNI stream uzerinde, etiket cipiyle CARPILARAK yapilir.
  /// Durum yalniz bellektedir ⇒ sekme kapaninca KENDILIGINDEN sifirlanir
  /// (cip seciminin o76'da olculen davranisinin AYNISI).
  String _arama = '';
  final _aramaDenetleyici = TextEditingController();

  @override
  void initState() {
    super.initState();
    _akis = widget.depo.gorevlerGorunur();
  }

  @override
  void dispose() {
    _aramaDenetleyici.dispose();
    super.dispose();
  }

  /// Bos sonuc ekranindaki tek dokunus: aramayi VE cip secimini birlikte
  /// sifirlar (kilit maddesi 3 -- kullanici cikmazda birakilmaz).
  void _suzgecleriTemizle() {
    _aramaDenetleyici.clear();
    setState(() {
      _arama = '';
      _secilenEtiket = null;
    });
  }

  /// K112: once YEREL YAZMA tamamlanir, SONRA itme tetiklenir. Sira
  /// pazarliksizdir -- tersi olursa itme turu kuyrugu HENUZ BOS gorur ve
  /// tetikleyici sessizce hicbir sey yapmaz (bu, kapinin mutantidir).
  Future<void> _yerelYaz(Future<void> Function() yazma) async {
    await yazma();
    final tetik = widget.onYerelYazma;
    if (tetik != null) await tetik();
  }

  void _yenidenDene() {
    setState(() {
      _akis = widget.depo.gorevlerGorunur();
    });
  }

  /// ODEV.md §4(a): arama alani -- CIP SERIDININ USTUNDE (Onur kilidi ④:
  /// okuma sirasi ara -> daralt -> listele; AppBar acilmaz).
  ///
  /// `hintStyle` BILEREK verilir (varsayilan ipucu rengi tema turevidir ve
  /// kontrasti dusuk kalabilir). 🔴 OLCULDU (denetim, 15 Agu): bu alani
  /// HICBIR mevcut kapi olcmuyor -- `hintText` bir `Text(` olmadigi icin
  /// R1/R2/R4 statik tarayicisina gorunmez, alanin semantik dugumunde
  /// label/value BOS oldugu icin `textContrastGuideline` o dugumu ATLAR
  /// (`accessibility.dart` `shouldSkipNode`). Ipucu metni, ipucu rengi ve
  /// odak halkasinin TEK pini `test/arama_dilimi_test.dart`tedir; kapi
  /// butcesi ihlalde oldugu icin yeni kapi DOSYASI acilmadi.
  Widget _aramaAlani(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(MBosluk.m, MBosluk.s, MBosluk.m, 0),
      child: TextField(
        key: const ValueKey('arama_alani'),
        controller: _aramaDenetleyici,
        onChanged: (deger) => setState(() => _arama = deger),
        style: MTipo.govdeM.copyWith(color: MRenk.metin(context)),
        decoration: InputDecoration(
          isDense: true,
          hintText: Metinler.aramaIpucu,
          hintStyle: MTipo.govdeM.copyWith(color: MRenk.metinIkincil(context)),
          // Dekoratiftir, DOKUNULABILIR DEGIL ⇒ A11Y-3 (ikon-yalniz BUTON
          // yasagi) ve dokunma hedefi kapisi kapsamina GIRMEZ.
          prefixIcon: Icon(
            Icons.search,
            size: MOlcu.ikon,
            color: MRenk.metinIkincil(context),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MRadius.m),
            borderSide: BorderSide(color: MRenk.kenarlikEtkilesim(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MRadius.m),
            borderSide: BorderSide(
              width: MOlcu.odakKalinlik,
              color: MRenk.birincil(context),
            ),
          ),
        ),
      ),
    );
  }

  /// ODEV.md §4(a): süzme çip şeridi -- listenin ÜSTÜNDE, yatay kaydirilir.
  /// "Tümü" cipi suzmeyi kaldirir; SECIM metne gore degil `secili == null`
  /// durumuna gore verilir (bir kullanici "Tümü" adli bir etiket yazsa bile
  /// davranis bozulmaz).
  Widget _etiketSeridi(List<String> etiketler, String? secili) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MBosluk.m,
        vertical: MBosluk.xs,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              key: const ValueKey('etiket_cipi_tumu'),
              label: Text(
                Metinler.etiketTumu,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              selected: secili == null,
              onSelected: (_) => setState(() => _secilenEtiket = null),
            ),
            for (final etiket in etiketler) ...[
              SizedBox(width: MBosluk.xs),
              ChoiceChip(
                key: ValueKey('etiket_cipi_$etiket'),
                label: Text(
                  etiket,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                selected: secili == etiket,
                // Ikinci dokunus suzmeyi KALDIRIR (secili cipe tekrar
                // dokunmak kullanicinin bekledigi geri alma yoludur).
                onSelected: (_) => setState(
                  () => _secilenEtiket = secili == etiket ? null : etiket,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MRenk.yuzey(context),
      appBar: widget.onYenile == null
          ? null
          : AppBar(
              backgroundColor: MRenk.yuzey(context),
              elevation: 0,
              actions: [
                IconButton(
                  key: const ValueKey('elle_yenile_dugmesi'),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Yenile',
                  onPressed: () => widget.onYenile!(),
                ),
              ],
            ),
      body: SafeArea(
        child: Column(
          children: [
            // GOREV-W2 T4: listenin USTUNE -- `depolama == null` iken
            // ValueListenableBuilder hic kurulmaz, DepolamaSeridi hic
            // olusmaz (geriye donuk uyumlu).
            if (widget.depolama != null)
              ValueListenableBuilder<DepolamaDurumu>(
                valueListenable: widget.depolama!,
                builder: (context, durum, _) => DepolamaSeridi(durum: durum),
              ),
            Expanded(
              child: StreamBuilder<List<GorevGorunum>>(
                stream: _akis,
                builder: (context, anlik) {
                  if (anlik.hasError) {
                    return HataDurumu(onYenidenDene: _yenidenDene);
                  }
                  if (!anlik.hasData) {
                    return const YuklenmeDurumu();
                  }
                  final gorunumler = anlik.data!;
                  if (gorunumler.isEmpty) {
                    return const BosDurum();
                  }
                  final tumEtiketler = <String>{
                    for (final g in gorunumler) ...g.gorev.etiketler,
                  }.toList()..sort();
                  // Secili etiket listeden KAYBOLDUYSA (son tasiyicisi
                  // silindi/etiketi kaldirildi) suzme KENDILIGINDEN duser.
                  // `setState` BUILD ICINDE CAGRILMAZ -- yerel degiskenle
                  // cozulur, alan bir sonraki dokunusta zaten guncellenir.
                  final secili = tumEtiketler.contains(_secilenEtiket)
                      ? _secilenEtiket
                      : null;
                  // 🔴 TEK SUZME YOLU: etiket cipi ile arama AYNI `where`da
                  // CARPILIR. Ikinci bir suzme yolu acmak `kanonik-kopya`
                  // riskidir; eslesme kurali da burada DEGIL, saf
                  // `aramaEslesir`dedir (bos sorgu = suzme yok orada karara
                  // baglanir, burada IKINCI KEZ kontrol EDILMEZ).
                  final suzulmus = gorunumler
                      .where(
                        (g) =>
                            (secili == null ||
                                g.gorev.etiketler.contains(secili)) &&
                            aramaEslesir(baslik: g.gorev.baslik, sorgu: _arama),
                      )
                      .toList();
                  return Column(
                    children: [
                      _aramaAlani(context),
                      // Etiketsiz projede serit HIC CIZILMEZ ⇒ mevcut duzen
                      // testleri (bos/yerel/hata vitrinleri dahil) ETKILENMEZ.
                      if (tumEtiketler.isNotEmpty)
                        _etiketSeridi(tumEtiketler, secili),
                      Expanded(
                        child: suzulmus.isEmpty
                            // Gorev VAR ama suzgecler hicbirini gecirmiyor:
                            // "Henüz görev yok." demek YALAN olurdu.
                            ? BosDurum.eslesmeYok(
                                onSuzgecleriTemizle: _suzgecleriTemizle,
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: MBosluk.m,
                                ),
                                itemCount: suzulmus.length,
                                itemBuilder: (context, i) {
                                  final gorunum = suzulmus[i];
                                  return GorevSatiri(
                                    key: ValueKey(
                                      'gorev_satiri_${gorunum.gorev.id}',
                                    ),
                                    gorev: gorunum.gorev,
                                    onTamamlaDegisti: (deger) => unawaited(
                                      _yerelYaz(
                                        () => widget.depo.tamamlaGeriAl(
                                          gorunum.gorev.id,
                                          tamamlandi: deger,
                                        ),
                                      ),
                                    ),
                                    senkronDurumu: gorunum.senkronDurumu,
                                    cakismaVarMi: gorunum.cakismaVarMi,
                                    depo: widget.depo,
                                    // IS-EMRI-o68 kriter 3 + ODEV.md §4(a):
                                    // duzenleme boylece URUN YOLUNDAN cagrilir --
                                    // `onTamamlaDegisti`'nin BIREBIR AYNI deseni
                                    // (K112: once YEREL YAZMA, sonra itme --
                                    // `_yerelYaz` sarmalayicisi ATLANMAZ).
                                    onAyrintilarDuzenlendi: (degisiklik) =>
                                        unawaited(
                                          _yerelYaz(
                                            () =>
                                                widget.depo.ayrintilariGuncelle(
                                                  gorunum.gorev.id,
                                                  baslik: degisiklik.baslik,
                                                  oncelik: degisiklik.oncelik,
                                                  sonTarih: degisiklik.sonTarih,
                                                  etiketEklenen:
                                                      degisiklik.etiketEklenen,
                                                  etiketSilinen:
                                                      degisiklik.etiketSilinen,
                                                ),
                                          ),
                                        ),
                                    // IS-EMRI-o72: duzenleme kablosunun BIREBIR
                                    // AYNI deseni (K112: once YEREL YAZMA, sonra
                                    // itme -- `_yerelYaz` sarmalayicisi ATLANMAZ).
                                    onSil: () => unawaited(
                                      _yerelYaz(
                                        () => widget.depo.sil(gorunum.gorev.id),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
            GorevEkleAlani(
              // K112: ONCE yerel yazma, SONRA itme (`_yerelYaz` sirayi
              // pazarliksiz tutar). Dort alan TEK `ekle()` cagrisina gider ⇒
              // TEK `WireOp`.
              // 🔴 EKLEME SUZGECLERI SIFIRLAR [Onur kilidi, 16 Agu 2026].
              // OLCULDU (bagimsiz denetim, 15 Agu): suzgec acikken eklenen
              // gorev listeye GIRIYOR ama ekranda GORUNMUYORDU ve hicbir
              // geri bildirim yoktu (depoda 2 gorev / ekranda 1 satir /
              // bildirim 0) -- kullanici yazdigini kaybettigini sanardi.
              // SENKRON sifirlanir: akis yeni degeri yayinlamadan once
              // suzgec duser, ara karede satir KAYBOLMAZ. `onEkle` yalnizca
              // dogrulamayi GECEN girdide atesler (`gorevBasligiDogrula`) ⇒
              // bos/gecersiz girdi suzgeci SIFIRLAMAZ.
              onEkle: (istek) {
                _suzgecleriTemizle();
                unawaited(
                  _yerelYaz(
                    () => widget.depo.ekle(
                      istek.baslik,
                      oncelik: istek.oncelik,
                      sonTarih: istek.sonTarih,
                      etiketler: istek.etiketler.toSet(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

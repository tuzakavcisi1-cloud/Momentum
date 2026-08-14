import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../veri/depolama_durumu.dart';
import '../veri/gorev_deposu.dart';
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

  @override
  void initState() {
    super.initState();
    _akis = widget.depo.gorevlerGorunur();
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
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: MBosluk.m),
                    itemCount: gorunumler.length,
                    itemBuilder: (context, i) {
                      final gorunum = gorunumler[i];
                      return GorevSatiri(
                        key: ValueKey('gorev_satiri_${gorunum.gorev.id}'),
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
                        // IS-EMRI-o68 kriter 3 + ODEV.md §4(a): duzenleme
                        // boylece URUN YOLUNDAN cagrilir --
                        // `onTamamlaDegisti`'nin BIREBIR AYNI deseni (K112:
                        // once YEREL YAZMA, sonra itme -- `_yerelYaz`
                        // sarmalayicisi ATLANMAZ).
                        onAyrintilarDuzenlendi: (degisiklik) => unawaited(
                          _yerelYaz(
                            () => widget.depo.ayrintilariGuncelle(
                              gorunum.gorev.id,
                              baslik: degisiklik.baslik,
                              oncelik: degisiklik.oncelik,
                              sonTarih: degisiklik.sonTarih,
                            ),
                          ),
                        ),
                        // IS-EMRI-o72: duzenleme kablosunun BIREBIR AYNI
                        // deseni (K112: once YEREL YAZMA, sonra itme --
                        // `_yerelYaz` sarmalayicisi ATLANMAZ).
                        onSil: () => unawaited(
                          _yerelYaz(() => widget.depo.sil(gorunum.gorev.id)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            GorevEkleAlani(
              onEkle: (baslik) => unawaited(
                _yerelYaz(() => widget.depo.ekle(baslik)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

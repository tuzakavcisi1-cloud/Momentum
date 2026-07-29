import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../sunum/bos_durum.dart';
import '../sunum/gorev_satiri.dart';
import '../sunum/hata_durumu.dart';
import '../sunum/senkron_rozeti.dart';
import '../sunum/yukleme_durumu.dart';
import '../veri/gorev_deposu.dart';

/// F5 -- DURUM VITRINI: olu tuzagi engeller (gercek veri akmadan da 8 durum
/// GORULEBILIR ve MCP/G5 kosulabilir), ama olcumun TEK yeri degildir --
/// G5 ayrica gercek GorevListesiEkrani uzerinde de kosar (bos*yerel*hata).
///
/// `--dart-define=DURUM_VITRINI=true` ile acilir. Sabit saat/idUret (F8):
/// hicbir alan DateTime.now()/uretimIdUret() cagirmaz, hepsi sabit literal.
/// Kaydirilabilir bir SUTUNDUR (gercek liste ListView kisiti altindadir,
/// vitrin degildir -- F5 gerekcesi).
class DurumVitrini extends StatelessWidget {
  const DurumVitrini({super.key});

  static final _sabitSaat = DateTime.utc(2026, 1, 1, 12);

  Gorev _ornekGorev(String id, String baslik, {bool tamamlandi = false}) {
    return Gorev(
      id: id,
      baslik: baslik,
      tamamlandi: tamamlandi,
      olusturuldu: _sabitSaat,
      guncellendi: _sabitSaat,
      senkronDurumu: 'yerel',
      silindi: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MRenk.yuzey(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(MBosluk.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                key: const ValueKey('vitrin_bos'),
                height: 160,
                child: const BosDurum(),
              ),
              SizedBox(
                key: const ValueKey('vitrin_yukleniyor'),
                height: 160,
                child: const YuklenmeDurumu(),
              ),
              GorevSatiri(
                key: const ValueKey('vitrin_yerel'),
                gorev: _ornekGorev('vitrin-yerel', 'Sut al'),
                onTamamlaDegisti: (_) {},
                senkronDurumu: SenkronDurumTuru.yerel,
              ),
              GorevSatiri(
                key: const ValueKey('vitrin_gonderilmemis'),
                gorev: _ornekGorev('vitrin-gonderilmemis', 'Sozlesmeyi imzala'),
                onTamamlaDegisti: (_) {},
                senkronDurumu: SenkronDurumTuru.gonderilmemis,
              ),
              GorevSatiri(
                key: const ValueKey('vitrin_kuyrukta'),
                gorev: _ornekGorev('vitrin-kuyrukta', 'Ekmek al'),
                onTamamlaDegisti: (_) {},
                senkronDurumu: SenkronDurumTuru.kuyrukta,
              ),
              GorevSatiri(
                key: const ValueKey('vitrin_senkronize'),
                gorev: _ornekGorev(
                  'vitrin-senkronize',
                  'Faturalari ode',
                  tamamlandi: true,
                ),
                onTamamlaDegisti: (_) {},
                senkronDurumu: SenkronDurumTuru.senkronize,
              ),
              GorevSatiri(
                key: const ValueKey('vitrin_cevrimdisi'),
                gorev: _ornekGorev('vitrin-cevrimdisi', 'Kitap oku'),
                onTamamlaDegisti: (_) {},
                senkronDurumu: SenkronDurumTuru.cevrimdisi,
              ),
              GorevSatiri(
                key: const ValueKey('vitrin_cakisma'),
                gorev: _ornekGorev('vitrin-cakisma', 'Toplanti hazirla'),
                onTamamlaDegisti: (_) {},
                cakismaVarMi: true,
              ),
              // GOREV-R10 D7 [K75]: cakisma DIK KANALDIR -- taban rozeti
              // BASTIRMAZ. Bu kart ikisini AYNI ANDA gosterir (cakisma
              // ikonu + "Gönderilmemiş değişiklik"), DESIGN.md v2 §4'teki
              // "iki rozet yan yana" senaryosunun vitrin karsiligidir.
              GorevSatiri(
                key: const ValueKey('vitrin_cakisma_bilesik'),
                gorev: _ornekGorev('vitrin-cakisma-bilesik', 'Rapor gonder'),
                onTamamlaDegisti: (_) {},
                senkronDurumu: SenkronDurumTuru.gonderilmemis,
                cakismaVarMi: true,
              ),
              SizedBox(
                key: const ValueKey('vitrin_hata'),
                height: 220,
                child: HataDurumu(onYenidenDene: () {}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

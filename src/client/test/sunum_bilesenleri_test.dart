import 'package:client/design/metinler.dart';
import 'package:client/design/tema.dart';
import 'package:client/sunum/bos_durum.dart';
import 'package:client/sunum/cakisma_rozeti.dart';
import 'package:client/sunum/dogal_dil_ayristirici.dart';
import 'package:client/sunum/gorev_ekle_alani.dart';
import 'package:client/sunum/gorev_satiri.dart';
import 'package:client/sunum/hata_durumu.dart';
import 'package:client/sunum/senkron_rozeti.dart';
import 'package:client/sunum/yukleme_durumu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _sarmala(Widget cocuk, {Brightness parlaklik = Brightness.light}) {
  return MaterialApp(theme: MomentumTema.olustur(parlaklik), home: cocuk);
}

Gorev _sahteGorev({bool tamamlandi = false}) => Gorev(
  id: 'g1',
  baslik: 'Sut al',
  tamamlandi: tamamlandi,
  olusturuldu: DateTime.utc(2026, 7, 26),
  guncellendi: DateTime.utc(2026, 7, 26),
  senkronDurumu: 'yerel',
  silindi: false,
);

/// GOREV-SS2 [T5]: `CakismaRozeti`/`CakismaCozumSayfasi` artik `entityId`+
/// `depo` alir (M184) -- bu dosyaya OZGU minimal sahte depo.
class _SahteDepo implements GorevDeposu {
  @override
  Stream<List<GorevGorunum>> gorevlerGorunur() => const Stream.empty();
  @override
  Future<void> ekle(
    String baslik, {
    int? oncelik,
    DateTime? sonTarih,
    Set<String> etiketler = const {},
    String? projeId,
  }) async {}
  @override
  Future<void> duzenle(String id, String yeniBaslik) async {}

  // ODEV.md §4(a): arayuze eklenen yeni yazma yolu. Bu sahte depo onu
  // KULLANMAZ -- govde bilerek bostur (mevcut `duzenle` stub'inin aynisi).
  @override
  Future<void> ayrintilariGuncelle(
    String id, {
    Yazim<String>? baslik,
    Yazim<int?>? oncelik,
    Yazim<DateTime?>? sonTarih,
    Yazim<String?>? projeId,
    Set<String>? etiketEklenen,
    Set<String>? etiketSilinen,
  }) async {}
  @override
  Future<void> tamamlaGeriAl(String id, {required bool tamamlandi}) async {}
  @override
  Future<void> sil(String id) async {}
  @override
  Stream<List<CakismaKaydi>> cakismaKayitlariniIzle(String entityId) =>
      Stream.value(const []);
  @override
  Future<void> cakismaCoz(String entityId, CakismaSecimi secim) async {}

  // IS-EMRI-o85-A: arayuze eklenen liste (Project) yazma yolu. Bu sahte
  // depo onu KULLANMAZ -- govde bilerek bostur (mevcut stub'lerin aynisi).
  @override
  Stream<List<Proje>> listelerGorunur() => Stream.value(const []);
  @override
  Future<void> listeEkle(String ad) async {}
  @override
  Future<void> listeDuzenle(String id, String yeniAd) async {}
  @override
  Future<void> listeSil(String id) async {}
}

void main() {
  group('MomentumTema', () {
    test('acik ve koyu ThemeData ayri brightness tasir', () {
      final acik = MomentumTema.olustur(Brightness.light);
      final koyu = MomentumTema.olustur(Brightness.dark);
      expect(acik.brightness, Brightness.light);
      expect(koyu.brightness, Brightness.dark);
      expect(acik.colorScheme.primary, isNot(koyu.colorScheme.primary));
    });
  });

  group('BosDurum', () {
    testWidgets('bos durum metnini gosterir', (tester) async {
      await tester.pumpWidget(_sarmala(const Scaffold(body: BosDurum())));
      expect(find.text(Metinler.bosDurum), findsOneWidget);
    });
  });

  group('YuklenmeDurumu', () {
    testWidgets('yukleniyor metnini gosterir', (tester) async {
      await tester.pumpWidget(_sarmala(const Scaffold(body: YuklenmeDurumu())));
      expect(find.text(Metinler.yukleniyor), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('HataDurumu', () {
    testWidgets('hata metni + yeniden dene dugmesi calisir', (tester) async {
      var tiklandi = false;
      await tester.pumpWidget(
        _sarmala(
          Scaffold(body: HataDurumu(onYenidenDene: () => tiklandi = true)),
        ),
      );
      expect(find.text(Metinler.birSeylerTersGitti), findsOneWidget);
      await tester.tap(find.text(Metinler.yenidenDene));
      expect(tiklandi, isTrue);
    });
  });

  group('SenkronRozeti', () {
    testWidgets('yerel: saat ikonu + metin', (tester) async {
      await tester.pumpWidget(
        _sarmala(
          const Scaffold(body: SenkronRozeti(durum: SenkronDurumTuru.yerel)),
        ),
      );
      expect(find.byIcon(Icons.schedule), findsOneWidget);
      // GOREV-A7 [K85 / D-A7-1]: GORUNUR metin KISALDI (236 px'te 2.0x'te
      // 2 satir), TAM metin Semantics(label:)'da DEGISMEDEN kaldi -- ekran
      // okuyucu bilgi KAYBETMEZ. Testin ikinci satiri bunu ISPAT EDER;
      // yalniz kisa metni sinamak, tam metnin sessizce kaybolmasina izin
      // verirdi. Semantics agacinin TAM olcumu G15/A13'tedir.
      expect(find.text(Metinler.rozetKisaYerel), findsOneWidget);
      expect(
        SenkronRozeti.tamMetinIcin(SenkronDurumTuru.yerel),
        Metinler.yalnizcaBuCihazda,
      );
    });

    testWidgets('kuyrukta: donen ok + metin', (tester) async {
      await tester.pumpWidget(
        _sarmala(
          const Scaffold(body: SenkronRozeti(durum: SenkronDurumTuru.kuyrukta)),
        ),
      );
      expect(find.byType(AnimatedRotation), findsOneWidget);
      expect(find.text(Metinler.gonderiliyor), findsOneWidget);
    });

    testWidgets('senkronize: gorunur rozet yok (gurultu azaltma)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _sarmala(
          const Scaffold(
            body: SenkronRozeti(durum: SenkronDurumTuru.senkronize),
          ),
        ),
      );
      expect(find.byType(Icon), findsNothing);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('cevrimdisi: bulut-kapali ikonu + metin', (tester) async {
      await tester.pumpWidget(
        _sarmala(
          const Scaffold(
            body: SenkronRozeti(durum: SenkronDurumTuru.cevrimdisi),
          ),
        ),
      );
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      // GOREV-A7 [K85 / D-A7-1]: gorunur "Çevrimdışı" (262,5 px / 2 satir);
      // tam metin (1102,5 px / 6 satir) Semantics(label:)'da kalir.
      expect(find.text(Metinler.rozetKisaCevrimdisi), findsOneWidget);
      expect(
        SenkronRozeti.tamMetinIcin(SenkronDurumTuru.cevrimdisi),
        Metinler.cevrimdisiKaydedildi,
      );
    });
  });

  group('GorevSatiri', () {
    testWidgets('baslik + onay kutusu + rozet gosterir, onTap tasimaz', (
      tester,
    ) async {
      bool? sonDeger;
      await tester.pumpWidget(
        _sarmala(
          Scaffold(
            body: GorevSatiri(
              gorev: _sahteGorev(),
              onTamamlaDegisti: (d) => sonDeger = d,
            ),
          ),
        ),
      );
      expect(find.text('Sut al'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);

      await tester.tap(find.byType(Checkbox));
      expect(sonDeger, isTrue);
    });

    testWidgets(
      'GOREV-R10 D7: cakisma varsa CakismaRozeti VE taban SenkronRozeti '
      'BIRLIKTE gosterir (cakisma taban rozeti bastirmaz)',
      (tester) async {
        await tester.pumpWidget(
          _sarmala(
            Scaffold(
              body: GorevSatiri(
                gorev: _sahteGorev(),
                onTamamlaDegisti: (_) {},
                cakismaVarMi: true,
              ),
            ),
          ),
        );
        expect(find.byType(CakismaRozeti), findsOneWidget);
        expect(find.byType(SenkronRozeti), findsOneWidget);
      },
    );
  });

  group('CakismaRozeti', () {
    testWidgets('dokununca cozum sayfasi acar', (tester) async {
      await tester.pumpWidget(
        _sarmala(
          Scaffold(
            body: CakismaRozeti(entityId: 'g1', depo: _SahteDepo()),
          ),
        ),
      );
      await tester.tap(find.byType(CakismaRozeti));
      await tester.pumpAndSettle();
      expect(find.byType(CakismaCozumSayfasi), findsOneWidget);
      // GOREV-SS2 [T5]: sahte depo SIFIR cakisma kaydi doner -- BOS DURUM
      // ZORUNLU (D-SS2-8): 0 kayitla acilis NORMAL haldir.
      expect(find.text(Metinler.cakismaKaydiYok), findsOneWidget);
    });
  });

  group('GorevEkleAlani', () {
    testWidgets('metin girip ekle dugmesine basinca onEkle cagrilir', (
      tester,
    ) async {
      DogalDilSonucu? eklenen;
      await tester.pumpWidget(
        _sarmala(Scaffold(body: GorevEkleAlani(onEkle: (v) => eklenen = v))),
      );
      await tester.enterText(find.byType(TextField), 'Ekmek al');
      await tester.tap(find.byIcon(Icons.add));
      expect(eklenen?.baslik, 'Ekmek al');
    });

    testWidgets('bos metinle onEkle cagrilmaz', (tester) async {
      DogalDilSonucu? eklenen;
      await tester.pumpWidget(
        _sarmala(Scaffold(body: GorevEkleAlani(onEkle: (v) => eklenen = v))),
      );
      await tester.tap(find.byIcon(Icons.add));
      expect(eklenen, isNull);
    });
  });
}

// G5 -- A11Y KAPISI (K57/T9). Kontrast HARIC her olcum burada; ayni testler
// hem durum vitrininde hem gercek GorevListesiEkrani'nde (bos*yerel*hata)
// kosar (spec SS5 G5 -- KOSUM YERI). Bu dosya dart:io ICERMEZ (web'de de
// koşar); kontrast ve statik dosya taramasi ayri @TestOn('vm') dosyalarindadir.

import 'package:client/design/metinler.dart';
import 'package:client/design/tokens.dart';
import 'package:client/sunum/cakisma_rozeti.dart';
import 'package:client/sunum/gorev_ekle_alani.dart';
import 'package:client/sunum/gorev_listesi_ekrani.dart';
import 'package:client/sunum/senkron_rozeti.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/vitrin/durum_vitrini.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// F6 kilidi -- araclar/fixture/metinler-kilit.json ile BIREBIR (donduruldu,
// kilit aninda dondu). Bu harita fixture'in DART TARAFINDAKI aynasidir;
// dart:io olmadan (web-uyumlu) karsilastirma yapabilmek icin buraya
// gomulmustur -- kaynak fixture dosyasi degismedikce bu ikisi es zamanli
// tutulur.
const Map<String, String> _fixtureGorunur = {
  'yalnizcaBuCihazda': 'Yalnızca bu cihazda',
  'gonderiliyor': 'Gönderiliyor',
  'cevrimdisiKaydedildi': 'Çevrimdışısınız. Değişiklikler kaydedildi.',
  'cakismaVar': 'Bu görev başka bir cihazda da değişti.',
  'bosDurum': 'Henüz görev yok. Aşağıdan ekleyin.',
  'birSeylerTersGitti': 'Bir şeyler ters gitti.',
  'yenidenDene': 'Yeniden dene',
  'yukleniyor': 'Yükleniyor',
};

// GOREV-A7 [K85 / spec v4 §4/D-A7-1] -- ROZETIN GORUNUR KISA metinleri.
// 🔴 UC DOSYA ES ZAMANLI: lib/design/metinler.dart ·
// araclar/fixture/metinler-kilit.json ("rozetKisaGorunur" grubu) · bu
// harita. Biri unutulursa asagidaki test ISIRIR -- bu ISIRMA BEKLENEN
// davranistir ve kapinin CALISTIGININ kanitidir (spec kabul kriteri 3).
//
// Neden AYRI harita (`_fixtureGorunur`a eklenmedi): bu uc dizge F6'nin
// KILITLI 13 dizgesine DAHIL DEGILDIR -- GOREV-slice-3b §T-metin (K59,
// sha F0C3A75A) "13 dizge" der ve o belge KILITLIDIR; uc dizgeyi
// `_fixtureGorunur`a katmak o kilitli belgenin sayi iddiasini BAYAT
// birakirdi (projede olculmus 'bayat-iddia' kusur sinifi). GOREV-R10
// `gonderilmemisDegisiklik` icin AYNI deseni kurmustu. Spec'in istedigi
// sey uc dosyanin ES ZAMANLI olmasidir; o kosul burada TAM saglanir.
const Map<String, String> _fixtureRozetKisa = {
  'rozetKisaYerel': 'Bu cihazda',
  'rozetKisaCevrimdisi': 'Çevrimdışı',
  'rozetKisaGonderilmedi': 'Gönderilmedi',
};

const Map<String, String> _fixtureDuyuru = {
  'duyuruGorevlerYukleniyor': 'Görevler yükleniyor',
  'duyuruSenkronizeEdildi': 'Senkronize edildi',
  'duyuruCevrimdisi': 'Çevrimdışı',
  'duyuruCakismaVar': 'Çakışma var',
  'duyuruHata': 'Hata',
};

/// SystemChannels.accessibility'i mock'lar; SemanticsService.sendAnnouncement
/// / announce'un GONDERDIGI dizgeleri yakalar (A11Y-7).
List<String> _duyurulariYakala(WidgetTester tester) {
  final yakalanan = <String>[];
  tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
    SystemChannels.accessibility,
    (dynamic mesaj) async {
      final harita = mesaj as Map;
      if (harita['type'] == 'announce') {
        final veri = harita['data'] as Map;
        yakalanan.add(veri['message'] as String);
      }
      return null;
    },
  );
  return yakalanan;
}

// VARSAYILAN azaltilmisAnimasyon: true -- SenkronRozeti'nin 'kuyrukta' varyanti
// (_DonenOk) gercek bir Timer.periodic baslatir; A11Y-5'in KENDI ISI bunu
// olcmek disinda, geri kalan testlerin animasyonla ilgisi yok ve gercek
// zamanlayici, testler arasi "Timer is still pending" INVARYANT ihlaline yol
// aciyordu (olculdu, ilk kosumda). Sadece gercekten animasyon TEST EDEN yer
// bunu false'a cevirir.
Widget _vitrinSarmalayici({bool azaltilmisAnimasyon = true, double textScale = 1.0}) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        final taban = MediaQuery.of(context);
        return MediaQuery(
          data: taban.copyWith(
            disableAnimations: azaltilmisAnimasyon,
            textScaler: TextScaler.linear(textScale),
          ),
          child: const DurumVitrini(),
        );
      },
    ),
  );
}

/// GERCEK EKRAN'i (GorevListesiEkrani) veri katmanindan izole eden SABIT
/// depo -- F4'un dikisinin (GorevDeposu arayuzu) tam da bunun icin var
/// olmasi: G5'in ilgisi UI/erisilebilirliktir, gercek Drift davranisi
/// zaten G7'de (test/veri_kapisi_test.dart, 6 test) ayrica kapsamli
/// dogrulanir. Drift/FFI'i widget-pump dongusune sokmamak, testleri hem
/// daha hizli hem daha az kirilgan yapar.
class _SabitDepo implements GorevDeposu {
  final List<Gorev> _gorevler;
  _SabitDepo(this._gorevler);

  // GOREV-R10 D5: arayuz artik GorevGorunum doner -- bu sabit depo sayim
  // tasimadigi icin (test verisi elle kurulur, kuyruk yok) daima sifir
  // U/B/Z ile rozetDikisi'ni cagirir; taban SALT K'nin (senkronDurumu)
  // esitlemesinden gelir.
  @override
  Stream<List<GorevGorunum>> gorevlerGorunur() => Stream.value(
    _gorevler.map((gorev) {
      final (durum, cakismaVarMi) = rozetDikisi(
        gorev.senkronDurumu,
        ucusta: 0,
        bekleyen: 0,
        zehirli: 0,
      );
      return GorevGorunum(
        gorev: gorev,
        senkronDurumu: durum,
        cakismaVarMi: cakismaVarMi,
      );
    }).toList(),
  );
  @override
  Future<void> ekle(String baslik) async {}
  @override
  Future<void> duzenle(String id, String yeniBaslik) async {}
  @override
  Future<void> tamamlaGeriAl(String id, {required bool tamamlandi}) async {}
  @override
  Future<void> sil(String id) async {}
  @override
  Stream<List<CakismaKaydi>> cakismaKayitlariniIzle(String entityId) => Stream.value(const []);
  @override
  Future<void> cakismaCoz(String entityId, CakismaSecimi secim) async {}
}

/// A11Y-7/hata durumunu tetiklemek icin: akis HER ZAMAN hata verir.
class _HataliDepo implements GorevDeposu {
  @override
  Stream<List<GorevGorunum>> gorevlerGorunur() =>
      Stream.error(StateError('mock hata'));
  @override
  Future<void> ekle(String baslik) async {}
  @override
  Future<void> duzenle(String id, String yeniBaslik) async {}
  @override
  Future<void> tamamlaGeriAl(String id, {required bool tamamlandi}) async {}
  @override
  Future<void> sil(String id) async {}
  @override
  Stream<List<CakismaKaydi>> cakismaKayitlariniIzle(String entityId) => Stream.value(const []);
  @override
  Future<void> cakismaCoz(String entityId, CakismaSecimi secim) async {}
}

Gorev _ornekGorev(String baslik) => Gorev(
  id: 'g5-ornek',
  baslik: baslik,
  tamamlandi: false,
  olusturuldu: DateTime.utc(2026, 7, 27, 12),
  guncellendi: DateTime.utc(2026, 7, 27, 12),
  senkronDurumu: 'yerel',
  silindi: false,
);

Widget _gercekEkranSarmalayici(GorevDeposu depo) {
  return MaterialApp(home: GorevListesiEkrani(depo: depo));
}

void main() {
  group('metin (F6 kilidi -- fixture/metinler-kilit.json ile 13 dizge)', () {
    test('gorunur (8) birebir', () {
      expect(Metinler.yalnizcaBuCihazda, _fixtureGorunur['yalnizcaBuCihazda']);
      expect(Metinler.gonderiliyor, _fixtureGorunur['gonderiliyor']);
      expect(Metinler.cevrimdisiKaydedildi, _fixtureGorunur['cevrimdisiKaydedildi']);
      expect(Metinler.cakismaVar, _fixtureGorunur['cakismaVar']);
      expect(Metinler.bosDurum, _fixtureGorunur['bosDurum']);
      expect(Metinler.birSeylerTersGitti, _fixtureGorunur['birSeylerTersGitti']);
      expect(Metinler.yenidenDene, _fixtureGorunur['yenidenDene']);
      expect(Metinler.yukleniyor, _fixtureGorunur['yukleniyor']);
    });

    test('rozet kisa gorunur (3) birebir -- GOREV-A7, F6 13 dizgesine DAHIL DEGIL', () {
      expect(Metinler.rozetKisaYerel, _fixtureRozetKisa['rozetKisaYerel']);
      expect(Metinler.rozetKisaCevrimdisi, _fixtureRozetKisa['rozetKisaCevrimdisi']);
      expect(Metinler.rozetKisaGonderilmedi, _fixtureRozetKisa['rozetKisaGonderilmedi']);
      // Kisa metin TAM metinden GERCEKTEN kisa olmali -- aksi halde
      // D-A7-1'in butun gerekcesi (236 px'te 2 satir) kaybolur.
      expect(
        Metinler.rozetKisaYerel.length,
        lessThan(Metinler.yalnizcaBuCihazda.length),
      );
      expect(
        Metinler.rozetKisaCevrimdisi.length,
        lessThan(Metinler.cevrimdisiKaydedildi.length),
      );
      expect(
        Metinler.rozetKisaGonderilmedi.length,
        lessThan(Metinler.gonderilmemisDegisiklik.length),
      );
    });

    test('semantics duyurusu (5) birebir', () {
      expect(Metinler.duyuruGorevlerYukleniyor, _fixtureDuyuru['duyuruGorevlerYukleniyor']);
      expect(Metinler.duyuruSenkronizeEdildi, _fixtureDuyuru['duyuruSenkronizeEdildi']);
      expect(Metinler.duyuruCevrimdisi, _fixtureDuyuru['duyuruCevrimdisi']);
      expect(Metinler.duyuruCakismaVar, _fixtureDuyuru['duyuruCakismaVar']);
      expect(Metinler.duyuruHata, _fixtureDuyuru['duyuruHata']);
    });
  });

  group('DURUM VITRINI', () {
    testWidgets('A11Y-1: androidTapTargetGuideline', (tester) async {
      final tutamac = tester.ensureSemantics();
      await tester.pumpWidget(_vitrinSarmalayici());
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      tutamac.dispose();
    });

    testWidgets('A11Y-3: labeledTapTargetGuideline', (tester) async {
      final tutamac = tester.ensureSemantics();
      await tester.pumpWidget(_vitrinSarmalayici());
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      tutamac.dispose();
    });

    testWidgets('A11Y-5: disableAnimations altinda tum sureler 0', (tester) async {
      await tester.pumpWidget(_vitrinSarmalayici(azaltilmisAnimasyon: true));
      await tester.pump();
      final donenOklar = tester.widgetList<AnimatedRotation>(find.byType(AnimatedRotation));
      expect(donenOklar, isNotEmpty);
      for (final w in donenOklar) {
        expect(w.duration, Duration.zero);
      }
      final yumusatmalar = tester.widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(yumusatmalar, isNotEmpty);
      for (final w in yumusatmalar) {
        expect(w.duration, Duration.zero);
      }
    });

    testWidgets(
      'A11Y-6: yerel/kuyrukta/cevrimdisi/cakisma rozetlerinde ikon VE metin dugumu',
      (tester) async {
        final tutamac = tester.ensureSemantics();
        await tester.pumpWidget(_vitrinSarmalayici());
        // ONEMLI: GorevSatiri'nin KENDI baslik Text'i HER ZAMAN vardir --
        // taramayi TUM satira degil, YALNIZ rozet alt-agacina (SenkronRozeti/
        // CakismaRozeti) daraltmak GEREKIR; yoksa satirin baslik metni rozetin
        // KENDI metnini taklit eder ve M17 KACAR (olculdu, ilk kosumda).
        //
        // "metin dugumu" spec'te "semantics AGACINDA" gecer (widget agacinda
        // degil): SenkronRozeti gorunur bir Text tasir, CakismaRozeti ise
        // SADECE Semantics(label:) ile (kucuk bir ikon-rozettir, govdesinde
        // Text YOKTUR -- gercek metin dokununca acilan sayfadadir). Ikisi de
        // GECERLI "metin dugumu" bicimidir; OR ile olculur (olculdu, ilk
        // kosumda: sadece find.byType(Text) CakismaRozeti'nde YANLIS-POZITIF
        // FAIL uretiyordu).
        const rozetTurleri = <String, Type>{
          'vitrin_yerel': SenkronRozeti,
          'vitrin_kuyrukta': SenkronRozeti,
          'vitrin_cevrimdisi': SenkronRozeti,
          'vitrin_cakisma': CakismaRozeti,
        };
        for (final girdi in rozetTurleri.entries) {
          final satir = find.byKey(ValueKey(girdi.key));
          expect(satir, findsOneWidget, reason: girdi.key);
          final rozet = find.descendant(
            of: satir,
            matching: find.byWidgetPredicate((w) => w.runtimeType == girdi.value),
          );
          expect(rozet, findsOneWidget, reason: '${girdi.key} -- rozet bulunamadi');
          expect(
            find.descendant(of: rozet, matching: find.byType(Icon)),
            findsWidgets,
            reason: '${girdi.key} -- rozette ikon dugumu bekleniyordu',
          );
          final gorunurMetinVar = find
              .descendant(of: rozet, matching: find.byType(Text))
              .evaluate()
              .isNotEmpty;
          final semantikMetinVar = tester.getSemantics(rozet).label.isNotEmpty;
          expect(
            gorunurMetinVar || semantikMetinVar,
            isTrue,
            reason: '${girdi.key} -- ne gorunur Text ne semantics label var',
          );
        }
        tutamac.dispose();
      },
    );

    testWidgets(
      'A11Y-7: yukleniyor/senkronize/cevrimdisi/cakisma/hata duyurulari F6 ile birebir',
      (tester) async {
        final yakalanan = _duyurulariYakala(tester);
        await tester.pumpWidget(_vitrinSarmalayici());
        await tester.pump();
        expect(
          yakalanan,
          containsAll(<String>[
            Metinler.duyuruGorevlerYukleniyor,
            Metinler.duyuruSenkronizeEdildi,
            Metinler.duyuruCevrimdisi,
            Metinler.duyuruHata,
            Metinler.duyuruCakismaVar,
          ]),
        );
      },
    );

    testWidgets('A11Y-4: textScaler 2.0 altinda beklenmeyen tasma (FlutterError) yok', (
      tester,
    ) async {
      await tester.pumpWidget(_vitrinSarmalayici(textScale: 2.0));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('A11Y-2: GorevEkleAlani odak halkasi', () {
    testWidgets('focusedBorder.width == odakKalinlik, color == birincil', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: GorevEkleAlani(onEkle: (_) {}))),
      );
      final alan = tester.widget<TextField>(find.byType(TextField));
      final context = tester.element(find.byType(GorevEkleAlani));
      final odakliKenar = alan.decoration!.focusedBorder as OutlineInputBorder;
      expect(odakliKenar.borderSide.width, MOlcu.odakKalinlik);
      expect(odakliKenar.borderSide.color, MRenk.birincil(context));
    });
  });

  group('GERCEK EKRAN (GorevListesiEkrani) -- bos * yerel * hata', () {
    testWidgets('BOS: A11Y-1 + A11Y-3 + metin', (tester) async {
      final tutamac = tester.ensureSemantics();
      await tester.pumpWidget(_gercekEkranSarmalayici(_SabitDepo(const [])));
      await tester.pump();
      expect(find.text(Metinler.bosDurum), findsOneWidget);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      tutamac.dispose();
    });

    testWidgets('YEREL: A11Y-1 + A11Y-3 + gorev satiri gorunur', (tester) async {
      final tutamac = tester.ensureSemantics();
      await tester.pumpWidget(
        _gercekEkranSarmalayici(_SabitDepo([_ornekGorev('G5 gercek ekran testi')])),
      );
      await tester.pump();
      expect(find.text('G5 gercek ekran testi'), findsOneWidget);
      // GOREV-A7 [K85 / D-A7-1]: gorunur dizge kisaldi, tam metin
      // Semantics(label:)'da kaldi (olcum G15/A13'te).
      expect(find.text(Metinler.rozetKisaYerel), findsOneWidget);
      expect(
        SenkronRozeti.tamMetinIcin(SenkronDurumTuru.yerel),
        Metinler.yalnizcaBuCihazda,
      );
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      tutamac.dispose();
    });

    testWidgets('HATA: A11Y-7 duyurusu + metin + yeniden dene', (tester) async {
      final yakalanan = _duyurulariYakala(tester);
      await tester.pumpWidget(_gercekEkranSarmalayici(_HataliDepo()));
      await tester.pump();
      expect(find.text(Metinler.birSeylerTersGitti), findsOneWidget);
      expect(find.text(Metinler.yenidenDene), findsOneWidget);
      expect(yakalanan, contains(Metinler.duyuruHata));
    });
  });
}

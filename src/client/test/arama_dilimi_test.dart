@TestOn('vm')
library;

// ODEV.md §4(a) BASLIKTA ARAMA DILIMI -- SAF KURAL + KABLO (UI) KAPISI.
//
// Neyi olcer:
//   (1) katlama TURKCE-GUVENLI: 'I'->'ı', 'İ'->'i' (MUTANT KAPISI: govde
//       `metin.toLowerCase()`e dusurulurse `IŞIK`/`ışık` ayagi OLDURUR);
//   (2) aksan KATLANMAZ (MUTANT KAPISI: katlamaya aksan soyme eklenirse
//       `odeme`/`Ödeme` ayagi OLDURUR);
//   (3) bos sorgu = suzme YOK, sorgu KIRPILIR;
//   (4) property: idempotent · refleksif · her alt dize bulunur;
//   (5) kablo: alan CIP SERIDININ USTUNDE · her tusta CANLI (debounce yok) ·
//       arama ile cip CARPILIR · bos sonucta AYRI metin + tek dokunusla
//       ikisini birden sifirlayan eylem · gorev YOKKEN alan HIC cizilmez.

import 'dart:async';

import 'package:client/design/metinler.dart';
import 'package:client/design/tokens.dart';
import 'package:client/sunum/arama_eslestirme.dart';
import 'package:client/sunum/gorev_ekle_alani.dart';
import 'package:client/sunum/gorev_listesi_ekrani.dart';
import 'package:client/sunum/senkron_rozeti.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// DURUM.md sinir 18: yeni sahte depo `ekle`nin UC opsiyonel alanini kabul
// ETMEK ZORUNDADIR.
class _SahteDepo implements GorevDeposu {
  final _denetleyici = StreamController<List<GorevGorunum>>.broadcast();

  @override
  Stream<List<GorevGorunum>> gorevlerGorunur() => _denetleyici.stream;

  @override
  Future<void> ekle(
    String baslik, {
    int? oncelik,
    DateTime? sonTarih,
    Set<String> etiketler = const {},
  }) async {}

  @override
  Future<void> duzenle(String id, String yeniBaslik) async {}

  @override
  Future<void> ayrintilariGuncelle(
    String id, {
    Yazim<String>? baslik,
    Yazim<int?>? oncelik,
    Yazim<DateTime?>? sonTarih,
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

  void yayinla(List<GorevGorunum> g) => _denetleyici.add(g);

  void kapat() => _denetleyici.close();
}

GorevGorunum _gorunum(
  String id,
  String baslik, [
  List<String> etiketler = const [],
]) => GorevGorunum(
  gorev: Gorev(
    id: id,
    baslik: baslik,
    tamamlandi: false,
    olusturuldu: DateTime.utc(2026, 8, 1),
    guncellendi: DateTime.utc(2026, 8, 1),
    senkronDurumu: 'senkronize',
    silindi: false,
    etiketler: etiketler,
  ),
  senkronDurumu: SenkronDurumTuru.senkronize,
  cakismaVarMi: false,
);

/// Property ayaklarinin ORTAK govdesi. RASTGELE DEGIL: deterministik ve
/// Turkce'nin tuzaklarini (I/İ/ı/i, aksan, BMP disi) kasten iceren sabit
/// kume -- ayni kosum ayni sonucu verir.
const List<String> _ornekler = [
  '',
  'Rapor gönder',
  'IŞIK yak',
  'ışık yak',
  'İş görüşmesi',
  'işik',
  'Ödeme yap',
  'ÇAMAŞIR ASILACAK',
  'Iğdır',
  'C# öğren',
  'ĞÜŞİÖÇ',
  'straße',
  '🙂 emoji satiri',
];

void main() {
  group('SAF KATLAMA -- Turkce tuzagi', () {
    test("'I' -> 'ı' ve 'İ' -> 'i' (kucuk harfler DEGISMEZ)", () {
      expect(aramaKatla('I'), 'ı');
      expect(aramaKatla('İ'), 'i');
      expect(aramaKatla('ı'), 'ı');
      expect(aramaKatla('i'), 'i');
    });

    test('🔴 MUTANT KAPISI: govde toLowerCase OLSAYDI BASKA sonuc verirdi', () {
      // OLCULDU (15 Agu 2026): 'IŞIK'.toLowerCase() == 'işik' -- 'ışık'
      // olmaliydi. Govde `metin.toLowerCase()`e dusurulurse bu ayak OLUR.
      expect(aramaKatla('IŞIK'), 'ışık');
      expect('IŞIK'.toLowerCase(), 'işik');
      expect('IŞIK'.toLowerCase(), isNot(aramaKatla('IŞIK')));
    });

    test('🔴 DIKIS KAPISI: `İ` girisi VM`de DAVRANISLA oldurulemez', () {
      // OLCULDU (15 Agu 2026, Dart 3.11): 'İ'.toLowerCase() VM'de [105],
      // dart2js/Node'da [105, 775] (i + U+0307). ⇒ `İ` girisini silen mutant
      // VM'de HICBIR davranisi degistirmez ama WEB'de `iş` sorgusunu
      // `İş görüşmesi`nden koparirdi. Bu yuzden TABLO BIREBIR sinanir --
      // o77 dersi: ortami degil DIKISI olc.
      expect(kTurkceKatlamaIstisnalari, {'I': 'ı', 'İ': 'i'});
      expect(aramaKatla('İŞ'), 'iş');
      expect(aramaKatla('İ').codeUnits, [105]);
      // VM kanaryasi: bu satir kirilirsa Dart'in VM katlamasi degismistir
      // ve yukaridaki gerekce YENIDEN OLCULMELIDIR.
      expect('İ'.toLowerCase().codeUnits, [105]);
    });

    test('Turkce ozel harfler dogru katlanir, aksan KORUNUR', () {
      expect(aramaKatla('ÇĞÖŞÜ'), 'çğöşü');
      expect(aramaKatla('Ödeme'), 'ödeme');
      expect(aramaKatla('ÇAMAŞIR'), 'çamaşır');
    });

    test('BMP disi karakter BOLUNMEZ (runes uzerinden yurunur)', () {
      expect(aramaKatla('A🙂B'), 'a🙂b');
      // 🔴 MUTANT KAPISI (`runes` -> `codeUnits`): emoji KASASIZ oldugu icin
      // iki yol da AYNI sonucu verir ⇒ emoji TEK BASINA bu mutanti OLDURMEZ.
      // KASALI bir BMP disi harf gerekir. OLCULDU (15 Agu 2026, VM):
      // '\u{10400}' (DESERET CAPITAL LONG I) -> '\u{10428}'; `codeUnits`
      // yolundan gidilirse vekil cift bolunur ve harf HIC katlanmaz.
      expect(aramaKatla('\u{10400}'), '\u{10428}');
      expect(
        aramaEslesir(baslik: '\u{10400}', sorgu: '\u{10428}'),
        isTrue,
        reason: 'BMP disi kasali harf de katlanarak eslesmeli',
      );
    });

    test('katlama tablosu TEK KAYNAK ve YALNIZ iki istisna tasir', () {
      // Tablo buyurse (or. aksan soyme eklenirse) bu ayak duser: katlama
      // BUYUK/KUCUK HARFTIR, baska bir sey degil.
      expect(kTurkceKatlamaIstisnalari, {'I': 'ı', 'İ': 'i'});
    });
  });

  group('SAF ESLESME', () {
    test('alt dize bulunur (kelime basi SART DEGIL)', () {
      expect(
        aramaEslesir(baslik: 'Aylık rapor gönder', sorgu: 'rapor'),
        isTrue,
      );
      expect(
        aramaEslesir(baslik: 'Aylık rapor gönder', sorgu: 'apor gö'),
        isTrue,
      );
    });

    test('🔴 buyuk/kucuk KATLANIR: IŞIK <-> ışık her iki yonde', () {
      expect(aramaEslesir(baslik: 'IŞIK yak', sorgu: 'ışık'), isTrue);
      expect(aramaEslesir(baslik: 'ışık yak', sorgu: 'IŞIK'), isTrue);
      expect(aramaEslesir(baslik: 'İş görüşmesi', sorgu: 'iş'), isTrue);
      expect(aramaEslesir(baslik: 'iş görüşmesi', sorgu: 'İŞ'), isTrue);
    });

    test('🔴 AKSAN KATLANMAZ: odeme, Ödeme`yi BULMAZ', () {
      expect(aramaEslesir(baslik: 'Ödeme yap', sorgu: 'odeme'), isFalse);
      expect(aramaEslesir(baslik: 'Şeker al', sorgu: 'seker'), isFalse);
      expect(aramaEslesir(baslik: 'Çamaşır', sorgu: 'camasir'), isFalse);
    });

    test('🔴 Turkce ayrimi KORUNUR: ışık, işik`i BULMAZ', () {
      expect(aramaEslesir(baslik: 'işik', sorgu: 'ışık'), isFalse);
      expect(aramaEslesir(baslik: 'ışık', sorgu: 'işik'), isFalse);
    });

    test('bos / yalniz bosluk sorgu = SUZME YOK', () {
      expect(aramaEslesir(baslik: 'Rapor', sorgu: ''), isTrue);
      expect(aramaEslesir(baslik: 'Rapor', sorgu: '   '), isTrue);
      expect(aramaEslesir(baslik: '', sorgu: ''), isTrue);
    });

    test('sorgu KIRPILIR, basliktaki ic bosluk KORUNUR', () {
      expect(aramaEslesir(baslik: 'Rapor gönder', sorgu: '  rapor '), isTrue);
      // 🔴 MUTANT KAPISI (`trim` -> `trimLeft`/`trimRight`): iki ucu da AYRI
      // ayri sinanir. Ustteki ornek TEK BASINA yetmez -- 'Rapor gönder'
      // basligi sagdaki boslugu ZATEN icerir, fark OLUSMAZ.
      expect(aramaEslesir(baslik: 'Rapor', sorgu: 'rapor '), isTrue);
      expect(aramaEslesir(baslik: 'Rapor', sorgu: ' rapor'), isTrue);
      expect(
        aramaEslesir(baslik: 'Rapor gönder', sorgu: 'rapor gönder'),
        isTrue,
      );
      expect(
        aramaEslesir(baslik: 'Raporgönder', sorgu: 'rapor gönder'),
        isFalse,
      );
    });

    test('eslesmeyen sorgu FALSE doner (fonksiyon her seye true DEMIYOR)', () {
      expect(aramaEslesir(baslik: 'Rapor', sorgu: 'zzz'), isFalse);
      expect(aramaEslesir(baslik: '', sorgu: 'z'), isFalse);
    });
  });

  group('PROPERTY (deterministik kume)', () {
    test('katlama IDEMPOTENT: katla(katla(x)) == katla(x)', () {
      for (final ornek in _ornekler) {
        expect(aramaKatla(aramaKatla(ornek)), aramaKatla(ornek), reason: ornek);
      }
    });

    test('REFLEKSIF: her baslik KENDINI bulur (ve katlanmisini da)', () {
      for (final ornek in _ornekler) {
        expect(
          aramaEslesir(baslik: ornek, sorgu: ornek),
          isTrue,
          reason: ornek,
        );
        expect(
          aramaEslesir(baslik: ornek, sorgu: aramaKatla(ornek)),
          isTrue,
          reason: ornek,
        );
      }
    });

    test('KATLANMIS her alt dize (on ek / son ek) BULUNUR', () {
      for (final ornek in _ornekler) {
        final harfler = aramaKatla(ornek).runes.toList();
        for (var i = 0; i <= harfler.length; i++) {
          final onEk = String.fromCharCodes(harfler.take(i));
          final sonEk = String.fromCharCodes(harfler.skip(i));
          expect(
            aramaEslesir(baslik: ornek, sorgu: onEk),
            isTrue,
            reason: '$ornek | on ek "$onEk"',
          );
          expect(
            aramaEslesir(baslik: ornek, sorgu: sonEk),
            isTrue,
            reason: '$ornek | son ek "$sonEk"',
          );
        }
      }
    });
  });

  group('KABLO (UI)', () {
    Future<_SahteDepo> ekraniKur(
      WidgetTester tester,
      List<GorevGorunum> gorevler,
    ) async {
      final depo = _SahteDepo();
      addTearDown(depo.kapat);
      await tester.pumpWidget(
        MaterialApp(home: GorevListesiEkrani(depo: depo)),
      );
      depo.yayinla(gorevler);
      await tester.pump();
      return depo;
    }

    final aramaAlani = find.byKey(const ValueKey('arama_alani'));
    final temizleDugmesi = find.byKey(
      const ValueKey('suzgecleri_temizle_dugmesi'),
    );
    // Ekranda ARTIK IKI `TextField` var ⇒ `find.byType(TextField)` belirsiz;
    // ekleme alani sahibi bilesenden inilerek bulunur.
    final ekleAlani = find.descendant(
      of: find.byType(GorevEkleAlani),
      matching: find.byType(TextField),
    );

    testWidgets('gorev YOKKEN arama alani HIC cizilmez (bos durum yolu AYNI)', (
      tester,
    ) async {
      await ekraniKur(tester, const []);
      expect(aramaAlani, findsNothing);
      expect(find.text(Metinler.bosDurum), findsOneWidget);
    });

    testWidgets('KILITLI METINLER birebir (CLAUDE.md §3 kilidi)', (
      tester,
    ) async {
      // Sabitler EK grubundadir (F6'nin 13 dizgesine dahil DEGIL) ⇒ fixture
      // kapisi onlari GORMEZ. Kilit metni birebir yaziyor; pin BURADADIR.
      expect(Metinler.aramaEslesmeYok, 'Eşleşen görev yok.');
      expect(Metinler.suzgecleriTemizle, 'Süzgeçleri temizle');
      expect(Metinler.aramaIpucu, 'Ara');
    });

    testWidgets('arama alani: ipucu + A11Y-2 odak halkasi PINLENDI', (
      tester,
    ) async {
      await ekraniKur(tester, [_gorunum('g1', 'Rapor')]);
      final alan = tester.widget<TextField>(aramaAlani);
      final context = tester.element(aramaAlani);
      final dekor = alan.decoration!;
      // 🔴 `hintText` bir `Text(` DEGILDIR ⇒ a11y_statik_tasma tarayicisina
      // GORUNMEZ; ustelik alanin semantik dugumunde label/value BOS oldugu
      // icin `textContrastGuideline` o dugumu ATLAR (OLCULDU, denetim
      // 15 Agu). Yani ipucunun metni de rengi de BASKA HICBIR kapida
      // olculmuyor -- tek pin burasidir.
      expect(dekor.hintText, Metinler.aramaIpucu);
      expect(
        (dekor.hintStyle!.color),
        MRenk.metinIkincil(context),
        reason: 'ipucu rengi zeminle ayni yapilirsa hicbir kapi kirmizi olmaz',
      );
      expect(alan.style!.color, MRenk.metin(context));
      // A11Y-2 kapisi (a11y_kapisi_test) YALNIZ GorevEkleAlani'ni olcer;
      // ikinci giris alani oraya EKLENMEDI (kapi butcesi ihlalde, yeni kapi
      // kodu yazilmaz) -- ayni iddia burada tutulur.
      final odakli = dekor.focusedBorder! as OutlineInputBorder;
      expect(odakli.borderSide.width, MOlcu.odakKalinlik);
      expect(odakli.borderSide.color, MRenk.birincil(context));
    });

    testWidgets('arama alani CIP SERIDININ USTUNDEDIR', (tester) async {
      await ekraniKur(tester, [
        _gorunum('g1', 'Rapor', const ['iş']),
      ]);
      expect(aramaAlani, findsOneWidget);
      final cip = find.byKey(const ValueKey('etiket_cipi_tumu'));
      expect(cip, findsOneWidget);
      expect(
        tester.getTopLeft(aramaAlani).dy,
        lessThan(tester.getTopLeft(cip).dy),
        reason: 'okuma sirasi ara -> daralt -> listele',
      );
    });

    testWidgets(
      'HER TUSTA CANLI: tek pump sonrasi liste DARALIR (debounce YOK)',
      (tester) async {
        await ekraniKur(tester, [
          _gorunum('g1', 'Rapor gönder'),
          _gorunum('g2', 'Market alışverişi'),
        ]);
        expect(find.text('Rapor gönder'), findsOneWidget);
        expect(find.text('Market alışverişi'), findsOneWidget);

        await tester.enterText(aramaAlani, 'rap');
        // 🔴 `pumpAndSettle` DEGIL: zamanlayici beklenmez. Debounce eklenseydi
        // bu tek kare suzmeyi HENUZ gostermezdi ve ayak duserdi.
        await tester.pump();
        expect(find.text('Rapor gönder'), findsOneWidget);
        expect(find.text('Market alışverişi'), findsNothing);
      },
    );

    testWidgets('alan TEMIZLENINCE liste GERI GELIR', (tester) async {
      await ekraniKur(tester, [
        _gorunum('g1', 'Rapor gönder'),
        _gorunum('g2', 'Market alışverişi'),
      ]);
      await tester.enterText(aramaAlani, 'rap');
      await tester.pump();
      expect(find.text('Market alışverişi'), findsNothing);

      await tester.enterText(aramaAlani, '');
      await tester.pump();
      expect(find.text('Rapor gönder'), findsOneWidget);
      expect(find.text('Market alışverişi'), findsOneWidget);
    });

    testWidgets(
      '🔴 TURKCE katlama CANLI YOLDA: IŞIK basligi ışık ile bulunur',
      (tester) async {
        await ekraniKur(tester, [
          _gorunum('g1', 'IŞIK yak'),
          _gorunum('g2', 'Market'),
        ]);
        await tester.enterText(aramaAlani, 'ışık');
        await tester.pump();
        expect(find.text('IŞIK yak'), findsOneWidget);
        expect(find.text('Market'), findsNothing);
      },
    );

    testWidgets('arama ile cip CARPILIR (VE), tek suzme yolu', (tester) async {
      await ekraniKur(tester, [
        _gorunum('g1', 'Rapor gönder', const ['iş']),
        _gorunum('g2', 'Rapor oku', const ['ev']),
        _gorunum('g3', 'Market', const ['ev']),
      ]);

      await tester.tap(find.byKey(const ValueKey('etiket_cipi_ev')));
      await tester.pump();
      expect(find.text('Rapor gönder'), findsNothing);
      expect(find.text('Rapor oku'), findsOneWidget);
      expect(find.text('Market'), findsOneWidget);

      await tester.enterText(aramaAlani, 'rapor');
      await tester.pump();
      expect(
        find.text('Rapor oku'),
        findsOneWidget,
        reason: 'yalniz IKI suzgeci de gecen satir kalir',
      );
      expect(find.text('Market'), findsNothing);
      expect(find.text('Rapor gönder'), findsNothing);
    });

    testWidgets(
      'bos sonuc: AYRI metin cizilir, "henuz gorev yok" YALANI KURULMAZ',
      (tester) async {
        await ekraniKur(tester, [
          _gorunum('g1', 'Rapor', const ['iş']),
          _gorunum('g2', 'Market', const ['ev']),
        ]);
        await tester.enterText(aramaAlani, 'zzz');
        await tester.pump();

        expect(find.text(Metinler.aramaEslesmeYok), findsOneWidget);
        expect(find.text(Metinler.bosDurum), findsNothing);
        expect(temizleDugmesi, findsOneWidget);
        // Arama alani KAYBOLMAZ: kullanici yazdigini duzeltebilmeli.
        expect(aramaAlani, findsOneWidget);
        // 🔴 CIP SERIDI ARAMAYLA DARALMAZ: serit SUZULMEMIS listeden
        // turetilir. Aksi halde "zzz" yazan kullanici seridin TAMAMINI
        // kaybeder, hangi etiket suzgecinin acik oldugunu goremezdi
        // (mutant TAM TAKIMDA sagkaliyordu -- denetim, 15 Agu).
        expect(find.byKey(const ValueKey('etiket_cipi_tumu')), findsOneWidget);
        expect(find.byKey(const ValueKey('etiket_cipi_iş')), findsOneWidget);
        expect(find.byKey(const ValueKey('etiket_cipi_ev')), findsOneWidget);
      },
    );

    testWidgets('🔴 EKLEME suzgecleri SIFIRLAR (Onur kilidi, 16 Agu)', (
      tester,
    ) async {
      // Suzgec acikken eklenen gorev EKRANDA GORUNMELI. Sahte depo akisa
      // yeni satir yayinlamaz -- olculebilir dikis SUZGECIN DUSMESIDIR:
      // eleyen sorgu sifirlanir ve elenen satirlar geri gelir.
      await ekraniKur(tester, [
        _gorunum('g1', 'Rapor', const ['iş']),
        _gorunum('g2', 'Market', const ['ev']),
      ]);
      await tester.tap(find.byKey(const ValueKey('etiket_cipi_iş')));
      await tester.pump();
      await tester.enterText(aramaAlani, 'zzz');
      await tester.pump();
      expect(find.text(Metinler.aramaEslesmeYok), findsOneWidget);

      await tester.enterText(ekleAlani, 'Sut al');
      await tester.tap(find.bySemanticsLabel(Metinler.ekleDugmesi));
      await tester.pump();

      expect(find.text(Metinler.aramaEslesmeYok), findsNothing);
      expect(find.text('Rapor'), findsOneWidget);
      expect(find.text('Market'), findsOneWidget);
      expect(tester.widget<TextField>(aramaAlani).controller!.text, isEmpty);
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(const ValueKey('etiket_cipi_tumu')))
            .selected,
        isTrue,
      );
    });

    testWidgets('GECERSIZ girdi suzgeci SIFIRLAMAZ (onEkle atesLENMEZ)', (
      tester,
    ) async {
      // Mutant kapisi: sifirlama `onEkle` yerine dugmenin KENDISINE
      // baglanirsa bos girdide de suzgec duserdi -- kullanicinin kurdugu
      // suzgec sebepsiz kaybolurdu.
      await ekraniKur(tester, [
        _gorunum('g1', 'Rapor'),
        _gorunum('g2', 'Market'),
      ]);
      await tester.enterText(aramaAlani, 'rapor');
      await tester.pump();
      expect(find.text('Market'), findsNothing);

      await tester.enterText(ekleAlani, '   ');
      await tester.tap(find.bySemanticsLabel(Metinler.ekleDugmesi));
      await tester.pump();

      expect(tester.widget<TextField>(aramaAlani).controller!.text, 'rapor');
      expect(find.text('Market'), findsNothing);
    });

    testWidgets('🔴 YALNIZ BASLIKTA aranir -- ETIKET metni aramaya GIRMEZ', (
      tester,
    ) async {
      // Kilit md.5. Bu ayak olmadan, `baslik:` argumanina etiketleri de
      // ekleyen mutant TAM TAKIMDA SAGKALIYORDU (denetim, 15 Agu).
      await ekraniKur(tester, [
        _gorunum('g1', 'Market', const ['rapor']),
        _gorunum('g2', 'Rapor oku', const ['ev']),
      ]);
      await tester.enterText(aramaAlani, 'rapor');
      await tester.pump();
      expect(find.text('Rapor oku'), findsOneWidget);
      expect(
        find.text('Market'),
        findsNothing,
        reason: 'etiketi `rapor` olan satir BASLIK aramasiyla GELMEMELI',
      );
    });

    testWidgets(
      'SUZGECLERI TEMIZLE aramayi VE cip secimini birlikte sifirlar',
      (tester) async {
        await ekraniKur(tester, [
          _gorunum('g1', 'Rapor', const ['iş']),
          _gorunum('g2', 'Market', const ['ev']),
        ]);

        await tester.tap(find.byKey(const ValueKey('etiket_cipi_iş')));
        await tester.pump();
        await tester.enterText(aramaAlani, 'zzz');
        await tester.pump();
        expect(find.text(Metinler.aramaEslesmeYok), findsOneWidget);

        await tester.tap(temizleDugmesi);
        await tester.pump();

        expect(find.text('Rapor'), findsOneWidget);
        expect(
          find.text('Market'),
          findsOneWidget,
          reason: 'cip secimi de dusmeli -- yalniz arama degil',
        );
        expect(
          tester.widget<TextField>(aramaAlani).controller!.text,
          isEmpty,
          reason: 'alanin METNI de silinmeli (yalniz durum degil)',
        );
        final tumuCipi = tester.widget<ChoiceChip>(
          find.byKey(const ValueKey('etiket_cipi_tumu')),
        );
        expect(tumuCipi.selected, isTrue);
      },
    );
  });
}

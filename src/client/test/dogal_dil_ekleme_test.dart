@TestOn('vm')
library;

// ODEV.md §4(a) DOGAL DIL DILIMI -- YAZMA YOLU ve UI KABLOSU kapisi.
//
// Ayristiricinin KENDISI `dogal_dil_ayristirici_test.dart`ta olculur (saf,
// DB'siz, 14 olu mutant). Bu dosya ayristirilan sonucun URUNE nasil indigini
// olcer:
//   1. `ekle()` dort alani TEK `WireOp` + TEK `transaction` ile yazar
//      (iki cagri -> iki op mutanti burada olur),
//   2. bos/verilmemis alanlar TELE HIC KONMAZ (LWW'yi bosuna damgalamak yok),
//   3. `GorevEkleAlani` ayristirmayi kendi yapar ve BOS baslikta alani
//      TEMIZLEMEZ (sessiz kayip yasagi),
//   4. ekran, dort alani `depo.ekle`ye K112 sirasiyla (once yazma, sonra
//      itme) gecirir.

import 'dart:async';
import 'dart:convert';

import 'package:client/design/metinler.dart';
import 'package:client/sunum/dogal_dil_ayristirici.dart';
import 'package:client/sunum/gorev_ekle_alani.dart';
import 'package:client/sunum/gorev_listesi_ekrani.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/veritabani.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _SayacId {
  int _n = 0;
  String cagir() => 'id-${++_n}';
}

/// `DateTime`i taklit eden SONDA: donusturucu cagrilirsa DEFTERE yazar.
///
/// 🔴 Var olma sebebi [bagimsiz denetim, o77]: `_gonder`daki
/// `widget.simdi()` -> `widget.simdi().toUtc()` mutanti, UTC koşan bir CI'da
/// DAVRANISLA oldurulemez (yerel == UTC olunca iki takvim gunu ayrisamaz).
/// Bu sonda DIKISI olcer, ORTAMI degil ⇒ her saat diliminde ayni sonucu verir.
/// Urun etkisi somuttur: UTC+3'te 00:00-03:00 arasi `bugün` yazan kullanici
/// DUNU alirdi (o74'un uc saatlik kaymasinin aynisi).
class _SondaTarih implements DateTime {
  final DateTime _ic;
  final List<String> defter;

  _SondaTarih(this._ic, this.defter);

  @override
  int get year => _ic.year;
  @override
  int get month => _ic.month;
  @override
  int get day => _ic.day;

  @override
  DateTime toUtc() {
    defter.add('toUtc');
    return _ic.toUtc();
  }

  @override
  DateTime toLocal() {
    defter.add('toLocal');
    return _ic.toLocal();
  }

  @override
  dynamic noSuchMethod(Invocation cagri) => super.noSuchMethod(cagri);
}

Future<DriftGorevDeposu> _depoKur(Veritabani db, _SayacId id) async {
  const sabitSaat = 1786838400000; // 2026-08-15T12:00:00Z
  final ayarlarDeposu = AyarlarDeposu(db, idUret: id.cagir);
  final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
  return DriftGorevDeposu(
    db,
    saat: () => DateTime.fromMillisecondsSinceEpoch(sabitSaat, isUtc: true),
    idUret: id.cagir,
    hlc: HlcUretici(simdiMs: () => sabitSaat, clientId: ayarlar.clientId),
    ayarlarDeposu: ayarlarDeposu,
    actorId: ayarlar.devUserId,
  );
}

/// Ekleme akisini KAYDEDEN sahte depo (ekran kablosu icin).
class _SahteDepo implements GorevDeposu {
  final List<String> cagrilar;
  final _denetleyici = StreamController<List<GorevGorunum>>.broadcast();

  _SahteDepo(this.cagrilar);

  @override
  Stream<List<GorevGorunum>> gorevlerGorunur() => _denetleyici.stream;

  @override
  Future<void> ekle(
    String baslik, {
    int? oncelik,
    DateTime? sonTarih,
    Set<String> etiketler = const {},
    String? projeId,
  }) async => cagrilar.add(
    'ekle|$baslik|$oncelik|${sonTarih?.toIso8601String()}|${etiketler.join(",")}',
  );

  @override
  Future<void> duzenle(String id, String yeniBaslik) async {}

  @override
  Future<void> ayrintilariGuncelle(
    String id, {
    Yazim<String>? baslik,
    Yazim<int?>? oncelik,
    Yazim<DateTime?>? sonTarih,
    Yazim<String?>? projeId,
    Set<String>? etiketEklenen,
    Set<String>? etiketSilinen,
  }) async => cagrilar.add('ayrintilariGuncelle:$id');

  @override
  Future<void> tamamlaGeriAl(String id, {required bool tamamlandi}) async {}

  @override
  Future<void> sil(String id) async {}

  @override
  Stream<List<CakismaKaydi>> cakismaKayitlariniIzle(String entityId) =>
      Stream.value(const []);

  @override
  Future<void> cakismaCoz(String entityId, CakismaSecimi secim) async {}

  @override
  Stream<List<Proje>> listelerGorunur() => Stream.value(const []);

  @override
  Future<void> listeEkle(String ad) async {}

  @override
  Future<void> listeDuzenle(String id, String yeniAd) async {}

  @override
  Future<void> listeSil(String id) async {}

  void yayinla(List<GorevGorunum> g) => _denetleyici.add(g);
  void kapat() => _denetleyici.close();
}

void main() {
  // ================= 1. YAZMA YOLU (DB + TEL) =================

  group('ekle() -- dort alan TEK op', () {
    late Veritabani db;
    late DriftGorevDeposu depo;

    setUp(() async {
      db = Veritabani(NativeDatabase.memory());
      depo = await _depoKur(db, _SayacId());
    });
    tearDown(() async => db.close());

    test('TEK WireOp: fields{title,priority,dueAt} + sets.tags.adds', () async {
      await depo.ekle(
        'rapor gönder',
        oncelik: 1,
        sonTarih: DateTime.utc(2026, 8, 16),
        etiketler: {'iş', 'acil'},
      );

      final kuyruk = await db.select(db.senkronKuyrugu).get();
      // 🔴 MUTANT KAPISI: `ekle` + `ayrintilariGuncelle` art arda cagrilsaydi
      // BURADA 2 cikardi. Dilimin en pahali kurali tam olarak budur.
      expect(kuyruk.length, 1, reason: 'dort alan TEK op tasimali');

      final govde = jsonDecode(kuyruk.single.govdeJson) as Map<String, Object?>;
      final alanlar = govde['fields']! as Map<String, Object?>;
      expect(alanlar.keys.toSet(), {'title', 'priority', 'dueAt'});
      expect((alanlar['title']! as Map)['value'], 'rapor gönder');
      expect((alanlar['priority']! as Map)['value'], '1');
      expect((alanlar['dueAt']! as Map)['value'], '2026-08-16T00:00:00.000Z');

      final sets = govde['sets']! as Map<String, Object?>;
      final adds = (sets['tags']! as Map<String, Object?>)['adds']! as List;
      expect(adds.length, 2);
      expect(adds.map((a) => (a as Map)['el']).toList(), ['iş', 'acil']);
      // Tag'ler BENZERSIZ: ayni tag iki elemana verilirse sunucudaki OR-Set
      // iki elemani TEK tag ile baglar ve bir remove ikisini birden dusurur.
      expect(adds.map((a) => (a as Map)['tag']).toSet().length, 2);

      // TUM HLC'ler AYNI damga (D3).
      final opHlc = govde['opHlc'];
      expect((alanlar['title']! as Map)['hlc'], opHlc);
      expect((adds.first as Map)['hlc'], opHlc);

      // 🔴 CIDDI KAPI [bagimsiz denetim, o77 -- emsal: etiket_dilimi_test]:
      // YEREL satirin `addTag`i ile TELE giden `tag` AYNI olmali. Ayrisirsa
      // (a) op daha kuyruktayken gelen snapshot `_kuyruktakiTagler`
      // korumasini KACIRIR ve kullanicinin etiketini SESSIZCE iptal eder,
      // (b) sonraki silme `observed`a sunucunun HIC gormedigi bir tag koyar
      // ⇒ etiket ADD-WINS ile geri gelir. `adds` tekilligi bunu OLCMEZ.
      final dbSatirlar = await db.select(db.gorevEtiketleri).get();
      expect(
        {for (final s in dbSatirlar) '${s.etiket}|${s.addTag}'},
        {for (final a in adds) '${(a as Map)['el']}|${a['tag']}'},
      );
    });

    test(
      'ATOMIKLIK: kuyruk yazimi firlarsa ETIKET satirlari da geri sarilir',
      () async {
        // 🔴 CIDDI KAPI [bagimsiz denetim, o77]: etiket ekleme dongusu
        // `transaction`in DISINA tasindiginda 667 testin HICBIRI kirilmiyordu
        // (`g8` yalniz ETIKETSIZ `ekle`yi goruyor). Bu ayak D8'in etiket kolunu
        // kapatir: op tele gitmisken yerelde etiket YOK = hayalet op.
        final db2 = Veritabani(NativeDatabase.memory());
        addTearDown(db2.close);
        final ayarlarDeposu = AyarlarDeposu(db2, idUret: uretimIdUret);
        final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();

        // Uretilecek operationId ile AYNI opId'de bir satir ONCEDEN eklenir ⇒
        // kuyruk INSERT'i PK ihlaliyle firlar (g8 deseni).
        const catisanOpId = 'catisan-op-id';
        await db2
            .into(db2.senkronKuyrugu)
            .insert(
              SenkronKuyruguCompanion.insert(
                opId: catisanOpId,
                clientId: 'x',
                entityType: 'Task',
                entityId: 'x',
                govdeJson: '{}',
                hlcWallMs: 1,
                hlcCounter: 1,
                olusturuldu: DateTime.now().toUtc(),
              ),
            );

        // Cagri sirasi: 1=entityId · 2=tag · 3=operationId (CATISAN).
        var cagri = 0;
        String idUret() {
          cagri++;
          return switch (cagri) {
            1 => 'taze-entity-id',
            2 => 'taze-tag',
            _ => catisanOpId,
          };
        }

        final depo2 = DriftGorevDeposu(
          db2,
          saat: () => DateTime.now().toUtc(),
          idUret: idUret,
          hlc: HlcUretici(
            simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch,
            clientId: ayarlar.clientId,
          ),
          ayarlarDeposu: ayarlarDeposu,
          actorId: ayarlar.devUserId,
        );

        await expectLater(
          depo2.ekle('atomiklik', etiketler: {'iş'}),
          throwsA(anything),
        );

        expect(await db2.select(db2.gorevler).get(), isEmpty);
        expect(
          await db2.select(db2.gorevEtiketleri).get(),
          isEmpty,
          reason: 'ETIKET satiri da GERI SARILMALI',
        );
        expect(
          (await db2.select(db2.senkronKuyrugu).get()).length,
          1,
          reason: 'yalniz ONCEDEN eklenen catisan satir kalmali',
        );
      },
    );

    test(
      'projeksiyon: gorev satiri + etiket satirlari AYNI transaction',
      () async {
        await depo.ekle(
          'rapor',
          oncelik: 2,
          sonTarih: DateTime.utc(2026, 12, 31),
          etiketler: {'ev'},
        );

        final satir = (await db.select(db.gorevler).get()).single;
        expect(satir.baslik, 'rapor');
        expect(satir.oncelik, 2);
        expect(satir.sonTarih, DateTime.utc(2026, 12, 31));

        final etiketSatiri = (await db.select(db.gorevEtiketleri).get()).single;
        expect(etiketSatiri.gorevId, satir.id);
        expect(etiketSatiri.etiket, 'ev');
        expect(etiketSatiri.iptalEdildi, isFalse);

        // Ekranda gorunen ham projeksiyon da doludur.
        final gorunur = await depo.gorevlerGorunur().first;
        expect(gorunur.single.gorev.etiketler, ['ev']);
        expect(gorunur.single.gorev.oncelik, 2);
      },
    );

    test('VERILMEYEN alan TELE HIC KONMAZ (geriye donuk davranis)', () async {
      await depo.ekle('yalniz baslik');

      final kuyruk = await db.select(db.senkronKuyrugu).get();
      expect(kuyruk.length, 1);
      final govde = jsonDecode(kuyruk.single.govdeJson) as Map<String, Object?>;

      // 🔴 MUTANT KAPISI: `if (oncelik != null)` bekcileri dusurulup
      // `value: null` yazilsaydi, YENI bir gorev sunucudaki hicbir seyi
      // ezmezdi ama tel govdesi ve LWW damgasi BOSUNA buyurdu; daha kotusu
      // `sets: {'tags': {}}` bos delta D2'yi (her op EN AZ BIR kanal) delerdi.
      expect((govde['fields']! as Map).keys.toSet(), {'title'});
      expect(govde.containsKey('sets'), isFalse, reason: 'bos tags YAZILMAZ');

      final satir = (await db.select(db.gorevler).get()).single;
      expect(satir.oncelik, isNull);
      expect(satir.sonTarih, isNull);
      expect(await db.select(db.gorevEtiketleri).get(), isEmpty);
    });
  });

  // ================= 2. WIDGET KABLOSU =================

  group('GorevEkleAlani -- ayristirma WIDGET`ta', () {
    final bugun = DateTime(2026, 8, 15, 9, 30);

    Future<DogalDilSonucu?> yaz(WidgetTester tester, String metin) async {
      DogalDilSonucu? alinan;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GorevEkleAlani(onEkle: (s) => alinan = s, simdi: () => bugun),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), metin);
      await tester.tap(find.bySemanticsLabel(Metinler.ekleDugmesi));
      await tester.pump();
      return alinan;
    }

    testWidgets('kilitli ornek dort alani tasiyarak yukari cikar', (
      tester,
    ) async {
      final s = await yaz(tester, 'yarın 17:00 rapor gönder #iş !p1');
      expect(s, isNotNull);
      expect(s!.baslik, '17:00 rapor gönder');
      expect(s.sonTarih, DateTime.utc(2026, 8, 16));
      expect(s.etiketler, ['iş']);
      expect(s.oncelik, 1);
      expect(
        (tester.widget(find.byType(TextField)) as TextField).controller!.text,
        '',
        reason: 'basarili eklemede alan TEMIZLENIR',
      );
    });

    testWidgets(
      'ayristirma sonrasi baslik BOSSA onEkle CAGRILMAZ ve alan KALIR',
      (tester) async {
        // 🔴 MUTANT KAPISI: ayristirma EKRANDA yapilsaydi widget ham metni
        // (`#iş`, bos DEGIL) gecerli sayar, alani TEMIZLER ve ekran bos basligi
        // sessizce duserdi -- kullanicinin yazdigi metin YOK OLURDU.
        final s = await yaz(tester, '#iş !p1 yarın');
        expect(s, isNull);
        expect(
          (tester.widget(find.byType(TextField)) as TextField).controller!.text,
          '#iş !p1 yarın',
          reason: 'gecersizse alan TEMIZLENMEZ (sessiz kayip yasak)',
        );
      },
    );

    testWidgets('duz metin eskisi gibi calisir (geriye donuk)', (tester) async {
      final s = await yaz(tester, '  Ekmek al  ');
      expect(s!.baslik, 'Ekmek al');
      expect(s.oncelik, isNull);
      expect(s.sonTarih, isNull);
      expect(s.etiketler, isEmpty);
    });

    test('VARSAYILAN simdi YEREL saat verir (UTC DEGIL)', () {
      // 🔴 MUTANT KAPISI [bagimsiz denetim, o77]: varsayilan
      // `DateTime.now` -> `() => DateTime.now().toUtc()` mutanti UTC koşan
      // CI'da DAVRANISLA oldurulemez. Bu iddia ORTAMDAN BAGIMSIZDIR:
      // `DateTime.now()` her saat diliminde `isUtc == false` doner.
      expect(GorevEkleAlani(onEkle: (_) {}).simdi().isUtc, isFalse);
    });

    testWidgets(
      '_gonder `simdi`nin tarihini DONUSTURMEDEN ayristiriciya verir',
      (tester) async {
        // 🔴 MUTANT KAPISI: `widget.simdi()` -> `widget.simdi().toUtc()` (ya da
        // `.toLocal()`) mutanti BURADA olur -- saat diliminden BAGIMSIZ olarak.
        final defter = <String>[];
        DogalDilSonucu? alinan;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GorevEkleAlani(
                onEkle: (s) => alinan = s,
                simdi: () => _SondaTarih(DateTime(2026, 8, 15, 1), defter),
              ),
            ),
          ),
        );
        await tester.enterText(find.byType(TextField), 'bugün rapor');
        await tester.tap(find.bySemanticsLabel(Metinler.ekleDugmesi));
        await tester.pump();

        expect(defter, isEmpty, reason: 'toUtc/toLocal CAGRILMAMALI');
        expect(alinan!.sonTarih, DateTime.utc(2026, 8, 15));
      },
    );

    testWidgets('VARSAYILAN simdi urunde GERCEK saati okur', (tester) async {
      // `simdi` enjekte EDILMEZSE varsayilan `DateTime.now` kosar. Gece yarisi
      // devrilmesine karsi: sonuc, tikla-oncesi ve tikla-sonrasi hesaplanan
      // iki takvim gununden BIRI olmalidir.
      DogalDilSonucu? alinan;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GorevEkleAlani(onEkle: (s) => alinan = s)),
        ),
      );
      final once = DateTime.now();
      await tester.enterText(find.byType(TextField), 'bugün rapor');
      await tester.tap(find.bySemanticsLabel(Metinler.ekleDugmesi));
      await tester.pump();
      final sonra = DateTime.now();

      expect(alinan!.baslik, 'rapor');
      expect(
        alinan!.sonTarih,
        anyOf(
          DateTime.utc(once.year, once.month, once.day),
          DateTime.utc(sonra.year, sonra.month, sonra.day),
        ),
      );
    });
  });

  // ================= 3. EKRAN KABLOSU (K112) =================

  testWidgets('ekran dort alani depo.ekle`ye gecirir, SONRA itme kosar', (
    tester,
  ) async {
    final sira = <String>[];
    final depo = _SahteDepo(sira);
    addTearDown(depo.kapat);

    await tester.pumpWidget(
      MaterialApp(
        home: GorevListesiEkrani(
          depo: depo,
          onYerelYazma: () async => sira.add('itme'),
        ),
      ),
    );
    depo.yayinla(const []);
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'rapor #iş #acil !p2');
    await tester.tap(find.bySemanticsLabel(Metinler.ekleDugmesi));
    await tester.pump();

    expect(sira, ['ekle|rapor|2|null|iş,acil', 'itme']);
  });

  testWidgets('ekran SON TARIHI de gecirir (gunu urun saatinden okur)', (
    tester,
  ) async {
    // 🔴 MUTANT KAPISI: ekranda `sonTarih: istek.sonTarih` satiri dusurulurse
    // BASKA HICBIR TEST kirilmaz -- bu ayak o kor noktayi kapatir. Ekran
    // `simdi`yi disari acmaz (varsayilan `DateTime.now`) ⇒ gece yarisi
    // devrilmesine karsi iki adaydan BIRI kabul edilir.
    final sira = <String>[];
    final depo = _SahteDepo(sira);
    addTearDown(depo.kapat);

    await tester.pumpWidget(MaterialApp(home: GorevListesiEkrani(depo: depo)));
    depo.yayinla(const []);
    await tester.pump();

    final once = DateTime.now();
    await tester.enterText(find.byType(TextField), 'bugün rapor');
    await tester.tap(find.bySemanticsLabel(Metinler.ekleDugmesi));
    await tester.pump();
    final sonra = DateTime.now();

    String bekle(DateTime g) =>
        'ekle|rapor|null|${DateTime.utc(g.year, g.month, g.day).toIso8601String()}|';
    expect(sira.single, anyOf(bekle(once), bekle(sonra)));
  });
}

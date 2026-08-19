@TestOn('vm')
library;

// ODEV.md §4(a) -- "Kullanici goreve ONCELIK ve SON TARIH verir, ikisini de
// listede gorur" dilimi.
//
// 🔴 BU DOSYA YENI BIR G<n>/D-<x> KAPISI ILAN ETMEZ -- kilitli backend
// sozlesmesini (FieldStrategyRegistry: `priority`/`dueAt` = scalar LWW;
// ProjectionFields: `ReadInt` + `ReadDate`) istemci urun yoluna baglayan
// urun kodu testidir.
//
// dart:io kullanir (TAKVIM GUNU PINI'nin STATIK ayagi) ⇒ @TestOn('vm')
// PAZARLIKSIZ (g14 / o68 emsali).

import 'dart:convert';
import 'dart:io';

import 'package:client/design/metinler.dart';
import 'package:client/senkron/uzak_degisiklik_uygulayici.dart';
import 'package:client/sunum/gorev_listesi_ekrani.dart';
import 'package:client/sunum/gorev_satiri.dart';
import 'package:client/sunum/senkron_rozeti.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/veritabani.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Gorev _gorev({int? oncelik, DateTime? sonTarih}) => Gorev(
  id: 'ornek',
  baslik: 'Rapor gonder',
  tamamlandi: false,
  olusturuldu: DateTime.utc(2026, 8, 10),
  guncellendi: DateTime.utc(2026, 8, 10),
  senkronDurumu: 'yerel',
  silindi: false,
  oncelik: oncelik,
  sonTarih: sonTarih,
);

Map<String, Object?> _hlcJson(int wall, int sayac, String clientId) => {
  'wallMs': wall,
  'counter': sayac,
  'clientId': clientId,
};

Map<String, Object?> _degisiklik({
  required String opId,
  required String clientId,
  required String entityId,
  required int wall,
  required Map<String, Object?> alanlar,
}) => {
  'cursor': {'wallMs': wall},
  'payload': {
    'operationId': opId,
    'clientId': clientId,
    'entityId': entityId,
    'actorId': 'aktor',
    'entityType': 'Task',
    'opHlc': _hlcJson(wall, 1, clientId),
    'fields': alanlar.map(
      (ad, deger) =>
          MapEntry(ad, {'value': deger, 'hlc': _hlcJson(wall, 1, clientId)}),
    ),
  },
};

void main() {
  group('SAF: oncelik esleme', () {
    test('enum <-> sayi gidis-donus, UC seviyenin HEPSI', () {
      for (final o in Oncelik.values) {
        expect(oncelikSayidan(oncelikSayiya(o)), o, reason: '$o gidis-donusu');
      }
      expect(oncelikSayiya(null), isNull);
      expect(oncelikSayidan(null), isNull);
    });

    test('PINLI sayilar: 1=yuksek, 2=orta, 3=dusuk', () {
      expect(oncelikSayiya(Oncelik.yuksek), 1);
      expect(oncelikSayiya(Oncelik.orta), 2);
      expect(oncelikSayiya(Oncelik.dusuk), 3);
    });

    test('BILINMEYEN sayi ekranda cizilmez (null doner) ama EZILMEZ', () {
      for (final n in [0, 4, -1, 99]) {
        expect(
          oncelikSayidan(n),
          isNull,
          reason:
              'baska bir istemcinin yazdigi $n degeri GOSTERILMEZ; ama DB/tel '
              'katmani onu HAM `int?` olarak tasidigi icin EZILMEZ',
        );
      }
    });
  });

  group('SAF: tel bicimi (backend sozlesmesine karsi)', () {
    test(
      'priority ONDALIK TAMSAYI dizesidir (int.TryParse/InvariantCulture)',
      () {
        expect(oncelikTele(1), '1');
        expect(oncelikTele(3), '3');
        expect(oncelikTele(null), isNull, reason: 'null = alani TEMIZLE');
      },
    );

    test('dueAt sunucunun TryParseExact kalibina oturur', () {
      final tel = sonTarihTele(DateTime.utc(2026, 8, 21));
      expect(tel, '2026-08-21T00:00:00.000Z');
      // Sunucu kalibi: yyyy-MM-dd'T'HH:mm:ss.FFFFFFFK -- 'K' burada 'Z'dir,
      // 'FFFFFFF' en fazla YEDI ondalik basamak kabul eder; Dart UC basamak
      // uretir (mikrosaniye varsa ALTI), ikisi de kalibin icinde kalir.
      expect(
        RegExp(
          r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,7}Z$',
        ).hasMatch(tel!),
        isTrue,
        reason: 'tel bicimi sunucunun kabul ettigi ISO kalibinda olmali: $tel',
      );
    });

    test('YEREL bir DateTime bile DAIMA UTC (Z sonekli) gonderilir', () {
      // 🔴 Ofset TASIMAYAN bir dize sunucuda `AssumeUniversal` ile UTC SAYILIR
      // -- yani `.toUtc()` dusurulurse yerel saat sessizce UTC diye okunur
      // (SS1.3'un uc saatlik kaymasi). Degerin KENDISI ortama bagli oldugu
      // icin (CI UTC, gelistirme makinesi UTC+3) yalniz 'Z' soneki olculur.
      final tel = sonTarihTele(DateTime(2026, 8, 21, 13, 45));
      expect(tel, isNotNull);
      expect(tel!.endsWith('Z'), isTrue, reason: 'tel: $tel');
    });
  });

  group('SAF: satirda gosterim', () {
    test('tarih etiketi YEREL SAATE CEVIRMEZ (takvim gunu)', () {
      expect(
        GorevSatiri.tarihEtiketi(DateTime.utc(2026, 8, 21)),
        '21 Ağu 2026',
      );
      expect(GorevSatiri.tarihEtiketi(DateTime.utc(2026, 1, 1)), '1 Oca 2026');
      expect(
        GorevSatiri.tarihEtiketi(DateTime.utc(2026, 12, 31)),
        '31 Ara 2026',
      );
    });

    test('ay kisaltmalari tablosu 12 uzunlugunda ve 1..12 ile indislenir', () {
      expect(Metinler.ayKisaltmalari, hasLength(12));
      expect(Metinler.ayKisaltmalari[DateTime.august - 1], 'Ağu');
    });

    test('meta metni: yok / yalniz oncelik / yalniz tarih / ikisi', () {
      expect(GorevSatiri.metaMetni(_gorev()), isNull);
      expect(GorevSatiri.metaMetni(_gorev(oncelik: 1)), Metinler.oncelikYuksek);
      expect(
        GorevSatiri.metaMetni(_gorev(sonTarih: DateTime.utc(2026, 8, 21))),
        '21 Ağu 2026',
      );
      expect(
        GorevSatiri.metaMetni(
          _gorev(oncelik: 2, sonTarih: DateTime.utc(2026, 8, 21)),
        ),
        '${Metinler.oncelikOrta} · 21 Ağu 2026',
      );
    });

    test('BILINMEYEN oncelik meta satirina SIZMAZ', () {
      expect(GorevSatiri.metaMetni(_gorev(oncelik: 7)), isNull);
    });
  });

  // 🔴 TAKVIM GUNU PINI'nin ENV-BAGIMSIZ ayagi. Bir widget testi bunu
  // GUVENILIR olcemez: CI UTC kosar, orada `.toLocal()` HICBIR SEYI
  // kaydirmaz ve mutant SESSIZCE GECER. Statik tarama env'den bagimsizdir
  // (bu projenin g14/o68'de kullandigi AYNI yontem).
  group('TAKVIM GUNU PINI (STATIK)', () {
    const yollar = [
      'lib/sunum/gorev_satiri.dart',
      'lib/veri/gorev_deposu.dart',
      'lib/senkron/uzak_degisiklik_uygulayici.dart',
    ];

    test('tarih tasiyan uc dosyada .toLocal() YOK', () {
      for (final yol in yollar) {
        final satirlar = File(yol).readAsLinesSync();
        expect(satirlar, isNotEmpty, reason: '$yol okunamadi -- kapi KORLESTI');
        final govde = satirlar
            .map((s) => s.contains('//') ? s.substring(0, s.indexOf('//')) : s)
            .join('\n');
        expect(
          govde,
          isNot(contains('.toLocal()')),
          reason:
              '$yol: `.toLocal()` takvim gununu UTC+3`te BIR GUN kaydirir '
              '(21 Ağu 00:00Z -> 21 Ağu 03:00 yerel gorunur ama ters yonde '
              '20 Ağu`a duser). Tarih DAIMA UTC takvim gunu olarak tasinir.',
        );
      }
    });
  });

  group('DEPO: tek op / tek transaction', () {
    late Veritabani db;
    late DriftGorevDeposu depo;
    final sabitSaat = DateTime.utc(2026, 8, 14, 12);

    setUp(() async {
      db = Veritabani(NativeDatabase.memory());
      var sayac = 0;
      String idUret() => 'ost-${sayac++}';
      final ayarlarDeposu = AyarlarDeposu(db, idUret: idUret);
      final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
      depo = DriftGorevDeposu(
        db,
        saat: () => sabitSaat,
        idUret: idUret,
        hlc: HlcUretici(
          simdiMs: () => sabitSaat.millisecondsSinceEpoch,
          clientId: ayarlar.clientId,
        ),
        ayarlarDeposu: ayarlarDeposu,
        actorId: ayarlar.devUserId,
      );
      await depo.ekle('Rapor gonder');
    });

    tearDown(() async => db.close());

    Future<String> mevcutId() async =>
        (await db.select(db.gorevler).getSingle()).id;

    Future<Map<String, Object?>> sonOpGovdesi() async {
      final kuyruk = await db.select(db.senkronKuyrugu).get();
      return jsonDecode(kuyruk.last.govdeJson) as Map<String, Object?>;
    }

    test(
      'oncelik + son tarih yazilir; projeksiyon VE kuyruk AYNI turda',
      () async {
        final id = await mevcutId();
        await depo.ayrintilariGuncelle(
          id,
          oncelik: const Yazim(1),
          sonTarih: Yazim(DateTime.utc(2026, 8, 21)),
        );

        final satir = await db.select(db.gorevler).getSingle();
        expect(satir.oncelik, 1);
        expect(satir.sonTarih, DateTime.utc(2026, 8, 21));

        final govde = await sonOpGovdesi();
        final alanlar = govde['fields'] as Map<String, Object?>;
        expect(alanlar.keys.toSet(), {'priority', 'dueAt'});
        expect((alanlar['priority'] as Map)['value'], '1');
        expect((alanlar['dueAt'] as Map)['value'], '2026-08-21T00:00:00.000Z');
      },
    );

    test('DEGISMEYEN alan tele KONMAZ (yalniz baslik gonderilir)', () async {
      final id = await mevcutId();
      await depo.ayrintilariGuncelle(id, baslik: const Yazim('Yeni baslik'));

      final govde = await sonOpGovdesi();
      final alanlar = govde['fields'] as Map<String, Object?>;
      expect(
        alanlar.keys.toSet(),
        {'title'},
        reason:
            'degismemis bir alani yeniden damgalamak, arada gelen uzak bir '
            'yazimi LWW ile sessizce EZERDI',
      );
    });

    test(
      'Yazim(null) = TEMIZLE: tele `value: null` konur, kolon NULL olur',
      () async {
        final id = await mevcutId();
        await depo.ayrintilariGuncelle(id, oncelik: const Yazim(2));
        expect((await db.select(db.gorevler).getSingle()).oncelik, 2);

        await depo.ayrintilariGuncelle(id, oncelik: const Yazim(null));
        expect((await db.select(db.gorevler).getSingle()).oncelik, isNull);

        final govde = await sonOpGovdesi();
        final alanlar = govde['fields'] as Map<String, Object?>;
        expect(alanlar.containsKey('priority'), isTrue);
        expect((alanlar['priority'] as Map)['value'], isNull);
      },
    );

    test('HICBIR alan verilmezse op URETILMEZ (D2: bos op yasak)', () async {
      final id = await mevcutId();
      final oncekiKuyruk = (await db.select(db.senkronKuyrugu).get()).length;
      await depo.ayrintilariGuncelle(id);
      final sonrakiKuyruk = (await db.select(db.senkronKuyrugu).get()).length;
      expect(sonrakiKuyruk, oncekiKuyruk);
    });

    test('bir op icindeki TUM HLC`ler AYNI damgadir (D3)', () async {
      final id = await mevcutId();
      await depo.ayrintilariGuncelle(
        id,
        baslik: const Yazim('X'),
        oncelik: const Yazim(3),
        sonTarih: Yazim(DateTime.utc(2026, 9, 1)),
      );
      final govde = await sonOpGovdesi();
      final opHlc = govde['opHlc'] as Map<String, Object?>;
      final alanlar = govde['fields'] as Map<String, Object?>;
      for (final ad in ['title', 'priority', 'dueAt']) {
        expect(
          (alanlar[ad] as Map)['hlc'],
          opHlc,
          reason: '$ad alaninin HLC`si opHlc ile AYNI olmali',
        );
      }
    });
  });

  group('UZAK: iki yeni skaler kanal projeksiyona iner', () {
    late Veritabani db;
    late UzakDegisiklikUygulayici uygulayici;

    setUp(() {
      db = Veritabani(NativeDatabase.memory());
      uygulayici = UzakDegisiklikUygulayici(db, clientId: 'bizim-client');
    });

    tearDown(() async => db.close());

    test('YENI entity: priority + dueAt INSERT dalinda yazilir', () async {
      await uygulayici.changesUygula([
        _degisiklik(
          opId: 'op-1',
          clientId: 'uzak-client',
          entityId: 'e1',
          wall: 1000,
          alanlar: {
            'title': 'Uzaktan gelen',
            'priority': '2',
            'dueAt': '2026-08-21T00:00:00.000Z',
          },
        ),
      ]);

      final satir = await db.select(db.gorevler).getSingle();
      expect(satir.baslik, 'Uzaktan gelen');
      expect(satir.oncelik, 2);
      expect(satir.sonTarih, DateTime.utc(2026, 8, 21));
    });

    test('MEVCUT entity: UPDATE dalinda yazilir', () async {
      await uygulayici.changesUygula([
        _degisiklik(
          opId: 'op-1',
          clientId: 'uzak-client',
          entityId: 'e1',
          wall: 1000,
          alanlar: {'title': 'Ilk'},
        ),
      ]);
      await uygulayici.changesUygula([
        _degisiklik(
          opId: 'op-2',
          clientId: 'uzak-client',
          entityId: 'e1',
          wall: 2000,
          alanlar: {'priority': '1', 'dueAt': '2026-09-01T00:00:00.000Z'},
        ),
      ]);

      final satir = await db.select(db.gorevler).getSingle();
      expect(satir.baslik, 'Ilk', reason: 'baslik kanali bu op`ta gelmedi');
      expect(satir.oncelik, 1);
      expect(satir.sonTarih, DateTime.utc(2026, 9, 1));
    });

    test('UZAKTAN TEMIZLEME (value: null) kolonu NULL yapar', () async {
      await uygulayici.changesUygula([
        _degisiklik(
          opId: 'op-1',
          clientId: 'uzak-client',
          entityId: 'e1',
          wall: 1000,
          alanlar: {'title': 'Ilk', 'priority': '1'},
        ),
      ]);
      expect((await db.select(db.gorevler).getSingle()).oncelik, 1);

      await uygulayici.changesUygula([
        _degisiklik(
          opId: 'op-2',
          clientId: 'uzak-client',
          entityId: 'e1',
          wall: 2000,
          alanlar: {'priority': null},
        ),
      ]);

      expect(
        (await db.select(db.gorevler).getSingle()).oncelik,
        isNull,
        reason:
            '"geldi mi" BAYRAGI olmasaydi (`g.oncelik != null` ile karar '
            'verilseydi) bu temizleme SESSIZCE DUSERDI',
      );
    });

    test('AYRISTIRILAMAYAN deger NULL`a duser, satiri patlatmaz', () async {
      await uygulayici.changesUygula([
        _degisiklik(
          opId: 'op-1',
          clientId: 'uzak-client',
          entityId: 'e1',
          wall: 1000,
          alanlar: {'title': 'Ilk', 'priority': 'abc', 'dueAt': 'not-a-date'},
        ),
      ]);

      final satir = await db.select(db.gorevler).getSingle();
      expect(satir.baslik, 'Ilk');
      expect(satir.oncelik, isNull);
      expect(satir.sonTarih, isNull);
    });
  });

  // 🔴 [BAGIMSIZ DENETIM, o74] TAKVIM GUNU PINI'nin YAZMA ayagi. Statik
  // `.toLocal()` taramasi `secilen.toUtc()` ya da `.utc`si dusurulmus
  // `DateTime(y,m,d)` mutantlarini GORMEZ -- ikisi de `.toLocal()` icermez.
  // Buradaki `isUtc`/`hour` iddialari onlari CI'da (UTC) bile oldurur.
  group('TAKVIM GUNU PINI: takvimGunu() normalizasyonu', () {
    test('YEREL girdi -> UTC gun basi, y/m/d KORUNUR', () {
      final gun = GorevSatiri.takvimGunu(DateTime(2026, 8, 21, 13, 45, 30));
      expect(gun.isUtc, isTrue, reason: '`.utc` dusurulmus olabilir');
      expect(gun.hour, 0, reason: '`secilen.toUtc()` yazilmis olabilir');
      expect(gun.minute, 0);
      expect(gun.second, 0);
      expect([gun.year, gun.month, gun.day], [2026, 8, 21]);
    });

    test('gidis-donus: takvimGunu -> tel -> etiket gun kaydirmaz', () {
      final gun = GorevSatiri.takvimGunu(DateTime(2026, 8, 21, 23, 59));
      expect(sonTarihTele(gun), '2026-08-21T00:00:00.000Z');
      expect(GorevSatiri.tarihEtiketi(gun), '21 Ağu 2026');
    });
  });

  group('WIDGET: meta satiri', () {
    Widget sarmala(Gorev gorev) => MaterialApp(
      home: Scaffold(
        body: GorevSatiri(gorev: gorev, onTamamlaDegisti: (_) {}),
      ),
    );

    testWidgets('oncelik + son tarih VARSA meta satiri CIZILIR', (
      tester,
    ) async {
      await tester.pumpWidget(
        sarmala(_gorev(oncelik: 1, sonTarih: DateTime.utc(2026, 8, 21))),
      );
      expect(
        find.text('${Metinler.oncelikYuksek} · 21 Ağu 2026'),
        findsOneWidget,
      );
    });

    // 🔴 [BAGIMSIZ DENETIM, o74] "meta yoksa HIC CIZILMEZ" iddiasi DIZGE
    // YOKLUGUYLA olculemez -- oncelik/tarih tasimayan bir gorevde o dizgeler
    // zaten hicbir halde cizilmez (BOS IDDIA). `_baslikVeMeta`'nin gercek
    // iddiasi "meta yokken agaca EK BIR Text dugumu girmez"tir; bos bir
    // `Text('')` ekleyen mutant satir yuksekligini degistirir (G13/G14/G15'in
    // konusu) ama dizge iddiasindan GECER. Bu yuzden FARK olculur.
    testWidgets('IKISI DE YOKSA agaca EK Text dugumu GIRMEZ (fark = 1)', (
      tester,
    ) async {
      int textSayisi() => tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(GorevSatiri),
              matching: find.byType(Text),
            ),
          )
          .length;

      await tester.pumpWidget(sarmala(_gorev()));
      final metasiz = textSayisi();

      await tester.pumpWidget(
        sarmala(_gorev(oncelik: 1, sonTarih: DateTime.utc(2026, 8, 21))),
      );
      final metali = textSayisi();

      expect(metasiz, greaterThan(0), reason: 'olcum korlestiyse yakala');
      expect(
        metali,
        metasiz + 1,
        reason:
            'meta satiri TAM BIR Text eklemeli; metasiz durumda EK dugum '
            'OLMAMALI (bos Text ekleyen mutant burada olur)',
      );
      expect(
        find.text('${Metinler.oncelikYuksek} · 21 Ağu 2026'),
        findsOneWidget,
      );
    });
  });

  // 🔴 [BAGIMSIZ DENETIM, o74] `showDatePicker`
  // `assert(!initialDate.isBefore(firstDate))` tasir. `sonTarih` BASKA BIR
  // ISTEMCIDEN gelebilir (sunucu herhangi bir DateTimeOffset kabul eder) ya da
  // takvim yili donunce eski bir yerel gorev de aralik disina duser.
  // Kelepce olmadan tarih dugmesi HICBIR SEY YAPMAZ.
  group('WIDGET: tarih secici aralik kelepcesi', () {
    testWidgets('COK ESKI son tarihte tarih dugmesi yine de secici ACAR', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GorevSatiri(
              gorev: _gorev(sonTarih: DateTime.utc(2019, 3, 1)),
              onTamamlaDegisti: (_) {},
              onAyrintilarDuzenlendi: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(OutlinedButton));
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      expect(
        find.byType(DatePickerDialog),
        findsOneWidget,
        reason:
            'initialDate firstDate`tan ONCE ise showDatePicker assert atar ve '
            'dugme sessizce olur -- kelepce bunu onler',
      );
    });
  });

  // 🔴 [BAGIMSIZ DENETIM, o74] URUN YOLU. Onceki testler `GorevSatiri`'ni
  // DOGRUDAN kuruyordu; ekranin kablosu (`gorev_listesi_ekrani.dart`)
  // hicbir testten gecmiyordu ⇒ `oncelik: degisiklik.oncelik` satirini SILEN
  // mutant tum suiti geciyordu (kullanici onceligi secer, kaydeder, hicbir
  // yere yazilmaz). Sahte depo ARGUMANLARI da kaydeder -- yalniz cagrildi
  // demek, alan dusuren mutanti yakalamaz.
  group('URUN YOLU: ekran kablosu', () {
    testWidgets('ekrandan oncelik secilir -> depoya ARGUMANIYLA ulasir', (
      tester,
    ) async {
      final depo = _KayitTutanDepo(_gorev());
      await tester.pumpWidget(
        MaterialApp(home: GorevListesiEkrani(depo: depo)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Metinler.oncelikYuksek));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Metinler.kaydetDugmesi));
      await tester.pumpAndSettle();

      expect(depo.cagrilar, hasLength(1));
      final c = depo.cagrilar.single;
      expect(c.id, 'ornek');
      expect(c.oncelik, isNotNull, reason: 'oncelik argumani DUSURULMUS');
      expect(c.oncelik!.deger, oncelikSayiya(Oncelik.yuksek));
      expect(c.baslik, isNull, reason: 'baslik degismedi, tele konmamali');
      expect(c.sonTarih, isNull);
    });

    testWidgets(
      'KIRPILMAMIS baslikli gorevde yalniz oncelik degisirse baslik TELE KONMAZ',
      (tester) async {
        // Uzaktan 'Rapor gonder ' (sondaki bosluk) gelmis olabilir. Ham degerle
        // karsilastiran bir el, kullanici basliga HIC DOKUNMASA bile `title`i
        // yeniden damgalar ve arada gelen uzak yazimi LWW ile EZER.
        final depo = _KayitTutanDepo(
          Gorev(
            id: 'ornek',
            baslik: 'Rapor gonder ',
            tamamlandi: false,
            olusturuldu: DateTime.utc(2026, 8, 10),
            guncellendi: DateTime.utc(2026, 8, 10),
            senkronDurumu: 'yerel',
            silindi: false,
          ),
        );
        await tester.pumpWidget(
          MaterialApp(home: GorevListesiEkrani(depo: depo)),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();
        await tester.tap(find.text(Metinler.oncelikOrta));
        await tester.pumpAndSettle();
        await tester.tap(find.text(Metinler.kaydetDugmesi));
        await tester.pumpAndSettle();

        expect(depo.cagrilar, hasLength(1));
        expect(depo.cagrilar.single.baslik, isNull);
        expect(
          depo.cagrilar.single.oncelik!.deger,
          oncelikSayiya(Oncelik.orta),
        );
      },
    );
  });
}

/// URUN YOLU testi icin: cagrilari ARGUMANLARIYLA kaydeden sahte depo.
class _Cagri {
  final String id;
  final Yazim<String>? baslik;
  final Yazim<int?>? oncelik;
  final Yazim<DateTime?>? sonTarih;
  const _Cagri(this.id, this.baslik, this.oncelik, this.sonTarih);
}

class _KayitTutanDepo implements GorevDeposu {
  final Gorev gorev;
  final List<_Cagri> cagrilar = [];

  _KayitTutanDepo(this.gorev);

  @override
  Stream<List<GorevGorunum>> gorevlerGorunur() => Stream.value([
    GorevGorunum(
      gorev: gorev,
      senkronDurumu: SenkronDurumTuru.yerel,
      cakismaVarMi: false,
    ),
  ]);

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

  @override
  Future<void> ayrintilariGuncelle(
    String id, {
    Yazim<String>? baslik,
    Yazim<int?>? oncelik,
    Yazim<DateTime?>? sonTarih,
    Yazim<String?>? projeId,
    Set<String>? etiketEklenen,
    Set<String>? etiketSilinen,
  }) async => cagrilar.add(_Cagri(id, baslik, oncelik, sonTarih));

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
}

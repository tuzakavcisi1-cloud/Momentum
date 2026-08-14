@TestOn('vm')
library;

// GOREV-A7 [K85 / spec v4 §5] -- G14 DIKEY DONUS KAPISI.
//
// 🔴 DIKEY DONUSUN AMACI KIRPMAYI ONLEMEK DEGILDIR. Onu D-A7-1 (kisa
// gorunur dizge) + D-A7-2 (maxLines) yapiyor. Dikey donusun isi SATIR
// YUKSEKLIGINI dusurmektir: rozet tam genislik alinca 2 satir yerine 1
// satira sigar. Olculmus gerekce (KANIT/A7/01-DENETIM.md §1.2): dikey
// donus rozete en fazla `maxWidth - 56` verir, uzun dizge 2.0x'te 1102,5
// px ister ⇒ TEK BASINA 72 kombinasyonun 61'inde kirpmayi kapatmiyordu.
//
// A8 dart:io kullanir ⇒ @TestOn('vm') PAZARLIKSIZ.

import 'dart:io';

import 'package:client/sunum/gorev_satiri.dart';
import 'package:client/sunum/senkron_rozeti.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Gorev _ornekGorev() => Gorev(
  id: 'g14-ornek',
  baslik: 'Sozlesmeyi gozden gecir ve imzala',
  tamamlandi: false,
  olusturuldu: DateTime.utc(2026, 7, 30, 12),
  guncellendi: DateTime.utc(2026, 7, 30, 12),
  senkronDurumu: 'yerel',
  silindi: false,
);

Widget _sarmalayici({
  required double genislik,
  required double olcek,
  required SenkronDurumTuru durum,
  bool cakismaVarMi = false,
  ValueChanged<String>? onBaslikDuzenlendi,
  VoidCallback? onSil,
}) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        final taban = MediaQuery.of(context);
        return MediaQuery(
          data: taban.copyWith(
            disableAnimations: true,
            textScaler: TextScaler.linear(olcek),
          ),
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: genislik,
                child: GorevSatiri(
                  gorev: _ornekGorev(),
                  onTamamlaDegisti: (_) {},
                  senkronDurumu: durum,
                  cakismaVarMi: cakismaVarMi,
                  onBaslikDuzenlendi: onBaslikDuzenlendi,
                  onSil: onSil,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// GorevSatiri'nin KENDI duzen Column'u. Alt bilesenlerin (Checkbox,
/// CakismaRozeti, SenkronRozeti) icinde Column YOKTUR -- A5 tam da bunu
/// yanlis-pozitif olarak sinar.
Finder _duzenColumn() =>
    find.descendant(of: find.byType(GorevSatiri), matching: find.byType(Column));

void main() {
  group('G14/A4 -- DAR ekran + BUYUK olcek ⇒ DIKEY', () {
    // Uc vaka. Birincisi spec'in kanonik ayagidir; diger ikisi MUTANT
    // KALDIRACIDIR ve olculerek secildi:
    //  · 320dp/1.0x: `baslikAsgari` OLMASA YATAY kalirdi (64+185,5 = 249,5
    //    < 320 ama 64+96+185,5 = 345,5 > 320) ⇒ M75 (baslikAsgari=0) BURADA
    //    isirir. Spec'in tek kanonik vakasi (320dp/2.0x) M75'e KOR kalirdi:
    //    orada baslikAsgari=0 olsa bile 64+343 = 407 > 320 ⇒ hala DIKEY.
    //  · 411dp/2.0x: `textScaler` VERILMESE YATAY kalirdi (64+96+185,5 =
    //    345,5 < 411 ama olcekli 64+96+343 = 503 > 411) ⇒ M77 BURADA isirir.
    //    320dp'de M77 de KOR kalirdi (345,5 > 320 ⇒ hala DIKEY).
    // Bu bir GEVSETME degil SIKILASTIRMADIR: spec'in vakasi AYNEN durur.
    const vakalar = <(double, double, SenkronDurumTuru, String)>[
      (320, 2.0, SenkronDurumTuru.gonderilmemis, 'spec kanonik ayagi'),
      (320, 1.0, SenkronDurumTuru.gonderilmemis, 'M75 kaldiraci (baslikAsgari)'),
      (411, 2.0, SenkronDurumTuru.gonderilmemis, 'M77 kaldiraci (textScaler)'),
    ];

    for (final (genislik, olcek, durum, neden) in vakalar) {
      testWidgets('${genislik}dp + ${olcek}x + ${durum.name} ⇒ DIKEY  [$neden]', (
        tester,
      ) async {
        await tester.pumpWidget(
          _sarmalayici(genislik: genislik, olcek: olcek, durum: durum),
        );
        await tester.pump();
        expect(
          _duzenColumn(),
          findsOneWidget,
          reason:
              'DIKEY duzen bekleniyordu ($neden) -- GorevSatiri altinda '
              'Column bulunamadi. baslikAsgari=${GorevSatiri.baslikAsgari}',
        );
      });
    }
  });

  group(
    'IS-EMRI-o68 -- baslik duzenleme ikonu `sabitler` KALDIRACI (M77b-sinifi)',
    () {
      // OLCULDU (bu is emrinde, ayni yontemle M75/M77 icin yapildigi gibi):
      // 370dp/1.0x/gonderilmemis -- SABIT terimler DISINDA HERSEY (durum,
      // olcek, rozetIstedigi≈185,5) M75 vakasiyla AYNI. onBaslikDuzenlendi
      // NULL iken 64+96+185,5=345,5 < 370 ⇒ YATAY. onBaslikDuzenlendi VARKEN
      // 116+96+185,5=397,5 > 370 ⇒ DIKEY. 345,5..397,5 araliginin ORTASI
      // (370) secildi -- her iki uca da ~25dp pay birakir (font metrigi
      // kaymasina karsi TAVANLI guvenlik payi).
      //
      // Gerekce (is emri §1.5): `_dikeyMi`nin `sabitler` toplami YENI
      // dokunma hedefini SAYMAZSA, OLCULEN duzen (bu formul) ile CIZILEN
      // duzen sessizce ayrisir -- bu kaldirac O terimi kaldiran/unutan bir
      // mutanti YAKALAR; ne mevcut M75/M77 (onBaslikDuzenlendi HER ZAMAN
      // null oldugu icin) ne de widget/kabul testleri (yalniz CAGRILDIGINI
      // dogrular, GENISLIK ESIGINI degil) bunu yakalayamazdi.
      testWidgets(
        '370dp + 1.0x + gonderilmemis + onBaslikDuzenlendi NULL ⇒ YATAY (taban)',
        (tester) async {
          await tester.pumpWidget(
            _sarmalayici(
              genislik: 370,
              olcek: 1.0,
              durum: SenkronDurumTuru.gonderilmemis,
            ),
          );
          await tester.pump();
          expect(
            _duzenColumn(),
            findsNothing,
            reason:
                'onBaslikDuzenlendi NULL iken 370dp YATAY kalmali -- '
                'kaldiracin TABANI budur (ikon CIZILMEDIGI icin sabitler '
                'buyumez)',
          );
        },
      );

      testWidgets(
        '370dp + 1.0x + gonderilmemis + onBaslikDuzenlendi VAR ⇒ DIKEY (kaldirac)',
        (tester) async {
          await tester.pumpWidget(
            _sarmalayici(
              genislik: 370,
              olcek: 1.0,
              durum: SenkronDurumTuru.gonderilmemis,
              onBaslikDuzenlendi: (_) {},
            ),
          );
          await tester.pump();
          expect(
            _duzenColumn(),
            findsOneWidget,
            reason:
                'AYNI genislikte (370dp) onBaslikDuzenlendi VARKEN DIKEY '
                'bekleniyordu -- `_dikeyMi`nin `sabitler` toplami duzenleme '
                'ikonunun 48dp+4dp genisligini SAYMAZSA (ya da ikon '
                'CIZILDIGI HALDE formul bunu gormezse) bu test SESSIZCE '
                'DUSER -- M77b-sinifi kusurun tam kendisi (is emri §1.5).',
          );
        },
      );

      // OLCULDU (bagimsiz denetimde istendi): cakismaVarMi VE
      // onBaslikDuzenlendi AYNI ANDA -- iki KOSULLU terim TOPLANMALI, biri
      // digerini EZMEMELI. 420dp: yalniz biri VARKEN 116+96+185,5=397,5<420
      // ⇒ YATAY (367 ve 370'teki kaldiraclarla AYNI mantik); IKISI BIRDEN
      // VARKEN 168+96+185,5=449,5>420 ⇒ DIKEY. Bu, terimlerden birinin
      // digerini SESSIZCE EZDIGI bir formul hatasini (ör. `?:` yerine
      // yanlislikla ikinci `if` ilk `if`i EZERSE) yakalar.
      testWidgets(
        '420dp + 1.0x + gonderilmemis + cakismaVarMi VE onBaslikDuzenlendi ⇒ DIKEY (toplam)',
        (tester) async {
          await tester.pumpWidget(
            _sarmalayici(
              genislik: 420,
              olcek: 1.0,
              durum: SenkronDurumTuru.gonderilmemis,
              cakismaVarMi: true,
              onBaslikDuzenlendi: (_) {},
            ),
          );
          await tester.pump();
          expect(
            _duzenColumn(),
            findsOneWidget,
            reason:
                'cakismaVarMi VE onBaslikDuzenlendi AYNI ANDA VARKEN 420dp '
                'DIKEY bekleniyordu -- iki kosullu terim TOPLANMALI (168), '
                'biri digerini EZMEMELI.',
          );
        },
      );

      testWidgets(
        '420dp + 1.0x + gonderilmemis + YALNIZ cakismaVarMi ⇒ YATAY (kontrol)',
        (tester) async {
          await tester.pumpWidget(
            _sarmalayici(
              genislik: 420,
              olcek: 1.0,
              durum: SenkronDurumTuru.gonderilmemis,
              cakismaVarMi: true,
            ),
          );
          await tester.pump();
          expect(
            _duzenColumn(),
            findsNothing,
            reason:
                'YALNIZ cakismaVarMi (onBaslikDuzenlendi NULL) VARKEN 420dp '
                'YATAY kalmali -- 420dp testinin TABAN karsilastirmasi.',
          );
        },
      );
    },
  );

  group(
    'IS-EMRI-o72 -- silme ikonu `sabitler` KALDIRACI (M-o72-2, M77b-sinifi)',
    () {
      // AYNI kaldirac deseni IS-EMRI-o68'in onBaslikDuzenlendi grubuyla:
      // onSil'in eklediği terim (MOlcu.dokunmaHedefi + MBosluk.xs) BUYUKLUK
      // olarak AYNIDIR ⇒ 370dp/1.0x/gonderilmemis esigi AYNEN gecerlidir
      // (64+96+185,5=345,5<370 NULL iken; 116+96+185,5=397,5>370 VARKEN).
      // Gerekce (is emri D4): `_dikeyMi`nin `sabitler` toplami onSil'in
      // dokunma hedefini SAYMAZSA, OLCULEN duzen ile CIZILEN duzen sessizce
      // ayrisir -- M-o72-2 tam bunu hedefler.
      testWidgets(
        '370dp + 1.0x + gonderilmemis + onSil VAR ⇒ DIKEY (kaldirac, D4 urun yolu)',
        (tester) async {
          await tester.pumpWidget(
            _sarmalayici(
              genislik: 370,
              olcek: 1.0,
              durum: SenkronDurumTuru.gonderilmemis,
              onSil: () {},
            ),
          );
          await tester.pump();
          expect(
            _duzenColumn(),
            findsOneWidget,
            reason:
                'AYNI genislikte (370dp) onSil VARKEN DIKEY bekleniyordu -- '
                '`_dikeyMi`nin `sabitler` toplami silme ikonunun 48dp+4dp '
                'genisligini SAYMAZSA (ya da ikon CIZILDIGI HALDE formul '
                'bunu gormezse) bu test SESSIZCE DUSER -- M77b-sinifi '
                'kusurun tam kendisi (is emri D4/M-o72-2).',
          );
        },
      );
    },
  );

  group('G14/A5 -- GENIS ekran + 1.0x ⇒ YATAY (yanlis-pozitif kontrolu)', () {
    testWidgets('800dp + 1.0x + yerel ⇒ Column YOK', (tester) async {
      await tester.pumpWidget(
        _sarmalayici(
          genislik: 800,
          olcek: 1.0,
          durum: SenkronDurumTuru.yerel,
        ),
      );
      await tester.pump();
      expect(
        _duzenColumn(),
        findsNothing,
        reason: 'genis ekranda YATAY kalmali -- "DIKEY daima true" bir '
            'cozum DEGIL, kapinin korlesmesidir (M76)',
      );
    });
  });

  group('G14/A6 -- KARARLILIK: ayni girdi iki kez pump ⇒ ayni duzen', () {
    testWidgets('320dp + 2.0x + gonderilmemis: titreme yok', (tester) async {
      Widget agac() => _sarmalayici(
        genislik: 320,
        olcek: 2.0,
        durum: SenkronDurumTuru.gonderilmemis,
      );

      await tester.pumpWidget(agac());
      await tester.pump();
      final ilkColumn = _duzenColumn().evaluate().length;
      final ilkBoyut = tester.getSize(find.byType(SenkronRozeti));

      await tester.pumpWidget(agac());
      await tester.pump();
      final ikinciColumn = _duzenColumn().evaluate().length;
      final ikinciBoyut = tester.getSize(find.byType(SenkronRozeti));

      expect(ikinciColumn, ilkColumn, reason: 'duzen secimi degisti (titreme)');
      expect(ikinciBoyut, ilkBoyut, reason: 'rozet boyutu degisti (titreme)');
    });
  });

  group('G14/A7 -- senkronize (metin null) ⇒ 320dp+2.0x\'te bile YATAY', () {
    testWidgets('rozet cizilmiyorsa dikeye donmenin sebebi de yok', (tester) async {
      await tester.pumpWidget(
        _sarmalayici(
          genislik: 320,
          olcek: 2.0,
          durum: SenkronDurumTuru.senkronize,
        ),
      );
      await tester.pump();
      expect(SenkronRozeti.metinIcin(SenkronDurumTuru.senkronize), isNull);
      expect(
        _duzenColumn(),
        findsNothing,
        reason: 'senkronize rozet CIZMEZ (SizedBox.shrink) ⇒ olculecek metin '
            'yok; dikey donus GEREKSIZ bir satir yuksekligi ekler',
      );
    });
  });

  group('G14/A8 -- STATIK: her TextPainter( cagrisi dispose() edilir', () {
    // Olculmus gerekce: TextPainter dispose EDILMEZSE Flutter'in leak
    // izleyicisi debug modda uyarir ve bellek sizar. M83 bu satiri siler.
    //
    // BEYAN EDILMIS SINIR: "govdesinde" burada "ayni dosyada, cagriyi
    // izleyen 40 satir icinde ve BIR SONRAKI TextPainter( cagrisindan
    // ONCE" olarak mekanikleStirilmistir. Tam bir kapsam (scope) cozumu
    // ayristirici ister; bu kapi onu YAPMAZ ve yapmadigini SOYLER.
    test('lib/sunum altindaki her TextPainter( cagrisi 40 satir icinde dispose()', () {
      final dosyalar = Directory('lib/sunum')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();
      expect(dosyalar, isNotEmpty, reason: 'lib/sunum taranacak dosya yok');

      final cagriSayaci = <String>[];
      final disposesizlar = <String>[];
      final cagri = RegExp(r'\bTextPainter\s*\(');

      for (final dosya in dosyalar) {
        final satirlar = dosya.readAsLinesSync();
        final cagriSatirlari = <int>[];
        for (var i = 0; i < satirlar.length; i++) {
          if (satirlar[i].trimLeft().startsWith('//')) continue;
          if (cagri.hasMatch(satirlar[i])) cagriSatirlari.add(i);
        }
        for (var k = 0; k < cagriSatirlari.length; k++) {
          final bas = cagriSatirlari[k];
          final sonrakiCagri = k + 1 < cagriSatirlari.length
              ? cagriSatirlari[k + 1]
              : satirlar.length;
          final son = [bas + 40, sonrakiCagri, satirlar.length]
              .reduce((a, b) => a < b ? a : b);
          final govde = satirlar.sublist(bas, son).join('\n');
          cagriSayaci.add('${dosya.path}:${bas + 1}');
          if (!govde.contains('.dispose()')) {
            disposesizlar.add('${dosya.path}:${bas + 1}: ${satirlar[bas].trim()}');
          }
        }
      }

      // KOR KAPI KONTROLU: taranan dosyalarda hic TextPainter yoksa bu test
      // hicbir sey olcmemis olur ve "gecti" demek YANILTICI olur.
      expect(
        cagriSayaci,
        isNotEmpty,
        reason: 'lib/sunum altinda TextPainter( cagrisi BULUNAMADI -- '
            'D-A7-3 kaldirildiysa bu kapi KORLESMISTIR, sessizce gecmemeli',
      );
      expect(
        disposesizlar,
        isEmpty,
        reason: 'Asagidaki TextPainter( cagrilarinda dispose() YOK '
            '(M83):\n${disposesizlar.join('\n')}',
      );
    });
  });
}

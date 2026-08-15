@TestOn('vm')
library;

// ODEV.md §4(a) DOGAL DIL DILIMI -- kapi testleri.
//
// Kapsam: kilitli sekiz kural (bkz. `dogal_dil_ayristirici.dart` basligi) *
// MUTANT KAPILARI (her biri ayristiricidaki TEK bir satirin mutasyonunu
// oldurur) * PROPERTY kapisi (rastgele token dizileriyle degismezler) *
// MEKANIK KOPYA KAPISI (`kDogalDilAzamiOncelik` ile `oncelikSayidan` ayni
// kumeyi tanir -- elle senkron tutulan bir kopya BIRAKILMAZ).
//
// Bu dosya DB'ye DOKUNMAZ: ayristirici saftir, kurulum GEREKTIRMEZ.

import 'dart:math';

import 'package:client/sunum/dogal_dil_ayristirici.dart';
import 'package:client/sunum/etiket_dogrulama.dart';
import 'package:client/veri/gorev_deposu.dart' show oncelikSayidan;
import 'package:flutter_test/flutter_test.dart';

/// Testlerin ORTAK "bugun"u: 15 Agustos 2026, Cumartesi -- saat/dilim
/// TASIYAN bir deger BILEREK secildi (normalizasyon mutantini oldurur).
final DateTime kBugun = DateTime(2026, 8, 15, 23, 45, 12);
final DateTime kBugunGun = DateTime.utc(2026, 8, 15);
final DateTime kYarinGun = DateTime.utc(2026, 8, 16);

DogalDilSonucu _coz(String ham, {DateTime? bugun}) =>
    dogalDilAyristir(ham, bugun: bugun ?? kBugun);

/// [liste]de [kume]den GECEN ilk eleman (yoksa `null`). `firstOrNull` SDK'da
/// degil `package:collection`da yasar -- teste yeni bagimlilik ACILMAZ.
String? _ilk(List<String> liste, List<String> kume) {
  for (final e in liste) {
    if (kume.contains(e)) return e;
  }
  return null;
}

void main() {
  group('kilitli ornek (CLAUDE.md §3)', () {
    test('yarın 17:00 rapor gönder #iş !p1 -> dort alan', () {
      final s = _coz('yarın 17:00 rapor gönder #iş !p1');

      // 🔴 MUTANT KAPISI (KILIT 3): saat AYRI BIR KURAL ALMAZ. Ayristirici
      // `17:00`u yutup atsaydi baslik "rapor gönder" olurdu -- kullanicinin
      // yazdigi saat hicbir yerde saklanmadigi icin bu SESSIZ KAYIPTIR.
      expect(s.baslik, '17:00 rapor gönder');
      expect(s.sonTarih, kYarinGun);
      expect(s.etiketler, ['iş']);
      expect(s.oncelik, 1);
    });

    test('onekler HER YERDE taninir (konum kurali yok)', () {
      final s = _coz('#iş rapor !p2 gönder bugün');
      expect(s.baslik, 'rapor gönder');
      expect(s.sonTarih, kBugunGun);
      expect(s.etiketler, ['iş']);
      expect(s.oncelik, 2);
    });
  });

  group('tarih -- cekirdek dagarcik (KILIT 1)', () {
    test('bugün / yarın takvim gunu UTC gece yarisidir', () {
      expect(_coz('bugün x').sonTarih, kBugunGun);
      expect(_coz('yarın x').sonTarih, kYarinGun);
      // 🔴 MUTANT KAPISI: `DateTime.utc(...)` yerine `DateTime(...)` yazilsa
      // (ya da normalizasyon dusurulse) `isUtc` false olur ve o74'un UC
      // SAATLIK KAYMASI geri gelir.
      expect(_coz('bugün x').sonTarih!.isUtc, isTrue);
      expect(_coz('yarın x').sonTarih!.hour, 0);
    });

    test('cagrildigi SAAT sonucu degistirmez (saflik)', () {
      // 🔴 MUTANT KAPISI: `bugunGun` normalizasyonu silinip ham `bugun`
      // kullanilsaydi, gece 23:45'te cagrilan `yarın` 16 Agu 23:45 olurdu.
      final gece = _coz('yarın', bugun: DateTime(2026, 8, 15, 23, 59, 59));
      final sabah = _coz('yarın', bugun: DateTime(2026, 8, 15, 0, 0, 1));
      expect(gece.sonTarih, kYarinGun);
      expect(sabah.sonTarih, kYarinGun);
    });

    test('ay sonu / yil sonu sinirinda yarın kaymaz', () {
      expect(
        _coz('yarın', bugun: DateTime(2026, 12, 31, 12)).sonTarih,
        DateTime.utc(2027, 1, 1),
      );
      expect(
        _coz('yarın', bugun: DateTime(2028, 2, 28, 12)).sonTarih,
        DateTime.utc(2028, 2, 29), // 2028 ARTIK YIL
      );
    });

    test('gg.aa.yyyy ve yyyy-aa-gg', () {
      expect(_coz('x 21.08.2026').sonTarih, DateTime.utc(2026, 8, 21));
      expect(_coz('x 2026-08-21').sonTarih, DateTime.utc(2026, 8, 21));
      expect(_coz('x 2026-8-21').sonTarih, DateTime.utc(2026, 8, 21));
    });

    test('yilsiz gg.aa DAIMA icinde bulunulan yil (KILIT 2)', () {
      expect(_coz('x 21.08').sonTarih, DateTime.utc(2026, 8, 21));
      // 🔴 MUTANT KAPISI: "gecmisse gelecek yila tasi" mutanti burada olur --
      // 3 Ocak 2026 GECMISTIR ve OYLE KALIR (Onur 15 Agu 2026'da kilitledi).
      expect(_coz('x 03.01').sonTarih, DateTime.utc(2026, 1, 3));
    });

    test('yilsiz tarihin yili CAGIRANIN bugun`undan gelir (SAFLIK)', () {
      // 🔴 MUTANT KAPISI [bagimsiz denetim, o77]: yil `DateTime.now().year`den
      // ya da SABIT 2026'dan alinsaydi butun testler yesil kalirdi -- kbugun
      // zaten 2026. Bu ayak `bugun` parametresini 2026 DISINA cikararak
      // "saati disaridan al" iddiasini MEKANIK olarak olcer (ve 2027'de
      // kendiliginde kirmizi yanacak bir zaman bombasini bugun oldurur).
      expect(
        _coz('x 21.08', bugun: DateTime(2031, 3, 4)).sonTarih,
        DateTime.utc(2031, 8, 21),
      );
      expect(
        _coz('x 03.01', bugun: DateTime(1999, 12, 31, 23, 59)).sonTarih,
        DateTime.utc(1999, 1, 3),
      );
    });

    test('YIL 0 REDDEDILIR (sunucu DateTimeOffset`i ayristiramaz)', () {
      // 🔴 [bagimsiz denetim, o77] `DateTime.utc(0,1,1)` Dart'ta GECERLIDIR ve
      // `0000-01-01T00:00:00.000Z` uretir; sunucunun `TryParseExact`i bunu
      // `MalformedFields`e atar ⇒ istemci cizer, sunucu DUSURUR (sinir otesi
      // sessiz kayip). Token baslikta KALMALI.
      for (final ham in const ['0000-01-01', '01.01.0000', '0000-12-31']) {
        expect(_coz('x $ham').sonTarih, isNull, reason: ham);
        expect(_coz('x $ham').baslik, 'x $ham', reason: ham);
      }
    });

    test('BASAMAK KELEPCELERI pinli (dolgulu/kisa bicimler tanINMAZ)', () {
      // 🔴 MUTANT KAPISI [bagimsiz denetim, o77]: `\d{1,2}` -> `\d{1,3}` ya da
      // `\d{4}` -> `\d{2,4}` genislemeleri BUTUN takim yesilken geciyordu.
      for (final ham in const [
        '0021.08.2026',
        '021.08',
        '26-08-21',
        '21.08.26',
        '2026-08-021',
      ]) {
        expect(_coz('x $ham').sonTarih, isNull, reason: ham);
        expect(_coz('x $ham').baslik, 'x $ham', reason: ham);
      }
    });

    test('ANAHTAR SOZCUK TAM esler -- `bugünkü`/`yarınki` BASLIKTA KALIR', () {
      // 🔴 MUTANT KAPISI [bagimsiz denetim, o77]: `token == 'bugün'` ->
      // `token.startsWith('bugün')` mutanti yesil geciyordu. Turkce'de
      // `bugünkü toplantı` en olasi girdilerden biri ve o mutant altinda
      // kullanicinin yazdigi ek SESSIZCE YOK OLURDU.
      for (final ham in const [
        'bugünkü toplantı',
        'yarınki sunum',
        'bugünlük iş',
        'yarından sonra',
      ]) {
        expect(_coz(ham).sonTarih, isNull, reason: ham);
        expect(_coz(ham).baslik, ham, reason: ham);
      }
    });

    test('GECERSIZ tarih tanINMAZ, token BASLIKTA KALIR', () {
      // 🔴 MUTANT KAPISI: `_takvimGunu`daki gidis-donus kontrolu silinirse
      // `DateTime.utc(2026,2,30)` PATLAMAZ, sessizce 2 Mart'a KAYAR --
      // kullanicinin gormedigi bir veri degisimi.
      for (final ham in const [
        '30.02.2026',
        '32.01.2026',
        '00.08.2026',
        '21.13.2026',
        '2026-02-30',
        '2026-00-10',
      ]) {
        final s = _coz('x $ham');
        expect(s.sonTarih, isNull, reason: '$ham tarih SAYILMAMALI');
        expect(s.baslik, 'x $ham', reason: '$ham baslikta KALMALI');
      }
    });

    test('29 Subat yalniz ARTIK YILDA gecerlidir', () {
      expect(_coz('29.02.2028').sonTarih, DateTime.utc(2028, 2, 29));
      expect(_coz('29.02.2027').sonTarih, isNull);
      expect(_coz('29.02.2027').baslik, '29.02.2027');
    });

    test('KAPSAM DISI dagarcik baslikta kalir', () {
      // Gun adlari / "haftaya" / "N gun sonra" bu dilimde TANINMAZ (KILIT 1).
      final s = _coz('pazartesi haftaya 3 gün sonra');
      expect(s.sonTarih, isNull);
      expect(s.baslik, 'pazartesi haftaya 3 gün sonra');
    });
  });

  group('oncelik (KILIT 4 + kopya kapisi)', () {
    test('!p1 !p2 !p3 tanINIR', () {
      expect(_coz('x !p1').oncelik, 1);
      expect(_coz('x !p2').oncelik, 2);
      expect(_coz('x !p3').oncelik, 3);
    });

    test('MEKANIK KOPYA KAPISI: kabul kumesi == oncelikSayidan kumesi', () {
      // 🔴 Bu test, `kDogalDilAzamiOncelik` sabiti ile `gorev_deposu.dart`
      // icindeki 1/2/3 pininin AYRISMASINI oldurur. Seviyeler degisirse
      // (or. dorduncu seviye) bu test elle senkron beklemeden KIRMIZI yanar.
      for (var n = 0; n <= 9; n++) {
        final ayristirdi = _coz('x !p$n').oncelik != null;
        final urunTaniyor = oncelikSayidan(n) != null;
        expect(
          ayristirdi,
          urunTaniyor,
          reason: '!p$n: ayristirici=$ayristirdi urun=$urunTaniyor',
        );
      }
    });

    test('!p4 BASLIKTA KALIR (bilinmeyen seviye URETILMEZ)', () {
      // 🔴 MUTANT KAPISI: aralik kontrolu silinirse `!p4` DB'ye 4 yazar --
      // ekranda cizilmeyen, kullanicinin goremedigi bir deger.
      final s = _coz('rapor !p4');
      expect(s.oncelik, isNull);
      expect(s.baslik, 'rapor !p4');
    });

    test('bicimsel varyantlar tanINMAZ', () {
      for (final ham in const ['!P1', 'p1', '!p', '!p01x', '!!p1']) {
        expect(_coz('x $ham').oncelik, isNull, reason: ham);
        expect(_coz('x $ham').baslik, 'x $ham', reason: ham);
      }
    });

    test('!p01 -> 1 (sifir dolgusu sayisal okunur)', () {
      // Bilincli: kalip `\d+` sayar, `int.tryParse` "01"i 1 okur. Kullaniciyi
      // sasirtacak bir sonuc DEGIL; yine de PINLENIR ki sessizce degismesin.
      expect(_coz('x !p01').oncelik, 1);
    });

    test('64 BITI ASAN basamak dizisi PATLAMAZ, baslikta kalir', () {
      // 🔴 CIDDI [bagimsiz denetim, o77 -- URUN KUSURU IDI]: `int.parse`
      // `FormatException` firlatiyordu. VM/Android'de ekleme dugmesi
      // SESSIZCE hicbir sey yapmiyordu; Web'de (dart2js) ayni girdi double'a
      // dusup FARKLI davraniyordu -- iki canli platform AYRISIYORDU.
      for (final ham in const [
        '!p99999999999999999999999',
        '!p9223372036854775808', // int64 tavani + 1
      ]) {
        final s = _coz('rapor $ham');
        expect(s.oncelik, isNull, reason: ham);
        expect(s.baslik, 'rapor $ham', reason: ham);
      }
      // Tavanin KENDISI hala sayisal okunur (kelepce basamakta degil, DEGERDE).
      expect(_coz('x !p9223372036854775807').oncelik, isNull);
    });
  });

  group('tekrar -- ILK KAZANIR (KILIT 4)', () {
    test('iki oncelik: ilki alinir, ikincisi baslikta kalir', () {
      // 🔴 MUTANT KAPISI: `if (oncelik == null)` bekcisi silinirse SON
      // kazanir ve `!p1` baslikta kalirdi -- kilit tam tersini soyluyor.
      final s = _coz('rapor !p1 gönder !p3');
      expect(s.oncelik, 1);
      expect(s.baslik, 'rapor gönder !p3');
    });

    test('iki tarih: ilki alinir, ikincisi baslikta kalir', () {
      final s = _coz('yarın rapor bugün');
      expect(s.sonTarih, kYarinGun);
      expect(s.baslik, 'rapor bugün');
    });

    test('etiket COKLUDUR -- ilk-kazanir ETIKETE UYGULANMAZ (KILIT 6)', () {
      final s = _coz('rapor #iş #acil');
      expect(s.etiketler, ['iş', 'acil']);
      expect(s.baslik, 'rapor');
    });
  });

  group('etiket (KILIT 6/7/8)', () {
    test('ayni etiket iki kez -> TEKILLESIR, ilk gorulme sirasi korunur', () {
      // 🔴 MUTANT KAPISI: `Set` yerine `List` kullanilsaydi ayni etiket icin
      // IKI `WireSetAdd` uretilirdi (iki ayri tag, ayni eleman).
      final s = _coz('rapor #b #a #b');
      expect(s.etiketler, ['b', 'a']);
      expect(s.baslik, 'rapor');
    });

    test('C# BOZULMAZ: # yalniz token BASINDA etikettir (KILIT 7)', () {
      // 🔴 MUTANT KAPISI: `startsWith('#')` -> `contains('#')` mutanti
      // "C# öğren"i "öğren" + #(bos) yapar.
      final s = _coz('C# öğren');
      expect(s.etiketler, isEmpty);
      expect(s.baslik, 'C# öğren');
    });

    test('tek basina # BASLIKTA KALIR (bos etiket reddedilir)', () {
      final s = _coz('rapor #');
      expect(s.etiketler, isEmpty);
      expect(s.baslik, 'rapor #');
    });

    test('32 karakteri ASAN etiket BASLIKTA KALIR', () {
      // 🔴 MUTANT KAPISI: `etiketDogrula` atlanip ham `substring(1)`
      // kullanilsaydi kelepce delinir, kural IKI YERDE yasardi.
      final uzun = 'a' * (kEtiketAzamiUzunluk + 1);
      final s = _coz('rapor #$uzun');
      expect(s.etiketler, isEmpty);
      expect(s.baslik, 'rapor #$uzun');

      final tamSinir = 'b' * kEtiketAzamiUzunluk;
      expect(_coz('rapor #$tamSinir').etiketler, [tamSinir]);
    });

    test('BUYUK/KUCUK HARF KATLANMAZ (o76 sinirı korunur)', () {
      final s = _coz('rapor #İş #iş');
      expect(s.etiketler, ['İş', 'iş']);
    });
  });

  group('buyuk harf ve ASCII (KILIT 5)', () {
    test('Yarın / YARIN / Bugün tanINMAZ', () {
      for (final ham in const ['Yarın', 'YARIN', 'Bugün', 'BUGÜN']) {
        final s = _coz('x $ham');
        expect(s.sonTarih, isNull, reason: ham);
        expect(s.baslik, 'x $ham', reason: ham);
      }
    });

    test('ASCII karsiliklar (bugun/yarin) tanINMAZ', () {
      expect(_coz('x bugun').sonTarih, isNull);
      expect(_coz('x yarin').sonTarih, isNull);
      expect(_coz('x bugun yarin').baslik, 'x bugun yarin');
    });
  });

  group('baslik insasi (KILIT 8)', () {
    test('bosluklar TEKE iner, bas/son kirpilir', () {
      // 🔴 MUTANT KAPISI: `join(' ')` -> `join('')` mutanti kelimeleri
      // birlestirirdi.
      expect(_coz('   rapor    gönder  ').baslik, 'rapor gönder');
    });

    test('her sey tanINIRSA baslik BOS doner (reddi cagiran yapar)', () {
      final s = _coz('yarın #iş !p1');
      expect(s.baslik, '');
      expect(s.sonTarih, kYarinGun);
      expect(s.etiketler, ['iş']);
      expect(s.oncelik, 1);
    });

    test('bos / yalniz bosluk girdi', () {
      expect(_coz('').baslik, '');
      expect(_coz('     ').baslik, '');
      expect(_coz('').etiketler, isEmpty);
    });

    test('token SIRASI korunur', () {
      expect(_coz('bir !p1 iki yarın üç').baslik, 'bir iki üç');
    });

    test('AYRAC yalniz bosluk DEGILDIR: sekme / satir sonu / NBSP', () {
      // 🔴 MUTANT KAPISI [bagimsiz denetim, o77]: ayrac `\s+` -> `' +'`
      // mutanti butun takim yesilken geciyordu. Yapistirilan metin (not
      // uygulamalari NBSP tasir, terminal cikitisi sekme) o mutant altinda
      // tarihini ve etiketini KAYBEDERDI.
      final s = _coz('rapor\tyarın #iş\n!p1');
      expect(s.baslik, 'rapor');
      expect(s.sonTarih, kYarinGun);
      expect(s.etiketler, ['iş']);
      expect(s.oncelik, 1);
    });
  });

  group('PROPERTY kapisi (500 rastgele dizi, tohum SABIT)', () {
    // Alfabe: SOLDAKI kume tanINIR, SAGDAKI kume TANINMAZ. Ayristirici bu
    // ayrimi bozarsa asagidaki degismezlerden en az biri kirilir.
    const taninanTarih = ['bugün', 'yarın', '21.08', '21.08.2026', '2026-08-21'];
    const taninanOncelik = ['!p1', '!p2', '!p3'];
    const taninanEtiket = ['#iş', '#acil', '#a'];
    const taninmayan = [
      'rapor',
      'gönder',
      '17:00',
      '!p4',
      '!P1',
      'Yarın',
      'bugun',
      '#',
      'C#',
      '30.02.2026',
      '32.13',
      'pazartesi',
    ];
    final alfabe = [
      ...taninanTarih,
      ...taninanOncelik,
      ...taninanEtiket,
      ...taninmayan,
    ];
    final taninanKume = {
      ...taninanTarih,
      ...taninanOncelik,
      ...taninanEtiket,
    };

    test('degismezler', () {
      final rastgele = Random(20260815); // TOHUM SABIT -> kosum tekrarlanabilir
      for (var i = 0; i < 500; i++) {
        final uzunluk = rastgele.nextInt(9);
        final tokenlar = List.generate(
          uzunluk,
          (_) => alfabe[rastgele.nextInt(alfabe.length)],
        );
        final ham = tokenlar.join(' ');
        final s = _coz(ham);
        final baslikTokenlari = s.baslik.isEmpty
            ? <String>[]
            : s.baslik.split(' ');

        // P1 SAFLIK: ayni girdi -> ayni cikti.
        final ikinci = _coz(ham);
        expect(ikinci.baslik, s.baslik, reason: 'P1 baslik: "$ham"');
        expect(ikinci.sonTarih, s.sonTarih, reason: 'P1 tarih: "$ham"');
        expect(ikinci.oncelik, s.oncelik, reason: 'P1 oncelik: "$ham"');
        expect(ikinci.etiketler, s.etiketler, reason: 'P1 etiket: "$ham"');

        // P2 KAYIP YOK: baslik, girdinin ALT DIZISIDIR (sira korunur) ve
        // dusen her token TANINAN kumedendir.
        var j = 0;
        final dusenler = <String>[];
        for (final token in tokenlar) {
          if (j < baslikTokenlari.length && baslikTokenlari[j] == token) {
            j++;
          } else {
            dusenler.add(token);
          }
        }
        expect(
          j,
          baslikTokenlari.length,
          reason: 'P2 baslik alt dizi DEGIL: "$ham" -> "${s.baslik}"',
        );
        for (final dusen in dusenler) {
          expect(
            taninanKume.contains(dusen),
            isTrue,
            reason: 'P2 TANINMAYAN token dustu: "$dusen" ("$ham")',
          );
        }

        // P3 TAKVIM GUNU PINI.
        if (s.sonTarih != null) {
          final t = s.sonTarih!;
          expect(t.isUtc, isTrue, reason: 'P3 UTC degil: "$ham"');
          expect(
            t.hour + t.minute + t.second + t.millisecond + t.microsecond,
            0,
            reason: 'P3 gece yarisi degil: "$ham"',
          );
        }

        // P4 ONCELIK ARALIGI.
        if (s.oncelik != null) {
          expect(oncelikSayidan(s.oncelik), isNotNull, reason: 'P4: "$ham"');
        }

        // P5 ETIKETLER GECERLI ve TEKIL.
        for (final etiket in s.etiketler) {
          expect(etiketDogrula(etiket), etiket, reason: 'P5 gecersiz: "$ham"');
        }
        expect(
          s.etiketler.toSet().length,
          s.etiketler.length,
          reason: 'P5 tekrar var: "$ham"',
        );

        // P6 BASLIK BICIMI: kirpilmis, cift bosluk yok.
        expect(s.baslik, s.baslik.trim(), reason: 'P6 kirpilmamis: "$ham"');
        expect(s.baslik.contains('  '), isFalse, reason: 'P6 cift bosluk');

        // P7 ILK KAZANIR: ilk TANINAN tarih/oncelik token'i sonucu belirler.
        final ilkTarih = _ilk(tokenlar, taninanTarih);
        expect(
          s.sonTarih,
          ilkTarih == null ? isNull : _coz(ilkTarih).sonTarih,
          reason: 'P7 tarih: "$ham"',
        );
        final ilkOncelik = _ilk(tokenlar, taninanOncelik);
        expect(
          s.oncelik,
          ilkOncelik == null ? isNull : int.parse(ilkOncelik.substring(2)),
          reason: 'P7 oncelik: "$ham"',
        );
      }
    });
  });
}

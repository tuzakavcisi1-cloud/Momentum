@TestOn('vm')
library;

import 'package:client/ag/auth_agi.dart';
import 'package:client/design/metinler.dart';
import 'package:client/sunum/giris_ekrani.dart';
import 'package:client/veri/kimlik_deposu.dart';
import 'package:client/veri/oturum_yoneticisi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _SahteAuthAgi implements AuthAgi {
  (String, String)? sonGirisCagrisi;
  (String, String)? sonKayitCagrisi;
  AuthSonucu sonuc = const AuthHttpHatasi(401);

  @override
  Future<AuthSonucu> girisYap(String eposta, String sifre) async {
    sonGirisCagrisi = (eposta, sifre);
    return sonuc;
  }

  @override
  Future<AuthSonucu> kayitOl(String eposta, String sifre) async {
    sonKayitCagrisi = (eposta, sifre);
    return sonuc;
  }

  @override
  Future<AuthSonucu> yenile(String yenilemeJetonu) async => sonuc;

  @override
  Future<void> cikisYap(String yenilemeJetonu) async {}
}

class _SahteKimlikDeposu implements KimlikDeposu {
  @override
  Future<KimlikDurumu?> oku() async => null;

  @override
  Future<void> yaz(KimlikDurumu durum) async {}

  @override
  Future<void> temizle() async {}
}

Widget _sarmala(Widget cocuk) => MaterialApp(home: cocuk);

void main() {
  group('IS-EMRI-o83 -- GirisEkrani', () {
    testWidgets('bos formla gonder -> validasyon hatasi gosterilir, girisYap CAGRILMAZ', (
      tester,
    ) async {
      final agi = _SahteAuthAgi();
      final yonetici = OturumYoneticisi(agi: agi, depo: _SahteKimlikDeposu());
      await tester.pumpWidget(
        _sarmala(GirisEkrani(oturumYoneticisi: yonetici)),
      );

      await tester.tap(find.text(Metinler.girisYapDugmesi));
      await tester.pump();

      expect(agi.sonGirisCagrisi, isNull);
    });

    testWidgets('gecerli eposta+sifre ile gonder -> girisYap DOGRU degerlerle CAGRILIR', (
      tester,
    ) async {
      final agi = _SahteAuthAgi()
        ..sonuc = const AuthBasarili(
          erisimJetonu: 'e',
          yenilemeJetonu: 'y',
          kullaniciId: 'k',
        );
      final yonetici = OturumYoneticisi(agi: agi, depo: _SahteKimlikDeposu());
      await tester.pumpWidget(
        _sarmala(GirisEkrani(oturumYoneticisi: yonetici)),
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        'kisi@ornek.test',
      );
      await tester.enterText(find.byType(TextFormField).last, 'sifre1234');
      await tester.tap(find.text(Metinler.girisYapDugmesi));
      await tester.pumpAndSettle();

      expect(agi.sonGirisCagrisi, ('kisi@ornek.test', 'sifre1234'));
    });

    testWidgets('basarisiz giris -> hata metni EKRANDA gorunur', (tester) async {
      final agi = _SahteAuthAgi()..sonuc = const AuthHttpHatasi(401);
      final yonetici = OturumYoneticisi(agi: agi, depo: _SahteKimlikDeposu());
      await tester.pumpWidget(
        _sarmala(GirisEkrani(oturumYoneticisi: yonetici)),
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        'kisi@ornek.test',
      );
      await tester.enterText(find.byType(TextFormField).last, 'yanlissifre');
      await tester.tap(find.text(Metinler.girisYapDugmesi));
      await tester.pumpAndSettle();

      expect(find.text(Metinler.girisHatasiGecersizBilgi), findsOneWidget);
    });

    testWidgets('"Hesabın yok mu?" -> kayit moduna gecer, gonder KAYITOL cagirir', (
      tester,
    ) async {
      final agi = _SahteAuthAgi()
        ..sonuc = const AuthBasarili(
          erisimJetonu: 'e',
          yenilemeJetonu: 'y',
          kullaniciId: 'k',
        );
      final yonetici = OturumYoneticisi(agi: agi, depo: _SahteKimlikDeposu());
      await tester.pumpWidget(
        _sarmala(GirisEkrani(oturumYoneticisi: yonetici)),
      );

      await tester.tap(find.text(Metinler.hesabinYokMu));
      await tester.pump();
      expect(find.text(Metinler.kayitOlDugmesi), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).first,
        'yeni@ornek.test',
      );
      await tester.enterText(find.byType(TextFormField).last, 'sifre1234');
      await tester.tap(find.text(Metinler.kayitOlDugmesi));
      await tester.pumpAndSettle();

      expect(agi.sonKayitCagrisi, ('yeni@ornek.test', 'sifre1234'));
      expect(agi.sonGirisCagrisi, isNull);
    });

    testWidgets('a11y: labeledTapTargetGuideline VE androidTapTargetGuideline gecer', (
      tester,
    ) async {
      final tutamac = tester.ensureSemantics();
      final yonetici = OturumYoneticisi(
        agi: _SahteAuthAgi(),
        depo: _SahteKimlikDeposu(),
      );
      await tester.pumpWidget(
        _sarmala(GirisEkrani(oturumYoneticisi: yonetici)),
      );

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      tutamac.dispose();
    });
  });
}

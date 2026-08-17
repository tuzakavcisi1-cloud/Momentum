import 'package:client/ag/auth_agi.dart';
import 'package:client/design/metinler.dart';
import 'package:client/veri/kimlik_deposu.dart';
import 'package:client/veri/oturum_yoneticisi.dart';
import 'package:flutter_test/flutter_test.dart';

class _SahteAuthAgi implements AuthAgi {
  AuthSonucu Function(String, String)? girisSonucu;
  AuthSonucu Function(String)? yenileSonucu;
  int yenileCagriSayisi = 0;
  int cikisCagriSayisi = 0;

  @override
  Future<AuthSonucu> girisYap(String eposta, String sifre) async =>
      girisSonucu!(eposta, sifre);

  @override
  Future<AuthSonucu> kayitOl(String eposta, String sifre) async =>
      girisSonucu!(eposta, sifre);

  @override
  Future<AuthSonucu> yenile(String yenilemeJetonu) async {
    yenileCagriSayisi++;
    return yenileSonucu!(yenilemeJetonu);
  }

  @override
  Future<void> cikisYap(String yenilemeJetonu) async {
    cikisCagriSayisi++;
  }
}

class _SahteKimlikDeposu implements KimlikDeposu {
  KimlikDurumu? _kayitli;
  int yazSayisi = 0;
  int temizleSayisi = 0;

  @override
  Future<KimlikDurumu?> oku() async => _kayitli;

  @override
  Future<void> yaz(KimlikDurumu durum) async {
    yazSayisi++;
    _kayitli = durum;
  }

  @override
  Future<void> temizle() async {
    temizleSayisi++;
    _kayitli = null;
  }
}

void main() {
  group('IS-EMRI-o83 -- OturumYoneticisi', () {
    test('baslat(): depoda kayitli oturum varsa oturum.value onunla dolar', () async {
      final depo = _SahteKimlikDeposu()
        .._kayitli = const KimlikDurumu(
          erisimJetonu: 'e1',
          yenilemeJetonu: 'y1',
          kullaniciId: 'k1',
        );
      final yonetici = OturumYoneticisi(agi: _SahteAuthAgi(), depo: depo);

      await yonetici.baslat();

      expect(yonetici.oturum.value?.kullaniciId, 'k1');
    });

    test('girisYap basarili: oturum dolar, depoya yazilir, hata null doner', () async {
      final agi = _SahteAuthAgi()
        ..girisSonucu = (_, _) => const AuthBasarili(
          erisimJetonu: 'e2',
          yenilemeJetonu: 'y2',
          kullaniciId: 'k2',
        );
      final depo = _SahteKimlikDeposu();
      final yonetici = OturumYoneticisi(agi: agi, depo: depo);

      final hata = await yonetici.girisYap('a@b.c', 'sifre123');

      expect(hata, isNull);
      expect(yonetici.oturum.value?.kullaniciId, 'k2');
      expect(depo.yazSayisi, 1);
    });

    test('girisYap 401: Turkce hata metni doner, oturum null KALIR', () async {
      final agi = _SahteAuthAgi()..girisSonucu = (_, _) => const AuthHttpHatasi(401);
      final yonetici = OturumYoneticisi(agi: agi, depo: _SahteKimlikDeposu());

      final hata = await yonetici.girisYap('a@b.c', 'yanlis');

      expect(hata, Metinler.girisHatasiGecersizBilgi);
      expect(yonetici.oturum.value, isNull);
    });

    test('kayitOl 409: e-posta kullanimda hatasi doner', () async {
      final agi = _SahteAuthAgi()..girisSonucu = (_, _) => const AuthHttpHatasi(409);
      final yonetici = OturumYoneticisi(agi: agi, depo: _SahteKimlikDeposu());

      final hata = await yonetici.kayitOl('a@b.c', 'sifre123');

      expect(hata, Metinler.girisHatasiEpostaKullanimda);
    });

    test('girisYap ag hatasi: ag hatasi metni doner', () async {
      final agi = _SahteAuthAgi()
        ..girisSonucu = (_, _) => AuthAgHatasi(Exception('baglanti yok'));
      final yonetici = OturumYoneticisi(agi: agi, depo: _SahteKimlikDeposu());

      final hata = await yonetici.girisYap('a@b.c', 'sifre123');

      expect(hata, Metinler.girisHatasiAg);
    });

    test('yenile(): oturum yoksa hemen FALSE doner, agi HIC cagrilmaz', () async {
      final agi = _SahteAuthAgi();
      final yonetici = OturumYoneticisi(agi: agi, depo: _SahteKimlikDeposu());

      final sonuc = await yonetici.yenile();

      expect(sonuc, isFalse);
      expect(agi.yenileCagriSayisi, 0);
    });

    test('yenile() basarili: oturum YENI jetonlarla guncellenir, TRUE doner', () async {
      final depo = _SahteKimlikDeposu()
        .._kayitli = const KimlikDurumu(
          erisimJetonu: 'eski-e',
          yenilemeJetonu: 'eski-y',
          kullaniciId: 'k1',
        );
      final agi = _SahteAuthAgi()
        ..yenileSonucu = (_) => const AuthBasarili(
          erisimJetonu: 'yeni-e',
          yenilemeJetonu: 'yeni-y',
          kullaniciId: 'k1',
        );
      final yonetici = OturumYoneticisi(agi: agi, depo: depo);
      await yonetici.baslat();

      final sonuc = await yonetici.yenile();

      expect(sonuc, isTrue);
      expect(yonetici.oturum.value?.erisimJetonu, 'yeni-e');
      expect(depo.yazSayisi, 1);
    });

    test('yenile() basarisiz: oturum SIFIRLANIR (null), depo temizlenir, FALSE doner -- IS-EMRI-o83 s2.2/11', () async {
      final depo = _SahteKimlikDeposu()
        .._kayitli = const KimlikDurumu(
          erisimJetonu: 'e1',
          yenilemeJetonu: 'y1',
          kullaniciId: 'k1',
        );
      final agi = _SahteAuthAgi()..yenileSonucu = (_) => const AuthHttpHatasi(401);
      final yonetici = OturumYoneticisi(agi: agi, depo: depo);
      await yonetici.baslat();

      final sonuc = await yonetici.yenile();

      expect(sonuc, isFalse);
      expect(yonetici.oturum.value, isNull);
      expect(depo.temizleSayisi, 1);
    });

    test('cikisYap(): oturum HEMEN sifirlanir, agi.cikisYap en-iyi-caba cagrilir', () async {
      final depo = _SahteKimlikDeposu()
        .._kayitli = const KimlikDurumu(
          erisimJetonu: 'e1',
          yenilemeJetonu: 'y1',
          kullaniciId: 'k1',
        );
      final agi = _SahteAuthAgi();
      final yonetici = OturumYoneticisi(agi: agi, depo: depo);
      await yonetici.baslat();

      await yonetici.cikisYap();
      // agi.cikisYap unawaited tetiklenir -- mikrotask'in bitmesini bekle.
      await Future<void>.delayed(Duration.zero);

      expect(yonetici.oturum.value, isNull);
      expect(depo.temizleSayisi, 1);
      expect(agi.cikisCagriSayisi, 1);
    });
  });
}

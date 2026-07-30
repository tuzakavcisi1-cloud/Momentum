@TestOn('vm')
library;

// GOREV-slice-3e-G12 T4 -- gercek zamanli sinyal BIRIM kapisi (A1-A13).
// K79/5 PAZARLIKSIZ: sahte KANAL, gercek PROTOKOL -- `package:web_socket`in
// resmi test ciftini (`fakes()`) `AdapterWebSocketChannel`e (uretim kodunun
// KENDI kullandigi sarmalayici) besleriz; yalniz TASIMA degisir, cerceve
// baytlari (`0x1E` ayracli gercek SignalR JSON govdeleri) GERCEKTIR.

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:client/ag/gercek_zamanli_sinyal.dart';
import 'package:client/ag/signalr_json_sinyal.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:web_socket/testing.dart' as ws_testing;
import 'package:web_socket/web_socket.dart' as pkg_ws;
import 'package:web_socket_channel/adapter_web_socket_channel.dart';

const String _ra = ''; // kayit ayraci (0x1E, RS) -- protokolun kendisi.
const String _taban = 'http://test.local';
const String _actorId = 'actor-1';

/// Test ortami: bir `SignalrJsonSinyal` + sahte sunucu ucu + gozlemlenen
/// olaylar/loglar + `kanalAcici` cagrildi mi bayragi.
class _Ortam {
  late final SignalrJsonSinyal sinyal;
  late pkg_ws.WebSocket sunucuSoket; // HER yeniden baglanmada TAZE cift kurulur (gercek WS gibi TEK KULLANIMLIK).
  final List<SinyalOlayi> olaylar = [];
  final List<String> loglar = [];
  bool kanalAciciCagrildi = false;
  int negotiateCagriSayisi = 0;
}

/// `negotiateYaniti` saglanmazsa negotiate HER ZAMAN 200 + gecerli token
/// doner. `kanalAcici` HER cagrildiginda TAZE bir sahte WS cifti kurar --
/// gercek bir WebSocket gibi bir kez kapanan baglanti YENIDEN dinlenemez
/// (`ws_testing.fakes()` tek-abonelikli akislar dondurur).
_Ortam _kur({
  http.Response Function()? negotiateYaniti,
  Random? rastgele,
  void Function()? negotiateGozlemci,
  Future<void>? negotiateBekle,
}) {
  final o = _Ortam();

  final istemci = MockClient((request) async {
    o.negotiateCagriSayisi++;
    negotiateGozlemci?.call();
    if (negotiateBekle != null) await negotiateBekle;
    if (negotiateYaniti != null) return negotiateYaniti();
    return http.Response(jsonEncode({'connectionToken': 'tok-1'}), 200);
  });

  o.sinyal = SignalrJsonSinyal(
    sunucuTabanUrl: _taban,
    actorId: _actorId,
    istemci: istemci,
    rastgele: rastgele,
    gunlukYaz: o.loglar.add,
    kanalAcici: (url, basliklar) {
      o.kanalAciciCagrildi = true;
      final (istemciSoket, sunucuSoket) = ws_testing.fakes(protocol: 'json');
      o.sunucuSoket = sunucuSoket;
      return AdapterWebSocketChannel(istemciSoket);
    },
  );
  o.sinyal.olaylar.listen(o.olaylar.add);
  return o;
}

Future<void> _pompala([int tur = 8]) async {
  for (var i = 0; i < tur; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

/// Basarili negotiate + WS + el sikismayi tamamlar; donen ortamda tam bir
/// `SinyalBaglandi` olayi vardir.
Future<_Ortam> _baglaniciKur() async {
  final o = _kur();
  unawaited(o.sinyal.baslat());
  await _pompala();
  o.sunucuSoket.sendText('{}$_ra'); // el sikisma yaniti: bos govde ⇒ basarili.
  await _pompala();
  return o;
}

double _jitterCarpani(Random r) => 1 + (r.nextDouble() * 0.4 - 0.2);

void main() {
  tearDown(() async {
    // Her testin ARDINDAN durdurma cagirilmasi zorunlu DEGIL (fakeAsync
    // testleri kendi ortamlarini kurar) ama gercek Timer birakan testler
    // sonraki testlere sizmasin diye burada YOK -- her test kendi ici
    // GEREKTIGINDE sinyal.durdur() cagirir.
  });

  group('G12 sinyal kapisi', () {
    test('A1: type1 target Changed -- BIR SinyalDegisiklik yayinlanir', () async {
      final o = await _baglaniciKur();
      expect(o.olaylar, [isA<SinyalBaglandi>()]);

      o.sunucuSoket.sendText('{"type":1,"target":"Changed","arguments":[]}$_ra');
      await _pompala();

      expect(o.olaylar, [isA<SinyalBaglandi>(), isA<SinyalDegisiklik>()]);
      await o.sinyal.durdur();
    });

    test('A2: type1 ama target != Changed -- olay YOK, gunlukYaz cagrilir', () async {
      final o = await _baglaniciKur();
      o.loglar.clear();

      o.sunucuSoket.sendText('{"type":1,"target":"Baska","arguments":[]}$_ra');
      await _pompala();

      expect(o.olaylar, [isA<SinyalBaglandi>()]); // yeni olay YOK.
      expect(o.loglar.any((s) => s.contains('taninmayan invocation hedefi')), isTrue);
      await o.sinyal.durdur();
    });

    test('A3: type6 (sunucu ping) -- HICBIR olay yayinlanmaz', () async {
      final o = await _baglaniciKur();

      o.sunucuSoket.sendText('{"type":6}$_ra');
      await _pompala();

      expect(o.olaylar, [isA<SinyalBaglandi>()]); // tek olay hala baglanma.
      await o.sinyal.durdur();
    });

    test('A4: type7 (close) -- olay yok, kanal kapatilir, yeniden baglanma PLANLANIR', () async {
      final o = await _baglaniciKur();
      final kapanmaTamam = Completer<void>();
      o.sunucuSoket.events.listen((e) {
        if (e is pkg_ws.CloseReceived && !kapanmaTamam.isCompleted) {
          kapanmaTamam.complete();
        }
      });

      o.sunucuSoket.sendText('{"type":7,"error":"sunucu kapatti"}$_ra');
      await _pompala();

      expect(o.olaylar, [isA<SinyalBaglandi>()]); // close olay YAYINLAMAZ.
      await kapanmaTamam.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => fail('kanal beklenen surede kapanmadi (sink.close() cagrilmadi)'),
      );

      // "planlanir" -- bir sonraki negotiate cagrisi gercekten gelir (tier0 ~1sn).
      final oncekiSayi = o.negotiateCagriSayisi;
      await Future<void>.delayed(const Duration(milliseconds: 1400)); // [DESIGN-LITERAL: SignalR tier0 yeniden-baglanma test zamanlamasi (~1sn), tasarim tokeni degil]
      expect(o.negotiateCagriSayisi, greaterThan(oncekiSayi));
      await o.sinyal.durdur();
    });

    test('A5: taninmayan tip -- olay yok AMA gunlukYaz cagrilir (sessiz DEGIL)', () async {
      final o = await _baglaniciKur();
      o.loglar.clear();

      o.sunucuSoket.sendText('{"type":99}$_ra');
      await _pompala();

      expect(o.olaylar, [isA<SinyalBaglandi>()]);
      expect(o.loglar.any((s) => s.contains('taninmayan mesaj tipi')), isTrue);
      await o.sinyal.durdur();
    });

    test('A6: tek cercevede 0x1E ile ayrilmis UC mesaj -- ucu de islenir, sira korunur', () async {
      final o = await _baglaniciKur();

      o.sunucuSoket.sendText(
        '{"type":1,"target":"Changed","arguments":[]}$_ra'
        '{"type":6}$_ra'
        '{"type":1,"target":"Changed","arguments":[]}$_ra',
      );
      await _pompala();

      expect(o.olaylar, [
        isA<SinyalBaglandi>(),
        isA<SinyalDegisiklik>(),
        isA<SinyalDegisiklik>(),
      ]);
      await o.sinyal.durdur();
    });

    test('A7a: el sikisma yaniti {} -- SinyalBaglandi yayinlanir', () async {
      final o = await _baglaniciKur();
      expect(o.olaylar, [isA<SinyalBaglandi>()]);
      await o.sinyal.durdur();
    });

    test('A7b: el sikisma yaniti error -- olay YOK, baglanti koptu sayilir', () async {
      final o = _kur();
      unawaited(o.sinyal.baslat());
      await _pompala();

      final kapanmaTamam = Completer<void>();
      o.sunucuSoket.events.listen((e) {
        if (e is pkg_ws.CloseReceived && !kapanmaTamam.isCompleted) {
          kapanmaTamam.complete();
        }
      });

      o.sunucuSoket.sendText('{"error":"surum uyumsuz"}$_ra');
      await _pompala();

      expect(o.olaylar, isEmpty); // SinyalBaglandi ASLA yayinlanmadi.
      await kapanmaTamam.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => fail('el sikisma hatasi sonrasi kanal kapatilmadi'),
      );
      await o.sinyal.durdur();
    });

    test('A8: el sikisma yaniti MESAJ olarak islenmez ("taninmayan" logu DUSMEZ)', () async {
      final o = await _baglaniciKur();
      // el sikisma yaniti `{}` idi -- `type` alani YOK. Islenseydi A5 yolundan
      // "taninmayan mesaj tipi" logu duserdi. Duşmedigini dogrula:
      expect(o.loglar.any((s) => s.contains('taninmayan')), isFalse);
      await o.sinyal.durdur();
    });

    test('A9: negotiate 401 -- SinyalBaglandi yok, WS HIC acilmaz (kanalAcici cagrilmadi)', () async {
      // GOVDE BILEREK GECERLI bir connectionToken tasir (M65'in ayirt edici
      // vakasi): statusCode kontrolu SILINSEYDI govde basariyla parse edilip
      // "basarili" sayilirdi -- ayak yalniz status-kod denetimine guvendigini
      // boylece kanitlar (bos govdeyle her iki kod yolu da jsonDecode'da
      // patlar ve mutant SESSIZCE gecerdi).
      final o = _kur(
        negotiateYaniti: () => http.Response(
          jsonEncode({'connectionToken': 'gecerli-ama-401-govdesi'}),
          401,
        ),
      );
      unawaited(o.sinyal.baslat());
      await _pompala();

      expect(o.kanalAciciCagrildi, isFalse);
      expect(o.olaylar, isEmpty);
      expect(o.loglar.any((s) => s.contains('baglanti koptu')), isTrue);
      await o.sinyal.durdur();
    });

    test('A10: negotiate 200 ama connectionToken yok/bos -- ayni sonuc', () async {
      final o = _kur(
        negotiateYaniti: () => http.Response(jsonEncode({'connectionToken': ''}), 200),
      );
      unawaited(o.sinyal.baslat());
      await _pompala();

      expect(o.kanalAciciCagrildi, isFalse);
      expect(o.olaylar, isEmpty);
      expect(o.loglar.any((s) => s.contains('baglanti koptu')), isTrue);
      await o.sinyal.durdur();
    });

    test('A11: basarili baglanmadan SONRA kopus -- geri cekilme indeksi SIFIRLANMIS olmali', () {
      fakeAsync((async) {
        // A12'de kanitlanmis teknikle AYNI: seed'li Random + TAM Duration
        // aritmetigi -- tahmini pencere degil, KESIN esitlik.
        final beklenenRastgele = Random(7);
        late _Ortam o;
        o = _kur(
          negotiateYaniti: () => o.negotiateCagriSayisi == 1
              ? http.Response('', 500)
              : http.Response(jsonEncode({'connectionToken': 'tok-1'}), 200),
          rastgele: Random(7),
        );

        unawaited(o.sinyal.baslat());
        async.elapse(Duration.zero);
        expect(o.negotiateCagriSayisi, 1); // 1. deneme -- BASARISIZ (500 yaniti).

        final carpan1 = _jitterCarpani(beklenenRastgele);
        final gecikme1 = Duration(seconds: 1) * carpan1; // tier0 -- ilk geri cekilme.
        async.elapse(gecikme1);
        expect(o.negotiateCagriSayisi, 2); // 2. deneme -- negotiate BASARILI.

        async.elapse(Duration.zero); // WS acilsin, el sikisma gonderilsin.
        o.sunucuSoket.sendText('{}$_ra'); // el sikisma BASARILI.
        async.elapse(Duration.zero);
        expect(o.olaylar, [isA<SinyalBaglandi>()]); // baglandi -- indeks SIFIRLANMALI.

        o.sunucuSoket.sendText('{"type":7,"error":"kopus"}$_ra'); // TEKRAR kopar.
        async.elapse(Duration.zero);

        // Indeks GERCEKTEN sifirlandiysa bu turun TABANI YINE 1sn'dir (2sn
        // DEGIL) -- M67 (indeks sifirlama silinirse) tam burada tier1'e
        // kayar ve asagidaki esitlik KIRILIR.
        final carpan2 = _jitterCarpani(beklenenRastgele);
        final gecikme2 = Duration(seconds: 1) * carpan2; // tier0 -- SIFIRLANMA kaniti.
        async.elapse(gecikme2 - const Duration(microseconds: 1));
        expect(o.negotiateCagriSayisi, 2, reason: 'beklenen gecikmeden ONCE tetiklenmemeli');
        async.elapse(const Duration(microseconds: 1));
        expect(o.negotiateCagriSayisi, 3, reason: '3. deneme TAM sifirlanmis tier0 aninda gelmeli');

        // temizlik: bekleyen zamanlayicilar birakilmasin.
        unawaited(o.sinyal.durdur());
        async.elapse(Duration.zero);
      });
    });

    test('A12: Random(42) -- 6 gecikme TAM beklenen degere esit, 7. tavanda KALIR', () {
      fakeAsync((async) {
        final beklenenRastgele = Random(42);
        const tabanlarSaniye = [1, 2, 4, 8, 16, 30, 30]; // 7. deneme de 30s tavaninda.

        // Beklenen KUMULATIF zaman damgalari -- 1. deneme t=0 (gecikme yok),
        // sonraki her deneme onceki toplam + o turun TAM (jitter'li) gecikmesi.
        final beklenenZamanlar = <Duration>[Duration.zero];
        var toplam = Duration.zero;
        for (final tabanSaniye in tabanlarSaniye) {
          toplam += Duration(seconds: tabanSaniye) * _jitterCarpani(beklenenRastgele);
          beklenenZamanlar.add(toplam);
        }

        final gorulenZamanlar = <Duration>[];
        final o = _kur(
          negotiateYaniti: () => http.Response('', 500), // HER ZAMAN basarisiz -- yalniz zamanlama olculur.
          rastgele: Random(42),
          negotiateGozlemci: () => gorulenZamanlar.add(async.elapsed),
        );

        unawaited(o.sinyal.baslat());
        // Tum dizinin (1 ilk deneme + 7 geri cekilme) rahat sigacagi kadar ilerlet.
        async.elapse(const Duration(seconds: 95));

        expect(
          gorulenZamanlar,
          beklenenZamanlar,
          reason: '8 deneme (ilk + 7 geri cekilme) TAM beklenen kumulatif anlarda gorulmeli',
        );

        unawaited(o.sinyal.durdur());
        async.elapse(Duration.zero);
      });
    });

    test('A13: durdur() sonrasi -- yeniden baglanma denenmez, olaylar kapanir, ikinci durdur() patlamaz', () async {
      final o = await _baglaniciKur();

      await o.sinyal.durdur();

      var kapandiMi = false;
      o.sinyal.olaylar.listen(null, onDone: () => kapandiMi = true);
      await _pompala();
      expect(kapandiMi, isTrue); // `olaylar` akisi KAPANDI.

      final oncekiSayi = o.negotiateCagriSayisi;
      // sunucu bir sey gonderse bile (kanal zaten kapali) yeni deneme OLMAZ.
      await Future<void>.delayed(const Duration(milliseconds: 1500)); // [DESIGN-LITERAL: kanal kapali dogrulama bekleme suresi (test zamanlamasi), tasarim tokeni degil]
      expect(o.negotiateCagriSayisi, oncekiSayi); // yeniden baglanma DENENMEDI.

      // ikinci durdur() PATLAMAZ (idempotent).
      await o.sinyal.durdur();
    });

    test('A13b: durdur() SIRASINDA askida kalan bir baglanma denemesi -- '
        'negotiate SONRADAN basarili donse bile WS acilmaya CALISILMAZ', () async {
      // `_denetleyici.close()` (T2) posta kapanan kanala olay sizmasini zaten
      // engeller -- bu ayak ONDAN BAGIMSIZ ikinci bir korumayi (`_durduruldu`
      // bayragi) hedefler: durdur() cagrildiginda HALA askida olan bir
      // negotiate cagrisi SONRADAN basariyla donerse bile is BOSA sarf
      // EDILMEMELI (WS acma denemesi hic baslamamali).
      final devamEtsin = Completer<void>();
      final o = _kur(negotiateBekle: devamEtsin.future);

      unawaited(o.sinyal.baslat());
      await _pompala(); // negotiate cagrisi baslar, `devamEtsin` icin ASKIDA kalir.

      await o.sinyal.durdur(); // baglanma denemesi HALA askidayken durduruldu.

      devamEtsin.complete(); // negotiate SIMDI serbest kalsin, basariyla tamamlansin.
      await _pompala();

      expect(o.kanalAciciCagrildi, isFalse); // `_durduruldu` WS denemesini ENGELLEMELI.
    });
  });
}

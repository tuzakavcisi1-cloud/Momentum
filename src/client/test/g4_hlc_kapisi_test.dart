// GOREV-slice-3c G4 -- HLC KAPISI (saat enjekte edilir). Ag/DB YOK, tamamen
// yerel saf mantik testi.

import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/veritabani.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('D3: ayni ms de 1000 cagri -- wallMs sabit, counter 1000 kez artan ve tekrarsiz', () {
    var simdi = 1000;
    final hlc = HlcUretici(simdiMs: () => simdi, clientId: 'c1');
    final gorulenler = <int>{};
    var oncekiCounter = -1;
    for (var i = 0; i < 1000; i++) {
      final h = hlc.sonrakiHlc();
      expect(h.wallMs, simdi);
      expect(h.counter, greaterThan(oncekiCounter), reason: 'K65: counter HER cagrida kesin artar');
      oncekiCounter = h.counter;
      expect(gorulenler.add(h.counter), isTrue, reason: 'counter tekrar etti: ${h.counter}');
    }
    expect(gorulenler, hasLength(1000));
  });

  test('D3: saat geri gider -- wallMs dusmez, counter artar', () {
    var simdi = 100000;
    final hlc = HlcUretici(simdiMs: () => simdi, clientId: 'c1');
    final ilk = hlc.sonrakiHlc();
    expect(ilk.wallMs, 100000);

    simdi = 50000; // saat GERI gider
    final ikinci = hlc.sonrakiHlc();
    expect(ikinci.wallMs, greaterThanOrEqualTo(ilk.wallMs));
    expect(ikinci.counter, ilk.counter + 1);
  });

  test('D3: saat ileri gider -- counter SIFIRLANMAZ, HER cagrida artmaya devam eder (K65)', () {
    var simdi = 100000;
    final hlc = HlcUretici(simdiMs: () => simdi, clientId: 'c1');
    hlc.sonrakiHlc();
    final ikinci = hlc.sonrakiHlc();

    simdi = 200000; // saat ILERI gider
    final ucuncu = hlc.sonrakiHlc();
    expect(ucuncu.wallMs, 200000);
    expect(
      ucuncu.counter,
      ikinci.counter + 1,
      reason: 'K65: wall degissin degismesin counter HER damgada kesin artar, sifirlanmaz -- '
          'sunucunun receive-time kirpmasi iki alan-HLCsini ayni wall_e dusurdugunde bile '
          'counter farki tie-break_i deterministik tutar',
    );
  });

  test('D3: sonWall 10 dk ileri kurulur -- uretilen wallMs now+300000u ASMAZ', () {
    const simdi = 1000000;
    final hlc = HlcUretici(
      simdiMs: () => simdi,
      clientId: 'c1',
      sonWall: simdi + const Duration(minutes: 10).inMilliseconds,
    );
    final h = hlc.sonrakiHlc();
    expect(h.wallMs, lessThanOrEqualTo(simdi + 300000));
    expect(h.wallMs, simdi + 300000); // 10dk > 5dk tavan -> tavana kirpilir
  });

  test(
    'D3: saat 400 gun ileri alinip DUZELTILIR -- tavan HER cagrida GUNCEL now dan yeniden hesaplanir',
    () {
      // D3 kirmizi uyari senaryosu BIREBIR: saat bir kez ILERI kacar
      // (sonWall o cagri sirasinda ILERI SURUKLENIR), sonra saat DUZELTILIR
      // -- tavansiz bir max(now,sonWall) burada sonWall'da SIKISIP KALIRDI
      // (~400 gun ileri damga); dogru kod GUNCEL now+300000'e GERI ceker.
      final normalSimdi = DateTime.utc(2026, 1, 1).millisecondsSinceEpoch;
      var an = normalSimdi + const Duration(days: 400).inMilliseconds;
      final hlc = HlcUretici(simdiMs: () => an, clientId: 'c1');
      hlc.sonrakiHlc(); // saat 400 gun ileriyken UC bir damga -- sonWall surukleniyor

      an = normalSimdi; // saat DUZELTILDI
      final h = hlc.sonrakiHlc();
      expect(
        h.wallMs,
        lessThanOrEqualTo(an + 300000),
        reason: 'duzeltilmis saatten sonra damga ESKI surukten KURTULMALI',
      );
    },
  );

  test('D3: yanitta serverHlc.wallMs > sonWall -- sonWall ileri tasinir', () {
    var simdi = 1000;
    final hlc = HlcUretici(simdiMs: () => simdi, clientId: 'c1');
    final ilk = hlc.sonrakiHlc();
    expect(ilk.wallMs, 1000);

    hlc.yanitIsle(serverHlc: const Hlc(wallMs: 5000, counter: 3, clientId: 'sunucu'));
    expect(hlc.sonWall, 5000);
    expect(hlc.sonCounter, 3);

    final sonraki = hlc.sonrakiHlc(); // simdi hala 1000, ama sonWall 5000
    expect(sonraki.wallMs, greaterThan(ilk.wallMs));
  });

  test('D3: yeniden baslatma -- sonWall/sonCounter kalicidan okunur, yeni damga kesin buyuk', () async {
    final db = Veritabani(NativeDatabase.memory());
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();

    var simdi = 1000;
    var hlc = HlcUretici(simdiMs: () => simdi, clientId: ayarlar.clientId);
    final ilkTur = <int>[];
    for (var i = 0; i < 5; i++) {
      ilkTur.add(hlc.sonrakiHlc().wallMs);
    }
    await ayarlarDeposu.hlcKalicilastir(hlc.sonWall, hlc.sonCounter);

    // "Yeniden baslatma" -- YENI bir HlcUretici, kalicidan okunan degerlerle.
    final ayarlar2 = await ayarlarDeposu.yukleVeyaOlustur();
    simdi = 500; // saat GERI alinmis olsun bile
    final hlc2 = HlcUretici(
      simdiMs: () => simdi,
      clientId: ayarlar2.clientId,
      sonWall: ayarlar2.sonWall,
      sonCounter: ayarlar2.sonCounter,
    );
    final yeniDamga = hlc2.sonrakiHlc();
    expect(yeniDamga.wallMs, greaterThanOrEqualTo(hlc.sonWall));
    expect(
      yeniDamga.wallMs > ilkTur.last || yeniDamga.counter > 0,
      isTrue,
      reason: 'yeniden baslatma sonrasi damga oncekinden KESIN buyuk olmali',
    );
    await db.close();
  });

  test('D3: clientId iki acilista AYNI -- ayarlarda TEK satir', () async {
    final db = Veritabani(NativeDatabase.memory());
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ilkAcilis = await ayarlarDeposu.yukleVeyaOlustur();
    final ikinciAcilis = await ayarlarDeposu.yukleVeyaOlustur();

    expect(ikinciAcilis.clientId, ilkAcilis.clientId);

    final tumSatirlar = await db.select(db.ayarlar).get();
    expect(tumSatirlar, hasLength(1));
    await db.close();
  });
}

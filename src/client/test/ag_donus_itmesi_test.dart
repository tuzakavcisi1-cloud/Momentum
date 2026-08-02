@TestOn('vm')
library;

// GOREV-A11 (K116) G22 -- AG-DONUS ITMESI (`D0` daraltmasi + `D-A11-1..6`).
//
// 🔴 KABUL KRITERI 0 (yuruyen iskelet, GOREV §7/0): bu dosyanin ILK testi
// (`a`) BILEREK YALNIZ BASINA yazildi. Bu depoda `fakeAsync` ile GERCEK
// (dosya tabanli) Drift'in BIRLIKTE kostugu HIC OLCULMEMISTI --
// `g1_cekme_yolu_kapisi_test.dart`'in "sanal saat" dedigi ayagi aslinda
// GERCEK 200 ms `Future.delayed` kullaniyordu (fakeAsync DEGIL) ve
// `signalr_json_sinyal.dart:123-133` bu depoda olculmus BASKA bir fakeAsync
// anomalisi kaydediyor. `a` ayagi gectiginde geri kalan ayaklar (b-l)
// yazilir; GECMEZSE (hang/timeout/yanlis olcum) DURULUR ve Onur'a sorulur.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:client/ag/senkron_agi.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/itme_yeniden_deneme.dart';
import 'package:client/veri/senkron_dongusu.dart';
import 'package:client/veri/veritabani.dart' hide Ayarlar;
import 'package:drift/native.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'destekler/sahte_senkron_agi.dart';

/// [g12_sinyal_kapisi_test.dart] ile AYNI kabul edilmis desen: seed'li
/// `Random` + TAM `Duration` aritmetigi -- tahmini pencere degil, KESIN
/// esitlik (D-A11-2/1).
double _jitterCarpani(Random r) => 1 + (r.nextDouble() * 0.4 - 0.2);

class _Kurulum {
  final Veritabani db;
  final AyarlarDeposu ayarlarDeposu;
  final Ayarlar ayarlar;
  final HlcUretici hlc;
  final DriftGorevDeposu depo;
  _Kurulum(this.db, this.ayarlarDeposu, this.ayarlar, this.hlc, this.depo);
}

SenkronSonucu _basariliYanit(Map<String, Object?> govde) {
  final ops = (govde['ops'] as List).cast<Map<String, Object?>>();
  return SenkronBasarili(
    jsonEncode({
      'serverHlc': null,
      'nextCursor': null,
      'hasMore': false,
      'resyncRequired': false,
      'applied': [
        for (final op in ops)
          {'operationId': op['operationId'], 'code': 'Applied', 'effectiveOpHlc': op['opHlc']},
      ],
      'changes': [],
      'snapshot': [],
    }),
  );
}

void main() {
  late Directory gecici;

  setUp(() {
    gecici = Directory.systemTemp.createTempSync('g22-ag-donus-itmesi');
  });

  tearDown(() {
    try {
      gecici.deleteSync(recursive: true);
    } catch (_) {}
  });

  Veritabani dosyaDbAc() => Veritabani(NativeDatabase(File('${gecici.path}/m.sqlite')));

  Future<_Kurulum> kurulumYap() async {
    final db = dosyaDbAc();
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final hlc = HlcUretici(
      simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch,
      clientId: ayarlar.clientId,
    );
    final depo = DriftGorevDeposu(
      db,
      saat: () => DateTime.now().toUtc(),
      idUret: uretimIdUret,
      hlc: hlc,
      ayarlarDeposu: ayarlarDeposu,
      actorId: ayarlar.devUserId,
    );
    return _Kurulum(db, ayarlarDeposu, ayarlar, hlc, depo);
  }

  SenkronDongusu donguOlustur(_Kurulum k, SahteSenkronAgi agi, {Random? rastgele}) => SenkronDongusu(
    db: k.db,
    agi: agi,
    ayarlarDeposu: k.ayarlarDeposu,
    hlc: k.hlc,
    clientId: k.ayarlar.clientId,
    devUserId: k.ayarlar.devUserId,
    itmeYenidenDenemeRastgele: rastgele,
  );

  test(
    'KABUL KRITERI 0 + G22/a: kuyrukta 1 op, tasima hatasi -- TAM 2s de ikinci istek (seed sabit)',
    () async {
      // Kurulum (gercek dosya-tabanli Drift, DB'ye GERCEK async I/O) fakeAsync
      // DISINDA yapilir -- yalniz zamanlamayi olcen kisim fakeAsync icindedir.
      final k = await kurulumYap();
      await k.depo.ekle('ag donus itmesi a testi');

      fakeAsync((async) {
        final beklenenRastgele = Random(7);
        var cagriSayisi = 0;
        final gorulenZamanlar = <Duration>[];

        final agi = SahteSenkronAgi(
          davranis: (govde, cagriNo) async {
            cagriSayisi++;
            gorulenZamanlar.add(async.elapsed);
            if (cagriSayisi == 1) {
              return SenkronAgHatasi(Exception('tasima hatasi'));
            }
            return _basariliYanit(govde);
          },
        );

        final dongu = donguOlustur(k, agi, rastgele: Random(7));

        unawaited(dongu.turCalistir());
        async.elapse(Duration.zero);
        expect(cagriSayisi, 1, reason: 'ilk istek hemen gitmeli (kuyrukta 1 op var)');

        final beklenenGecikme = const Duration(seconds: 2) * _jitterCarpani(beklenenRastgele);
        async.elapse(beklenenGecikme - const Duration(microseconds: 1));
        expect(cagriSayisi, 1, reason: 'beklenen gecikmeden ONCE ikinci istek gitmemeli');

        async.elapse(const Duration(microseconds: 1));
        expect(cagriSayisi, 2, reason: 'TAM beklenen gecikmede ikinci istek gitmeli');
        expect(
          gorulenZamanlar[1],
          beklenenGecikme,
          reason: 'seed sabit ⇒ KESIN esitlik (pencere degil)',
        );
      });

      await k.db.close();
    },
  );

  test(
    'G22/b: ardisik hatalar -- istek anlari 2,5,15,30,60, 6.dan sonra 60 sabit',
    () async {
      final k = await kurulumYap();
      await k.depo.ekle('ardisik hata testi');

      fakeAsync((async) {
        final beklenenRastgele = Random(42);
        const tabanlarSaniye = [2, 5, 15, 30, 60, 60]; // 6.dan sonra 60'da sabit.
        final beklenenZamanlar = <Duration>[Duration.zero];
        var toplam = Duration.zero;
        for (final s in tabanlarSaniye) {
          toplam += Duration(seconds: s) * _jitterCarpani(beklenenRastgele);
          beklenenZamanlar.add(toplam);
        }

        final gorulenZamanlar = <Duration>[];
        final agi = SahteSenkronAgi(
          davranis: (govde, cagriNo) async {
            gorulenZamanlar.add(async.elapsed);
            return SenkronAgHatasi(Exception('tasima hatasi'));
          },
        );
        final dongu = donguOlustur(k, agi, rastgele: Random(42));

        unawaited(dongu.turCalistir());
        // Tam beklenen 7 cagriyi kapsayacak KADAR ilerlet -- sonraki (8.) tier
        // en az 48s (60s * %80 jitter tabani) sonra gelir, o yuzden kucuk bir
        // pay (10s) yeterlidir ve fazladan bir cagriyi ICERI SIZDIRMAZ.
        async.elapse(beklenenZamanlar.last + const Duration(seconds: 10));

        expect(gorulenZamanlar.length, beklenenZamanlar.length);
        for (var i = 0; i < beklenenZamanlar.length; i++) {
          expect(gorulenZamanlar[i], beklenenZamanlar[i], reason: 'cagri $i zamanlamasi');
        }
      });

      await k.db.close();
    },
  );

  test(
    'G22/c: ag duzelir -- op gider, kuyruk bosalir, +300s pendingTimers BOS, ek istek yok',
    () async {
      final k = await kurulumYap();
      await k.depo.ekle('ag duzelme testi');

      fakeAsync((async) {
        var cagriSayisi = 0;
        final agi = SahteSenkronAgi(
          davranis: (govde, cagriNo) async {
            cagriSayisi++;
            if (cagriSayisi == 1) return SenkronAgHatasi(Exception('tasima hatasi'));
            return _basariliYanit(govde);
          },
        );
        final dongu = donguOlustur(k, agi, rastgele: Random(3));

        unawaited(dongu.turCalistir());
        async.elapse(Duration.zero);
        expect(cagriSayisi, 1);
        expect(async.pendingTimers, isNotEmpty, reason: 'retry planlanmis olmali');

        async.elapse(const Duration(seconds: 3)); // tier0 (2s) + jitter tavani (2.4s) rahat sigar.
        expect(cagriSayisi, 2, reason: 'retry basarili olmali');

        async.elapse(const Duration(seconds: 300));
        expect(cagriSayisi, 2, reason: 'kuyruk bos -- ek istek YOK');
        expect(async.pendingTimers, isEmpty, reason: 'bekleyen zamanlayici KALMAMALI');
      });

      await k.db.close();
    },
  );

  test(
    'G22/c2: bekleyen retry timer + DISARIDAN basarili tur -- sifirla() IPTAL ETMELI',
    () async {
      final k = await kurulumYap();
      await k.depo.ekle('c2 iptal ayagi');

      fakeAsync((async) {
        var cagriSayisi = 0;
        final agi = SahteSenkronAgi(
          davranis: (govde, cagriNo) async {
            cagriSayisi++;
            if (cagriSayisi == 1) return SenkronAgHatasi(Exception('tasima hatasi'));
            return _basariliYanit(govde);
          },
        );
        final dongu = donguOlustur(k, agi, rastgele: Random(3));

        unawaited(dongu.turCalistir());
        async.elapse(Duration.zero);
        expect(cagriSayisi, 1);
        expect(async.pendingTimers, isNotEmpty, reason: 'retry planlanmis olmali');

        // Timer HENUZ ATESLEMEDI -- disaridan taze cagri geliyor.
        unawaited(dongu.turCalistir());
        async.elapse(Duration.zero);
        expect(cagriSayisi, 2, reason: 'disaridan gelen tur kosmus olmali');
        expect(
          async.pendingTimers,
          isEmpty,
          reason: 'sifirla() bekleyen retry timer ini IPTAL ETMELIYDI',
        );
      });

      await k.db.close();
    },
  );

  test(
    'G22/d: basari sonrasi yeni op + hata -- ilk yeniden deneme YINE 2s (cizelge sifirlandi)',
    () async {
      final k = await kurulumYap();
      await k.depo.ekle('ilk op');

      fakeAsync((async) {
        final beklenenRastgele = Random(11);
        var cagriSayisi = 0;

        final agi = SahteSenkronAgi(
          davranis: (govde, cagriNo) async {
            cagriSayisi++;
            if (cagriSayisi <= 2) return SenkronAgHatasi(Exception('tasima hatasi'));
            if (cagriSayisi == 3) return _basariliYanit(govde); // ilk op basarili -- SIFIRLANIR.
            return SenkronAgHatasi(Exception('tasima hatasi')); // yeni op da basarisiz.
          },
        );
        final dongu = donguOlustur(k, agi, rastgele: Random(11));

        unawaited(dongu.turCalistir()); // cagri 1 -- basarisiz (tier0).
        async.elapse(Duration.zero);
        expect(cagriSayisi, 1);

        final gecikme1 = const Duration(seconds: 2) * _jitterCarpani(beklenenRastgele);
        async.elapse(gecikme1); // cagri 2 -- basarisiz (tier1).
        expect(cagriSayisi, 2);

        final gecikme2 = const Duration(seconds: 5) * _jitterCarpani(beklenenRastgele);
        async.elapse(gecikme2); // cagri 3 -- BASARILI -- cizelge SIFIRLANIR.
        expect(cagriSayisi, 3);
        expect(async.pendingTimers, isEmpty, reason: 'basari sonrasi bekleyen zamanlayici yok');

        var ikinciOpEklendi = false;
        unawaited(
          k.depo.ekle('ikinci op').then((_) {
            ikinciOpEklendi = true;
            unawaited(dongu.turCalistir()); // cagri 4 -- DISARIDAN, basarisiz.
          }),
        );
        async.elapse(Duration.zero);
        expect(ikinciOpEklendi, isTrue);
        expect(cagriSayisi, 4);

        final beklenenIlkYenidenDeneme = const Duration(seconds: 2) * _jitterCarpani(beklenenRastgele);
        async.elapse(beklenenIlkYenidenDeneme - const Duration(microseconds: 1));
        expect(cagriSayisi, 4, reason: 'beklenen gecikmeden once gitmemeli');
        async.elapse(const Duration(microseconds: 1));
        expect(cagriSayisi, 5, reason: 'cizelge sifirlandigi icin YINE 2s de gelmeli');
      });

      await k.db.close();
    },
  );

  test(
    'G22/e: bekleyen zamanlayici varken IKINCI hata -- nonPeriodicTimerCount == 1',
    () async {
      final k = await kurulumYap();
      await k.depo.ekle('tekillik testi');

      fakeAsync((async) {
        final agi = SahteSenkronAgi(
          davranis: (govde, cagriNo) async => SenkronAgHatasi(Exception('tasima hatasi')),
        );
        final dongu = donguOlustur(k, agi, rastgele: Random(5));

        unawaited(dongu.turCalistir()); // cagri 1 -- basarisiz, 1 zamanlayici planlanir.
        async.elapse(Duration.zero);
        expect(async.nonPeriodicTimerCount, 1);

        // "ikinci hata": bekleyen zamanlayici DAHA ateslenmeden DISARIDAN
        // yeniden tetiklenir (ör. baska bir yerel yazma) ve YINE basarisiz olur.
        unawaited(dongu.turCalistir()); // cagri 2 -- basarisiz.
        async.elapse(Duration.zero);

        expect(async.nonPeriodicTimerCount, 1, reason: 'ayni anda EN FAZLA bir bekleyen zamanlayici');

        // [ERISILEBILIRLIK, M143] Yukaridaki iki cagri DA disaridandir --
        // SenkronDongusu.turCalistir()'in giris noktasi (sifirla()) her disaridan
        // cagrida zaten iptal eder, bu yuzden planla()'nin KENDI ic cancel()'i o
        // senaryoda gozlemlenemez (M141/M142 ile AYNI erisilebilirlik sinifi).
        // planla() BIR SINIF SORUMLULUGUDUR (D-A11-2/2) -- SenkronDongusu'nun
        // ONA nasil eristigine bagli olmamali. Bu yuzden ItmeYenidenDeneme
        // DOGRUDAN (SenkronDongusu'suz) da sinanir: ayni zamanlayici alaninin
        // TEKLIGI sinif SEVIYESINDE olcbulur ve M143'u orada YAKALAR.
        final bagimsizItme = ItmeYenidenDeneme(turCalistir: () async {}, rastgele: Random(1));
        bagimsizItme.planla();
        bagimsizItme.planla();
        expect(
          async.nonPeriodicTimerCount,
          2,
          reason: 'yukaridaki 1 (SenkronDongusu) + bagimsiz sinifin KENDI tekligi -- '
              'ikinci planla() birinciyi iptal etmeliydi',
        );
      });

      await k.db.close();
    },
  );

  test('G22/f: ag 400 -- +300s pendingTimers BOS (planlanmadi)', () async {
    final k = await kurulumYap();
    await k.depo.ekle('400 testi');

    fakeAsync((async) {
      var cagriSayisi = 0;
      final agi = SahteSenkronAgi(
        davranis: (govde, cagriNo) async {
          cagriSayisi++;
          return const SenkronHttpHatasi(400);
        },
      );
      final dongu = donguOlustur(k, agi, rastgele: Random(9));

      unawaited(dongu.turCalistir());
      async.elapse(const Duration(seconds: 300));

      expect(cagriSayisi, 1, reason: '400 icin yeniden deneme HIC planlanmaz');
      expect(async.pendingTimers, isEmpty);
    });

    await k.db.close();
  });

  test('G22/g: ag 503 -- yeniden deneme planlanir (pendingTimers dolu)', () async {
    final k = await kurulumYap();
    await k.depo.ekle('503 testi');

    fakeAsync((async) {
      var cagriSayisi = 0;
      final agi = SahteSenkronAgi(
        davranis: (govde, cagriNo) async {
          cagriSayisi++;
          return const SenkronHttpHatasi(503);
        },
      );
      final dongu = donguOlustur(k, agi, rastgele: Random(13));

      unawaited(dongu.turCalistir());
      async.elapse(Duration.zero);

      expect(cagriSayisi, 1);
      expect(async.pendingTimers, isNotEmpty, reason: '5xx icin yeniden deneme PLANLANIR');
    });

    await k.db.close();
  });

  test(
    'G22/h: yeniden deneme boyunca gonderilen HER govdede ops BOS DEGIL (cekme yok)',
    () async {
      final k = await kurulumYap();
      await k.depo.ekle('bos olmayan govde testi');

      fakeAsync((async) {
        final agi = SahteSenkronAgi(
          davranis: (govde, cagriNo) async {
            if (cagriNo < 3) return SenkronAgHatasi(Exception('tasima hatasi'));
            return _basariliYanit(govde);
          },
        );
        final dongu = donguOlustur(k, agi, rastgele: Random(17));

        unawaited(dongu.turCalistir());
        async.elapse(const Duration(seconds: 30)); // ilk iki tier (2s, 5s) rahat sigar.

        expect(agi.alinanIstekler.length, greaterThanOrEqualTo(3));
        for (final istek in agi.alinanIstekler) {
          expect(istek['ops'] as List, isNotEmpty, reason: 'yeniden deneme cekme YAPMAZ, itme yapar');
        }
      });

      await k.db.close();
    },
  );

  test(
    'G22/i: durdur() sonrasi +300s -- pendingTimers BOS (yetim zamanlayici yok)',
    () async {
      final k = await kurulumYap();
      await k.depo.ekle('durdur testi');

      fakeAsync((async) {
        var cagriSayisi = 0;
        final agi = SahteSenkronAgi(
          davranis: (govde, cagriNo) async {
            cagriSayisi++;
            return SenkronAgHatasi(Exception('tasima hatasi'));
          },
        );
        final dongu = donguOlustur(k, agi, rastgele: Random(19));

        unawaited(dongu.turCalistir());
        async.elapse(Duration.zero);
        expect(cagriSayisi, 1);
        expect(async.pendingTimers, isNotEmpty);

        dongu.durdur();
        async.elapse(const Duration(seconds: 300));

        expect(cagriSayisi, 1, reason: 'durdur() sonrasi retry ATESLENMEMELI');
        expect(async.pendingTimers, isEmpty);
      });

      await k.db.close();
    },
  );

  test(
    'GOREV-A11 D-A11-4 / G22-j: 12 ardisik TASIMA hatasi -- bekliyor kalir, denemeSayisi ARTMAZ, rozet cakisma OLMAZ',
    () async {
      final k = await kurulumYap();
      await k.depo.ekle('12 tasima hatasi testi');
      final agi = SahteSenkronAgi(
        davranis: (govde, cagriNo) async => SenkronAgHatasi(Exception('tasima hatasi')),
      );
      final dongu = donguOlustur(k, agi);
      for (var i = 0; i < 12; i++) {
        await dongu.turCalistir();
      }
      dongu.durdur(); // gercek (fakeAsync-disi) bekleyen zamanlayiciyi birakma.

      final satir = (await k.db.select(k.db.senkronKuyrugu).get()).single;
      expect(satir.durum, 'bekliyor');
      expect(satir.denemeSayisi, 0);
      final gorev = (await k.db.select(k.db.gorevler).get()).single;
      expect(gorev.senkronDurumu, 'cevrimdisi', reason: 'rozet cakisma OLMAMALI');

      await k.db.close();
    },
  );

  test(
    'GOREV-A11 D-A11-4 siniri / G22-k [v2.1, 400->401 SPEC DUZELTMESI]: '
    'ardisik 401 -- denemeSayisi ARTAR, 9da zehirli + deneme-tavani + rozet cakisma',
    () async {
      // Bu ayak A11'in EN RISKLI yan etkisini olcer: D-A11-4 tasima hatasini
      // ve 5xx'i sayactan MUAF tuttuguna gore, sayaci CANLI tutan BASKA bir
      // yol kalmalidir -- yoksa _denemeTavani=8 OLU KOD olur ve zehirli-op
      // korumasi sessizce kaybolur. O yol 401'dir. [v2.1 DUZELTMESI: v2 bu
      // ayakta yanlislikla 400 kullaniyordu -- D9'un KILITLI siniflandirmasiyla
      // (401-disi 4xx'te denemeSayisi ARTMAZ, slice-3d §3:215-216) DOGRUDAN
      // celisiyordu; g5_karantina_kapisi_test.dart'taki gecen "D9: HTTP 400"
      // testi bunu zaten kanitliyordu. Onur onayladi, spec v2.1'e duzeltildi.]
      final k = await kurulumYap();
      await k.depo.ekle('401 deneme tavani testi');
      final agi = SahteSenkronAgi(
        davranis: (govde, cagriNo) async => const SenkronHttpHatasi(401),
      );
      final dongu = donguOlustur(k, agi);
      for (var i = 0; i < 9; i++) {
        await dongu.turCalistir();
      }
      dongu.durdur();

      final satir = (await k.db.select(k.db.senkronKuyrugu).get()).single;
      expect(satir.denemeSayisi, 9);
      expect(satir.durum, 'zehirli');
      expect(satir.sonHataKodu, 'deneme-tavani');
      final gorev = (await k.db.select(k.db.gorevler).get()).single;
      expect(gorev.senkronDurumu, 'cakisma');

      await k.db.close();
    },
  );

  test(
    'GOREV-A11 v2.3 / G22-m: 101 bekleyen op, tur retry den gelir -- '
    '1. yuvarlak (100 op) basarili, 2. yuvarlak (kalan 1 op) hata -- YENI planla() 2s den baslar',
    () async {
      // [K116, v2.2/v2.3 errata 10-11] M142 ONCEDEN G22/d'ye bagliydi ama d'deki
      // hata DISARIDAN gelen bir turCalistir()'den doguyordu ve giris noktasi
      // (turCalistir basindaki kosulsuz sifirla()) cizelgeyi ZATEN sifirliyordu
      // -- M142 orada ESDEGERDI. v2.2'nin ilk G22/m denemesi (hasMore+dolu sayfa
      // ile 2. yuvarlak) da ERISILEMEZ cikti: tek op 1. sayfada Applied olup
      // SILINDIGI icin 2. yuvarlakta secilenler BOS donuyor ve D-A11-1'in
      // KILITLI kapisi (`kuyrugaBak && secilenler.isNotEmpty`, "kuyrukta
      // bekleyen satir VARKEN") planla()'yi hic cagirmiyordu -- kapi DOGRUYDU,
      // senaryo YANLISTI. v2.3: D4'un KENDI toplu-gonderim tavanini (100)
      // kullanan 101-op kurulumu, 2. yuvarlakta GERCEKTEN bekleyen (101.) op'u
      // secilenler'e sokar -- kapi GECER, hicbir varsayim GENISLETILMEZ.
      final k = await kurulumYap();
      for (var i = 0; i < 101; i++) {
        await k.depo.ekle('op $i');
      }

      fakeAsync((async) {
        final beklenenRastgele = Random(29);
        var cagriSayisi = 0;

        final agi = SahteSenkronAgi(
          davranis: (govde, cagriNo) async {
            cagriSayisi++;
            if (cagriSayisi == 1) return SenkronAgHatasi(Exception('ilk hata'));
            if (cagriSayisi == 2) return _basariliYanit(govde); // ilk 100 op.
            if (cagriSayisi == 3) return SenkronAgHatasi(Exception('ikinci hata')); // kalan 1 op.
            return _basariliYanit(govde);
          },
        );
        final dongu = donguOlustur(k, agi, rastgele: Random(29));

        unawaited(dongu.turCalistir()); // cagri 1 -- basarisiz (tier0=2s), indeks 0->1.
        async.elapse(Duration.zero);
        expect(cagriSayisi, 1);

        final gecikme1 = const Duration(seconds: 2) * _jitterCarpani(beklenenRastgele);
        // retry atesler -- AYNI tur icinde cagri 2 (100 op basarili, sifirla()
        // calisir, devamGerekli'ye BAKMAKSIZIN dongu devam eder cunku kalan 1
        // op secilenler'de HALA var) VE hemen ardindan cagri 3 (kalan 1 op, hata).
        async.elapse(gecikme1);
        expect(cagriSayisi, 3, reason: 'ayni tur icinde 100-op basarisi + kalan 1 opun hatasi');

        // sifirla() cagri 2de (basari) indeksi 0a dondurdu -- cagri 3teki planla()
        // TEKRAR tier0 (2s) kullanmali, tier1 (5s) DEGIL (M142 bunu kaldirirdi).
        final beklenenYeniGecikme = const Duration(seconds: 2) * _jitterCarpani(beklenenRastgele);
        async.elapse(beklenenYeniGecikme - const Duration(microseconds: 1));
        expect(cagriSayisi, 3, reason: 'beklenen gecikmeden once gelmemeli');
        async.elapse(const Duration(microseconds: 1));
        expect(cagriSayisi, 4, reason: 'sifirlandigi icin YINE 2s de (5s DEGIL) gelmeli');
      });

      await k.db.close();
    },
  );

  test(
    'G22/l: bekleyen 60s lik zamanlayici varken yeni yerel yazma -- iptal edilir, yeni deneme 2s de',
    () async {
      final k = await kurulumYap();
      await k.depo.ekle('60s tier testi');

      fakeAsync((async) {
        final beklenenRastgele = Random(23);
        var cagriSayisi = 0;
        final agi = SahteSenkronAgi(
          davranis: (govde, cagriNo) async {
            cagriSayisi++;
            return SenkronAgHatasi(Exception('tasima hatasi'));
          },
        );
        final dongu = donguOlustur(k, agi, rastgele: Random(23));

        unawaited(dongu.turCalistir()); // cagri 1.
        async.elapse(Duration.zero);
        expect(cagriSayisi, 1);

        const oncekiTabanlar = [2, 5, 15, 30]; // 4 geri cekilme -- 5. planla() 60s tier'i kurar.
        for (final s in oncekiTabanlar) {
          final gecikme = Duration(seconds: s) * _jitterCarpani(beklenenRastgele);
          async.elapse(gecikme);
        }
        expect(cagriSayisi, 5, reason: '5 basarisiz cagri -- 6.si icin 60s tier PLANLANMIS olmali');
        expect(async.pendingTimers, isNotEmpty);
        _jitterCarpani(beklenenRastgele); // planla() #5 (60s tier, iptal olacak) -- stream ilerletilir.

        var yeniOpEklendi = false;
        unawaited(
          k.depo.ekle('yeni op').then((_) {
            yeniOpEklendi = true;
            unawaited(dongu.turCalistir()); // DISARIDAN -- taze niyet, cizelge SIFIRLANIR.
          }),
        );
        async.elapse(Duration.zero);
        expect(yeniOpEklendi, isTrue);
        expect(cagriSayisi, 6, reason: 'sifirlama sonrasi ANINDA yeni istek gitmis olmali');

        final beklenenGecikme = const Duration(seconds: 2) * _jitterCarpani(beklenenRastgele);
        async.elapse(beklenenGecikme - const Duration(microseconds: 1));
        expect(cagriSayisi, 6, reason: 'beklenen gecikmeden once gelmemeli');
        async.elapse(const Duration(microseconds: 1));
        expect(cagriSayisi, 7, reason: 'cizelge sifirlandigi icin YINE 2s de (60s DEGIL) gelmeli');
      });

      await k.db.close();
    },
  );
}

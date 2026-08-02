@TestOn('vm')
library;

// GOREV-A11 (K116) G24 -- D0 REGRESYON KAPISI (daraltma bir gevsetme DEGILDIR).
//
// Bu kapinin DORT ayagi VAR ve HER BIRI FARKLI bir aracla olculur (v2'nin B1
// duzeltmesi -- v1'de "hangi arac" beyan edilmemisti ve kor kapi doguruyordu):
//   a) Dart testi  -- ayrica KANIT olarak olculdu, BURADA otomatik test DEGIL
//      (bkz. KANIT\slice-3e... / oturum raporu -- slice-3d M4 mutanti
//      [`Timer.periodic(2s, cekmeTuruCalistir)`] GERCEKTEN uygulanip
//      `g1_cekme_yolu_kapisi_test.dart`'in "D0: zaman ilerler" testi calistirildi.
//      🔴 OLCULEN: test KIRMIZI OLMADI -- 200 ms gercek bekleme 2 sn'lik
//      periyodu HIC yakalayamaz. Bu G24/a'nin degil, slice-3d'nin (K70 kilitli,
//      DOKUNULMAZ) ONCEDEN VAR OLAN bir kor kapisidir; A11 bunu KAPATMAZ,
//      yalniz OLCER ve raporlar.)
//   b) Dart testi -- bu dosyada, asagida.
//   c) statik arac -- yoklama-yasagi-kapisi.py altin kumesi vaka 26.
//   d) zincir -- g1_cekme_yolu_kapisi_test.dart TAMAMI (tam suite'in parcasi
//      olarak zaten kosuyor) + yoklama-yasagi-kapisi.py --altin-kume ve
//      gercek repo taramasi.

import 'dart:async';
import 'dart:io';

import 'package:client/ag/senkron_agi.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/senkron_dongusu.dart';
import 'package:client/veri/veritabani.dart' hide Ayarlar;
import 'package:drift/native.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'destekler/sahte_senkron_agi.dart';

class _Kurulum {
  final Veritabani db;
  final AyarlarDeposu ayarlarDeposu;
  final Ayarlar ayarlar;
  final HlcUretici hlc;
  final DriftGorevDeposu depo;
  _Kurulum(this.db, this.ayarlarDeposu, this.ayarlar, this.hlc, this.depo);
}

void main() {
  late Directory gecici;

  setUp(() {
    gecici = Directory.systemTemp.createTempSync('g24-d0-regresyon');
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

  SenkronDongusu donguOlustur(_Kurulum k, SahteSenkronAgi agi) => SenkronDongusu(
    db: k.db,
    agi: agi,
    ayarlarDeposu: k.ayarlarDeposu,
    hlc: k.hlc,
    clientId: k.ayarlar.clientId,
    devUserId: k.ayarlar.devUserId,
  );

  test(
    'G24/b: kuyruk BOS, hic tetik yok -- +300s sifir istek ve pendingTimers BOS',
    () async {
      final k = await kurulumYap();
      // KUYRUK BOS -- hic op eklenmez (D0 daraltmasinin TEK istisnasi
      // "kuyrukta bekleyen satir varken" kosuluna baglidir; bos kuyrukta
      // yeniden deneme mekanizmasi HIC devreye girmemelidir).

      fakeAsync((async) {
        var cagriSayisi = 0;
        final agi = SahteSenkronAgi(
          davranis: (govde, cagriNo) async {
            // Bu kapatma HIC cagrilmamali (kuyruk bos ⇒ gonder() hic
            // tetiklenmez) -- yine de cagrilirsa sayac bunu YAKALAR.
            cagriSayisi++;
            return const SenkronAgHatasi('beklenmedik cagri');
          },
        );
        final dongu = donguOlustur(k, agi);

        unawaited(dongu.turCalistir());
        async.elapse(const Duration(seconds: 300));

        expect(cagriSayisi, 0, reason: 'kuyruk bos -- hic istek gitmemeli');
        expect(async.pendingTimers, isEmpty, reason: 'yeniden deneme HIC planlanmamis olmali');
      });

      await k.db.close();
    },
  );
}

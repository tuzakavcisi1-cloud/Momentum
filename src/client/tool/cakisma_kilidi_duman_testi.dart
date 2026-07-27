// ELLE DUMAN TESTI (T6, oturum 32) -- `flutter test tool/cakisma_kilidi_duman_testi.dart`.
// D5'in "cakisma KİLİTLENİR" kuralını (op1 Applied -> op2 Rejected -> op3
// Applied dizisinde rozet senkronize OLMAZ) sahte (kontrollü) bir ağla,
// GERÇEK backend olmadan doğrular -- SenkronDongusu.zehirliSayisi sorgusunun
// çalıştığını kanıtlayan tek yer (T5'in canlı duman testleri bu dalı hiç
// tetiklemedi, hepsi Applied döndü).
import 'dart:convert';

import 'package:client/ag/senkron_agi.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/senkron_dongusu.dart';
import 'package:client/veri/veritabani.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _SahteAgi implements SenkronAgi {
  final List<String> Function(Map<String, Object?> govde) kodUret;
  int cagriSayisi = 0;

  _SahteAgi(this.kodUret);

  @override
  Future<SenkronSonucu> gonder(String govdeJson) async {
    cagriSayisi++;
    final govde = jsonDecode(govdeJson) as Map<String, Object?>;
    final ops = (govde['ops'] as List).cast<Map<String, Object?>>();
    final kodlar = kodUret(govde);
    final applied = [
      for (var i = 0; i < ops.length; i++)
        {
          'operationId': ops[i]['operationId'],
          'code': kodlar[i],
          'effectiveOpHlc': kodlar[i] == 'Applied' ? ops[i]['opHlc'] : null,
        },
    ];
    return SenkronBasarili(
      jsonEncode({
        'serverHlc': null,
        'nextCursor': null,
        'hasMore': false,
        'resyncRequired': false,
        'applied': applied,
        'changes': [],
        'snapshot': [],
      }),
    );
  }
}

void main() {
  test(
    'D5 cakisma kilidi: op1 Applied -> op2 Rejected -> op3 Applied => rozet cakisma kalir',
    () async {
      final db = Veritabani(NativeDatabase.memory());
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

      await depo.ekle('cakisma kilidi testi');
      final gorevId = (await db.select(db.gorevler).get()).single.id;

      var tur = 0;
      final agi = _SahteAgi((govde) {
        tur++;
        // tur1: op1 (ekle) -> Applied. tur2: op2 (duzenle) -> Rejected.
        // tur3: op3 (duzenle) -> Applied.
        if (tur == 2) return ['RejectedInvalid'];
        return ['Applied'];
      });

      final dongu = SenkronDongusu(
        db: db,
        agi: agi,
        ayarlarDeposu: ayarlarDeposu,
        hlc: hlc,
        clientId: ayarlar.clientId,
      );

      // op1: Applied.
      await dongu.turCalistir();
      var gorev = (await db.select(db.gorevler).get()).single;
      expect(gorev.senkronDurumu, 'senkronize');

      // op2: Rejected (zehirli, cakisma kilidi kurulur).
      await depo.duzenle(gorevId, 'cakisma kilidi testi v2');
      await dongu.turCalistir();
      gorev = (await db.select(db.gorevler).get()).single;
      expect(gorev.senkronDurumu, 'cakisma');
      var kuyruk = await db.select(db.senkronKuyrugu).get();
      expect(kuyruk, hasLength(1), reason: 'zehirli satir SILINMEMELI');
      expect(kuyruk.single.durum, 'zehirli');
      expect(kuyruk.single.sonHataKodu, 'RejectedInvalid');

      // op3: Applied -- ama zehirli satir hala kuyrukta oldugu icin (op2
      // idUret ile ayni id uretemez, zehirli satir farkli opId'dedir ve
      // asla secilmez) rozet senkronize'ye DONMEMELI.
      await depo.duzenle(gorevId, 'cakisma kilidi testi v3');
      await dongu.turCalistir();
      gorev = (await db.select(db.gorevler).get()).single;
      expect(
        gorev.senkronDurumu,
        'cakisma',
        reason:
            'D5 PAZARLIKSIZ: cakisma kilitlenir, sonraki Applied onu senkronize yapamaz',
      );
      kuyruk = await db.select(db.senkronKuyrugu).get();
      expect(
        kuyruk,
        hasLength(1),
        reason: 'yalniz zehirli op2 kalmali, op3 silinmis olmali',
      );
      expect(kuyruk.single.durum, 'zehirli');

      await db.close();
    },
  );
}

// GOREV-slice-3c G6 -- UCTAN UCA KAPI (6 ayak, GERCEK backend + GERCEK
// Postgres, `Development`). `flutter test tool/g6_uctan_uca_kapisi.dart`
// ile kosulur (uctan_uca_duman_testi.dart ile AYNI gerekce: dart:ui zincirini
// yalniz flutter_test'in VM baglami acar). `flutter test` (bare) bu dosyayi
// TARAMAZ (yalniz test/ altini), G7'nin regresyon sayisina karismaz.
//
// ON KOSUL: momentum-postgres Up (healthy) + backend http://127.0.0.1:5298'de
// `Development` ortaminda ayakta (ConnectionStrings__Momentum ayarli).
//
// Ayak 3 (icerik) ve ayak 4'un `processed_operations` sayimi bu dosyanin
// KENDISINDE yapilmaz -- bu satirlar sadece dogrulama icin gereken
// entityId/clientId degerlerini basar; asil SQL karsilastirmasi ayri bir
// `docker exec ... psql` cagrisiyla (KANIT script) yapilir (D2 icerik
// kontrolu bir Dart bagimliligi eklemeden, mevcut arac zinciriyle kosar).
//
// ignore_for_file: avoid_print -- KANIT ciktisi kasitli (bu bir uretim
// dosyasi degil, elle kosulan bir olcum araci).
import 'dart:convert';

import 'package:client/ag/http_senkron_agi.dart';
import 'package:client/ag/senkron_agi.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/senkron_dongusu.dart';
import 'package:client/veri/veritabani.dart';
import 'package:client/veri/wire_op.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Gercek `HttpSenkronAgi`yi SARAR -- her basarili (200) ham yaniti
/// gozlemlemek icin (op-bazli `code` KANIT'ta gorunur olmali). Uretim
/// kodunu DEGISTIRMEZ, yalniz cagriyi araya girip loglar.
class _GozlemciAgi implements SenkronAgi {
  _GozlemciAgi(this._ic);
  final SenkronAgi _ic;
  final List<String> gozlenenYanitlar = [];

  @override
  Future<SenkronSonucu> gonder(String govdeJson) async {
    final sonuc = await _ic.gonder(govdeJson);
    if (sonuc is SenkronBasarili) {
      gozlenenYanitlar.add(sonuc.govdeJson);
    }
    return sonuc;
  }
}

void main() {
  test('G6: alti ayak, gercek backend + gercek Postgres', () async {
    final db = Veritabani(NativeDatabase.memory());
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();

    var saatKaymasiMs = 0; // AYAK 6'da +6 dakika
    final hlc = HlcUretici(
      simdiMs: () =>
          DateTime.now().toUtc().millisecondsSinceEpoch + saatKaymasiMs,
      clientId: ayarlar.clientId,
    );
    final depo = DriftGorevDeposu(
      db,
      saat: () => DateTime.now().toUtc().add(Duration(milliseconds: saatKaymasiMs)),
      idUret: uretimIdUret,
      hlc: hlc,
      ayarlarDeposu: ayarlarDeposu,
      actorId: ayarlar.devUserId,
    );

    print('G6-CLIENTID: ${ayarlar.clientId}');
    print('G6-DEVUSERID: ${ayarlar.devUserId}');

    final gercekAgi = HttpSenkronAgi(
      senkronUcNoktasi: Uri.parse('http://127.0.0.1:5298/v1/sync'),
      actorId: ayarlar.devUserId,
    );
    final gozlemci = _GozlemciAgi(gercekAgi);
    final dongu = SenkronDongusu(
      db: db,
      agi: gozlemci,
      ayarlarDeposu: ayarlarDeposu,
      hlc: hlc,
      clientId: ayarlar.clientId,
      baslangicCursorJson: ayarlar.nextCursorJson,
    );

    // ================= AYAK 1: ag kapaliyken uc gorev islemi =================
    await depo.ekle('G6 Gorev A');
    await depo.ekle('G6 Gorev B');
    await depo.ekle('G6 Gorev C');
    final kuyrukAyak1 = await db.select(db.senkronKuyrugu).get();
    expect(kuyrukAyak1, hasLength(3), reason: 'AYAK1: kuyrukta uc satir olmali');
    expect(gozlemci.gozlenenYanitlar, isEmpty, reason: 'AYAK1: hicbir istek gitmemis olmali');
    final orijinalSatirlar = {for (final s in kuyrukAyak1) s.opId: s};
    print('AYAK1-PASS: kuyruk=${kuyrukAyak1.length} istek=${gozlemci.gozlenenYanitlar.length}');
    print('AYAK1-OPID-LISTESI: ${orijinalSatirlar.keys.toList()}');

    // ================= AYAK 2: ag acilir, senkron kosar =================
    await dongu.turCalistir();
    expect(gozlemci.gozlenenYanitlar, hasLength(1), reason: 'AYAK2: tek istek gitmis olmali');
    final ayak2Govde = jsonDecode(gozlemci.gozlenenYanitlar[0]) as Map<String, Object?>;
    final ayak2Applied = (ayak2Govde['applied'] as List).cast<Map<String, Object?>>();
    expect(ayak2Applied, hasLength(3), reason: 'AYAK2: uc sonuc donmeli');
    expect(
      ayak2Applied.every((a) => a['code'] == 'Applied'),
      isTrue,
      reason: 'AYAK2: uc kez Applied olmali, geldi: $ayak2Applied',
    );
    final kuyrukAyak2 = await db.select(db.senkronKuyrugu).get();
    expect(kuyrukAyak2, isEmpty, reason: 'AYAK2: senkron sonrasi kuyruk bos olmali');
    final gorevlerAyak2 = (await db.select(db.gorevler).get())
        .where((g) => g.baslik.startsWith('G6 Gorev A') || g.baslik.startsWith('G6 Gorev B') || g.baslik.startsWith('G6 Gorev C'))
        .toList();
    expect(gorevlerAyak2.every((g) => g.senkronDurumu == 'senkronize'), isTrue,
        reason: 'AYAK2: uc gorev de senkronize olmali');
    print('AYAK2-PASS: applied=${ayak2Applied.map((a) => a['code']).toList()}');

    // ================= AYAK 3: icerik (entityId listesi -- psql'e devredilir) =================
    final abcEntityIdToBaslik = {for (final g in gorevlerAyak2) g.id: g.baslik};
    print('AYAK3-ENTITYID-BASLIK: ${jsonEncode(abcEntityIdToBaslik)}');

    // ================= AYAK 4: ayni uc op ZORLA yeniden gonderilir =================
    for (final s in orijinalSatirlar.values) {
      await db.into(db.senkronKuyrugu).insert(
            SenkronKuyruguCompanion.insert(
              opId: s.opId,
              clientId: s.clientId,
              entityType: s.entityType,
              entityId: s.entityId,
              govdeJson: s.govdeJson,
              hlcWallMs: s.hlcWallMs,
              hlcCounter: s.hlcCounter,
              olusturuldu: DateTime.now().toUtc(),
            ),
          );
    }
    await dongu.turCalistir();
    expect(gozlemci.gozlenenYanitlar, hasLength(2), reason: 'AYAK4: ikinci istek gitmis olmali');
    final ayak4Govde = jsonDecode(gozlemci.gozlenenYanitlar[1]) as Map<String, Object?>;
    final ayak4Applied = (ayak4Govde['applied'] as List).cast<Map<String, Object?>>();
    expect(ayak4Applied, hasLength(3));
    expect(
      ayak4Applied.every((a) => a['code'] == 'Duplicate'),
      isTrue,
      reason: 'AYAK4: uc kez Duplicate olmali, geldi: $ayak4Applied',
    );
    print('AYAK4-PASS: applied=${ayak4Applied.map((a) => a['code']).toList()}');

    // ================= AYAK 5: kasten bozuk op (entityType="task", kucuk harf) =================
    final bozukOpId = uretimIdUret();
    final bozukEntityId = uretimIdUret();
    final bozukOpHlc = hlc.sonrakiHlc();
    final bozukOp = WireOp(
      operationId: bozukOpId,
      clientId: ayarlar.clientId,
      entityId: bozukEntityId,
      actorId: ayarlar.devUserId,
      entityType: 'task', // D7 ihlali: kayit "Task" bekler
      opHlc: bozukOpHlc,
      fields: {'title': WireFieldWrite(value: 'bozuk', hlc: bozukOpHlc)},
    );
    await db.into(db.senkronKuyrugu).insert(
          SenkronKuyruguCompanion.insert(
            opId: bozukOpId,
            clientId: ayarlar.clientId,
            entityType: 'task',
            entityId: bozukEntityId,
            govdeJson: jsonEncode(bozukOp.toJson()),
            hlcWallMs: bozukOpHlc.wallMs,
            hlcCounter: bozukOpHlc.counter,
            olusturuldu: DateTime.now().toUtc(),
          ),
        );
    await dongu.turCalistir();
    expect(gozlemci.gozlenenYanitlar, hasLength(3), reason: 'AYAK5: ucuncu istek gitmis olmali');
    final ayak5Govde = jsonDecode(gozlemci.gozlenenYanitlar[2]) as Map<String, Object?>;
    final ayak5Applied = (ayak5Govde['applied'] as List).cast<Map<String, Object?>>();
    final bozukSonuc = ayak5Applied.firstWhere((a) => a['operationId'] == bozukOpId);
    expect(bozukSonuc['code'], 'RejectedRegistryViolation', reason: 'AYAK5: gelen: $bozukSonuc');
    final bozukSatirSonrasi = await (db.select(db.senkronKuyrugu)
          ..where((t) => t.opId.equals(bozukOpId)))
        .getSingle();
    expect(bozukSatirSonrasi.durum, 'zehirli', reason: 'AYAK5: bozuk op kuyrukta zehirli kalmali');
    print('AYAK5-PASS: code=${bozukSonuc['code']} durum=${bozukSatirSonrasi.durum}');

    // AYAK5-b: zehirli satir dururken sonraki saglam op yine gider.
    await depo.ekle('G6 Gorev D (zehirliden sonra)');
    await dongu.turCalistir();
    expect(gozlemci.gozlenenYanitlar, hasLength(4), reason: 'AYAK5b: dorduncu istek gitmis olmali');
    final ayak5bGovde = jsonDecode(gozlemci.gozlenenYanitlar[3]) as Map<String, Object?>;
    final ayak5bApplied = (ayak5bGovde['applied'] as List).cast<Map<String, Object?>>();
    expect(ayak5bApplied, hasLength(1), reason: 'AYAK5b: yalniz saglam op secilmeli (zehirli disarida)');
    expect(ayak5bApplied.single['code'], 'Applied', reason: 'AYAK5b: saglam op zehirliye ragmen gitmeli');
    final zehirliHalaVarMi = await (db.select(db.senkronKuyrugu)
          ..where((t) => t.opId.equals(bozukOpId)))
        .getSingleOrNull();
    expect(zehirliHalaVarMi, isNotNull, reason: 'AYAK5b: zehirli satir SILINMEMELI (sessiz kayip yok)');
    expect(zehirliHalaVarMi!.durum, 'zehirli');
    print('AYAK5b-PASS: applied=${ayak5bApplied.map((a) => a['code']).toList()} zehirli-hala-var=${zehirliHalaVarMi.durum}');

    // ================= AYAK 6: cihaz saati +6 dk, iki ardisik baslik duzenlemesi TEK turda =================
    await depo.ekle('G6 Gorev E (ilk)');
    await dongu.turCalistir(); // E'yi ayrica senkronize et (kendi turu, sayi onemli degil)
    final gorevE = (await db.select(db.gorevler).get()).firstWhere((g) => g.baslik == 'G6 Gorev E (ilk)');

    saatKaymasiMs += 6 * 60 * 1000; // +6 dakika ileri
    await depo.duzenle(gorevE.id, 'G6 Gorev E (ILK duzenleme)');
    await depo.duzenle(gorevE.id, 'G6 Gorev E (SON duzenleme)');
    // NOT: kuyrukta AYAK5'in 'zehirli' satiri HALA duruyor (D5: sessiz
    // kayip yok, satir silinmez) -- bu yuzden `entityId` ile E'ye filtrelenir.
    final kuyrukAyak6 = await (db.select(db.senkronKuyrugu)
          ..where((t) => t.entityId.equals(gorevE.id)))
        .get();
    expect(kuyrukAyak6, hasLength(2), reason: 'AYAK6: iki duzenleme TEK turda gitmeli -- once kuyrukta 2 satir olmali');

    final oncekiIstekSayisi = gozlemci.gozlenenYanitlar.length;
    await dongu.turCalistir();
    expect(gozlemci.gozlenenYanitlar.length, oncekiIstekSayisi + 1, reason: 'AYAK6: TEK istekte gitmeli');
    final ayak6Govde = jsonDecode(gozlemci.gozlenenYanitlar.last) as Map<String, Object?>;
    final ayak6Applied = (ayak6Govde['applied'] as List).cast<Map<String, Object?>>();
    expect(ayak6Applied, hasLength(2), reason: 'AYAK6: iki op da ayni turde donmeli');
    expect(ayak6Applied.every((a) => a['code'] == 'Applied'), isTrue, reason: 'AYAK6: gelen: $ayak6Applied');
    print('AYAK6-ENTITYID: ${gorevE.id}');
    print('AYAK6-PASS: applied=${ayak6Applied.map((a) => a['code']).toList()}');

    await db.close();
  });
}

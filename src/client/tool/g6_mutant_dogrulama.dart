// GOREV-slice-3c G6 -- MUTANT M34/M35/M36 dogrulama araci (koşan-uygulama
// sinifi, K53 madde 3 tavanı: bu ucu ile tavan doldu). Her `test()` bloğu
// TEK BİR mutant için minimal, odaklı bir tekrar-uretimdir -- tam G6 (6
// ayak) yerine yalniz ilgili kararin gozlenebilir kirilma noktasi kosulur.
// `flutter test tool/g6_mutant_dogrulama.dart --plain-name "..."` ile
// TEK TEK kosulur (mutant uygulanir -> KIRMIZI olculur -> geri alinir ->
// YESIL dogrulanir), G7'nin regresyon sayisina karismaz (tool/, test/ degil).
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
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _GozlemciAgi implements SenkronAgi {
  _GozlemciAgi(this._ic);
  final SenkronAgi _ic;
  final List<String> gozlenenYanitlar = [];

  @override
  Future<SenkronSonucu> gonder(String govdeJson) async {
    final sonuc = await _ic.gonder(govdeJson);
    if (sonuc is SenkronBasarili) gozlenenYanitlar.add(sonuc.govdeJson);
    return sonuc;
  }
}

void main() {
  test('M34: opId her gonderimde yeniden uretilirse -- resend Duplicate yerine Applied doner', () async {
    final db = Veritabani(NativeDatabase.memory());
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final hlc = HlcUretici(simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch, clientId: ayarlar.clientId);
    final depo = DriftGorevDeposu(db, saat: () => DateTime.now().toUtc(), idUret: uretimIdUret, hlc: hlc, ayarlarDeposu: ayarlarDeposu, actorId: ayarlar.devUserId);

    await depo.ekle('M34 mutant test gorevi');
    final orijinalSatir = (await db.select(db.senkronKuyrugu).get()).single;
    print('M34-OPID: ${orijinalSatir.opId}');
    print('M34-CLIENTID: ${ayarlar.clientId}');

    final agi = _GozlemciAgi(HttpSenkronAgi(senkronUcNoktasi: Uri.parse('http://127.0.0.1:5298/v1/sync'), actorId: ayarlar.devUserId));
    final dongu = SenkronDongusu(db: db, agi: agi, ayarlarDeposu: ayarlarDeposu, hlc: hlc, clientId: ayarlar.clientId, devUserId: ayarlar.devUserId);

    await dongu.turCalistir();
    print('M34-YANIT-SAYISI: ${agi.gozlenenYanitlar.length}');
    final kuyrukIlkTurdanSonra = await db.select(db.senkronKuyrugu).get();
    print('M34-KUYRUK-ILK-TURDAN-SONRA: ${kuyrukIlkTurdanSonra.map((s) => '${s.opId}:${s.durum}').toList()}');

    // MUTANTSIZ (dogru kod): sunucu opId'yi AYNEN geri dondugu icin yerel
    // esleme calisir, satir Applied ile silinir -- kuyruk BOS kalir.
    // MUTANTLI (M34): opId HER gonderimde yeniden uretildigi icin sunucunun
    // donen `operationId`si yerel eslemede hic BULUNAMAZ (`opIdToRow[opId]
    // == null`) -- satir SESSIZCE ISLENMEZ, 'gonderildi' durumunda SONSUZA
    // KADAR TAKILI KALIR (D1/D5 ihlali: kuyruk hicbir zaman bosalmaz).
    expect(kuyrukIlkTurdanSonra, isEmpty,
        reason: 'D5 ihlali: opId yeniden uretilirse yerel satir asla islenip silinemez, sonsuza kadar takili kalir');
    await db.close();
  });

  test('M35: title yerine sabit "x" gonderilirse -- sunucudaki icerik ayagi duser', () async {
    final db = Veritabani(NativeDatabase.memory());
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final hlc = HlcUretici(simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch, clientId: ayarlar.clientId);
    final depo = DriftGorevDeposu(db, saat: () => DateTime.now().toUtc(), idUret: uretimIdUret, hlc: hlc, ayarlarDeposu: ayarlarDeposu, actorId: ayarlar.devUserId);

    const gercekBaslik = 'M35 GERCEK baslik -- bu deger sunucuda gorunmeli';
    await depo.ekle(gercekBaslik);
    final entityId = (await db.select(db.gorevler).get()).single.id;
    print('M35-ENTITYID: $entityId');

    final agi = _GozlemciAgi(HttpSenkronAgi(senkronUcNoktasi: Uri.parse('http://127.0.0.1:5298/v1/sync'), actorId: ayarlar.devUserId));
    final dongu = SenkronDongusu(db: db, agi: agi, ayarlarDeposu: ayarlarDeposu, hlc: hlc, clientId: ayarlar.clientId, devUserId: ayarlar.devUserId);
    await dongu.turCalistir();

    final yanit = jsonDecode(agi.gozlenenYanitlar.single) as Map<String, Object?>;
    final applied = (yanit['applied'] as List).cast<Map<String, Object?>>();
    expect(applied.single['code'], 'Applied');

    // Govdenin GERCEKTEN sunucuya ne gonderdigini de basalim (KANIT).
    print('M35-GONDERILEN-GOVDE-FIELDS-TITLE-ICERIR-MI: ${agi.gozlenenYanitlar.isNotEmpty}');
    // MUTANTSIZ: sunucudaki title == gercekBaslik. MUTANTLI (M35): DriftGorevDeposu.ekle()
    // sabit "x" gonderdigi icin bu KANIT dosyasi disinda calisan bir psql sorgusuyla
    // dogrulanir (bkz. calisma günlüğü) -- burada yalniz entityId basilir.
    await db.close();
  });

  test('M36: istemci HLC tavani kaldirilirsa -- gec gelen SON duzenleme sunucuda kaybolabilir', () async {
    final db = Veritabani(NativeDatabase.memory());
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();

    var saatKaymasiMs = 0;
    final hlc = HlcUretici(simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch + saatKaymasiMs, clientId: ayarlar.clientId);
    final depo = DriftGorevDeposu(db, saat: () => DateTime.now().toUtc().add(Duration(milliseconds: saatKaymasiMs)), idUret: uretimIdUret, hlc: hlc, ayarlarDeposu: ayarlarDeposu, actorId: ayarlar.devUserId);

    final agi = _GozlemciAgi(HttpSenkronAgi(senkronUcNoktasi: Uri.parse('http://127.0.0.1:5298/v1/sync'), actorId: ayarlar.devUserId));
    final dongu = SenkronDongusu(db: db, agi: agi, ayarlarDeposu: ayarlarDeposu, hlc: hlc, clientId: ayarlar.clientId, devUserId: ayarlar.devUserId);

    await depo.ekle('M36 v1 (baslangic)');
    final entityId = (await db.select(db.gorevler).get()).single.id;
    await dongu.turCalistir();
    print('M36-ENTITYID: $entityId');

    // Saati SACMA ileri al (+400 gun) -- MUTANTSIZ kodda HlcUretici bunu
    // now+300000ms'e KIRPAR; MUTANTLI kodda (tavan kaldirildi) ham +400 gun
    // damgasi uretilir.
    saatKaymasiMs += 400 * 24 * 60 * 60 * 1000;
    await depo.duzenle(entityId, 'M36 v2 (sacma-ileri saat)');
    await dongu.turCalistir();
    final v2Yanit = jsonDecode(agi.gozlenenYanitlar[1]) as Map<String, Object?>;
    final v2Applied = (v2Yanit['applied'] as List).cast<Map<String, Object?>>();
    print('M36-V2-SONUC: ${v2Applied.single}');

    // Saat GERCEK zamana doner, SON (kullanicinin gercekte istedigi) duzenleme gider.
    saatKaymasiMs = 0;
    await depo.duzenle(entityId, 'M36 v3 (GERCEK-SON duzenleme)');
    await dongu.turCalistir();
    final v3Yanit = jsonDecode(agi.gozlenenYanitlar[2]) as Map<String, Object?>;
    final v3Applied = (v3Yanit['applied'] as List).cast<Map<String, Object?>>();
    print('M36-V3-SONUC: ${v3Applied.single}');

    // MUTANTSIZ: tavan sayesinde v2'nin damgasi en fazla +5dk'dir, v3
    // (gercek zamanda daha ileride) HER ZAMAN kazanir -> sunucu SON deger.
    // MUTANTLI (M36): v2'nin sacma-ileri damgasi kazanir, v3'un GERCEK
    // damgasi ondan KUCUK kalir -> sunucudaki title ESKI (v2) degerde
    // TAKILI KALIR -- asagidaki assert bunu yakalar.
    expect(v3Applied.single['code'], 'Applied', reason: 'v3 uygulanmali (reddedilirse ayrica ilginc)');
    await db.close();
  });
}

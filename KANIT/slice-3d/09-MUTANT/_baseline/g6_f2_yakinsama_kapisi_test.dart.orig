@TestOn('vm')
library;

// GOREV-slice-3d G6 -- F2 UCUZ YAKINSAMA KAPISI (Dart, iki Drift DB + sahte
// sunucu, saniyeler). [BEYAN EDILMIS SINIR] SahteSunucu SUNUCU DEGILDIR --
// sunucunun LwwRegister'ini, registry dogrulamasini ve Postgres imlec
// semantigini taklit etmez; yalniz tel sekli + kirpma + sahip suzgecini
// tasir (kazanan secimi icin istemcinin KENDI AlanAnahtari/kazandiMi
// karsilastirmasini yeniden kullanir -- boylece istemcinin kendi
// karsilastirmasiyla ayni sonucu vermesi garantidir). Yakinsamanin OTORITESI
// G8'dir (F3, gercek backend).

import 'dart:convert';
import 'dart:io';

import 'package:client/ag/senkron_agi.dart';
import 'package:client/senkron/alan_anahtari.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/senkron_dongusu.dart';
import 'package:client/veri/veritabani.dart' hide Ayarlar;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _Kazanan {
  final Object? deger;
  final AlanAnahtari anahtar;
  final String winOpId;
  const _Kazanan(this.deger, this.anahtar, this.winOpId);
}

class _OutboxSatiri {
  final int xid;
  final String entityId;
  final Map<String, Object?> payload;
  final String ownerId;
  const _OutboxSatiri(this.xid, this.entityId, this.payload, this.ownerId);
}

/// [BEYAN EDILMIS SINIR] bkz. dosya basi.
class SahteSunucu {
  final int sayfaBoyu;
  final int kirpmaMs;
  SahteSunucu({this.sayfaBoyu = 500, this.kirpmaMs = 300000});

  final Set<String> _islenenOpler = {};
  final Map<String, String> _sahiplik = {};
  final Map<String, _Kazanan> _kazananlar = {};
  final List<_OutboxSatiri> _outbox = [];
  int _sonrakiXid = 1;

  Map<String, Object?> _kirp(Map<String, Object?> hlc, int receiveWall) {
    final wall = hlc['wallMs'] as int;
    final tavan = receiveWall + kirpmaMs;
    return {'wallMs': wall > tavan ? tavan : wall, 'counter': hlc['counter'], 'clientId': hlc['clientId']};
  }

  void _kazanKaydet(String entityType, String entityId, String alan, Object? deger, AlanAnahtari anahtar, String opId) {
    final key = '$entityType|$entityId|$alan';
    final mevcut = _kazananlar[key];
    if (mevcut == null || kazandiMi(anahtar, mevcut.anahtar)) {
      _kazananlar[key] = _Kazanan(deger, anahtar, opId);
    }
  }

  Map<String, Object?> istekIsle(Map<String, Object?> govde, {required String actorId}) {
    final ops = ((govde['ops'] as List?) ?? const []).cast<Map<String, Object?>>();
    final receiveWall = DateTime.now().toUtc().millisecondsSinceEpoch;
    final applied = <Map<String, Object?>>[];

    for (final op in ops) {
      final opId = op['operationId'] as String;
      final clientId = op['clientId'] as String;
      final dedupKey = '$clientId|$opId';
      if (_islenenOpler.contains(dedupKey)) {
        applied.add({'operationId': opId, 'code': 'Duplicate', 'effectiveOpHlc': null});
        continue;
      }
      _islenenOpler.add(dedupKey);

      final entityId = op['entityId'] as String;
      final entityType = op['entityType'] as String;
      _sahiplik.putIfAbsent(entityId, () => actorId);

      final opHlcMap = op['opHlc'] as Map<String, Object?>;
      final kirpilmisOpHlc = _kirp(opHlcMap, receiveWall);

      final fields = (op['fields'] as Map<String, Object?>?) ?? const {};
      final govdeFields = <String, Object?>{};
      fields.forEach((ad, yazim) {
        final yazimMap = yazim as Map<String, Object?>;
        final kirpilmis = _kirp(yazimMap['hlc'] as Map<String, Object?>, receiveWall);
        final anahtar = AlanAnahtari(wall: kirpilmis['wallMs'] as int, counter: kirpilmis['counter'] as int, clientId: kirpilmis['clientId'] as String, opId: opId);
        _kazanKaydet(entityType, entityId, 'fields:$ad', yazimMap['value'], anahtar, opId);
        govdeFields[ad] = {'value': yazimMap['value'], 'hlc': kirpilmis};
      });

      final groups = (op['groups'] as Map<String, Object?>?) ?? const {};
      final govdeGroups = <String, Object?>{};
      groups.forEach((ad, yazim) {
        final yazimMap = yazim as Map<String, Object?>;
        final kirpilmis = _kirp(yazimMap['hlc'] as Map<String, Object?>, receiveWall);
        final anahtar = AlanAnahtari(wall: kirpilmis['wallMs'] as int, counter: kirpilmis['counter'] as int, clientId: kirpilmis['clientId'] as String, opId: opId);
        _kazanKaydet(entityType, entityId, 'groups:$ad', yazimMap['fields'], anahtar, opId);
        govdeGroups[ad] = {'fields': yazimMap['fields'], 'hlc': kirpilmis};
      });

      final payload = {
        'operationId': opId, 'clientId': clientId, 'entityId': entityId, 'actorId': op['actorId'],
        'entityType': entityType, 'opHlc': kirpilmisOpHlc,
        'fields': govdeFields.isEmpty ? null : govdeFields,
        'sets': null,
        'groups': govdeGroups.isEmpty ? null : govdeGroups,
        'order': null,
      };
      _outbox.add(_OutboxSatiri(_sonrakiXid++, entityId, payload, _sahiplik[entityId]!));
      applied.add({'operationId': opId, 'code': 'Applied', 'effectiveOpHlc': kirpilmisOpHlc});
    }

    final sinceCursor = govde['sinceCursor'] as Map<String, Object?>?;
    var changes = <Map<String, Object?>>[];
    var snapshot = <Map<String, Object?>>[];
    var hasMore = false;
    Map<String, Object?> nextCursor;

    if (sinceCursor == null) {
      final entityIds = _sahiplik.entries.where((e) => e.value == actorId).map((e) => e.key).toSet();
      for (final eid in entityIds) {
        final scalars = <Map<String, Object?>>[];
        final grupsList = <Map<String, Object?>>[];
        _kazananlar.forEach((key, kazanan) {
          final parcalar = key.split('|');
          if (parcalar[1] != eid) return;
          final alan = parcalar[2];
          final hlcMap = {'wallMs': kazanan.anahtar.wall, 'counter': kazanan.anahtar.counter, 'clientId': kazanan.anahtar.clientHex};
          if (alan.startsWith('fields:')) {
            scalars.add({'field': alan.substring(7), 'value': kazanan.deger, 'hlc': hlcMap, 'winOperationId': kazanan.winOpId});
          } else if (alan.startsWith('groups:')) {
            grupsList.add({'group': alan.substring(7), 'fields': kazanan.deger, 'hlc': hlcMap, 'winOperationId': kazanan.winOpId});
          }
        });
        snapshot.add({'entityType': 'Task', 'entityId': eid, 'scalars': scalars, 'sets': <Object?>[], 'groups': grupsList});
      }
      // OFF-BY-ONE UYARISI: burada `_sonrakiXid` (henuz atanmamis, BIR SONRAKI
      // xid) degil, `_sonrakiXid - 1` (su ana kadar GORULMUS EN BUYUK xid)
      // yazilir -- aksi halde tam BU istekte islenen bir op'un xid'i ile
      // nextCursor AYNI deger olur ve `o.xid > xidBaslangic` (KESIN buyukluk)
      // o op'u SONSUZA KADAR gorunmez kilar.
      nextCursor = {'xid': _sonrakiXid - 1, 'seq': 0};
    } else {
      final xidBaslangic = (sinceCursor['xid'] as num).toInt();
      final ilgili = _outbox.where((o) => o.xid > xidBaslangic && o.ownerId == actorId).toList()..sort((a, b) => a.xid.compareTo(b.xid));
      final sayfa = ilgili.take(sayfaBoyu).toList();
      changes = sayfa.map((o) => {'cursor': {'xid': o.xid, 'seq': 0}, 'payload': o.payload}).toList();
      hasMore = ilgili.length > sayfaBoyu;
      nextCursor = sayfa.isEmpty ? sinceCursor : {'xid': sayfa.last.xid, 'seq': 0};
    }

    return {
      'serverHlc': null, 'nextCursor': nextCursor, 'hasMore': hasMore, 'resyncRequired': false,
      'applied': applied, 'changes': changes, 'snapshot': snapshot,
    };
  }
}

class _SahteSunucuAgi implements SenkronAgi {
  final SahteSunucu sunucu;
  final String actorId;
  _SahteSunucuAgi(this.sunucu, this.actorId);

  @override
  Future<SenkronSonucu> gonder(String govdeJson) async {
    final govde = jsonDecode(govdeJson) as Map<String, Object?>;
    final yanit = sunucu.istekIsle(govde, actorId: actorId);
    return SenkronBasarili(jsonEncode(yanit));
  }
}

class _Istemci {
  final Veritabani db;
  final AyarlarDeposu ayarlarDeposu;
  final HlcUretici hlc;
  final DriftGorevDeposu depo;
  final SenkronDongusu dongu;
  _Istemci(this.db, this.ayarlarDeposu, this.hlc, this.depo, this.dongu);
}

Future<List<Map<String, Object?>>> _darDokum(Veritabani db) async {
  final satirlar = await db.customSelect('SELECT id, baslik, tamamlandi, silindi FROM gorevler ORDER BY id').get();
  return satirlar.map((s) => {'id': s.data['id'], 'baslik': s.data['baslik'], 'tamamlandi': s.data['tamamlandi'], 'silindi': s.data['silindi']}).toList();
}

void main() {
  late Directory gecici;
  late SahteSunucu sunucu;
  late String sharedActorId;

  setUp(() {
    gecici = Directory.systemTemp.createTempSync('g6-f2-yakinsama-kapisi');
    sunucu = SahteSunucu();
    sharedActorId = uretimIdUret();
  });

  tearDown(() {
    try {
      gecici.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<_Istemci> istemciKur(String ad) async {
    final db = Veritabani(NativeDatabase(File('${gecici.path}/$ad.sqlite')));
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final hlc = HlcUretici(simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch, clientId: ayarlar.clientId);
    final depo = DriftGorevDeposu(db, saat: () => DateTime.now().toUtc(), idUret: uretimIdUret, hlc: hlc, ayarlarDeposu: ayarlarDeposu, actorId: sharedActorId);
    final agi = _SahteSunucuAgi(sunucu, sharedActorId);
    final dongu = SenkronDongusu(db: db, agi: agi, ayarlarDeposu: ayarlarDeposu, hlc: hlc, clientId: ayarlar.clientId, devUserId: sharedActorId, baslangicCursorJson: ayarlar.nextCursorJson);
    return _Istemci(db, ayarlarDeposu, hlc, depo, dongu);
  }

  test('D3: A yazar -> B ceker -> B yazar -> A ceker -- iki DAR DOKUM bayt-ozdes', () async {
    final a = await istemciKur('a');
    final b = await istemciKur('b');

    await a.depo.ekle('G6 ortak gorev');
    await a.dongu.turCalistir();
    await b.dongu.cekmeTuruCalistir();

    final entityId = (await a.db.select(a.db.gorevler).get()).single.id;
    await b.depo.duzenle(entityId, 'G6 B degistirdi');
    await b.dongu.turCalistir();
    await a.dongu.cekmeTuruCalistir();

    final aDokum = jsonEncode(await _darDokum(a.db));
    final bDokum = jsonEncode(await _darDokum(b.db));
    expect(aDokum, bDokum, reason: 'dar dokumler bayt-ozdes olmali (K1)');

    await a.db.close();
    await b.db.close();
  });

  test('D3: B IKI AYRI turda cekiyor -- ikinci turda gelen ESKI (dusuk HLC) yazim, birinci turda uygulanmis YENI degeri EZMEZ (kalici meta)', () async {
    // Bu satir M24'un (UzakAlanDurumu yazimi kaldirilirsa "kor overwrite")
    // yakaladigi ayaktir: TEK bir changesUygula cagrisi icindeki iki yazim
    // bellekteki _GorevGuncellemesi ile dogru sıralanir (kalici metaya
    // gerek DUYMAZ); ancak İKİ AYRI cagrida (iki ayri pull round'u) gelen
    // yaziMLARIN dogru sirasi YALNIZ UzakAlanDurumu'na KALICI yazilmis
    // meta ile korunabilir.
    final a = await istemciKur('a');
    final b = await istemciKur('b');

    await a.depo.ekle('G6 meta-kalicilik testi');
    await a.dongu.turCalistir();
    await b.dongu.cekmeTuruCalistir();
    final entityId = (await a.db.select(a.db.gorevler).get()).single.id;

    Future<void> dogrudanYaz(String opId, String clientId, int wall, String deger) async {
      final govde = jsonEncode({
        'operationId': opId, 'clientId': clientId, 'entityId': entityId, 'actorId': sharedActorId,
        'entityType': 'Task', 'opHlc': {'wallMs': wall, 'counter': 0, 'clientId': clientId},
        'fields': {'title': {'value': deger, 'hlc': {'wallMs': wall, 'counter': 0, 'clientId': clientId}}},
      });
      await a.db.into(a.db.senkronKuyrugu).insert(
            SenkronKuyruguCompanion.insert(
              opId: opId, clientId: clientId, entityType: 'Task', entityId: entityId, govdeJson: govde,
              hlcWallMs: wall, hlcCounter: 0, olusturuldu: DateTime.now().toUtc(),
            ),
          );
    }

    // Yeni yazimlar entity YARATMA opundan (gercek DateTime.now() HLC'si)
    // DAHA YENI olmali -- taban SIMDIKI zamandan ileriye kurulur.
    final simdi = DateTime.now().toUtc().millisecondsSinceEpoch;
    final yuksekWall = simdi + 20000;
    final dusukWall = simdi + 10000;

    // Tur 1: YUKSEK wall -- A gonderir, B AYRI bir pull round'unda ceker.
    await dogrudanYaz('meta-kalicilik-yeni', 'client-meta-yeni', yuksekWall, 'YENI deger (yuksek wall)');
    await a.dongu.turCalistir();
    await b.dongu.cekmeTuruCalistir();
    final bIlkTur = (await (b.db.select(b.db.gorevler)..where((t) => t.id.equals(entityId))).getSingle()).baslik;
    expect(bIlkTur, 'YENI deger (yuksek wall)', reason: 'ilk turda yuksek-HLC yazim uygulanmali');

    // Tur 2: DUSUK wall (creation'dan yeni ama tur-1'den eski) -- AYRI bir
    // op, AYRI bir pull round'unda gelir (gec kalmis/sirasi bozuk bir
    // yazimi simule eder).
    await dogrudanYaz('meta-kalicilik-eski', 'client-meta-eski', dusukWall, 'ESKI deger (dusuk wall)');
    await a.dongu.turCalistir();
    await b.dongu.cekmeTuruCalistir();

    final bIkinciTur = (await (b.db.select(b.db.gorevler)..where((t) => t.id.equals(entityId))).getSingle()).baslik;
    expect(bIkinciTur, 'YENI deger (yuksek wall)', reason: 'kalici meta ikinci turdaki DUSUK-HLC yazimi reddetmeli -- ESKI deger asla gorunmemeli');

    await a.db.close();
    await b.db.close();
  });

  test('D3: ayni alana ESZAMANLI iki yazim (farkli clientId, ayni wallMs+counter) -- iki istemci AYNI kazanani secer', () async {
    final a = await istemciKur('a');
    final b = await istemciKur('b');

    await a.depo.ekle('G6 cakisma gorevi');
    await a.dongu.turCalistir();
    await b.dongu.cekmeTuruCalistir();
    final entityId = (await a.db.select(a.db.gorevler).get()).single.id;

    // Iki taraf da AYNI wallMs+counter ile (farkli clientId) dogrudan
    // kuyruga ELLE yazar -- gercek eszamanlilik cakismasini KESIN olarak
    // simule eder (zamanlamaya bagli degil).
    const ortakWall = 5000;
    const ortakCounter = 0;
    Future<void> cakisanYaz(_Istemci istemci, String opId, String clientId, String deger) async {
      final govde = jsonEncode({
        'operationId': opId, 'clientId': clientId, 'entityId': entityId, 'actorId': sharedActorId,
        'entityType': 'Task', 'opHlc': {'wallMs': ortakWall, 'counter': ortakCounter, 'clientId': clientId},
        'fields': {'title': {'value': deger, 'hlc': {'wallMs': ortakWall, 'counter': ortakCounter, 'clientId': clientId}}},
      });
      await istemci.db.into(istemci.db.senkronKuyrugu).insert(
            SenkronKuyruguCompanion.insert(
              opId: opId, clientId: clientId, entityType: 'Task', entityId: entityId, govdeJson: govde,
              hlcWallMs: ortakWall, hlcCounter: ortakCounter, olusturuldu: DateTime.now().toUtc(),
            ),
          );
    }

    await cakisanYaz(a, 'cakisan-op-a', 'client-cakisan-a', 'A tarafinin degeri');
    await cakisanYaz(b, 'cakisan-op-b', 'client-cakisan-b', 'B tarafinin degeri');
    await a.dongu.turCalistir();
    await b.dongu.turCalistir();
    await a.dongu.cekmeTuruCalistir();
    await b.dongu.cekmeTuruCalistir();

    final aBaslik = (await (a.db.select(a.db.gorevler)..where((t) => t.id.equals(entityId))).getSingle()).baslik;
    final bBaslik = (await (b.db.select(b.db.gorevler)..where((t) => t.id.equals(entityId))).getSingle()).baslik;
    expect(aBaslik, bBaslik, reason: 'iki istemci AYNI kazanani secmeli (normHex ordinal tie-break)');

    await a.db.close();
    await b.db.close();
  });

  test('D5: A\'nin bekleyen duzenlemesi varken A ceker -- cekmeden HEMEN SONRA A projeksiyonu A\'nin bekleyen degerini tasir', () async {
    final a = await istemciKur('a');
    final b = await istemciKur('b');

    await a.depo.ekle('G6 bekleyen testi');
    await a.dongu.turCalistir();
    await b.dongu.cekmeTuruCalistir();
    final entityId = (await a.db.select(a.db.gorevler).get()).single.id;

    // B onceden farkli bir deger yazip senkronlar (dusuk HLC).
    await b.depo.duzenle(entityId, 'G6 B eski deger');
    await b.dongu.turCalistir();

    // A YEREL duzenleme yapar (kuyrukta bekliyor) -- GONDERMEDEN once ceker.
    await a.depo.duzenle(entityId, 'G6 A bekleyen deger');
    await a.dongu.cekmeTuruCalistir();

    final aBaslik = (await (a.db.select(a.db.gorevler)..where((t) => t.id.equals(entityId))).getSingle()).baslik;
    expect(aBaslik, 'G6 A bekleyen deger', reason: 'A bekleyen kendi degerini gormeli (silinip geri gelmemeli)');

    await a.db.close();
    await b.db.close();
  });

  test('D0: ikinci tur -- sinceCursor DOLU gider (snapshot dalina donmez)', () async {
    final a = await istemciKur('a');
    await a.dongu.cekmeTuruCalistir(); // ilk tur -- sinceCursor null gider, nextCursor doner.
    final ayarSonrasi = await (a.db.select(a.db.ayarlar)..where((t) => t.id.equals(1))).getSingle();
    expect(ayarSonrasi.nextCursorJson, isNotNull);

    // Ikinci turu GOZLEMLEYEBILMEK icin sunucuyu ARAYA giren bir govde-kontrolcusu ile sarmalayalim.
    Map<String, Object?>? ikinciGovde;
    final gozlemciAgi = _GozlemciSahteSunucuAgi(sunucu, ayarSonrasi.devUserId, (govde) {
      ikinciGovde = govde;
    });
    final dongu2 = SenkronDongusu(
      db: a.db, agi: gozlemciAgi, ayarlarDeposu: a.ayarlarDeposu, hlc: a.hlc,
      clientId: (await a.ayarlarDeposu.yukleVeyaOlustur()).clientId, devUserId: ayarSonrasi.devUserId,
      baslangicCursorJson: ayarSonrasi.nextCursorJson,
    );
    await dongu2.cekmeTuruCalistir();
    expect(ikinciGovde, isNotNull);
    expect(ikinciGovde!['sinceCursor'], isNotNull, reason: 'ikinci tur sinceCursor DOLU gitmeli, snapshot dalina DONMEMELI');

    await a.db.close();
  });
}

class _GozlemciSahteSunucuAgi implements SenkronAgi {
  final SahteSunucu sunucu;
  final String actorId;
  final void Function(Map<String, Object?> govde) govdeGozlemci;
  _GozlemciSahteSunucuAgi(this.sunucu, this.actorId, this.govdeGozlemci);

  @override
  Future<SenkronSonucu> gonder(String govdeJson) async {
    final govde = jsonDecode(govdeJson) as Map<String, Object?>;
    govdeGozlemci(govde);
    final yanit = sunucu.istekIsle(govde, actorId: actorId);
    return SenkronBasarili(jsonEncode(yanit));
  }
}

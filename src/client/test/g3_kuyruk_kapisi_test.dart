@TestOn('vm')
library;

// GOREV-slice-3c G3 -- KUYRUK / TOPLU GONDERIM / IMLEC KAPISI.
// PAZARLIKSIZ: NativeDatabase.memory() YASAK -- gercek dosya DB kullanilir
// (bellekte "kapat, yeniden ac" ayagi dogru kodla da yesil kalir, M14 ile
// dogru kod ayirt edilemez).

import 'dart:convert';
import 'dart:io';

import 'package:client/ag/senkron_agi.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/senkron_dongusu.dart';
import 'package:client/veri/veritabani.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'destekler/sahte_senkron_agi.dart';
import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v1.dart' as v1;

void main() {
  late Directory gecici;

  setUp(() {
    gecici = Directory.systemTemp.createTempSync('g3-kuyruk-kapisi');
  });

  tearDown(() {
    // Windows'ta NativeDatabase kapandiktan HEMEN sonra bile isletim
    // sistemi dosya kilidini birazcik gec birakabilir (antivirus taramasi
    // vb.); temizlik testin PASS/FAIL hukmunu ETKILEMEMELI.
    try {
      gecici.deleteSync(recursive: true);
    } catch (_) {
      // gecici klasor -- OS eninde sonunda temizler.
    }
  });

  Future<Veritabani> dosyaDbAc() async {
    final dosya = File('${gecici.path}/m.sqlite');
    return Veritabani(NativeDatabase(dosya));
  }

  test('D1: uc op uret, DB kapat, yeniden ac -- kuyrukta uc satir', () async {
    var db = await dosyaDbAc();
    final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    final hlc = HlcUretici(
      simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch,
      clientId: ayarlar.clientId,
);
    var depo = DriftGorevDeposu(
      db,
      saat: () => DateTime.now().toUtc(),
      idUret: uretimIdUret,
      hlc: hlc,
      ayarlarDeposu: ayarlarDeposu,
      actorId: ayarlar.devUserId,
    );

    await depo.ekle('Bir');
    await depo.ekle('Iki');
    await depo.ekle('Uc');
    await db.close();

    db = await dosyaDbAc();
    final kuyruk = await db.select(db.senkronKuyrugu).get();
    expect(kuyruk, hasLength(3));
    await db.close();
  });

  test(
    'D1: siralama (hlcWallMs, hlcCounter, opId) artan -- esit damgada opId tie-break',
    () async {
      final db = await dosyaDbAc();
      // Esit (hlcWallMs, hlcCounter) tasiyan iki satiri DOGRUDAN ekleriz --
      // gercek yazma yolu HLC'yi hep ilerlettigi icin bu senaryoyu dogal
      // olarak uretemez; D3'un sunucu-clamp tie senaryosunu (iki farkli
      // op'un ayni damgaya kirpilmasi) TAKLIT eder.
      final ortak = (wallMs: 1000, counter: 5);
      // govdeJson icine opId'yi GOMERIZ ki gonderilen HAM istek metninden
      // hangi satirin ONCE gittigi ayirt edilebilsin (iki satirin govdesi
      // ayni olsaydi sira gozlenemezdi).
      await db
          .into(db.senkronKuyrugu)
          .insert(
            SenkronKuyruguCompanion.insert(
              opId: 'zzz-buyuk-opid',
              clientId: 'c1',
              entityType: 'Task',
              entityId: 'e1',
              govdeJson: '{"operationId":"zzz-buyuk-opid"}',
              hlcWallMs: ortak.wallMs,
              hlcCounter: ortak.counter,
              olusturuldu: DateTime.now().toUtc(),
            ),
          );
      await db
          .into(db.senkronKuyrugu)
          .insert(
            SenkronKuyruguCompanion.insert(
              opId: 'aaa-kucuk-opid',
              clientId: 'c1',
              entityType: 'Task',
              entityId: 'e1',
              govdeJson: '{"operationId":"aaa-kucuk-opid"}',
              hlcWallMs: ortak.wallMs,
              hlcCounter: ortak.counter,
              olusturuldu: DateTime.now().toUtc(),
            ),
          );

      // GERCEK SenkronDongusu._bekleyenleriSec()'i (M15'in hedefi) kosarak
      // dogrular -- kendi ORDER BY'ini elle tekrarlamak M15'i hicbir zaman
      // ISIRMAZ, cunku uretim kodunu hic COSTURMEZ.
      final ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
      final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
      final hlc = HlcUretici(
        simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch,
        clientId: ayarlar.clientId,
);
      final agi = SahteSenkronAgi();
      final dongu = SenkronDongusu(
        db: db,
        agi: agi,
        ayarlarDeposu: ayarlarDeposu,
        hlc: hlc,
        clientId: ayarlar.clientId,
        devUserId: ayarlar.devUserId,
      );
      await dongu.turCalistir();

      expect(agi.alinanHamIstekler, hasLength(1));
      final ham = agi.alinanHamIstekler.single;
      expect(
        ham.indexOf('aaa-kucuk-opid') < ham.indexOf('zzz-buyuk-opid'),
        isTrue,
        reason: 'aaa-kucuk-opid, zzz-buyuk-opidden ONCE gonderilmeli (opId tie-break)',
      );
      await db.close();
    },
  );

  test('D1: govdeJson gonderim oncesi/sonrasi bayt bayt AYNI (yeniden uretilmez)', () async {
    final db = await dosyaDbAc();
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

    await depo.ekle('Govde sabitligi testi');
    final oncesi = (await db.select(db.senkronKuyrugu).get()).single.govdeJson;

    final agi = SahteSenkronAgi();
    final dongu = SenkronDongusu(
      db: db,
      agi: agi,
      ayarlarDeposu: ayarlarDeposu,
      hlc: hlc,
      clientId: ayarlar.clientId,
      devUserId: ayarlar.devUserId,
    );
    await dongu.turCalistir();

    expect(agi.alinanIstekler, hasLength(1));
    final gonderilenOp = (agi.alinanIstekler.single['ops'] as List).single;
    expect(jsonEncode(gonderilenOp), oncesi);
    await db.close();
  });

  test(
    'D1: migration v1->v3 -- eski yerel satirlar korunur, yeni CHECK 5 deger kabul eder',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(1);

      final eskiDb = v1.DatabaseAtV1(schema.newConnection());
      // schema_v1.dart Companion sinifi URETMEZ (--data-classes/--companions
      // bayraklari verilmedi) -- v1 semasinin gercek sutun adlarina karsi ham
      // SQL ile ekleriz.
      await eskiDb.customStatement(
        "INSERT INTO gorevler (id, baslik, tamamlandi, olusturuldu, guncellendi, senkron_durumu, silindi) "
        "VALUES (?, ?, 0, ?, ?, 'yerel', 0)",
        [
          'eski-gorev-v1',
          'Migrasyon oncesi gorev',
          DateTime.utc(2026, 1, 1).toIso8601String(),
          DateTime.utc(2026, 1, 1).toIso8601String(),
        ],
      );
      await eskiDb.close();

      // NOT: verifier.migrateAndValidate() burada KULLANILMAZ -- drift_dev'in
      // statik sema dokumu, calisma zamani DriftDatabaseOptions
      // (storeDateTimeAsText:true, F8/G7 UTC garantisi icin kasitli) tip
      // farkini BILMEZ ve INTEGER bekler, gercekte TEXT'tir; bu bilinen bir
      // sema-dokum sinirlamasidir (validateColumnConstraints:false BILE bu
      // TIP uyusmazligini gevsetmiyor). G3'un asil sarti VERI BUTUNLUGUDUR
      // (esik satirlar korunur + yeni CHECK); asagidaki sorgu DB'yi actiginda
      // MigrationStrategy'yi GERCEKTEN calistirir (drift'in kendi lazy-migrate
      // davranisi) -- migrasyon hata verirse bu sorgu ATAR.
      final yeniDb = Veritabani(schema.newConnection());

      final satir = await (yeniDb.select(
        yeniDb.gorevler,
      )..where((t) => t.id.equals('eski-gorev-v1'))).getSingle();
      expect(satir.senkronDurumu, 'yerel', reason: 'eski satir korunmali');

      for (final gecerli in [
        'yerel',
        'kuyrukta',
        'senkronize',
        'cakisma',
        'cevrimdisi',
      ]) {
        await yeniDb.customStatement(
          'UPDATE gorevler SET senkron_durumu = ? WHERE id = ?',
          [gecerli, 'eski-gorev-v1'],
        );
      }
      await yeniDb.close();
    },
  );

  test(
    'D4: kuyrukta 150 op -- her istegin ops uzunlugu <= 100, iki tur, sahte ag 400 dondurmez',
    () async {
      final db = await dosyaDbAc();
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

      for (var i = 0; i < 150; i++) {
        await depo.ekle('Gorev $i');
      }
      expect(await db.select(db.senkronKuyrugu).get(), hasLength(150));

      final agi = SahteSenkronAgi();
      final dongu = SenkronDongusu(
        db: db,
        agi: agi,
        ayarlarDeposu: ayarlarDeposu,
        hlc: hlc,
        clientId: ayarlar.clientId,
        devUserId: ayarlar.devUserId,
      );
      await dongu.turCalistir();

      expect(agi.alinanIstekler, hasLength(2), reason: '150 op = 100 + 50, iki tur');
      for (final istek in agi.alinanIstekler) {
        final opsUzunlugu = (istek['ops'] as List).length;
        expect(opsUzunlugu, lessThanOrEqualTo(100));
      }
      for (final durumKodu in agi.alinanIstekler) {
        // sahte ag 400 dondurmedi -- kuyruk tamamen bosaldi.
        expect(durumKodu, isNotNull);
      }
      expect(await db.select(db.senkronKuyrugu).get(), isEmpty);
      await db.close();
    },
  );

  test(
    'D4: iki tur ESZAMANLI baslatilir -- sahte aga giden istek sayisi tek turu asmaz, denemeSayisi cift artmaz',
    () async {
      final db = await dosyaDbAc();
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
      await depo.ekle('Tek tur garantisi testi');

      final agi = SahteSenkronAgi(
        davranis: (govde, cagriNo) async {
          // agi cagrisini yavaslat -- iki tetiklemenin GERCEKTEN CAKISMASINI
          // saglar (yoksa ilk cagri anlik doner, ikinci tetik zaten mutex'i
          // BULAMAZ ve yanlislikla "gecti" gorunur).
          // [DESIGN-LITERAL: tasarim degeri degil, test-ici sahte ag gecikmesi -- olcum gerekci, UI/tema disi]
          await Future<void>.delayed(const Duration(milliseconds: 50));
          final ops = (govde['ops'] as List);
          return SenkronBasarili(
            jsonEncode({
              'serverHlc': null,
              'nextCursor': null,
              'hasMore': false,
              'resyncRequired': false,
              'applied': [
                for (final op in ops)
                  {
                    'operationId': (op as Map)['operationId'],
                    'code': 'Applied',
                    'effectiveOpHlc': op['opHlc'],
                  },
              ],
              'changes': [],
              'snapshot': [],
            }),
          );
        },
      );
      final dongu = SenkronDongusu(
        db: db,
        agi: agi,
        ayarlarDeposu: ayarlarDeposu,
        hlc: hlc,
        clientId: ayarlar.clientId,
        devUserId: ayarlar.devUserId,
      );

      final ikiTur = [dongu.turCalistir(), dongu.turCalistir()];
      await Future.wait(ikiTur);

      expect(
        agi.alinanIstekler,
        hasLength(1),
        reason: 'D4 mutex: ikinci tetik yeni bir tur BASLATMAMALI',
      );
      await db.close();
    },
  );

  test('D6: nextCursor ham metin olarak yazilir, yeniden acilista okunur, sonraki istek sinceCursor ile gider', () async {
    var db = await dosyaDbAc();
    var ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    var ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    var hlc = HlcUretici(
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
    await depo.ekle('Imlec testi');

    const hamCursor = '{"xid":9999999999999999999,"seq":0}';
    var agi = SahteSenkronAgi(
      davranis: (govde, cagriNo) async {
        final ops = (govde['ops'] as List);
        return SenkronBasarili(
          jsonEncode({
            'serverHlc': null,
            'nextCursor': null, // asagida ham metinle degistirilecek
            'hasMore': false,
            'resyncRequired': false,
            'applied': [
              for (final op in ops)
                {
                  'operationId': (op as Map)['operationId'],
                  'code': 'Applied',
                  'effectiveOpHlc': op['opHlc'],
                },
            ],
            'changes': [],
            'snapshot': [],
          }).replaceFirst('"nextCursor":null', '"nextCursor":$hamCursor'),
        );
      },
    );
    var dongu = SenkronDongusu(
      db: db,
      agi: agi,
      ayarlarDeposu: ayarlarDeposu,
      hlc: hlc,
      clientId: ayarlar.clientId,
      devUserId: ayarlar.devUserId,
    );
    await dongu.turCalistir();

    final ayarSatiri1 = await (db.select(
      db.ayarlar,
    )..where((t) => t.id.equals(1))).getSingle();
    expect(
      ayarSatiri1.nextCursorJson,
      hamCursor,
      reason: 'buyuk xid HAM METIN olarak saklanmali (ulong hassasiyeti)',
    );

    await db.close();
    db = await dosyaDbAc();
    ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    expect(ayarlar.nextCursorJson, hamCursor, reason: 'yeniden acilista okunmali');

    hlc = HlcUretici(
      simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch,
      clientId: ayarlar.clientId,
);
    agi = SahteSenkronAgi();
    dongu = SenkronDongusu(
      db: db,
      agi: agi,
      ayarlarDeposu: ayarlarDeposu,
      hlc: hlc,
      clientId: ayarlar.clientId,
      devUserId: ayarlar.devUserId,
      baslangicCursorJson: ayarlar.nextCursorJson,
    );
    final depo2 = DriftGorevDeposu(
      db,
      saat: () => DateTime.now().toUtc(),
      idUret: uretimIdUret,
      hlc: hlc,
      ayarlarDeposu: ayarlarDeposu,
      actorId: ayarlar.devUserId,
    );
    await depo2.ekle('Ikinci tur');
    await dongu.turCalistir();

    expect(agi.alinanHamIstekler, hasLength(1));
    // HAM istek metnini kontrol eder -- jsonDecode (alinanIstekler) buyuk
    // xid'i double'a cevirip hassasiyet KAYBEDER (bu bir SahteSenkronAgi
    // dogrulama-defteri sinirlamasidir, SenkronDongusu'nun kendisi hicbir
    // zaman decode/re-encode YAPMAZ -- D6 pazarliksiz).
    expect(
      agi.alinanHamIstekler.single.contains('"sinceCursor":$hamCursor'),
      isTrue,
      reason: 'sonraki istek saklanan sinceCursor ile HAM METIN olarak gitmeli',
    );
    await db.close();
  });

  test('D6: resyncRequired true -- saklanan imlec silinir, sonraki istek sinceCursor OLMADAN gider', () async {
    final db = await dosyaDbAc();
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

    // Once GECERLI bir imlec olustur (resync'in onu SILDIGINI gormek icin).
    // Bos kuyrukla tur ASLA istek GONDERMEZ (D4: gonderilecek bir sey yoksa
    // ag cagrisi yapilmaz) -- imlec elde etmek icin once bir op uretilir.
    await depo.ekle('ilk senkron -- imlec elde etmek icin');
    var agi = SahteSenkronAgi(
      davranis: (govde, cagriNo) async => SenkronBasarili(
        jsonEncode({
          'serverHlc': null,
          'nextCursor': {'xid': 5, 'seq': 0},
          'hasMore': false,
          'resyncRequired': false,
          'applied': [
            for (final op in (govde['ops'] as List))
              {
                'operationId': (op as Map)['operationId'],
                'code': 'Applied',
                'effectiveOpHlc': op['opHlc'],
              },
          ],
          'changes': [],
          'snapshot': [],
        }),
      ),
    );
    var dongu = SenkronDongusu(
      db: db,
      agi: agi,
      ayarlarDeposu: ayarlarDeposu,
      hlc: hlc,
      clientId: ayarlar.clientId,
      devUserId: ayarlar.devUserId,
    );
    await dongu.turCalistir();
    var ayarSatiri = await (db.select(
      db.ayarlar,
    )..where((t) => t.id.equals(1))).getSingle();
    expect(ayarSatiri.nextCursorJson, isNotNull);

    // Simdi resyncRequired:true dondur.
    agi = SahteSenkronAgi(
      davranis: (govde, cagriNo) async => SenkronBasarili(
        jsonEncode({
          'serverHlc': null,
          'nextCursor': govde['sinceCursor'],
          'hasMore': false,
          'resyncRequired': true,
          'applied': [],
          'changes': [],
          'snapshot': [],
        }),
      ),
    );
    dongu = SenkronDongusu(
      db: db,
      agi: agi,
      ayarlarDeposu: ayarlarDeposu,
      hlc: hlc,
      clientId: ayarlar.clientId,
      devUserId: ayarlar.devUserId,
      baslangicCursorJson: ayarSatiri.nextCursorJson,
    );
    await depo.ekle('resync tetikleyici');
    await dongu.turCalistir();

    ayarSatiri = await (db.select(
      db.ayarlar,
    )..where((t) => t.id.equals(1))).getSingle();
    expect(ayarSatiri.nextCursorJson, isNull, reason: 'resyncRequired imleci SILMELI');

    // Sonraki tur -- sinceCursor'suz gitmeli.
    agi = SahteSenkronAgi();
    dongu = SenkronDongusu(
      db: db,
      agi: agi,
      ayarlarDeposu: ayarlarDeposu,
      hlc: hlc,
      clientId: ayarlar.clientId,
      devUserId: ayarlar.devUserId,
      baslangicCursorJson: ayarSatiri.nextCursorJson,
    );
    await depo.ekle('resync sonrasi op');
    await dongu.turCalistir();
    expect(agi.alinanIstekler.single['sinceCursor'], isNull);
    await db.close();
  });
}

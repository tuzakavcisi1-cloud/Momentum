// GOREV-slice-3c G5 -- KARANTINA / ROZET / YANIT SINIFI KAPISI (sahte ag).

import 'dart:convert';

import 'package:client/ag/senkron_agi.dart';
import 'package:client/sunum/cakisma_rozeti.dart';
import 'package:client/sunum/gorev_satiri.dart';
import 'package:client/sunum/senkron_rozeti.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/senkron_dongusu.dart';
import 'package:client/veri/veritabani.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'destekler/sahte_senkron_agi.dart';

SenkronSonucu _uygulananYanit(Map<String, Object?> govde, {String kod = 'Applied'}) {
  final ops = (govde['ops'] as List).cast<Map<String, Object?>>();
  return SenkronBasarili(
    jsonEncode({
      'serverHlc': null,
      'nextCursor': null,
      'hasMore': false,
      'resyncRequired': false,
      'applied': [
        for (final op in ops)
          {
            'operationId': op['operationId'],
            'code': kod,
            'effectiveOpHlc': kod == 'Applied' ? op['opHlc'] : null,
          },
      ],
      'changes': [],
      'snapshot': [],
    }),
  );
}

void main() {
  late Veritabani db;
  late AyarlarDeposu ayarlarDeposu;
  late DriftGorevDeposu depo;
  late HlcUretici hlc;
  late String clientId;
  late String devUserId;

  setUp(() async {
    db = Veritabani(NativeDatabase.memory());
    ayarlarDeposu = AyarlarDeposu(db, idUret: uretimIdUret);
    final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();
    clientId = ayarlar.clientId;
    devUserId = ayarlar.devUserId;
    hlc = HlcUretici(
      simdiMs: () => DateTime.now().toUtc().millisecondsSinceEpoch,
      clientId: clientId,
    );
    depo = DriftGorevDeposu(
      db,
      saat: () => DateTime.now().toUtc(),
      idUret: uretimIdUret,
      hlc: hlc,
      ayarlarDeposu: ayarlarDeposu,
      actorId: ayarlar.devUserId,
    );
  });

  tearDown(() async => db.close());

  SenkronDongusu donguOlustur(SahteSenkronAgi agi) => SenkronDongusu(
    db: db,
    agi: agi,
    ayarlarDeposu: ayarlarDeposu,
    hlc: hlc,
    clientId: clientId,
    devUserId: devUserId,
  );

  test('D5: Duplicate -- Applied ile AYNI muamele (idempotens): satir silinir, senkronize olur', () async {
    await depo.ekle('idempotens testi');
    final agi = SahteSenkronAgi(
      davranis: (govde, cagriNo) async => _uygulananYanit(govde, kod: 'Duplicate'),
    );
    await donguOlustur(agi).turCalistir();

    final kuyruk = await db.select(db.senkronKuyrugu).get();
    expect(kuyruk, isEmpty, reason: 'Duplicate idempotenttir -- satir SILINMELI');
    final gorev = (await db.select(db.gorevler).get()).single;
    expect(gorev.senkronDurumu, 'senkronize');
  });

  test('D5: RejectedRegistryViolation -- zehirli, SILINMEZ, sonHataKodu yazilir', () async {
    await depo.ekle('kayit ihlali testi');
    final agi = SahteSenkronAgi(
      davranis: (govde, cagriNo) async =>
          _uygulananYanit(govde, kod: 'RejectedRegistryViolation'),
    );
    await donguOlustur(agi).turCalistir();

    final kuyruk = await db.select(db.senkronKuyrugu).get();
    expect(kuyruk, hasLength(1));
    expect(kuyruk.single.durum, 'zehirli');
    expect(kuyruk.single.sonHataKodu, 'RejectedRegistryViolation');

    final gorev = (await db.select(db.gorevler).get()).single;
    expect(gorev.senkronDurumu, 'cakisma');
  });

  test('D5: zehirli + iki saglam op -- saglamlar GONDERILIR, kuyruk tikanmaz', () async {
    await depo.ekle('zehirli olacak');
    final zehirliId = (await db.select(db.gorevler).get()).single.id;
    await depo.ekle('saglam bir');
    await depo.ekle('saglam iki');

    final agi = SahteSenkronAgi(
      davranis: (govde, cagriNo) async {
        final ops = (govde['ops'] as List).cast<Map<String, Object?>>();
        return SenkronBasarili(
          jsonEncode({
            'serverHlc': null,
            'nextCursor': null,
            'hasMore': false,
            'resyncRequired': false,
            'applied': [
              for (final op in ops)
                {
                  'operationId': op['operationId'],
                  'code': op['entityId'] == zehirliId ? 'RejectedInvalid' : 'Applied',
                  'effectiveOpHlc': op['entityId'] == zehirliId ? null : op['opHlc'],
                },
            ],
            'changes': [],
            'snapshot': [],
          }),
        );
      },
    );
    await donguOlustur(agi).turCalistir();

    final kuyruk = await db.select(db.senkronKuyrugu).get();
    expect(kuyruk, hasLength(1), reason: 'yalniz zehirli op kalmali');
    expect(kuyruk.single.entityId, zehirliId);

    final saglamGorevler = (await db.select(db.gorevler).get())
        .where((g) => g.id != zehirliId);
    for (final g in saglamGorevler) {
      expect(g.senkronDurumu, 'senkronize');
    }
  });

  test('D5: zehirli op sonraki turda SECILMEZ, denemeSayisi artmaz', () async {
    await depo.ekle('zehirli kalici');
    final agi1 = SahteSenkronAgi(
      davranis: (govde, cagriNo) async => _uygulananYanit(govde, kod: 'RejectedAbsurdHlc'),
    );
    // .timeout() SAVUNMA AMACLI (M26 KANITI, oturum 32): zehirli satir
    // secilebilir kalirsa (M26) ayni op SONSUZA DEK yeniden gonderilir --
    // zehirli-disi bir dongu de zaten "SenkronBasarili sonrasi return YOK"
    // kuralindan dolayi TEK turda birden fazla parti dener; koruma olmadan
    // bu senaryo dakikalarca surebilir/donebilir. Zaman asimi da gecerli
    // bir KIRMIZI sonuctur (hicbir zaman ASILMAMASI gereken bir cagri hic
    // bitmiyor demektir).
    await donguOlustur(
      agi1,
    ).turCalistir().timeout(const Duration(seconds: 5));
    final ilkKuyruk = (await db.select(db.senkronKuyrugu).get()).single;
    expect(ilkKuyruk.durum, 'zehirli');
    expect(ilkKuyruk.denemeSayisi, 0);

    final agi2 = SahteSenkronAgi(); // varsayilan: Applied doner (ama secilmemeli)
    await donguOlustur(
      agi2,
    ).turCalistir().timeout(const Duration(seconds: 5));

    expect(agi2.alinanIstekler, isEmpty, reason: 'zehirli satir hicbir bekleyen sec sorgusuna girmemeli');
    final ikinciKuyruk = (await db.select(db.senkronKuyrugu).get()).single;
    expect(ikinciKuyruk.durum, 'zehirli');
    expect(ikinciKuyruk.denemeSayisi, 0, reason: 'secilmedi -- denemeSayisi ARTMAMALI');
  });

  test('D5: taninmayan code ("Foo") -- zehirli, sonHataKodu == "Foo"', () async {
    await depo.ekle('bilinmeyen kod testi');
    final agi = SahteSenkronAgi(davranis: (govde, cagriNo) async => _uygulananYanit(govde, kod: 'Foo'));
    await donguOlustur(agi).turCalistir();

    final satir = (await db.select(db.senkronKuyrugu).get()).single;
    expect(satir.durum, 'zehirli');
    expect(satir.sonHataKodu, 'Foo');
  });

  test(
    'D5: cakisma kilidi -- op1(Applied) -> op2(Rejected) -> op3(Applied) rozet cakismada KALIR',
    () async {
      await depo.ekle('cakisma kilidi');
      final gorevId = (await db.select(db.gorevler).get()).single.id;

      var tur = 0;
      final agi = SahteSenkronAgi(
        davranis: (govde, cagriNo) async {
          tur++;
          return _uygulananYanit(govde, kod: tur == 2 ? 'RejectedInvalid' : 'Applied');
        },
      );
      final dongu = donguOlustur(agi);

      await dongu.turCalistir(); // op1: Applied
      expect((await db.select(db.gorevler).get()).single.senkronDurumu, 'senkronize');

      await depo.duzenle(gorevId, 'v2');
      await dongu.turCalistir(); // op2: Rejected
      expect((await db.select(db.gorevler).get()).single.senkronDurumu, 'cakisma');

      await depo.duzenle(gorevId, 'v3');
      await dongu.turCalistir(); // op3: Applied
      expect(
        (await db.select(db.gorevler).get()).single.senkronDurumu,
        'cakisma',
        reason: 'D5 PAZARLIKSIZ: zehirli satir dururken senkronize olamaz',
      );
    },
  );

  test('D5: rozet dikisi -- cakisma => GorevSatiri.cakismaVarMi==true, CakismaRozeti gorunur', (
  ) async {
    final (durum, cakismaVarMi) = rozetDikisi(
      'cakisma',
      ucusta: 0,
      bekleyen: 0,
      zehirli: 0,
    );
    expect(durum, SenkronDurumTuru.yerel);
    expect(cakismaVarMi, isTrue);
  });

  testWidgets(
    'D5: rozet dikisi widget -- cakisma rozeti gorevSatirinda CakismaRozeti render eder',
    (tester) async {
      // NOT: GorevListesiEkrani (gercek Drift Stream + SenkronDongusu) BURADA
      // KULLANILMAZ -- NativeDatabase'in ic Timer'i AutomatedTestWidgetsFlutterBinding'in
      // "widget agaci elden cikarildiktan sonra bekleyen Timer olamaz" kuralini
      // ihlal ediyor (ayri, DB'siz bir sorun; G5'in kapsami degil). rozetDikisi('cakisma')
      // -> (yerel,true) donusumu yukaridaki testte zaten dogrulandi; burada YALNIZ
      // o CIKTI ile GorevSatiri'nin CakismaRozeti gosterdigini kontrol eder.
      final (senkronDurumu, cakismaVarMi) = rozetDikisi(
        'cakisma',
        ucusta: 0,
        bekleyen: 0,
        zehirli: 0,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GorevSatiri(
              gorev: Gorev(
                id: 'g1',
                baslik: 'widget rozet testi',
                tamamlandi: false,
                olusturuldu: DateTime.utc(2026, 1, 1),
                guncellendi: DateTime.utc(2026, 1, 1),
                senkronDurumu: 'cakisma',
                silindi: false,
              ),
              onTamamlaDegisti: (_) {},
              senkronDurumu: senkronDurumu,
              cakismaVarMi: cakismaVarMi,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CakismaRozeti), findsOneWidget);
    },
  );

  test('D9: HTTP 400 -- tur DURUR, denemeSayisi artmaz, satirlar bekliyor', () async {
    await depo.ekle('http 400 testi');
    final agi = SahteSenkronAgi(
      davranis: (govde, cagriNo) async => const SenkronHttpHatasi(400),
    );
    await donguOlustur(agi).turCalistir();

    final satir = (await db.select(db.senkronKuyrugu).get()).single;
    expect(satir.durum, 'bekliyor');
    expect(satir.denemeSayisi, 0);
    final gorev = (await db.select(db.gorevler).get()).single;
    expect(gorev.senkronDurumu, 'cakisma');
  });

  test(
    'GOREV-A11 D-A11-4: HTTP 500 / zaman asimi -- bekliyor, denemeSayisi ARTMAZ, rozet cevrimdisi',
    () async {
      // [K116] Bu testin ONCEKI hali (A11 ONCESI) denemeSayisi++ bekliyordu
      // -- D-A11-4 tam da BUNU daraltti: taşıma hatasi/5xx sunucuya HIC
      // ulasmamis/degerlendirilmemistir, D-A11-2 cizelgesiyle 9. basarisizlik
      // ~5 dk'da gelip satiri KALICI zehirlerdi (duzeltme, duzeltmediginden
      // KOTU olurdu). 401-disi-4xx zaten hic artirmiyordu (asagidaki 400
      // testi); 401 bu dilimin KAPSAMI DISINDA, eski davranisi KORUR.
      await depo.ekle('http 500 testi');
      final agi500 = SahteSenkronAgi(
        davranis: (govde, cagriNo) async => const SenkronHttpHatasi(500),
      );
      await donguOlustur(agi500).turCalistir();
      var satir = (await db.select(db.senkronKuyrugu).get()).single;
      expect(satir.durum, 'bekliyor');
      expect(satir.denemeSayisi, 0);
      var gorev = (await db.select(db.gorevler).get()).single;
      expect(gorev.senkronDurumu, 'cevrimdisi');

      final agiAg = SahteSenkronAgi(
        davranis: (govde, cagriNo) async => SenkronAgHatasi(Exception('zaman asimi')),
      );
      await donguOlustur(agiAg).turCalistir();
      satir = (await db.select(db.senkronKuyrugu).get()).single;
      expect(satir.durum, 'bekliyor');
      expect(satir.denemeSayisi, 0, reason: 'D-A11-4: tasima hatasi da ARTIRMAZ');
      gorev = (await db.select(db.gorevler).get()).single;
      expect(gorev.senkronDurumu, 'cevrimdisi');
    },
  );

  test('D9: denemeSayisi 9a ulasir -- durum=zehirli, sonHataKodu=deneme-tavani (401, D-A11-4 disi)', () async {
    // [K116] Onceden 503 kullaniyordu; D-A11-4 5xx'i bu sayactan MUAF
    // tuttugu icin artik BURADA 401 kullanilir -- 401 D-A11-4'un KAPSAMI
    // DISINDA oldugu icin eski (artiran) davranisi hala tasir ve deneme-tavani
    // mekanizmasinin CANLI kaldigini kanitlar.
    await depo.ekle('deneme tavani testi');
    final agi = SahteSenkronAgi(
      davranis: (govde, cagriNo) async => const SenkronHttpHatasi(401),
    );
    final dongu = donguOlustur(agi);
    for (var i = 0; i < 9; i++) {
      await dongu.turCalistir();
    }

    final satir = (await db.select(db.senkronKuyrugu).get()).single;
    expect(satir.denemeSayisi, 9);
    expect(satir.durum, 'zehirli');
    expect(satir.sonHataKodu, 'deneme-tavani');
    final gorev = (await db.select(db.gorevler).get()).single;
    expect(gorev.senkronDurumu, 'cakisma');
  });
}

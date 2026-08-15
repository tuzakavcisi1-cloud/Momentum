@TestOn('vm')
library;

// GOREV-R10 -- G11 ROZET TURETME KAPISI (K75). Rozet artik KOLONDAN DEGIL
// KUYRUKTAN turetilir (D1-D9, GOREV-R10-rozet-turetme.md §2). On iki ayak
// (A1-A12) D-kurallarinin makine-okunur karsiligidir; hicbiri emulator/koşan
// uygulama ISTEMEZ (K53/3: hepsi statik/widget sinifi, mutant tavansiz).
//
// PAZARLIKSIZ: pumpAndSettle KULLANILMAZ -- 'kuyrukta' durumunun _DonenOk'u
// Timer.periodic ile sonsuz kare planlar (senkron_rozeti.dart). Widget
// ayaklari tester.pump() kullanir.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:client/ag/senkron_agi.dart';
import 'package:client/design/metinler.dart';
import 'package:client/sunum/cakisma_rozeti.dart';
import 'package:client/sunum/gorev_satiri.dart';
import 'package:client/sunum/senkron_rozeti.dart';
import 'package:client/veri/ayarlar_deposu.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:client/veri/hlc.dart';
import 'package:client/veri/senkron_dongusu.dart';
import 'package:client/veri/veritabani.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'destekler/sahte_senkron_agi.dart';

/// g5_karantina_kapisi_test.dart'taki `_uygulananYanit`in yerel kopyasi --
/// dosyalar arasi PRIVATE sembol paylasilamaz.
SenkronSonucu _basariliYanit(Map<String, Object?> govde, {String kod = 'Applied'}) {
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

/// a11y_kapisi_test.dart'taki `_duyurulariYakala`nin yerel kopyasi.
List<String> _duyurulariYakala(WidgetTester tester) {
  final yakalanan = <String>[];
  tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
    SystemChannels.accessibility,
    (dynamic mesaj) async {
      final harita = mesaj as Map;
      if (harita['type'] == 'announce') {
        final veri = harita['data'] as Map;
        yakalanan.add(veri['message'] as String);
      }
      return null;
    },
  );
  return yakalanan;
}

/// G11-A11 icin: SenkronRozeti'nin `durum`unu test icinden degistirebilen
/// sarmalayici -- ayni State'in didUpdateWidget'i gercekten koşsun diye.
class _DurumSarmalayici extends StatefulWidget {
  final SenkronDurumTuru ilkDurum;
  const _DurumSarmalayici({required this.ilkDurum});

  @override
  State<_DurumSarmalayici> createState() => _DurumSarmalayiciState();
}

class _DurumSarmalayiciState extends State<_DurumSarmalayici> {
  late SenkronDurumTuru _durum = widget.ilkDurum;

  void durumDegistir(SenkronDurumTuru yeni) => setState(() => _durum = yeni);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: SenkronRozeti(durum: _durum)));
  }
}

// GOREV-R10 OLCULMUS ORTAM KISITI: `JoinedSelectStatement.watch()` (D6
// join'i) stream iptalinde SIFIR sureli bir Timer planliyor
// (`StreamQueryStore.markAsClosed`) ve bu dosyada BIRDEN FAZLA widget testi
// `GorevListesiEkrani` (gercek DriftGorevDeposu + join) ile ard arda
// calisirsa ikinci `pumpWidget()` cagrisi SONSUZA DEK askida kaliyor --
// olculdu (`debug_a9a10_v2.log`, izole print izleriyle). Bu yuzden G11-A7/
// A9/A10 gercek depo+GorevListesiEkrani KOMBINASYONUNU BURADA KULLANMAZ:
// D6/D7'nin VERI tarafi gercek DriftGorevDeposu ile (`.first`), D7'nin
// RENDER tarafi izole `GorevSatiri` ile ayrilarak olculur -- G10'un AYAK5/
// AYAK6'daki (tek widget testi, ayni dosyada tek basina) gercek depo +
// GorevListesiEkrani deseni bundan ETKILENMEZ.

/// Sinif govdesinden ilk dengeli `{ ... }` blogunu kesip doner (basit
/// derinlik sayaci -- G11-A12'nin statik SAF/alan taramasi icin yeterli).
String _govdeCikar(String kaynak, int fonksiyonAdiSonu) {
  final parametreSonu = kaynak.indexOf(')', fonksiyonAdiSonu);
  final govdeBaslangic = kaynak.indexOf('{', parametreSonu);
  var derinlik = 0;
  for (var i = govdeBaslangic; i < kaynak.length; i++) {
    if (kaynak[i] == '{') derinlik++;
    if (kaynak[i] == '}') {
      derinlik--;
      if (derinlik == 0) return kaynak.substring(govdeBaslangic, i + 1);
    }
  }
  throw StateError('govde kapanisi bulunamadi ($fonksiyonAdiSonu)');
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

  SenkronDongusu donguOlustur(SenkronAgi agi) => SenkronDongusu(
    db: db,
    agi: agi,
    ayarlarDeposu: ayarlarDeposu,
    hlc: hlc,
    clientId: clientId,
    devUserId: devUserId,
  );

  // ============ G11-A1 -- rozetDikisi SAF birim tablosu (D2) ============

  test('G11-A1: rozetDikisi -- dort taban kuralinin her satiri ayri expect (D2)', () {
    // kural 1: ucusta>0 => kuyrukta, K ne olursa olsun kazanir.
    expect(
      rozetDikisi('yerel', ucusta: 1, bekleyen: 0, zehirli: 0).$1,
      SenkronDurumTuru.kuyrukta,
    );
    expect(
      rozetDikisi('senkronize', ucusta: 2, bekleyen: 5, zehirli: 1).$1,
      SenkronDurumTuru.kuyrukta,
    );

    // kural 2: ucusta=0, bekleyen>0, K=='cevrimdisi' => cevrimdisi.
    expect(
      rozetDikisi('cevrimdisi', ucusta: 0, bekleyen: 1, zehirli: 0).$1,
      SenkronDurumTuru.cevrimdisi,
    );

    // kural 3: ucusta=0, bekleyen>0, K != 'cevrimdisi' VE K != 'yerel' =>
    // gonderilmemis (YENI). K != 'yerel' siniri BUILD BULGUSU (rozetDikisi
    // doc yorumuna bkz.): satır sunucuda VAR olmasi (DESIGN.md v2 §4)
    // gerekir, hic senkronlanmamis bir satir (K='yerel') bunu SAGLAMAZ --
    // ölçüldü: bu siniri olmadan g10 AYAK6 ("taze görev -> Yalnızca bu
    // cihazda") KIRILIYORDU.
    expect(
      rozetDikisi('senkronize', ucusta: 0, bekleyen: 1, zehirli: 0).$1,
      SenkronDurumTuru.gonderilmemis,
    );
    expect(
      rozetDikisi('cakisma', ucusta: 0, bekleyen: 1, zehirli: 0).$1,
      SenkronDurumTuru.gonderilmemis,
      reason: 'K=cakisma da rule 3e girer -- G11-A7 bilesik senaryosunun temeli',
    );
    expect(
      rozetDikisi('yerel', ucusta: 0, bekleyen: 3, zehirli: 0).$1,
      SenkronDurumTuru.yerel,
      reason: 'K=yerel ISTISNA -- hic senkronlanmamis satir sunucuda YOK, gonderilmemis YANLIS OLURDU',
    );

    // kural 4: ucusta=0, bekleyen=0 => K eslemesi.
    expect(rozetDikisi('yerel', ucusta: 0, bekleyen: 0, zehirli: 0).$1, SenkronDurumTuru.yerel);
    expect(
      rozetDikisi('senkronize', ucusta: 0, bekleyen: 0, zehirli: 0).$1,
      SenkronDurumTuru.senkronize,
    );
    expect(
      rozetDikisi('cevrimdisi', ucusta: 0, bekleyen: 0, zehirli: 0).$1,
      SenkronDurumTuru.cevrimdisi,
    );
    expect(rozetDikisi('cakisma', ucusta: 0, bekleyen: 0, zehirli: 0).$1, SenkronDurumTuru.yerel);
    expect(
      rozetDikisi('kuyrukta', ucusta: 0, bekleyen: 0, zehirli: 0).$1,
      SenkronDurumTuru.kuyrukta,
    );
  });

  // ============ G11-A2 -- taninmayan K firlatir (D3) ============

  test('G11-A2: taninmayan senkronDurumu ArgumentError firlatir (D3)', () {
    expect(
      () => rozetDikisi('bilinmeyen-deger', ucusta: 0, bekleyen: 0, zehirli: 0),
      throwsArgumentError,
    );
    // D3 PAZARLIKSIZ: K ONCE dogrulanir -- kural 1 (ucusta>0) kisa devre
    // yapsa bile taninmayan K hala FIRLAMALI.
    expect(
      () => rozetDikisi('bilinmeyen-deger', ucusta: 7, bekleyen: 0, zehirli: 0),
      throwsArgumentError,
    );
  });

  // ============ G11-A3 -- R10 ASIL SENARYO (D2) ============

  test('G11-A3: R10 ASIL SENARYO -- senkronize satir duzenle() ile gonderilmemis olur', () async {
    await depo.ekle('R10 senaryosu');
    final id = (await db.select(db.gorevler).get()).single.id;

    // Gercek uretim yolu: basarili itme turu satiri 'senkronize' yapar
    // (senkron_dongusu.dart _tekSonucIsle -> _rozetYaz).
    await donguOlustur(SahteSenkronAgi()).turCalistir();
    expect((await db.select(db.gorevler).get()).single.senkronDurumu, 'senkronize');

    // R10 kusuru: duzenle() KOLONA DOKUNMAZ (K75 kirmizi cizgi) -- yalniz
    // kuyruga yeni bir 'bekliyor' op yazar.
    await depo.duzenle(id, 'R10 senaryosu v2');

    final gorunum = (await depo.gorevlerGorunur().first).single;
    expect(gorunum.senkronDurumu, SenkronDurumTuru.gonderilmemis);
    expect(
      gorunum.gorev.senkronDurumu,
      'senkronize',
      reason: 'K75 PAZARLIKSIZ: kolon degismedi -- rozet KUYRUKTAN turedi',
    );
  });

  // ============ G11-A4 -- IKI GOREV, entityId izolasyonu (D6) ============

  test('G11-A4: IKI GOREV -- Anin bekleyen opu var, Bnin yok (D6 entityId izolasyonu)', () async {
    await depo.ekle('Gorev A');
    await depo.ekle('Gorev B');
    final satirlar = await db.select(db.gorevler).get();
    final idA = satirlar.firstWhere((g) => g.baslik == 'Gorev A').id;
    final idB = satirlar.firstWhere((g) => g.baslik == 'Gorev B').id;

    await donguOlustur(SahteSenkronAgi()).turCalistir(); // ikisi de senkronize olur.

    await depo.duzenle(idA, 'Gorev A v2'); // YALNIZ A icin bekleyen op.

    final gorunumler = await depo.gorevlerGorunur().first;
    final gorunumA = gorunumler.firstWhere((g) => g.gorev.id == idA);
    final gorunumB = gorunumler.firstWhere((g) => g.gorev.id == idB);

    expect(
      gorunumA.senkronDurumu,
      SenkronDurumTuru.gonderilmemis,
      reason: 'A: kendi bekleyen opu var',
    );
    expect(
      gorunumB.senkronDurumu,
      SenkronDurumTuru.senkronize,
      reason: 'B: hicbir bekleyen opu yok -- Anin sayimi Bye SIZMAMALI',
    );
  });

  // ============ G11-A5 -- YALNIZ KUYRUGA YAZ, akis yeniden yayin (D6) ============

  test(
    'G11-A5: YALNIZ KUYRUGA YAZ -- gonderildiKurtar() sonrasi akis yeniden yayin yapar (D6 readsFrom)',
    () async {
      await depo.ekle('Kurtarma senaryosu');
      final id = (await db.select(db.gorevler).get()).single.id;
      // Onceki oturum cokmus gibi: kuyruk satiri 'gonderildi'de takili
      // kaldi (gercek yol: senkron_dongusu.dart bir tur cevap BEKLERKEN
      // uygulama kapanirsa satir bu durumda kalir).
      await (db.update(
        db.senkronKuyrugu,
      )..where((t) => t.entityId.equals(id))).write(const SenkronKuyruguCompanion(durum: Value('gonderildi')));

      final iterator = StreamIterator(depo.gorevlerGorunur());
      // expect() ortada FIRLARSA asagidaki iterator.cancel() hic calismaz --
      // acik abonelik kalirsa bir sonraki testin tearDown'i (db.close())
      // tikanip 30s test-timeout'una CARPAR (olculdu, M48 kirmizi kosumu).
      // addTearDown HER ZAMAN (basari/basarisizlik farketmeksizin) calisir.
      addTearDown(iterator.cancel);
      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current.single.senkronDurumu, SenkronDurumTuru.kuyrukta);

      // gonderildiKurtar() YALNIZ senkron_kuyrugu tablosuna yazar, gorevler'e
      // HIC dokunmaz -- D6'nin readsFrom gerekliligi tam bunun icin: bu
      // yazim yalniz gorevler'i izleyen bir akisa GORUNMEZ olurdu.
      await donguOlustur(SahteSenkronAgi()).gonderildiKurtar();

      expect(await iterator.moveNext(), isTrue);
      expect(
        iterator.current.single.senkronDurumu,
        // K bu senaryoda 'yerel' KALIR (gorev hic senkronlanmadi) -- D2
        // kural 3'un K!='yerel' istisnasi (rozetDikisi build bulgusu) burada
        // da gecerli, taban rule 4'e duser. Onemli olan DEGER degil, GECIS:
        // kuyrukta -> yerel hala akisin YENIDEN YAYIN yaptigini kanitlar.
        SenkronDurumTuru.yerel,
        reason: 'kurtarma sonrasi U=0,B=1,K=yerel -- akis YENIDEN YAYIN yapmis olmali (kuyrukta -> yerel gecisi)',
      );
    },
  );

  // ============ G11-A6 -- ASKIDA AG (D2 kural 1) ============

  test(
    'G11-A6: ASKIDA AG -- turCalistir() await edilmeden, U>0 iken taban kuyrukta (D2 kural 1)',
    () async {
      await depo.ekle('Askida ag testi');

      final tamamlanmasinBekle = Completer<SenkronSonucu>();
      final agi = SahteSenkronAgi(
        davranis: (govde, cagriNo) => tamamlanmasinBekle.future,
      );

      final iterator = StreamIterator(depo.gorevlerGorunur());
      // expect() ortada FIRLARSA asagidaki iterator.cancel() hic calismaz --
      // acik abonelik kalirsa bir sonraki testin tearDown'i (db.close())
      // tikanip 30s test-timeout'una CARPAR (olculdu, M48 kirmizi kosumu).
      // addTearDown HER ZAMAN (basari/basarisizlik farketmeksizin) calisir.
      addTearDown(iterator.cancel);
      expect(await iterator.moveNext(), isTrue);
      // K='yerel' (hic senkronlanmadi) -- D2 kural 3'un K!='yerel' istisnasi
      // (rozetDikisi build bulgusu) burada devreye girer, taban rule 4'e
      // duser: 'yerel'. B=1 (ekle()'in kendi opu) olsa da bu satir sunucuda
      // henuz hic VAR OLMADIGI icin "gonderilmemis" YANLIS olurdu.
      expect(iterator.current.single.senkronDurumu, SenkronDurumTuru.yerel);

      final turFuture = donguOlustur(agi).turCalistir(); // KASITLI await edilmedi.

      // Istek gonderilirken (satir 'gonderildi'ye gecerken) akis YENI bir
      // kare yayinlar -- sabit sleep YOK, stream'in kendisi koşulu bekletir.
      expect(await iterator.moveNext(), isTrue);
      expect(
        iterator.current.single.senkronDurumu,
        SenkronDurumTuru.kuyrukta,
        reason: 'ag hala askida, U>0 -- her sey baska turlu olsa bile kuyrukta kazanir',
      );

      tamamlanmasinBekle.complete(_basariliYanit(await _sonIstek(agi)));
      await turFuture.timeout(const Duration(seconds: 5));
    },
  );

  // ============ G11-A7 -- BILESIK: cakisma + bekleyen ayni anda (D7) ============

  test(
    'G11-A7-veri: BILESIK -- ayni gorevde zehirli+bekliyor -- gorunum ayni anda cakismaVarMi VE gonderilmemis tasir (D7)',
    () async {
      await depo.ekle('bilesik testi');
      final id = (await db.select(db.gorevler).get()).single.id;

      // op1: reddedilir -- zehirli + K='cakisma'.
      await donguOlustur(
        SahteSenkronAgi(
          davranis: (govde, cagriNo) async => _basariliYanit(govde, kod: 'RejectedInvalid'),
        ),
      ).turCalistir();
      expect((await db.select(db.senkronKuyrugu).get()).single.durum, 'zehirli');

      // op2: YENI bekleyen op -- tur COSTURULMEZ, kuyrukta op1(zehirli) +
      // op2(bekliyor) BIRLIKTE durur.
      await depo.duzenle(id, 'bilesik v2');
      final kuyruk = await db.select(db.senkronKuyrugu).get();
      expect(kuyruk, hasLength(2));

      final gorunum = (await depo.gorevlerGorunur().first).single;
      expect(gorunum.cakismaVarMi, isTrue);
      expect(gorunum.senkronDurumu, SenkronDurumTuru.gonderilmemis);
    },
  );

  // GOREV-R10 OLCULMUS ORTAM KISITI: gercek GorevListesiEkrani'ni (canli
  // Drift/join stream) BASKA bir gercek-stream widget testinden HEMEN SONRA
  // ayni dosyada pumpWidget etmek "pumpWidget()" cagrisinin KENDISINI
  // sonsuza dek askida birakiyor (olculdu: dart:io print izleriyle izole
  // edildi, `debug_a9a10_v2.log`; JoinedSelectStatement.watch()'in stream-
  // iptal Timer'i ile AutomatedTestWidgetsFlutterBinding arasinda kirilgan
  // bir etkilesim -- g5_karantina_kapisi_test.dart'in AYNI SINIFTAN kacinma
  // gerekcesiyle ayni kok). D7'nin GORSEL/render tarafi bu yuzden gercek
  // depo yerine izole GorevSatiri ile, D6'nin VERI tarafi (yukaridaki test)
  // gercek DriftGorevDeposu ile dogrulanir -- ikisi birlikte tam kapsar.
  testWidgets(
    'G11-A7-widget: BILESIK -- GorevSatiri cakismaVarMi+gonderilmemis ile CakismaRozeti VE taban rozet BIRLIKTE cizer (D7)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GorevSatiri(
              gorev: Gorev(
                id: 'g1',
                baslik: 'bilesik widget testi',
                tamamlandi: false,
                olusturuldu: DateTime.utc(2026, 1, 1),
                guncellendi: DateTime.utc(2026, 1, 1),
                senkronDurumu: 'cakisma',
                silindi: false,
              ),
              onTamamlaDegisti: (_) {},
              senkronDurumu: SenkronDurumTuru.gonderilmemis,
              cakismaVarMi: true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CakismaRozeti), findsOneWidget);
      expect(find.byType(SenkronRozeti), findsOneWidget);
      // GOREV-A7 [K85 / D-A7-1]: gorunur dizge "Gönderilmedi" (315,0 px /
      // 2 satir); tam metin "Gönderilmemiş değişiklik" (630,0 px / 3 satir)
      // Semantics(label:)'da kalir. D7'nin ISI iki rozetin BIRLIKTE
      // cizildigini olcmektir -- dizgenin uzunlugu D7'nin konusu degildir.
      expect(find.text(Metinler.rozetKisaGonderilmedi), findsOneWidget);
      expect(
        SenkronRozeti.tamMetinIcin(SenkronDurumTuru.gonderilmemis),
        Metinler.gonderilmemisDegisiklik,
      );
    },
  );

  // ============ G11-A8 -- 4xx: Z=0 ama K=cakisma (D1) ============

  test('G11-A8: 4xx -- zehirli uretmez ama K=cakisma yazar, cakisma ikonu yine de gorunur (D1)', () async {
    await depo.ekle('4xx testi');
    final agi = SahteSenkronAgi(davranis: (govde, cagriNo) async => const SenkronHttpHatasi(400));
    await donguOlustur(agi).turCalistir();

    final kuyrukSatiri = (await db.select(db.senkronKuyrugu).get()).single;
    expect(kuyrukSatiri.durum, 'bekliyor', reason: 'D9: 400 -- satir bekliyor kalir, zehirli OLMAZ');

    final gorunum = (await depo.gorevlerGorunur().first).single;
    expect(
      gorunum.cakismaVarMi,
      isTrue,
      reason: 'Z=0 ama K=cakisma -- D1: yalniz Z>0 YETERSIZ, K==cakisma dali de kanali acar',
    );
  });

  // ============ G11-A9 -- groupBy: uc kuyruk satiri, TEK gorunum (D6) ============

  // NOT: widget agacinin dogrulanmasi (N GorevGorunum -> N GorevSatiri) genel
  // ve kosulsuz bir ListView.builder eslemesidir, GorevListesiEkrani'nin
  // KENDISI degismedi ve g10_rozet_kapsami_test.dart AYAK5/AYAK6'da gercek
  // depo ile zaten kanitli -- burada olcum GEREKEN sey groupBy'in KENDISI
  // (M50 hedefi), o da veri katmaninda TAM ve daha guvenilir sekilde olculur
  // (bkz. A7'nin ust yorumu: ayni dosyada canli-stream widget testleri arka
  // arkaya calisinca pumpWidget() askida kaliyor -- olculdu, debug_a9a10_v2.log).
  // KOR AYAK ONARIMI [K76 -- Cowork, K34-f: kapiyi yazan el ONARMAZ].
  // ESKI SURUM TEK GOREVLE KURULMUSTU ve `hasLength(1)` bekliyordu; M50
  // (groupBy dusurulur) bu ayagi GECIYORDU -- OLCULDU, KANIT/R10/09-MUTANT/
  // M50-kirmizi.txt: dusen ayaklar A4 ve A10, A9 YESIL. Sebep mekanik:
  // `addColumns([count(...)])` tasiyan bir sorgudan GROUP BY dusunce SQLite
  // TOPLAM sorgusuna doner ve UC degil **TEK** satir verir; yani hasLength(1)
  // mutant altinda da DOGRU kalir. Testin eski `reason` metni ("satir kuyruk
  // satiri kadar (3) tekrar eder") OLGUSAL OLARAK YANLISTI.
  // ONARIM: IKI gorevle kur -- toplam cokmesi ancak boyle GORUNUR olur
  // (groupBy yoksa 2 gorev icin de TEK satir doner).
  test('G11-A9: groupBy -- IKI gorev (biri UC bekleyen op), gorunumde IKI satir (D6)', () async {
    await depo.ekle('groupBy A'); // A: 1. bekleyen op.
    final idA = (await db.select(db.gorevler).get()).single.id;
    await depo.duzenle(idA, 'A-v2'); // A: 2. bekleyen op.
    await depo.duzenle(idA, 'A-v3'); // A: 3. bekleyen op.
    await depo.ekle('groupBy B'); // B: tek bekleyen op.
    final idB = (await db.select(db.gorevler).get())
        .firstWhere((s) => s.id != idA)
        .id;

    expect(
      (await db.select(db.senkronKuyrugu).get()),
      hasLength(4),
      reason: 'onkosul: A=3 op, B=1 op',
    );

    final gorunumler = await depo.gorevlerGorunur().first;
    expect(
      gorunumler,
      hasLength(2),
      reason: 'groupBy dusarse sorgu TOPLAM sorgusuna coker ve TEK satir doner',
    );
    expect(
      gorunumler.map((g) => g.gorev.id).toSet(),
      {idA, idB},
      reason: 'iki gorev de gorunumde, sayimlar gorev BASINA gruplanmis olmali',
    );
    // K='yerel' (bu senaryoda hic senkronlanmadi) -- D2 kural 3'un K!='yerel'
    // istisnasi (rozetDikisi build bulgusu) burada da devrede, taban rule
    // 4'e duser. groupBy'in ISPATI 'hasLength(1)' -- deger degil, SAYI onemli.
    expect(
      gorunumler.every((g) => g.senkronDurumu == SenkronDurumTuru.yerel),
      isTrue,
      reason: 'ikisi de hic senkronlanmadi (K=yerel) -- D2 kural 3 istisnasi [K76]',
    );
  });

  // ============ G11-A10 -- silindi: kuyruk satiri diriltmez (D6) ============

  test('G11-A10: silindi -- silinen gorev gorunumde yok, kuyruk satiri onu diriltmiyor (D6)', () async {
    await depo.ekle('silinecek gorev');
    final id = (await db.select(db.gorevler).get()).single.id;
    await depo.sil(id); // silindi=true + kuyruga 'isDeleted' (bekliyor) op'u.

    final kuyrukSatirlari = (await db.select(db.senkronKuyrugu).get())
        .where((s) => s.entityId == id);
    expect(kuyrukSatirlari, isNotEmpty, reason: 'onkosul: silinen gorevin HALA bekleyen bir kuyruk satiri var');

    final gorunumler = await depo.gorevlerGorunur().first;
    expect(gorunumler, isEmpty, reason: 'silindi=true satir LEFT JOIN uzerinden dahi geri gelmemeli');
  });

  // ============ G11-A11 -- duyuru gecis (D9) ============

  testWidgets(
    'G11-A11: duyuru -- yerel -> senkronize gecisinde BIR duyuru; ikinci (ayni durumlu) pump\'ta tekrar YOK (D9)',
    (tester) async {
      final duyurular = _duyurulariYakala(tester);
      await tester.pumpWidget(const _DurumSarmalayici(ilkDurum: SenkronDurumTuru.yerel));
      await tester.pump();
      expect(duyurular, isEmpty, reason: 'yerel duyuru metni tasimiyor');

      final durumState = tester.state<_DurumSarmalayiciState>(find.byType(_DurumSarmalayici));

      durumState.durumDegistir(SenkronDurumTuru.senkronize);
      await tester.pump();
      expect(duyurular, [Metinler.duyuruSenkronizeEdildi]);

      // Ikinci pump -- AYNI durum (senkronize) ile yeniden rebuild tetikler
      // (didUpdateWidget koşar) ama onceki==yeni oldugu icin TEKRAR duyuru
      // YOK.
      durumState.durumDegistir(SenkronDurumTuru.senkronize);
      await tester.pump();
      expect(duyurular, [Metinler.duyuruSenkronizeEdildi], reason: 'ayni durum -- ikinci duyuru YOK');
    },
  );

  // ============ G11-A12 -- ham sayim sizmiyor + rozetDikisi SAF (D4/D5) ============

  // 🔴 ODEV.md §4(a) TABAN BILEREK GUNCELLENDI (7 -> 9 -> 10): `oncelik` +
  // `sonTarih`, sonra etiket diliminde `etiketler`
  // eklendi. Bu testin KORUDUGU invaryant SAYI DEGIL, KAYNAKTIR: `Gorev`
  // yalniz HAM PROJEKSIYON SUTUNU tasir; KUYRUKTAN TURETILEN U/B/Z sayimlari
  // (ve rozet durumu) `GorevGorunum` katmaninda kalir. Iki yeni alan ham DB
  // sutunudur ⇒ invaryant ihlal edilmedi, yalniz liste uzadi. `etiketler` de
  // HAM projeksiyondur (OR-Set'in aktif elemanlari, AYNI sorguda toplanir) --
  // kuyruktan turetilen bir deger DEGILDIR.
  test('G11-A12a: Gorev YALNIZ ham sutun tasir -- U/B/Z sayimlari veri katmanindan disari cikmaz (D5)', () {
    final kaynak = File('lib/veri/gorev_deposu.dart').readAsStringSync();
    final sinifBaslangic = kaynak.indexOf('class Gorev {');
    expect(sinifBaslangic, greaterThan(-1), reason: 'Gorev sinifi bulunamadi');
    final sinifBitis = kaynak.indexOf('\n}', sinifBaslangic);
    final govde = kaynak.substring(sinifBaslangic, sinifBitis);

    final alanlar = RegExp(
      r'^\s*final\s+\S+\s+(\w+);',
      multiLine: true,
    ).allMatches(govde).map((m) => m.group(1)).toList();

    expect(
      alanlar,
      [
        'id',
        'baslik',
        'tamamlandi',
        'olusturuldu',
        'guncellendi',
        'senkronDurumu',
        'silindi',
        'oncelik',
        'sonTarih',
        'etiketler',
      ],
      reason:
          'Gorev yalniz HAM SUTUN tasir -- U/B/Z sayimlari GorevGorunum '
          'katmaninda kalmali, Gorev\'e SIZMAMALI',
    );
  });

  test('G11-A12b: rozetDikisi SAF -- DB/BuildContext/saat erisimi yok (D4)', () {
    final kaynak = File('lib/veri/gorev_deposu.dart').readAsStringSync();
    final imzaBaslangic = kaynak.indexOf('rozetDikisi(');
    expect(imzaBaslangic, greaterThan(-1), reason: 'rozetDikisi tanimi bulunamadi');
    final govde = _govdeCikar(kaynak, imzaBaslangic);

    expect(govde.contains('_db'), isFalse, reason: 'SAF: DB erisimi olamaz');
    expect(govde.contains('await'), isFalse, reason: 'SAF: I/O/async olamaz');
    expect(govde.contains('DateTime.now'), isFalse, reason: 'SAF: saat erisimi olamaz (D4)');
    expect(govde.contains('BuildContext'), isFalse, reason: 'SAF: BuildContext erisimi olamaz');
  });
}

/// G11-A6 icin: SahteSenkronAgi'nin ALICI govdesini (son istegi) okur --
/// tamamlanmasinBekle.complete() cagirmadan once govde LAZIM.
Future<Map<String, Object?>> _sonIstek(SahteSenkronAgi agi) async {
  while (agi.alinanIstekler.isEmpty) {
    await Future<void>.delayed(Duration.zero);
  }
  return agi.alinanIstekler.last;
}

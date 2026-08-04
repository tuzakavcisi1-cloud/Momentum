import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../sunum/senkron_rozeti.dart';
import 'ayarlar_deposu.dart';
import 'hlc.dart';
import 'veritabani.dart';
import 'wire_op.dart';

/// F4'un dikisi: widget'lar Drift'in urettigi satir sinifini (GorevRow)
/// dogrudan tuketmez -- bu domain modeli araya girer. Adim 3'te beslenen
/// tip degisirse (gercek senkron alanlari eklenirse) degisiklik yalniz
/// burada ve _map()'te kalir, dokuz bilesen yeniden yazilmaz.
class Gorev {
  final String id;
  final String baslik;
  final bool tamamlandi;
  final DateTime olusturuldu;
  final DateTime guncellendi;
  final String senkronDurumu;
  final bool silindi;

  const Gorev({
    required this.id,
    required this.baslik,
    required this.tamamlandi,
    required this.olusturuldu,
    required this.guncellendi,
    required this.senkronDurumu,
    required this.silindi,
  });
}

/// GOREV-R10 D5: `Gorev` (ham 7 alan, K75 PAZARLIKSIZ degismez) + KUYRUKTAN
/// TURETILEN rozet durumu TEK yerde -- widget'lar iki ayri parametre yerine
/// (senkronDurumu, cakismaVarMi) TEK gorunum nesnesi tuketir. Ham `U`/`B`/`Z`
/// sayimlari BURADAN DISARI CIKMAZ; yalniz turetilmis sonuc tasinir.
class GorevGorunum {
  final Gorev gorev;
  final SenkronDurumTuru senkronDurumu;
  final bool cakismaVarMi;

  const GorevGorunum({
    required this.gorev,
    required this.senkronDurumu,
    required this.cakismaVarMi,
  });
}

/// GOREV-SS2 D-SS2-8: `CakismaKaydiRow`'un (Drift satiri) ekrana sizmamis
/// hali -- F4 dikisinin (Gorev/GorevRow ayrimi) aynisi.
class CakismaKaydi {
  final String alan;
  final String kaybedenDeger;
  final String kazananDeger;

  const CakismaKaydi({
    required this.alan,
    required this.kaybedenDeger,
    required this.kazananDeger,
  });
}

/// GOREV-SS2 D-SS2-6: `cakismaCoz`'un secim parametresi.
enum CakismaSecimi { benimkiniTut, onlarinkiniAl }

abstract class GorevDeposu {
  /// Gorunur kayitlara TEK erisim yolu -- silindi=false filtresi YALNIZ
  /// burada. GOREV-R10 D5/D6: rozet KUYRUKTAN turetilir, sonuc GorevGorunum
  /// olarak doner (Gorev + turetilmis senkronDurumu/cakismaVarMi).
  Stream<List<GorevGorunum>> gorevlerGorunur();

  Future<void> ekle(String baslik);

  Future<void> duzenle(String id, String yeniBaslik);

  Future<void> tamamlaGeriAl(String id, {required bool tamamlandi});

  Future<void> sil(String id);

  /// GOREV-SS2 D-SS2-8/S9: entity icin cakisma kayitlarini IZLER (watch()) --
  /// tek seferlik okuma DEGIL: ekran acikken kayit degisirse (or. cozulurse)
  /// yeniden cizilir.
  Stream<List<CakismaKaydi>> cakismaKayitlariniIzle(String entityId);

  /// GOREV-SS2 D-SS2-6: entity'nin TUM cakisma kayitlarina TEK secim
  /// uygulanir (karar entity basinadir, S1).
  Future<void> cakismaCoz(String entityId, CakismaSecimi secim);
}

/// GOREV-SS2 D-SS2-4 PAZARLIKSIZ: cakisma tespiti icin TEK temsil alani --
/// hem kaybeden hem kazanan deger BU fonksiyondan gecer. v1'in MAJOR-1
/// kusuru: tel temsili ('done'/'true') projeksiyon bool'uyla karsilastirildi,
/// esitlik hic tetiklenmedi. EKRANDA GOSTERILEN METIN BU DIZE DEGILDIR --
/// Metinler'den gelen yerellestirilmis etiket kullanilir (D-SS2-8); bu
/// yalniz KARSILASTIRMA ve DEPOLAMA birimidir.
String kanonikDize(String alan, Object deger) {
  switch (alan) {
    case 'fields:title':
      return deger as String;
    case 'groups:completion':
      return (deger as bool) ? 'tamamlandi' : 'acik';
    default:
      throw StateError('kanonikDize: desteklenmeyen alan -- $alan');
  }
}

/// GOREV-R10 D3/D4 PAZARLIKSIZ: SAF fonksiyon -- DB/BuildContext/saat erisimi
/// YOK, ayni girdi HER ZAMAN ayni cikti. `senkronDurumu` (K, ham kolon) ONCE
/// dogrulanir -- taninmayan dize kurallar 1-3 kisa devre yapsa bile FIRLAR
/// (D3, mevcut "sessizce 'yerel'e dusmek YASAK" invaryanti).
///
/// D1 PAZARLIKSIZ cakisma kanali: `zehirli>0 || senkronDurumu=='cakisma' ||
/// cakismaKaydiSayisi>0` (GOREV-SS2 D-SS2-5: UCUNCU kanal) -- yalniz
/// `zehirli>0` YANLIStir (4xx yolu zehirli satir uretmeden kolona 'cakisma'
/// yazar, bkz. senkron_dongusu.dart _httpHatasiIsle).
///
/// D2 taban durumu (ilk eslesen kural kazanir):
///  1. ucusta>0                                             => kuyrukta
///  2. ucusta=0, bekleyen>0, K=='cevrimdisi'                => cevrimdisi
///  3. ucusta=0, bekleyen>0, K!='yerel' [build bulgusu, altta] => gonderilmemis (YENI)
///  4. ucusta=0, bekleyen=0                  => K eslemesi
(SenkronDurumTuru, bool) rozetDikisi(
  String senkronDurumu, {
  required int ucusta,
  required int bekleyen,
  required int zehirli,
  // GOREV-SS2 D-SS2-5: varsayilan 0 -- var olan cagri yerleri (SS2'den
  // ONCEKI) bu kanali hic bilmez, 0 onlarin gercek durumudur (cakisma kaydi
  // henuz mumkun degildi).
  int cakismaKaydiSayisi = 0,
}) {
  const gecerliDurumlar = {
    'yerel',
    'kuyrukta',
    'senkronize',
    'cakisma',
    'cevrimdisi',
  };
  if (!gecerliDurumlar.contains(senkronDurumu)) {
    throw ArgumentError('Taninmayan senkronDurumu: $senkronDurumu');
  }

  final cakismaVarMi = zehirli > 0 || senkronDurumu == 'cakisma' || cakismaKaydiSayisi > 0;

  // BUILD-ZAMANI BULGU (K75 D2 kural 3'e ELE ALINMAMIŞ kenar durum --
  // ölçüldü, spec'e kopyalanmadı, Cowork/Onur'a build notunda bildirilir):
  // D2 kural 3'ün ham metni ("U=0,B>0 => gonderilmemis") K='yerel'i istisna
  // TUTMUYOR, ama DESIGN.md v2 §4 "gönderilmemiş"i AÇIKÇA "satır sunucuda
  // VAR" diye tanımlıyor -- taze/hiç senkronlanmamış bir satır (K='yerel')
  // sunucuda YOK. Ham kural bu haliyle uygulanınca ÖLÇÜLEN regresyon:
  // g10_rozet_kapsami_test.dart AYAK6 (ekle() sonrası "Yalnızca bu cihazda"
  // beklentisi) KIRILDI -- taze bir görev, kendi gönderilmemiş ekleme
  // op'undan ötürü B>0 olduğu için hemen "Gönderilmemiş değişiklik" gösterdi.
  // DESIGN.md'nin kendi tanımını tie-break olarak kullanıp K=='yerel' kural
  // 3'ten İSTİSNA TUTULUR (rule 4'e düşer, taban 'yerel' kalır) -- kilitli
  // R10 senaryosunun kendisi (senkronize->düzenle->gönderilmemiş, G11-A3)
  // ETKİLENMEZ çünkü orada K zaten 'yerel' DEĞİLDİR.
  final SenkronDurumTuru taban;
  if (ucusta > 0) {
    taban = SenkronDurumTuru.kuyrukta;
  } else if (bekleyen > 0 && senkronDurumu == 'cevrimdisi') {
    taban = SenkronDurumTuru.cevrimdisi;
  } else if (bekleyen > 0 && senkronDurumu != 'yerel') {
    taban = SenkronDurumTuru.gonderilmemis;
  } else {
    taban = switch (senkronDurumu) {
      'senkronize' => SenkronDurumTuru.senkronize,
      'yerel' => SenkronDurumTuru.yerel,
      'cevrimdisi' => SenkronDurumTuru.cevrimdisi,
      'cakisma' => SenkronDurumTuru.yerel,
      'kuyrukta' => SenkronDurumTuru.kuyrukta,
      _ => throw StateError('gecerliDurumlar disi: $senkronDurumu'),
    };
  }

  return (taban, cakismaVarMi);
}

/// GOREV-slice-3c T4 (D2/D7/D8-1): dort yazma yolunun HER BIRI, `Gorevler`
/// satirini VE onun `WireOp`unu TEK Drift `transaction()` icinde yazar --
/// kuyruk yazilmadan `Gorevler` commit olursa veri sunucuya asla gitmez
/// (D8 kirmizi uyari, "hayalet op" ters sirada dogar). Bir op icindeki TUM
/// HLC'ler (`opHlc` + her `fields`/`groups` alaninin `hlc`si) D3'un AYNI
/// damgasidir -- bu yuzden her yazma yolu `hlc.sonrakiHlc()`i BIR KEZ cagirir
/// ve sonucu her yerde yeniden kullanir.
class DriftGorevDeposu implements GorevDeposu {
  final Veritabani _db;
  final DateTime Function() saat;
  final String Function() idUret;
  final HlcUretici hlc;
  final AyarlarDeposu ayarlarDeposu;
  final String actorId;

  DriftGorevDeposu(
    this._db, {
    required this.saat,
    required this.idUret,
    required this.hlc,
    required this.ayarlarDeposu,
    required this.actorId,
  });

  Gorev _map(GorevRow satir) => Gorev(
    id: satir.id,
    baslik: satir.baslik,
    tamamlandi: satir.tamamlandi,
    olusturuldu: satir.olusturuldu,
    guncellendi: satir.guncellendi,
    senkronDurumu: satir.senkronDurumu,
    silindi: satir.silindi,
  );

  /// GOREV-R10 D6 PAZARLIKSIZ: TEK sorgu, TEK `watch()` -- iki ayri stream +
  /// combineLatest YASAK (ara karede yanlis rozet doğurur). `Gorevler`
  /// SURUCU, kuyruk `leftOuterJoin` -- `innerJoin` kuyruk satiri olmayan
  /// (senkronize) her gorevi listeden DUSURUR. `groupBy(gorevler.id)`
  /// PAZARLIKSIZ: yoksa satir sayisi O(kuyruk satiri) olur. SQLite
  /// `FILTER (WHERE ...)` kullanilir -- olculdu (bu makinede sqlite 3.53.3,
  /// FILTER >=3.30'dan beri var, build notunda beyan edilir).
  /// GOREV-SS2 D-SS2-5: `cakismaKayitlari`'na IKINCI bir `leftOuterJoin` --
  /// entity basina BIRDEN COK satir uretir (PK alan bazlidir) ⇒ TUM
  /// count(...) sutunlari `distinct: true` OLMAK ZORUNDADIR (aksi halde iki
  /// join'in kartezyen carpimi ucusta/bekleyen/zehirli sayilarini SISIRIR).
  /// `Ö12`'nin TEK sorgu / TEK `watch()` kilidi AYNEN durur.
  /// [hamSayimGozlemcisi] Test-görünür (GOREV-SS2 G33/d: `distinct: true`'nun
  /// fan-out'u GERÇEKTEN engellediğini kanıtlamak için HAM sayılara erişim
  /// gerekir -- `GorevGorunum` bunları KASITLI OLARAK dışarı çıkarmaz (D6).
  /// Üretimde her zaman null; imza `GorevDeposu.gorevlerGorunur()`'u
  /// EKSİKSİZ karşılar (yalnız EK bir opsiyonel parametre).
  @override
  Stream<List<GorevGorunum>> gorevlerGorunur({
    void Function(int ucusta, int bekleyen, int zehirli, int cakismaKaydiSayisi)? hamSayimGozlemcisi,
  }) {
    final kuyruk = _db.senkronKuyrugu;
    final cakisma = _db.cakismaKayitlari;
    final ucustaSutunu = kuyruk.opId.count(
      filter: kuyruk.durum.equals('gonderildi'),
      distinct: true,
    );
    final bekleyenSutunu = kuyruk.opId.count(
      filter: kuyruk.durum.equals('bekliyor'),
      distinct: true,
    );
    final zehirliSutunu = kuyruk.opId.count(
      filter: kuyruk.durum.equals('zehirli'),
      distinct: true,
    );
    final cakismaSutunu = cakisma.alan.count(distinct: true);

    final sorgu =
        _db.select(_db.gorevler).join([
            leftOuterJoin(
              kuyruk,
              kuyruk.entityId.equalsExp(_db.gorevler.id) &
                  kuyruk.entityType.equals('Task'),
              useColumns: false,
            ),
            leftOuterJoin(
              cakisma,
              cakisma.entityId.equalsExp(_db.gorevler.id),
              useColumns: false,
            ),
          ])
          ..where(_db.gorevler.silindi.equals(false))
          ..addColumns([ucustaSutunu, bekleyenSutunu, zehirliSutunu, cakismaSutunu])
          ..groupBy([_db.gorevler.id])
          ..orderBy([
            OrderingTerm(expression: _db.gorevler.olusturuldu),
            OrderingTerm(expression: _db.gorevler.id),
          ]);

    return sorgu.watch().map(
      (satirlar) => satirlar.map((satir) {
        final gorev = _map(satir.readTable(_db.gorevler));
        final ucusta = satir.read(ucustaSutunu) ?? 0;
        final bekleyen = satir.read(bekleyenSutunu) ?? 0;
        final zehirli = satir.read(zehirliSutunu) ?? 0;
        final cakismaKaydiSayisi = satir.read(cakismaSutunu) ?? 0;
        hamSayimGozlemcisi?.call(ucusta, bekleyen, zehirli, cakismaKaydiSayisi);
        final (senkronDurumu, cakismaVarMi) = rozetDikisi(
          gorev.senkronDurumu,
          ucusta: ucusta,
          bekleyen: bekleyen,
          zehirli: zehirli,
          cakismaKaydiSayisi: cakismaKaydiSayisi,
        );
        return GorevGorunum(
          gorev: gorev,
          senkronDurumu: senkronDurumu,
          cakismaVarMi: cakismaVarMi,
        );
      }).toList(),
    );
  }

  @override
  Future<void> ekle(String baslik) async {
    final simdi = saat();
    final id = idUret();
    final opHlc = hlc.sonrakiHlc();
    final op = WireOp(
      operationId: idUret(),
      clientId: hlc.clientId,
      entityId: id,
      actorId: actorId,
      entityType: 'Task',
      opHlc: opHlc,
      fields: {'title': WireFieldWrite(value: baslik, hlc: opHlc)},
    );

    await _db.transaction(() async {
      await _db
          .into(_db.gorevler)
          .insert(
            GorevlerCompanion.insert(
              id: id,
              baslik: baslik,
              olusturuldu: simdi,
              guncellendi: simdi,
            ),
          );
      await _kuyrugaYaz(op);
    });
  }

  @override
  Future<void> duzenle(String id, String yeniBaslik) async {
    final opHlc = hlc.sonrakiHlc();
    final op = WireOp(
      operationId: idUret(),
      clientId: hlc.clientId,
      entityId: id,
      actorId: actorId,
      entityType: 'Task',
      opHlc: opHlc,
      fields: {'title': WireFieldWrite(value: yeniBaslik, hlc: opHlc)},
    );

    await _db.transaction(() async {
      await (_db.update(_db.gorevler)..where((t) => t.id.equals(id))).write(
        GorevlerCompanion(
          baslik: Value(yeniBaslik),
          guncellendi: Value(saat()),
        ),
      );
      await _kuyrugaYaz(op);
    });
  }

  @override
  Future<void> tamamlaGeriAl(String id, {required bool tamamlandi}) async {
    final opHlc = hlc.sonrakiHlc();
    // D2 PAZARLIKSIZ: completion REPLACE'tir -- status ve completedAt DAIMA
    // birlikte yazilir. .toUtc() dusurulemez (SS1.3 kirmizi uyari: 3 saat kaymasi).
    final op = WireOp(
      operationId: idUret(),
      clientId: hlc.clientId,
      entityId: id,
      actorId: actorId,
      entityType: 'Task',
      opHlc: opHlc,
      groups: {
        'completion': WireGroupWrite(
          fields: {
            'status': tamamlandi ? 'done' : 'open',
            'completedAt': tamamlandi ? saat().toUtc().toIso8601String() : null,
          },
          hlc: opHlc,
        ),
      },
    );

    await _db.transaction(() async {
      await (_db.update(_db.gorevler)..where((t) => t.id.equals(id))).write(
        GorevlerCompanion(
          tamamlandi: Value(tamamlandi),
          guncellendi: Value(saat()),
        ),
      );
      await _kuyrugaYaz(op);
    });
  }

  @override
  Future<void> sil(String id) async {
    final opHlc = hlc.sonrakiHlc();
    final op = WireOp(
      operationId: idUret(),
      clientId: hlc.clientId,
      entityId: id,
      actorId: actorId,
      entityType: 'Task',
      opHlc: opHlc,
      fields: {'isDeleted': WireFieldWrite(value: 'true', hlc: opHlc)},
    );

    await _db.transaction(() async {
      await (_db.update(_db.gorevler)..where((t) => t.id.equals(id))).write(
        GorevlerCompanion(silindi: const Value(true), guncellendi: Value(saat())),
      );
      await _kuyrugaYaz(op);
    });
  }

  @override
  Stream<List<CakismaKaydi>> cakismaKayitlariniIzle(String entityId) {
    return (_db.select(
      _db.cakismaKayitlari,
    )..where((t) => t.entityId.equals(entityId))).watch().map(
      (satirlar) => satirlar
          .map(
            (s) => CakismaKaydi(
              alan: s.alan,
              kaybedenDeger: s.kaybedenDeger,
              kazananDeger: s.kazananDeger,
            ),
          )
          .toList(),
    );
  }

  /// GOREV-SS2 D-SS2-6: yazma ONCE, silme SONRA, ikisi de AYNI transaction.
  /// 🟢 IC ICE TRANSACTION -- S11 OLCULDU VE DOGRULANDI (T6,
  /// `test/g34_cakismacoz_test.dart`, "S11 OLCUMU" testi): bu metot KENDI
  /// `_db.transaction()`'ini acar; icinden cagrilan `duzenle`/`tamamlaGeriAl`
  /// KENDI `transaction()`'larini IC ICE acar ve drift bunu GERCEKTEN
  /// savepoint'e indirger (izole test: dis transaction'da kasitli hata
  /// firlatilinca ic transaction'in yazdigi deger de GERI ALINDI). `benimkiniTut`
  /// mevcut yerel-yazma akisini (duzenle/tamamlaGeriAl) kullanir cunku o akis
  /// projeksiyonu DA yazar (v1'in BLOKER-6'si: yalniz kuyruga yazmak).
  @override
  Future<void> cakismaCoz(String entityId, CakismaSecimi secim) async {
    await _db.transaction(() async {
      // 🔴 M177'nin (siralamayi ters cevirme) GERCEKTEN GOZLENEBILIR olmasi
      // icin kayitlar TRANSACTION ICINDE, silmeden HEMEN ONCE degil YAZMADAN
      // ONCE okunur -- sira ters cevrilip silme yazmadan ONCE kosarsa bu
      // sorgu BOS doner ve yazma hic gerceklesmez (M177'nin isirdigi budur).
      final kayitlar = await (_db.select(
        _db.cakismaKayitlari,
      )..where((t) => t.entityId.equals(entityId))).get();

      if (secim == CakismaSecimi.benimkiniTut) {
        for (final kayit in kayitlar) {
          switch (kayit.alan) {
            case 'fields:title':
              await duzenle(entityId, kayit.kaybedenDeger);
            case 'groups:completion':
              await tamamlaGeriAl(
                entityId,
                tamamlandi: kayit.kaybedenDeger == 'tamamlandi',
              );
          }
        }
      }
      // onlarinkiniAl: yazma YOK -- projeksiyon zaten uzagin degerini tasiyor.
      await (_db.delete(
        _db.cakismaKayitlari,
      )..where((t) => t.entityId.equals(entityId))).go();
    });
  }

  /// D1: `govdeJson` uretim aninda donar; gonderim aninda YENIDEN URETILMEZ.
  /// D8-1 ile ayni transaction icinde cagrilir (ustteki dort yazma yolu).
  Future<void> _kuyrugaYaz(WireOp op) async {
    await _db
        .into(_db.senkronKuyrugu)
        .insert(
          SenkronKuyruguCompanion.insert(
            opId: op.operationId,
            clientId: op.clientId,
            entityType: op.entityType,
            entityId: op.entityId,
            govdeJson: jsonEncode(op.toJson()),
            hlcWallMs: op.opHlc.wallMs,
            hlcCounter: op.opHlc.counter,
            olusturuldu: saat().toUtc(),
          ),
        );
    await ayarlarDeposu.hlcKalicilastir(hlc.sonWall, hlc.sonCounter);
  }
}

/// Uretim idUret() -- UUID v7 (RFC 9562), bagimliliksiz (spec'te uuid paketi
/// yok; Random.secure() ile elle uretilir).
///
/// K65 (Onur, kilitli): v4 (tamamen rastgele) yerine v7 (zaman-sirali) --
/// ilk 48 bit unix_ts_ms, buyuk-endian. Sebep: sunucunun `LwwRegister` tie-
/// break'i `opId`nin DIZE-ORDINAL karsilastirmasidir ve bu karsilastirma
/// zaman-sirali bir opId varsayar (bkz. backend `HlcKey`); v4 ile bu
/// varsayim yanlisti -- iki alan-HLC'si sunucu tarafinda ayni degere
/// kirpildiginda (D3 kirmizi uyari senaryosu) tie-break YAZI-TURAya
/// donusuyordu. v7'nin zaman-sirali on-eki bu carpismayi kaynaginda keser.
String uretimIdUret() {
  final simdiMs = DateTime.now().toUtc().millisecondsSinceEpoch;
  final rastgele = Random.secure();
  final baytlar = List<int>.generate(16, (_) => rastgele.nextInt(256));

  baytlar[0] = (simdiMs >> 40) & 0xFF;
  baytlar[1] = (simdiMs >> 32) & 0xFF;
  baytlar[2] = (simdiMs >> 24) & 0xFF;
  baytlar[3] = (simdiMs >> 16) & 0xFF;
  baytlar[4] = (simdiMs >> 8) & 0xFF;
  baytlar[5] = simdiMs & 0xFF;
  baytlar[6] = (baytlar[6] & 0x0F) | 0x70; // surum 7
  baytlar[8] = (baytlar[8] & 0x3F) | 0x80; // varyant 10xx

  String hex(int baslangic, int bitis) => baytlar
      .sublist(baslangic, bitis)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();

  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}

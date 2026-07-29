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

abstract class GorevDeposu {
  /// Gorunur kayitlara TEK erisim yolu -- silindi=false filtresi YALNIZ
  /// burada. GOREV-R10 D5/D6: rozet KUYRUKTAN turetilir, sonuc GorevGorunum
  /// olarak doner (Gorev + turetilmis senkronDurumu/cakismaVarMi).
  Stream<List<GorevGorunum>> gorevlerGorunur();

  Future<void> ekle(String baslik);

  Future<void> duzenle(String id, String yeniBaslik);

  Future<void> tamamlaGeriAl(String id, {required bool tamamlandi});

  Future<void> sil(String id);
}

/// GOREV-R10 D3/D4 PAZARLIKSIZ: SAF fonksiyon -- DB/BuildContext/saat erisimi
/// YOK, ayni girdi HER ZAMAN ayni cikti. `senkronDurumu` (K, ham kolon) ONCE
/// dogrulanir -- taninmayan dize kurallar 1-3 kisa devre yapsa bile FIRLAR
/// (D3, mevcut "sessizce 'yerel'e dusmek YASAK" invaryanti).
///
/// D1 PAZARLIKSIZ cakisma kanali: `zehirli>0 || senkronDurumu=='cakisma'` --
/// yalniz `zehirli>0` YANLIStir (4xx yolu zehirli satir uretmeden kolona
/// 'cakisma' yazar, bkz. senkron_dongusu.dart _httpHatasiIsle).
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

  final cakismaVarMi = zehirli > 0 || senkronDurumu == 'cakisma';

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
  @override
  Stream<List<GorevGorunum>> gorevlerGorunur() {
    final kuyruk = _db.senkronKuyrugu;
    final ucustaSutunu = kuyruk.opId.count(
      filter: kuyruk.durum.equals('gonderildi'),
    );
    final bekleyenSutunu = kuyruk.opId.count(
      filter: kuyruk.durum.equals('bekliyor'),
    );
    final zehirliSutunu = kuyruk.opId.count(
      filter: kuyruk.durum.equals('zehirli'),
    );

    final sorgu =
        _db.select(_db.gorevler).join([
            leftOuterJoin(
              kuyruk,
              kuyruk.entityId.equalsExp(_db.gorevler.id) &
                  kuyruk.entityType.equals('Task'),
              useColumns: false,
            ),
          ])
          ..where(_db.gorevler.silindi.equals(false))
          ..addColumns([ucustaSutunu, bekleyenSutunu, zehirliSutunu])
          ..groupBy([_db.gorevler.id])
          ..orderBy([
            OrderingTerm(expression: _db.gorevler.olusturuldu),
            OrderingTerm(expression: _db.gorevler.id),
          ]);

    return sorgu.watch().map(
      (satirlar) => satirlar.map((satir) {
        final gorev = _map(satir.readTable(_db.gorevler));
        final (senkronDurumu, cakismaVarMi) = rozetDikisi(
          gorev.senkronDurumu,
          ucusta: satir.read(ucustaSutunu) ?? 0,
          bekleyen: satir.read(bekleyenSutunu) ?? 0,
          zehirli: satir.read(zehirliSutunu) ?? 0,
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

import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

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

abstract class GorevDeposu {
  /// Gorunur kayitlara TEK erisim yolu -- silindi=false filtresi YALNIZ burada.
  Stream<List<Gorev>> gorevlerGorunur();

  Future<void> ekle(String baslik);

  Future<void> duzenle(String id, String yeniBaslik);

  Future<void> tamamlaGeriAl(String id, {required bool tamamlandi});

  Future<void> sil(String id);
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

  @override
  Stream<List<Gorev>> gorevlerGorunur() {
    final sorgu = _db.select(_db.gorevler)
      ..where((t) => t.silindi.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.olusturuldu)]);
    return sorgu.watch().map((satirlar) => satirlar.map(_map).toList());
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

import 'dart:math';

import 'package:drift/drift.dart';

import 'veritabani.dart';

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

class DriftGorevDeposu implements GorevDeposu {
  final Veritabani _db;
  final DateTime Function() saat;
  final String Function() idUret;

  DriftGorevDeposu(this._db, {required this.saat, required this.idUret});

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
    await _db
        .into(_db.gorevler)
        .insert(
          GorevlerCompanion.insert(
            id: idUret(),
            baslik: baslik,
            olusturuldu: simdi,
            guncellendi: simdi,
          ),
        );
  }

  @override
  Future<void> duzenle(String id, String yeniBaslik) async {
    await (_db.update(_db.gorevler)..where((t) => t.id.equals(id))).write(
      GorevlerCompanion(baslik: Value(yeniBaslik), guncellendi: Value(saat())),
    );
  }

  @override
  Future<void> tamamlaGeriAl(String id, {required bool tamamlandi}) async {
    await (_db.update(_db.gorevler)..where((t) => t.id.equals(id))).write(
      GorevlerCompanion(
        tamamlandi: Value(tamamlandi),
        guncellendi: Value(saat()),
      ),
    );
  }

  @override
  Future<void> sil(String id) async {
    await (_db.update(_db.gorevler)..where((t) => t.id.equals(id))).write(
      GorevlerCompanion(silindi: const Value(true), guncellendi: Value(saat())),
    );
  }
}

/// Uretim idUret() -- UUID v4 (RFC 4122), bagimliliksiz (spec'te uuid paketi
/// yok; Random.secure() ile elle uretilir).
String uretimIdUret() {
  final rastgele = Random.secure();
  final baytlar = List<int>.generate(16, (_) => rastgele.nextInt(256));
  baytlar[6] = (baytlar[6] & 0x0F) | 0x40; // surum 4
  baytlar[8] = (baytlar[8] & 0x3F) | 0x80; // varyant 10xx

  String hex(int baslangic, int bitis) => baytlar
      .sublist(baslangic, bitis)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();

  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}

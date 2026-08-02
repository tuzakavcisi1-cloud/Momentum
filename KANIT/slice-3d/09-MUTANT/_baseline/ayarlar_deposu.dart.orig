import 'package:drift/drift.dart';

import 'veritabani.dart';

/// GOREV-slice-3c D3/D6/D7: tek-satirlik cihaz ayarlarinin uygulama-katmani
/// gorunumu. `clientId` (cihaz) ve `devUserId` (X-Momentum-Dev-User basligina
/// giden GUID, D0/D7) BAGIMSIZ uretilir -- D7 `actorId != clientId` sartini
/// iki ayri `idUret()` cagrisi dogal olarak saglar.
class Ayarlar {
  final String clientId;
  final int sonWall;
  final int sonCounter;
  final String? nextCursorJson;
  final String devUserId;
  final String? imlecSahibi;

  const Ayarlar({
    required this.clientId,
    required this.sonWall,
    required this.sonCounter,
    required this.nextCursorJson,
    required this.devUserId,
    required this.imlecSahibi,
  });
}

class AyarlarDeposu {
  final Veritabani _db;
  final String Function() idUret;

  AyarlarDeposu(this._db, {required this.idUret});

  /// Tek satiri (`id == 1`) okur; yoksa BIR KEZ uretir ve kalicilastirir.
  ///
  /// slice-3d D7/4 (Ö4, pinlendi): `SenkronDongusu` kurulmadan ÖNCE burada
  /// `imlecSahibi != devUserId` karsilastirilir -- farkliysa (ya da
  /// `imlecSahibi == null`, migration'dan gelen SAHIPSIZ eski satir)
  /// `nextCursorJson` VE `uzak_alan_durumu` TEK transaction'da sifirlanir,
  /// sonra `imlecSahibi = devUserId` yazilir. Aksi halde onceki kullanicinin
  /// imleci yeni kullanicinin akisina uygulanir.
  Future<Ayarlar> yukleVeyaOlustur() async {
    final satir = await (_db.select(
      _db.ayarlar,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (satir != null) {
      if (satir.imlecSahibi != satir.devUserId) {
        await _db.transaction(() async {
          await (_db.update(_db.ayarlar)..where((t) => t.id.equals(1))).write(
            AyarlarCompanion(
              nextCursorJson: const Value(null),
              imlecSahibi: Value(satir.devUserId),
            ),
          );
          await _db.delete(_db.uzakAlanDurumu).go();
        });
        return Ayarlar(
          clientId: satir.clientId,
          sonWall: satir.sonWall,
          sonCounter: satir.sonCounter,
          nextCursorJson: null,
          devUserId: satir.devUserId,
          imlecSahibi: satir.devUserId,
        );
      }
      return Ayarlar(
        clientId: satir.clientId,
        sonWall: satir.sonWall,
        sonCounter: satir.sonCounter,
        nextCursorJson: satir.nextCursorJson,
        devUserId: satir.devUserId,
        imlecSahibi: satir.imlecSahibi,
      );
    }

    final yeniClientId = idUret();
    final yeniDevUserId = idUret();
    await _db
        .into(_db.ayarlar)
        .insert(
          AyarlarCompanion.insert(
            clientId: yeniClientId,
            devUserId: yeniDevUserId,
            imlecSahibi: Value(yeniDevUserId),
          ),
        );
    return Ayarlar(
      clientId: yeniClientId,
      sonWall: 0,
      sonCounter: 0,
      nextCursorJson: null,
      devUserId: yeniDevUserId,
      imlecSahibi: yeniDevUserId,
    );
  }

  /// D3: HLC durumunu kalicilastirir (`sonrakiHlc`/`yanitIsle` sonrasi).
  Future<void> hlcKalicilastir(int sonWall, int sonCounter) async {
    await (_db.update(_db.ayarlar)..where((t) => t.id.equals(1))).write(
      AyarlarCompanion(sonWall: Value(sonWall), sonCounter: Value(sonCounter)),
    );
  }

  /// D6/D7-4 (Ö4): `NextCursor` ham JSON metni olarak yazilir; `null`
  /// verilirse (`resyncRequired == true`) saklanan imlec SILINIR.
  /// `imlecSahibi = devUserId` AYNI cagrida, AYNI transaction'da yazilir --
  /// ayri yazim YASAK (imlec yeni sahiple, sahip alani eski degerle
  /// kalirsa karsilastirma KALICI OLARAK yanlis cevap verir).
  Future<void> nextCursorKalicilastir(String? json, {required String devUserId}) async {
    await (_db.update(_db.ayarlar)..where((t) => t.id.equals(1))).write(
      AyarlarCompanion(nextCursorJson: Value(json), imlecSahibi: Value(devUserId)),
    );
  }

  /// slice-3d D7/4 (Ö4, SINIR): uretimde CAGRILMAZ -- `G1`'in kullanici-
  /// degisimi ayagini OLCULEBILIR kilmak icin genel API'de duran bir yol
  /// (bugun kullanici degistiren bir akis yok). Yalniz `devUserId` yazar,
  /// imlece DOKUNMAZ.
  Future<void> devUserIdDegistir(String yeni) async {
    await (_db.update(_db.ayarlar)..where((t) => t.id.equals(1))).write(
      AyarlarCompanion(devUserId: Value(yeni)),
    );
  }
}

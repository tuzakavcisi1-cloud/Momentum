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

  const Ayarlar({
    required this.clientId,
    required this.sonWall,
    required this.sonCounter,
    required this.nextCursorJson,
    required this.devUserId,
  });
}

class AyarlarDeposu {
  final Veritabani _db;
  final String Function() idUret;

  AyarlarDeposu(this._db, {required this.idUret});

  /// Tek satiri (`id == 1`) okur; yoksa BIR KEZ uretir ve kalicilastirir.
  Future<Ayarlar> yukleVeyaOlustur() async {
    final satir = await (_db.select(
      _db.ayarlar,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (satir != null) {
      return Ayarlar(
        clientId: satir.clientId,
        sonWall: satir.sonWall,
        sonCounter: satir.sonCounter,
        nextCursorJson: satir.nextCursorJson,
        devUserId: satir.devUserId,
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
          ),
        );
    return Ayarlar(
      clientId: yeniClientId,
      sonWall: 0,
      sonCounter: 0,
      nextCursorJson: null,
      devUserId: yeniDevUserId,
    );
  }

  /// D3: HLC durumunu kalicilastirir (`sonrakiHlc`/`yanitIsle` sonrasi).
  Future<void> hlcKalicilastir(int sonWall, int sonCounter) async {
    await (_db.update(_db.ayarlar)..where((t) => t.id.equals(1))).write(
      AyarlarCompanion(sonWall: Value(sonWall), sonCounter: Value(sonCounter)),
    );
  }

  /// D6: `NextCursor` ham JSON metni olarak yazilir; `null` verilirse
  /// (`resyncRequired == true`) saklanan imlec SILINIR.
  Future<void> nextCursorKalicilastir(String? json) async {
    await (_db.update(_db.ayarlar)..where((t) => t.id.equals(1))).write(
      AyarlarCompanion(nextCursorJson: Value(json)),
    );
  }
}

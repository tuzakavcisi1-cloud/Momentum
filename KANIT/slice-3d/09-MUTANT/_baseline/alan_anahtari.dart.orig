import 'package:drift/drift.dart';

import '../veri/veritabani.dart';

/// GOREV-slice-3d D3: yerel LWW anahtari -- sunucunun `HlcKey`sini (`Hlc` +
/// `OperationId`, `string.CompareOrdinal(OperationId.ToString("N"), ...)`)
/// BIREBIR taklit eder. `clientHex`/`opHex` DAIMA normalize (tiresiz, kucuk
/// harf) TUTULUR -- normalize etmeyi cagirana birakmak D3'un pazarliksiz
/// kuralini (normHex) ihlal etmeyi kolaylastirirdi.
class AlanAnahtari implements Comparable<AlanAnahtari> {
  final int wall;
  final int counter;
  final String clientHex;
  final String opHex;

  AlanAnahtari({
    required this.wall,
    required this.counter,
    required String clientId,
    required String opId,
  }) : clientHex = normHex(clientId),
       opHex = normHex(opId);

  /// DB'den okurken -- sutunlar ZATEN normalize saklanir (bkz. UzakAlanDurumuDeposu).
  const AlanAnahtari.normalizeEdilmis({
    required this.wall,
    required this.counter,
    required this.clientHex,
    required this.opHex,
  });

  /// D3 PAZARLIKSIZ: `karsilastir`. negatif/0/pozitif. Sunucunun `Hlc.CompareTo`
  /// sirasiyla eslesir (wall -> counter -> clientHex ordinal -> opHex ordinal).
  @override
  int compareTo(AlanAnahtari b) {
    if (wall != b.wall) return wall.compareTo(b.wall);
    if (counter != b.counter) return counter.compareTo(b.counter);
    final clientKarsilastirma = clientHex.compareTo(b.clientHex);
    if (clientKarsilastirma != 0) return clientKarsilastirma;
    return opHex.compareTo(b.opHex);
  }

  @override
  String toString() => 'AlanAnahtari(wall: $wall, counter: $counter, clientHex: $clientHex, opHex: $opHex)';
}

/// D3 PAZARLIKSIZ: sunucu `Guid.ToString("N")` (tiresiz, kucuk harf) uzerinde
/// `StringComparer.Ordinal` kullanir. Dart `String.compareTo` UTF-16 kod
/// birimi sirasidir ve `[0-9a-f]` icin bu `CompareOrdinal` ile AYNI sonucu
/// verir (G4'te 200-cift ile olculur, varsayilmaz).
String normHex(String guidDizesi) => guidDizesi.replaceAll('-', '').toLowerCase();

/// D3 PAZARLIKSIZ: `mevcut == null` ise her zaman kazanir; aksi halde KESIN
/// BUYUKLUK gerekir (`>`, `>=` DEGIL) -- esit anahtar mevcudu korur, aksi
/// halde echo (D6) kendi yazimini kendi ustune yeniden uygular.
bool kazandiMi(AlanAnahtari gelen, AlanAnahtari? mevcut) {
  if (mevcut == null) return true;
  return gelen.compareTo(mevcut) > 0;
}

/// `null`-toleransli buyuk-secici -- D5'in `enBuyuk(meta, kuyruk)` tabanini kurar.
AlanAnahtari? enBuyuk(AlanAnahtari? a, AlanAnahtari? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a.compareTo(b) >= 0 ? a : b;
}

/// GOREV-slice-3d D3/D5: `UzakAlanDurumu` okuma/yazma + IKI KARAR AYRIMI.
/// Saf karsilastirma (`AlanAnahtari`/`kazandiMi`/`enBuyuk`) DB'ye dokunmaz;
/// bu sinif DB'ye dokunan TEK yerdir -- cagiran disinda baska kod
/// `uzak_alan_durumu` tablosuna yazmaz.
class UzakAlanDurumuDeposu {
  final Veritabani _db;
  UzakAlanDurumuDeposu(this._db);

  Future<AlanAnahtari?> metaOku(String entityType, String entityId, String alan) async {
    final satir = await (_db.select(_db.uzakAlanDurumu)..where(
          (t) => t.entityType.equals(entityType) & t.entityId.equals(entityId) & t.alan.equals(alan),
        ))
        .getSingleOrNull();
    if (satir == null) return null;
    return AlanAnahtari.normalizeEdilmis(
      wall: satir.hlcWall,
      counter: satir.hlcCounter,
      clientHex: satir.hlcClientId,
      opHex: satir.winOpId,
    );
  }

  Future<void> metaYaz(String entityType, String entityId, String alan, AlanAnahtari anahtar) async {
    await _db
        .into(_db.uzakAlanDurumu)
        .insertOnConflictUpdate(
          UzakAlanDurumuCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            alan: alan,
            hlcWall: anahtar.wall,
            hlcCounter: anahtar.counter,
            hlcClientId: anahtar.clientHex,
            winOpId: anahtar.opHex,
          ),
        );
  }

  /// D3'un IKI AYRI KARARI (Ö1, pinlendi) -- KARIŞTIRMAK D6'yı ÖLDÜRÜR:
  /// **meta karari** yalniz `UzakAlanDurumu`'nun ESKI degerine karsi verilir
  /// ve kazanirsa `UzakAlanDurumu` HER HALUKARDA guncellenir (kuyruga hic
  /// bakmaz -- echo'nun tek gerekcesi budur, D6). **Projeksiyon karari**
  /// ESKI meta ile `kuyrukTabani`nin BUYUGUNE karsi AYRICA verilir (D5) --
  /// `kuyrukTabani` `null` ise (henuz T5 baglanmadi ya da kuyrukta yazim
  /// yok) taban yalniz eski meta'dir. Doner: projeksiyon guncellensin mi.
  Future<bool> degerlendirVeMetaYaz({
    required String entityType,
    required String entityId,
    required String alan,
    required AlanAnahtari gelenAnahtar,
    AlanAnahtari? kuyrukTabani,
  }) async {
    final eskiMeta = await metaOku(entityType, entityId, alan);
    if (kazandiMi(gelenAnahtar, eskiMeta)) {
      await metaYaz(entityType, entityId, alan, gelenAnahtar);
    }
    final projeksiyonTabani = enBuyuk(eskiMeta, kuyrukTabani);
    return kazandiMi(gelenAnahtar, projeksiyonTabani);
  }
}

/// GOREV-slice-3c T5: `/v1/sync` tasima katmani soyutlamasi -- senkron
/// dongusu (T6) bunun ARKASINDA calisir, gercek HTTP'yi hic bilmez. D9'un
/// yanit siniflandirmasi (200/401/4xx/5xx/ag hatasi) bu sonuc tipi uzerinde
/// calisir.
sealed class SenkronSonucu {
  const SenkronSonucu();
}

/// HTTP 200. `govdeJson` HAM metindir (decode edilmis `Map` DEGIL) --
/// D6: `WireCursor.Xid` `ulong`dur, Dart `int` web'de 53-bit guvenlidir,
/// sayiya cevirmek YASAKTIR; govde bu yuzden metin olarak tasinir ve
/// yalniz gereken alanlar (D6: `nextCursor`, `resyncRequired`; D5:
/// `applied`) ayrica parse edilir.
class SenkronBasarili extends SenkronSonucu {
  final String govdeJson;
  const SenkronBasarili(this.govdeJson);
}

/// HTTP durum kodu 200 DISINDA herhangi bir sey (401/4xx/5xx) -- D9
/// siniflandirmasi bu kod uzerinden calisir.
class SenkronHttpHatasi extends SenkronSonucu {
  final int durumKodu;
  const SenkronHttpHatasi(this.durumKodu);
}

/// Baglanti/zaman asimi gibi HTTP DISI hatalar (D9 "ag hatasi / zaman
/// asimi" satiri).
class SenkronAgHatasi extends SenkronSonucu {
  final Object neden;
  const SenkronAgHatasi(this.neden);
}

abstract class SenkronAgi {
  /// [govdeJson] zaten kodlanmis ham istek govdesidir (T6 uretir; D6
  /// geregi `sinceCursor` alani da ham metin olarak icine gomulur).
  Future<SenkronSonucu> gonder(String govdeJson);
}

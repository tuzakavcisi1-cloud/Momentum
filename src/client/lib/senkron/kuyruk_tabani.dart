import 'package:drift/drift.dart';

import '../veri/veritabani.dart';
import 'alan_anahtari.dart';

/// GOREV-slice-3d D5: kuyruktan ham cikarilan tek bir alan-HLC'si (opId HARIC
/// -- cagiran `SenkronKuyruguRow.opId`'yi zaten PK olarak elinde tutar).
class HamAlanHlc {
  final int wallMs;
  final int counter;
  final String clientId;
  const HamAlanHlc({required this.wallMs, required this.counter, required this.clientId});
}

/// D5 PAZARLIKSIZ: `govdeJson`'dan DECODE/RE-ENCODE YAPMADAN (D1: govde
/// yeniden uretilmez) tek bir alanin HLC'sini cikarir. Desenler PAZARLIKSIZ
/// pinlidir (spec D5) -- `WireOp.toJson()`'un SABIT anahtar sirasina
/// (`value` sonra `hlc`; grupta `fields` sonra `hlc`) dayanir.
///
/// FAIL-LOUD (Ö5): cipa (`"<ad>":`) YOKKEN sessiz `null` MESRUDUR (op o
/// alani hic yazmiyor). Cipa VARKEN desen TUTMAZSA `StateError` firlatilir
/// -- iki farkli olay AYNI `null`'a cevrilemez, aksi halde bekleyen yerel
/// yazim SESSIZCE ezilir (P7 kor kalir).
HamAlanHlc? hamAlanHlcCikar(String govdeJson, String alan) {
  final ikiNokta = alan.indexOf(':');
  final kanal = alan.substring(0, ikiNokta); // 'fields' | 'groups' | 'order'
  final ad = alan.substring(ikiNokta + 1);

  final cipa = '"$ad":';
  if (!govdeJson.contains(cipa)) return null; // MESRU: op o alani yazmiyor

  final adKacisli = RegExp.escape(ad);
  final RegExp desen;
  switch (kanal) {
    case 'fields':
    case 'order': // [BEYAN] order icin ayri bir kuyruk deseni YOKTUR -- istemci
      // WireOp.toJson()'da order anahtari hic uretmez, bu yuzden cipa
      // pratikte HICBIR ZAMAN bulunmaz (yukaridaki erken-null ile durur).
      // Aksi olasiliga karsi savunmaci olarak fields ile AYNI bicim
      // varsayilir (FieldStrategyRegistry'de fractional de alan-basina
      // HLC tasir).
      desen = RegExp(
        '"$adKacisli":\\{"value":(?:null|"(?:[^"\\\\]|\\\\.)*"),"hlc":\\{"wallMs":(\\d+),"counter":(\\d+),"clientId":"([^"]+)"\\}',
      );
    case 'groups':
      desen = RegExp(
        '"$adKacisli":\\{"fields":\\{(?:"(?:[^"\\\\]|\\\\.)*"|[^{}])*\\},"hlc":\\{"wallMs":(\\d+),"counter":(\\d+),"clientId":"([^"]+)"\\}',
      );
    default:
      throw StateError('hamAlanHlcCikar: bilinmeyen kanal -- $kanal ($alan)');
  }

  final eslesme = desen.firstMatch(govdeJson);
  if (eslesme == null) {
    throw StateError('hamAlanHlcCikar: cipa VAR, desen TUTMADI -- $ad');
  }
  return HamAlanHlc(
    wallMs: int.parse(eslesme.group(1)!),
    counter: int.parse(eslesme.group(2)!),
    clientId: eslesme.group(3)!,
  );
}

/// D5: bir entity+alan icin KUYRUKTAKI (henuz sunucuya ULAŞMAMIŞ YA DA
/// yaniti henuz DONMEMIS -- `bekliyor` VE `gonderildi`, `gonderildi`
/// DISARIDA BIRAKILAMAZ) en buyuk anahtari doner; kuyrukta o alani yazan
/// op yoksa `null`.
Future<AlanAnahtari?> kuyrukEnBuyuk(Veritabani db, String entityId, String alan) async {
  final satirlar = await (db.select(
    db.senkronKuyrugu,
  )..where((t) => t.entityId.equals(entityId) & t.durum.isIn(['bekliyor', 'gonderildi']))).get();

  AlanAnahtari? en;
  for (final satir in satirlar) {
    final h = hamAlanHlcCikar(satir.govdeJson, alan);
    if (h == null) continue;
    final aday = AlanAnahtari(wall: h.wallMs, counter: h.counter, clientId: h.clientId, opId: satir.opId);
    en = enBuyuk(en, aday);
  }
  return en;
}

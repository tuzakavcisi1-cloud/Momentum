import 'dart:convert';

import 'package:client/ag/senkron_agi.dart';

/// GOREV-slice-3c T7 -- sunucunun sozlesmesini taklit eden sahte ag.
/// D4 PAZARLIKSIZ: `ops.length > 100` ise 400 doner (gercek sunucunun
/// `SyncRequestValidator`ini taklit eder) -- aksi halde D4 ayagi hicbir
/// sey olcmez. Varsayilan davranis: gonderilen her op icin `Applied`.
class SahteSenkronAgi implements SenkronAgi {
  final List<Map<String, Object?>> alinanIstekler = [];

  /// Decode EDILMEMIS ham istek govdeleri -- buyuk `xid` (ulong) gibi 64-bit
  /// int sinirini asan alanlarin `jsonDecode` ile SESSIZCE double'a
  /// donusmesi (hassasiyet kaybi) YALNIZ BU LISTEDE degil, `alinanIstekler`
  /// icin kacinilmazdir; hassasiyet gerektiren dogrulamalar BUNU kullanmali.
  final List<String> alinanHamIstekler = [];

  /// O an kac `gonder()` cagrisi AYNI ANDA calisiyor (D4 mutex testleri icin).
  int esZamanliCagriSayaci = 0;
  int gorulenMaxEsZamanliCagri = 0;

  /// Ozellestirilebilir davranis: verilmezse hepsi Applied doner.
  final Future<SenkronSonucu> Function(
    Map<String, Object?> govde,
    int cagriNo,
  )?
  davranis;

  SahteSenkronAgi({this.davranis});

  @override
  Future<SenkronSonucu> gonder(String govdeJson) async {
    esZamanliCagriSayaci++;
    if (esZamanliCagriSayaci > gorulenMaxEsZamanliCagri) {
      gorulenMaxEsZamanliCagri = esZamanliCagriSayaci;
    }
    try {
      alinanHamIstekler.add(govdeJson);
      final govde = jsonDecode(govdeJson) as Map<String, Object?>;
      alinanIstekler.add(govde);

      final ops = (govde['ops'] as List?) ?? const [];
      if (ops.length > 100) {
        return const SenkronHttpHatasi(400);
      }

      if (davranis != null) {
        return await davranis!(govde, alinanIstekler.length);
      }

      final applied = [
        for (final op in ops)
          {
            'operationId': (op as Map)['operationId'],
            'code': 'Applied',
            'effectiveOpHlc': op['opHlc'],
          },
      ];
      return SenkronBasarili(
        jsonEncode({
          'serverHlc': null,
          'nextCursor': null,
          'hasMore': false,
          'resyncRequired': false,
          'applied': applied,
          'changes': [],
          'snapshot': [],
        }),
      );
    } finally {
      esZamanliCagriSayaci--;
    }
  }
}

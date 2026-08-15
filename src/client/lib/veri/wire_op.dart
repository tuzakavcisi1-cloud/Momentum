import 'hlc.dart';

/// Tel modelleri (GOREV-slice-3c D2/D7) -- sunucunun `WireOp`/`WireFieldWrite`/
/// `WireGroupWrite` kayitlarinin JSON gorunumuyle BIREBIR eslesir (camelCase).

class WireFieldWrite {
  final String? value;
  final Hlc hlc;

  const WireFieldWrite({required this.value, required this.hlc});

  Map<String, Object?> toJson() => {'value': value, 'hlc': hlc.toJson()};
}

class WireGroupWrite {
  final Map<String, String?> fields;
  final Hlc hlc;

  const WireGroupWrite({required this.fields, required this.hlc});

  Map<String, Object?> toJson() => {'fields': fields, 'hlc': hlc.toJson()};
}

/// ODEV.md §4(a) etiket dilimi -- OR-Set tel aynasi. Sunucu KAYNAGINDAN
/// OLCULDU, varsayilmadi (`Momentum.Application/Features/Sync/SyncContracts.cs`,
/// JSON `JsonSerializerDefaults.Web` = camelCase):
///   `WireSetAdd(string El, Guid Tag, WireHlc Hlc)`
///   `WireSetRemove(string El, IReadOnlyList<Guid> Observed, WireHlc Hlc)`
///   `WireSetDelta(IReadOnlyList<WireSetAdd>? Adds, IReadOnlyList<WireSetRemove>? Removes)`
/// JSON adlari BIREBIR: el/tag/hlc/observed/adds/removes.
class WireSetAdd {
  final String el;

  /// Sunucuda `Guid`e ayrisir -- istemci UUID v7 uretir (`uretimIdUret`).
  final String tag;
  final Hlc hlc;

  const WireSetAdd({required this.el, required this.tag, required this.hlc});

  Map<String, Object?> toJson() => {'el': el, 'tag': tag, 'hlc': hlc.toJson()};
}

class WireSetRemove {
  final String el;

  /// YALNIZ GORULEN tag'ler iptal edilir -- eszamanli, HENUZ GORULMEMIS bir
  /// add ASLA (ADD-WINS). Bos `observed` ile remove URETILMEZ: aktif tag
  /// yoksa op hic dogmaz (`DriftGorevDeposu.ayrintilariGuncelle`).
  final List<String> observed;
  final Hlc hlc;

  const WireSetRemove({
    required this.el,
    required this.observed,
    required this.hlc,
  });

  Map<String, Object?> toJson() => {
    'el': el,
    'observed': observed,
    'hlc': hlc.toJson(),
  };
}

class WireSetDelta {
  final List<WireSetAdd> adds;
  final List<WireSetRemove> removes;

  const WireSetDelta({this.adds = const [], this.removes = const []});

  bool get bosMu => adds.isEmpty && removes.isEmpty;

  /// Sunucuda `Adds`/`Removes` NULLABLE'dir ⇒ BOS liste tele KONMAZ.
  Map<String, Object?> toJson() => {
    if (adds.isNotEmpty) 'adds': adds.map((a) => a.toJson()).toList(),
    if (removes.isNotEmpty) 'removes': removes.map((r) => r.toJson()).toList(),
  };
}

/// D7 zarf: `operationId`/`clientId`/`entityId`/`actorId` DORDU de bos-olmayan
/// gecerli GUID'dir. D2: her op EN AZ BIR kanal tasir (`fields` ya da
/// `groups`); bos op UYGULAMA KATMANINDA asla uretilmez -- cagiran taraf
/// (DriftGorevDeposu) bunu garanti eder.
class WireOp {
  final String operationId;
  final String clientId;
  final String entityId;
  final String actorId;
  final String entityType;
  final Hlc opHlc;
  final Map<String, WireFieldWrite> fields;
  final Map<String, WireGroupWrite> groups;

  /// ODEV.md §4(a): OR-Set kanali (bugun TEK anahtar -- `tags`). D2'nin "her
  /// op EN AZ BIR kanal tasir" sarti bu kanalla da SAGLANIR.
  final Map<String, WireSetDelta> sets;

  const WireOp({
    required this.operationId,
    required this.clientId,
    required this.entityId,
    required this.actorId,
    required this.entityType,
    required this.opHlc,
    this.fields = const {},
    this.groups = const {},
    this.sets = const {},
  });

  Map<String, Object?> toJson() => {
    'operationId': operationId,
    'clientId': clientId,
    'entityId': entityId,
    'actorId': actorId,
    'entityType': entityType,
    'opHlc': opHlc.toJson(),
    if (fields.isNotEmpty)
      'fields': fields.map((k, v) => MapEntry(k, v.toJson())),
    if (groups.isNotEmpty)
      'groups': groups.map((k, v) => MapEntry(k, v.toJson())),
    if (sets.isNotEmpty) 'sets': sets.map((k, v) => MapEntry(k, v.toJson())),
  };
}

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

  const WireOp({
    required this.operationId,
    required this.clientId,
    required this.entityId,
    required this.actorId,
    required this.entityType,
    required this.opHlc,
    this.fields = const {},
    this.groups = const {},
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
  };
}

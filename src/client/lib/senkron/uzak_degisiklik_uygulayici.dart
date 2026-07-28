import 'package:drift/drift.dart';

import '../veri/hlc.dart';
import '../veri/veritabani.dart';
import 'alan_anahtari.dart';

/// Bir entity icin bu cagirimda gorulen kazanan projeksiyon degerleri --
/// hepsi opsiyoneldir (bu cagrida o kanal hic gelmemis/kazanmamis olabilir).
class _GorevGuncellemesi {
  String? baslik;
  bool? tamamlandi;
  bool? silindi;
  int? guncellendiWallMs; // kazanan yazimlarin EN BUYUK wallMs'i
  int? olusturulduWallMs; // gorulen TUM op/alan-HLC'lerinin EN KUCUK wallMs'i
  bool herhangiBirKanalKazandi = false;
}

Hlc _hlcOku(Map<String, Object?> hlcMap) => Hlc.fromJson(hlcMap);

/// GOREV-slice-3d D2/D4: `changes`/`snapshot` icin IKI AYRI ayristirici +
/// uc alanin (baslik/tamamlandi/silindi) projeksiyonu. `kuyrukTabaniSaglayici`
/// T5'te gercek `kuyrukEnBuyuk`e baglanir -- burada saglanmazsa (T3 asamasi,
/// G3 testleri) taban DAIMA null'dur, yani projeksiyon karari yalniz ESKI
/// meta'ya karsi verilir (D5'in koruma katmani henuz yok).
class UzakDegisiklikUygulayici {
  final Veritabani _db;
  final UzakAlanDurumuDeposu _metaDepo;
  final Future<AlanAnahtari?> Function(String entityId, String alan) kuyrukTabaniSaglayici;

  UzakDegisiklikUygulayici(
    this._db, {
    Future<AlanAnahtari?> Function(String entityId, String alan)? kuyrukTabaniSaglayici,
  }) : _metaDepo = UzakAlanDurumuDeposu(_db),
       kuyrukTabaniSaglayici = kuyrukTabaniSaglayici ?? ((_, _) async => null);

  /// D2: `changes[i] = {cursor, payload}`; `payload` bir WireOp'tur, HER
  /// yazimin KENDI HLC'si vardir. Tie-break `payload['operationId']`.
  Future<void> changesUygula(List<Map<String, Object?>> changes) async {
    final guncellemeler = <String, _GorevGuncellemesi>{};
    for (final degisiklik in changes) {
      final payload = degisiklik['payload'] as Map<String, Object?>;
      final entityId = payload['entityId'] as String;
      final entityType = payload['entityType'] as String;
      final operationId = payload['operationId'] as String;
      final opHlcWall = (payload['opHlc'] as Map<String, Object?>)['wallMs'] as int;

      final g = guncellemeler.putIfAbsent(entityId, () => _GorevGuncellemesi());
      g.olusturulduWallMs = g.olusturulduWallMs == null ? opHlcWall : (opHlcWall < g.olusturulduWallMs! ? opHlcWall : g.olusturulduWallMs);

      // [KIRMIZI] D2 -- null kanal korumasi PAZARLIKSIZ: her kanal okumasi
      // `as Map<String,Object?>? ?? const {}` bicimindedir.
      final fields = (payload['fields'] as Map<String, Object?>?) ?? const {};
      for (final girdi in fields.entries) {
        final ad = girdi.key;
        final yazim = girdi.value as Map<String, Object?>;
        final hlc = _hlcOku(yazim['hlc'] as Map<String, Object?>);
        final deger = yazim['value'] as String?;
        await _kanalUygula(
          entityType: entityType,
          entityId: entityId,
          alan: 'fields:$ad',
          anahtar: AlanAnahtari(wall: hlc.wallMs, counter: hlc.counter, clientId: hlc.clientId, opId: operationId),
          g: g,
          kanalAdi: ad,
          fieldsDegeri: deger,
        );
      }

      final groups = (payload['groups'] as Map<String, Object?>?) ?? const {};
      for (final girdi in groups.entries) {
        final ad = girdi.key;
        final yazim = girdi.value as Map<String, Object?>;
        final hlc = _hlcOku(yazim['hlc'] as Map<String, Object?>);
        final grupFields = (yazim['fields'] as Map<String, Object?>?) ?? const {};
        await _kanalUygula(
          entityType: entityType,
          entityId: entityId,
          alan: 'groups:$ad',
          anahtar: AlanAnahtari(wall: hlc.wallMs, counter: hlc.counter, clientId: hlc.clientId, opId: operationId),
          g: g,
          kanalAdi: ad,
          groupFields: grupFields,
        );
      }

      // [BEYAN] order kanali icin gercek bir tel ornegi bu dilimde
      // OLCULMEDI (backend WireOp.Order daima null geldi) -- `fields` ile
      // AYNI per-alan bicimi VARSAYILIR (FieldStrategyRegistry'de fractional
      // de scalar gibi alan-basina HLC tasir). Projeksiyona YAZILMAZ, yalniz
      // UzakAlanDurumu'na kaydedilir.
      final order = (payload['order'] as Map<String, Object?>?) ?? const {};
      for (final girdi in order.entries) {
        final ad = girdi.key;
        final yazim = girdi.value as Map<String, Object?>;
        final hlc = _hlcOku(yazim['hlc'] as Map<String, Object?>);
        await _metaDepo.degerlendirVeMetaYaz(
          entityType: entityType,
          entityId: entityId,
          alan: 'order:$ad',
          gelenAnahtar: AlanAnahtari(wall: hlc.wallMs, counter: hlc.counter, clientId: hlc.clientId, opId: operationId),
          kuyrukTabani: await kuyrukTabaniSaglayici(entityId, 'order:$ad'),
        );
      }
      // `sets` kanali bilincli olarak yok sayilir (SINIR, D2/1.4).
    }
    await _projeksiyonYaz(guncellemeler);
  }

  /// D2: `snapshot[i] = {entityType, entityId, scalars[], sets[], groups[]}`
  /// -- tie-break `winOperationId` DOGRUDAN gelir, uydurulmaz. BIRLESTIRICI:
  /// tablo temizlenmez, snapshotta olmayan yerel satir dokunulmadan durur.
  Future<void> snapshotUygula(List<Map<String, Object?>> snapshot) async {
    final guncellemeler = <String, _GorevGuncellemesi>{};
    for (final entity in snapshot) {
      final entityType = entity['entityType'] as String;
      final entityId = entity['entityId'] as String;
      final g = guncellemeler.putIfAbsent(entityId, () => _GorevGuncellemesi());

      final scalars = (entity['scalars'] as List?) ?? const [];
      for (final ham in scalars) {
        final scalar = ham as Map<String, Object?>;
        final ad = scalar['field'] as String;
        final hlc = _hlcOku(scalar['hlc'] as Map<String, Object?>);
        final winOpId = scalar['winOperationId'] as String;
        g.olusturulduWallMs = g.olusturulduWallMs == null ? hlc.wallMs : (hlc.wallMs < g.olusturulduWallMs! ? hlc.wallMs : g.olusturulduWallMs);
        await _kanalUygula(
          entityType: entityType,
          entityId: entityId,
          alan: 'fields:$ad',
          anahtar: AlanAnahtari(wall: hlc.wallMs, counter: hlc.counter, clientId: hlc.clientId, opId: winOpId),
          g: g,
          kanalAdi: ad,
          fieldsDegeri: scalar['value'] as String?,
        );
      }

      final groups = (entity['groups'] as List?) ?? const [];
      for (final ham in groups) {
        final grup = ham as Map<String, Object?>;
        final ad = grup['group'] as String;
        final hlc = _hlcOku(grup['hlc'] as Map<String, Object?>);
        final winOpId = grup['winOperationId'] as String;
        final grupFields = (grup['fields'] as Map<String, Object?>?) ?? const {};
        g.olusturulduWallMs = g.olusturulduWallMs == null ? hlc.wallMs : (hlc.wallMs < g.olusturulduWallMs! ? hlc.wallMs : g.olusturulduWallMs);
        await _kanalUygula(
          entityType: entityType,
          entityId: entityId,
          alan: 'groups:$ad',
          anahtar: AlanAnahtari(wall: hlc.wallMs, counter: hlc.counter, clientId: hlc.clientId, opId: winOpId),
          g: g,
          kanalAdi: ad,
          groupFields: grupFields,
        );
      }
      // `sets` kanali bilincli olarak yok sayilir (SINIR, D2/1.4).
    }
    await _projeksiyonYaz(guncellemeler);
  }

  /// Tek bir kanalin (`fields:ad` ya da `groups:ad`) meta+projeksiyon
  /// kararini verir; kazanirsa `g`ye YALNIZ BILINEN UC ALANIN esini yazar.
  /// [KIRMIZI] D2 -- BILINMEYEN ALAN SESSIZCE ATLANMAZ: `_metaDepo` her
  /// zaman cagrilir (UzakAlanDurumu'na yazilir), projeksiyon eslemesi
  /// yalniz `title`/`completion`/`isDeleted` icin vardir.
  Future<void> _kanalUygula({
    required String entityType,
    required String entityId,
    required String alan,
    required AlanAnahtari anahtar,
    required _GorevGuncellemesi g,
    required String kanalAdi,
    String? fieldsDegeri,
    Map<String, Object?>? groupFields,
  }) async {
    final projeksiyonKazandi = await _metaDepo.degerlendirVeMetaYaz(
      entityType: entityType,
      entityId: entityId,
      alan: alan,
      gelenAnahtar: anahtar,
      kuyrukTabani: await kuyrukTabaniSaglayici(entityId, alan),
    );
    if (!projeksiyonKazandi) return;

    // D4: yalniz UC eslemeden biri -- rozete (senkronDurumu) ASLA dokunulmaz.
    if (alan == 'fields:title') {
      g.baslik = fieldsDegeri ?? '';
      g.herhangiBirKanalKazandi = true;
      g.guncellendiWallMs = g.guncellendiWallMs == null ? anahtar.wall : (anahtar.wall > g.guncellendiWallMs! ? anahtar.wall : g.guncellendiWallMs);
    } else if (alan == 'fields:isDeleted') {
      // [KIRMIZI] D4 -- Ordinal, TAM dize karsilastirma. "True"/"TRUE" silinmis SAYILMAZ.
      g.silindi = fieldsDegeri == 'true';
      g.herhangiBirKanalKazandi = true;
      g.guncellendiWallMs = g.guncellendiWallMs == null ? anahtar.wall : (anahtar.wall > g.guncellendiWallMs! ? anahtar.wall : g.guncellendiWallMs);
    } else if (alan == 'groups:completion') {
      final status = groupFields?['status'] as String?;
      g.tamamlandi = status == 'done'; // Ordinal, TAM dize
      g.herhangiBirKanalKazandi = true;
      g.guncellendiWallMs = g.guncellendiWallMs == null ? anahtar.wall : (anahtar.wall > g.guncellendiWallMs! ? anahtar.wall : g.guncellendiWallMs);
    }
    // Bilinmeyen alan: UzakAlanDurumu'na YAZILDI (yukarida), projeksiyona DOKUNULMADI.
  }

  Future<void> _projeksiyonYaz(Map<String, _GorevGuncellemesi> guncellemeler) async {
    for (final girdi in guncellemeler.entries) {
      final entityId = girdi.key;
      final g = girdi.value;
      if (!g.herhangiBirKanalKazandi) continue;

      final mevcut = await (_db.select(_db.gorevler)..where((t) => t.id.equals(entityId))).getSingleOrNull();
      if (mevcut == null) {
        // D4/B3: YENI entity -- yedi sutunlu Gorevler'e kurala bagli INSERT.
        final olusturulduWall = g.olusturulduWallMs ?? g.guncellendiWallMs ?? 0;
        final guncellendiWall = g.guncellendiWallMs ?? olusturulduWall;
        await _db
            .into(_db.gorevler)
            .insert(
              GorevlerCompanion.insert(
                id: entityId,
                baslik: g.baslik ?? '',
                tamamlandi: Value(g.tamamlandi ?? false),
                olusturuldu: DateTime.fromMillisecondsSinceEpoch(olusturulduWall, isUtc: true),
                guncellendi: DateTime.fromMillisecondsSinceEpoch(guncellendiWall, isUtc: true),
                silindi: Value(g.silindi ?? false),
                // senkronDurumu YAZILMAZ -- sutun varsayilaniyla ('yerel') doGar (D4 BEYAN).
              ),
            );
      } else {
        final companion = GorevlerCompanion(
          baslik: g.baslik != null ? Value(g.baslik!) : const Value.absent(),
          tamamlandi: g.tamamlandi != null ? Value(g.tamamlandi!) : const Value.absent(),
          silindi: g.silindi != null ? Value(g.silindi!) : const Value.absent(),
          guncellendi: g.guncellendiWallMs != null
              ? Value(DateTime.fromMillisecondsSinceEpoch(g.guncellendiWallMs!, isUtc: true))
              : const Value.absent(),
          // senkronDurumu YAZILMAZ (D4 PAZARLIKSIZ -- rozet dokunulmazligi).
        );
        await (_db.update(_db.gorevler)..where((t) => t.id.equals(entityId))).write(companion);
      }
    }
  }
}

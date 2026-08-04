import 'package:drift/drift.dart';

import '../veri/gorev_deposu.dart';
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
  // GOREV-SS2 D-SS2-2 on kosulu 1: kanal basina KAZANAN anahtar -- D-SS2-3
  // sart 3'un ("kazanan biz degiliz") clientHex karsilastirmasi bunsuz
  // yapilamaz. `_kanalUygula`da kazanan kanalla BIRLIKTE yazilir.
  AlanAnahtari? baslikKazananAnahtari;
  AlanAnahtari? tamamlandiKazananAnahtari;
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
  // GOREV-SS2 D-SS2-2 on kosulu 2: cihazin KENDI clientId'si -- D-SS2-3 sart
  // 3'un ("kazanan biz degiliz") normHex karsilastirmasi bunsuz yapilamaz.
  final String clientId;
  // GOREV-SS2 D-SS2-11: turun BASINDA alinan anlik goruntuden cevaplanir.
  // Varsayilan (test/T3 asamasi): daima false -- sessiz yanlis-pozitif
  // uretmez, cakisma sart 2'si hic saglanmaz.
  final Future<bool> Function(String entityId, String alan) bekleyenYerelYazimVarMi;
  // GOREV-SS2 D-SS2-9: `olusturuldu` BUNDAN yazilir, `DateTime.now()`'in
  // DOGRUDAN cagrilmasi YASAKTIR (GorevDeposu'nun disiplininin aynisi).
  final DateTime Function() saat;

  UzakDegisiklikUygulayici(
    this._db, {
    // GOREV-SS2 T2 (regresyon yok sarti): var olan ~20 test cagri yeri
    // clientId GECIRMEZ; varsayilan '' hicbir gercek clientId ile ESLESMEZ
    // (GUID BOS OLAMAZ) -- D-SS2-3 sart 3 (echo elemesi) T3'ten once hic
    // saglanamayacagi icin bu varsayilan yanlis-pozitif URETMEZ.
    this.clientId = '',
    Future<AlanAnahtari?> Function(String entityId, String alan)? kuyrukTabaniSaglayici,
    Future<bool> Function(String entityId, String alan)? bekleyenYerelYazimVarMi,
    DateTime Function()? saat,
  }) : _metaDepo = UzakAlanDurumuDeposu(_db),
       kuyrukTabaniSaglayici = kuyrukTabaniSaglayici ?? ((_, _) async => null),
       bekleyenYerelYazimVarMi = bekleyenYerelYazimVarMi ?? ((_, _) async => false),
       saat = saat ?? (() => DateTime.now().toUtc());

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
      g.baslikKazananAnahtari = anahtar; // GOREV-SS2 D-SS2-2/1
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
      g.tamamlandiKazananAnahtari = anahtar; // GOREV-SS2 D-SS2-2/1
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
                // R9/T1 (K72 -- P6/D4 DARALTILDI): INSERT-from-pull 'senkronize'
                // ile dogar -- bu satirda bekleyen yerel yazim YOKTUR (henuz
                // kuyrukta hic op yok), P6/P7'nin korudugu senaryo bu DEGILDIR.
                // UPDATE dali (asagida) rozete DOKUNMAZ, kilit orada AYNEN durur.
                senkronDurumu: const Value('senkronize'),
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

        // GOREV-SS2 D-SS2-2: tespit noktasi -- `mevcut` burada ZATEN OKUNMUS
        // (yukarida), ekstra SELECT yok. Kanal kazanmadiysa (deger null)
        // hic cagrilmaz -- sart 1 boylece PEK cagiranin kendisinde saglanir.
        if (g.baslik != null) {
          await _cakismaTespitEtVeYaz(
            entityId: entityId,
            alan: 'fields:title',
            kanonikYeni: kanonikDize('fields:title', g.baslik!),
            kanonikEski: kanonikDize('fields:title', mevcut.baslik),
            kazananAnahtari: g.baslikKazananAnahtari!,
          );
        }
        if (g.tamamlandi != null) {
          await _cakismaTespitEtVeYaz(
            entityId: entityId,
            alan: 'groups:completion',
            kanonikYeni: kanonikDize('groups:completion', g.tamamlandi!),
            kanonikEski: kanonikDize('groups:completion', mevcut.tamamlandi),
            kazananAnahtari: g.tamamlandiKazananAnahtari!,
          );
        }
      }
    }
  }

  /// GOREV-SS2 D-SS2-3 PAZARLIKSIZ: dort sart (hepsi AND, kayit YOKSA) --
  /// kanal bu partide kazandi (cagiran zaten saglar), kuyrukta bekleyen
  /// yerel yazim var, kazanan BIZ DEGILIZ, degerler farkli.
  /// BAYATLAMA (`/e`): kayit VARSA sart 2 ve 4 ARANMAKSIZIN -- ama sart 3
  /// ARANARAK -- kazananDeger/kazananClientHex GUNCELLENIR, kaybedenDeger
  /// KORUNUR. Sart 3 `/e`'de de arandigi icin kendi echo'muz kaybedeni
  /// EZEMEZ (M180b, tur 2 B2-4).
  Future<void> _cakismaTespitEtVeYaz({
    required String entityId,
    required String alan,
    required String kanonikYeni,
    required String kanonikEski,
    required AlanAnahtari kazananAnahtari,
  }) async {
    final kazananBiziz = kazananAnahtari.clientHex == normHex(clientId);

    final mevcutKayit = await (_db.select(_db.cakismaKayitlari)
          ..where((t) => t.entityId.equals(entityId) & t.alan.equals(alan)))
        .getSingleOrNull();

    if (mevcutKayit == null) {
      if (kazananBiziz) return; // sart 3
      final bekleyenVar = await bekleyenYerelYazimVarMi(entityId, alan);
      if (!bekleyenVar) return; // sart 2
      if (kanonikEski == kanonikYeni) return; // sart 4
      await _db.into(_db.cakismaKayitlari).insert(
        CakismaKayitlariCompanion.insert(
          entityId: entityId,
          alan: alan,
          kaybedenDeger: kanonikEski,
          kazananDeger: kanonikYeni,
          kazananClientHex: kazananAnahtari.clientHex,
          olusturuldu: saat(),
        ),
      );
    } else {
      if (kazananBiziz) return; // sart 3 -- `/e`'de de aranir (M180b).
      await (_db.update(_db.cakismaKayitlari)
            ..where((t) => t.entityId.equals(entityId) & t.alan.equals(alan)))
          .write(
        CakismaKayitlariCompanion(
          kazananDeger: Value(kanonikYeni),
          kazananClientHex: Value(kazananAnahtari.clientHex),
          // kaybedenDeger KORUNUR -- yazilmiyor.
        ),
      );
    }
  }
}

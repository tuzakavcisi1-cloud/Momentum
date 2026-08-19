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
  // ODEV.md §4(a): iki YENI skaler kanal. Deger `null` OLABILECEGI icin
  // (alan temizlendi) "geldi mi" AYRI bir bayrakla tasinir -- yoksa
  // "temizlendi" ile "hic gelmedi" ayirt edilemezdi.
  int? oncelik;
  bool oncelikGeldi = false;
  DateTime? sonTarih;
  bool sonTarihGeldi = false;
  // IS-EMRI-o85-A C3: `projectId` -- Task tarafinin `Project`e bagi.
  // `null` OLABILECEGI icin (Gelen Kutusu'na tasindi) "geldi mi" AYRI bir
  // bayrakla tasinir -- oncelik/sonTarih'in AYNI deseni.
  String? projeId;
  bool projeIdGeldi = false;
}

/// IS-EMRI-o85-A C1: `Project` icin AYRI havuz -- `_GorevGuncellemesi`nin
/// dar esdegeri, yalniz `name`/`isDeleted` tanir (K3: `pos`/`renk` bu
/// dilimde YOK, `Projeler`de `guncellendi` sutunu da YOK).
class _ProjeGuncellemesi {
  String? ad;
  bool? silindi;
  int? olusturulduWallMs;
  bool herhangiBirKanalKazandi = false;
}

Hlc _hlcOku(Map<String, Object?> hlcMap) => Hlc.fromJson(hlcMap);

/// GOREV-slice-3d D2/D4: `changes`/`snapshot` icin IKI AYRI ayristirici +
/// BES alanin (baslik/tamamlandi/silindi + ODEV.md §4(a) oncelik/sonTarih)
/// projeksiyonu. `kuyrukTabaniSaglayici`
/// T5'te gercek `kuyrukEnBuyuk`e baglanir -- burada saglanmazsa (T3 asamasi,
/// G3 testleri) taban DAIMA null'dur, yani projeksiyon karari yalniz ESKI
/// meta'ya karsi verilir (D5'in koruma katmani henuz yok).
class UzakDegisiklikUygulayici {
  final Veritabani _db;
  final UzakAlanDurumuDeposu _metaDepo;
  final Future<AlanAnahtari?> Function(String entityId, String alan)
  kuyrukTabaniSaglayici;
  // GOREV-SS2 D-SS2-2 on kosulu 2: cihazin KENDI clientId'si -- D-SS2-3 sart
  // 3'un ("kazanan biz degiliz") normHex karsilastirmasi bunsuz yapilamaz.
  final String clientId;
  // GOREV-SS2 D-SS2-11: turun BASINDA alinan anlik goruntuden cevaplanir.
  // Varsayilan (test/T3 asamasi): daima false -- sessiz yanlis-pozitif
  // uretmez, cakisma sart 2'si hic saglanmaz.
  final Future<bool> Function(String entityId, String alan)
  bekleyenYerelYazimVarMi;
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
    Future<AlanAnahtari?> Function(String entityId, String alan)?
    kuyrukTabaniSaglayici,
    Future<bool> Function(String entityId, String alan)?
    bekleyenYerelYazimVarMi,
    DateTime Function()? saat,
  }) : _metaDepo = UzakAlanDurumuDeposu(_db),
       kuyrukTabaniSaglayici = kuyrukTabaniSaglayici ?? ((_, _) async => null),
       bekleyenYerelYazimVarMi =
           bekleyenYerelYazimVarMi ?? ((_, _) async => false),
       saat = saat ?? (() => DateTime.now().toUtc());

  /// D2: `changes[i] = {cursor, payload}`; `payload` bir WireOp'tur, HER
  /// yazimin KENDI HLC'si vardir. Tie-break `payload['operationId']`.
  ///
  /// IS-EMRI-o85-A C1: `entityType` DALI -- `Task` bugunku yola
  /// (`guncellemeler`/`_kanalUygula`) DEGISMEDEN gider; `Project` AYRI bir
  /// havuza (`projeGuncellemeleri`/`_projeKanalUygula`) gider; BASKA HICBIR
  /// entityType projeksiyona YAZILMAZ (yalniz `UzakAlanDurumu`ya, D2'nin
  /// "bilinmeyen alan sessizce atlanmaz" ayni disiplini entityType icin de
  /// gecerlidir).
  Future<void> changesUygula(List<Map<String, Object?>> changes) async {
    final guncellemeler = <String, _GorevGuncellemesi>{};
    final projeGuncellemeleri = <String, _ProjeGuncellemesi>{};
    for (final degisiklik in changes) {
      final payload = degisiklik['payload'] as Map<String, Object?>;
      final entityId = payload['entityId'] as String;
      final entityType = payload['entityType'] as String;
      final operationId = payload['operationId'] as String;
      final opHlcWall =
          (payload['opHlc'] as Map<String, Object?>)['wallMs'] as int;

      _GorevGuncellemesi? g;
      _ProjeGuncellemesi? pg;
      if (entityType == 'Task') {
        g = guncellemeler.putIfAbsent(entityId, () => _GorevGuncellemesi());
        g.olusturulduWallMs = g.olusturulduWallMs == null
            ? opHlcWall
            : (opHlcWall < g.olusturulduWallMs!
                  ? opHlcWall
                  : g.olusturulduWallMs);
      } else if (entityType == 'Project') {
        pg = projeGuncellemeleri.putIfAbsent(
          entityId,
          () => _ProjeGuncellemesi(),
        );
        pg.olusturulduWallMs = pg.olusturulduWallMs == null
            ? opHlcWall
            : (opHlcWall < pg.olusturulduWallMs!
                  ? opHlcWall
                  : pg.olusturulduWallMs);
      }

      // [KIRMIZI] D2 -- null kanal korumasi PAZARLIKSIZ: her kanal okumasi
      // `as Map<String,Object?>? ?? const {}` bicimindedir.
      final fields = (payload['fields'] as Map<String, Object?>?) ?? const {};
      for (final girdi in fields.entries) {
        final ad = girdi.key;
        final yazim = girdi.value as Map<String, Object?>;
        final hlc = _hlcOku(yazim['hlc'] as Map<String, Object?>);
        final deger = yazim['value'] as String?;
        final anahtar = AlanAnahtari(
          wall: hlc.wallMs,
          counter: hlc.counter,
          clientId: hlc.clientId,
          opId: operationId,
        );
        if (g != null) {
          await _kanalUygula(
            entityType: entityType,
            entityId: entityId,
            alan: 'fields:$ad',
            anahtar: anahtar,
            g: g,
            kanalAdi: ad,
            fieldsDegeri: deger,
          );
        } else if (pg != null) {
          await _projeKanalUygula(
            entityType: entityType,
            entityId: entityId,
            alan: 'fields:$ad',
            anahtar: anahtar,
            pg: pg,
            fieldsDegeri: deger,
          );
        } else {
          await _metaDepo.degerlendirVeMetaYaz(
            entityType: entityType,
            entityId: entityId,
            alan: 'fields:$ad',
            gelenAnahtar: anahtar,
            kuyrukTabani: await kuyrukTabaniSaglayici(entityId, 'fields:$ad'),
          );
        }
      }

      final groups = (payload['groups'] as Map<String, Object?>?) ?? const {};
      for (final girdi in groups.entries) {
        final ad = girdi.key;
        final yazim = girdi.value as Map<String, Object?>;
        final hlc = _hlcOku(yazim['hlc'] as Map<String, Object?>);
        final grupFields =
            (yazim['fields'] as Map<String, Object?>?) ?? const {};
        final anahtar = AlanAnahtari(
          wall: hlc.wallMs,
          counter: hlc.counter,
          clientId: hlc.clientId,
          opId: operationId,
        );
        if (g != null) {
          await _kanalUygula(
            entityType: entityType,
            entityId: entityId,
            alan: 'groups:$ad',
            anahtar: anahtar,
            g: g,
            kanalAdi: ad,
            groupFields: grupFields,
          );
        } else if (pg != null) {
          await _projeKanalUygula(
            entityType: entityType,
            entityId: entityId,
            alan: 'groups:$ad',
            anahtar: anahtar,
            pg: pg,
            groupFields: grupFields,
          );
        } else {
          await _metaDepo.degerlendirVeMetaYaz(
            entityType: entityType,
            entityId: entityId,
            alan: 'groups:$ad',
            gelenAnahtar: anahtar,
            kuyrukTabani: await kuyrukTabaniSaglayici(entityId, 'groups:$ad'),
          );
        }
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
          gelenAnahtar: AlanAnahtari(
            wall: hlc.wallMs,
            counter: hlc.counter,
            clientId: hlc.clientId,
            opId: operationId,
          ),
          kuyrukTabani: await kuyrukTabaniSaglayici(entityId, 'order:$ad'),
        );
      }
      // ODEV.md §4(a): `sets` kanali ARTIK BAGLIDIR -- SINIR D2/1.4 KAPANDI.
      // 🔴 `_kanalUygula`/`degerlendirVeMetaYaz` BU YOLA GIRMEZ:
      // `UzakAlanDurumu`nun PK'si (entityType, entityId, alan) ALAN BASINA
      // TEK KAZANAN demektir; OR-Set'te "kazanan deger" YOKTUR, uyelik TAG
      // BASINADIR. Ayrica `hamAlanHlcCikar` bilinmeyen kanalda `StateError`
      // FIRLATIR ⇒ `sets` LWW meta/kuyruk-tabani yoluna ASLA baglanmaz.
      // 🔴 YAZILI SINIR [o76 denetimi]: `tags` DISINDAKI set adlari
      // (`assignees`, `checklistItems` -- registry'de Task icin GECERLI)
      // bu dilimde UYGULANMAZ. Sessiz degil, BEYAN EDILMIS bir sinirdir:
      // istemcide o setlerin ne tablosu ne ekrani vardir; `UzakAlanDurumu`ya
      // yazmak da YANLIS olurdu (OR-Set'te alan basina kazanan yoktur).
      // AYRICA: sets, VAR OLMAYAN bir entity icin gelirse etiket satiri
      // yazilir ama `Gorevler` satiri DOGMAZ (projeksiyon yalniz bilinen
      // kanallardan dogar) -- satir gorunmez durur, sonradan gelen entity
      // ile birlesir. Ikisi de DURUM.md/oturum belgesinde yazilidir.
      final sets = (payload['sets'] as Map<String, Object?>?) ?? const {};
      final tagsDelta = sets['tags'] as Map<String, Object?>?;
      if (tagsDelta != null) {
        await _etiketDeltaUygula(entityId, tagsDelta);
      }
    }
    await _projeksiyonYaz(guncellemeler);
    await _projeksiyonYazProje(projeGuncellemeleri);
  }

  /// ODEV.md §4(a) §4.2 birlestirme kurallari. IKISI DE IDEMPOTENT ve
  /// DEGISMELIDIR (hangi sirada gelirse gelsin sonuc AYNI):
  ///  - `adds`    ⇒ `insertOrIgnore` (VAR OLAN SATIRA DOKUNMA) ⇒ iptal
  ///    edilmis bir tag'in add'i OLU DOGAR = sunucunun `OrSetField`i.
  ///  - `removes` ⇒ her `observed` tag icin satir ACILIR ve `iptalEdildi=true`
  ///    yazilir; HIC GORULMEMIS bir tag icin de (sunucu `Cancelled.Add(...)`
  ///    ile AYNISINI yapar) -- iptal KALICIDIR, sonra gelen add OLU DOGAR.
  Future<void> _etiketDeltaUygula(
    String entityId,
    Map<String, Object?> delta,
  ) async {
    final adds = (delta['adds'] as List?) ?? const [];
    for (final ham in adds) {
      final add = ham as Map<String, Object?>;
      await _db
          .into(_db.gorevEtiketleri)
          .insert(
            GorevEtiketleriCompanion.insert(
              gorevId: entityId,
              etiket: add['el'] as String,
              addTag: add['tag'] as String,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }

    final removes = (delta['removes'] as List?) ?? const [];
    for (final ham in removes) {
      final remove = ham as Map<String, Object?>;
      final el = remove['el'] as String;
      final observed = (remove['observed'] as List?) ?? const [];
      for (final tag in observed) {
        await _db
            .into(_db.gorevEtiketleri)
            .insert(
              GorevEtiketleriCompanion.insert(
                gorevId: entityId,
                etiket: el,
                addTag: tag as String,
                iptalEdildi: const Value(true),
              ),
              onConflict: DoUpdate(
                (_) => const GorevEtiketleriCompanion(iptalEdildi: Value(true)),
              ),
            );
      }
    }
  }

  /// ODEV.md §4(a): snapshot uzlasmasi.
  /// 🔴 SNAPSHOT YALNIZ AKTIF TAG TASIR -- `SyncPuller` `Cancelled:false,
  /// Hlc: not null` suzgeci uygular (kaynaktan OLCULDU) ⇒ tombstone tele HIC
  /// CIKMAZ. Dolayisiyla "snapshot'ta yok" iki AYRI seyi birden anlatir:
  /// (a) uzakta iptal edildi, (b) benim add'im HENUZ GITMEDI. Ayrim
  /// KUYRUKTAN yapilir: tag'i yazan op hala `bekliyor`/`gonderildi` ise
  /// KORUNUR, degilse iptal edilir.
  ///
  /// Sunucu, TUM elemanlari iptal edilmis bir seti snapshot'a HIC KOYMAZ
  /// (`elements.Count > 0` kosulu) ⇒ 'tags' anahtarinin YOKLUGU "uzakta
  /// aktif etiket yok" demektir ve uzlasma YINE kosar. Ama `sets` ANAHTARI
  /// hic yoksa (kismi/eski bir snapshot) uzlasma KOSMAZ: yoklugu "etiket
  /// yok" diye okumak, kuyruga girmemis her yerel etiketi sessizce silerdi.
  Future<void> _etiketSnapshotUzlas(String entityId, List<Object?> sets) async {
    // 🔴 [OLCULDU -- bagimsiz denetim, o76] Anahtar (ELEMAN, TAG) CIFTIDIR,
    // yalniz tag DEGIL: sunucunun `OrSetField.ElementState`i uyeligi
    // (element, tag) basina tutar. Yalniz tag'e bakilsaydi, ayni tag baska
    // bir eleman altinda aktif gorunduginde yerel satir iptal edilmezdi.
    final uzaktakiCiftler = <(String, String)>{};
    for (final ham in sets) {
      final set = ham as Map<String, Object?>;
      if (set['setName'] != 'tags') continue;
      final elemanlar = (set['elements'] as List?) ?? const [];
      for (final hamEleman in elemanlar) {
        final eleman = hamEleman as Map<String, Object?>;
        final el = eleman['element'] as String;
        final aktifTagler = (eleman['activeTags'] as List?) ?? const [];
        for (final hamTag in aktifTagler) {
          final tag = (hamTag as Map<String, Object?>)['tag'] as String;
          uzaktakiCiftler.add((el, tag));
          // `insertOrIgnore`: YEREL TOMBSTONE KORUNUR -- kendi silmemiz
          // sunucuya henuz islenmediyse snapshot o tag'i hala AKTIF gosterir
          // ve satiri diriltmek kullanicinin sildigi etiketi geri getirirdi.
          await _db
              .into(_db.gorevEtiketleri)
              .insert(
                GorevEtiketleriCompanion.insert(
                  gorevId: entityId,
                  etiket: el,
                  addTag: tag,
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }
    }

    final yerelAktifler =
        await (_db.select(_db.gorevEtiketleri)..where(
              (t) => t.gorevId.equals(entityId) & t.iptalEdildi.equals(false),
            ))
            .get();
    final fazlalik = yerelAktifler
        .where((s) => !uzaktakiCiftler.contains((s.etiket, s.addTag)))
        .toList();
    if (fazlalik.isEmpty) return;

    final kuyruktakiler = await _kuyruktakiTagler(entityId);
    for (final satir in fazlalik) {
      if (kuyruktakiler.contains(satir.addTag)) continue; // KUYRUK KORUMASI
      await (_db.update(_db.gorevEtiketleri)..where(
            (t) =>
                t.gorevId.equals(satir.gorevId) &
                t.etiket.equals(satir.etiket) &
                t.addTag.equals(satir.addTag),
          ))
          .write(const GorevEtiketleriCompanion(iptalEdildi: Value(true)));
    }
  }

  /// Kuyruktaki (`bekliyor`/`gonderildi`) op govdelerinden `"tag":"<GUID>"`
  /// desenini cikarir. DECODE/RE-ENCODE YAPILMAZ (D1: govde yeniden
  /// uretilmez -- `hamAlanHlcCikar`in AYNI doktrini).
  /// `removes`in `observed`u BARE-STRING dizisidir (`["<guid>",...]`) ve bu
  /// desene TAKILMAZ ⇒ silme op'u kuyruktayken o tag KORUNMAZ; dogrusu da
  /// budur (kullanici o etiketi silmek istedi).
  Future<Set<String>> _kuyruktakiTagler(String entityId) async {
    final satirlar =
        await (_db.select(_db.senkronKuyrugu)..where(
              (t) =>
                  t.entityId.equals(entityId) &
                  t.durum.isIn(['bekliyor', 'gonderildi']),
            ))
            .get();
    final desen = RegExp('"tag":"([^"]+)"');
    return satirlar
        .expand((s) => desen.allMatches(s.govdeJson).map((m) => m.group(1)!))
        .toSet();
  }

  /// D2: `snapshot[i] = {entityType, entityId, scalars[], sets[], groups[]}`
  /// -- tie-break `winOperationId` DOGRUDAN gelir, uydurulmaz. BIRLESTIRICI:
  /// tablo temizlenmez, snapshotta olmayan yerel satir dokunulmadan durur.
  ///
  /// IS-EMRI-o85-A C2: `changesUygula`nin AYNI `entityType` dali -- `Project`
  /// varliklari snapshot'ta gelir (`ReadOwnedEntitiesAsync` entityType'tan
  /// bagimsizdir, o84/o85-A s1.3); dal acilmazsa liste TEMIZ KURULUMDA
  /// GORUNMEZ.
  Future<void> snapshotUygula(List<Map<String, Object?>> snapshot) async {
    final guncellemeler = <String, _GorevGuncellemesi>{};
    final projeGuncellemeleri = <String, _ProjeGuncellemesi>{};
    for (final entity in snapshot) {
      final entityType = entity['entityType'] as String;
      final entityId = entity['entityId'] as String;

      _GorevGuncellemesi? g;
      _ProjeGuncellemesi? pg;
      if (entityType == 'Task') {
        g = guncellemeler.putIfAbsent(entityId, () => _GorevGuncellemesi());
      } else if (entityType == 'Project') {
        pg = projeGuncellemeleri.putIfAbsent(
          entityId,
          () => _ProjeGuncellemesi(),
        );
      }

      final scalars = (entity['scalars'] as List?) ?? const [];
      for (final ham in scalars) {
        final scalar = ham as Map<String, Object?>;
        final ad = scalar['field'] as String;
        final hlc = _hlcOku(scalar['hlc'] as Map<String, Object?>);
        final winOpId = scalar['winOperationId'] as String;
        final anahtar = AlanAnahtari(
          wall: hlc.wallMs,
          counter: hlc.counter,
          clientId: hlc.clientId,
          opId: winOpId,
        );
        if (g != null) {
          g.olusturulduWallMs = g.olusturulduWallMs == null
              ? hlc.wallMs
              : (hlc.wallMs < g.olusturulduWallMs!
                    ? hlc.wallMs
                    : g.olusturulduWallMs);
          await _kanalUygula(
            entityType: entityType,
            entityId: entityId,
            alan: 'fields:$ad',
            anahtar: anahtar,
            g: g,
            kanalAdi: ad,
            fieldsDegeri: scalar['value'] as String?,
          );
        } else if (pg != null) {
          pg.olusturulduWallMs = pg.olusturulduWallMs == null
              ? hlc.wallMs
              : (hlc.wallMs < pg.olusturulduWallMs!
                    ? hlc.wallMs
                    : pg.olusturulduWallMs);
          await _projeKanalUygula(
            entityType: entityType,
            entityId: entityId,
            alan: 'fields:$ad',
            anahtar: anahtar,
            pg: pg,
            fieldsDegeri: scalar['value'] as String?,
          );
        } else {
          await _metaDepo.degerlendirVeMetaYaz(
            entityType: entityType,
            entityId: entityId,
            alan: 'fields:$ad',
            gelenAnahtar: anahtar,
            kuyrukTabani: await kuyrukTabaniSaglayici(entityId, 'fields:$ad'),
          );
        }
      }

      final groups = (entity['groups'] as List?) ?? const [];
      for (final ham in groups) {
        final grup = ham as Map<String, Object?>;
        final ad = grup['group'] as String;
        final hlc = _hlcOku(grup['hlc'] as Map<String, Object?>);
        final winOpId = grup['winOperationId'] as String;
        final grupFields =
            (grup['fields'] as Map<String, Object?>?) ?? const {};
        final anahtar = AlanAnahtari(
          wall: hlc.wallMs,
          counter: hlc.counter,
          clientId: hlc.clientId,
          opId: winOpId,
        );
        if (g != null) {
          g.olusturulduWallMs = g.olusturulduWallMs == null
              ? hlc.wallMs
              : (hlc.wallMs < g.olusturulduWallMs!
                    ? hlc.wallMs
                    : g.olusturulduWallMs);
          await _kanalUygula(
            entityType: entityType,
            entityId: entityId,
            alan: 'groups:$ad',
            anahtar: anahtar,
            g: g,
            kanalAdi: ad,
            groupFields: grupFields,
          );
        } else if (pg != null) {
          pg.olusturulduWallMs = pg.olusturulduWallMs == null
              ? hlc.wallMs
              : (hlc.wallMs < pg.olusturulduWallMs!
                    ? hlc.wallMs
                    : pg.olusturulduWallMs);
          await _projeKanalUygula(
            entityType: entityType,
            entityId: entityId,
            alan: 'groups:$ad',
            anahtar: anahtar,
            pg: pg,
            groupFields: grupFields,
          );
        } else {
          await _metaDepo.degerlendirVeMetaYaz(
            entityType: entityType,
            entityId: entityId,
            alan: 'groups:$ad',
            gelenAnahtar: anahtar,
            kuyrukTabani: await kuyrukTabaniSaglayici(entityId, 'groups:$ad'),
          );
        }
      }
      // ODEV.md §4(a): etiket uzlasmasi (SINIR D2/1.4 KAPANDI). `sets`
      // ANAHTARI VARSA -- bos liste OLSA BILE -- kosar; anahtar HIC YOKSA
      // kosmaz (gerekce `_etiketSnapshotUzlas` belgesinde).
      if (entity.containsKey('sets')) {
        await _etiketSnapshotUzlas(
          entityId,
          (entity['sets'] as List?) ?? const [],
        );
      }
    }
    await _projeksiyonYaz(guncellemeler);
    await _projeksiyonYazProje(projeGuncellemeleri);
  }

  /// Tek bir kanalin (`fields:ad` ya da `groups:ad`) meta+projeksiyon
  /// kararini verir; kazanirsa `g`ye YALNIZ BILINEN UC ALANIN esini yazar.
  /// [KIRMIZI] D2 -- BILINMEYEN ALAN SESSIZCE ATLANMAZ: `_metaDepo` her
  /// zaman cagrilir (UzakAlanDurumu'na yazilir), projeksiyon eslemesi
  /// yalniz `title`/`completion`/`isDeleted`/`priority`/`dueAt` icin vardir.
  /// 🔴 CAKISMA TESPITI bu iki YENI alan icin KAPSAM DISIDIR (`kanonikDize`
  /// yalniz `fields:title` ve `groups:completion` tanir ve digerinde FIRLAR)
  /// -- sinir DURUM.md'ye yazildi.
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

    // D4: yalniz BES eslemeden biri -- rozete (senkronDurumu) ASLA dokunulmaz.
    if (alan == 'fields:title') {
      g.baslik = fieldsDegeri ?? '';
      g.baslikKazananAnahtari = anahtar; // GOREV-SS2 D-SS2-2/1
      g.herhangiBirKanalKazandi = true;
      g.guncellendiWallMs = g.guncellendiWallMs == null
          ? anahtar.wall
          : (anahtar.wall > g.guncellendiWallMs!
                ? anahtar.wall
                : g.guncellendiWallMs);
    } else if (alan == 'fields:isDeleted') {
      // [KIRMIZI] D4 -- Ordinal, TAM dize karsilastirma. "True"/"TRUE" silinmis SAYILMAZ.
      g.silindi = fieldsDegeri == 'true';
      g.herhangiBirKanalKazandi = true;
      g.guncellendiWallMs = g.guncellendiWallMs == null
          ? anahtar.wall
          : (anahtar.wall > g.guncellendiWallMs!
                ? anahtar.wall
                : g.guncellendiWallMs);
    } else if (alan == 'fields:priority') {
      // Sunucunun `ReadInt`iyle AYNI SONUC: ayristirilamayan deger NULL'a
      // duser. FARK (SINIR, DURUM.md'ye yazildi): sunucu ayrica
      // `MalformedFields` listesi tutar, istemcide o liste YOKTUR; ayrica
      // .NET `NumberStyles.Integer` bastaki/sondaki bosluga izin verir,
      // Dart'in `int.tryParse`i vermez -- ikisi de bizim URETTIGIMIZ tel
      // bicimi icin (bosluksuz ondalik) AYNI davranir.
      g.oncelik = fieldsDegeri == null ? null : int.tryParse(fieldsDegeri);
      g.oncelikGeldi = true;
      g.herhangiBirKanalKazandi = true;
      g.guncellendiWallMs = g.guncellendiWallMs == null
          ? anahtar.wall
          : (anahtar.wall > g.guncellendiWallMs!
                ? anahtar.wall
                : g.guncellendiWallMs);
    } else if (alan == 'fields:dueAt') {
      // TAKVIM GUNU PINI: gelen dize UTC'dir (sunucu `AdjustToUniversal`
      // ile kanoniklestirir, biz de `DateTime.utc(y,m,d)` gonderiyoruz) --
      // `.toUtc()` yalniz garantiyi PEKISTIRIR, gun kaydirmaz.
      // SINIR: `DateTime.tryParse` sunucunun `TryParseExact`inden DAHA
      // MUSAMAHAKARDIR; okuma yonunde bu guvenlidir (gonderen bicimi biz
      // pinliyoruz), yazma yonunde degil.
      g.sonTarih = fieldsDegeri == null
          ? null
          : DateTime.tryParse(fieldsDegeri)?.toUtc();
      g.sonTarihGeldi = true;
      g.herhangiBirKanalKazandi = true;
      g.guncellendiWallMs = g.guncellendiWallMs == null
          ? anahtar.wall
          : (anahtar.wall > g.guncellendiWallMs!
                ? anahtar.wall
                : g.guncellendiWallMs);
    } else if (alan == 'fields:projectId') {
      // IS-EMRI-o85-A C3: `null` = Gelen Kutusu (K4) -- oncelik/sonTarih'in
      // AYNI "geldi mi" bayrak deseni. Cakisma tespiti KAPSAM DISI (asagida,
      // `_projeksiyonYaz`'da `_cakismaTespitEtVeYaz` bu alan icin CAGRILMAZ).
      g.projeId = fieldsDegeri;
      g.projeIdGeldi = true;
      g.herhangiBirKanalKazandi = true;
      g.guncellendiWallMs = g.guncellendiWallMs == null
          ? anahtar.wall
          : (anahtar.wall > g.guncellendiWallMs!
                ? anahtar.wall
                : g.guncellendiWallMs);
    } else if (alan == 'groups:completion') {
      final status = groupFields?['status'] as String?;
      g.tamamlandi = status == 'done'; // Ordinal, TAM dize
      g.tamamlandiKazananAnahtari = anahtar; // GOREV-SS2 D-SS2-2/1
      g.herhangiBirKanalKazandi = true;
      g.guncellendiWallMs = g.guncellendiWallMs == null
          ? anahtar.wall
          : (anahtar.wall > g.guncellendiWallMs!
                ? anahtar.wall
                : g.guncellendiWallMs);
    }
    // Bilinmeyen alan: UzakAlanDurumu'na YAZILDI (yukarida), projeksiyona DOKUNULMADI.
  }

  /// IS-EMRI-o85-A C1: `_kanalUygula`nin `Project` esdegeri -- yalniz IKI
  /// eslemesi var (`fields:name`, `fields:isDeleted`). Meta karari AYNI
  /// `_metaDepo.degerlendirVeMetaYaz` cagrisidir -- PK zaten
  /// `(entityType, entityId, alan)`, Task/Project entity id'leri arasinda
  /// CARPISMA YOKTUR (UUID). C3: bu iki alan icin de cakisma tespiti
  /// KAPSAM DISIDIR -- `kanonikDize` cagrilmaz (`priority`/`dueAt`in Task
  /// tarafinda yazilan sinirin AYNISI).
  Future<void> _projeKanalUygula({
    required String entityType,
    required String entityId,
    required String alan,
    required AlanAnahtari anahtar,
    required _ProjeGuncellemesi pg,
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

    if (alan == 'fields:name') {
      pg.ad = fieldsDegeri ?? '';
      pg.herhangiBirKanalKazandi = true;
    } else if (alan == 'fields:isDeleted') {
      // [KIRMIZI] D4 -- Ordinal, TAM dize karsilastirma (Task tarafinin
      // AYNI kurali, satir ~442).
      pg.silindi = fieldsDegeri == 'true';
      pg.herhangiBirKanalKazandi = true;
    }
    // Bilinmeyen alan: UzakAlanDurumu'na YAZILDI (yukarida), projeksiyona DOKUNULMADI.
  }

  Future<void> _projeksiyonYaz(
    Map<String, _GorevGuncellemesi> guncellemeler,
  ) async {
    for (final girdi in guncellemeler.entries) {
      final entityId = girdi.key;
      final g = girdi.value;
      if (!g.herhangiBirKanalKazandi) continue;

      final mevcut = await (_db.select(
        _db.gorevler,
      )..where((t) => t.id.equals(entityId))).getSingleOrNull();
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
                olusturuldu: DateTime.fromMillisecondsSinceEpoch(
                  olusturulduWall,
                  isUtc: true,
                ),
                guncellendi: DateTime.fromMillisecondsSinceEpoch(
                  guncellendiWall,
                  isUtc: true,
                ),
                silindi: Value(g.silindi ?? false),
                oncelik: Value(g.oncelik),
                sonTarih: Value(g.sonTarih),
                projeId: Value(g.projeId),
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
          tamamlandi: g.tamamlandi != null
              ? Value(g.tamamlandi!)
              : const Value.absent(),
          silindi: g.silindi != null ? Value(g.silindi!) : const Value.absent(),
          // ODEV.md §4(a): "geldi mi" BAYRAGI ile karar verilir -- `g.oncelik
          // != null` demek, gelen bir "temizle" (null) yazimini SESSIZCE
          // DUSURURDU.
          oncelik: g.oncelikGeldi ? Value(g.oncelik) : const Value.absent(),
          sonTarih: g.sonTarihGeldi ? Value(g.sonTarih) : const Value.absent(),
          // IS-EMRI-o85-A C3: cakisma tespiti KAPSAM DISI -- asagida
          // `_cakismaTespitEtVeYaz` bu alan icin CAGRILMAZ (priority/dueAt
          // ile AYNI sinir, kanonikDize 'fields:projectId' TANIMAZ).
          projeId: g.projeIdGeldi ? Value(g.projeId) : const Value.absent(),
          guncellendi: g.guncellendiWallMs != null
              ? Value(
                  DateTime.fromMillisecondsSinceEpoch(
                    g.guncellendiWallMs!,
                    isUtc: true,
                  ),
                )
              : const Value.absent(),
          // senkronDurumu YAZILMAZ (D4 PAZARLIKSIZ -- rozet dokunulmazligi).
        );
        await (_db.update(
          _db.gorevler,
        )..where((t) => t.id.equals(entityId))).write(companion);

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

  /// IS-EMRI-o85-A C1: `_projeksiyonYaz`nin `Project` esdegeri --
  /// `Projeler`de `guncellendi` sutunu YOK (K3), bu yuzden Task tarafinin
  /// `guncellendiWallMs` izlemesi burada YOKTUR. C3: cakisma tespiti
  /// KAPSAM DISI -- `_cakismaTespitEtVeYaz`/`kanonikDize` cagrilmaz.
  Future<void> _projeksiyonYazProje(
    Map<String, _ProjeGuncellemesi> guncellemeler,
  ) async {
    for (final girdi in guncellemeler.entries) {
      final entityId = girdi.key;
      final pg = girdi.value;
      if (!pg.herhangiBirKanalKazandi) continue;

      final mevcut = await (_db.select(
        _db.projeler,
      )..where((t) => t.id.equals(entityId))).getSingleOrNull();
      if (mevcut == null) {
        // D4/B3 esdegeri: YENI entity -- Projeler'e kurala bagli INSERT.
        final olusturulduWall = pg.olusturulduWallMs ?? 0;
        await _db
            .into(_db.projeler)
            .insert(
              ProjelerCompanion.insert(
                id: entityId,
                ad: pg.ad ?? '',
                silindi: Value(pg.silindi ?? false),
                olusturuldu: DateTime.fromMillisecondsSinceEpoch(
                  olusturulduWall,
                  isUtc: true,
                ),
              ),
            );
      } else {
        await (_db.update(
          _db.projeler,
        )..where((t) => t.id.equals(entityId))).write(
          ProjelerCompanion(
            ad: pg.ad != null ? Value(pg.ad!) : const Value.absent(),
            silindi: pg.silindi != null
                ? Value(pg.silindi!)
                : const Value.absent(),
          ),
        );
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

    final mevcutKayit =
        await (_db.select(_db.cakismaKayitlari)
              ..where((t) => t.entityId.equals(entityId) & t.alan.equals(alan)))
            .getSingleOrNull();

    if (mevcutKayit == null) {
      if (kazananBiziz) return; // sart 3
      final bekleyenVar = await bekleyenYerelYazimVarMi(entityId, alan);
      if (!bekleyenVar) return; // sart 2
      if (kanonikEski == kanonikYeni) return; // sart 4
      await _db
          .into(_db.cakismaKayitlari)
          .insert(
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
      await (_db.update(
        _db.cakismaKayitlari,
      )..where((t) => t.entityId.equals(entityId) & t.alan.equals(alan))).write(
        CakismaKayitlariCompanion(
          kazananDeger: Value(kanonikYeni),
          kazananClientHex: Value(kazananAnahtari.clientHex),
          // kaybedenDeger KORUNUR -- yazilmiyor.
        ),
      );
    }
  }
}

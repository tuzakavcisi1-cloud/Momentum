// ignore_for_file: prefer_initializing_formals -- alanlar bilerek PRIVATE
// (`_db` vb.), yapici parametreleri ise PUBLIC adlandirilmis (`db` vb.);
// `this._db` seklinde yazmak parametre adini da private yapip disaridan
// adlandirilmis argumanla cagirmayi imkansizlastirirdi.

import 'dart:convert';

import 'package:drift/drift.dart';

import '../ag/senkron_agi.dart';
import 'ayarlar_deposu.dart';
import 'hlc.dart';
import 'veritabani.dart';

/// GOREV-slice-3c T6: senkron dongusu -- D4 (tek uçuş, toplu gönderim
/// tavanı 100) + D8/2 (`gonderildi` kurtarma) + D5 (sonuç işleme) + D9
/// (yanıt sınıflandırma) BURADA birlesir. `HlcUretici` D3'un damgasini,
/// `AyarlarDeposu` D6'nin imlecini tasir -- ikisi de UYGULAMA GENELINDE
/// TEK ORNEKTIR (main.dart bunlari DriftGorevDeposu ile PAYLASIR).
class SenkronDongusu {
  static const int _denemeTavani = 8;

  final Veritabani _db;
  final SenkronAgi _agi;
  final AyarlarDeposu _ayarlarDeposu;
  final HlcUretici _hlc;
  final String _clientId;

  String? _mevcutCursorJson;

  Future<void>? _devamEdenTur;

  SenkronDongusu({
    required Veritabani db,
    required SenkronAgi agi,
    required AyarlarDeposu ayarlarDeposu,
    required HlcUretici hlc,
    required String clientId,
    String? baslangicCursorJson,
  }) : _db = db,
       _agi = agi,
       _ayarlarDeposu = ayarlarDeposu,
       _hlc = hlc,
       _clientId = clientId,
       _mevcutCursorJson = baslangicCursorJson;

  /// D4 PAZARLIKSIZ: aynı anda en fazla BİR tur. Zaten devam eden bir tur
  /// varsa yeni bir tur BAŞLATMAZ, onun bitmesini bekler -- zamanlayıcı +
  /// elle tetik + "bağlantı geri geldi" olayı çakışsa bile sahte ağa giden
  /// istek sayısı tek turdan fazla olmaz, `denemeSayisi` çift artmaz.
  Future<void> turCalistir() {
    final devamEden = _devamEdenTur;
    if (devamEden != null) return devamEden;
    final tur = _turCalistirIc();
    _devamEdenTur = tur;
    return tur.whenComplete(() => _devamEdenTur = null);
  }

  /// D8/2: uçuş işareti olan (`gonderildi`) TÜM satırları `bekliyor`e
  /// döndürür. Uygulama açılışında AYRICA (tur beklemeden) çağrılmalıdır --
  /// `turCalistir()` zaten her turun başında bunu yapar.
  Future<void> gonderildiKurtar() async {
    await (_db.update(
      _db.senkronKuyrugu,
    )..where((t) => t.durum.equals('gonderildi'))).write(
      const SenkronKuyruguCompanion(durum: Value('bekliyor')),
    );
  }

  Future<void> _turCalistirIc() async {
    await gonderildiKurtar();

    while (true) {
      final secilenler = await _bekleyenleriSec();
      if (secilenler.isEmpty) return;

      await (_db.update(_db.senkronKuyrugu)..where(
            (t) => t.opId.isIn(secilenler.map((s) => s.opId)),
          ))
          .write(const SenkronKuyruguCompanion(durum: Value('gonderildi')));

      final govde = _istekGovdesiOlustur(secilenler);
      final sonuc = await _agi.gonder(govde);

      switch (sonuc) {
        case SenkronBasarili(:final govdeJson):
          await _basariliYanitIsle(govdeJson, secilenler);
        // basarili -- kuyrukta baska bekleyen varsa dongu devam eder.
        case SenkronHttpHatasi(:final durumKodu):
          await _httpHatasiIsle(durumKodu, secilenler);
          return; // D9: 4xx/401/5xx sonrasi devam etmenin anlami yok.
        case SenkronAgHatasi():
          await _bekliyorGeriDondurVeDenemeArtir(
            secilenler,
            basariRozeti: 'cevrimdisi',
          );
          return;
      }
    }
  }

  Future<List<SenkronKuyruguRow>> _bekleyenleriSec() {
    return (_db.select(_db.senkronKuyrugu)
          ..where((t) => t.durum.equals('bekliyor'))
          ..orderBy([
            (t) => OrderingTerm(expression: t.hlcWallMs),
            (t) => OrderingTerm(expression: t.hlcCounter),
            (t) => OrderingTerm(expression: t.opId),
          ])
          ..limit(100))
        .get();
  }

  /// D6 PAZARLIKSIZ: `sinceCursor`/her opun `govdeJson`'u HAM METİN olarak
  /// gömülür -- decode/re-encode YOK (D1: govde yeniden üretilmez; D6:
  /// `Xid` `ulong`, sayıya çevirmek yasak).
  String _istekGovdesiOlustur(List<SenkronKuyruguRow> secilenler) {
    final opsJoined = secilenler.map((s) => s.govdeJson).join(',');
    final cursor = _mevcutCursorJson ?? 'null';
    return '{"clientId":${jsonEncode(_clientId)},"clientHlc":null,'
        '"sinceCursor":$cursor,"ops":[$opsJoined]}';
  }

  Future<void> _basariliYanitIsle(
    String govdeJson,
    List<SenkronKuyruguRow> gonderilenler,
  ) async {
    final govde = jsonDecode(govdeJson) as Map<String, Object?>;
    final appliedListesi = (govde['applied'] as List)
        .cast<Map<String, Object?>>();
    final resyncRequired = govde['resyncRequired'] as bool? ?? false;
    final opIdToRow = {for (final r in gonderilenler) r.opId: r};

    await _db.transaction(() async {
      final serverHlcJson = govde['serverHlc'] as Map<String, Object?>?;
      if (serverHlcJson != null) {
        _hlc.yanitIsle(serverHlc: _hlcFromJson(serverHlcJson));
      }

      for (final sonuc in appliedListesi) {
        final opId = sonuc['operationId'] as String;
        final satir = opIdToRow[opId];
        if (satir == null) continue; // beklenmedik -- guvenlik agi

        final code = sonuc['code'] as String;
        final effectiveOpHlcJson =
            sonuc['effectiveOpHlc'] as Map<String, Object?>?;
        if (effectiveOpHlcJson != null) {
          _hlc.yanitIsle(effectiveOpHlc: _hlcFromJson(effectiveOpHlcJson));
        }

        await _tekSonucIsle(satir, code);
      }

      await _ayarlarDeposu.hlcKalicilastir(_hlc.sonWall, _hlc.sonCounter);

      if (resyncRequired) {
        _mevcutCursorJson = null;
      } else {
        _mevcutCursorJson = _hamCursorCikar(govdeJson);
      }
      await _ayarlarDeposu.nextCursorKalicilastir(_mevcutCursorJson);
    });
  }

  /// D5: op bazında sonuç işleme + `cakisma` kilidi.
  Future<void> _tekSonucIsle(SenkronKuyruguRow satir, String code) async {
    switch (code) {
      case 'Applied':
      case 'Duplicate':
        await (_db.delete(
          _db.senkronKuyrugu,
        )..where((t) => t.opId.equals(satir.opId))).go();
        final zehirliSayisi =
            await (_db.selectOnly(_db.senkronKuyrugu)
                  ..addColumns([_db.senkronKuyrugu.opId.count()])
                  ..where(
                    _db.senkronKuyrugu.entityId.equals(satir.entityId) &
                        _db.senkronKuyrugu.durum.equals('zehirli'),
                  ))
                .map((r) => r.read(_db.senkronKuyrugu.opId.count())!)
                .getSingle();
        // D5 PAZARLIKSIZ ("cakisma KİLİTLENİR"): bu görev için başka bir
        // zehirli satır varsa Applied/Duplicate onu senkronize YAPAMAZ.
        if (zehirliSayisi == 0) {
          await _rozetYaz(satir.entityId, 'senkronize');
        }
      default:
        // RejectedRegistryViolation / RejectedAbsurdHlc / RejectedInvalid /
        // RejectedSetCapExceeded / tanınmayan kod -- HEPSİ aynı: zehirli,
        // satır SİLİNMEZ (sessiz veri kaybı yok), sonHataKodu ham kod.
        await (_db.update(_db.senkronKuyrugu)..where(
              (t) => t.opId.equals(satir.opId),
            ))
            .write(
              SenkronKuyruguCompanion(
                durum: const Value('zehirli'),
                sonHataKodu: Value(code),
              ),
            );
        await _rozetYaz(satir.entityId, 'cakisma');
    }
  }

  /// D9: 401 hariç HER 4xx -- tur DURUR, `denemeSayisi` ARTMAZ, satırlar
  /// `bekliyor` kalır. 401 ve 5xx ise ağ hatasıyla AYNI muameleyi görür.
  Future<void> _httpHatasiIsle(
    int durumKodu,
    List<SenkronKuyruguRow> gonderilenler,
  ) async {
    if (durumKodu == 401 || durumKodu >= 500) {
      await _bekliyorGeriDondurVeDenemeArtir(
        gonderilenler,
        basariRozeti: 'cevrimdisi',
        sonHataKodu: 'http-$durumKodu',
      );
    } else {
      await _db.transaction(() async {
        for (final satir in gonderilenler) {
          await (_db.update(_db.senkronKuyrugu)..where(
                (t) => t.opId.equals(satir.opId),
              ))
              .write(
                SenkronKuyruguCompanion(
                  durum: const Value('bekliyor'),
                  sonHataKodu: Value('http-$durumKodu'),
                ),
              );
          await _rozetYaz(satir.entityId, 'cakisma');
        }
      });
    }
  }

  /// D9: ağ hatası/zaman aşımı VE 401/5xx için ortak yol -- `bekliyor`,
  /// `denemeSayisi++`; `denemeSayisi > 8` ⇒ `zehirli` + `deneme-tavani`
  /// (D9 kirmizi uyari: denemeSayisi ÖLÜ SAYAÇ OLAMAZ).
  Future<void> _bekliyorGeriDondurVeDenemeArtir(
    List<SenkronKuyruguRow> satirlar, {
    required String basariRozeti,
    String? sonHataKodu,
  }) async {
    await _db.transaction(() async {
      for (final satir in satirlar) {
        final yeniDeneme = satir.denemeSayisi + 1;
        if (yeniDeneme > _denemeTavani) {
          await (_db.update(_db.senkronKuyrugu)..where(
                (t) => t.opId.equals(satir.opId),
              ))
              .write(
                SenkronKuyruguCompanion(
                  durum: const Value('zehirli'),
                  denemeSayisi: Value(yeniDeneme),
                  sonHataKodu: const Value('deneme-tavani'),
                ),
              );
          await _rozetYaz(satir.entityId, 'cakisma');
        } else {
          await (_db.update(_db.senkronKuyrugu)..where(
                (t) => t.opId.equals(satir.opId),
              ))
              .write(
                SenkronKuyruguCompanion(
                  durum: const Value('bekliyor'),
                  denemeSayisi: Value(yeniDeneme),
                  sonHataKodu: Value(sonHataKodu),
                ),
              );
          await _rozetYaz(satir.entityId, basariRozeti);
        }
      }
    });
  }

  Future<void> _rozetYaz(String entityId, String senkronDurumu) async {
    await (_db.update(
      _db.gorevler,
    )..where((t) => t.id.equals(entityId))).write(
      GorevlerCompanion(senkronDurumu: Value(senkronDurumu)),
    );
  }

  Hlc _hlcFromJson(Map<String, Object?> json) => Hlc(
    wallMs: json['wallMs'] as int,
    counter: json['counter'] as int,
    clientId: json['clientId'] as String,
  );

  /// D6 PAZARLIKSIZ: `nextCursor`'ın HAM alt-metnini (decode etmeden)
  /// çıkarır -- `WireCursor` yalnız iki düz alan taşır (`Xid`,`Seq`),
  /// iç içe süslü parantez YOKTUR, bu yüzden `[^}]*` güvenlidir.
  String? _hamCursorCikar(String govdeJson) {
    final eslesme = RegExp(
      r'"nextCursor"\s*:\s*(null|\{[^}]*\})',
    ).firstMatch(govdeJson);
    if (eslesme == null) return null;
    final deger = eslesme.group(1)!;
    return deger == 'null' ? null : deger;
  }
}

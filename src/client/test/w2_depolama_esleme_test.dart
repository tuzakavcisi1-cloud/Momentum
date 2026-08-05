// GOREV-W2 T10 -- G39 (eslesme kapisi) + G41 (drift sozlesme pini).
// @TestOn('vm') YAZILMAZ: depolama_durumu.dart drift'i hic import etmez
// (D-W2-1), bu dosyanin G39 yarisi dart:io da drift'in web tarafini da
// gerektirmez. G41 yalniz VM-guvenli `wasm_setup/types.dart`'i import eder
// (dosyanin kendi basligi: "imported in integration tests on a Dart VM") --
// o da web'de calisir, @TestOn('vm') GEREKMEZ.

import 'package:client/veri/depolama_durumu.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: implementation_imports
import 'package:drift/src/web/wasm_setup/types.dart';

void main() {
  group('G39 -- eslesme kapisi (depolamaSinifiCoz)', () {
    test('G39/a — opfsShared+opfs ve opfsLocks+opfs ⇒ kaliciOpfs (pozitif kontrol)', () {
      expect(
        depolamaSinifiCoz(uygulamaAdi: 'opfsShared', depolamaApi: 'opfs'),
        DepolamaSinifi.kaliciOpfs,
      );
      expect(
        depolamaSinifiCoz(uygulamaAdi: 'opfsLocks', depolamaApi: 'opfs'),
        DepolamaSinifi.kaliciOpfs,
      );
    });

    test('G39/b — opfsQuantum+opfs (bilinmeyen ad) ⇒ geriDusus', () {
      expect(
        depolamaSinifiCoz(uygulamaAdi: 'opfsQuantum', depolamaApi: 'opfs'),
        DepolamaSinifi.geriDusus,
      );
    });

    test('G39/c — sharedIndexedDb+null ve unsafeIndexedDb+indexedDb ⇒ geriDusus', () {
      expect(
        depolamaSinifiCoz(uygulamaAdi: 'sharedIndexedDb', depolamaApi: null),
        DepolamaSinifi.geriDusus,
      );
      expect(
        depolamaSinifiCoz(uygulamaAdi: 'unsafeIndexedDb', depolamaApi: 'indexedDb'),
        DepolamaSinifi.geriDusus,
      );
    });

    test('G39/d — inMemory+null ⇒ kaliciDegil', () {
      expect(
        depolamaSinifiCoz(uygulamaAdi: 'inMemory', depolamaApi: null),
        DepolamaSinifi.kaliciDegil,
      );
    });

    test('G39/e — opfsShared+webSql (bilinmeyen api) ⇒ geriDusus', () {
      expect(
        depolamaSinifiCoz(uygulamaAdi: 'opfsShared', depolamaApi: 'webSql'),
        DepolamaSinifi.geriDusus,
      );
    });

    test('G39/g — null+null ⇒ geriDusus (uretimde erisilemez, guvenli taraf yine de olculur)', () {
      expect(
        depolamaSinifiCoz(uygulamaAdi: null, depolamaApi: null),
        DepolamaSinifi.geriDusus,
      );
    });
  });

  group('G41 -- drift sozlesme pini (gercek enum)', () {
    test(
      'G41/a — WasmStorageImplementation/WebStorageApi gercek degerleri T1 kumelerini kapsar (pozitif kontrol)',
      () {
        final gercekUygulamaAdlari = WasmStorageImplementation.values
            .map((e) => e.name)
            .toSet();
        final beklenenAdlar = <String>{
          ...kaliciOpfsAdlari,
          ...geriDususAdlari,
          kaliciDegilAdi,
        };
        expect(
          gercekUygulamaAdlari.containsAll(beklenenAdlar),
          isTrue,
          reason:
              'drift gercek enum degerleri T1 kumesini kapsamiyor -- '
              'gercek: $gercekUygulamaAdlari, beklenen: $beklenenAdlar',
        );

        final gercekApiAdlari = WebStorageApi.values.map((e) => e.name).toSet();
        expect(
          gercekApiAdlari,
          {'opfs', 'indexedDb'},
          reason: 'drift gercek WebStorageApi kumesi degisti -- pin bayatladi: $gercekApiAdlari',
        );
      },
    );
  });
}

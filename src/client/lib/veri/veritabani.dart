import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'veritabani.g.dart';

/// GOREV-slice-3b T4: `gorevler` tablosu.
/// senkronDurumu bu dilimde yalniz 'yerel' degerini alabilir (CHECK kisiti) --
/// gercek senkron durumlari K42-d adim 3'te eklenir.
@DataClassName('GorevRow')
class Gorevler extends Table {
  TextColumn get id => text()();
  TextColumn get baslik => text()();
  BoolColumn get tamamlandi => boolean().withDefault(const Constant(false))();
  DateTimeColumn get olusturuldu => dateTime()();
  DateTimeColumn get guncellendi => dateTime()();
  TextColumn get senkronDurumu => text()
      // ignore: recursive_getters
      .check(senkronDurumu.equals('yerel'))
      .withDefault(const Constant('yerel'))();
  BoolColumn get silindi => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Gorevler])
class Veritabani extends _$Veritabani {
  Veritabani([QueryExecutor? baglanti]) : super(baglanti ?? _uretimBaglantisi());

  @override
  int get schemaVersion => 1;

  /// isUtc==true garantisi (G7 kriter 4) storeDateTimeAsText ile gelir:
  /// UTC DateTime -> toIso8601String() ('Z' sonekli) -> DateTime.parse geri
  /// okumada isUtc=true dondurur (bkz. drift SqlTypes._readDateTime).
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

QueryExecutor _uretimBaglantisi() {
  return driftDatabase(
    name: 'momentum',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
      // G6 KANITI: chosenImplementation/missingFeatures HER ZAMAN basilir --
      // drift_flutter'in varsayilan isleyicisi yalniz missingFeatures doluyken
      // basar; G6'nin pozitif olcumu (opfs* secildi) icin bu yetersizdir.
      onResult: (sonuc) {
        // ignore: avoid_print
        print(
          'MOMENTUM-G6-KANIT chosenImplementation=${sonuc.chosenImplementation} '
          'missingFeatures=${sonuc.missingFeatures}',
        );
      },
    ),
  );
}

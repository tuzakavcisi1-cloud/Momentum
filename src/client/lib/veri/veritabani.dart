import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'veritabani.g.dart';

/// GOREV-slice-3b T4 + slice-3c T2: `gorevler` tablosu.
/// senkronDurumu artik bes deger alabilir (CHECK kisiti, migration v1->v2,
/// GOREV-slice-3c D1) -- gercek senkron durumlari burada eklendi.
@DataClassName('GorevRow')
class Gorevler extends Table {
  TextColumn get id => text()();
  TextColumn get baslik => text()();
  BoolColumn get tamamlandi => boolean().withDefault(const Constant(false))();
  DateTimeColumn get olusturuldu => dateTime()();
  DateTimeColumn get guncellendi => dateTime()();
  TextColumn get senkronDurumu => text()
      .check(
        // ignore: recursive_getters
        senkronDurumu.isIn([
          'yerel',
          'kuyrukta',
          'senkronize',
          'cakisma',
          'cevrimdisi',
        ]),
      )
      .withDefault(const Constant('yerel'))();
  BoolColumn get silindi => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// GOREV-slice-3c D1: cikis kuyrugu. `govdeJson` UretIM ANINDA donar ve
/// gonderim aninda YENIDEN URETILMEZ (HLC damgasini ileri kaydirmamak icin --
/// bkz. D1 kirmizi uyari). Okuma sirasi (hlcWallMs, hlcCounter, opId) artan;
/// ucuncu anahtar (opId, PK) pazarliksiz tie-break'tir.
@DataClassName('SenkronKuyruguRow')
class SenkronKuyrugu extends Table {
  TextColumn get opId => text()();
  TextColumn get clientId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get govdeJson => text()();
  IntColumn get hlcWallMs => integer()();
  IntColumn get hlcCounter => integer()();
  TextColumn get durum => text()
      // ignore: recursive_getters
      .check(durum.isIn(['bekliyor', 'gonderildi', 'zehirli']))
      .withDefault(const Constant('bekliyor'))();
  IntColumn get denemeSayisi => integer().withDefault(const Constant(0))();
  TextColumn get sonHataKodu => text().nullable()();
  DateTimeColumn get olusturuldu => dateTime()();

  @override
  Set<Column> get primaryKey => {opId};
}

/// GOREV-slice-3c T3 (D3, D6, D7): tek-satirlik cihaz ayarlari. `id` daima
/// `1` -- tek satir garantisi uygulama katmaninda (AyarlarDeposu) saglanir.
@DataClassName('AyarRow')
class Ayarlar extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get clientId => text()();
  IntColumn get sonWall => integer().withDefault(const Constant(0))();
  IntColumn get sonCounter => integer().withDefault(const Constant(0))();
  TextColumn get nextCursorJson => text().nullable()();
  TextColumn get devUserId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Gorevler, SenkronKuyrugu, Ayarlar])
class Veritabani extends _$Veritabani {
  Veritabani([QueryExecutor? baglanti]) : super(baglanti ?? _uretimBaglantisi());

  @override
  int get schemaVersion => 3;

  /// GOREV-slice-3c D1/T3: v1->v2 SQLite bir CHECK kisitini ALTER TABLE ile
  /// degistiremez -- `gorevler` (yeni 5-degerli CHECK ile) `TableMigration`
  /// ile YENIDEN YARATILIR; veri `columnTransformer` OLMADAN kopyalanir
  /// (sutun adlari/tipleri degismedi, yalniz CHECK genisledi). v2->v3 salt
  /// eklemelidir (`ayarlar`), CHECK/tip degisikligi yok.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(senkronKuyrugu);
        await m.alterTable(TableMigration(gorevler));
      }
      if (from < 3) {
        await m.createTable(ayarlar);
      }
    },
  );

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

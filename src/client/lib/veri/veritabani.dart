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
  // GOREV-slice-3d D7/4: imlecin AIT OLDUGU devUserId. devUserId degisirse
  // (bugun cagrilmayan devUserIdDegistir haric hicbir akista) imlec +
  // UzakAlanDurumu sifirlanir -- eski satir (migration'dan gelen) null'dir
  // ve SAHIPSIZ sayilir (D7/4).
  TextColumn get imlecSahibi => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// GOREV-slice-3d D1: yerel LWW meta tablosu. `Gorevler` SAF PROJEKSIYON
/// kalir -- HLC/versiyon bilgisi burada, ayri tabloda durur. `alan`
/// KANAL-NITELIKLI'dir (`fields:title`, `groups:completion`, `order:listPos`)
/// -- bir grubun TEK HLC'si vardir, uyeleri ayri damgalanmaz.
@DataClassName('UzakAlanDurumuRow')
class UzakAlanDurumu extends Table {
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get alan => text()();
  IntColumn get hlcWall => integer()();
  IntColumn get hlcCounter => integer()();
  TextColumn get hlcClientId => text()();
  TextColumn get winOpId => text()();

  @override
  Set<Column> get primaryKey => {entityType, entityId, alan};
}

/// GOREV-SS2 D-SS2-1: cakisma kayitlari, salt-ekleme (schemaVersion 4 -> 5).
/// PK `(entityId, alan)` -- alan basina TEK kayit (cakisma gecmisi K95'te
/// kapsam disi). `entityType` YOK -- bu dilimde tek entity turu (`task`)
/// vardir ve sutun hicbir yerde okunmayacakti (olu sutun yazilmaz).
@DataClassName('CakismaKaydiRow')
class CakismaKayitlari extends Table {
  TextColumn get entityId => text()();
  TextColumn get alan => text()(); // 'fields:title' | 'groups:completion' -- BASKASI YOK
  TextColumn get kaybedenDeger => text()(); // YEREL deger, ezilmeden ONCE -- kanonik dize
  TextColumn get kazananDeger => text()(); // UZAK deger -- AYNI kanonik dize fonksiyonundan
  TextColumn get kazananClientHex => text()();
  DateTimeColumn get olusturuldu => dateTime()();

  @override
  Set<Column> get primaryKey => {entityId, alan};
}

@DriftDatabase(tables: [Gorevler, SenkronKuyrugu, Ayarlar, UzakAlanDurumu, CakismaKayitlari])
class Veritabani extends _$Veritabani {
  Veritabani([QueryExecutor? baglanti]) : super(baglanti ?? _uretimBaglantisi());

  @override
  int get schemaVersion => 5;

  /// GOREV-slice-3c D1/T3: v1->v2 SQLite bir CHECK kisitini ALTER TABLE ile
  /// degistiremez -- `gorevler` (yeni 5-degerli CHECK ile) `TableMigration`
  /// ile YENIDEN YARATILIR; veri `columnTransformer` OLMADAN kopyalanir
  /// (sutun adlari/tipleri degismedi, yalniz CHECK genisledi). v2->v3 salt
  /// eklemelidir (`ayarlar`), CHECK/tip degisikligi yok.
  /// GOREV-slice-3d D1/D7-4: v3->v4 SALT-EKLEMEdir -- `Gorevler`e DOKUNULMAZ,
  /// `alterTable` cagrilmaz; `uzakAlanDurumu` yeni tablo + `ayarlar.imlecSahibi`
  /// yeni sutun AYNI blokta (Ö6: iki ayri drift_dev komutu -- dump + generate).
  /// GOREV-SS2 D-SS2-1: v4->v5 de SALT-EKLEMEDIR -- `cakismaKayitlari` yeni
  /// tablo, `Gorevler`e DOKUNULMAZ. Sira PAZARLIKSIZ (T1): v4 dump ONCE
  /// alinir (schemaVersion hala 4 iken), sonra bump, sonra generate.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(senkronKuyrugu);
        await m.alterTable(TableMigration(gorevler));
      }
      // `createTable` cagiranin GUNCEL (v4) Dart tablo tanimini kullanir --
      // `ayarlar` burada YENI olusturulursa `imlecSahibi` ZATEN icindedir.
      final ayarlarYeniOlusturuldu = from < 3;
      if (ayarlarYeniOlusturuldu) {
        await m.createTable(ayarlar);
      }
      if (from < 4) {
        await m.createTable(uzakAlanDurumu);
        if (!ayarlarYeniOlusturuldu) {
          // `ayarlar` v3'ten beri VARDI (imlecSahibi'siz) -- simdi eklenir.
          // Yeni olusturulduysa (yukarida) sutun ZATEN var -- ikinci kez
          // eklemek "duplicate column" ile patlar.
          await m.addColumn(ayarlar, ayarlar.imlecSahibi);
        }
      }
      // GOREV-SS2 D-SS2-1: v4->v5 SALT-EKLEMEDIR -- `Gorevler`e DOKUNULMAZ,
      // `alterTable` cagrilmaz (Ö10).
      if (from < 5) {
        await m.createTable(cakismaKayitlari);
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

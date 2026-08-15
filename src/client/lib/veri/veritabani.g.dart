// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'veritabani.dart';

// ignore_for_file: type=lint
class $GorevlerTable extends Gorevler with TableInfo<$GorevlerTable, GorevRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GorevlerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baslikMeta = const VerificationMeta('baslik');
  @override
  late final GeneratedColumn<String> baslik = GeneratedColumn<String>(
    'baslik',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tamamlandiMeta = const VerificationMeta(
    'tamamlandi',
  );
  @override
  late final GeneratedColumn<bool> tamamlandi = GeneratedColumn<bool>(
    'tamamlandi',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tamamlandi" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _olusturulduMeta = const VerificationMeta(
    'olusturuldu',
  );
  @override
  late final GeneratedColumn<DateTime> olusturuldu = GeneratedColumn<DateTime>(
    'olusturuldu',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _guncellendiMeta = const VerificationMeta(
    'guncellendi',
  );
  @override
  late final GeneratedColumn<DateTime> guncellendi = GeneratedColumn<DateTime>(
    'guncellendi',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senkronDurumuMeta = const VerificationMeta(
    'senkronDurumu',
  );
  @override
  late final GeneratedColumn<String> senkronDurumu = GeneratedColumn<String>(
    'senkron_durumu',
    aliasedName,
    false,
    check: () => senkronDurumu.isIn([
      'yerel',
      'kuyrukta',
      'senkronize',
      'cakisma',
      'cevrimdisi',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('yerel'),
  );
  static const VerificationMeta _silindiMeta = const VerificationMeta(
    'silindi',
  );
  @override
  late final GeneratedColumn<bool> silindi = GeneratedColumn<bool>(
    'silindi',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("silindi" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _oncelikMeta = const VerificationMeta(
    'oncelik',
  );
  @override
  late final GeneratedColumn<int> oncelik = GeneratedColumn<int>(
    'oncelik',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sonTarihMeta = const VerificationMeta(
    'sonTarih',
  );
  @override
  late final GeneratedColumn<DateTime> sonTarih = GeneratedColumn<DateTime>(
    'son_tarih',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    baslik,
    tamamlandi,
    olusturuldu,
    guncellendi,
    senkronDurumu,
    silindi,
    oncelik,
    sonTarih,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gorevler';
  @override
  VerificationContext validateIntegrity(
    Insertable<GorevRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('baslik')) {
      context.handle(
        _baslikMeta,
        baslik.isAcceptableOrUnknown(data['baslik']!, _baslikMeta),
      );
    } else if (isInserting) {
      context.missing(_baslikMeta);
    }
    if (data.containsKey('tamamlandi')) {
      context.handle(
        _tamamlandiMeta,
        tamamlandi.isAcceptableOrUnknown(data['tamamlandi']!, _tamamlandiMeta),
      );
    }
    if (data.containsKey('olusturuldu')) {
      context.handle(
        _olusturulduMeta,
        olusturuldu.isAcceptableOrUnknown(
          data['olusturuldu']!,
          _olusturulduMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_olusturulduMeta);
    }
    if (data.containsKey('guncellendi')) {
      context.handle(
        _guncellendiMeta,
        guncellendi.isAcceptableOrUnknown(
          data['guncellendi']!,
          _guncellendiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_guncellendiMeta);
    }
    if (data.containsKey('senkron_durumu')) {
      context.handle(
        _senkronDurumuMeta,
        senkronDurumu.isAcceptableOrUnknown(
          data['senkron_durumu']!,
          _senkronDurumuMeta,
        ),
      );
    }
    if (data.containsKey('silindi')) {
      context.handle(
        _silindiMeta,
        silindi.isAcceptableOrUnknown(data['silindi']!, _silindiMeta),
      );
    }
    if (data.containsKey('oncelik')) {
      context.handle(
        _oncelikMeta,
        oncelik.isAcceptableOrUnknown(data['oncelik']!, _oncelikMeta),
      );
    }
    if (data.containsKey('son_tarih')) {
      context.handle(
        _sonTarihMeta,
        sonTarih.isAcceptableOrUnknown(data['son_tarih']!, _sonTarihMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GorevRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GorevRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      baslik: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}baslik'],
      )!,
      tamamlandi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tamamlandi'],
      )!,
      olusturuldu: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}olusturuldu'],
      )!,
      guncellendi: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}guncellendi'],
      )!,
      senkronDurumu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}senkron_durumu'],
      )!,
      silindi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}silindi'],
      )!,
      oncelik: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}oncelik'],
      ),
      sonTarih: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}son_tarih'],
      ),
    );
  }

  @override
  $GorevlerTable createAlias(String alias) {
    return $GorevlerTable(attachedDatabase, alias);
  }
}

class GorevRow extends DataClass implements Insertable<GorevRow> {
  final String id;
  final String baslik;
  final bool tamamlandi;
  final DateTime olusturuldu;
  final DateTime guncellendi;
  final String senkronDurumu;
  final bool silindi;

  /// ODEV.md §4(a) "oncelik + son tarih" dilimi (schemaVersion 5 -> 6).
  /// HAM `int?`tir -- sunucunun `priority` scalar'iyla (`ProjectionFields
  /// .ReadInt`, `NumberStyles.Integer` + `InvariantCulture`) AYNI tur.
  /// 1/2/3 disinda bir deger gelirse SAKLANIR ama ekranda cizilmez: baska
  /// bir istemcinin yazdigi bilinmeyen degeri sessizce EZMEK, LWW'nin
  /// altini oymak olurdu.
  final int? oncelik;

  /// TAKVIM GUNU PINI (PAZARLIKSIZ): daima `DateTime.utc(y, m, d)` --
  /// saat/dakika DAIMA sifir, `isUtc` DAIMA true. Yerel saat dilimine
  /// CEVRILMEZ: UTC+3'te `.toUtc()` gunu bir gun geri kaydirir
  /// (yerel 21 Ağu 00:00 -> 20 Ağu 21:00Z). Tel bicimi bu degerin
  /// `toIso8601String()`idir ve sunucunun
  /// `yyyy-MM-dd'T'HH:mm:ss.FFFFFFFK` TryParseExact kalibina oturur.
  final DateTime? sonTarih;
  const GorevRow({
    required this.id,
    required this.baslik,
    required this.tamamlandi,
    required this.olusturuldu,
    required this.guncellendi,
    required this.senkronDurumu,
    required this.silindi,
    this.oncelik,
    this.sonTarih,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['baslik'] = Variable<String>(baslik);
    map['tamamlandi'] = Variable<bool>(tamamlandi);
    map['olusturuldu'] = Variable<DateTime>(olusturuldu);
    map['guncellendi'] = Variable<DateTime>(guncellendi);
    map['senkron_durumu'] = Variable<String>(senkronDurumu);
    map['silindi'] = Variable<bool>(silindi);
    if (!nullToAbsent || oncelik != null) {
      map['oncelik'] = Variable<int>(oncelik);
    }
    if (!nullToAbsent || sonTarih != null) {
      map['son_tarih'] = Variable<DateTime>(sonTarih);
    }
    return map;
  }

  GorevlerCompanion toCompanion(bool nullToAbsent) {
    return GorevlerCompanion(
      id: Value(id),
      baslik: Value(baslik),
      tamamlandi: Value(tamamlandi),
      olusturuldu: Value(olusturuldu),
      guncellendi: Value(guncellendi),
      senkronDurumu: Value(senkronDurumu),
      silindi: Value(silindi),
      oncelik: oncelik == null && nullToAbsent
          ? const Value.absent()
          : Value(oncelik),
      sonTarih: sonTarih == null && nullToAbsent
          ? const Value.absent()
          : Value(sonTarih),
    );
  }

  factory GorevRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GorevRow(
      id: serializer.fromJson<String>(json['id']),
      baslik: serializer.fromJson<String>(json['baslik']),
      tamamlandi: serializer.fromJson<bool>(json['tamamlandi']),
      olusturuldu: serializer.fromJson<DateTime>(json['olusturuldu']),
      guncellendi: serializer.fromJson<DateTime>(json['guncellendi']),
      senkronDurumu: serializer.fromJson<String>(json['senkronDurumu']),
      silindi: serializer.fromJson<bool>(json['silindi']),
      oncelik: serializer.fromJson<int?>(json['oncelik']),
      sonTarih: serializer.fromJson<DateTime?>(json['sonTarih']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'baslik': serializer.toJson<String>(baslik),
      'tamamlandi': serializer.toJson<bool>(tamamlandi),
      'olusturuldu': serializer.toJson<DateTime>(olusturuldu),
      'guncellendi': serializer.toJson<DateTime>(guncellendi),
      'senkronDurumu': serializer.toJson<String>(senkronDurumu),
      'silindi': serializer.toJson<bool>(silindi),
      'oncelik': serializer.toJson<int?>(oncelik),
      'sonTarih': serializer.toJson<DateTime?>(sonTarih),
    };
  }

  GorevRow copyWith({
    String? id,
    String? baslik,
    bool? tamamlandi,
    DateTime? olusturuldu,
    DateTime? guncellendi,
    String? senkronDurumu,
    bool? silindi,
    Value<int?> oncelik = const Value.absent(),
    Value<DateTime?> sonTarih = const Value.absent(),
  }) => GorevRow(
    id: id ?? this.id,
    baslik: baslik ?? this.baslik,
    tamamlandi: tamamlandi ?? this.tamamlandi,
    olusturuldu: olusturuldu ?? this.olusturuldu,
    guncellendi: guncellendi ?? this.guncellendi,
    senkronDurumu: senkronDurumu ?? this.senkronDurumu,
    silindi: silindi ?? this.silindi,
    oncelik: oncelik.present ? oncelik.value : this.oncelik,
    sonTarih: sonTarih.present ? sonTarih.value : this.sonTarih,
  );
  GorevRow copyWithCompanion(GorevlerCompanion data) {
    return GorevRow(
      id: data.id.present ? data.id.value : this.id,
      baslik: data.baslik.present ? data.baslik.value : this.baslik,
      tamamlandi: data.tamamlandi.present
          ? data.tamamlandi.value
          : this.tamamlandi,
      olusturuldu: data.olusturuldu.present
          ? data.olusturuldu.value
          : this.olusturuldu,
      guncellendi: data.guncellendi.present
          ? data.guncellendi.value
          : this.guncellendi,
      senkronDurumu: data.senkronDurumu.present
          ? data.senkronDurumu.value
          : this.senkronDurumu,
      silindi: data.silindi.present ? data.silindi.value : this.silindi,
      oncelik: data.oncelik.present ? data.oncelik.value : this.oncelik,
      sonTarih: data.sonTarih.present ? data.sonTarih.value : this.sonTarih,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GorevRow(')
          ..write('id: $id, ')
          ..write('baslik: $baslik, ')
          ..write('tamamlandi: $tamamlandi, ')
          ..write('olusturuldu: $olusturuldu, ')
          ..write('guncellendi: $guncellendi, ')
          ..write('senkronDurumu: $senkronDurumu, ')
          ..write('silindi: $silindi, ')
          ..write('oncelik: $oncelik, ')
          ..write('sonTarih: $sonTarih')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    baslik,
    tamamlandi,
    olusturuldu,
    guncellendi,
    senkronDurumu,
    silindi,
    oncelik,
    sonTarih,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GorevRow &&
          other.id == this.id &&
          other.baslik == this.baslik &&
          other.tamamlandi == this.tamamlandi &&
          other.olusturuldu == this.olusturuldu &&
          other.guncellendi == this.guncellendi &&
          other.senkronDurumu == this.senkronDurumu &&
          other.silindi == this.silindi &&
          other.oncelik == this.oncelik &&
          other.sonTarih == this.sonTarih);
}

class GorevlerCompanion extends UpdateCompanion<GorevRow> {
  final Value<String> id;
  final Value<String> baslik;
  final Value<bool> tamamlandi;
  final Value<DateTime> olusturuldu;
  final Value<DateTime> guncellendi;
  final Value<String> senkronDurumu;
  final Value<bool> silindi;
  final Value<int?> oncelik;
  final Value<DateTime?> sonTarih;
  final Value<int> rowid;
  const GorevlerCompanion({
    this.id = const Value.absent(),
    this.baslik = const Value.absent(),
    this.tamamlandi = const Value.absent(),
    this.olusturuldu = const Value.absent(),
    this.guncellendi = const Value.absent(),
    this.senkronDurumu = const Value.absent(),
    this.silindi = const Value.absent(),
    this.oncelik = const Value.absent(),
    this.sonTarih = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GorevlerCompanion.insert({
    required String id,
    required String baslik,
    this.tamamlandi = const Value.absent(),
    required DateTime olusturuldu,
    required DateTime guncellendi,
    this.senkronDurumu = const Value.absent(),
    this.silindi = const Value.absent(),
    this.oncelik = const Value.absent(),
    this.sonTarih = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       baslik = Value(baslik),
       olusturuldu = Value(olusturuldu),
       guncellendi = Value(guncellendi);
  static Insertable<GorevRow> custom({
    Expression<String>? id,
    Expression<String>? baslik,
    Expression<bool>? tamamlandi,
    Expression<DateTime>? olusturuldu,
    Expression<DateTime>? guncellendi,
    Expression<String>? senkronDurumu,
    Expression<bool>? silindi,
    Expression<int>? oncelik,
    Expression<DateTime>? sonTarih,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (baslik != null) 'baslik': baslik,
      if (tamamlandi != null) 'tamamlandi': tamamlandi,
      if (olusturuldu != null) 'olusturuldu': olusturuldu,
      if (guncellendi != null) 'guncellendi': guncellendi,
      if (senkronDurumu != null) 'senkron_durumu': senkronDurumu,
      if (silindi != null) 'silindi': silindi,
      if (oncelik != null) 'oncelik': oncelik,
      if (sonTarih != null) 'son_tarih': sonTarih,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GorevlerCompanion copyWith({
    Value<String>? id,
    Value<String>? baslik,
    Value<bool>? tamamlandi,
    Value<DateTime>? olusturuldu,
    Value<DateTime>? guncellendi,
    Value<String>? senkronDurumu,
    Value<bool>? silindi,
    Value<int?>? oncelik,
    Value<DateTime?>? sonTarih,
    Value<int>? rowid,
  }) {
    return GorevlerCompanion(
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      tamamlandi: tamamlandi ?? this.tamamlandi,
      olusturuldu: olusturuldu ?? this.olusturuldu,
      guncellendi: guncellendi ?? this.guncellendi,
      senkronDurumu: senkronDurumu ?? this.senkronDurumu,
      silindi: silindi ?? this.silindi,
      oncelik: oncelik ?? this.oncelik,
      sonTarih: sonTarih ?? this.sonTarih,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (baslik.present) {
      map['baslik'] = Variable<String>(baslik.value);
    }
    if (tamamlandi.present) {
      map['tamamlandi'] = Variable<bool>(tamamlandi.value);
    }
    if (olusturuldu.present) {
      map['olusturuldu'] = Variable<DateTime>(olusturuldu.value);
    }
    if (guncellendi.present) {
      map['guncellendi'] = Variable<DateTime>(guncellendi.value);
    }
    if (senkronDurumu.present) {
      map['senkron_durumu'] = Variable<String>(senkronDurumu.value);
    }
    if (silindi.present) {
      map['silindi'] = Variable<bool>(silindi.value);
    }
    if (oncelik.present) {
      map['oncelik'] = Variable<int>(oncelik.value);
    }
    if (sonTarih.present) {
      map['son_tarih'] = Variable<DateTime>(sonTarih.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GorevlerCompanion(')
          ..write('id: $id, ')
          ..write('baslik: $baslik, ')
          ..write('tamamlandi: $tamamlandi, ')
          ..write('olusturuldu: $olusturuldu, ')
          ..write('guncellendi: $guncellendi, ')
          ..write('senkronDurumu: $senkronDurumu, ')
          ..write('silindi: $silindi, ')
          ..write('oncelik: $oncelik, ')
          ..write('sonTarih: $sonTarih, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SenkronKuyruguTable extends SenkronKuyrugu
    with TableInfo<$SenkronKuyruguTable, SenkronKuyruguRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SenkronKuyruguTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _govdeJsonMeta = const VerificationMeta(
    'govdeJson',
  );
  @override
  late final GeneratedColumn<String> govdeJson = GeneratedColumn<String>(
    'govde_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcWallMsMeta = const VerificationMeta(
    'hlcWallMs',
  );
  @override
  late final GeneratedColumn<int> hlcWallMs = GeneratedColumn<int>(
    'hlc_wall_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcCounterMeta = const VerificationMeta(
    'hlcCounter',
  );
  @override
  late final GeneratedColumn<int> hlcCounter = GeneratedColumn<int>(
    'hlc_counter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durumMeta = const VerificationMeta('durum');
  @override
  late final GeneratedColumn<String> durum = GeneratedColumn<String>(
    'durum',
    aliasedName,
    false,
    check: () => durum.isIn(['bekliyor', 'gonderildi', 'zehirli']),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bekliyor'),
  );
  static const VerificationMeta _denemeSayisiMeta = const VerificationMeta(
    'denemeSayisi',
  );
  @override
  late final GeneratedColumn<int> denemeSayisi = GeneratedColumn<int>(
    'deneme_sayisi',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sonHataKoduMeta = const VerificationMeta(
    'sonHataKodu',
  );
  @override
  late final GeneratedColumn<String> sonHataKodu = GeneratedColumn<String>(
    'son_hata_kodu',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _olusturulduMeta = const VerificationMeta(
    'olusturuldu',
  );
  @override
  late final GeneratedColumn<DateTime> olusturuldu = GeneratedColumn<DateTime>(
    'olusturuldu',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    clientId,
    entityType,
    entityId,
    govdeJson,
    hlcWallMs,
    hlcCounter,
    durum,
    denemeSayisi,
    sonHataKodu,
    olusturuldu,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'senkron_kuyrugu';
  @override
  VerificationContext validateIntegrity(
    Insertable<SenkronKuyruguRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('govde_json')) {
      context.handle(
        _govdeJsonMeta,
        govdeJson.isAcceptableOrUnknown(data['govde_json']!, _govdeJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_govdeJsonMeta);
    }
    if (data.containsKey('hlc_wall_ms')) {
      context.handle(
        _hlcWallMsMeta,
        hlcWallMs.isAcceptableOrUnknown(data['hlc_wall_ms']!, _hlcWallMsMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcWallMsMeta);
    }
    if (data.containsKey('hlc_counter')) {
      context.handle(
        _hlcCounterMeta,
        hlcCounter.isAcceptableOrUnknown(data['hlc_counter']!, _hlcCounterMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcCounterMeta);
    }
    if (data.containsKey('durum')) {
      context.handle(
        _durumMeta,
        durum.isAcceptableOrUnknown(data['durum']!, _durumMeta),
      );
    }
    if (data.containsKey('deneme_sayisi')) {
      context.handle(
        _denemeSayisiMeta,
        denemeSayisi.isAcceptableOrUnknown(
          data['deneme_sayisi']!,
          _denemeSayisiMeta,
        ),
      );
    }
    if (data.containsKey('son_hata_kodu')) {
      context.handle(
        _sonHataKoduMeta,
        sonHataKodu.isAcceptableOrUnknown(
          data['son_hata_kodu']!,
          _sonHataKoduMeta,
        ),
      );
    }
    if (data.containsKey('olusturuldu')) {
      context.handle(
        _olusturulduMeta,
        olusturuldu.isAcceptableOrUnknown(
          data['olusturuldu']!,
          _olusturulduMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_olusturulduMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  SenkronKuyruguRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SenkronKuyruguRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      govdeJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}govde_json'],
      )!,
      hlcWallMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hlc_wall_ms'],
      )!,
      hlcCounter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hlc_counter'],
      )!,
      durum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}durum'],
      )!,
      denemeSayisi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deneme_sayisi'],
      )!,
      sonHataKodu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}son_hata_kodu'],
      ),
      olusturuldu: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}olusturuldu'],
      )!,
    );
  }

  @override
  $SenkronKuyruguTable createAlias(String alias) {
    return $SenkronKuyruguTable(attachedDatabase, alias);
  }
}

class SenkronKuyruguRow extends DataClass
    implements Insertable<SenkronKuyruguRow> {
  final String opId;
  final String clientId;
  final String entityType;
  final String entityId;
  final String govdeJson;
  final int hlcWallMs;
  final int hlcCounter;
  final String durum;
  final int denemeSayisi;
  final String? sonHataKodu;
  final DateTime olusturuldu;
  const SenkronKuyruguRow({
    required this.opId,
    required this.clientId,
    required this.entityType,
    required this.entityId,
    required this.govdeJson,
    required this.hlcWallMs,
    required this.hlcCounter,
    required this.durum,
    required this.denemeSayisi,
    this.sonHataKodu,
    required this.olusturuldu,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<String>(opId);
    map['client_id'] = Variable<String>(clientId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['govde_json'] = Variable<String>(govdeJson);
    map['hlc_wall_ms'] = Variable<int>(hlcWallMs);
    map['hlc_counter'] = Variable<int>(hlcCounter);
    map['durum'] = Variable<String>(durum);
    map['deneme_sayisi'] = Variable<int>(denemeSayisi);
    if (!nullToAbsent || sonHataKodu != null) {
      map['son_hata_kodu'] = Variable<String>(sonHataKodu);
    }
    map['olusturuldu'] = Variable<DateTime>(olusturuldu);
    return map;
  }

  SenkronKuyruguCompanion toCompanion(bool nullToAbsent) {
    return SenkronKuyruguCompanion(
      opId: Value(opId),
      clientId: Value(clientId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      govdeJson: Value(govdeJson),
      hlcWallMs: Value(hlcWallMs),
      hlcCounter: Value(hlcCounter),
      durum: Value(durum),
      denemeSayisi: Value(denemeSayisi),
      sonHataKodu: sonHataKodu == null && nullToAbsent
          ? const Value.absent()
          : Value(sonHataKodu),
      olusturuldu: Value(olusturuldu),
    );
  }

  factory SenkronKuyruguRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SenkronKuyruguRow(
      opId: serializer.fromJson<String>(json['opId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      govdeJson: serializer.fromJson<String>(json['govdeJson']),
      hlcWallMs: serializer.fromJson<int>(json['hlcWallMs']),
      hlcCounter: serializer.fromJson<int>(json['hlcCounter']),
      durum: serializer.fromJson<String>(json['durum']),
      denemeSayisi: serializer.fromJson<int>(json['denemeSayisi']),
      sonHataKodu: serializer.fromJson<String?>(json['sonHataKodu']),
      olusturuldu: serializer.fromJson<DateTime>(json['olusturuldu']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String>(opId),
      'clientId': serializer.toJson<String>(clientId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'govdeJson': serializer.toJson<String>(govdeJson),
      'hlcWallMs': serializer.toJson<int>(hlcWallMs),
      'hlcCounter': serializer.toJson<int>(hlcCounter),
      'durum': serializer.toJson<String>(durum),
      'denemeSayisi': serializer.toJson<int>(denemeSayisi),
      'sonHataKodu': serializer.toJson<String?>(sonHataKodu),
      'olusturuldu': serializer.toJson<DateTime>(olusturuldu),
    };
  }

  SenkronKuyruguRow copyWith({
    String? opId,
    String? clientId,
    String? entityType,
    String? entityId,
    String? govdeJson,
    int? hlcWallMs,
    int? hlcCounter,
    String? durum,
    int? denemeSayisi,
    Value<String?> sonHataKodu = const Value.absent(),
    DateTime? olusturuldu,
  }) => SenkronKuyruguRow(
    opId: opId ?? this.opId,
    clientId: clientId ?? this.clientId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    govdeJson: govdeJson ?? this.govdeJson,
    hlcWallMs: hlcWallMs ?? this.hlcWallMs,
    hlcCounter: hlcCounter ?? this.hlcCounter,
    durum: durum ?? this.durum,
    denemeSayisi: denemeSayisi ?? this.denemeSayisi,
    sonHataKodu: sonHataKodu.present ? sonHataKodu.value : this.sonHataKodu,
    olusturuldu: olusturuldu ?? this.olusturuldu,
  );
  SenkronKuyruguRow copyWithCompanion(SenkronKuyruguCompanion data) {
    return SenkronKuyruguRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      govdeJson: data.govdeJson.present ? data.govdeJson.value : this.govdeJson,
      hlcWallMs: data.hlcWallMs.present ? data.hlcWallMs.value : this.hlcWallMs,
      hlcCounter: data.hlcCounter.present
          ? data.hlcCounter.value
          : this.hlcCounter,
      durum: data.durum.present ? data.durum.value : this.durum,
      denemeSayisi: data.denemeSayisi.present
          ? data.denemeSayisi.value
          : this.denemeSayisi,
      sonHataKodu: data.sonHataKodu.present
          ? data.sonHataKodu.value
          : this.sonHataKodu,
      olusturuldu: data.olusturuldu.present
          ? data.olusturuldu.value
          : this.olusturuldu,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SenkronKuyruguRow(')
          ..write('opId: $opId, ')
          ..write('clientId: $clientId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('govdeJson: $govdeJson, ')
          ..write('hlcWallMs: $hlcWallMs, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('durum: $durum, ')
          ..write('denemeSayisi: $denemeSayisi, ')
          ..write('sonHataKodu: $sonHataKodu, ')
          ..write('olusturuldu: $olusturuldu')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    clientId,
    entityType,
    entityId,
    govdeJson,
    hlcWallMs,
    hlcCounter,
    durum,
    denemeSayisi,
    sonHataKodu,
    olusturuldu,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SenkronKuyruguRow &&
          other.opId == this.opId &&
          other.clientId == this.clientId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.govdeJson == this.govdeJson &&
          other.hlcWallMs == this.hlcWallMs &&
          other.hlcCounter == this.hlcCounter &&
          other.durum == this.durum &&
          other.denemeSayisi == this.denemeSayisi &&
          other.sonHataKodu == this.sonHataKodu &&
          other.olusturuldu == this.olusturuldu);
}

class SenkronKuyruguCompanion extends UpdateCompanion<SenkronKuyruguRow> {
  final Value<String> opId;
  final Value<String> clientId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> govdeJson;
  final Value<int> hlcWallMs;
  final Value<int> hlcCounter;
  final Value<String> durum;
  final Value<int> denemeSayisi;
  final Value<String?> sonHataKodu;
  final Value<DateTime> olusturuldu;
  final Value<int> rowid;
  const SenkronKuyruguCompanion({
    this.opId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.govdeJson = const Value.absent(),
    this.hlcWallMs = const Value.absent(),
    this.hlcCounter = const Value.absent(),
    this.durum = const Value.absent(),
    this.denemeSayisi = const Value.absent(),
    this.sonHataKodu = const Value.absent(),
    this.olusturuldu = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SenkronKuyruguCompanion.insert({
    required String opId,
    required String clientId,
    required String entityType,
    required String entityId,
    required String govdeJson,
    required int hlcWallMs,
    required int hlcCounter,
    this.durum = const Value.absent(),
    this.denemeSayisi = const Value.absent(),
    this.sonHataKodu = const Value.absent(),
    required DateTime olusturuldu,
    this.rowid = const Value.absent(),
  }) : opId = Value(opId),
       clientId = Value(clientId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       govdeJson = Value(govdeJson),
       hlcWallMs = Value(hlcWallMs),
       hlcCounter = Value(hlcCounter),
       olusturuldu = Value(olusturuldu);
  static Insertable<SenkronKuyruguRow> custom({
    Expression<String>? opId,
    Expression<String>? clientId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? govdeJson,
    Expression<int>? hlcWallMs,
    Expression<int>? hlcCounter,
    Expression<String>? durum,
    Expression<int>? denemeSayisi,
    Expression<String>? sonHataKodu,
    Expression<DateTime>? olusturuldu,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (clientId != null) 'client_id': clientId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (govdeJson != null) 'govde_json': govdeJson,
      if (hlcWallMs != null) 'hlc_wall_ms': hlcWallMs,
      if (hlcCounter != null) 'hlc_counter': hlcCounter,
      if (durum != null) 'durum': durum,
      if (denemeSayisi != null) 'deneme_sayisi': denemeSayisi,
      if (sonHataKodu != null) 'son_hata_kodu': sonHataKodu,
      if (olusturuldu != null) 'olusturuldu': olusturuldu,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SenkronKuyruguCompanion copyWith({
    Value<String>? opId,
    Value<String>? clientId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? govdeJson,
    Value<int>? hlcWallMs,
    Value<int>? hlcCounter,
    Value<String>? durum,
    Value<int>? denemeSayisi,
    Value<String?>? sonHataKodu,
    Value<DateTime>? olusturuldu,
    Value<int>? rowid,
  }) {
    return SenkronKuyruguCompanion(
      opId: opId ?? this.opId,
      clientId: clientId ?? this.clientId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      govdeJson: govdeJson ?? this.govdeJson,
      hlcWallMs: hlcWallMs ?? this.hlcWallMs,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      durum: durum ?? this.durum,
      denemeSayisi: denemeSayisi ?? this.denemeSayisi,
      sonHataKodu: sonHataKodu ?? this.sonHataKodu,
      olusturuldu: olusturuldu ?? this.olusturuldu,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (govdeJson.present) {
      map['govde_json'] = Variable<String>(govdeJson.value);
    }
    if (hlcWallMs.present) {
      map['hlc_wall_ms'] = Variable<int>(hlcWallMs.value);
    }
    if (hlcCounter.present) {
      map['hlc_counter'] = Variable<int>(hlcCounter.value);
    }
    if (durum.present) {
      map['durum'] = Variable<String>(durum.value);
    }
    if (denemeSayisi.present) {
      map['deneme_sayisi'] = Variable<int>(denemeSayisi.value);
    }
    if (sonHataKodu.present) {
      map['son_hata_kodu'] = Variable<String>(sonHataKodu.value);
    }
    if (olusturuldu.present) {
      map['olusturuldu'] = Variable<DateTime>(olusturuldu.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SenkronKuyruguCompanion(')
          ..write('opId: $opId, ')
          ..write('clientId: $clientId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('govdeJson: $govdeJson, ')
          ..write('hlcWallMs: $hlcWallMs, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('durum: $durum, ')
          ..write('denemeSayisi: $denemeSayisi, ')
          ..write('sonHataKodu: $sonHataKodu, ')
          ..write('olusturuldu: $olusturuldu, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AyarlarTable extends Ayarlar with TableInfo<$AyarlarTable, AyarRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AyarlarTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sonWallMeta = const VerificationMeta(
    'sonWall',
  );
  @override
  late final GeneratedColumn<int> sonWall = GeneratedColumn<int>(
    'son_wall',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sonCounterMeta = const VerificationMeta(
    'sonCounter',
  );
  @override
  late final GeneratedColumn<int> sonCounter = GeneratedColumn<int>(
    'son_counter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextCursorJsonMeta = const VerificationMeta(
    'nextCursorJson',
  );
  @override
  late final GeneratedColumn<String> nextCursorJson = GeneratedColumn<String>(
    'next_cursor_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _devUserIdMeta = const VerificationMeta(
    'devUserId',
  );
  @override
  late final GeneratedColumn<String> devUserId = GeneratedColumn<String>(
    'dev_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imlecSahibiMeta = const VerificationMeta(
    'imlecSahibi',
  );
  @override
  late final GeneratedColumn<String> imlecSahibi = GeneratedColumn<String>(
    'imlec_sahibi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    sonWall,
    sonCounter,
    nextCursorJson,
    devUserId,
    imlecSahibi,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ayarlar';
  @override
  VerificationContext validateIntegrity(
    Insertable<AyarRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('son_wall')) {
      context.handle(
        _sonWallMeta,
        sonWall.isAcceptableOrUnknown(data['son_wall']!, _sonWallMeta),
      );
    }
    if (data.containsKey('son_counter')) {
      context.handle(
        _sonCounterMeta,
        sonCounter.isAcceptableOrUnknown(data['son_counter']!, _sonCounterMeta),
      );
    }
    if (data.containsKey('next_cursor_json')) {
      context.handle(
        _nextCursorJsonMeta,
        nextCursorJson.isAcceptableOrUnknown(
          data['next_cursor_json']!,
          _nextCursorJsonMeta,
        ),
      );
    }
    if (data.containsKey('dev_user_id')) {
      context.handle(
        _devUserIdMeta,
        devUserId.isAcceptableOrUnknown(data['dev_user_id']!, _devUserIdMeta),
      );
    } else if (isInserting) {
      context.missing(_devUserIdMeta);
    }
    if (data.containsKey('imlec_sahibi')) {
      context.handle(
        _imlecSahibiMeta,
        imlecSahibi.isAcceptableOrUnknown(
          data['imlec_sahibi']!,
          _imlecSahibiMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AyarRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AyarRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      sonWall: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}son_wall'],
      )!,
      sonCounter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}son_counter'],
      )!,
      nextCursorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_cursor_json'],
      ),
      devUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dev_user_id'],
      )!,
      imlecSahibi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imlec_sahibi'],
      ),
    );
  }

  @override
  $AyarlarTable createAlias(String alias) {
    return $AyarlarTable(attachedDatabase, alias);
  }
}

class AyarRow extends DataClass implements Insertable<AyarRow> {
  final int id;
  final String clientId;
  final int sonWall;
  final int sonCounter;
  final String? nextCursorJson;
  final String devUserId;
  final String? imlecSahibi;
  const AyarRow({
    required this.id,
    required this.clientId,
    required this.sonWall,
    required this.sonCounter,
    this.nextCursorJson,
    required this.devUserId,
    this.imlecSahibi,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['client_id'] = Variable<String>(clientId);
    map['son_wall'] = Variable<int>(sonWall);
    map['son_counter'] = Variable<int>(sonCounter);
    if (!nullToAbsent || nextCursorJson != null) {
      map['next_cursor_json'] = Variable<String>(nextCursorJson);
    }
    map['dev_user_id'] = Variable<String>(devUserId);
    if (!nullToAbsent || imlecSahibi != null) {
      map['imlec_sahibi'] = Variable<String>(imlecSahibi);
    }
    return map;
  }

  AyarlarCompanion toCompanion(bool nullToAbsent) {
    return AyarlarCompanion(
      id: Value(id),
      clientId: Value(clientId),
      sonWall: Value(sonWall),
      sonCounter: Value(sonCounter),
      nextCursorJson: nextCursorJson == null && nullToAbsent
          ? const Value.absent()
          : Value(nextCursorJson),
      devUserId: Value(devUserId),
      imlecSahibi: imlecSahibi == null && nullToAbsent
          ? const Value.absent()
          : Value(imlecSahibi),
    );
  }

  factory AyarRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AyarRow(
      id: serializer.fromJson<int>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      sonWall: serializer.fromJson<int>(json['sonWall']),
      sonCounter: serializer.fromJson<int>(json['sonCounter']),
      nextCursorJson: serializer.fromJson<String?>(json['nextCursorJson']),
      devUserId: serializer.fromJson<String>(json['devUserId']),
      imlecSahibi: serializer.fromJson<String?>(json['imlecSahibi']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clientId': serializer.toJson<String>(clientId),
      'sonWall': serializer.toJson<int>(sonWall),
      'sonCounter': serializer.toJson<int>(sonCounter),
      'nextCursorJson': serializer.toJson<String?>(nextCursorJson),
      'devUserId': serializer.toJson<String>(devUserId),
      'imlecSahibi': serializer.toJson<String?>(imlecSahibi),
    };
  }

  AyarRow copyWith({
    int? id,
    String? clientId,
    int? sonWall,
    int? sonCounter,
    Value<String?> nextCursorJson = const Value.absent(),
    String? devUserId,
    Value<String?> imlecSahibi = const Value.absent(),
  }) => AyarRow(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    sonWall: sonWall ?? this.sonWall,
    sonCounter: sonCounter ?? this.sonCounter,
    nextCursorJson: nextCursorJson.present
        ? nextCursorJson.value
        : this.nextCursorJson,
    devUserId: devUserId ?? this.devUserId,
    imlecSahibi: imlecSahibi.present ? imlecSahibi.value : this.imlecSahibi,
  );
  AyarRow copyWithCompanion(AyarlarCompanion data) {
    return AyarRow(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      sonWall: data.sonWall.present ? data.sonWall.value : this.sonWall,
      sonCounter: data.sonCounter.present
          ? data.sonCounter.value
          : this.sonCounter,
      nextCursorJson: data.nextCursorJson.present
          ? data.nextCursorJson.value
          : this.nextCursorJson,
      devUserId: data.devUserId.present ? data.devUserId.value : this.devUserId,
      imlecSahibi: data.imlecSahibi.present
          ? data.imlecSahibi.value
          : this.imlecSahibi,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AyarRow(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('sonWall: $sonWall, ')
          ..write('sonCounter: $sonCounter, ')
          ..write('nextCursorJson: $nextCursorJson, ')
          ..write('devUserId: $devUserId, ')
          ..write('imlecSahibi: $imlecSahibi')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    sonWall,
    sonCounter,
    nextCursorJson,
    devUserId,
    imlecSahibi,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AyarRow &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.sonWall == this.sonWall &&
          other.sonCounter == this.sonCounter &&
          other.nextCursorJson == this.nextCursorJson &&
          other.devUserId == this.devUserId &&
          other.imlecSahibi == this.imlecSahibi);
}

class AyarlarCompanion extends UpdateCompanion<AyarRow> {
  final Value<int> id;
  final Value<String> clientId;
  final Value<int> sonWall;
  final Value<int> sonCounter;
  final Value<String?> nextCursorJson;
  final Value<String> devUserId;
  final Value<String?> imlecSahibi;
  const AyarlarCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.sonWall = const Value.absent(),
    this.sonCounter = const Value.absent(),
    this.nextCursorJson = const Value.absent(),
    this.devUserId = const Value.absent(),
    this.imlecSahibi = const Value.absent(),
  });
  AyarlarCompanion.insert({
    this.id = const Value.absent(),
    required String clientId,
    this.sonWall = const Value.absent(),
    this.sonCounter = const Value.absent(),
    this.nextCursorJson = const Value.absent(),
    required String devUserId,
    this.imlecSahibi = const Value.absent(),
  }) : clientId = Value(clientId),
       devUserId = Value(devUserId);
  static Insertable<AyarRow> custom({
    Expression<int>? id,
    Expression<String>? clientId,
    Expression<int>? sonWall,
    Expression<int>? sonCounter,
    Expression<String>? nextCursorJson,
    Expression<String>? devUserId,
    Expression<String>? imlecSahibi,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (sonWall != null) 'son_wall': sonWall,
      if (sonCounter != null) 'son_counter': sonCounter,
      if (nextCursorJson != null) 'next_cursor_json': nextCursorJson,
      if (devUserId != null) 'dev_user_id': devUserId,
      if (imlecSahibi != null) 'imlec_sahibi': imlecSahibi,
    });
  }

  AyarlarCompanion copyWith({
    Value<int>? id,
    Value<String>? clientId,
    Value<int>? sonWall,
    Value<int>? sonCounter,
    Value<String?>? nextCursorJson,
    Value<String>? devUserId,
    Value<String?>? imlecSahibi,
  }) {
    return AyarlarCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      sonWall: sonWall ?? this.sonWall,
      sonCounter: sonCounter ?? this.sonCounter,
      nextCursorJson: nextCursorJson ?? this.nextCursorJson,
      devUserId: devUserId ?? this.devUserId,
      imlecSahibi: imlecSahibi ?? this.imlecSahibi,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (sonWall.present) {
      map['son_wall'] = Variable<int>(sonWall.value);
    }
    if (sonCounter.present) {
      map['son_counter'] = Variable<int>(sonCounter.value);
    }
    if (nextCursorJson.present) {
      map['next_cursor_json'] = Variable<String>(nextCursorJson.value);
    }
    if (devUserId.present) {
      map['dev_user_id'] = Variable<String>(devUserId.value);
    }
    if (imlecSahibi.present) {
      map['imlec_sahibi'] = Variable<String>(imlecSahibi.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AyarlarCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('sonWall: $sonWall, ')
          ..write('sonCounter: $sonCounter, ')
          ..write('nextCursorJson: $nextCursorJson, ')
          ..write('devUserId: $devUserId, ')
          ..write('imlecSahibi: $imlecSahibi')
          ..write(')'))
        .toString();
  }
}

class $UzakAlanDurumuTable extends UzakAlanDurumu
    with TableInfo<$UzakAlanDurumuTable, UzakAlanDurumuRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UzakAlanDurumuTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alanMeta = const VerificationMeta('alan');
  @override
  late final GeneratedColumn<String> alan = GeneratedColumn<String>(
    'alan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcWallMeta = const VerificationMeta(
    'hlcWall',
  );
  @override
  late final GeneratedColumn<int> hlcWall = GeneratedColumn<int>(
    'hlc_wall',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcCounterMeta = const VerificationMeta(
    'hlcCounter',
  );
  @override
  late final GeneratedColumn<int> hlcCounter = GeneratedColumn<int>(
    'hlc_counter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcClientIdMeta = const VerificationMeta(
    'hlcClientId',
  );
  @override
  late final GeneratedColumn<String> hlcClientId = GeneratedColumn<String>(
    'hlc_client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _winOpIdMeta = const VerificationMeta(
    'winOpId',
  );
  @override
  late final GeneratedColumn<String> winOpId = GeneratedColumn<String>(
    'win_op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityType,
    entityId,
    alan,
    hlcWall,
    hlcCounter,
    hlcClientId,
    winOpId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'uzak_alan_durumu';
  @override
  VerificationContext validateIntegrity(
    Insertable<UzakAlanDurumuRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('alan')) {
      context.handle(
        _alanMeta,
        alan.isAcceptableOrUnknown(data['alan']!, _alanMeta),
      );
    } else if (isInserting) {
      context.missing(_alanMeta);
    }
    if (data.containsKey('hlc_wall')) {
      context.handle(
        _hlcWallMeta,
        hlcWall.isAcceptableOrUnknown(data['hlc_wall']!, _hlcWallMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcWallMeta);
    }
    if (data.containsKey('hlc_counter')) {
      context.handle(
        _hlcCounterMeta,
        hlcCounter.isAcceptableOrUnknown(data['hlc_counter']!, _hlcCounterMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcCounterMeta);
    }
    if (data.containsKey('hlc_client_id')) {
      context.handle(
        _hlcClientIdMeta,
        hlcClientId.isAcceptableOrUnknown(
          data['hlc_client_id']!,
          _hlcClientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hlcClientIdMeta);
    }
    if (data.containsKey('win_op_id')) {
      context.handle(
        _winOpIdMeta,
        winOpId.isAcceptableOrUnknown(data['win_op_id']!, _winOpIdMeta),
      );
    } else if (isInserting) {
      context.missing(_winOpIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType, entityId, alan};
  @override
  UzakAlanDurumuRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UzakAlanDurumuRow(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      alan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alan'],
      )!,
      hlcWall: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hlc_wall'],
      )!,
      hlcCounter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hlc_counter'],
      )!,
      hlcClientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc_client_id'],
      )!,
      winOpId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}win_op_id'],
      )!,
    );
  }

  @override
  $UzakAlanDurumuTable createAlias(String alias) {
    return $UzakAlanDurumuTable(attachedDatabase, alias);
  }
}

class UzakAlanDurumuRow extends DataClass
    implements Insertable<UzakAlanDurumuRow> {
  final String entityType;
  final String entityId;
  final String alan;
  final int hlcWall;
  final int hlcCounter;
  final String hlcClientId;
  final String winOpId;
  const UzakAlanDurumuRow({
    required this.entityType,
    required this.entityId,
    required this.alan,
    required this.hlcWall,
    required this.hlcCounter,
    required this.hlcClientId,
    required this.winOpId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['alan'] = Variable<String>(alan);
    map['hlc_wall'] = Variable<int>(hlcWall);
    map['hlc_counter'] = Variable<int>(hlcCounter);
    map['hlc_client_id'] = Variable<String>(hlcClientId);
    map['win_op_id'] = Variable<String>(winOpId);
    return map;
  }

  UzakAlanDurumuCompanion toCompanion(bool nullToAbsent) {
    return UzakAlanDurumuCompanion(
      entityType: Value(entityType),
      entityId: Value(entityId),
      alan: Value(alan),
      hlcWall: Value(hlcWall),
      hlcCounter: Value(hlcCounter),
      hlcClientId: Value(hlcClientId),
      winOpId: Value(winOpId),
    );
  }

  factory UzakAlanDurumuRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UzakAlanDurumuRow(
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      alan: serializer.fromJson<String>(json['alan']),
      hlcWall: serializer.fromJson<int>(json['hlcWall']),
      hlcCounter: serializer.fromJson<int>(json['hlcCounter']),
      hlcClientId: serializer.fromJson<String>(json['hlcClientId']),
      winOpId: serializer.fromJson<String>(json['winOpId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'alan': serializer.toJson<String>(alan),
      'hlcWall': serializer.toJson<int>(hlcWall),
      'hlcCounter': serializer.toJson<int>(hlcCounter),
      'hlcClientId': serializer.toJson<String>(hlcClientId),
      'winOpId': serializer.toJson<String>(winOpId),
    };
  }

  UzakAlanDurumuRow copyWith({
    String? entityType,
    String? entityId,
    String? alan,
    int? hlcWall,
    int? hlcCounter,
    String? hlcClientId,
    String? winOpId,
  }) => UzakAlanDurumuRow(
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    alan: alan ?? this.alan,
    hlcWall: hlcWall ?? this.hlcWall,
    hlcCounter: hlcCounter ?? this.hlcCounter,
    hlcClientId: hlcClientId ?? this.hlcClientId,
    winOpId: winOpId ?? this.winOpId,
  );
  UzakAlanDurumuRow copyWithCompanion(UzakAlanDurumuCompanion data) {
    return UzakAlanDurumuRow(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      alan: data.alan.present ? data.alan.value : this.alan,
      hlcWall: data.hlcWall.present ? data.hlcWall.value : this.hlcWall,
      hlcCounter: data.hlcCounter.present
          ? data.hlcCounter.value
          : this.hlcCounter,
      hlcClientId: data.hlcClientId.present
          ? data.hlcClientId.value
          : this.hlcClientId,
      winOpId: data.winOpId.present ? data.winOpId.value : this.winOpId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UzakAlanDurumuRow(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('alan: $alan, ')
          ..write('hlcWall: $hlcWall, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcClientId: $hlcClientId, ')
          ..write('winOpId: $winOpId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entityType,
    entityId,
    alan,
    hlcWall,
    hlcCounter,
    hlcClientId,
    winOpId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UzakAlanDurumuRow &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.alan == this.alan &&
          other.hlcWall == this.hlcWall &&
          other.hlcCounter == this.hlcCounter &&
          other.hlcClientId == this.hlcClientId &&
          other.winOpId == this.winOpId);
}

class UzakAlanDurumuCompanion extends UpdateCompanion<UzakAlanDurumuRow> {
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> alan;
  final Value<int> hlcWall;
  final Value<int> hlcCounter;
  final Value<String> hlcClientId;
  final Value<String> winOpId;
  final Value<int> rowid;
  const UzakAlanDurumuCompanion({
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.alan = const Value.absent(),
    this.hlcWall = const Value.absent(),
    this.hlcCounter = const Value.absent(),
    this.hlcClientId = const Value.absent(),
    this.winOpId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UzakAlanDurumuCompanion.insert({
    required String entityType,
    required String entityId,
    required String alan,
    required int hlcWall,
    required int hlcCounter,
    required String hlcClientId,
    required String winOpId,
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       alan = Value(alan),
       hlcWall = Value(hlcWall),
       hlcCounter = Value(hlcCounter),
       hlcClientId = Value(hlcClientId),
       winOpId = Value(winOpId);
  static Insertable<UzakAlanDurumuRow> custom({
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? alan,
    Expression<int>? hlcWall,
    Expression<int>? hlcCounter,
    Expression<String>? hlcClientId,
    Expression<String>? winOpId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (alan != null) 'alan': alan,
      if (hlcWall != null) 'hlc_wall': hlcWall,
      if (hlcCounter != null) 'hlc_counter': hlcCounter,
      if (hlcClientId != null) 'hlc_client_id': hlcClientId,
      if (winOpId != null) 'win_op_id': winOpId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UzakAlanDurumuCompanion copyWith({
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? alan,
    Value<int>? hlcWall,
    Value<int>? hlcCounter,
    Value<String>? hlcClientId,
    Value<String>? winOpId,
    Value<int>? rowid,
  }) {
    return UzakAlanDurumuCompanion(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      alan: alan ?? this.alan,
      hlcWall: hlcWall ?? this.hlcWall,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      hlcClientId: hlcClientId ?? this.hlcClientId,
      winOpId: winOpId ?? this.winOpId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (alan.present) {
      map['alan'] = Variable<String>(alan.value);
    }
    if (hlcWall.present) {
      map['hlc_wall'] = Variable<int>(hlcWall.value);
    }
    if (hlcCounter.present) {
      map['hlc_counter'] = Variable<int>(hlcCounter.value);
    }
    if (hlcClientId.present) {
      map['hlc_client_id'] = Variable<String>(hlcClientId.value);
    }
    if (winOpId.present) {
      map['win_op_id'] = Variable<String>(winOpId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UzakAlanDurumuCompanion(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('alan: $alan, ')
          ..write('hlcWall: $hlcWall, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcClientId: $hlcClientId, ')
          ..write('winOpId: $winOpId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CakismaKayitlariTable extends CakismaKayitlari
    with TableInfo<$CakismaKayitlariTable, CakismaKaydiRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CakismaKayitlariTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alanMeta = const VerificationMeta('alan');
  @override
  late final GeneratedColumn<String> alan = GeneratedColumn<String>(
    'alan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kaybedenDegerMeta = const VerificationMeta(
    'kaybedenDeger',
  );
  @override
  late final GeneratedColumn<String> kaybedenDeger = GeneratedColumn<String>(
    'kaybeden_deger',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kazananDegerMeta = const VerificationMeta(
    'kazananDeger',
  );
  @override
  late final GeneratedColumn<String> kazananDeger = GeneratedColumn<String>(
    'kazanan_deger',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kazananClientHexMeta = const VerificationMeta(
    'kazananClientHex',
  );
  @override
  late final GeneratedColumn<String> kazananClientHex = GeneratedColumn<String>(
    'kazanan_client_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _olusturulduMeta = const VerificationMeta(
    'olusturuldu',
  );
  @override
  late final GeneratedColumn<DateTime> olusturuldu = GeneratedColumn<DateTime>(
    'olusturuldu',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityId,
    alan,
    kaybedenDeger,
    kazananDeger,
    kazananClientHex,
    olusturuldu,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cakisma_kayitlari';
  @override
  VerificationContext validateIntegrity(
    Insertable<CakismaKaydiRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('alan')) {
      context.handle(
        _alanMeta,
        alan.isAcceptableOrUnknown(data['alan']!, _alanMeta),
      );
    } else if (isInserting) {
      context.missing(_alanMeta);
    }
    if (data.containsKey('kaybeden_deger')) {
      context.handle(
        _kaybedenDegerMeta,
        kaybedenDeger.isAcceptableOrUnknown(
          data['kaybeden_deger']!,
          _kaybedenDegerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kaybedenDegerMeta);
    }
    if (data.containsKey('kazanan_deger')) {
      context.handle(
        _kazananDegerMeta,
        kazananDeger.isAcceptableOrUnknown(
          data['kazanan_deger']!,
          _kazananDegerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kazananDegerMeta);
    }
    if (data.containsKey('kazanan_client_hex')) {
      context.handle(
        _kazananClientHexMeta,
        kazananClientHex.isAcceptableOrUnknown(
          data['kazanan_client_hex']!,
          _kazananClientHexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kazananClientHexMeta);
    }
    if (data.containsKey('olusturuldu')) {
      context.handle(
        _olusturulduMeta,
        olusturuldu.isAcceptableOrUnknown(
          data['olusturuldu']!,
          _olusturulduMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_olusturulduMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityId, alan};
  @override
  CakismaKaydiRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CakismaKaydiRow(
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      alan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alan'],
      )!,
      kaybedenDeger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kaybeden_deger'],
      )!,
      kazananDeger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kazanan_deger'],
      )!,
      kazananClientHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kazanan_client_hex'],
      )!,
      olusturuldu: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}olusturuldu'],
      )!,
    );
  }

  @override
  $CakismaKayitlariTable createAlias(String alias) {
    return $CakismaKayitlariTable(attachedDatabase, alias);
  }
}

class CakismaKaydiRow extends DataClass implements Insertable<CakismaKaydiRow> {
  final String entityId;
  final String alan;
  final String kaybedenDeger;
  final String kazananDeger;
  final String kazananClientHex;
  final DateTime olusturuldu;
  const CakismaKaydiRow({
    required this.entityId,
    required this.alan,
    required this.kaybedenDeger,
    required this.kazananDeger,
    required this.kazananClientHex,
    required this.olusturuldu,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_id'] = Variable<String>(entityId);
    map['alan'] = Variable<String>(alan);
    map['kaybeden_deger'] = Variable<String>(kaybedenDeger);
    map['kazanan_deger'] = Variable<String>(kazananDeger);
    map['kazanan_client_hex'] = Variable<String>(kazananClientHex);
    map['olusturuldu'] = Variable<DateTime>(olusturuldu);
    return map;
  }

  CakismaKayitlariCompanion toCompanion(bool nullToAbsent) {
    return CakismaKayitlariCompanion(
      entityId: Value(entityId),
      alan: Value(alan),
      kaybedenDeger: Value(kaybedenDeger),
      kazananDeger: Value(kazananDeger),
      kazananClientHex: Value(kazananClientHex),
      olusturuldu: Value(olusturuldu),
    );
  }

  factory CakismaKaydiRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CakismaKaydiRow(
      entityId: serializer.fromJson<String>(json['entityId']),
      alan: serializer.fromJson<String>(json['alan']),
      kaybedenDeger: serializer.fromJson<String>(json['kaybedenDeger']),
      kazananDeger: serializer.fromJson<String>(json['kazananDeger']),
      kazananClientHex: serializer.fromJson<String>(json['kazananClientHex']),
      olusturuldu: serializer.fromJson<DateTime>(json['olusturuldu']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityId': serializer.toJson<String>(entityId),
      'alan': serializer.toJson<String>(alan),
      'kaybedenDeger': serializer.toJson<String>(kaybedenDeger),
      'kazananDeger': serializer.toJson<String>(kazananDeger),
      'kazananClientHex': serializer.toJson<String>(kazananClientHex),
      'olusturuldu': serializer.toJson<DateTime>(olusturuldu),
    };
  }

  CakismaKaydiRow copyWith({
    String? entityId,
    String? alan,
    String? kaybedenDeger,
    String? kazananDeger,
    String? kazananClientHex,
    DateTime? olusturuldu,
  }) => CakismaKaydiRow(
    entityId: entityId ?? this.entityId,
    alan: alan ?? this.alan,
    kaybedenDeger: kaybedenDeger ?? this.kaybedenDeger,
    kazananDeger: kazananDeger ?? this.kazananDeger,
    kazananClientHex: kazananClientHex ?? this.kazananClientHex,
    olusturuldu: olusturuldu ?? this.olusturuldu,
  );
  CakismaKaydiRow copyWithCompanion(CakismaKayitlariCompanion data) {
    return CakismaKaydiRow(
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      alan: data.alan.present ? data.alan.value : this.alan,
      kaybedenDeger: data.kaybedenDeger.present
          ? data.kaybedenDeger.value
          : this.kaybedenDeger,
      kazananDeger: data.kazananDeger.present
          ? data.kazananDeger.value
          : this.kazananDeger,
      kazananClientHex: data.kazananClientHex.present
          ? data.kazananClientHex.value
          : this.kazananClientHex,
      olusturuldu: data.olusturuldu.present
          ? data.olusturuldu.value
          : this.olusturuldu,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CakismaKaydiRow(')
          ..write('entityId: $entityId, ')
          ..write('alan: $alan, ')
          ..write('kaybedenDeger: $kaybedenDeger, ')
          ..write('kazananDeger: $kazananDeger, ')
          ..write('kazananClientHex: $kazananClientHex, ')
          ..write('olusturuldu: $olusturuldu')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entityId,
    alan,
    kaybedenDeger,
    kazananDeger,
    kazananClientHex,
    olusturuldu,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CakismaKaydiRow &&
          other.entityId == this.entityId &&
          other.alan == this.alan &&
          other.kaybedenDeger == this.kaybedenDeger &&
          other.kazananDeger == this.kazananDeger &&
          other.kazananClientHex == this.kazananClientHex &&
          other.olusturuldu == this.olusturuldu);
}

class CakismaKayitlariCompanion extends UpdateCompanion<CakismaKaydiRow> {
  final Value<String> entityId;
  final Value<String> alan;
  final Value<String> kaybedenDeger;
  final Value<String> kazananDeger;
  final Value<String> kazananClientHex;
  final Value<DateTime> olusturuldu;
  final Value<int> rowid;
  const CakismaKayitlariCompanion({
    this.entityId = const Value.absent(),
    this.alan = const Value.absent(),
    this.kaybedenDeger = const Value.absent(),
    this.kazananDeger = const Value.absent(),
    this.kazananClientHex = const Value.absent(),
    this.olusturuldu = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CakismaKayitlariCompanion.insert({
    required String entityId,
    required String alan,
    required String kaybedenDeger,
    required String kazananDeger,
    required String kazananClientHex,
    required DateTime olusturuldu,
    this.rowid = const Value.absent(),
  }) : entityId = Value(entityId),
       alan = Value(alan),
       kaybedenDeger = Value(kaybedenDeger),
       kazananDeger = Value(kazananDeger),
       kazananClientHex = Value(kazananClientHex),
       olusturuldu = Value(olusturuldu);
  static Insertable<CakismaKaydiRow> custom({
    Expression<String>? entityId,
    Expression<String>? alan,
    Expression<String>? kaybedenDeger,
    Expression<String>? kazananDeger,
    Expression<String>? kazananClientHex,
    Expression<DateTime>? olusturuldu,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityId != null) 'entity_id': entityId,
      if (alan != null) 'alan': alan,
      if (kaybedenDeger != null) 'kaybeden_deger': kaybedenDeger,
      if (kazananDeger != null) 'kazanan_deger': kazananDeger,
      if (kazananClientHex != null) 'kazanan_client_hex': kazananClientHex,
      if (olusturuldu != null) 'olusturuldu': olusturuldu,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CakismaKayitlariCompanion copyWith({
    Value<String>? entityId,
    Value<String>? alan,
    Value<String>? kaybedenDeger,
    Value<String>? kazananDeger,
    Value<String>? kazananClientHex,
    Value<DateTime>? olusturuldu,
    Value<int>? rowid,
  }) {
    return CakismaKayitlariCompanion(
      entityId: entityId ?? this.entityId,
      alan: alan ?? this.alan,
      kaybedenDeger: kaybedenDeger ?? this.kaybedenDeger,
      kazananDeger: kazananDeger ?? this.kazananDeger,
      kazananClientHex: kazananClientHex ?? this.kazananClientHex,
      olusturuldu: olusturuldu ?? this.olusturuldu,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (alan.present) {
      map['alan'] = Variable<String>(alan.value);
    }
    if (kaybedenDeger.present) {
      map['kaybeden_deger'] = Variable<String>(kaybedenDeger.value);
    }
    if (kazananDeger.present) {
      map['kazanan_deger'] = Variable<String>(kazananDeger.value);
    }
    if (kazananClientHex.present) {
      map['kazanan_client_hex'] = Variable<String>(kazananClientHex.value);
    }
    if (olusturuldu.present) {
      map['olusturuldu'] = Variable<DateTime>(olusturuldu.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CakismaKayitlariCompanion(')
          ..write('entityId: $entityId, ')
          ..write('alan: $alan, ')
          ..write('kaybedenDeger: $kaybedenDeger, ')
          ..write('kazananDeger: $kazananDeger, ')
          ..write('kazananClientHex: $kazananClientHex, ')
          ..write('olusturuldu: $olusturuldu, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GorevEtiketleriTable extends GorevEtiketleri
    with TableInfo<$GorevEtiketleriTable, GorevEtiketiRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GorevEtiketleriTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gorevIdMeta = const VerificationMeta(
    'gorevId',
  );
  @override
  late final GeneratedColumn<String> gorevId = GeneratedColumn<String>(
    'gorev_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etiketMeta = const VerificationMeta('etiket');
  @override
  late final GeneratedColumn<String> etiket = GeneratedColumn<String>(
    'etiket',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addTagMeta = const VerificationMeta('addTag');
  @override
  late final GeneratedColumn<String> addTag = GeneratedColumn<String>(
    'add_tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iptalEdildiMeta = const VerificationMeta(
    'iptalEdildi',
  );
  @override
  late final GeneratedColumn<bool> iptalEdildi = GeneratedColumn<bool>(
    'iptal_edildi',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("iptal_edildi" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [gorevId, etiket, addTag, iptalEdildi];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gorev_etiketleri';
  @override
  VerificationContext validateIntegrity(
    Insertable<GorevEtiketiRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('gorev_id')) {
      context.handle(
        _gorevIdMeta,
        gorevId.isAcceptableOrUnknown(data['gorev_id']!, _gorevIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gorevIdMeta);
    }
    if (data.containsKey('etiket')) {
      context.handle(
        _etiketMeta,
        etiket.isAcceptableOrUnknown(data['etiket']!, _etiketMeta),
      );
    } else if (isInserting) {
      context.missing(_etiketMeta);
    }
    if (data.containsKey('add_tag')) {
      context.handle(
        _addTagMeta,
        addTag.isAcceptableOrUnknown(data['add_tag']!, _addTagMeta),
      );
    } else if (isInserting) {
      context.missing(_addTagMeta);
    }
    if (data.containsKey('iptal_edildi')) {
      context.handle(
        _iptalEdildiMeta,
        iptalEdildi.isAcceptableOrUnknown(
          data['iptal_edildi']!,
          _iptalEdildiMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gorevId, etiket, addTag};
  @override
  GorevEtiketiRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GorevEtiketiRow(
      gorevId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gorev_id'],
      )!,
      etiket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etiket'],
      )!,
      addTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}add_tag'],
      )!,
      iptalEdildi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}iptal_edildi'],
      )!,
    );
  }

  @override
  $GorevEtiketleriTable createAlias(String alias) {
    return $GorevEtiketleriTable(attachedDatabase, alias);
  }
}

class GorevEtiketiRow extends DataClass implements Insertable<GorevEtiketiRow> {
  final String gorevId;
  final String etiket;
  final String addTag;
  final bool iptalEdildi;
  const GorevEtiketiRow({
    required this.gorevId,
    required this.etiket,
    required this.addTag,
    required this.iptalEdildi,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['gorev_id'] = Variable<String>(gorevId);
    map['etiket'] = Variable<String>(etiket);
    map['add_tag'] = Variable<String>(addTag);
    map['iptal_edildi'] = Variable<bool>(iptalEdildi);
    return map;
  }

  GorevEtiketleriCompanion toCompanion(bool nullToAbsent) {
    return GorevEtiketleriCompanion(
      gorevId: Value(gorevId),
      etiket: Value(etiket),
      addTag: Value(addTag),
      iptalEdildi: Value(iptalEdildi),
    );
  }

  factory GorevEtiketiRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GorevEtiketiRow(
      gorevId: serializer.fromJson<String>(json['gorevId']),
      etiket: serializer.fromJson<String>(json['etiket']),
      addTag: serializer.fromJson<String>(json['addTag']),
      iptalEdildi: serializer.fromJson<bool>(json['iptalEdildi']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gorevId': serializer.toJson<String>(gorevId),
      'etiket': serializer.toJson<String>(etiket),
      'addTag': serializer.toJson<String>(addTag),
      'iptalEdildi': serializer.toJson<bool>(iptalEdildi),
    };
  }

  GorevEtiketiRow copyWith({
    String? gorevId,
    String? etiket,
    String? addTag,
    bool? iptalEdildi,
  }) => GorevEtiketiRow(
    gorevId: gorevId ?? this.gorevId,
    etiket: etiket ?? this.etiket,
    addTag: addTag ?? this.addTag,
    iptalEdildi: iptalEdildi ?? this.iptalEdildi,
  );
  GorevEtiketiRow copyWithCompanion(GorevEtiketleriCompanion data) {
    return GorevEtiketiRow(
      gorevId: data.gorevId.present ? data.gorevId.value : this.gorevId,
      etiket: data.etiket.present ? data.etiket.value : this.etiket,
      addTag: data.addTag.present ? data.addTag.value : this.addTag,
      iptalEdildi: data.iptalEdildi.present
          ? data.iptalEdildi.value
          : this.iptalEdildi,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GorevEtiketiRow(')
          ..write('gorevId: $gorevId, ')
          ..write('etiket: $etiket, ')
          ..write('addTag: $addTag, ')
          ..write('iptalEdildi: $iptalEdildi')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gorevId, etiket, addTag, iptalEdildi);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GorevEtiketiRow &&
          other.gorevId == this.gorevId &&
          other.etiket == this.etiket &&
          other.addTag == this.addTag &&
          other.iptalEdildi == this.iptalEdildi);
}

class GorevEtiketleriCompanion extends UpdateCompanion<GorevEtiketiRow> {
  final Value<String> gorevId;
  final Value<String> etiket;
  final Value<String> addTag;
  final Value<bool> iptalEdildi;
  final Value<int> rowid;
  const GorevEtiketleriCompanion({
    this.gorevId = const Value.absent(),
    this.etiket = const Value.absent(),
    this.addTag = const Value.absent(),
    this.iptalEdildi = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GorevEtiketleriCompanion.insert({
    required String gorevId,
    required String etiket,
    required String addTag,
    this.iptalEdildi = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : gorevId = Value(gorevId),
       etiket = Value(etiket),
       addTag = Value(addTag);
  static Insertable<GorevEtiketiRow> custom({
    Expression<String>? gorevId,
    Expression<String>? etiket,
    Expression<String>? addTag,
    Expression<bool>? iptalEdildi,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gorevId != null) 'gorev_id': gorevId,
      if (etiket != null) 'etiket': etiket,
      if (addTag != null) 'add_tag': addTag,
      if (iptalEdildi != null) 'iptal_edildi': iptalEdildi,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GorevEtiketleriCompanion copyWith({
    Value<String>? gorevId,
    Value<String>? etiket,
    Value<String>? addTag,
    Value<bool>? iptalEdildi,
    Value<int>? rowid,
  }) {
    return GorevEtiketleriCompanion(
      gorevId: gorevId ?? this.gorevId,
      etiket: etiket ?? this.etiket,
      addTag: addTag ?? this.addTag,
      iptalEdildi: iptalEdildi ?? this.iptalEdildi,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gorevId.present) {
      map['gorev_id'] = Variable<String>(gorevId.value);
    }
    if (etiket.present) {
      map['etiket'] = Variable<String>(etiket.value);
    }
    if (addTag.present) {
      map['add_tag'] = Variable<String>(addTag.value);
    }
    if (iptalEdildi.present) {
      map['iptal_edildi'] = Variable<bool>(iptalEdildi.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GorevEtiketleriCompanion(')
          ..write('gorevId: $gorevId, ')
          ..write('etiket: $etiket, ')
          ..write('addTag: $addTag, ')
          ..write('iptalEdildi: $iptalEdildi, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$Veritabani extends GeneratedDatabase {
  _$Veritabani(QueryExecutor e) : super(e);
  $VeritabaniManager get managers => $VeritabaniManager(this);
  late final $GorevlerTable gorevler = $GorevlerTable(this);
  late final $SenkronKuyruguTable senkronKuyrugu = $SenkronKuyruguTable(this);
  late final $AyarlarTable ayarlar = $AyarlarTable(this);
  late final $UzakAlanDurumuTable uzakAlanDurumu = $UzakAlanDurumuTable(this);
  late final $CakismaKayitlariTable cakismaKayitlari = $CakismaKayitlariTable(
    this,
  );
  late final $GorevEtiketleriTable gorevEtiketleri = $GorevEtiketleriTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    gorevler,
    senkronKuyrugu,
    ayarlar,
    uzakAlanDurumu,
    cakismaKayitlari,
    gorevEtiketleri,
  ];
}

typedef $$GorevlerTableCreateCompanionBuilder =
    GorevlerCompanion Function({
      required String id,
      required String baslik,
      Value<bool> tamamlandi,
      required DateTime olusturuldu,
      required DateTime guncellendi,
      Value<String> senkronDurumu,
      Value<bool> silindi,
      Value<int?> oncelik,
      Value<DateTime?> sonTarih,
      Value<int> rowid,
    });
typedef $$GorevlerTableUpdateCompanionBuilder =
    GorevlerCompanion Function({
      Value<String> id,
      Value<String> baslik,
      Value<bool> tamamlandi,
      Value<DateTime> olusturuldu,
      Value<DateTime> guncellendi,
      Value<String> senkronDurumu,
      Value<bool> silindi,
      Value<int?> oncelik,
      Value<DateTime?> sonTarih,
      Value<int> rowid,
    });

class $$GorevlerTableFilterComposer
    extends Composer<_$Veritabani, $GorevlerTable> {
  $$GorevlerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baslik => $composableBuilder(
    column: $table.baslik,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get tamamlandi => $composableBuilder(
    column: $table.tamamlandi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get olusturuldu => $composableBuilder(
    column: $table.olusturuldu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get guncellendi => $composableBuilder(
    column: $table.guncellendi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senkronDurumu => $composableBuilder(
    column: $table.senkronDurumu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get silindi => $composableBuilder(
    column: $table.silindi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oncelik => $composableBuilder(
    column: $table.oncelik,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sonTarih => $composableBuilder(
    column: $table.sonTarih,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GorevlerTableOrderingComposer
    extends Composer<_$Veritabani, $GorevlerTable> {
  $$GorevlerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baslik => $composableBuilder(
    column: $table.baslik,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get tamamlandi => $composableBuilder(
    column: $table.tamamlandi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get olusturuldu => $composableBuilder(
    column: $table.olusturuldu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get guncellendi => $composableBuilder(
    column: $table.guncellendi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senkronDurumu => $composableBuilder(
    column: $table.senkronDurumu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get silindi => $composableBuilder(
    column: $table.silindi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oncelik => $composableBuilder(
    column: $table.oncelik,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sonTarih => $composableBuilder(
    column: $table.sonTarih,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GorevlerTableAnnotationComposer
    extends Composer<_$Veritabani, $GorevlerTable> {
  $$GorevlerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get baslik =>
      $composableBuilder(column: $table.baslik, builder: (column) => column);

  GeneratedColumn<bool> get tamamlandi => $composableBuilder(
    column: $table.tamamlandi,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get olusturuldu => $composableBuilder(
    column: $table.olusturuldu,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get guncellendi => $composableBuilder(
    column: $table.guncellendi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senkronDurumu => $composableBuilder(
    column: $table.senkronDurumu,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get silindi =>
      $composableBuilder(column: $table.silindi, builder: (column) => column);

  GeneratedColumn<int> get oncelik =>
      $composableBuilder(column: $table.oncelik, builder: (column) => column);

  GeneratedColumn<DateTime> get sonTarih =>
      $composableBuilder(column: $table.sonTarih, builder: (column) => column);
}

class $$GorevlerTableTableManager
    extends
        RootTableManager<
          _$Veritabani,
          $GorevlerTable,
          GorevRow,
          $$GorevlerTableFilterComposer,
          $$GorevlerTableOrderingComposer,
          $$GorevlerTableAnnotationComposer,
          $$GorevlerTableCreateCompanionBuilder,
          $$GorevlerTableUpdateCompanionBuilder,
          (GorevRow, BaseReferences<_$Veritabani, $GorevlerTable, GorevRow>),
          GorevRow,
          PrefetchHooks Function()
        > {
  $$GorevlerTableTableManager(_$Veritabani db, $GorevlerTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GorevlerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GorevlerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GorevlerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> baslik = const Value.absent(),
                Value<bool> tamamlandi = const Value.absent(),
                Value<DateTime> olusturuldu = const Value.absent(),
                Value<DateTime> guncellendi = const Value.absent(),
                Value<String> senkronDurumu = const Value.absent(),
                Value<bool> silindi = const Value.absent(),
                Value<int?> oncelik = const Value.absent(),
                Value<DateTime?> sonTarih = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GorevlerCompanion(
                id: id,
                baslik: baslik,
                tamamlandi: tamamlandi,
                olusturuldu: olusturuldu,
                guncellendi: guncellendi,
                senkronDurumu: senkronDurumu,
                silindi: silindi,
                oncelik: oncelik,
                sonTarih: sonTarih,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String baslik,
                Value<bool> tamamlandi = const Value.absent(),
                required DateTime olusturuldu,
                required DateTime guncellendi,
                Value<String> senkronDurumu = const Value.absent(),
                Value<bool> silindi = const Value.absent(),
                Value<int?> oncelik = const Value.absent(),
                Value<DateTime?> sonTarih = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GorevlerCompanion.insert(
                id: id,
                baslik: baslik,
                tamamlandi: tamamlandi,
                olusturuldu: olusturuldu,
                guncellendi: guncellendi,
                senkronDurumu: senkronDurumu,
                silindi: silindi,
                oncelik: oncelik,
                sonTarih: sonTarih,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GorevlerTableProcessedTableManager =
    ProcessedTableManager<
      _$Veritabani,
      $GorevlerTable,
      GorevRow,
      $$GorevlerTableFilterComposer,
      $$GorevlerTableOrderingComposer,
      $$GorevlerTableAnnotationComposer,
      $$GorevlerTableCreateCompanionBuilder,
      $$GorevlerTableUpdateCompanionBuilder,
      (GorevRow, BaseReferences<_$Veritabani, $GorevlerTable, GorevRow>),
      GorevRow,
      PrefetchHooks Function()
    >;
typedef $$SenkronKuyruguTableCreateCompanionBuilder =
    SenkronKuyruguCompanion Function({
      required String opId,
      required String clientId,
      required String entityType,
      required String entityId,
      required String govdeJson,
      required int hlcWallMs,
      required int hlcCounter,
      Value<String> durum,
      Value<int> denemeSayisi,
      Value<String?> sonHataKodu,
      required DateTime olusturuldu,
      Value<int> rowid,
    });
typedef $$SenkronKuyruguTableUpdateCompanionBuilder =
    SenkronKuyruguCompanion Function({
      Value<String> opId,
      Value<String> clientId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> govdeJson,
      Value<int> hlcWallMs,
      Value<int> hlcCounter,
      Value<String> durum,
      Value<int> denemeSayisi,
      Value<String?> sonHataKodu,
      Value<DateTime> olusturuldu,
      Value<int> rowid,
    });

class $$SenkronKuyruguTableFilterComposer
    extends Composer<_$Veritabani, $SenkronKuyruguTable> {
  $$SenkronKuyruguTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get govdeJson => $composableBuilder(
    column: $table.govdeJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hlcWallMs => $composableBuilder(
    column: $table.hlcWallMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get durum => $composableBuilder(
    column: $table.durum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get denemeSayisi => $composableBuilder(
    column: $table.denemeSayisi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sonHataKodu => $composableBuilder(
    column: $table.sonHataKodu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get olusturuldu => $composableBuilder(
    column: $table.olusturuldu,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SenkronKuyruguTableOrderingComposer
    extends Composer<_$Veritabani, $SenkronKuyruguTable> {
  $$SenkronKuyruguTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get govdeJson => $composableBuilder(
    column: $table.govdeJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hlcWallMs => $composableBuilder(
    column: $table.hlcWallMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get durum => $composableBuilder(
    column: $table.durum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get denemeSayisi => $composableBuilder(
    column: $table.denemeSayisi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sonHataKodu => $composableBuilder(
    column: $table.sonHataKodu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get olusturuldu => $composableBuilder(
    column: $table.olusturuldu,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SenkronKuyruguTableAnnotationComposer
    extends Composer<_$Veritabani, $SenkronKuyruguTable> {
  $$SenkronKuyruguTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get govdeJson =>
      $composableBuilder(column: $table.govdeJson, builder: (column) => column);

  GeneratedColumn<int> get hlcWallMs =>
      $composableBuilder(column: $table.hlcWallMs, builder: (column) => column);

  GeneratedColumn<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get durum =>
      $composableBuilder(column: $table.durum, builder: (column) => column);

  GeneratedColumn<int> get denemeSayisi => $composableBuilder(
    column: $table.denemeSayisi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sonHataKodu => $composableBuilder(
    column: $table.sonHataKodu,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get olusturuldu => $composableBuilder(
    column: $table.olusturuldu,
    builder: (column) => column,
  );
}

class $$SenkronKuyruguTableTableManager
    extends
        RootTableManager<
          _$Veritabani,
          $SenkronKuyruguTable,
          SenkronKuyruguRow,
          $$SenkronKuyruguTableFilterComposer,
          $$SenkronKuyruguTableOrderingComposer,
          $$SenkronKuyruguTableAnnotationComposer,
          $$SenkronKuyruguTableCreateCompanionBuilder,
          $$SenkronKuyruguTableUpdateCompanionBuilder,
          (
            SenkronKuyruguRow,
            BaseReferences<
              _$Veritabani,
              $SenkronKuyruguTable,
              SenkronKuyruguRow
            >,
          ),
          SenkronKuyruguRow,
          PrefetchHooks Function()
        > {
  $$SenkronKuyruguTableTableManager(_$Veritabani db, $SenkronKuyruguTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SenkronKuyruguTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SenkronKuyruguTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SenkronKuyruguTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> opId = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> govdeJson = const Value.absent(),
                Value<int> hlcWallMs = const Value.absent(),
                Value<int> hlcCounter = const Value.absent(),
                Value<String> durum = const Value.absent(),
                Value<int> denemeSayisi = const Value.absent(),
                Value<String?> sonHataKodu = const Value.absent(),
                Value<DateTime> olusturuldu = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SenkronKuyruguCompanion(
                opId: opId,
                clientId: clientId,
                entityType: entityType,
                entityId: entityId,
                govdeJson: govdeJson,
                hlcWallMs: hlcWallMs,
                hlcCounter: hlcCounter,
                durum: durum,
                denemeSayisi: denemeSayisi,
                sonHataKodu: sonHataKodu,
                olusturuldu: olusturuldu,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opId,
                required String clientId,
                required String entityType,
                required String entityId,
                required String govdeJson,
                required int hlcWallMs,
                required int hlcCounter,
                Value<String> durum = const Value.absent(),
                Value<int> denemeSayisi = const Value.absent(),
                Value<String?> sonHataKodu = const Value.absent(),
                required DateTime olusturuldu,
                Value<int> rowid = const Value.absent(),
              }) => SenkronKuyruguCompanion.insert(
                opId: opId,
                clientId: clientId,
                entityType: entityType,
                entityId: entityId,
                govdeJson: govdeJson,
                hlcWallMs: hlcWallMs,
                hlcCounter: hlcCounter,
                durum: durum,
                denemeSayisi: denemeSayisi,
                sonHataKodu: sonHataKodu,
                olusturuldu: olusturuldu,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SenkronKuyruguTableProcessedTableManager =
    ProcessedTableManager<
      _$Veritabani,
      $SenkronKuyruguTable,
      SenkronKuyruguRow,
      $$SenkronKuyruguTableFilterComposer,
      $$SenkronKuyruguTableOrderingComposer,
      $$SenkronKuyruguTableAnnotationComposer,
      $$SenkronKuyruguTableCreateCompanionBuilder,
      $$SenkronKuyruguTableUpdateCompanionBuilder,
      (
        SenkronKuyruguRow,
        BaseReferences<_$Veritabani, $SenkronKuyruguTable, SenkronKuyruguRow>,
      ),
      SenkronKuyruguRow,
      PrefetchHooks Function()
    >;
typedef $$AyarlarTableCreateCompanionBuilder =
    AyarlarCompanion Function({
      Value<int> id,
      required String clientId,
      Value<int> sonWall,
      Value<int> sonCounter,
      Value<String?> nextCursorJson,
      required String devUserId,
      Value<String?> imlecSahibi,
    });
typedef $$AyarlarTableUpdateCompanionBuilder =
    AyarlarCompanion Function({
      Value<int> id,
      Value<String> clientId,
      Value<int> sonWall,
      Value<int> sonCounter,
      Value<String?> nextCursorJson,
      Value<String> devUserId,
      Value<String?> imlecSahibi,
    });

class $$AyarlarTableFilterComposer
    extends Composer<_$Veritabani, $AyarlarTable> {
  $$AyarlarTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sonWall => $composableBuilder(
    column: $table.sonWall,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sonCounter => $composableBuilder(
    column: $table.sonCounter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextCursorJson => $composableBuilder(
    column: $table.nextCursorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get devUserId => $composableBuilder(
    column: $table.devUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imlecSahibi => $composableBuilder(
    column: $table.imlecSahibi,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AyarlarTableOrderingComposer
    extends Composer<_$Veritabani, $AyarlarTable> {
  $$AyarlarTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sonWall => $composableBuilder(
    column: $table.sonWall,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sonCounter => $composableBuilder(
    column: $table.sonCounter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextCursorJson => $composableBuilder(
    column: $table.nextCursorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get devUserId => $composableBuilder(
    column: $table.devUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imlecSahibi => $composableBuilder(
    column: $table.imlecSahibi,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AyarlarTableAnnotationComposer
    extends Composer<_$Veritabani, $AyarlarTable> {
  $$AyarlarTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<int> get sonWall =>
      $composableBuilder(column: $table.sonWall, builder: (column) => column);

  GeneratedColumn<int> get sonCounter => $composableBuilder(
    column: $table.sonCounter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextCursorJson => $composableBuilder(
    column: $table.nextCursorJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get devUserId =>
      $composableBuilder(column: $table.devUserId, builder: (column) => column);

  GeneratedColumn<String> get imlecSahibi => $composableBuilder(
    column: $table.imlecSahibi,
    builder: (column) => column,
  );
}

class $$AyarlarTableTableManager
    extends
        RootTableManager<
          _$Veritabani,
          $AyarlarTable,
          AyarRow,
          $$AyarlarTableFilterComposer,
          $$AyarlarTableOrderingComposer,
          $$AyarlarTableAnnotationComposer,
          $$AyarlarTableCreateCompanionBuilder,
          $$AyarlarTableUpdateCompanionBuilder,
          (AyarRow, BaseReferences<_$Veritabani, $AyarlarTable, AyarRow>),
          AyarRow,
          PrefetchHooks Function()
        > {
  $$AyarlarTableTableManager(_$Veritabani db, $AyarlarTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AyarlarTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AyarlarTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AyarlarTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<int> sonWall = const Value.absent(),
                Value<int> sonCounter = const Value.absent(),
                Value<String?> nextCursorJson = const Value.absent(),
                Value<String> devUserId = const Value.absent(),
                Value<String?> imlecSahibi = const Value.absent(),
              }) => AyarlarCompanion(
                id: id,
                clientId: clientId,
                sonWall: sonWall,
                sonCounter: sonCounter,
                nextCursorJson: nextCursorJson,
                devUserId: devUserId,
                imlecSahibi: imlecSahibi,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String clientId,
                Value<int> sonWall = const Value.absent(),
                Value<int> sonCounter = const Value.absent(),
                Value<String?> nextCursorJson = const Value.absent(),
                required String devUserId,
                Value<String?> imlecSahibi = const Value.absent(),
              }) => AyarlarCompanion.insert(
                id: id,
                clientId: clientId,
                sonWall: sonWall,
                sonCounter: sonCounter,
                nextCursorJson: nextCursorJson,
                devUserId: devUserId,
                imlecSahibi: imlecSahibi,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AyarlarTableProcessedTableManager =
    ProcessedTableManager<
      _$Veritabani,
      $AyarlarTable,
      AyarRow,
      $$AyarlarTableFilterComposer,
      $$AyarlarTableOrderingComposer,
      $$AyarlarTableAnnotationComposer,
      $$AyarlarTableCreateCompanionBuilder,
      $$AyarlarTableUpdateCompanionBuilder,
      (AyarRow, BaseReferences<_$Veritabani, $AyarlarTable, AyarRow>),
      AyarRow,
      PrefetchHooks Function()
    >;
typedef $$UzakAlanDurumuTableCreateCompanionBuilder =
    UzakAlanDurumuCompanion Function({
      required String entityType,
      required String entityId,
      required String alan,
      required int hlcWall,
      required int hlcCounter,
      required String hlcClientId,
      required String winOpId,
      Value<int> rowid,
    });
typedef $$UzakAlanDurumuTableUpdateCompanionBuilder =
    UzakAlanDurumuCompanion Function({
      Value<String> entityType,
      Value<String> entityId,
      Value<String> alan,
      Value<int> hlcWall,
      Value<int> hlcCounter,
      Value<String> hlcClientId,
      Value<String> winOpId,
      Value<int> rowid,
    });

class $$UzakAlanDurumuTableFilterComposer
    extends Composer<_$Veritabani, $UzakAlanDurumuTable> {
  $$UzakAlanDurumuTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alan => $composableBuilder(
    column: $table.alan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hlcWall => $composableBuilder(
    column: $table.hlcWall,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlcClientId => $composableBuilder(
    column: $table.hlcClientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winOpId => $composableBuilder(
    column: $table.winOpId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UzakAlanDurumuTableOrderingComposer
    extends Composer<_$Veritabani, $UzakAlanDurumuTable> {
  $$UzakAlanDurumuTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alan => $composableBuilder(
    column: $table.alan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hlcWall => $composableBuilder(
    column: $table.hlcWall,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlcClientId => $composableBuilder(
    column: $table.hlcClientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winOpId => $composableBuilder(
    column: $table.winOpId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UzakAlanDurumuTableAnnotationComposer
    extends Composer<_$Veritabani, $UzakAlanDurumuTable> {
  $$UzakAlanDurumuTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get alan =>
      $composableBuilder(column: $table.alan, builder: (column) => column);

  GeneratedColumn<int> get hlcWall =>
      $composableBuilder(column: $table.hlcWall, builder: (column) => column);

  GeneratedColumn<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hlcClientId => $composableBuilder(
    column: $table.hlcClientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get winOpId =>
      $composableBuilder(column: $table.winOpId, builder: (column) => column);
}

class $$UzakAlanDurumuTableTableManager
    extends
        RootTableManager<
          _$Veritabani,
          $UzakAlanDurumuTable,
          UzakAlanDurumuRow,
          $$UzakAlanDurumuTableFilterComposer,
          $$UzakAlanDurumuTableOrderingComposer,
          $$UzakAlanDurumuTableAnnotationComposer,
          $$UzakAlanDurumuTableCreateCompanionBuilder,
          $$UzakAlanDurumuTableUpdateCompanionBuilder,
          (
            UzakAlanDurumuRow,
            BaseReferences<
              _$Veritabani,
              $UzakAlanDurumuTable,
              UzakAlanDurumuRow
            >,
          ),
          UzakAlanDurumuRow,
          PrefetchHooks Function()
        > {
  $$UzakAlanDurumuTableTableManager(_$Veritabani db, $UzakAlanDurumuTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UzakAlanDurumuTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UzakAlanDurumuTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UzakAlanDurumuTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> alan = const Value.absent(),
                Value<int> hlcWall = const Value.absent(),
                Value<int> hlcCounter = const Value.absent(),
                Value<String> hlcClientId = const Value.absent(),
                Value<String> winOpId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UzakAlanDurumuCompanion(
                entityType: entityType,
                entityId: entityId,
                alan: alan,
                hlcWall: hlcWall,
                hlcCounter: hlcCounter,
                hlcClientId: hlcClientId,
                winOpId: winOpId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                required String entityId,
                required String alan,
                required int hlcWall,
                required int hlcCounter,
                required String hlcClientId,
                required String winOpId,
                Value<int> rowid = const Value.absent(),
              }) => UzakAlanDurumuCompanion.insert(
                entityType: entityType,
                entityId: entityId,
                alan: alan,
                hlcWall: hlcWall,
                hlcCounter: hlcCounter,
                hlcClientId: hlcClientId,
                winOpId: winOpId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UzakAlanDurumuTableProcessedTableManager =
    ProcessedTableManager<
      _$Veritabani,
      $UzakAlanDurumuTable,
      UzakAlanDurumuRow,
      $$UzakAlanDurumuTableFilterComposer,
      $$UzakAlanDurumuTableOrderingComposer,
      $$UzakAlanDurumuTableAnnotationComposer,
      $$UzakAlanDurumuTableCreateCompanionBuilder,
      $$UzakAlanDurumuTableUpdateCompanionBuilder,
      (
        UzakAlanDurumuRow,
        BaseReferences<_$Veritabani, $UzakAlanDurumuTable, UzakAlanDurumuRow>,
      ),
      UzakAlanDurumuRow,
      PrefetchHooks Function()
    >;
typedef $$CakismaKayitlariTableCreateCompanionBuilder =
    CakismaKayitlariCompanion Function({
      required String entityId,
      required String alan,
      required String kaybedenDeger,
      required String kazananDeger,
      required String kazananClientHex,
      required DateTime olusturuldu,
      Value<int> rowid,
    });
typedef $$CakismaKayitlariTableUpdateCompanionBuilder =
    CakismaKayitlariCompanion Function({
      Value<String> entityId,
      Value<String> alan,
      Value<String> kaybedenDeger,
      Value<String> kazananDeger,
      Value<String> kazananClientHex,
      Value<DateTime> olusturuldu,
      Value<int> rowid,
    });

class $$CakismaKayitlariTableFilterComposer
    extends Composer<_$Veritabani, $CakismaKayitlariTable> {
  $$CakismaKayitlariTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alan => $composableBuilder(
    column: $table.alan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kaybedenDeger => $composableBuilder(
    column: $table.kaybedenDeger,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kazananDeger => $composableBuilder(
    column: $table.kazananDeger,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kazananClientHex => $composableBuilder(
    column: $table.kazananClientHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get olusturuldu => $composableBuilder(
    column: $table.olusturuldu,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CakismaKayitlariTableOrderingComposer
    extends Composer<_$Veritabani, $CakismaKayitlariTable> {
  $$CakismaKayitlariTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alan => $composableBuilder(
    column: $table.alan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kaybedenDeger => $composableBuilder(
    column: $table.kaybedenDeger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kazananDeger => $composableBuilder(
    column: $table.kazananDeger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kazananClientHex => $composableBuilder(
    column: $table.kazananClientHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get olusturuldu => $composableBuilder(
    column: $table.olusturuldu,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CakismaKayitlariTableAnnotationComposer
    extends Composer<_$Veritabani, $CakismaKayitlariTable> {
  $$CakismaKayitlariTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get alan =>
      $composableBuilder(column: $table.alan, builder: (column) => column);

  GeneratedColumn<String> get kaybedenDeger => $composableBuilder(
    column: $table.kaybedenDeger,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kazananDeger => $composableBuilder(
    column: $table.kazananDeger,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kazananClientHex => $composableBuilder(
    column: $table.kazananClientHex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get olusturuldu => $composableBuilder(
    column: $table.olusturuldu,
    builder: (column) => column,
  );
}

class $$CakismaKayitlariTableTableManager
    extends
        RootTableManager<
          _$Veritabani,
          $CakismaKayitlariTable,
          CakismaKaydiRow,
          $$CakismaKayitlariTableFilterComposer,
          $$CakismaKayitlariTableOrderingComposer,
          $$CakismaKayitlariTableAnnotationComposer,
          $$CakismaKayitlariTableCreateCompanionBuilder,
          $$CakismaKayitlariTableUpdateCompanionBuilder,
          (
            CakismaKaydiRow,
            BaseReferences<
              _$Veritabani,
              $CakismaKayitlariTable,
              CakismaKaydiRow
            >,
          ),
          CakismaKaydiRow,
          PrefetchHooks Function()
        > {
  $$CakismaKayitlariTableTableManager(
    _$Veritabani db,
    $CakismaKayitlariTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CakismaKayitlariTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CakismaKayitlariTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CakismaKayitlariTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityId = const Value.absent(),
                Value<String> alan = const Value.absent(),
                Value<String> kaybedenDeger = const Value.absent(),
                Value<String> kazananDeger = const Value.absent(),
                Value<String> kazananClientHex = const Value.absent(),
                Value<DateTime> olusturuldu = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CakismaKayitlariCompanion(
                entityId: entityId,
                alan: alan,
                kaybedenDeger: kaybedenDeger,
                kazananDeger: kazananDeger,
                kazananClientHex: kazananClientHex,
                olusturuldu: olusturuldu,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityId,
                required String alan,
                required String kaybedenDeger,
                required String kazananDeger,
                required String kazananClientHex,
                required DateTime olusturuldu,
                Value<int> rowid = const Value.absent(),
              }) => CakismaKayitlariCompanion.insert(
                entityId: entityId,
                alan: alan,
                kaybedenDeger: kaybedenDeger,
                kazananDeger: kazananDeger,
                kazananClientHex: kazananClientHex,
                olusturuldu: olusturuldu,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CakismaKayitlariTableProcessedTableManager =
    ProcessedTableManager<
      _$Veritabani,
      $CakismaKayitlariTable,
      CakismaKaydiRow,
      $$CakismaKayitlariTableFilterComposer,
      $$CakismaKayitlariTableOrderingComposer,
      $$CakismaKayitlariTableAnnotationComposer,
      $$CakismaKayitlariTableCreateCompanionBuilder,
      $$CakismaKayitlariTableUpdateCompanionBuilder,
      (
        CakismaKaydiRow,
        BaseReferences<_$Veritabani, $CakismaKayitlariTable, CakismaKaydiRow>,
      ),
      CakismaKaydiRow,
      PrefetchHooks Function()
    >;
typedef $$GorevEtiketleriTableCreateCompanionBuilder =
    GorevEtiketleriCompanion Function({
      required String gorevId,
      required String etiket,
      required String addTag,
      Value<bool> iptalEdildi,
      Value<int> rowid,
    });
typedef $$GorevEtiketleriTableUpdateCompanionBuilder =
    GorevEtiketleriCompanion Function({
      Value<String> gorevId,
      Value<String> etiket,
      Value<String> addTag,
      Value<bool> iptalEdildi,
      Value<int> rowid,
    });

class $$GorevEtiketleriTableFilterComposer
    extends Composer<_$Veritabani, $GorevEtiketleriTable> {
  $$GorevEtiketleriTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gorevId => $composableBuilder(
    column: $table.gorevId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etiket => $composableBuilder(
    column: $table.etiket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addTag => $composableBuilder(
    column: $table.addTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get iptalEdildi => $composableBuilder(
    column: $table.iptalEdildi,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GorevEtiketleriTableOrderingComposer
    extends Composer<_$Veritabani, $GorevEtiketleriTable> {
  $$GorevEtiketleriTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gorevId => $composableBuilder(
    column: $table.gorevId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etiket => $composableBuilder(
    column: $table.etiket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addTag => $composableBuilder(
    column: $table.addTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get iptalEdildi => $composableBuilder(
    column: $table.iptalEdildi,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GorevEtiketleriTableAnnotationComposer
    extends Composer<_$Veritabani, $GorevEtiketleriTable> {
  $$GorevEtiketleriTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gorevId =>
      $composableBuilder(column: $table.gorevId, builder: (column) => column);

  GeneratedColumn<String> get etiket =>
      $composableBuilder(column: $table.etiket, builder: (column) => column);

  GeneratedColumn<String> get addTag =>
      $composableBuilder(column: $table.addTag, builder: (column) => column);

  GeneratedColumn<bool> get iptalEdildi => $composableBuilder(
    column: $table.iptalEdildi,
    builder: (column) => column,
  );
}

class $$GorevEtiketleriTableTableManager
    extends
        RootTableManager<
          _$Veritabani,
          $GorevEtiketleriTable,
          GorevEtiketiRow,
          $$GorevEtiketleriTableFilterComposer,
          $$GorevEtiketleriTableOrderingComposer,
          $$GorevEtiketleriTableAnnotationComposer,
          $$GorevEtiketleriTableCreateCompanionBuilder,
          $$GorevEtiketleriTableUpdateCompanionBuilder,
          (
            GorevEtiketiRow,
            BaseReferences<
              _$Veritabani,
              $GorevEtiketleriTable,
              GorevEtiketiRow
            >,
          ),
          GorevEtiketiRow,
          PrefetchHooks Function()
        > {
  $$GorevEtiketleriTableTableManager(
    _$Veritabani db,
    $GorevEtiketleriTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GorevEtiketleriTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GorevEtiketleriTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GorevEtiketleriTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gorevId = const Value.absent(),
                Value<String> etiket = const Value.absent(),
                Value<String> addTag = const Value.absent(),
                Value<bool> iptalEdildi = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GorevEtiketleriCompanion(
                gorevId: gorevId,
                etiket: etiket,
                addTag: addTag,
                iptalEdildi: iptalEdildi,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String gorevId,
                required String etiket,
                required String addTag,
                Value<bool> iptalEdildi = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GorevEtiketleriCompanion.insert(
                gorevId: gorevId,
                etiket: etiket,
                addTag: addTag,
                iptalEdildi: iptalEdildi,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GorevEtiketleriTableProcessedTableManager =
    ProcessedTableManager<
      _$Veritabani,
      $GorevEtiketleriTable,
      GorevEtiketiRow,
      $$GorevEtiketleriTableFilterComposer,
      $$GorevEtiketleriTableOrderingComposer,
      $$GorevEtiketleriTableAnnotationComposer,
      $$GorevEtiketleriTableCreateCompanionBuilder,
      $$GorevEtiketleriTableUpdateCompanionBuilder,
      (
        GorevEtiketiRow,
        BaseReferences<_$Veritabani, $GorevEtiketleriTable, GorevEtiketiRow>,
      ),
      GorevEtiketiRow,
      PrefetchHooks Function()
    >;

class $VeritabaniManager {
  final _$Veritabani _db;
  $VeritabaniManager(this._db);
  $$GorevlerTableTableManager get gorevler =>
      $$GorevlerTableTableManager(_db, _db.gorevler);
  $$SenkronKuyruguTableTableManager get senkronKuyrugu =>
      $$SenkronKuyruguTableTableManager(_db, _db.senkronKuyrugu);
  $$AyarlarTableTableManager get ayarlar =>
      $$AyarlarTableTableManager(_db, _db.ayarlar);
  $$UzakAlanDurumuTableTableManager get uzakAlanDurumu =>
      $$UzakAlanDurumuTableTableManager(_db, _db.uzakAlanDurumu);
  $$CakismaKayitlariTableTableManager get cakismaKayitlari =>
      $$CakismaKayitlariTableTableManager(_db, _db.cakismaKayitlari);
  $$GorevEtiketleriTableTableManager get gorevEtiketleri =>
      $$GorevEtiketleriTableTableManager(_db, _db.gorevEtiketleri);
}

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
    check: () => senkronDurumu.equals('yerel'),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    baslik,
    tamamlandi,
    olusturuldu,
    guncellendi,
    senkronDurumu,
    silindi,
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
  const GorevRow({
    required this.id,
    required this.baslik,
    required this.tamamlandi,
    required this.olusturuldu,
    required this.guncellendi,
    required this.senkronDurumu,
    required this.silindi,
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
  }) => GorevRow(
    id: id ?? this.id,
    baslik: baslik ?? this.baslik,
    tamamlandi: tamamlandi ?? this.tamamlandi,
    olusturuldu: olusturuldu ?? this.olusturuldu,
    guncellendi: guncellendi ?? this.guncellendi,
    senkronDurumu: senkronDurumu ?? this.senkronDurumu,
    silindi: silindi ?? this.silindi,
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
          ..write('silindi: $silindi')
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
          other.silindi == this.silindi);
}

class GorevlerCompanion extends UpdateCompanion<GorevRow> {
  final Value<String> id;
  final Value<String> baslik;
  final Value<bool> tamamlandi;
  final Value<DateTime> olusturuldu;
  final Value<DateTime> guncellendi;
  final Value<String> senkronDurumu;
  final Value<bool> silindi;
  final Value<int> rowid;
  const GorevlerCompanion({
    this.id = const Value.absent(),
    this.baslik = const Value.absent(),
    this.tamamlandi = const Value.absent(),
    this.olusturuldu = const Value.absent(),
    this.guncellendi = const Value.absent(),
    this.senkronDurumu = const Value.absent(),
    this.silindi = const Value.absent(),
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
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$Veritabani extends GeneratedDatabase {
  _$Veritabani(QueryExecutor e) : super(e);
  $VeritabaniManager get managers => $VeritabaniManager(this);
  late final $GorevlerTable gorevler = $GorevlerTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [gorevler];
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
                Value<int> rowid = const Value.absent(),
              }) => GorevlerCompanion(
                id: id,
                baslik: baslik,
                tamamlandi: tamamlandi,
                olusturuldu: olusturuldu,
                guncellendi: guncellendi,
                senkronDurumu: senkronDurumu,
                silindi: silindi,
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
                Value<int> rowid = const Value.absent(),
              }) => GorevlerCompanion.insert(
                id: id,
                baslik: baslik,
                tamamlandi: tamamlandi,
                olusturuldu: olusturuldu,
                guncellendi: guncellendi,
                senkronDurumu: senkronDurumu,
                silindi: silindi,
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

class $VeritabaniManager {
  final _$Veritabani _db;
  $VeritabaniManager(this._db);
  $$GorevlerTableTableManager get gorevler =>
      $$GorevlerTableTableManager(_db, _db.gorevler);
}

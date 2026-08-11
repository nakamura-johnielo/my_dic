import 'package:drift/drift.dart';

/// A stable, read-only view of a SQLite schema for contract tests.
///
/// This deliberately captures the live database instead of producing golden
/// files: callers keep the expected contract in the test, so it cannot be
/// silently refreshed after a schema change.
Future<DatabaseSchemaSnapshot> captureSchemaSnapshot(
  GeneratedDatabase database,
) async {
  final tableRows = await database.customSelect('''
    SELECT name, sql FROM sqlite_master
    WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
    ORDER BY name
  ''').get();
  final indexRows = await database.customSelect('''
    SELECT name, tbl_name, sql FROM sqlite_master
    WHERE type = 'index' AND sql IS NOT NULL
    ORDER BY name
  ''').get();

  final tables = <String, TableSchemaSnapshot>{};
  for (final row in tableRows) {
    final name = row.data['name']! as String;
    final columns =
        await database.customSelect('PRAGMA table_info($name)').get();
    final foreignKeys =
        await database.customSelect('PRAGMA foreign_key_list($name)').get();
    tables[name] = TableSchemaSnapshot(
      createSql: normalizeSchemaSql(row.data['sql']! as String),
      columns: columns
          .map((column) => ColumnSchemaSnapshot.fromRow(column.data))
          .toList(growable: false),
      foreignKeys: foreignKeys
          .map((key) => ForeignKeySchemaSnapshot.fromRow(key.data))
          .toList(growable: false),
    );
  }

  return DatabaseSchemaSnapshot(
    tables: tables,
    indexes: indexRows
        .map((row) => IndexSchemaSnapshot(
              name: row.data['name']! as String,
              table: row.data['tbl_name']! as String,
              sql: normalizeSchemaSql(row.data['sql']! as String),
            ))
        .toList(growable: false),
    emittedTableNames: database.allTables
        .map((table) => table.actualTableName)
        .toList(growable: false)
      ..sort(),
  );
}

String normalizeSchemaSql(String sql) => sql
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceAllMapped(
      RegExp(r'\s*([(),])\s*'),
      (match) => match.group(1)!,
    )
    .trim();

final class DatabaseSchemaSnapshot {
  const DatabaseSchemaSnapshot({
    required this.tables,
    required this.indexes,
    required this.emittedTableNames,
  });

  final Map<String, TableSchemaSnapshot> tables;
  final List<IndexSchemaSnapshot> indexes;
  final List<String> emittedTableNames;
}

final class TableSchemaSnapshot {
  const TableSchemaSnapshot({
    required this.createSql,
    required this.columns,
    required this.foreignKeys,
  });

  final String createSql;
  final List<ColumnSchemaSnapshot> columns;
  final List<ForeignKeySchemaSnapshot> foreignKeys;
}

final class ColumnSchemaSnapshot {
  const ColumnSchemaSnapshot({
    required this.name,
    required this.type,
    required this.notNull,
    required this.defaultValue,
    required this.primaryKeyOrder,
  });

  factory ColumnSchemaSnapshot.fromRow(Map<String, Object?> row) =>
      ColumnSchemaSnapshot(
        name: row['name']! as String,
        type: row['type']! as String,
        notNull: row['notnull'] == 1,
        defaultValue: row['dflt_value']?.toString(),
        primaryKeyOrder: row['pk']! as int,
      );

  final String name;
  final String type;
  final bool notNull;
  final String? defaultValue;
  final int primaryKeyOrder;
}

final class ForeignKeySchemaSnapshot {
  const ForeignKeySchemaSnapshot({
    required this.table,
    required this.from,
    required this.to,
    required this.onUpdate,
    required this.onDelete,
  });

  factory ForeignKeySchemaSnapshot.fromRow(Map<String, Object?> row) =>
      ForeignKeySchemaSnapshot(
        table: row['table']! as String,
        from: row['from']! as String,
        to: row['to']! as String,
        onUpdate: row['on_update']! as String,
        onDelete: row['on_delete']! as String,
      );

  final String table;
  final String from;
  final String to;
  final String onUpdate;
  final String onDelete;
}

final class IndexSchemaSnapshot {
  const IndexSchemaSnapshot({
    required this.name,
    required this.table,
    required this.sql,
  });

  final String name;
  final String table;
  final String sql;
}

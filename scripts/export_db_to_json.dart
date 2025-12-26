/// SQLiteデータベースからJSONへのエクスポートスクリプト
/// 
/// 使い方:
/// dart scripts/export_db_to_json.dart
/// 
/// このスクリプトは assets/ 内の .db ファイルを読み込み、
/// assets/data/ 配下にJSON形式でエクスポートします。

import 'dart:io';
import 'dart:convert';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as path;

void main() async {
  print('=== Database to JSON Export Tool ===\n');
  
  final scriptDir = path.dirname(Platform.script.toFilePath());
  final projectRoot = path.dirname(scriptDir);
  final assetsDir = path.join(projectRoot, 'assets');
  final outputDir = path.join(assetsDir, 'data');
  
  // 出力ディレクトリの作成
  final outputDirectory = Directory(outputDir);
  if (!await outputDirectory.exists()) {
    await outputDirectory.create(recursive: true);
    print('Created output directory: $outputDir\n');
  }
  
  // エクスポート対象のデータベース
  final databases = [
    'kotobank.db',
    'es_en_conjugacions.db',
  ];
  
  for (final dbName in databases) {
    final dbPath = path.join(assetsDir, dbName);
    final dbFile = File(dbPath);
    
    if (!await dbFile.exists()) {
      print('⚠️  Database not found: $dbPath');
      continue;
    }
    
    print('Processing: $dbName');
    await exportDatabaseToJson(dbPath, outputDir, dbName);
    print('✅ Completed: $dbName\n');
  }
  
  print('=== Export Complete ===');
}

Future<void> exportDatabaseToJson(String dbPath, String outputDir, String dbName) async {
  final db = sqlite3.open(dbPath);
  
  try {
    // データベース内の全テーブルを取得
    final tables = db.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
    );
    
    final Map<String, dynamic> dbData = {
      'database': dbName,
      'exported_at': DateTime.now().toIso8601String(),
      'tables': {},
    };
    
    for (final table in tables) {
      final tableName = table['name'] as String;
      print('  - Exporting table: $tableName');
      
      // テーブルのスキーマ情報を取得
      final schema = db.select("PRAGMA table_info($tableName)");
      final columns = schema.map((col) => {
        'name': col['name'],
        'type': col['type'],
        'notnull': col['notnull'],
        'pk': col['pk'],
      }).toList();
      
      // テーブルデータを取得
      final rows = db.select("SELECT * FROM $tableName");
      final rowCount = rows.length;
      
      dbData['tables'][tableName] = {
        'schema': columns,
        'rows': rows.map((row) => Map<String, dynamic>.from(row)).toList(),
        'row_count': rowCount,
      };
      
      print('    → $rowCount rows exported');
    }
    
    // JSONファイルとして保存
    final jsonFileName = dbName.replaceAll('.db', '.json');
    final jsonPath = path.join(outputDir, jsonFileName);
    final jsonFile = File(jsonPath);
    
    // Pretty print for debugging, but can be minified for production
    final encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(dbData);
    
    await jsonFile.writeAsString(jsonString);
    
    final fileSizeMB = (await jsonFile.length()) / (1024 * 1024);
    print('  📁 Saved to: $jsonPath (${fileSizeMB.toStringAsFixed(2)} MB)');
    
  } finally {
    db.dispose();
  }
}

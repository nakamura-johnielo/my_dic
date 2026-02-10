/// SQLiteデータベースから軽量JSON(Gzip圧縮)へのエクスポートスクリプト
/// 
/// 使い方:
/// dart scripts/export_db_to_json_compressed.dart
/// 
/// 出力: assets/data/*.json.gz (Gzip圧縮版)
library;

import 'dart:io';
import 'dart:convert';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as path;
import 'package:my_dic/core/shared/utils/logger.dart';


void main() async {
  AppLogger.print('=== Database to Compressed JSON Export Tool ===\n');
  
  final scriptDir = path.dirname(Platform.script.toFilePath());
  final projectRoot = path.dirname(scriptDir);
  final assetsDir = path.join(projectRoot, 'assets');
  final outputDir = path.join(assetsDir, 'db_for_web');
  
  final outputDirectory = Directory(outputDir);
  if (!await outputDirectory.exists()) {
    await outputDirectory.create(recursive: true);
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
      AppLogger.print('⚠️  Database not found: $dbPath');
      continue;
    }
    
    AppLogger.print('Processing: $dbName');
    await exportDatabaseToCompressedJson(dbPath, outputDir, dbName);
    AppLogger.print('✅ Completed: $dbName\n');
  }
  
  AppLogger.print('=== Export Complete ===');
  AppLogger.print('\n⚠️  Note: The generated .json.gz files need to be decompressed');
  AppLogger.print('in the Flutter web app using GZipCodec before parsing.');
}

Future<void> exportDatabaseToCompressedJson(
  String dbPath,
  String outputDir,
  String dbName,
) async {
  final db = sqlite3.open(dbPath);
  
  try {
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
      AppLogger.print('  - Exporting table: $tableName');
      
      final schema = db.select("PRAGMA table_info($tableName)");
      final columns = schema.map((col) => {
        'name': col['name'],
        'type': col['type'],
        'notnull': col['notnull'],
        'pk': col['pk'],
      }).toList();
      
      final rows = db.select("SELECT * FROM $tableName");
      final rowCount = rows.length;
      
      dbData['tables'][tableName] = {
        'schema': columns,
        'rows': rows.map((row) => Map<String, dynamic>.from(row)).toList(),
        'row_count': rowCount,
      };
      
      AppLogger.print('    → $rowCount rows exported');
    }
    
    // JSON文字列に変換（コンパクト版）
    final jsonString = jsonEncode(dbData);
    
    // Gzip圧縮
    final bytes = utf8.encode(jsonString);
    final compressed = gzip.encode(bytes);
    
    // .json.gz ファイルとして保存
    final compressedFileName = dbName.replaceAll('.db', '.json.gz');
    final compressedPath = path.join(outputDir, compressedFileName);
    final compressedFile = File(compressedPath);
    
    await compressedFile.writeAsBytes(compressed);
    
    final originalSizeMB = bytes.length / (1024 * 1024);
    final compressedSizeMB = compressed.length / (1024 * 1024);
    final compressionRatio = ((1 - compressed.length / bytes.length) * 100);
    
    AppLogger.print('  📁 Original: ${originalSizeMB.toStringAsFixed(2)} MB');
    AppLogger.print('  📦 Compressed: ${compressedSizeMB.toStringAsFixed(2)} MB (${compressionRatio.toStringAsFixed(1)}% reduction)');
    AppLogger.print('  💾 Saved to: $compressedPath');
    
  } finally {
    db.dispose();
  }
}

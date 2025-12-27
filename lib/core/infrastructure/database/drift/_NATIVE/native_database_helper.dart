// ネイティブプラットフォーム専用（Mobile/Desktop）
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

Future<QueryExecutor> createNativeExecutor(File file) async {
  // Android用のsqlite3初期化
  if (Platform.isAndroid) {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
  }
  
  return NativeDatabase(file);
}

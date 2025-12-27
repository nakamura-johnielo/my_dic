// Web環境用のWasmDatabaseヘルパー（drift/wasm.dart使用）
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

Future<QueryExecutor> createWebExecutor(String name) async {
  // // WasmSqlite3をロード
  // final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));

  // // IndexedDBをストレージとして使用
  // final fs = await IndexedDbFileSystem.open(dbName: name);

  // // DatabaseConnectionを作成
  // return WasmDatabase(
  //   sqlite3: sqlite3,
  //   fileSystem: fs,
  //   path: '$name.db',
  // );

  final result = await WasmDatabase.open(
    databaseName: name,
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  );
  return result.resolvedExecutor;
}

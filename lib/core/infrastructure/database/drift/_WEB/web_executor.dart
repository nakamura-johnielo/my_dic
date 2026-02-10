// Web環境用のWasmDatabaseヘルパー（drift/wasm.dart使用）
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

Future<QueryExecutor> createWebExecutor(String name) async {
  final result = await WasmDatabase.open(
    databaseName: name,
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  );
  return result.resolvedExecutor;
}

// ネイティブプラットフォーム用のWasmDatabaseスタブ
import 'package:drift/drift.dart';

Future<QueryExecutor> createWebExecutor(String name) async {
  throw UnsupportedError('WasmDatabase is only supported on web platform');
}

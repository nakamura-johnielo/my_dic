// ネイティブプラットフォーム用のWebDatabaseスタブ
import 'package:drift/drift.dart';

QueryExecutor createWebExecutor(String name) {
  throw UnsupportedError('WebDatabase is only supported on web platform');
}

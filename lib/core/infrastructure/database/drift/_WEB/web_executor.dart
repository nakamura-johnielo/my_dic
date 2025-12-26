// Web環境用のWebDatabaseヘルパー
import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor createWebExecutor(String name) {
  return WebDatabase(name);
}

// Web環境用のスタブファイル
import 'package:drift/drift.dart';

Future<QueryExecutor> createNativeExecutor(dynamic file) async {
  throw UnsupportedError('NativeDatabase is not supported on web');
}

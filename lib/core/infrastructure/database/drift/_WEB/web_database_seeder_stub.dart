/// 非Webプラットフォーム用のスタブ。
/// このファイルは、Web固有コードのインポートを避けるため、モバイル/デスクトップ向けの
/// コンパイル時に使用します。
library;

import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

class WebDatabaseSeeder {
  final DatabaseProvider db;

  WebDatabaseSeeder(this.db);

  /// 非Webプラットフォームでは決して呼び出してはいけません。
  Future<void> seedFromJson() async {
    throw UnsupportedError('WebDatabaseSeeder is only for web platform');
  }
}

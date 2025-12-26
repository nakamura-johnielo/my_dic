/// Stub for non-web platforms
/// This file is used when compiling for mobile/desktop platforms
/// to avoid importing web-specific code

import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

class WebDatabaseSeeder {
  final DatabaseProvider db;

  WebDatabaseSeeder(this.db);

  /// This should never be called on non-web platforms
  Future<void> seedFromJson() async {
    throw UnsupportedError('WebDatabaseSeeder is only for web platform');
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

final databaseProvider = Provider<DatabaseProvider>((ref) {
  final database = DatabaseProvider();
  ref.onDispose(() {
    unawaited(database.close());
  });
  return database;
});

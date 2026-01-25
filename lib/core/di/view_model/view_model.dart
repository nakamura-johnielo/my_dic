import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/global.dart';
import 'package:my_dic/core/section/db_loading/database_loading_notifier.dart';
import 'package:my_dic/core/section/db_loading/database_loading_state.dart';



final databaseLoadingProvider =
    StateNotifierProvider<DatabaseLoadingNotifier, DatabaseLoadingState>(
  (ref) => globalDatabaseLoadingNotifier,
);

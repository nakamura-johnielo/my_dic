import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/data/repository_impl/drift_my_word_repository.dart';

// ============================================================================
// Database & DAO Providers
// ============================================================================
final myWordStatusDaoProvider = Provider<MyWordStatusDao>((ref) {
  return MyWordStatusDao(ref.read(databaseProvider));
});

final myWordDaoProvider = Provider<MyWordDao>((ref) {
  return MyWordDao(ref.read(databaseProvider));
});

// ============================================================================
// Repository Providers
// ============================================================================

final myWordRepositoryProvider = Provider<IMyWordRepository>((ref) {
  return DriftMyWordRepository(
    ref.read(myWordDaoProvider),
    ref.read(myWordStatusDaoProvider),
  );
});

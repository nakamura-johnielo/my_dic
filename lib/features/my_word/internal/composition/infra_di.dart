import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/my_word/internal/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/features/my_word/internal/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/my_word_drift_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/my_word_status_drift_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/i_my_word_remote_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/i_my_word_status_remote_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/repository_impl/my_word_repository.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/repository_impl/my_word_status_repository.dart';
import 'package:my_dic/features/my_word/port/composition.dart';
import 'package:my_dic/features/my_word/internal/application/query/i_my_word_item_query_repository.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/query/drift_my_word_item_query_repository.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/guest_migration/my_word_guest_migration_adapter.dart';
import 'package:my_dic/features/my_word/port/guest_migration.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_dependencies.dart';

// ============================================================================
// Database & DAO Providers
// ============================================================================
final myWordStatusDaoProvider = Provider<MyWordStatusDao>((ref) {
  return MyWordStatusDao(ref.read(databaseProvider));
});

final myWordDaoProvider = Provider<MyWordDao>((ref) {
  return MyWordDao(ref.read(databaseProvider));
});

final myWordItemQueryRepositoryProvider =
    Provider<IMyWordItemQueryRepository>((ref) {
  return DriftMyWordItemQueryRepository(ref.read(myWordDaoProvider));
});

final myWordLocalDataSourceProvider = Provider<IMyWordLocalDataSource>((ref) {
  return MyWordDriftDataSource(
    ref.read(myWordDaoProvider),
  );
});

final myWordStatusLocalDataSourceProvider =
    Provider<IMyWordStatusLocalDataSource>((ref) {
  return MyWordStatusDriftDataSource(
    ref.read(myWordStatusDaoProvider),
  );
});

// ============================================================================
// Firebase DAO Providers
// ============================================================================

final myWordFirebaseDaoProvider = Provider<FirebaseMyWordDao>((ref) {
  return FirebaseMyWordDao(
    ref.read(myWordFirestoreProvider),
    ref.read(myWordRemoteMutationExecutorDependencyProvider),
  );
});

final myWordGuestMigrationPortProvider =
    Provider<MyWordGuestMigrationPort>((ref) => MyWordGuestMigrationAdapter(
          ref.read(myWordLocalDataSourceProvider),
          ref.read(myWordStatusLocalDataSourceProvider),
        ));

final myWordStatusFirebaseDaoProvider =
    Provider<FirebaseMyWordStatusDao>((ref) {
  return FirebaseMyWordStatusDao(
    ref.read(myWordFirestoreProvider),
    ref.read(myWordRemoteMutationExecutorDependencyProvider),
  );
});

// ============================================================================
// Remote Data Source Providers
// ============================================================================

final myWordRemoteDataSourceProvider = Provider<IMyWordRemoteDataSource>((ref) {
  return FirebaseMyWordDataSource(
    ref.read(myWordFirebaseDaoProvider),
  );
});

final myWordStatusRemoteDataSourceProvider =
    Provider<IMyWordStatusRemoteDataSource>((ref) {
  return FirebaseMyWordStatusDataSource(
    ref.read(myWordStatusFirebaseDaoProvider),
  );
});

// ============================================================================
// Repository Providers
// ============================================================================

final myWordRepositoryProvider = Provider<IMyWordRepository>((ref) {
  return MyWordRepository(
    ref.read(myWordLocalDataSourceProvider),
    ref.read(myWordOutboxWriterDependencyProvider),
  );
});

final myWordStatusRepositoryProvider = Provider<IMyWordStatusRepository>((ref) {
  return MyWordStatusRepository(
    ref.read(myWordStatusLocalDataSourceProvider),
    ref.read(myWordOutboxWriterDependencyProvider),
  );
});

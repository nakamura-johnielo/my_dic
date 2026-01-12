import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/infrastructure/database/firebase/firebase_provider.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_local_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_status_local_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_word_drift_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_word_status_drift_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/myword/firebase_my_word_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/myword/firebase_my_word_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/myword/i_my_word_remote_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/status/firebase_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/status/firebase_my_word_status_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/status/i_my_word_status_remote_data_source.dart';
import 'package:my_dic/features/my_word/data/repository_impl/drift_my_word_repository.dart';
import 'package:my_dic/features/my_word/data/repository_impl/my_word_status_repository.dart';

// ============================================================================
// Database & DAO Providers
// ============================================================================
final myWordStatusDaoProvider = Provider<MyWordStatusDao>((ref) {
  return MyWordStatusDao(ref.read(databaseProvider));
});

final myWordDaoProvider = Provider<MyWordDao>((ref) {
  return MyWordDao(ref.read(databaseProvider));
});

final myWordLocalDataSourceProvider = Provider<IMyWordLocalDataSource>((ref) {
  return MyWordDriftDataSource(
    ref.read(myWordDaoProvider),
  );
});

final myWordStatusLocalDataSourceProvider = Provider<IMyWordStatusLocalDataSource>((ref) {
  return MyWordStatusDriftDataSource(
    ref.read(myWordStatusDaoProvider),
  );
});

// ============================================================================
// Firebase DAO Providers
// ============================================================================

final myWordFirebaseDaoProvider = Provider<FirebaseMyWordDao>((ref) {
  return FirebaseMyWordDao(ref.read(firestoreDBProvider));
});

final myWordStatusFirebaseDaoProvider = Provider<FirebaseMyWordStatusDao>((ref) {
  return FirebaseMyWordStatusDao(ref.read(firestoreDBProvider));
});

// ============================================================================
// Remote Data Source Providers
// ============================================================================

final myWordRemoteDataSourceProvider = Provider<IMyWordRemoteDataSource>((ref) {
  return FirebaseMyWordDataSource(
    ref.read(myWordFirebaseDaoProvider),
  );
});

final myWordStatusRemoteDataSourceProvider = Provider<IMyWordStatusRemoteDataSource>((ref) {
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
    ref.read(myWordRemoteDataSourceProvider),
  );
});

final myWordStatusRepositoryProvider = Provider<IMyWordStatusRepository>((ref) {
  return MyWordStatusRepository(
    ref.read(myWordStatusLocalDataSourceProvider),
    ref.read(myWordStatusRemoteDataSourceProvider),
  );
});

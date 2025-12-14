import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/features/auth/di/data_di.dart';
import 'package:my_dic/features/auth/domain/usecase/observe_auth_state_interactor.dart';
import 'package:my_dic/features/auth/domain/usecase/signin.dart';
import 'package:my_dic/features/auth/domain/usecase/signup.dart';
import 'package:my_dic/features/auth/domain/usecase/verify_email.dart';
import 'package:my_dic/features/user/domain/usecase/get_user.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/features/auth/data/repository_impl/firebase_auth_repository_impl.dart';
import 'package:my_dic/features/user/data/repository_impl/firebase_user_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/sync%20service/word_status_sync_service.dart';
import 'package:my_dic/core/infrastructure/repository/wordstatus_repository.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/syncstatus_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/word_status_dao.dart';
import 'package:my_dic/features/user/data/data_source/remote/user_profile_dao.dart';
import 'package:my_dic/features/auth/data/data_source/remote/firebase_auth_dao.dart';
import 'package:my_dic/_Framework_Driver/remote/firebase/DAO/word_status_dao.dart';
import 'package:my_dic/core/infrastructure/firebase/firebase_provider.dart';

// firebase

// ====data
//Dao

final remoteWordStatusDaoProvider =
    Provider((ref) => FirebaseWordStatusDao(ref.watch(firestoreDBProvider)));

// repository

final wordStatusRepositoryProvider = Provider<IWordStatusRepository>((ref) {
  final local = ref.read(localWordStatusDaoProvider);
  final remote = ref.read(remoteWordStatusDaoProvider);
  // final localDataSource = ref.watch(localWordStatusDaoProvider);
  // return WordStatusRepository(dataSource, localDataSource);
  return WordStatusRepository(remote, local);
});

//====================================================----
//==================================================
// UseCase

// service
final syncStatusDaoProvider = Provider((ref) => SyncStatusDao());

final lastSyncProvider =
    FutureProvider.family<DateTime?, String>((ref, key) async {
  final dao = ref.watch(syncStatusDaoProvider);
  return await dao.getLastSync(key);
});

final setLastSyncProvider =
    Provider.family<void Function(DateTime), String>((ref, key) {
  final dao = ref.watch(syncStatusDaoProvider);
  return (dateTime) async {
    await dao.setLastSync(key, dateTime);
    ref.invalidate(lastSyncProvider(key)); // 更新後に再取得
  };
});

final wordStatusSyncServiceProvider = Provider<WordStatusSyncService>((ref) {
  final remoteDao = ref.watch(remoteWordStatusDaoProvider);
  final localDao = ref.watch(localWordStatusDaoProvider);
  return WordStatusSyncService(remoteDao, localDao);
});

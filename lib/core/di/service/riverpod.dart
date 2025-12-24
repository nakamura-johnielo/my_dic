import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/di/usecase/usecase_di.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/service/word_status_sync_service.dart';
import 'package:my_dic/core/infrastructure/repository/wordstatus_repository.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/shared_preferences_syncstatus_dao.dart';
import 'package:my_dic/core/infrastructure/database/dao/remote/firebase_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/firebase_provider.dart';

// firebase

// ====data
//Dao

// repository



//====================================================----
//==================================================
// UseCase

// service

// final lastSyncProvider =
//     FutureProvider<DateTime?>((ref) async {
//   final dao = ref.watch(sharedPreferenceSyncStatusDaoProvider);
//   return await dao.getLastSyncDate();
// });

// final setLastSyncProvider =
//     Provider<void Function(DateTime)>((ref) {
//   final dao = ref.watch(sharedPreferenceSyncStatusDaoProvider);
//   return (dateTime) async {
//     await dao.updateLastSyncDate( dateTime);
//     ref.invalidate(lastSyncProvider); // 更新後に再取得
//   };
// });

// final wordStatusSyncServiceProvider = Provider<WordStatusSyncService>((ref) {
//   final remoteDao = ref.watch(remoteWordStatusDaoProvider);
//   final localDao = ref.watch(localWordStatusDaoProvider);
//   return WordStatusSyncService(remoteDao, localDao,
//       ref.read(syncEspJpnWordStatusUseCaseProvider));
// });

// import 'dart:async';

// import 'package:my_dic/core/infrastructure/database/database_provider.dart';
// import 'package:my_dic/core/infrastructure/dto/wordStatusEntity.dart';

// import 'package:my_dic/core/infrastructure/database/dao/local/esp_jpn/esp_jpn_word_status_dao.dart'
//     as local;
// import 'package:my_dic/core/infrastructure/database/dao/remote/firebase_word_status_dao.dart'
//     as remote;
// import 'package:my_dic/core/service/usecase/i_sync_esp_jpn_word_status_usecase.dart';
// import 'package:my_dic/core/service/usecase/sync_esp_jpn_word_status_interactor.dart';

// class WordStatusSyncService {
//   final remote.FirebaseWordStatusDao _remote;
//   final local.EspJpnWordStatusDao _local;
//   final ISyncEspJpnWordStatusUseCase _syncUseCase;

//   WordStatusSyncService(this._remote, this._local, this._syncUseCase);

//   StreamSubscription<List<WordStatusDTO>>? _sub;

//   /// 一回限りの同期
//   Future<void> syncOnce(String userId)async{
//     await _syncUseCase.syncOnce(userId);
//   }

//   /// 同期開始。onSynced: 同期処理後に最新 updatedAt を渡す
//   void startSync(
//       String userId, DateTime lastSync, void Function(DateTime) onSynced) {
//     _sub?.cancel();
//     _sub = _remote.watchUpdatedAfter(userId, lastSync).listen((entities) async {
//       if (entities.isEmpty) return;
//       DateTime maxUpdated = lastSync;
//       for (final entity in entities) {
//         print(
//             "${entity.wordId}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!status UPDATED");
//         await _local.updateStatus(
//           EspJpnWordStatusTableData(
//             wordId: entity.wordId,
//             isLearned: entity.isLearned,
//             isBookmarked: entity.isBookmarked,
//             hasNote: entity.hasNote,
//             editAt: entity.updatedAt.toIso8601String(),
//           ),
//         );
//         if (entity.updatedAt.isAfter(maxUpdated)) {
//           maxUpdated = entity.updatedAt;
//         }
//       }
//       onSynced(maxUpdated);
//     });
//   }

//     void dispose() {
//     _sub?.cancel();
//     _sub = null;
//   }
// }

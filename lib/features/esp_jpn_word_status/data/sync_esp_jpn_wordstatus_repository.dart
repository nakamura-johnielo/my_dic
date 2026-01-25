// import 'package:my_dic/core/domain/i_repository/i_sync_repository.dart';
// import 'package:my_dic/core/domain/i_repository/i_sync_status_repository.dart';
// import 'package:my_dic/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart';
// import 'package:my_dic/core/infrastructure/datasource/word_status/i_remote_word_status_data_source.dart';
// import 'package:my_dic/core/shared/consts/dates.dart';
// import 'package:my_dic/core/shared/errors/domain_errors.dart';
// import 'package:my_dic/core/shared/utils/result.dart';
// import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
// import 'package:my_dic/core/infrastructure/repositories/converters/word_status_converter.dart';
// import 'package:my_dic/features/esp_jpn_word_status/data/wordStatusEntity.dart';

// class SyncEspJpnWordStatusRepository implements ISyncRepository {
//   final IRemoteWordStatusDataSource _remote;
//   final ILocalWordStatusDataSource _local;

//   final ISyncStatusRepository _localSyncStatusRepository;

//   SyncEspJpnWordStatusRepository(
//       this._remote, this._local, this._localSyncStatusRepository);



//   @override
//   Future<Result<void>> syncOnUpdatedRemote(String userId, String id) async {
//   print("syncOnUpdatedRemote called for wordId: $id");
//     //時刻判定
//     //localの時刻が古ければ更新
//     final remoteItem =
//         await _remote.getWordStatusById(userId, int.parse(id));

//     if (remoteItem==null) {
//       print(
//           'Failed to get remote word status by id: ${id}');
//       return Result.failure(NotFoundError(
//           message:
//               'Failed to get remote word status by id: ${id}'));
//     }


//     // if (remoteItem == null) {
//     //   //remoteに存在しない場合
//     //   return Result.failure(UnexpectedError(
//     //     message: 'リモートの単語ステータスが見つかりません',
//     //   ));
//     // }

//     final syncResult = await _syncHandle(userId, remoteItem);
//     if (syncResult.isFailure) {
//       return Result.failure(syncResult.errorOrNull!);
//     }

//     return await _updateLocalLastSyncDate();
//   }


//   @override
//   Future<Result<void>> syncOnce(String userId) async {
//     print("syncOnce start");
//     //最終同期時刻以降の差分を同期する

//     // localの最終同期時刻取得
//     final localLastSyncDate = await _getLastSyncDate();

//     //remoteのその時刻以降の更新データを取得
//     final remoteData =
//         await _remote.getWordStatusAfter(userId, localLastSyncDate);
//     // print(">>>>>>unsync remoteData");

//     // (remoteData as List<WordStatus> ).map((e) => print(">>>>>>unsync remote wordId: ${e.wordId}"));

//     //remoteの値でlocalを更新した場合、そのwordIdを格納
//     final List<int> wordIdsUpdatedByRemote = [];

//     if ((remoteData as List<WordStatus>).isNotEmpty) {
//       for (var remoteItem in remoteData) {
//         final idResult = await _syncHandle(userId, remoteItem);
//         final id = idResult.when(
//           success: (data) => data,
//           failure: (error) {
//             print('Failed to sync handle: ${error.message}');
//             return null;
//           },
//         );
//         if (id != null) {
//           wordIdsUpdatedByRemote.add(id);
//         }
//       }
//     }

//     final uploadResult = await _uploadLocal2Remote(
//         userId, localLastSyncDate, wordIdsUpdatedByRemote);
//     if (uploadResult.isFailure) {
//       return uploadResult;
//     }

//     final updateDateResult = await _updateLocalLastSyncDate();
//     if (updateDateResult.isFailure) {
//       return updateDateResult;
//     }

//     return const Result.success(null);
//   }

//   @override
//   Stream<List<int>> watchRemoteChangedIds(String userId) {
//     //final lastSyncTime =await _getLastSyncDate();
//     //final lastSyncTime = DateTime.now().toUtc();
//     return _remote.watchChangedIds(userId);
//   }

// //=========local method==========================================

//   Future<DateTime> _getLastSyncDate() async {
//     final result = await _localSyncStatusRepository.getLastSyncDate();

//     return result.when(
//       success: (localLastSyncDate) => localLastSyncDate ?? MyDateTime.sentinel,
//       failure: (error) {
//         print('Failed to get last sync date: $error');
//         return MyDateTime.sentinel;
//       },
//     );
//   }
  
//   Future<Result<void>> _updateLocalLastSyncDate() async {
//     //TODO servertimestapで同期時刻取得sる用変更
//     final now = DateTime.now().toUtc();
//     final result = await _localSyncStatusRepository.updateSyncDate(now);

//     result.when(
//       success: (_) => print('Sync date updated successfully'),
//       failure: (error) => print('Failed to update sync date: $error'),
//     );

//     return result;
//   }

//   Future<Result<int?>> _syncHandle(
//       String userId, WordStatusDTO remoteItem) async {
//     //remoteの値でlocalが更新された場合、wordId そうではない場合null
//     //与えられたWordStatusとlocalの時刻を最新の法を同期
//     //localに反映、remoteに反映

//     final localData = await _local.getWordStatusById(remoteItem.wordId);

//     if (localData == null) {  
//       print('Failed to get local word status by id: ${remoteItem.wordId}');
    
//       // ローカルに存在しない場合は、リモートのデータでローカルを作成
//       await _local.updateWordStatus(WordStatusConverter.toTableData(remoteItem.toEntity()));

//       return Result.success(remoteItem.wordId);
//       // return Result.failure(NotFoundError(
//       //     message:
//       //         'Failed to get local word status by id: ${remoteItem.wordId}'));
//     }

   

//     final remoteUpdatedAt = remoteItem.updatedAt;
//     final localUpdatedAt = DateTime.parse(localData.editAt).toUtc();

//     print("~~~~~~ Remote: $remoteUpdatedAt, Local: $localUpdatedAt");

//     if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
//       print("Remote is newer for wordId: ${remoteItem.wordId}");
//       // リモートの方が新しい場合
//       // local更新
//       await _local.updateWordStatus(
//           WordStatusConverter.toTableData(remoteItem.toEntity()));
//       return Result.success(remoteItem.wordId);
//     } else if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
//       print("Local is newer for wordId: ${remoteItem.wordId}");
//       // ローカルの方が新しい場合
//       // remote更新
//       await _remote.updateWordStatus(userId,
//           WordStatusDTO.fromAppEntity(WordStatusConverter.toEntity(localData)));
//     } else {
//       // 同じ場合
//       //何もしない
//       //loop止める

//       // ローカルの方が新しい場合とおなじとする
//       //remote更新
//       //await _remoteWordStatusRepository.updateWordStatus(userId, localData);
//     }
//     return const Result.success(null);
//   }

//   Future<Result<void>> _uploadLocal2Remote(
//       String userId, DateTime datetime, List<int> ids) async {
//     final localData=
//         await _local.getWordStatusAfter(datetime);

//     if (localData.isEmpty) {
//       print(
//           'Failed to get local word status after: ${datetime.toIso8601String()}');
//       return Result.failure(NotFoundError(
//           message:
//               'Failed to get local word status after: ${datetime.toIso8601String()}'));
//     }


//     //print("local espjpn wordstatus sync length: ${localData.length}");
//     if (localData.isEmpty) return const Result.success(null);
// final input=localData.map((e) => WordStatusDTO.fromAppEntity(WordStatusConverter.toEntity(e))).toList();
//      await _remote.updateWordStatusBatch(
//         userId, input);
//     return const Result.success(null);

//   }

// }

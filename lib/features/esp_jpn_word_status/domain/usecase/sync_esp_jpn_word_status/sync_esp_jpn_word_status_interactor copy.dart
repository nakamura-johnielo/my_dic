// import 'package:my_dic/core/domain/i_repository/i_sync_repository.dart';
// import 'package:my_dic/core/domain/usecase/i_sync_usecase.dart';
// import 'package:my_dic/core/shared/consts/dates.dart';
// import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
// import 'package:my_dic/core/domain/i_repository/i_sync_status_repository.dart';
// import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';
// import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/sync_esp_jpn_word_status/i_sync_esp_jpn_word_status_usecase.dart';
// import 'package:my_dic/core/shared/errors/app_error.dart';
// import 'package:my_dic/core/shared/errors/unexpected_error.dart';
// import 'package:my_dic/core/shared/utils/result.dart';

// //TODO Repository化
// class SyncEspJpnWordStatusInteractor implements ISyncUseCase {
//   final ISyncStatusRepository _localSyncStatusRepository;
// // final ISyncStatusRepository _remote;
//   // final IWordStatusRepository _wordStatusRepository;
//   // final ILocalWordStatusRepository _localWordStatusRepository;
//   // final IRemoteWordStatusRepository _remoteWordStatusRepository;
//   final ISyncRepository _syncWordStatusRepository;

//   SyncEspJpnWordStatusInteractor(
//       this._localSyncStatusRepository,
//       // this._wordStatusRepository,
//       // this._localWordStatusRepository,
//       // this._remoteWordStatusRepository,
//       this._syncWordStatusRepository);

//   @override
//   Future<Result<void>> syncOnce(String userId) async {
//     print("syncOnce start");
//     //最終同期時刻以降の差分を同期する
//     await _syncWordStatusRepository.syncOnce(userId);
    
//     return const Result.success(null);
//   }

//   @override
//   Future<Result<void>> syncOnUpdatedLocal(String userId, int wordId) async {
//     print("syncOnUpdatedLocal called for wordId: $wordId");
//     //remoteへの反映処理
//     //remoteの時刻が古ければ更新
//     final remoteItemResult =
//         await _syncWordStatusRepository.getRemoteWordStatusById(userId, wordId);

//     if (remoteItemResult.isFailure) {
//       print(
//           'Failed to get remote word status by id: ${remoteItemResult.errorOrNull?.message}');
//       return Result.failure(remoteItemResult.errorOrNull!);
//     }

//     final remoteItem = remoteItemResult.dataOrNull;

//     if (remoteItem == null) {
//       //remoteに存在しない場合はそのまま更新
//       final localDataResult =
//           await _syncWordStatusRepository.getLocalWordStatusById(wordId);

//       if (localDataResult.isFailure) {
//         print(
//             'Failed to get local word status by id: ${localDataResult.errorOrNull?.message}');
//         return Result.failure(localDataResult.errorOrNull!);
//       }

//       final localData = localDataResult.dataOrNull;
//       if (localData == null) {
//         return Result.failure(UnexpectedError(
//           message: 'ローカルの単語ステータスが見つかりません',
//         ));
//       }

//       final updateResult = await _syncWordStatusRepository
//           .updateRemoteWordStatus(localData, userId, null);
//       if (updateResult.isFailure) {
//         return updateResult;
//       }

//       return await _updateLocalLastSyncDate();
//     }

//     final syncResult = await _syncHandle(userId, remoteItem);
//     if (syncResult.isFailure) {
//       return Result.failure(syncResult.errorOrNull!);
//     }

//     return await _updateLocalLastSyncDate();
//   }

//   @override
//   Future<Result<void>> syncOnUpdatedRemote(String userId, int wordId) async {
//     print("syncOnUpdatedRemote called for wordId: $wordId");
//     //時刻判定
//     //localの時刻が古ければ更新
//     final remoteItemResult =
//         await _syncWordStatusRepository.getRemoteWordStatusById(userId, wordId);

//     if (remoteItemResult.isFailure) {
//       print(
//           'Failed to get remote word status by id: ${remoteItemResult.errorOrNull?.message}');
//       return Result.failure(remoteItemResult.errorOrNull!);
//     }

//     final remoteItem = remoteItemResult.dataOrNull;

//     if (remoteItem == null) {
//       //remoteに存在しない場合
//       return Result.failure(UnexpectedError(
//         message: 'リモートの単語ステータスが見つかりません',
//       ));
//     }

//     final syncResult = await _syncHandle(userId, remoteItem);
//     if (syncResult.isFailure) {
//       return Result.failure(syncResult.errorOrNull!);
//     }

//     return await _updateLocalLastSyncDate();
//   }

 
//   Future<Result<int?>> _syncHandle(String userId, WordStatus remoteItem) async {
//     //remoteの値でlocalが更新された場合、wordId そうではない場合null
//     //与えられたWordStatusとlocalの時刻を最新の法を同期
//     //localに反映、remoteに反映

//     final localDataResult = await _syncWordStatusRepository
//         .getLocalWordStatusById(remoteItem.wordId);

//     if (localDataResult.isFailure) {
//       print(
//           'Failed to get local word status by id: ${localDataResult.errorOrNull?.message}');
//       return Result.failure(localDataResult.errorOrNull!);
//     }

//     final localData = localDataResult.dataOrNull;

//     if (localData == null) {
//       // ローカルに存在しない場合は、リモートのデータでローカルを作成
//       final updateResult = await _syncWordStatusRepository
//           .updateLocalWordStatus(remoteItem, remoteItem.editAt);
//       if (updateResult.isFailure) {
//         return Result.failure(updateResult.errorOrNull!);
//       }
//       return Result.success(remoteItem.wordId);
//     }

//     final remoteUpdatedAt = remoteItem.editAt;
//     final localUpdatedAt = localData.editAt;

//     print("~~~~~~ Remote: $remoteUpdatedAt, Local: $localUpdatedAt");

//     if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
//       print("Remote is newer for wordId: ${remoteItem.wordId}");
//       // リモートの方が新しい場合
//       // local更新
//       final updateResult =
//           await _syncWordStatusRepository.updateLocalWordStatus(
//         remoteItem,
//         remoteItem.editAt,
//       );
//       if (updateResult.isFailure) {
//         return Result.failure(updateResult.errorOrNull!);
//       }
//       return Result.success(remoteItem.wordId);
//     } else if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
//       print("Local is newer for wordId: ${remoteItem.wordId}");
//       // ローカルの方が新しい場合
//       // remote更新
//       final updateResult = await _syncWordStatusRepository
//           .updateRemoteWordStatus(localData, userId, null);
//       if (updateResult.isFailure) {
//         return Result.failure(updateResult.errorOrNull!);
//       }
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

//   @override
//   Stream<List<int>> watchRemoteChangedIds(String userId) {
//     //final lastSyncTime =await _getLastSyncDate();
//     //final lastSyncTime = DateTime.now().toUtc();
//     return _syncWordStatusRepository.watchRemoteChangedIds(userId);
//   }

//   @override
//   Stream<List<int>> watchLocalChangedIds() {
//     //TODO driftでは無理
//     //final dateTime =await _getLastSyncDate();
//     final dateTime = DateTime.now().toUtc();
//     return _syncWordStatusRepository.watchLocalChangedIds(dateTime);
//   }
// }

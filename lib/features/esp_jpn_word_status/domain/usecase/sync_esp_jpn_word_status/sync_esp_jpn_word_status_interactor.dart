import 'package:my_dic/core/domain/usecase/i_sync_usecase.dart';
import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/core/shared/consts/syncPriority.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_sync_status_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/sync_esp_jpn_word_status/i_sync_esp_jpn_word_status_usecase.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';

//TODO Repository化
class SyncEspJpnWordStatusInteractor implements ISyncUseCase {
  final ISyncStatusRepository _localSyncStatusRepository;
// final ISyncStatusRepository _remote;
  // final IWordStatusRepository _wordStatusRepository;
  // final ILocalWordStatusRepository _localWordStatusRepository;
  // final IRemoteWordStatusRepository _remoteWordStatusRepository;
  final IWordStatusRepository _wordStatusRepository;

  SyncEspJpnWordStatusInteractor(
      this._localSyncStatusRepository,
      // this._wordStatusRepository,
      // this._localWordStatusRepository,
      // this._remoteWordStatusRepository,
      this._wordStatusRepository);

  @override
  int get priority => Syncpriority.baseStatus;

  @override
  Future<Result<void>> syncOnce(String userId) async {
    print("syncOnce start");
    //最終同期時刻以降の差分を同期する

    // localの最終同期時刻取得
    final localLastSyncDate = await _getLastSyncDate();

    //remoteのその時刻以降の更新データを取得
    final remoteDataResult = await _wordStatusRepository
        .getRemoteWordStatusAfter(userId, localLastSyncDate);
    // print(">>>>>>unsync remoteData");

    final remoteData = remoteDataResult.when(
      success: (data) => data,
      failure: (error) {
        print('Failed to get remote word status after: ${error.message}');
        return error;
      },
    );

    // remoteDataがエラーの場合は早期リターン
    if (remoteData is AppError) {
      return Result.failure(remoteData);
    }

    // (remoteData as List<WordStatus> ).map((e) => print(">>>>>>unsync remote wordId: ${e.wordId}"));

    //remoteの値でlocalを更新した場合、そのwordIdを格納
    final List<int> wordIdsUpdatedByRemote = [];

    if ((remoteData as List<WordStatus>).isNotEmpty) {
      for (var remoteItem in remoteData) {
        final idResult = await _syncHandle(userId, remoteItem);
        final id = idResult.when(
          success: (data) => data,
          failure: (error) {
            print('Failed to sync handle: ${error.message}');
            return null;
          },
        );
        if (id != null) {
          wordIdsUpdatedByRemote.add(id);
        }
      }
    }

    final uploadResult = await _uploadLocal2Remote(
        userId, localLastSyncDate, wordIdsUpdatedByRemote);

    if (uploadResult.isFailure) {
      return uploadResult;
    }

    final updateDateResult = await _updateLocalLastSyncDate();
    if (updateDateResult.isFailure) {
      return updateDateResult;
    }

    return const Result.success(null);
  }

  @override
  Future<Result<void>> syncOnUpdatedLocal(String userId, String wordId) async {
    print("syncOnUpdatedLocal called for wordId: $wordId");
    //remoteへの反映処理
    //remoteの時刻が古ければ更新
    final remoteItemResult = await _wordStatusRepository
        .getRemoteWordStatusById(userId, int.parse(wordId));

    if (remoteItemResult.isFailure) {
      print(
          'Failed to get remote word status by id: ${remoteItemResult.errorOrNull?.message}');
      return Result.failure(remoteItemResult.errorOrNull!);
    }

    final remoteItem = remoteItemResult.dataOrNull;

    if (remoteItem == null) {
      //remoteに存在しない場合はそのまま更新
      final localDataResult =
          await _wordStatusRepository.getLocalWordStatusById(int.parse(wordId));

      if (localDataResult.isFailure) {
        print(
            'Failed to get local word status by id: ${localDataResult.errorOrNull?.message}');
        return Result.failure(localDataResult.errorOrNull!);
      }

      final localData = localDataResult.dataOrNull;
      if (localData == null) {
        return Result.failure(UnexpectedError(
          message: 'ローカルの単語ステータスが見つかりません',
        ));
      }

      final updateResult = await _wordStatusRepository.updateRemoteWordStatus(
          localData, userId, null);
      if (updateResult.isFailure) {
        return updateResult;
      }

      return await _updateLocalLastSyncDate();
    }

    final syncResult = await _syncHandle(userId, remoteItem);
    if (syncResult.isFailure) {
      return Result.failure(syncResult.errorOrNull!);
    }

    return await _updateLocalLastSyncDate();
  }

  @override
  Future<Result<void>> syncOnUpdatedRemote(String userId, String wordId) async {
    print("syncOnUpdatedRemote called for wordId: $wordId");
    //時刻判定
    //localの時刻が古ければ更新
    final remoteItemResult = await _wordStatusRepository
        .getRemoteWordStatusById(userId, int.parse(wordId));

    if (remoteItemResult.isFailure) {
      print(
          'Failed to get remote word status by id: ${remoteItemResult.errorOrNull?.message}');
      return Result.failure(remoteItemResult.errorOrNull!);
    }

    final remoteItem = remoteItemResult.dataOrNull;

    if (remoteItem == null) {
      //remoteに存在しない場合
      return Result.failure(UnexpectedError(
        message: 'リモートの単語ステータスが見つかりません',
      ));
    }

    final syncResult = await _syncHandleOnRemoteChanged(userId, remoteItem);
    if (syncResult.isFailure) {
      return Result.failure(syncResult.errorOrNull!);
    }

    return await _updateLocalLastSyncDate();
  }

  @override
  Stream<List<int>> watchRemoteChangedIds(String userId) {
    //final lastSyncTime =await _getLastSyncDate();
    //final lastSyncTime = DateTime.now().toUtc();
    return _wordStatusRepository.watchRemoteChangedIds(userId);
  }

//=========Local method========================================================================

  Future<DateTime> _getLastSyncDate() async {
    final result = await _localSyncStatusRepository.getLastSyncDate();

    return result.when(
      success: (localLastSyncDate) => localLastSyncDate ?? MyDateTime.sentinel,
      failure: (error) {
        print('Failed to get last sync date: $error');
        return MyDateTime.sentinel;
      },
    );
  }

  Future<Result<void>> _uploadLocal2Remote(
      String userId, DateTime datetime, List<int> ids) async {
    final localDataResult =
        await _wordStatusRepository.getLocalWordStatusAfter(datetime);

    if (localDataResult.isFailure) {
      print(
          'Failed to get local word status after: ${localDataResult.errorOrNull?.message}');
      return Result.failure(localDataResult.errorOrNull!);
    }

    final localData = localDataResult.dataOrNull!;

    print("local espjpnstatus sync length: ${localData.length}");
    if (localData.isEmpty) return const Result.success(null);

    final result = await _wordStatusRepository.updateBatchRemoteWordStatus(
        localData, userId, null);

    result.when(
      success: (_) => print('Batch update successful'),
      failure: (error) => print('Batch update failed: ${error.message}'),
    );

    return result;
  }

  Future<Result<void>> _updateLocalLastSyncDate() async {
    //TODO servertimestapで同期時刻取得sる用変更
    final now = DateTime.now().toUtc();
    final result = await _localSyncStatusRepository.updateSyncDate(now);

    result.when(
      success: (_) => print('Sync date updated successfully'),
      failure: (error) => print('Failed to update sync date: $error'),
    );

    return result;
  }

  Future<Result<int?>> _syncHandle(String userId, WordStatus remoteItem) async {
    //remoteの値でlocalが更新された場合、wordId そうではない場合null
    //与えられたWordStatusとlocalの時刻を最新の法を同期
    //localに反映、remoteに反映

    final localDataResult =
        await _wordStatusRepository.getLocalWordStatusById(remoteItem.wordId);

    if (localDataResult.isFailure) {
      print(
          'Failed to get local word status by id: ${localDataResult.errorOrNull?.message}');
      return Result.failure(localDataResult.errorOrNull!);
    }

    final localData = localDataResult.dataOrNull;

    if (localData == null) {
      // ローカルに存在しない場合は、リモートのデータでローカルを作成
      final updateResult = await _wordStatusRepository.updateLocalWordStatus(
          remoteItem.wordId,
          remoteItem.isLearned ? 1 : null,
          remoteItem.isBookmarked ? 1 : null,
          remoteItem.hasNote ? 1 : null,
          remoteItem.editAt);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    }

    final remoteUpdatedAt = remoteItem.editAt;
    final localUpdatedAt = localData.editAt;

    print("~~~~~~ Remote: $remoteUpdatedAt, Local: $localUpdatedAt");

    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      print("Remote is newer for wordId: ${remoteItem.wordId}");
      // リモートの方が新しい場合
      // local更新
      final updateResult = await _wordStatusRepository.updateLocalWordStatus(
          remoteItem.wordId,
          remoteItem.isLearned ? 1 : null,
          remoteItem.isBookmarked ? 1 : null,
          remoteItem.hasNote ? 1 : null,
          remoteItem.editAt);

      if (updateResult.isFailure) {
        return Result.failure(updateResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    } else if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
      print("Local is newer for wordId: ${remoteItem.wordId}");
      // ローカルの方が新しい場合
      // remote更新
      final updateResult = await _wordStatusRepository.updateRemoteWordStatus(
          localData, userId, null);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.errorOrNull!);
      }
    } else {
      // 同じ場合
      //何もしない
      //loop止める

      // ローカルの方が新しい場合とおなじとする
      //remote更新
      //await _remoteWordStatusRepository.updateWordStatus(userId, localData);
    }
    return const Result.success(null);
  }

  Future<Result<int?>> _syncHandleOnRemoteChanged(String userId, WordStatus remoteItem) async {
    //remoteの値でlocalが更新された場合、wordId そうではない場合null
    //与えられたWordStatusとlocalの時刻を最新の法を同期
    //localに反映、remoteに反映

    final localDataResult =
        await _wordStatusRepository.getLocalWordStatusById(remoteItem.wordId);

    if (localDataResult.isFailure) {
      print(
          'Failed to get local word status by id: ${localDataResult.errorOrNull?.message}');
      return Result.failure(localDataResult.errorOrNull!);
    }

    final localData = localDataResult.dataOrNull;

    if (localData == null) {
      // ローカルに存在しない場合は、リモートのデータでローカルを作成
      final updateResult = await _wordStatusRepository.updateLocalWordStatus(
          remoteItem.wordId,
          remoteItem.isLearned ? 1 : null,
          remoteItem.isBookmarked ? 1 : null,
          remoteItem.hasNote ? 1 : null,
          remoteItem.editAt);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    }

    final remoteUpdatedAt = remoteItem.editAt;
    final localUpdatedAt = localData.editAt;

    print("~~~~~~ Remote: $remoteUpdatedAt, Local: $localUpdatedAt");

    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      print("Remote is newer for wordId: ${remoteItem.wordId}");
      // リモートの方が新しい場合
      // local更新
      final updateResult = await _wordStatusRepository.updateLocalWordStatus(
          remoteItem.wordId,
          remoteItem.isLearned ? 1 : null,
          remoteItem.isBookmarked ? 1 : null,
          remoteItem.hasNote ? 1 : null,
          remoteItem.editAt);

      if (updateResult.isFailure) {
        return Result.failure(updateResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    } 
    return const Result.success(null);
  }
}


import 'package:my_dic/core/domain/i_repository/i_sync_status_repository.dart';
import 'package:my_dic/core/domain/usecase/i_sync_usecase.dart';
import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/core/shared/consts/syncPriority.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word_status.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/update_my_word_status/update_my_word_status_repository_input_data.dart';

class SyncMyWordStatusUsecase implements ISyncUseCase{
  @override
  int get priority => Syncpriority.baseStatus;
  
  final ISyncStatusRepository _localSyncStatusRepository;
  final IMyWordStatusRepository _myWordStatusRepository;

  SyncMyWordStatusUsecase(this._localSyncStatusRepository, this._myWordStatusRepository);



  @override
  Future<Result<void>> syncOnce(String userId) async {
    final localLastSyncDate = await _getLastSyncDate();

    final remoteDataResult =
        await _myWordStatusRepository.getRemoteStatusAfter(userId, localLastSyncDate);

    final remoteData = remoteDataResult.when(
      success: (data) => data,
      failure: (error) => error,
    );

    if (remoteData is AppError) {
      return Result.failure(remoteData);
    }

    final List<int> wordIdsUpdatedByRemote = [];

    if ((remoteData as List<MyWordStatus>).isNotEmpty) {
      for (final remoteItem in remoteData) {
        final idResult = await _syncHandleOnOnce(userId, remoteItem);
        final updatedId = idResult.when(
          success: (data) => data,
          failure: (_) => null,
        );
        if (updatedId != null) {
          wordIdsUpdatedByRemote.add(updatedId);
        }
      }
    }

    final uploadResult =
        await _uploadLocal2Remote(userId, localLastSyncDate, wordIdsUpdatedByRemote);
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
    final remoteItemResult =
        await _myWordStatusRepository.getRemoteStatusById(userId, int.parse(wordId));

    if (remoteItemResult.isFailure) {
      return Result.failure(remoteItemResult.errorOrNull!);
    }

    final remoteItem = remoteItemResult.dataOrNull;

    if (remoteItem == null) {
      final localDataResult = await _myWordStatusRepository.getLocalStatusById(int.parse(wordId));

      if (localDataResult.isFailure) {
        return Result.failure(localDataResult.errorOrNull!);
      }

      final localData = localDataResult.dataOrNull;
      if (localData == null) {
        return Result.failure(NotFoundError(
          message: 'ローカルのMyWordが見つかりません',
        ));
      }

      final updateResult =
          await _myWordStatusRepository.updateRemoteStatus(userId, localData, null);

      if (updateResult.isFailure) {
        return updateResult;
      }

      return _updateLocalLastSyncDate();
    }

    final syncResult = await _syncHandle(userId, remoteItem);
    if (syncResult.isFailure) {
      return Result.failure(syncResult.errorOrNull!);
    }

    return _updateLocalLastSyncDate();
  }

  @override
  Future<Result<void>> syncOnUpdatedRemote(String userId, String wordId) async {
    final remoteItemResult =
        await _myWordStatusRepository.getRemoteStatusById(userId, int.parse(wordId));

    if (remoteItemResult.isFailure) {
      return Result.failure(remoteItemResult.errorOrNull!);
    }

    final remoteItem = remoteItemResult.dataOrNull;

    if (remoteItem == null) {
      return Result.failure(NotFoundError(
        message: 'リモートのMyWordが見つかりません',
      ));
    }

    final syncResult = await _syncHandleOnRemoteChanged(userId, remoteItem);
    if (syncResult.isFailure) {
      return Result.failure(syncResult.errorOrNull!);
    }

    return _updateLocalLastSyncDate();
  }

 @override
  Stream<List<int>> watchRemoteChangedIds(String userId) {
    return _myWordStatusRepository.watchRemoteChangedIds(userId);
  }

//========local method================================================

  Future<Result<void>> _updateLocalLastSyncDate() async {
    final now = DateTime.now().toUtc();
    return _localSyncStatusRepository.updateSyncDate(now);
  }

  Future<DateTime> _getLastSyncDate() async {
    final result = await _localSyncStatusRepository.getLastSyncDate();

    return result.when(
      success: (localLastSyncDate) => localLastSyncDate ?? MyDateTime.sentinel,
      failure: (_) => MyDateTime.sentinel,
    );
  }

  Future<Result<int?>> _syncHandle(String userId, MyWordStatus remoteItem) async {
    final localDataResult =
        await _myWordStatusRepository.getLocalStatusById(remoteItem.wordId);

    if (localDataResult.isFailure) {
      return Result.failure(localDataResult.errorOrNull!);
    }

    final localData = localDataResult.dataOrNull;

    if (localData == null) {
      final input=UpdateMyWordStatusRepositoryInputData (
        remoteItem.wordId,
        remoteItem.isLearned?1:0,
        remoteItem.isBookmarked?1:0,
        null,// remoteItem.hasNote?1:0,
        remoteItem.editAt,
        null
      );
      final createResult = await _myWordStatusRepository.updateLocalStatus(input);
      if (createResult.isFailure) {
        return Result.failure(createResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    }

    final remoteUpdatedAt = remoteItem.editAt;
    final localUpdatedAt = localData.editAt;

    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      
      final input=UpdateMyWordStatusRepositoryInputData (
        remoteItem.wordId,
        remoteItem.isLearned?1:0,
        remoteItem.isBookmarked?1:0,
        null,// remoteItem.hasNote?1:0,
        remoteItem.editAt,
        null
      );
      final updateResult =
          await _myWordStatusRepository.updateLocalStatus(input);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    }

    if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
      final updateResult =
          await _myWordStatusRepository.updateRemoteStatus(userId, localData, null);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.errorOrNull!);
      }
    }

    return const Result.success(null);
  }


  Future<Result<int?>> _syncHandleOnOnce(String userId, MyWordStatus remoteItem) async {
    final localDataResult =
        await _myWordStatusRepository.getLocalStatusById(remoteItem.wordId);

    if (localDataResult.isFailure) {
      return Result.failure(localDataResult.errorOrNull!);
    }

    final localData = localDataResult.dataOrNull;

    if (localData == null) {
      final input=UpdateMyWordStatusRepositoryInputData (
        remoteItem.wordId,
        remoteItem.isLearned?1:0,
        remoteItem.isBookmarked?1:0,
        null,// remoteItem.hasNote?1:0,
        remoteItem.editAt,
        null
      );
      final createResult = await _myWordStatusRepository.updateLocalStatus(input);
      if (createResult.isFailure) {
        return Result.failure(createResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    }

    final remoteUpdatedAt = remoteItem.editAt;
    final localUpdatedAt = localData.editAt;

    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      
      final input=UpdateMyWordStatusRepositoryInputData (
        remoteItem.wordId,
        remoteItem.isLearned?1:0,
        remoteItem.isBookmarked?1:0,
        null,// remoteItem.hasNote?1:0,
        remoteItem.editAt,
        null
      );
      final updateResult =
          await _myWordStatusRepository.updateLocalStatus(input);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    }

    if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
      final updateResult =
          await _myWordStatusRepository.updateRemoteStatus(userId, localData, null);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.errorOrNull!);
      }
    }

    return const Result.success(null);
  }


  Future<Result<int?>> _syncHandleOnRemoteChanged(String userId, MyWordStatus remoteItem) async {
    final localDataResult =
        await _myWordStatusRepository.getLocalStatusById(remoteItem.wordId);

    if (localDataResult.isFailure) {
      return Result.failure(localDataResult.errorOrNull!);
    }

    final localData = localDataResult.dataOrNull;

    if (localData == null) {
      final input=UpdateMyWordStatusRepositoryInputData (
        remoteItem.wordId,
        remoteItem.isLearned?1:0,
        remoteItem.isBookmarked?1:0,
        null,// remoteItem.hasNote?1:0,
        remoteItem.editAt,
        null
      );
      final createResult = await _myWordStatusRepository.updateLocalStatus(input);
      if (createResult.isFailure) {
        return Result.failure(createResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    }

    final remoteUpdatedAt = remoteItem.editAt;
    final localUpdatedAt = localData.editAt;

    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      
      final input=UpdateMyWordStatusRepositoryInputData (
        remoteItem.wordId,
        remoteItem.isLearned?1:0,
        remoteItem.isBookmarked?1:0,
        null,// remoteItem.hasNote?1:0,
        remoteItem.editAt,
        null
      );
      final updateResult =
          await _myWordStatusRepository.updateLocalStatus(input);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    }

    return const Result.success(null);
  }

  Future<Result<void>> _uploadLocal2Remote(
    String userId,
    DateTime datetime,
    List<int> idsUpdatedByRemote,
  ) async {
    final localDataResult = await _myWordStatusRepository.getLocalStatusAfter(datetime);

    if (localDataResult.isFailure) {
      return Result.failure(localDataResult.errorOrNull!);
    }

    final localData = localDataResult.dataOrNull!;
    print("local myword status sync length: ${localData.length}");
    
    if (localData.isEmpty) {
      return const Result.success(null);
    }

    final filtered = localData
        .where((w) => !idsUpdatedByRemote.contains(w.wordId))
        .toList();

    if (filtered.isEmpty) {
      return const Result.success(null);
    }

    return _myWordStatusRepository.updateBatchRemoteStatus(userId, filtered);
  }

 
  
}
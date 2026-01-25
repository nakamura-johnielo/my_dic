
import 'package:my_dic/core/domain/i_repository/i_sync_status_repository.dart';
import 'package:my_dic/core/domain/usecase/i_sync_usecase.dart';
import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/core/shared/consts/syncPriority.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word_status.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/update_my_word_status/update_my_word_status_repository_input_data.dart';

class SyncMyWordStatusUsecase implements ISyncUseCase{
  @override
  int get priority => Syncpriority.baseStatus;
  
  final ISyncStatusRepository _localSyncStatusRepository;
  final IMyWordStatusRepository _myWordStatusRepository;
  final IAuthRepository _authRepository;

  SyncMyWordStatusUsecase(
    this._localSyncStatusRepository,
    this._myWordStatusRepository,
    this._authRepository,
  );

  Future<String?> _getCurrentAccountId() async {
    try {
      final authResult = await _authRepository.getCurrentAuth();
      return authResult.when(
        success: (auth) =>
            auth.isAuthenticated && auth.accountId.isNotEmpty ? auth.accountId : null,
        failure: (_) => null,
      );
    } catch (_) {
      return null;
    }
  }



  @override
  Future<Result<void>> syncOnce() async {
    final accountId = await _getCurrentAccountId();
    if (accountId == null) {
      return const Result.success(null);
    }
    final localLastSyncDate = await _getLastSyncDate();

    final remoteDataResult =
        await _myWordStatusRepository.getRemoteStatusAfter(accountId, localLastSyncDate);

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
        final idResult = await _syncHandleOnOnce(accountId, remoteItem);
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
      await _uploadLocal2Remote(accountId, localLastSyncDate, wordIdsUpdatedByRemote);
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
  Future<Result<void>> syncOnUpdatedLocal(String wordId) async {
    final accountId = await _getCurrentAccountId();
    if (accountId == null) {
      return const Result.success(null);
    }
    final remoteItemResult =
        await _myWordStatusRepository.getRemoteStatusById(accountId, int.parse(wordId));

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
          await _myWordStatusRepository.updateRemoteStatus(accountId, localData, null);

      if (updateResult.isFailure) {
        return updateResult;
      }

      return _updateLocalLastSyncDate();
    }

    final syncResult = await _syncHandle(accountId, remoteItem);
    if (syncResult.isFailure) {
      return Result.failure(syncResult.errorOrNull!);
    }

    return _updateLocalLastSyncDate();
  }

  @override
  Future<Result<void>> syncOnUpdatedRemote(String wordId) async {
    final accountId = await _getCurrentAccountId();
    if (accountId == null) {
      return const Result.success(null);
    }
    final remoteItemResult =
        await _myWordStatusRepository.getRemoteStatusById(accountId, int.parse(wordId));

    if (remoteItemResult.isFailure) {
      return Result.failure(remoteItemResult.errorOrNull!);
    }

    final remoteItem = remoteItemResult.dataOrNull;

    if (remoteItem == null) {
      return Result.failure(NotFoundError(
        message: 'リモートのMyWordが見つかりません',
      ));
    }

    final syncResult = await _syncHandleOnRemoteChanged(accountId, remoteItem);
    if (syncResult.isFailure) {
      return Result.failure(syncResult.errorOrNull!);
    }

    return _updateLocalLastSyncDate();
  }

 @override
  Stream<List<int>> watchRemoteChangedIds() {
    return Stream.fromFuture(_getCurrentAccountId()).asyncExpand((accountId) {
      if (accountId == null) {
        return Stream.value(const <int>[]);
      }
      return _myWordStatusRepository.watchRemoteChangedIds(accountId);
    });
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
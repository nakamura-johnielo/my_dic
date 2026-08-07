import 'package:my_dic/core/domain/entity/sync_checkpoint.dart';
import 'package:my_dic/core/domain/i_repository/i_sync_status_repository.dart';
import 'package:my_dic/core/domain/usecase/i_sync_usecase.dart';
import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/core/shared/consts/sync_priority.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word_status.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/update_my_word_status/update_my_word_status_repository_input_data.dart';
import 'package:my_dic/core/shared/utils/logger.dart';

class SyncMyWordStatusUsecase implements ISyncUseCase {
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

  Future<Result<String?>> _getCurrentAccountId() async {
    try {
      final authResult = await _authRepository.getCurrentAuth();
      return authResult.map(
        (auth) => auth.isAuthenticated && auth.accountId.isNotEmpty
            ? auth.accountId
            : null,
      );
    } catch (error, stackTrace) {
      return Result.failure(UnexpectedError(
        message: '認証状態の取得に失敗しました',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<void>> syncOnce() async {
    final accountIdResult = await _getCurrentAccountId();
    if (accountIdResult.isFailure) {
      return Result.failure(accountIdResult.errorOrNull!);
    }
    final accountId = accountIdResult.dataOrNull;
    if (accountId == null) {
      return const Result.success(null);
    }
    final checkpointCandidate = DateTime.now().toUtc();
    final lastSyncDateResult = await _getLastSyncDate(accountId);
    if (lastSyncDateResult.isFailure) {
      return Result.failure(lastSyncDateResult.errorOrNull!);
    }
    final localLastSyncDate = lastSyncDateResult.dataOrNull!;

    final remoteDataResult = await _myWordStatusRepository.getRemoteStatusAfter(
        accountId, localLastSyncDate);

    if (remoteDataResult.isFailure) {
      return Result.failure(remoteDataResult.errorOrNull!);
    }
    final remoteData = remoteDataResult.dataOrNull!;

    final List<String> wordIdsUpdatedByRemote = [];

    if (remoteData.isNotEmpty) {
      for (final remoteItem in remoteData) {
        final idResult = await _syncHandleOnOnce(accountId, remoteItem);
        if (idResult.isFailure) {
          return Result.failure(idResult.errorOrNull!);
        }
        final updatedId = idResult.dataOrNull;
        if (updatedId != null) {
          wordIdsUpdatedByRemote.add(updatedId);
        }
      }
    }

    final uploadResult = await _uploadLocal2Remote(
        accountId, localLastSyncDate, wordIdsUpdatedByRemote);
    if (uploadResult.isFailure) {
      return uploadResult;
    }

    final updateDateResult =
        await _commitCheckpoint(accountId, checkpointCandidate);
    if (updateDateResult.isFailure) {
      return updateDateResult;
    }

    return const Result.success(null);
  }

  @override
  Future<Result<void>> syncOnUpdatedLocal(String wordId) async {
    final accountIdResult = await _getCurrentAccountId();
    if (accountIdResult.isFailure) {
      return Result.failure(accountIdResult.errorOrNull!);
    }
    final accountId = accountIdResult.dataOrNull;
    if (accountId == null) {
      return const Result.success(null);
    }
    final remoteItemResult =
        await _myWordStatusRepository.getRemoteStatusById(accountId, wordId);

    if (remoteItemResult.isFailure) {
      return Result.failure(remoteItemResult.errorOrNull!);
    }

    final remoteItem = remoteItemResult.dataOrNull;

    if (remoteItem == null) {
      final localDataResult =
          await _myWordStatusRepository.getLocalStatusById(wordId);

      if (localDataResult.isFailure) {
        return Result.failure(localDataResult.errorOrNull!);
      }

      final localData = localDataResult.dataOrNull;
      if (localData == null) {
        return Result.failure(NotFoundError(
          message: 'ローカルのMyWordが見つかりません',
        ));
      }

      final updateResult = await _myWordStatusRepository.updateRemoteStatus(
          accountId, localData, null);

      if (updateResult.isFailure) {
        return updateResult;
      }

      return const Result.success(null);
    }

    final syncResult = await _syncHandle(accountId, remoteItem);
    if (syncResult.isFailure) {
      return Result.failure(syncResult.errorOrNull!);
    }

    return const Result.success(null);
  }

  @override
  Future<Result<void>> syncOnUpdatedRemote(String wordId) async {
    final accountIdResult = await _getCurrentAccountId();
    if (accountIdResult.isFailure) {
      return Result.failure(accountIdResult.errorOrNull!);
    }
    final accountId = accountIdResult.dataOrNull;
    if (accountId == null) {
      return const Result.success(null);
    }
    final remoteItemResult =
        await _myWordStatusRepository.getRemoteStatusById(accountId, wordId);

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

    return const Result.success(null);
  }

  @override
  Stream<List<String>> watchRemoteChangedIds() {
    return Stream.fromFuture(_getCurrentAccountId()).asyncExpand(
      (accountIdResult) => accountIdResult.when(
        success: (accountId) => accountId == null
            ? Stream.value(const <String>[])
            : _myWordStatusRepository.watchRemoteChangedIds(accountId),
        failure: Stream.error,
      ),
    );
  }

//========local method================================================

  Future<Result<void>> _commitCheckpoint(
    String accountId,
    DateTime lastSuccessfulAt,
  ) {
    return _localSyncStatusRepository.saveCheckpoint(
      SyncCheckpoint(
        key: SyncCheckpointKey(
          accountId: accountId,
          dataset: SyncDataset.myWordStatus,
        ),
        lastSuccessfulAt: lastSuccessfulAt,
      ),
    );
  }

  Future<Result<DateTime>> _getLastSyncDate(String accountId) async {
    final result = await _localSyncStatusRepository.getCheckpoint(
      SyncCheckpointKey(
        accountId: accountId,
        dataset: SyncDataset.myWordStatus,
      ),
    );

    return result.map(
      (checkpoint) => checkpoint?.lastSuccessfulAt ?? MyDateTime.sentinel,
    );
  }

  Future<Result<String?>> _syncHandle(
      String userId, MyWordStatus remoteItem) async {
    final localDataResult =
        await _myWordStatusRepository.getLocalStatusById(remoteItem.wordId);

    if (localDataResult.isFailure) {
      return Result.failure(localDataResult.errorOrNull!);
    }

    final localData = localDataResult.dataOrNull;

    if (localData == null) {
      final input = UpdateMyWordStatusRepositoryInputData(
          remoteItem.wordId,
          remoteItem.isLearned ? 1 : 0,
          remoteItem.isBookmarked ? 1 : 0,
          null, // remoteItem.hasNote?1:0,
          remoteItem.editAt,
          null);
      final createResult =
          await _myWordStatusRepository.updateLocalStatus(input);
      if (createResult.isFailure) {
        return Result.failure(createResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    }

    final remoteUpdatedAt = remoteItem.editAt;
    final localUpdatedAt = localData.editAt;

    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      final input = UpdateMyWordStatusRepositoryInputData(
          remoteItem.wordId,
          remoteItem.isLearned ? 1 : 0,
          remoteItem.isBookmarked ? 1 : 0,
          null, // remoteItem.hasNote?1:0,
          remoteItem.editAt,
          null);
      final updateResult =
          await _myWordStatusRepository.updateLocalStatus(input);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    }

    if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
      final updateResult = await _myWordStatusRepository.updateRemoteStatus(
          userId, localData, null);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.errorOrNull!);
      }
    }

    return const Result.success(null);
  }

  Future<Result<String?>> _syncHandleOnOnce(
      String userId, MyWordStatus remoteItem) async {
    final localDataResult =
        await _myWordStatusRepository.getLocalStatusById(remoteItem.wordId);

    if (localDataResult.isFailure) {
      return Result.failure(localDataResult.errorOrNull!);
    }

    final localData = localDataResult.dataOrNull;

    if (localData == null) {
      final input = UpdateMyWordStatusRepositoryInputData(
          remoteItem.wordId,
          remoteItem.isLearned ? 1 : 0,
          remoteItem.isBookmarked ? 1 : 0,
          null, // remoteItem.hasNote?1:0,
          remoteItem.editAt,
          null);
      final createResult =
          await _myWordStatusRepository.updateLocalStatus(input);
      if (createResult.isFailure) {
        return Result.failure(createResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    }

    final remoteUpdatedAt = remoteItem.editAt;
    final localUpdatedAt = localData.editAt;

    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      final input = UpdateMyWordStatusRepositoryInputData(
          remoteItem.wordId,
          remoteItem.isLearned ? 1 : 0,
          remoteItem.isBookmarked ? 1 : 0,
          null, // remoteItem.hasNote?1:0,
          remoteItem.editAt,
          null);
      final updateResult =
          await _myWordStatusRepository.updateLocalStatus(input);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    }

    if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
      final updateResult = await _myWordStatusRepository.updateRemoteStatus(
          userId, localData, null);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.errorOrNull!);
      }
    }

    return const Result.success(null);
  }

  Future<Result<String?>> _syncHandleOnRemoteChanged(
      String userId, MyWordStatus remoteItem) async {
    final localDataResult =
        await _myWordStatusRepository.getLocalStatusById(remoteItem.wordId);

    if (localDataResult.isFailure) {
      return Result.failure(localDataResult.errorOrNull!);
    }

    final localData = localDataResult.dataOrNull;

    if (localData == null) {
      final input = UpdateMyWordStatusRepositoryInputData(
          remoteItem.wordId,
          remoteItem.isLearned ? 1 : 0,
          remoteItem.isBookmarked ? 1 : 0,
          null, // remoteItem.hasNote?1:0,
          remoteItem.editAt,
          null);
      final createResult =
          await _myWordStatusRepository.updateLocalStatus(input);
      if (createResult.isFailure) {
        return Result.failure(createResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    }

    final remoteUpdatedAt = remoteItem.editAt;
    final localUpdatedAt = localData.editAt;

    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      final input = UpdateMyWordStatusRepositoryInputData(
          remoteItem.wordId,
          remoteItem.isLearned ? 1 : 0,
          remoteItem.isBookmarked ? 1 : 0,
          null, // remoteItem.hasNote?1:0,
          remoteItem.editAt,
          null);
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
    List<String> idsUpdatedByRemote,
  ) async {
    final localDataResult =
        await _myWordStatusRepository.getLocalStatusAfter(datetime);

    if (localDataResult.isFailure) {
      return Result.failure(localDataResult.errorOrNull!);
    }

    final localData = localDataResult.dataOrNull!;
    AppLogger.print("local myword status sync length: ${localData.length}");

    if (localData.isEmpty) {
      return const Result.success(null);
    }

    final filtered =
        localData.where((w) => !idsUpdatedByRemote.contains(w.wordId)).toList();

    if (filtered.isEmpty) {
      return const Result.success(null);
    }

    return _myWordStatusRepository.updateBatchRemoteStatus(userId, filtered);
  }
}

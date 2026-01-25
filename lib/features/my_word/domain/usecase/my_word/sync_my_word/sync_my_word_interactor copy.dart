import 'package:my_dic/core/domain/i_repository/i_sync_status_repository.dart';
import 'package:my_dic/core/domain/usecase/i_sync_usecase.dart';
import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/core/shared/consts/syncPriority.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/sync_my_word/i_sync_my_word_usecase.dart';

class SyncMyWordInteractor implements ISyncUseCase {
  final ISyncStatusRepository _localSyncStatusRepository;
  final IMyWordRepository _myWordRepository;
  final IAuthRepository _authRepository;

  @override
  int get priority => Syncpriority.base;

  SyncMyWordInteractor(
    this._localSyncStatusRepository,
    this._myWordRepository,
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

    final remoteDataResult = await _myWordRepository.getRemoteMyWordsAfter(
        accountId, localLastSyncDate);

    final remoteData = remoteDataResult.when(
      success: (data) => data,
      failure: (error) => error,
    );

    if (remoteData is AppError) {
      return Result.failure(remoteData);
    }

    final List<int> wordIdsUpdatedByRemote = [];

    if ((remoteData as List<MyWord>).isNotEmpty) {
      for (final remoteItem in remoteData) {
        final idResult = await _syncHandle(accountId, remoteItem);
        final updatedId = idResult.when(
          success: (data) => data,
          failure: (_) => null,
        );
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
        await _myWordRepository.getRemoteMyWordById(accountId, int.parse(wordId));

    if (remoteItemResult.isFailure) {
      return Result.failure(remoteItemResult.errorOrNull!);
    }

    final remoteItem = remoteItemResult.dataOrNull;

    if (remoteItem == null) {
      final localDataResult =
          await _myWordRepository.getLocalMyWordById(int.parse(wordId));

      if (localDataResult.isFailure) {
        return Result.failure(localDataResult.errorOrNull!);
      }

      final localData = localDataResult.dataOrNull;
      if (localData == null) {
        return Result.failure(UnexpectedError(
          message: 'ローカルのMyWordが見つかりません',
        ));
      }

      final updateResult =
          await _myWordRepository.updateRemoteMyWord(accountId, localData, null);

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
        await _myWordRepository.getRemoteMyWordById(accountId, int.parse(wordId));

    if (remoteItemResult.isFailure) {
      return Result.failure(remoteItemResult.errorOrNull!);
    }

    final remoteItem = remoteItemResult.dataOrNull;

    if (remoteItem == null) {
      return Result.failure(UnexpectedError(
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
      return _myWordRepository.watchRemoteChangedIds(accountId);
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

  Future<Result<int?>> _syncHandle(String userId, MyWord remoteItem) async {
    final localDataResult =
        await _myWordRepository.getLocalMyWordById(remoteItem.wordId);

    if (localDataResult.isFailure) {
      return Result.failure(localDataResult.errorOrNull!);
    }

    final localData = localDataResult.dataOrNull;

    if (localData == null) {
      final createResult =
          await _myWordRepository.createLocalMyWord(remoteItem);
      if (createResult.isFailure) {
        return Result.failure(createResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    }

    final remoteUpdatedAt = remoteItem.editAt;
    final localUpdatedAt = localData.editAt;

    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      final updateResult = await _myWordRepository.updateLocalMyWord(
          remoteItem, remoteItem.editAt);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    }

    if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
        final updateResult =
          await _myWordRepository.updateRemoteMyWord(userId, localData, null);
      if (updateResult.isFailure) {
        return Result.failure(updateResult.errorOrNull!);
      }
    }

    return const Result.success(null);
  }

  Future<Result<int?>> _syncHandleOnRemoteChanged(
      String userId, MyWord remoteItem) async {
    print("MyWord remote changed handle");
    final localDataResult =
        await _myWordRepository.getLocalMyWordById(remoteItem.wordId);

    if (localDataResult.isFailure) {
      return Result.failure(localDataResult.errorOrNull!);
    }

    final localData = localDataResult.dataOrNull;

    if (localData == null) {
      print("local null");
      final createResult =
          await _myWordRepository.createLocalMyWord(remoteItem);
      if (createResult.isFailure) {
        return Result.failure(createResult.errorOrNull!);
      }
      return Result.success(remoteItem.wordId);
    }

    final remoteUpdatedAt = remoteItem.editAt;
    final localUpdatedAt = localData.editAt;

    print("local exist ${localUpdatedAt.toIso8601String()}");
    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      final updateResult = await _myWordRepository.updateLocalMyWord(
          remoteItem, remoteItem.editAt);
      if (updateResult.isFailure) {
        print("Fil!!!!!!");
        return Result.failure(updateResult.errorOrNull!);
      }
      print(
          "MyWord remote changed sync local updated: ${remoteItem.wordId}, ${remoteItem.word}");
      return Result.success(remoteItem.wordId);
    }
    print("paassse");

    return const Result.success(null);
  }

  Future<Result<void>> _uploadLocal2Remote(
    String userId,
    DateTime datetime,
    List<int> idsUpdatedByRemote,
  ) async {
    final localDataResult =
        await _myWordRepository.getLocalMyWordsAfter(datetime);

    if (localDataResult.isFailure) {
      return Result.failure(localDataResult.errorOrNull!);
    }

    final localData = localDataResult.dataOrNull!;

    print("local myword sync length: ${localData.length}");

    if (localData.isEmpty) {
      return const Result.success(null);
    }

    final filtered =
        localData.where((w) => !idsUpdatedByRemote.contains(w.wordId)).toList();

    if (filtered.isEmpty) {
      return const Result.success(null);
    }

    return _myWordRepository.updateBatchRemoteMyWords(userId, filtered);
  }
}

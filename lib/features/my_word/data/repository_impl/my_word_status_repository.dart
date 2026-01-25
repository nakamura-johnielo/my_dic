import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word_status.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/update_my_word_status/update_my_word_status_repository_input_data.dart';
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_status_local_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/status/i_my_word_status_remote_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/status/firebase_my_word_status_dto.dart';

class MyWordStatusRepository implements IMyWordStatusRepository {
  final IMyWordStatusLocalDataSource _localDataSource;
  final IMyWordStatusRemoteDataSource _remoteDataSource;

  MyWordStatusRepository(this._localDataSource, this._remoteDataSource);

  @override
  Future<Result<void>> updateStatus(
      UpdateMyWordStatusRepositoryInputData input) async {
    try {
      log("updatestatusrepo");
      MyWordStatusTableData data = MyWordStatusTableData(
        myWordId: input.wordId,
        isLearned: input.status.contains(FeatureTag.isLearned) ? 1 : 0,
        isBookmarked: input.status.contains(FeatureTag.isBookmarked) ? 1 : 0,
        hasNote: input.status.contains(FeatureTag.hasNote) ? 1 : 0,
        editAt: input.editAt.toIso8601String(),
      );

      if (await _localDataSource.existStatus(input.wordId)) {
        await _localDataSource.updateStatus(data);
      } else {
        await _localDataSource.insertStatus(data);
      }
if(input.userId==null)return const Result.success(null);
      await _remoteDataSource.updateStatus(
          input.userId!, MyWordStatusDTO(myWordId: input.wordId, isLearned: input.status.contains(FeatureTag.isLearned)?1:0, isBookmarked: input.status.contains(FeatureTag.isBookmarked)?1:0, createdAt: input.editAt, updatedAt: input.editAt));
      return const Result.success(null);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語ステータスの更新に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Stream<MyWordStatus> watchStatus(int wordId) {
    return _localDataSource.watchWordStatus(wordId).map((statusData) {
      if (statusData == null) {
        return MyWordStatus(
          wordId: wordId,
          isLearned: false,
          isBookmarked: false,
        );
      }
      return MyWordStatus(
        wordId: statusData.myWordId,
        isLearned: statusData.isLearned == 1,
        isBookmarked: statusData.isBookmarked == 1,
      );
    });
  }

  // ============================================================================
  // Remote Methods
  // ============================================================================

  @override
  Future<Result<List<MyWordStatus>>> getRemoteStatusAfter(
      String userId, DateTime datetime) async {
    try {
      final dtoList = await _remoteDataSource.getStatusAfter(userId, datetime);
      final entities = dtoList.map((dto) => dto.toEntity()).toList();
      return Result.success(entities);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートのステータス取得に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートのステータス取得中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<MyWordStatus?>> getRemoteStatusById(
      String userId, int myWordId) async {
    try {
      final dto = await _remoteDataSource.getStatusById(userId, myWordId);
      return Result.success(dto?.toEntity());
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートのステータス取得に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートのステータス取得中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> updateRemoteStatus(
      String userId, MyWordStatus status, DateTime? now) async {
    try {
      final updatedStatus = status.copyWith(editAt: now ?? DateTime.now().toUtc());
      final dto = MyWordStatusDTO.fromAppEntity(updatedStatus);
      await _remoteDataSource.updateStatus(userId, dto);
      return const Result.success(null);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートのステータス更新に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートのステータス更新中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> updateBatchRemoteStatus(
      String userId, List<MyWordStatus> statusList) async {
    try {
      final dtoList = statusList.map((status) => MyWordStatusDTO.fromAppEntity(status)).toList();
      await _remoteDataSource.updateStatusBatch(userId, dtoList);
      return const Result.success(null);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートのステータス一括更新に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートのステータス一括更新中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  // ============================================================================
  // Local Methods for Sync
  // ============================================================================

  @override
  Future<Result<List<MyWordStatus>>> getLocalStatusAfter(DateTime datetime) async {
    try {
      // Need to add to data source - return empty for now
      return const Result.success([]);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'ローカルのステータス取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<MyWordStatus?>> getLocalStatusById(int myWordId) async {
    try {
      final statusData = await _localDataSource.watchWordStatus(myWordId).first;
      if (statusData == null) {
        return const Result.success(null);
      }
      return Result.success(MyWordStatus(
        wordId: statusData.myWordId,
        isLearned: statusData.isLearned == 1,
        isBookmarked: statusData.isBookmarked == 1,
        editAt: DateTime.parse(statusData.editAt),
      ));
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'ローカルのステータス取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> updateLocalStatus(MyWordStatus status, DateTime now) async {
    try {
      final data = MyWordStatusTableData(
        myWordId: status.wordId,
        isLearned: status.isLearned ? 1 : 0,
        isBookmarked: status.isBookmarked ? 1 : 0,
        hasNote: 0,
        editAt: now.toIso8601String(),
      );

      if (await _localDataSource.existStatus(status.wordId)) {
        await _localDataSource.updateStatus(data);
      } else {
        await _localDataSource.insertStatus(data);
      }
      return const Result.success(null);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'ローカルのステータス更新に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  // ============================================================================
  // Watch Streams
  // ============================================================================

  @override
  Stream<List<int>> watchRemoteChangedIds(String userId) {
    return _remoteDataSource.watchChangedIds(userId);
  }

  @override
  Stream<List<int>> watchLocalChangedIds(DateTime datetime) {
    // Need to implement in local data source
    return Stream.value([]);
  }
}

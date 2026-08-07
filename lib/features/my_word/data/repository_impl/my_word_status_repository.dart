import 'package:my_dic/core/shared/utils/logger.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word_status.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/domain/model/my_word_status/update_my_word_status_repository_input_data.dart';
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_status_local_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/status/i_my_word_status_remote_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/status/firebase_my_word_status_dto.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/port/outbox_writer.dart';

class MyWordStatusRepository implements IMyWordStatusRepository {
  final IMyWordStatusLocalDataSource _localDataSource;
  final IMyWordStatusRemoteDataSource _remoteDataSource;
  final OutboxWriter _outboxWriter;
  final Uuid _uuid;

  MyWordStatusRepository(
    this._localDataSource,
    this._remoteDataSource,
    this._outboxWriter, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  @override
  Future<Result<void>> updateStatus(
      UpdateMyWordStatusRepositoryInputData input) async {
    try {
      AppLogger.print("updatestatusrepo");
      final editAt = input.editAt.toIso8601String();
      final scope = input.userId ?? guestAccountScope;
      await _localDataSource.runInTransaction(() async {
        final row = await _localDataSource.applyStatusPatch(
          input.wordId,
          _toNullableInt(input.isLearned),
          _toNullableInt(input.isBookmarked),
          _toNullableInt(input.hasNote),
          editAt,
          scope,
        );
        if (input.userId != null) {
          final fieldMask = <String>[];
          final payload = <String, Object?>{};
          if (input.isLearned case SetValue(value: final value)) {
            fieldMask.add('isLearned');
            payload['isLearned'] = value;
          }
          if (input.isBookmarked case SetValue(value: final value)) {
            fieldMask.add('isBookmarked');
            payload['isBookmarked'] = value;
          }
          if (input.hasNote case SetValue(value: final value)) {
            fieldMask.add('hasNote');
            payload['hasNote'] = value;
          }
          if (fieldMask.isNotEmpty) {
            await _outboxWriter.enqueue(SyncMutation(
              mutationId: _uuid.v4(),
              accountId: input.userId!,
              dataset: SyncDataset.myWordStatus,
              entityId: input.wordId,
              operation: SyncMutationOperation.patch,
              payload: payload,
              fieldMask: fieldMask,
              localRevision: row.localRevision,
              clientUpdatedAt: input.editAt.toUtc(),
            ));
          }
        }
        return row;
      });
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
  Stream<MyWordStatus> watchStatus(String wordId, {required String accountId}) {
    return _localDataSource
        .watchWordStatus(wordId, accountId)
        .map((statusData) {
      AppLogger.print("mywordstatus stream");
      if (statusData == null) {
        AppLogger.print("null");
        return MyWordStatus(
          wordId: wordId,
          isLearned: false,
          isBookmarked: false,
        );
      }
      AppLogger.print(
          "mystatus ${statusData.myWordId}, learned:${statusData.isLearned}, bookmarked:${statusData.isBookmarked}");
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
      String userId, String myWordId) async {
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
      final updatedStatus =
          status.copyWith(editAt: now ?? DateTime.now().toUtc());
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
      final dtoList = statusList
          .map((status) => MyWordStatusDTO.fromAppEntity(status))
          .toList();
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
  Future<Result<List<MyWordStatus>>> getLocalStatusAfter(
      DateTime datetime) async {
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
  Future<Result<MyWordStatus?>> getLocalStatusById(String myWordId) async {
    try {
      // Legacy sync path predates real account scoping; preserves prior
      // behavior by keeping the same fixed scope it always used.
      final statusData = await _localDataSource
          .watchWordStatus(myWordId, guestAccountScope)
          .first;
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
  Future<Result<void>> updateLocalStatus(
      UpdateMyWordStatusRepositoryInputData input) async {
    try {
      MyWordStatusTableData data = MyWordStatusTableData(
        myWordId: input.wordId,
        isLearned: _toNullableInt(input.isLearned) ?? 0,
        isBookmarked: _toNullableInt(input.isBookmarked) ?? 0,
        hasNote: _toNullableInt(input.hasNote) ?? 0,
        editAt: input.editAt.toIso8601String(),
        accountId: 'legacy_unowned',
        localRevision: 0,
      );

      if (await _localDataSource.existStatus(input.wordId)) {
        await _localDataSource.updateStatus(
          input.wordId,
          _toNullableInt(input.isLearned),
          _toNullableInt(input.isBookmarked),
          _toNullableInt(input.hasNote),
          input.editAt.toIso8601String(),
        );
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

  int? _toNullableInt(FieldUpdate<bool> update) => switch (update) {
        SetValue(value: final value) => value ? 1 : 0,
        Unchanged() => null,
      };

  // ============================================================================
  // Watch Streams
  // ============================================================================

  @override
  Stream<List<String>> watchRemoteChangedIds(String userId) {
    return _remoteDataSource.watchChangedIds(userId);
  }

  @override
  Stream<List<String>> watchLocalChangedIds(DateTime datetime) {
    // Need to implement in local data source
    return Stream.value([]);
  }
}

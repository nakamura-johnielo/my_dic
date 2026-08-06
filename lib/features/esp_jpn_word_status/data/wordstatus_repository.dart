import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_remote_word_status_data_source.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/core/infrastructure/repositories/converters/word_status_converter.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/wordStatusEntity.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/port/outbox_writer.dart';

class WordStatusRepository implements IWordStatusRepository {
  final IRemoteWordStatusDataSource _remote;
  final ILocalWordStatusDataSource _local;
  final OutboxWriter _outboxWriter;
  final Uuid _uuid;
  WordStatusRepository(this._remote, this._local, this._outboxWriter,
      {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  @override
  Future<Result<WordStatus>> updateLocalWordStatus(
    UpdateStatusRepositoryInputData input,
    DateTime editAt, {
    required String? accountId,
  }) async {
    try {
      final updated = await _local.runInTransaction(() async {
        final row = await _local.updateWordStatus(
          input.wordId,
          _changedValue(input.isLearned),
          _changedValue(input.isBookmarked),
          _changedValue(input.hasNote),
          editAt.toIso8601String(),
        );
        if (accountId != null) {
          final fieldMask = <String>[];
          final payload = <String, Object?>{};
          _collectChange(fieldMask, payload, 'isLearned', input.isLearned);
          _collectChange(
              fieldMask, payload, 'isBookmarked', input.isBookmarked);
          _collectChange(fieldMask, payload, 'hasNote', input.hasNote);
          if (fieldMask.isNotEmpty) {
            await _outboxWriter.enqueue(SyncMutation(
              mutationId: _uuid.v4(),
              accountId: accountId,
              dataset: SyncDataset.espJpnWordStatus,
              entityId: input.wordId.toString(),
              operation: SyncMutationOperation.patch,
              payload: payload,
              fieldMask: fieldMask,
              localRevision: row.localRevision,
            ));
          }
        }
        return row;
      });

      AppLogger.print("Local update success");
      return Result.success(WordStatusConverter.toEntity(updated));
    } catch (e, s) {
      AppLogger.print("Local update failed: $e");
      return Result.failure(DatabaseError(
        message: 'ローカルの単語ステータス更新に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

//TODO mutable changeにする
  void _collectChange(List<String> fieldMask, Map<String, Object?> payload,
      String field, FieldUpdate<bool> update) {
    if (update is SetValue<bool>) {
      fieldMask.add(field);
      payload[field] = update.value;
    }
  }

  bool? _changedValue(FieldUpdate<bool> update) => switch (update) {
        Unchanged<bool>() => null,
        SetValue<bool>(:final value) => value,
      };

  @override
  Future<Result<void>> updateRemoteWordStatus(
    WordStatus wordStatus,
    String userId,
    DateTime? now,
  ) async {
    try {
      final remoteInput = wordStatus.copyWith(editAt: now);
      final dto = WordStatusDTO.fromAppEntity(remoteInput);
      await _remote.updateWordStatus(userId, dto);
      return const Result.success(null);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートの単語ステータス更新に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートの単語ステータス更新中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> deleteWordStatus(WordStatus wordStatus) async {
    // TODO: Implement when needed
    return const Result.success(null);
  }

  @override
  Future<Result<WordStatus?>> getWordStatusById(int id) async {
    try {
      final res = await _local.getWordStatusById(id);
      if (res != null) {
        return Result.success(WordStatusConverter.toEntity(res));
      }
      return Result.success(null);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語ステータスの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Stream<WordStatus> watchWordStatusById(int id) {
    return _local.watchWordStatusById(id).map((data) {
      if (data == null) throw Exception('Word status not found for id: $id');
      return WordStatusConverter.toEntity(data);
    });
  }

  @override
  Future<Result<List<WordStatus>>> getLocalWordStatusAfter(
    DateTime datetime,
  ) async {
    try {
      final dataList = await _local.getWordStatusAfter(datetime);
      final entities = WordStatusConverter.toEntityList(dataList);
      return Result.success(entities);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'ローカルの単語ステータス一覧取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<WordStatus?>> getLocalWordStatusById(int id) async {
    try {
      final data = await _local.getWordStatusById(id);
      if (data == null) {
        return Result.success(null);
      }
      return Result.success(WordStatusConverter.toEntity(data));
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'ローカルの単語ステータス取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<List<WordStatus>>> getRemoteWordStatusAfter(
    String userId,
    DateTime datetime,
  ) async {
    try {
      final dtoList = await _remote.getWordStatusAfter(userId, datetime);
      final entities = dtoList.map((dto) => dto.toEntity()).toList();
      return Result.success(entities);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートの単語ステータス一覧取得に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートの単語ステータス一覧取得中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<WordStatus?>> getRemoteWordStatusById(
    String userId,
    int id,
  ) async {
    try {
      final dto = await _remote.getWordStatusById(userId, id);
      if (dto == null) {
        return Result.success(null);
      }
      return Result.success(dto.toEntity());
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートの単語ステータス取得に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートの単語ステータス取得中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> updateBatchRemoteWordStatus(
    List<WordStatus> wordStatusList,
    String userId,
    DateTime? now,
  ) async {
    try {
      final dtoList = wordStatusList.map((w) {
        final updated = now != null ? w.copyWith(editAt: now) : w;
        return WordStatusDTO.fromAppEntity(updated);
      }).toList();

      await _remote.updateWordStatusBatch(userId, dtoList);
      return const Result.success(null);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートの単語ステータス一括更新に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートの単語ステータス一括更新中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Stream<List<int>> watchLocalChangedIds(DateTime datetime) {
    return _local.watchChangedIds(datetime);
  }

  @override
  Stream<List<int>> watchRemoteChangedIds(String userId) {
    return _remote.watchChangedIds(userId);
  }
}

import 'package:uuid/uuid.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/core/infrastructure/repositories/converters/word_status_converter.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/port/outbox_writer.dart';

class WordStatusRepository implements IWordStatusRepository {
  final ILocalWordStatusDataSource _local;
  final OutboxWriter _outboxWriter;
  final Uuid _uuid;
  WordStatusRepository(this._local, this._outboxWriter, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  @override
  Future<Result<WordStatus>> updateLocalWordStatus(
    UpdateStatusRepositoryInputData input,
    DateTime editAt, {
    required String? accountId,
  }) async {
    try {
      final scope = accountId ?? guestAccountScope;
      final updated = await _local.runInTransaction(() async {
        final row = await _local.updateWordStatus(
          input.wordId,
          _changedValue(input.isLearned),
          _changedValue(input.isBookmarked),
          _changedValue(input.hasNote),
          editAt.toIso8601String(),
          scope,
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
  Future<Result<void>> deleteWordStatus(WordStatus wordStatus) async {
    // TODO: Implement when needed
    return const Result.success(null);
  }

  @override
  Future<Result<WordStatus?>> getWordStatusById(int id,
      {required String accountId}) async {
    try {
      final res = await _local.getWordStatusById(id, accountId);
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
  Stream<WordStatus> watchWordStatusById(int id, {required String accountId}) {
    return _local.watchWordStatusById(id, accountId).map((data) {
      if (data == null) throw Exception('Word status not found for id: $id');
      return WordStatusConverter.toEntity(data);
    });
  }

  @override
  Future<Result<List<WordStatus>>> getLocalWordStatusAfter(
    DateTime datetime, {
    required String accountId,
  }) async {
    try {
      final dataList = await _local.getWordStatusAfter(datetime, accountId);
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
  Future<Result<WordStatus?>> getLocalWordStatusById(int id,
      {required String accountId}) async {
    try {
      final data = await _local.getWordStatusById(id, accountId);
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
  Stream<List<int>> watchLocalChangedIds(DateTime datetime,
      {required String accountId}) {
    return _local.watchChangedIds(datetime, accountId);
  }
}

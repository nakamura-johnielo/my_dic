import 'package:my_dic/core/shared/utils/result.dart';
import 'package:uuid/uuid.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_local_data_source.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/word_status_repository_adapter.dart';

final class JpnEspDictionaryWordStatusAdapter
    implements IDictionaryWordStatusAdapter {
  JpnEspDictionaryWordStatusAdapter(this._local, this._outboxWriter,
      {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final JpnEspWordStatusLocalDataSource _local;
  final IOutboxWriter _outboxWriter;
  final Uuid _uuid;

  @override
  CatalogId get catalogId => CatalogId.jpnEspMain;

  @override
  Future<Result<WordStatus?>> get(CatalogWordRef word,
      {required String accountId}) async {
    _checkCatalog(word);
    try {
      final row = await _local.getWordStatusById(word.wordId, accountId);
      return Result.success(row == null ? null : _map(word, row));
    } catch (error, stackTrace) {
      return Result.failure(_asAppError(error, stackTrace));
    }
  }

  @override
  Stream<WordStatus> watch(CatalogWordRef word, {required String accountId}) {
    _checkCatalog(word);
    return _local
        .watchWordStatusById(word.wordId, accountId)
        .map((row) => row == null ? _defaultFor(word) : _map(word, row));
  }

  @override
  Future<Result<WordStatus>> update(
    CatalogWordRef word, {
    required FieldUpdate<bool> isLearned,
    required FieldUpdate<bool> isBookmarked,
    required FieldUpdate<bool> hasNote,
    required DateTime updatedAt,
    required String? accountId,
  }) async {
    _checkCatalog(word);
    final utcUpdatedAt = updatedAt.toUtc();
    try {
      final row = await _local.runInTransaction(() async {
        final updated = await _local.updateWordStatus(
          word.wordId,
          _changedValue(isLearned),
          _changedValue(isBookmarked),
          _changedValue(hasNote),
          utcUpdatedAt.toIso8601String(),
          accountId ?? guestAccountScope,
        );
        if (accountId != null) {
          final fieldMask = <String>[];
          final payload = <String, Object?>{};
          _collectChange(fieldMask, payload, 'isLearned', isLearned);
          _collectChange(fieldMask, payload, 'isBookmarked', isBookmarked);
          _collectChange(fieldMask, payload, 'hasNote', hasNote);
          if (fieldMask.isNotEmpty) {
            await _outboxWriter.enqueue(SyncMutation(
              mutationId: _uuid.v4(),
              accountId: accountId,
              dataset: SyncDataset.jpnEspWordStatus,
              entityId: word.wordId.toString(),
              operation: SyncMutationOperation.patch,
              payload: payload,
              fieldMask: fieldMask,
              localRevision: updated.localRevision,
              clientUpdatedAt: utcUpdatedAt,
            ));
          }
        }
        return updated;
      });
      return Result.success(_map(word, row));
    } catch (error, stackTrace) {
      return Result.failure(_asAppError(error, stackTrace));
    }
  }

  void _checkCatalog(CatalogWordRef word) {
    assert(
        word.catalogId == catalogId, 'CatalogWordRef does not match adapter.');
    if (word.catalogId != catalogId) {
      throw ArgumentError.value(word.catalogId, 'word.catalogId',
          'JpnEspDictionaryWordStatusAdapter only handles $catalogId.');
    }
  }

  WordStatus _map(CatalogWordRef word, dynamic row) => WordStatus(
        word: word,
        isLearned: row.isLearned == 1,
        isBookmarked: row.isBookmarked == 1,
        hasNote: row.hasNote == 1,
        updatedAt: DateTime.parse(row.editAt).toUtc(),
      );

  WordStatus _defaultFor(CatalogWordRef word) => WordStatus(
        word: word,
        isLearned: false,
        isBookmarked: false,
        hasNote: false,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );

  bool? _changedValue(FieldUpdate<bool> update) => switch (update) {
        Unchanged<bool>() => null,
        SetValue<bool>(:final value) => value,
      };

  void _collectChange(List<String> fieldMask, Map<String, Object?> payload,
      String field, FieldUpdate<bool> update) {
    if (update case SetValue<bool>(:final value)) {
      fieldMask.add(field);
      payload[field] = value;
    }
  }

  AppError _asAppError(Object error, StackTrace stackTrace) => error is AppError
      ? error
      : DatabaseError(
          message: 'Failed to access Jpn-Esp word status.',
          originalError: error,
          stackTrace: stackTrace,
        );
}

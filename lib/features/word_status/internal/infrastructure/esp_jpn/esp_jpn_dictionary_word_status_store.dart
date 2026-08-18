import 'package:uuid/uuid.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_local_data_source.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/composite_word_status_repository.dart';
import 'package:my_dic/features/word_status/internal/domain/model/word_status_record.dart';

final class EspJpnDictionaryWordStatusStore
    implements DictionaryWordStatusStore {
  EspJpnDictionaryWordStatusStore(this._local, this._outboxWriter,
      {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final EspJpnWordStatusLocalDataSource _local;
  final OutboxWriter _outboxWriter;
  final Uuid _uuid;

  @override
  CatalogId get catalogId => CatalogId.espJpnMain;

  @override
  Future<Result<WordStatus?>> get(CatalogWordRef word,
      {required String accountId}) async {
    _checkCatalog(word);
    try {
      final row = await _local.getWordStatusRecordById(word.wordId, accountId);
      return Result.success(row == null ? null : _map(word, row));
    } catch (error, stackTrace) {
      return Result.failure(_asAppError(error, stackTrace));
    }
  }

  @override
  Future<Result<Map<CatalogWordRef, WordStatus>>> getBatch(
      Iterable<CatalogWordRef> words,
      {required String accountId}) async {
    final requested = {for (final word in words) word.wordId: word};
    for (final word in requested.values) {
      _checkCatalog(word);
    }
    try {
      final rows = await _local.getWordStatusRecordsByIds(
        requested.keys,
        accountId,
      );
      return Result.success(Map.unmodifiable({
        for (final row in rows)
          requested[row.wordId]!: _map(requested[row.wordId]!, row),
      }));
    } catch (error, stackTrace) {
      return Result.failure(_asAppError(error, stackTrace));
    }
  }

  @override
  Stream<WordStatus> watch(CatalogWordRef word, {required String accountId}) {
    _checkCatalog(word);
    return _local
        .watchWordStatusRecordById(word.wordId, accountId)
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
              dataset: SyncDataset.espJpnWordStatus,
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
      return Result.success(WordStatus(
        word: word,
        isLearned: row.isLearned == 1,
        isBookmarked: row.isBookmarked == 1,
        hasNote: row.hasNote == 1,
        updatedAt: DateTime.parse(row.editAt).toUtc(),
      ));
    } catch (error, stackTrace) {
      return Result.failure(_asAppError(error, stackTrace));
    }
  }

  void _checkCatalog(CatalogWordRef word) {
    assert(
        word.catalogId == catalogId, 'CatalogWordRef does not match adapter.');
    if (word.catalogId != catalogId) {
      throw ArgumentError.value(word.catalogId, 'word.catalogId',
          'EspJpnDictionaryWordStatusStore only handles $catalogId.');
    }
  }

  WordStatus _map(CatalogWordRef word, WordStatusRecord row) => WordStatus(
        word: word,
        isLearned: row.isLearned,
        isBookmarked: row.isBookmarked,
        hasNote: row.hasNote,
        updatedAt: row.updatedAt,
      );

  WordStatus _defaultFor(CatalogWordRef word) => WordStatus(
        word: word,
        isLearned: false,
        isBookmarked: false,
        hasNote: false,
        updatedAt: null,
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
          message: 'Failed to access Esp-Jpn word status.',
          originalError: error,
          stackTrace: stackTrace,
        );
}

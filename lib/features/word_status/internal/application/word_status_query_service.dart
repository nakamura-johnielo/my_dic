import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_status/internal/domain/word_status_repository.dart';
import 'package:my_dic/features/word_status/internal/domain/word_status_repository_error.dart';
import 'package:my_dic/features/word_status/port/error.dart';
import 'package:my_dic/features/word_status/port/model/word_status.dart';
import 'package:my_dic/features/word_status/port/model/word_status_scope.dart';
import 'package:my_dic/features/word_status/port/query.dart';
import 'package:my_dic/features/word_status/port/result.dart';

final class WordStatusQueryService
    implements
        WordStatusReaderPort,
        WordStatusWatchPort,
        WordStatusBatchReaderPort {
  WordStatusQueryService(this._repository);

  final WordStatusRepository _repository;

  @override
  Future<Result<WordStatus>> read(ReadWordStatusQuery query) async {
    final unsupported = _unsupported(query.word.catalogId);
    if (unsupported != null) return Result.failure(unsupported);
    try {
      final result = await _repository.get(
        query.word,
        accountId: _persistenceScope(query.scope),
      );
      return result.when(
        success: (data) =>
            Result.success(data ?? WordStatus.initial(query.word)),
        failure: (error) => Result.failure(_normalizeReadError(error)),
      );
    } catch (_) {
      return const Result.failure(WordStatusReadError.unexpected());
    }
  }

  @override
  Stream<Result<WordStatus>> watch(ReadWordStatusQuery query) async* {
    final unsupported = _unsupported(query.word.catalogId);
    if (unsupported != null) {
      yield Result.failure(unsupported);
      return;
    }
    try {
      await for (final status in _repository.watch(
        query.word,
        accountId: _persistenceScope(query.scope),
      )) {
        yield Result.success(status);
      }
    } on WordStatusRecordCorruptionError {
      yield const Result.failure(WordStatusReadError.corruptData());
    } on DatabaseError {
      yield const Result.failure(WordStatusReadError.storage());
    } catch (_) {
      yield const Result.failure(WordStatusReadError.unexpected());
    }
  }

  @override
  Future<Result<WordStatusBatch>> readBatch(
    ReadWordStatusBatchQuery query,
  ) async {
    if (query.words.isEmpty) {
      return Result.success(WordStatusBatch.empty());
    }
    for (final word in query.words) {
      final unsupported = _unsupported(word.catalogId);
      if (unsupported != null) return Result.failure(unsupported);
    }
    try {
      final result = await _repository.getBatch(
        query.words,
        accountId: _persistenceScope(query.scope),
      );
      return result.when(
        success: (data) => Result.success(
            WordStatusBatch(
              query.words.map(
                (word) => data[word] ?? WordStatus.initial(word),
              ),
            ),
          ),
        failure: (error) => Result.failure(_normalizeReadError(error)),
      );
    } catch (_) {
      return const Result.failure(WordStatusReadError.unexpected());
    }
  }

  WordStatusReadError? _unsupported(CatalogId catalogId) =>
      _repository.supportedCatalogs.contains(catalogId)
          ? null
          : WordStatusReadError.unsupportedCatalog(catalogId);
}

String _persistenceScope(WordStatusScope scope) => switch (scope) {
      GuestWordStatusScope() => guestAccountScope,
      AccountWordStatusScope(:final accountId) => accountId,
    };

WordStatusReadError _normalizeReadError(Object error) => switch (error) {
      WordStatusReadError() => error,
      WordStatusRecordCorruptionError() =>
        const WordStatusReadError.corruptData(),
      DatabaseError() => const WordStatusReadError.storage(),
      _ => const WordStatusReadError.unexpected(),
    };

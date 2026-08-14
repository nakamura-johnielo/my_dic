import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/word_status/internal/application/word_status_clock.dart'
    show SystemWordStatusClock;
import 'package:my_dic/features/word_status/internal/application/word_status_query_service.dart';
import 'package:my_dic/features/word_status/internal/domain/word_status_repository.dart';
import 'package:my_dic/features/word_status/internal/domain/word_status_repository_error.dart';
import 'package:my_dic/features/word_status/port/command.dart';
import 'package:my_dic/features/word_status/port/composition_contract.dart';
import 'package:my_dic/features/word_status/port/error.dart';
import 'package:my_dic/features/word_status/port/model/word_status.dart';
import 'package:my_dic/features/word_status/port/model/word_status_scope.dart';
import 'package:my_dic/features/word_status/port/query.dart';
import 'package:my_dic/features/word_status/port/result.dart';

/// The complete application-facing WordStatus capability.
final class WordStatusApplicationService
    implements
        WordStatusReaderPort,
        WordStatusWatchPort,
        WordStatusBatchReaderPort,
        WordStatusCommandPort {
  WordStatusApplicationService(
    this._repository, {
    WordStatusClock clock = const SystemWordStatusClock(),
  })  : _clock = clock,
        _queries = WordStatusQueryService(_repository);

  final WordStatusRepository _repository;
  final WordStatusClock _clock;
  final WordStatusQueryService _queries;

  @override
  Future<Result<WordStatus>> read(ReadWordStatusQuery query) =>
      _queries.read(query);

  @override
  Stream<Result<WordStatus>> watch(ReadWordStatusQuery query) =>
      _queries.watch(query);

  @override
  Future<Result<WordStatusBatch>> readBatch(ReadWordStatusBatchQuery query) =>
      _queries.readBatch(query);

  @override
  Future<Result<void>> update(UpdateWordStatusCommand command) async {
    // Existing callers rely on an unchanged command being a successful no-op,
    // including before repository dispatch and clock evaluation.
    if (!command.hasChanges) return const Result.success(null);
    if (!_repository.supportedCatalogs.contains(command.word.catalogId)) {
      return Result.failure(
        WordStatusWriteError.unsupportedCatalog(command.word.catalogId),
      );
    }
    try {
      final result = await _repository.update(
        command.word,
        isLearned: command.isLearned,
        isBookmarked: command.isBookmarked,
        hasNote: command.hasNote,
        updatedAt: _clock.now().toUtc(),
        accountId: _writeAccountId(command.scope),
      );
      return result.when(
        success: (_) => const Result.success(null),
        failure: (error) => Result.failure(_normalizeWriteError(error)),
      );
    } catch (_) {
      return const Result.failure(WordStatusWriteError.unexpected());
    }
  }
}

String? _writeAccountId(WordStatusScope scope) => switch (scope) {
      GuestWordStatusScope() => null,
      AccountWordStatusScope(:final accountId) => accountId,
    };

WordStatusWriteError _normalizeWriteError(Object error) => switch (error) {
      WordStatusWriteError() => error,
      WordStatusRecordCorruptionError() =>
        const WordStatusWriteError.corruptData(),
      DatabaseError() => const WordStatusWriteError.storage(),
      _ => const WordStatusWriteError.unexpected(),
    };

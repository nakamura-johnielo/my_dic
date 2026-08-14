import 'package:my_dic/features/ranking/port/ranking.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

/// Pure contract adapter from WordStatus batch reads to Ranking.
final class WordStatusBackedRankingGateway
    implements RankingWordStatusGateway {
  const WordStatusBackedRankingGateway(this._wordStatus);

  final WordStatusBatchReaderPort _wordStatus;

  @override
  Future<Result<RankingWordStatusBatch>> readBatch(
    RankingWordStatusBatchQuery query,
  ) async {
    try {
      final result = await _wordStatus.readBatch(
        ReadWordStatusBatchQuery(
          scope: _scope(query.scope),
          words: query.words,
        ),
      );
      if (result case Success<WordStatusBatch>(data: final batch)) {
        return Result.success(
          RankingWordStatusBatch(batch.statuses.map(_fact)),
        );
      }
      final error = result.errorOrNull!;
      return Result.failure(_error(error));
    } catch (error, stackTrace) {
      return Result.failure(
        RankingWordStatusGatewayError(
          kind: RankingWordStatusGatewayFailureKind.unexpected,
          message: 'Word status data could not be read for Ranking.',
          originalError: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

WordStatusScope _scope(RankingAccountScope scope) => switch (scope) {
      GuestRankingAccountScope() => const WordStatusScope.guest(),
      AccountRankingScope(:final accountId) =>
        WordStatusScope.account(accountId),
    };

RankingWordStatusFact _fact(WordStatus status) => RankingWordStatusFact(
      word: status.word,
      isLearned: status.isLearned,
      isBookmarked: status.isBookmarked,
      hasNote: status.hasNote,
    );

RankingWordStatusGatewayError _error(Object error) {
  final kind = switch (error) {
    WordStatusReadError(
      kind: WordStatusReadFailureKind.unsupportedCatalog,
    ) =>
      RankingWordStatusGatewayFailureKind.unsupportedCatalog,
    WordStatusReadError(kind: WordStatusReadFailureKind.corruptData) =>
      RankingWordStatusGatewayFailureKind.invalidData,
    WordStatusReadError(kind: WordStatusReadFailureKind.storage) =>
      RankingWordStatusGatewayFailureKind.unavailable,
    _ => RankingWordStatusGatewayFailureKind.unexpected,
  };
  return RankingWordStatusGatewayError(
    kind: kind,
    message: error is WordStatusReadError
        ? error.message
        : 'Word status data could not be read for Ranking.',
    originalError: error,
    stackTrace: error is WordStatusReadError ? error.stackTrace : null,
  );
}

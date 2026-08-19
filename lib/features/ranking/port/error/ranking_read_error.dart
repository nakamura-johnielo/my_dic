import 'package:my_dic/core/shared/errors/app_error.dart';

enum RankingReadFailureKind {
  catalogUnavailable,
  wordStatusUnavailable,
  invalidSourceItem,
  unexpected,
}

/// 唯一のページリーダーが返す、Ranking 所有の失敗。
final class RankingReadError extends AppError {
  const RankingReadError._({
    required this.kind,
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });

  const RankingReadError.catalogUnavailable({
    Object? originalError,
    StackTrace? stackTrace,
  }) : this._(
          kind: RankingReadFailureKind.catalogUnavailable,
          message: 'Ranking source data is unavailable.',
          code: 'RANKING_CATALOG_UNAVAILABLE',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  const RankingReadError.wordStatusUnavailable({
    Object? originalError,
    StackTrace? stackTrace,
  }) : this._(
          kind: RankingReadFailureKind.wordStatusUnavailable,
          message: 'Ranking status data is unavailable.',
          code: 'RANKING_WORD_STATUS_UNAVAILABLE',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  const RankingReadError.invalidSourceItem({
    Object? originalError,
    StackTrace? stackTrace,
  }) : this._(
          kind: RankingReadFailureKind.invalidSourceItem,
          message: 'Ranking source data is invalid.',
          code: 'RANKING_INVALID_SOURCE_ITEM',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  const RankingReadError.unexpected({
    Object? originalError,
    StackTrace? stackTrace,
  }) : this._(
          kind: RankingReadFailureKind.unexpected,
          message: 'Ranking data could not be read.',
          code: 'RANKING_UNEXPECTED_READ',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  final RankingReadFailureKind kind;
}

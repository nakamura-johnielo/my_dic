import 'package:my_dic/core/shared/errors/app_error.dart';

/// Search の警告を生じさせた、個別に回復可能な操作です。
enum SearchIssueSource { meaning, frequency, ranking, conjugation }

/// 致命的ではない拡張処理の失敗を表す、Search 所有の基底型です。
sealed class SearchIssueError extends AppError {
  const SearchIssueError({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

final class SearchEnrichmentUnavailableError extends SearchIssueError {
  const SearchEnrichmentUnavailableError({
    String message = 'Search enrichment is unavailable',
    super.originalError,
    super.stackTrace,
  }) : super(message: message, code: 'SEARCH_ENRICHMENT_UNAVAILABLE');
}

final class SearchIssue {
  const SearchIssue({required this.source, required this.error});

  final SearchIssueSource source;
  final SearchIssueError error;
}

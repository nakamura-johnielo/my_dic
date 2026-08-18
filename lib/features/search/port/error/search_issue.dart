import 'package:my_dic/core/shared/errors/app_error.dart';

/// The independently recoverable operation that produced a Search warning.
enum SearchIssueSource { meaning, frequency, ranking, conjugation }

/// Search-owned base type for non-fatal enrichment failures.
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

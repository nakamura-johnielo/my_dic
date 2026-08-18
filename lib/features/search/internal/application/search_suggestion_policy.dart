/// Compatibility limits for conjugation suggestions.
abstract final class SearchSuggestionPolicy {
  /// Search fetches four candidates so presentation can select stable results.
  static const int fetchLimit = 4;

  /// Existing Search presentation displays at most two candidates.
  static const int displayLimit = 2;
}

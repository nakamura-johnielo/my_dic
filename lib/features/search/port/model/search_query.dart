import 'search_direction.dart';

/// Input for a paged dictionary search.
final class SearchQuery {
  const SearchQuery({
    required this.text,
    required this.direction,
    required this.page,
    required this.size,
    required this.includeConjugationSuggestions,
  })  : assert(page >= 0),
        assert(size > 0);

  final String text;
  final SearchDirection direction;
  final int page;
  final int size;
  final bool includeConjugationSuggestions;
}

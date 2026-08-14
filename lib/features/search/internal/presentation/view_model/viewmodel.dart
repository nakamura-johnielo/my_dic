import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/features/search/internal/application/search_direction_policy.dart';
import 'package:my_dic/features/search/internal/presentation/ui_model/search_ui_model.dart';
import 'package:my_dic/features/search/port/search.dart';

/// Owns result-set identity, request attempts, and the page to retry.
///
/// [InfinityScrollController] deliberately only drives pagination.  It never
/// owns a query, an error, or a failed page identity.
class SearchViewModel extends StateNotifier<SearchState> {
  SearchViewModel(this._search) : super(const SearchState());

  final SearchQueryPort _search;
  int _generation = 0;
  final _attempts = <_SearchPageIdentity, int>{};
  final _inFlight = <_SearchPageIdentity, Future<bool>>{};
  final _activeTokens = <_SearchPageIdentity, _SearchRequestToken>{};
  _SearchPageIdentity? _failedPage;

  void updateQuery(String query) {
    final value = query.trim();
    _generation++;
    _failedPage = null;
    state = SearchState(
      query: value,
      // A new result set must not render the previous query while loading.
      results: value.isEmpty
          ? const QueryState.initial()
          : const QueryState.loading(),
    );
  }

  void clearResults() {
    _generation++;
    _failedPage = null;
    state =
        SearchState(query: state.query, results: const QueryState.initial());
  }

  Future<bool> loadSearchResults(int size, int page) {
    final query = state.query;
    if (query.isEmpty) return Future.value(false);
    final direction = _directionFor(query);
    final failed = _failedPage;
    final identity = failed != null &&
            failed.generation == _generation &&
            failed.query == query &&
            failed.size == size
        ? failed
        : _SearchPageIdentity(
            generation: _generation,
            query: query,
            direction: direction,
            page: page,
            size: size,
          );
    final pending = _inFlight[identity];
    if (pending != null) return pending;
    // One active request per result-set generation. A query change intentionally
    // starts a new generation, so its page 0 is not blocked by a stale request.
    if (_activeTokens.values.any((token) => token.generation == _generation)) {
      return Future.value(false);
    }

    final request = _load(identity);
    _inFlight[identity] = request;
    return request;
  }

  /// Retries exactly the most recently failed page, if it still belongs to
  /// the current result set. This is intentionally VM-owned business state.
  Future<bool> retryFailed() {
    final failed = _failedPage;
    if (failed == null ||
        failed.generation != _generation ||
        failed.query != state.query) {
      return Future.value(false);
    }
    return loadSearchResults(failed.size, failed.page);
  }

  Future<bool> _load(_SearchPageIdentity identity) async {
    final token = _SearchRequestToken(
      generation: identity.generation,
      page: identity,
      attempt: (_attempts[identity] ?? 0) + 1,
    );
    _attempts[identity] = token.attempt;
    _activeTokens[identity] = token;
    final previous = state.results.dataOrNull;
    state = state.copyWith(results: QueryState.loading(previousData: previous));

    try {
      final result = await _search.search(SearchQuery(
        text: identity.query,
        direction: identity.direction,
        page: identity.page,
        size: identity.size,
      ));
      if (!_isCurrent(token)) return false;
      if (result case Success<SearchResultPage>(data: final output)) {
        _failedPage = null;
        final next = SearchResults(
          direction: output.direction,
          items: output.items,
          conjugationSuggestions: output.conjugationSuggestions,
          hasNext: output.hasNext,
        );
        // Capture the current value after await. This retains a completed
        // page when another valid page completed while this request waited.
        final current = state.results.dataOrNull;
        _publish(
          next,
          current,
          identity.page > 0,
          warnings: output.issues
              .map(
                (issue) => QueryWarning(
                  source: issue.source.name,
                  error: issue.error,
                ),
              )
              .toList(growable: false),
        );
        return output.hasNext;
      }
      _failedPage = identity;
      _fail(result.errorOrNull!, state.results.dataOrNull);
      return false;
    } finally {
      if (_activeTokens[identity] == token) _activeTokens.remove(identity);
      // The map entry is still this request unless a later attempt replaced it.
      _inFlight.remove(identity);
    }
  }

  bool _isCurrent(_SearchRequestToken token) =>
      mounted &&
      token.generation == _generation &&
      token.page.query == state.query &&
      _activeTokens[token.page] == token;

  SearchDirection _directionFor(String query) =>
      SearchDirectionPolicy.fromText(query);

  void _fail(AppError error, SearchResults? previous) {
    if (mounted) {
      state = state.copyWith(
        results: QueryState.failure(error, previousData: previous),
      );
    }
  }

  void _publish(SearchResults next, SearchResults? previous, bool append,
      {List<QueryWarning> warnings = const []}) {
    final value = previous?.merge(next, append: append) ?? next;
    state = state.copyWith(
      results: value.isEmpty
          ? QueryState.empty(warnings: warnings)
          : QueryState.data(value, warnings: warnings),
    );
  }
}

class _SearchPageIdentity {
  const _SearchPageIdentity({
    required this.generation,
    required this.query,
    required this.direction,
    required this.page,
    required this.size,
  });

  final int generation;
  final String query;
  final SearchDirection direction;
  final int page;
  final int size;

  @override
  bool operator ==(Object other) =>
      other is _SearchPageIdentity &&
      generation == other.generation &&
      query == other.query &&
      direction == other.direction &&
      page == other.page &&
      size == other.size;

  @override
  int get hashCode => Object.hash(generation, query, direction, page, size);
}

class _SearchRequestToken {
  const _SearchRequestToken({
    required this.generation,
    required this.page,
    required this.attempt,
  });

  final int generation;
  final _SearchPageIdentity page;
  final int attempt;

  @override
  bool operator ==(Object other) =>
      other is _SearchRequestToken &&
      generation == other.generation &&
      page == other.page &&
      attempt == other.attempt;

  @override
  int get hashCode => Object.hash(generation, page, attempt);
}

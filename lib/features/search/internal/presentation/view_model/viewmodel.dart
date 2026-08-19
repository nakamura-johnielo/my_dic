import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/features/search/internal/application/search_direction_policy.dart';
import 'package:my_dic/features/search/internal/presentation/ui_model/search_ui_model.dart';
import 'package:my_dic/features/search/port/search.dart';

/// 結果セットの識別子、リクエスト試行、および再試行するページを保持します。
///
/// [InfinityScrollController] は意図的にページネーションのみを制御します。
/// クエリ、エラー、失敗したページの識別子は保持しません。
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
      // 新しい結果セットでは、読み込み中に前のクエリを表示してはなりません。
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
    // 結果セット世代ごとに有効なリクエストは 1 件です。クエリ変更では意図的に
    // 新しい世代を開始するため、その 0 ページ目は古いリクエストに妨げられません。
    if (_activeTokens.values.any((token) => token.generation == _generation)) {
      return Future.value(false);
    }

    final request = _load(identity);
    _inFlight[identity] = request;
    return request;
  }

  /// 現在の結果セットに属している場合のみ、直近で失敗したページを再試行します。
  /// これは意図的に VM が所有するビジネス状態です。
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
        // await 後に現在値を取得します。これにより、このリクエストの待機中に
        // 別の有効なページが完了した場合も、完了済みページを保持できます。
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
      // 後続の試行で置き換えられていない限り、マップの項目はこのリクエストのままです。
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/internal/presentation/search/ui_model/quiz_search_models.dart';
import 'package:my_dic/features/quiz/port/query/quiz_candidate_query.dart';
import 'package:my_dic/features/quiz/port/query/quiz_candidate_reader_port.dart';

class QuizSearchViewModel extends StateNotifier<QuizSearchState> {
  QuizSearchViewModel(this._source) : super(const QuizSearchState());
  final QuizCandidateQueryPort _source;

  int _resultSetGeneration = 0;
  RequestToken? _activeToken;
  PageIdentity? _failedPage;
  final Map<PageIdentity, int> _attempts = {};

  void updateQuery(String query) {
    final value = query.trim();
    if (value == state.query) return;

    _resultSetGeneration++;
    _activeToken = null;
    _failedPage = null;
    _attempts.clear();
    state = QuizSearchState(
      query: value,
      // A query is a new result set: do not retain old-query candidates while
      // the explicitly triggered page zero request is in flight.
      results: value.isEmpty
          ? const QueryState.initial()
          : const QueryState.loading(),
    );
  }

  Future<bool> loadSearchResults(int size, int page) async {
    final query = state.query;
    if (query.isEmpty || _activeToken != null) return false;

    final identity = PageIdentity(query: query, page: page, size: size);
    final token = RequestToken(
      generation: _resultSetGeneration,
      pageIdentity: identity,
      attempt: (_attempts[identity] ?? 0) + 1,
    );
    _attempts[identity] = token.attempt;
    _activeToken = token;
    final previous = state.results.dataOrNull;
    state = state.copyWith(results: QueryState.loading(previousData: previous));
    final result = await _source.search(
      QuizCandidateQuery(text: query, page: page, size: size),
    );
    if (!_isActive(token)) return false;
    _activeToken = null;
    return result.when(success: (output) {
      final next =
          QuizSearchResults(items: output.candidates, hasNext: output.hasNext);
      final value = previous?.merge(next, append: page > 0) ?? next;
      final warnings = output.issues
          .map((w) => QueryWarning(source: w.source.name, error: w.error))
          .toList();
      state = state.copyWith(
          results: value.isEmpty
              ? QueryState.empty(warnings: warnings)
              : QueryState.data(value, warnings: warnings));
      _failedPage = null;
      return output.hasNext;
    }, failure: (error) {
      state = state.copyWith(
          results: QueryState.failure(error, previousData: previous));
      _failedPage = identity;
      return false;
    });
  }

  /// Retries exactly the failed logical page.  The shared scroll controller
  /// never owns this identity or its attempt number.
  Future<bool> retryFailed() {
    final failed = _failedPage;
    if (failed == null || failed.query != state.query)
      return Future.value(false);
    return loadSearchResults(failed.size, failed.page);
  }

  bool _isActive(RequestToken token) =>
      mounted &&
      token == _activeToken &&
      token.generation == _resultSetGeneration &&
      token.pageIdentity.query == state.query;
}

/// The VM-owned business identity of one requestable candidate page.
final class PageIdentity {
  const PageIdentity(
      {required this.query, required this.page, required this.size});

  final String query;
  final int page;
  final int size;

  @override
  bool operator ==(Object other) =>
      other is PageIdentity &&
      other.query == query &&
      other.page == page &&
      other.size == size;

  @override
  int get hashCode => Object.hash(query, page, size);
}

/// Guards publication of an asynchronous response for a logical page attempt.
final class RequestToken {
  const RequestToken({
    required this.generation,
    required this.pageIdentity,
    required this.attempt,
  });

  final int generation;
  final PageIdentity pageIdentity;
  final int attempt;

  @override
  bool operator ==(Object other) =>
      other is RequestToken &&
      other.generation == generation &&
      other.pageIdentity == pageIdentity &&
      other.attempt == attempt;

  @override
  int get hashCode => Object.hash(generation, pageIdentity, attempt);
}

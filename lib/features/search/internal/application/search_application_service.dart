import 'package:my_dic/features/search/port/search.dart';

import 'search_suggestion_policy.dart';

/// Search's application-level reader over its consumer-owned Catalog gateway.
final class SearchApplicationService implements SearchQueryPort {
  SearchApplicationService(this._gateway);

  final SearchCatalogGateway _gateway;

  @override
  Future<Result<SearchResultPage>> search(SearchQuery query) async {
    try {
      final primaryResult = await _gateway.searchPrimary(
        SearchCatalogQuery(
          text: query.text,
          direction: query.direction,
          page: query.page,
          size: query.size,
        ),
      );
      if (primaryResult case Failure(error: final error)) {
        if (error is SearchCatalogGatewayError) {
          return Result<SearchResultPage>.failure(
            SearchDataUnavailableError(
              message: error.message,
              originalError: error,
              stackTrace: error.stackTrace,
            ),
          );
        }
        return Result<SearchResultPage>.failure(
          SearchUnexpectedReadError(
            message: error.message,
            originalError: error,
            stackTrace: error.stackTrace,
          ),
        );
      }

      final primary = primaryResult.dataOrNull!;
      final issues = <SearchIssue>[];
      final items = await _enrichPrimary(
        primary.items,
        query.direction,
        issues,
      );
      final suggestions = await _loadSuggestions(query, issues);
      return Result.success(
        SearchResultPage(
          direction: query.direction,
          items: items,
          conjugationSuggestions: suggestions,
          hasNext: primary.hasMore,
          issues: issues,
        ),
      );
    } catch (error, stackTrace) {
      return Result<SearchResultPage>.failure(
        SearchUnexpectedReadError(
          originalError: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<List<SearchResultItem>> _enrichPrimary(
    List<SearchPrimaryHit> hits,
    SearchDirection direction,
    List<SearchIssue> issues,
  ) async {
    if (hits.isEmpty) return const [];
    final words = hits.map((hit) => hit.word).toList(growable: false);

    final meaningsFuture = _attempt(() => _gateway.readMeanings(words));
    if (direction == SearchDirection.jpnEsp) {
      final meaningsAttempt = await meaningsFuture;
      _recordIssue(issues, SearchIssueSource.meaning, meaningsAttempt);
      final meanings = meaningsAttempt.valueOr(const {});
      return hits
          .map(
            (hit) => SearchResultItem(
              word: hit.word,
              headword: hit.headword,
              hasConjugation: hit.hasConjugation,
              meaningText: meanings[hit.word]?.text,
            ),
          )
          .toList(growable: false);
    }

    // Launch independent reads together, then record failures in the existing
    // meaning -> ranking -> frequency order regardless of completion timing.
    final rankingsFuture = _attempt(() => _gateway.readRankings(words));
    final frequenciesFuture = _attempt(() => _gateway.readFrequencies(words));
    final meaningsAttempt = await meaningsFuture;
    final rankingsAttempt = await rankingsFuture;
    final frequenciesAttempt = await frequenciesFuture;
    _recordIssue(issues, SearchIssueSource.meaning, meaningsAttempt);
    _recordIssue(issues, SearchIssueSource.ranking, rankingsAttempt);
    _recordIssue(issues, SearchIssueSource.frequency, frequenciesAttempt);

    final meanings = meaningsAttempt.valueOr(const {});
    final rankings = rankingsAttempt.valueOr(const {});
    final frequencies = frequenciesAttempt.valueOr(const {});
    return hits
        .map(
          (hit) => SearchResultItem(
            word: hit.word,
            headword: hit.headword,
            hasConjugation: hit.hasConjugation,
            meaningText: meanings[hit.word]?.text,
            rankingNo: rankings[hit.word]?.rankingNo,
            starCount: frequencies[hit.word]?.value,
          ),
        )
        .toList(growable: false);
  }

  Future<List<SearchConjugationSuggestion>> _loadSuggestions(
    SearchQuery query,
    List<SearchIssue> issues,
  ) async {
    if (query.direction != SearchDirection.espJpn || query.page != 0) {
      return const [];
    }

    final pageAttempt = await _attempt(
      () => _gateway.searchConjugations(
        SearchCatalogQuery(
          text: query.text,
          direction: SearchDirection.espJpn,
          page: 0,
          size: SearchSuggestionPolicy.fetchLimit,
        ),
      ),
    );
    _recordIssue(issues, SearchIssueSource.conjugation, pageAttempt);
    final page = pageAttempt.valueOr(
      SearchCatalogPage<SearchConjugationHit>(
        items: const [],
        hasMore: false,
      ),
    );
    if (page.items.isEmpty) return const [];

    final words = page.items.map((hit) => hit.word).toList(growable: false);
    final meaningsFuture = _attempt(() => _gateway.readMeanings(words));
    final rankingsFuture = _attempt(() => _gateway.readRankings(words));
    final frequenciesFuture = _attempt(() => _gateway.readFrequencies(words));
    final meaningsAttempt = await meaningsFuture;
    final rankingsAttempt = await rankingsFuture;
    final frequenciesAttempt = await frequenciesFuture;
    _recordIssue(issues, SearchIssueSource.meaning, meaningsAttempt);
    _recordIssue(issues, SearchIssueSource.ranking, rankingsAttempt);
    _recordIssue(issues, SearchIssueSource.frequency, frequenciesAttempt);

    final meanings = meaningsAttempt.valueOr(const {});
    final rankings = rankingsAttempt.valueOr(const {});
    final frequencies = frequenciesAttempt.valueOr(const {});
    return page.items
        .map(
          (hit) => SearchConjugationSuggestion(
            word: hit.word,
            headword: hit.headword,
            matches: hit.matches,
            meaningText: meanings[hit.word]?.text,
            rankingNo: rankings[hit.word]?.rankingNo,
            starCount: frequencies[hit.word]?.value,
          ),
        )
        .toList(growable: false);
  }

  Future<_EnrichmentAttempt<T>> _attempt<T>(
    Future<Result<T>> Function() operation,
  ) async {
    try {
      final result = await operation();
      if (result case Success<T>(data: final value)) {
        return _EnrichmentAttempt<T>.success(value);
      }
      final error = result.errorOrNull!;
      return _EnrichmentAttempt<T>.failure(
        SearchEnrichmentUnavailableError(
          message: error.message,
          originalError: error,
          stackTrace: error.stackTrace,
        ),
      );
    } catch (error, stackTrace) {
      return _EnrichmentAttempt<T>.failure(
        SearchEnrichmentUnavailableError(
          originalError: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  void _recordIssue<T>(
    List<SearchIssue> issues,
    SearchIssueSource source,
    _EnrichmentAttempt<T> attempt,
  ) {
    final error = attempt.error;
    if (error != null) {
      issues.add(SearchIssue(source: source, error: error));
    }
  }
}

final class _EnrichmentAttempt<T> {
  const _EnrichmentAttempt.success(this.value) : error = null;
  const _EnrichmentAttempt.failure(this.error) : value = null;

  final T? value;
  final SearchIssueError? error;

  T valueOr(T fallback) => value ?? fallback;
}

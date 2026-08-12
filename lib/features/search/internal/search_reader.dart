import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/search/port/catalog_gateway.dart';
import 'package:my_dic/features/search/port/model/conjugation_search_item.dart';
import 'package:my_dic/features/search/port/model/search_direction.dart';
import 'package:my_dic/features/search/port/model/search_query.dart';
import 'package:my_dic/features/search/port/model/search_result_item.dart';
import 'package:my_dic/features/search/port/model/search_result_page.dart';
import 'package:my_dic/features/search/port/reader.dart';

/// Search policy for paging, suggestion eligibility, and partial failures.
final class InternalSearchReaderPort implements SearchReaderPort {
  InternalSearchReaderPort(this._gateway);

  final SearchCatalogGateway _gateway;

  @override
  Future<Result<SearchResultPage>> search(SearchQuery query) async {
    if (query.text.trim().isEmpty) {
      return Result.failure(
        ValidationError(message: 'A search word is required.'),
      );
    }

    final primaryResult = await _gateway.searchPrimary(
      SearchCatalogQuery(
        text: query.text,
        direction: query.direction,
        page: query.page,
        size: query.size,
      ),
    );
    if (primaryResult case Failure(error: final error)) {
      return Result.failure(error);
    }
    final primary = primaryResult.dataOrNull!;
    final issues = <SearchIssue>[];
    final items = await _enrichPrimary(primary.items, query.direction, issues);
    final suggestions = await _suggestions(query, issues);
    return Result.success(
      SearchResultPage(
        items: items,
        conjugationSuggestions: suggestions,
        hasNext: primary.hasMore,
        issues: issues,
      ),
    );
  }

  Future<List<SearchResultItem>> _enrichPrimary(
    List<SearchPrimaryHit> hits,
    SearchDirection direction,
    List<SearchIssue> issues,
  ) async {
    if (hits.isEmpty) return const [];
    final words = hits.map((hit) => hit.word).toList(growable: false);
    final meaning = _capture(
      'meaning',
      () => _gateway.readMeanings(words),
      issues,
      <CatalogWordRef, SearchMeaningMetadata>{},
    );
    final ranking = direction == SearchDirection.espJpn
        ? _capture(
            'ranking',
            () => _gateway.readRankingMetadata(words),
            issues,
            <CatalogWordRef, SearchRankingMetadata>{},
          )
        : Future.value(<CatalogWordRef, SearchRankingMetadata>{});
    final headword = direction == SearchDirection.espJpn
        ? _capture(
            'starCount',
            () => _gateway.readHeadwordMetadata(words),
            issues,
            <CatalogWordRef, SearchHeadwordMetadata>{},
          )
        : Future.value(<CatalogWordRef, SearchHeadwordMetadata>{});
    final meanings = await meaning;
    final rankings = await ranking;
    final headwords = await headword;
    return hits
        .map(
          (hit) => SearchResultItem(
            wordId: hit.word.wordId,
            word: hit.word,
            headword: hit.headword,
            direction: direction,
            hasConjugation: hit.hasConjugation,
            meaningText: meanings[hit.word]?.text,
            rankingNo: rankings[hit.word]?.rankingNo,
            starCount: headwords[hit.word]?.frequency,
          ),
        )
        .toList(growable: false);
  }

  Future<List<ConjugationSearchItem>> _suggestions(
    SearchQuery query,
    List<SearchIssue> issues,
  ) async {
    if (query.direction != SearchDirection.espJpn ||
        !query.includeConjugationSuggestions ||
        query.page != 0) {
      return const [];
    }
    final page = await _capture(
      'conjugation',
      () => _gateway.searchConjugations(
        SearchCatalogQuery(
          text: query.text,
          direction: SearchDirection.espJpn,
          page: 0,
          size: 4,
        ),
      ),
      issues,
      SearchCatalogPage<SearchConjugationHit>(
        items: const [],
        hasMore: false,
      ),
    );
    if (page.items.isEmpty) return const [];
    final words = page.items.map((hit) => hit.word).toList(growable: false);
    final meaning = _capture(
      'meaning',
      () => _gateway.readMeanings(words),
      issues,
      <CatalogWordRef, SearchMeaningMetadata>{},
    );
    final ranking = _capture(
      'ranking',
      () => _gateway.readRankingMetadata(words),
      issues,
      <CatalogWordRef, SearchRankingMetadata>{},
    );
    final headword = _capture(
      'starCount',
      () => _gateway.readHeadwordMetadata(words),
      issues,
      <CatalogWordRef, SearchHeadwordMetadata>{},
    );
    final meanings = await meaning;
    final rankings = await ranking;
    final headwords = await headword;
    return page.items
        .map(
          (hit) => ConjugationSearchItem(
            wordId: hit.word.wordId,
            word: hit.word,
            headword: hit.headword,
            matches: hit.matches,
            meaningText: meanings[hit.word]?.text,
            rankingNo: rankings[hit.word]?.rankingNo,
            starCount: headwords[hit.word]?.frequency,
          ),
        )
        .toList(growable: false);
  }

  Future<T> _capture<T>(
    String source,
    Future<Result<T>> Function() operation,
    List<SearchIssue> issues,
    T fallback,
  ) async {
    final result = await operation();
    return result.when(
      success: (value) => value,
      failure: (error) {
        issues.add(SearchIssue(source: source, error: error));
        return fallback;
      },
    );
  }
}

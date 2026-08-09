import 'package:my_dic/core/application/query/query_issue.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/conjugation/conjugation_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/search_query_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/search_query_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/search_ranking_lookup.dart';
import 'package:my_dic/features/search/application/query/conjugation_search_item.dart';
import 'package:my_dic/features/search/application/query/i_search_query_repository.dart';
import 'package:my_dic/features/search/application/query/search_direction.dart';
import 'package:my_dic/features/search/application/query/search_query.dart';
import 'package:my_dic/features/search/application/query/search_result_item.dart';
import 'package:my_dic/features/search/application/query/search_result_page.dart';

/// Catalog's provider-side implementation of Search's query repository port.
class DriftSearchQueryRepository implements ISearchQueryRepository {
  DriftSearchQueryRepository(
    this._dao,
    this._espJpnDictionary,
    this._jpnEspDictionary,
    this._conjugations,
    this._rankingLookup,
  );

  final SearchQueryDao _dao;
  final IEsjDictionaryLocalDataSource _espJpnDictionary;
  final IJpnEspDictionaryLocalDataSource _jpnEspDictionary;
  final IConjugacionLocalDataSource _conjugations;
  final SearchRankingLookup _rankingLookup;

  @override
  Future<Result<SearchResultPage>> search(SearchQuery query) async {
    try {
      final primary = await _dao.fetchPrimary(query);
      final ids = primary.map((item) => item.wordId).toList(growable: false);
      final issues = <QueryIssue>[];
      final enrichment = await _loadEnrichment(query.direction, ids, issues);
      final suggestions = await _loadSuggestions(query, issues);
      final items = primary
          .map(
            (item) => SearchResultItem(
              wordId: item.wordId,
              headword: item.headword,
              direction: item.direction,
              hasConjugation: item.hasConjugation,
              meaningText: enrichment.meanings[item.wordId],
              rankingNo: enrichment.rankings[item.wordId],
              starCount: enrichment.stars[item.wordId],
            ),
          )
          .toList(growable: false);
      return Result.success(SearchResultPage(
        items: items,
        conjugationSuggestions: suggestions,
        hasNext: items.length == query.size,
        issues: issues,
      ));
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'Unable to search dictionary entries.',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }

  Future<_SearchEnrichment> _loadEnrichment(
    SearchDirection direction,
    List<int> wordIds,
    List<QueryIssue> issues,
  ) async {
    if (wordIds.isEmpty) return const _SearchEnrichment();
    final ranking = _capture(
      'ranking',
      () => direction == SearchDirection.espJpn
          ? _rankingLookup.getRankingNosByWordIds(wordIds)
          : Future.value(<int, int>{}),
      issues,
    );
    final meaning = _capture(
      'meaning',
      () => _loadMeanings(direction, wordIds),
      issues,
    );
    final stars = _capture(
      'starCount',
      () => direction == SearchDirection.espJpn
          ? _loadStars(wordIds)
          : Future.value(<int, int>{}),
      issues,
    );
    final results = await Future.wait([ranking, meaning, stars]);
    return _SearchEnrichment(
      rankings: results[0] as Map<int, int>,
      meanings: results[1] as Map<int, String>,
      stars: results[2] as Map<int, int>,
    );
  }

  Future<List<ConjugationSearchItem>> _loadSuggestions(
    SearchQuery query,
    List<QueryIssue> issues,
  ) async {
    final suggestions = await _capture(
      'conjugation',
      () => _dao.fetchConjugationSuggestions(query),
      issues,
    );
    if (suggestions.isEmpty) return suggestions;
    final ids = suggestions.map((item) => item.wordId).toList(growable: false);
    final enrichment =
        await _loadEnrichment(SearchDirection.espJpn, ids, issues);
    return suggestions
        .map(
          (item) => ConjugationSearchItem(
            wordId: item.wordId,
            headword: item.headword,
            matches: item.matches,
            meaningText: enrichment.meanings[item.wordId],
            rankingNo: enrichment.rankings[item.wordId],
            starCount: enrichment.stars[item.wordId],
          ),
        )
        .toList(growable: false);
  }

  Future<Map<int, String>> _loadMeanings(
    SearchDirection direction,
    List<int> wordIds,
  ) async {
    if (direction == SearchDirection.jpnEsp) {
      final html = await _jpnEspDictionary.getContentsByWordIds(wordIds);
      return _plainMeanings(html);
    }
    final conjugation = await _conjugations.getMeaningsByWordIds(wordIds);
    final dictionary =
        await _espJpnDictionary.getFirstContentsByWordIds(wordIds);
    final result = Map<int, String>.from(conjugation);
    dictionary.forEach((wordId, html) {
      result.putIfAbsent(wordId, () => extractMeaningText(html));
    });
    result.removeWhere((_, meaning) => meaning.isEmpty);
    return result;
  }

  Future<Map<int, int>> _loadStars(List<int> wordIds) async {
    final headwords =
        await _espJpnDictionary.getFirstHeadwordsByWordIds(wordIds);
    return headwords.map(
      (wordId, headword) => MapEntry(wordId, starCountFromHeadword(headword)),
    );
  }

  Future<T> _capture<T>(
    String source,
    Future<T> Function() action,
    List<QueryIssue> issues,
  ) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      issues.add(
        QueryIssue(source: source, error: _asAppError(error, stackTrace)),
      );
      return _emptyValue<T>();
    }
  }
}

Map<int, String> _plainMeanings(Map<int, String> html) => html.map(
      (wordId, value) => MapEntry(wordId, extractMeaningText(value)),
    )..removeWhere((_, meaning) => meaning.isEmpty);

AppError _asAppError(Object error, StackTrace stackTrace) => error is AppError
    ? error
    : DatabaseError(
        message: 'Unable to load search enrichment.',
        originalError: error,
        stackTrace: stackTrace,
      );

T _emptyValue<T>() {
  if (T == Map<int, int>) return <int, int>{} as T;
  if (T == Map<int, String>) return <int, String>{} as T;
  if (T == List<ConjugationSearchItem>) return <ConjugationSearchItem>[] as T;
  throw StateError('No empty value registered for $T.');
}

class _SearchEnrichment {
  const _SearchEnrichment({
    this.rankings = const {},
    this.meanings = const {},
    this.stars = const {},
  });

  final Map<int, int> rankings;
  final Map<int, String> meanings;
  final Map<int, int> stars;
}

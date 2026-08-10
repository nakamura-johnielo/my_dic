import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/search/port/catalog_gateway.dart';
import 'package:my_dic/features/search/port/model/conjugation_search_item.dart';
import 'package:my_dic/features/search/port/model/search_conjugation_match_key.dart';
import 'package:my_dic/features/search/port/model/search_direction.dart';
import 'package:my_dic/features/search/port/model/search_query.dart';
import 'package:my_dic/features/search/port/model/search_result_page.dart';
import 'package:my_dic/features/search/port/model/search_result_item.dart';
import 'package:my_dic/features/search/port/reader.dart';

/// Search policy: paging, suggestion eligibility and enrichment failure policy.
final class InternalSearchReaderPort implements SearchReaderPort {
  InternalSearchReaderPort(this._gateway);
  final SearchCatalogGateway _gateway;

  @override
  Future<Result<SearchResultPage>> search(SearchQuery query) async {
    if (query.text.trim().isEmpty) {
      return Result.failure(ValidationError(message: 'A search word is required.'));
    }
    final rawQuery = SearchRawQuery(text: query.text, page: query.page, size: query.size, espJpn: query.direction == SearchDirection.espJpn);
    try {
      final primary = await _gateway.searchPrimary(rawQuery);
      final issues = <SearchIssue>[];
      final items = await _enrichPrimary(primary, query.direction, issues);
      final suggestions = await _suggestions(query, rawQuery, issues);
      return Result.success(SearchResultPage(
        items: items,
        conjugationSuggestions: suggestions,
        hasNext: primary.length == query.size,
        issues: issues,
      ));
    } catch (error, stackTrace) {
      return Result.failure(_error('Unable to search dictionary entries.', error, stackTrace));
    }
  }

  Future<List<SearchResultItem>> _enrichPrimary(List<SearchPrimaryRawHit> hits, SearchDirection direction, List<SearchIssue> issues) async {
    if (hits.isEmpty) return const [];
    final words = hits.map((hit) => hit.word).toList(growable: false);
    final meaning = _capture<Map<CatalogWordRef, String>>('meaning', () => _gateway.getMeanings(words), issues);
    final ranking = _capture<Map<CatalogWordRef, int>>('ranking', () => direction == SearchDirection.espJpn ? _gateway.getRankingMetadata(words) : Future.value(<CatalogWordRef, int>{}), issues);
    final headword = _capture<Map<CatalogWordRef, String>>('starCount', () => direction == SearchDirection.espJpn ? _gateway.getHeadwords(words) : Future.value(<CatalogWordRef, String>{}), issues);
    final meanings = await meaning;
    final rankings = await ranking;
    final headwords = await headword;
    return hits.map((hit) => SearchResultItem(wordId: hit.word.wordId, word: hit.word, headword: hit.headword, direction: direction, hasConjugation: hit.hasConjugation, meaningText: meanings[hit.word], rankingNo: rankings[hit.word], starCount: headwords[hit.word] == null ? null : _stars(headwords[hit.word] as String))).toList(growable: false);
  }

  Future<List<ConjugationSearchItem>> _suggestions(SearchQuery query, SearchRawQuery rawQuery, List<SearchIssue> issues) async {
    if (query.direction != SearchDirection.espJpn || !query.includeConjugationSuggestions || query.page != 0) return const [];
    final hits = await _capture('conjugation', () => _gateway.searchConjugations(rawQuery), issues);
    if (hits.isEmpty) return const [];
    final words = hits.map((hit) => hit.word).toList(growable: false);
    final meaning = _capture<Map<CatalogWordRef, String>>('meaning', () => _gateway.getMeanings(words), issues);
    final ranking = _capture<Map<CatalogWordRef, int>>('ranking', () => _gateway.getRankingMetadata(words), issues);
    final headword = _capture<Map<CatalogWordRef, String>>('starCount', () => _gateway.getHeadwords(words), issues);
    final meanings = await meaning;
    final rankings = await ranking;
    final headwords = await headword;
    return hits.map((hit) => ConjugationSearchItem(wordId: hit.word.wordId, word: hit.word, headword: hit.headword, matches: {for (final entry in hit.matches.entries) if (SearchConjugationMatchKey.tryFromWireValue(entry.key) case final key?) key: entry.value}, meaningText: meanings[hit.word], rankingNo: rankings[hit.word], starCount: headwords[hit.word] == null ? null : _stars(headwords[hit.word] as String))).toList(growable: false);
  }

  Future<T> _capture<T>(String source, Future<T> Function() operation, List<SearchIssue> issues) async {
    try { return await operation(); } catch (error, stackTrace) {
      issues.add(SearchIssue(source: source, error: _error('Unable to load search enrichment.', error, stackTrace)));
      return _empty<T>();
    }
  }
}

AppError _error(String message, Object error, StackTrace stackTrace) => error is AppError ? error : DatabaseError(message: message, originalError: error, stackTrace: stackTrace);
int _stars(String headword) => RegExp(r'<sup>\((\*+)\)</sup>').firstMatch(headword)?.group(1)?.length ?? 0;
T _empty<T>() {
  if (T == List<SearchConjugationRawHit>) return <SearchConjugationRawHit>[] as T;
  if (T == Map<CatalogWordRef, String>) return <CatalogWordRef, String>{} as T;
  if (T == Map<CatalogWordRef, int>) return <CatalogWordRef, int>{} as T;
  throw StateError('No empty Search fallback for $T.');
}

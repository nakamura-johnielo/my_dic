import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/search/internal/search_reader.dart';
import 'package:my_dic/features/search/port/catalog_gateway.dart';
import 'package:my_dic/features/search/port/model/search_conjugation_match_key.dart';
import 'package:my_dic/features/search/port/model/search_direction.dart';
import 'package:my_dic/features/search/port/model/search_query.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);
  const query = SearchQuery(
    text: 'hab',
    direction: SearchDirection.espJpn,
    page: 0,
    size: 20,
    includeConjugationSuggestions: true,
  );

  test('uses Catalog paging, typed matches, plain meaning, and frequency',
      () async {
    final gateway = _Gateway(
      primary: SearchCatalogPage(
        items: const [
          SearchPrimaryHit(
            word: word,
            headword: 'hablar',
            hasConjugation: true,
          ),
        ],
        hasMore: true,
      ),
      suggestions: SearchCatalogPage(
        items: [
          SearchConjugationHit(
            word: word,
            headword: 'hablar',
            matches: const {
              SearchConjugationMatchKey.indicativePresentYo: 'hablo',
            },
          ),
        ],
        hasMore: false,
      ),
    );

    final result = await InternalSearchReaderPort(gateway).search(query);

    final page = result.dataOrNull!;
    expect(page.hasNext, isTrue);
    expect(page.items.single.meaningText, 'speak');
    expect(page.items.single.starCount, 2);
    expect(
      page.conjugationSuggestions.single.matches,
      const {SearchConjugationMatchKey.indicativePresentYo: 'hablo'},
    );
    expect(gateway.suggestionQueries.single.size, 4);
  });

  test('only primary failure fails the whole search', () async {
    final failure = DatabaseError(message: 'primary');
    final result = await InternalSearchReaderPort(
      _Gateway(primaryError: failure),
    ).search(query);
    expect(result.errorOrNull, same(failure));
  });

  test('enrichment and suggestion failures become issues and fallbacks',
      () async {
    final gateway = _Gateway(
      primary: SearchCatalogPage(
        items: const [
          SearchPrimaryHit(
            word: word,
            headword: 'hablar',
            hasConjugation: true,
          ),
        ],
        hasMore: false,
      ),
      failEnrichment: true,
      suggestionError: DatabaseError(message: 'suggestions'),
    );
    final result = await InternalSearchReaderPort(gateway).search(query);
    final page = result.dataOrNull!;
    expect(page.items.single.meaningText, isNull);
    expect(page.items.single.rankingNo, isNull);
    expect(page.items.single.starCount, isNull);
    expect(page.conjugationSuggestions, isEmpty);
    expect(
      page.issues.map((issue) => issue.source),
      containsAll(['meaning', 'ranking', 'starCount', 'conjugation']),
    );
  });

  test('does not call Spanish-only readers for Japanese search', () async {
    final gateway = _Gateway(
      primary: SearchCatalogPage(
        items: const [
          SearchPrimaryHit(
            word: CatalogWordRef(
              catalogId: CatalogId.jpnEspMain,
              wordId: 3,
            ),
            headword: '話す',
            hasConjugation: false,
          ),
        ],
        hasMore: false,
      ),
    );
    await InternalSearchReaderPort(gateway).search(
      const SearchQuery(
        text: '話す',
        direction: SearchDirection.jpnEsp,
        page: 0,
        size: 20,
        includeConjugationSuggestions: true,
      ),
    );
    expect(gateway.suggestionQueries, isEmpty);
    expect(gateway.rankingCalls, 0);
    expect(gateway.headwordCalls, 0);
  });
}

final class _Gateway implements SearchCatalogGateway {
  _Gateway({
    SearchCatalogPage<SearchPrimaryHit>? primary,
    SearchCatalogPage<SearchConjugationHit>? suggestions,
    this.primaryError,
    this.suggestionError,
    this.failEnrichment = false,
  })  : primary = primary ??
            SearchCatalogPage<SearchPrimaryHit>(
              items: const [],
              hasMore: false,
            ),
        suggestions = suggestions ??
            SearchCatalogPage<SearchConjugationHit>(
              items: const [],
              hasMore: false,
            );

  final SearchCatalogPage<SearchPrimaryHit> primary;
  final SearchCatalogPage<SearchConjugationHit> suggestions;
  final DatabaseError? primaryError;
  final DatabaseError? suggestionError;
  final bool failEnrichment;
  final suggestionQueries = <SearchCatalogQuery>[];
  int rankingCalls = 0;
  int headwordCalls = 0;

  @override
  Future<Result<SearchCatalogPage<SearchPrimaryHit>>> searchPrimary(
    SearchCatalogQuery query,
  ) async =>
      primaryError == null
          ? Result.success(primary)
          : Result.failure(primaryError!);

  @override
  Future<Result<SearchCatalogPage<SearchConjugationHit>>> searchConjugations(
    SearchCatalogQuery query,
  ) async {
    suggestionQueries.add(query);
    return suggestionError == null
        ? Result.success(suggestions)
        : Result.failure(suggestionError!);
  }

  @override
  Future<Result<Map<CatalogWordRef, SearchMeaningMetadata>>> readMeanings(
    Iterable<CatalogWordRef> words,
  ) async =>
      _enrichment(
        {for (final word in words) word: const SearchMeaningMetadata('speak')},
      );

  @override
  Future<Result<Map<CatalogWordRef, SearchHeadwordMetadata>>>
      readHeadwordMetadata(Iterable<CatalogWordRef> words) async {
    headwordCalls++;
    return _enrichment({
      for (final word in words)
        word: const SearchHeadwordMetadata(headword: 'hablar', frequency: 2),
    });
  }

  @override
  Future<Result<Map<CatalogWordRef, SearchRankingMetadata>>>
      readRankingMetadata(Iterable<CatalogWordRef> words) async {
    rankingCalls++;
    return _enrichment({
      for (final word in words) word: const SearchRankingMetadata(1),
    });
  }

  Result<T> _enrichment<T>(T value) => failEnrichment
      ? Result.failure(DatabaseError(message: 'enrichment'))
      : Result.success(value);
}

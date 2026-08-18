import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/search/internal/application/search_application_service.dart';
import 'package:my_dic/features/search/internal/application/search_direction_policy.dart';
import 'package:my_dic/features/search/internal/application/search_suggestion_policy.dart';
import 'package:my_dic/features/search/port/search.dart';

void main() {
  const primaryWord = CatalogWordRef(
    catalogId: CatalogId.espJpnMain,
    wordId: 7,
  );

  group('Search direction characterization', () {
    test('uses the existing Latin and Spanish-character boundary', () {
      expect(SearchDirectionPolicy.fromText('abc'), SearchDirection.espJpn);
      expect(SearchDirectionPolicy.fromText('ABC'), SearchDirection.espJpn);
      expect(SearchDirectionPolicy.fromText('áéíóúñü'), SearchDirection.espJpn);
      expect(SearchDirectionPolicy.fromText('話aす'), SearchDirection.espJpn);
      expect(SearchDirectionPolicy.fromText('話す'), SearchDirection.jpnEsp);
      expect(SearchDirectionPolicy.fromText('１２３!?'), SearchDirection.jpnEsp);
    });
  });

  group('Search application characterization', () {
    test('preserves Catalog hasMore instead of inferring it from item count',
        () async {
      final exactSizeGateway = _Gateway(
        primary: _primaryPage(wordIds: const [1, 2], hasMore: false),
      );
      final exactSize = await SearchApplicationService(exactSizeGateway).search(
        SearchQuery(
          text: 'hablar',
          direction: SearchDirection.espJpn,
          page: 1,
          size: 2,
        ),
      );

      expect(exactSize.dataOrNull!.items, hasLength(2));
      expect(exactSize.dataOrNull!.hasNext, isFalse);

      final lookAheadGateway = _Gateway(
        primary: _primaryPage(wordIds: const [1], hasMore: true),
      );
      final lookAhead = await SearchApplicationService(lookAheadGateway).search(
        SearchQuery(
          text: 'hablar',
          direction: SearchDirection.espJpn,
          page: 1,
          size: 2,
        ),
      );

      expect(lookAhead.dataOrNull!.items, hasLength(1));
      expect(lookAhead.dataOrNull!.hasNext, isTrue);
    });

    test('orders warnings by the existing operation sequence', () async {
      final gateway = _Gateway(
        primary: SearchCatalogPage(
          items: const [
            SearchPrimaryHit(
              word: primaryWord,
              headword: 'hablar',
              hasConjugation: true,
            ),
          ],
          hasMore: false,
        ),
        failedEnrichments: const {
          SearchIssueSource.meaning,
          SearchIssueSource.ranking,
          SearchIssueSource.frequency,
        },
        failConjugationSearch: true,
      );

      final result = await SearchApplicationService(gateway).search(
        SearchQuery(
          text: 'hablar',
          direction: SearchDirection.espJpn,
          page: 0,
          size: 20,
        ),
      );

      final page = result.dataOrNull!;
      expect(page.items, hasLength(1));
      expect(
        page.issues.map((issue) => issue.source).toList(),
        const [
          SearchIssueSource.meaning,
          SearchIssueSource.ranking,
          SearchIssueSource.frequency,
          SearchIssueSource.conjugation,
        ],
      );
      expect(
        page.issues.every(
          (issue) => issue.error is SearchEnrichmentUnavailableError,
        ),
        isTrue,
      );
    });

    test('treats missing optional batch keys as null without a warning',
        () async {
      final gateway = _Gateway(
        primary: SearchCatalogPage(
          items: const [
            SearchPrimaryHit(
              word: primaryWord,
              headword: 'hablar',
              hasConjugation: true,
            ),
          ],
          hasMore: false,
        ),
        omitMetadata: true,
      );

      final result = await SearchApplicationService(gateway).search(
        SearchQuery(
          text: 'hablar',
          direction: SearchDirection.espJpn,
          page: 1,
          size: 20,
        ),
      );

      final page = result.dataOrNull!;
      expect(page.items.single.meaningText, isNull);
      expect(page.items.single.rankingNo, isNull);
      expect(page.items.single.starCount, isNull);
      expect(page.issues, isEmpty);
      expect(gateway.conjugationQueries, isEmpty);
    });

    test('keeps suggestion fetch four and presentation display two', () async {
      final gateway = _Gateway(
        primary: SearchCatalogPage<SearchPrimaryHit>(
          items: const [],
          hasMore: false,
        ),
        conjugations: SearchCatalogPage(
          items: [
            for (var id = 10; id < 14; id++)
              SearchConjugationHit(
                word: CatalogWordRef(
                  catalogId: CatalogId.espJpnMain,
                  wordId: id,
                ),
                headword: 'verb$id',
                matches: const {
                  SearchConjugationMatchKey.indicativePresentYo: 'form',
                },
              ),
          ],
          hasMore: false,
        ),
      );

      final result = await SearchApplicationService(gateway).search(
        SearchQuery(
          text: 'hab',
          direction: SearchDirection.espJpn,
          page: 0,
          size: 20,
        ),
      );

      expect(gateway.conjugationQueries.single.size,
          SearchSuggestionPolicy.fetchLimit);
      expect(SearchSuggestionPolicy.fetchLimit, 4);
      expect(SearchSuggestionPolicy.displayLimit, 2);
      expect(result.dataOrNull!.conjugationSuggestions, hasLength(4));
    });

    test('normalizes primary gateway failure to SearchReadError', () async {
      final gateway = _Gateway(failPrimary: true);
      final result = await SearchApplicationService(gateway).search(
        SearchQuery(
          text: 'hablar',
          direction: SearchDirection.espJpn,
          page: 0,
          size: 20,
        ),
      );

      expect(result, isA<Failure<SearchResultPage>>());
      expect(result.errorOrNull, isA<SearchDataUnavailableError>());
      expect(result.errorOrNull!.originalError,
          isA<SearchCatalogGatewayError>());
      expect(gateway.meaningCalls, 0);
      expect(gateway.frequencyCalls, 0);
      expect(gateway.rankingCalls, 0);
      expect(gateway.conjugationQueries, isEmpty);
    });

    test('does not call Spanish-only operations for Japanese direction',
        () async {
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

      await SearchApplicationService(gateway).search(
        SearchQuery(
          text: '話す',
          direction: SearchDirection.jpnEsp,
          page: 0,
          size: 20,
        ),
      );

      expect(gateway.frequencyCalls, 0);
      expect(gateway.rankingCalls, 0);
      expect(gateway.conjugationQueries, isEmpty);
    });
  });
}

SearchCatalogPage<SearchPrimaryHit> _primaryPage({
  required List<int> wordIds,
  required bool hasMore,
}) =>
    SearchCatalogPage(
      items: [
        for (final id in wordIds)
          SearchPrimaryHit(
            word: CatalogWordRef(
              catalogId: CatalogId.espJpnMain,
              wordId: id,
            ),
            headword: 'word$id',
            hasConjugation: false,
          ),
      ],
      hasMore: hasMore,
    );

final class _Gateway implements SearchCatalogGateway {
  _Gateway({
    SearchCatalogPage<SearchPrimaryHit>? primary,
    SearchCatalogPage<SearchConjugationHit>? conjugations,
    this.failedEnrichments = const {},
    this.failPrimary = false,
    this.failConjugationSearch = false,
    this.omitMetadata = false,
  })  : primary = primary ??
            SearchCatalogPage<SearchPrimaryHit>(
              items: const [],
              hasMore: false,
            ),
        conjugations = conjugations ??
            SearchCatalogPage<SearchConjugationHit>(
              items: const [],
              hasMore: false,
            );

  final SearchCatalogPage<SearchPrimaryHit> primary;
  final SearchCatalogPage<SearchConjugationHit> conjugations;
  final Set<SearchIssueSource> failedEnrichments;
  final bool failPrimary;
  final bool failConjugationSearch;
  final bool omitMetadata;
  final conjugationQueries = <SearchCatalogQuery>[];
  int meaningCalls = 0;
  int frequencyCalls = 0;
  int rankingCalls = 0;

  @override
  Future<Result<SearchCatalogPage<SearchPrimaryHit>>> searchPrimary(
    SearchCatalogQuery query,
  ) async =>
      failPrimary
          ? const Result<SearchCatalogPage<SearchPrimaryHit>>.failure(
              SearchCatalogGatewayError(
                operation: SearchCatalogOperation.primarySearch,
                message: 'primary unavailable',
              ),
            )
          : Result.success(primary);

  @override
  Future<Result<SearchCatalogPage<SearchConjugationHit>>> searchConjugations(
    SearchCatalogQuery query,
  ) async {
    conjugationQueries.add(query);
    return failConjugationSearch
        ? const Result<SearchCatalogPage<SearchConjugationHit>>.failure(
            SearchCatalogGatewayError(
              operation: SearchCatalogOperation.conjugationSearch,
              message: 'conjugation unavailable',
            ),
          )
        : Result.success(conjugations);
  }

  @override
  Future<Result<Map<CatalogWordRef, SearchMeaningMetadata>>> readMeanings(
    Iterable<CatalogWordRef> words,
  ) async {
    meaningCalls++;
    return _metadataResult(
      SearchIssueSource.meaning,
      SearchCatalogOperation.meanings,
      {for (final word in words) word: const SearchMeaningMetadata('meaning')},
    );
  }

  @override
  Future<Result<Map<CatalogWordRef, SearchFrequencyMetadata>>> readFrequencies(
    Iterable<CatalogWordRef> words,
  ) async {
    frequencyCalls++;
    return _metadataResult(
      SearchIssueSource.frequency,
      SearchCatalogOperation.frequencies,
      {for (final word in words) word: SearchFrequencyMetadata(2)},
    );
  }

  @override
  Future<Result<Map<CatalogWordRef, SearchRankingMetadata>>> readRankings(
    Iterable<CatalogWordRef> words,
  ) async {
    rankingCalls++;
    return _metadataResult(
      SearchIssueSource.ranking,
      SearchCatalogOperation.rankings,
      {for (final word in words) word: const SearchRankingMetadata(1)},
    );
  }

  Result<Map<CatalogWordRef, T>> _metadataResult<T>(
    SearchIssueSource source,
    SearchCatalogOperation operation,
    Map<CatalogWordRef, T> values,
  ) {
    if (failedEnrichments.contains(source)) {
      return Result.failure(
        SearchCatalogGatewayError(
          operation: operation,
          message: '$source unavailable',
        ),
      );
    }
    return Result.success(
      omitMetadata ? <CatalogWordRef, T>{} : values,
    );
  }
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/search/port/search.dart';

void main() {
  const word = CatalogWordRef(
    catalogId: CatalogId.espJpnMain,
    wordId: 7,
  );

  group('Search facade queries', () {
    test('trim text and retain explicit direction and paging', () {
      final query = SearchQuery(
        text: '  hablar  ',
        direction: SearchDirection.espJpn,
        page: 2,
        size: 20,
      );

      expect(query.text, 'hablar');
      expect(query.direction, SearchDirection.espJpn);
      expect(query.page, 2);
      expect(query.size, 20);
    });

    test('reject blank text and invalid paging synchronously', () {
      expect(
        () => SearchQuery(
          text: ' \n\t ',
          direction: SearchDirection.espJpn,
          page: 0,
          size: 20,
        ),
        throwsArgumentError,
      );
      expect(
        () => SearchQuery(
          text: 'hablar',
          direction: SearchDirection.espJpn,
          page: -1,
          size: 20,
        ),
        throwsArgumentError,
      );
      expect(
        () => SearchQuery(
          text: 'hablar',
          direction: SearchDirection.espJpn,
          page: 0,
          size: 0,
        ),
        throwsArgumentError,
      );
    });

    test('required gateway query owns the same invariants', () {
      final query = SearchCatalogQuery(
        text: '  話す ',
        direction: SearchDirection.jpnEsp,
        page: 0,
        size: 10,
      );
      expect(query.text, '話す');

      expect(
        () => SearchCatalogQuery(
          text: ' ',
          direction: SearchDirection.jpnEsp,
          page: 0,
          size: 10,
        ),
        throwsArgumentError,
      );
      expect(
        () => SearchCatalogQuery(
          text: '話す',
          direction: SearchDirection.jpnEsp,
          page: -1,
          size: 10,
        ),
        throwsArgumentError,
      );
      expect(
        () => SearchCatalogQuery(
          text: '話す',
          direction: SearchDirection.jpnEsp,
          page: 0,
          size: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('Search facade results', () {
    test('preserve sole identity, optional absence, direction, and paging', () {
      const item = SearchResultItem(
        word: word,
        headword: 'hablar',
        hasConjugation: true,
      );
      final page = SearchResultPage(
        direction: SearchDirection.espJpn,
        items: const [item],
        conjugationSuggestions: const [],
        hasNext: true,
        issues: const [],
      );

      expect(page.items.single.word, word);
      expect(page.items.single.meaningText, isNull);
      expect(page.items.single.rankingNo, isNull);
      expect(page.items.single.starCount, isNull);
      expect(page.direction, SearchDirection.espJpn);
      expect(page.hasNext, isTrue);
    });

    test('represent an empty collection as success with explicit direction',
        () {
      final result = Result<SearchResultPage>.success(
        SearchResultPage(
          direction: SearchDirection.jpnEsp,
          items: const [],
          conjugationSuggestions: const [],
          hasNext: false,
          issues: const [],
        ),
      );

      expect(result, isA<Success<SearchResultPage>>());
      expect(result.dataOrNull!.items, isEmpty);
      expect(result.dataOrNull!.direction, SearchDirection.jpnEsp);
    });

    test('defensively copy result lists and conjugation maps', () {
      const item = SearchResultItem(
        word: word,
        headword: 'hablar',
        hasConjugation: true,
      );
      final matches = <SearchConjugationMatchKey, String>{
        SearchConjugationMatchKey.indicativePresentYo: 'hablo',
      };
      final suggestion = SearchConjugationSuggestion(
        word: word,
        headword: 'hablar',
        matches: matches,
      );
      final items = <SearchResultItem>[item];
      final suggestions = <SearchConjugationSuggestion>[suggestion];
      final issues = <SearchIssue>[];
      final page = SearchResultPage(
        direction: SearchDirection.espJpn,
        items: items,
        conjugationSuggestions: suggestions,
        hasNext: false,
        issues: issues,
      );

      items.clear();
      suggestions.clear();
      issues.add(
        const SearchIssue(
          source: SearchIssueSource.ranking,
          error: SearchEnrichmentUnavailableError(),
        ),
      );
      matches[SearchConjugationMatchKey.indicativePresentYo] = 'changed';

      expect(page.items, const [item]);
      expect(page.conjugationSuggestions, hasLength(1));
      expect(page.issues, isEmpty);
      expect(
        suggestion.matches[SearchConjugationMatchKey.indicativePresentYo],
        'hablo',
      );
      expect(() => page.items.clear(), throwsUnsupportedError);
      expect(() => suggestion.matches.clear(), throwsUnsupportedError);
    });
  });

  group('Search facade failures', () {
    test('reader returns a typed primary failure through Result', () async {
      final result = await _UnavailableReader().search(
        SearchQuery(
          text: 'hablar',
          direction: SearchDirection.espJpn,
          page: 0,
          size: 20,
        ),
      );

      expect(result, isA<Failure<SearchResultPage>>());
      expect(result.errorOrNull, isA<SearchReadError>());
    });

    test('distinguish typed primary failure from typed partial issue', () {
      const primary = SearchDataUnavailableError();
      const issue = SearchIssue(
        source: SearchIssueSource.frequency,
        error: SearchEnrichmentUnavailableError(),
      );

      expect(primary, isA<SearchReadError>());
      expect(primary.code, 'SEARCH_DATA_UNAVAILABLE');
      expect(issue.source, SearchIssueSource.frequency);
      expect(issue.error, isA<SearchIssueError>());
    });

    test('type Catalog gateway operation without a wire string', () {
      const error = SearchCatalogGatewayError(
        operation: SearchCatalogOperation.rankings,
        message: 'ranking unavailable',
      );

      expect(error.operation, SearchCatalogOperation.rankings);
      expect(error.code, 'SEARCH_CATALOG_GATEWAY_FAILURE');
    });
  });

  test('gateway pages defensively copy items and retain hasMore', () {
    const hit = SearchPrimaryHit(
      word: word,
      headword: 'hablar',
      hasConjugation: true,
    );
    final hits = <SearchPrimaryHit>[hit];
    final page = SearchCatalogPage(items: hits, hasMore: true);
    hits.clear();

    expect(page.items, const [hit]);
    expect(page.hasMore, isTrue);
    expect(() => page.items.clear(), throwsUnsupportedError);
    expect(() => SearchFrequencyMetadata(-1), throwsArgumentError);
  });

  test('business facade contract files remain pure Dart', () {
    const files = [
      'lib/features/search/port/search.dart',
      'lib/features/search/port/query/search_reader_port.dart',
      'lib/features/search/port/query/search_query.dart',
      'lib/features/search/port/query/search_catalog_query.dart',
      'lib/features/search/port/model/search_direction.dart',
      'lib/features/search/port/model/search_conjugation_match.dart',
      'lib/features/search/port/model/search_result_item.dart',
      'lib/features/search/port/result/search_result_page.dart',
      'lib/features/search/port/result/search_catalog_page.dart',
      'lib/features/search/port/error/search_read_error.dart',
      'lib/features/search/port/error/search_issue.dart',
      'lib/features/search/port/error/search_catalog_gateway_error.dart',
      'lib/features/search/port/gateway/search_catalog_gateway.dart',
    ];
    final source = files.map((path) => File(path).readAsStringSync()).join();

    for (final forbidden in [
      'package:flutter/',
      'package:flutter_riverpod/',
      'package:drift/',
      'package:cloud_firestore/',
      'features/search/internal/',
    ]) {
      expect(source, isNot(contains(forbidden)), reason: forbidden);
    }
  });
}

final class _UnavailableReader implements SearchQueryPort {
  @override
  Future<Result<SearchResultPage>> search(SearchQuery query) async =>
      const Result<SearchResultPage>.failure(SearchDataUnavailableError());
}

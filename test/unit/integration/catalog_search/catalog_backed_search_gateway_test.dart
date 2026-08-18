import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/search/port/search.dart';
import 'package:my_dic/integration/catalog_search/catalog_backed_search_gateway.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 9);
  final query = SearchCatalogQuery(
    text: 'hab',
    direction: SearchDirection.espJpn,
    page: 1,
    size: 4,
  );

  test('maps Catalog pages, typed matches, and metadata to Search values',
      () async {
    final gateway = CatalogBackedSearchGateway(
      _ports(
        words: _WordReader(
          Result.success(
            CatalogSearchPage(
              items: const [
                CatalogWordSearchHit(
                  word: word,
                  headword: 'hablar',
                  hasConjugation: true,
                ),
              ],
              hasMore: true,
            ),
          ),
        ),
        conjugations: _ConjugationSearchReader(
          Result.success(
            CatalogSearchPage(
              items: [
                CatalogConjugationSearchHit(
                  word: word,
                  headword: 'hablar',
                  matches: {
                    const CatalogConjugationMatch(
                      moodTense: CatalogMoodTense.indicativePresent,
                      subject: CatalogSubject.yo,
                    ): 'hablo',
                  },
                ),
              ],
              hasMore: false,
            ),
          ),
        ),
        summaries: _SummaryReader(),
        rankings: _RankingReader(),
      ),
    );

    final primary = (await gateway.searchPrimary(query)).dataOrNull!;
    final suggestions = (await gateway.searchConjugations(query)).dataOrNull!;
    final meanings = (await gateway.readMeanings([word])).dataOrNull!;
    final frequencies = (await gateway.readFrequencies([word])).dataOrNull!;
    final rankings = (await gateway.readRankings([word])).dataOrNull!;

    expect(primary.hasMore, isTrue);
    expect(primary.items.single.word, word);
    expect(
      suggestions.items.single.matches,
      const {SearchConjugationMatchKey.indicativePresentYo: 'hablo'},
    );
    expect(meanings[word]!.text, 'speak');
    expect(frequencies[word]!.value, 3);
    expect(rankings[word]!.rankingNo, 12);
  });

  test('maps Catalog failure while preserving cause and stack', () async {
    final cause = StateError('database');
    final stack = StackTrace.current;
    final gateway = CatalogBackedSearchGateway(
      _ports(
        words: _WordReader(
          Result.failure(
            CatalogDataUnavailableError(
              originalError: cause,
              stackTrace: stack,
            ),
          ),
        ),
      ),
    );

    final error = (await gateway.searchPrimary(query)).errorOrNull;
    expect(error, isA<SearchCatalogGatewayError>());
    final typedError = error as SearchCatalogGatewayError;
    expect(
      typedError.operation,
      SearchCatalogOperation.primarySearch,
    );
    expect(typedError.originalError, same(cause));
    expect(typedError.stackTrace, same(stack));
  });

  test('maps every supported conjugation variant without enum indexes',
      () async {
    final matches = {
      for (final match in _allCatalogMatches()) match: match.toString(),
    };
    final gateway = CatalogBackedSearchGateway(
      _ports(
        words: _WordReader(
          Result.success(
            CatalogSearchPage<CatalogWordSearchHit>(
              items: const [],
              hasMore: false,
            ),
          ),
        ),
        conjugations: _ConjugationSearchReader(
          Result.success(
            CatalogSearchPage(
              items: [
                CatalogConjugationSearchHit(
                  word: word,
                  headword: 'hablar',
                  matches: matches,
                ),
              ],
              hasMore: false,
            ),
          ),
        ),
      ),
    );

    final page = (await gateway.searchConjugations(query)).dataOrNull!;

    expect(
      page.items.single.matches.keys.toSet(),
      SearchConjugationMatchKey.values.toSet(),
    );
  });

  test('keeps empty batches and missing keys as successful absence', () async {
    final gateway = CatalogBackedSearchGateway(
      _ports(
        words: _WordReader(
          Result.success(
            CatalogSearchPage<CatalogWordSearchHit>(
              items: const [],
              hasMore: false,
            ),
          ),
        ),
        summaries: _MissingSummaryReader(),
      ),
    );

    expect((await gateway.readMeanings(const [])).dataOrNull, isEmpty);
    expect((await gateway.readMeanings([word])).dataOrNull, isEmpty);
    expect((await gateway.readFrequencies([word])).dataOrNull, isEmpty);
  });

  test('normalizes unexpected exceptions with typed operation and stack',
      () async {
    final cause = StateError('unexpected');
    final gateway = CatalogBackedSearchGateway(
      _ports(words: _ThrowingWordReader(cause)),
    );

    final error = (await gateway.searchPrimary(query)).errorOrNull;

    expect(error, isA<SearchCatalogGatewayError>());
    final typedError = error as SearchCatalogGatewayError;
    expect(
      typedError.operation,
      SearchCatalogOperation.primarySearch,
    );
    expect(typedError.originalError, same(cause));
    expect(typedError.stackTrace, isNotNull);
  });

  test('pure adapter imports only the Catalog and Search business facades', () {
    final source = File(
      'lib/integration/catalog_search/catalog_backed_search_gateway.dart',
    ).readAsStringSync();
    final imports = RegExp(
      r'''^import ['"]([^'"]+)['"];''',
      multiLine: true,
    ).allMatches(source).map((match) => match.group(1)).toList();

    expect(imports, const [
      'package:my_dic/features/catalog/port/catalog.dart',
      'package:my_dic/features/search/port/search.dart',
    ]);
    expect(source, isNot(contains('.index')));
    for (final forbidden in [
      'features/catalog/internal/',
      'features/search/internal/',
      'package:flutter/',
      'package:flutter_riverpod/',
      'package:drift/',
    ]) {
      expect(source, isNot(contains(forbidden)), reason: forbidden);
    }
  });
}

Iterable<CatalogConjugationMatch> _allCatalogMatches() sync* {
  for (final moodTense in CatalogMoodTense.values) {
    if (moodTense == CatalogMoodTense.participlePresent ||
        moodTense == CatalogMoodTense.participlePast) {
      yield CatalogConjugationMatch(moodTense: moodTense);
      continue;
    }
    for (final subject in CatalogSubject.values) {
      if (moodTense == CatalogMoodTense.imperative &&
          subject == CatalogSubject.yo) {
        continue;
      }
      yield CatalogConjugationMatch(
        moodTense: moodTense,
        subject: subject,
      );
    }
  }
}

CatalogReadPorts _ports({
  required CatalogWordSearchQueryPort words,
  CatalogConjugationSearchQueryPort? conjugations,
  CatalogEntrySummaryQueryPort? summaries,
  CatalogRankingQueryPort? rankings,
}) =>
    CatalogReadPorts(
      entryDetail: _UnusedEntry(),
      conjugation: _UnusedConjugation(),
      wordSearch: words,
      conjugationSearch: conjugations ?? _UnusedConjugationSearch(),
      entrySummary: summaries ?? _UnusedSummary(),
      ranking: rankings ?? _UnusedRanking(),
      rankedEntries: _UnusedProviderPrerequisites(),
      semanticEntryDetail: _UnusedProviderPrerequisites(),
    );

final class _UnusedProviderPrerequisites
    implements
        CatalogRankedEntryFeedQueryPort,
        CatalogSemanticEntryDetailQueryPort {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _WordReader implements CatalogWordSearchQueryPort {
  const _WordReader(this.result);
  final Result<CatalogSearchPage<CatalogWordSearchHit>> result;
  @override
  Future<Result<CatalogSearchPage<CatalogWordSearchHit>>> searchWords(
    CatalogWordSearchQuery query,
  ) async =>
      result;
}

final class _ThrowingWordReader implements CatalogWordSearchQueryPort {
  const _ThrowingWordReader(this.error);

  final Object error;

  @override
  Future<Result<CatalogSearchPage<CatalogWordSearchHit>>> searchWords(
    CatalogWordSearchQuery query,
  ) =>
      Future.error(error, StackTrace.current);
}

final class _ConjugationSearchReader
    implements CatalogConjugationSearchQueryPort {
  const _ConjugationSearchReader(this.result);
  final Result<CatalogSearchPage<CatalogConjugationSearchHit>> result;
  @override
  Future<Result<CatalogSearchPage<CatalogConjugationSearchHit>>>
      searchConjugations(CatalogConjugationSearchQuery query) async => result;
}

final class _SummaryReader implements CatalogEntrySummaryQueryPort {
  @override
  Future<Result<Map<CatalogWordRef, CatalogMeaningSummary>>> readMeanings(
    Iterable<CatalogWordRef> words,
  ) async =>
      Result.success({
        for (final word in words)
          word: const CatalogMeaningSummary(meaning: 'speak'),
      });

  @override
  Future<Result<Map<CatalogWordRef, CatalogHeadwordMetadata>>>
      readHeadwordMetadata(Iterable<CatalogWordRef> words) async =>
          Result.success({
            for (final word in words)
              word: CatalogHeadwordMetadata(
                headword: 'hablar',
                frequencyLevel: CatalogFrequencyLevel(3),
              ),
          });
}

final class _MissingSummaryReader implements CatalogEntrySummaryQueryPort {
  @override
  Future<Result<Map<CatalogWordRef, CatalogMeaningSummary>>> readMeanings(
    Iterable<CatalogWordRef> words,
  ) async =>
      Result.success(<CatalogWordRef, CatalogMeaningSummary>{});

  @override
  Future<Result<Map<CatalogWordRef, CatalogHeadwordMetadata>>>
      readHeadwordMetadata(Iterable<CatalogWordRef> words) async =>
          Result.success(<CatalogWordRef, CatalogHeadwordMetadata>{});
}

final class _RankingReader implements CatalogRankingQueryPort {
  @override
  Future<Result<Map<CatalogWordRef, CatalogRankingMetadata>>>
      readRankingMetadata(Iterable<CatalogWordRef> words) async =>
          Result.success({
            for (final word in words)
              word: const CatalogRankingMetadata(rankingNo: 12),
          });
}

final class _UnusedEntry implements CatalogEntryDetailQueryPort {
  @override
  Future<Result<CatalogEntryDetail>> readEntryDetail(CatalogWordRef word) =>
      throw UnimplementedError();
}

final class _UnusedConjugation implements CatalogConjugationQueryPort {
  @override
  Future<Result<CatalogConjugation?>> readConjugation(CatalogWordRef word) =>
      throw UnimplementedError();
  @override
  Future<Result<bool>> hasConjugation(CatalogWordRef word) =>
      throw UnimplementedError();
}

final class _UnusedConjugationSearch
    implements CatalogConjugationSearchQueryPort {
  @override
  Future<Result<CatalogSearchPage<CatalogConjugationSearchHit>>>
      searchConjugations(CatalogConjugationSearchQuery query) =>
          throw UnimplementedError();
}

final class _UnusedSummary implements CatalogEntrySummaryQueryPort {
  @override
  Future<Result<Map<CatalogWordRef, CatalogHeadwordMetadata>>>
      readHeadwordMetadata(Iterable<CatalogWordRef> words) =>
          throw UnimplementedError();
  @override
  Future<Result<Map<CatalogWordRef, CatalogMeaningSummary>>> readMeanings(
    Iterable<CatalogWordRef> words,
  ) =>
      throw UnimplementedError();
}

final class _UnusedRanking implements CatalogRankingQueryPort {
  @override
  Future<Result<Map<CatalogWordRef, CatalogRankingMetadata>>>
      readRankingMetadata(Iterable<CatalogWordRef> words) =>
          throw UnimplementedError();
}

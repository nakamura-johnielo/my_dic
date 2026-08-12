import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/search/port/catalog_gateway.dart';
import 'package:my_dic/features/search/port/error/search_catalog_gateway_error.dart';
import 'package:my_dic/features/search/port/model/search_conjugation_match_key.dart';
import 'package:my_dic/features/search/port/model/search_direction.dart';
import 'package:my_dic/integration/catalog_search/catalog_backed_search_gateway.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 9);
  const query = SearchCatalogQuery(
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
    final headwords = (await gateway.readHeadwordMetadata([word])).dataOrNull!;
    final rankings = (await gateway.readRankingMetadata([word])).dataOrNull!;

    expect(primary.hasMore, isTrue);
    expect(primary.items.single.word, word);
    expect(
      suggestions.items.single.matches,
      const {SearchConjugationMatchKey.indicativePresentYo: 'hablo'},
    );
    expect(meanings[word]!.text, 'speak');
    expect(headwords[word]!.headword, 'hablar');
    expect(headwords[word]!.frequency, 3);
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
    expect(error!.originalError, same(cause));
    expect(error.stackTrace, same(stack));
  });
}

CatalogReadPorts _ports({
  required CatalogWordSearchReaderPort words,
  CatalogConjugationSearchReaderPort? conjugations,
  CatalogEntrySummaryReaderPort? summaries,
  CatalogRankingReaderPort? rankings,
}) =>
    CatalogReadPorts(
      entryDetail: _UnusedEntry(),
      conjugation: _UnusedConjugation(),
      wordSearch: words,
      conjugationSearch: conjugations ?? _UnusedConjugationSearch(),
      entrySummary: summaries ?? _UnusedSummary(),
      ranking: rankings ?? _UnusedRanking(),
    );

final class _WordReader implements CatalogWordSearchReaderPort {
  const _WordReader(this.result);
  final Result<CatalogSearchPage<CatalogWordSearchHit>> result;
  @override
  Future<Result<CatalogSearchPage<CatalogWordSearchHit>>> searchWords(
    CatalogWordSearchQuery query,
  ) async =>
      result;
}

final class _ConjugationSearchReader
    implements CatalogConjugationSearchReaderPort {
  const _ConjugationSearchReader(this.result);
  final Result<CatalogSearchPage<CatalogConjugationSearchHit>> result;
  @override
  Future<Result<CatalogSearchPage<CatalogConjugationSearchHit>>>
      searchConjugations(CatalogConjugationSearchQuery query) async => result;
}

final class _SummaryReader implements CatalogEntrySummaryReaderPort {
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

final class _RankingReader implements CatalogRankingReaderPort {
  @override
  Future<Result<Map<CatalogWordRef, CatalogRankingMetadata>>>
      readRankingMetadata(Iterable<CatalogWordRef> words) async =>
          Result.success({
            for (final word in words)
              word: const CatalogRankingMetadata(rankingNo: 12),
          });
}

final class _UnusedEntry implements CatalogEntryDetailReaderPort {
  @override
  Future<Result<CatalogEntryDetail>> readEntryDetail(CatalogWordRef word) =>
      throw UnimplementedError();
}

final class _UnusedConjugation implements CatalogConjugationReaderPort {
  @override
  Future<Result<CatalogConjugation?>> readConjugation(CatalogWordRef word) =>
      throw UnimplementedError();
  @override
  Future<Result<bool>> hasConjugation(CatalogWordRef word) =>
      throw UnimplementedError();
}

final class _UnusedConjugationSearch
    implements CatalogConjugationSearchReaderPort {
  @override
  Future<Result<CatalogSearchPage<CatalogConjugationSearchHit>>>
      searchConjugations(CatalogConjugationSearchQuery query) =>
          throw UnimplementedError();
}

final class _UnusedSummary implements CatalogEntrySummaryReaderPort {
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

final class _UnusedRanking implements CatalogRankingReaderPort {
  @override
  Future<Result<Map<CatalogWordRef, CatalogRankingMetadata>>>
      readRankingMetadata(Iterable<CatalogWordRef> words) =>
          throw UnimplementedError();
}

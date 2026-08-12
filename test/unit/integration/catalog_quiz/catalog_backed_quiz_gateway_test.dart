import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/port/catalog_gateway.dart';
import 'package:my_dic/features/quiz/port/error/quiz_catalog_gateway_error.dart';
import 'package:my_dic/integration/catalog_quiz/catalog_backed_quiz_gateway.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 9);

  test('maps Catalog candidate page and typed enrichment to Quiz values',
      () async {
    final conjugations = _ConjugationSearchReader(
      Result.success(
        CatalogSearchPage(
          items: [
            CatalogConjugationSearchHit(
              word: word,
              headword: 'raw hablar',
              matches: const {},
            ),
          ],
          hasMore: true,
        ),
      ),
    );
    final gateway = CatalogBackedQuizGateway(
      _ports(
        conjugations: conjugations,
        summaries: _SummaryReader(),
        rankings: _RankingReader(),
      ),
    );

    final page = (await gateway.searchConjugationCandidates(
      const QuizCatalogQuery(text: 'hab', page: 1, size: 4),
    ))
        .dataOrNull!;
    final meanings = (await gateway.readMeanings([word])).dataOrNull!;
    final headwords = (await gateway.readHeadwordMetadata([word])).dataOrNull!;
    final rankings = (await gateway.readRankingMetadata([word])).dataOrNull!;

    expect(conjugations.query?.catalogId, CatalogId.espJpnMain);
    expect(conjugations.query?.text, 'hab');
    expect(conjugations.query?.page, 1);
    expect(conjugations.query?.size, 4);
    expect(page.hasMore, isTrue);
    expect(page.items.single.word, word);
    expect(page.items.single.headword, 'raw hablar');
    expect(meanings[word]!.text, 'speak');
    expect(headwords[word]!.headword, 'hablar');
    expect(headwords[word]!.frequency, 3);
    expect(rankings[word]!.rankingNo, 12);
  });

  test('maps Catalog failure while preserving its cause and stack', () async {
    final cause = StateError('database');
    final stack = StackTrace.current;
    final gateway = CatalogBackedQuizGateway(
      _ports(
        conjugations: _ConjugationSearchReader(
          Result.failure(
            CatalogDataUnavailableError(
              originalError: cause,
              stackTrace: stack,
            ),
          ),
        ),
      ),
    );

    final error = (await gateway.searchConjugationCandidates(
      const QuizCatalogQuery(text: 'hab', page: 0, size: 30),
    ))
        .errorOrNull;

    expect(error, isA<QuizCatalogGatewayError>());
    expect((error! as QuizCatalogGatewayError).operation, 'conjugation');
    expect(error.originalError, same(cause));
    expect(error.stackTrace, same(stack));
  });
}

CatalogReadPorts _ports({
  required CatalogConjugationSearchReaderPort conjugations,
  CatalogEntrySummaryReaderPort? summaries,
  CatalogRankingReaderPort? rankings,
}) =>
    CatalogReadPorts(
      entryDetail: _UnusedEntry(),
      conjugation: _UnusedConjugation(),
      wordSearch: _UnusedWordSearch(),
      conjugationSearch: conjugations,
      entrySummary: summaries ?? _UnusedSummary(),
      ranking: rankings ?? _UnusedRanking(),
    );

final class _ConjugationSearchReader
    implements CatalogConjugationSearchReaderPort {
  _ConjugationSearchReader(this.result);
  final Result<CatalogSearchPage<CatalogConjugationSearchHit>> result;
  CatalogConjugationSearchQuery? query;

  @override
  Future<Result<CatalogSearchPage<CatalogConjugationSearchHit>>>
      searchConjugations(CatalogConjugationSearchQuery value) async {
    query = value;
    return result;
  }
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

final class _UnusedWordSearch implements CatalogWordSearchReaderPort {
  @override
  Future<Result<CatalogSearchPage<CatalogWordSearchHit>>> searchWords(
    CatalogWordSearchQuery query,
  ) =>
      throw UnimplementedError();
}

final class _UnusedSummary implements CatalogEntrySummaryReaderPort {
  @override
  Future<Result<Map<CatalogWordRef, CatalogMeaningSummary>>> readMeanings(
    Iterable<CatalogWordRef> words,
  ) =>
      throw UnimplementedError();

  @override
  Future<Result<Map<CatalogWordRef, CatalogHeadwordMetadata>>>
      readHeadwordMetadata(Iterable<CatalogWordRef> words) =>
          throw UnimplementedError();
}

final class _UnusedRanking implements CatalogRankingReaderPort {
  @override
  Future<Result<Map<CatalogWordRef, CatalogRankingMetadata>>>
      readRankingMetadata(Iterable<CatalogWordRef> words) =>
          throw UnimplementedError();
}

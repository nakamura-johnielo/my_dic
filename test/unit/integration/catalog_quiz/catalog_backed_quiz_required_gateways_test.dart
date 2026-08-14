import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';
import 'package:my_dic/integration/catalog_quiz/catalog_backed_quiz_candidate_gateway.dart';
import 'package:my_dic/integration/catalog_quiz/catalog_backed_quiz_game_gateway.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 9);

  test('candidate gateway preserves Catalog identity and hasMore', () async {
    final gateway = CatalogBackedQuizCandidateGateway(_ports(
      search: _SearchReader(Result.success(CatalogSearchPage(
        items: [
          CatalogConjugationSearchHit(
              word: word, headword: 'hablar', matches: const {})
        ],
        hasMore: true,
      ))),
    ));

    final page = (await gateway.searchConjugationCandidates(
      const QuizCatalogCandidateQuery(text: 'hab', page: 2, size: 5),
    ))
        .dataOrNull!;

    expect(page.hasMore, isTrue);
    expect(page.items.single.word, same(word));
  });

  test('candidate gateway translates Catalog errors without losing cause',
      () async {
    final cause = StateError('offline');
    final stack = StackTrace.current;
    final gateway = CatalogBackedQuizCandidateGateway(_ports(
      search: _SearchReader(Result.failure(CatalogDataUnavailableError(
        originalError: cause,
        stackTrace: stack,
      ))),
    ));

    final error = (await gateway.searchConjugationCandidates(
      const QuizCatalogCandidateQuery(text: 'hab', page: 0, size: 5),
    ))
        .errorOrNull! as QuizCatalogGatewayError;

    expect(error.operation, 'conjugationCandidates');
    expect(error.originalError, same(cause));
    expect(error.stackTrace, same(stack));
  });

  test('game gateway maps primary detail and optional conjugation', () async {
    final gateway = CatalogBackedQuizGameGateway(_ports(
      detail: _DetailReader(Result.success(EspJpnEntryDetail(
        word: word,
        entries: [EspJpnEntry(dictionaryId: 1, word: 'hablar')],
      ))),
      conjugation: _ConjugationReader(Result.success(CatalogConjugation(
        word: word,
        participles:
            const CatalogParticiples(present: 'hablando', past: 'hablado'),
        conjugations: {
          CatalogMoodTense.indicativePresent: CatalogTenseConjugation(
            forms: {CatalogSubject.yo: 'hablo'},
          ),
        },
      ))),
    ));

    final primary = (await gateway.readPrimaryWord(word)).dataOrNull!;
    final conjugation = (await gateway.readConjugation(word)).dataOrNull!;

    expect(primary.word, same(word));
    expect(primary.headword, 'hablar');
    expect(conjugation.word, same(word));
    expect(
      conjugation.form(QuizMoodTense.indicativePresent, QuizSubject.yo),
      'hablo',
    );
  });
}

CatalogReadPorts _ports({
  CatalogConjugationSearchQueryPort? search,
  CatalogEntryDetailQueryPort? detail,
  CatalogConjugationQueryPort? conjugation,
}) =>
    CatalogReadPorts(
      entryDetail: detail ?? _UnusedDetail(),
      conjugation: conjugation ?? _UnusedConjugation(),
      wordSearch: _UnusedWordSearch(),
      conjugationSearch: search ?? _UnusedSearch(),
      entrySummary: _UnusedSummary(),
      ranking: _UnusedRanking(),
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

final class _SearchReader implements CatalogConjugationSearchQueryPort {
  _SearchReader(this.result);
  final Result<CatalogSearchPage<CatalogConjugationSearchHit>> result;
  @override
  Future<Result<CatalogSearchPage<CatalogConjugationSearchHit>>>
      searchConjugations(CatalogConjugationSearchQuery query) async => result;
}

final class _DetailReader implements CatalogEntryDetailQueryPort {
  _DetailReader(this.result);
  final Result<CatalogEntryDetail> result;
  @override
  Future<Result<CatalogEntryDetail>> readEntryDetail(
          CatalogWordRef word) async =>
      result;
}

final class _ConjugationReader implements CatalogConjugationQueryPort {
  _ConjugationReader(this.result);
  final Result<CatalogConjugation?> result;
  @override
  Future<Result<CatalogConjugation?>> readConjugation(
          CatalogWordRef word) async =>
      result;
  @override
  Future<Result<bool>> hasConjugation(CatalogWordRef word) =>
      throw UnimplementedError();
}

final class _UnusedDetail implements CatalogEntryDetailQueryPort {
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

final class _UnusedSearch implements CatalogConjugationSearchQueryPort {
  @override
  Future<Result<CatalogSearchPage<CatalogConjugationSearchHit>>>
      searchConjugations(CatalogConjugationSearchQuery query) =>
          throw UnimplementedError();
}

final class _UnusedWordSearch implements CatalogWordSearchQueryPort {
  @override
  Future<Result<CatalogSearchPage<CatalogWordSearchHit>>> searchWords(
          CatalogWordSearchQuery query) =>
      throw UnimplementedError();
}

final class _UnusedSummary implements CatalogEntrySummaryQueryPort {
  @override
  Future<Result<Map<CatalogWordRef, CatalogMeaningSummary>>> readMeanings(
          Iterable<CatalogWordRef> words) =>
      throw UnimplementedError();
  @override
  Future<Result<Map<CatalogWordRef, CatalogHeadwordMetadata>>>
      readHeadwordMetadata(Iterable<CatalogWordRef> words) =>
          throw UnimplementedError();
}

final class _UnusedRanking implements CatalogRankingQueryPort {
  @override
  Future<Result<Map<CatalogWordRef, CatalogRankingMetadata>>>
      readRankingMetadata(Iterable<CatalogWordRef> words) =>
          throw UnimplementedError();
}

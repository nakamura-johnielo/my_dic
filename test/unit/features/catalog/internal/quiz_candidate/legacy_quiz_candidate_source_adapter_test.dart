import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/datasource/conjugacion/i_conjugacion_local_datasource.dart';
import 'package:my_dic/core/infrastructure/datasource/esj/esj_dictionary_dataset.dart';
import 'package:my_dic/core/infrastructure/datasource/esj/i_esj_dictionary_data_source.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/legacy/quiz_candidate/legacy_quiz_candidate_enrichment.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/legacy/quiz_candidate/legacy_quiz_candidate_source_adapter.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_query.dart';

void main() {
  test('maps the paged primary rows to EspJpn candidates with enrichment',
      () async {
    final conjugations = _Conjugations(rows: const [
      EspConjugationTableData(wordId: 7, word: 'hablar'),
      EspConjugationTableData(wordId: 8, word: 'comer'),
    ]);
    final source = _source(
      conjugations,
      dictionary: _Dictionary(
        contents: {7: '<p data-orgtag="meaning">to <b>speak</b></p>'},
        headwords: {7: 'hablar<sup>(**)</sup>', 8: 'comer'},
      ),
      rankings: (ids) async => {7: 3, 8: 12},
    );

    final result = await source.search(
      const QuizCandidateQuery(text: ' hablar ', page: 1, size: 2),
    );
    final page = result.dataOrNull!;

    expect(conjugations.requests, [('hablar', 2, 1)]);
    expect(page.hasNext, isTrue);
    expect(page.candidates, [
      const QuizCandidate(
        word: _espWord7,
        headword: 'hablar',
        meaningText: 'to speak',
        rankingNo: 3,
        starCount: 2,
      ),
      const QuizCandidate(
        word: _espWord8,
        headword: 'comer',
        meaningText: null,
        rankingNo: 12,
        starCount: 0,
      ),
    ]);
    expect(page.issues, isEmpty);
  });

  test('uses conjugation meaning before dictionary fallback', () async {
    final conjugations = _Conjugations(
      rows: const [EspConjugationTableData(wordId: 7, word: 'hablar')],
      meanings: {7: 'conjugation meaning'},
    );
    final result = await _source(
      conjugations,
      dictionary: _Dictionary(
        contents: {7: '<p data-orgtag="meaning">dictionary meaning</p>'},
      ),
      rankings: (ids) async => const {},
    ).search(const QuizCandidateQuery(text: 'hablar', page: 0, size: 2));

    expect(result.dataOrNull!.candidates.single.meaningText,
        'conjugation meaning');
  });

  test(
      'returns source warnings and keeps the primary page on enrichment errors',
      () async {
    final conjugations = _Conjugations(
      rows: const [EspConjugationTableData(wordId: 7, word: 'hablar')],
      failMeanings: true,
    );
    final result = await _source(
      conjugations,
      dictionary: _Dictionary(failContents: true, failHeadwords: true),
      rankings: (ids) => throw StateError('ranking unavailable'),
    ).search(const QuizCandidateQuery(text: 'hablar', page: 0, size: 2));
    final page = result.dataOrNull!;

    expect(page.candidates.single.meaningText, isNull);
    expect(page.candidates.single.rankingNo, isNull);
    expect(page.candidates.single.starCount, isNull);
    expect(page.issues.map((issue) => issue.source).toSet(),
        {'ranking', 'meaning', 'starCount'});
    expect(page.issues.map((issue) => issue.error),
        everyElement(isA<DatabaseError>()));
  });

  test('wraps a primary query failure as the Quiz candidate database error',
      () async {
    final result = await _source(
      _Conjugations(failPrimary: true),
      dictionary: _Dictionary(),
      rankings: (ids) async => const {},
    ).search(const QuizCandidateQuery(text: 'hablar', page: 0, size: 30));

    final error = result.errorOrNull!;
    expect(error, isA<DatabaseError>());
    expect(error.message, 'Unable to search quiz candidates.');
  });

  test(
      'exposes immutable page collections and derives hasNext from primary size',
      () async {
    final source = _source(
      _Conjugations(
          rows: const [EspConjugationTableData(wordId: 7, word: 'hablar')]),
      dictionary: _Dictionary(),
      rankings: (ids) async => const {},
    );
    final page = (await source.search(
      const QuizCandidateQuery(text: 'hablar', page: 0, size: 2),
    ))
        .dataOrNull!;

    expect(page.hasNext, isFalse);
    expect(() => page.candidates.add(page.candidates.single),
        throwsUnsupportedError);
  });
}

const _espWord7 = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);
const _espWord8 = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 8);

LegacyQuizCandidateSourceAdapter _source(
  _Conjugations conjugations, {
  required _Dictionary dictionary,
  required Future<Map<int, int>> Function(List<int>) rankings,
}) =>
    LegacyQuizCandidateSourceAdapter(
      conjugations,
      LegacyQuizCandidateEnrichment(conjugations, dictionary, rankings),
    );

final class _Conjugations implements IConjugacionLocalDataSource {
  _Conjugations({
    this.rows = const [],
    this.meanings = const {},
    this.failPrimary = false,
    this.failMeanings = false,
  });

  final List<EspConjugationTableData> rows;
  final Map<int, String> meanings;
  final bool failPrimary;
  final bool failMeanings;
  final List<(String, int, int)> requests = [];

  @override
  Future<List<EspConjugationTableData>> getQuizConjugacionByWordWithPage(
    String word,
    int size,
    int currentPage,
  ) async {
    requests.add((word, size, currentPage));
    if (failPrimary) throw StateError('primary unavailable');
    return rows;
  }

  @override
  Future<Map<int, String>> getMeaningsByWordIds(List<int> wordIds) async {
    if (failMeanings) throw StateError('meanings unavailable');
    return meanings;
  }

  @override
  Future<EspConjugationTableData?> getConjugacionByWordId(int id) async => null;

  @override
  Future<List<EspConjugationTableData>> getConjugacionByWordWithPage(
    String word,
    int size,
    int currentPage,
  ) async =>
      const [];

  @override
  Future<bool> existsConjByWordId(int wordId) async => false;

  @override
  Future<String?> getSimpleMeaningById(int id) async => null;
}

final class _Dictionary implements IEsjDictionaryLocalDataSource {
  _Dictionary({
    this.contents = const {},
    this.headwords = const {},
    this.failContents = false,
    this.failHeadwords = false,
  });

  final Map<int, String> contents;
  final Map<int, String> headwords;
  final bool failContents;
  final bool failHeadwords;

  @override
  Future<Map<int, String>> getFirstContentsByWordIds(List<int> wordIds) async {
    if (failContents) throw StateError('contents unavailable');
    return contents;
  }

  @override
  Future<Map<int, String>> getFirstHeadwordsByWordIds(List<int> wordIds) async {
    if (failHeadwords) throw StateError('headwords unavailable');
    return headwords;
  }

  @override
  Future<List<EsjDictionaryDataSet>> getDictionaryByWordId(int wordId) async =>
      const [];

  @override
  Future<String?> getFirstContentByWordId(int wordId) async => contents[wordId];

  @override
  Future<String?> getFirstHeadwordByWordId(int wordId) async =>
      headwords[wordId];

  @override
  Future<String?> getHeadwordById(int id) async => null;

  @override
  Future<String?> getSimpleMeaningById(int id) async => null;
}

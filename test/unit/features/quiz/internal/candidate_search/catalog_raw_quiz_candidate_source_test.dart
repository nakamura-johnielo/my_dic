import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/raw_quiz_candidate_reader.dart';
import 'package:my_dic/features/quiz/internal/candidate_search/catalog_raw_quiz_candidate_source.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_query.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);

  test('owns trimmed paging and candidate enrichment policy', () async {
    final catalog = _Catalog(
      hits: const [CatalogRawQuizCandidateHit(word: word, headword: 'hablar')],
      meanings: {word: 'to speak'},
      headwords: {word: 'hablar<sup>(**)</sup>'},
      rankings: {word: 3},
    );

    final result = await CatalogRawQuizCandidateSource(catalog).search(
      const QuizCandidateQuery(text: ' hablar ', page: 1, size: 1),
    );

    expect(catalog.query?.text, 'hablar');
    expect(catalog.query?.page, 1);
    expect(catalog.query?.size, 1);
    final page = result.dataOrNull!;
    expect(page.hasNext, isTrue);
    expect(page.issues, isEmpty);
    expect(page.candidates.single.headword, 'hablar<sup>(**)</sup>');
    expect(page.candidates.single.meaningText, 'to speak');
    expect(page.candidates.single.rankingNo, 3);
    expect(page.candidates.single.starCount, 2);
  });

  test('turns enrichment failures into partial issues', () async {
    final catalog = _Catalog(
      hits: const [CatalogRawQuizCandidateHit(word: word, headword: 'hablar')],
      failMeanings: true,
      failRankings: true,
    );

    final page = (await CatalogRawQuizCandidateSource(catalog).search(
      const QuizCandidateQuery(text: 'hablar', page: 0, size: 30),
    ))
        .dataOrNull!;

    expect(page.candidates, hasLength(1));
    expect(page.issues.map((issue) => issue.source),
        containsAll(<String>['meaning', 'ranking']));
  });

  test('turns a primary raw candidate failure into a Result failure', () async {
    final result = await CatalogRawQuizCandidateSource(
      _Catalog(failSearch: true),
    ).search(const QuizCandidateQuery(text: 'hablar', page: 0, size: 30));

    expect(result, isA<Failure>());
  });
}

final class _Catalog implements CatalogRawQuizCandidateReader {
  _Catalog({
    this.hits = const [],
    this.meanings = const {},
    this.headwords = const {},
    this.rankings = const {},
    this.failSearch = false,
    this.failMeanings = false,
    this.failRankings = false,
  });

  final List<CatalogRawQuizCandidateHit> hits;
  final Map<CatalogWordRef, String> meanings;
  final Map<CatalogWordRef, String> headwords;
  final Map<CatalogWordRef, int> rankings;
  final bool failSearch;
  final bool failMeanings;
  final bool failRankings;
  CatalogRawQuizCandidateQuery? query;

  @override
  Future<List<CatalogRawQuizCandidateHit>> searchQuizCandidates(
      CatalogRawQuizCandidateQuery value) async {
    query = value;
    if (failSearch) throw StateError('search failed');
    return hits;
  }

  @override
  Future<Map<CatalogWordRef, String>> getQuizCandidateHeadwords(
          Iterable<CatalogWordRef> words) async =>
      headwords;

  @override
  Future<Map<CatalogWordRef, String>> getQuizCandidateMeanings(
      Iterable<CatalogWordRef> words) async {
    if (failMeanings) throw StateError('meaning failed');
    return meanings;
  }

  @override
  Future<Map<CatalogWordRef, int>> getQuizCandidateRankingMetadata(
      Iterable<CatalogWordRef> words) async {
    if (failRankings) throw StateError('ranking failed');
    return rankings;
  }
}

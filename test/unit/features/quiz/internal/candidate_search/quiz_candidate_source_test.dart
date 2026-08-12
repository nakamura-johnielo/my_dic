import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/internal/candidate_search/quiz_candidate_source.dart';
import 'package:my_dic/features/quiz/port/catalog_gateway.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_query.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);

  test('owns trimmed paging, typed frequency, and Catalog hasMore policy',
      () async {
    final gateway = _Gateway(
      primary: Result.success(
        QuizCatalogPage(
          items: const [
            QuizConjugationCandidate(word: word, headword: 'raw hablar'),
          ],
          hasMore: false,
        ),
      ),
      meanings: {word: const QuizMeaningMetadata('to speak')},
      headwords: {
        word: QuizHeadwordMetadata(headword: 'hablar', frequency: 4),
      },
      rankings: {word: const QuizRankingMetadata(3)},
    );

    final page = (await GatewayQuizCandidateSource(gateway).search(
      const QuizCandidateQuery(text: ' hablar ', page: 2, size: 1),
    ))
        .dataOrNull!;

    expect(gateway.query?.text, 'hablar');
    expect(gateway.query?.page, 2);
    expect(gateway.query?.size, 1);
    expect(page.hasNext, isFalse);
    expect(page.issues, isEmpty);
    expect(page.candidates.single.headword, 'hablar');
    expect(page.candidates.single.meaningText, 'to speak');
    expect(page.candidates.single.rankingNo, 3);
    expect(page.candidates.single.starCount, 4);
  });

  test('keeps enrichment failures non-fatal with raw and null fallbacks',
      () async {
    final failure = DatabaseError(message: 'unavailable');
    final gateway = _Gateway(
      primary: Result.success(
        QuizCatalogPage(
          items: const [
            QuizConjugationCandidate(
              word: word,
              headword: 'raw<sup>(****)</sup>',
            ),
          ],
          hasMore: true,
        ),
      ),
      meaningFailure: failure,
      headwordFailure: failure,
      rankingFailure: failure,
    );

    final page = (await GatewayQuizCandidateSource(gateway).search(
      const QuizCandidateQuery(text: 'hablar', page: 0, size: 30),
    ))
        .dataOrNull!;
    final candidate = page.candidates.single;

    expect(candidate.headword, 'raw<sup>(****)</sup>');
    expect(candidate.meaningText, isNull);
    expect(candidate.rankingNo, isNull);
    expect(candidate.starCount, isNull);
    expect(
      page.issues.map((issue) => issue.source),
      containsAll(['meaning', 'headword', 'ranking']),
    );
  });

  test('keeps primary candidate failure fatal', () async {
    final failure = DatabaseError(message: 'search unavailable');
    final result = await GatewayQuizCandidateSource(
      _Gateway(primary: Result.failure(failure)),
    ).search(const QuizCandidateQuery(text: 'hablar', page: 0, size: 30));

    expect(result.errorOrNull, same(failure));
  });
}

final class _Gateway implements QuizCatalogGateway {
  _Gateway({
    required this.primary,
    this.meanings = const {},
    this.headwords = const {},
    this.rankings = const {},
    this.meaningFailure,
    this.headwordFailure,
    this.rankingFailure,
  });

  final Result<QuizCatalogPage<QuizConjugationCandidate>> primary;
  final Map<CatalogWordRef, QuizMeaningMetadata> meanings;
  final Map<CatalogWordRef, QuizHeadwordMetadata> headwords;
  final Map<CatalogWordRef, QuizRankingMetadata> rankings;
  final DatabaseError? meaningFailure;
  final DatabaseError? headwordFailure;
  final DatabaseError? rankingFailure;
  QuizCatalogQuery? query;

  @override
  Future<Result<QuizCatalogPage<QuizConjugationCandidate>>>
      searchConjugationCandidates(QuizCatalogQuery value) async {
    query = value;
    return primary;
  }

  @override
  Future<Result<Map<CatalogWordRef, QuizMeaningMetadata>>> readMeanings(
    Iterable<CatalogWordRef> words,
  ) async =>
      meaningFailure == null
          ? Result.success(meanings)
          : Result.failure(meaningFailure!);

  @override
  Future<Result<Map<CatalogWordRef, QuizHeadwordMetadata>>>
      readHeadwordMetadata(Iterable<CatalogWordRef> words) async =>
          headwordFailure == null
              ? Result.success(headwords)
              : Result.failure(headwordFailure!);

  @override
  Future<Result<Map<CatalogWordRef, QuizRankingMetadata>>> readRankingMetadata(
          Iterable<CatalogWordRef> words) async =>
      rankingFailure == null
          ? Result.success(rankings)
          : Result.failure(rankingFailure!);
}

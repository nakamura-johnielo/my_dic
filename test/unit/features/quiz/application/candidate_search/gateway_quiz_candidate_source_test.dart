import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/features/quiz/internal/application/candidate_search/gateway_quiz_candidate_source.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);

  test('normalizes the query and projects Catalog look-ahead metadata',
      () async {
    final gateway = _Gateway(
      primary: Result.success(
        QuizCatalogCandidatePage(
          items: const [QuizCatalogCandidate(word: word, headword: 'raw')],
          hasMore: true,
        ),
      ),
      meanings: {word: const QuizCatalogMeaning('to speak')},
      headwords: {
        word: const QuizCatalogHeadword(text: 'hablar', frequency: 4)
      },
      rankings: {word: const QuizCatalogRanking(3)},
    );

    final result = await GatewayQuizCandidateSource(gateway).search(
      QuizCandidateQuery(text: ' hablar ', page: 2, size: 1),
    );
    final page = result.dataOrNull!;

    expect(gateway.query?.text, 'hablar');
    expect(gateway.query?.page, 2);
    expect(gateway.query?.size, 1);
    expect(page.hasNext, isTrue);
    expect(page.issues, isEmpty);
    expect(page.candidates.single.headword, 'hablar');
    expect(page.candidates.single.meaningText, 'to speak');
    expect(page.candidates.single.rankingNo, 3);
    expect(page.candidates.single.starCount, 4);
  });

  test('keeps typed enrichment failures non-fatal and uses raw headword',
      () async {
    final failure = DatabaseError(message: 'unavailable');
    final gateway = _Gateway(
      primary: Result.success(
        QuizCatalogCandidatePage(
          items: const [
            QuizCatalogCandidate(word: word, headword: 'raw hablar'),
          ],
          hasMore: false,
        ),
      ),
      meaningFailure: failure,
      headwordFailure: failure,
      rankingFailure: failure,
    );

    final page = (await GatewayQuizCandidateSource(gateway).search(
      QuizCandidateQuery(text: 'hablar', page: 0, size: 30),
    ))
        .dataOrNull!;

    expect(page.candidates.single.headword, 'raw hablar');
    expect(page.candidates.single.meaningText, isNull);
    expect(page.candidates.single.rankingNo, isNull);
    expect(page.candidates.single.starCount, isNull);
    expect(
      page.issues.map((issue) => issue.source).toSet(),
      {
        QuizCandidateIssueSource.meaning,
        QuizCandidateIssueSource.headword,
        QuizCandidateIssueSource.ranking,
      },
    );
  });

  test('returns primary search failure without enrichment', () async {
    final failure = DatabaseError(message: 'search unavailable');
    final gateway = _Gateway(primary: Result.failure(failure));

    final result = await GatewayQuizCandidateSource(gateway).search(
      QuizCandidateQuery(text: 'hablar', page: 0, size: 30),
    );

    expect(result.errorOrNull, same(failure));
    expect(gateway.enrichmentCalls, 0);
  });
}

final class _Gateway implements QuizCandidateCatalogGateway {
  _Gateway({
    required this.primary,
    this.meanings = const {},
    this.headwords = const {},
    this.rankings = const {},
    this.meaningFailure,
    this.headwordFailure,
    this.rankingFailure,
  });

  final Result<QuizCatalogCandidatePage> primary;
  final Map<CatalogWordRef, QuizCatalogMeaning> meanings;
  final Map<CatalogWordRef, QuizCatalogHeadword> headwords;
  final Map<CatalogWordRef, QuizCatalogRanking> rankings;
  final DatabaseError? meaningFailure;
  final DatabaseError? headwordFailure;
  final DatabaseError? rankingFailure;
  QuizCatalogCandidateQuery? query;
  int enrichmentCalls = 0;

  @override
  Future<Result<QuizCatalogCandidatePage>> searchConjugationCandidates(
    QuizCatalogCandidateQuery value,
  ) async {
    query = value;
    return primary;
  }

  @override
  Future<Result<Map<CatalogWordRef, QuizCatalogMeaning>>> readMeanings(
    Iterable<CatalogWordRef> words,
  ) async {
    enrichmentCalls++;
    return meaningFailure == null
        ? Result.success(meanings)
        : Result.failure(meaningFailure!);
  }

  @override
  Future<Result<Map<CatalogWordRef, QuizCatalogHeadword>>> readHeadwords(
    Iterable<CatalogWordRef> words,
  ) async {
    enrichmentCalls++;
    return headwordFailure == null
        ? Result.success(headwords)
        : Result.failure(headwordFailure!);
  }

  @override
  Future<Result<Map<CatalogWordRef, QuizCatalogRanking>>> readRankings(
    Iterable<CatalogWordRef> words,
  ) async {
    enrichmentCalls++;
    return rankingFailure == null
        ? Result.success(rankings)
        : Result.failure(rankingFailure!);
  }
}

import 'package:my_dic/features/quiz/port/quiz.dart';

/// Quiz-owned candidate discovery and enrichment policy.
///
/// The Catalog gateway deliberately exposes only mechanical reads. This reader
/// owns query normalization, failure severity, fallback values, and the
/// projection into the Quiz-facing candidate page.
final class GatewayQuizCandidateSource implements QuizCandidateReaderPort {
  const GatewayQuizCandidateSource(this._catalog);

  final QuizCandidateCatalogGateway _catalog;

  @override
  Future<Result<QuizCandidatePage>> search(QuizCandidateQuery query) async {
    final primary = await _catalog.searchConjugationCandidates(
      QuizCatalogCandidateQuery(
        text: query.text.trim(),
        page: query.page,
        size: query.size,
      ),
    );

    return switch (primary) {
      Failure(:final error) => Result.failure(error),
      Success(:final data) => _enrich(data),
      _ => throw StateError('Unexpected Quiz candidate search result.'),
    };
  }

  Future<Result<QuizCandidatePage>> _enrich(
    QuizCatalogCandidatePage page,
  ) async {
    final words = page.items.map((candidate) => candidate.word).toList(
          growable: false,
        );
    final issues = <QuizCandidateIssue>[];
    final enrichment = await Future.wait<Object>([
      _capture(
        QuizCandidateIssueSource.meaning,
        () => _catalog.readMeanings(words),
        issues,
      ),
      _capture(
        QuizCandidateIssueSource.headword,
        () => _catalog.readHeadwords(words),
        issues,
      ),
      _capture(
        QuizCandidateIssueSource.ranking,
        () => _catalog.readRankings(words),
        issues,
      ),
    ]);
    final meanings = enrichment[0] as Map<CatalogWordRef, QuizCatalogMeaning>;
    final headwords = enrichment[1] as Map<CatalogWordRef, QuizCatalogHeadword>;
    final rankings = enrichment[2] as Map<CatalogWordRef, QuizCatalogRanking>;

    return Result.success(
      QuizCandidatePage(
        candidates: page.items.map(
          (candidate) {
            final headword = headwords[candidate.word];
            return QuizCandidate(
              word: candidate.word,
              headword: headword?.text ?? candidate.headword,
              meaningText: meanings[candidate.word]?.text,
              rankingNo: rankings[candidate.word]?.rank,
              starCount: headword?.frequency,
            );
          },
        ).toList(growable: false),
        hasNext: page.hasMore,
        issues: issues,
      ),
    );
  }

  Future<Map<CatalogWordRef, T>> _capture<T>(
    QuizCandidateIssueSource source,
    Future<Result<Map<CatalogWordRef, T>>> Function() read,
    List<QuizCandidateIssue> issues,
  ) async {
    final result = await read();
    return switch (result) {
      Success(:final data) => data,
      Failure(:final error) => () {
          issues.add(QuizCandidateIssue(source: source, error: error));
          return <CatalogWordRef, T>{};
        }(),
      _ => throw StateError('Unexpected Quiz candidate enrichment result.'),
    };
  }
}

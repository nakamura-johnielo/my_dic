import 'package:my_dic/features/quiz/port/quiz.dart';

/// Quiz 所有の候補検出・拡充クエリサービス。
///
/// Catalog ゲートウェイは意図的に機械的な読み取りのみを公開する。このサービスはクエリの
/// 正規化、失敗の重大度、フォールバック値、および Quiz 向け候補ページへのプロジェクションを所有する。
final class QuizCandidateQueryService implements QuizCandidateQueryPort {
  const QuizCandidateQueryService(this._catalog);

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

    // いずれかを await する前にすべての拡充読み取りを開始し、異種キャストを使わずに既存の
    // 並列読み取り動作を維持する。
    final meaningsFuture = _capture(
      QuizCandidateIssueSource.meaning,
      () => _catalog.readMeanings(words),
      issues,
    );
    final headwordsFuture = _capture(
      QuizCandidateIssueSource.headword,
      () => _catalog.readHeadwords(words),
      issues,
    );
    final rankingsFuture = _capture(
      QuizCandidateIssueSource.ranking,
      () => _catalog.readRankings(words),
      issues,
    );
    final meanings = await meaningsFuture;
    final headwords = await headwordsFuture;
    final rankings = await rankingsFuture;

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

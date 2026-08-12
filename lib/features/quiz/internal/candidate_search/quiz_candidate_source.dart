import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/port/catalog_gateway.dart';
import 'package:my_dic/features/quiz/port/candidate_source.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_issue.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_page.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_query.dart';

/// Quiz-owned candidate and partial-enrichment policy.
final class GatewayQuizCandidateSource implements QuizCandidateSource {
  const GatewayQuizCandidateSource(this._catalog);

  final QuizCatalogGateway _catalog;

  @override
  Future<Result<QuizCandidatePage>> search(QuizCandidateQuery query) async {
    final primary = await _catalog.searchConjugationCandidates(
      QuizCatalogQuery(
        text: query.text.trim(),
        page: query.page,
        size: query.size,
      ),
    );
    return primary.when(
      failure: Result.failure,
      success: (page) => _enrich(page),
    );
  }

  Future<Result<QuizCandidatePage>> _enrich(
    QuizCatalogPage<QuizConjugationCandidate> page,
  ) async {
    final words = page.items.map((item) => item.word).toList(growable: false);
    final issues = <QuizCandidateIssue>[];
    final values = await Future.wait<Object>([
      _capture('meaning', () => _catalog.readMeanings(words), issues),
      _capture('headword', () => _catalog.readHeadwordMetadata(words), issues),
      _capture('ranking', () => _catalog.readRankingMetadata(words), issues),
    ]);
    final meanings = values[0] as Map<CatalogWordRef, QuizMeaningMetadata>;
    final headwords = values[1] as Map<CatalogWordRef, QuizHeadwordMetadata>;
    final rankings = values[2] as Map<CatalogWordRef, QuizRankingMetadata>;

    return Result.success(
      QuizCandidatePage(
        candidates: page.items.map((item) {
          final headword = headwords[item.word];
          return QuizCandidate(
            word: item.word,
            headword: headword?.headword ?? item.headword,
            meaningText: meanings[item.word]?.text,
            rankingNo: rankings[item.word]?.rankingNo,
            starCount: headword?.frequency,
          );
        }).toList(growable: false),
        hasNext: page.hasMore,
        issues: issues,
      ),
    );
  }

  Future<Map<CatalogWordRef, T>> _capture<T>(
    String source,
    Future<Result<Map<CatalogWordRef, T>>> Function() read,
    List<QuizCandidateIssue> issues,
  ) async {
    final result = await read();
    return result.when(
      success: (values) => values,
      failure: (error) {
        issues.add(QuizCandidateIssue(source: source, error: error));
        return const {};
      },
    );
  }
}

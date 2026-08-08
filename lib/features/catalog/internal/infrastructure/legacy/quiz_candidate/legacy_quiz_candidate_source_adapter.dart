import 'package:my_dic/core/infrastructure/datasource/conjugacion/i_conjugacion_local_datasource.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/legacy/quiz_candidate/legacy_quiz_candidate_enrichment.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/legacy/quiz_candidate/legacy_quiz_candidate_mapper.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_page.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_issue.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_query.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_source.dart';

/// Catalog-side implementation of Quiz's candidate lookup port.
final class LegacyQuizCandidateSourceAdapter implements QuizCandidateSource {
  LegacyQuizCandidateSourceAdapter(this._conjugations, this._enrichment);

  final IConjugacionLocalDataSource _conjugations;
  final LegacyQuizCandidateEnrichment _enrichment;

  @override
  Future<Result<QuizCandidatePage>> search(QuizCandidateQuery query) async {
    try {
      final primary = await _conjugations.getQuizConjugacionByWordWithPage(
        query.text.trim(),
        query.size,
        query.page,
      );
      final ids = primary.map((row) => row.wordId).toList(growable: false);
      final issues = <QuizCandidateIssue>[];
      final enrichment = await _enrichment.load(ids, issues);
      final candidates = primary
          .map(
            (row) => mapLegacyQuizCandidate(
              wordId: row.wordId,
              headword: row.word,
              meaningText: enrichment.meanings[row.wordId],
              rankingNo: enrichment.rankings[row.wordId],
              starCount: enrichment.starCounts[row.wordId],
            ),
          )
          .toList(growable: false);
      return Result.success(QuizCandidatePage(
        candidates: candidates,
        hasNext: candidates.length == query.size,
        issues: issues,
      ));
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'Unable to search quiz candidates.',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }
}

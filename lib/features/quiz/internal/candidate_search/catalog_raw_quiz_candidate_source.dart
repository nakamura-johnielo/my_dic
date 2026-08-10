import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/raw_quiz_candidate_reader.dart';
import 'package:my_dic/features/quiz/port/candidate_source.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_issue.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_page.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_query.dart';

/// Quiz-owned policy over Catalog's raw candidate capability.
final class CatalogRawQuizCandidateSource implements QuizCandidateSource {
  CatalogRawQuizCandidateSource(this._catalog);
  final CatalogRawQuizCandidateReader _catalog;

  @override
  Future<Result<QuizCandidatePage>> search(QuizCandidateQuery query) async {
    try {
      final raw = await _catalog.searchQuizCandidates(
          CatalogRawQuizCandidateQuery(
              text: query.text.trim(), page: query.page, size: query.size));
      final words = raw.map((hit) => hit.word).toList(growable: false);
      final issues = <QuizCandidateIssue>[];
      final meanings = _capture<Map<CatalogWordRef, String>>('meaning',
          () => _catalog.getQuizCandidateMeanings(words), const {}, issues);
      final headwords = _capture<Map<CatalogWordRef, String>>('headword',
          () => _catalog.getQuizCandidateHeadwords(words), const {}, issues);
      final rankings = _capture<Map<CatalogWordRef, int>>(
          'ranking',
          () => _catalog.getQuizCandidateRankingMetadata(words),
          const {},
          issues);
      final enrichment = await Future.wait([meanings, headwords, rankings]);
      final meaningValues = enrichment[0] as Map<CatalogWordRef, String>;
      final headwordValues = enrichment[1] as Map<CatalogWordRef, String>;
      final rankingValues = enrichment[2] as Map<CatalogWordRef, int>;
      return Result.success(QuizCandidatePage(
        candidates: raw
            .map((hit) => QuizCandidate(
                  word: hit.word,
                  headword: headwordValues[hit.word] ?? hit.headword,
                  meaningText: meaningValues[hit.word],
                  rankingNo: rankingValues[hit.word],
                  starCount:
                      _starCount(headwordValues[hit.word] ?? hit.headword),
                ))
            .toList(growable: false),
        hasNext: raw.length == query.size,
        issues: issues,
      ));
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
          message: 'Unable to search quiz candidates.',
          originalError: error,
          stackTrace: stackTrace));
    }
  }

  Future<T> _capture<T>(String source, Future<T> Function() action, T fallback,
      List<QuizCandidateIssue> issues) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      issues.add(QuizCandidateIssue(
          source: source,
          error: DatabaseError(
              message: 'Unable to load quiz candidate enrichment.',
              originalError: error,
              stackTrace: stackTrace)));
      return fallback;
    }
  }
}

int _starCount(String value) =>
    RegExp(r'<sup>\((\*+)\)</sup>').firstMatch(value)?.group(1)?.length ?? 0;

import 'package:my_dic/features/catalog/port/catalog.dart' show CatalogWordRef;
import '../error/quiz_candidate_issue.dart';

final class QuizCandidate {
  const QuizCandidate(
      {required this.word,
      required this.headword,
      this.meaningText,
      this.rankingNo,
      this.starCount});
  final CatalogWordRef word;
  final String headword;
  final String? meaningText;
  final int? rankingNo;
  final int? starCount;
}

/// Candidate result. [hasNext] is the Catalog look-ahead signal, not a count.
final class QuizCandidatePage {
  QuizCandidatePage(
      {required List<QuizCandidate> candidates,
      required this.hasNext,
      List<QuizCandidateIssue> issues = const []})
      : candidates = List.unmodifiable(candidates),
        issues = List.unmodifiable(issues);
  final List<QuizCandidate> candidates;
  final bool hasNext;
  final List<QuizCandidateIssue> issues;
}

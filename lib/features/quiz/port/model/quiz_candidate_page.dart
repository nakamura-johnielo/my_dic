import 'package:my_dic/features/quiz/port/model/quiz_candidate.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_issue.dart';

/// A page of Quiz candidates and any non-fatal enrichment issues.
final class QuizCandidatePage {
  QuizCandidatePage({
    required List<QuizCandidate> candidates,
    required this.hasNext,
    required List<QuizCandidateIssue> issues,
  })  : candidates = List.unmodifiable(candidates),
        issues = List.unmodifiable(issues);

  final List<QuizCandidate> candidates;
  final bool hasNext;
  final List<QuizCandidateIssue> issues;
}

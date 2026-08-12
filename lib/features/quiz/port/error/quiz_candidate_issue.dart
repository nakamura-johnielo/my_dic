import 'package:my_dic/core/shared/errors/app_error.dart';

/// A non-fatal candidate-enrichment concern, kept separate from search failure.
enum QuizCandidateIssueSource { meaning, headword, ranking }

final class QuizCandidateIssue {
  const QuizCandidateIssue({required this.source, required this.error});
  final QuizCandidateIssueSource source;
  final AppError error;
}

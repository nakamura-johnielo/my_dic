import 'package:my_dic/core/shared/errors/app_error.dart';

/// A non-fatal failure while enriching a Quiz candidate page.
final class QuizCandidateIssue {
  const QuizCandidateIssue({required this.source, required this.error});

  /// The failed concern, such as `meaning`, `ranking`, or `starCount`.
  final String source;
  final AppError error;
}

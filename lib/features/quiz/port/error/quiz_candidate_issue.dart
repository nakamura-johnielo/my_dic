import 'package:my_dic/core/shared/errors/app_error.dart';

/// 検索失敗とは分離して保持する、致命的ではない候補拡充上の問題。
enum QuizCandidateIssueSource { meaning, headword, ranking }

final class QuizCandidateIssue {
  const QuizCandidateIssue({required this.source, required this.error});
  final QuizCandidateIssueSource source;
  final AppError error;
}

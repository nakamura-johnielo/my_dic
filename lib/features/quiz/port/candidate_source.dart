import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_page.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_query.dart';

/// Provider-neutral public capability for discovering Quiz candidates.
abstract interface class QuizCandidateSource {
  Future<Result<QuizCandidatePage>> search(QuizCandidateQuery query);
}

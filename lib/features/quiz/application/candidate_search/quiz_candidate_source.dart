import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_page.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_query.dart';

/// Quiz-owned port for paged candidate discovery.
abstract interface class QuizCandidateSource {
  Future<Result<QuizCandidatePage>> search(QuizCandidateQuery query);
}

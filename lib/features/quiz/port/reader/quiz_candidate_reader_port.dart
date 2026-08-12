import 'package:my_dic/core/shared/utils/result.dart';
import '../query/quiz_candidate_query.dart';
import '../result/quiz_candidate_page.dart';

abstract interface class QuizCandidateReaderPort {
  Future<Result<QuizCandidatePage>> search(QuizCandidateQuery query);
}

import 'package:my_dic/core/shared/utils/result.dart';
import 'quiz_game_query.dart';
import '../result/quiz_game_load_outcome.dart';

abstract interface class QuizGameQueryPort {
  Future<Result<QuizGameLoadOutcome>> load(QuizGameQuery query);
}

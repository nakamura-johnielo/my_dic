import 'package:my_dic/core/shared/utils/result.dart';
import '../query/quiz_game_query.dart';
import '../result/quiz_game_load_outcome.dart';

abstract interface class QuizGameReaderPort {
  Future<Result<QuizGameLoadOutcome>> load(QuizGameQuery query);
}

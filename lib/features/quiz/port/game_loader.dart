import 'model/quiz_game_load_result.dart';
import 'model/quiz_game_query.dart';

/// Provider-neutral aggregate capability for loading a Quiz game.
abstract interface class LoadQuizGame {
  Future<QuizGameLoadResult> load(QuizGameQuery query);
}

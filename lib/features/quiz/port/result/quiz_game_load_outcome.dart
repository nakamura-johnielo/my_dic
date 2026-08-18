import '../error/quiz_game_load_error.dart';
import '../model/quiz_conjugation.dart';

final class QuizGameData {
  const QuizGameData(
      {required this.conjugation,
      required this.englishConjugation,
      required this.promptGuide,
      required this.beConjugation});
  final QuizConjugation conjugation;
  final QuizEnglishConjugation englishConjugation;
  final QuizEnglishPromptGuide promptGuide;
  final QuizBeConjugation beConjugation;
}

sealed class QuizGameLoadOutcome {
  const QuizGameLoadOutcome();
  const factory QuizGameLoadOutcome.ready(QuizGameData game) = QuizGameReady;
  const factory QuizGameLoadOutcome.primaryNotFound() = QuizGamePrimaryNotFound;
  const factory QuizGameLoadOutcome.noConjugation() = QuizGameNoConjugation;
  const factory QuizGameLoadOutcome.failure(QuizGameLoadError error) =
      QuizGameLoadFailure;
}

final class QuizGameReady extends QuizGameLoadOutcome {
  const QuizGameReady(this.game);
  final QuizGameData game;
}

final class QuizGamePrimaryNotFound extends QuizGameLoadOutcome {
  const QuizGamePrimaryNotFound();
}

final class QuizGameNoConjugation extends QuizGameLoadOutcome {
  const QuizGameNoConjugation();
}

final class QuizGameLoadFailure extends QuizGameLoadOutcome {
  const QuizGameLoadFailure(this.error);
  final QuizGameLoadError error;
}

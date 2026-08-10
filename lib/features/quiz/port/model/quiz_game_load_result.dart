import 'quiz_game_load_source.dart';
import 'quiz_game_data.dart';

/// Result of loading all inputs needed by a Quiz game.
sealed class QuizGameLoadResult {
  const QuizGameLoadResult();

  const factory QuizGameLoadResult.ready(QuizGameData game) = QuizGameReady;
  const factory QuizGameLoadResult.notFound() = QuizGameNotFound;
  const factory QuizGameLoadResult.noConjugation() = QuizGameNoConjugation;
  const factory QuizGameLoadResult.failure({
    required QuizGameLoadSource source,
    required Object error,
  }) = QuizGameLoadFailure;
}

/// A successfully assembled game.
///
final class QuizGameReady extends QuizGameLoadResult {
  const QuizGameReady(this.game);

  final QuizGameData game;

  @override
  bool operator ==(Object other) =>
      other is QuizGameReady && game == other.game;

  @override
  int get hashCode => game.hashCode;
}

/// The requested word no longer exists in the game source.
final class QuizGameNotFound extends QuizGameLoadResult {
  const QuizGameNotFound();

  @override
  bool operator ==(Object other) => other is QuizGameNotFound;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// The word exists but cannot produce a conjugation quiz.
final class QuizGameNoConjugation extends QuizGameLoadResult {
  const QuizGameNoConjugation();

  @override
  bool operator ==(Object other) => other is QuizGameNoConjugation;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// A load failure together with the input that failed.
final class QuizGameLoadFailure extends QuizGameLoadResult {
  const QuizGameLoadFailure({required this.source, required this.error});

  final QuizGameLoadSource source;
  final Object error;

  @override
  bool operator ==(Object other) =>
      other is QuizGameLoadFailure &&
      source == other.source &&
      error == other.error;

  @override
  int get hashCode => Object.hash(source, error);
}

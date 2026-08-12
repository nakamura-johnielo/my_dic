import 'package:my_dic/core/shared/errors/app_error.dart';

/// The dependency whose typed Quiz load error was returned.
enum QuizGameLoadSource {
  primaryCatalog,
  catalogConjugation,
  englishConjugation,
  englishGuide,
  beConjugation
}

/// Quiz vocabulary for failures while assembling a game.
final class QuizGameLoadError extends AppError {
  const QuizGameLoadError(
      {required this.source, required super.message, super.code})
      : super(originalError: null, stackTrace: null);

  final QuizGameLoadSource source;
}

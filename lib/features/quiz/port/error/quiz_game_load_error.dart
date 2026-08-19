import 'package:my_dic/core/shared/errors/app_error.dart';

/// 型付き Quiz 読み込みエラーを返した依存関係。
enum QuizGameLoadSource {
  primaryCatalog,
  catalogConjugation,
  englishConjugation,
  englishGuide,
  beConjugation
}

/// ゲームの組み立て中に発生する失敗を表す Quiz の語彙。
final class QuizGameLoadError extends AppError {
  const QuizGameLoadError(
      {required this.source, required super.message, super.code})
      : super(originalError: null, stackTrace: null);

  final QuizGameLoadSource source;
}

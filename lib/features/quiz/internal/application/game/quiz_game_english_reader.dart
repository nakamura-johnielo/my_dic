import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/port/model/quiz_conjugation.dart';

/// Owner-side seam for the English conjugation table.
///
/// The table's row and fallback mapping remain infrastructure concerns.
abstract interface class QuizGameEnglishReader {
  Future<Result<QuizEnglishConjugation>> readEnglishConjugation(int wordId);
}

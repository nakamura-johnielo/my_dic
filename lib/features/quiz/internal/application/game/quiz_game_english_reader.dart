import 'package:my_dic/core/shared/utils/result.dart';

/// Owner-side seam for the English conjugation table.
///
/// The table's wire keys remain an infrastructure concern; the application
/// service projects this raw value into the public typed model.
abstract interface class QuizGameEnglishReader {
  Future<Result<Map<String, String>>> readEnglishConjugation(int wordId);
}

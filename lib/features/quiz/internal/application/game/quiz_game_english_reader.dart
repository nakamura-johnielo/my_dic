import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/port/model/quiz_conjugation.dart';

/// 英語活用形テーブルに対する所有側の境界。
///
/// テーブルの行およびフォールバックのマッピングは、インフラストラクチャの関心事のままとする。
abstract interface class QuizGameEnglishReader {
  Future<Result<QuizEnglishConjugation>> readEnglishConjugation(int wordId);
}

import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/port/model/quiz_conjugation.dart';

/// 2 つのバンドル済み Quiz 問題文アセットに対する所有側の境界。
abstract interface class QuizGameAssetReader {
  Future<Result<QuizEnglishPromptGuide>> readEnglishPromptGuide();

  Future<Result<QuizBeConjugation>> readBeConjugation();
}

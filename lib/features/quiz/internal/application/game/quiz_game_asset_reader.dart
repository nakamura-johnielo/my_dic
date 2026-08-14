import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/port/model/quiz_conjugation.dart';

/// Owner-side seam for the two bundled Quiz prompt assets.
abstract interface class QuizGameAssetReader {
  Future<Result<QuizEnglishPromptGuide>> readEnglishPromptGuide();

  Future<Result<QuizBeConjugation>> readBeConjugation();
}

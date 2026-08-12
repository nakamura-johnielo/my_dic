import 'package:my_dic/core/shared/utils/result.dart';

/// Owner-side seam for the two bundled Quiz prompt assets.
abstract interface class QuizGameAssetReader {
  Future<Result<Map<String, String>>> readEnglishPromptGuide();

  Future<Result<Map<String, Map<String, String>>>> readBeConjugation();
}

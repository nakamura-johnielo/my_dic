import 'package:my_dic/core/shared/utils/result.dart';

abstract class IFetchEnglishConjSubUsecase {
  Future<Result<Map<String, String>>> getConjEnglishGuide();
  Future<Result<Map<String, Map<String, String>>>> getConjOfBe();
}

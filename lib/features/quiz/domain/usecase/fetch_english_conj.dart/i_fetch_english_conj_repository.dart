import 'package:my_dic/core/shared/utils/result.dart';

abstract class IEsEnConjugacionRepository {
  Future<Result<Map<String, String>>> getEnglishConjById(int id);
}

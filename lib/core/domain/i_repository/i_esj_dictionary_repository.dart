import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';

abstract class IEsjDictionaryRepository {
  Future<Result<List<EspJpnDictionary>>> getDictionaryByWordId(int id);
}

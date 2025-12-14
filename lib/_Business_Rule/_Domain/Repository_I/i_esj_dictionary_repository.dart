import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';

abstract class IEsjDictionaryRepository {
  Future<List<EsjDictionary>> getDictionaryByWordId(int id);
}

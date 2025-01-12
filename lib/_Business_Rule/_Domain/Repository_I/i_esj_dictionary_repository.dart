import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/esj_dictionary.dart';

abstract class IEsjDictionaryRepository {
  Future<List<EsjDictionary>> getDictionaryByWordId(int id);
}

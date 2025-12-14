import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';

class FetchDictionaryOutputData {
  int wordId;
  List<EsjDictionary> dictionary;
  FetchDictionaryOutputData(this.wordId, this.dictionary);
}

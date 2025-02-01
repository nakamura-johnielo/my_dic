import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/esj_dictionary.dart';

class FetchDictionaryOutputData {
  int wordId;
  List<EsjDictionary> dictionary;
  FetchDictionaryOutputData(this.wordId, this.dictionary);
}

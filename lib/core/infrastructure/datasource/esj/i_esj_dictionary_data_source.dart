import 'package:my_dic/core/infrastructure/datasource/esj/esj_dictionary_dataset.dart';

abstract class IEsjDictionaryLocalDataSource {
  Future<List<EsjDictionaryDataSet>> getDictionaryByWordId(int wordId);

  Future<String?> getHeadwordById(int id);
  Future<String?> getSimpleMeaningById(int id);

  // wordId based (used for search metadata)
  Future<String?> getFirstHeadwordByWordId(int wordId);
  Future<String?> getFirstContentByWordId(int wordId);
  Future<Map<int, String>> getFirstHeadwordsByWordIds(List<int> wordIds);
  Future<Map<int, String>> getFirstContentsByWordIds(List<int> wordIds);
}

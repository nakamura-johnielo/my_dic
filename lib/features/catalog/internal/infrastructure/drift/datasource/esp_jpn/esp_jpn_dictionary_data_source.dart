import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_dataset.dart';

abstract class IEsjDictionaryLocalDataSource {
  Future<List<EspJpnDictionaryDataSet>> getDictionaryByWordId(int wordId);
  Future<String?> getHeadwordById(int id);
  Future<String?> getSimpleMeaningById(int id);
  Future<String?> getFirstHeadwordByWordId(int wordId);
  Future<String?> getFirstContentByWordId(int wordId);
  Future<Map<int, String>> getFirstHeadwordsByWordIds(List<int> wordIds);
  Future<Map<int, String>> getFirstContentsByWordIds(List<int> wordIds);
}

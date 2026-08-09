import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_dictionary_dataset.dart';

abstract class IJpnEspDictionaryLocalDataSource {
  Future<List<JpnEspDictionaryDataSet>> getDictionaryByWordId(int wordId);
  Future<Map<int, String>> getContentsByWordIds(List<int> wordIds);
}

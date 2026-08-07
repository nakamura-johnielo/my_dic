import 'package:my_dic/core/infrastructure/datasource/jpn_esp/jpn_esp_dictionary_dataset.dart';

abstract class IJpnEspDictionaryLocalDataSource {
  Future<List<JpnEspDictionaryDataSet>> getDictionaryByWordId(int wordId);
  Future<Map<int, String>> getContentsByWordIds(List<int> wordIds);
}

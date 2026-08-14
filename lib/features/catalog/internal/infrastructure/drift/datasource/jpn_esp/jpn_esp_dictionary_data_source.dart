import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_dictionary_dataset.dart';

abstract interface class JpnEspDictionaryDataSource {
  Future<List<JpnEspDictionaryDataSet>> getDictionaryByWordId(int wordId);
}

import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_dataset.dart';

abstract interface class EspJpnDictionaryDataSource {
  Future<List<EspJpnDictionaryDataSet>> getDictionaryByWordId(int wordId);
}

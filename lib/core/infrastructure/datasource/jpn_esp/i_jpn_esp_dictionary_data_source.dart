import 'package:my_dic/core/infrastructure/datasource/jpn_esp/jpn_esp_dictionary_dataset.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_repository_input_data.dart';

abstract class IJpnEspDictionaryLocalDataSource {
  Future<List<JpnEspDictionaryDataSet>> getDictionaryByWordId(FetchJpnEspDictionaryRepositoryInputData input);
}

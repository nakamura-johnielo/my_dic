import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_input_data.dart';

abstract class IFetchJpnEspDictionaryUseCase {
  Future<List<JpnEspDictionary>> execute(FetchJpnEspDictionaryInputData input);
}

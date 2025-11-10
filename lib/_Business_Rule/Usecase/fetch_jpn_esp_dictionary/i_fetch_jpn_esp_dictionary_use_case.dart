import 'package:my_dic/_Business_Rule/Usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_input_data.dart';

abstract class IFetchJpnEspDictionaryUseCase {
  Future<void> execute(FetchJpnEspDictionaryInputData input);
}

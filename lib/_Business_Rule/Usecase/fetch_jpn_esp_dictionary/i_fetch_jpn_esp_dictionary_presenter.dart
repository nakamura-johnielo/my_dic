import 'package:my_dic/_Business_Rule/Usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_output_data.dart';

abstract class IFetchJpnEspDictionaryPresenter {
  void executeFetch(FetchJpnEspDictionaryOutputData input);
}

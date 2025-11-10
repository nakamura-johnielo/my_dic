import 'package:my_dic/_Business_Rule/Usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/jpn_esp/jpn_esp_dictionary.dart';

abstract class IJpnEspDictionaryRepository {
  Future<List<JpnEspDictionary>> getDictionaryByWordId(
      FetchJpnEspDictionaryRepositoryInputData input);
  //Future<String> getBySomething(FetchJpnEspDictionaryRepositoryInputData input);
}

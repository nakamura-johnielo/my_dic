import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_input_data.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_use_case.dart';

class JpnEspWordPageController {
  final IFetchJpnEspDictionaryUseCase _fetchDictionaryUseCase;

  JpnEspWordPageController(this._fetchDictionaryUseCase);

  void fetchDictionaryById(int wordId) async {
    FetchJpnEspDictionaryInputData input =
        FetchJpnEspDictionaryInputData(wordId);
    await _fetchDictionaryUseCase.execute(input);
  }
}

import 'package:my_dic/core/application/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_input_data.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/shared/utils/result.dart';

abstract interface class IFetchJpnEspDictionaryUseCase {
  Future<Result<List<JpnEspDictionary>>> execute(
    FetchJpnEspDictionaryInputData input,
  );
}

import 'package:my_dic/core/application/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_use_case.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/core/shared/utils/result.dart';

class FetchJpnEspDictionaryInteractor implements IFetchJpnEspDictionaryUseCase {
  final IJpnEspDictionaryRepository _repository;

  FetchJpnEspDictionaryInteractor(this._repository);

  @override
  Future<Result<List<JpnEspDictionary>>> execute(
    FetchJpnEspDictionaryInputData input,
  ) =>
      _repository.getDictionaryByWordId(input.id);
}

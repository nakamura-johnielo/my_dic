import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_input_data.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_use_case.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_repository_input_data.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';

class FetchJpnEspDictionaryInteractor implements IFetchJpnEspDictionaryUseCase {
  // final IFetchJpnEspDictionaryPresenter _fetchJpnEspDictionaryPresenterImpl;
  final IJpnEspDictionaryRepository _driftJpnEspDictionaryRepository;

  FetchJpnEspDictionaryInteractor(
      this._driftJpnEspDictionaryRepository);

  @override
  Future<Result<List<JpnEspDictionary>>> execute(
      FetchJpnEspDictionaryInputData input) async {
    FetchJpnEspDictionaryRepositoryInputData repositoryInput =
        FetchJpnEspDictionaryRepositoryInputData(input.id);

    // リポジトリが既にResult<T>を返すのでそのまま返す
    return await _driftJpnEspDictionaryRepository
        .getDictionaryByWordId(repositoryInput);

    // FetchJpnEspDictionaryOutputData output =
    //     FetchJpnEspDictionaryOutputData(input.id, res);

    // _fetchJpnEspDictionaryPresenterImpl.executeFetch(output);
  }
}

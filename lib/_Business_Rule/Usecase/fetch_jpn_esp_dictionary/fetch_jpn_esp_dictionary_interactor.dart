import 'package:my_dic/_Business_Rule/Usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_repository_input_data.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_jpn_esp_dictionary_repository.dart';

class FetchJpnEspDictionaryInteractor implements IFetchJpnEspDictionaryUseCase {
  final IFetchJpnEspDictionaryPresenter _fetchJpnEspDictionaryPresenterImpl;
  final IJpnEspDictionaryRepository _driftJpnEspDictionaryRepository;

  FetchJpnEspDictionaryInteractor(this._fetchJpnEspDictionaryPresenterImpl,
      this._driftJpnEspDictionaryRepository);

  @override
  Future<void> execute(FetchJpnEspDictionaryInputData input) async {
    FetchJpnEspDictionaryRepositoryInputData repositoryInput =
        FetchJpnEspDictionaryRepositoryInputData(input.id);

    List<JpnEspDictionary> res = await _driftJpnEspDictionaryRepository
        .getDictionaryByWordId(repositoryInput);

    FetchJpnEspDictionaryOutputData output =
        FetchJpnEspDictionaryOutputData(input.id, res);

    _fetchJpnEspDictionaryPresenterImpl.executeFetch(output);
  }
}

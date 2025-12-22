import 'package:my_dic/core/domain/usecase/fetch_dictionary/fetch_dictionary_input_data.dart';
import 'package:my_dic/core/domain/usecase/fetch_dictionary/i_fetch_dictionary_use_case.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_dictionary_repository.dart';

class FetchEspJpnDictionaryInteractor implements IFetchEspJpnDictionaryUseCase {
  // final IFetchDictionaryPresenter _dictionaryFragmentPresenterImpl;
  final IEsjDictionaryRepository _esjDictionaryRepository;

  FetchEspJpnDictionaryInteractor( this._esjDictionaryRepository);

  @override
  Future<List<EspJpnDictionary>> execute(FetchDictionaryInputData input) async {
    //FetchDictionaryRepositoryInputData repositoryInput=FetchDictionaryRepositoryInputData();
    List<EspJpnDictionary> data =
        await _esjDictionaryRepository.getDictionaryByWordId(input.wordId);
    // FetchDictionaryOutputData output =
    //     FetchDictionaryOutputData(input.wordId, data);
    // _dictionaryFragmentPresenterImpl.execute(output);
    return data;
  }
}

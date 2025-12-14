import 'package:my_dic/_Business_Rule/Usecase/fetch_dictionary/fetch_dictionary_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_dictionary/i_fetch_dictionary_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_dictionary/fetch_dictionary_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_dictionary/i_fetch_dictionary_presenter.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_dictionary_repository.dart';

class FetchDictionaryInteractor implements IFetchDictionaryUseCase {
  final IFetchDictionaryPresenter _dictionaryFragmentPresenterImpl;
  final IEsjDictionaryRepository _esjDictionaryRepository;

  FetchDictionaryInteractor(
      this._dictionaryFragmentPresenterImpl, this._esjDictionaryRepository);

  @override
  Future<void> execute(FetchDictionaryInputData input) async {
    //FetchDictionaryRepositoryInputData repositoryInput=FetchDictionaryRepositoryInputData();
    List<EsjDictionary> data =
        await _esjDictionaryRepository.getDictionaryByWordId(input.wordId);
    FetchDictionaryOutputData output =
        FetchDictionaryOutputData(input.wordId, data);
    _dictionaryFragmentPresenterImpl.execute(output);
  }
}

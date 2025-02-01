import 'package:my_dic/_Business_Rule/Usecase/fetch_dictionary/fetch_dictionary_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_dictionary/i_fetch_dictionary_presenter.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/main_view_model.dart';

class DictionaryFragmentPresenterImpl implements IFetchDictionaryPresenter {
  final MainViewModel _mainViewModel;

  DictionaryFragmentPresenterImpl(this._mainViewModel);

  @override
  void execute(FetchDictionaryOutputData input) {
    _mainViewModel.setDictionaryCache(input.wordId, input.dictionary);
  }
}

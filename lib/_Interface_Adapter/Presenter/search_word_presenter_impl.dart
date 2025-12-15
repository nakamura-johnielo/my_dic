import 'package:my_dic/features/search/domain/usecase/search_word/i_search_word_presenter.dart';
import 'package:my_dic/features/search/domain/usecase/search_word/search_word_output_data.dart';
import 'package:my_dic/features/search/presentation/view_model/search_view_model.dart';
//import 'package:my_dic/_Interface_Adapter/ViewModel/search_word_view_model.dart';

class SearchWordPresenterImpl implements ISearchWordPresenter {
  final SearchViewModel _searchViewModel;
  SearchWordPresenterImpl(this._searchViewModel);

  @override
  void executInicialEspJpn(SearchWordOutputData input) {
    _searchViewModel.inicializeEspJpnItems(input.wordList);
  }

  @override
  void executNextEspJpn(SearchWordOutputData input) {
    _searchViewModel.addEspJpnItems(input.wordList);
  }

  @override
  void executeInicialJpnEsp(SearchJpnEspWordOutputData input) {
    _searchViewModel.inicializeJpnEspItems(input.wordList);
  }

  @override
  void executeNextJpnEsp(SearchJpnEspWordOutputData input) {
    _searchViewModel.addJpnEspItems(input.wordList);
  }

  @override
  void executInicialConjugacion(SearchConjugacionOutputData input) {
    _searchViewModel.inicializeConjugacionItems(input.wordList);
  }

  @override
  void executNextConjugacion(SearchConjugacionOutputData input) {
    _searchViewModel.addConjugacionItems(input.wordList);
  }
}

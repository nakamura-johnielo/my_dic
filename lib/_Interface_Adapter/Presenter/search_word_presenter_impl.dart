import 'package:my_dic/_Business_Rule/Usecase/search_word/i_search_word_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_output_data.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/search_view_model.dart';
//import 'package:my_dic/_Interface_Adapter/ViewModel/search_word_view_model.dart';

class SearchWordPresenterImpl implements ISearchWordPresenter {
  final SearchViewModel _searchViewModel;
  SearchWordPresenterImpl(this._searchViewModel);

  @override
  void execute(SearchWordOutputData input) {
    _searchViewModel.filteredItems = input.wordList;
  }
}

/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_output_data.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/i_search_word_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_output_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/word.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_word_repository.dart';

final searchViewModelProvider =
    ChangeNotifierProvider((ref) => DI<SearchViewModel>());

class SearchViewModel extends ChangeNotifier {
  final ExploreController _exploreController;
  SearchViewModel(this._exploreController);

  List<MyResult> _filteredItems = [];
  String _query = "";

  String get query => _query;
  set query(String value) {
    _query = value;
    _fireController();
    notifyListeners();
  }

  List<MyResult> get filteredItems => _filteredItems;
  set filteredItems(List<MyResult> values) {
    _filteredItems = values;
    notifyListeners();
  }

  Future<void> _fireController() async {
    if (_query.isNotEmpty) {
      _exploreController.search(_query);
    }
  }
}

//controller
//flutter/material.dart have searchcontroller class
class ExploreController {
  SearchInteractor _searchInteractor;
  ExploreController(this._searchInteractor);

  void search(String query) {
    _searchInteractor.execute(query);
  }
}

//usecase
class SearchInteractor {
  MyRepository _myRepository;
  SearchPresenter _presenter;
  SearchInteractor(this._myRepository, this._presenter);

  void execute(String input) async {
    List<MyResult> results = await _myRepository.getMyResults(input);
    _presenter.execute(results);
  }
}

//presenter
class SearchPresenter {
  SearchViewModel _viewModel;
  SearchPresenter(this._viewModel);

  void execute(List<MyResult> input) async {
    _viewModel.filteredItems = input;
  }
}

final DI = GetIt.instance;

void setupLocator() {
  //repository
  DI.registerFactory<MyRepository>(() => MyRepository());

  //viewmodel
  DI.registerFactory<SearchViewModel>(
      () => SearchViewModel(DI<ExploreController>()));

  //controller
  DI.registerFactory<ExploreController>(
      () => ExploreController(DI<SearchInteractor>()));

  //usecase
  DI.registerFactory<SearchInteractor>(
      () => SearchInteractor(DI<MyRepository>(), DI<SearchPresenter>()));

  //presenter
  DI.registerFactory<SearchPresenter>(() => SearchPresenter());
}
 */

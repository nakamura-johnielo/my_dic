import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/fetch_conjugation_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/i_fetch_conjugation_presenter.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/main_view_model.dart';

class ConjugacionFragmentPresenterImpl implements IFetchConjugationPresenter {
  final MainViewModel _mainViewModel;

  ConjugacionFragmentPresenterImpl(this._mainViewModel);

  @override
  void execute(FetchConjugationOutputData input) {
    _mainViewModel.setConjugacionCache(input.wordId, input.conjugacions);
  }
}

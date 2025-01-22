import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/i_add_filter_presenter.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/ranking_view_model.dart';

class AddFilterPresenterImpl implements IAddFilterPresenter {
  final RankingViewModel _rankingViewModel;
  AddFilterPresenterImpl(this._rankingViewModel);
  @override
  void execute(AddFilterOutputData input) {
    _rankingViewModel.addPartOfSpeechFilter(input.filter);
  }
}

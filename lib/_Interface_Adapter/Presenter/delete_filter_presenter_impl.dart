import 'package:my_dic/_Business_Rule/Usecase/delete_filter/delete_filter_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/i_delete_filter_presenter.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/ranking_view_model.dart';

class DeleteFilterPresenterImpl implements IDeleteFilterPresenter {
  final RankingViewModel _rankingViewModel;
  DeleteFilterPresenterImpl(this._rankingViewModel);
  @override
  void execute(DeleteFilterOutputData input) {
    _rankingViewModel.deletePartOfSpeechFilter(input.filter);
  }
}

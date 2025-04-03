import 'package:my_dic/_Business_Rule/Usecase/load_my_word/load_my_word_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_my_word/i_load_my_word_presenter.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/my_word_view_model.dart';

class LoadMyWordPresenterImpl implements ILoadMyWordPresenter {
  final MyWordViewModel _myWordViewModel;

  LoadMyWordPresenterImpl(this._myWordViewModel);

  @override
  void execute(LoadMyWordOutputData input) {
    _myWordViewModel.addItemsInHead(input.myWordList);
    //_myWordViewModel.item = input.myWordList;
  }
}

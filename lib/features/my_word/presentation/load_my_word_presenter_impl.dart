import 'package:my_dic/features/my_word/domain/usecase/load_my_word/load_my_word_output_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/load_my_word/i_load_my_word_presenter.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_view_model.dart';

class LoadMyWordPresenterImpl implements ILoadMyWordPresenter {
  final MyWordViewModel _myWordViewModel;

  LoadMyWordPresenterImpl(this._myWordViewModel);

  @override
  void execute(LoadMyWordOutputData input) {
    _myWordViewModel.addItemsInHead(input.myWordList);
    //_myWordViewModel.items = input.myWordList;
  }
}

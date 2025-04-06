import 'package:my_dic/_Business_Rule/Usecase/my_word/delete/delete_my_word/delete_my_word_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/i_my_word_fragment_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/register_my_word/register_my_word_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/update/update_my_word/update_my_word_output_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/my_word.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/my_word_view_model.dart';

class MyWordFragmentPresenterImpl implements IMyWordFragmentPresenter {
  final MyWordViewModel _myWordViewModel;
  MyWordFragmentPresenterImpl(this._myWordViewModel);
  @override
  void completeRegistration(RegisterMyWordOutputData input) {
    _myWordViewModel.addItemInHead(MyWord(
        wordId: input.myWordId,
        word: input.headword,
        contents: input.description));
  }

  @override
  void completeUpdate(UpdateMyWordOutputData input) {
    MyWord myWord = MyWord(
        wordId: input.myWordId,
        word: input.headword,
        contents: input.description);
    _myWordViewModel.replaceItem(myWord, input.index);
  }

  @override
  void completeDelete(DeleteMyWordOutputData input) {
    _myWordViewModel.deleteItemWithIndex(input.index);
  }
}

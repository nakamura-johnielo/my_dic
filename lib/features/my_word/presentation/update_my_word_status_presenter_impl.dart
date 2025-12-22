import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/i_update_my_word_status_presenter.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/update_my_word_status_output_data.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_view_model.dart';

class UpdateMyWordStatusPresenterImpl implements IUpdateMyWordStatusPresenter {
  final MyWordViewModel _myWordViewModel;
  UpdateMyWordStatusPresenterImpl(this._myWordViewModel);

  @override
  void execute(UpdateMyWordStatusOutputData input) {
    /* _rankingViewModel.updateWordStatus(
        index: input.index,
        isBookmarked: input.isBookmarked,
        isLearned: input.isLearned,
        hasNote: input.hasNote);
  } */
    _myWordViewModel.updateAllWordStatus(
      wordId: input.wordId,
      isBookmarked: input.isBookmarked,
      isLearned: input.isLearned,
    );
  }
}

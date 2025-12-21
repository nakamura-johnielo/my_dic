import 'package:my_dic/core/domain/usecase/update_status/update_status_output_data.dart';
import 'package:my_dic/core/domain/usecase/update_status/i_update_status_presenter.dart';
import 'package:my_dic/features/ranking/presentation/view_model/ranking_view_model.dart';

class UpdateStatusPresenterImpl implements IUpdateStatusPresenter {
  final RankingViewModel _rankingViewModel;
  UpdateStatusPresenterImpl(this._rankingViewModel);

  @override
  void execute(UpdateStatusOutputData input) {
    /* _rankingViewModel.updateWordStatus(
        index: input.index,
        isBookmarked: input.isBookmarked,
        isLearned: input.isLearned,
        hasNote: input.hasNote);
  } */
    _rankingViewModel.updateAllWordStatus(
        wordId: input.wordId,
        isBookmarked: input.isBookmarked,
        isLearned: input.isLearned,
        hasNote: input.hasNote);
  }
}

import 'package:my_dic/core/common/enums/feature_tag.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/update_my_word_status_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/update_my_word_status_output_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/i_update_my_word_status_presenter.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/update_my_word_status_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/utils/date_handler.dart';

class UpdateMyWordStatusInteractor implements IUpdateMyWordStatusUseCase {
  final IUpdateMyWordStatusPresenter _updateMyWordStatusPresenterImpl;
  final IMyWordRepository _driftMyWordRepository;

  UpdateMyWordStatusInteractor(
      this._updateMyWordStatusPresenterImpl, this._driftMyWordRepository);

  @override
  void execute(UpdateMyWordStatusInputData input) {
    String dateTime = getNowUTCDateHour();
    UpdateMyWordStatusRepositoryInputData repositoryInput =
        UpdateMyWordStatusRepositoryInputData(
            input.wordId, input.status, dateTime);

    _driftMyWordRepository.updateStatus(repositoryInput);

    UpdateMyWordStatusOutputData output = UpdateMyWordStatusOutputData(
      index: input.index,
      wordId: input.wordId,
      isBookmarked: input.status.contains(FeatureTag.isBookmarked),
      isLearned: input.status.contains(FeatureTag.isLearned),
      hasNote: input.status.contains(FeatureTag.hasNote),
    );

    _updateMyWordStatusPresenterImpl.execute(output);
  }
}

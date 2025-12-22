import 'package:my_dic/core/common/enums/feature_tag.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_input_data.dart';
import 'package:my_dic/core/domain/usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_output_data.dart';
import 'package:my_dic/core/domain/usecase/update_status/i_update_status_presenter.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_word_repository.dart';
import 'package:my_dic/utils/date_handler.dart';

class UpdateStatusInteractor implements IUpdateStatusUseCase {
   final IUpdateStatusPresenter _updateStatusPresenterImpl;
  final IEsjWordRepository _driftEsjWordRepository;

  UpdateStatusInteractor(
       this._updateStatusPresenterImpl, 
      this._driftEsjWordRepository);
  @override
  void execute(UpdateStatusInputData input) {
    String dateTime = getNowUTCDateHour();
    UpdateStatusRepositoryInputData repositoryInput =
        UpdateStatusRepositoryInputData(input.wordId, input.status, dateTime);
    _driftEsjWordRepository.updateStatus(repositoryInput);

    UpdateStatusOutputData output = UpdateStatusOutputData(
      index: input.index,
      wordId: input.wordId,
      isBookmarked: input.status.contains(FeatureTag.isBookmarked),
      isLearned: input.status.contains(FeatureTag.isLearned),
      hasNote: input.status.contains(FeatureTag.hasNote),
    );
     _updateStatusPresenterImpl.execute(output);
  }
}

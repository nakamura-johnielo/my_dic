import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_status/update_status_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_status/update_status_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_status/i_update_status_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_word_repository.dart';

class UpdateStatusInteractor implements IUpdateStatusUseCase {
  final IUpdateStatusPresenter _updateStatusPresenterImpl;
  final IEsjWordRepository _driftEsjWordRepository;

  UpdateStatusInteractor(
      this._updateStatusPresenterImpl, this._driftEsjWordRepository);

  @override
  void execute(UpdateStatusInputData input) {
    UpdateStatusRepositoryInputData repositoryInput =
        UpdateStatusRepositoryInputData(input.wordId, input.status);
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

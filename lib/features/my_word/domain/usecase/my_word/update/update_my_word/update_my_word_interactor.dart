import 'package:my_dic/features/my_word/domain/usecase/my_word/i_my_word_fragment_presenter.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/i_update_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_output_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/utils/date_handler.dart';

class UpdateMyWordInteractor implements IUpdateMyWordUseCase {
  final IMyWordFragmentPresenter _myWordFragmentPresenterImpl;
  final IMyWordRepository _driftMyWordRepository;

  UpdateMyWordInteractor(
      this._myWordFragmentPresenterImpl, this._driftMyWordRepository);

  @override
  Future<bool> execute(UpdateMyWordInputData input) async {
    try {
      String dateTime = getNowUTCDateHour();

      UpdateMyWordRepositoryInputData repositoryInput =
          UpdateMyWordRepositoryInputData(
              input.myWordId, input.headword, input.description, dateTime);

      bool res = await _driftMyWordRepository.updateWord(repositoryInput);

      UpdateMyWordOutputData output = UpdateMyWordOutputData(
          input.myWordId, input.headword, input.description, input.index);
      _myWordFragmentPresenterImpl.completeUpdate(output);
      return res;
    } catch (e) {
      return false;
    }
  }
}

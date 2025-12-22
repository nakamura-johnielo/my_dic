import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/i_delete_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_output_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/i_my_word_fragment_presenter.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/utils/date_handler.dart';

class DeleteMyWordInteractor implements IDeleteMyWordUseCase {
  final IMyWordFragmentPresenter _myWordPresenterImpl;
  final IMyWordRepository _driftMyWordRepository;

  DeleteMyWordInteractor(
      this._myWordPresenterImpl, this._driftMyWordRepository);

  @override
  Future<bool> execute(DeleteMyWordInputData input) async {
    try {
      String dateTime = getNowUTCDateHour();

      DeleteMyWordRepositoryInputData repositoryInput =
          DeleteMyWordRepositoryInputData(input.id, dateTime);
      bool res = await _driftMyWordRepository.deleteWord(repositoryInput);

      DeleteMyWordOutputData output = DeleteMyWordOutputData(input.index);
      _myWordPresenterImpl.completeDelete(output);
      return res;
    } catch (e) {
      return false;
    }
  }
}

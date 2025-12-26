import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/i_register_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/core/shared/utils/date_handler.dart';

class RegisterMyWordInteractor implements IRegisterMyWordUseCase {
  final IMyWordRepository _driftMyWordRepository;

  RegisterMyWordInteractor( this._driftMyWordRepository);

  @override
  Future<bool> execute(RegisterMyWordInputData input) async {
    String dateTime = getNowUTCDateHour();
    RegisterMyWordRepositoryInputData repositoryInput =
        RegisterMyWordRepositoryInputData(
            input.headword, input.description, dateTime);
    try {
      int myWordId = await _driftMyWordRepository.registerWord(repositoryInput);

      // RegisterMyWordOutputData output =
      //     RegisterMyWordOutputData(myWordId, input.headword, input.description);

      // _myWordFragmentPresenterImpl.completeRegistration(output);

      return true;
    } catch (e) {
      return false;
    }
  }
}

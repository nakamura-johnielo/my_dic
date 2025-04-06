import 'package:my_dic/_Business_Rule/Usecase/my_word/create/register_my_word/register_my_word_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/register_my_word/i_register_my_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/register_my_word/register_my_word_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/i_my_word_fragment_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/register_my_word/register_my_word_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_my_word_repository.dart';
import 'package:my_dic/utils/date_handler.dart';

class RegisterMyWordInteractor implements IRegisterMyWordUseCase {
  final IMyWordFragmentPresenter _myWordFragmentPresenterImpl;
  final IMyWordRepository _driftMyWordRepository;

  RegisterMyWordInteractor(
      this._myWordFragmentPresenterImpl, this._driftMyWordRepository);

  @override
  Future<bool> execute(RegisterMyWordInputData input) async {
    String dateTime = getNowUTCDateHour();
    RegisterMyWordRepositoryInputData repositoryInput =
        RegisterMyWordRepositoryInputData(
            input.headword, input.description, dateTime);
    try {
      int myWordId = await _driftMyWordRepository.registerWord(repositoryInput);

      RegisterMyWordOutputData output =
          RegisterMyWordOutputData(myWordId, input.headword, input.description);

      _myWordFragmentPresenterImpl.completeRegistration(output);

      return true;
    } catch (e) {
      return false;
    }
  }
}

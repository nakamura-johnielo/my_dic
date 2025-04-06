import 'package:my_dic/_Business_Rule/Usecase/my_word/update/handle_word_update/handle_word_update_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/update/handle_word_update/i_handle_word_update_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/update/handle_word_update/handle_word_update_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/update/handle_word_update/i_handle_word_update_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/update/handle_word_update/handle_word_update_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_my_word_repository.dart';

class HandleWordUpdateInteractor implements IHandleWordUpdateUseCase {
  final IHandleWordUpdatePresenter _handleWordUpdatePresenterImpl;
  final IMyWordRepository _driftHandleWordUpdateRepository;

  HandleWordUpdateInteractor(this._handleWordUpdatePresenterImpl,
      this._driftHandleWordUpdateRepository);

  @override
  void execute(HandleWordUpdateInputData input) {
    HandleWordUpdateRepositoryInputData repositoryInput =
        HandleWordUpdateRepositoryInputData(0);
    //Future<String> data0 = _driftHandleWordUpdateRepository.getBySometing(repositoryInput);
    Future<String> data1 = _driftHandleWordUpdateRepository.getById(input.id);
    HandleWordUpdateOutputData output = HandleWordUpdateOutputData(0);
    _handleWordUpdatePresenterImpl.execute(output);
  }
}

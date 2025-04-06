import 'package:my_dic/_Business_Rule/Usecase/my_word/delete/handle_word_delete/handle_word_delete_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/delete/handle_word_delete/i_handle_word_delete_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/delete/handle_word_delete/handle_word_delete_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/delete/handle_word_delete/i_handle_word_delete_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/delete/handle_word_delete/handle_word_delete_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_my_word_repository.dart';

class HandleWordDeleteInteractor implements IHandleWordDeleteUseCase {
  final IHandleWordDeletePresenter _handleWordDeletePresenterImpl;
  final IMyWordRepository _driftMyWordRepository;

  HandleWordDeleteInteractor(
      this._handleWordDeletePresenterImpl, this._driftMyWordRepository);

  @override
  void execute(HandleWordDeleteInputData input) {
    HandleWordDeleteRepositoryInputData repositoryInput =
        HandleWordDeleteRepositoryInputData(0);
    //Future<String> data0 = _driftMyWordRepository.getBySometing(repositoryInput);
    Future<String> data1 = _driftMyWordRepository.getById(input.id);
    HandleWordDeleteOutputData output = HandleWordDeleteOutputData(0);
    _handleWordDeletePresenterImpl.execute(output);
  }
}

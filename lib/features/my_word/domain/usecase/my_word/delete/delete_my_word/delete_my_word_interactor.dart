import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/i_delete_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/core/shared/utils/date_handler.dart';

class DeleteMyWordInteractor implements IDeleteMyWordUseCase {
  final IMyWordRepository _driftMyWordRepository;

  DeleteMyWordInteractor(this._driftMyWordRepository);

  @override
  Future<Result<void>> execute(DeleteMyWordInputData input) async {
    String dateTime = getNowUTCDateHour();

    DeleteMyWordRepositoryInputData repositoryInput =
        DeleteMyWordRepositoryInputData(input.id, dateTime,input.userId);

    return await _driftMyWordRepository.deleteWord(repositoryInput);
  }
}

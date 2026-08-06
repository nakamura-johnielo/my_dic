import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/i_delete_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';

class DeleteMyWordInteractor implements IDeleteMyWordUseCase {
  final IMyWordRepository _driftMyWordRepository;
  final CurrentSession _currentSession;

  DeleteMyWordInteractor(this._driftMyWordRepository, this._currentSession);

  @override
  Future<Result<void>> execute(DeleteMyWordInputData input) async {
    String dateTime = MyDateTime.getNowUTCDateHour().toIso8601String();

    final accountId = _currentSession.accountIdOrNull;

    DeleteMyWordRepositoryInputData repositoryInput =
        DeleteMyWordRepositoryInputData(input.id, dateTime, accountId);

    return await _driftMyWordRepository.deleteWord(repositoryInput);
  }
}

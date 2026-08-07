import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word_status/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word_status/update_my_word_status/update_my_word_status_input_data.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/domain/model/my_word_status/update_my_word_status_repository_input_data.dart';

class UpdateMyWordStatusInteractor implements IUpdateMyWordStatusUseCase {
  UpdateMyWordStatusInteractor(this._repository, this._currentSession);

  final IMyWordStatusRepository _repository;
  final CurrentSession _currentSession;

  @override
  Future<Result<void>> execute(UpdateMyWordStatusInputData input) {
    final command = UpdateMyWordStatusRepositoryInputData(
      input.wordId,
      input.isLearned,
      input.isBookmarked,
      input.hasNote,
      DateTime.now().toUtc(),
      _currentSession.accountIdOrNull,
    );
    return _repository.updateStatus(command);
  }
}

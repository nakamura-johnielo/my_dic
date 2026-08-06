import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/update_my_word_status/update_my_word_status_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/update_my_word_status/update_my_word_status_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_status_repository.dart';

class UpdateMyWordStatusInteractor implements IUpdateMyWordStatusUseCase {
  final IMyWordStatusRepository _myWordStatusRepository;
  final CurrentSession _currentSession;

  UpdateMyWordStatusInteractor(
      this._myWordStatusRepository, this._currentSession);

  @override
  Future<Result<void>> execute(UpdateMyWordStatusInputData input) async {
    try {
      final dateTime = DateTime.now().toUtc();

      final accountId = _currentSession.accountIdOrNull;

      UpdateMyWordStatusRepositoryInputData repositoryInput =
          UpdateMyWordStatusRepositoryInputData(input.wordId, input.isLearned,
              input.isBookmarked, input.hasNote, dateTime, accountId);

      return await _myWordStatusRepository.updateStatus(repositoryInput);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'ステータス更新に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }
}

import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word_status/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word_status/update_my_word_status/update_my_word_status_input_data.dart';
import 'package:my_dic/features/my_word/internal/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/internal/domain/inputData/my_word_status/update_my_word_status_repository_input_data.dart';

class UpdateMyWordStatusInteractor implements IUpdateMyWordStatusUseCase {
  UpdateMyWordStatusInteractor(this._repository);

  final IMyWordStatusRepository _repository;

  @override
  Future<Result<void>> execute(UpdateMyWordStatusInputData input) {
    final command = UpdateMyWordStatusRepositoryInputData(
      input.wordId,
      input.isLearned,
      input.isBookmarked,
      input.hasNote,
      DateTime.now().toUtc(),
      input.accountScope == guestAccountScope ? null : input.accountScope,
    );
    return _repository.updateStatus(command);
  }
}

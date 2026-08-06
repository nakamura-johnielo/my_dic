import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_input_data.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_repository_input_data.dart';

class UpdateStatusInteractor implements IUpdateStatusUseCase {
  final IWordStatusRepository _wordStatusRepository;
  final CurrentSession _currentSession;

  UpdateStatusInteractor(this._wordStatusRepository, this._currentSession);

  @override
  Future<Result<void>> execute(UpdateStatusInputData input) async {
    if (!input.hasChanges) {
      return const Result.success(null);
    }

    final dateTime = DateTime.now().toUtc();
    final accountId = _currentSession.accountIdOrNull;

    // Delivery to Firebase happens via the outbox mutation enqueued by
    // updateLocalWordStatus and consumed by EspJpnWordStatusSyncHandler, not
    // by this usecase directly.
    final localResult = await _wordStatusRepository.updateLocalWordStatus(
      UpdateStatusRepositoryInputData(
        wordId: input.wordId,
        isLearned: input.isLearned,
        isBookmarked: input.isBookmarked,
        hasNote: input.hasNote,
      ),
      dateTime,
      accountId: accountId,
    );

    if (localResult.isFailure) {
      return Result.failure(localResult.errorOrNull!);
    }

    return const Result.success(null);
  }
}

import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/i_jpn_esp_word_status_repository.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_input_data.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/i_update_jpn_esp_status_use_case.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_repository_input_data.dart';

class UpdateJpnEspStatusInteractor implements IUpdateJpnEspStatusUseCase {
  final IJpnEspWordStatusRepository _wordStatusRepository;
  final CurrentSession _currentSession;

  UpdateJpnEspStatusInteractor(
      this._wordStatusRepository, this._currentSession);

  @override
  Future<Result<void>> execute(UpdateJpnEspStatusInputData input) async {
    if (!input.hasChanges) {
      return const Result.success(null);
    }

    final dateTime = DateTime.now().toUtc();

    // Update local first
    final localResult = await _wordStatusRepository.updateLocalWordStatus(
      UpdateJpnEspStatusRepositoryInputData(
        wordId: input.wordId,
        isLearned: input.isLearned,
        isBookmarked: input.isBookmarked,
        hasNote: input.hasNote,
      ),
      dateTime,
    );

    // Return error immediately if local update failed
    if (localResult.isFailure) {
      return Result.failure(localResult.errorOrNull!);
    }
    final updatedStatus = localResult.dataOrNull!;

    // Update remote only for logged-in users
    final accountId = _currentSession.accountIdOrNull;

    if (accountId != null) {
      final remoteResult = await _wordStatusRepository.updateRemoteWordStatus(
          updatedStatus, accountId, dateTime);

      // Remote failure is logged but local is already updated
      if (remoteResult.isFailure) {
        AppLogger.print(
            'Remote jpn_esp status update failed: ${remoteResult.errorOrNull?.message}');
        // Treat remote failure as warning, return success (local is updated)
        // Can sync later if needed
      }
    }

    return const Result.success(null);
  }
}
